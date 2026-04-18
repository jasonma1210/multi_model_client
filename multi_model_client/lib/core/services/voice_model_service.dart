/// 语音模型服务 - LLM Studio 语音模型管理模块
/// 
/// 功能：
/// - ASR/TTS 模型下载管理
/// - 模型版本控制
/// - 断点续传下载
/// - 多平台模型适配
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语音模型类型
enum VoiceModelType {
  asr, // 语音识别
  tts, // 语音合成
}

/// 语音模型信息
class VoiceModelInfo {
  final String id;
  final String name;
  final String description;
  final VoiceModelType type;
  final String version;
  final String downloadUrl;
  final String archiveName; // 下载后的文件名（含扩展名）
  final int fileSize; // bytes
  final String? checksum;
  final List<String> supportedPlatforms; // macos, ios, android, windows, linux
  final String? minVersion;
  // TTS 专有：支持的音色列表
  final List<Map<String, String>> voices;

  const VoiceModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.version,
    required this.downloadUrl,
    required this.archiveName,
    required this.fileSize,
    this.checksum,
    required this.supportedPlatforms,
    this.minVersion,
    this.voices = const [],
  });
}

/// 模型下载进度
class VoiceModelDownloadProgress {
  final String modelId;
  final int totalBytes;
  final int downloadedBytes;
  final double progress; // 0.0 - 1.0
  final String status; // idle, downloading, paused, completed, error
  final String? error;

  const VoiceModelDownloadProgress({
    required this.modelId,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    this.progress = 0.0,
    this.status = 'idle',
    this.error,
  });

