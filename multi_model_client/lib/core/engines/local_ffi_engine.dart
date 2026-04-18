/// 本地 FFI 推理引擎 - LLM Studio 本地模型推理模块
///
/// 工业级标准实现：
/// - 静态打包 llama.cpp 动态库（构建时嵌入 app bundle）
/// - 动态下载 .gguf 模型文件（运行时通过模型市场下载）
/// - 使用 LlamaParent/LlamaChild Isolate 架构（推理不阻塞 UI）
/// - 使用 llama_cpp_dart 内置 ChatFormat（支持 ChatML/Alpaca/Gemma 等模板）
///
/// 支持平台：
/// - macOS: Metal 加速 (Apple Silicon)
/// - iOS: Metal 加速
/// - Android: Vulkan/OpenCL 加速
/// - Windows: CUDA/CPU
/// - Linux: CUDA/CPU
///
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

import '../models/model_entry.dart';
import '../services/llama_library_loader.dart';
import 'model_inference_engine.dart';

/// 本地 FFI 推理引擎
///
/// 使用 llama_cpp_dart 的 LlamaParent/LlamaChild Isolate 架构
/// 推理在后台 Isolate 中执行，不阻塞 UI 线程
class LocalFFIEngine {
  static final LocalFFIEngine _instance = LocalFFIEngine._();
  static LocalFFIEngine get instance => _instance;

  LocalFFIEngine._();

  // LlamaParent 是 Isolate 通信的桥梁，推理在子 Isolate 中运行
  LlamaParent? _llamaParent;
  String? _currentModelPath;

  // 状态
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  String? get currentModelPath => _currentModelPath;

  // ════════════════════════════════════════════════════════════════════════
  //  平台检测
  // ════════════════════════════════════════════════════════════════════════

  /// 检测当前平台支持的加速后端
  static AccelerationBackend detectAccelerationBackend() {
    if (Platform.isMacOS || Platform.isIOS) {
      return AccelerationBackend.metal;
    } else if (Platform.isWindows || Platform.isLinux) {
      return AccelerationBackend.cpu; // 简化处理
    } else if (Platform.isAndroid) {
      return AccelerationBackend.vulkan;
    }
    return AccelerationBackend.cpu;
  }

