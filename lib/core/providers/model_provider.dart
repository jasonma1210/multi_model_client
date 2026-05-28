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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/model_entry.dart';
import '../services/security_bookmark_service.dart';
import '../services/model_path_cache.dart';
import '../storage/database_connection.dart';
import '../services/model_download/download_task_manager.dart';

const _kModelsKey = 'saved_models_v2';

/// 下载任务数量 Provider
/// 监听 DownloadTaskManager 的进度通知器，返回当前下载中的任务数量
final downloadingCountProvider = Provider<int>((ref) {
  final taskManager = DownloadTaskManager.instance;
  final tasks = taskManager.progressNotifier.value;
  
  // 计算正在下载或待处理的任务数量
  int count = 0;
  for (final entry in tasks.entries) {
    final progress = entry.value;
    if (progress.status == DownloadStatus.downloading || 
        progress.status == DownloadStatus.pending) {
      count++;
    }
  }
  
  return count;
});

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

  /// 本地模型列表（过滤掉 mmproj 文件）
  List<ModelEntry> get localModels => models
      .where((m) => m.isLocal && !(m.filePath?.startsWith('mmproj') ?? false))
      .toList();

  /// mmproj 投影仪文件列表（显示但不可直接加载）
  List<ModelEntry> get mmprojModels => models
      .where((m) => m.isLocal && (m.filePath?.startsWith('mmproj') ?? false))
      .toList();

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
        var models = list
            .map((e) => ModelEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        
        // 修复：移除模型路径中的重复目录名
        // 旧路径格式：/path/to/model.gguf/model.gguf → 新路径：/path/to/model.gguf
        models = models.map((m) {
          if (m.isLocal && m.filePath != null) {
            final path = m.filePath!;
            // 检查是否包含重复的 .gguf 路径（目录名和文件名都是 .gguf）
            final ggufDirIdx = path.indexOf('.gguf/');
            final ggufDirIdxWin = path.indexOf('.gguf\\');
            final idx = ggufDirIdx >= 0 ? ggufDirIdx : ggufDirIdxWin;
            if (idx > 0) {
              // 截取到第一个 .gguf 为止（保留完整目录路径）
              final fixedPath = path.substring(0, idx + 5);
              if (fixedPath != path) {
                debugPrint('[ModelProvider] 修复模型路径: $path → $fixedPath');
                return m.copyWith(filePath: fixedPath);
              }
            }
          }
          return m;
        }).toList();
        
        state = ModelState(models: models);
        
        // 打印所有本地模型（调试用）
        for (final m in models.where((m) => m.isLocal)) {
          debugPrint('[ModelProvider] 本地模型: ${m.displayName}, filePath: ${m.filePath}, isMultimodal: ${m.isMultimodal}, mmprojFileName: ${m.mmprojFileName}');
        }
        
        // 保存修复后的路径
        await _persist();
        
        // 对缺少 mmprojFileName 的多模态模型，尝试自动从 models 目录关联
        await _autoLinkMmprojFiles();
      } else {
        state = const ModelState(models: []);
      }
    } catch (e) {
      state = ModelState(error: e.toString());
    }
  }

  /// 自动关联 mmproj 文件：
  /// 扫描所有模型目录，为 mmprojFileName 为 null 的本地模型
  /// 尝试匹配目录下的 mmproj 文件（支持多种命名模式）
  /// 
  /// 平台差异化：
  /// - macOS/Windows/Linux（桌面端）：允许访问外部路径和自定义下载路径
  /// - iOS/Android（移动端）：仅允许沙盒内的路径
  Future<void> _autoLinkMmprojFiles() async {
    try {
      // 收集所有模型目录
      final dirs = <String>[];
      final appDir = await getApplicationDocumentsDirectory();
      dirs.add('${appDir.path}/models');
      
      // 添加自定义下载路径（仅桌面端：macOS/Windows/Linux）
      // 移动端（iOS/Android）由于安全沙箱限制，不允许访问外部路径
      if (_isDesktopPlatform()) {
        final customPath = _prefs?.getString('download_path');
        if (customPath != null && customPath.isNotEmpty) {
          final customDir = Directory(customPath);
          if (await customDir.exists()) {
            dirs.add(customPath);
          }
        }
        
        // 添加所有本地模型所在的目录（支持外部路径模型的 mmproj 匹配）
        for (final model in state.models) {
          if (model.isLocal && model.filePath != null) {
            final lastSlash = model.filePath!.lastIndexOf('/');
            if (lastSlash > 0) {
              final modelDir = model.filePath!.substring(0, lastSlash);
              if (!dirs.contains(modelDir)) {
                final dir = Directory(modelDir);
                if (await dir.exists()) {
                  dirs.add(modelDir);
                }
              }
            }
          }
        }
      }
      
      // 收集所有 mmproj 文件（递归搜索所有目录）
      final mmprojFiles = <String, String>{}; // 文件名 -> 完整路径
      for (final dirPath in dirs) {
        final dir = Directory(dirPath);
        if (!await dir.exists()) continue;
        // macOS 沙盒：扫描外部目录前先获取访问权限
        bool hasAccess = true;
        if (Platform.isMacOS) {
          hasAccess = await SecurityBookmarkService.instance.startAccessing(dirPath);
        }
        try {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File) {
              final name = entity.path.split('/').last;
              if (name.toLowerCase().contains('mmproj') && name.endsWith('.gguf')) {
                mmprojFiles[name] = entity.path;
                debugPrint('[ModelProvider] 发现 mmproj 文件: $name');
              }
            }
          }
        } catch (e) {
          debugPrint('[ModelProvider] 扫描目录失败（可能无沙盒权限）: $dirPath - $e');
        } finally {
          if (Platform.isMacOS && hasAccess) {
            await SecurityBookmarkService.instance.stopAccessing(dirPath);
          }
        }
      }

      if (mmprojFiles.isEmpty) {
        debugPrint('[ModelProvider] 没有发现 mmproj 文件');
        return;
      }
      debugPrint('[ModelProvider] 共发现 ${mmprojFiles.length} 个 mmproj 文件');

      bool changed = false;
      final updatedModels = state.models.map((m) {
        if (!m.isLocal || m.mmprojFileName != null) return m;

        final modelName = (m.filePath ?? m.displayName).toLowerCase();
        final modelBaseName = _extractModelBaseName(modelName);

        // 匹配策略 1：精确前缀匹配（mmproj-{name}.gguf）
        String? matched;
        for (final entry in mmprojFiles.entries) {
          final fLower = entry.key.toLowerCase();
          if (fLower.startsWith('mmproj') && fLower.contains(modelBaseName)) {
            matched = entry.key;
            debugPrint('[ModelProvider] mmproj 前缀匹配: ${m.displayName} -> ${entry.key}');
            break;
          }
        }

        // 匹配策略 2：中缀匹配（{name}-mmproj-{suffix}.gguf）
        if (matched == null) {
          final modelPrefix = _extractModelPrefix(modelBaseName);
          if (modelPrefix.isNotEmpty) {
            for (final entry in mmprojFiles.entries) {
              final fLower = entry.key.toLowerCase();
              if (fLower.contains('mmproj') && fLower.contains(modelPrefix)) {
                matched = entry.key;
                debugPrint('[ModelProvider] mmproj 中缀匹配: ${m.displayName} -> ${entry.key} (prefix=$modelPrefix)');
                break;
              }
            }
          }
        }

        // 匹配策略 3：同目录匹配
        if (matched == null && m.filePath != null) {
          final lastSlash = m.filePath!.lastIndexOf('/');
          if (lastSlash > 0) {
            final modelDir = m.filePath!.substring(0, lastSlash);
            for (final entry in mmprojFiles.entries) {
              final mmprojLastSlash = entry.value.lastIndexOf('/');
              if (mmprojLastSlash > 0) {
                final mmprojDir = entry.value.substring(0, mmprojLastSlash);
                if (mmprojDir == modelDir) {
                  matched = entry.key;
                  debugPrint('[ModelProvider] mmproj 同目录匹配: ${m.displayName} -> ${entry.key}');
                  break;
                }
              }
            }
          }
        }

        // Fallback: 如果只有一个 mmproj 文件，就关联它
        if (matched == null && mmprojFiles.length == 1) {
          matched = mmprojFiles.keys.first;
          debugPrint('[ModelProvider] Fallback 关联: ${m.displayName} -> $matched');
        }

        if (matched != null) {
          changed = true;
          return m.copyWith(mmprojFileName: matched, isMultimodal: true);
        }
        return m;
      }).toList();

      if (changed) {
        debugPrint('[ModelProvider] 关联完成，保存到 SharedPreferences');
        state = state.copyWith(models: updatedModels);
        await _persist();
      }
    } catch (e) {
      debugPrint('[ModelProvider] _autoLinkMmprojFiles 失败: $e');
    }
  }

  /// 从模型文件名中提取基础名称（去掉路径和扩展名）
  String _extractModelBaseName(String modelName) {
    // 提取文件名部分
    String name = modelName;
    if (name.contains('/')) {
      name = name.split('/').last;
    }
    if (name.endsWith('.gguf')) {
      name = name.substring(0, name.length - 5);
    }
    return name.toLowerCase();
  }

  /// 从模型文件名中提取共同前缀（去掉量化级别、版本后缀等）
  String _extractModelPrefix(String modelName) {
    final lower = modelName.toLowerCase();
    final suffixPatterns = [
      '-q4_0', '-q4_1', '-q4_k_s', '-q4_k_m', '-q4_k_l',
      '-q5_0', '-q5_1', '-q5_k_s', '-q5_k_m',
      '-q6_k', '-q8_0', '-iq4_xs', '-iq4_nl',
      '-bf16', '-fp16', '-f32',
      '-ultra', '-uncensored', '-heretic',
      '-instruct',
    ];
    
    String prefix = lower;
    for (final pattern in suffixPatterns) {
      final idx = prefix.indexOf(pattern);
      if (idx > 0) {
        prefix = prefix.substring(0, idx);
        break;
      }
    }
    
    if (prefix.length < 5) return '';
    return prefix;
  }

  /// 判断是否为桌面平台（macOS/Windows/Linux）
  /// 桌面平台支持外部路径访问，移动端（iOS/Android）受沙盒限制
  bool _isDesktopPlatform() {
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
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
    bool? isMultimodal,
  }) async {
    final entry = ModelEntry(
      id: _uuid.v4(),
      displayName: displayName,
      type: config.protocol == RemoteProtocol.ollama ? ModelType.ollama : ModelType.remote,
      remoteConfig: config,
      isMultimodal: isMultimodal,
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
    bool? isMultimodal,
    String? mmprojFileName,
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
      isMultimodal: isMultimodal,
      mmprojFileName: mmprojFileName,
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
  /// [isMultimodal] 可选，用于更新多模态支持状态
  Future<void> updateRemoteConfig(String modelId, RemoteModelConfig config, {String? displayName, bool? isMultimodal}) async {
    final updated = state.models.map((m) {
      if (m.id == modelId) {
        return m.copyWith(
          remoteConfig: config,
          displayName: displayName,
          isMultimodal: isMultimodal,
        );
      }
      return m;
    }).toList();
    state = state.copyWith(models: updated);
    await _persist();
  }

  /// ★★★ 更新模型的 Reasoning 开关（本地/远程通用）★★★
  ///
  /// 远程模型没有 localParams，使用 ModelEntry 顶级 enableReasoning 字段存储
  Future<void> updateEnableReasoning(String modelId, bool enable) async {
    final updated = state.models.map((m) {
      if (m.id == modelId) {
        if (m.isLocal && m.localParams != null) {
          // 本地模型：同时更新 localParams.enableReasoning 和顶级字段
          return m.copyWith(
            localParams: m.localParams!.copyWith(enableReasoning: enable),
            enableReasoning: enable,
          );
        } else {
          // 远程模型：只更新顶级字段
          return m.copyWith(enableReasoning: enable);
        }
      }
      return m;
    }).toList();
    state = state.copyWith(models: updated);
    await _persist();
  }

  /// 更新本地模型的多模态支持状态
  Future<void> updateLocalModelMultimodal(String modelId, bool isMultimodal) async {
    final updated = state.models.map((m) {
      if (m.id == modelId) {
        return m.copyWith(isMultimodal: isMultimodal);
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

  /// 删除模型（同时删除本地模型文件和关联会话）
  Future<void> deleteModel(String modelId) async {
    // 找到要删除的模型，获取文件路径
    final modelToDelete = state.models.where((m) => m.id == modelId).firstOrNull;
    
    // 删除模型文件（如果存在本地文件路径）
    if (modelToDelete != null && modelToDelete.filePath != null) {
      final filePath = modelToDelete.filePath!;
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('[ModelProvider] 已删除模型文件: $filePath');
        }
      } catch (e) {
        debugPrint('[ModelProvider] 删除模型文件失败: $e');
      }
    }
    
    // 删除使用该模型的所有会话
    await _deleteSessionsByModelId(modelId);
    
    // 从列表中移除
    state = state.copyWith(
      models: state.models.where((m) => m.id != modelId).toList(),
    );
    await _persist();
    
    // 清除路径缓存，确保后续查找不会命中已删除的文件
    ModelPathCache.instance.invalidate();
  }

  /// 仅删除模型关联的会话（不删除模型文件和模型记录）
  /// 用于模型管理页面中删除模型时，只清理会话
  Future<int> deleteModelSessionsOnly(String modelId) async {
    return await _deleteSessionsByModelId(modelId);
  }

  /// 删除使用指定模型的所有会话（内部方法）
  /// 同时级联删除每个会话的消息，避免孤立数据
  Future<int> _deleteSessionsByModelId(String modelId) async {
    int deletedCount = 0;
    try {
      final db = database;
      final allSessions = await db.getAllSessions();
      final sessionsToDelete = allSessions.where((s) => s.modelId == modelId).toList();
      
      for (final session in sessionsToDelete) {
        // 级联删除：先删消息再删会话
        await db.deleteSessionWithMessages(session.id);
        deletedCount++;
      }
      
      if (sessionsToDelete.isNotEmpty) {
        debugPrint('[ModelProvider] 共删除 $deletedCount 个关联会话（含消息）');
      }
    } catch (e) {
      debugPrint('[ModelProvider] 删除关联会话失败: $e');
    }
    return deletedCount;
  }

  /// 仅从模型列表中移除模型记录（不删除文件和会话）
  Future<void> removeModelFromList(String modelId) async {
    state = state.copyWith(
      models: state.models.where((m) => m.id != modelId).toList(),
    );
    await _persist();
  }

  /// 扫描当前配置的模型目录并注册本地模型（gguf 文件）
  /// 同时清理文件已不存在的本地模型条目
  Future<void> scanDownloadedModels() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      
      // 获取当前有效的模型目录（自定义路径或默认路径）
      final customPath = _prefs!.getString('download_path');
      String modelsDirPath;
      if (customPath != null && customPath.isNotEmpty) {
        modelsDirPath = customPath;
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        modelsDirPath = '${appDir.path}/models';
      }
      
      final modelsDir = Directory(modelsDirPath);
      if (!await modelsDir.exists()) return;

      // 清理：移除文件已不存在的本地模型
      final validModels = <ModelEntry>[];
      for (final model in state.models) {
        if (model.isLocal && model.filePath != null) {
          final file = File(model.filePath!);
          if (await file.exists()) {
            validModels.add(model);
          } else {
            debugPrint('[ModelProvider] 清理不存在的模型: ${model.displayName} (${model.filePath})');
          }
        } else {
          validModels.add(model);
        }
      }
      
      if (validModels.length != state.models.length) {
        state = state.copyWith(models: validModels);
        await _persist();
      }

      // 扫描当前目录下的新模型
      final existingPaths = state.models
          .where((m) => m.isLocal && m.filePath != null)
          .map((m) => m.filePath!)
          .toSet();

      // macOS 沙盒：扫描外部目录前先获取访问权限
      final bool hasDirAccess;
      if (Platform.isMacOS) {
        hasDirAccess = await SecurityBookmarkService.instance.startAccessing(modelsDirPath);
      } else {
        hasDirAccess = true;
      }

      final newEntries = <ModelEntry>[];
      try {
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
      } finally {
        if (Platform.isMacOS && hasDirAccess) {
          await SecurityBookmarkService.instance.stopAccessing(modelsDirPath);
        }
      }

      if (newEntries.isNotEmpty) {
        state = state.copyWith(models: [...state.models, ...newEntries]);
        await _persist();
        await _autoLinkMmprojFiles();
      }
    } catch (e) {
      debugPrint('[model_provider] Error: $e');
    }
  }

  /// 递归扫描指定目录，发现的 gguf 文件自动注册到模型列表
  /// 返回新发现并注册的模型数量
  Future<int> scanDirectoryForModels(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return 0;

      // macOS 沙盒：扫描外部目录前先获取访问权限
      final bool hasDirAccess;
      if (Platform.isMacOS) {
        hasDirAccess = await SecurityBookmarkService.instance.startAccessing(dirPath);
      } else {
        hasDirAccess = true;
      }

      final existingPaths = state.models
          .where((m) => m.isLocal && m.filePath != null)
          .map((m) => m.filePath!)
          .toSet();

      final newEntries = <ModelEntry>[];
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && entity.path.toLowerCase().endsWith('.gguf')) {
            final fileName = entity.path.split('/').last;
            if (fileName.toLowerCase().contains('mmproj')) continue;
            
            if (!existingPaths.contains(entity.path)) {
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
      } finally {
        if (Platform.isMacOS && hasDirAccess) {
          await SecurityBookmarkService.instance.stopAccessing(dirPath);
        }
      }

      if (newEntries.isNotEmpty) {
        state = state.copyWith(models: [...state.models, ...newEntries]);
        await _persist();
        
        // 清除路径缓存，确保新模型可被发现
        ModelPathCache.instance.invalidate();
        
        // 自动关联 mmproj 文件
        await _autoLinkMmprojFiles();
      }

      debugPrint('[ModelProvider] 扫描目录 $dirPath 完成，新增 ${newEntries.length} 个模型');
      return newEntries.length;
    } catch (e) {
      debugPrint('[ModelProvider] 扫描目录失败: $e');
      return 0;
    }
  }

  /// 切换模型目录时刷新模型列表：
  /// 1. 移除不属于新目录的所有本地模型（仅保留远程模型和新目录下的模型）
  /// 2. 扫描新目录并注册新模型
  /// 返回新发现并注册的模型数量
  Future<int> refreshModelsForDirectory(String newDirPath) async {
    try {
      final newDir = Directory(newDirPath);
      if (!await newDir.exists()) return 0;

      // 过滤模型：仅保留远程模型和新目录下的本地模型
      // 切换目录后，之前所有目录下的本地模型都不再显示
      final keptModels = <ModelEntry>[];
      final removedModels = <ModelEntry>[];
      
      for (final model in state.models) {
        if (model.isRemote) {
          keptModels.add(model);
        } else if (model.filePath == null) {
          keptModels.add(model);
        } else if (model.filePath!.startsWith(newDirPath)) {
          keptModels.add(model);
        } else {
          removedModels.add(model);
        }
      }

      if (removedModels.isNotEmpty) {
        debugPrint('[ModelProvider] 切换目录，移除 ${removedModels.length} 个旧目录模型');
        for (final m in removedModels) {
          debugPrint('[ModelProvider]   移除: ${m.displayName} (${m.filePath})');
        }
      }

      // macOS 沙盒：扫描新目录前先获取访问权限
      final bool hasDirAccess;
      if (Platform.isMacOS) {
        hasDirAccess = await SecurityBookmarkService.instance.startAccessing(newDirPath);
      } else {
        hasDirAccess = true;
      }

      // 扫描新目录
      final existingPaths = keptModels
          .where((m) => m.isLocal && m.filePath != null)
          .map((m) => m.filePath!)
          .toSet();

      final newEntries = <ModelEntry>[];
      try {
        await for (final entity in newDir.list(recursive: true)) {
          if (entity is File && entity.path.toLowerCase().endsWith('.gguf')) {
            final fileName = entity.path.split('/').last;
            if (fileName.toLowerCase().contains('mmproj')) continue;
            
            if (!existingPaths.contains(entity.path)) {
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
      } finally {
        if (Platform.isMacOS && hasDirAccess) {
          await SecurityBookmarkService.instance.stopAccessing(newDirPath);
        }
      }

      // 更新状态
      state = state.copyWith(models: [...keptModels, ...newEntries]);
      await _persist();

      // 清除路径缓存
      ModelPathCache.instance.invalidate();

      // 自动关联 mmproj 文件
      await _autoLinkMmprojFiles();

      debugPrint('[ModelProvider] 目录切换完成：保留 ${keptModels.length} 个模型，新增 ${newEntries.length} 个模型');
      return newEntries.length;
    } catch (e) {
      debugPrint('[ModelProvider] 刷新目录失败: $e');
      return 0;
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

/// 便捷 Provider：可供会话使用的所有模型（已下载完成的本地模型 + 远程模型）
final availableModelsProvider = Provider<List<ModelEntry>>((ref) {
  final modelState = ref.watch(modelProvider);
  
  // 监听下载进度，过滤掉仍在下载中的本地模型
  final downloadProgress = DownloadTaskManager.instance.progressNotifier.value;
  
  return modelState.models.where((model) {
    // 远程模型始终可用
    if (model.isRemote) return true;
    
    // 本地模型：检查是否仍在下载中
    if (model.isLocal) {
      // 遍历下载进度，查找是否有对应的下载任务且状态不是 completed
      for (final entry in downloadProgress.entries) {
        final progress = entry.value;
        // 如果进度信息的 modelId 匹配此模型，且状态不是 completed，则隐藏
        if (progress.modelId == model.id && 
            progress.status != DownloadStatus.completed) {
          return false;
        }
      }
    }
    
    return true;
  }).toList();
});

/// 已下载完成的本地模型 Provider（排除 mmproj 文件）
final completedLocalModelsProvider = Provider<List<ModelEntry>>((ref) {
  final allModels = ref.watch(availableModelsProvider);
  return allModels
      .where((m) => m.isLocal && !(m.filePath?.startsWith('mmproj') ?? false))
      .toList();
});

/// 下载中的模型列表 Provider
final downloadingModelsProvider = Provider<List<ModelEntry>>((ref) {
  final modelState = ref.watch(modelProvider);
  final downloadProgress = DownloadTaskManager.instance.progressNotifier.value;
  
  return modelState.models.where((model) {
    if (!model.isLocal) return false;
    
    for (final entry in downloadProgress.entries) {
      final progress = entry.value;
      if (progress.modelId == model.id && 
          progress.status != DownloadStatus.completed) {
        return true;
      }
    }
    return false;
  }).toList();
});
