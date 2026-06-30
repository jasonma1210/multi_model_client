// v0.43.0 实现 A2A 流式事件 sealed class
//
// 事件类型（参考 A2A v0.2 spec）：
// - TaskStatusUpdateEvent (status-update): 状态变更（submitted/working/input-required/completed/failed/canceled）
// - TaskArtifactUpdateEvent (artifact-update): 产物更新（增量）
// - MessageEvent: 助手流式消息（用于实时渲染）
// - EndEvent: 流结束
// - UnknownEvent: 无法解析的事件（不抛错，降级处理）

import 'a2a_protocol.dart';

sealed class A2AStreamEvent {
  const A2AStreamEvent();

  /// 解析 JSON-RPC 响应帧
  /// 兼容两种格式：
  /// 1. { result: { type: ..., ... } }
  /// 2. 直接 event payload（一些实现省略 result 包装）
  factory A2AStreamEvent.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    final payload = result ?? json;

    final type = (payload['type'] as String?) ?? (json['method'] as String?) ?? 'unknown';

    switch (type) {
      case 'task':
      case 'Task':
        return A2ATaskEvent(task: A2ATask.fromJson(payload));
      case 'message':
      case 'Message':
        return A2AMessageEvent(message: A2AMessage.fromJson(payload));
      case 'artifact':
      case 'Artifact':
      case 'artifact-update':
      case 'TaskArtifactUpdateEvent':
        return A2AArtifactEvent(artifact: Artifact.fromJson(payload));
      case 'status':
      case 'status-update':
      case 'TaskStatusUpdateEvent':
        return A2AStatusEvent(status: TaskStatus.fromJson(payload));
      case 'end':
      case 'done':
        return const A2AEndEvent();
      default:
        return A2AUnknownEvent(rawType: type, payload: payload);
    }
  }
}

/// 任务对象事件（通常是流的第一个事件，包含完整任务信息）
class A2ATaskEvent extends A2AStreamEvent {
  final A2ATask task;
  const A2ATaskEvent({required this.task});
}

/// 助手消息事件（流式文本）
class A2AMessageEvent extends A2AStreamEvent {
  final A2AMessage message;
  const A2AMessageEvent({required this.message});
}

/// 产物更新事件
class A2AArtifactEvent extends A2AStreamEvent {
  final Artifact artifact;
  const A2AArtifactEvent({required this.artifact});
}

/// 状态更新事件
class A2AStatusEvent extends A2AStreamEvent {
  final TaskStatus status;
  const A2AStatusEvent({required this.status});
}

/// 流结束事件
class A2AEndEvent extends A2AStreamEvent {
  const A2AEndEvent();
}

/// 未知事件（容错）
class A2AUnknownEvent extends A2AStreamEvent {
  final String rawType;
  final Map<String, dynamic> payload;
  const A2AUnknownEvent({required this.rawType, required this.payload});
}
