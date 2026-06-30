import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// OpenAI API配置
class OpenAIConfig {
  final String apiKey;
  final String baseUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final double topP;
  final int? n;
  final bool stream;
  final List<String>? stop;
  final double? presencePenalty;
  final double? frequencyPenalty;
  final Map<String, dynamic>? logitBias;
  final String? user;

  // v0.42.0: 思考预算配置
  /// 思考模式：'disabled' | 'enabled' | 'adaptive'
  final String? thinkingMode;

  /// 思考 Token 预算（仅 enabled 模式有效）
  final int? thinkingBudget;

  /// 思考过程是否展示给用户
  final bool? showThinkingProcess;

  OpenAIConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-3.5-turbo',
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.topP = 1.0,
    this.n,
    this.stream = false,
    this.stop,
    this.presencePenalty,
    this.frequencyPenalty,
    this.logitBias,
    this.user,
    this.thinkingMode,
    this.thinkingBudget,
    this.showThinkingProcess,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'top_p': topP,
      if (n != null) 'n': n,
      'stream': stream,
      if (stop != null) 'stop': stop,
      if (presencePenalty != null) 'presence_penalty': presencePenalty,
      if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
      if (logitBias != null) 'logit_bias': logitBias,
      if (user != null) 'user': user,
      // v0.42.0: 注入 reasoning 参数（仅 o-series / GPT-5）
      if (_shouldInjectReasoning()) ..._buildReasoningPayload(),
    };
  }

  /// 是否应注入 reasoning 参数
  bool _shouldInjectReasoning() {
    final id = model.toLowerCase();
    final isReasoningModel = id.contains('o1') ||
        id.contains('o3') ||
        id.contains('o4') ||
        id.contains('gpt-5');
    return isReasoningModel && thinkingMode != null && thinkingMode != 'disabled';
  }

  /// 构造 reasoning payload
  Map<String, dynamic> _buildReasoningPayload() {
    if (thinkingMode == 'enabled' && thinkingBudget != null) {
      // OpenAI reasoning_effort 是枚举值，需要从 budget 转换
      final effort = _budgetToEffort(thinkingBudget!);
      return {'reasoning': {'effort': effort}};
    }
    if (thinkingMode == 'adaptive') {
      return {'reasoning': {'effort': 'medium'}};
    }
    return {};
  }

  /// 将 token 预算转换为 effort 等级
  String _budgetToEffort(int budget) {
    if (budget < 5000) return 'low';
    if (budget < 20000) return 'medium';
    if (budget < 50000) return 'high';
    return 'xhigh';
  }
}

/// OpenAI消息
class OpenAIMessage {
  final String role;
  final String content;
  final String? name;

  OpenAIMessage({
    required this.role,
    required this.content,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (name != null) 'name': name,
    };
  }

  factory OpenAIMessage.fromJson(Map<String, dynamic> json) {
    return OpenAIMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      name: json['name'] as String?,
    );
  }
}

/// OpenAI响应
class OpenAIResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChoice> choices;
  final OpenAIUsage usage;

  OpenAIResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: json['created'] as int,
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((c) => OpenAIChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
      usage: OpenAIUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }
}

/// OpenAI选择
class OpenAIChoice {
  final int index;
  final OpenAIMessage message;
  final OpenAIMessage? delta;
  final String? finishReason;

  OpenAIChoice({
    required this.index,
    required this.message,
    this.delta,
    this.finishReason,
  });

  factory OpenAIChoice.fromJson(Map<String, dynamic> json) {
    return OpenAIChoice(
      index: json['index'] as int,
      message: OpenAIMessage.fromJson(
        (json['message'] ?? json['delta']) as Map<String, dynamic>,
      ),
      delta: json['delta'] != null
          ? OpenAIMessage.fromJson(json['delta'] as Map<String, dynamic>)
          : null,
      finishReason: json['finish_reason'] as String?,
    );
  }
}

/// OpenAI使用量
class OpenAIUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  // v0.42.0: 思考 tokens（o-series / GPT-5 reasoning）
  final int? reasoningTokens;

  OpenAIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.reasoningTokens,
  });

  factory OpenAIUsage.fromJson(Map<String, dynamic> json) {
    // OpenAI reasoning tokens 字段可能命名为：
    // - completion_tokens_details.reasoning_tokens
    // - reasoning_tokens
    int? reasoning;
    final details = json['completion_tokens_details'];
    if (details is Map<String, dynamic>) {
      reasoning = details['reasoning_tokens'] as int?;
    }
    reasoning ??= json['reasoning_tokens'] as int?;

    return OpenAIUsage(
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
      reasoningTokens: reasoning,
    );
  }
}

