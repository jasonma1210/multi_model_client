/// 模型更新服务 (Model Update Service)
///
/// 功能：
/// - 检查 ASR/VAD/说话人分离模型的更新
/// - 下载更新并显示进度
/// - 版本管理和回滚
///
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 模型更新状态
enum UpdateStatus {
  idle,          // 空闲
  checking,      // 检查中
  available,     // 有更新可用
  downloading,   // 下载中
  installing,    // 安装中
  completed,     // 完成
  error,         // 错误
}

/// 模型更新信息
class ModelUpdate {
  final String modelId;
  final String modelName;
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final int fileSize;
  final String? releaseNotes;
  final String? releaseUrl;
  final List<String> mirrorUrls;

  const ModelUpdate({
    required this.modelId,
    required this.modelName,
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.fileSize,
    this.releaseNotes,
    this.releaseUrl,
    this.mirrorUrls = const [],
  });

  bool get hasUpdate => currentVersion != latestVersion;

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 更新进度
class UpdateProgress {
  final String modelId;
  final UpdateStatus status;
  final double progress;     // 0.0 - 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String? message;
  final String? error;

  const UpdateProgress({
    required this.modelId,
    required this.status,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.message,
    this.error,
  });

  String get progressPercent => '${(progress * 100).toStringAsFixed(1)}%';

  String get speedFormatted {
    // 简化版，实际应计算下载速度
    return '';
  }
}

/// 模型版本信息
class ModelVersion {
  final String modelId;
  final String version;
  final String installedPath;
  final DateTime installedAt;

  const ModelVersion({
    required this.modelId,
    required this.version,
    required this.installedPath,
    required this.installedAt,
  });

  Map<String, dynamic> toJson() => {
    'modelId': modelId,
    'version': version,
    'installedPath': installedPath,
    'installedAt': installedAt.toIso8601String(),
  };

  factory ModelVersion.fromJson(Map<String, dynamic> json) => ModelVersion(
    modelId: json['modelId'] as String,
    version: json['version'] as String,
    installedPath: json['installedPath'] as String,
    installedAt: DateTime.parse(json['installedAt'] as String),
  );
}

/// 模型更新服务
class ModelUpdateService {
  static ModelUpdateService? _instance;
  static ModelUpdateService get instance => _instance ??= ModelUpdateService._();

  ModelUpdateService._();

  final Dio _dio = Dio();
  final StreamController<UpdateProgress> _progressController =
      StreamController<UpdateProgress>.broadcast();

  Map<String, ModelVersion> _installedVersions = {};
  bool _initialized = false;

  // GitHub API 配置
  static const String _githubApiBase = 'https://api.github.com';
  static const String _repoOwner = 'k2-fsa';
  static const String _repoName = 'sherpa-onnx';

  // 模型仓库配置
  static final Map<String, ModelRepoConfig> _modelRepos = {
    'sensevoice-int8': ModelRepoConfig(
      repoOwner: 'k2-fsa',
      repoName: 'sherpa-onnx',
      releaseTag: 'asr-models-2024-07-17',
      assetPattern: 'sherpa-onnx-sense-voice-*-int8-*',
      versionRegex: RegExp(r'(\d{4}-\d{2}-\d{2})'),
    ),
    'silero-vad': ModelRepoConfig(
      repoOwner: 'snakers4',
      repoName: 'silero-vad',
      releaseTag: 'latest',
      assetPattern: 'silero_vad*.onnx',
      versionRegex: RegExp(r'v(\d+\.\d+\.\d+)'),
    ),
    'ecapa-tdnn': ModelRepoConfig(
      repoOwner: 'speechbrain',
      repoName: 'speechbrain',
      releaseTag: 'latest',
      assetPattern: '*ecapa*',
      versionRegex: RegExp(r'v(\d+\.\d+\.\d+)'),
    ),
  };

  /// 初始化服务
  Future<void> init() async {
    if (_initialized) return;

    await _loadInstalledVersions();
    _initialized = true;

    debugPrint('[ModelUpdate] 服务初始化完成，已安装模型: ${_installedVersions.length}');
  }

  /// 加载已安装模型版本
  Future<void> _loadInstalledVersions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionsJson = prefs.getString('model_versions');

      if (versionsJson != null) {
        final Map<String, dynamic> versionsMap = jsonDecode(versionsJson);
        _installedVersions = versionsMap.map(
          (key, value) => MapEntry(key, ModelVersion.fromJson(value as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      debugPrint('[ModelUpdate] 加载版本信息失败: $e');
    }
  }

  /// 保存已安装模型版本
  Future<void> _saveInstalledVersions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionsMap = _installedVersions.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString('model_versions', jsonEncode(versionsMap));
    } catch (e) {
      debugPrint('[ModelUpdate] 保存版本信息失败: $e');
    }
  }

  /// 检查指定模型的更新
  Future<ModelUpdate?> checkUpdate(String modelId) async {
    if (!_initialized) await init();

    try {
      final repoConfig = _modelRepos[modelId];
      if (repoConfig == null) {
        debugPrint('[ModelUpdate] 未找到模型配置: $modelId');
        return null;
      }

      // 获取最新 release
      final release = await _getLatestRelease(
        repoConfig.repoOwner,
        repoConfig.repoName,
        repoConfig.releaseTag,
      );

      if (release == null) return null;

      // 解析版本号
      final latestVersion = _extractVersion(release['tag_name'] as String, repoConfig.versionRegex);
      final currentVersion = _installedVersions[modelId]?.version ?? '0.0.0';

      if (latestVersion == currentVersion) {
        debugPrint('[ModelUpdate] $modelId 已是最新版本: $currentVersion');
        return null;
      }

      // 查找下载资源
      final assets = release['assets'] as List<dynamic>? ?? [];
      String? downloadUrl;
      int fileSize = 0;

      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (_matchesPattern(name, repoConfig.assetPattern)) {
          downloadUrl = asset['browser_download_url'] as String?;
          fileSize = asset['size'] as int? ?? 0;
          break;
        }
      }

      if (downloadUrl == null) {
        debugPrint('[ModelUpdate] 未找到下载资源: $modelId');
        return null;
      }

      return ModelUpdate(
        modelId: modelId,
        modelName: _getModelName(modelId),
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        fileSize: fileSize,
        releaseNotes: release['body'] as String?,
        releaseUrl: release['html_url'] as String?,
      );
    } catch (e) {
      debugPrint('[ModelUpdate] 检查更新失败: $e');
      return null;
    }
  }

