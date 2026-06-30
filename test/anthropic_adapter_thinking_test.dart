/// Anthropic Adapter 思考预算测试（v0.42.0）
///
/// 验证 Extended Thinking 参数注入逻辑。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/adapters/anthropic_adapter.dart';

void main() {
  group('Anthropic thinking 注入', () {
    test('claude-4 模型 + enabled 模式 → 注入 thinking', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-4-sonnet',
        maxTokens: 8192,
        thinkingMode: 'enabled',
        thinkingBudget: 16000,
      );
      final json = config.toJson();
      expect(json['thinking'], isNotNull);
      expect((json['thinking'] as Map)['type'], 'enabled');
      expect((json['thinking'] as Map)['budget_tokens'], 16000);
    });

    test('claude-4 模型 + adaptive 模式 → 注入 thinking, 默认 10K', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-4-opus',
        maxTokens: 8192,
        thinkingMode: 'adaptive',
      );
      final json = config.toJson();
      expect(json['thinking'], isNotNull);
      expect((json['thinking'] as Map)['budget_tokens'], 10000);
    });

    test('claude-4 模型 + disabled 模式 → 不注入', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-4-sonnet',
        maxTokens: 8192,
        thinkingMode: 'disabled',
      );
      final json = config.toJson();
      expect(json.containsKey('thinking'), false);
    });

    test('claude-3-7 模型 + enabled → 注入', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-3-7-sonnet',
        maxTokens: 8192,
        thinkingMode: 'enabled',
        thinkingBudget: 5000,
      );
      final json = config.toJson();
      expect(json['thinking'], isNotNull);
      expect((json['thinking'] as Map)['budget_tokens'], 5000);
    });

    test('claude-3-5 模型 → 不注入（非 4.5/3.7+）', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-3-5-sonnet-20241022',
        maxTokens: 8192,
        thinkingMode: 'enabled',
        thinkingBudget: 10000,
      );
      final json = config.toJson();
      expect(json.containsKey('thinking'), false);
    });

    test('claude-3-opus 模型 → 不注入', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-3-opus-20240229',
        maxTokens: 4096,
        thinkingMode: 'enabled',
        thinkingBudget: 10000,
      );
      final json = config.toJson();
      expect(json.containsKey('thinking'), false);
    });

    test('thinkingMode 为 null → 不注入', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-4-sonnet',
        maxTokens: 8192,
        thinkingMode: null,
      );
      final json = config.toJson();
      expect(json.containsKey('thinking'), false);
    });

    test('enabled 模式 + thinkingBudget 为 null → 默认 10K', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-4-sonnet',
        maxTokens: 8192,
        thinkingMode: 'enabled',
        thinkingBudget: null,
      );
      final json = config.toJson();
      expect((json['thinking'] as Map)['budget_tokens'], 10000);
    });
  });

  group('Anthropic 基础 toJson', () {
    test('必填字段存在', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-3-5-sonnet-20241022',
        maxTokens: 4096,
        temperature: 0.7,
        topP: 0.9,
        topK: 5,
        stream: true,
      );
      final json = config.toJson();
      expect(json['model'], 'claude-3-5-sonnet-20241022');
      expect(json['max_tokens'], 4096);
      expect(json['temperature'], 0.7);
      expect(json['top_p'], 0.9);
      expect(json['top_k'], 5);
      expect(json['stream'], true);
    });

    test('可选字段在 null 时不出现', () {
      final config = AnthropicConfig(
        apiKey: 'sk-ant-test',
        model: 'claude-3-5-sonnet',
        maxTokens: 4096,
      );
      final json = config.toJson();
      expect(json.containsKey('temperature'), false);
      expect(json.containsKey('top_p'), false);
      expect(json.containsKey('top_k'), false);
      expect(json.containsKey('stop_sequences'), false);
    });
  });
}
