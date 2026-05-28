/// 多模态插件按需下载服务 - LLM Studio 插件管理模块
/// 
/// 功能：
/// - 检测多模态功能所需的插件/模型是否已下载
/// - 按需下载插件和模型（首次使用时触发）
/// - 集成到现有下载管理页面
/// - 支持下载进度追踪
/// - 与语音设置的 ASR/TTS 模型管理整合
/// 
/// 插件类型：
/// - OCR: 图片文字识别（iOS Vision / Android ML Kit）
/// - AudioExtractor: 视频音频提取
/// - ASR: 语音识别模型
/// - TTS: 语音合成模型
/// 
/// @author Jianma
/// @version 1.0.0
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 插件类型
enum PluginType {
  ocr,           // 图片 OCR 识别
  audioExtractor, // 视频音频提取
  asrModel,      // ASR 语音识别模型
  ttsModel,      // TTS 语音合成模型
}

/// 插件平台支持
class PluginPlatformSupport {
  final bool ios;
  final bool android;
  final bool macos;
  final bool windows;
  final bool linux;

  const PluginPlatformSupport({
    this.ios = true,
    this.android = true,
    this.macos = true,
    this.windows = true,
    this.linux = true,
  });

  bool get isSupported {
    if (Platform.isIOS) return ios;
    if (Platform.isAndroid) return android;
    if (Platform.isMacOS) return macos;
    if (Platform.isWindows) return windows;
    if (Platform.isLinux) return linux;
    return false;
  }
}

/// 插件信息
class PluginInfo {
  final String id;
  final String name;
  final String description;
  final PluginType type;
  final String downloadUrl;
  final List<String> mirrorUrls; // 国内镜像地址列表（按优先级排序）
  final int fileSize; // bytes
  final String? checksum;
  final PluginPlatformSupport platformSupport;
  final bool isBuiltIn; // 是否内置（系统原生 API，无需下载）
  final String? requiredSetting; // 关联的设置项（如 "voice_asr"）

  const PluginInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.downloadUrl = '',
    this.mirrorUrls = const [],
    this.fileSize = 0,
    this.checksum,
    this.platformSupport = const PluginPlatformSupport(),
    this.isBuiltIn = false,
    this.requiredSetting,
  });

  /// 获取所有可用的下载链接（原始地址 + 镜像地址）
  List<String> get allDownloadUrls => [downloadUrl, ...mirrorUrls].where((u) => u.isNotEmpty).toList();
}

/// 插件下载状态
enum PluginDownloadStatus {
  notDownloaded, // 未下载
  downloading,   // 下载中
  downloaded,    // 已下载
  error,         // 错误
}

/// 插件状态
class PluginStatus {
  final String pluginId;
  final PluginDownloadStatus status;
  final double progress; // 0.0 - 1.0
  final String? localPath;
  final String? errorMessage;
  final int downloadedBytes;
  final int totalBytes;

  const PluginStatus({
    required this.pluginId,
    required this.status,
    this.progress = 0.0,
    this.localPath,
    this.errorMessage,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
  });

  PluginStatus copyWith({
    String? pluginId,
    PluginDownloadStatus? status,
    double? progress,
    String? localPath,
    String? errorMessage,
    int? downloadedBytes,
    int? totalBytes,
  }) {
    return PluginStatus(
      pluginId: pluginId ?? this.pluginId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      localPath: localPath ?? this.localPath,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }

  /// 获取人类可读的进度文本
  String get progressText {
    switch (status) {
      case PluginDownloadStatus.notDownloaded:
        return '未下载';
      case PluginDownloadStatus.downloading:
        return '${(progress * 100).toInt()}%';
      case PluginDownloadStatus.downloaded:
        return '已下载';
      case PluginDownloadStatus.error:
        return '错误: $errorMessage';
    }
  }
}

/// 多模态插件按需下载服务
/// 
/// 使用方式：
/// 1. 用户上传文件时，调用 checkAndDownloadPlugin() 检测并下载
/// 2. 或者在设置页面展示所有插件状态，供用户手动管理
class PluginDownloadService {
  static PluginDownloadService? _instance;
  static PluginDownloadService get instance => _instance ??= PluginDownloadService._();
  PluginDownloadService._();

  /// Dio 实例
  final Dio _dio = Dio();

  /// 下载任务管理
  final Map<String, CancelToken> _cancelTokens = {};

  /// 插件状态缓存
  final Map<String, PluginStatus> _pluginStatus = {};

