/// 本地服务器推理引擎 - LM Studio 架构（桌面端）
///
/// 使用 llama-server 进程 + HTTP API 通信
/// 特点：
/// - 热更新：只需替换 llama-server 文件
/// - 进程隔离：llama.cpp 崩溃不会导致 Flutter 闪退
/// - 标准 API：兼容 OpenAI 格式
///
/// 适用平台：macOS / Windows / Linux
///
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'llama_server_process.dart';
import 'llama_server_client.dart';
import '../models/model_entry.dart';
import 'model_inference_engine.dart';

/// 本地服务器推理引擎（桌面端）
class LocalServerEngine {
  static final LocalServerEngine _instance = LocalServerEngine._();
  static LocalServerEngine get instance => _instance;

  LocalServerEngine._();

  final LlamaServerProcess _process = LlamaServerProcess.instance;
  LlamaServerClient? _client;
  String? _currentModelPath;

  // 状态
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  String? get currentModelPath => _currentModelPath;

  /// 初始化引擎
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('[LocalServerEngine] 初始化...');
    
    // 初始化运行时目录
    await _process.initialize();
    
    _isInitialized = true;
    debugPrint('[LocalServerEngine] ✅ 初始化完成');
  }

  /// 加载 GGUF 模型
  Future<void> loadModel({
    required String modelPath,
    LocalModelParams? params,
    void Function(double progress, String message)? onProgress,
  }) async {
    // 如果已有模型，先卸载
    await unloadModel();

    debugPrint('[LocalServerEngine] 加载模型: $modelPath');

    // 启动 llama-server
    await _process.start(
      modelPath: modelPath,
      port: 8080,
      contextSize: params?.contextSize ?? 8192,
      gpuLayers: params?.gpuLayers ?? 99,
      onProgress: onProgress,
    );

    // 创建 HTTP 客户端
    _client = LlamaServerClient(baseUrl: _process.baseUrl);
    _currentModelPath = modelPath;

    debugPrint('[LocalServerEngine] ✅ 模型加载完成');
  }

  /// 阻塞式生成
  Future<String> generate(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async {
    _ensureInitialized();

    final response = await _client!.sendChat(
      messages: messages,
      temperature: options?.temperature ?? 0.7,
      maxTokens: options?.maxTokens ?? -1,
    );

    return response;
  }

  /// 流式生成
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    ChatOptions? options,
  }) async* {
    _ensureInitialized();

    await for (final chunk in _client!.sendChatStream(
      messages: messages,
      temperature: options?.temperature ?? 0.7,
      maxTokens: options?.maxTokens ?? -1,
    )) {
      if (chunk.error != null) {
        throw Exception(chunk.error);
      }
      
      if (!chunk.done && chunk.content != null) {
        yield chunk.content!;
      }
    }
  }

  /// 停止当前生成
  Future<void> stopGeneration() async {
    // llama-server 不支持停止，但我们可以断开连接
    debugPrint('[LocalServerEngine] 停止生成（仅断开连接）');
  }

  /// 检查模型是否已加载
  bool isModelLoaded(String modelPath) {
    return _isInitialized && 
           _process.isRunning && 
           _currentModelPath == modelPath;
  }

  /// 卸载当前模型
  Future<void> unloadModel() async {
    if (_process.isRunning) {
      await _process.stop();
    }
    
    _client?.dispose();
    _client = null;
    _currentModelPath = null;
    
    debugPrint('[LocalServerEngine] 模型已卸载');
  }

  /// 释放所有资源
  Future<void> dispose() async {
    await unloadModel();
    _isInitialized = false;
    debugPrint('[LocalServerEngine] 已释放');
  }

  void _ensureInitialized() {
    if (!_isInitialized || _client == null) {
      throw Exception(
        'LocalServerEngine 未初始化。请先调用 loadModel() 加载模型。',
      );
    }
  }
}

/// 本地模型参数（简化版）
class LocalModelParams {
  final int contextSize;
  final int gpuLayers;
  final int cpuThreads;
  final double temperature;
  final int maxTokens;

  const LocalModelParams({
    this.contextSize = 8192,
    this.gpuLayers = 99,
    this.cpuThreads = 4,
    this.temperature = 0.7,
    this.maxTokens = -1,
  });
}

/// 聊天选项
class ChatOptions {
  final double temperature;
  final int maxTokens;
  final double topP;
  final int topK;

  const ChatOptions({
    this.temperature = 0.7,
    this.maxTokens = -1,
    this.topP = 0.9,
    this.topK = 40,
  });
}