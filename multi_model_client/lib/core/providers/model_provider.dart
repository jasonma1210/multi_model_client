/// 模型 Provider - LLM Studio 模型状态管理模块
/// 
/// 功能：
/// - 模型列表状态管理
/// - 模型持久化存储
/// - 模型 CRUD 操作
/// - SharedPreferences 集成
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/model_entry.dart';

const _kModelsKey = 'saved_models_v2';

/// 模型列表状态
class ModelState {
  final List<ModelEntry> models;
  final bool isLoading;
  final String? error;

  const ModelState({
    this.models = const [],
    this.isLoading = false,
    this.error,
  });

  ModelState copyWith({
    List<ModelEntry>? models,
    bool? isLoading,
    String? error,
  }) {
    return ModelState(
      models: models ?? this.models,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 是否一个可用模型都没有
  bool get isEmpty => models.isEmpty;

  /// 本地模型列表
  List<ModelEntry> get localModels => models.where((m) => m.isLocal).toList();

  /// 远程/Ollama 模型列表
  List<ModelEntry> get remoteModels => models.where((m) => m.isRemote).toList();

  /// 当前已加载的本地模型
  ModelEntry? get loadedModel {
    try {
      return models.firstWhere((m) => m.isLocal && m.isLoaded);
    } catch (_) {
      return null;
    }
  }
}

/// 模型列表 Notifier
class ModelNotifier extends StateNotifier<ModelState> {
  final _uuid = const Uuid();
  SharedPreferences? _prefs;

  ModelNotifier() : super(const ModelState(isLoading: true)) {
    _loadModels();
  }

  Future<void> _loadModels() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(_kModelsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        final models = list
            .map((e) => ModelEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        state = ModelState(models: models);
      } else {
        state = const ModelState(models: []);
      }
    } catch (e) {
      state = ModelState(error: e.toString());
    }
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    final raw = jsonEncode(state.models.map((m) => m.toJson()).toList());
    await _prefs!.setString(_kModelsKey, raw);
  }

  /// 添加远程模型
  Future<ModelEntry> addRemoteModel({
    required String displayName,
    required RemoteModelConfig config,
  }) async {
    final entry = ModelEntry(
      id: _uuid.v4(),
      displayName: displayName,
      type: config.protocol == RemoteProtocol.ollama ? ModelType.ollama : ModelType.remote,
      remoteConfig: config,
    );
    state = state.copyWith(models: [...state.models, entry]);
    await _persist();
    return entry;
  }

  /// 注册已下载的本地模型
  Future<ModelEntry> addLocalModel({
    required String displayName,
    required String filePath,
    int? parameterSize,
    String? quantLevel,
    String? description,
  }) async {
    final entry = ModelEntry(
      id: _uuid.v4(),
      displayName: displayName,
      type: ModelType.local,
      filePath: filePath,
      localParams: const LocalModelParams(),
      parameterSize: parameterSize,
      quantLevel: quantLevel,
      description: description,
    );
    state = state.copyWith(models: [...state.models, entry]);
    await _persist();
    return entry;
  }

  /// 更新本地模型参数
  Future<void> updateLocalParams(String modelId, LocalModelParams params) async {
    final updated = state.models.map((m) {
      if (m.id == modelId) {
        return m.copyWith(localParams: params);
      }
      return m;
    }).toList();
    state = state.copyWith(models: updated);
    await _persist();
  }

  /// 更新远程模型配置
  /// [displayName] 可选，用于更新模型显示名称
  Future<void> updateRemoteConfig(String modelId, RemoteModelConfig config, {String? displayName}) async {
    final updated = state.models.map((m) {
      if (m.id == modelId) {
        return m.copyWith(
          remoteConfig: config,
          displayName: displayName,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(models: updated);
    await _persist();
  }

  /// 标记模型为已加载
  void setModelLoaded(String modelId, bool loaded) {
    final updated = state.models.map((m) {
      if (m.isLocal) {
        // 卸载其他已加载的本地模型
        if (m.id == modelId) {
          return m.copyWith(isLoaded: loaded);
        } else if (loaded) {
          return m.copyWith(isLoaded: false);
        }
      }
      return m;
    }).toList();
    state = state.copyWith(models: updated);
    // 加载状态不持久化，重启后重新加载
  }

  /// 删除模型
  Future<void> deleteModel(String modelId) async {
    state = state.copyWith(
      models: state.models.where((m) => m.id != modelId).toList(),
    );
    await _persist();
  }

  /// 扫描下载目录并注册本地模型（gguf 文件）
  Future<void> scanDownloadedModels() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/models');
      if (!await modelsDir.exists()) return;

      final existingPaths = state.models
          .where((m) => m.isLocal && m.filePath != null)
          .map((m) => m.filePath!)
          .toSet();

      final newEntries = <ModelEntry>[];
      await for (final entity in modelsDir.list(recursive: true)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.gguf')) {
          if (!existingPaths.contains(entity.path)) {
            final fileName = entity.path.split('/').last;
            final displayName = fileName.replaceAll('.gguf', '').replaceAll('_', ' ');
            newEntries.add(ModelEntry(
              id: _uuid.v4(),
              displayName: displayName,
              type: ModelType.local,
              filePath: entity.path,
              localParams: const LocalModelParams(),
            ));
          }
        }
      }

      if (newEntries.isNotEmpty) {
        state = state.copyWith(models: [...state.models, ...newEntries]);
        await _persist();
      }
    } catch (e) {
      // 扫描失败不影响主流程
    }
  }
}

/// 全局模型 Provider
final modelProvider = StateNotifierProvider<ModelNotifier, ModelState>((ref) {
  return ModelNotifier();
});

/// 便捷 Provider：当前是否有模型
final hasAnyModelProvider = Provider<bool>((ref) {
  return ref.watch(modelProvider).models.isNotEmpty;
});

/// 便捷 Provider：可供会话使用的所有模型
final availableModelsProvider = Provider<List<ModelEntry>>((ref) {
  return ref.watch(modelProvider).models;
});
