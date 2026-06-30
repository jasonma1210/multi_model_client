// v0.43.0 实现 A2A JSON-RPC 客户端（支持 reconnect 和 Last-Event-ID 续传）
//
// A2A over JSON-RPC 2.0 over HTTP
// 端点：<agent_url>/a2a
// 传输：HTTP POST（同步） + SSE（流式，含 Last-Event-ID 续传）
//
// 移动端关键能力：
// 1. 心跳检测：服务端超过 30s 无事件则视为断开
// 2. 指数退避自动重连：3s -> 6s -> 12s -> 24s -> 30s (capped)
// 3. Last-Event-ID 续传：SSE 协议原生支持，断线后从最后收到的事件 ID 继续
// 4. 优雅关闭：cancel() 后停止重连

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'a2a_protocol.dart';
import 'a2a_stream_event.dart';

/// A2A JSON-RPC 方法名
class A2AMethods {
  static const sendMessage = 'SendMessage';
  static const sendStreamingMessage = 'SendStreamingMessage';
  static const getTask = 'GetTask';
  static const listTasks = 'ListTasks';
  static const cancelTask = 'CancelTask';
  static const agentCard = 'GetAgentCard';
  static const subscribeTask = 'SubscribeTask';
}

/// Reconnect 配置
class A2AReconnectConfig {
  /// 初始退避
  final Duration initialBackoff;

  /// 最大退避
  final Duration maxBackoff;

  /// 最大重试次数（0 = 无限）
  final int maxRetries;

  /// 心跳超时：超过这个时间没收到任何事件就视为断开
  final Duration heartbeatTimeout;

  const A2AReconnectConfig({
    this.initialBackoff = const Duration(seconds: 3),
    this.maxBackoff = const Duration(seconds: 30),
    this.maxRetries = 0,
    this.heartbeatTimeout = const Duration(seconds: 45),
  });

  static const defaultConfig = A2AReconnectConfig();
}

/// A2A 客户端
class A2AClient {
  final String agentUrl;
  final Dio _dio;
  final Map<String, String> _headers;
  final A2AReconnectConfig _reconnectConfig;

  A2AClient({
    required this.agentUrl,
    String? apiKey,
    Dio? dio,
    A2AReconnectConfig reconnectConfig = A2AReconnectConfig.defaultConfig,
  })  : _dio = dio ?? Dio(),
        _reconnectConfig = reconnectConfig,
        _headers = {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        };

  // === 同步 API ===

  /// 获取 Agent Card
  Future<AgentCard> getAgentCard() async {
    final response = await _sendRpc(A2AMethods.agentCard, {});
    if (response['error'] != null) {
      throw _wrapError(response['error'] as Map<String, dynamic>);
    }
    final result = response['result'] as Map<String, dynamic>;
    return AgentCard.fromJson(result);
  }

  /// 发送消息（同步）
  Future<A2ATask> sendMessage({
    required String messageId,
    required String contextId,
    required List<Part> parts,
    String? referenceTaskIds,
    Map<String, dynamic>? metadata,
  }) async {
    final params = {
      'message': {
        'messageId': messageId,
        'role': 'user',
        'parts': parts.map((p) => p.toJson()).toList(),
        'contextId': contextId,
        if (referenceTaskIds != null) 'referenceTaskIds': referenceTaskIds,
        if (metadata != null) 'metadata': metadata,
      },
    };
    final response = await _sendRpc(A2AMethods.sendMessage, params);
    if (response['error'] != null) {
      throw _wrapError(response['error'] as Map<String, dynamic>);
    }
    return A2ATask.fromJson(response['result'] as Map<String, dynamic>);
  }

  /// 获取任务状态
  Future<A2ATask?> getTask(String taskId, {int? historyLength}) async {
    final response = await _sendRpc(A2AMethods.getTask, {
      'taskId': taskId,
      if (historyLength != null) 'historyLength': historyLength,
    });
    if (response['error'] != null) {
      final err = response['error'] as Map<String, dynamic>;
      if ((err['code'] as int?) == -32001) return null;
      throw _wrapError(err);
    }
    return A2ATask.fromJson(response['result'] as Map<String, dynamic>);
  }