  /// 检查所有模型的更新
  Future<List<ModelUpdate>> checkAllUpdates() async {
    final updates = <ModelUpdate>[];

    for (final modelId in _modelRepos.keys) {
      final update = await checkUpdate(modelId);
      if (update != null) {
        updates.add(update);
      }
    }

    return updates;
  }

  /// 下载并安装更新
  Future<bool> downloadUpdate(ModelUpdate update) async {
    if (!_initialized) await init();

    try {
      _progressController.add(UpdateProgress(
        modelId: update.modelId,
        status: UpdateStatus.downloading,
        progress: 0.0,
        message: '开始下载...',
      ));

      // 获取下载目录
      final appDir = await getApplicationSupportDirectory();
      final modelDir = Directory('${appDir.path}/models/${update.modelId}');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final filePath = '${modelDir.path}/${update.modelId}_${update.latestVersion}.onnx';

      // 尝试多个下载源
      final urls = [update.downloadUrl, ...update.modelId == 'sensevoice-int8'
          ? ['https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/model.int8.onnx']
          : []];

      bool downloaded = false;
      for (final url in urls) {
        try {
          await _dio.download(
            url,
            filePath,
            onReceiveProgress: (received, total) {
              if (total > 0) {
                final progress = received / total;
                _progressController.add(UpdateProgress(
                  modelId: update.modelId,
                  status: UpdateStatus.downloading,
                  progress: progress,
                  downloadedBytes: received,
                  totalBytes: total,
                  message: '下载中: ${(progress * 100).toStringAsFixed(1)}%',
                ));
              }
            },
          );
          downloaded = true;
          break;
        } catch (e) {
          debugPrint('[ModelUpdate] 下载失败 ($url): $e');
        }
      }

      if (!downloaded) {
        _progressController.add(UpdateProgress(
          modelId: update.modelId,
          status: UpdateStatus.error,
          error: '所有下载源均失败',
        ));
        return false;
      }

      // 验证下载文件
      final file = File(filePath);
      if (!await file.exists() || await file.length() < 1000000) {
        _progressController.add(UpdateProgress(
          modelId: update.modelId,
          status: UpdateStatus.error,
          error: '下载文件无效',
        ));
        return false;
      }

      // 更新版本信息
      _installedVersions[update.modelId] = ModelVersion(
        modelId: update.modelId,
        version: update.latestVersion,
        installedPath: filePath,
        installedAt: DateTime.now(),
      );
      await _saveInstalledVersions();

      _progressController.add(UpdateProgress(
        modelId: update.modelId,
        status: UpdateStatus.completed,
        progress: 1.0,
        message: '更新完成',
      ));

      debugPrint('[ModelUpdate] ${update.modelId} 更新完成: ${update.latestVersion}');
      return true;
    } catch (e) {
      _progressController.add(UpdateProgress(
        modelId: update.modelId,
        status: UpdateStatus.error,
        error: e.toString(),
      ));
      debugPrint('[ModelUpdate] 更新失败: $e');
      return false;
    }
  }

  /// 获取最新 release
  Future<Map<String, dynamic>?> _getLatestRelease(
    String owner,
    String repo,
    String tag,
  ) async {
    try {
      final url = tag == 'latest'
          ? '$_githubApiBase/repos/$owner/$repo/releases/latest'
          : '$_githubApiBase/repos/$owner/$repo/releases/tags/$tag';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[ModelUpdate] 获取 release 失败: $e');
    }
    return null;
  }

  /// 提取版本号
  String _extractVersion(String tagName, RegExp regex) {
    final match = regex.firstMatch(tagName);
    return match?.group(1) ?? tagName;
  }

  /// 匹配文件名模式
  bool _matchesPattern(String filename, String pattern) {
    final regex = RegExp(pattern.replaceAll('*', '.*'));
    return regex.hasMatch(filename);
  }

  /// 获取模型名称
  String _getModelName(String modelId) {
    switch (modelId) {
      case 'sensevoice-int8':
        return 'SenseVoice Small (int8)';
      case 'sensevoice':
        return 'SenseVoice Small';
      case 'silero-vad':
        return 'Silero VAD';
      case 'ecapa-tdnn':
        return 'ECAPA-TDNN';
      default:
        return modelId;
    }
  }

  /// 获取已安装模型版本
  ModelVersion? getInstalledVersion(String modelId) {
    return _installedVersions[modelId];
  }

  /// 获取进度流
  Stream<UpdateProgress> get progressStream => _progressController.stream;

  /// 释放资源
  void dispose() {
    _progressController.close();
  }
}

/// 模型仓库配置
class ModelRepoConfig {
  final String repoOwner;
  final String repoName;
  final String releaseTag;
  final String assetPattern;
  final RegExp versionRegex;

  const ModelRepoConfig({
    required this.repoOwner,
    required this.repoName,
    required this.releaseTag,
    required this.assetPattern,
    required this.versionRegex,
  });
}
