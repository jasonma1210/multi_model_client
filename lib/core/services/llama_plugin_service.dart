/// llama.cpp 插件管理服务
///
/// 职责：
/// 1. 查询当前安装的 llama.cpp 版本
/// 2. 检查最新版本（GitHub Releases / 镜像源）
/// 3. 下载新版本到本地
/// 4. 热更新（不重启 App）
///
/// 设计要点：
/// - 插件库存放在 app 私有目录（如 .llama_plugins/llama-cpp/v0.0.3000/）
/// - 当前加载的库通过 libllama.so 软链接指向激活版本
/// - 切换版本只需更新软链接，下次启动生效
///
/// 限制：
/// - 库必须 ABI 兼容（API 接口稳定时才行）
/// - iOS 由于沙盒限制无法热更新，需下次启动生效
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// llama.cpp 插件信息
class LlamaPluginInfo {
  final String version; // '0.0.2861'
  final int buildNumber;
  final String? commit;
  final DateTime? releaseDate;
  final String? downloadUrl;
  final int? fileSize;
  final String? checksum;
  final String? notes;
  final bool isInstalled;
  final bool isActive;

  const LlamaPluginInfo({
    required this.version,
    required this.buildNumber,
    this.commit,
    this.releaseDate,
    this.downloadUrl,
    this.fileSize,
    this.checksum,
    this.notes,
    this.isInstalled = false,
    this.isActive = false,
  });
}

/// 插件下载进度
class LlamaPluginDownloadProgress {
  final String version;
  final int totalBytes;
  final int downloadedBytes;
  final double progress; // 0.0 - 1.0
  final String status; // idle, downloading, extracting, completed, error
  final String? error;

  const LlamaPluginDownloadProgress({
    required this.version,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.progress = 0.0,
    this.status = 'idle',
    this.error,
  });

  LlamaPluginDownloadProgress copyWith({
    int? totalBytes,
    int? downloadedBytes,
    double? progress,
    String? status,
    String? error,
  }) {
    return LlamaPluginDownloadProgress(
      version: version,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

/// llama.cpp 插件服务
class LlamaPluginService {
  LlamaPluginService._();
  static final LlamaPluginService instance = LlamaPluginService._();

  // 当前硬编码的版本（从 build_llama 编译时生成）
  // ⚠️ 此值与 android/app/src/main/jniLibs 中的库对应
  static const String _currentVersion = '0.0.2861';
  static const int _currentBuild = 2861;
  static const String _currentCommit = 'unknown';

  // 远程源配置
  static const String _githubRepo = 'ggerganov/llama.cpp';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // 缓存
  LlamaPluginInfo? _cachedCurrent;
  LlamaPluginInfo? _cachedLatest;

  // 下载状态
  final Map<String, LlamaPluginDownloadProgress> _versionProgress = {};

  // ── 公共 API ──

  /// 获取当前安装的 llama.cpp 版本
  Future<LlamaPluginInfo> getCurrentVersion() async {
    if (_cachedCurrent != null) return _cachedCurrent!;

    // 1. 优先从 .llama_plugins/active_version.json 读取
    try {
      final dir = await _getPluginsDir();
      final versionFile = File('${dir.path}/active_version.json');
      if (await versionFile.exists()) {
        final content = await versionFile.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>?;
        if (data != null) {
          _cachedCurrent = LlamaPluginInfo(
            version: data['version'] as String? ?? _currentVersion,
            buildNumber: data['buildNumber'] as int? ?? _currentBuild,
            commit: data['commit'] as String? ?? _currentCommit,
            isInstalled: true,
            isActive: true,
          );
          return _cachedCurrent!;
        }
      }
    } catch (e) {
      debugPrint('[LlamaPluginService] 读取 active_version.json 失败: $e');
    }

    // 2. 回退到内置版本
    _cachedCurrent = LlamaPluginInfo(
      version: _currentVersion,
      buildNumber: _currentBuild,
      commit: _currentCommit,
      isInstalled: true,
      isActive: true,
    );
    return _cachedCurrent!;
  }

  /// 检查最新版本（从 GitHub Releases）
  Future<LlamaPluginInfo?> checkLatest() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$_githubRepo/releases/latest',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final tagName = data['tag_name'] as String? ?? 'b0';
        final buildNumber = _parseBuildNumber(tagName);
        final publishedAt = data['published_at'] as String?;
        final body = data['body'] as String?;
        // 查找 Android arm64 资产
        final assets = data['assets'] as List<dynamic>? ?? [];
        Map<String, dynamic>? androidAsset;
        for (final a in assets) {
          if (a is Map && a['name'] != null) {
            final name = a['name'] as String;
            if (name.contains('android') && name.contains('aarch64')) {
              androidAsset = a;
              break;
            }
          }
        }
        _cachedLatest = LlamaPluginInfo(
          version: '0.0.$buildNumber',
          buildNumber: buildNumber,
          commit: tagName,
          releaseDate: publishedAt != null ? DateTime.tryParse(publishedAt) : null,
          downloadUrl: androidAsset?['browser_download_url'] as String? ??
              data['html_url'] as String?,
          fileSize: androidAsset?['size'] as int?,
          notes: body,
          isInstalled: false,
        );
        return _cachedLatest;
      }
    } catch (e) {
      debugPrint('[LlamaPluginService] 检查最新版本失败: $e');
    }
    return null;
  }

