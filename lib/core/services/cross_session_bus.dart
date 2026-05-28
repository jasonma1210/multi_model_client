/// 跨会话通信总线
/// 
/// 提供安全的会话间消息传递机制，用于：
/// - 任务编排中的会话协调
/// - 数据共享和传递
/// - 事件通知
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// 会话消息类型
enum SessionMessageType {
  /// 数据消息
  data,
  
  /// 事件通知
  event,
  
  /// 请求消息
  request,
  
  /// 响应消息
  response,
  
  /// 心跳消息
  heartbeat,
}

/// 会话消息
class SessionMessage {
  /// 消息 ID
  final String id;
  
  /// 发送方会话 ID
  final String fromSessionId;
  
  /// 接收方会话 ID
  final String toSessionId;
  
  /// 消息类型
  final SessionMessageType type;
  
  /// 消息主题
  final String topic;
  
  /// 消息负载
  final Map<String, dynamic> payload;
  
  /// 创建时间
  final DateTime timestamp;
  
  /// 是否已处理
  bool isProcessed;
  
  SessionMessage({
    String? id,
    required this.fromSessionId,
    required this.toSessionId,
    required this.type,
    required this.topic,
    required this.payload,
    DateTime? timestamp,
    this.isProcessed = false,
  }) : id = id ?? _generateMessageId(),
       timestamp = timestamp ?? DateTime.now();
  
  /// 生成消息 ID
  static String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}';
  }
  
  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromSessionId': fromSessionId,
      'toSessionId': toSessionId,
      'type': type.name,
      'topic': topic,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'isProcessed': isProcessed,
    };
  }
  
  /// 从 JSON 反序列化
  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    return SessionMessage(
      id: json['id'] as String,
      fromSessionId: json['fromSessionId'] as String,
      toSessionId: json['toSessionId'] as String,
      type: SessionMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SessionMessageType.data,
      ),
      topic: json['topic'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isProcessed: json['isProcessed'] as bool? ?? false,
    );
  }
  
  @override
  String toString() {
    return 'SessionMessage(id: $id, from: $fromSessionId, to: $toSessionId, topic: $topic)';
  }
}

/// 跨会话通信总线
class CrossSessionBus {
  static final CrossSessionBus _instance = CrossSessionBus._internal();
  factory CrossSessionBus() => _instance;
  CrossSessionBus._internal();
  
  /// 消息流控制器
  final Map<String, StreamController<SessionMessage>> _sessionControllers = {};
  
  /// 全局消息流
  final StreamController<SessionMessage> _globalController = 
      StreamController<SessionMessage>.broadcast();
  
  /// 消息历史
  final List<SessionMessage> _messageHistory = [];
  
  /// 最大历史消息数
  static const int maxHistorySize = 1000;
  
  /// 订阅会话消息
  Stream<SessionMessage> subscribe(String sessionId) {
    _sessionControllers.putIfAbsent(
      sessionId,
      () => StreamController<SessionMessage>.broadcast(),
    );
    return _sessionControllers[sessionId]!.stream;
  }
  
  /// 订阅全局消息
  Stream<SessionMessage> subscribeGlobal() {
    return _globalController.stream;
  }
  
  /// 订阅特定主题
  Stream<SessionMessage> subscribeTopic(String sessionId, String topic) {
    return subscribe(sessionId).where((msg) => msg.topic == topic);
  }
  
  /// 发送消息
  Future<void> sendMessage(SessionMessage message) async {
    // 记录消息历史
    _recordMessage(message);
    
    // 发送到目标会话
    final controller = _sessionControllers[message.toSessionId];
    if (controller != null && !controller.isClosed) {
      controller.add(message);
    }
    
    // 发送到全局流
    if (!_globalController.isClosed) {
      _globalController.add(message);
    }
    
    debugPrint('[CrossSessionBus] 消息已发送: ${message.topic} (${message.fromSessionId} -> ${message.toSessionId})');
  }
  
