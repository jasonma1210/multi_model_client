// v0.43.0 实现 A2A 委派服务（让 ChatPage 把消息流式委派给远程 Agent）
//
// 职责：
// 1. 接收 ChatPage 的文本（+ 累积图片 base64）
// 2. 调用 A2AClient.sendStreamingMessage 启动流式任务
// 3. 把 A2AStreamEvent 累积为最终回复文本
// 4. 通过回调实时返回增量文本，让 ChatPage 走和 LLM 一样的流式 UI 路径
// 5. 任务完成后通过 onComplete 回调返回完整文本
//
// 用法：
// ```dart
// final service = A2ADelegationService(ref);
// await service.delegate(
//   agentName: 'ResearchAgent',
//   text: userText,
//   contextId: sessionId,
//   onDelta: (delta) => setState(() => _streamingText += delta),
//   onComplete: (fullText) => setState(() => _isGenerating = false),
//   onError: (e) => setState(() => _isGenerating = false),
// );
// ```

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/protocols/a2a/a2a_client.dart';
import '../../../core/protocols/a2a/a2a_protocol.dart';
import '../../../core/protocols/a2a/a2a_stream_event.dart';
import '../providers/a2a_providers.dart';

/// A2A 委派服务（轻量，绑定到 WidgetRef）
class A2ADelegationService {
  final WidgetRef _ref;
  A2AStreamSubscription? _sub;
  StreamSubscription<A2AStreamEvent>? _eventSub;
  StreamSubscription<A2AReconnectEvent>? _reconnectSub;
  bool _cancelled = false;

  A2ADelegationService(this._ref);

  /// 委派消息给 A2A 远程 Agent
  ///
  /// [onDelta] 每次收到增量文本时触发
  /// [onReconnect] 重连状态变化时触发
  /// [onComplete] 任务完成时触发，参数为最终完整文本
  /// [onError] 出错时触发
  /// [images] 可选图片描述（仅作为元数据传给 Agent，不会自动 base64）
  Future<void> delegate({
    required String agentName,
    required String text,
    required String contextId,
    required void Function(String delta) onDelta,
    void Function(A2AReconnectEvent event)? onReconnect,
    required void Function(String fullText) onComplete,
    required void Function(Object error) onError,
  }) async {
    final agents = _ref.read(a2aAgentsProvider);
    final serverId = agents.agentToServerMap[agentName];
    if (serverId == null) {
      onError('Agent 不存在: $agentName，请先在 A2A 面板中确认已加载');
      return;
    }
    final settings = _ref.read(a2aSettingsProvider);
    final config = settings.servers.firstWhere(
      (s) => s.id == serverId,
      orElse: () => throw StateError('A2A server config missing for $serverId'),
    );
    final manager = _ref.read(a2aClientManagerProvider);
    final client = manager.getOrCreate(config);

    final userMessageId = const Uuid().v4();
    _cancelled = false;

    // 也通过全局 provider 跟踪（用于 ChatPage 显示任务监控卡片）
    _ref.read(a2aTaskRuntimeProvider.notifier).startStreaming(
          agentName: agentName,
          userMessageId: userMessageId,
          contextId: contextId,
          text: text,
        );

    // 拿到底层 subscription，做增量文本回调
    final runtime = _ref.read(a2aTaskRuntimeProvider);
    final sub = runtime?.subscription;
    if (sub == null) {
      onError('A2A 任务启动失败：subscription 为空');
      return;
    }
    _sub = sub;

    // 跟踪累积文本
    String accumulated = '';

    _eventSub = sub.stream.listen(
      (event) {
        if (_cancelled) return;
        switch (event) {
          case A2AMessageEvent(:final message):
            final delta = message.parts
                .whereType<TextPart>()
                .map((p) => p.text)
                .join('');
            if (delta.isNotEmpty) {
              accumulated += delta;
              onDelta(delta);
            }
          case A2AStatusEvent(:final status):
            if (status.state == TaskState.failed) {
              onError(status.reason ?? 'A2A 任务失败');
            } else if (status.state == TaskState.canceled) {
              onError('A2A 任务被取消');
            } else if (status.state == TaskState.completed) {
              onComplete(accumulated);
            }
          case A2AEndEvent():
            onComplete(accumulated);
          case A2AArtifactEvent():
          case A2ATaskEvent():
          case A2AUnknownEvent():
            break;
        }
      },
      onError: (e) {
        debugPrint('[A2ADelegation] stream error: $e');
        onError(e);
      },
      onDone: () {
        debugPrint('[A2ADelegation] stream done, accumulated: ${accumulated.length} chars');
        onComplete(accumulated);
      },
    );

    _reconnectSub = sub.events.listen(
      (event) {
        debugPrint('[A2ADelegation] reconnect: $event');
        onReconnect?.call(event);
      },
    );
  }

  /// 取消当前委派
  Future<void> cancel() async {
    _cancelled = true;
    await _eventSub?.cancel();
    await _reconnectSub?.cancel();
    await _ref.read(a2aTaskRuntimeProvider.notifier).cancel();
    _eventSub = null;
    _reconnectSub = null;
    _sub = null;
  }

  /// 释放资源（不要取消 task runtime，让用户看到结果）
  Future<void> dispose() async {
    await _eventSub?.cancel();
    await _reconnectSub?.cancel();
    _eventSub = null;
    _reconnectSub = null;
    _sub = null;
  }
}
