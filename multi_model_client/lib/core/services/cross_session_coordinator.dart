/// 跨会话协调器
///
/// 负责：
/// - 工作流节点之间的跨会话数据传递
/// - 会话资源分配和回收
/// - 多会话任务的同步与协调
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'cross_session_bus.dart';

/// 协调任务
class CoordinationTask {
  /// 任务 ID
  final String taskId;

  /// 工作流实例 ID
  final String workflowInstanceId;

  /// 源会话 ID
  final String sourceSessionId;

  /// 目标会话 ID
  final String? targetSessionId;

  /// 任务类型
  final CoordinationTaskType type;

  /// 任务数据
  final Map<String, dynamic> data;

  /// 创建时间
  final DateTime createdAt;

  /// 状态
  CoordinationTaskStatus status;

  /// 完成时间
  DateTime? completedAt;

  /// 结果
  Map<String, dynamic>? result;

  CoordinationTask({
    required this.taskId,
    required this.workflowInstanceId,
    required this.sourceSessionId,
    this.targetSessionId,
    required this.type,
    required this.data,
    DateTime? createdAt,
    this.status = CoordinationTaskStatus.pending,
    this.completedAt,
    this.result,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// 协调任务类型
enum CoordinationTaskType {
  /// 数据传递
  dataTransfer,

  /// 任务委托
  taskDelegation,

  /// 结果汇总
  resultAggregation,

  /// 同步等待
  syncBarrier,

  /// 会话创建
  sessionCreation,
}

/// 协调任务状态
enum CoordinationTaskStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

/// 跨会话协调器
class CrossSessionCoordinator {
  static final CrossSessionCoordinator _instance = CrossSessionCoordinator._internal();
  factory CrossSessionCoordinator() => _instance;
  CrossSessionCoordinator._internal();

  /// 跨会话总线
  final CrossSessionBus _bus = CrossSessionBus();

  /// 活跃协调任务
  final Map<String, CoordinationTask> _activeTasks = {};

  /// 同步屏障
  final Map<String, _SyncBarrier> _syncBarriers = {};

  /// 数据共享池
  final Map<String, Map<String, dynamic>> _sharedDataPool = {};

  /// 订阅流
  final Map<String, StreamSubscription> _subscriptions = {};

  /// 初始化协调器
  void initialize() {
    // 订阅协调相关的消息主题
    _subscriptions['data_transfer'] = _bus.subscribeGlobal().listen((message) {
      if (message.topic == 'coordination:data_transfer') {
        _handleDataTransfer(message);
      }
    });

    _subscriptions['sync_barrier'] = _bus.subscribeGlobal().listen((message) {
      if (message.topic == 'coordination:sync_barrier') {
        _handleSyncBarrier(message);
      }
    });

    debugPrint('[CrossSessionCoordinator] 协调器初始化完成');
  }

  /// 释放资源
  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
    _activeTasks.clear();
    _syncBarriers.clear();
    _sharedDataPool.clear();
  }

  /// 在会话间传递数据
  Future<void> transferData({
    required String fromSessionId,
    required String toSessionId,
    required String key,
    required dynamic value,
    required String workflowInstanceId,
  }) async {
    final task = CoordinationTask(
      taskId: _generateTaskId(),
      workflowInstanceId: workflowInstanceId,
      sourceSessionId: fromSessionId,
      targetSessionId: toSessionId,
      type: CoordinationTaskType.dataTransfer,
      data: {'key': key, 'value': value},
    );

    _activeTasks[task.taskId] = task;

    // 通过总线发送数据
    await _bus.sendMessage(SessionMessage(
      fromSessionId: fromSessionId,
      toSessionId: toSessionId,
      type: SessionMessageType.data,
      topic: 'coordination:data_transfer',
      payload: {
        'taskId': task.taskId,
        'key': key,
        'value': value,
        'workflowInstanceId': workflowInstanceId,
      },
    ));

    task.status = CoordinationTaskStatus.completed;
    task.completedAt = DateTime.now();

    debugPrint('[CrossSessionCoordinator] 数据传递: $key ($fromSessionId -> $toSessionId)');
  }

  /// 在共享池中存储数据
  void setSharedData(String workflowInstanceId, String key, dynamic value) {
    _sharedDataPool.putIfAbsent(workflowInstanceId, () => {});
    _sharedDataPool[workflowInstanceId]![key] = value;
  }

  /// 从共享池获取数据
  dynamic getSharedData(String workflowInstanceId, String key) {
    return _sharedDataPool[workflowInstanceId]?[key];
  }

  /// 获取工作流所有共享数据
  Map<String, dynamic>? getAllSharedData(String workflowInstanceId) {
    return _sharedDataPool[workflowInstanceId];
  }

  /// 创建同步屏障（等待多个会话到达同一执行点）
  Future<void> createSyncBarrier({
    required String barrierId,
    required List<String> sessionIds,
    required String workflowInstanceId,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    final barrier = _SyncBarrier(
      barrierId: barrierId,
      sessionIds: sessionIds.toSet(),
      workflowInstanceId: workflowInstanceId,
      timeout: timeout,
    );

    _syncBarriers[barrierId] = barrier;

    debugPrint('[CrossSessionCoordinator] 创建同步屏障: $barrierId (${sessionIds.length} 个会话)');
  }

  /// 等待同步屏障
  Future<bool> awaitSyncBarrier({
    required String barrierId,
    required String sessionId,
    Map<String, dynamic>? data,
  }) async {
    final barrier = _syncBarriers[barrierId];
    if (barrier == null) {
      throw CrossSessionCoordinatorException('同步屏障不存在: $barrierId');
    }

    if (!barrier.sessionIds.contains(sessionId)) {
      throw CrossSessionCoordinatorException('会话不在同步屏障中: $sessionId');
    }

    // 广播到达消息
    await _bus.broadcast(
      sessionId,
      'coordination:sync_barrier',
      {
        'barrierId': barrierId,
        'sessionId': sessionId,
        'data': data,
      },
    );

    // 标记已到达
    barrier.arrived.add(sessionId);

    // 检查是否所有会话都已到达
    if (barrier.arrived.length >= barrier.sessionIds.length) {
      barrier.completer.complete(true);
      debugPrint('[CrossSessionCoordinator] 同步屏障通过: $barrierId');
      return true;
    }

    // 等待超时或全部到达
    try {
      return await barrier.completer.future.timeout(barrier.timeout);
    } on TimeoutException {
      barrier.completer.complete(false);
      debugPrint('[CrossSessionCoordinator] 同步屏障超时: $barrierId');
      return false;
    }
  }

  /// 委托任务给另一个会话
  Future<Map<String, dynamic>> delegateTask({
    required String fromSessionId,
    required String toSessionId,
    required String taskType,
    required Map<String, dynamic> taskData,
    required String workflowInstanceId,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final task = CoordinationTask(
      taskId: _generateTaskId(),
      workflowInstanceId: workflowInstanceId,
      sourceSessionId: fromSessionId,
      targetSessionId: toSessionId,
      type: CoordinationTaskType.taskDelegation,
      data: {
        'taskType': taskType,
        'taskData': taskData,
      },
    );

    _activeTasks[task.taskId] = task;
    task.status = CoordinationTaskStatus.inProgress;

    // 发送请求并等待响应
    try {
      final response = await _bus.sendRequest(
        fromSessionId,
        toSessionId,
        'coordination:task_delegation',
        {
          'taskId': task.taskId,
          'taskType': taskType,
          'taskData': taskData,
          'workflowInstanceId': workflowInstanceId,
        },
        timeout: timeout,
      );

      task.status = CoordinationTaskStatus.completed;
      task.completedAt = DateTime.now();
      task.result = response.payload['data'] as Map<String, dynamic>?;

      return task.result ?? {};
    } catch (e) {
      task.status = CoordinationTaskStatus.failed;
      throw CrossSessionCoordinatorException('任务委托失败: $e');
    }
  }

  /// 汇总多个会话的结果
  Future<Map<String, dynamic>> aggregateResults({
    required String coordinatorSessionId,
    required List<String> sourceSessionIds,
    required String workflowInstanceId,
    Duration timeout = const Duration(minutes: 10),
  }) async {
    final taskId = _generateTaskId();
    final results = <String, dynamic>{};
    final completer = Completer<Map<String, dynamic>>();

    // 订阅每个源会话的结果
    final subscriptions = <StreamSubscription>[];
    int receivedCount = 0;

    for (final sourceId in sourceSessionIds) {
      final sub = _bus.subscribeTopic(coordinatorSessionId, 'coordination:result:$taskId').listen(
        (message) {
          if (message.fromSessionId == sourceId) {
            results[sourceId] = message.payload['data'];
            receivedCount++;

            if (receivedCount >= sourceSessionIds.length) {
              if (!completer.isCompleted) {
                completer.complete(results);
              }
            }
          }
        },
      );
      subscriptions.add(sub);
    }

    // 请求每个会话发送结果
    for (final sourceId in sourceSessionIds) {
      await _bus.sendMessage(SessionMessage(
        fromSessionId: coordinatorSessionId,
        toSessionId: sourceId,
        type: SessionMessageType.request,
        topic: 'coordination:request_result',
        payload: {
          'taskId': taskId,
          'workflowInstanceId': workflowInstanceId,
        },
      ));
    }

    // 等待超时或全部完成
    try {
      final result = await completer.future.timeout(timeout);
      for (final sub in subscriptions) {
        sub.cancel();
      }
      return result;
    } on TimeoutException {
      for (final sub in subscriptions) {
        sub.cancel();
      }
      debugPrint('[CrossSessionCoordinator] 结果汇总超时: 已收到 $receivedCount/${sourceSessionIds.length}');
      return results;
    }
  }

  /// 响应结果请求
  Future<void> respondToResultRequest({
    required String sessionId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    await _bus.sendMessage(SessionMessage(
      fromSessionId: sessionId,
      toSessionId: '*', // 发送给协调者
      type: SessionMessageType.data,
      topic: 'coordination:result:$taskId',
      payload: {'data': data},
    ));
  }

  /// 获取活跃任务列表
  List<CoordinationTask> getActiveTasks() {
    return _activeTasks.values.toList();
  }

  /// 获取任务状态
  CoordinationTask? getTask(String taskId) {
    return _activeTasks[taskId];
  }

  /// 处理数据传递消息
  void _handleDataTransfer(SessionMessage message) {
    final key = message.payload['key'] as String?;
    final value = message.payload['value'];
    final workflowInstanceId = message.payload['workflowInstanceId'] as String?;

    if (key != null && workflowInstanceId != null) {
      setSharedData(workflowInstanceId, key, value);
    }
  }

  /// 处理同步屏障消息
  void _handleSyncBarrier(SessionMessage message) {
    final barrierId = message.payload['barrierId'] as String?;
    if (barrierId == null) return;

    final barrier = _syncBarriers[barrierId];
    if (barrier == null) return;

    final sessionId = message.payload['sessionId'] as String?;
    if (sessionId != null) {
      barrier.arrived.add(sessionId);
      if (barrier.arrived.length >= barrier.sessionIds.length) {
        if (!barrier.completer.isCompleted) {
          barrier.completer.complete(true);
        }
      }
    }
  }

  /// 生成任务 ID
  String _generateTaskId() {
    return 'coord_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().hashCode.toRadixString(16)}';
  }
}

/// 同步屏障
class _SyncBarrier {
  final String barrierId;
  final Set<String> sessionIds;
  final String workflowInstanceId;
  final Duration timeout;
  final Set<String> arrived = {};
  final Completer<bool> completer = Completer<bool>();

  _SyncBarrier({
    required this.barrierId,
    required this.sessionIds,
    required this.workflowInstanceId,
    required this.timeout,
  });
}

/// 协调器异常
class CrossSessionCoordinatorException implements Exception {
  final String message;
  const CrossSessionCoordinatorException(this.message);

  @override
  String toString() => 'CrossSessionCoordinatorException: $message';
}
