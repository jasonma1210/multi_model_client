/// 工作流持久化层
///
/// 负责：
/// - 工作流定义的存储和读取
/// - 工作流执行记录的持久化
/// - 工作流日志存储
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/workflow_definition.dart';
import '../domain/workflow_state_machine.dart';

/// 工作流持久化记录
class WorkflowRecord {
  /// 工作流 ID
  final String id;

  /// 工作流名称
  final String name;

  /// 描述
  final String? description;

  /// 版本
  final int version;

  /// 定义 JSON
  final String definitionJson;

  /// 标签
  final List<String> tags;

  /// 是否启用
  bool enabled;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  WorkflowRecord({
    required this.id,
    required this.name,
    this.description,
    this.version = 1,
    required this.definitionJson,
    this.tags = const [],
    this.enabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从定义创建记录
  factory WorkflowRecord.fromDefinition(WorkflowDefinition definition) {
    return WorkflowRecord(
      id: definition.id,
      name: definition.name,
      description: definition.description,
      version: definition.version,
      definitionJson: definition.toJsonString(),
      tags: definition.tags,
      createdAt: definition.createdAt,
      updatedAt: definition.updatedAt,
    );
  }

  /// 转换为定义
  WorkflowDefinition toDefinition() {
    return WorkflowDefinition.fromJsonString(definitionJson);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'version': version,
        'definitionJson': definitionJson,
        'tags': tags,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkflowRecord.fromJson(Map<String, dynamic> json) {
    return WorkflowRecord(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      version: json['version'] as int? ?? 1,
      definitionJson: json['definitionJson'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      enabled: json['enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 工作流执行记录
class WorkflowExecutionRecord {
  /// 实例 ID
  final String instanceId;

  /// 工作流 ID
  final String workflowId;

  /// 状态
  final String status;

  /// 输入变量 JSON
  final String? inputVariablesJson;

  /// 输出变量 JSON
  final String? outputVariablesJson;

  /// 节点状态 JSON
  final String? nodeStatesJson;

  /// 错误信息
  final String? errorMessage;

  /// 开始时间
  final DateTime? startTime;

  /// 结束时间
  final DateTime? endTime;

  /// 创建时间
  final DateTime createdAt;

  WorkflowExecutionRecord({
    required this.instanceId,
    required this.workflowId,
    required this.status,
    this.inputVariablesJson,
    this.outputVariablesJson,
    this.nodeStatesJson,
    this.errorMessage,
    this.startTime,
    this.endTime,
    required this.createdAt,
  });

  /// 从状态数据创建
  factory WorkflowExecutionRecord.fromStateData(WorkflowStateData state, String workflowId) {
    return WorkflowExecutionRecord(
      instanceId: state.instanceId,
      workflowId: workflowId,
      status: state.status.name,
      inputVariablesJson: jsonEncode(state.variables),
      nodeStatesJson: jsonEncode(state.nodeStates.map((k, v) => MapEntry(k, v.name))),
      errorMessage: state.errorMessage,
      startTime: state.startTime,
      endTime: state.endTime,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'instanceId': instanceId,
        'workflowId': workflowId,
        'status': status,
        'inputVariablesJson': inputVariablesJson,
        'outputVariablesJson': outputVariablesJson,
        'nodeStatesJson': nodeStatesJson,
        'errorMessage': errorMessage,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}

/// 工作流日志记录
class WorkflowLogRecord {
  final String id;
  final String instanceId;
  final String nodeId;
  final String level;
  final String message;
  final String? dataJson;
  final DateTime timestamp;

  WorkflowLogRecord({
    required this.id,
    required this.instanceId,
    required this.nodeId,
    required this.level,
    required this.message,
    this.dataJson,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'instanceId': instanceId,
        'nodeId': nodeId,
        'level': level,
        'message': message,
        'dataJson': dataJson,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 工作流持久化仓库
///
/// 当前实现使用内存存储，后续可扩展为数据库存储。
class WorkflowRepository {
  static final WorkflowRepository _instance = WorkflowRepository._internal();
  factory WorkflowRepository() => _instance;
  WorkflowRepository._internal();

  /// 工作流定义存储
  final Map<String, WorkflowRecord> _workflows = {};

  /// 执行记录存储
  final Map<String, WorkflowExecutionRecord> _executions = {};

  /// 日志存储
  final List<WorkflowLogRecord> _logs = [];

  /// 最大日志条数
  static const int maxLogCount = 10000;

  // ── 工作流定义 CRUD ──

  /// 保存工作流定义
  Future<void> saveWorkflow(WorkflowDefinition definition) async {
    final record = WorkflowRecord.fromDefinition(definition);
    _workflows[record.id] = record;
    debugPrint('[WorkflowRepository] 保存工作流: ${record.id}');
  }

  /// 获取工作流定义
  Future<WorkflowDefinition?> getWorkflow(String id) async {
    final record = _workflows[id];
    return record?.toDefinition();
  }

  /// 获取所有工作流
  Future<List<WorkflowDefinition>> getAllWorkflows() async {
    return _workflows.values.map((r) => r.toDefinition()).toList();
  }

  /// 获取所有工作流记录
  Future<List<WorkflowRecord>> getAllWorkflowRecords() async {
    return _workflows.values.toList();
  }

  /// 删除工作流
  Future<void> deleteWorkflow(String id) async {
    _workflows.remove(id);
    debugPrint('[WorkflowRepository] 删除工作流: $id');
  }

  /// 启用/禁用工作流
  Future<void> toggleWorkflow(String id, bool enabled) async {
    final record = _workflows[id];
    if (record != null) {
      record.enabled = enabled;
    }
  }

  /// 搜索工作流
  Future<List<WorkflowDefinition>> searchWorkflows({
    String? keyword,
    List<String>? tags,
    bool? enabled,
  }) async {
    var records = _workflows.values.toList();

    if (keyword != null && keyword.isNotEmpty) {
      records = records.where((r) =>
          r.name.toLowerCase().contains(keyword.toLowerCase()) ||
          (r.description?.toLowerCase().contains(keyword.toLowerCase()) ?? false)).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      records = records.where((r) =>
          tags.any((tag) => r.tags.contains(tag))).toList();
    }

    if (enabled != null) {
      records = records.where((r) => r.enabled == enabled).toList();
    }

    return records.map((r) => r.toDefinition()).toList();
  }

  // ── 执行记录 CRUD ──

  /// 保存执行记录
  Future<void> saveExecutionRecord(WorkflowExecutionRecord record) async {
    _executions[record.instanceId] = record;
  }

  /// 获取执行记录
  Future<WorkflowExecutionRecord?> getExecutionRecord(String instanceId) async {
    return _executions[instanceId];
  }

  /// 获取工作流的所有执行记录
  Future<List<WorkflowExecutionRecord>> getExecutionRecords(String workflowId) async {
    return _executions.values
        .where((r) => r.workflowId == workflowId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 获取最近的执行记录
  Future<List<WorkflowExecutionRecord>> getRecentExecutions({int limit = 20}) async {
    final records = _executions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records.take(limit).toList();
  }

  // ── 日志 CRUD ──

  /// 保存日志
  Future<void> saveLog(WorkflowLogRecord log) async {
    _logs.add(log);

    // 限制日志数量
    if (_logs.length > maxLogCount) {
      _logs.removeRange(0, _logs.length - maxLogCount);
    }
  }

  /// 获取执行实例的日志
  Future<List<WorkflowLogRecord>> getLogs(String instanceId) async {
    return _logs.where((l) => l.instanceId == instanceId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 获取节点日志
  Future<List<WorkflowLogRecord>> getNodeLogs(String instanceId, String nodeId) async {
    return _logs
        .where((l) => l.instanceId == instanceId && l.nodeId == nodeId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// 清空日志
  Future<void> clearLogs() async {
    _logs.clear();
  }

  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'totalWorkflows': _workflows.length,
      'enabledWorkflows': _workflows.values.where((r) => r.enabled).length,
      'totalExecutions': _executions.length,
      'totalLogs': _logs.length,
    };
  }
}
