// v0.43.0 A2A 协议单元测试

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/protocols/a2a/a2a_protocol.dart';

void main() {
  group('AgentCard 序列化', () {
    test('基础 AgentCard 转 JSON', () {
      const card = AgentCard(
        name: 'ResearchAgent',
        description: '研究助手',
        url: 'https://example.com/agent',
        skills: [AgentSkill(id: 'research', name: '研究', description: '深度研究')],
      );
      final json = card.toJson();
      expect(json['name'], 'ResearchAgent');
      expect(json['skills'], isA<List>());
      expect((json['skills'] as List).length, 1);
    });

    test('AgentCard 从 JSON 反序列化', () {
      final json = {
        'name': 'CodeAgent',
        'description': '代码助手',
        'url': 'https://example.com/code',
        'capabilities': {'streaming': true, 'pushNotifications': false, 'stateTransitionHistory': false},
        'skills': [
          {'id': 'code', 'name': 'Code', 'description': 'Generate code'}
        ],
      };
      final card = AgentCard.fromJson(json);
      expect(card.name, 'CodeAgent');
      expect(card.capabilities.streaming, true);
      expect(card.skills.length, 1);
    });
  });

  group('TaskState', () {
    test('wire name 转换', () {
      expect(TaskState.working.wireName, 'working');
      expect(TaskState.fromWireName('completed'), TaskState.completed);
      expect(TaskState.fromWireName('invalid'), TaskState.unknown);
    });
  });

  group('A2AMessage', () {
    test('构造 + 序列化', () {
      final msg = A2AMessage(
        messageId: 'm1',
        role: 'user',
        parts: const [TextPart('Hello')],
        contextId: 'ctx1',
      );
      final json = msg.toJson();
      expect(json['messageId'], 'm1');
      expect(json['role'], 'user');
      expect(json['parts'][0]['text'], 'Hello');
      expect(json['contextId'], 'ctx1');
    });

    test('反序列化 text 提取', () {
      final json = {
        'messageId': 'm1',
        'role': 'agent',
        'parts': [
          {'type': 'text', 'text': 'Reply'},
          {'type': 'text', 'text': 'more'},
        ],
      };
      final msg = A2AMessage.fromJson(json);
      expect(msg.text, 'Reply\nmore');
    });
  });

  group('A2ATask', () {
    test('Task 序列化与状态', () {
      final task = A2ATask(
        id: 't1',
        contextId: 'c1',
        status: TaskStatus(state: TaskState.working, timestamp: DateTime(2026, 1, 1)),
      );
      final json = task.toJson();
      expect(json['id'], 't1');
      expect(json['status']['state'], 'working');
    });

    test('Task 状态更新', () {
      final task = A2ATask(
        id: 't1',
        contextId: 'c1',
        status: TaskStatus(state: TaskState.submitted),
      );
      final updated = task.copyWith(status: TaskStatus(state: TaskState.completed));
      expect(task.state, TaskState.submitted);
      expect(updated.state, TaskState.completed);
      expect(updated.id, 't1');
    });
  });

  group('Part 类型', () {
    test('TextPart', () {
      const p = TextPart('hi');
      expect(p.toJson()['text'], 'hi');
      expect(p.toJson()['type'], 'text');
    });

    test('FilePart', () {
      const p = FilePart(fileUri: 'https://x.com/a.pdf', mimeType: 'application/pdf', name: 'a.pdf');
      expect(p.toJson()['type'], 'file');
      expect(p.toJson()['file']['mimeType'], 'application/pdf');
    });

    test('DataPart', () {
      const p = DataPart({'key': 'value'});
      expect(p.toJson()['type'], 'data');
      expect(p.toJson()['data']['key'], 'value');
    });
  });
}