  /// 取消任务
  Future<bool> cancelTask(String taskId) async {
    final response = await _sendRpc(A2AMethods.cancelTask, {'taskId': taskId});
    if (response['error'] != null) {
      throw _wrapError(response['error'] as Map<String, dynamic>);
    }
    return (response['result'] as Map<String, dynamic>)['success'] as bool? ?? false;
  }

  /// 列出任务
  Future<List<A2ATask>> listTasks({String? contextId, int? limit}) async {
    final response = await _sendRpc(A2AMethods.listTasks, {
      if (contextId != null) 'contextId': contextId,
      if (limit != null) 'limit': limit,
    });
    if (response['error'] != null) {
      throw _wrapError(response['error'] as Map<String, dynamic>);
    }
    final result = response['result'] as Map<String, dynamic>;
    final tasks = result['tasks'] as List<dynamic>? ?? [];
    return tasks.map((t) => A2ATask.fromJson(t as Map<String, dynamic>)).toList();
  }

  // === 流式 API（支持 reconnect）===

  /// 发送流式消息（SSE）
  ///
  /// 内部会处理：
  /// - 心跳超时
  /// - 断线自动重连（指数退避）
  /// - Last-Event-ID 续传
  ///
  /// 取消订阅：调用返回的 [A2AStreamSubscription].cancel()
  A2AStreamSubscription sendStreamingMessage({
    required String messageId,
    required String contextId,
    required List<Part> parts,
    String? referenceTaskIds,
    Map<String, dynamic>? metadata,
  }) {
    final params = {
      'message': {
        'messageId': messageId,
        'role': 'user',
        'parts': parts.map((p) => p.toJson()).toList(),
        'contextId': contextId,
        if (referenceTaskIds != null) 'referenceTaskIds': referenceTaskIds,
        if (metadata != null) 'metadata': metadata,
      },
    };
    return _streamRpc(
      method: A2AMethods.sendStreamingMessage,
      params: params,
    );
  }

  /// 订阅已有任务的事件流
  A2AStreamSubscription subscribeTask(String taskId) {
    return _streamRpc(
      method: A2AMethods.subscribeTask,
      params: {'taskId': taskId},
    );
  }

  // === Private ===

