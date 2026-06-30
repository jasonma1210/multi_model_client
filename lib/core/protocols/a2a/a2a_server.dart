// v0.43.0 实现 A2A Server SDK
//
// 允许 MJ Nexus 作为 A2A Server 暴露给其他 Agent
// 实现要点：
// 1. 注册 Agent Card
// 2. 处理 SendMessage / GetTask / ListTasks / CancelTask JSON-RPC 方法
// 3. 与 ModelInferenceEngine 集成（让 LLM 处理消息）
// 4. 暴露为 HTTP endpoint（由应用路由层调用）

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'a2a_protocol.dart';
import 'a2a_stream_event.dart';

/// A2A Server - 业务 Agent 实现
///
/// MJ Nexus 内置 3 个参考 Agent：
/// - ResearchAgent: 委派给深度研究引擎
/// - CodeAgent: 代码生成/分析
/// - SummaryAgent: 内容总结
abstract class A2AAgentHandler {
  /// Agent Card
  AgentCard get card;

  /// 处理消息
  /// 返回 Event 流（task/message/artifact/status/end）
  Stream<A2AStreamEvent> handleMessage(A2AMessage message, A2ATask task);

  /// 是否能处理给定 skill
  bool canHandle(String skillId) => card.skills.any((s) => s.id == skillId);
}

/// A2A Server 引擎
class A2AServer {
  final Map<String, A2AAgentHandler> _agents = {};
  final Map<String, A2ATask> _tasks = {};
  final Uuid _uuid = const Uuid();

  /// 注册 Agent
  void registerAgent(A2AAgentHandler agent) {
    _agents[agent.card.name] = agent;
  }

  /// 列出所有 Agent Card
  List<AgentCard> listAgentCards() => _agents.values.map((a) => a.card).toList();

  /// 处理 JSON-RPC 请求
  Future<Map<String, dynamic>> handleRpc(String method, Map<String, dynamic> params) async {
    try {
      switch (method) {
        case 'GetAgentCard':
          final name = params['name'] as String?;
          if (name == null) {
            return _success({'agents': _agents.values.map((a) => a.card.toJson()).toList()});
          }
          final agent = _agents[name];
          if (agent == null) {
            return _error(-32601, 'Agent not found: $name');
          }
          return _success(agent.card.toJson());

        case 'SendMessage':
          return _success(await _sendMessage(params));

        case 'GetTask':
          return _success(_getTask(params));

        case 'ListTasks':
          return _success(_listTasks(params));

        case 'CancelTask':
          return _success(_cancelTask(params));

        default:
          return _error(-32601, 'Method not found: $method');
      }
    } catch (e, stack) {
      debugPrint('[A2AServer] error: $e\n$stack');
      return _error(-32603, 'Internal error: $e');
    }
  }

  /// 内部处理 SendMessage
  Future<Map<String, dynamic>> _sendMessage(Map<String, dynamic> params) async {
    final messageJson = params['message'] as Map<String, dynamic>?;
    if (messageJson == null) {
      throw Exception('Missing message');
    }
    final message = A2AMessage.fromJson(messageJson);
    final contextId = message.contextId ?? _uuid.v4();

    // 找到合适的 Agent
    final skillId = (params['skillId'] as String?) ?? (message.metadata ?? '');
    final agent = _findAgentForSkill(skillId);

    if (agent == null) {
      return _taskErrorResult('No available agent');
    }

    // 创建任务
    final taskId = _uuid.v4();
    var task = A2ATask(
      id: taskId,
      contextId: contextId,
      status: TaskStatus(state: TaskState.submitted, timestamp: DateTime.now()),
      history: [message],
    );
    _tasks[taskId] = task;

    // 异步处理
    unawaited(_executeTask(agent, task, message));

    return task.toJson();
  }

