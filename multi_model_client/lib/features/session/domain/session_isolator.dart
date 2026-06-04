/// 会话资源隔离器
/// 
/// 管理会话间资源隔离，包括：
/// - 会话上下文管理
/// - 资源锁管理
/// - 并发控制
/// - 资源清理
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/storage/database.dart' show Session, Message;
import 'session_context.dart';

/// 会话隔离器
class SessionIsolator {
  static final SessionIsolator _instance = SessionIsolator._internal();
  factory SessionIsolator() => _instance;
  SessionIsolator._internal();
  
  /// 活跃的会话上下文
  final Map<String, SessionContext> _activeContexts = {};
  
  /// 会话锁管理
  final Map<String, Completer<void>> _sessionLocks = {};
  
  /// 最大活跃会话数
  static const int maxActiveSessions = 50;
  
  /// 会话超时时间
  static const Duration sessionTimeout = Duration(hours: 2);
  
  /// 超时检查定时器
  Timer? _cleanupTimer;
  
  /// 初始化隔离器
  void initialize() {
    // 启动定期清理
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupInactiveSessions(),
    );
    
    debugPrint('[SessionIsolator] 初始化完成');
  }
  
  /// 释放资源
  void dispose() {
    _cleanupTimer?.cancel();
    _activeContexts.clear();
    _sessionLocks.clear();
  }
  
  /// 获取或创建会话上下文
  Future<SessionContext> getOrCreateContext({
    required String sessionId,
    required Session session,
    List<Message>? initialMessages,
  }) async {
    // 检查是否已存在
    if (_activeContexts.containsKey(sessionId)) {
      final context = _activeContexts[sessionId]!;
      context.lastActiveAt = DateTime.now();
      return context;
    }
    
    // 检查是否超过最大活跃会话数
    if (_activeContexts.length >= maxActiveSessions) {
      // 清理最久未活跃的会话
      _evictLeastActiveSession();
    }
    
    // 创建新的上下文
    final context = SessionContext(
      sessionId: sessionId,
      session: session,
      messages: initialMessages,
    );
    
    _activeContexts[sessionId] = context;
    
    debugPrint('[SessionIsolator] 创建会话上下文: $sessionId');
    
    return context;
  }
  
  /// 获取会话上下文
  SessionContext? getContext(String sessionId) {
    final context = _activeContexts[sessionId];
    if (context != null) {
      context.lastActiveAt = DateTime.now();
    }
    return context;
  }
  
  /// 移除会话上下文
  Future<void> removeContext(String sessionId) async {
    final context = _activeContexts.remove(sessionId);
    if (context != null) {
      // 释放锁
      if (context.isLocked) {
        context.unlock();
      }
      
      debugPrint('[SessionIsolator] 移除会话上下文: $sessionId');
    }
  }
  
  /// 获取所有活跃会话 ID
  List<String> getActiveSessionIds() {
    return _activeContexts.keys.toList();
  }
  
  /// 获取活跃会话数量
  int get activeSessionCount => _activeContexts.length;
  
  /// 检查会话是否活跃
  bool isSessionActive(String sessionId) {
    return _activeContexts.containsKey(sessionId);
  }
  
  /// 获取会话锁
  Future<void> acquireSessionLock(
    String sessionId, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final context = _activeContexts[sessionId];
    if (context == null) {
      throw SessionIsolatorException('会话不存在: $sessionId');
    }
    
    await context.lock(timeout: timeout);
  }
  
  /// 释放会话锁
  void releaseSessionLock(String sessionId) {
    final context = _activeContexts[sessionId];
    context?.unlock();
  }
  
  /// 执行会话操作（自动加锁解锁）
  Future<T> executeWithLock<T>(
    String sessionId,
    Future<T> Function(SessionContext context) operation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final context = _activeContexts[sessionId];
    if (context == null) {
      throw SessionIsolatorException('会话不存在: $sessionId');
    }
    
    await context.lock(timeout: timeout);
    
    try {
      return await operation(context);
    } finally {
      context.unlock();
    }
  }
  
  /// 创建会话快照
  SessionSnapshot? createSnapshot(String sessionId) {
    final context = _activeContexts[sessionId];
    return context?.snapshot();
  }
  
  /// 从快照恢复会话
  Future<void> restoreFromSnapshot(SessionSnapshot snapshot) async {
    final context = _activeContexts[snapshot.sessionId];
    if (context != null) {
      context.restore(snapshot);
      debugPrint('[SessionIsolator] 从快照恢复会话: ${snapshot.sessionId}');
    }
  }
  
  /// 清理非活跃会话
  void _cleanupInactiveSessions() {
    final now = DateTime.now();
    final inactiveSessions = <String>[];
    
    for (final entry in _activeContexts.entries) {
      final inactiveTime = now.difference(entry.value.lastActiveAt);
      if (inactiveTime > sessionTimeout) {
        inactiveSessions.add(entry.key);
      }
    }
    
    for (final sessionId in inactiveSessions) {
      _activeContexts.remove(sessionId);
      debugPrint('[SessionIsolator] 清理非活跃会话: $sessionId');
    }
    
    if (inactiveSessions.isNotEmpty) {
      debugPrint('[SessionIsolator] 清理了 ${inactiveSessions.length} 个非活跃会话');
    }
  }
  
  /// 驱逐最久未活跃的会话
  void _evictLeastActiveSession() {
    if (_activeContexts.isEmpty) return;
    
    // 找到最久未活跃的会话
    String? leastActiveId;
    DateTime? leastActiveTime;
    
    for (final entry in _activeContexts.entries) {
      if (leastActiveTime == null || entry.value.lastActiveAt.isBefore(leastActiveTime)) {
        leastActiveId = entry.key;
        leastActiveTime = entry.value.lastActiveAt;
      }
    }
    
    if (leastActiveId != null) {
      _activeContexts.remove(leastActiveId);
      debugPrint('[SessionIsolator] 驱逐会话: $leastActiveId');
    }
  }
  
  /// 获取会话统计信息
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    int lockedCount = 0;
    int activeCount = 0;
    
    for (final context in _activeContexts.values) {
      if (context.isLocked) lockedCount++;
      if (now.difference(context.lastActiveAt).inMinutes < 5) activeCount++;
    }
    
    return {
      'totalSessions': _activeContexts.length,
      'activeSessions': activeCount,
      'lockedSessions': lockedCount,
      'maxSessions': maxActiveSessions,
    };
  }
}

/// 会话隔离器异常
class SessionIsolatorException implements Exception {
  final String message;
  
  const SessionIsolatorException(this.message);
  
  @override
  String toString() => 'SessionIsolatorException: $message';
}