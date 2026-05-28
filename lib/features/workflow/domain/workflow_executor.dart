/// 工作流执行引擎
///
/// 核心执行器，负责：
/// - 驱动 DAG 节点按拓扑序执行
/// - 处理条件分支、循环、子工作流
/// - 管理超时、重试、错误处理
/// - 协调跨会话资源
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'workflow_definition.dart';
import 'workflow_node.dart';
import 'workflow_state_machine.dart';

/// 节点执行器接口
abstract class NodeExecutor {
  /// 节点类型
  NodeType get nodeType;

  /// 执行节点
  Future<NodeResult> execute(WorkflowNode node, NodeExecutionContext context);
}

/// 工作流执行配置
class WorkflowExecutionConfig {
  /// 最大并行节点数
  final int maxParallelNodes;

  /// 全局超时时间
  final Duration? globalTimeout;

  /// 是否在失败时中止
  final bool abortOnFailure;

  /// 最大重试次数
  final int maxRetries;

  /// 重试延迟基础值
  final Duration retryBaseDelay;

  /// 日志详细级别
  final LogLevel logLevel;

  const WorkflowExecutionConfig({
    this.maxParallelNodes = 5,
    this.globalTimeout,
    this.abortOnFailure = true,
    this.maxRetries = 3,
    this.retryBaseDelay = const Duration(seconds: 1),
    this.logLevel = LogLevel.info,
  });
}

/// 日志级别
enum LogLevel { debug, info, warning, error }

/// 执行日志条目
class ExecutionLog {
  final String nodeId;
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const ExecutionLog({
    required this.nodeId,
    required this.message,
    required this.level,
    required this.timestamp,
    this.data,
  });
}

/// 工作流执行实例
class WorkflowExecution {
  /// 实例 ID
  final String instanceId;

  /// 工作流定义
  final WorkflowDefinition definition;

  /// 状态数据
  final WorkflowStateData state;

  /// 执行配置
  final WorkflowExecutionConfig config;

  /// 执行日志
  final List<ExecutionLog> logs;

  /// 完成回调
  final Completer<void> _completionCompleter = Completer<void>();

  /// 取消标志
  bool _cancelled = false;

  /// 超时定时器
  Timer? _timeoutTimer;

  WorkflowExecution({
    required this.instanceId,
    required this.definition,
    required this.state,
    this.config = const WorkflowExecutionConfig(),
    List<ExecutionLog>? logs,
  }) : logs = logs ?? [];

  /// 执行完成的 Future
  Future<void> get completion => _completionCompleter.future;

  /// 是否已取消
  bool get isCancelled => _cancelled;

  /// 添加日志
  void log(String nodeId, String message, LogLevel level, {Map<String, dynamic>? data}) {
    if (_shouldLog(level)) {
      final entry = ExecutionLog(
        nodeId: nodeId,
        message: message,
        level: level,
        timestamp: DateTime.now(),
        data: data,
      );
      logs.add(entry);
      debugPrint('[Workflow:$instanceId] [${level.name}] [$nodeId] $message');
    }
  }

  bool _shouldLog(LogLevel level) {
    const levels = LogLevel.values;
    return levels.indexOf(level) >= levels.indexOf(config.logLevel);
  }
}

/// 工作流执行引擎
class WorkflowEngine {
  static final WorkflowEngine _instance = WorkflowEngine._internal();
  factory WorkflowEngine() => _instance;
  WorkflowEngine._internal();

  /// 节点执行器注册表
  final Map<NodeType, NodeExecutor> _executors = {};

  /// 活跃的执行实例
  final Map<String, WorkflowExecution> _activeExecutions = {};

  /// 执行事件流
  final StreamController<WorkflowExecutionEvent> _eventController =
      StreamController<WorkflowExecutionEvent>.broadcast();

  /// 订阅执行事件
  Stream<WorkflowExecutionEvent> get eventStream => _eventController.stream;

  /// 注册节点执行器
  void registerExecutor(NodeExecutor executor) {
    _executors[executor.nodeType] = executor;
    debugPrint('[WorkflowEngine] 注册执行器: ${executor.nodeType.name}');
  }

