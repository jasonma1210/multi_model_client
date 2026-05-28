/// 推理引擎管理器 - LLM Studio 模型推理调度模块
///
/// 功能：
/// - 自动选择最优推理引擎
/// - 协调本地 FFI / Ollama / 远程 API 引擎
/// - 引擎状态监控
/// - 故障自动切换
///
/// 静态打包方案：
/// - llama.cpp 引擎已内置在应用中（通过 Flutter 打包）
/// - 所有平台统一使用 LocalFFIEngine（FFI 直接调用）
/// - 模型文件（.gguf）通过应用内下载功能获取
///
/// @author JianMa
/// @version 3.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/model_entry.dart';
import '../platform/platform_utils.dart';
import 'local_ffi_engine.dart';
import 'model_inference_engine.dart';

/// 推理引擎管理器
/// 负责协调本地 FFI 引擎、Ollama 引擎和远程 API 引擎
class InferenceEngineManager {
  static final InferenceEngineManager _instance = InferenceEngineManager._();
  static InferenceEngineManager get instance => _instance;

  InferenceEngineManager._();

  // ════════════════════════════════════════════════════════════════════════
  //  引擎实例
  // ════════════════════════════════════════════════════════════════════════

  /// 本地 FFI 引擎（移动端 + 桌面端统一使用）
  /// 静态打包方案：llama.cpp 库已内置在应用中
  final LocalFFIEngine _localFFIEngine = LocalFFIEngine.instance;

  // ════════════════════════════════════════════════════════════════════════
  //  状态
  // ════════════════════════════════════════════════════════════════════════

  /// 当前激活的推理模式
  InferenceMode _currentMode = InferenceMode.auto;

  /// 当前模型配置
  ModelEntry? _currentModel;

  /// 远程 API Dio 客户端
  final Map<String, Dio> _dioClients = {};

  // ════════════════════════════════════════════════════════════════════════
  //  公开接口
  // ════════════════════════════════════════════════════════════════════════

  /// 获取当前推理模式
  InferenceMode get currentMode => _currentMode;

  /// 获取当前模型
  ModelEntry? get currentModel => _currentModel;

  /// 获取本地 FFI 引擎实例
  LocalFFIEngine get localFFIEngine => _localFFIEngine;

  /// 检查本地 FFI 引擎是否可用
  bool get isLocalFFIAvailable => _localFFIEngine.isInitialized;

