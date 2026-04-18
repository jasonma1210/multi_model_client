import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'hardware_compatibility_checker.dart';

/// 模型来源
enum ModelSource {
  huggingFace,
  modelScope,
  local,
}

/// 模型信息
class ModelInfo {
  final String id;
  final String name;
  final String description;
  final String author;
  final int downloads;
  final int likes;
  final List<String> tags;
  final String? license;
  final int parameterSize; // 参数量（亿）
  final int contextLength; // 上下文长度
  final ModelSource source;
  final String downloadUrl;
  final String? readmeUrl;
  final List<String> requiredFeatures; // 需要的硬件特性
  final int minRamGB; // 最小内存需求（GB）
  final int minStorageGB; // 最小存储需求（GB）
  final bool isQuantized; // 是否量化
  final String? quantizationMethod; // 量化方法（GGUF, GPTQ等）

  ModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    this.downloads = 0,
    this.likes = 0,
    this.tags = const [],
    this.license,
    this.parameterSize = 0,
    this.contextLength = 2048,
    required this.source,
    required this.downloadUrl,
    this.readmeUrl,
    this.requiredFeatures = const [],
    this.minRamGB = 4,
    this.minStorageGB = 2,
    this.isQuantized = false,
    this.quantizationMethod,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json, ModelSource source) {
    switch (source) {
      case ModelSource.huggingFace:
        return ModelInfo.fromHuggingFace(json);
      case ModelSource.modelScope:
        return ModelInfo.fromModelScope(json);
      case ModelSource.local:
        return ModelInfo.fromLocal(json);
    }
  }

  factory ModelInfo.fromHuggingFace(Map<String, dynamic> json) {
    final modelId = json['id'] as String? ?? json['modelId'] as String? ?? '';
    final tags = (json['tags'] as List<dynamic>?)?.cast<String>() ?? [];

    // 解析参数量
    int parameterSize = 0;
    final tagStr = tags.join(' ').toLowerCase();
    if (tagStr.contains('7b')) parameterSize = 7;
    if (tagStr.contains('13b')) parameterSize = 13;
    if (tagStr.contains('70b')) parameterSize = 70;

    // 解析量化信息
    bool isQuantized = false;
    String? quantizationMethod;
    if (tagStr.contains('gguf')) {
      isQuantized = true;
      quantizationMethod = 'GGUF';
    } else if (tagStr.contains('gptq')) {
      isQuantized = true;
      quantizationMethod = 'GPTQ';
    }

    return ModelInfo(
      id: modelId,
      name: json['modelId'] as String? ?? modelId,
      description: json['description'] as String? ?? '',
      author: json['author'] as String? ?? '',
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      tags: tags,
      license: json['license'] as String?,
      parameterSize: parameterSize,
      contextLength: 4096, // 默认上下文长度
      source: ModelSource.huggingFace,
      downloadUrl: 'https://huggingface.co/$modelId/resolve/main/model.gguf',
      readmeUrl: 'https://huggingface.co/$modelId/blob/main/README.md',
      requiredFeatures: _parseRequiredFeatures(tags),
      minRamGB: _estimateMinRam(parameterSize, isQuantized),
      minStorageGB: _estimateMinStorage(parameterSize, isQuantized),
      isQuantized: isQuantized,
      quantizationMethod: quantizationMethod,
    );
  }

  factory ModelInfo.fromModelScope(Map<String, dynamic> json) {
    final modelId = json['id'] as String? ?? json['model_id'] as String? ?? '';
    final name = json['name'] as String? ?? json['model_name'] as String? ?? modelId;

    // 解析参数量
    int parameterSize = 0;
    final nameLower = name.toLowerCase();
    if (nameLower.contains('7b')) parameterSize = 7;
    if (nameLower.contains('13b')) parameterSize = 13;
    if (nameLower.contains('70b')) parameterSize = 70;

    return ModelInfo(
      id: modelId,
      name: name,
      description: json['description'] as String? ?? json['summary'] as String? ?? '',
      author: json['author'] as String? ?? json['owner'] as String? ?? '',
      downloads: json['downloads'] as int? ?? json['download_count'] as int? ?? 0,
      likes: json['likes'] as int? ?? json['stars'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      license: json['license'] as String?,
      parameterSize: parameterSize,
      contextLength: 4096,
      source: ModelSource.modelScope,
      downloadUrl: 'https://modelscope.cn/models/$modelId/resolve/master/model.gguf',
      readmeUrl: 'https://modelscope.cn/models/$modelId/files/master/README.md',
      requiredFeatures: _parseRequiredFeatures(
        (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      ),
      minRamGB: _estimateMinRam(parameterSize, false),
      minStorageGB: _estimateMinStorage(parameterSize, false),
      isQuantized: false,
    );
  }

  factory ModelInfo.fromLocal(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      author: json['author'] as String? ?? '',
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      license: json['license'] as String?,
      parameterSize: json['parameterSize'] as int? ?? 0,
      contextLength: json['contextLength'] as int? ?? 2048,
      source: ModelSource.local,
      downloadUrl: json['downloadUrl'] as String,
      readmeUrl: json['readmeUrl'] as String?,
      requiredFeatures: (json['requiredFeatures'] as List<dynamic>?)?.cast<String>() ?? [],
      minRamGB: json['minRamGB'] as int? ?? 4,
      minStorageGB: json['minStorageGB'] as int? ?? 2,
      isQuantized: json['isQuantized'] as bool? ?? false,
      quantizationMethod: json['quantizationMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'downloads': downloads,
      'likes': likes,
      'tags': tags,
      'license': license,
      'parameterSize': parameterSize,
      'contextLength': contextLength,
      'source': source.name,
      'downloadUrl': downloadUrl,
      'readmeUrl': readmeUrl,
      'requiredFeatures': requiredFeatures,
      'minRamGB': minRamGB,
      'minStorageGB': minStorageGB,
      'isQuantized': isQuantized,
      'quantizationMethod': quantizationMethod,
    };
  }

  static List<String> _parseRequiredFeatures(List<String> tags) {
    final features = <String>[];
    final tagStr = tags.join(' ').toLowerCase();

    if (tagStr.contains('gpu') || tagStr.contains('cuda')) {
      features.add('gpu');
    }
    if (tagStr.contains('metal')) {
      features.add('metal');
    }
    if (tagStr.contains('vulkan')) {
      features.add('vulkan');
    }
    if (tagStr.contains('neon')) {
      features.add('neon');
    }

    return features;
  }

  static int _estimateMinRam(int parameterSize, bool isQuantized) {
    // 估算最小内存需求
    // 非量化模型：参数量 * 2 bytes（FP16）
    // 量化模型：参数量 * 0.5-1 byte（4-8 bit量化）
    if (parameterSize == 0) return 4;

    if (isQuantized) {
      return (parameterSize * 0.8).round(); // 4-5 bit量化
    } else {
      return (parameterSize * 2).round();
    }
  }

  static int _estimateMinStorage(int parameterSize, bool isQuantized) {
    // 估算最小存储需求
    if (parameterSize == 0) return 2;

    if (isQuantized) {
      return (parameterSize * 0.7).round();
    } else {
      return parameterSize;
    }
  }
}

/// 模型下载进度
class DownloadProgress {
  final String modelId;
  final int totalBytes;
  final int downloadedBytes;
  final double progress; // 0.0 - 1.0
  final String status; // downloading, extracting, completed, error
  final String? error;

  DownloadProgress({
    required this.modelId,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.progress,
    required this.status,
    this.error,
  });

  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';

  String get downloadedMB => '${(downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB';

  String get totalMB => '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

/// 模型下载管理器
class ModelDownloadManager {
  final Dio _dio;
  final HardwareCompatibilityChecker _hardwareChecker;
  final String _downloadDir;

  final Map<String, CancelToken> _downloadTokens = {};
  final ValueNotifier<Map<String, DownloadProgress>> progressNotifier = ValueNotifier({});

  ModelDownloadManager({
    required Dio dio,
    required HardwareCompatibilityChecker hardwareChecker,
    required String downloadDir,
  })  : _dio = dio,
        _hardwareChecker = hardwareChecker,
        _downloadDir = downloadDir;

  /// 搜索Hugging Face模型
  Future<List<ModelInfo>> searchHuggingFace(
    String query, {
    int limit = 20,
    String? filter,
  }) async {
    try {
      final response = await _dio.get(
        'https://huggingface.co/api/models',
        queryParameters: {
          'search': query,
          'limit': limit,
          if (filter != null) 'filter': filter,
        },
      );

      final models = (response.data as List<dynamic>)
          .map((json) => ModelInfo.fromJson(json, ModelSource.huggingFace))
          .toList();

      return models;
    } catch (e) {
      debugPrint('Error searching Hugging Face: $e');
      return [];
    }
  }

  /// 搜索魔搭社区模型
  Future<List<ModelInfo>> searchModelScope(
    String query, {
    int limit = 20,
    String? filter,
  }) async {
    try {
      final response = await _dio.get(
        'https://modelscope.cn/api/v1/models',
        queryParameters: {
          'name': query,
          'PageSize': limit,
          if (filter != null) 'filter': filter,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final models = (data['Data']?['Models'] as List<dynamic>?)
              ?.map((json) => ModelInfo.fromJson(json, ModelSource.modelScope))
              .toList() ??
          [];

      return models;
    } catch (e) {
      debugPrint('Error searching ModelScope: $e');
      return [];
    }
  }

  /// 获取模型详情（Hugging Face）
  Future<ModelInfo?> getHuggingFaceModel(String modelId) async {
    try {
      final response = await _dio.get(
        'https://huggingface.co/api/models/$modelId',
      );

      return ModelInfo.fromJson(response.data, ModelSource.huggingFace);
    } catch (e) {
      debugPrint('Error getting Hugging Face model: $e');
      return null;
    }
  }

  /// 获取模型详情（魔搭社区）
  Future<ModelInfo?> getModelScopeModel(String modelId) async {
    try {
      final response = await _dio.get(
        'https://modelscope.cn/api/v1/models/$modelId',
      );

      final data = response.data as Map<String, dynamic>;
      return ModelInfo.fromJson(data['Data'], ModelSource.modelScope);
    } catch (e) {
      debugPrint('Error getting ModelScope model: $e');
      return null;
    }
  }

  /// 检查模型兼容性
  Future<CompatibilityResult> checkCompatibility(ModelInfo model) async {
    return await _hardwareChecker.checkModelCompatibility(
      minRamGB: model.minRamGB,
      minStorageGB: model.minStorageGB,
      requiredFeatures: model.requiredFeatures,
    );
  }

  /// 下载模型
  Future<bool> downloadModel(
    ModelInfo model, {
    Function(DownloadProgress)? onProgress,
  }) async {
    try {
      // 检查兼容性
      final compatibility = await checkCompatibility(model);
      if (!compatibility.isCompatible) {
        debugPrint('Model not compatible: ${compatibility.reasons.join(", ")}');
        return false;
      }

      // 检查存储空间
      final hasSpace = await _hardwareChecker.hasEnoughStorage(model.minStorageGB);
      if (!hasSpace) {
        debugPrint('Not enough storage space');
        return false;
      }

      // 创建下载目录
      final modelDir = '$_downloadDir/${model.id.replaceAll('/', '_')}';
      final modelFile = '$modelDir/model.gguf';
      await Directory(modelDir).create(recursive: true);

      // 创建取消令牌
      final cancelToken = CancelToken();
      _downloadTokens[model.id] = cancelToken;

      // 初始化进度
      final initialProgress = DownloadProgress(
        modelId: model.id,
        totalBytes: 0,
        downloadedBytes: 0,
        progress: 0,
        status: 'downloading',
      );
      // 不可变更新：创建新 Map 触发 ValueNotifier 通知
      progressNotifier.value = {
        ...progressNotifier.value,
        model.id: initialProgress,
      };

      // 执行下载
      await _dio.download(
        model.downloadUrl,
        modelFile,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final progress = DownloadProgress(
            modelId: model.id,
            totalBytes: total,
            downloadedBytes: received,
            progress: total > 0 ? received / total : 0,
            status: 'downloading',
          );

          progressNotifier.value = {
            ...progressNotifier.value,
            model.id: progress,
          };

          if (onProgress != null) {
            onProgress(progress);
          }
        },
      );

      // 更新状态为完成
      final completedProgress = DownloadProgress(
        modelId: model.id,
        totalBytes: File(modelFile).lengthSync(),
        downloadedBytes: File(modelFile).lengthSync(),
        progress: 1.0,
        status: 'completed',
      );
      progressNotifier.value = {
        ...progressNotifier.value,
        model.id: completedProgress,
      };

      // 清理取消令牌
      _downloadTokens.remove(model.id);

      return true;
    } catch (e) {
      debugPrint('Error downloading model: $e');

      // 更新状态为错误
      final errorProgress = DownloadProgress(
        modelId: model.id,
        totalBytes: 0,
        downloadedBytes: 0,
        progress: 0,
        status: 'error',
        error: e.toString(),
      );
      progressNotifier.value = {
        ...progressNotifier.value,
        model.id: errorProgress,
      };

      return false;
    }
  }

  /// 取消下载
  void cancelDownload(String modelId) {
    final token = _downloadTokens[modelId];
    if (token != null) {
      token.cancel('User cancelled download');
      _downloadTokens.remove(modelId);

      // 用不可变 Map 移除条目，触发 ValueNotifier 通知
      final updated = Map<String, DownloadProgress>.from(progressNotifier.value);
      updated.remove(modelId);
      progressNotifier.value = updated;
    }
  }

  /// 获取下载进度
  DownloadProgress? getDownloadProgress(String modelId) {
    return progressNotifier.value[modelId];
  }

  /// 获取所有下载中的模型
  List<String> getDownloadingModels() {
    return progressNotifier.value.keys
        .where((id) => progressNotifier.value[id]?.status == 'downloading')
        .toList();
  }

  /// 删除已下载的模型
  Future<bool> deleteModel(String modelId) async {
    try {
      final modelDir = '$_downloadDir/${modelId.replaceAll('/', '_')}';
      final dir = Directory(modelDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      return true;
    } catch (e) {
      debugPrint('Error deleting model: $e');
      return false;
    }
  }

  /// 获取已下载的模型列表
  Future<List<ModelInfo>> getDownloadedModels() async {
    try {
      final dir = Directory(_downloadDir);
      if (!await dir.exists()) {
        return [];
      }

      final models = <ModelInfo>[];
      await for (final entity in dir.list()) {
        if (entity is Directory) {
          final modelFile = File('${entity.path}/model.gguf');
          if (await modelFile.exists()) {
            final modelName = entity.path.split('/').last.replaceAll('_', '/');

            // 创建本地模型信息
            models.add(ModelInfo(
              id: modelName,
              name: modelName,
              description: 'Downloaded model',
              author: 'Local',
              source: ModelSource.local,
              downloadUrl: modelFile.path,
              minRamGB: 4,
              minStorageGB: 2,
            ));
          }
        }
      }

      return models;
    } catch (e) {
      debugPrint('Error getting downloaded models: $e');
      return [];
    }
  }

  /// 释放资源
  void dispose() {
    for (final token in _downloadTokens.values) {
      token.cancel('Manager disposed');
    }
    _downloadTokens.clear();
  }
}