  /// 获取所有已注册的执行器类型
  Set<NodeType> get registeredExecutors => _executors.keys.toSet();

  /// 执行工作流
  Future<WorkflowExecution> execute(
    WorkflowDefinition definition, {
    Map<String, dynamic>? inputVariables,
    WorkflowExecutionConfig config = const WorkflowExecutionConfig(),
    String? sessionId,
  }) async {
    // 验证工作流定义
    final validation = definition.validate();
    if (!validation.isValid) {
      throw WorkflowExecutionException('工作流定义无效: ${validation.errors.join(', ')}');
    }

    // 检查必要执行器是否已注册
    final requiredTypes = definition.nodes.map((n) => n.type).toSet();
    for (final type in requiredTypes) {
      if (type != NodeType.start &&
          type != NodeType.end &&
          !_executors.containsKey(type)) {
        throw WorkflowExecutionException('缺少节点执行器: ${type.name}');
      }
    }

    // 创建执行实例
    final instanceId = _generateInstanceId(definition.id);
    final state = WorkflowStateData(
      instanceId: instanceId,
      definitionId: definition.id,
      variables: Map<String, dynamic>.from(definition.variables.map(
        (k, v) => MapEntry(k, v.defaultValue),
      )),
    );

    // 合并输入变量
    if (inputVariables != null) {
      state.variables.addAll(inputVariables);
    }

    final execution = WorkflowExecution(
      instanceId: instanceId,
      definition: definition,
      state: state,
      config: config,
    );

    _activeExecutions[instanceId] = execution;

    // 启动超时定时器
    if (config.globalTimeout != null) {
      execution._timeoutTimer = Timer(config.globalTimeout!, () {
        _handleTimeout(execution);
      });
    }

    // 广播事件
    _emitEvent(WorkflowExecutionEvent.started(instanceId, definition.id));

    execution.log('engine', '工作流开始执行: ${definition.name}', LogLevel.info);

    // 转换状态
    state.transition(WorkflowEvent.start);

    try {
      // 执行 DAG
      await _executeDAG(execution);

      // 标记完成
      if (!execution.isCancelled && !state.hasFailedNodes) {
        state.transition(WorkflowEvent.complete);
        execution.log('engine', '工作流执行完成', LogLevel.info);
        _emitEvent(WorkflowExecutionEvent.completed(instanceId));
      } else if (state.hasFailedNodes) {
        state.transition(WorkflowEvent.fail, context: {
          'failedNodes': state.failedNodes.toList(),
        });
        execution.log('engine', '工作流执行失败', LogLevel.error);
        _emitEvent(WorkflowExecutionEvent.failed(instanceId, state.errorMessage ?? '节点执行失败'));
      }
    } catch (e) {
      state.transition(WorkflowEvent.fail, context: {'error': e.toString()});
      state.errorMessage = e.toString();
      execution.log('engine', '工作流执行异常: $e', LogLevel.error);
      _emitEvent(WorkflowExecutionEvent.failed(instanceId, e.toString()));
    } finally {
      // 清理
      execution._timeoutTimer?.cancel();
      _activeExecutions.remove(instanceId);
      if (!execution._completionCompleter.isCompleted) {
        execution._completionCompleter.complete();
      }
    }

    return execution;
  }

  /// 取消执行
  Future<void> cancel(String instanceId) async {
    final execution = _activeExecutions[instanceId];
    if (execution == null) return;

    execution._cancelled = true;
    execution.state.transition(WorkflowEvent.cancel);
    execution.log('engine', '工作流已取消', LogLevel.warning);
    _emitEvent(WorkflowExecutionEvent.cancelled(instanceId));
  }

  /// 暂停执行
  Future<void> pause(String instanceId) async {
    final execution = _activeExecutions[instanceId];
    if (execution == null) return;

    execution.state.transition(WorkflowEvent.pause);
    execution.log('engine', '工作流已暂停', LogLevel.warning);
    _emitEvent(WorkflowExecutionEvent.paused(instanceId));
  }

