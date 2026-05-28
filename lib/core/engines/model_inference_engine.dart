/// 模型推理引擎 - LLM Studio 核心推理模块
/// 
/// 负责：
/// - 本地模型推理（Ollama API / llama.cpp FFI）
/// - 远程模型推理（OpenAI / Anthropic API）
/// - 流式响应处理
/// - 模型配置管理
/// 
/// 支持的推理后端：
/// - Ollama（本地，支持 Metal/CUDA/Vulkan 加速）
/// - llama.cpp FFI（本地，支持 Metal/CUDA 加速）
/// - OpenAI API（远程）
/// - Anthropic API（远程）
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/model_interface.dart' show IModelManager, ModelInfo, ModelCapabilities, ModelLoadingState, LoadingStatus, ModelDownloadConfig;
import '../models/model_entry.dart';
import '../platform/platform_utils.dart';
import 'local_ffi_engine.dart' show LocalFFIEngine;

const _kModelsKey = 'saved_models_v2';

/// 清洗 AI 输出中的思考标签
/// 当 enableReasoning=false 时调用，防止 <|channel>thought、Thinking Process: 等标签出现在 UI 中
String _cleanThinkTags(String text) {
  if (text.isEmpty) return text;
  
  // 模式1: <|channel>thought...\思考内容\ vaping 或 <|channel|>
  // 使用非贪婪匹配，防止跨行问题
  var cleaned = text.replaceAll(
    RegExp(r'<\|channel\|>thought[\s\S]*?<\/?vaping', multiLine: true),
    '',
  );
  // 也匹配没有结束标签的情况（思考标签不完整时）
  cleaned = cleaned.replaceAll(
    RegExp(r'<\|channel\|>thought[\s\S]*?$', multiLine: true),
    '',
  );
  
  // 模式2: <|channel|>
  cleaned = cleaned.replaceAll('<|channel|>', '');
  
  // 模式3: Thinking Process:... （单行）
  cleaned = cleaned.replaceAll(
    RegExp(r'Thinking Process:\s*', multiLine: true),
    '',
  );
  
  // 模式4: 清除所有 <|...|> 格式的 XML-like 标签
  cleaned = cleaned.replaceAll(
    RegExp(r'<\|[^|]*\|>'),
    '',
  );
  
  return cleaned.trim();
}

// ════════════════════════════════════════════════════════════════════════════
//  全局单例：确保 ModelLoadPage 和 DialogueEngine 共用同一实例
// ════════════════════════════════════════════════════════════════════════════

final _globalModelEngine = ModelInferenceEngine._();

/// 获取全局 ModelInferenceEngine 实例
ModelInferenceEngine get globalModelEngine => _globalModelEngine;

// ════════════════════════════════════════════════════════════════════════════
//  结构化聊天消息
// ════════════════════════════════════════════════════════════════════════════

/// 图片数据（多模态使用）
class ChatImageData {
  final String base64Data; // base64 编码的图片数据
  final String mimeType;   // 如 'image/jpeg', 'image/png'

  const ChatImageData({required this.base64Data, required this.mimeType});
}

/// 聊天消息（结构化，替代纯文本 prompt）
///
/// 支持多模态：当 [images] 非空时，[toJson] 生成 OpenAI vision 格式
/// （content 为数组：[{type:text,...}, {type:image_url,...}, ...]）
class ChatMessage {
  final String role; // 'system', 'user', 'assistant'
  final String content;
  /// 附带的图片数据（多模态场景，仅 user 消息有效）
  final List<ChatImageData> images;

  const ChatMessage({
    required this.role,
    required this.content,
    this.images = const [],
  });

  bool get hasImages => images.isNotEmpty;

  /// OpenAI 格式序列化
  /// 无图片 → {'role': ..., 'content': '...'} （纯文本，兼容旧模型）
  /// 有图片 → {'role': ..., 'content': [{type:'text',...}, {type:'image_url',...},...]}
  Map<String, dynamic> toJson() {
    if (!hasImages) {
      return {'role': role, 'content': content};
    }
    final contentArray = <Map<String, dynamic>>[];
    if (content.isNotEmpty) {
      contentArray.add({'type': 'text', 'text': content});
    }
    for (final img in images) {
      contentArray.add({
        'type': 'image_url',
        'image_url': {'url': 'data:${img.mimeType};base64,${img.base64Data}'},
      });
    }
    return {'role': role, 'content': contentArray};
  }

  /// Anthropic 格式序列化（content 结构不同）
  /// 无图片 → {'role': ..., 'content': '...'} （纯文本兼容）
  /// 有图片 → {'role': ..., 'content': [{type:'text',...}, {type:'image', source:{...}}, ...]}
  Map<String, dynamic> toAnthropicJson() {
    if (!hasImages) {
      return {'role': role, 'content': content};
    }
    final contentArray = <Map<String, dynamic>>[];
    // Anthropic 要求图片放在文字前面
    for (final img in images) {
      contentArray.add({
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': img.mimeType,
          'data': img.base64Data,
        },
      });
    }
    if (content.isNotEmpty) {
      contentArray.add({'type': 'text', 'text': content});
    }
    return {'role': role, 'content': contentArray};
  }

  /// Ollama 格式序列化（Ollama /api/chat 专用）
  ///
  /// 格式与 OpenAI 不同：
  /// - 文本：{'type':'text', 'text': '...'}
  /// - 图片：{'type':'image', 'image': '`<base64_data>`'}
  /// （注意：不是 'image_url'，也不带 data:image/... 前缀）
  Map<String, dynamic> toOllamaJson() {
    if (!hasImages) {
      return {'role': role, 'content': content};
    }
    final contentArray = <Map<String, dynamic>>[];
    // Ollama 图片格式：base64 数据不带 data:... 前缀
    for (final img in images) {
      contentArray.add({'type': 'image', 'image': img.base64Data});
    }
    if (content.isNotEmpty) {
      contentArray.add({'type': 'text', 'text': content});
    }
    return {'role': role, 'content': contentArray};
  }

  factory ChatMessage.system(String content) =>
      ChatMessage(role: 'system', content: content);
  factory ChatMessage.user(String content, {List<ChatImageData> images = const []}) =>
      ChatMessage(role: 'user', content: content, images: images);
  factory ChatMessage.assistant(String content) =>
      ChatMessage(role: 'assistant', content: content);
}

/// 聊天选项（统一采样参数，兼容 OpenAI / Anthropic / Ollama）
class ChatOptions {
  final double? temperature;
  final double? topP;
  final int? topK;
  final int? maxTokens;
  final double? repeatPenalty;
  final String? stop;
  final int? numCtx; // Ollama 专用：上下文窗口大小
  final int? numPredict; // Ollama 专用：最大预测 token 数
  final bool? enableReasoning; // 思考模式：启用 Chain-of-Thought