  VoiceModelDownloadProgress copyWith({
    String? modelId,
    int? totalBytes,
    int? downloadedBytes,
    double? progress,
    String? status,
    String? error,
  }) {
    return VoiceModelDownloadProgress(
      modelId: modelId ?? this.modelId,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

/// 语音模型服务 - 管理 ASR/TTS 模型下载
class VoiceModelService {
  static final VoiceModelService _instance = VoiceModelService._internal();
  factory VoiceModelService() => _instance;
  VoiceModelService._internal();

  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, VoiceModelDownloadProgress> _downloadProgress = {};

  // 存储路径
  String? _modelsDir;

  /// 获取模型存储目录
  Future<String> get modelsDir async {
    if (_modelsDir != null) return _modelsDir!;

    final appDir = await getApplicationDocumentsDirectory();
    _modelsDir = '${appDir.path}/voice_models';

    final dir = Directory(_modelsDir!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return _modelsDir!;
  }

  /// 获取当前平台标识
  String get platform {
    if (Platform.isMacOS) return 'macos';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ASR 模型列表
  // 来源: https://github.com/k2-fsa/sherpa-onnx/releases/tag/asr-models
  // 均为 .tar.bz2 格式，全平台通用
  // ────────────────────────────────────────────────────────────────────────────
  static const List<VoiceModelInfo> asrModels = [
    // SenseVoice int8 量化版本（推荐：体积小，中英日韩粤五语）
    VoiceModelInfo(
      id: 'sensevoice-int8',
      name: 'SenseVoice Small (int8)',
      description: '阿里 SenseVoice 量化版，支持中/英/日/韩/粤五语，体积仅 158MB，推荐',
      type: VoiceModelType.asr,
      version: '2025-09-09',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
      archiveName:
          'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2',
      fileSize: 158000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
    // SenseVoice 完整版（精度更高）
    VoiceModelInfo(
      id: 'sensevoice',
      name: 'SenseVoice Small',
      description: '阿里 SenseVoice 完整版，支持中/英/日/韩/粤五语，识别精度更高，845MB',
      type: VoiceModelType.asr,
      version: '2025-09-09',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2025-09-09.tar.bz2',
      archiveName:
          'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2025-09-09.tar.bz2',
      fileSize: 845000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
    // Whisper Tiny（英文，最小）
    VoiceModelInfo(
      id: 'whisper-tiny-en',
      name: 'Whisper Tiny (英文)',
      description: 'OpenAI Whisper tiny 英文版，体积仅 112MB，英文识别速度快',
      type: VoiceModelType.asr,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-tiny.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-tiny.en.tar.bz2',
      fileSize: 112000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
    // Whisper Tiny 多语言
    VoiceModelInfo(
      id: 'whisper-tiny',
      name: 'Whisper Tiny (多语言)',
      description: 'OpenAI Whisper tiny 多语言版，体积 110MB，支持多国语言',
      type: VoiceModelType.asr,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-tiny.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-tiny.tar.bz2',
      fileSize: 110000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
    // Whisper Base 英文
    VoiceModelInfo(
      id: 'whisper-base-en',
      name: 'Whisper Base (英文)',
      description: 'OpenAI Whisper base 英文版，198MB，英文识别效果均衡',
      type: VoiceModelType.asr,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-base.en.tar.bz2',
      archiveName: 'sherpa-onnx-whisper-base.en.tar.bz2',
      fileSize: 198000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
    // Paraformer 中文小模型
    VoiceModelInfo(
      id: 'paraformer-zh-small',
      name: 'Paraformer-Small (中文)',
      description: 'Paraformer 中文小模型，仅 74MB，中文识别速度极快',
      type: VoiceModelType.asr,
      version: '2024-03-09',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-paraformer-zh-small-2024-03-09.tar.bz2',
      archiveName: 'sherpa-onnx-paraformer-zh-small-2024-03-09.tar.bz2',
      fileSize: 74000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
    // Paraformer 中文最新版（int8 量化）
    VoiceModelInfo(
      id: 'paraformer-zh-int8',
      name: 'Paraformer (中文 int8)',
      description: 'Paraformer 中文量化版 2025 最新，217MB，中文识别精度高',
      type: VoiceModelType.asr,
      version: '2025-10-07',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-paraformer-zh-int8-2025-10-07.tar.bz2',
      archiveName: 'sherpa-onnx-paraformer-zh-int8-2025-10-07.tar.bz2',
      fileSize: 217000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
    ),
  ];

  // ────────────────────────────────────────────────────────────────────────────
  // TTS 模型列表
  // 来源: https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models
  // 均为 .tar.bz2 格式，全平台通用
  // ────────────────────────────────────────────────────────────────────────────
  static const List<VoiceModelInfo> ttsModels = [
    // MeloTTS 中英双语（推荐）
    VoiceModelInfo(
      id: 'melo-zh-en',
      name: 'MeloTTS 中英双语（推荐）',
      description: 'MeloTTS 中英双语模型，159MB，支持普通话与英文，自然流畅',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-melo-tts-zh_en.tar.bz2',
      archiveName: 'vits-melo-tts-zh_en.tar.bz2',
      fileSize: 159000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': '中文女声', 'desc': '普通话，自然流畅'},
        {'id': '1', 'name': '英文女声', 'desc': '英式发音，清晰'},
      ],
    ),
    // VITS 中文（多音色，台湾 HuggingFace 风格）
    VoiceModelInfo(
      id: 'vits-zh-keqing',
      name: 'VITS 中文 - 刻晴',
      description: 'VITS 中文模型（刻晴音色），115MB，二次元风格清脆女声',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-keqing.tar.bz2',
      archiveName: 'vits-zh-hf-keqing.tar.bz2',
      fileSize: 115000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': '刻晴', 'desc': '清脆甜美，二次元风格'},
        {'id': '1', 'name': '刻晴2', 'desc': '稍低沉版本'},
        {'id': '2', 'name': '刻晴3', 'desc': '活泼版本'},
      ],
    ),
    // VITS 中文（echo 音色）
    VoiceModelInfo(
      id: 'vits-zh-echo',
      name: 'VITS 中文 - Echo',
      description: 'VITS 中文模型（Echo音色），114MB，自然温柔女声',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-echo.tar.bz2',
      archiveName: 'vits-zh-hf-echo.tar.bz2',
      fileSize: 114000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': 'Echo 1', 'desc': '自然温柔'},
        {'id': '1', 'name': 'Echo 2', 'desc': '稍活泼'},
        {'id': '2', 'name': 'Echo 3', 'desc': '成熟稳重'},
      ],
    ),
    // VITS 中文（eula 音色，知性女声）
    VoiceModelInfo(
      id: 'vits-zh-eula',
      name: 'VITS 中文 - Eula',
      description: 'VITS 中文模型（Eula音色），114MB，知性成熟女声',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-eula.tar.bz2',
      archiveName: 'vits-zh-hf-eula.tar.bz2',
      fileSize: 114000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': 'Eula 1', 'desc': '知性成熟'},
        {'id': '1', 'name': 'Eula 2', 'desc': '温柔版本'},
        {'id': '2', 'name': 'Eula 3', 'desc': '活泼版本'},
      ],
    ),
    // VITS 中文（bronya 音色，深沉男声）
    VoiceModelInfo(
      id: 'vits-zh-bronya',
      name: 'VITS 中文 - Bronya',
      description: 'VITS 中文模型（Bronya音色），115MB，沉稳冷静风格',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-bronya.tar.bz2',
      archiveName: 'vits-zh-hf-bronya.tar.bz2',
      fileSize: 115000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': 'Bronya 1', 'desc': '冷静沉稳'},
        {'id': '1', 'name': 'Bronya 2', 'desc': '温和版本'},
      ],
    ),
    // VITS 中文 AiShell3（多说话人，174个音色）
    VoiceModelInfo(
      id: 'vits-zh-aishell3',
      name: 'VITS 中文 AiShell3',
      description: 'VITS 中文 AiShell3 数据集，140MB，174个不同说话人音色',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-aishell3.tar.bz2',
      archiveName: 'vits-zh-aishell3.tar.bz2',
      fileSize: 140000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': '说话人 0', 'desc': '女声'},
        {'id': '1', 'name': '说话人 1', 'desc': '男声'},
        {'id': '10', 'name': '说话人 10', 'desc': '中性'},
        {'id': '100', 'name': '说话人 100', 'desc': '更多音色见文档'},
      ],
    ),
    // VITS 粤语
    VoiceModelInfo(
      id: 'vits-cantonese',
      name: 'VITS 粤语',
      description: 'VITS 粤语合成模型，102MB，广东话合成',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-cantonese-hf-xiaomaiiwn.tar.bz2',
      archiveName: 'vits-cantonese-hf-xiaomaiiwn.tar.bz2',
      fileSize: 102000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': '粤语女声', 'desc': '标准广东话'},
      ],
    ),
    // MeloTTS 英文
    VoiceModelInfo(
      id: 'melo-en',
      name: 'MeloTTS 英文',
      description: 'MeloTTS 英文模型，155MB，自然英语语音合成',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-melo-tts-en.tar.bz2',
      archiveName: 'vits-melo-tts-en.tar.bz2',
      fileSize: 155000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': '英文女声', 'desc': '自然英文'},
        {'id': '1', 'name': '英文男声', 'desc': '清晰英文'},
      ],
    ),
    // VITS Piper 英文 LJSpeech（高质量）
    VoiceModelInfo(
      id: 'vits-en-ljspeech',
      name: 'VITS Piper English (LJSpeech)',
      description: 'VITS Piper 英文 LJSpeech 模型，110MB，高品质英文朗读声',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-coqui-en-ljspeech.tar.bz2',
      archiveName: 'vits-coqui-en-ljspeech.tar.bz2',
      fileSize: 110000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': 'LJSpeech', 'desc': '经典英文朗读，清晰自然'},
      ],
    ),
  ];

  /// 获取 ASR 模型列表（过滤当前平台）
  List<VoiceModelInfo> getAsrModels() {
    return asrModels
        .where((m) => m.supportedPlatforms.contains(platform))
        .toList();
  }

  /// 获取 TTS 模型列表（过滤当前平台）
  List<VoiceModelInfo> getTtsModels() {
    return ttsModels
        .where((m) => m.supportedPlatforms.contains(platform))
        .toList();
  }

  /// 根据 TTS 模型 ID 获取音色列表
  List<Map<String, String>> getTtsVoices(String ttsModelId) {
    final model = ttsModels.where((m) => m.id == ttsModelId).firstOrNull;
    if (model != null && model.voices.isNotEmpty) {
      return model.voices;
    }
    // 默认 OpenAI 兼容音色（当 TTS Provider 为 openai 时）
    return const [
      {'id': 'alloy', 'name': 'Alloy', 'desc': '中性、通用'},
      {'id': 'echo', 'name': 'Echo', 'desc': '清晰、温暖'},
      {'id': 'fable', 'name': 'Fable', 'desc': '故事感、富有表现力'},
      {'id': 'onyx', 'name': 'Onyx', 'desc': '低沉、严肃'},
      {'id': 'nova', 'name': 'Nova', 'desc': '活泼、年轻'},
      {'id': 'shimmer', 'name': 'Shimmer', 'desc': '柔和、优雅'},
    ];
  }

  /// 获取已安装的模型版本
  Future<String?> getInstalledVersion(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('voice_model_version_$modelId');
  }

  /// 检查是否有新版本可用
  Future<bool> hasNewVersion(String modelId) async {
    final installedVersion = await getInstalledVersion(modelId);
    if (installedVersion == null) return false; // 未安装则不显示"有新版本"

    final allModels = [...asrModels, ...ttsModels];
    final model = allModels.where((m) => m.id == modelId).firstOrNull;
    if (model == null) return false;

    return installedVersion != model.version;
  }

  /// 获取下载进度
  VoiceModelDownloadProgress? getDownloadProgress(String modelId) {
    return _downloadProgress[modelId];
  }

  /// 下载模型（支持断点续传）
  ///
  /// 文件格式：.tar.bz2（sherpa-onnx 全部使用此格式）
  /// 下载到 <modelsDir>/<modelId>/<archiveName>
  Future<void> downloadModel({
    required String modelId,
    required Function(VoiceModelDownloadProgress) onProgress,
  }) async {
    final allModels = [...asrModels, ...ttsModels];
    final model = allModels.where((m) => m.id == modelId).firstOrNull;
    if (model == null) throw Exception('Model not found: $modelId');

    final dir = await modelsDir;
    final modelDir = '$dir/$modelId';
    final archivePath = '$modelDir/${model.archiveName}';

    // 确保目录存在
    final modelDirectory = Directory(modelDir);
    if (!await modelDirectory.exists()) {
      await modelDirectory.create(recursive: true);
    }

    // 取消之前的下载（如有）
    _cancelTokens[modelId]?.cancel('restart');
    final cancelToken = CancelToken();
    _cancelTokens[modelId] = cancelToken;

    // 初始化进度
    _downloadProgress[modelId] = VoiceModelDownloadProgress(
      modelId: modelId,
      status: 'downloading',
    );
    onProgress(_downloadProgress[modelId]!);

    try {
      // 检查已下载的字节数（断点续传）
      int downloadedBytes = 0;
      final archiveFile = File(archivePath);
      if (await archiveFile.exists()) {
        downloadedBytes = await archiveFile.length();
      }

      // 配置下载选项
      final options = Options(
        receiveTimeout: const Duration(minutes: 30),
        headers: downloadedBytes > 0
            ? {'Range': 'bytes=$downloadedBytes-'}
            : null,
        responseType: ResponseType.stream,
      );

      // 执行下载
      await _dio.download(
        model.downloadUrl,
        archivePath,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final actualTotal =
              total > 0 ? (downloadedBytes + total) : model.fileSize;
          final actualReceived = downloadedBytes + received;
          final progress =
              actualTotal > 0 ? actualReceived / actualTotal : 0.0;

          _downloadProgress[modelId] = VoiceModelDownloadProgress(
            modelId: modelId,
            totalBytes: actualTotal,
            downloadedBytes: actualReceived,
            progress: progress.clamp(0.0, 1.0),
            status: 'downloading',
          );
          onProgress(_downloadProgress[modelId]!);
        },
        deleteOnError: false,
      );

      // 下载完成，开始解压
      _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
        progress: 1.0,
        status: 'extracting',
        downloadedBytes: model.fileSize,
        totalBytes: model.fileSize,
      );
      onProgress(_downloadProgress[modelId]!);

      // 解压 tar.bz2
      try {
        await _extractTarBz2(archivePath, modelDir);
        // 解压成功后删除压缩包（节省空间）
        final archiveFile = File(archivePath);
        if (await archiveFile.exists()) {
          await archiveFile.delete();
        }
      } catch (e) {
        _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
          status: 'error',
          error: '解压失败: $e',
        );
        onProgress(_downloadProgress[modelId]!);
        rethrow;
      }

      _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
        status: 'completed',
      );
      onProgress(_downloadProgress[modelId]!);

