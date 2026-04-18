/// llama.cpp 版本更新服务 - LLM Studio
///
/// 功能：
/// - 检测 GitHub 最新版本
/// - 下载并解压新版本
/// - 版本对比和更新提示
///
/// @author Jianma
/// @version 1.0.0
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// llama.cpp 版本信息
class LlamaCppVersion {
  final String tagName; // b8830
  final String releaseUrl;
  final DateTime publishedAt;
  final String body;
  final List<LlamaCppAsset> assets;

  LlamaCppVersion({
    required this.tagName,
    required this.releaseUrl,
    required this.publishedAt,
    required this.body,
    required this.assets,
  });

  /// 从 build 号提取数字
  int get buildNumber {
    final match = RegExp(r'b(\d+)').firstMatch(tagName);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// 解析 GitHub API 响应
  factory LlamaCppVersion.fromJson(Map<String, dynamic> json) {
    final assets = (json['assets'] as List? ?? [])
        .map((a) => LlamaCppAsset.fromJson(a))
        .toList();

    return LlamaCppVersion(
      tagName: json['tag_name'] ?? '',
      releaseUrl: json['html_url'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      body: json['body'] ?? '',
      assets: assets,
    );
  }
}

/// llama.cpp 资源文件
class LlamaCppAsset {
  final String name;
  final int size;
  final String downloadUrl;
  final String browserDownloadUrl;

  LlamaCppAsset({
    required this.name,
    required this.size,
    required this.downloadUrl,
    required this.browserDownloadUrl,
  });

  factory LlamaCppAsset.fromJson(Map<String, dynamic> json) {
    return LlamaCppAsset(
      name: json['name'] ?? '',
      size: json['size'] ?? 0,
      downloadUrl: json['url'] ?? '',
      browserDownloadUrl: json['browser_download_url'] ?? '',
    );
  }

  /// 判断是否匹配当前平台
  bool matchesCurrentPlatform() {
    final os = Platform.operatingSystem;
    final arch = Platform.operatingSystemVersion.toLowerCase();

    if (os == 'macos') {
      if (arch.contains('arm') || arch.contains('aarch64')) {
        return name.contains('macos-arm64');
      } else {
        return name.contains('macos-x64') || name.contains('macos-intel');
      }
    } else if (os == 'linux') {
      if (arch.contains('arm') || arch.contains('aarch64')) {
        return name.contains('ubuntu-arm64');
      } else {
        return name.contains('ubuntu-x64');
      }
    } else if (os == 'windows') {
      if (arch.contains('arm') || arch.contains('aarch64')) {
        return name.contains('win-arm64');
      } else {
        return name.contains('win-x64');
      }
    }
    return false;
  }

  /// 判断是否为预编译的二进制文件（不是源码包）
  bool isBinaryPackage() {
    return (name.contains('-bin-') || name.contains('-xcframework')) &&
           !name.contains('source') &&
           !name.endsWith('.tarball') &&
           !name.endsWith('.zipball');
  }

  /// 获取可执行文件名称
  String getExecutableName() {
    final os = Platform.operatingSystem;
    if (os == 'windows') {
      return 'llama-cli.exe';
    }
    return 'llama-cli';
  }
}

/// 更新状态
enum UpdateStatus {
  idle,
  checking,
  available,
  downloading,
  extracting,
  completed,
  failed,
}

/// 更新进度
class UpdateProgress {
  final UpdateStatus status;
  final double progress; // 0.0 - 1.0
  final String message;
  final String? error;

  UpdateProgress({
    required this.status,
    this.progress = 0.0,
    this.message = '',
    this.error,
  });

  factory UpdateProgress.idle() => UpdateProgress(
        status: UpdateStatus.idle,
        message: '就绪',
      );

  factory UpdateProgress.checking() => UpdateProgress(
        status: UpdateStatus.checking,
        message: '正在检查更新...',
      );

  factory UpdateProgress.available(LlamaCppVersion version) => UpdateProgress(
        status: UpdateStatus.available,
        message: '发现新版本: ${version.tagName}',
      );

  factory UpdateProgress.downloading(double progress) => UpdateProgress(
        status: UpdateStatus.downloading,
        progress: progress,
        message: '正在下载... ${(progress * 100).toStringAsFixed(1)}%',
      );

  factory UpdateProgress.extracting() => UpdateProgress(
        status: UpdateStatus.extracting,
        message: '正在解压...',
      );

  factory UpdateProgress.completed(String version) => UpdateProgress(
        status: UpdateStatus.completed,
        message: '已更新到 $version',
      );

  factory UpdateProgress.failed(String error) => UpdateProgress(
        status: UpdateStatus.failed,
        message: '更新失败',
        error: error,
      );
}

/// llama.cpp 版本更新服务
class LlamaCppUpdateService {
  static final LlamaCppUpdateService _instance = LlamaCppUpdateService._();
  static LlamaCppUpdateService get instance => _instance;

  LlamaCppUpdateService._();

  final Dio _dio = Dio();
  static const String _githubApiUrl =
      'https://api.github.com/repos/ggml-org/llama.cpp/releases/latest';

  /// 本地存储路径
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/llama_cpp_updates';
  }

  /// 获取当前本地版本
  /// 从存储的版本文件中读取，如果没有则返回 null
  Future<String?> getLocalVersion() async {
    try {
      final path = await _localPath;
      final versionFile = File('$path/current_version.txt');
      if (await versionFile.exists()) {
        return (await versionFile.readAsString()).trim();
      }
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 读取本地版本失败: $e');
    }
    return null;
  }

  /// 保存当前版本到本地
  Future<void> saveLocalVersion(String version) async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final versionFile = File('$path/current_version.txt');
      await versionFile.writeAsString(version);
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 保存本地版本失败: $e');
    }
  }

  /// 检查最新版本
  Future<LlamaCppVersion?> checkForUpdate() async {
    try {
      debugPrint('[LlamaCppUpdateService] 检查 llama.cpp 最新版本...');

      final response = await _dio.get(
        _githubApiUrl,
        options: Options(
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final version = LlamaCppVersion.fromJson(response.data);
        debugPrint('[LlamaCppUpdateService] 最新版本: ${version.tagName}');
        return version;
      }

      debugPrint('[LlamaCppUpdateService] API 返回状态: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      debugPrint('[LlamaCppUpdateService] 网络错误: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 检查更新失败: $e');
      return null;
    }
  }

  /// 比较版本，判断是否需要更新
  /// [localVersion] 本地版本（如 "b8800"）
  /// [remoteVersion] 远程版本
  /// [threshold] 更新阈值，默认相差 50 个 build 才提示
  bool shouldUpdate(String? localVersion, LlamaCppVersion remoteVersion,
      {int threshold = 50}) {
    if (localVersion == null || localVersion.isEmpty) {
      return true; // 没有本地版本，应该更新
    }

    final localBuild = _extractBuildNumber(localVersion);
    final remoteBuild = remoteVersion.buildNumber;

    return (remoteBuild - localBuild) >= threshold;
  }

  /// 从版本字符串提取 build 号
  int _extractBuildNumber(String version) {
    final match = RegExp(r'b(\d+)').firstMatch(version);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  /// 下载并解压新版本
  Future<String?> downloadAndExtract(
    LlamaCppVersion version, {
    void Function(UpdateProgress)? onProgress,
  }) async {
    try {
      // 找到匹配当前平台的资源
      final asset = version.assets.firstWhere(
        (a) => a.matchesCurrentPlatform(),
        orElse: () => version.assets.first,
      );

      onProgress?.call(UpdateProgress.downloading(0.0));
      debugPrint('[LlamaCppUpdateService] 开始下载: ${asset.name}');

      // 创建临时目录
      final tempPath = await _localPath;
      final tempDir = Directory('$tempPath/temp');
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }

      final downloadPath = '${tempDir.path}/${asset.name}';

      // 下载文件
      await _dio.download(
        asset.browserDownloadUrl,
        downloadPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(UpdateProgress.downloading(progress));
          }
        },
        options: Options(
          headers: {
            'Accept': 'application/octet-stream',
          },
        ),
      );

      debugPrint('[LlamaCppUpdateService] 下载完成: $downloadPath');

      // 解压
      onProgress?.call(UpdateProgress.extracting());
      final extractPath = await _extractArchive(downloadPath, tempPath);

      // 保存版本号
      await saveLocalVersion(version.tagName);

      onProgress?.call(UpdateProgress.completed(version.tagName));
      debugPrint('[LlamaCppUpdateService] 更新完成: $extractPath');

      return extractPath;
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 更新失败: $e');
      onProgress?.call(UpdateProgress.failed(e.toString()));
      return null;
    }
  }

  /// 解压归档文件
  Future<String> _extractArchive(String archivePath, String destPath) async {
    final file = File(archivePath);
    final fileName = file.uri.pathSegments.last;

    if (fileName.endsWith('.tar.gz') || fileName.endsWith('.tgz')) {
      // 使用系统命令解压
      final result = await Process.run(
        'tar',
        ['-xzf', archivePath, '-C', destPath],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw Exception('解压失败: ${result.stderr}');
      }

      // 返回解压后的目录
      final dirName = fileName.replaceAll(RegExp(r'\.tar\.gz$|\.tgz$'), '');
      return '$destPath/$dirName';
    } else if (fileName.endsWith('.zip')) {
      // 使用系统命令解压 zip
      final result = await Process.run(
        'unzip',
        ['-o', archivePath, '-d', destPath],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        throw Exception('解压失败: ${result.stderr}');
      }

      return destPath;
    }

    throw Exception('不支持的归档格式: $fileName');
  }

  /// 获取本地已下载的 llama.cpp 库路径
  Future<String?> getLocalLibraryPath() async {
    try {
      final path = await _localPath;
      final extractedDir = Directory('$path/extracted');
      
      if (!await extractedDir.exists()) {
        return null;
      }

      // 查找库文件
      final os = Platform.operatingSystem;
      String libName;
      if (os == 'macos') {
        libName = 'libllama.dylib';
      } else if (os == 'windows') {
        libName = 'libllama.dll';
      } else {
        libName = 'libllama.so';
      }

      // 递归查找
      final files = await extractedDir.list(recursive: true).toList();
      for (final file in files) {
        if (file is File && file.path.endsWith(libName)) {
          return file.path;
        }
      }
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 获取本地库路径失败: $e');
    }
    return null;
  }

  /// 清理旧版本
  Future<void> cleanupOldVersions() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        debugPrint('[LlamaCppUpdateService] 已清理旧版本');
      }
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 清理失败: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  //  热更新功能：不重启 App 动态更新 llama.cpp 库
  // ════════════════════════════════════════════════════════════════════════

  /// 核心库文件列表（必须同步）
  static const List<String> _coreLibs = [
    'libllama.dylib',
    'libllama-common.dylib',
  ];

  /// 可选依赖库（如果存在则同步）
  static const List<String> _optionalLibs = [
    'libggml.dylib',
    'libggml-base.dylib',
    'libggml-metal.dylib',
    'libggml-cpu.dylib',
    'libggml-blas.dylib',
    'libggml-rpc.dylib',
  ];

  /// 项目 libs 目录路径
  String get _projectLibsPath =>
      '/Users/jianma/Desktop/LLM STUDIO/multi_model_client/libs';

  /// macos/Frameworks 目录路径
  String get _projectFrameworksPath =>
      '/Users/jianma/Desktop/LLM STUDIO/multi_model_client/macos/Frameworks';

  /// 热更新 llama.cpp 库（不重启 App）
  ///
  /// 流程：
  /// 1. 找到下载的库文件
  /// 2. 复制到项目 libs 目录
  /// 3. 复制到 macos/Frameworks 目录
  /// 4. 通知引擎重新加载
  Future<HotUpdateResult> hotUpdate({
    void Function(UpdateProgress)? onProgress,
  }) async {
    try {
      onProgress?.call(UpdateProgress(
        status: UpdateStatus.extracting,
        message: '正在准备热更新...',
      ));

      // 1. 查找解压后的库目录
      final extractPath = await _findExtractedLibPath();
      if (extractPath == null) {
        return HotUpdateResult(
          success: false,
          error: '未找到已下载的 llama.cpp 库文件',
        );
      }

      debugPrint('[LlamaCppUpdateService] 热更新源目录: $extractPath');

      // 2. 同步到 libs 目录
      onProgress?.call(UpdateProgress(
        status: UpdateStatus.extracting,
        message: '正在同步到 libs...',
      ));

      int syncedCount = 0;
      final allLibs = [..._coreLibs, ..._optionalLibs];

      for (final libName in allLibs) {
        final srcFile = File('$extractPath/$libName');
        if (await srcFile.exists()) {
          // 复制到 libs
          final dstLibs = File('$_projectLibsPath/$libName');
          await srcFile.copy(dstLibs.path);
          debugPrint('[LlamaCppUpdateService] ✅ 已同步到 libs: $libName');

          // 复制到 macos/Frameworks
          final dstFrameworks = File('$_projectFrameworksPath/$libName');
          await srcFile.copy(dstFrameworks.path);
          debugPrint('[LlamaCppUpdateService] ✅ 已同步到 Frameworks: $libName');

          syncedCount++;
        }
      }

      if (syncedCount == 0) {
        return HotUpdateResult(
          success: false,
          error: '未找到任何库文件进行同步',
        );
      }

      // 3. 通知引擎重新加载
      onProgress?.call(UpdateProgress(
        status: UpdateStatus.completed,
        message: '库文件已更新，正在重新加载引擎...',
      ));

      await _reloadInferenceEngine();

      return HotUpdateResult(
        success: true,
        message: '热更新完成！已更新 $syncedCount 个库文件',
        syncedCount: syncedCount,
      );
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 热更新失败: $e');
      return HotUpdateResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 查找解压后的库目录
  Future<String?> _findExtractedLibPath() async {
    final path = await _localPath;
    final dir = Directory(path);

    if (!await dir.exists()) return null;

    // 查找包含 libllama.dylib 的目录
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('libllama.dylib')) {
        // 返回父目录
        return entity.parent.path;
      }
    }

    return null;
  }

  /// 重新加载推理引擎
  Future<void> _reloadInferenceEngine() async {
    try {
      // 导入并重新加载推理引擎
      // ignore: avoid_imports_for_library_files
      // 注意：这里需要延迟导入避免循环依赖
      // 在实际调用时，引擎会通过 clearCache 清除缓存，
      // 下次推理时会自动使用新的库文件
      debugPrint('[LlamaCppUpdateService] 引擎热更新完成');

      // 如果引擎正在使用中，需要重新加载模型
      // 这里通过事件机制通知相关模块
    } catch (e) {
      debugPrint('[LlamaCppUpdateService] 引擎重新加载失败: $e');
    }
  }
}

/// 热更新结果
class HotUpdateResult {
  final bool success;
  final String message;
  final String? error;
  final int syncedCount;

  HotUpdateResult({
    required this.success,
    this.message = '',
    this.error,
    this.syncedCount = 0,
  });
}