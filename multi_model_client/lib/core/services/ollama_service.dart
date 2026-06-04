/// Ollama 本地模型服务 - LLM Studio 本地推理模块
/// 
/// 功能：
/// - Ollama API 集成
/// - 本地大模型推理
/// - 流式响应处理
/// - 跨平台连接适配
/// 
/// 注意：默认使用跨平台 Ollama 连接地址：
/// - Android 模拟器/真机 → http://10.0.2.2:11434
/// - macOS / Windows / Linux / iOS → http://localhost:11434
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../platform/platform_utils.dart';

/// Ollama 本地模型服务
/// 提供与 Ollama API 的集成，支持本地大模型推理
class OllamaService {
  // Ollama 服务器地址
  final String baseUrl;
  final Dio _dio;
  static const String _tag = 'OllamaService';

  OllamaService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? PlatformUtils.getDefaultOllamaBaseUrl(),
       _dio = Dio(BaseOptions(
    baseUrl: baseUrl ?? PlatformUtils.getDefaultOllamaBaseUrl(),
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  /// 获取可用模型列表
  Future<List<OllamaModel>> listModels() async {
    try {
      final response = await _dio.get('/api/tags');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final models = data['models'] as List;
        return models.map((m) => OllamaModel.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('[$_tag] 获取模型列表失败: $e');
      return [];
    }
  }

  /// 生成文本（同步）- 使用标准 /api/chat 接口
  ///
  /// [model] 模型名称
  /// [prompt] 用户输入的纯文本 prompt（会自动包装为单条 user 消息）
  Future<OllamaResponse> generate({
    required String model,
    required String prompt,
    String? system,
    List<String>? images,
    int? seed,
    Map<String, dynamic>? options,
    int? numCtx,
    int? numKeep,
    int? numPredict,
    double? temperature,
    double? topP,
    int? topK,
    bool? stream,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'system': ?system,
          'images': ?images,
          'seed': ?seed,
          if (options != null && options.isNotEmpty) 'options': options,
          'num_ctx': ?numCtx,
          'num_keep': ?numKeep,
          'num_predict': ?numPredict,
          'temperature': ?temperature,
          'top_p': ?topP,
          'top_k': ?topK,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        return OllamaResponse.fromJson(response.data);
      }
      throw Exception('Generate failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ollama generate error: $e');
    }
  }

  /// 生成文本（流式）- 使用标准 /api/chat 接口
  Stream<String> generateStream({
    required String model,
    required String prompt,
    String? system,
    List<String>? images,
    int? seed,
    Map<String, dynamic>? options,
    int? numCtx,
    int? numPredict,
    double? temperature,
    double? topP,
    int? topK,
  }) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        '/api/chat',
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'system': ?system,
          'images': ?images,
          'seed': ?seed,
          if (options != null && options.isNotEmpty) 'options': options,
          'num_ctx': ?numCtx,
          'num_predict': ?numPredict,
          'temperature': ?temperature,
          'top_p': ?topP,
          'top_k': ?topK,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      // Dio 流式响应需要通过 .stream 获取真正的 Stream
      final stream = response.data!.stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk, allowMalformed: true);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          if (lines[i].trim().isEmpty) continue;
          try {
            final data = jsonDecode(lines[i]) as Map<String, dynamic>;
            final response = OllamaResponse.fromJson(data);
            if (response.response != null) {
              yield response.response!;
            }
            if (response.done == true) {
              return;
            }
          } catch (_) {
            // Skip invalid JSON
          }
        }
      }
    } catch (e) {
      throw Exception('Ollama stream error: $e');
    }
  }

  /// 聊天（同步）
  Future<OllamaChatResponse> chat({
    required String model,
    required List<OllamaMessage> messages,
    String? system,
    int? seed,
    int? numCtx,
    int? numPredict,
    double? temperature,
    double? topP,
    int? topK,
    bool? stream,
  }) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'system': ?system,
          'seed': ?seed,
          'num_ctx': ?numCtx,
          'num_predict': ?numPredict,
          'temperature': ?temperature,
          'top_p': ?topP,
          'top_k': ?topK,
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        return OllamaChatResponse.fromJson(response.data);
      }
      throw Exception('Chat failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('Ollama chat error: $e');
    }
  }

  /// 聊天（流式）
  Stream<String> chatStream({
    required String model,
    required List<OllamaMessage> messages,
    String? system,
    int? seed,
    int? numCtx,
    int? numPredict,
    double? temperature,
    double? topP,
    int? topK,
  }) async* {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'system': ?system,
          'seed': ?seed,
          'num_ctx': ?numCtx,
          'num_predict': ?numPredict,
          'temperature': ?temperature,
          'top_p': ?topP,
          'top_k': ?topK,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      // 修复：response.data 是 ResponseBody，需要用 .stream 获取真正的流
      final responseBody = response.data;
      if (responseBody == null) {
        throw Exception('Ollama response data is null');
      }
      final stream = responseBody.stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          if (lines[i].isNotEmpty) {
            try {
              final data = jsonDecode(lines[i]) as Map<String, dynamic>;
              final message = data['message'] as Map<String, dynamic>?;
              if (message != null && message['content'] != null) {
                yield message['content'] as String;
              }
              if (data['done'] == true) {
                return;
              }
            } catch (e) {
              debugPrint('[ollama_service] Error: $e');
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Ollama chat stream error: $e');
    }
  }

  /// 检查 Ollama 服务是否运行中
  Future<bool> isRunning() async {
    try {
      final response = await _dio.get('/api/tags');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 获取模型信息
  Future<OllamaModel?> getModelInfo(String modelName) async {
    try {
      final response = await _dio.post(
        '/api/show',
        data: {'name': modelName},
      );

      if (response.statusCode == 200) {
        return OllamaModel.fromShowJson(response.data, modelName);
      }
      return null;
    } catch (e) {
      debugPrint('[$_tag] 获取模型信息失败: $e');
      return null;
    }
  }

  /// 拉取模型
  Future<void> pullModel(String modelName, {Function(double)? onProgress}) async {
    try {
      final response = await _dio.post(
        '/api/pull',
        data: {'name': modelName, 'stream': false},
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          if (lines[i].isNotEmpty) {
            try {
              final data = jsonDecode(lines[i]) as Map<String, dynamic>;
              if (data['status'] != null) {
                // 可以在这里处理进度
                final completed = data['completed'] as int?;
                final total = data['total'] as int?;
                if (completed != null && total != null && total > 0) {
                  onProgress?.call(completed / total);
                }
              }
            } catch (e) {
              debugPrint('[ollama_service] Error: $e');
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to pull model: $e');
    }
  }
}

/// Ollama 模型信息
class OllamaModel {
  final String name;
  final String? modifiedAt;
  final int? size;
  final String? digest;

  OllamaModel({
    required this.name,
    this.modifiedAt,
    this.size,
    this.digest,
  });

  factory OllamaModel.fromJson(Map<String, dynamic> json) {
    return OllamaModel(
      name: json['name'] as String,
      modifiedAt: json['modified_at'] as String?,
      size: json['size'] as int?,
      digest: json['digest'] as String?,
    );
  }

  factory OllamaModel.fromShowJson(Map<String, dynamic> json, String name) {
    return OllamaModel(
      name: name,
      modifiedAt: null,
      size: json['size'] as int?,
      digest: null,
    );
  }
}

/// Ollama 消息
class OllamaMessage {
  final String role; // 'system', 'user', 'assistant'
  final String content;
  final List<String>? images;

  OllamaMessage({
    required this.role,
    required this.content,
    this.images,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        if (images != null) 'images': images,
      };
}

/// Ollama 生成响应
class OllamaResponse {
  final String? model;
  final String? response;
  final bool? done;
  final String? context;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;
  final int? evalCount;

  OllamaResponse({
    this.model,
    this.response,
    this.done,
    this.context,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.evalCount,
  });

  factory OllamaResponse.fromJson(Map<String, dynamic> json) {
    return OllamaResponse(
      model: json['model'] as String?,
      response: json['response'] as String?,
      done: json['done'] as bool?,
      context: json['context'] as String?,
      totalDuration: json['total_duration'] as int?,
      loadDuration: json['load_duration'] as int?,
      promptEvalCount: json['prompt_eval_count'] as int?,
      evalCount: json['eval_count'] as int?,
    );
  }
}

/// Ollama 聊天响应
class OllamaChatResponse {
  final String? model;
  final OllamaMessage? message;
  final bool? done;
  final int? totalDuration;
  final int? loadDuration;
  final int? promptEvalCount;
  final int? evalCount;

  OllamaChatResponse({
    this.model,
    this.message,
    this.done,
    this.totalDuration,
    this.loadDuration,
    this.promptEvalCount,
    this.evalCount,
  });

  factory OllamaChatResponse.fromJson(Map<String, dynamic> json) {
    final messageJson = json['message'] as Map<String, dynamic>?;
    return OllamaChatResponse(
      model: json['model'] as String?,
      message: messageJson != null
          ? OllamaMessage(
              role: messageJson['role'] as String? ?? 'assistant',
              content: messageJson['content'] as String? ?? '',
            )
          : null,
      done: json['done'] as bool?,
      totalDuration: json['total_duration'] as int?,
      loadDuration: json['load_duration'] as int?,
      promptEvalCount: json['prompt_eval_count'] as int?,
      evalCount: json['eval_count'] as int?,
    );
  }
}

// Riverpod Providers

// Ollama 服务 Provider
final ollamaServiceProvider = Provider<OllamaService>((ref) {
  return OllamaService();
});

// 可用模型列表 Provider
final availableOllamaModelsProvider = FutureProvider<List<OllamaModel>>((ref) async {
  final service = ref.watch(ollamaServiceProvider);
  return await service.listModels();
});

// Ollama 服务状态
final ollamaRunningProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(ollamaServiceProvider);
  return await service.isRunning();
});

// 选中的模型
final selectedOllamaModelProvider = StateProvider<String?>((ref) => null);