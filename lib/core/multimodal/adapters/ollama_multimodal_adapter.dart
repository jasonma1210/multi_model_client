// v0.43.0 实现 Ollama vision 适配器
//
// Ollama 多模态格式：
// POST /api/chat
// {
//   "model": "llava",
//   "messages": [{
//     "role": "user",
//     "content": "What's in this image?",
//     "images": ["<base64_string>", ...]
//   }],
//   "stream": false
// }
//
// 注意：Ollama 的 images 字段是顶层，不在 content 内
// 视频/音频由 Ollama 部分模型支持，本适配器暂只处理图片

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/multimodal_message.dart';
import 'multimodal_adapter.dart';

class OllamaMultimodalAdapter implements MultimodalAdapter {
  @override
  final LLMProvider provider = LLMProvider.ollama;

  final String baseUrl;
  final Dio _dio;
  final String defaultModel;

  OllamaMultimodalAdapter({
    this.baseUrl = 'http://localhost:11434',
    this.defaultModel = 'llava',
    Dio? dio,
  }) : _dio = dio ?? Dio();

  @override
  Future<MultimodalResponse> chat({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    int? thinkingBudget,
  }) async {
    final m = model ?? defaultModel;
    final body = _buildBody(messages, m, temperature: temperature);

    try {
      final response = await _dio.post(
        '$baseUrl/api/chat',
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
    final body = _buildBody(messages, m, temperature: temperature)..['stream'] = true;

    try {
      final response = await _dio.post<ResponseBody>(
        '$baseUrl/api/chat',
        data: body,
        options: Options(
          headers: {'Content-Type': 'application/json', 'Accept': 'application/x-ndjson'},
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data!.stream;
      final lineStream = response.data!.stream
          .map((chunk) => utf8.decode(chunk))
          .transform(const LineSplitter());
      await for (final chunk in lineStream) {
        if (chunk.isEmpty) continue;
        try {
          final json = jsonDecode(chunk) as Map<String, dynamic>;
          final message = json['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          final done = json['done'] as bool? ?? false;
          if (content != null && content.isNotEmpty) {
            yield MultimodalStreamChunk(delta: content);
          }
          if (done) {
            final usage = MultimodalUsage(
              inputTokens: (json['prompt_eval_count'] as int?) ?? 0,
              outputTokens: (json['eval_count'] as int?) ?? 0,
            );
            yield MultimodalStreamChunk(usage: usage, finishReason: 'stop');
            break;
          }
        } catch (e) {
          debugPrint('[OllamaStream] parse error: $e');
        }
      }
    } on DioException catch (e) {
      throw _wrapError(e);
    }
  }

  /// Ollama 特殊格式：images 是顶层字段
  Map<String, dynamic> _buildBody(
    List<MultimodalMessage> messages,
    String model, {
    double? temperature,
  }) {
    final convertedMessages = <Map<String, dynamic>>[];
    for (final m in messages) {
      final images = m.images
          .map((img) => img.effectiveBase64)
          .where((b64) => b64 != null)
          .cast<String>()
          .toList();
      final result = <String, dynamic>{
        'role': m.role,
        'content': m.text,
      };
      if (images.isNotEmpty) result['images'] = images;
      convertedMessages.add(result);
    }

    return {
      'model': model,
      'messages': convertedMessages,
      'stream': false,
      if (temperature != null) 'options': {'temperature': temperature},
    };
  }

  MultimodalResponse _parseResponse(Map<String, dynamic> json, String model) {
    final message = json['message'] as Map<String, dynamic>?;
    return MultimodalResponse(
      content: message?['content'] as String? ?? '',
      model: model,
      finishReason: json['done'] == true ? 'stop' : null,
      usage: MultimodalUsage(
        inputTokens: (json['prompt_eval_count'] as int?) ?? 0,
        outputTokens: (json['eval_count'] as int?) ?? 0,
      ),
    );
  }

  Exception _wrapError(DioException e) {
    if (e.response != null) {
      return Exception('Ollama API error ${e.response!.statusCode}: ${e.response!.data}');
    }
    return Exception('Ollama network error: ${e.message}');
  }
}
