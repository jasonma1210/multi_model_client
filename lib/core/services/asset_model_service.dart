/// 按需下载资源服务 - LLM Studio 模型管理模块
/// 
/// 功能：
/// - 按需下载 ASR/TTS/OCR 模型（首次使用时提示下载）
/// - 模型下载管理（断点续传、进度追踪）
/// - 模型版本控制
/// - 支持多平台（iOS/Android/macOS/Windows）
/// 
/// 按需下载策略：
/// - 用户首次使用某个功能时（如上传音频），检测模型是否存在
/// - 如果模型不存在，弹出提示让用户确认下载
/// - 下载完成后，以后的使用全是纯离线
/// 
/// 优化目标：
/// - 基础安装包 ~25MB（只含 Flutter UI、SQLite、llama.cpp 桥接）
/// - 模型按需下载，不打包在 App 中
/// - 符合 App Store / Google Play 上架规范
/// 
/// @author Jianma
/// @version 2.0.0
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 资源类型
enum ResourceType {
  asrModel,  // ASR 语音识别模型（Whisper/Sherpa-ONNX）
  ttsModel,  // TTS 语音合成模型
  ocrModel,  // OCR 文字识别模型（ML Kit 通过 Play Services 下载）
}

/// 资源状态
enum ResourceStatus {
  notDownloaded, // 未下载（需要按需下载）
  downloading,   // 下载中
  ready,         // 就绪可用
  error,         // 出错
}

/// 单个资源的状态信息
class AssetResourceStatus {
  final String id;
  final String name;
  final ResourceType type;
  final ResourceStatus status;
  final double progress; // 0.0 - 1.0
  final String? errorMessage;
  final String? localPath; // 下载后的本地路径
  final int? fileSize; // bytes
  final int? downloadedSize; // 已下载 bytes

  const AssetResourceStatus({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.progress = 0.0,
    this.errorMessage,
    this.localPath,
    this.fileSize,
    this.downloadedSize,
  });

  AssetResourceStatus copyWith({
    String? id,
    String? name,
    ResourceType? type,
    ResourceStatus? status,
    double? progress,
    String? errorMessage,
    String? localPath,
    int? fileSize,
    int? downloadedSize,
  }) {
    return AssetResourceStatus(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      downloadedSize: downloadedSize ?? this.downloadedSize,
    );
  }
}

/// 按需下载资源服务
/// 
/// 使用方式：
/// 1. 用户首次使用某个功能（如上传音频）
/// 2. 检测模型是否存在，不存在则提示下载
/// 3. 用户确认后开始下载，显示进度
/// 4. 下载完成后自动使用
class AssetModelService {
  static AssetModelService? _instance;
  static AssetModelService get instance => _instance ??= AssetModelService._();
  AssetModelService._();

  /// Dio 实例
  final Dio _dio = Dio();

  /// 下载任务管理
  final Map<String, CancelToken> _cancelTokens = {};

  /// 资源状态缓存
  final Map<String, AssetResourceStatus> _resourceStatus = {};

  /// SharedPreferences key 前缀
  static const String _downloadedFlagKey = 'asset_downloaded_';
  static const String _localPathKey = 'asset_local_path_';

  /// 资源目录
  String? _resourcesDir;

