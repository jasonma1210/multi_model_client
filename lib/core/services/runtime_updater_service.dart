/// 运行时更新服务 - 云端配置 + 动态下载
///
/// 功能：
/// - 从云端获取最新的 llama.cpp 运行时版本
/// - 对比本地版本，判断是否需要更新
/// - 下载并解压运行时到用户沙盒目录
/// - 支持热更新（无需重启 App）
///
/// 云端 manifest.json 格式：
/// {
///   "version": "b3001",
///   "runtimes": {
///     "macos-metal-arm64": "https://yourapi.com/dl/llama-server-mac-arm64.zip",
///     "macos-x64": "https://yourapi.com/dl/llama-server-mac-x64.zip",
///     "windows-cuda-x64": "https://yourapi.com/dl/llama-server-win-cuda.zip",
///     "windows-avx2-x64": "https://yourapi.com/dl/llama-server-win-avx2.zip",
///     "linux-cuda-x64": "https://yourapi.com/dl/llama-server-linux-cuda.zip",
///     "linux-x64": "https://yourapi.com/dl/llama-server-linux-x64.zip"
///   }
/// }
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// 运行时版本信息
class RuntimeVersion {
  final String version; // b3001
  final Map<String, RuntimeAsset> runtimes;

  RuntimeVersion({required this.version, required this.runtimes});

  factory RuntimeVersion.fromJson(Map<String, dynamic> json) {
    final runtimesJson = json['runtimes'] as Map<String, dynamic>? ?? {};
    final runtimes = runtimesJson.map(
      (key, value) => MapEntry(key, RuntimeAsset.fromJson(value)),
    );

    return RuntimeVersion(
      version: json['version'] ?? '',
      runtimes: runtimes,
    );
  }
}

/// 运行时资源
class RuntimeAsset {
  final String url;
  final String? sha256;
  final int size;

  RuntimeAsset({required this.url, this.sha256, this.size = 0});

  factory RuntimeAsset.fromJson(Map<String, dynamic> json) {
    return RuntimeAsset(
      url: json['url'] ?? '',
      sha256: json['sha256'],
      size: json['size'] ?? 0,
    );
  }
}

/// 更新状态
enum RuntimeUpdateStatus {
  idle,
  checking,
  available,
  downloading,
  extracting,
  completed,
  failed,
}

/// 更新进度
class RuntimeUpdateProgress {
  final RuntimeUpdateStatus status;
  final double progress;
  final String message;
  final String? error;

  RuntimeUpdateProgress({
    required this.status,
    this.progress = 0.0,
    this.message = '',
    this.error,
  });

  factory RuntimeUpdateProgress.idle() => RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.idle,
        message: '就绪',
      );

  factory RuntimeUpdateProgress.checking() => RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.checking,
        message: '正在检查更新...',
      );

  factory RuntimeUpdateProgress.available(String version) =>
      RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.available,
        message: '发现新版本: $version',
      );

  factory RuntimeUpdateProgress.downloading(double progress) =>
      RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.downloading,
        progress: progress,
        message: '正在下载运行时... ${(progress * 100).toStringAsFixed(1)}%',
      );

  factory RuntimeUpdateProgress.extracting() => RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.extracting,
        message: '正在解压...',
      );

  factory RuntimeUpdateProgress.completed(String version) =>
      RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.completed,
        message: '运行时已更新到 $version',
      );

  factory RuntimeUpdateProgress.failed(String error) => RuntimeUpdateProgress(
        status: RuntimeUpdateStatus.failed,
        message: '更新失败',
        error: error,
      );
}

/// 运行时更新服务
class RuntimeUpdaterService {
  static final RuntimeUpdaterService _instance = RuntimeUpdaterService._();
  static RuntimeUpdaterService get instance => _instance;

  RuntimeUpdaterService._();

  final Dio _dio = Dio();

  // ════════════════════════════════════════════════════════════════════════
  //  配置（使用 GitHub Releases 自动更新）
  // ════════════════════════════════════════════════════════════════════════

  /// GitHub 仓库地址
  static const String _githubOwner = 'Jianma-Android';
  static const String _githubRepo = 'LLM-Studio';

  /// GitHub Tags API 地址
  static const String _tagsUrl = 'https://api.github.com/repos/$_githubOwner/$_githubRepo/tags';

