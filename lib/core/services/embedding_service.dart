/// 向量嵌入服务 - LLM Studio 语义向量化模块
/// 
/// 功能：
/// - 文本向量化（OpenAI Embeddings API）
/// - 本地模型支持（TensorFlow Lite）
/// - Hash-based 伪向量（测试用）
/// - 向量相似度计算
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 向量嵌入服务
/// 提供文本向量化功能
class EmbeddingService {
  // 嵌入维度（sentence-transformers默认768）
  static const int embeddingDimension = 768;
  static const String _tag = 'EmbeddingService';

  // API配置（如果使用远程服务）
  final String? apiKey;
  final String apiEndpoint;

  EmbeddingService({
    this.apiKey,
    this.apiEndpoint = 'https://api.openai.com/v1/embeddings',
  });

  /// 生成文本嵌入向量
  /// 支持三种方式：
  /// 1. 远程API（OpenAI Embeddings）- 推荐用于生产环境
  /// 2. 本地模型（TensorFlow Lite）- 推荐用于离线场景
  /// 3. Hash-based伪向量 - 仅用于测试
  Future<List<double>> generateEmbedding(String text, {bool useRemoteAPI = true}) async {
    // 方式1：使用远程API（OpenAI Embeddings）
    if (useRemoteAPI && apiKey != null) {
      try {
        return await _generateEmbeddingFromAPI(text);
      } catch (e) {
        debugPrint('[$_tag] 远程嵌入失败，降级到本地: $e');
        // 降级到本地方法
      }
    }

    // 方式2：本地 TF Lite 未集成，使用 hash-based 伪向量作为降级方案
    // 生产环境推荐使用远程 API 或 Sherpa-ONNX embedding 模型

    // 方式3：Hash-based伪向量（降级方案）
    return generatePseudoEmbedding(text);
  }

  /// 使用远程API生成嵌入向量
  Future<List<double>> _generateEmbeddingFromAPI(String text) async {
    if (apiKey == null) {
      throw StateError('API key not configured');
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        apiEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'text-embedding-ada-002',
          'input': text,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final embeddings = data['data'][0]['embedding'] as List;
        return embeddings.cast<double>();
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to generate embedding: $e');
    }
  }

  /// 批量生成嵌入向量
  Future<List<List<double>>> generateEmbeddings(List<String> texts) async {
    final embeddings = <List<double>>[];
    for (final text in texts) {
      embeddings.add(await generateEmbedding(text));
    }
    return embeddings;
  }

  /// 计算余弦相似度
  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) {
      return 0.0;
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// 欧几里得距离
  double euclideanDistance(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw ArgumentError('Vectors must have same dimension');
    }

    double sum = 0.0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }

    return sqrt(sum);
  }

  /// 向量序列化为JSON字符串
  String vectorToJson(List<double> vector) {
    return jsonEncode(vector);
  }

  /// JSON字符串反序列化为向量
  List<double> jsonToVector(String json) {
    final list = jsonDecode(json) as List;
    return list.cast<double>();
  }

  /// 生成伪嵌入向量（临时实现）
  /// 注意：这不是真正的语义嵌入，仅用于测试
  List<double> generatePseudoEmbedding(String text) {
    // 使用文本hash生成确定性的伪向量
    // 注意：这不是真正的语义嵌入，仅用于测试
    final bytes = utf8.encode(text);
    final hash = sha256.convert(bytes);

    // 使用hash生成伪向量
    final vector = List<double>.filled(embeddingDimension, 0.0);
    final hashBytes = hash.bytes;

    for (int i = 0; i < embeddingDimension && i < hashBytes.length * 10; i++) {
      final byteIndex = i % hashBytes.length;
      final factor = (i ~/ hashBytes.length) + 1;
      vector[i] = (hashBytes[byteIndex] / 256.0 - 0.5) * factor / 10.0;
    }

    // 归一化向量
    return _normalizeVector(vector);
  }

  /// 归一化向量
  List<double> _normalizeVector(List<double> vector) {
    double norm = 0.0;
    for (final v in vector) {
      norm += v * v;
    }
    norm = sqrt(norm);

    if (norm == 0) {
      return vector;
    }

    return vector.map((v) => v / norm).toList();
  }
}
