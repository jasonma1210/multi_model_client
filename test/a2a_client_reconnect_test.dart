// v0.43.0 A2A 客户端单元测试
//
// 覆盖：
// 1. A2AStreamEvent 解析（sealed class 模式匹配）
// 2. AgentCard / Task / Message JSON 序列化
// 3. A2A 客户端重连配置 + Last-Event-ID 续传

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mj_nexus/core/protocols/a2a/a2a_client.dart';
import 'package:mj_nexus/core/protocols/a2a/a2a_protocol.dart';
import 'package:mj_nexus/core/protocols/a2a/a2a_stream_event.dart';

void main() {
  group('A2AStreamEvent 解析', () {
    test('解析 task 事件', () {
      final json = {
        'result': {
          'type': 'task',
          'id': 'task-1',
          'contextId': 'ctx-1',
          'status': {
            'state': 'working',
            'timestamp': '2026-06-30T10:00:00Z',
          },
          'history': [],
          'artifacts': [],
        },
      };
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2ATaskEvent>());
      final task = (event as A2ATaskEvent).task;
      expect(task.id, 'task-1');
      expect(task.contextId, 'ctx-1');
      expect(task.state, TaskState.working);
    });

    test('解析 status-update 事件', () {
      final json = {
        'result': {
          'type': 'status-update',
          'state': 'completed',
          'timestamp': '2026-06-30T10:00:00Z',
        },
      };
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2AStatusEvent>());
      expect((event as A2AStatusEvent).status.state, TaskState.completed);
    });

    test('解析 message 事件', () {
      final json = {
        'result': {
          'type': 'message',
          'messageId': 'msg-1',
          'role': 'agent',
          'parts': [
            {'type': 'text', 'text': 'Hello from A2A'},
          ],
          'contextId': 'ctx-1',
          'taskId': 'task-1',
        },
      };
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2AMessageEvent>());
      final msg = (event as A2AMessageEvent).message;
      expect(msg.text, 'Hello from A2A');
    });

    test('解析 artifact 事件', () {
      final json = {
        'result': {
          'type': 'artifact',
          'artifactId': 'art-1',
          'name': 'result',
          'parts': [
            {'type': 'text', 'text': 'artifact content'},
          ],
        },
      };
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2AArtifactEvent>());
      final art = (event as A2AArtifactEvent).artifact;
      expect(art.name, 'result');
    });

    test('解析 end 事件', () {
      final json = {
        'result': {'type': 'end'},
      };
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2AEndEvent>());
    });

    test('未知类型降级为 UnknownEvent', () {
      final json = {
        'result': {'type': 'weird-future-type', 'data': 'foo'},
      };
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2AUnknownEvent>());
      expect((event as A2AUnknownEvent).rawType, 'weird-future-type');
    });

    test('空 result 降级为 unknown', () {
      final json = {'result': null};
      final event = A2AStreamEvent.fromJson(json);
      expect(event, isA<A2AStreamEvent>());
      // 未知类型 → A2AUnknownEvent
      expect(event, isA<A2AUnknownEvent>());
    });
  });

  group('TaskState 枚举', () {
    test('wire name 一致', () {
      for (final state in TaskState.values) {
        expect(TaskState.fromWireName(state.wireName), state);
      }
    });

    test('未知 wire name 降级为 unknown', () {
      expect(TaskState.fromWireName('something-new'), TaskState.unknown);
    });
  });

  group('AgentCard JSON 序列化', () {
    test('toJson/fromJson 对称', () {
      const card = AgentCard(
        name: 'TestAgent',
        description: 'A test agent',
        url: 'https://agent.example.com',
        version: '1.0.0',
        capabilities: AgentCapabilities(streaming: true, pushNotifications: false),
        skills: [
          AgentSkill(
            id: 'search',
            name: 'Web Search',
            description: 'Search the web',
            tags: ['web', 'search'],
          ),
        ],
      );
      final json = card.toJson();
      final restored = AgentCard.fromJson(json);
      expect(restored.name, 'TestAgent');
      expect(restored.skills.length, 1);
      expect(restored.skills.first.id, 'search');
      expect(restored.capabilities.streaming, true);
    });
  });

  group('A2AReconnectConfig', () {
    test('默认配置合理', () {
      const config = A2AReconnectConfig();
      expect(config.initialBackoff.inSeconds, 3);
      expect(config.maxBackoff.inSeconds, 30);
      expect(config.maxRetries, 0);
      expect(config.heartbeatTimeout.inSeconds, 45);
    });
  });

  group('A2AClient 实例化', () {
    test('可正常构造', () {
      final client = A2AClient(agentUrl: 'https://agent.example.com');
      expect(client.agentUrl, 'https://agent.example.com');
    });

    test('支持自定义 Reconnect 配置', () {
      final client = A2AClient(
        agentUrl: 'https://agent.example.com',
        apiKey: 'sk-test',
        reconnectConfig: const A2AReconnectConfig(
          initialBackoff: Duration(seconds: 1),
          maxBackoff: Duration(seconds: 10),
          maxRetries: 3,
        ),
      );
      expect(client.agentUrl, 'https://agent.example.com');
    });
  });

  group('A2AStreamSubscription', () {
    test('cancel 关闭 controller', () async {
      final businessController = StreamController<A2AStreamEvent>.broadcast();
      final reconnectController = StreamController<A2AReconnectEvent>.broadcast();
      var cancelled = false;
      final sub = A2AStreamSubscription.test(
        controller: businessController,
        reconnectController: reconnectController,
        cancel: () async {
          cancelled = true;
          if (!businessController.isClosed) await businessController.close();
          if (!reconnectController.isClosed) await reconnectController.close();
        },
      );
      await sub.cancel();
      expect(cancelled, true);
      expect(businessController.isClosed, true);
      expect(reconnectController.isClosed, true);
    });

    test('暴露 events stream', () async {
      final businessController = StreamController<A2AStreamEvent>.broadcast();
      final reconnectController = StreamController<A2AReconnectEvent>.broadcast();
      final sub = A2AStreamSubscription.test(
        controller: businessController,
        reconnectController: reconnectController,
        cancel: () async {},
      );
      expect(sub.events, isA<Stream<A2AReconnectEvent>>());
      expect(sub.stream, isA<Stream<A2AStreamEvent>>());
      // 主动关闭以避免测试框架警告
      await businessController.close();
      await reconnectController.close();
    });

    test('pause/resume 是可调用的 no-op 默认实现', () async {
      final businessController = StreamController<A2AStreamEvent>.broadcast();
      final reconnectController = StreamController<A2AReconnectEvent>.broadcast();
      final sub = A2AStreamSubscription.test(
        controller: businessController,
        reconnectController: reconnectController,
        cancel: () async {},
      );
      // 验证 pause/resume 可调用
      sub.pause();
      sub.resume();
      // 关闭
      await businessController.close();
      await reconnectController.close();
    });
  });

  group('A2AReconnectConfig', () {
    test('默认配置含 jitter 和 idleTimeout', () {
      const config = A2AReconnectConfig();
      expect(config.initialBackoff.inSeconds, 3);
      expect(config.maxBackoff.inSeconds, 30);
      expect(config.maxRetries, 0);
      expect(config.heartbeatTimeout.inSeconds, 45);
      expect(config.jitterRatio, 0.3);
      expect(config.idleTimeout.inSeconds, 120);
    });

    test('可自定义 jitter 与 idle timeout', () {
      const config = A2AReconnectConfig(
        initialBackoff: Duration(seconds: 1),
        maxBackoff: Duration(seconds: 5),
        maxRetries: 5,
        jitterRatio: 0.5,
        idleTimeout: Duration(seconds: 60),
      );
      expect(config.jitterRatio, 0.5);
      expect(config.idleTimeout.inSeconds, 60);
      expect(config.maxRetries, 5);
    });
  });

  group('A2AReconnectEvent', () {
    test('构造 + toString 包含关键字段', () {
      const event = A2AReconnectEvent(
        state: A2AReconnectState.reconnecting,
        attempt: 3,
        nextBackoff: Duration(seconds: 6),
        reason: 'heartbeat-timeout',
      );
      expect(event.state, A2AReconnectState.reconnecting);
      expect(event.attempt, 3);
      expect(event.nextBackoff, const Duration(seconds: 6));
      expect(event.reason, 'heartbeat-timeout');
      expect(event.toString(), contains('reconnecting'));
      expect(event.toString(), contains('attempt=3'));
    });

    test('四种状态值', () {
      expect(A2AReconnectState.values.length, 4);
      expect(A2AReconnectState.values, containsAll([
        A2AReconnectState.connecting,
        A2AReconnectState.connected,
        A2AReconnectState.reconnecting,
        A2AReconnectState.closed,
      ]));
    });
  });

  group('A2A 客户端 sendStreamingMessage 错误处理', () {
    test('不可用的端点抛 A2A RPC 异常', () async {
      final client = A2AClient(agentUrl: 'http://127.0.0.1:1');
      expect(
        () => client.sendMessage(
          messageId: 'm1',
          contextId: 'c1',
          parts: [const TextPart('hi')],
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
