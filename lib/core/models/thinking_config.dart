/// 思考预算配置
///
/// v0.42.0 新增：让用户控制 Claude / GPT 等模型的推理深度。
/// 支持 Anthropic Extended Thinking 和 OpenAI o-series reasoning_effort。
library;

import 'package:flutter/foundation.dart';

/// 思考模式枚举
enum ThinkingMode {
  /// 禁用思考（不传 thinking/reasoning 参数）
  disabled,

  /// 启用固定预算（显式指定 budget_tokens）
  enabled,

  /// 自适应（让模型自主决定，Anthropic 默认行为）
  adaptive,
}

extension ThinkingModeX on ThinkingMode {
  /// 字符串表示（用于数据库存储）
  String get name {
    switch (this) {
      case ThinkingMode.disabled:
        return 'disabled';
      case ThinkingMode.enabled:
        return 'enabled';
      case ThinkingMode.adaptive:
        return 'adaptive';
    }
  }

  /// 是否支持 budget 配置
  bool get supportsBudget => this == ThinkingMode.enabled;

  /// 友好显示名
  String get displayName {
    switch (this) {
      case ThinkingMode.disabled:
        return '关闭';
      case ThinkingMode.enabled:
        return '自定义';
      case ThinkingMode.adaptive:
        return '自适应';
    }
  }

  /// 描述
  String get description {
    switch (this) {
      case ThinkingMode.disabled:
        return '不使用思考功能，响应最快';
      case ThinkingMode.enabled:
        return '固定 Token 预算，预算越大思考越充分';
      case ThinkingMode.adaptive:
        return '由模型自主决定何时思考';
    }
  }
}

/// 思考预算配置
@immutable
class ThinkingConfig {
  /// 思考模式
  final ThinkingMode mode;

  /// 思考 Token 预算（仅 enabled 模式有效）
  /// 范围：1024 - 100000
  final int? budgetTokens;

  /// 是否向用户展示思考过程
  final bool showThinkingProcess;

  const ThinkingConfig({
    required this.mode,
    this.budgetTokens,
    this.showThinkingProcess = true,
  });

  /// 禁用思考
  static const ThinkingConfig disabled = ThinkingConfig(
    mode: ThinkingMode.disabled,
  );

  /// 自适应思考
  static const ThinkingConfig adaptive = ThinkingConfig(
    mode: ThinkingMode.adaptive,
  );

  /// 从字符串解析（兼容数据库存储）
  static ThinkingConfig fromString(String? value, {int? budgetTokens}) {
    if (value == null) return adaptive;
    switch (value) {
      case 'disabled':
        return disabled;
      case 'enabled':
        return ThinkingConfig(
          mode: ThinkingMode.enabled,
          budgetTokens: budgetTokens,
        );
      case 'adaptive':
      default:
        return adaptive;
    }
  }

  /// 验证配置是否合法
  /// 返回 null 表示合法，否则返回错误信息
  String? validate() {
    if (mode == ThinkingMode.enabled) {
      if (budgetTokens == null) {
        return '启用模式下必须设置 budgetTokens';
      }
      if (budgetTokens! < 1024) {
        return '预算不能小于 1024 tokens';
      }
      if (budgetTokens! > 100000) {
        return '预算不能大于 100000 tokens';
      }
    }
    return null;
  }

  /// 序列化为 JSON（用于存储 / 网络传输）
  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'budget_tokens': budgetTokens,
        'show_process': showThinkingProcess,
      };

  /// 从 JSON 反序列化
  factory ThinkingConfig.fromJson(Map<String, dynamic> json) {
    return ThinkingConfig(
      mode: _parseMode(json['mode']),
      budgetTokens: json['budget_tokens'] as int?,
      showThinkingProcess: json['show_process'] as bool? ?? true,
    );
  }

  static ThinkingMode _parseMode(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'disabled':
          return ThinkingMode.disabled;
        case 'enabled':
          return ThinkingMode.enabled;
        case 'adaptive':
        default:
          return ThinkingMode.adaptive;
      }
    }
    return ThinkingMode.adaptive;
  }

  ThinkingConfig copyWith({
    ThinkingMode? mode,
    int? budgetTokens,
    bool? showThinkingProcess,
  }) {
    return ThinkingConfig(
      mode: mode ?? this.mode,
      budgetTokens: budgetTokens ?? this.budgetTokens,
      showThinkingProcess: showThinkingProcess ?? this.showThinkingProcess,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThinkingConfig &&
        other.mode == mode &&
        other.budgetTokens == budgetTokens &&
        other.showThinkingProcess == showThinkingProcess;
  }

  @override
  int get hashCode =>
      Object.hash(mode, budgetTokens, showThinkingProcess);

  @override
  String toString() =>
      'ThinkingConfig(mode: $mode, budget: $budgetTokens, show: $showThinkingProcess)';
}

/// 模型能力标记
@immutable
class ThinkingCapability {
  /// 是否原生支持思考
  final bool supportsThinking;

  /// 最小预算
  final int minBudget;

  /// 最大预算
  final int maxBudget;

