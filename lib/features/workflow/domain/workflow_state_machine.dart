/// 工作流状态机
///
/// 管理工作流实例和节点的状态转换：
/// - 工作流级别: pending -> running -> completed / failed / cancelled / paused
/// - 节点级别: pending -> waiting -> running -> success / failed / skipped / cancelled
library;

import 'dart:async';
import 'package:flutter/foundation.dart';

/// 工作流实例状态
enum WorkflowStatus {
  /// 待执行
  pending,

  /// 等待前置条件满足
  waiting,

  /// 运行中
  running,

  /// 暂停
  paused,

  /// 已完成（成功）
  completed,

  /// 已失败
  failed,

  /// 已跳过
  skipped,

  /// 已取消
  cancelled,

  /// 超时
  timedOut,

  /// 重试中
  retrying,

  /// 等待审批
  awaitingApproval,
}

/// 状态转换事件
enum WorkflowEvent {
  /// 开始执行
  start,

  /// 暂停
  pause,

  /// 恢复
  resume,

  /// 完成
  complete,

  /// 失败
  fail,

  /// 取消
  cancel,

  /// 超时
  timeout,

  /// 等待审批
  requestApproval,

  /// 审批通过
  approve,

  /// 审批拒绝
  reject,

  /// 重试
  retry,
}

/// 状态转换规则
class StateTransition {
  final WorkflowStatus from;
  final WorkflowEvent event;
  final WorkflowStatus to;
  final bool Function(Map<String, dynamic> context)? guard;

  const StateTransition({
    required this.from,
    required this.event,
    required this.to,
    this.guard,
  });
}

/// 工作流实例状态数据
class WorkflowStateData {
  /// 工作流实例 ID
  final String instanceId;

  /// 工作流定义 ID
  final String definitionId;

  /// 当前状态
  WorkflowStatus status;

  /// 各节点状态
  final Map<String, WorkflowStatus> nodeStates;

  /// 变量上下文
  final Map<String, dynamic> variables;

  /// 节点输出
  final Map<String, Map<String, dynamic>> nodeOutputs;

  /// 状态变更历史
  final List<StateChangeRecord> stateHistory;

  /// 开始时间
  DateTime? startTime;

  /// 结束时间
  DateTime? endTime;

  /// 当前执行节点列表
  final Set<String> runningNodes;

  /// 已完成节点集合
  final Set<String> completedNodes;

  /// 已失败节点集合
  final Set<String> failedNodes;

  /// 错误信息
  String? errorMessage;

  /// 审批数据
  Map<String, dynamic>? approvalData;

  /// 审批 Completer
  Completer<bool>? _approvalCompleter;

  WorkflowStateData({
    required this.instanceId,
    required this.definitionId,
    this.status = WorkflowStatus.pending,
    Map<String, WorkflowStatus>? nodeStates,
    Map<String, dynamic>? variables,
    Map<String, Map<String, dynamic>>? nodeOutputs,
    List<StateChangeRecord>? stateHistory,
    this.startTime,
    this.endTime,
    Set<String>? runningNodes,
    Set<String>? completedNodes,
    Set<String>? failedNodes,
    this.errorMessage,
    this.approvalData,
  })  : nodeStates = nodeStates ?? {},
        variables = variables ?? {},
        nodeOutputs = nodeOutputs ?? {},
        stateHistory = stateHistory ?? [],
        runningNodes = runningNodes ?? {},
        completedNodes = completedNodes ?? {},
        failedNodes = failedNodes ?? {};

  /// 执行状态转换
  bool transition(WorkflowEvent event, {Map<String, dynamic>? context}) {
    final rule = _stateMachineRules.firstWhere(
      (rule) => rule.from == status && rule.event == event,
      orElse: () => StateTransition(
        from: status,
        event: event,
        to: status, // 无匹配规则则保持当前状态
      ),
    );

    // 检查 guard 条件
    if (rule.guard != null && context != null) {
      if (!rule.guard!(context)) {
        debugPrint('[StateMachine] Guard 条件不满足: ${status.name} -> ${event.name}');
        return false;
      }
    }

    if (rule.to == status && rule.from == status) {
      debugPrint('[StateMachine] 无有效转换: ${status.name} + ${event.name}');
      return false;
    }

    final oldStatus = status;
    status = rule.to;

    if (status == WorkflowStatus.running && startTime == null) {
      startTime = DateTime.now();
    }

    if (_isTerminal(status)) {
      endTime = DateTime.now();
    }

    stateHistory.add(StateChangeRecord(
      from: oldStatus,
      to: status,
      event: event,
      timestamp: DateTime.now(),
      context: context,
    ));

    debugPrint('[StateMachine] 状态转换: ${oldStatus.name} -> ${status.name} (${event.name})');
    return true;
  }

  /// 获取节点状态
  WorkflowStatus getNodeState(String nodeId) {
    return nodeStates[nodeId] ?? WorkflowStatus.pending;
  }

  /// 设置节点状态
  void setNodeState(String nodeId, WorkflowStatus state) {
    nodeStates[nodeId] = state;
    if (state == WorkflowStatus.running) {
      runningNodes.add(nodeId);
      completedNodes.remove(nodeId);
      failedNodes.remove(nodeId);
    } else if (state == WorkflowStatus.completed) {
      runningNodes.remove(nodeId);
      completedNodes.add(nodeId);
      failedNodes.remove(nodeId);
    } else if (state == WorkflowStatus.failed) {
      runningNodes.remove(nodeId);
      failedNodes.add(nodeId);
    } else {
      runningNodes.remove(nodeId);
    }
  }