  Future<void> _executeTask(A2AAgentHandler agent, A2ATask task, A2AMessage message) async {
    final updated = task.copyWith(
      status: TaskStatus(state: TaskState.working, timestamp: DateTime.now()),
    );
    _tasks[task.id] = updated;

    try {
      final eventStream = agent.handleMessage(message, updated);
      final newArtifacts = <Artifact>[];
      final newHistory = List<A2AMessage>.from(updated.history);

      await for (final event in eventStream) {
        switch (event) {
          case A2AStatusEvent(:final status):
            _tasks[task.id] = updated.copyWith(status: status);
          case A2AMessageEvent(:final message):
            newHistory.add(message);
            _tasks[task.id] = updated.copyWith(history: newHistory);
          case A2AArtifactEvent(:final artifact):
            newArtifacts.add(artifact);
            _tasks[task.id] = updated.copyWith(artifacts: newArtifacts);
          case A2ATaskEvent():
          case A2AEndEvent():
          case A2AUnknownEvent():
            // 忽略
            break;
        }
      }

      _tasks[task.id] = _tasks[task.id]!.copyWith(
        status: TaskStatus(state: TaskState.completed, timestamp: DateTime.now()),
      );
    } catch (e) {
      _tasks[task.id] = _tasks[task.id]!.copyWith(
        status: TaskStatus(
          state: TaskState.failed,
          reason: e.toString(),
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  A2AAgentHandler? _findAgentForSkill(String skillId) {
    for (final agent in _agents.values) {
      if (agent.canHandle(skillId)) return agent;
    }
    return _agents.values.isNotEmpty ? _agents.values.first : null;
  }

  Map<String, dynamic> _getTask(Map<String, dynamic> params) {
    final taskId = params['taskId'] as String?;
    final task = taskId != null ? _tasks[taskId] : null;
    if (task == null) {
      throw Exception('Task not found: $taskId');
    }
    return task.toJson();
  }

  Map<String, dynamic> _listTasks(Map<String, dynamic> params) {
    final contextId = params['contextId'] as String?;
    var tasks = _tasks.values.toList();
    if (contextId != null) {
      tasks = tasks.where((t) => t.contextId == contextId).toList();
    }
    return {'tasks': tasks.map((t) => t.toJson()).toList()};
  }

  Map<String, dynamic> _cancelTask(Map<String, dynamic> params) {
    final taskId = params['taskId'] as String?;
    final task = taskId != null ? _tasks[taskId] : null;
    if (task == null || taskId == null) {
      return {'success': false, 'reason': 'Task not found'};
    }
    _tasks[taskId] = task.copyWith(
      status: TaskStatus(state: TaskState.canceled, timestamp: DateTime.now()),
    );
    return {'success': true};
  }

  Map<String, dynamic> _success(dynamic result) {
    return {
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'result': result,
    };
  }

  Map<String, dynamic> _error(int code, String message) {
    return {
      'jsonrpc': '2.0',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'error': {'code': code, 'message': message},
    };
  }

  Map<String, dynamic> _taskErrorResult(String reason) {
    return {
      'error': {'code': -32010, 'message': reason},
    };
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  内置 Agent 实现
// ════════════════════════════════════════════════════════════════════════════

/// 通用 LLM Agent - 调用 ModelInferenceEngine 处理消息
class LlmA2AAgent implements A2AAgentHandler {
  @override
  final AgentCard card;
  final String _systemPrompt;
  final Future<String> Function(String) _inference;

  LlmA2AAgent({
    required String name,
    required String description,
    required List<AgentSkill> skills,
    required String systemPrompt,
    required Future<String> Function(String) inference,
  })  : card = AgentCard(
          name: name,
          description: description,
          url: 'local://mcp/$name',
          capabilities: const AgentCapabilities(streaming: true),
          skills: skills,
        ),
        _systemPrompt = systemPrompt,
        _inference = inference;

  @override
  bool canHandle(String skillId) => card.skills.any((s) => s.id == skillId || s.id == '*');

  @override
  Stream<A2AStreamEvent> handleMessage(A2AMessage message, A2ATask task) async* {
    final text = message.text;
    yield A2AStatusEvent(status: TaskStatus(state: TaskState.working, timestamp: DateTime.now()));

    try {
      final response = await _inference('$_systemPrompt\n\nUser: $text\n\nAssistant:');

      yield A2AMessageEvent(
        message: A2AMessage(
          messageId: const Uuid().v4(),
          role: 'agent',
          parts: [TextPart(response)],
          contextId: task.contextId,
          taskId: task.id,
        ),
      );

      yield A2AArtifactEvent(
        artifact: Artifact(
          artifactId: const Uuid().v4(),
          name: 'response',
          parts: [TextPart(response)],
        ),
      );
    } catch (e) {
      yield A2AStatusEvent(
        status: TaskStatus(state: TaskState.failed, reason: e.toString(), timestamp: DateTime.now()),
      );
    }
  }
}
