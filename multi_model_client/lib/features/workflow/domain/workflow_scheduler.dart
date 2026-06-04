/// 工作流调度器
///
/// 负责：
/// - 定时触发工作流
/// - 事件触发工作流
/// - 消息触发工作流
/// - 优先级队列管理
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// 调度任务
class ScheduledWorkflow {
  /// 工作流定义 ID
  final String definitionId;

  /// 调度表达式（cron 或 interval）
  final String schedule;

  /// 下次执行时间
  DateTime nextRunTime;

  /// 上次执行时间
  DateTime? lastRunTime;

  /// 是否启用
  bool enabled;

  /// 输入变量
  final Map<String, dynamic> inputVariables;

  /// 最大重试次数
  final int maxRetries;

  /// 优先级
  final int priority;

  ScheduledWorkflow({
    required this.definitionId,
    required this.schedule,
    required this.nextRunTime,
    this.lastRunTime,
    this.enabled = true,
    this.inputVariables = const {},
    this.maxRetries = 3,
    this.priority = 0,
  });

  Map<String, dynamic> toJson() => {
        'definitionId': definitionId,
        'schedule': schedule,
        'nextRunTime': nextRunTime.toIso8601String(),
        'lastRunTime': lastRunTime?.toIso8601String(),
        'enabled': enabled,
        'inputVariables': inputVariables,
        'maxRetries': maxRetries,
        'priority': priority,
      };

  factory ScheduledWorkflow.fromJson(Map<String, dynamic> json) {
    return ScheduledWorkflow(
      definitionId: json['definitionId'] as String,
      schedule: json['schedule'] as String,
      nextRunTime: DateTime.parse(json['nextRunTime'] as String),
      lastRunTime: json['lastRunTime'] != null
          ? DateTime.parse(json['lastRunTime'] as String)
          : null,
      enabled: json['enabled'] as bool? ?? true,
      inputVariables: Map<String, dynamic>.from(json['inputVariables'] as Map? ?? {}),
      maxRetries: json['maxRetries'] as int? ?? 3,
      priority: json['priority'] as int? ?? 0,
    );
  }
}

/// 调度器事件
class SchedulerEvent {
  final String type;
  final String definitionId;
  final String? instanceId;
  final DateTime timestamp;
  final String? error;