  const ChatOptions({
    this.temperature,
    this.topP,
    this.topK,
    this.maxTokens,
    this.repeatPenalty,
    this.stop,
    this.numCtx,
    this.numPredict,
    this.enableReasoning,
  });

  /// 从 LocalModelParams 创建
  factory ChatOptions.fromLocalParams(LocalModelParams params) {
    return ChatOptions(
      temperature: params.temperature,
      topP: params.topPEnabled ? params.topP : null,
      topK: params.topK,
      maxTokens: params.maxTokens,
      repeatPenalty:
          params.repeatPenaltyEnabled ? params.repeatPenalty : null,
      stop: params.stopString,
      numCtx: 8192, // 默认上下文窗口
      numPredict: params.limitResponseLength ? (params.maxTokens ?? 2048) : null,
      enableReasoning: params.enableReasoning,
    );
  }

  /// 从 RemoteModelConfig 创建
  factory ChatOptions.fromRemoteConfig(RemoteModelConfig config) {
    return ChatOptions(
      temperature: config.temperature,
      topP: config.topP,
      maxTokens: config.maxTokens,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  ModelInferenceEngine
// ════════════════════════════════════════════════════════════════════════════

class ModelInferenceEngine implements IModelManager {
  final Map<String, StreamSubscription> _activeStreams = {};

  // 远程模型 HTTP 客户端（按 modelId 缓存）
  final Map<String, Dio> _remoteDioClients = {};

  // Ollama 模型标记
  final Set<String> _ollamaReadyModels = {};

  // 本地 FFI 模型标记（使用 LocalFFIEngine 加载的模型）
  final Set<String> _localFFIReadyModels = {};

  // 已验证连通性的远程模型
  final Set<String> _verifiedRemoteModels = {};

  final _loadingStateController =
      StreamController<ModelLoadingState>.broadcast();

  // Performance tracking
  final Map<String, List<int>> _tokenGenerationTimes = {};
  static const int _maxHistorySize = 100;

  // Ollama 模型名映射（modelId -> ollama model name）
  final Map<String, String> _ollamaModelNames = {};
  // Ollama base URL 映射
  final Map<String, String> _ollamaBaseUrls = {};
  // 缓存的模型参数（modelId -> ChatOptions）
  final Map<String, ChatOptions> _cachedOptions = {};

  /// 私有构造函数（单例模式）
  ModelInferenceEngine._();

  @override
  Stream<ModelLoadingState> get loadingStateStream =>
      _loadingStateController.stream;

  /// 从 SharedPreferences 读取 ModelEntry
  Future<ModelEntry?> _getModelEntry(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kModelsKey);
    if (raw == null) {
      debugPrint('[ModelInferenceEngine] _getModelEntry: 模型列表为空，key=$_kModelsKey');
      return null;
    }

    final list = jsonDecode(raw) as List<dynamic>;
    for (final e in list) {
      final entry = ModelEntry.fromJson(e as Map<String, dynamic>);
      if (entry.id == modelId) {
        // 调试：检查 API key 状态
        if (entry.remoteConfig != null) {
          final apiKeyLen = entry.remoteConfig!.apiKey.length;
          debugPrint('[ModelInferenceEngine] _getModelEntry: 找到模型 ${entry.displayName}, API key长度=$apiKeyLen');
          if (apiKeyLen == 0) {
            debugPrint('[ModelInferenceEngine] ⚠️ 警告: 模型 ${entry.displayName} 的 API key 为空!');
          }
        }
        return entry;
      }
    }
    debugPrint('[ModelInferenceEngine] _getModelEntry: 未找到模型 modelId=$modelId');
    return null;
  }

  // ────────────────────────── 模型加载 ──────────────────────────

  @override
  Future<ModelInfo> loadModel(String modelId, {String? mmprojPath}) async {
    try {
      _loadingStateController.add(ModelLoadingState(
        modelId: modelId,
        status: LoadingStatus.loading,
        progress: 0.0,
      ));

      final modelEntry = await _getModelEntry(modelId);
      if (modelEntry == null) {
        throw StateError('模型 $modelId 不存在，请先添加模型');
      }

      if (modelEntry.isLocal) {
        // 本地模型优先使用 llama.cpp (LocalFFIEngine)
        // 如果没有传入 mmprojPath，使用模型关联的 mmprojFileName
        final effectiveMmprojPath = mmprojPath ?? modelEntry.mmprojFileName;
        return await _loadLocalModelViaFFI(modelEntry, effectiveMmprojPath);
      } else {
        return await _loadRemoteModel(modelEntry);
      }
    } catch (e) {
      _loadingStateController.add(ModelLoadingState(
        modelId: modelId,
        status: LoadingStatus.error,
        progress: 0.0,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  /// 通过 llama.cpp FFI 加载本地模型
  /// [mmprojPath] 多模态投影仪文件路径（可选）
  Future<ModelInfo> _loadLocalModelViaFFI(ModelEntry modelEntry, [String? mmprojPath]) async {
    // ★ 安全检查：filePath 为 null 时给出明确错误，避免崩溃
    final filePath = modelEntry.filePath;
    if (filePath == null || filePath.isEmpty) {
      const msg = '本地模型文件路径为空，请重新下载模型文件';
      debugPrint('LocalFFIEngine: ❌ $msg (modelId=${modelEntry.id})');
      _loadingStateController.add(ModelLoadingState(
        modelId: modelEntry.id,
        status: LoadingStatus.error,
        progress: 0.0,
        error: msg,
      ));
      throw StateError(msg);
    }

    try {
      // 缓存本地模型参数
      if (modelEntry.localParams != null) {
        _cachedOptions[modelEntry.id] =
            ChatOptions.fromLocalParams(modelEntry.localParams!);
      }

      // 使用 LocalFFIEngine 加载模型
      final ffiEngine = LocalFFIEngine.instance;
      await ffiEngine.loadModel(
        modelPath: filePath,
        params: modelEntry.localParams,
        mmprojPath: mmprojPath,
        onProgress: (progress, message) {
          // 更新加载状态
          _loadingStateController.add(ModelLoadingState(
            modelId: modelEntry.id,
            status: LoadingStatus.loading,
            progress: progress,
            message: message,
          ));
        },
      );

      // 标记本地 FFI 模型已就绪
      _localFFIReadyModels.add(modelEntry.id);

      _loadingStateController.add(ModelLoadingState(
        modelId: modelEntry.id,
        status: LoadingStatus.ready,
        progress: 1.0,
      ));

      return ModelInfo(
        id: modelEntry.id,
        name: modelEntry.displayName,
        type: 'local',
        source: 'llama.cpp',
        capabilities: const ModelCapabilities(maxContextWindow: 8192),
        config: {'modelPath': filePath},
      );
    } catch (e) {
      debugPrint('LocalFFIEngine 加载失败: $e');
      _loadingStateController.add(ModelLoadingState(
        modelId: modelEntry.id,
        status: LoadingStatus.error,
        progress: 0.0,
        error: e.toString(),
      ));
      rethrow;
    }
  }

  /// 通过 Ollama API 加载本地模型（已废弃，仅用于远程 Ollama 模型）
  Future<ModelInfo> _loadLocalModelViaOllama(ModelEntry modelEntry) async {
    final config = modelEntry.remoteConfig;

    // 使用平台工具类获取默认地址
    String ollamaBaseUrl = PlatformUtils.getDefaultOllamaBaseUrl();
    String ollamaModelName =
        modelEntry.displayName.toLowerCase().replaceAll(' ', '');

    if (config != null && config.protocol == RemoteProtocol.ollama) {
      ollamaBaseUrl = config.baseUrl;
      ollamaModelName = config.modelId;
    }

    // 缓存本地模型参数
    if (modelEntry.localParams != null) {
      _cachedOptions[modelEntry.id] =
          ChatOptions.fromLocalParams(modelEntry.localParams!);
    }

    // 创建 Ollama Dio 客户端
    final dio = Dio(BaseOptions(
      baseUrl: ollamaBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 5),
      headers: {'Content-Type': 'application/json'},
    ));

    // 验证 Ollama 服务连通性
    try {
      final response = await dio.get('/api/tags');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final models = data['models'] as List? ?? [];

        // 查找匹配的模型
        bool modelFound = false;
        for (final m in models) {
          final name = m['name'] as String? ?? '';
          if (name == ollamaModelName ||
              name.startsWith('$ollamaModelName:')) {
            modelFound = true;
            ollamaModelName = name; // 使用完整的模型名（含 tag）
            break;
          }
        }

        if (!modelFound && models.isNotEmpty) {
          // 尝试从 GGUF 文件名推断模型名
          final fileName = modelEntry.filePath?.split('/').last ?? '';
          final baseName = fileName
              .replaceAll('.gguf', '')
              .replaceAll(RegExp(r'[-_]'), ' ')
              .toLowerCase();

          for (final m in models) {
            final name = (m['name'] as String? ?? '').toLowerCase();
            if (name.contains(baseName.split(' ').first) ||
                baseName.contains(name.split(':').first)) {
              modelFound = true;
              ollamaModelName = m['name'] as String;
              break;
            }
          }
        }

        if (!modelFound) {
          debugPrint(
              'Ollama 中未找到模型 $ollamaModelName，可用模型: ${models.map((m) => m['name']).toList()}');
          // 不再 fallback，让用户知道模型不存在
          if (models.isEmpty) {
            throw StateError(
                'Ollama 服务中没有可用的模型。请先拉取模型（如 ollama pull qwen2.5:7b）。');
          }
          // 列出可用模型供用户参考
          final availableNames =
              models.map((m) => m['name'] as String).take(5).join(', ');
          throw StateError(
              'Ollama 中未找到模型 "$ollamaModelName"。\n可用模型: $availableNames\n请先拉取模型（如 ollama pull $ollamaModelName）');
        }
      }
    } catch (e) {
      if (e is StateError) rethrow;
      debugPrint('Ollama 连通性检查失败: $e');
      throw StateError(
          '无法连接 Ollama 服务（$ollamaBaseUrl），请确保 Ollama 已启动。\n${PlatformUtils.ollamaConnectionHint}\n错误: $e');
    }

    // 缓存 Ollama Dio 客户端
    _remoteDioClients[modelEntry.id] = dio;
    _ollamaReadyModels.add(modelEntry.id);
    _ollamaModelNames[modelEntry.id] = ollamaModelName;
    _ollamaBaseUrls[modelEntry.id] = ollamaBaseUrl;

    _loadingStateController.add(ModelLoadingState(
      modelId: modelEntry.id,
      status: LoadingStatus.ready,
      progress: 1.0,
    ));

    return ModelInfo(
      id: modelEntry.id,
      name: modelEntry.displayName,
      type: 'local',
      source: 'ollama',
      capabilities: const ModelCapabilities(maxContextWindow: 8192),
      config: {'baseUrl': ollamaBaseUrl, 'modelName': ollamaModelName},
    );
  }

  /// 加载远程模型
  Future<ModelInfo> _loadRemoteModel(ModelEntry modelEntry) async {
    final config = modelEntry.remoteConfig;
    if (config == null) {
      throw StateError('远程模型 ${modelEntry.displayName} 缺少 API 配置');
    }

    // 调试：检查 API key 状态
    debugPrint('[ModelInferenceEngine] _loadRemoteModel: ${modelEntry.displayName}');
    debugPrint('[ModelInferenceEngine]   协议: ${config.protocol}');
    debugPrint('[ModelInferenceEngine]   BaseURL: ${config.baseUrl}');
    debugPrint('[ModelInferenceEngine]   ModelID: ${config.modelId}');
    debugPrint('[ModelInferenceEngine]   API Key长度: ${config.apiKey.length}');
    if (config.apiKey.isEmpty) {
      debugPrint('[ModelInferenceEngine]   ⚠️ 警告: API Key 为空!');
      // 根据协议提示不同的配置位置
      String hint;
      switch (config.protocol) {
        case RemoteProtocol.openai:
          hint = '请在模型设置中添加 OpenAI API Key';
        case RemoteProtocol.anthropic:
          hint = '请在模型设置中添加 Anthropic API Key';
        case RemoteProtocol.ollama:
          hint = '请确保 Ollama 服务正在运行';
      }
      debugPrint('[ModelInferenceEngine]   💡 提示: $hint');
    }

    // 缓存远程模型参数
    _cachedOptions[modelEntry.id] =
        ChatOptions.fromRemoteConfig(config);

    // 创建 Dio 客户端
    final dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 5),
      headers: _buildApiHeaders(config),
    ));
    _remoteDioClients[modelEntry.id] = dio;

    // 验证连通性
    try {
      if (config.protocol == RemoteProtocol.ollama) {
        await dio.get('/api/tags');
        _ollamaReadyModels.add(modelEntry.id);
      } else if (config.protocol == RemoteProtocol.openai) {
        await dio.get('/models');
      } else if (config.protocol == RemoteProtocol.anthropic) {
        // Anthropic 没有 /models 列表端点，直接标记为就绪
        debugPrint('Anthropic 模型配置已就绪: ${config.modelId}');
      }
    } catch (e) {
      debugPrint('远程模型连通性检查失败（继续）: $e');
    }

    _verifiedRemoteModels.add(modelEntry.id);

    _loadingStateController.add(ModelLoadingState(
      modelId: modelEntry.id,
      status: LoadingStatus.ready,
      progress: 1.0,
    ));

    return ModelInfo(
      id: modelEntry.id,
      name: modelEntry.displayName,
      type: 'remote',
      source: config.protocol.name,
      capabilities: ModelCapabilities(
          maxContextWindow:
              config.protocol == RemoteProtocol.anthropic ? 200000 : 128000),
      config: config.toJson(),
    );
  }

  /// 构建 API 请求头
  Map<String, String> _buildApiHeaders(RemoteModelConfig config) {
    // 调试：检查 API key 是否正确传递
    debugPrint('[ModelInferenceEngine] _buildApiHeaders: protocol=${config.protocol}, apiKey长度=${config.apiKey.length}');
    
    switch (config.protocol) {
      case RemoteProtocol.openai:
        return {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        };
      case RemoteProtocol.anthropic:
        return {
          'x-api-key': config.apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        };
      case RemoteProtocol.ollama:
        return {
          'Content-Type': 'application/json',
        };
    }
  }

  @override
  Future<void> unloadModel(String modelId) async {
    _remoteDioClients.remove(modelId)?.close();
    _ollamaReadyModels.remove(modelId);
    _ollamaModelNames.remove(modelId);
    _ollamaBaseUrls.remove(modelId);
    _verifiedRemoteModels.remove(modelId);
    _localFFIReadyModels.remove(modelId);
    _cachedOptions.remove(modelId);
  }

  @override
  Future<void> downloadModel(ModelDownloadConfig config) async {
    throw UnimplementedError('Use DownloadTaskManager for downloads');
  }

  @override
  Future<ModelInfo> getModelInfo(String modelId) async {
    final entry = await _getModelEntry(modelId);
    if (entry == null) throw StateError('Model $modelId not found');

    return ModelInfo(
      id: entry.id,
      name: entry.displayName,
      type: entry.type.name,
      source: entry.isLocal
          ? 'ollama'
          : (entry.remoteConfig?.protocol.name ?? 'remote'),
      capabilities: const ModelCapabilities(maxContextWindow: 8192),
      config: {},
    );
  }

  @override
  Future<List<ModelInfo>> getAvailableModels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kModelsKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) {
      final entry = ModelEntry.fromJson(e as Map<String, dynamic>);
      return ModelInfo(
        id: entry.id,
        name: entry.displayName,
        type: entry.type.name,
        source: entry.isLocal ? 'ollama' : 'remote',
        capabilities: const ModelCapabilities(maxContextWindow: 8192),
        config: {},
      );
    }).toList();
  }

  @override
  Future<ModelCapabilities> detectCapabilities(String modelId) async {
    return const ModelCapabilities(maxContextWindow: 8192);
  }

  // ────────────────────────── 核心推理方法 ──────────────────────────

  /// 模型是否已就绪
  bool isModelReady(String modelId) {
    return _localFFIReadyModels.contains(modelId) ||
        _ollamaReadyModels.contains(modelId) ||
        _verifiedRemoteModels.contains(modelId);
  }

  /// 查询模型是否支持多模态（图片输入）
  /// 用于 DialogueEngine 决定历史消息是否保留图片
  Future<bool> supportsMultimodal(String modelId) async {
    final entry = await _getModelEntry(modelId);
    return entry?.supportsMultimodal ?? false;
  }

  /// ★★★ 获取模型的上下文大小 ★★★
  ///
  /// 用于 DialogueEngine 动态设置上下文压缩阈值为 90%。
  /// 本地模型：从 LocalFFIEngine 获取
  /// 远程模型：从模型配置获取（默认 4096）
  Future<int> getContextSize(String modelId) async {
    final entry = await _getModelEntry(modelId);
    if (entry == null) return 4096;

    // 本地模型：从 LocalFFIEngine 获取实际配置的 contextSize
    if (entry.isLocal) {
      try {
        final ffiEngine = LocalFFIEngine.instance;
        if (ffiEngine.isInitialized) {
          return ffiEngine.maxContextSize;
        }
      } catch (_) {
        // ignore: non-critical error
      }
    }

    // 远程模型：从 localParams 或 remoteConfig 获取
    final localParams = entry.localParams;
    if (localParams != null) {
      return localParams.contextSize;
    }
    final remoteConfig = entry.remoteConfig;
    if (remoteConfig != null) {
      return remoteConfig.maxTokens;
    }

    // 回退默认值
    return 4096;
  }

  /// 获取当前上下文使用信息（已用 token、总 token、使用率）
  /// 返回 (usedTokens, maxTokens, usageRatio 0.0~1.0)
  ({int used, int max, double ratio}) getContextUsage() {
    final ffiEngine = LocalFFIEngine.instance;
    if (!ffiEngine.isInitialized) {
      return (used: 0, max: 0, ratio: 0.0);
    }
    return (
      used: ffiEngine.estimatedUsedTokens,
      max: ffiEngine.maxContextTokens,
      ratio: ffiEngine.currentContextUsage,
    );
  }

  /// 刷新上下文使用率估算（消息变化后调用）
  void refreshContextUsage() {
    LocalFFIEngine.instance.refreshContextUsage();
  }

  /// 基于实际消息列表更新上下文使用率（从数据库加载的历史消息）
  void updateContextUsageFromMessages(List<dynamic> messages) {
    LocalFFIEngine.instance.updateContextUsageFromMessages(messages);
  }

  // ──────── 兼容旧接口（纯文本 prompt，内部转为单条 user message） ────────

  /// 生成回复（同步，纯文本 prompt 兼容接口）
  Future<String> generate(String modelId, String prompt,
      {int maxTokens = 2048}) async {
    final messages = [ChatMessage.user(prompt)];
    final options = await _getOptions(modelId, maxTokens);
    return generateChat(modelId, messages, options: options);
  }

  /// 流式推理（纯文本 prompt 兼容接口）
  Stream<String> generateStream(String modelId, String prompt,
      {int maxTokens = 2048}) async* {
    final messages = [ChatMessage.user(prompt)];
    final options = await _getOptions(modelId, maxTokens);
    yield* generateChatStream(modelId, messages, options: options);
  }

  // ──────── 新接口：结构化消息 ────────

  /// 生成回复（同步，结构化消息）
  Future<String> generateChat(
    String modelId,
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    final modelEntry = await _getModelEntry(modelId);
    if (modelEntry == null) {
      debugPrint('[ModelInferenceEngine] generateChat: 模型 $modelId 不存在');
      throw StateError('模型 $modelId 不存在，请先在模型管理中添加模型');
    }

    // ★★★ 修复 Reasoning 开关不生效：每次生成时从 ModelEntry 获取最新参数 ★★★
    // 不使用缓存的 _cachedOptions，因为用户更改设置后缓存不会自动更新
    // effectiveEnableReasoning 同时兼容本地模型（localParams.enableReasoning）
    // 和远程模型（ModelEntry.enableReasoning 顶级字段）
    final effectiveOptions = options ??
        (modelEntry.localParams != null
            ? ChatOptions.fromLocalParams(modelEntry.localParams!)
            : ChatOptions(enableReasoning: modelEntry.effectiveEnableReasoning));

    if (modelEntry.isLocal) {
      // 优先使用本地 FFI 引擎（llamadart）
      if (_localFFIReadyModels.contains(modelId)) {
        return await _callLocalFFI(messages, options: effectiveOptions);
      }
      // ★ 回退：LocalFFIEngine 单例实际已初始化（跨页面返回等场景）
      final ffiEngine = LocalFFIEngine.instance;
      if (ffiEngine.isInitialized) {
        debugPrint('[ModelInferenceEngine] generateChat: FFI 单例已初始化，直接使用');
        _localFFIReadyModels.add(modelId); // 补标记，避免下次再走这里
        return await _callLocalFFI(messages, options: effectiveOptions);
      }
      // 备用 Ollama API
      if (!_ollamaReadyModels.contains(modelId)) {
        debugPrint('[ModelInferenceEngine] generateChat: 本地模型 ${modelEntry.displayName} 未加载');
        throw StateError(
            '本地模型 ${modelEntry.displayName} 未加载，请先在模型页面点击「加载并开始对话」');
      }
      return await _callOllamaChat(modelId, messages, options: effectiveOptions);
    } else {
      final config = modelEntry.remoteConfig;
      if (config == null) {
        debugPrint('[ModelInferenceEngine] generateChat: 远程模型 ${modelEntry.displayName} 缺少 API 配置');
        throw StateError('远程模型 ${modelEntry.displayName} 缺少 API 配置');
      }

      // 检查 API key 是否为空
      if (config.apiKey.isEmpty) {
        debugPrint('[ModelInferenceEngine] generateChat: ⚠️ API Key 为空!');
        String hint;
        switch (config.protocol) {
          case RemoteProtocol.openai:
            hint = '请在模型设置中为 "${modelEntry.displayName}" 添加 OpenAI API Key';
          case RemoteProtocol.anthropic:
            hint = '请在模型设置中为 "${modelEntry.displayName}" 添加 Anthropic API Key';
          case RemoteProtocol.ollama:
            hint = '请确保 Ollama 服务正在运行';
        }
        throw StateError(hint);
      }

      final dio = _getOrCreateDio(modelId, config);
      // ★★★ 修复参数实时性：始终从 modelEntry 获取最新参数（不用过时的缓存）★★★
      // effectiveOptions 永远不为 null（已在上面设置默认值），直接使用
      return _callByProtocol(dio, config, messages, effectiveOptions);
    }
  }

  /// 根据协议类型调用远程 API（非流式）
  Future<String> _callByProtocol(
    Dio dio,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) {
    switch (config.protocol) {
      case RemoteProtocol.openai:
        return _callOpenAI(dio, config, messages, options);
      case RemoteProtocol.anthropic:
        return _callAnthropic(dio, config, messages, options);
      case RemoteProtocol.ollama:
        return _callOllamaRemoteAPI(dio, config, messages, options);
    }
  }

  /// 流式推理（结构化消息）
  Stream<String> generateChatStream(
    String modelId,
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    final modelEntry = await _getModelEntry(modelId);
    if (modelEntry == null) {
      debugPrint('[ModelInferenceEngine] generateChatStream: 模型 $modelId 不存在');
      throw StateError('模型 $modelId 不存在，请先在模型管理中添加模型');
    }

    // ★★★ 修复 Reasoning 开关不生效：每次生成时从 ModelEntry 获取最新参数 ★★★
    // effectiveEnableReasoning 同时兼容本地模型（localParams.enableReasoning）
    // 和远程模型（ModelEntry.enableReasoning 顶级字段）
    final effectiveOptions = options ??
        (modelEntry.localParams != null
            ? ChatOptions.fromLocalParams(modelEntry.localParams!)
            : ChatOptions(enableReasoning: modelEntry.effectiveEnableReasoning));

    if (modelEntry.isLocal) {
      // 优先使用本地 FFI 引擎（llamadart）
      if (_localFFIReadyModels.contains(modelId)) {
        yield* _streamLocalFFI(messages, options: effectiveOptions);
        return;
      }
      // ★ 回退：LocalFFIEngine 单例实际已初始化（跨页面返回等场景）
      final ffiEngine = LocalFFIEngine.instance;
      if (ffiEngine.isInitialized) {
        debugPrint('[ModelInferenceEngine] generateChatStream: FFI 单例已初始化，直接使用');
        _localFFIReadyModels.add(modelId); // 补标记
        yield* _streamLocalFFI(messages, options: effectiveOptions);
        return;
      }
      // 备用 Ollama API
      if (!_ollamaReadyModels.contains(modelId)) {
        debugPrint('[ModelInferenceEngine] generateChatStream: 本地模型 ${modelEntry.displayName} 未加载');
        throw StateError(
            '本地模型 ${modelEntry.displayName} 未加载，请先在模型页面点击「加载并开始对话」');
      }
      yield* _streamOllamaChat(modelId, messages, options: effectiveOptions);
    } else {
      final config = modelEntry.remoteConfig;
      if (config == null) {
        debugPrint('[ModelInferenceEngine] generateChatStream: 远程模型 ${modelEntry.displayName} 缺少 API 配置');
        throw StateError('远程模型 ${modelEntry.displayName} 缺少 API 配置');
      }

      // 检查 API key 是否为空
      if (config.apiKey.isEmpty) {
        debugPrint('[ModelInferenceEngine] generateChatStream: ⚠️ API Key 为空!');
        String hint;
        switch (config.protocol) {
          case RemoteProtocol.openai:
            hint = '请在模型设置中为 "${modelEntry.displayName}" 添加 OpenAI API Key';
          case RemoteProtocol.anthropic:
            hint = '请在模型设置中为 "${modelEntry.displayName}" 添加 Anthropic API Key';
          case RemoteProtocol.ollama:
            hint = '请确保 Ollama 服务正在运行';
        }
        throw StateError(hint);
      }

      // ★★★ 修复参数实时性：始终从 modelEntry 获取最新参数（不用过时的缓存）★★★
      // effectiveOptions 永远不为 null（已在上面设置默认值），直接使用

      // 根据协议类型调用流式 API
      if (config.protocol == RemoteProtocol.openai) {
        yield* _streamOpenAI(modelId, config, messages, effectiveOptions);
      } else if (config.protocol == RemoteProtocol.anthropic) {
        yield* _streamAnthropic(modelId, config, messages, effectiveOptions);
      } else {
        yield* _streamOllamaRemoteAPI(modelId, config, messages, effectiveOptions);
      }
    }
  }

  void cancelGeneration(String modelId) {
    final subscription = _activeStreams.remove(modelId);
    subscription?.cancel();
  }

  // ────────────────────────── 辅助方法 ──────────────────────────

  /// 获取或创建 Dio 客户端
  Dio _getOrCreateDio(String modelId, RemoteModelConfig config) {
    return _remoteDioClients.putIfAbsent(
      modelId,
      () => Dio(BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
        headers: _buildApiHeaders(config),
      )),
    );
  }

  /// 获取 ChatOptions（优先用缓存的，其次构建默认的）
  Future<ChatOptions> _getOptions(String modelId, int maxTokens) async {
    if (_cachedOptions.containsKey(modelId)) {
      return _cachedOptions[modelId]!;
    }
    final modelEntry = await _getModelEntry(modelId);
    if (modelEntry == null) return ChatOptions(maxTokens: maxTokens);

    if (modelEntry.localParams != null) {
      return ChatOptions.fromLocalParams(modelEntry.localParams!);
    }
    if (modelEntry.remoteConfig != null) {
      return ChatOptions.fromRemoteConfig(modelEntry.remoteConfig!);
    }
    return ChatOptions(maxTokens: maxTokens);
  }

  // ────────────────────────── Ollama Chat API（本地模型） ──────────────────────────

  Future<String> _callOllamaChat(
    String modelId,
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    final modelName = _ollamaModelNames[modelId] ?? 'qwen2.5:7b';
    final baseUrl =
        _ollamaBaseUrls[modelId] ?? PlatformUtils.getDefaultOllamaBaseUrl();
    final dio = _remoteDioClients[modelId] ??
        Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 5),
          headers: {'Content-Type': 'application/json'},
        ));

    // ★★★ 应用思考模式控制 ★★★
    final processedMessages = _applyThinkingMode(messages, options);

    final data = <String, dynamic>{
      'model': modelName,
      'messages': processedMessages.map((m) => m.toJson()).toList(),
      'stream': false,
    };

    // 添加 Ollama options
    final ollamaOptions = _buildOllamaOptions(options);
    if (ollamaOptions.isNotEmpty) {
      data['options'] = ollamaOptions;
    }

    final response = await dio.post('/api/chat', data: data);

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] as Map<String, dynamic>?;
      return message?['content'] as String? ?? '';
    }
    throw Exception('Ollama 返回格式异常');
  }

  Stream<String> _streamOllamaChat(
    String modelId,
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    final modelName = _ollamaModelNames[modelId] ?? 'qwen2.5:7b';
    final baseUrl =
        _ollamaBaseUrls[modelId] ?? PlatformUtils.getDefaultOllamaBaseUrl();
    final dio = _remoteDioClients[modelId] ??
        Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 5),
          headers: {'Content-Type': 'application/json'},
        ));

    // ★★★ 应用思考模式控制 ★★★
    final processedMessages = _applyThinkingMode(messages, options);

    final data = <String, dynamic>{
      'model': modelName,
      'messages': processedMessages.map((m) => m.toJson()).toList(),
      'stream': true,
    };

    final ollamaOptions = _buildOllamaOptions(options);
    if (ollamaOptions.isNotEmpty) {
      data['options'] = ollamaOptions;
    }

    final response = await dio.post(
      '/api/chat',
      data: data,
      options: Options(responseType: ResponseType.stream),
    );

    final respData = response.data;
    if (respData == null) throw StateError("流式响应为空（response.data 为 null）");
    final stream = respData.stream;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.last;

      for (int i = 0; i < lines.length - 1; i++) {
        if (lines[i].trim().isEmpty) continue;
        try {
          final jsonData = jsonDecode(lines[i]) as Map<String, dynamic>;
          final message = jsonData['message'] as Map<String, dynamic>?;
          if (message != null && message['content'] != null) {
            final content = message['content'] as String;
            // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
            final enableReasoning = options?.enableReasoning ?? true;
            yield enableReasoning ? content : _cleanThinkTags(content);
          }
          if (jsonData['done'] == true) return;
        } catch (_) {
          // ignore: non-critical error
        }
      }
    }
  }

  /// 构建 Ollama options 参数
  Map<String, dynamic> _buildOllamaOptions(ChatOptions? options) {
    if (options == null) return {};
    final opts = <String, dynamic>{};
    if (options.temperature != null) opts['temperature'] = options.temperature;
    if (options.topP != null) opts['top_p'] = options.topP;
    if (options.topK != null) opts['top_k'] = options.topK;
    if (options.maxTokens != null) opts['num_predict'] = options.maxTokens;
    if (options.numPredict != null) opts['num_predict'] = options.numPredict;
    if (options.repeatPenalty != null) {
      opts['repeat_penalty'] = options.repeatPenalty;
    }
    if (options.stop != null) opts['stop'] = [options.stop];
    if (options.numCtx != null) opts['num_ctx'] = options.numCtx;
    return opts;
  }

  // ────────────────────────── 统一 Thinking 控制（所有后端共用）──────────────────────────

  /// 统一思考模式控制 - 双层策略
  ///
  /// 层1：System prompt 注入/清理思考引导语
  /// 层2：enableReasoning=false 时在最后一条 user 消息末尾追加 `/no_think`
  ///       （Qwen3 / QwQ 等模型的原生 thinking_budget 控制 token）
  ///
  /// 适用范围：LocalFFI / Ollama / OpenAI / Anthropic 全部路径
  List<ChatMessage> _applyThinkingMode(
    List<ChatMessage> messages,
    ChatOptions? options,
  ) {
    final enableReasoning = options?.enableReasoning ?? false;
    debugPrint('[ModelInferenceEngine] _applyThinkingMode: enableReasoning=$enableReasoning');

    if (messages.isEmpty) return messages;

    final modifiedMessages = List<ChatMessage>.from(messages);

    // ── 层 1：处理 system prompt ──
    final firstMessage = messages.first;
    if (firstMessage.role != 'system') {
      // 没有 system 消息时，插入一条
      final thinkingPrompt = enableReasoning
          ? '你是一个善于思考的AI助手。在回答复杂问题时，请先展示你的思考过程（用<think>...</think>标签包裹），然后再给出最终答案。'
          : '你是一个高效的AI助手，请直接给出简洁的答案。';
      modifiedMessages.insert(0, ChatMessage(role: 'system', content: thinkingPrompt));
    } else {
      // 已有 system 消息：清理旧引导语，防止重复累积
      var sysContent = firstMessage.content
          .replaceAll(RegExp(r'\n\n请在回答复杂问题时先展示思考过程.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n请直接给出简洁明了的答案.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n你是一个高效的AI助手.*', dotAll: true), '')
          .replaceAll(RegExp(r'\n\n你是一个善于思考的AI助手.*', dotAll: true), '');
      if (enableReasoning) {
        sysContent += '\n\n请在回答复杂问题时先展示思考过程（用<think>...</think>标签包裹），然后再给出最终答案。';
      }
      modifiedMessages[0] = ChatMessage(role: 'system', content: sysContent);
    }

    // ── 层 2：用户消息追加 /no_think（仅关闭时）──
    if (!enableReasoning) {
      for (int i = modifiedMessages.length - 1; i >= 0; i--) {
        if (modifiedMessages[i].role == 'user') {
          final userMsg = modifiedMessages[i];
          if (!userMsg.content.endsWith('/no_think')) {
            modifiedMessages[i] = ChatMessage(
              role: userMsg.role,
              content: '${userMsg.content} /no_think',
              images: userMsg.images,
            );
          }
          break;
        }
      }
    }

    return modifiedMessages;
  }

  // ────────────────────────── 本地 FFI (llamadart) ──────────────────────────

  /// 使用本地 FFI 引擎生成回复（阻塞式）
  Future<String> _callLocalFFI(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    final ffiEngine = LocalFFIEngine.instance;
    return await ffiEngine.generate(messages, options: options);
  }

  /// 使用本地 FFI 引擎生成回复（流式）
  Stream<String> _streamLocalFFI(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    final ffiEngine = LocalFFIEngine.instance;
    yield* ffiEngine.generateStream(messages, options: options);
  }

  // ────────────────────────── OpenAI API ──────────────────────────

  Future<String> _callOpenAI(
    Dio dio,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) async {
    // ★★★ 应用思考模式控制 ★★★
    final processedMessages = _applyThinkingMode(messages, options);

    final data = <String, dynamic>{
      'model': config.modelId,
      'messages': processedMessages.map((m) => m.toJson()).toList(),
      'stream': false,
    };

    // OpenAI 参数
    if (options.temperature != null) data['temperature'] = options.temperature;
    if (options.topP != null) data['top_p'] = options.topP;
    if (options.maxTokens != null) data['max_tokens'] = options.maxTokens;
    if (options.stop != null) data['stop'] = [options.stop];

    final response = await dio.post('/chat/completions', data: data);

    final choices = response.data['choices'] as List;
    if (choices.isEmpty) throw Exception('OpenAI 返回空响应');
    final content = choices[0]['message']['content'] as String;
    // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
    return options.enableReasoning != false ? content : _cleanThinkTags(content);
  }

  Stream<String> _streamOpenAI(
    String modelId,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) async* {
    final dio = _getOrCreateDio(modelId, config);

    // 调试：记录完整请求信息
    debugPrint('[ModelInferenceEngine] _streamOpenAI:');
    debugPrint('  - baseUrl: ${config.baseUrl}');
    debugPrint('  - modelId: ${config.modelId}');
    debugPrint('  - apiKey 长度: ${config.apiKey.length}');
    debugPrint('  - apiKey 前5位: ${config.apiKey.length > 5 ? config.apiKey.substring(0, 5) : config.apiKey}...');
    debugPrint('  - enableReasoning: ${options.enableReasoning}');

    // ★★★ 应用思考模式控制 ★★★
    final processedMessages = _applyThinkingMode(messages, options);

    final data = <String, dynamic>{
      'model': config.modelId,
      'messages': processedMessages.map((m) => m.toJson()).toList(),
      'stream': true,
    };

    if (options.temperature != null) data['temperature'] = options.temperature;
    if (options.topP != null) data['top_p'] = options.topP;
    if (options.maxTokens != null) data['max_tokens'] = options.maxTokens;
    if (options.stop != null) data['stop'] = [options.stop];

    try {
      final response = await dio.post(
        '/chat/completions',
        data: data,
        options: Options(responseType: ResponseType.stream),
      );

      final responseData = response.data;
      if (responseData == null) {
        throw StateError('OpenAI 流式响应为空（response.data 为 null）');
      }
      final stream = responseData.stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk, allowMalformed: true);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          var line = lines[i].trim();
          if (!line.startsWith('data: ')) continue;
          line = line.substring(6);

          if (line == '[DONE]') return;

          try {
            final jsonData = jsonDecode(line) as Map<String, dynamic>;
            final choices = jsonData['choices'] as List?;
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'] as Map<String, dynamic>?;
              if (delta != null && delta['content'] != null) {
                final content = delta['content'] as String;
                // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
                yield options.enableReasoning != false ? content : _cleanThinkTags(content);
              }
            }
          } catch (_) {
            // ignore: non-critical error
          }
        }
      }
    } on DioException catch (e) {
      // 捕获并详细记录 Dio 错误
      debugPrint('[ModelInferenceEngine] _streamOpenAI DioException:');
      debugPrint('  - type: ${e.type}');
      debugPrint('  - message: ${e.message}');
      debugPrint('  - response status: ${e.response?.statusCode}');
      debugPrint('  - response data: ${e.response?.data}');
      debugPrint('  - request headers: ${e.requestOptions.headers}');
      
      // 重新抛出，让上层处理
      rethrow;
    }
  }

  // ────────────────────────── Anthropic API ──────────────────────────

  Future<String> _callAnthropic(
    Dio dio,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) async {
    // ★★★ 应用思考模式控制（先处理消息，再提取 system prompt）★★★
    final processedMessages = _applyThinkingMode(messages, options);

    // Anthropic: system 提示词是独立字段，不在 messages 中
    final systemPrompt = _extractSystemPrompt(processedMessages);
    final nonSystemMessages =
        processedMessages.where((m) => m.role != 'system').toList();

    final data = <String, dynamic>{
      'model': config.modelId,
      'max_tokens': options.maxTokens ?? 4096,
      'messages': nonSystemMessages.map((m) => m.toAnthropicJson()).toList(),
    };

    if (systemPrompt != null) {
      data['system'] = systemPrompt;
    }
    if (options.temperature != null) data['temperature'] = options.temperature;
    if (options.topP != null) data['top_p'] = options.topP;
    if (options.topK != null) data['top_k'] = options.topK;
    if (options.stop != null) data['stop_sequences'] = [options.stop];

    final response = await dio.post('/v1/messages', data: data);

    final content = response.data['content'] as List;
    if (content.isEmpty) throw Exception('Anthropic 返回空响应');
    final text = content[0]['text'] as String;
    // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
    return options.enableReasoning != false ? text : _cleanThinkTags(text);
  }

  Stream<String> _streamAnthropic(
    String modelId,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) async* {
    final dio = _getOrCreateDio(modelId, config);

    // ★★★ 应用思考模式控制（先处理消息，再提取 system prompt）★★★
    final processedMessages = _applyThinkingMode(messages, options);
    debugPrint('[ModelInferenceEngine] _streamAnthropic: enableReasoning=${options.enableReasoning}');

    // Anthropic: system 提示词是独立字段
    final systemPrompt = _extractSystemPrompt(processedMessages);
    final nonSystemMessages =
        processedMessages.where((m) => m.role != 'system').toList();

    final data = <String, dynamic>{
      'model': config.modelId,
      'max_tokens': options.maxTokens ?? 4096,
      'messages': nonSystemMessages.map((m) => m.toAnthropicJson()).toList(),
      'stream': true,
    };

    if (systemPrompt != null) {
      data['system'] = systemPrompt;
    }
    if (options.temperature != null) data['temperature'] = options.temperature;
    if (options.topP != null) data['top_p'] = options.topP;
    if (options.topK != null) data['top_k'] = options.topK;
    if (options.stop != null) data['stop_sequences'] = [options.stop];

    final response = await dio.post(
      '/v1/messages',
      data: data,
      options: Options(responseType: ResponseType.stream),
    );

    final respData = response.data;
    if (respData == null) throw StateError("流式响应为空（response.data 为 null）");
    final stream = respData.stream;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.last;

      for (int i = 0; i < lines.length - 1; i++) {
        var line = lines[i].trim();
        if (!line.startsWith('data: ')) continue;
        line = line.substring(6);

        try {
          final jsonData = jsonDecode(line) as Map<String, dynamic>;
          final type = jsonData['type'] as String?;

          if (type == 'content_block_delta') {
            final delta = jsonData['delta'] as Map<String, dynamic>?;
            if (delta != null && delta['text'] != null) {
              final content = delta['text'] as String;
              // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
              yield options.enableReasoning != false ? content : _cleanThinkTags(content);
            }
          } else if (type == 'message_stop') {
            return;
          }
        } catch (_) {
          // ignore: non-critical error
        }
      }
    }
  }

  /// 从消息列表中提取 system 提示词（用于 Anthropic）
  String? _extractSystemPrompt(List<ChatMessage> messages) {
    final systemMessages =
        messages.where((m) => m.role == 'system').toList();
    if (systemMessages.isEmpty) return null;
    return systemMessages.map((m) => m.content).join('\n\n');
  }

  // ────────────────────────── Ollama Remote API ──────────────────────────

  Future<String> _callOllamaRemoteAPI(
    Dio dio,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) async {
    // ★★★ 应用思考模式控制 ★★★
    final processedMessages = _applyThinkingMode(messages, options);

    final data = <String, dynamic>{
      'model': config.modelId,
      'messages': processedMessages.map((m) => m.toJson()).toList(),
      'stream': false,
    };

    final ollamaOptions = _buildOllamaOptions(options);
    if (ollamaOptions.isNotEmpty) {
      data['options'] = ollamaOptions;
    }

    final response = await dio.post('/api/chat', data: data);

    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] as Map<String, dynamic>?;
      final content = message?['content'] as String? ?? '';
      // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
      return options.enableReasoning != false ? content : _cleanThinkTags(content);
    }
    throw Exception('Ollama 返回格式异常');
  }

  Stream<String> _streamOllamaRemoteAPI(
    String modelId,
    RemoteModelConfig config,
    List<ChatMessage> messages,
    ChatOptions options,
  ) async* {
    final dio = _getOrCreateDio(modelId, config);

    // ★★★ 应用思考模式控制 ★★★
    final processedMessages = _applyThinkingMode(messages, options);

    final data = <String, dynamic>{
      'model': config.modelId,
      'messages': processedMessages.map((m) => m.toJson()).toList(),
      'stream': true,
    };

    final ollamaOptions = _buildOllamaOptions(options);
    if (ollamaOptions.isNotEmpty) {
      data['options'] = ollamaOptions;
    }

    final response = await dio.post(
      '/api/chat',
      data: data,
      options: Options(responseType: ResponseType.stream),
    );

    final respData = response.data;
    if (respData == null) throw StateError("流式响应为空（response.data 为 null）");
    final stream = respData.stream;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk, allowMalformed: true);
      final lines = buffer.split('\n');
      buffer = lines.last;

      for (int i = 0; i < lines.length - 1; i++) {
        if (lines[i].trim().isEmpty) continue;
        try {
          final jsonData = jsonDecode(lines[i]) as Map<String, dynamic>;
          final message = jsonData['message'] as Map<String, dynamic>?;
          if (message != null && message['content'] != null) {
            final content = message['content'] as String;
            // ★★★ 清洗思考标签（enableReasoning=false 时）★★★
            // options 为非空 ChatOptions，但 enableReasoning 为 bool?
            final enableReasoning = options.enableReasoning ?? true;
            yield enableReasoning ? content : _cleanThinkTags(content);
          }
          if (jsonData['done'] == true) return;
        } catch (_) {
          // ignore: non-critical error
        }
      }
    }
  }

  // ────────────────────────── 性能追踪 ──────────────────────────

  /// 记录单次生成的耗时（供 DialogueEngine 调用）
  void recordGenerationTime(String modelId, int elapsedMs, int outputLength) {
    final history =
        _tokenGenerationTimes.putIfAbsent(modelId, () => []);
    history.add(elapsedMs);
    while (history.length > _maxHistorySize) {
      history.removeAt(0);
    }
  }

  double getAverageTokensPerSecond(String modelId) {
    final history = _tokenGenerationTimes[modelId];
    if (history == null || history.isEmpty) return 0.0;
    final avgMs = history.reduce((a, b) => a + b) / history.length;
    if (avgMs == 0) return 0.0;
    return 1000.0 / avgMs * 10;
  }

  Map<String, dynamic> getPerformanceStats(String modelId) {
    final history = _tokenGenerationTimes[modelId];
    if (history == null || history.isEmpty) {
      return {
        'averageTimeMs': 0,
        'minTimeMs': 0,
        'maxTimeMs': 0,
        'estimatedTokPerSec': 0.0,
        'totalGenerations': 0
      };
    }
    final avgMs = history.reduce((a, b) => a + b) / history.length;
    return {
      'averageTimeMs': avgMs.toInt(),
      'minTimeMs': history.reduce((a, b) => a < b ? a : b),
      'maxTimeMs': history.reduce((a, b) => a > b ? a : b),
      'estimatedTokPerSec': getAverageTokensPerSecond(modelId),
      'totalGenerations': history.length,
    };
  }

  void dispose() {
    // 释放本地 FFI 引擎资源（GPU 内存）
    LocalFFIEngine.instance.dispose();
    
    for (final dio in _remoteDioClients.values) {
      dio.close();
    }
    _remoteDioClients.clear();
    _ollamaReadyModels.clear();
    _ollamaModelNames.clear();
    _ollamaBaseUrls.clear();
    _verifiedRemoteModels.clear();
    _localFFIReadyModels.clear();
    _cachedOptions.clear();
    _loadingStateController.close();
  }
}