  /// SharedPreferences key
  static const String _downloadedKey = 'plugin_downloaded_';
  static const String _localPathKey = 'plugin_local_path_';

  /// 资源目录
  String? _resourcesDir;

  /// 获取资源目录
  Future<String> get resourcesDir async {
    if (_resourcesDir != null) return _resourcesDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _resourcesDir = '${appDir.path}/plugins';
    final dir = Directory(_resourcesDir!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _resourcesDir!;
  }

  /// 获取所有可用插件列表
  List<PluginInfo> getAvailablePlugins() {
    return [
      // OCR - 系统内置，无需下载
      const PluginInfo(
        id: 'ocr',
        name: '文字识别 (OCR)',
        description: '识别图片中的文字。iOS 使用 Vision 框架，Android 使用 ML Kit（通过 Play Services 自动下载模型）',
        type: PluginType.ocr,
        isBuiltIn: true,
        platformSupport: PluginPlatformSupport(ios: true, android: true, macos: true, windows: true, linux: true),
      ),
      
      // 视频音频提取 - 系统内置
      const PluginInfo(
        id: 'audio_extractor',
        name: '视频音频提取',
        description: '从视频中提取音频轨道。iOS 使用 AVFoundation，Android 使用 MediaExtractor',
        type: PluginType.audioExtractor,
        isBuiltIn: true,
        platformSupport: PluginPlatformSupport(ios: true, android: true, macos: true, windows: false, linux: false),
      ),
      
      // ASR 模型 - 需要下载
      // 国内镜像：ModelScope (魔搭社区)
      const PluginInfo(
        id: 'asr_sensevoice',
        name: '语音识别 (SenseVoice)',
        description: '阿里 SenseVoice 语音识别模型，支持中/英/日/韩/粤五语，约 158MB',
        type: PluginType.asrModel,
        downloadUrl: 'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
        mirrorUrls: [
          // ModelScope 魔搭社区镜像（推荐国内用户）
          'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
          // 备用：hf-mirror.com 镜像
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09/resolve/main/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
        ],
        fileSize: 158000000,
        platformSupport: PluginPlatformSupport(ios: true, android: true, macos: true, windows: true, linux: true),
        requiredSetting: 'voice_asr',
      ),
      
      const PluginInfo(
        id: 'asr_paraformer',
        name: '语音识别 (Paraformer)',
        description: '阿里 Paraformer 中文语音识别模型，约 48MB',
        type: PluginType.asrModel,
        downloadUrl: 'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-paraformer-zh-2024-09-01.tar.bz2',
        mirrorUrls: [
          // ModelScope 魔搭社区镜像
          'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-paraformer-zh-2024-09-01.tar.bz2',
          // 备用：hf-mirror.com 镜像
          'https://hf-mirror.com/csukuangfj/sherpa-onnx-paraformer-zh-2024-09-01/resolve/main/sherpa-onnx-paraformer-zh-2024-09-01.tar.bz2',
        ],
        fileSize: 48000000,
        platformSupport: PluginPlatformSupport(ios: true, android: true, macos: true, windows: true, linux: true),
        requiredSetting: 'voice_asr',
      ),
      
      // TTS 模型 - 需要下载
      // CosyVoice 本身就在 ModelScope 上，优先使用镜像
      const PluginInfo(
        id: 'tts_cosyvoice',
        name: '语音合成 (CosyVoice)',
        description: '阿里 CosyVoice 多音色语音合成模型，约 100MB',
        type: PluginType.ttsModel,
        downloadUrl: 'https://github.com/modelscope/speech-cosyvoice-onnx/releases/download/V1.0/cosyvoice-onnx.tar.bz2',
        mirrorUrls: [
          // ModelScope 魔搭社区镜像（优先，下载更快）
          'https://modelscope.cn/models/iic/speech-cosyvoice-onnx/resolve/master/cosyvoice-onnx.tar.bz2',
        ],
        fileSize: 100000000,
        platformSupport: PluginPlatformSupport(ios: true, android: true, macos: true, windows: true, linux: true),
        requiredSetting: 'voice_tts',
      ),
    ];
  }

  /// 根据类型获取插件列表
  List<PluginInfo> getPluginsByType(PluginType type) {
    return getAvailablePlugins().where((p) => p.type == type).toList();
  }

  /// 检查插件是否已下载
  Future<bool> isPluginDownloaded(String pluginId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_downloadedKey$pluginId') ?? false;
  }

  /// 获取插件本地路径
  Future<String?> getPluginLocalPath(String pluginId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_localPathKey$pluginId');
  }

  /// 获取插件状态
  Future<PluginStatus> getPluginStatus(String pluginId) async {
    if (_pluginStatus.containsKey(pluginId)) {
      return _pluginStatus[pluginId]!;
    }

    final plugin = getAvailablePlugins().firstWhere(
      (p) => p.id == pluginId,
      orElse: () => PluginInfo(
        id: pluginId,
        name: pluginId,
        description: '',
        type: PluginType.ocr,
      ),
    );

    // 内置插件直接返回已下载
    if (plugin.isBuiltIn) {
      return PluginStatus(
        pluginId: pluginId,
        status: PluginDownloadStatus.downloaded,
        localPath: 'built-in',
      );
    }

    // 检查是否已下载
    final downloaded = await isPluginDownloaded(pluginId);
    final localPath = downloaded ? await getPluginLocalPath(pluginId) : null;
    
    final status = downloaded && localPath != null
        ? PluginDownloadStatus.downloaded
        : PluginDownloadStatus.notDownloaded;

    return PluginStatus(
      pluginId: pluginId,
      status: status,
      localPath: localPath,
      totalBytes: plugin.fileSize,
    );
  }

  /// 下载插件（支持镜像自动回退）
  /// 
  /// [pluginId] 插件 ID
  /// [onProgress] 进度回调 (status, progress, downloaded, total)
  Future<PluginStatus> downloadPlugin(
    String pluginId, {
    void Function(String status, double progress, int downloaded, int total)? onProgress,
  }) async {
    final plugin = getAvailablePlugins().firstWhere(
      (p) => p.id == pluginId,
      orElse: () => throw Exception('未找到插件: $pluginId'),
    );

    // 内置插件直接返回
    if (plugin.isBuiltIn) {
      return PluginStatus(
        pluginId: pluginId,
        status: PluginDownloadStatus.downloaded,
        localPath: 'built-in',
      );
    }

    // 检查是否已下载
    final alreadyDownloaded = await isPluginDownloaded(pluginId);
    if (alreadyDownloaded) {
      final localPath = await getPluginLocalPath(pluginId);
      return PluginStatus(
        pluginId: pluginId,
        status: PluginDownloadStatus.downloaded,
        localPath: localPath,
        totalBytes: plugin.fileSize,
      );
    }

    // 开始下载
    _pluginStatus[pluginId] = PluginStatus(
      pluginId: pluginId,
      status: PluginDownloadStatus.downloading,
      progress: 0.0,
      totalBytes: plugin.fileSize,
    );
    onProgress?.call('准备下载...', 0.0, 0, plugin.fileSize);

    // 获取所有可用的下载链接（原始 + 镜像）
    final allUrls = plugin.allDownloadUrls;
    String? lastError;
    
    // 尝试每个下载链接
    for (int urlIndex = 0; urlIndex < allUrls.length; urlIndex++) {
      final downloadUrl = allUrls[urlIndex];
      final isMirror = urlIndex > 0;
      final sourceName = isMirror ? '镜像$urlIndex' : '官方';
      
      debugPrint('[PluginDownloadService] 尝试从 $sourceName 下载: $downloadUrl');
      onProgress?.call('正在连接 $sourceName...', 0.05, 0, plugin.fileSize);

      try {
        final dir = await resourcesDir;
        final fileName = downloadUrl.split('/').last;
        final targetPath = '$dir/$fileName';
        
        // 创建 CancelToken
        final cancelToken = CancelToken();
        _cancelTokens[pluginId] = cancelToken;

        // 下载文件
        onProgress?.call('$sourceName 下载中...', 0.1, 0, plugin.fileSize);
        
        await _dio.download(
          downloadUrl,
          targetPath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              _pluginStatus[pluginId] = _pluginStatus[pluginId]!.copyWith(
                progress: progress,
                downloadedBytes: received,
              );
              onProgress?.call('$sourceName 下载中 ${(progress * 100).toInt()}%', progress, received, total);
            }
          },
        );

        // 下载完成
        final successMsg = isMirror ? '下载完成（使用镜像加速）' : '下载完成';
        onProgress?.call(successMsg, 1.0, plugin.fileSize, plugin.fileSize);
        
        // 标记已下载
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('$_downloadedKey$pluginId', true);
        await prefs.setString('$_localPathKey$pluginId', targetPath);
        
        final status = PluginStatus(
          pluginId: pluginId,
          status: PluginDownloadStatus.downloaded,
          progress: 1.0,
          localPath: targetPath,
          totalBytes: plugin.fileSize,
        );
        
        _pluginStatus[pluginId] = status;
        _cancelTokens.remove(pluginId);
        
        debugPrint('[PluginDownloadService] ✅ $pluginId 下载成功（来源: $sourceName）');
        return status;
        
      } catch (e) {
        lastError = e.toString();
        
        // 如果是用户主动取消，不尝试其他镜像
        if (e is DioException && e.type == DioExceptionType.cancel) {
          debugPrint('[PluginDownloadService] 下载取消: $pluginId');
          break;
        }
        
        debugPrint('[PluginDownloadService] ⚠️ $sourceName 下载失败: $e');
        
        // 继续尝试下一个镜像
        if (urlIndex < allUrls.length - 1) {
          onProgress?.call('源下载失败，尝试镜像...', 0.05, 0, plugin.fileSize);
        }
      }
    }
    