  A2AStreamSubscription _streamRpc({
    required String method,
    required Map<String, dynamic> params,
  }) {
    final controller = StreamController<A2AStreamEvent>.broadcast();
    final state = _StreamState();
    bool cancelled = false;

    Timer? reconnectTimer;
    Timer? heartbeatTimer;
    StreamSubscription<String>? currentSub;
    CancelToken? cancelToken;

    // 使用 late 变量避开 Dart 局部函数前向引用问题
    late Future<void> Function({String? lastEventId}) connect;

    void scheduleReconnect() {
      if (cancelled) return;
      if (_reconnectConfig.maxRetries > 0 &&
          state.retryAttempt >= _reconnectConfig.maxRetries) {
        controller.addError(
          A2AStreamException('超过最大重试次数（${_reconnectConfig.maxRetries}）'),
        );
        controller.close();
        return;
      }
      final backoffMs = math.min(
        _reconnectConfig.initialBackoff.inMilliseconds *
            math.pow(2, state.retryAttempt).toInt(),
        _reconnectConfig.maxBackoff.inMilliseconds,
      );
      state.retryAttempt++;
      debugPrint(
        '[A2A] 将在 ${backoffMs}ms 后重连 (第 ${state.retryAttempt} 次)，Last-Event-ID: ${state.lastEventId}',
      );
      reconnectTimer?.cancel();
      reconnectTimer = Timer(Duration(milliseconds: backoffMs), () {
        if (!cancelled) connect(lastEventId: state.lastEventId);
      });
    }

    void startHeartbeat() {
      heartbeatTimer?.cancel();
      heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (cancelled) return;
        final elapsed = DateTime.now().difference(state.lastEventTime);
        if (elapsed > _reconnectConfig.heartbeatTimeout) {
          debugPrint('[A2A] heartbeat timeout (${elapsed.inSeconds}s)，触发重连');
          currentSub?.cancel();
          scheduleReconnect();
        }
      });
    }

    connect = ({String? lastEventId}) async {
      if (cancelled) return;
      cancelToken?.cancel('reconnecting');
      cancelToken = CancelToken();

      final body = _buildRpcBody(method, params);
      try {
        final headers = <String, String>{
          ..._headers,
          'Accept': 'text/event-stream',
          if (lastEventId != null) 'Last-Event-ID': lastEventId,
        };
        final response = await _dio.post<ResponseBody>(
          '$agentUrl/a2a',
          data: body,
          options: Options(
            headers: headers,
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(seconds: 90),
          ),
          cancelToken: cancelToken,
        );

        if (cancelled) return;
        state.connected = true;
        state.retryAttempt = 0;

        startHeartbeat();

        final lineStream = response.data!.stream
            .map((chunk) => utf8.decode(chunk))
            .transform(const LineSplitter());
        currentSub = lineStream.listen(
          (line) {
            if (cancelled) return;
            _handleSseLine(
              line,
              state: state,
              controller: controller,
            );
            // 收到事件，重置心跳
            startHeartbeat();
          },
          onError: (e, st) {
            debugPrint('[A2A] stream error: $e');
            state.connected = false;
            if (!cancelled) scheduleReconnect();
          },
          onDone: () {
            debugPrint('[A2A] stream done');
            state.connected = false;
            if (!state.receivedEnd && !cancelled) {
              scheduleReconnect();
            }
          },
          cancelOnError: true,
        );
      } on DioException catch (e) {
        if (cancelled) return;
        debugPrint('[A2A] connect error: ${e.message}');
        state.connected = false;
        if (e.type != DioExceptionType.cancel) {
          scheduleReconnect();
        }
      } catch (e) {
        if (cancelled) return;
        debugPrint('[A2A] unexpected error: $e');
        state.connected = false;
        scheduleReconnect();
      }
    };

    // 启动第一次连接
    connect();

    return A2AStreamSubscription._(
      controller: controller,
      cancel: () async {
        cancelled = true;
        reconnectTimer?.cancel();
        heartbeatTimer?.cancel();
        cancelToken?.cancel('user-cancelled');
        await currentSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );
  }

  void _handleSseLine(
    String line, {
    required _StreamState state,
    required StreamController<A2AStreamEvent> controller,
  }) {
    if (line.isEmpty) return;
    state.lastEventTime = DateTime.now();

    if (line.startsWith('id:')) {
      state.lastEventId = line.substring(3).trim();
      return;
    }
    if (line.startsWith('event:')) {
      state.eventType = line.substring(6).trim();
      return;
    }
    if (!line.startsWith('data:')) return;
    final data = line.substring(5).trim();
    if (data.isEmpty || data == '[DONE]') return;

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final event = A2AStreamEvent.fromJson(json);
      if (event is A2AEndEvent) {
        state.receivedEnd = true;
      }
      controller.add(event);
    } catch (e) {
      debugPrint('[A2A] parse error: $e, data: $data');
    }
  }

  Future<Map<String, dynamic>> _sendRpc(String method, Map<String, dynamic> params) async {
    final body = _buildRpcBody(method, params);
    try {
      final response = await _dio.post(
        '$agentUrl/a2a',
        data: body,
        options: Options(headers: _headers, receiveTimeout: const Duration(seconds: 30)),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('A2A RPC error: ${e.response?.statusCode} ${e.message}');
    }
  }

  Map<String, dynamic> _buildRpcBody(String method, Map<String, dynamic> params) {
    return {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
  }

  Exception _wrapError(Map<String, dynamic> error) {
    return Exception('A2A error ${error['code']}: ${error['message']}');
  }
}

/// SSE 流订阅句柄
class A2AStreamSubscription {
  final Stream<A2AStreamEvent> stream;
  final Future<void> Function() cancel;

  A2AStreamSubscription._({
    required StreamController<A2AStreamEvent> controller,
    required this.cancel,
  }) : stream = controller.stream;

  /// 测试用工厂构造器
  @visibleForTesting
  factory A2AStreamSubscription.test({
    required StreamController<A2AStreamEvent> controller,
    required Future<void> Function() cancel,
  }) {
    return A2AStreamSubscription._(controller: controller, cancel: cancel);
  }
}

class _StreamState {
  bool connected = false;
  bool receivedEnd = false;
  String? lastEventId;
  String? eventType;
  DateTime lastEventTime = DateTime.now();
  int retryAttempt = 0;
}

/// A2A 流式异常
class A2AStreamException implements Exception {
  final String message;
  const A2AStreamException(this.message);

  @override
  String toString() => 'A2AStreamException: $message';
}