  /// 获取 llama.cpp 库路径
  static String getLibraryPath() {
    if (Platform.isMacOS || Platform.isIOS) {
      return 'libllama.dylib';
    } else if (Platform.isWindows) {
      return 'libllama.dll';
    } else {
      return 'libllama.so';
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  模型加载（核心改动：使用 LlamaParent + Isolate）
  // ════════════════════════════════════════════════════════════════════════

  /// 加载 GGUF 模型
  ///
  /// 使用 LlamaParent/LlamaChild Isolate 架构：
  /// - LlamaParent 在主 Isolate，负责发送指令和接收 token
  /// - LlamaChild 在后台 Isolate，执行实际的 llama.cpp 推理
  /// - 通过 `Stream<String>` 实时传递生成的 token
  Future<void> loadModel({
    required String modelPath,
    LocalModelParams? params,
    void Function(double progress, String message)? onProgress,
  }) async {
    // 如果已有模型，先卸载
    await dispose();

    // 设置 llama.cpp 库路径
    final libraryPath = await _getLibraryFullPath();
    if (libraryPath == null) {
      throw LocalFFIException(
        'llama.cpp 库文件未找到！\n\n'
        '请确保：\n'
        '1. macos/Frameworks 目录包含 libllama.dylib\n'
        '2. 运行 flutter build macos 构建应用\n'
        '3. 或手动运行 bash macos/copy_frameworks.sh\n',
      );
    }

    debugPrint('LocalFFIEngine: Using library at $libraryPath');
    debugPrint('LocalFFIEngine: Loading model from $modelPath');

    onProgress?.call(0.2, 'Initializing inference engine...');

    // ★ 关键：设置 Llama.libraryPath，LlamaParent.init() 会自动将其
    // 通过 LlamaInit 指令传递给后台 Isolate 的 LlamaChild
    Llama.libraryPath = libraryPath;

    // 构建模型参数
    final modelParams = _buildModelParams(params);
    final contextParams = _buildContextParams(params);
    final samplerParams = _buildSamplerParams(params);

    // 创建 LlamaLoad 指令
    final loadCommand = LlamaLoad(
      path: modelPath,
      modelParams: modelParams,
      contextParams: contextParams,
      samplingParams: samplerParams,
      verbose: false,
    );

    // 创建 LlamaParent（管理后台 Isolate 中的推理）
    // LlamaParent.init() 会自动：
    // 1. spawn LlamaChild（后台 Isolate）
    // 2. 发送 LlamaInit(libraryPath) 设置库路径
    // 3. 发送 LlamaLoad 加载模型
    // 4. 等待模型就绪
    _llamaParent = LlamaParent(loadCommand);

    try {
      await _llamaParent!.init();

      _currentModelPath = modelPath;
      _isInitialized = true;

      onProgress?.call(1.0, 'Model loaded');
      debugPrint('LocalFFIEngine: ✅ Model loaded successfully');
      debugPrint('LocalFFIEngine: Backend: ${detectAccelerationBackend().name}');
    } catch (e) {
      debugPrint('LocalFFIEngine: ❌ Failed to load model: $e');
      _llamaParent?.dispose();
      _llamaParent = null;
      throw LocalFFIException('模型加载失败: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  文本生成（Isolate 隔离，不阻塞 UI）
  // ════════════════════════════════════════════════════════════════════════

  /// 阻塞式生成（等待完整结果）
  Future<String> generate(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    _ensureInitialized();

    final prompt = _buildPrompt(messages);
    final promptId = await _llamaParent!.sendPrompt(prompt);

    // 等待生成完成
    await _llamaParent!.waitForCompletion(promptId);

    // 收集所有 token
    final buffer = StringBuffer();
    await for (final token in _llamaParent!.stream) {
      buffer.write(token);
    }

    return buffer.toString();
  }

  /// 流式生成（实时返回 token，不阻塞 UI）
  ///
  /// 推理在后台 Isolate 中执行，通过 Stream 实时传递 token
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    _ensureInitialized();

    final prompt = _buildPrompt(messages);
    await _llamaParent!.sendPrompt(prompt);

    // 直接转发 Isolate 的流式输出
    yield* _llamaParent!.stream;
  }

  /// 停止当前生成
  Future<void> stopGeneration() async {
    if (_llamaParent != null && _llamaParent!.isGenerating) {
      await _llamaParent!.stop();
      debugPrint('LocalFFIEngine: Generation stopped');
    }
  }

  /// 构建 prompt 字符串
  /// 将消息列表转换为纯文本 prompt
  String _buildPrompt(List<ChatMessage> messages) {
    final buffer = StringBuffer();

    for (final message in messages) {
      switch (message.role) {
        case 'system':
          buffer.writeln('System: ${message.content}');
          break;
        case 'user':
          buffer.writeln('User: ${message.content}');
          break;
        case 'assistant':
          buffer.writeln('Assistant: ${message.content}');
          break;
        default:
          buffer.writeln(message.content);
      }
    }

    buffer.write('Assistant:');
    return buffer.toString();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  参数构建（llama_cpp_dart 的参数类型）
  // ════════════════════════════════════════════════════════════════════════

  /// 构建 ModelParams（GPU 层数在此设置）
  ModelParams _buildModelParams(LocalModelParams? params) {
    final modelParams = ModelParams();
    // GPU 层数：macOS/iOS Metal 加速，Windows/Linux CUDA 加速
    // nGpuLayers = 99 表示全部卸载到 GPU
    modelParams.nGpuLayers = 99;
    return modelParams;
  }

  /// 构建 ContextParams
  ContextParams _buildContextParams(LocalModelParams? params) {
    final ctx = ContextParams();
    // 上下文窗口大小
    ctx.nCtx = 8192;
    // 线程数
    ctx.nThreads = params?.cpuThreads ?? 4;
    ctx.nThreadsBatch = params?.cpuThreads ?? 4;
    return ctx;
  }

  /// 构建 SamplerParams
  SamplerParams _buildSamplerParams(LocalModelParams? params) {
    final sampler = SamplerParams();
    if (params != null) {
      sampler.temp = params.temperature;
      sampler.topP = params.topPEnabled ? params.topP : 1.0;
      sampler.topK = params.topK;
      sampler.minP = params.minPEnabled ? params.minP : 0.0;
      sampler.penaltyRepeat = params.repeatPenaltyEnabled ? params.repeatPenalty : 1.0;
    }
    return sampler;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  模型管理
  // ════════════════════════════════════════════════════════════════════════

  /// 检查模型是否已加载
  bool isModelLoaded(String modelPath) {
    return _isInitialized && _currentModelPath == modelPath;
  }

  /// 卸载当前模型，释放内存
  Future<void> unloadModel() async {
    if (_llamaParent != null) {
      await _llamaParent!.dispose();
      _llamaParent = null;
      _currentModelPath = null;
      _isInitialized = false;
      debugPrint('LocalFFIEngine: Model unloaded');
    }
  }

  /// 释放所有资源
  Future<void> dispose() async {
    await unloadModel();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  热更新支持
  // ════════════════════════════════════════════════════════════════════════

  /// 热更新后重新加载模型
  ///
  /// 在 llama.cpp 库文件更新后调用，无需重启 App
  Future<void> reloadAfterHotUpdate({
    void Function(double progress, String message)? onProgress,
  }) async {
    if (_currentModelPath == null) {
      debugPrint('LocalFFIEngine: 没有已加载的模型，跳过热更新');
      return;
    }

    final modelPath = _currentModelPath!;
    debugPrint('LocalFFIEngine: 热更新后重新加载模型: $modelPath');

    // 1. 清除库缓存，强制重新查找
    LlamaLibraryLoader.instance.clearCache();

    // 2. 重新设置库路径
    final libraryPath = await LlamaLibraryLoader.instance.getLibraryPath();
    if (libraryPath == null) {
      throw LocalFFIException('热更新后未找到 llama.cpp 库文件');
    }

    Llama.libraryPath = libraryPath;

    // 3. 重新加载模型
    await loadModel(
      modelPath: modelPath,
      onProgress: onProgress,
    );

    debugPrint('LocalFFIEngine: ✅ 热更新完成，模型已重新加载');
  }

  // ════════════════════════════════════════════════════════════════════════
  //  库路径查找
  // ════════════════════════════════════════════════════════════════════════

  /// 获取库文件的完整路径
  Future<String?> _getLibraryFullPath() async {
    final loader = LlamaLibraryLoader.instance;
    return await loader.getLibraryPath();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  辅助方法
  // ════════════════════════════════════════════════════════════════════════

  void _ensureInitialized() {
    if (!_isInitialized || _llamaParent == null) {
      throw LocalFFIException(
        'LocalFFIEngine is not initialized. '
        'Please load a model first using loadModel().',
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
//  异常类
// ════════════════════════════════════════════════════════════════════════

class LocalFFIException implements Exception {
  final String message;
  LocalFFIException(this.message);

  @override
  String toString() => 'LocalFFIException: $message';
}

// ════════════════════════════════════════════════════════════════════════
//  模型信息
// ════════════════════════════════════════════════════════════════════════

class ModelInfo {
  final String path;
  final String backend;
  final bool loaded;

  ModelInfo({
    required this.path,
    required this.backend,
    required this.loaded,
  });
}

// ════════════════════════════════════════════════════════════════════════
//  加速后端枚举
// ════════════════════════════════════════════════════════════════════════

enum AccelerationBackend {
  metal,  // Apple Metal (macOS/iOS)
  cuda,    // NVIDIA CUDA (Windows/Linux)
  vulkan,  // Vulkan (Android)
  cpu,     // CPU only
}