  /// 检查 Ollama 是否可用
  Future<bool> isOllamaAvailable() async {
    final baseUrl = PlatformUtils.getDefaultOllamaBaseUrl();
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 2),
      ));
      final response = await dio.get('$baseUrl/api/tags');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  模型加载
  // ════════════════════════════════════════════════════════════════════════

  /// 加载模型
  /// 根据模型类型和平台自动选择合适的推理引擎
  Future<void> loadModel(ModelEntry model) async {
    _currentModel = model;

    switch (model.type) {
      case ModelType.local:
        // 本地模型：使用双轨制
        await _loadLocalModel(model);
        break;
      case ModelType.remote:
      case ModelType.ollama:
        // 远程模型：通过网络调用
        _currentMode = InferenceMode.remoteAPI;
        break;
    }
  }

  /// 加载本地模型 - 统一使用 FFI 引擎
  /// 静态打包方案：所有平台都使用 llama.cpp FFI
  Future<void> _loadLocalModel(ModelEntry model) async {
    if (model.filePath == null) {
      throw InferenceEngineException('Local model file path is null');
    }

    // 所有平台统一使用 LocalFFIEngine
    if (_isLocalFFISupported()) {
      await _localFFIEngine.loadModel(
        modelPath: model.filePath!,
        params: model.localParams,
        mmprojPath: model.mmprojFileName,
      );
      _currentMode = InferenceMode.localFFI;
      debugPrint('[InferenceEngineManager] ✅ 使用 LocalFFIEngine (llama.cpp FFI)');
      return;
    }

    throw InferenceEngineException(
      'Local model loading is not supported on this platform. '
      'Please ensure llama.cpp library is available.',
    );
  }

  /// 检查本地 FFI 是否支持
  bool _isLocalFFISupported() {
    // 检查平台是否支持
    if (!Platform.isMacOS && !Platform.isIOS &&
        !Platform.isAndroid && !Platform.isWindows &&
        !Platform.isLinux) {
      return false;
    }

    // 检查 llama.cpp 库是否存在
    // 在实际应用中，这里应该检查库文件是否存在
    return true;
  }

  /// 卸载当前模型
  Future<void> unloadModel() async {
    // 根据当前模式卸载
    switch (_currentMode) {
      case InferenceMode.localFFI:
        await _localFFIEngine.unloadModel();
        break;
      default:
        break;
    }
    _currentModel = null;
    _currentMode = InferenceMode.auto;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  文本生成
  // ════════════════════════════════════════════════════════════════════════

  /// 阻塞式生成
  Future<String> generate(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    switch (_currentMode) {
      case InferenceMode.localFFI:
        return _localFFIEngine.generate(messages, options: options);
      case InferenceMode.localOllama:
        return _generateViaOllama(messages, options: options);
      case InferenceMode.remoteAPI:
        return _generateViaRemoteAPI(messages, options: options);
      case InferenceMode.auto:
        throw InferenceEngineException(
          'No model loaded. Please load a model first.',
        );
    }
  }

  /// 流式生成
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) {
    switch (_currentMode) {
      case InferenceMode.localFFI:
        return _localFFIEngine.generateStream(messages, options: options);
      case InferenceMode.localOllama:
        return _streamViaOllama(messages, options: options);
      case InferenceMode.remoteAPI:
        return _streamViaRemoteAPI(messages, options: options);
      case InferenceMode.auto:
        throw InferenceEngineException(
          'No model loaded. Please load a model first.',
        );
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Ollama 推理
  // ════════════════════════════════════════════════════════════════════════

  Future<String> _generateViaOllama(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    final baseUrl = PlatformUtils.getDefaultOllamaBaseUrl();
    final modelName = _currentModel?.remoteConfig?.modelId ?? 'llama3.2';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 5),
    ));

    // 构建 Ollama API 请求
    final requestBody = {
      'model': modelName,
      'messages': messages.map((m) => m.toOllamaJson()).toList(),
      'stream': false,
      if (options != null) ..._buildOllamaOptions(options),
    };

    try {
      final response = await dio.post('/api/chat', data: requestBody);
      final data = response.data;
      if (data['message'] != null) {
        return data['message']['content'] ?? '';
      }
      return '';
    } on DioException catch (e) {
      throw InferenceEngineException('Ollama API error: ${e.message}');
    }
  }

  Stream<String> _streamViaOllama(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) {
    final baseUrl = PlatformUtils.getDefaultOllamaBaseUrl();
    final modelName = _currentModel?.remoteConfig?.modelId ?? 'llama3.2';

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 5),
    ));

    final requestBody = {
      'model': modelName,
      'messages': messages.map((m) => m.toOllamaJson()).toList(),
      'stream': true,
      if (options != null) ..._buildOllamaOptions(options),
    };

    final controller = StreamController<String>();

    dio.post(
      '/api/chat',
      data: requestBody,
      options: Options(responseType: ResponseType.stream),
    ).then((response) {
      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      stream.listen(
        (data) {
          buffer += String.fromCharCodes(data);
          final lines = buffer.split('\n');
          buffer = lines.last;

          for (int i = 0; i < lines.length - 1; i++) {
            final line = lines[i].trim();
            if (line.isNotEmpty && line != '[DONE]') {
              try {
                final json = jsonDecode(line);
                if (json['message'] != null) {
                  controller.add(json['message']['content'] ?? '');
                }
              } catch (_) {
                // ignore: non-critical error
              }
            }
          }
        },
        onDone: () => controller.close(),
        onError: (e) => controller.addError(e),
      );
    }).catchError((e) {
      controller.addError(e);
      controller.close();
    });

    return controller.stream;
  }

  Map<String, dynamic> _buildOllamaOptions(ChatOptions options) {
    return {
      'options': {
        if (options.temperature != null) 'temperature': options.temperature,
        if (options.topP != null) 'top_p': options.topP,
        if (options.topK != null) 'top_k': options.topK,
        if (options.maxTokens != null) 'num_predict': options.maxTokens,
        if (options.repeatPenalty != null) 'repeat_penalty': options.repeatPenalty,
        if (options.numCtx != null) 'num_ctx': options.numCtx,
      },
    };
  }

  // ════════════════════════════════════════════════════════════════════════
  //  远程 API 推理
  // ════════════════════════════════════════════════════════════════════════

  Future<String> _generateViaRemoteAPI(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    if (_currentModel == null) {
      throw InferenceEngineException('No model loaded');
    }

    // 使用全局 ModelInferenceEngine
    return globalModelEngine.generateChat(
      _currentModel!.id,
      messages,
      options: options,
    );
  }

  Stream<String> _streamViaRemoteAPI(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) {
    if (_currentModel == null) {
      throw InferenceEngineException('No model loaded');
    }

    // 使用全局 ModelInferenceEngine
    return globalModelEngine.generateChatStream(
      _currentModel!.id,
      messages,
      options: options,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  资源清理
  // ════════════════════════════════════════════════════════════════════════

  Future<void> dispose() async {
    await _localFFIEngine.dispose();
    for (final dio in _dioClients.values) {
      dio.close();
    }
    _dioClients.clear();
    _currentModel = null;
    _currentMode = InferenceMode.auto;
  }
}

// ════════════════════════════════════════════════════════════════════════
//  推理模式枚举
// ════════════════════════════════════════════════════════════════════════

enum InferenceMode {
  /// 自动选择最佳引擎
  auto,

  /// 本地 FFI 引擎（llama.cpp 直接加载 GGUF）
  localFFI,

  /// 本地 Ollama API
  localOllama,

  /// 远程 API（OpenAI/Anthropic/其他）
  remoteAPI,
}

// ════════════════════════════════════════════════════════════════════════
//  异常类
// ════════════════════════════════════════════════════════════════════════

class InferenceEngineException implements Exception {
  final String message;
  InferenceEngineException(this.message);

  @override
  String toString() => 'InferenceEngineException: $message';
}