  /// 广播消息
  Future<void> broadcast(
    String fromSessionId,
    String topic,
    Map<String, dynamic> payload, {
    SessionMessageType type = SessionMessageType.event,
  }) async {
    final message = SessionMessage(
      fromSessionId: fromSessionId,
      toSessionId: '*', // 广播
      type: type,
      topic: topic,
      payload: payload,
    );
    
    // 发送到所有会话
    for (final controller in _sessionControllers.values) {
      if (!controller.isClosed) {
        controller.add(message);
      }
    }
    
    // 发送到全局流
    if (!_globalController.isClosed) {
      _globalController.add(message);
    }
    
    _recordMessage(message);
    
    debugPrint('[CrossSessionBus] 广播消息: $topic from $fromSessionId');
  }
  
  /// 发送请求并等待响应
  Future<SessionMessage> sendRequest(
    String fromSessionId,
    String toSessionId,
    String topic,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final requestId = _generateRequestId();
    
    // 创建请求消息
    final request = SessionMessage(
      id: requestId,
      fromSessionId: fromSessionId,
      toSessionId: toSessionId,
      type: SessionMessageType.request,
      topic: topic,
      payload: payload,
    );
    
    // 等待响应
    final completer = Completer<SessionMessage>();
    
    final subscription = subscribe(fromSessionId)
        .where((msg) => 
            msg.type == SessionMessageType.response && 
            msg.topic == topic &&
            msg.payload['requestId'] == requestId)
        .listen((msg) {
      if (!completer.isCompleted) {
        completer.complete(msg);
      }
    });
    
    // 发送请求
    await sendMessage(request);
    
    try {
      // 等待响应或超时
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      throw CrossSessionBusException('请求超时: $topic');
    } finally {
      subscription.cancel();
    }
  }
  
  /// 响应请求
  Future<void> respond(
    SessionMessage request,
    Map<String, dynamic> responseData, {
    bool success = true,
  }) async {
    final response = SessionMessage(
      fromSessionId: request.toSessionId,
      toSessionId: request.fromSessionId,
      type: SessionMessageType.response,
      topic: request.topic,
      payload: {
        'requestId': request.id,
        'success': success,
        'data': responseData,
      },
    );
    
    await sendMessage(response);
  }
  
  /// 生成请求 ID
  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode}';
  }
  
  /// 记录消息
  void _recordMessage(SessionMessage message) {
    _messageHistory.add(message);
    
    // 限制历史大小
    if (_messageHistory.length > maxHistorySize) {
      _messageHistory.removeAt(0);
    }
  }
  
  /// 获取消息历史
  List<SessionMessage> getMessageHistory({
    String? sessionId,
    String? topic,
    int? limit,
  }) {
    var history = List<SessionMessage>.from(_messageHistory);
    
    if (sessionId != null) {
      history = history.where((msg) => 
          msg.fromSessionId == sessionId || msg.toSessionId == sessionId).toList();
    }
    
    if (topic != null) {
      history = history.where((msg) => msg.topic == topic).toList();
    }
    
    if (limit != null && history.length > limit) {
      history = history.sublist(history.length - limit);
    }
    
    return history;
  }
  
  /// 清空消息历史
  void clearHistory() {
    _messageHistory.clear();
  }
  
  /// 取消会话订阅
  void unsubscribe(String sessionId) {
    final controller = _sessionControllers.remove(sessionId);
    controller?.close();
    
    debugPrint('[CrossSessionBus] 取消订阅: $sessionId');
  }
  
  /// 释放资源
  void dispose() {
    for (final controller in _sessionControllers.values) {
      controller.close();
    }
    _sessionControllers.clear();
    _globalController.close();
    _messageHistory.clear();
  }
  
  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'activeSubscriptions': _sessionControllers.length,
      'totalMessages': _messageHistory.length,
      'messageTypes': _getMessageTypeCounts(),
    };
  }
  
  Map<String, int> _getMessageTypeCounts() {
    final counts = <String, int>{};
    for (final msg in _messageHistory) {
      counts[msg.type.name] = (counts[msg.type.name] ?? 0) + 1;
    }
    return counts;
  }
}

/// 跨会话通信异常
class CrossSessionBusException implements Exception {
  final String message;
  
  const CrossSessionBusException(this.message);
  
  @override
  String toString() => 'CrossSessionBusException: $message';
}