  /// 获取资源存储目录
  Future<String> get resourcesDir async {
    if (_resourcesDir != null) return _resourcesDir!;

    final appDir = await getApplicationDocumentsDirectory();
    _resourcesDir = '${appDir.path}/on_demand_resources';

    final dir = Directory(_resourcesDir!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return _resourcesDir!;
  }

  /// 获取资源子目录
  Future<String> getResourceSubDir(ResourceType type) async {
    final baseDir = await resourcesDir;
    String subDir;
    
    switch (type) {
      case ResourceType.asrModel:
        subDir = 'asr_models';
        break;
      case ResourceType.ttsModel:
        subDir = 'tts_models';
        break;
      case ResourceType.ocrModel:
        subDir = 'ocr_models';
        break;
    }

    final fullPath = '$baseDir/$subDir';
    final dir = Directory(fullPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return fullPath;
  }

  /// 检查资源是否已下载
  Future<bool> isResourceDownloaded(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_downloadedFlagKey$resourceId') ?? false;
  }

  /// 标记资源已下载
  Future<void> markResourceDownloaded(String resourceId, String localPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_downloadedFlagKey$resourceId', true);
    await prefs.setString('$_localPathKey$resourceId', localPath);
  }

  /// 获取资源本地路径
  Future<String?> getResourceLocalPath(String resourceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_localPathKey$resourceId');
  }

  /// 获取资源状态
  Future<AssetResourceStatus> getResourceStatus(String resourceId) async {
    if (_resourceStatus.containsKey(resourceId)) {
      return _resourceStatus[resourceId]!;
    }

    // 从存储读取状态
    final downloaded = await isResourceDownloaded(resourceId);
    final localPath = downloaded ? await getResourceLocalPath(resourceId) : null;
    
    ResourceStatus status;
    if (downloaded && localPath != null && await File(localPath).exists()) {
      status = ResourceStatus.ready;
    } else if (_resourceStatus.containsKey(resourceId) && 
               _resourceStatus[resourceId]!.status == ResourceStatus.downloading) {
      status = ResourceStatus.downloading;
    } else {
      status = ResourceStatus.notDownloaded;
    }

    final resourceInfo = _getResourceInfo(resourceId);
    return AssetResourceStatus(
      id: resourceId,
      name: resourceInfo?['name'] as String? ?? resourceId,
      type: resourceInfo?['type'] as ResourceType? ?? ResourceType.asrModel,
      status: status,
      localPath: localPath,
      fileSize: resourceInfo?['fileSize'] as int?,
    );
  }

  /// 获取资源信息
  Map<String, dynamic>? _getResourceInfo(String resourceId) {
    final resources = _getAvailableResources();
    for (final resource in resources) {
      if (resource['id'] == resourceId) {
        return resource;
      }
    }
    return null;
  }

  /// 获取可用资源列表
  List<Map<String, dynamic>> _getAvailableResources() {
    return [
      // ASR 模型 - SenseVoice Small int8（推荐，中英日韩粤五语）
      {
        'id': 'sensevoice-int8',
        'name': 'SenseVoice Small (int8)',
        'type': ResourceType.asrModel,
        'description': '阿里 SenseVoice 量化版，支持中/英/日/韩/粤五语',
        'downloadUrl': 
            'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
        'fileSize': 158000000, // 158MB
      },
      // ASR 模型 - Paraformer 中文
      {
        'id': 'paraformer-zh',
        'name': 'Paraformer 中文',
        'type': ResourceType.asrModel,
        'description': '阿里 Paraformer 中文识别模型',
        'downloadUrl': 
            'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-paraformer-zh-2024-09-01.tar.bz2',
        'fileSize': 48000000, // 48MB
      },
      // ASR 模型 - Whisper Tiny（多语言）
      {
        'id': 'whisper-tiny',
        'name': 'Whisper Tiny',
        'type': ResourceType.asrModel,
        'description': 'OpenAI Whisper 多语言模型',
        'downloadUrl': 
            'https://github.com/openai/whisper/main/model-medium.bin', // 示例 URL
        'fileSize': 75000000, // 75MB
      },
      // TTS 模型 - CosyVoice
      {
        'id': 'cosyvoice-tts',
        'name': 'CosyVoice 语音合成',
        'type': ResourceType.ttsModel,
        'description': '阿里 CosyVoice 多音色语音合成',
        'downloadUrl': 
            'https://github.com/modelscope/speech-cosyvoice-onnx/releases/download/V1.0/cosyvoice-onnx.tar.bz2',
        'fileSize': 100000000, // 100MB
      },
    ];
  }

  /// 获取所有可用资源列表
  List<Map<String, dynamic>> getAvailableResources() {
    return _getAvailableResources();
  }

  /// 下载资源
  /// 
  /// [resourceId] 资源 ID
  /// [onProgress] 进度回调 (status, progress, downloadedSize, totalSize)
  Future<AssetResourceStatus> downloadResource(
    String resourceId, {
    void Function(String status, double progress, int downloaded, int total)? onProgress,
  }) async {
    final resourceInfo = _getResourceInfo(resourceId);
    if (resourceInfo == null) {
      return AssetResourceStatus(
        id: resourceId,
        name: resourceId,
        type: ResourceType.asrModel,
        status: ResourceStatus.error,
        errorMessage: '未找到资源信息: $resourceId',
      );
    }

    // 检查是否已下载
    final alreadyDownloaded = await isResourceDownloaded(resourceId);
    if (alreadyDownloaded) {
      final localPath = await getResourceLocalPath(resourceId);
      if (localPath != null && await File(localPath).exists()) {
        return AssetResourceStatus(
          id: resourceId,
          name: resourceInfo['name'] as String,
          type: resourceInfo['type'] as ResourceType,
          status: ResourceStatus.ready,
          localPath: localPath,
          fileSize: resourceInfo['fileSize'] as int?,
        );
      }
    }

    // 开始下载
    _resourceStatus[resourceId] = AssetResourceStatus(
      id: resourceId,
      name: resourceInfo['name'] as String,
      type: resourceInfo['type'] as ResourceType,
      status: ResourceStatus.downloading,
      progress: 0.0,
    );
    onProgress?.call('准备下载...', 0.0, 0, resourceInfo['fileSize'] as int);

    try {
      final downloadUrl = resourceInfo['downloadUrl'] as String;
      final subDir = await getResourceSubDir(resourceInfo['type'] as ResourceType);
      final fileName = downloadUrl.split('/').last;
      final targetPath = '$subDir/$fileName';
      
      // 创建 CancelToken
      final cancelToken = CancelToken();
      _cancelTokens[resourceId] = cancelToken;

      // 下载文件
      onProgress?.call('开始下载...', 0.1, 0, resourceInfo['fileSize'] as int);
      
      await _dio.download(
        downloadUrl,
        targetPath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _resourceStatus[resourceId] = _resourceStatus[resourceId]!.copyWith(
              progress: progress,
              downloadedSize: received,
            );
            onProgress?.call('下载中 ${(progress * 100).toInt()}%', progress, received, total);
          }
        },
      );

      // 下载完成，解压文件
      onProgress?.call('解压中...', 0.9, resourceInfo['fileSize'] as int, resourceInfo['fileSize'] as int);
      
      final extractedPath = await _extractArchive(targetPath, subDir);
      
      // 标记已下载
      await markResourceDownloaded(resourceId, extractedPath);
      
      onProgress?.call('下载完成', 1.0, resourceInfo['fileSize'] as int, resourceInfo['fileSize'] as int);
      
      final status = AssetResourceStatus(
        id: resourceId,
        name: resourceInfo['name'] as String,
        type: resourceInfo['type'] as ResourceType,
        status: ResourceStatus.ready,
        progress: 1.0,
        localPath: extractedPath,
        fileSize: resourceInfo['fileSize'] as int?,
      );
      
      _resourceStatus[resourceId] = status;
      _cancelTokens.remove(resourceId);
      return status;
      
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('[AssetModelService] 下载取消: $resourceId');
      } else {
        debugPrint('[AssetModelService] 下载失败: $resourceId, 错误: $e');
      }
      
      final status = AssetResourceStatus(
        id: resourceId,
        name: resourceInfo['name'] as String,
        type: resourceInfo['type'] as ResourceType,
        status: ResourceStatus.error,
        errorMessage: e.toString(),
      );
      
      _resourceStatus[resourceId] = status;
      _cancelTokens.remove(resourceId);
      return status;
    }
  }

  /// 取消下载
  Future<void> cancelDownload(String resourceId) async {
    final cancelToken = _cancelTokens[resourceId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('用户取消下载');
    }
  }

  /// 解压归档文件
  Future<String> _extractArchive(String archivePath, String targetDir) async {
    // 这里可以添加归档文件解压逻辑
    // 如果是 .tar.bz2 等格式，需要使用 archive 包解压
    // 当前直接返回归档文件路径（假设模型是单个文件或已解压）
    return archivePath;
  }

  /// 检查 OCR 是否可用（ML Kit 通过 Play Services 自动下载）
  Future<bool> isOCRAvailable() async {
    // ML Kit 的模型通过 Google Play Services 自动按需下载
    // 不需要手动检查
    return true;
  }

  /// 获取所有资源状态概览
  Future<Map<ResourceType, AssetResourceStatus>> getAllResourceStatus() async {
    final result = <ResourceType, AssetResourceStatus>{};
    
    final resources = _getAvailableResources();
    
    // 按类型分组，取第一个
    for (final type in ResourceType.values) {
      final typeResources = resources.where((r) => r['type'] == type).toList();
      if (typeResources.isNotEmpty) {
        final firstResource = typeResources.first;
        final status = await getResourceStatus(firstResource['id'] as String);
        result[type] = status;
      }
    }

    return result;
  }

  /// 删除资源（释放存储空间）
  Future<void> deleteResource(String resourceId) async {
    final localPath = await getResourceLocalPath(resourceId);
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_downloadedFlagKey$resourceId');
    await prefs.remove('$_localPathKey$resourceId');
    
    _resourceStatus.remove(resourceId);
    debugPrint('[AssetModelService] 已删除资源: $resourceId');
  }

  /// 重置所有资源
  Future<void> resetAllResources() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 清除所有标记
    final keys = prefs.getKeys()
        .where((k) => k.startsWith(_downloadedFlagKey) || k.startsWith(_localPathKey))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    // 清除状态缓存
    _resourceStatus.clear();
    
    // 删除资源目录
    final dir = Directory(await resourcesDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    
    debugPrint('[AssetModelService] 已重置所有资源');
  }

  /// 获取资源本地路径（如果已下载）
  Future<String?> getResourcePath(String resourceId) async {
    final status = await getResourceStatus(resourceId);
    if (status.status == ResourceStatus.ready && status.localPath != null) {
      return status.localPath;
    }
    return null;
  }
}