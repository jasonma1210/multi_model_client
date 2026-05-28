/// 本地代理服务 - 统一 MiMo API 端点并提供重试机制
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 代理服务状态
enum ProxyServiceStatus {
  stopped,
  starting,
  running,
  error,
}

/// 代理请求日志
class ProxyRequestLog {
  final String method;
  final String path;
  final int? statusCode;
  final String? errorMessage;
  final Duration duration;
  final DateTime timestamp;

  ProxyRequestLog({
    required this.method,
    required this.path,
    this.statusCode,
    this.errorMessage,
    required this.duration,
    required this.timestamp,
  });
}

/// 本地代理服务
class LocalProxyService {
  static const String _tag = 'LocalProxyService';
  static const String _defaultTargetBase = 'https://api.xiaomimimo.com/v1';
  static const String _proxyPortKey = 'local_proxy_port';
  static const int _defaultPort = 8099;
  
  HttpServer? _server;
  ProxyServiceStatus _status = ProxyServiceStatus.stopped;
  String _targetBaseUrl = _defaultTargetBase;
  final List<ProxyRequestLog> _requestLogs = [];
  final StreamController<ProxyServiceStatus> _statusController = 
      StreamController<ProxyServiceStatus>.broadcast();
  final StreamController<ProxyRequestLog> _logController = 
      StreamController<ProxyRequestLog>.broadcast();

  /// 代理服务状态流
  Stream<ProxyServiceStatus> get statusStream => _statusController.stream;
  
  /// 请求日志流
  Stream<ProxyRequestLog> get logStream => _logController.stream;
  
  /// 当前状态
  ProxyServiceStatus get status => _status;
  
  /// 本地代理地址
  String? get proxyUrl => _server != null 
      ? 'http://localhost:${_server!.port}' 
      : null;
  
  /// 请求日志列表
  List<ProxyRequestLog> get requestLogs => List.unmodifiable(_requestLogs);

  /// 启动代理服务
  Future<String?> start({int? port}) async {
    if (_status == ProxyServiceStatus.running) {
      debugPrint('[$_tag] Proxy already running on $_server');
      return proxyUrl;
    }

    _updateStatus(ProxyServiceStatus.starting);

    try {
      // 读取配置
      final prefs = await SharedPreferences.getInstance();
      final targetUrl = prefs.getString('mimo_base_url');
      if (targetUrl != null && targetUrl.isNotEmpty) {
        _targetBaseUrl = targetUrl;
      }
      
      final proxyPort = port ?? prefs.getInt(_proxyPortKey) ?? _defaultPort;

      // 启动 HTTP 服务器
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, proxyPort);
      debugPrint('[$_tag] Proxy started on port $proxyPort, target: $_targetBaseUrl');

      // 监听请求
      _server!.listen(_handleRequest);

      _updateStatus(ProxyServiceStatus.running);
      return proxyUrl;
    } catch (e) {
      debugPrint('[$_tag] Failed to start proxy: $e');
      _updateStatus(ProxyServiceStatus.error);
      return null;
    }
  }

  /// 停止代理服务
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
    _updateStatus(ProxyServiceStatus.stopped);
    debugPrint('[$_tag] Proxy stopped');
  }

  /// 处理代理请求
  Future<void> _handleRequest(HttpRequest request) async {
    final stopwatch = Stopwatch()..start();
    final path = request.uri.path;
    final method = request.method;

    debugPrint('[$_tag] Proxy request: $method $path');

    try {
      // 构建目标 URL
      final targetUrl = '$_targetBaseUrl$path${request.uri.hasQuery ? '?${request.uri.query}' : ''}';

      // 创建 HTTP 客户端
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      
      // 转发请求
      final proxyRequest = await client.openUrl(method, Uri.parse(targetUrl));
      
      // 复制请求头
      request.headers.forEach((name, values) {
        if (name != 'host' && name != 'connection') {
          proxyRequest.headers.set(name, values);
        }
      });

      // 复制请求体
      if (method == 'POST' || method == 'PUT') {
        final body = await request.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        proxyRequest.add(body);
      }

      // 获取响应
      final proxyResponse = await proxyRequest.close();
      
      // 设置响应头
      proxyResponse.headers.forEach((name, values) {
        request.response.headers.set(name, values);
      });
      request.response.statusCode = proxyResponse.statusCode;

      // 复制响应体
      await proxyResponse.pipe(request.response);

      stopwatch.stop();
      _addLog(ProxyRequestLog(
        method: method,
        path: path,
        statusCode: proxyResponse.statusCode,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      ));

      debugPrint('[$_tag] Proxy response: ${proxyResponse.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
    } catch (e) {
      stopwatch.stop();
      final errorMsg = 'Proxy error: $e';
      debugPrint('[$_tag] $errorMsg');

      // 返回错误响应
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.set('Content-Type', 'application/json');
      request.response.write(jsonEncode({'error': errorMsg}));

      _addLog(ProxyRequestLog(
        method: method,
        path: path,
        errorMessage: errorMsg,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
      ));
    } finally {
      await request.response.close();
    }
  }

  /// 添加请求日志
  void _addLog(ProxyRequestLog log) {
    _requestLogs.add(log);
    _logController.add(log);
    
    // 只保留最近 100 条日志
    if (_requestLogs.length > 100) {
      _requestLogs.removeAt(0);
    }
  }

  /// 更新状态
  void _updateStatus(ProxyServiceStatus status) {
    _status = status;
    _statusController.add(status);
  }

  /// 释放资源
  void dispose() {
    stop();
    _statusController.close();
    _logController.close();
  }
}

/// 单例实例
final localProxyService = LocalProxyService();