/// OpenAI适配器
class OpenAIAdapter {
  final Dio _dio;
  OpenAIConfig _config;

  OpenAIAdapter({
    required OpenAIConfig config,
  })  : _config = config,
        _dio = Dio(BaseOptions(
          baseUrl: config.baseUrl,
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  /// 更新配置
  void updateConfig(OpenAIConfig config) {
    _config = config;
    _dio.options.baseUrl = config.baseUrl;
    _dio.options.headers['Authorization'] = 'Bearer ${config.apiKey}';
  }

  /// 获取当前配置
  OpenAIConfig get config => _config;

  /// 聊天补全
  Future<OpenAIResponse> chatCompletion(
    List<OpenAIMessage> messages, {
    OpenAIConfig? overrideConfig,
  }) async {
    try {
      final effectiveConfig = overrideConfig ?? _config;

      final response = await _dio.post(
        '/chat/completions',
        data: {
          ...effectiveConfig.toJson(),
          'messages': messages.map((m) => m.toJson()).toList(),
        },
      );

      return OpenAIResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('OpenAI API error: $e');
    }
  }

  /// 流式聊天补全
  Stream<OpenAIChoice> chatCompletionStream(
    List<OpenAIMessage> messages, {
    OpenAIConfig? overrideConfig,
  }) async* {
    try {
      final effectiveConfig = (overrideConfig ?? _config);
      final streamConfig = OpenAIConfig(
        apiKey: effectiveConfig.apiKey,
        baseUrl: effectiveConfig.baseUrl,
        model: effectiveConfig.model,
        temperature: effectiveConfig.temperature,
        maxTokens: effectiveConfig.maxTokens,
        topP: effectiveConfig.topP,
        stream: true,
        stop: effectiveConfig.stop,
        presencePenalty: effectiveConfig.presencePenalty,
        frequencyPenalty: effectiveConfig.frequencyPenalty,
        user: effectiveConfig.user,
      );

      final response = await _dio.post(
        '/chat/completions',
        data: {
          ...streamConfig.toJson(),
          'messages': messages.map((m) => m.toJson()).toList(),
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: null,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        buffer.write(text);

        // 处理SSE格式
        final lines = buffer.toString().split('\n');
        buffer.clear();

        for (var i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.isEmpty || line == 'data: [DONE]') continue;
          if (!line.startsWith('data: ')) continue;

          try {
            final jsonStr = line.substring(6);
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;

            if (choices != null && choices.isNotEmpty) {
              final choice = OpenAIChoice.fromJson(choices[0] as Map<String, dynamic>);
              if (choice.delta?.content != null && choice.delta!.content.isNotEmpty) {
                yield choice;
              }
            }
          } catch (e) {
            debugPrint('Error parsing SSE: $e');
          }
        }

        // 保留最后一个不完整的行
        if (lines.isNotEmpty) {
          buffer.write(lines.last);
        }
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('OpenAI streaming error: $e');
    }
  }

  /// 获取可用模型列表
  Future<List<String>> listModels() async {
    try {
      final response = await _dio.get('/models');
      final data = response.data as Map<String, dynamic>;
      final models = data['data'] as List<dynamic>;

      return models
          .map((m) => m['id'] as String)
          .where((id) => id.contains('gpt'))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to list models: $e');
    }
  }

  /// 计算Token数量（估算）
  int estimateTokens(String text) {
    // 简单估算：英文约4字符=1token，中文约1.5字符=1token
    final englishChars = text.codeUnits.where((c) => c < 128).length;
    final chineseChars = text.length - englishChars;

    return (englishChars / 4 + chineseChars / 1.5).ceil();
  }

  /// 错误处理
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      String message;
      if (data is Map && data['error'] != null) {
        message = data['error']['message'] ?? 'Unknown error';
      } else {
        message = 'HTTP $statusCode';
      }

      switch (statusCode) {
        case 401:
          return Exception('OpenAI API key invalid: $message');
        case 429:
          return Exception('OpenAI API rate limit exceeded: $message');
        case 500:
        case 502:
        case 503:
          return Exception('OpenAI API server error: $message');
        default:
          return Exception('OpenAI API error ($statusCode): $message');
      }
    } else {
      return Exception('Network error: ${e.message}');
    }
  }

  /// 测试API连接
  Future<bool> testConnection() async {
    try {
      await listModels();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 构建对话历史
  static List<OpenAIMessage> buildConversationHistory(
    List<Map<String, String>> messages,
  ) {
    return messages
        .map((m) => OpenAIMessage(
              role: m['role'] ?? 'user',
              content: m['content'] ?? '',
            ))
        .toList();
  }
}
