import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Anthropic API配置
class AnthropicConfig {
  final String apiKey;
  final String baseUrl;
  final String model;
  final int maxTokens;
  final double? temperature;
  final double? topP;
  final int? topK;
  final List<String>? stopSequences;
  final bool stream;

  AnthropicConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.anthropic.com/v1',
    this.model = 'claude-3-5-sonnet-20241022',
    this.maxTokens = 4096,
    this.temperature,
    this.topP,
    this.topK,
    this.stopSequences,
    this.stream = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'max_tokens': maxTokens,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (topK != null) 'top_k': topK,
      if (stopSequences != null) 'stop_sequences': stopSequences,
      'stream': stream,
    };
  }
}

/// Anthropic消息
class AnthropicMessage {
  final String role;
  final String content;

  AnthropicMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory AnthropicMessage.fromJson(Map<String, dynamic> json) {
    return AnthropicMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }
}

/// Anthropic响应
class AnthropicResponse {
  final String id;
  final String type;
  final String role;
  final List<AnthropicContent> content;
  final String model;
  final AnthropicUsage usage;
  final String? stopReason;
  final String? stopSequence;

  AnthropicResponse({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.model,
    required this.usage,
    this.stopReason,
    this.stopSequence,
  });

  factory AnthropicResponse.fromJson(Map<String, dynamic> json) {
    return AnthropicResponse(
      id: json['id'] as String,
      type: json['type'] as String,
      role: json['role'] as String,
      content: (json['content'] as List<dynamic>)
          .map((c) => AnthropicContent.fromJson(c as Map<String, dynamic>))
          .toList(),
      model: json['model'] as String,
      usage: AnthropicUsage.fromJson(json['usage'] as Map<String, dynamic>),
      stopReason: json['stop_reason'] as String?,
      stopSequence: json['stop_sequence'] as String?,
    );
  }

  String get text {
    return content
        .where((c) => c.type == 'text')
        .map((c) => c.text ?? '')
        .join('\n');
  }
}

/// Anthropic内容
class AnthropicContent {
  final String type;
  final String? text;
  final String? thinking;

  AnthropicContent({
    required this.type,
    this.text,
    this.thinking,
  });

  factory AnthropicContent.fromJson(Map<String, dynamic> json) {
    return AnthropicContent(
      type: json['type'] as String,
      text: json['text'] as String?,
      thinking: json['thinking'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (text != null) 'text': text,
      if (thinking != null) 'thinking': thinking,
    };
  }
}

/// Anthropic使用量
class AnthropicUsage {
  final int inputTokens;
  final int outputTokens;

  AnthropicUsage({
    required this.inputTokens,
    required this.outputTokens,
  });

  factory AnthropicUsage.fromJson(Map<String, dynamic> json) {
    return AnthropicUsage(
      inputTokens: json['input_tokens'] as int,
      outputTokens: json['output_tokens'] as int,
    );
  }
}

/// Anthropic流式事件
class AnthropicStreamEvent {
  final String type;
  final int? index;
  final AnthropicContent? delta;
  final AnthropicUsage? usage;
  final String? stopReason;

  AnthropicStreamEvent({
    required this.type,
    this.index,
    this.delta,
    this.usage,
    this.stopReason,
  });

  factory AnthropicStreamEvent.fromJson(Map<String, dynamic> json) {
    return AnthropicStreamEvent(
      type: json['type'] as String,
      index: json['index'] as int?,
      delta: json['delta'] != null
          ? AnthropicContent.fromJson(json['delta'] as Map<String, dynamic>)
          : null,
      usage: json['usage'] != null
          ? AnthropicUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
      stopReason: json['stop_reason'] as String?,
    );
  }
}

/// Anthropic适配器
class AnthropicAdapter {
  final Dio _dio;
  AnthropicConfig _config;

  AnthropicAdapter({
    required AnthropicConfig config,
  })  : _config = config,
        _dio = Dio(BaseOptions(
          baseUrl: config.baseUrl,
          headers: {
            'x-api-key': config.apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ));

  /// 更新配置
  void updateConfig(AnthropicConfig config) {
    _config = config;
    _dio.options.baseUrl = config.baseUrl;
    _dio.options.headers['x-api-key'] = config.apiKey;
  }

  /// 获取当前配置
  AnthropicConfig get config => _config;

  /// 消息补全
  Future<AnthropicResponse> createMessage(
    List<AnthropicMessage> messages, {
    String? system,
    AnthropicConfig? overrideConfig,
  }) async {
    try {
      final effectiveConfig = overrideConfig ?? _config;

      final data = <String, dynamic>{
        ...effectiveConfig.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

      if (system != null) {
        data['system'] = system;
      }

      final response = await _dio.post(
        '/messages',
        data: data,
      );

      return AnthropicResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Anthropic API error: $e');
    }
  }

  /// 流式消息补全
  Stream<AnthropicStreamEvent> createMessageStream(
    List<AnthropicMessage> messages, {
    String? system,
    AnthropicConfig? overrideConfig,
  }) async* {
    try {
      final effectiveConfig = (overrideConfig ?? _config);
      final streamConfig = AnthropicConfig(
        apiKey: effectiveConfig.apiKey,
        baseUrl: effectiveConfig.baseUrl,
        model: effectiveConfig.model,
        maxTokens: effectiveConfig.maxTokens,
        temperature: effectiveConfig.temperature,
        topP: effectiveConfig.topP,
        topK: effectiveConfig.topK,
        stopSequences: effectiveConfig.stopSequences,
        stream: true,
      );

      final data = <String, dynamic>{
        ...streamConfig.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

      if (system != null) {
        data['system'] = system;
      }

      final response = await _dio.post(
        '/messages',
        data: data,
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
          if (line.isEmpty || !line.startsWith('data: ')) continue;

          try {
            final jsonStr = line.substring(6);
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            final event = AnthropicStreamEvent.fromJson(json);

            // 只返回内容增量事件
            if (event.type == 'content_block_delta' && event.delta != null) {
              yield event;
            } else if (event.type == 'message_stop') {
              break;
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
      throw Exception('Anthropic streaming error: $e');
    }
  }

  /// 计算Token数量（估算）
  int estimateTokens(String text) {
    // Claude使用类似GPT的tokenization
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
          return Exception('Anthropic API key invalid: $message');
        case 429:
          return Exception('Anthropic API rate limit exceeded: $message');
        case 500:
        case 502:
        case 503:
          return Exception('Anthropic API server error: $message');
        default:
          return Exception('Anthropic API error ($statusCode): $message');
      }
    } else {
      return Exception('Network error: ${e.message}');
    }
  }

  /// 测试API连接
  Future<bool> testConnection() async {
    try {
      await createMessage(
        [AnthropicMessage(role: 'user', content: 'test')],
        overrideConfig: AnthropicConfig(
          apiKey: _config.apiKey,
          baseUrl: _config.baseUrl,
          model: _config.model,
          maxTokens: 10,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 构建对话历史
  static List<AnthropicMessage> buildConversationHistory(
    List<Map<String, String>> messages,
  ) {
    return messages
        .map((m) => AnthropicMessage(
              role: m['role'] ?? 'user',
              content: m['content'] ?? '',
            ))
        .toList();
  }
}
