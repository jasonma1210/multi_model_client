/// 模型版本检查服务
///
/// 职责：
/// 1. 从远程源查询 ASR/TTS 模型的最新版本
/// 2. 通知用户有更新可用
/// 3. 缓存版本信息以减少网络请求
///
/// 数据源：
/// - GitHub Releases API（sherpa-onnx）
/// - ModelScope API（国内镜像元数据）
/// - HuggingFace API（海外源元数据）
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 模型版本信息
class ModelVersionInfo {
  final String modelId;
  final String installedVersion;
  final String? latestVersion;
  final String? downloadUrl;
  final DateTime? releaseDate;
  final String? releaseNotes;
  final bool hasUpdate;

  const ModelVersionInfo({
    required this.modelId,
    required this.installedVersion,
    this.latestVersion,
    this.downloadUrl,
    this.releaseDate,
    this.releaseNotes,
    this.hasUpdate = false,
  });
}

/// 版本检查服务（单例）
class ModelVersionService {
  ModelVersionService._();
  static final ModelVersionService instance = ModelVersionService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 缓存：modelId → 版本信息
  final Map<String, ModelVersionInfo> _cache = {};
  DateTime? _lastFetch;
  static const Duration _cacheTTL = Duration(hours: 6);

  // ── 公共 API ──

  /// 检查模型是否有更新（通过 GitHub Releases API）
  ///
  /// [modelId] 模型 ID
  /// [installedVersion] 当前安装版本（null 表示未安装）
  /// [githubRepo] GitHub 仓库（格式：owner/repo），用于查询 release
  /// [tagName] 指定的 tag 名称（可选）
  Future<ModelVersionInfo> checkForUpdate({
    required String modelId,
    required String? installedVersion,
    String? githubRepo,
    String? specificTag,
  }) async {
    // 1. 检查缓存
    final cached = _cache[modelId];
    if (cached != null && _lastFetch != null) {
      if (DateTime.now().difference(_lastFetch!) < _cacheTTL) {
        return _rebuildInfo(modelId, installedVersion, cached);
      }
    }

    // 2. 查询 GitHub Releases API
    ModelVersionInfo? remoteInfo;
    if (githubRepo != null) {
      try {
        final tag = specificTag ?? 'asr-models'; // sherpa-onnx 默认为 asr-models tag
        final url = 'https://api.github.com/repos/$githubRepo/releases/tags/$tag';
        final response = await _dio.get<Map<String, dynamic>>(
          url,
          options: Options(
            headers: {'Accept': 'application/vnd.github.v3+json'},
          ),
        );
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data!;
          final tagName = data['tag_name'] as String? ?? tag;
          final publishedAt = data['published_at'] as String?;
          final body = data['body'] as String?;
          remoteInfo = ModelVersionInfo(
            modelId: modelId,
            installedVersion: installedVersion ?? '',
            latestVersion: tagName,
            releaseDate: publishedAt != null ? DateTime.tryParse(publishedAt) : null,
            releaseNotes: body,
            hasUpdate: installedVersion != null && installedVersion != tagName,
          );
        }
      } catch (e) {
        debugPrint('[ModelVersionService] GitHub API 查询失败: $e');
      }
    }

    // 3. 缓存结果
    if (remoteInfo != null) {
      _cache[modelId] = remoteInfo;
      _lastFetch = DateTime.now();
    }

    return _rebuildInfo(modelId, installedVersion, remoteInfo);
  }

  /// 批量检查多个模型
  Future<List<ModelVersionInfo>> checkBatch(List<({
    String modelId,
    String? installedVersion,
    String? githubRepo,
    String? specificTag,
  })> models) async {
    final results = <ModelVersionInfo>[];
    for (final m in models) {
      results.add(await checkForUpdate(
        modelId: m.modelId,
        installedVersion: m.installedVersion,
        githubRepo: m.githubRepo,
        specificTag: m.specificTag,
      ));
    }
    return results;
  }

  /// 清除缓存
  void clearCache() {
    _cache.clear();
    _lastFetch = null;
  }

  // ── 内部 ──

  ModelVersionInfo _rebuildInfo(
    String modelId,
    String? installedVersion,
    ModelVersionInfo? remote,
  ) {
    return ModelVersionInfo(
      modelId: modelId,
      installedVersion: installedVersion ?? '',
      latestVersion: remote?.latestVersion,
      downloadUrl: remote?.downloadUrl,
      releaseDate: remote?.releaseDate,
      releaseNotes: remote?.releaseNotes,
      hasUpdate: remote != null &&
          installedVersion != null &&
          installedVersion != remote.latestVersion,
    );
  }
}
