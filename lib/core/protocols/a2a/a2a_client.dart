// v0.43.0 实现 A2A JSON-RPC 客户端（支持 reconnect 和 Last-Event-ID 续传）
//
// A2A over JSON-RPC 2.0 over HTTP
// 端点：<agent_url>/a2a
// 传输：HTTP POST（同步） + SSE（流式，含 Last-Event-ID 续传）
//
// 移动端关键能力：
// 1. 心跳检测：服务端超过 heartbeatTimeout 无事件则视为断开
// 2. 指数退避自动重连：initialBackoff → maxBackoff (含 jitter 防止雪崩)
// 3. Last-Event-ID 续传：SSE 协议原生支持，断线后从最后收到的事件 ID 继续
// 4. 优雅关闭：cancel() 后停止重连
// 5. 重连状态事件：通过 A2AStreamSubscription.events 监听（reconnecting/connected/closed）
// 6. 可重试错误分类：网络/超时/5xx 重试，4xx 立即失败
// 7. 暂停/恢复：pause() / resume() 用于移动端网络切换场景

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

  /// jitter 比例（0.0 - 1.0），用于防止雷鸣群
  final double jitterRatio;

  /// 连接建立后的空闲超时
  final Duration idleTimeout;

  const A2AReconnectConfig({
    this.initialBackoff = const Duration(seconds: 3),
    this.maxBackoff = const Duration(seconds: 30),
    this.maxRetries = 0,
    this.heartbeatTimeout = const Duration(seconds: 45),
    this.jitterRatio = 0.3,
    this.idleTimeout = const Duration(seconds: 120),
  });

  static const defaultConfig = A2AReconnectConfig();
}

/// 重连状态（用于 UI 反馈）
enum A2AReconnectState {
  /// 正在连接
  connecting,

  /// 已连接
  connected,

  /// 等待重连
  reconnecting,

  /// 已关闭（最终态）
  closed,
}

/// A2A 重连状态事件（与业务事件 A2AStreamEvent 分开传输）
class A2AReconnectEvent {
  final A2AReconnectState state;
  final int attempt;
  final Duration? nextBackoff;
  final String? reason;

  const A2AReconnectEvent({
    required this.state,
    this.attempt = 0,
    this.nextBackoff,
    this.reason,
  });

  @override
  String toString() => 'A2AReconnectEvent($state, attempt=$attempt, backoff=$nextBackoff, reason=$reason)';
}

/// A2A 客户端
class A2AClient {
  final String agentUrl;
  final Dio _dio;
  final Map<String, String> _headers;
  final A2AReconnectConfig _reconnectConfig;
  final math.Random _random = math.Random();

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

  /// 暴露 reconnect config（用于 UI 展示）
  A2AReconnectConfig get reconnectConfig => _reconnectConfig;

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
  /// - 断线自动重连（指数退避 + jitter）
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
    final businessController = StreamController<A2AStreamEvent>.broadcast();
    final reconnectController = StreamController<A2AReconnectEvent>.broadcast();
    final state = _StreamState();
    bool cancelled = false;
    bool paused = false;

    Timer? reconnectTimer;
    Timer? heartbeatTimer;
    Timer? idleTimer;
    StreamSubscription<String>? currentSub;
    CancelToken? cancelToken;

    void emitReconnect(A2AReconnectEvent event) {
      if (reconnectController.isClosed) return;
      reconnectController.add(event);
    }

    // 使用 late 变量避开 Dart 局部函数前向引用问题
    late Future<void> Function({String? lastEventId}) connect;

