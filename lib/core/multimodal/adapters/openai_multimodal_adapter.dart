// v0.43.0 实现 OpenAI 多模态适配器
//
// v0.42.0 已有 OpenAIMessage 简单 content 字符串支持
// v0.43.0 升级：
// 1. 使用 MultimodalMessage 统一接口
// 2. content 数组支持 text / image_url / input_audio
// 3. Audio 格式：{type: input_audio, input_audio: {data, format}}
// 4. File 格式（v0.43.0 新增）：{type: file_url, file_url: {url}}

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/multimodal_message.dart';
import 'multimodal_adapter.dart';

class OpenAIMultimodalAdapter implements MultimodalAdapter {
  @override
  final LLMProvider provider = LLMProvider.openai;

  final String apiKey;
  final String baseUrl;
  final Dio _dio;
  final String defaultModel;

  OpenAIMultimodalAdapter({
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
    this.defaultModel = 'gpt-4o',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

  /// OpenAI 视觉模型白名单
  bool _isVisionModel(String model) {
    final id = model.toLowerCase();
    return id.contains('gpt-4o') ||
        id.contains('gpt-4-vision') ||
        id.contains('gpt-4-turbo') ||
        id.contains('gpt-5') ||
        id.contains('o1') ||
        id.contains('o3') ||
        id.contains('o4');
  }

  /// OpenAI reasoning 模型
  bool _isReasoningModel(String model) {
    final id = model.toLowerCase();
    return id.contains('o1') || id.contains('o3') || id.contains('o4') || id.contains('gpt-5');
  }

  @override
  Future<MultimodalResponse> chat({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    int? thinkingBudget,
  }) async {
    final m = model ?? defaultModel;
    final body = _buildBody(messages, m, temperature: temperature, maxTokens: maxTokens, thinkingBudget: thinkingBudget);

    try {
      final response = await _dio.post(
        '$baseUrl/chat/completions',
        data: body,
        options: Options(headers: _headers),
      );
      return _parseResponse(response.data as Map<String, dynamic>, m);
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  @override
  Stream<MultimodalStreamChunk> chatStream({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    int? thinkingBudget,
  }) async* {
    final m = model ?? defaultModel;
    final body = _buildBody(messages, m, temperature: temperature, maxTokens: maxTokens, thinkingBudget: thinkingBudget)..['stream'] = true;

    try {
      final response = await _dio.post<ResponseBody>(
        '$baseUrl/chat/completions',
        data: body,
        options: Options(
          headers: {..._headers, 'Accept': 'text/event-stream'},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      // SSE 流
      final lineStream = response.data!.stream
          .map((chunk) => utf8.decode(chunk))
          .transform(const LineSplitter());
      await for (final chunk in lineStream) {
        if (chunk.isEmpty || !chunk.startsWith('data:')) continue;
        final data = chunk.substring(5).trim();
        if (data == '[DONE]') break;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final delta = (choices.first as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;

          final content = delta?['content'] as String?;
          final reasoning = delta?['reasoning_content'] as String?;

          if ((content != null && content.isNotEmpty) || (reasoning != null && reasoning.isNotEmpty)) {
            yield MultimodalStreamChunk(
              delta: content ?? '',
              thinkingDelta: reasoning,
            );
          }
        } catch (e) {
          debugPrint('[OpenAIStream] parse error: $e');
        }
      }
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  Map<String, dynamic> _buildBody(
    List<MultimodalMessage> messages,
    String model, {
    double? temperature,
    int? maxTokens,
    int? thinkingBudget,
  }) {
    final convertedMessages = messages.map((m) => m.toProviderJson(provider)).toList();

    final body = <String, dynamic>{
      'model': model,
      'messages': convertedMessages,
    };

    // max_tokens vs max_completion_tokens
    if (maxTokens != null) {
      if (_isReasoningModel(model)) {
        body['max_completion_tokens'] = maxTokens;
      } else {
        body['max_tokens'] = maxTokens;
      }
    }

    if (temperature != null && !_isReasoningModel(model)) {
      body['temperature'] = temperature;
    }

    // v0.42.0 兼容：reasoning_effort
    if (_isReasoningModel(model) && thinkingBudget != null) {
      body['reasoning_effort'] = _budgetToEffort(thinkingBudget);
    }

    return body;
  }

  String _budgetToEffort(int budget) {
    if (budget < 5000) return 'low';
    if (budget < 20000) return 'medium';
    if (budget < 50000) return 'high';
    return 'xhigh';
  }

  MultimodalResponse _parseResponse(Map<String, dynamic> json, String model) {
    final choices = json['choices'] as List<dynamic>? ?? [];
    final choice = choices.isNotEmpty ? choices.first as Map<String, dynamic> : null;
    final message = choice?['message'] as Map<String, dynamic>?;
    final usage = json['usage'] as Map<String, dynamic>?;

    final toolCallsJson = message?['tool_calls'] as List<dynamic>?;
    List<MultimodalToolCall>? toolCalls;
    if (toolCallsJson != null && toolCallsJson.isNotEmpty) {
      toolCalls = toolCallsJson.map((tc) {
        final tcMap = tc as Map<String, dynamic>;
        final fn = tcMap['function'] as Map<String, dynamic>?;
        return MultimodalToolCall(
          id: tcMap['id'] as String,
          name: fn?['name'] as String? ?? '',
          arguments: jsonDecode(fn?['arguments'] as String? ?? '{}') as Map<String, dynamic>,
        );
      }).toList();
    }

    return MultimodalResponse(
      content: message?['content'] as String? ?? '',
      model: model,
      finishReason: choice?['finish_reason'] as String?,
      toolCalls: toolCalls,
      usage: MultimodalUsage(
        inputTokens: usage?['prompt_tokens'] as int? ?? 0,
        outputTokens: usage?['completion_tokens'] as int? ?? 0,
        thinkingTokens: usage?['reasoning_tokens'] as int?,
        imageTokens: usage?['image_tokens'] as int?,
      ),
    );
  }

  Exception _wrapError(DioException e) {
    if (e.response != null) {
      return Exception('OpenAI API error ${e.response!.statusCode}: ${e.response!.data}');
    }
    return Exception('OpenAI network error: ${e.message}');
  }
}