  /// 保存节点输出
  void setNodeOutput(String nodeId, Map<String, dynamic> output) {
    nodeOutputs[nodeId] = output;
  }

  /// 获取节点输出
  Map<String, dynamic>? getNodeOutput(String nodeId) {
    return nodeOutputs[nodeId];
  }

  /// 是否所有节点完成
  bool get allNodesCompleted => runningNodes.isEmpty && failedNodes.isEmpty;

  /// 是否有失败节点
  bool get hasFailedNodes => failedNodes.isNotEmpty;

  /// 执行时长
  Duration? get duration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  /// 等待审批
  Future<bool> awaitApproval(Map<String, dynamic> approvalData) {
    this.approvalData = approvalData;
    status = WorkflowStatus.awaitingApproval;
    _approvalCompleter = Completer<bool>();
    return _approvalCompleter!.future;
  }

  /// 提交审批结果
  void submitApprovalResult(bool approved) {
    if (_approvalCompleter != null && !_approvalCompleter!.isCompleted) {
      _approvalCompleter!.complete(approved);
      _approvalCompleter = null;
    }
  }

  static bool _isTerminal(WorkflowStatus status) {
    return status == WorkflowStatus.completed ||
        status == WorkflowStatus.failed ||
        status == WorkflowStatus.cancelled ||
        status == WorkflowStatus.timedOut;
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'instanceId': instanceId,
      'definitionId': definitionId,
      'status': status.name,
      'nodeStates': nodeStates.map((k, v) => MapEntry(k, v.name)),
      'variables': variables,
      'nodeOutputs': nodeOutputs,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'runningNodes': runningNodes.toList(),
      'completedNodes': completedNodes.toList(),
      'failedNodes': failedNodes.toList(),
      'errorMessage': errorMessage,
    };
  }

  /// 从 JSON 反序列化
  factory WorkflowStateData.fromJson(Map<String, dynamic> json) {
    return WorkflowStateData(
      instanceId: json['instanceId'] as String,
      definitionId: json['definitionId'] as String,
      status: WorkflowStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkflowStatus.pending,
      ),
      nodeStates: (json['nodeStates'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              k,
              WorkflowStatus.values.firstWhere(
                (e) => e.name == v,
                orElse: () => WorkflowStatus.pending,
              ),
            ),
          ) ??
          {},
      variables: Map<String, dynamic>.from(json['variables'] as Map? ?? {}),
      nodeOutputs: (json['nodeOutputs'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
          ) ??
          {},
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      runningNodes: Set<String>.from(json['runningNodes'] as List? ?? []),
      completedNodes: Set<String>.from(json['completedNodes'] as List? ?? []),
      failedNodes: Set<String>.from(json['failedNodes'] as List? ?? []),
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

/// 状态变更记录
class StateChangeRecord {
  final WorkflowStatus from;
  final WorkflowStatus to;
  final WorkflowEvent event;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const StateChangeRecord({
    required this.from,
    required this.to,
    required this.event,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'from': from.name,
        'to': to.name,
        'event': event.name,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };
}

/// 状态转换规则表
const List<StateTransition> _stateMachineRules = [
  // pending -> running (start)
  StateTransition(from: WorkflowStatus.pending, event: WorkflowEvent.start, to: WorkflowStatus.running),
  // running -> paused (pause)
  StateTransition(from: WorkflowStatus.running, event: WorkflowEvent.pause, to: WorkflowStatus.paused),
  // paused -> running (resume)
  StateTransition(from: WorkflowStatus.paused, event: WorkflowEvent.resume, to: WorkflowStatus.running),
  // running -> completed (complete)
  StateTransition(from: WorkflowStatus.running, event: WorkflowEvent.complete, to: WorkflowStatus.completed),
  // running -> failed (fail)
  StateTransition(from: WorkflowStatus.running, event: WorkflowEvent.fail, to: WorkflowStatus.failed),
  // pending -> cancelled (cancel)
  StateTransition(from: WorkflowStatus.pending, event: WorkflowEvent.cancel, to: WorkflowStatus.cancelled),
  // running -> cancelled (cancel)
  StateTransition(from: WorkflowStatus.running, event: WorkflowEvent.cancel, to: WorkflowStatus.cancelled),
  // paused -> cancelled (cancel)
  StateTransition(from: WorkflowStatus.paused, event: WorkflowEvent.cancel, to: WorkflowStatus.cancelled),
  // running -> timedOut (timeout)
  StateTransition(from: WorkflowStatus.running, event: WorkflowEvent.timeout, to: WorkflowStatus.timedOut),
  // running -> awaitingApproval
  StateTransition(from: WorkflowStatus.running, event: WorkflowEvent.requestApproval, to: WorkflowStatus.awaitingApproval),
  // awaitingApproval -> running (approve)
  StateTransition(from: WorkflowStatus.awaitingApproval, event: WorkflowEvent.approve, to: WorkflowStatus.running),
  // awaitingApproval -> failed (reject)
  StateTransition(from: WorkflowStatus.awaitingApproval, event: WorkflowEvent.reject, to: WorkflowStatus.failed),
  // failed -> running (retry)
  StateTransition(from: WorkflowStatus.failed, event: WorkflowEvent.retry, to: WorkflowStatus.running),
  // timedOut -> running (retry)
  StateTransition(from: WorkflowStatus.timedOut, event: WorkflowEvent.retry, to: WorkflowStatus.running),
];

/// 状态机异常
class StateMachineException implements Exception {
  final String message;
  const StateMachineException(this.message);

  @override
  String toString() => 'StateMachineException: $message';
}
