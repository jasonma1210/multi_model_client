// v0.43.0 实现 Anthropic 多模态适配器
//
// 实现要点：
// 1. content 数组支持 text / image / document 三种 block
// 2. base64 模式：{type: image, source: {type: base64, media_type, data}}
// 3. URL 模式：{type: image, source: {type: url, url}}
// 4. 解析 thinking + image token
// 5. Extended Thinking 兼容（v0.42.0 已支持）

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/multimodal_message.dart';
import 'multimodal_adapter.dart';

class AnthropicMultimodalAdapter implements MultimodalAdapter {
  @override
  final LLMProvider provider = LLMProvider.anthropic;

  final String apiKey;
  final String baseUrl;
  final Dio _dio;
  final String defaultModel;

  AnthropicMultimodalAdapter({
    required this.apiKey,
    this.baseUrl = 'https://api.anthropic.com/v1',
    this.defaultModel = 'claude-3-5-sonnet-20241022',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Map<String, String> get _headers => {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json',
      };

  /// 是否支持 Extended Thinking
  bool _supportsThinking(String model) {
    final id = model.toLowerCase();
    return id.contains('claude-4') || id.contains('claude-3-7') || id.contains('claude-3.7');
  }

  /// 是否支持 vision
  bool _supportsVision(String model) {
    final id = model.toLowerCase();
    return id.contains('claude-3') || id.contains('claude-4');
  }

  @override
  Future<MultimodalResponse> chat({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens = 4096,
    double? temperature,
    int? thinkingBudget,
  }) async {
    final m = model ?? defaultModel;

    // 提取 system prompt
    final systemParts = <String>[];
    final conversation = <Map<String, dynamic>>[];
    for (final msg in messages) {
      if (msg.role == 'system') {
        systemParts.add(msg.text);
      } else {
        conversation.add(msg.toProviderJson(provider));
      }
    }

    final body = <String, dynamic>{
      'model': m,
      'max_tokens': maxTokens ?? 4096,
      'messages': conversation,
      if (systemParts.isNotEmpty) 'system': systemParts.join('\n\n'),
      if (temperature != null) 'temperature': temperature,
      if (_supportsThinking(m) && thinkingBudget != null) ..._buildThinkingPayload(thinkingBudget),
    };

    try {
      final response = await _dio.post(
        '$baseUrl/messages',
        data: body,
        options: Options(headers: _headers),
      );
      return _parseResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  @override
  Stream<MultimodalStreamChunk> chatStream({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens = 4096,
    double? temperature,
    int? thinkingBudget,
  }) async* {
    final m = model ?? defaultModel;

    final systemParts = <String>[];
    final conversation = <Map<String, dynamic>>[];
    for (final msg in messages) {
      if (msg.role == 'system') {
        systemParts.add(msg.text);
      } else {
        conversation.add(msg.toProviderJson(provider));
      }
    }

    final body = <String, dynamic>{
      'model': m,
      'max_tokens': maxTokens ?? 4096,
      'messages': conversation,
      'stream': true,
      if (systemParts.isNotEmpty) 'system': systemParts.join('\n\n'),
      if (temperature != null) 'temperature': temperature,
      if (_supportsThinking(m) && thinkingBudget != null) ..._buildThinkingPayload(thinkingBudget),
    };

    try {
      final response = await _dio.post<ResponseBody>(
        '$baseUrl/messages',
        data: body,
        options: Options(
          headers: {..._headers, 'Accept': 'text/event-stream'},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      String buffer = '';
      MultimodalUsage? finalUsage;
      String? finishReason;

      final lineStream = stream
          .map((chunk) => utf8.decode(chunk))
          .transform(const LineSplitter());
      await for (final chunk in lineStream) {
        if (chunk.isEmpty || !chunk.startsWith('data:')) continue;
        final data = chunk.substring(5).trim();
        if (data == '[DONE]') break;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final type = json['type'] as String?;

          if (type == 'content_block_start' || type == 'content_block_delta') {
            final delta = json['delta'] as Map<String, dynamic>?;
            final deltaType = delta?['type'] as String?;

            if (deltaType == 'text_delta') {
              final text = delta?['text'];
              yield MultimodalStreamChunk(delta: text is String ? text : '');
            } else if (deltaType == 'thinking_delta') {
              final thinking = delta?['thinking'];
              yield MultimodalStreamChunk(thinkingDelta: thinking is String ? thinking : '');
            }
          } else if (type == 'message_delta') {
            final delta = json['delta'] as Map<String, dynamic>?;
            final stopReason = delta?['stop_reason'];
            if (stopReason is String) {
              finishReason = stopReason;
            }
          } else if (type == 'message_stop') {
            break;
          }
        } catch (e) {
          debugPrint('[AnthropicStream] parse error: $e, data: $data');
        }
      }

      yield MultimodalStreamChunk(usage: finalUsage, finishReason: finishReason);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  Map<String, dynamic> _buildThinkingPayload(int budget) {
    return {
      'thinking': {
        'type': 'enabled',
        'budget_tokens': budget,
      },
    };
  }

  MultimodalResponse _parseResponse(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>? ?? [];
    final textBuffer = StringBuffer();
    String? thinkingContent;
    final toolCalls = <MultimodalToolCall>[];

    for (final block in content) {
      final blockMap = block as Map<String, dynamic>;
      final type = blockMap['type'] as String?;
      if (type == 'text') {
        textBuffer.write(blockMap['text'] as String? ?? '');
      } else if (type == 'thinking') {
        thinkingContent = blockMap['thinking'] as String?;
      } else if (type == 'tool_use') {
        toolCalls.add(MultimodalToolCall(
          id: blockMap['id'] as String,
          name: blockMap['name'] as String,
          arguments: (blockMap['input'] as Map<String, dynamic>?) ?? const {},
        ));
      }
    }

    final usage = json['usage'] as Map<String, dynamic>?;
    return MultimodalResponse(
      content: textBuffer.toString(),
      thinkingContent: thinkingContent,
      model: json['model'] as String? ?? defaultModel,
      finishReason: json['stop_reason'] as String?,
      toolCalls: toolCalls.isEmpty ? null : toolCalls,
      usage: MultimodalUsage(
        inputTokens: usage?['input_tokens'] as int? ?? 0,
        outputTokens: usage?['output_tokens'] as int? ?? 0,
        thinkingTokens: usage?['thinking_tokens'] as int?,
        imageTokens: usage?['image_tokens'] as int?,
      ),
    );
  }

  Exception _wrapError(DioException e) {
    if (e.response != null) {
      return Exception('Anthropic API error ${e.response!.statusCode}: ${e.response!.data}');
    }
    return Exception('Anthropic network error: ${e.message}');
  }
}
