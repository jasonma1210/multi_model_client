import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model_download_manager.dart';
import 'modelscope_api.dart' show ModelFile;

/// HuggingFace API客户端（重构版）
/// 
/// 🔧 强制使用 hf-mirror.com 镜像，解决国内访问问题
/// 功能：
/// - 搜索模型
/// - 获取模型详情
/// - 获取模型文件列表
/// - 获取热门模型推荐（从 API 动态获取）
/// - 生成下载链接
class HuggingFaceApi {
  final Dio _dio;
  static const String _tag = 'HuggingFaceApi';

  /// 🔧 强制使用 hf-mirror.com 镜像
  static const String _mirrorBaseUrl = 'https://hf-mirror.com';
  static const String _apiBaseUrl = 'https://hf-mirror.com/api';

  HuggingFaceApi(this._dio);

  /// 搜索模型
  /// [query] 搜索关键词
  /// [limit] 返回结果数量
  /// [filter] 过滤条件（如 "gguf"）
  /// [author] 作者名
  /// [sortBy] 排序方式（"downloads" 按下载量，"likes" 按点赞，"newest" 最新）
  Future<List<ModelInfo>> searchModels({
    required String query,
    int limit = 20,
    String? filter,
    String? author,
    String? sortBy,
  }) async {
    try {
      final url = '$_apiBaseUrl/models';

      final response = await _dio.get(
        url,
        queryParameters: {
          'search': query,
          'limit': limit,
          'filter': ?filter,
          'author': ?author,
          'sort': ?sortBy,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final models = response.data as List<dynamic>;
      return models
          .map((m) => ModelInfo.fromHuggingFace(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取模型详情
  Future<ModelInfo?> getModel(String modelId) async {
    try {
      final url = '$_apiBaseUrl/models/$modelId';
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      return ModelInfo.fromHuggingFace(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  /// 获取模型文件列表
  Future<List<ModelFile>> getModelFiles(String modelId, {String revision = 'main'}) async {
    try {
      final url = '$_apiBaseUrl/models/$modelId/tree/$revision';
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final files = response.data as List<dynamic>;
      return files
          .map((f) => ModelFile.fromJson(f as Map<String, dynamic>, ModelSource.huggingFace))
          .toList();
    } on DioException catch (e) {
      debugPrint('[$_tag] 获取文件列表失败: $e');
      return [];
    }
  }

  /// 获取下载链接
  /// 
  /// 🔧 强制使用 hf-mirror.com 镜像
  String getDownloadUrl(String modelId, String filePath, {String revision = 'main'}) {
    return '$_mirrorBaseUrl/$modelId/resolve/$revision/$filePath';
  }

  /// 获取模型README
  Future<String?> getModelReadme(String modelId, {String revision = 'main'}) async {
    try {
      final url = '$_mirrorBaseUrl/$modelId/raw/$revision/README.md';
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.plain,
        ),
      );
      return response.data as String;
    } on DioException catch (e) {
      debugPrint('[$_tag] 获取README失败: $e');
      return null;
    }
  }

  /// 获取热门 GGUF 模型（从 API 动态获取，按下载量排序）
  /// 
  /// 不再使用硬编码，改为从 hf-mirror.com API 获取热门模型
  Future<List<FeaturedModel>> getFeaturedModels() async {
    try {
      // 从 API 获取热门 GGUF 模型
      final results = await searchModels(
        query: 'gguf',
        limit: 30,
        filter: 'gguf',
      );

      // 按下载量排序，取前 15 个
      final sorted = results.toList()
        ..sort((a, b) => b.downloads.compareTo(a.downloads));
      final topModels = sorted.take(15).toList();

      // 转换为 FeaturedModel 格式
      return topModels.map((model) => FeaturedModel(
        id: model.id,
        name: model.name,
        author: model.author,
        description: model.description.isNotEmpty 
            ? model.description 
            : '热门 GGUF 量化模型',
        params: model.parameterSize > 0 ? '${model.parameterSize}B' : '未知',
        quantLevels: model.quantizationMethod != null 
            ? [model.quantizationMethod!] 
            : ['GGUF'],
        minRam: model.minRamGB > 0 ? model.minRamGB : 4,
        minStorage: model.minStorageGB > 0 ? model.minStorageGB : 4,
        contextLength: 8192,
        isMultimodal: model.isMultimodal,
        mmprojFile: model.mmprojPath,
        tags: _extractTags(model),
      )).toList();
    } catch (e) {
      debugPrint('[$_tag] 获取热门模型失败: $e');
      return [];
    }
  }

  /// 从 ModelInfo 提取标签
  List<String> _extractTags(ModelInfo model) {
    final tags = <String>[];
    final name = model.name.toLowerCase();
    final author = model.author.toLowerCase();

    // 根据模型名称提取标签
    if (name.contains('qwen') || name.contains('glm') || name.contains('yi') || author.contains('qwen') || author.contains('01.ai')) {
      tags.add('中文');
    }
    if (name.contains('code') || name.contains('coder')) {
      tags.add('编程');
    }
    if (name.contains('math') || name.contains('reasoning') || name.contains('r1')) {
      tags.add('推理');
    }
    if (name.contains('vision') || name.contains('vl') || name.contains('llava') || model.isMultimodal) {
      tags.add('多模态');
    }
    if (model.parameterSize > 0 && model.parameterSize <= 3) {
      tags.add('轻量');
    } else if (model.parameterSize >= 14) {
      tags.add('高性能');
    }

    // 添加下载量标签
    if (model.downloads > 100000) {
      tags.add('热门');
    }

    return tags.isEmpty ? ['对话'] : tags;
  }

  /// 错误处理
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return Exception('网络连接失败，请检查网络设置');
      case DioExceptionType.connectionTimeout:
        return Exception('连接超时，请重试');
      case DioExceptionType.receiveTimeout:
        return Exception('响应超时，请重试');
      default:
        return Exception('请求失败: ${e.message}');
    }
  }
}

/// 热门模型信息
class FeaturedModel {
  final String id;
  final String name;
  final String author;
  final String description;
  final String params;
  final List<String> quantLevels;
  final int minRam;
  final int minStorage;
  final int contextLength;
  final bool isMultimodal;
  final String? mmprojFile;
  final List<String> tags;

  const FeaturedModel({
    required this.id,
    required this.name,
    required this.author,
    required this.description,
    required this.params,
    required this.quantLevels,
    required this.minRam,
    required this.minStorage,
    required this.contextLength,
    required this.isMultimodal,
    this.mmprojFile,
    required this.tags,
  });
}