    // 所有镜像都失败
    debugPrint('[PluginDownloadService] ❌ $pluginId 所有下载源都失败: $lastError');
    
    final status = PluginStatus(
      pluginId: pluginId,
      status: PluginDownloadStatus.error,
      errorMessage: '所有下载源都失败: $lastError',
      totalBytes: plugin.fileSize,
    );
    
    _pluginStatus[pluginId] = status;
    _cancelTokens.remove(pluginId);
    return status;
  }

  /// 取消下载
  Future<void> cancelDownload(String pluginId) async {
    final cancelToken = _cancelTokens[pluginId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('用户取消下载');
    }
  }

  /// 删除插件
  Future<void> deletePlugin(String pluginId) async {
    final localPath = await getPluginLocalPath(pluginId);
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_downloadedKey$pluginId');
    await prefs.remove('$_localPathKey$pluginId');
    
    _pluginStatus.remove(pluginId);
    debugPrint('[PluginDownloadService] 已删除插件: $pluginId');
  }

  /// 检测并下载所需插件
  /// 
  /// 根据媒体类型自动检测所需插件
  /// [mediaType] 媒体类型 (video, audio, image, document)
  /// [onProgress] 进度回调
  Future<PluginStatus> checkAndDownloadForMedia(
    String mediaType, {
    void Function(String status, double progress, int downloaded, int total)? onProgress,
  }) async {
    String? requiredPluginId;
    
    switch (mediaType.toLowerCase()) {
      case 'video':
      case 'audio':
        // 音频/视频需要 ASR 模型
        requiredPluginId = 'asr_sensevoice'; // 默认使用 SenseVoice
        break;
      case 'image':
        // 图片需要 OCR（内置）
        return PluginStatus(
          pluginId: 'ocr',
          status: PluginDownloadStatus.downloaded,
          localPath: 'built-in',
        );
      case 'document':
        // 文档不需要额外插件
        return PluginStatus(
          pluginId: 'document',
          status: PluginDownloadStatus.downloaded,
          localPath: 'built-in',
        );
      default:
        throw Exception('未知的媒体类型: $mediaType');
    }

    // 检查插件状态
    final status = await getPluginStatus(requiredPluginId);
    
    if (status.status == PluginDownloadStatus.downloaded) {
      return status;
    }

    // 需要下载
    return await downloadPlugin(requiredPluginId, onProgress: onProgress);
  }

  /// 获取所有插件状态
  Future<List<PluginStatus>> getAllPluginStatus() async {
    final plugins = getAvailablePlugins();
    final statuses = <PluginStatus>[];
    
    for (final plugin in plugins) {
      final status = await getPluginStatus(plugin.id);
      statuses.add(status);
    }
    
    return statuses;
  }

  /// 获取需要下载的插件（按类型）
  Future<List<PluginInfo>> getRequiredPluginsForType(PluginType type) async {
    final plugins = getPluginsByType(type);
    final required = <PluginInfo>[];
    
    for (final plugin in plugins) {
      final status = await getPluginStatus(plugin.id);
      if (status.status != PluginDownloadStatus.downloaded) {
        required.add(plugin);
      }
    }
    
    return required;
  }

  /// 重置所有插件状态
  Future<void> resetAllPlugins() async {
    final prefs = await SharedPreferences.getInstance();
    
    final keys = prefs.getKeys()
        .where((k) => k.startsWith(_downloadedKey) || k.startsWith(_localPathKey))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    _pluginStatus.clear();
    
    final dir = Directory(await resourcesDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    
    debugPrint('[PluginDownloadService] 已重置所有插件');
  }
}