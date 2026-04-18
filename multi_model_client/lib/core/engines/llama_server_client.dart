/// llama-server HTTP 客户端 - LM Studio 架构
///
/// 通过 HTTP REST API 与本地 llama-server 通信
/// 支持流式响应（SSE）
///
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 聊天消息
class ChatMessage {
  final String role; // system, user, assistant
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// 流式响应块
class StreamChunk {
  final String? content;
  final String? role;
  final bool done;
  final String? error;

  StreamChunk({
    this.content,
    this.role,
    this.done = false,
    this.error,
  });

  factory StreamChunk.fromDelta(Map<String, dynamic> delta) {
    return StreamChunk(
      content: delta['content'] as String?,
      role: delta['role'] as String?,
    );
  }

  factory StreamChunk.done() => StreamChunk(done: true);
  factory StreamChunk.error(String msg) => StreamChunk(error: msg);
}

/// llama-server HTTP 客户端
class LlamaServerClient {
  final String baseUrl;
  final http.Client _client;

  LlamaServerClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 发送聊天请求（流式）
  Stream<StreamChunk> sendChatStream({
    required List<ChatMessage> messages,
    String? model,
    double temperature = 0.7,
    int maxTokens = -1,
  }) async* {
    final uri = Uri.parse('$baseUrl/v1/chat/completions');

    final body = {
      'model': model ?? 'default',
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': true,
      'temperature': temperature,
      if (maxTokens > 0) 'max_tokens': maxTokens,
    };

    debugPrint('[LlamaServerClient] 发送请求: ${jsonEncode(body)}');

    try {
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);

      final response = await _client.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        yield StreamChunk.error('请求失败: ${response.statusCode} - $errorBody');
        return;
      }

      // 解析 SSE 流
      final buffer = StringBuffer();
      
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer.write(chunk);
        final data = buffer.toString();

        // 按行分割 SSE 数据
        final lines = data.split('\n');
        
        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            
            if (jsonStr == '[DONE]') {
              yield StreamChunk.done();
              return;
            }

            try {
              final json = jsonDecode(jsonStr);
              final choices = json['choices'] as List?;
              
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] as Map<String, dynamic>?;
                
                if (delta != null) {
                  yield StreamChunk.fromDelta(delta);
                }
              }
            } catch (e) {
              debugPrint('[LlamaServerClient] 解析 SSE 失败: $e');
            }
          }
        }

        // 保留未完成的行
        if (lines.isNotEmpty) {
          final lastLine = lines.last;
          if (!lastLine.trim().isEmpty && !lastLine.startsWith('data: ')) {
            buffer.clear();
            buffer.write(lastLine);
          } else {
            buffer.clear();
          }
        }
      }
    } catch (e) {
      yield StreamChunk.error('网络错误: $e');
    }
  }

  /// 发送聊天请求（非流式）
  Future<String> sendChat({
    required List<ChatMessage> messages,
    String? model,
    double temperature = 0.7,
    int maxTokens = -1,
  }) async {
    final uri = Uri.parse('$baseUrl/v1/chat/completions');

    final body = {
      'model': model ?? 'default',
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': false,
      'temperature': temperature,
      if (maxTokens > 0) 'max_tokens': maxTokens,
    };

    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('请求失败: ${response.statusCode} - ${response.body}');
      }

      final json = jsonDecode(response.body);
      final choices = json['choices'] as List?;
      
      if (choices != null && choices.isNotEmpty) {
        return choices[0]['message']['content'] as String;
      }

      return '';
    } catch (e) {
      throw Exception('聊天失败: $e');
    }
  }

  /// 获取模型列表
  Future<List<String>> getModels() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/v1/models'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] as List?;
        
        if (data != null) {
          return data.map((m) => m['id'] as String).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('[LlamaServerClient] 获取模型列表失败: $e');
      return [];
    }
  }

  /// 获取服务器健康状态
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    _client.close();
  }
}