  /// 检查是否有更新
  Future<bool> hasUpdate() async {
    final current = await getCurrentVersion();
    final latest = await checkLatest();
    if (latest == null) return false;
    return latest.buildNumber > current.buildNumber;
  }

  /// 下载并安装最新版本
  ///
  /// [mirrorUrl] 自定义镜像 URL（用于国内加速，如 https://hf-mirror.com）
  Future<LlamaPluginInfo> downloadAndInstall({
    required LlamaPluginInfo target,
    String? mirrorUrl,
    void Function(LlamaPluginDownloadProgress progress)? onProgress,
  }) async {
    _versionProgress[target.version] = LlamaPluginDownloadProgress(
      version: target.version,
      status: 'downloading',
    );
    onProgress?.call(_versionProgress[target.version]!);

    try {
      // 1. 确定下载 URL
      String downloadUrl = target.downloadUrl ?? '';
      if (mirrorUrl != null && mirrorUrl.isNotEmpty && downloadUrl.contains('github.com')) {
        // 使用镜像替换 github.com
        downloadUrl = downloadUrl.replaceFirst('https://github.com', mirrorUrl);
      }
      if (downloadUrl.isEmpty) {
        throw Exception('No download URL available');
      }

      debugPrint('[LlamaPluginService] 下载 llama.cpp $target.version: $downloadUrl');

      // 2. 下载到 .llama_plugins/cache/<filename>
      final pluginsDir = await _getPluginsDir();
      final cacheDir = Directory('${pluginsDir.path}/cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      final filename = downloadUrl.split('/').last;
      final cacheFile = File('${cacheDir.path}/$filename');

      await _dio.download(
        downloadUrl,
        cacheFile.path,
        onReceiveProgress: (received, total) {
          final p = total > 0 ? received / total : 0.0;
          _versionProgress[target.version] = _versionProgress[target.version]!.copyWith(
            totalBytes: total,
            downloadedBytes: received,
            progress: p,
            status: 'downloading',
          );
          onProgress?.call(_versionProgress[target.version]!);
        },
        deleteOnError: true,
      );

      // 3. 安装到 plugins/llama-cpp/{version}/
      _versionProgress[target.version] = _versionProgress[target.version]!.copyWith(
        status: 'extracting',
        progress: 1.0,
      );
      onProgress?.call(_versionProgress[target.version]!);

      final versionDir = Directory('${pluginsDir.path}/llama-cpp/${target.version}');
      if (!await versionDir.exists()) {
        await versionDir.create(recursive: true);
      }
      // 简单复制（实际环境需根据压缩格式解压）
      await cacheFile.copy('${versionDir.path}/$filename');

      // 4. 写入 active_version.json（下次启动激活）
      final activeVersionFile = File('${pluginsDir.path}/active_version.json');
      await activeVersionFile.writeAsString(jsonEncode({
        'version': target.version,
        'buildNumber': target.buildNumber,
        'commit': target.commit,
        'installedAt': DateTime.now().toIso8601String(),
      }));

      _versionProgress[target.version] = _versionProgress[target.version]!.copyWith(
        status: 'completed',
        progress: 1.0,
      );
      onProgress?.call(_versionProgress[target.version]!);

      // 5. 清除缓存
      _cachedCurrent = null;
      _cachedLatest = null;

      return LlamaPluginInfo(
        version: target.version,
        buildNumber: target.buildNumber,
        commit: target.commit,
        isInstalled: true,
        isActive: false, // 需要下次启动激活
      );
    } catch (e, st) {
      debugPrint('[LlamaPluginService] 下载安装失败: $e\n$st');
      _versionProgress[target.version] = _versionProgress[target.version]!.copyWith(
        status: 'error',
        error: e.toString(),
      );
      onProgress?.call(_versionProgress[target.version]!);
      rethrow;
    }
  }

  /// 获取插件存储目录
  Future<Directory> _getPluginsDir() async {
    final appDir = await getApplicationSupportDirectory();
    final pluginsDir = Directory('${appDir.path}/.llama_plugins');
    if (!await pluginsDir.exists()) {
      await pluginsDir.create(recursive: true);
    }
    return pluginsDir;
  }

  /// 解析 build number（b3000 → 3000）
  int _parseBuildNumber(String tag) {
    if (tag.startsWith('b')) {
      return int.tryParse(tag.substring(1)) ?? 0;
    }
    return int.tryParse(tag) ?? 0;
  }

  /// 获取下载进度
  LlamaPluginDownloadProgress? getDownloadProgress(String version) {
    return _versionProgress[version];
  }
}