  /// 推荐的默认预算
  final int? recommendedBudget;

  const ThinkingCapability({
    required this.supportsThinking,
    this.minBudget = 1024,
    this.maxBudget = 100000,
    this.recommendedBudget,
  });

  /// 不支持思考
  static const ThinkingCapability notSupported = ThinkingCapability(
    supportsThinking: false,
  );

  /// Claude 4.5 Sonnet 能力
  static const ThinkingCapability claude45Sonnet = ThinkingCapability(
    supportsThinking: true,
    minBudget: 1024,
    maxBudget: 100000,
    recommendedBudget: 10000,
  );

  /// Claude 4.5 Opus 能力
  static const ThinkingCapability claude45Opus = ThinkingCapability(
    supportsThinking: true,
    minBudget: 1024,
    maxBudget: 100000,
    recommendedBudget: 20000,
  );

  /// OpenAI o3-mini 能力
  static const ThinkingCapability o3Mini = ThinkingCapability(
    supportsThinking: true,
    minBudget: 1024,
    maxBudget: 50000,
    recommendedBudget: 10000,
  );

  /// OpenAI o1 能力
  static const ThinkingCapability o1 = ThinkingCapability(
    supportsThinking: true,
    minBudget: 1024,
    maxBudget: 50000,
    recommendedBudget: 15000,
  );

  /// 从模型 ID 自动推断能力
  static ThinkingCapability fromModelId(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('claude-4-5-opus') || id.contains('claude-4.5-opus')) {
      return claude45Opus;
    }
    if (id.contains('claude-4-5') || id.contains('claude-4.5')) {
      return claude45Sonnet;
    }
    if (id.contains('o3-mini')) {
      return o3Mini;
    }
    if (id.contains('o1') || id.contains('o3') || id.contains('o4')) {
      return o1;
    }
    if (id.contains('gpt-5')) {
      return ThinkingCapability(
        supportsThinking: true,
        minBudget: 1024,
        maxBudget: 50000,
        recommendedBudget: 10000,
      );
    }
    return notSupported;
  }
}

/// Token 用量统计（v0.42.0 扩展）
@immutable
class TokenUsage {
  final int inputTokens;
  final int outputTokens;
  final int thinkingTokens;
  final int totalTokens;

  const TokenUsage({
    required this.inputTokens,
    required this.outputTokens,
    this.thinkingTokens = 0,
    required this.totalTokens,
  });

  /// 零用量
  static const TokenUsage zero = TokenUsage(
    inputTokens: 0,
    outputTokens: 0,
    thinkingTokens: 0,
    totalTokens: 0,
  );

  Map<String, dynamic> toJson() => {
        'input_tokens': inputTokens,
        'output_tokens': outputTokens,
        'thinking_tokens': thinkingTokens,
        'total_tokens': totalTokens,
      };

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      inputTokens: json['input_tokens'] as int? ?? 0,
      outputTokens: json['output_tokens'] as int? ?? 0,
      thinkingTokens: json['thinking_tokens'] as int? ?? 0,
      totalTokens: json['total_tokens'] as int? ?? 0,
    );
  }

  /// 估算成本（美元）
  /// pricing 单位：USD per 1K tokens
  double estimateCost({
    required double inputPrice,
    required double outputPrice,
    required double thinkingPrice,
  }) {
    return (inputTokens / 1000 * inputPrice) +
        (outputTokens / 1000 * outputPrice) +
        (thinkingTokens / 1000 * thinkingPrice);
  }
}

/// 模型定价参考（USD per 1K tokens, 2026-06 最新数据）
class ModelPricing {
  /// Claude 4.5 Sonnet
  static const Map<String, double> claude45Sonnet = {
    'input': 0.003,
    'output': 0.015,
    'thinking': 0.015, // 与 output 同价
  };

  /// Claude 4.5 Opus
  static const Map<String, double> claude45Opus = {
    'input': 0.015,
    'output': 0.075,
    'thinking': 0.075,
  };

  /// OpenAI o3-mini
  static const Map<String, double> o3Mini = {
    'input': 0.0011,
    'output': 0.0044,
    'thinking': 0.0044,
  };

  /// OpenAI o1
  static const Map<String, double> o1 = {
    'input': 0.015,
    'output': 0.060,
    'thinking': 0.060,
  };

  /// GPT-5
  static const Map<String, double> gpt5 = {
    'input': 0.005,
    'output': 0.020,
    'thinking': 0.020,
  };

  /// 根据模型 ID 获取定价
  static Map<String, double> getPricing(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('claude-4-5-opus') || id.contains('claude-4.5-opus')) {
      return claude45Opus;
    }
    if (id.contains('claude-4-5') || id.contains('claude-4.5')) {
      return claude45Sonnet;
    }
    if (id.contains('o3-mini')) {
      return o3Mini;
    }
    if (id.contains('o1')) {
      return o1;
    }
    if (id.contains('gpt-5')) {
      return gpt5;
    }
    return {'input': 0.001, 'output': 0.002, 'thinking': 0.002};
  }
}