  SchedulerEvent({
    required this.type,
    required this.definitionId,
    this.instanceId,
    DateTime? timestamp,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 工作流调度器
class WorkflowScheduler {
  static final WorkflowScheduler _instance = WorkflowScheduler._internal();
  factory WorkflowScheduler() => _instance;
  WorkflowScheduler._internal();

  /// 定时调度任务
  final Map<String, ScheduledWorkflow> _scheduledTasks = {};

  /// 优先级队列（待执行）
  final PriorityQueue<_QueueItem> _executionQueue = PriorityQueue<_QueueItem>(
    (a, b) => b.priority.compareTo(a.priority),
  );

  /// 调度检查定时器
  Timer? _schedulerTimer;

  /// 事件流
  final StreamController<SchedulerEvent> _eventController =
      StreamController<SchedulerEvent>.broadcast();

  /// 事件触发器映射
  final Map<String, List<String>> _eventTriggers = {};

  /// 消息触发器映射
  final Map<String, List<String>> _messageTriggers = {};

  /// 订阅调度事件
  Stream<SchedulerEvent> get eventStream => _eventController.stream;

  /// 初始化调度器
  void initialize({Duration checkInterval = const Duration(seconds: 30)}) {
    _schedulerTimer = Timer.periodic(checkInterval, (_) => _checkScheduledTasks());
    debugPrint('[WorkflowScheduler] 调度器初始化完成，检查间隔: ${checkInterval.inSeconds}s');
  }

  /// 释放资源
  void dispose() {
    _schedulerTimer?.cancel();
    _eventController.close();
  }

  /// 添加定时调度任务
  void addScheduledTask(ScheduledWorkflow task) {
    _scheduledTasks[task.definitionId] = task;
    debugPrint('[WorkflowScheduler] 添加调度任务: ${task.definitionId} @ ${task.schedule}');
  }

  /// 移除调度任务
  void removeScheduledTask(String definitionId) {
    _scheduledTasks.remove(definitionId);
  }

  /// 启用/禁用调度任务
  void toggleScheduledTask(String definitionId, bool enabled) {
    final task = _scheduledTasks[definitionId];
    if (task != null) {
      task.enabled = enabled;
    }
  }

  /// 注册事件触发器
  void registerEventTrigger(String eventType, String definitionId) {
    _eventTriggers.putIfAbsent(eventType, () => []);
    if (!_eventTriggers[eventType]!.contains(definitionId)) {
      _eventTriggers[eventType]!.add(definitionId);
    }
  }

  /// 注册消息触发器
  void registerMessageTrigger(String topic, String definitionId) {
    _messageTriggers.putIfAbsent(topic, () => []);
    if (!_messageTriggers[topic]!.contains(definitionId)) {
      _messageTriggers[topic]!.add(definitionId);
    }
  }

  /// 手动触发工作流
  Future<void> trigger(String definitionId, {Map<String, dynamic>? variables}) async {
    _executionQueue.add(_QueueItem(
      definitionId: definitionId,
      priority: 0,
      inputVariables: variables,
    ));

    _processQueue();
  }

  /// 触发事件
  void onEvent(String eventType, {Map<String, dynamic>? data}) {
    final definitionIds = _eventTriggers[eventType];
    if (definitionIds != null) {
      for (final defId in definitionIds) {
        _executionQueue.add(_QueueItem(
          definitionId: defId,
          priority: 1, // 事件触发优先级较高
          inputVariables: data,
        ));
      }
      _processQueue();
    }
  }

  /// 触发消息
  void onMessage(String topic, Map<String, dynamic> payload) {
    final definitionIds = _messageTriggers[topic];
    if (definitionIds != null) {
      for (final defId in definitionIds) {
        _executionQueue.add(_QueueItem(
          definitionId: defId,
          priority: 2, // 消息触发优先级最高
          inputVariables: payload,
        ));
      }
      _processQueue();
    }
  }

  /// 获取所有调度任务
  List<ScheduledWorkflow> getScheduledTasks() {
    return _scheduledTasks.values.toList();
  }

  /// 获取队列状态
  Map<String, dynamic> getQueueStatus() {
    return {
      'scheduledTasks': _scheduledTasks.length,
      'pendingInQueue': _executionQueue.length,
      'eventTriggers': _eventTriggers.length,
      'messageTriggers': _messageTriggers.length,
    };
  }

  /// 检查定时任务
  void _checkScheduledTasks() {
    final now = DateTime.now();

    for (final task in _scheduledTasks.values) {
      if (!task.enabled) continue;
      if (task.nextRunTime.isBefore(now) || task.nextRunTime.isAtSameMomentAs(now)) {
        _executionQueue.add(_QueueItem(
          definitionId: task.definitionId,
          priority: task.priority,
          inputVariables: task.inputVariables,
        ));

        task.lastRunTime = now;
        task.nextRunTime = _calculateNextRunTime(task.schedule, now);
      }
    }

    _processQueue();
  }

  /// 处理执行队列
  Future<void> _processQueue() async {
    while (_executionQueue.isNotEmpty) {
      final item = _executionQueue.removeFirst();

      // 获取工作流定义（这里需要 WorkflowRepository 配合）
      // TODO: 从 WorkflowRepository 获取定义并执行

      _eventController.add(SchedulerEvent(
        type: 'triggered',
        definitionId: item.definitionId,
      ));
    }
  }

  /// 计算下次运行时间（简单 cron 解析）
  DateTime _calculateNextRunTime(String schedule, DateTime from) {
    // 支持简单格式：
    // "every:30m" - 每30分钟
    // "every:1h" - 每1小时
    // "every:1d" - 每1天
    // "daily:HH:mm" - 每天指定时间
    // "weekly:MON,HH:mm" - 每周指定时间

    if (schedule.startsWith('every:')) {
      final interval = schedule.substring(6);
      if (interval.endsWith('m')) {
        final minutes = int.parse(interval.replaceAll('m', ''));
        return from.add(Duration(minutes: minutes));
      } else if (interval.endsWith('h')) {
        final hours = int.parse(interval.replaceAll('h', ''));
        return from.add(Duration(hours: hours));
      } else if (interval.endsWith('d')) {
        final days = int.parse(interval.replaceAll('d', ''));
        return from.add(Duration(days: days));
      }
    }

    if (schedule.startsWith('daily:')) {
      final timeStr = schedule.substring(6);
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      var next = DateTime(from.year, from.month, from.day, hour, minute);
      if (next.isBefore(from) || next.isAtSameMomentAs(from)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }

    if (schedule.startsWith('weekly:')) {
      final parts = schedule.substring(7).split(',');
      final dayStr = parts[0];
      final timeStr = parts[1];
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final dayMap = {
        'MON': 1, 'TUE': 2, 'WED': 3, 'THU': 4,
        'FRI': 5, 'SAT': 6, 'SUN': 7,
      };
      final targetDay = dayMap[dayStr.toUpperCase()] ?? 1;

      var next = from;
      while (next.weekday != targetDay ||
          next.hour != hour ||
          next.minute != minute) {
        next = next.add(const Duration(minutes: 1));
        if (next.difference(from).inDays > 7) break;
      }
      return next;
    }

    // 默认：1小时后
    return from.add(const Duration(hours: 1));
  }
}

/// 队列项
class _QueueItem {
  final String definitionId;
  final int priority;
  final Map<String, dynamic>? inputVariables;

  _QueueItem({
    required this.definitionId,
    this.priority = 0,
    this.inputVariables,
  });
}

/// 优先级队列实现
class PriorityQueue<E> {
  final List<E> _heap;
  final Comparator<E> _comparator;

  PriorityQueue(this._comparator) : _heap = [];

  int get length => _heap.length;
  bool get isEmpty => _heap.isEmpty;
  bool get isNotEmpty => _heap.isNotEmpty;

  void add(E element) {
    _heap.add(element);
    _siftUp(_heap.length - 1);
  }

  E removeFirst() {
    if (_heap.isEmpty) throw StateError('Priority queue is empty');
    final first = _heap.first;
    final last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _siftDown(0);
    }
    return first;
  }

  E get first {
    if (_heap.isEmpty) throw StateError('Priority queue is empty');
    return _heap.first;
  }

  void _siftUp(int index) {
    while (index > 0) {
      final parent = (index - 1) ~/ 2;
      if (_comparator(_heap[index], _heap[parent]) < 0) {
        final temp = _heap[index];
        _heap[index] = _heap[parent];
        _heap[parent] = temp;
        index = parent;
      } else {
        break;
      }
    }
  }

  void _siftDown(int index) {
    final length = _heap.length;
    while (true) {
      int smallest = index;
      final left = 2 * index + 1;
      final right = 2 * index + 2;

      if (left < length && _comparator(_heap[left], _heap[smallest]) < 0) {
        smallest = left;
      }
      if (right < length && _comparator(_heap[right], _heap[smallest]) < 0) {
        smallest = right;
      }
      if (smallest != index) {
        final temp = _heap[index];
        _heap[index] = _heap[smallest];
        _heap[smallest] = temp;
        index = smallest;
      } else {
        break;
      }
    }
  }
}
