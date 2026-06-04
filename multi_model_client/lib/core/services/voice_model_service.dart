/// 语音模型服务 - LLM Studio 语音模型管理模块
///
/// 功能：
/// - ASR/TTS 模型下载管理
/// - 模型版本控制
/// - 断点续传下载
/// - 多平台模型适配
/// - 镜像源智能切换（国内/海外）
/// - 远程版本检查与更新
///
/// @author JianMa
/// @version 1.1.0
library;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mirror_service.dart';
import 'model_version_service.dart';

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
  final List<String> mirrorUrls; // 国内镜像地址列表
  final String archiveName; // 下载后的文件名（含扩展名）
  final int fileSize; // bytes
  final String? checksum;
  final List<String> supportedPlatforms; // macos, ios, android, windows, linux
  final String? minVersion;
  // TTS 专有：支持的音色列表
  final List<Map<String, String>> voices;

  // ────────────────────────────────────────────────────────────────────────────
  // 直链下载支持（下载单个文件而非 tar.bz2，无需解压）
  // 支持 ASR (ModelScope) 和 TTS (hf-mirror.com) 两种源
  // ────────────────────────────────────────────────────────────────────────────
  /// 是否为直链下载模式（下载单个文件，无需解压 tar.bz2）
  final bool isDirectDownload;
  /// 直链下载的文件列表：[{'url': ..., 'filename': ..., 'size': ...}, ...]
  final List<Map<String, dynamic>> directFiles;

  const VoiceModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.version,
    required this.downloadUrl,
    this.mirrorUrls = const [],
    required this.archiveName,
    required this.fileSize,
    this.checksum,
    required this.supportedPlatforms,
    this.minVersion,
    this.voices = const [],
    // 直链下载参数
    this.isDirectDownload = false,
    this.directFiles = const [],
  });

  /// 获取所有可用的下载链接
  List<String> get allDownloadUrls => [downloadUrl, ...mirrorUrls].where((u) => u.isNotEmpty).toList();
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
  // 国内镜像: ModelScope (魔搭社区)
  // ────────────────────────────────────────────────────────────────────────────
  static const List<VoiceModelInfo> asrModels = [
    // ─────────────────────────────────────────────────────────────────────────
    // SenseVoice int8 量化版本（推荐）
    // 直链下载（下载 model.int8.onnx + tokens.txt 单文件，无需解压）
    // 来源: ModelScope pengzhendong 镜像（国内直连，速度快）
    // ─────────────────────────────────────────────────────────────────────────
    VoiceModelInfo(
      id: 'sensevoice-int8',
      name: 'SenseVoice Small (int8) - 推荐',
      description: '阿里 SenseVoice 量化版，支持中/英/日/韩/粤五语，体积仅 ~24MB，推荐国内用户使用',
      type: VoiceModelType.asr,
      version: '2024-07-17',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models-2024-07-17/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2',
      mirrorUrls: [
        // hf-mirror.com（HuggingFace 国内镜像，压缩包）
        'https://hf-mirror.com/csukuangfj/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/resolve/main/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2',
      ],
      archiveName:
          'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2024-07-17.tar.bz2',
      fileSize: 60000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      // ─────────────────────────────────────────────────────────────────────────
      // 直链下载配置（推荐国内使用）
      // 同时下载 model.int8.onnx 和 tokens.txt 两个文件
      // 来源: ModelScope pengzhendong 镜像（resolve/master 格式，国内直连）
      // ─────────────────────────────────────────────────────────────────────────
      isDirectDownload: true,
      directFiles: [
        {
          'url': 'https://modelscope.cn/models/pengzhendong/sherpa-onnx-sense-voice-zh-en-ja-ko-yue/resolve/master/model.int8.onnx',
          'filename': 'model.int8.onnx',
          'size': 23000000, // ~23MB
        },
        {
          'url': 'https://modelscope.cn/models/pengzhendong/sherpa-onnx-sense-voice-zh-en-ja-ko-yue/resolve/master/tokens.txt',
          'filename': 'tokens.txt',
          'size': 1000000, // ~1MB
        },
      ],
    ),
    // SenseVoice 完整版（精度更高）
    VoiceModelInfo(
      id: 'sensevoice',
      name: 'SenseVoice Small',
      description: '阿里 SenseVoice 完整版，支持中/英/日/韩/粤五语，识别精度更高，约 230MB',
      type: VoiceModelType.asr,
      version: '2024-07-17',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models-2024-07-17/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2',
      mirrorUrls: [
        'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2',
      ],
      archiveName:
          'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2',
      fileSize: 230000000,
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
      mirrorUrls: [
        // ModelScope 魔搭社区镜像（可能不稳定）
        'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-whisper-tiny.en.tar.bz2',
      ],
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
      mirrorUrls: [
        'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-whisper-tiny.tar.bz2',
      ],
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
      mirrorUrls: [
        'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-whisper-base.en.tar.bz2',
      ],
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
      mirrorUrls: [
        'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-paraformer-zh-small-2024-03-09.tar.bz2',
      ],
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
      mirrorUrls: [
        'https://modelscope.cn/models/zhaochaoqun/sherpa-onnx-asr-models/resolve/master/sherpa-onnx-paraformer-zh-int8-2025-10-07.tar.bz2',
      ],
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
  // 国内镜像: hf-mirror.com（HuggingFace 国内镜像）
  // ────────────────────────────────────────────────────────────────────────────
  static const List<VoiceModelInfo> ttsModels = [
    // MeloTTS 中英双语（推荐）
    VoiceModelInfo(
      id: 'melo-zh-en',
      name: 'MeloTTS 中英双语（推荐）',
      description: 'MeloTTS 中英双语模型，支持普通话与英文，自然流畅',
      type: VoiceModelType.tts,
      version: '1.0.0',
      downloadUrl:
          'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-melo-tts-zh_en.tar.bz2',
      mirrorUrls: [
        // hf-mirror.com（HuggingFace 国内镜像）
        'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/vits-melo-tts-zh_en.tar.bz2',
      ],
      archiveName: 'vits-melo-tts-zh_en.tar.bz2',
      fileSize: 159000000,
      supportedPlatforms: ['macos', 'ios', 'android', 'windows', 'linux'],
      minVersion: '1.0.0',
      voices: [
        {'id': '0', 'name': '中文女声', 'desc': '普通话，自然流畅'},
        {'id': '1', 'name': '英文女声', 'desc': '英式发音，清晰'},
      ],
      // ─────────────────────────────────────────────────────────────────────────
      // 直链下载配置（推荐国内使用，从 hf-mirror.com 下载单文件）
      // MeloTTS 需要以下文件: model.onnx, tokens.txt, lexicon.txt, *.fst
      // ─────────────────────────────────────────────────────────────────────────
      isDirectDownload: true,
      directFiles: [
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/model.onnx',
          'filename': 'model.onnx',
          'size': 170000000, // ~170MB
        },
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/tokens.txt',
          'filename': 'tokens.txt',
          'size': 1000, // ~655 bytes
        },
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/lexicon.txt',
          'filename': 'lexicon.txt',
          'size': 7000000, // ~6.84MB
        },
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/date.fst',
          'filename': 'date.fst',
          'size': 60000, // ~59.2KB
        },
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/number.fst',
          'filename': 'number.fst',
          'size': 65000, // ~64.5KB
        },
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/phone.fst',
          'filename': 'phone.fst',
          'size': 90000, // ~88.6KB
        },
        {
          'url': 'https://hf-mirror.com/csukuangfj/vits-melo-tts-zh_en/resolve/main/new_heteronym.fst',
          'filename': 'new_heteronym.fst',
          'size': 22000, // ~22KB
        },
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
      mirrorUrls: [
        'https://ghfast.top/https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-keqing.tar.bz2',
      ],
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
      mirrorUrls: [
        'https://ghfast.top/https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-echo.tar.bz2',
      ],
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
      mirrorUrls: [
        'https://ghfast.top/https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-zh-hf-eula.tar.bz2',
      ],
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

  /// 启动下载（公开 API，集成镜像智能选择）
  ///
  /// 流程：
  /// 1. 根据模型 preferChinaMirror 标记 + 当前语言/网络选择镜像
  /// 2. 重排 downloadUrl + mirrorUrls 顺序（偏好镜像排前）
  /// 3. 调用内部下载逻辑
  Future<void> startDownload(
    String modelId, {
    void Function(VoiceModelDownloadProgress progress)? onProgress,
  }) async {
    final allModels = <VoiceModelInfo>[...asrModels, ...ttsModels];
    final model = allModels.where((m) => m.id == modelId).firstOrNull;
    if (model == null) {
      onProgress?.call(VoiceModelDownloadProgress(
        modelId: modelId,
        status: 'error',
        error: 'Model not found: $modelId',
      ));
      return;
    }

    // 1. 决定镜像偏好
    final preferredMirror = await MirrorService.instance.detectBestMirror();
    MirrorService.instance.setUserPreference(preferredMirror);
    debugPrint('[VoiceModelService] 模型 ${model.id} 使用镜像: $preferredMirror');

    // 2. 重排 downloadUrl + mirrorUrls：偏好镜像的 URL 排前面
    final allUrls = model.allDownloadUrls;
    final reorderedUrls = <String>[];
    for (final url in allUrls) {
      if (preferredMirror == MirrorType.china) {
        if (url.contains('modelscope.cn') || url.contains('hf-mirror.com')) {
          reorderedUrls.insert(0, url);
        } else {
          reorderedUrls.add(url);
        }
      } else {
        if (url.contains('huggingface.co') || url.contains('github.com')) {
          reorderedUrls.insert(0, url);
        } else {
          reorderedUrls.add(url);
        }
      }
    }
    // 重新组合：主 URL + 镜像 URLs
    final newDownloadUrl = reorderedUrls.isNotEmpty ? reorderedUrls.first : model.downloadUrl;
    final newMirrorUrls = reorderedUrls.length > 1 ? reorderedUrls.sublist(1) : <String>[];

    // 3. 替换为新顺序的 model
    final effectiveModel = VoiceModelInfo(
      id: model.id,
      name: model.name,
      description: model.description,
      type: model.type,
      version: model.version,
      downloadUrl: newDownloadUrl,
      mirrorUrls: newMirrorUrls,
      archiveName: model.archiveName,
      fileSize: model.fileSize,
      checksum: model.checksum,
      supportedPlatforms: model.supportedPlatforms,
      minVersion: model.minVersion,
      voices: model.voices,
      isDirectDownload: model.isDirectDownload,
      directFiles: model.directFiles,
    );

    // 4. 调用原下载逻辑
    await downloadModel(
      modelId: effectiveModel.id,
      onProgress: onProgress ?? (_) {},
    );
  }

  /// 检查所有模型是否有更新
  Future<List<ModelVersionInfo>> checkForUpdates() async {
    final results = <ModelVersionInfo>[];
    final allModels = <VoiceModelInfo>[...asrModels, ...ttsModels];
    for (final model in allModels) {
      if (model.checksum == null) continue; // 没有 GitHub repo 标识，跳过
      final installedVersion = await _getInstalledVersion(model.id);
      final info = await ModelVersionService.instance.checkForUpdate(
        modelId: model.id,
        installedVersion: installedVersion,
        githubRepo: model.checksum, // 暂用 checksum 字段存 github repo
        specificTag: null,
      );
      results.add(info);
    }
    return results;
  }

  /// 设置镜像偏好（null = 自动）
  void setMirrorPreference(MirrorType? type) {
    MirrorService.instance.setUserPreference(type);
  }

  /// 获取当前生效的镜像
  Future<MirrorType> getCurrentMirror() {
    return MirrorService.instance.detectBestMirror();
  }

  /// 获取已安装的本地版本
  Future<String?> _getInstalledVersion(String modelId) {
    return getInstalledVersion(modelId);
  }

  /// 下载模型（支持断点续传）
  ///
  /// 文件格式：.tar.bz2（sherpa-onnx 全部使用此格式）
  /// 下载到 `<modelsDir>`/`<modelId>`/`<archiveName>`
  /// 支持镜像自动回退
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

    // 获取所有可用的下载链接
    final allUrls = model.allDownloadUrls;
    String? lastError;
    
    // 尝试每个下载链接
    for (int urlIndex = 0; urlIndex < allUrls.length; urlIndex++) {
      final downloadUrl = allUrls[urlIndex];
      final isMirror = urlIndex > 0;
      final sourceName = isMirror ? '镜像$urlIndex' : '官方';
      
      debugPrint('[VoiceModelService] 尝试从 $sourceName 下载: $downloadUrl');
      
      // 更新状态显示当前使用的源
      _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
        status: 'downloading',
      );
      onProgress(_downloadProgress[modelId]!);

      try {
        // ─── 修复：不使用断点续传 ───
        // Dio download 不支持文件 append 模式，使用 Range header 会导致：
        // 1. 服务端忽略 Range 返回全量 → 进度 double-counting（显示大小远超实际）
        // 2. 服务端支持 Range → Dio 覆盖文件而非追加 → 文件损坏
        // 解决方案：删除不完整文件，全量下载，进度 = received / total（简单准确）
        final archiveFile = File(archivePath);
        bool archiveAlreadyExists = false;
        if (await archiveFile.exists()) {
          final existingSize = await archiveFile.length();
          if (existingSize > 0 && existingSize >= model.fileSize * 0.8) {
            debugPrint('[VoiceModelService] ✅ $modelId 压缩包已存在（${formatFileSize(existingSize)}），跳过下载');
            archiveAlreadyExists = true;
          } else {
            debugPrint('[VoiceModelService] 🔄 删除不完整压缩包（${formatFileSize(existingSize)} / ${formatFileSize(model.fileSize)}）');
            await archiveFile.delete();
          }
        }

        if (!archiveAlreadyExists) {
          await _dio.download(
            downloadUrl,
            archivePath,
            cancelToken: cancelToken,
            onReceiveProgress: (received, total) {
              final actualTotal = total > 0 ? total : model.fileSize;
              final progress = actualTotal > 0 ? received / actualTotal : 0.0;

              _downloadProgress[modelId] = VoiceModelDownloadProgress(
                modelId: modelId,
                totalBytes: actualTotal,
                downloadedBytes: received,
                progress: progress.clamp(0.0, 1.0),
                status: 'downloading',
              );
              final progressMsg = isMirror 
                  ? '$sourceName 下载中 ${(progress * 100).toInt()}%'
                  : '下载中 ${(progress * 100).toInt()}%';
              debugPrint('[VoiceModelService] $progressMsg');
              onProgress(_downloadProgress[modelId]!);
            },
            deleteOnError: true,
          );
        }

        // 下载完成，开始解压
        _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
          progress: 1.0,
          status: 'extracting',
          downloadedBytes: model.fileSize,
          totalBytes: model.fileSize,
        );
        final successMsg = isMirror 
            ? '下载完成（使用镜像加速）'
            : '下载完成';
        debugPrint('[VoiceModelService] ✅ $modelId $successMsg');
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
        
        return; // 下载成功，返回
        
      } catch (e) {
        lastError = e.toString();
        
        // 如果是用户主动取消，不尝试其他镜像
        if (e is DioException && e.type == DioExceptionType.cancel) {
          debugPrint('[VoiceModelService] 下载取消: $modelId');
          break;
        }
        
        debugPrint('[VoiceModelService] ⚠️ $sourceName 下载失败: $e');
        
        // 继续尝试下一个镜像
        if (urlIndex < allUrls.length - 1) {
          _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
            status: 'downloading',
          );
          onProgress(_downloadProgress[modelId]!);
        }
      }
    }
    
    // 所有镜像都失败
    debugPrint('[VoiceModelService] ❌ $modelId 所有下载源都失败: $lastError');
    _downloadProgress[modelId] = (_downloadProgress[modelId] ??
            VoiceModelDownloadProgress(modelId: modelId))
        .copyWith(
      status: 'error',
      error: '所有下载源都失败: $lastError',
    );
    onProgress(_downloadProgress[modelId]!);
    throw Exception('所有下载源都失败: $lastError');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SenseVoice 直链下载（下载单个文件，无需解压 tar.bz2）
  // 来源: ModelScope 魔搭社区（k2-fsa 官方同步）
  // 优势: 下载更快（~24MB vs ~60MB），无需解压，即下即用
  // ────────────────────────────────────────────────────────────────────────────

  /// 下载模型直链文件（单文件逐个下载，无需解压 tar.bz2）
  ///
  /// [modelId] 模型 ID（如 sensevoice-int8, melo-zh-en）
  /// [onProgress] 进度回调
  ///
  /// 支持 ModelScope / hf-mirror.com 等国内可访问源
  Future<void> downloadModelDirect({
    required String modelId,
    required Function(VoiceModelDownloadProgress) onProgress,
  }) async {
    final allModels = [...asrModels, ...ttsModels];
    final model = allModels.where((m) => m.id == modelId).firstOrNull;
    if (model == null) throw Exception('Model not found: $modelId');

    // 检查是否为直链下载模式
    if (!model.isDirectDownload) {
      debugPrint('[VoiceModelService] ⚠️ $modelId 不支持直链下载，使用传统方式');
      return downloadModel(modelId: modelId, onProgress: onProgress);
    }

    final dir = await modelsDir;
    final modelDir = '$dir/$modelId';

    // 确保目录存在
    final modelDirectory = Directory(modelDir);
    if (!await modelDirectory.exists()) {
      await modelDirectory.create(recursive: true);
    }

    // 取消之前的下载（如有）
    _cancelTokens[modelId]?.cancel('restart');
    final cancelToken = CancelToken();
    _cancelTokens[modelId] = cancelToken;

    // 获取需要下载的文件列表
    final files = model.directFiles;
    if (files.isEmpty) {
      throw Exception('没有找到可下载的文件');
    }

    final totalSize = files.fold<int>(0, (sum, f) => sum + (f['size'] as int));

    // 初始化进度
    _downloadProgress[modelId] = VoiceModelDownloadProgress(
      modelId: modelId,
      totalBytes: totalSize,
      status: 'downloading',
    );
    onProgress(_downloadProgress[modelId]!);

    debugPrint('[VoiceModelService] 🎯 开始直链下载 $modelId (共 ${files.length} 个文件，约 ${formatFileSize(totalSize)})');

    // ─── 修复：不使用断点续传 ───
    // 同 downloadModel，Dio download 不支持 append，Range header 导致进度计算错误
    // 使用全量下载 + 已完成文件跳过策略
    int completedBytes = 0;       // 已完成文件的实际总大小
    int remainingEstimated = totalSize; // 剩余未处理文件的预估大小

    // 依次下载每个文件
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final url = file['url'] as String;
      final filename = file['filename'] as String;
      final estimatedFileSize = (file['size'] as int?) ?? 0;

      if (url.isEmpty) {
        debugPrint('[VoiceModelService] ⚠️ 文件 $filename 的 URL 为空，跳过');
        remainingEstimated -= estimatedFileSize;
        continue;
      }

      final destPath = '$modelDir/$filename';
      final fileLabel = '${i + 1}/${files.length} ($filename)';

      try {
        // 检查文件是否已存在（之前成功下载的完整文件）
        final destFile = File(destPath);
        if (await destFile.exists()) {
          final existingSize = await destFile.length();
          if (existingSize > 0) {
            debugPrint('[VoiceModelService] ✅ [$fileLabel] 已存在（${formatFileSize(existingSize)}），跳过');
            completedBytes += existingSize;
            remainingEstimated -= estimatedFileSize;
            // 更新整体进度
            final totalEst = completedBytes + remainingEstimated;
            final progress = totalEst > 0 ? (completedBytes / totalEst).clamp(0.0, 0.99) : 0.0;
            _downloadProgress[modelId] = VoiceModelDownloadProgress(
              modelId: modelId,
              totalBytes: totalEst,
              downloadedBytes: completedBytes,
              progress: progress,
              status: 'downloading',
            );
            onProgress(_downloadProgress[modelId]!);
            continue;
          }
          // 空文件，删除重新下载
          await destFile.delete();
        }

        // 从剩余预估中减去当前文件
        remainingEstimated -= estimatedFileSize;
        // 当前文件的真实总大小（将在 onReceiveProgress 中用 Content-Length 更新）
        int currentFileTotal = estimatedFileSize;

        debugPrint('[VoiceModelService] 📥 [$fileLabel] 开始下载: $url');

        // 全量下载（不使用 Range header，进度 = received / total）
        await _dio.download(
          url,
          destPath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            // 用服务端 Content-Length 更新当前文件的真实大小
            if (total > 0) currentFileTotal = total;
            // 整体进度 = (已完成 + 当前已收) / (已完成 + 当前文件总 + 剩余预估)
            final totalEstimate = completedBytes + currentFileTotal + remainingEstimated;
            final currentOverall = completedBytes + received;
            final progress = totalEstimate > 0
                ? (currentOverall / totalEstimate).clamp(0.0, 0.99)
                : 0.0;
            _downloadProgress[modelId] = VoiceModelDownloadProgress(
              modelId: modelId,
              totalBytes: totalEstimate,
              downloadedBytes: currentOverall,
              progress: progress,
              status: 'downloading',
            );
            onProgress(_downloadProgress[modelId]!);
          },
          deleteOnError: true,
        );

        // 文件下载完成，用实际大小更新
        final actualSize = await destFile.length();
        completedBytes += actualSize;
        debugPrint('[VoiceModelService] ✅ [$fileLabel] 完成: ${formatFileSize(actualSize)} (总: ${formatFileSize(completedBytes)})');

      } catch (e) {
        if (e is DioException && e.type == DioExceptionType.cancel) {
          debugPrint('[VoiceModelService] 下载取消: $modelId');
          rethrow;
        }
        debugPrint('[VoiceModelService] ❌ [$fileLabel] 下载失败: $e');
        _downloadProgress[modelId] = (_downloadProgress[modelId] ??
                VoiceModelDownloadProgress(modelId: modelId))
            .copyWith(
          status: 'error',
          error: '[$fileLabel] 下载失败: $e',
        );
        onProgress(_downloadProgress[modelId]!);
        throw Exception('[$fileLabel] 下载失败: $e');
      }
    }

    // 验证所有文件是否下载完成
    debugPrint('[VoiceModelService] 🔍 验证文件完整性...');
    bool allFilesExist = true;
    for (final file in files) {
      final filename = file['filename'] as String;
      final destPath = '$modelDir/$filename';
      final destFile = File(destPath);
      if (!await destFile.exists()) {
        debugPrint('[VoiceModelService] ❌ 文件缺失: $filename');
        allFilesExist = false;
        break;
      }
      final size = await destFile.length();
      debugPrint('[VoiceModelService] ✅ $filename 存在: ${formatFileSize(size)}');
    }

    if (!allFilesExist) {
      _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
        status: 'error',
        error: '部分文件下载不完整',
      );
      onProgress(_downloadProgress[modelId]!);
      throw Exception('部分文件下载不完整');
    }

    // 下载成功 — 用实际下载的总大小
    _downloadProgress[modelId] = _downloadProgress[modelId]!.copyWith(
      progress: 1.0,
      status: 'completed',
      downloadedBytes: completedBytes,
      totalBytes: completedBytes,
    );
    debugPrint('[VoiceModelService] ✅ $modelId 直链下载全部完成！总大小: ${formatFileSize(completedBytes)}');
    onProgress(_downloadProgress[modelId]!);

    // 保存版本信息
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_model_version_$modelId', model.version);
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
    // macOS/Linux/iOS 使用系统 tar 命令（子进程，不阻塞 UI）
    if (Platform.isMacOS || Platform.isLinux || Platform.isIOS) {
      final result = await Process.run(
        'tar',
        ['-xjf', archivePath, '-C', destDir],
        runInShell: false,
      );
      if (result.exitCode != 0) {
        throw Exception('tar 解压失败 (exit ${result.exitCode}): ${result.stderr}');
      }
      return;
    }

    if (Platform.isWindows) {
      // Windows 10 1903+ 内置 tar.exe
      final result = await Process.run(
        'tar',
        ['-xjf', archivePath, '-C', destDir],
        runInShell: true,
      );
      if (result.exitCode != 0) {
        throw Exception('tar 解压失败 (exit ${result.exitCode}): ${result.stderr}');
      }
      return;
    }

    // Android: 使用 Isolate 在后台线程解压，避免 UI 卡死(ANR)
    if (Platform.isAndroid) {
      debugPrint('[VoiceModelService] Android: 在后台 Isolate 解压 $archivePath');
      try {
        await Isolate.run(() => _extractTarBz2InIsolate(archivePath, destDir));
        debugPrint('[VoiceModelService] ✅ Android 后台解压完成');
      } catch (e) {
        debugPrint('[VoiceModelService] ❌ Android 后台解压失败: $e');
        throw Exception('解压失败（文件可能损坏或过大）: $e');
      }
      return;
    }
  }

  /// 在 Isolate 中执行 tar.bz2 解压（Android 专用，防止 ANR）
  /// 此函数必须是顶层函数或静态方法才能被 Isolate.run() 调用
  static void _extractTarBz2InIsolate(String archivePath, String destDir) {
    final inputFile = File(archivePath);
    final fileSize = inputFile.lengthSync();
    debugPrint('[VoiceModelService-Isolate] 文件大小: $fileSize bytes');

    // 读取整个 bz2 文件并解码
    final compressed = inputFile.readAsBytesSync();
    final bz2Decoder = BZip2Decoder();
    final tarBytes = bz2Decoder.decodeBytes(compressed, verify: false);
    compressed.length; // 手动标记 compressed 可 GC

    debugPrint('[VoiceModelService-Isolate] BZip2 解码完成，tar 大小: ${tarBytes.length} bytes');

    // 解码 tar
    final tarArchive = TarDecoder().decodeBytes(tarBytes);
    tarBytes.length; // 标记 tarBytes 不再需要
    debugPrint('[VoiceModelService-Isolate] tar 包含 ${tarArchive.length} 个文件');

    // 确保目标目录存在
    final destDirObj = Directory(destDir);
    if (!destDirObj.existsSync()) {
      destDirObj.createSync(recursive: true);
    }

    // 解压所有文件
    int extractedCount = 0;
    for (final file in tarArchive) {
      final filename = file.name;
      // 跳过空文件名和目录条目
      if (filename.isEmpty) continue;
      if (filename.endsWith('/') || filename.endsWith('\\')) continue;

      final data = file.content;
      // 跳过空目录（content 为空或全为 0）
      if (data.isEmpty || data.every((b) => b == 0)) continue;

      final cleanName = filename
          .replaceAll(RegExp(r'^/+'), '')
          .replaceAll(RegExp(r'/+'), '/');
      final outputPath = '$destDir/$cleanName';
      final outFile = File(outputPath);
      
      // 确保父目录存在
      final parentDir = outFile.parent;
      if (!parentDir.existsSync()) {
        parentDir.createSync(recursive: true);
      }
      
      outFile.writeAsBytesSync(data);
      extractedCount++;
    }

    debugPrint('[VoiceModelService-Isolate] ✅ 解压完成: $extractedCount 个文件');
  }

  /// 获取模型解压后的实际目录（解压后会有一层子目录）
  /// 
  /// 直链下载模式：直接返回 modelDir 路径（如 voice_models/sensevoice-int8/）
  /// tar.bz2 模式：返回解压后的子目录（如 voice_models/sensevoice-int8/sherpa-onnx-.../）
  Future<String?> getModelDirectory(String modelId) async {
    final dir = await modelsDir;
    final modelDir = Directory('$dir/$modelId');
    if (!await modelDir.exists()) return null;

    // 检查是否为直链下载模式
    final model = [...asrModels, ...ttsModels].where((m) => m.id == modelId).firstOrNull;
    if (model != null && model.isDirectDownload) {
      // 直链下载模式：直接返回 modelDir，文件直接在目录下
      // 检查是否有 .onnx 文件存在
      final onnxFiles = ['model.onnx', 'model.int8.onnx'];
      for (final name in onnxFiles) {
        final onnxFile = File('${modelDir.path}/$name');
        if (await onnxFile.exists()) {
          return modelDir.path;
        }
      }
    }

    // 解压后的压缩包根目录：找到第一个子目录
    final entries = await modelDir.list().toList();
    for (final entry in entries) {
      if (entry is Directory) {
        return entry.path;
      }
    }
    // 没有子目录，说明直接解压在 modelDir 下或为直链下载
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
    } catch (_) {
      // ignore: non-critical error
    }

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
    } catch (_) {
      // ignore: non-critical error
    }
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
    } catch (_) {
      // ignore: non-critical error
    }
  }

  /// 检查模型是否已下载（目录存在且有 onnx 文件，排除只有压缩包的情况）
  ///
  /// 对于 ASR 模型，额外检查 tokens.txt 是否存在
  /// 对于 TTS 模型，额外检查 tokens.txt 和 lexicon.txt 是否存在（如果模型需要）
  Future<bool> isModelDownloaded(String modelId) async {
    final dir = await modelsDir;
    final modelDir = Directory('$dir/$modelId');
    if (!await modelDir.exists()) return false;

    // 必须有 .onnx 文件
    final onnx = await findOnnxModel(modelId);
    if (onnx == null) return false;

    // ASR 模型必须有 tokens.txt
    final model = [...asrModels, ...ttsModels].where((m) => m.id == modelId).firstOrNull;
    if (model != null) {
      if (model.type == VoiceModelType.asr) {
        final tokens = await findTokensFile(modelId);
        if (tokens == null) {
          debugPrint('[VoiceModelService] ⚠️ $modelId onnx 存在但缺少 tokens.txt');
          return false;
        }
      }
      // 直链下载的 TTS 模型（如 MeloTTS）需要 tokens.txt + lexicon.txt
      if (model.type == VoiceModelType.tts && model.isDirectDownload) {
        final tokens = await findTokensFile(modelId);
        if (tokens == null) {
          debugPrint('[VoiceModelService] ⚠️ $modelId onnx 存在但缺少 tokens.txt');
          return false;
        }
        // MeloTTS 需要 lexicon.txt
        if (model.id.startsWith('melo-')) {
          final lexicon = await findLexiconFile(modelId);
          if (lexicon == null) {
            debugPrint('[VoiceModelService] ⚠️ $modelId onnx 存在但缺少 lexicon.txt');
            return false;
          }
        }
      }
    }

    return true;
  }

  /// 获取已下载的模型 ID 列表（用于 UI 选择）
  Future<List<String>> getDownloadedModelIds(VoiceModelType type) async {
    final models = type == VoiceModelType.asr ? asrModels : ttsModels;
    final downloadedIds = <String>[];
    for (final model in models) {
      if (await isModelDownloaded(model.id)) {
        downloadedIds.add(model.id);
      }
    }
    return downloadedIds;
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