    void scheduleReconnect(String reason) {
      if (cancelled || paused) return;
      if (_reconnectConfig.maxRetries > 0 &&
          state.retryAttempt >= _reconnectConfig.maxRetries) {
        emitReconnect(A2AReconnectEvent(
          state: A2AReconnectState.closed,
          attempt: state.retryAttempt,
          reason: '超过最大重试次数（${_reconnectConfig.maxRetries}）',
        ));
        businessController.addError(
          A2AStreamException('超过最大重试次数（${_reconnectConfig.maxRetries}）'),
        );
        businessController.close();
        return;
      }
      final baseMs = math.min(
        _reconnectConfig.initialBackoff.inMilliseconds *
            math.pow(2, state.retryAttempt).toInt(),
        _reconnectConfig.maxBackoff.inMilliseconds,
      );
      // jitter: [base * (1 - r), base * (1 + r)]
      final jitterMs = _reconnectConfig.jitterRatio > 0
          ? (baseMs * _reconnectConfig.jitterRatio * (_random.nextDouble() * 2 - 1)).round()
          : 0;
      final backoffMs = (baseMs + jitterMs).clamp(0, _reconnectConfig.maxBackoff.inMilliseconds);
      state.retryAttempt++;
      final backoff = Duration(milliseconds: backoffMs);
      debugPrint(
        '[A2A] 将在 ${backoff.inMilliseconds}ms 后重连 (第 ${state.retryAttempt} 次)，Last-Event-ID: ${state.lastEventId}, reason: $reason',
      );
      emitReconnect(A2AReconnectEvent(
        state: A2AReconnectState.reconnecting,
        attempt: state.retryAttempt,
        nextBackoff: backoff,
        reason: reason,
      ));
      reconnectTimer?.cancel();
      reconnectTimer = Timer(backoff, () {
        if (!cancelled && !paused) connect(lastEventId: state.lastEventId);
      });
    }

