/// llama-server 进程管理器 - LM Studio 架构
///
/// 桌面端使用独立的 llama-server 进程，而不是直接 FFI 调用
/// 优点：
/// - 热更新引擎：只需替换 llama-server 文件
/// - 进程隔离：llama.cpp 崩溃不会导致 Flutter UI 闪退
/// - 标准 API：通过 HTTP 与 llama-server 通信
///
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// llama-server 进程状态
enum LlamaServerState {
  stopped,
  starting,
  ready,
  error,
}

/// llama-server 进程管理器
class LlamaServerProcess {
  static final LlamaServerProcess _instance = LlamaServerProcess._();
  static LlamaServerProcess get instance => _instance;

  LlamaServerProcess._();

  Process? _process;
  String? _currentModelPath;
  int _port = 8080;
  LlamaServerState _state = LlamaServerState.stopped;
  String? _runtimePath;

  // 状态
  LlamaServerState get state => _state;
  String? get currentModelPath => _currentModelPath;
  int get port => _port;
  bool get isRunning => _state == LlamaServerState.ready;

  /// 初始化运行时目录
  Future<void> initialize() async {
    _runtimePath = await _getRuntimePath();
    debugPrint('[LlamaServerProcess] 运行时目录: $_runtimePath');
  }

  /// 获取运行时目录路径
  Future<String> _getRuntimePath() async {
    // 根据平台选择目录
    if (Platform.isMacOS || Platform.isIOS) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/Library/Application Support/LLM Studio/runtime';
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      return '$appData/LLM Studio/runtime';
    } else {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/.llm_studio/runtime';
    }
  }

  /// 获取 llama-server 可执行文件路径
  String get serverExecutablePath {
    if (_runtimePath == null) {
      throw Exception('LlamaServerProcess 未初始化，请先调用 initialize()');
    }

    if (Platform.isMacOS) {
      return '$_runtimePath/llama-server';
    } else if (Platform.isWindows) {
      return '$_runtimePath/llama-server.exe';
    } else {
      return '$_runtimePath/llama-server';
    }
  }

  /// 启动 llama-server 并加载模型
  Future<void> start({
    required String modelPath,
    int port = 8080,
    int contextSize = 8192,
    int gpuLayers = 99,
    void Function(double progress, String message)? onProgress,
  }) async {
    // 如果已有进程，先停止
    if (_process != null) {
      await stop();
    }

    _port = port;
    _state = LlamaServerState.starting;
    onProgress?.call(0.1, '正在启动 llama-server...');

    // 检查运行时是否存在
    final serverPath = serverExecutablePath;
    if (!File(serverPath).existsSync()) {
      _state = LlamaServerState.error;
      throw Exception(
        'llama-server 未找到！\n\n'
        '请先在设置中下载并更新 llama.cpp 运行时\n'
        '运行时路径: $serverPath',
      );
    }

    // 赋予可执行权限 (macOS/Linux)
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', serverPath]);
    }

    onProgress?.call(0.2, '正在加载模型: ${modelPath.split('/').last}');

    // 构建参数
    final args = [
      '-m', modelPath,           // 模型路径
      '--port', port.toString(), // 端口
      '-c', contextSize.toString(), // 上下文长度
      '-ngl', gpuLayers.toString(), // GPU 加速层数
      '--host', '127.0.0.1',     // 仅本地访问
    ];

    debugPrint('[LlamaServerProcess] 启动命令: $serverPath ${args.join(' ')}');

    try {
      // 启动进程
      _process = await Process.start(
        serverPath,
        args,
        mode: ProcessStartMode.normal,
      );

      _currentModelPath = modelPath;

      // 监听输出，等待服务器就绪
      final completer = Completer<void>();

      _process!.stdout.transform(utf8.decoder).listen((data) {
        debugPrint('[LlamaServer] $data');

        // 检测服务器启动成功
        if (data.contains('HTTP server listening') || 
            data.contains('server listening') ||
            data.contains('llama server ready')) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      });

      _process!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint('[LlamaServer ERROR] $data');
      });

      // 等待服务器启动，最多 30 秒
      onProgress?.call(0.5, '等待模型加载...');
      
      try {
        await completer.future.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            // 即使超时也尝试连接，可能只是日志不同
            debugPrint('[LlamaServerProcess] 启动超时但继续尝试');
          },
        );
      } catch (e) {
        debugPrint('[LlamaServerProcess] 等待启动: $e');
      }

      // 等待一小段时间确保服务器完全就绪
      await Future.delayed(const Duration(seconds: 2));

      // 测试连接
      final connected = await _testConnection();
      if (!connected) {
        throw Exception('无法连接到 llama-server');
      }

      _state = LlamaServerState.ready;
      onProgress?.call(1.0, '模型加载完成');

      debugPrint('[LlamaServerProcess] ✅ llama-server 已启动，端口: $port');
    } catch (e) {
      _state = LlamaServerState.error;
      await stop();
      rethrow;
    }
  }

  /// 测试服务器连接
  Future<bool> _testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:$_port/v1/models'),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[LlamaServerProcess] 连接测试失败: $e');
      return false;
    }
  }

  /// 停止 llama-server
  Future<void> stop() async {
    if (_process != null) {
      debugPrint('[LlamaServerProcess] 停止 llama-server...');
      
      // 尝试优雅退出
      _process!.kill(ProcessSignal.sigterm);
      
      // 等待进程退出
      await _process!.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // 强制杀死
          _process!.kill(ProcessSignal.sigkill);
          return -1;
        },
      );

      _process = null;
    }

    _currentModelPath = null;
    _state = LlamaServerState.stopped;
    debugPrint('[LlamaServerProcess] ✅ llama-server 已停止');
  }

  /// 检查是否有模型加载
  bool hasModelLoaded(String modelPath) {
    return _state == LlamaServerState.ready && 
           _currentModelPath == modelPath;
  }

  /// 获取服务器基础 URL
  String get baseUrl => 'http://127.0.0.1:$_port';

  /// 释放所有资源
  Future<void> dispose() async {
    await stop();
  }
}