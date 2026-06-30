/// OpenAI Adapter 思考预算测试（v0.42.0）
///
/// 验证 reasoning_effort 参数注入逻辑。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/adapters/openai_adapter.dart';

void main() {
  group('OpenAI reasoning 注入', () {
    test('o1 模型 + enabled 模式 + 小预算 → low', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o1-mini',
        thinkingMode: 'enabled',
        thinkingBudget: 1000,
      );
      final json = config.toJson();
      expect(json['reasoning'], isNotNull);
      expect((json['reasoning'] as Map)['effort'], 'low');
    });

    test('o1 模型 + enabled 模式 + 中预算 → medium', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o1-preview',
        thinkingMode: 'enabled',
        thinkingBudget: 10000,
      );
      final json = config.toJson();
      expect((json['reasoning'] as Map)['effort'], 'medium');
    });

    test('o1 模型 + enabled 模式 + 大预算 → high', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o1',
        thinkingMode: 'enabled',
        thinkingBudget: 30000,
      );
      final json = config.toJson();
      expect((json['reasoning'] as Map)['effort'], 'high');
    });

    test('o1 模型 + enabled 模式 + 超大预算 → xhigh', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o3-mini',
        thinkingMode: 'enabled',
        thinkingBudget: 80000,
      );
      final json = config.toJson();
      expect((json['reasoning'] as Map)['effort'], 'xhigh');
    });

    test('o1 模型 + adaptive 模式 → medium', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o1-mini',
        thinkingMode: 'adaptive',
      );
      final json = config.toJson();
      expect((json['reasoning'] as Map)['effort'], 'medium');
    });

    test('o1 模型 + disabled 模式 → 不注入', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o1-mini',
        thinkingMode: 'disabled',
      );
      final json = config.toJson();
      expect(json.containsKey('reasoning'), false);
    });

    test('GPT-5 模型 + enabled → 注入 reasoning', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'gpt-5',
        thinkingMode: 'enabled',
        thinkingBudget: 10000,
      );
      final json = config.toJson();
      expect((json['reasoning'] as Map)['effort'], 'medium');
    });

    test('非推理模型（gpt-3.5）→ 不注入 reasoning', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'gpt-3.5-turbo',
        thinkingMode: 'enabled',
        thinkingBudget: 10000,
      );
      final json = config.toJson();
      expect(json.containsKey('reasoning'), false);
    });

    test('thinkingMode 为 null → 不注入', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'o1-mini',
        thinkingMode: null,
      );
      final json = config.toJson();
      expect(json.containsKey('reasoning'), false);
    });

    test('gpt-4o 模型 + enabled → 不注入（非推理模型）', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'gpt-4o',
        thinkingMode: 'enabled',
        thinkingBudget: 10000,
      );
      final json = config.toJson();
      expect(json.containsKey('reasoning'), false);
    });
  });

  group('OpenAI 基础 toJson', () {
    test('必填字段存在', () {
      final config = OpenAIConfig(
        apiKey: 'sk-test',
        model: 'gpt-4',
        temperature: 0.5,
        maxTokens: 1024,
        stream: true,
      );
      final json = config.toJson();
      expect(json['model'], 'gpt-4');
      expect(json['temperature'], 0.5);
      expect(json['max_tokens'], 1024);
      expect(json['stream'], true);
    });

    test('可选字段在 null 时不出现', () {
      final config = OpenAIConfig(apiKey: 'sk-test', model: 'gpt-4');
      final json = config.toJson();
      expect(json.containsKey('presence_penalty'), false);
      expect(json.containsKey('frequency_penalty'), false);
      expect(json.containsKey('user'), false);
    });
  });
}
