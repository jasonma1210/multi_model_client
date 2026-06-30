/// ThinkingConfig 单元测试
///
/// v0.42.0 新增：覆盖思考预算配置模型的所有方法。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/models/thinking_config.dart';

void main() {
  group('ThinkingConfig.fromString', () {
    test('disabled 模式', () {
      final config = ThinkingConfig.fromString('disabled');
      expect(config.mode, ThinkingMode.disabled);
      expect(config.budgetTokens, isNull);
    });

    test('enabled 模式 - 带 budget', () {
      final config = ThinkingConfig.fromString('enabled', budgetTokens: 16000);
      expect(config.mode, ThinkingMode.enabled);
      expect(config.budgetTokens, 16000);
    });

    test('adaptive 模式', () {
      final config = ThinkingConfig.fromString('adaptive');
      expect(config.mode, ThinkingMode.adaptive);
      expect(config.budgetTokens, isNull);
    });

    test('未知模式回退到 adaptive', () {
      final config = ThinkingConfig.fromString('unknown');
      expect(config.mode, ThinkingMode.adaptive);
    });

    test('null 输入回退到 adaptive', () {
      final config = ThinkingConfig.fromString(null);
      expect(config.mode, ThinkingMode.adaptive);
    });
  });

  group('ThinkingConfig.toJson', () {
    test('输出包含 mode/budget_tokens/show_process', () {
      final config = ThinkingConfig(
        mode: ThinkingMode.enabled,
        budgetTokens: 8000,
      );
      final json = config.toJson();
      expect(json['mode'], 'enabled');
      expect(json['budget_tokens'], 8000);
      expect(json['show_process'], true);
    });
  });

  group('ThinkingConfig.validate', () {
    test('enabled 模式无 budget 报错', () {
      const config = ThinkingConfig(mode: ThinkingMode.enabled);
      expect(config.validate(), isNotNull);
    });

    test('enabled 模式 budget 太小报错', () {
      const config = ThinkingConfig(mode: ThinkingMode.enabled, budgetTokens: 100);
      expect(config.validate(), isNotNull);
    });

    test('enabled 模式 budget 太大报错', () {
      const config =
          ThinkingConfig(mode: ThinkingMode.enabled, budgetTokens: 200000);
      expect(config.validate(), isNotNull);
    });

    test('enabled 模式 budget 合法', () {
      const config =
          ThinkingConfig(mode: ThinkingMode.enabled, budgetTokens: 10000);
      expect(config.validate(), isNull);
    });

    test('disabled 模式不要求 budget', () {
      const config = ThinkingConfig(mode: ThinkingMode.disabled);
      expect(config.validate(), isNull);
    });
  });

  group('ThinkingCapability.fromModelId', () {
    test('Anthropic Claude 4.5 Sonnet 支持思考', () {
      final cap = ThinkingCapability.fromModelId('claude-4-5-sonnet');
      expect(cap.supportsThinking, true);
      expect(cap.recommendedBudget, 10000);
    });

    test('Claude 4.5 Opus 推荐更高预算', () {
      final cap = ThinkingCapability.fromModelId('claude-4-5-opus');
      expect(cap.supportsThinking, true);
      expect(cap.recommendedBudget, 20000);
    });

    test('OpenAI o1 支持思考', () {
      final cap = ThinkingCapability.fromModelId('o1-preview');
      expect(cap.supportsThinking, true);
    });

    test('OpenAI o3-mini 支持思考', () {
      final cap = ThinkingCapability.fromModelId('o3-mini');
      expect(cap.supportsThinking, true);
    });

    test('GPT-5 支持思考', () {
      final cap = ThinkingCapability.fromModelId('gpt-5');
      expect(cap.supportsThinking, true);
    });

    test('GPT-3.5 不支持思考', () {
      final cap = ThinkingCapability.fromModelId('gpt-3.5-turbo');
      expect(cap.supportsThinking, false);
    });

    test('Claude 3 Opus 不支持思考', () {
      final cap = ThinkingCapability.fromModelId('claude-3-opus');
      expect(cap.supportsThinking, false);
    });

    test('大小写不敏感', () {
      final cap = ThinkingCapability.fromModelId('CLAUDE-4-5-SONNET');
      expect(cap.supportsThinking, true);
    });
  });

  group('ThinkingConfig equality', () {
    test('相同 mode/budget/showProcess 相等', () {
      const a = ThinkingConfig(
        mode: ThinkingMode.enabled,
        budgetTokens: 10000,
      );
      const b = ThinkingConfig(
        mode: ThinkingMode.enabled,
        budgetTokens: 10000,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('不同 mode 不相等', () {
      const a = ThinkingConfig(mode: ThinkingMode.disabled);
      const b = ThinkingConfig(mode: ThinkingMode.adaptive);
      expect(a, isNot(equals(b)));
    });
  });
}