      // 保存版本信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('voice_model_version_$modelId', model.version);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _downloadProgress[modelId] = (_downloadProgress[modelId] ??
                VoiceModelDownloadProgress(modelId: modelId))
            .copyWith(status: 'paused');
        onProgress(_downloadProgress[modelId]!);
      } else {
        _downloadProgress[modelId] = (_downloadProgress[modelId] ??
                VoiceModelDownloadProgress(modelId: modelId))
            .copyWith(
          status: 'error',
          error: '下载失败: ${e.message ?? e.type.name}',
        );
        onProgress(_downloadProgress[modelId]!);
        rethrow;
      }
    } catch (e) {
      _downloadProgress[modelId] = (_downloadProgress[modelId] ??
              VoiceModelDownloadProgress(modelId: modelId))
          .copyWith(
        status: 'error',
        error: e.toString(),
      );
      onProgress(_downloadProgress[modelId]!);
      rethrow;
    }
  }

  /// 暂停下载（取消 Dio 请求，保留已下载的文件支持续传）
  void pauseDownload(String modelId) {
    _cancelTokens[modelId]?.cancel('pause');
    if (_downloadProgress.containsKey(modelId)) {
      _downloadProgress[modelId] =
          _downloadProgress[modelId]!.copyWith(status: 'paused');
    }
  }

  /// 解压 tar.bz2 到目标目录
  Future<void> _extractTarBz2(String archivePath, String destDir) async {
    // macOS/Linux/iOS 使用系统 tar 命令
    if (Platform.isMacOS || Platform.isLinux || Platform.isIOS) {
      final result = await Process.run(
        'tar',
        ['-xjf', archivePath, '-C', destDir],
        runInShell: false,
      );
      if (result.exitCode != 0) {
        throw Exception('tar 解压失败 (exit ${result.exitCode}): ${result.stderr}');
      }
    } else if (Platform.isWindows) {
      // Windows 10 1903+ 内置 tar.exe，同样支持 bz2
      final result = await Process.run(
        'tar',
        ['-xjf', archivePath, '-C', destDir],
        runInShell: true,
      );
      if (result.exitCode != 0) {
        throw Exception('tar 解压失败 (exit ${result.exitCode}): ${result.stderr}');
      }
    } else if (Platform.isAndroid) {
      // Android 没有系统 tar，使用 Flutter isolate + dart:io 解包
      // 暂时只支持从外部工具解压
      throw UnimplementedError('Android 暂不支持 tar.bz2 解压，请手动解压后放入 voice_models 目录');
    }
  }

  /// 获取模型解压后的实际目录（解压后会有一层子目录）
  ///
  /// 例如 voice_models/melo-zh-en/ 下解压出 vits-melo-tts-zh_en/ 子目录
  Future<String?> getModelDirectory(String modelId) async {
    final dir = await modelsDir;
    final modelDir = Directory('$dir/$modelId');
    if (!await modelDir.exists()) return null;

    // 解压后的压缩包根目录：找到第一个子目录
    final entries = await modelDir.list().toList();
    for (final entry in entries) {
      if (entry is Directory) {
        return entry.path;
      }
    }
    // 没有子目录，说明直接解压在 modelDir 下
    return modelDir.path;
  }

  /// 在目录中找到 .onnx 文件路径
  /// 优先级：model.onnx > model.int8.onnx > 其他 .onnx
  Future<String?> findOnnxModel(String modelId) async {
    final dir = await getModelDirectory(modelId);
    if (dir == null) return null;

    // 收集所有 .onnx 文件
    final onnxFiles = <String>[];
    final directory = Directory(dir);
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.onnx')) {
          onnxFiles.add(entity.path);
        }
      }
    } catch (_) {}

    if (onnxFiles.isEmpty) return null;

    // 优先返回 model.onnx（非量化）
    final nonQuantized = onnxFiles.firstWhere(
      (p) => p.split(Platform.pathSeparator).last == 'model.onnx',
      orElse: () => '',
    );
    if (nonQuantized.isNotEmpty) return nonQuantized;

    // 其次 model.int8.onnx
    final int8 = onnxFiles.firstWhere(
      (p) => p.split(Platform.pathSeparator).last == 'model.int8.onnx',
      orElse: () => '',
    );
    if (int8.isNotEmpty) return int8;

    // 最后任意 .onnx
    return onnxFiles.first;
  }

  /// 在目录中找到 tokens.txt 路径
  Future<String?> findTokensFile(String modelId) async {
    final dir = await getModelDirectory(modelId);
    if (dir == null) return null;
    return _findFileRecursive(dir, (name) => name == 'tokens.txt');
  }

  /// 在目录中找到 lexicon.txt 路径（部分模型使用）
  Future<String?> findLexiconFile(String modelId) async {
    final dir = await getModelDirectory(modelId);
    if (dir == null) return null;
    return _findFileRecursive(dir, (name) => name == 'lexicon.txt');
  }

  /// 在目录中找到 .fst 文件列表（TTS 规则 FST）
  Future<List<String>> findFstFiles(String modelId) async {
    final dir = await getModelDirectory(modelId);
    if (dir == null) return [];
    final result = <String>[];
    await _findFilesRecursive(Directory(dir), (name) => name.endsWith('.fst'), result);
    return result;
  }

  /// 递归查找满足条件的第一个文件
  Future<String?> _findFileRecursive(String dir, bool Function(String) predicate) async {
    final directory = Directory(dir);
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (predicate(name)) return entity.path;
        }
      }
    } catch (_) {}
    return null;
  }

  /// 递归查找满足条件的所有文件
  Future<void> _findFilesRecursive(
      Directory dir, bool Function(String) predicate, List<String> result) async {
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (predicate(name)) result.add(entity.path);
        }
      }
    } catch (_) {}
  }

  /// 检查模型是否已下载（目录存在且有子目录/onnx文件，排除只有压缩包的情况）
  Future<bool> isModelDownloaded(String modelId) async {
    final dir = await modelsDir;
    final modelDir = Directory('$dir/$modelId');
    if (!await modelDir.exists()) return false;
    // 如果只有 .tar.bz2 或目录为空，认为未安装
    final onnx = await findOnnxModel(modelId);
    return onnx != null;
  }

  /// 删除已下载的模型
  Future<void> deleteModel(String modelId) async {
    final dir = await modelsDir;
    final modelDir = Directory('$dir/$modelId');
    if (await modelDir.exists()) {
      await modelDir.delete(recursive: true);
    }

    // 清除版本信息和进度
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('voice_model_version_$modelId');
    _downloadProgress.remove(modelId);
    _cancelTokens.remove(modelId);
  }

  /// 格式化文件大小（人类可读）
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// 全局实例
final voiceModelService = VoiceModelService();
