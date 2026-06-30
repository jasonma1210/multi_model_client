// v0.43.0 实现 多模态适配器统一接口
//
// 目标：
// 1. 抽象 OpenAI / Anthropic / Gemini / Ollama / llama.cpp 的多模态序列化差异
// 2. 提供流式 + 非流式两种调用方式
// 3. 支持 thinking budget 注入
// 4. 统一 usage 解析（含 vision tokens）

import 'dart:async';

import 'package:dio/dio.dart';

import '../domain/multimodal_message.dart';

/// 统一多模态 LLM 响应
class MultimodalResponse {
  final String content;
  final String? thinkingContent; // Extended Thinking 输出
  final MultimodalUsage usage;
  final String model;
  final String? finishReason;
  final List<MultimodalToolCall>? toolCalls;

  const MultimodalResponse({
    required this.content,
    required this.usage,
    required this.model,
    this.thinkingContent,
    this.finishReason,
    this.toolCalls,
  });
}

/// Token 用量（多模态版本）
class MultimodalUsage {
  final int inputTokens;
  final int outputTokens;
  final int? thinkingTokens; // Extended Thinking
  final int? imageTokens; // 视觉 token

  const MultimodalUsage({
    required this.inputTokens,
    required this.outputTokens,
    this.thinkingTokens,
    this.imageTokens,
  });

  int get totalTokens => inputTokens + outputTokens + (thinkingTokens ?? 0);
}

/// 工具调用
class MultimodalToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  const MultimodalToolCall({required this.id, required this.name, required this.arguments});
}

/// 流式响应 chunk
class MultimodalStreamChunk {
  final String delta; // 文本增量
  final String? thinkingDelta; // 思考增量
  final MultimodalUsage? usage; // 最后一个 chunk 才会有
  final String? finishReason;
  final MultimodalToolCall? toolCallDelta;

  const MultimodalStreamChunk({
    this.delta = '',
    this.thinkingDelta,
    this.usage,
    this.finishReason,
    this.toolCallDelta,
  });
}

/// 多模态适配器抽象接口
abstract class MultimodalAdapter {
  LLMProvider get provider;

  /// 非流式聊天
  Future<MultimodalResponse> chat({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    int? thinkingBudget,
  });

  /// 流式聊天
  Stream<MultimodalStreamChunk> chatStream({
    required List<MultimodalMessage> messages,
    String? model,
    int? maxTokens,
    double? temperature,
    int? thinkingBudget,
  });
}

/// 基础 HTTP 工具
class HttpChatClient {
  final Dio dio;
  HttpChatClient({Dio? dio}) : dio = dio ?? Dio();

  Future<Stream<List<int>>> postStream(
    String url, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    final response = await dio.post<ResponseBody>(
      url,
      data: body,
      options: Options(
        headers: {
          ...headers,
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
        responseType: ResponseType.stream,
      ),
    );
    return response.data!.stream;
  }

  Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    final response = await dio.post(url, data: body, options: Options(headers: headers));
    return response.data as Map<String, dynamic>;
  }
}