  /// 恢复执行
  Future<void> resume(String instanceId) async {
    final execution = _activeExecutions[instanceId];
    if (execution == null) return;

    execution.state.transition(WorkflowEvent.resume);
    execution.log('engine', '工作流已恢复', LogLevel.info);
    _emitEvent(WorkflowExecutionEvent.resumed(instanceId));

    // 重新执行未完成的节点
    _executeDAG(execution);
  }

  /// 提交审批结果
  void submitApproval(String instanceId, bool approved) {
    final execution = _activeExecutions[instanceId];
    if (execution == null) return;

    execution.state.submitApprovalResult(approved);
    if (approved) {
      execution.state.transition(WorkflowEvent.approve);
      execution.log('engine', '审批通过', LogLevel.info);
    } else {
      execution.state.transition(WorkflowEvent.reject);
      execution.log('engine', '审批拒绝', LogLevel.warning);
    }
  }

  /// 获取活跃执行列表
  List<WorkflowExecution> getActiveExecutions() {
    return _activeExecutions.values.toList();
  }

  /// 获取执行状态
  WorkflowExecution? getExecution(String instanceId) {
    return _activeExecutions[instanceId];
  }

  /// 执行 DAG（核心算法）
  Future<void> _executeDAG(WorkflowExecution execution) async {
    final definition = execution.definition;
    final state = execution.state;

    // 计算拓扑排序
    final topoOrder = _topologicalSort(definition);
    if (topoOrder == null) {
      throw WorkflowExecutionException('工作流存在循环依赖');
    }

    // 跟踪每个节点的就绪状态
    final completedSet = <String>{};
    final pendingQueue = Queue<String>();

    // 初始化：加入没有前驱的节点
    for (final nodeId in topoOrder) {
      final predecessors = definition.getPreviousNodes(nodeId);
      if (predecessors.isEmpty) {
        pendingQueue.add(nodeId);
      }
    }

    // 并行执行控制
    final runningFutures = <String, Future<void>>{};
    final maxParallel = execution.config.maxParallelNodes;

    while (pendingQueue.isNotEmpty || runningFutures.isNotEmpty) {
      if (execution.isCancelled) break;

      // 暂停等待
      while (state.status == WorkflowStatus.paused) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (execution.isCancelled) break;
      }
      if (execution.isCancelled) break;

      // 启动就绪节点
      while (pendingQueue.isNotEmpty && runningFutures.length < maxParallel) {
        final nodeId = pendingQueue.removeFirst();
        final node = definition.getNode(nodeId)!;

        // 检查前驱是否全部完成
        final predecessors = definition.getPreviousNodes(nodeId);
        final allPredecessorsDone = predecessors.every((p) => completedSet.contains(p.id));

        if (!allPredecessorsDone) {
          pendingQueue.add(nodeId); // 放回队列
          break;
        }

        // 处理条件边 — 检查是否有满足条件的边
        if (predecessors.isNotEmpty) {
          final incomingEdges = definition.edges.where((e) => e.targetId == nodeId);
          bool anyEdgeValid = false;
          for (final edge in incomingEdges) {
            if (edge.isConditional) {
              final conditionResult = _evaluateCondition(edge.condition!, state.variables);
              if (conditionResult) {
                anyEdgeValid = true;
                break;
              }
            } else {
              anyEdgeValid = true;
              break;
            }
          }
          if (!anyEdgeValid) {
            // 跳过此节点
            state.setNodeState(nodeId, WorkflowStatus.skipped);
            completedSet.add(nodeId);
            execution.log(nodeId, '节点被跳过（条件不满足）', LogLevel.debug);
            _addSuccessorsToQueue(nodeId, definition, completedSet, pendingQueue);
            continue;
          }
        }

        // 处理不同节点类型
        if (node.type == NodeType.start) {
          state.setNodeState(nodeId, WorkflowStatus.completed);
          completedSet.add(nodeId);
          execution.log(nodeId, '起始节点', LogLevel.debug);
          _addSuccessorsToQueue(nodeId, definition, completedSet, pendingQueue);
          continue;
        }

        if (node.type == NodeType.end) {
          state.setNodeState(nodeId, WorkflowStatus.completed);
          completedSet.add(nodeId);
          execution.log(nodeId, '结束节点', LogLevel.debug);
          continue;
        }

        // 启动异步执行
        runningFutures[nodeId] = _executeNode(execution, node).then((_) {
          runningFutures.remove(nodeId);
          completedSet.add(nodeId);
          _addSuccessorsToQueue(nodeId, definition, completedSet, pendingQueue);
        }).catchError((e) {
          runningFutures.remove(nodeId);
          state.setNodeState(nodeId, WorkflowStatus.failed);
          state.failedNodes.add(nodeId);
          state.errorMessage = e.toString();
          execution.log(nodeId, '节点执行失败: $e', LogLevel.error);

          if (execution.config.abortOnFailure) {
            execution._cancelled = true;
          }
        });
      }

      // 等待至少一个节点完成
      if (runningFutures.isNotEmpty) {
        await Future.any(runningFutures.values);
      }
    }
  }

  /// 将后续节点加入队列
  void _addSuccessorsToQueue(
    String nodeId,
    WorkflowDefinition definition,
    Set<String> completedSet,
    Queue<String> pendingQueue,
  ) {
    final nextNodes = definition.getNextNodes(nodeId);
    for (final next in nextNodes) {
      if (!completedSet.contains(next.id) && !pendingQueue.contains(next.id)) {
        final predecessors = definition.getPreviousNodes(next.id);
        final allDone = predecessors.every((p) => completedSet.contains(p.id));
        if (allDone) {
          pendingQueue.add(next.id);
        }
      }
    }
  }

  /// 执行单个节点
  Future<void> _executeNode(WorkflowExecution execution, WorkflowNode node) async {
    final state = execution.state;
    final maxRetries = node.maxRetries ?? execution.config.maxRetries;
    int retryCount = 0;

    state.setNodeState(node.id, WorkflowStatus.running);
    execution.log(node.id, '开始执行节点: ${node.name}', LogLevel.info);

    // 处理循环节点
    if (node.type == NodeType.loop) {
      await _executeLoopNode(execution, node);
      return;
    }

    // 处理子工作流节点
    if (node.type == NodeType.subWorkflow) {
      await _executeSubWorkflowNode(execution, node);
      return;
    }

    // 处理审批节点
    if (node.type == NodeType.approval) {
      await _executeApprovalNode(execution, node);
      return;
    }

    while (retryCount <= maxRetries) {
      if (execution.isCancelled) {
        state.setNodeState(node.id, WorkflowStatus.cancelled);
        return;
      }

      try {
        // 准备执行上下文
        final context = _buildNodeContext(execution, node, retryCount);

        // 获取执行器
        final executor = _executors[node.type];
        if (executor == null) {
          throw WorkflowExecutionException('未找到节点执行器: ${node.type.name}');
        }

        // 设置超时
        final timeout = node.timeout ?? const Duration(minutes: 5);

        // 执行节点
        final result = await executor.execute(node, context).timeout(timeout);

        // 处理结果
        state.setNodeOutput(node.id, result.output);
        state.setNodeState(node.id, WorkflowStatus.completed);

        // 更新变量
        _applyOutputMapping(node, result.output, state.variables);

        execution.log(node.id, '节点执行成功', LogLevel.info, data: result.output);
        _emitEvent(WorkflowExecutionEvent.nodeCompleted(
            execution.instanceId, node.id, result));

        return;
      } on TimeoutException {
        retryCount++;
        if (retryCount <= maxRetries) {
          execution.log(node.id, '节点超时，重试 $retryCount/$maxRetries', LogLevel.warning);
          state.setNodeState(node.id, WorkflowStatus.retrying);
          await Future.delayed(node.retryDelay * retryCount);
        } else {
          state.setNodeState(node.id, WorkflowStatus.failed);
          state.failedNodes.add(node.id);
          execution.log(node.id, '节点执行超时', LogLevel.error);
          rethrow;
        }
      } catch (e) {
        retryCount++;
        if (retryCount <= maxRetries) {
          execution.log(node.id, '节点执行失败，重试 $retryCount/$maxRetries: $e', LogLevel.warning);
          state.setNodeState(node.id, WorkflowStatus.retrying);
          await Future.delayed(node.retryDelay * retryCount);
        } else {
          state.setNodeState(node.id, WorkflowStatus.failed);
          state.failedNodes.add(node.id);
          execution.log(node.id, '节点执行失败: $e', LogLevel.error);
          rethrow;
        }
      }
    }
  }

  /// 执行循环节点
  Future<void> _executeLoopNode(WorkflowExecution execution, WorkflowNode node) async {
    final state = execution.state;
    final loopConfig = node.loopConfig;

    if (loopConfig == null) {
      throw WorkflowExecutionException('循环节点缺少 LoopConfig');
    }

    state.setNodeState(node.id, WorkflowStatus.running);

    switch (loopConfig.type) {
      case LoopType.forEach:
        final collectionStr = _resolveExpression(loopConfig.collectionExpression!, state.variables);
        List<dynamic> collection;
        if (collectionStr is List) {
          collection = collectionStr;
        } else if (collectionStr is String) {
          try {
            collection = (jsonDecode(collectionStr) as List).cast<dynamic>();
          } catch (_) {
            collection = [collectionStr];
          }
        } else {
          collection = [collectionStr];
        }

        for (int i = 0; i < collection.length && !execution.isCancelled; i++) {
          state.variables[loopConfig.loopVariable] = collection[i];
          state.variables[loopConfig.indexVariable] = i;

          execution.log(node.id, '循环迭代 $i: ${collection[i]}', LogLevel.debug);

          // 执行循环体中的后续节点
          final nextNodes = execution.definition.getNextNodes(node.id);
          for (final next in nextNodes) {
            if (execution.isCancelled) break;
            await _executeNode(execution, next);
          }
        }
        break;

      case LoopType.whileLoop:
        int iteration = 0;
        while (iteration < loopConfig.maxIterations && !execution.isCancelled) {
          final conditionResult = _evaluateCondition(loopConfig.conditionExpression!, state.variables);
          if (!conditionResult) break;

          state.variables[loopConfig.indexVariable] = iteration;
          execution.log(node.id, 'While 循环迭代 $iteration', LogLevel.debug);

          final nextNodes = execution.definition.getNextNodes(node.id);
          for (final next in nextNodes) {
            if (execution.isCancelled) break;
            await _executeNode(execution, next);
          }
          iteration++;
        }
        break;

      case LoopType.count:
        final count = loopConfig.maxIterations;
        for (int i = 0; i < count && !execution.isCancelled; i++) {
          state.variables[loopConfig.indexVariable] = i;
          execution.log(node.id, 'Count 循环迭代 $i/$count', LogLevel.debug);

          final nextNodes = execution.definition.getNextNodes(node.id);
          for (final next in nextNodes) {
            if (execution.isCancelled) break;
            await _executeNode(execution, next);
          }
        }
        break;
    }

    state.setNodeState(node.id, WorkflowStatus.completed);
  }

  /// 执行子工作流节点
  Future<void> _executeSubWorkflowNode(WorkflowExecution execution, WorkflowNode node) async {
    // 子工作流通过调用 WorkflowRepository 获取定义并递归执行
    final state = execution.state;
    state.setNodeState(node.id, WorkflowStatus.running);
    execution.log(node.id, '子工作流节点 — 此功能需要 WorkflowRepository 配合', LogLevel.warning);
    // TODO: 实现子工作流递归执行
    state.setNodeState(node.id, WorkflowStatus.completed);
  }

  /// 执行审批节点
  Future<void> _executeApprovalNode(WorkflowExecution execution, WorkflowNode node) async {
    final state = execution.state;

    state.setNodeState(node.id, WorkflowStatus.running);
    execution.log(node.id, '等待人工审批', LogLevel.info);

    state.transition(WorkflowEvent.requestApproval);

    _emitEvent(WorkflowExecutionEvent.awaitingApproval(
      execution.instanceId,
      node.id,
      node.config,
    ));

    // 等待审批结果
    final approved = await state.awaitApproval({
      'nodeId': node.id,
      'nodeName': node.name,
      'config': node.config,
    });

    if (approved) {
      state.setNodeState(node.id, WorkflowStatus.completed);
      execution.log(node.id, '审批通过', LogLevel.info);
    } else {
      state.setNodeState(node.id, WorkflowStatus.failed);
      state.failedNodes.add(node.id);
      execution.log(node.id, '审批拒绝', LogLevel.warning);
    }
  }

  /// 构建节点执行上下文
  NodeExecutionContext _buildNodeContext(
    WorkflowExecution execution,
    WorkflowNode node,
    int retryCount,
  ) {
    final upstreamResults = <String, NodeResult>{};
    final prevNodes = execution.definition.getPreviousNodes(node.id);

    for (final prev in prevNodes) {
      final output = execution.state.getNodeOutput(prev.id);
      if (output != null) {
        upstreamResults[prev.id] = NodeResult.success(output);
      }
    }

    return NodeExecutionContext(
      nodeId: node.id,
      workflowInstanceId: execution.instanceId,
      variables: Map.from(execution.state.variables),
      upstreamResults: upstreamResults,
      startTime: DateTime.now(),
      retryCount: retryCount,
    );
  }

  /// 应用输出映射
  void _applyOutputMapping(
    WorkflowNode node,
    Map<String, dynamic> output,
    Map<String, dynamic> variables,
  ) {
    for (final entry in node.outputMapping.entries) {
      final sourceKey = entry.value;
      final targetKey = entry.key;
      if (output.containsKey(sourceKey)) {
        variables[targetKey] = output[sourceKey];
      }
    }
  }

  /// 评估条件表达式（简单实现）
  bool _evaluateCondition(String expression, Map<String, dynamic> variables) {
    // 替换变量
    String resolved = expression;
    for (final entry in variables.entries) {
      resolved = resolved.replaceAll('{${entry.key}}', '${entry.value}');
    }

    // 简单比较运算
    // 支持: ==, !=, >, <, >=, <=, &&, ||
    resolved = resolved.trim();

    // 处理布尔值
    if (resolved == 'true') return true;
    if (resolved == 'false') return false;

    // 处理 AND/OR
    if (resolved.contains('&&')) {
      final parts = resolved.split('&&');
      return parts.every((p) => _evaluateCondition(p.trim(), variables));
    }
    if (resolved.contains('||')) {
      final parts = resolved.split('||');
      return parts.any((p) => _evaluateCondition(p.trim(), variables));
    }

    // 处理 NOT
    if (resolved.startsWith('!')) {
      return !_evaluateCondition(resolved.substring(1).trim(), variables);
    }

    // 处理比较运算
    for (final op in ['>=', '<=', '!=', '==', '>', '<']) {
      if (resolved.contains(op)) {
        final parts = resolved.split(op);
        if (parts.length == 2) {
          final left = parts[0].trim();
          final right = parts[1].trim();
          return _compareValues(left, right, op);
        }
      }
    }

    // 默认：非空字符串为 true
    return resolved.isNotEmpty && resolved != 'null' && resolved != '0' && resolved != 'false';
  }

  /// 比较值
  bool _compareValues(String left, String right, String op) {
    final leftNum = num.tryParse(left);
    final rightNum = num.tryParse(right);

    if (leftNum != null && rightNum != null) {
      switch (op) {
        case '==': return leftNum == rightNum;
        case '!=': return leftNum != rightNum;
        case '>': return leftNum > rightNum;
        case '<': return leftNum < rightNum;
        case '>=': return leftNum >= rightNum;
        case '<=': return leftNum <= rightNum;
      }
    }

    // 字符串比较
    switch (op) {
      case '==': return left == right;
      case '!=': return left != right;
      default: return false;
    }
  }

  /// 解析表达式
  dynamic _resolveExpression(String expression, Map<String, dynamic> variables) {
    // 简单变量引用: {variableName}
    if (expression.startsWith('{') && expression.endsWith('}')) {
      final varName = expression.substring(1, expression.length - 1);
      return variables[varName];
    }
    return expression;
  }

  /// 拓扑排序
  List<String>? _topologicalSort(WorkflowDefinition definition) {
    final inDegree = <String, int>{};
    final adjacency = <String, List<String>>{};

    // 初始化
    for (final node in definition.nodes) {
      inDegree[node.id] = 0;
      adjacency[node.id] = [];
    }

    // 构建邻接表和入度表
    for (final edge in definition.edges) {
      adjacency[edge.sourceId]?.add(edge.targetId);
      inDegree[edge.targetId] = (inDegree[edge.targetId] ?? 0) + 1;
    }

    // Kahn 算法
    final queue = Queue<String>();
    for (final entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }

    final result = <String>[];
    while (queue.isNotEmpty) {
      final nodeId = queue.removeFirst();
      result.add(nodeId);

      for (final neighbor in adjacency[nodeId] ?? []) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }

    // 检查是否有环
    if (result.length != definition.nodes.length) {
      return null;
    }

    return result;
  }

  /// 处理超时
  void _handleTimeout(WorkflowExecution execution) {
    execution.state.transition(WorkflowEvent.timeout);
    execution.state.errorMessage = '工作流执行超时';
    execution.log('engine', '工作流执行超时', LogLevel.error);
    _emitEvent(WorkflowExecutionEvent.timedOut(execution.instanceId));
    execution._cancelled = true;
  }

  /// 发送事件
  void _emitEvent(WorkflowExecutionEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// 生成实例 ID
  String _generateInstanceId(String definitionId) {
    return '${definitionId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 释放资源
  void dispose() {
    _eventController.close();
  }
}

/// 工作流执行事件
class WorkflowExecutionEvent {
  final String type;
  final String instanceId;
  final String? nodeId;
  final NodeResult? nodeResult;
  final String? error;
  final DateTime timestamp;

  WorkflowExecutionEvent({
    required this.type,
    required this.instanceId,
    this.nodeId,
    this.nodeResult,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WorkflowExecutionEvent.started(String instanceId, String definitionId) =>
      WorkflowExecutionEvent(type: 'started', instanceId: instanceId);

  factory WorkflowExecutionEvent.completed(String instanceId) =>
      WorkflowExecutionEvent(type: 'completed', instanceId: instanceId);

  factory WorkflowExecutionEvent.failed(String instanceId, String error) =>
      WorkflowExecutionEvent(type: 'failed', instanceId: instanceId, error: error);

  factory WorkflowExecutionEvent.cancelled(String instanceId) =>
      WorkflowExecutionEvent(type: 'cancelled', instanceId: instanceId);

  factory WorkflowExecutionEvent.paused(String instanceId) =>
      WorkflowExecutionEvent(type: 'paused', instanceId: instanceId);

  factory WorkflowExecutionEvent.resumed(String instanceId) =>
      WorkflowExecutionEvent(type: 'resumed', instanceId: instanceId);

  factory WorkflowExecutionEvent.timedOut(String instanceId) =>
      WorkflowExecutionEvent(type: 'timedOut', instanceId: instanceId);

  factory WorkflowExecutionEvent.nodeCompleted(
          String instanceId, String nodeId, NodeResult result) =>
      WorkflowExecutionEvent(
        type: 'nodeCompleted',
        instanceId: instanceId,
        nodeId: nodeId,
        nodeResult: result,
      );

  factory WorkflowExecutionEvent.awaitingApproval(
          String instanceId, String nodeId, Map<String, dynamic> config) =>
      WorkflowExecutionEvent(
        type: 'awaitingApproval',
        instanceId: instanceId,
        nodeId: nodeId,
      );
}

/// 工作流执行异常
class WorkflowExecutionException implements Exception {
  final String message;
  const WorkflowExecutionException(this.message);

  @override
  String toString() => 'WorkflowExecutionException: $message';
}