    void startHeartbeat() {
      heartbeatTimer?.cancel();
      heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (cancelled || paused) return;
        final elapsed = DateTime.now().difference(state.lastEventTime);
        if (elapsed > _reconnectConfig.heartbeatTimeout) {
          debugPrint('[A2A] heartbeat timeout (${elapsed.inSeconds}s)，触发重连');
          currentSub?.cancel();
          scheduleReconnect('heartbeat-timeout');
        }
      });
    }

    void startIdleTimer() {
      idleTimer?.cancel();
      idleTimer = Timer(_reconnectConfig.idleTimeout, () {
        if (cancelled || paused) return;
        // 长时间无事件主动断开触发重连（保持 Last-Event-ID 续传）
        debugPrint('[A2A] idle timeout (${_reconnectConfig.idleTimeout.inSeconds}s)，触发 keep-alive 重连');
        currentSub?.cancel();
        scheduleReconnect('idle-keep-alive');
      });
    }

    void resetAllTimers() {
      state.lastEventTime = DateTime.now();
      startHeartbeat();
      startIdleTimer();
    }

    connect = ({String? lastEventId}) async {
      if (cancelled || paused) return;
      cancelToken?.cancel('reconnecting');
      cancelToken = CancelToken();

      emitReconnect(A2AReconnectEvent(
        state: A2AReconnectState.connecting,
        attempt: state.retryAttempt,
      ));

      final body = _buildRpcBody(method, params);
      try {
        final headers = <String, String>{
          ..._headers,
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
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

        if (cancelled || paused) return;
        state.connected = true;
        state.retryAttempt = 0;
        state.receivedEnd = false;
        emitReconnect(const A2AReconnectEvent(state: A2AReconnectState.connected));

        resetAllTimers();

        final lineStream = response.data!.stream
            .map((chunk) => utf8.decode(chunk))
            .transform(const LineSplitter());
        currentSub = lineStream.listen(
          (line) {
            if (cancelled || paused) return;
            _handleSseLine(
              line,
              state: state,
              controller: businessController,
            );
            // 收到事件，重置心跳
            resetAllTimers();
          },
          onError: (e, st) {
            debugPrint('[A2A] stream error: $e');
            state.connected = false;
            if (!cancelled && !paused) scheduleReconnect('stream-error: $e');
          },
          onDone: () {
            debugPrint('[A2A] stream done');
            state.connected = false;
            if (!state.receivedEnd && !cancelled && !paused) {
              scheduleReconnect('stream-done-without-end');
            } else if (state.receivedEnd) {
              emitReconnect(const A2AReconnectEvent(state: A2AReconnectState.closed, reason: 'completed'));
            }
          },
          cancelOnError: true,
        );
      } on DioException catch (e) {
        if (cancelled || paused) return;
        debugPrint('[A2A] connect error: ${e.message}');
        state.connected = false;
        if (e.type == DioExceptionType.cancel) return;
        if (!_isRetryableDioError(e)) {
          // 不可重试错误：直接关闭
          emitReconnect(A2AReconnectEvent(
            state: A2AReconnectState.closed,
            reason: 'non-retryable: ${e.type}',
          ));
          businessController.addError(A2AStreamException('A2A 不可重试错误: ${e.message}'));
          await businessController.close();
          return;
        }
        scheduleReconnect('dio-${e.type}');
      } catch (e) {
        if (cancelled || paused) return;
        debugPrint('[A2A] unexpected error: $e');
        state.connected = false;
        scheduleReconnect('unexpected: $e');
      }
    };

    Future<void> doCancel() async {
      cancelled = true;
      paused = false;
      reconnectTimer?.cancel();
      heartbeatTimer?.cancel();
      idleTimer?.cancel();
      cancelToken?.cancel('user-cancelled');
      await currentSub?.cancel();
      if (!businessController.isClosed) {
        await businessController.close();
      }
      if (!reconnectController.isClosed) {
        emitReconnect(const A2AReconnectEvent(state: A2AReconnectState.closed, reason: 'cancelled'));
        await reconnectController.close();
      }
    }

    void doPause() {
      if (cancelled) return;
      paused = true;
      reconnectTimer?.cancel();
      heartbeatTimer?.cancel();
      idleTimer?.cancel();
      cancelToken?.cancel('paused');
      currentSub?.cancel();
      state.connected = false;
      debugPrint('[A2A] stream paused (lastEventId=${state.lastEventId})');
    }

    void doResume() {
      if (cancelled || !paused) return;
      paused = false;
      state.retryAttempt = 0; // 用户主动恢复时重置重试计数
      debugPrint('[A2A] stream resuming from lastEventId=${state.lastEventId}');
      connect(lastEventId: state.lastEventId);
    }

    // 启动第一次连接
    connect();

    return A2AStreamSubscription._(
      businessController: businessController,
      reconnectController: reconnectController,
      cancel: doCancel,
      pause: doPause,
      resume: doResume,
    );
  }

  /// 判断 Dio 错误是否可重试
  bool _isRetryableDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return true;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return false;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        // 5xx 和 408/429 重试，其他 4xx 立即失败
        return code >= 500 || code == 408 || code == 429;
    }
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
    // SSE 注释行（心跳），忽略
    if (line.startsWith(':')) return;
    if (!line.startsWith('data:')) return;
    final data = line.substring(5).trim();
    if (data.isEmpty || data == '[DONE]') return;

    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final event = A2AStreamEvent.fromJson(json);
      if (event is A2AEndEvent) {
        state.receivedEnd = true;
      }
      if (!controller.isClosed) controller.add(event);
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
  /// 业务事件流（A2AStreamEvent）
  final Stream<A2AStreamEvent> stream;

  /// 重连状态事件流（用于 UI 提示"正在重连..."）
  final Stream<A2AReconnectEvent> events;

  /// 取消订阅（不可恢复）
  final Future<void> Function() cancel;

  /// 暂停（保留 Last-Event-ID，可 resume）
  final void Function() pause;

  /// 恢复（从 Last-Event-ID 继续）
  final void Function() resume;

  A2AStreamSubscription._({
    required StreamController<A2AStreamEvent> businessController,
    required StreamController<A2AReconnectEvent> reconnectController,
    required this.cancel,
    required this.pause,
    required this.resume,
  })  : stream = businessController.stream,
        events = reconnectController.stream;

  /// 测试用工厂构造器
  @visibleForTesting
  factory A2AStreamSubscription.test({
    required StreamController<A2AStreamEvent> controller,
    required StreamController<A2AReconnectEvent>? reconnectController,
    required Future<void> Function() cancel,
    void Function()? pause,
    void Function()? resume,
  }) {
    final rc = reconnectController ?? StreamController<A2AReconnectEvent>.broadcast();
    return A2AStreamSubscription._(
      businessController: controller,
      reconnectController: rc,
      cancel: cancel,
      pause: pause ?? () {},
      resume: resume ?? () {},
    );
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
