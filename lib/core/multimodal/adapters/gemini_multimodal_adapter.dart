// v0.43.0 实现 Google Gemini 多模态适配器
//
// 实现要点：
// 1. Gemini 原生多模态：parts 数组支持 text / inline_data / file_data
// 2. 图片以 inline_data 形式（base64 编码）
// 3. URL 形式：file_data {file_uri, mime_type}
// 4. 视频/音频：inline_data
// 5. 流式响应：StreamGenerateContent

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/multimodal_message.dart';
import 'multimodal_adapter.dart';

class GeminiMultimodalAdapter implements MultimodalAdapter {
  @override
  final LLMProvider provider = LLMProvider.gemini;

  final String apiKey;
  final String baseUrl;
  final Dio _dio;
  final String defaultModel;

  GeminiMultimodalAdapter({
    required this.apiKey,
    this.baseUrl = 'https://generativelanguage.googleapis.com/v1beta',
    this.defaultModel = 'gemini-1.5-flash',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  String get _modelsBase => '$baseUrl/models';

  @override
  Future<MultimodalResponse> chat({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    int? thinkingBudget,
  }) async {
    final m = model ?? defaultModel;
    final body = _buildBody(messages, temperature: temperature, maxTokens: maxTokens, thinkingBudget: thinkingBudget);

    try {
      final response = await _dio.post(
        '$_modelsBase/$m:generateContent?key=$apiKey',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
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
    final body = _buildBody(messages, temperature: temperature, maxTokens: maxTokens, thinkingBudget: thinkingBudget);

    try {
      final response = await _dio.post<ResponseBody>(
        '$_modelsBase/$m:streamGenerateContent?key=$apiKey&alt=sse',
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json', 'Accept': 'text/event-stream'},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      final lineStream = response.data!.stream
          .map((chunk) => utf8.decode(chunk))
          .transform(const LineSplitter());
      await for (final chunk in lineStream) {
        if (chunk.isEmpty || !chunk.startsWith('data:')) continue;
        final data = chunk.substring(5).trim();
        if (data.isEmpty || data == '[DONE]') continue;

        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final candidates = json['candidates'] as List<dynamic>?;
          if (candidates == null || candidates.isEmpty) continue;

          final content = (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>? ?? [];

          for (final part in parts) {
            final partMap = part as Map<String, dynamic>;
            final text = partMap['text'] as String?;
            if (text != null && text.isNotEmpty) {
              yield MultimodalStreamChunk(delta: text);
            }
          }
        } catch (e) {
          debugPrint('[GeminiStream] parse error: $e');
        }
      }
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  Map<String, dynamic> _buildBody(
    List<MultimodalMessage> messages, {
    double? temperature,
    int? maxTokens,
    int? thinkingBudget,
  }) {
    // Gemini 的 system instruction 独立字段
    final systemParts = <Map<String, dynamic>>[];
    final conversation = <Map<String, dynamic>>[];

    for (final msg in messages) {
      if (msg.role == 'system') {
        systemParts.add({'text': msg.text});
      } else {
        conversation.add(msg.toProviderJson(provider));
      }
    }

    final generationConfig = <String, dynamic>{};
    if (temperature != null) generationConfig['temperature'] = temperature;
    if (maxTokens != null) generationConfig['maxOutputTokens'] = maxTokens;
    if (thinkingBudget != null && thinkingBudget > 0) {
      generationConfig['thinkingConfig'] = {'thinkingBudget': thinkingBudget};
    }

    return {
      if (systemParts.isNotEmpty)
        'systemInstruction': {'parts': systemParts},
      'contents': conversation,
      if (generationConfig.isNotEmpty) 'generationConfig': generationConfig,
    };
  }

  MultimodalResponse _parseResponse(Map<String, dynamic> json, String model) {
    final candidates = json['candidates'] as List<dynamic>? ?? [];
    final textBuffer = StringBuffer();

    if (candidates.isNotEmpty) {
      final content = (candidates.first as Map<String, dynamic>)['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>? ?? [];
      for (final part in parts) {
        final text = (part as Map<String, dynamic>)['text'] as String?;
        if (text != null) textBuffer.write(text);
      }
    }

    final usage = json['usageMetadata'] as Map<String, dynamic>?;
    return MultimodalResponse(
      content: textBuffer.toString(),
      model: model,
      finishReason: candidates.isNotEmpty
          ? ((candidates.first as Map<String, dynamic>)['finishReason'] as String?)
          : null,
      usage: MultimodalUsage(
        inputTokens: usage?['promptTokenCount'] as int? ?? 0,
        outputTokens: usage?['candidatesTokenCount'] as int? ?? 0,
        thinkingTokens: usage?['thoughtsTokenCount'] as int?,
        imageTokens: usage?['imagesTokenCount'] as int?,
      ),
    );
  }

  Exception _wrapError(DioException e) {
    if (e.response != null) {
      return Exception('Gemini API error ${e.response!.statusCode}: ${e.response!.data}');
    }
    return Exception('Gemini network error: ${e.message}');
  }
}