  /// GitHub Releases API 地址
  static const String _releasesUrl = 'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  /// 本地版本文件路径
  String get _versionFilePath {
    if (Platform.isMacOS || Platform.isIOS) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/Library/Application Support/LLM Studio/runtime/.version';
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      return '$appData/LLM Studio/runtime/.version';
    } else {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/.llm_studio/runtime/.version';
    }
  }

  /// 运行时目录路径
  Future<String> get runtimeDir async {
    if (Platform.isMacOS || Platform.isIOS) {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/Library/Application Support/LLM Studio/runtime';
    } else if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'] ?? '';
      return '$appData/LLM Studio/runtime';
    } else {
      final home = Platform.environment['HOME'] ?? '';
      return '$home/.llm_studio/runtime';
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  版本管理
  // ════════════════════════════════════════════════════════════════════════

  /// 获取本地版本
  Future<String?> getLocalVersion() async {
    try {
      final file = File(_versionFilePath);
      if (await file.exists()) {
        return (await file.readAsString()).trim();
      }
    } catch (e) {
      debugPrint('[RuntimeUpdater] 读取本地版本失败: $e');
    }
    return null;
  }

  /// 保存本地版本
  Future<void> saveLocalVersion(String version) async {
    try {
      final dir = Directory(_versionFilePath).parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      await File(_versionFilePath).writeAsString(version);
    } catch (e) {
      debugPrint('[RuntimeUpdater] 保存本地版本失败: $e');
    }
  }

  /// 获取当前平台的运行时标识
  String get _platformKey {
    final os = Platform.operatingSystem;
    final arch = Platform.operatingSystemVersion.toLowerCase();

    if (os == 'macos') {
      if (arch.contains('arm') || arch.contains('aarch64')) {
        return 'macos-metal-arm64';
      } else {
        return 'macos-x64';
      }
    } else if (os == 'windows') {
      // 可以通过 nvidia-smi 检测是否有 NVIDIA GPU
      if (_hasNvidiaGPU()) {
        return 'windows-cuda-x64';
      }
      return 'windows-avx2-x64';
    } else if (os == 'linux') {
      if (_hasNvidiaGPU()) {
        return 'linux-cuda-x64';
      }
      return 'linux-x64';
    }

    // 默认返回通用标识
    return '$os-x64';
  }

  /// 检测是否有 NVIDIA GPU
  bool _hasNvidiaGPU() {
    try {
      // 尝试运行 nvidia-smi
      final result = Process.runSync('nvidia-smi', ['--query-gpu=name', '--format=csv,noheader']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  更新检查
  // ════════════════════════════════════════════════════════════════════════

  /// 从 GitHub Tags API 检查最新版本
  Future<RuntimeVersion?> checkForUpdate() async {
    try {
      debugPrint('[RuntimeUpdater] 从 GitHub Tags 检查更新: $_tagsUrl');

      final response = await _dio.get(
        _tagsUrl,
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/vnd.github.v3+json'},
        ),
      );

      if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
        final tags = response.data as List;
        final latestTag = tags[0] as Map<String, dynamic>;
        final tagName = latestTag['name'] as String? ?? '';

        if (tagName.isEmpty) return null;

        debugPrint('[RuntimeUpdater] GitHub 最新 tag: $tagName');

        // 尝试获取该 tag 的 release 信息（包含下载资产）
        RuntimeVersion? releaseVersion;
        try {
          final releaseResp = await _dio.get(
            _releasesUrl,
            options: Options(
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/vnd.github.v3+json'},
            ),
          );
          if (releaseResp.statusCode == 200) {
            releaseVersion = _parseGitHubRelease(releaseResp.data as Map<String, dynamic>);
          }
        } catch (e) {
          debugPrint('[RuntimeUpdater] 获取 release 失败，使用 tag: $e');
        }

        // 如果没有 release 资产，返回仅含版本号的对象
        return releaseVersion ?? RuntimeVersion(
          version: tagName,
          runtimes: {},
        );
      }

      return null;
    } catch (e) {
      debugPrint('[RuntimeUpdater] 检查更新失败: $e');
      return null;
    }
  }

  /// 解析 GitHub Release 数据
  RuntimeVersion? _parseGitHubRelease(Map<String, dynamic> json) {
    try {
      final tagName = json['tag_name'] as String? ?? '';
      final assets = json['assets'] as List? ?? [];

      final runtimes = <String, RuntimeAsset>{};
      for (final asset in assets) {
        final assetMap = asset as Map<String, dynamic>;
        final name = assetMap['name'] as String? ?? '';
        final url = assetMap['browser_download_url'] as String? ?? '';
        final size = assetMap['size'] as int? ?? 0;

        // 匹配平台资源
        if (name.contains('macos') && name.contains('arm64')) {
          runtimes['macos-metal-arm64'] = RuntimeAsset(url: url, size: size);
        } else if (name.contains('macos') && (name.contains('x64') || name.contains('x86'))) {
          runtimes['macos-x64'] = RuntimeAsset(url: url, size: size);
        } else if (name.contains('windows') && name.contains('cuda')) {
          runtimes['windows-cuda-x64'] = RuntimeAsset(url: url, size: size);
        } else if (name.contains('windows')) {
          runtimes['windows-avx2-x64'] = RuntimeAsset(url: url, size: size);
        } else if (name.contains('linux') && name.contains('cuda')) {
          runtimes['linux-cuda-x64'] = RuntimeAsset(url: url, size: size);
        } else if (name.contains('linux')) {
          runtimes['linux-x64'] = RuntimeAsset(url: url, size: size);
        }
      }

      return RuntimeVersion(version: tagName, runtimes: runtimes);
    } catch (e) {
      debugPrint('[RuntimeUpdater] 解析 release 数据失败: $e');
      return null;
    }
  }

  /// 判断是否需要更新
  Future<bool> needsUpdate() async {
    final localVersion = await getLocalVersion();
    final remoteVersion = await checkForUpdate();

    if (remoteVersion == null) {
      return false;
    }

    if (localVersion == null) {
      return true; // 没有本地版本，需要更新
    }

    // 比较版本（简单比较，实际可以用 semver）
    final localBuild = _extractBuildNumber(localVersion);
    final remoteBuild = _extractBuildNumber(remoteVersion.version);

    return remoteBuild > localBuild;
  }

  /// 从版本字符串提取 build 号
  int _extractBuildNumber(String version) {
    final match = RegExp(r'b(\d+)').firstMatch(version);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  下载与更新
  // ════════════════════════════════════════════════════════════════════════

  /// 下载并更新运行时
  Future<bool> downloadAndUpdate({
    void Function(RuntimeUpdateProgress)? onProgress,
  }) async {
    try {
      // 1. 获取云端版本信息
      onProgress?.call(RuntimeUpdateProgress.checking());

      final remoteVersion = await checkForUpdate();
      if (remoteVersion == null) {
        onProgress?.call(RuntimeUpdateProgress.failed('无法获取云端版本'));
        return false;
      }

      // 2. 找到当前平台的下载链接
      final platformKey = _platformKey;
      final asset = remoteVersion.runtimes[platformKey];

      if (asset == null) {
        onProgress?.call(RuntimeUpdateProgress.failed('不支持当前平台: $platformKey'));
        return false;
      }

      // 3. 创建临时下载目录
      final tempDir = await getTemporaryDirectory();
      final downloadPath = '${tempDir.path}/llama-runtime-${remoteVersion.version}.zip';

      // 4. 下载
      onProgress?.call(RuntimeUpdateProgress.downloading(0.0));

      await _dio.download(
        asset.url,
        downloadPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(RuntimeUpdateProgress.downloading(progress));
          }
        },
      );

      debugPrint('[RuntimeUpdater] 下载完成: $downloadPath');

      // 5. 解压到运行时目录
      onProgress?.call(RuntimeUpdateProgress.extracting());

      final runtimePath = await runtimeDir;
      await _extractArchive(downloadPath, runtimePath);

      // 6. 保存版本号
      await saveLocalVersion(remoteVersion.version);

      // 7. 赋予可执行权限
      await _chmodExecutable(runtimePath);

      onProgress?.call(RuntimeUpdateProgress.completed(remoteVersion.version));

      debugPrint('[RuntimeUpdater] ✅ 运行时更新完成: ${remoteVersion.version}');
      return true;
    } catch (e) {
      debugPrint('[RuntimeUpdater] 更新失败: $e');
      onProgress?.call(RuntimeUpdateProgress.failed(e.toString()));
      return false;
    }
  }

  /// 解压归档文件
  Future<void> _extractArchive(String archivePath, String destPath) async {
    final file = File(archivePath);
    final fileName = file.uri.pathSegments.last;

    // 确保目标目录存在
    final destDir = Directory(destPath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    if (fileName.endsWith('.zip')) {
      final result = await Process.run(
        'unzip',
        ['-o', archivePath, '-d', destPath],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw Exception('解压失败: ${result.stderr}');
      }
    } else if (fileName.endsWith('.tar.gz') || fileName.endsWith('.tgz')) {
      final result = await Process.run(
        'tar',
        ['-xzf', archivePath, '-C', destPath],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw Exception('解压失败: ${result.stderr}');
      }
    }
  }

  /// 赋予可执行权限
  Future<void> _chmodExecutable(String runtimePath) async {
    final dir = Directory(runtimePath);

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final name = entity.path.split('/').last;
        // 给 llama-server 赋予可执行权限
        if (name.startsWith('llama-server') && !name.endsWith('.dylib')) {
          await Process.run('chmod', ['+x', entity.path]);
        }
      }
    }
  }

  /// 检查运行时是否可用
  Future<bool> isRuntimeAvailable() async {
    try {
      final runtimePath = await runtimeDir;
      final serverPath = Platform.isWindows
          ? '$runtimePath/llama-server.exe'
          : '$runtimePath/llama-server';

      return File(serverPath).existsSync();
    } catch (e) {
      return false;
    }
  }

  /// 获取运行时路径
  Future<String> getRuntimePath() async {
    return await runtimeDir;
  }
}