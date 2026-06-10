// ignore_for_file: constant_identifier_names
/// TTS 语音合成服务 - LLM Studio 语音输出模块
/// 
/// 负责：
/// - 文本转语音合成
/// - 多种 TTS 后端支持（OpenAI / MiMo / Edge / Sherpa-ONNX / 系统内置）
/// - 长文本分块处理
/// - 音频播放控制
/// - MiMo 优先 + 超时降级（Edge TTS / Sherpa）
/// 
/// 支持的 TTS 后端：
/// - OpenAI TTS API（云端，高质量）
/// - MiMo TTS API（云端，中文优化，优先使用）
/// - Edge TTS（微软免费神经网络语音，WebSocket 流式，降级方案）
/// - Sherpa-ONNX（本地离线，中文优化，无网降级方案）
/// - 系统内置 TTS（macOS/Windows/iOS/Android，最终降级）
/// 
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:web_socket_channel/io.dart';
import 'package:crypto/crypto.dart';
import 'voice_model_service.dart';
import 'tts_style_parser.dart';
import 'audio_format_utils.dart';
import '../platform/platform_utils.dart';

/// TTS 提供商类型
enum TTSProvider {
  openai,    // OpenAI TTS API (云端)
  mimo,      // 小米 MiMo TTS API (云端，中文优化)
  cosyvoice, // CosyVoice 本地 Docker TTS (阿里开源，支持流式/克隆/指令控制)
  fishaudio, // Fish Audio S2 Pro 本地 MLX TTS (Apple Silicon 原生，支持克隆/情感标签)
  edge,      // 微软 Edge TTS (免费，WebSocket 流式，降级方案)
  sherpa,    // Sherpa-ONNX 本地离线 TTS (中文优化)
  system,    // 系统内置 TTS (macOS/Windows/iOS/Android)
}

/// 语音模型 (OpenAI)
enum VoiceModel {
  alloy,     // OpenAI 默认
  echo,
  fable,
  onyx,
  nova,
  shimmer,
}

/// 小米 MiMo TTS 音色
/// 完整列表来自 MiMo 官方文档：
/// - mimo_default: 因部署集群而异，中国集群默认为冰糖，其他集群默认为Mia
/// - bingtang/moli/suda/baihua: 中文音色
/// - Mia/Chloe/Milo/Dean: 英文音色
/// - default_zh/default_en: 中英文默认音色
enum MiMoVoice {
  mimo_default,  // MiMo 默认音色（推荐，因集群自动选择）
  bingtang,      // 冰糖 - 中文 女性
  moli,          // 茉莉 - 中文 女性
  suda,          // 苏打 - 中文 男性
  baihua,        // 白桦 - 中文 男性
  Mia,           // Mia - 英文 女性
  Chloe,         // Chloe - 英文 女性
  Milo,          // Milo - 英文 男性
  Dean,          // Dean - 英文 男性
  default_zh,    // 中文女声
  default_en,    // 英文女声
}

/// CosyVoice 推理模式
/// CosyVoice2-0.5B 模型不支持 SFT/instruct 模式（无 spk2info.pt），
/// 仅支持以下三种模式：
enum CosyVoiceMode {
  zero_shot,     // 零样本克隆（需要参考音频 + 参考文本，音色还原度最高）
  cross_lingual, // 跨语言克隆（只需参考音频，不需要文本，最便捷）
  instruct2,     // 指令控制 V2（参考音频 + 自然语言指令控制情感/语速等）
}

/// Edge TTS 音色（微软免费神经网络语音）
enum EdgeVoice {
  xiaoxiao,     // zh-CN-XiaoxiaoNeural (中文女声，温暖自然)
  xiaoyi,       // zh-CN-XiaoyiNeural (中文女声，活泼)
  yunjian,       // zh-CN-YunjianNeural (中文男声，沉稳)
  xiaochen,     // zh-CN-XiaochenNeural (中文女声，甜美)
  xiaohan,      // zh-CN-XiaohanNeural (中文女声，温柔)
  xiaomeng,     // zh-CN-XiaomengNeural (中文女声，可爱)
  xiaomo,       // zh-CN-XiaomoNeural (中文女声，成熟)
  xiaoqiu,      // zh-CN-XiaoqiuNeural (中文女声，知性)
  xiaorui,      // zh-CN-XiaoruiNeural (中文女声，温暖)
  xiaoshuang,   // zh-CN-XiaoshuangNeural (中文女声，童声)
  xiaoxuan,     // zh-CN-XiaoxuanNeural (中文女声，优雅)
  xiaoyan,      // zh-CN-XiaoyanNeural (中文女声，专业)
  xiaozhen,     // zh-CN-XiaozhenNeural (中文女声，新闻)
  yunxi,        // zh-CN-YunxiNeural (中文男声，阳光)
  yunxia,       // zh-CN-YunxiaNeural (中文男声，少年)
  yunyang,      // zh-CN-YunyangNeural (中文男声，新闻)
}

/// Edge TTS 音色映射
const Map<EdgeVoice, String> _edgeVoiceNames = {
  EdgeVoice.xiaoxiao: 'zh-CN-XiaoxiaoNeural',
  EdgeVoice.xiaoyi: 'zh-CN-XiaoyiNeural',
  EdgeVoice.yunjian: 'zh-CN-YunjianNeural',
  EdgeVoice.xiaochen: 'zh-CN-XiaochenNeural',
  EdgeVoice.xiaohan: 'zh-CN-XiaohanNeural',
  EdgeVoice.xiaomeng: 'zh-CN-XiaomengNeural',
  EdgeVoice.xiaomo: 'zh-CN-XiaomoNeural',
  EdgeVoice.xiaoqiu: 'zh-CN-XiaoqiuNeural',
  EdgeVoice.xiaorui: 'zh-CN-XiaoruiNeural',
  EdgeVoice.xiaoshuang: 'zh-CN-XiaoshuangNeural',
  EdgeVoice.xiaoxuan: 'zh-CN-XiaoxuanNeural',
  EdgeVoice.xiaoyan: 'zh-CN-XiaoyanNeural',
  EdgeVoice.xiaozhen: 'zh-CN-XiaozhenNeural',
  EdgeVoice.yunxi: 'zh-CN-YunxiNeural',
  EdgeVoice.yunxia: 'zh-CN-YunxiaNeural',
  EdgeVoice.yunyang: 'zh-CN-YunyangNeural',
};

/// Sherpa-ONNX 语音
enum SherpaVoice {
  zephyr,      // 中文女声
  af_sarah,    // 英文女声
  af_alloy,    // 英文女声
  af_fable,    // 英文女声
  af_onyx,     // 英文男声
  af_nova,     // 英文女声
  af_shimmer,  // 英文女声
  am_floyd,    // 英文男声
  am_eric,     // 英文男声
}

/// Sherpa-ONNX 语音信息
class SherpaVoiceInfo {
  final String id;
  final String name;
  final String description;

  const SherpaVoiceInfo({
    required this.id,
    required this.name,
    required this.description,
  });

  static const List<SherpaVoiceInfo> presets = [
    SherpaVoiceInfo(
      id: 'zephyr',
      name: '中文女声',
      description: '温暖自然的中文女声',
    ),
    SherpaVoiceInfo(
      id: 'af_sarah',
      name: 'Sarah',
      description: '英文女声，清晰流畅',
    ),
    SherpaVoiceInfo(
      id: 'af_alloy',
      name: 'Alloy',
      description: '英文女声，金属质感',
    ),
    SherpaVoiceInfo(
      id: 'af_fable',
      name: 'Fable',
      description: '英文女声，讲故事风格',
    ),
    SherpaVoiceInfo(
      id: 'af_onyx',
      name: 'Onyx',
      description: '英文男声，低沉有力',
    ),
    SherpaVoiceInfo(
      id: 'af_nova',
      name: 'Nova',
      description: '英文女声，明亮清脆',
    ),
    SherpaVoiceInfo(
      id: 'af_shimmer',
      name: 'Shimmer',
      description: '英文女声，柔和细腻',
    ),
    SherpaVoiceInfo(
      id: 'am_floyd',
      name: 'Floyd',
      description: '英文男声，节奏感强',
    ),
    SherpaVoiceInfo(
      id: 'am_eric',
      name: 'Eric',
      description: '英文男声，专业播音',
    ),
  ];
}

/// 音频播放器状态
enum AudioPlayerState {
  idle,
  playing,
  paused,
  stopped,
}

/// WAV 文件解析数据（用于交叉淡入淡出和音量归一化）
class _WavFileData {
  final String path;
  final int headerSize;
  final List<int> pcmBytes;

  _WavFileData({
    required this.path,
    required this.headerSize,
    required this.pcmBytes,
  });
}

/// 语音合成服务 (TTS)
class TTSService {
  // 当前使用的提供商
  final TTSProvider _provider;
  final String? _apiKey;
  final VoiceModel _voice;
  /// 小米 MiMo TTS 音色（枚举，仅用于兼容旧代码）
  final MiMoVoice _mimoVoice;
  /// ★ MiMo TTS 音色 ID（字符串，优先使用，直接传给 API）
  /// 支持所有 MiMo 官方音色：mimo_default, bingtang, moli, suda, baihua, Mia, Chloe, Milo, Dean 等
  /// 也支持克隆音色的 DataURL 格式
  final String? _mimoVoiceId;
  /// Edge TTS 音色
  final EdgeVoice _edgeVoice;
  /// 克隆音色参考音频路径（非空时使用克隆模式）
  final String? _cloneReferenceAudioPath;
  /// 小米 MiMo TTS 基础 URL（可选，默认使用官方端点）
  final String? _mimoBaseUrl;
  final double _speechRate;
  /// Sherpa 模型 ID（对应 VoiceModelService 中的模型 id，用于定位解压后目录）
  final String? _sherpaModelId;
  /// 说话人 ID（当模型支持多说话人时使用）
  final int _speakerId;
  /// ★ 系统 TTS 音色 ID（SharedPreferences 中的 tts_voice_id）
  final String? _systemVoiceId;
  /// ★ CosyVoice 服务地址（Docker 本地部署，默认 http://localhost:50000）
  final String? _cosyvoiceBaseUrl;
  /// ★ CosyVoice 推理模式
  final CosyVoiceMode _cosyvoiceMode;
  /// ★ CosyVoice 指令文本（instruct2 模式使用，如"用开心的语气说话"）
  final String? _cosyvoiceInstructText;
  /// ★ Fish Audio 服务地址（MLX 本地部署，默认 http://localhost:50001）
  final String? _fishaudioBaseUrl;
  /// ★ Fish Audio 参考音频路径（语音克隆时使用）
  final String? _fishaudioReferenceAudioPath;
  /// ★ Fish Audio 参考音频文本转录（提升克隆质量）
  final String? _fishaudioReferenceText;
  static const String _tag = 'TTSService';
  static const String _defaultMiMoBaseUrl = 'https://api.xiaomimimo.com/v1';

  /// 全局 MiMo API 调用限流：记录上次调用时间
  static DateTime? _lastMiMoCallTime;
  /// 两次 MiMo API 调用之间的最小间隔
  static const Duration _minCallInterval = Duration(seconds: 3);

  /// 等待限流间隔，确保两次调用之间有足够的间隔
  static Future<void> _waitForRateLimit() async {
    if (_lastMiMoCallTime != null) {
      final elapsed = DateTime.now().difference(_lastMiMoCallTime!);
      if (elapsed < _minCallInterval) {
        final waitMs = _minCallInterval.inMilliseconds - elapsed.inMilliseconds;
        debugPrint('$_tag   ⏳ 限流等待 ${waitMs}ms');
        await Future.delayed(Duration(milliseconds: waitMs));
      }
    }
    _lastMiMoCallTime = DateTime.now();
  }

  /// 从 SharedPreferences 读取自定义 MiMo API 地址
  Future<String> _getMiMoBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customUrl = prefs.getString('mimo_base_url');
      if (customUrl != null && customUrl.isNotEmpty) return customUrl;
    } catch (_) {}
    return _defaultMiMoBaseUrl;
  }

  // Sherpa-ONNX 实例
  OfflineTts? _sherpaTts;
  bool _sherpaInitialized = false;
  
  // 系统 TTS 实例
  FlutterTts? _systemTts;
  bool _systemTtsInitialized = false;
  // ignore: unused_field — TTS 引擎绑定状态，预留给未来诊断
  bool _systemTtsBound = false;
  
  /// ★ 是否为克隆音色模式（用于 UI 提示）
  bool get isCloneMode => _cloneReferenceAudioPath != null;

  // just_audio 播放器实例（用于 stop/pause/resume 控制）
  final AudioPlayer _audioPlayer = AudioPlayer();
  // ignore: unused_field — 跟踪音频播放状态，用于 _playAudio 和 stop 操作
  bool _isPlaying = false;
  /// 用户是否主动请求停止（用于 speakLongText 的循环控制）
  /// 与 _isPlaying 的区别：_isPlaying 在音频自然播完后会变 false，
  /// 但 _stopRequested 仅由用户/系统显式调用 stop() 赋值
  bool _stopRequested = false;
  /// playerStateStream 订阅（需在每次 _playAudio 时取消旧订阅，防止监听泄漏）
  StreamSubscription<PlayerState>? _playerStateSubscription;

  TTSService({
    TTSProvider provider = TTSProvider.system,  // 默认使用系统内置 TTS
    String? apiKey,
    VoiceModel voice = VoiceModel.alloy,
    MiMoVoice mimoVoice = MiMoVoice.mimo_default,
    /// ★ MiMo 音色 ID 字符串（优先于 mimoVoice 枚举，直接传给 API）
    /// 支持所有 MiMo 官方音色：mimo_default, bingtang, moli, suda, baihua, Mia, Chloe, Milo, Dean 等
    String? mimoVoiceId,
    EdgeVoice edgeVoice = EdgeVoice.xiaoxiao,  // Edge TTS 默认中文女声
    String? cloneReferenceAudioPath,
    String? mimoBaseUrl,
    double speechRate = 1.0,  // 默认语速 1x
    String? sherpaModelId,
    int speakerId = 0,
    /// ★ 系统 TTS 音色 ID（来自 SharedPreferences 的 tts_voice_id）
    /// 字符串形式以支持任意 ID（系统 TTS 的 voice ID 可能不是数字）
    String? systemVoiceId,
    /// ★ CosyVoice 服务地址（Docker 本地部署，默认 http://localhost:50000）
    String? cosyvoiceBaseUrl,
    /// ★ CosyVoice 推理模式（默认跨语言克隆，最便捷）
    CosyVoiceMode cosyvoiceMode = CosyVoiceMode.cross_lingual,
    /// ★ CosyVoice 指令文本（instruct2 模式使用，如"用开心的语气说话"）
    String? cosyvoiceInstructText,
    /// ★ Fish Audio 服务地址（MLX 本地部署，默认 http://localhost:50001）
    String? fishaudioBaseUrl,
    /// ★ Fish Audio 参考音频路径（语音克隆时使用）
    String? fishaudioReferenceAudioPath,
    /// ★ Fish Audio 参考音频文本转录（提升克隆质量）
    String? fishaudioReferenceText,
  })  : _provider = provider,
        _apiKey = apiKey,
        _voice = voice,
        _mimoVoice = mimoVoice,
        _mimoVoiceId = mimoVoiceId,
        _edgeVoice = edgeVoice,
        _cloneReferenceAudioPath = cloneReferenceAudioPath,
        _mimoBaseUrl = mimoBaseUrl,
        _speechRate = speechRate,
        _sherpaModelId = sherpaModelId,
        _speakerId = speakerId,
        _systemVoiceId = systemVoiceId,
        _cosyvoiceBaseUrl = cosyvoiceBaseUrl,
        _cosyvoiceMode = cosyvoiceMode,
        _cosyvoiceInstructText = cosyvoiceInstructText,
        _fishaudioBaseUrl = fishaudioBaseUrl,
        _fishaudioReferenceAudioPath = fishaudioReferenceAudioPath,
        _fishaudioReferenceText = fishaudioReferenceText;

  /// 合成语音（返回音频文件路径）
  /// ★ VoiceClone 模式使用2分钟总超时（比普通合成慢），其他模式1分钟
  Future<String> synthesize(String text, {String? outputPath}) async {
    debugPrint('[$_tag] synthesize() 开始: provider=$_provider, text长度=${text.length}');
    // ★ 动态总超时：VoiceClone 模式需要更长时间（处理参考音频），其他模式1分钟
    final isClone = _provider == TTSProvider.mimo && _cloneReferenceAudioPath != null;
    final totalTimeout = isClone ? const Duration(minutes: 2) : const Duration(minutes: 1);
    try {
      final path = await _synthesizeInternal(text, outputPath: outputPath)
          .timeout(totalTimeout, onTimeout: () {
        debugPrint('[$_tag] ⚠️ TTS 合成总超时 (${totalTimeout.inMinutes}分钟)，停止当前语音输出');
        throw TimeoutException('TTS synthesis timed out after ${totalTimeout.inMinutes} minute(s)');
      });
      debugPrint('[$_tag] synthesize() ✅ 完成: path=$path');
      return path;
    } catch (e, stack) {
      debugPrint('[$_tag] synthesize() ❌ 异常: $e');
      debugPrint('[$_tag] synthesize() 堆栈: $stack');
      rethrow;
    }
  }

  /// 内部合成方法（不含超时包装）
  /// ★ 切换权完全交给用户，不自动降级
  Future<String> _synthesizeInternal(String text, {String? outputPath}) async {
    try {
      String path;
      switch (_provider) {
        case TTSProvider.openai:
          debugPrint('[$_tag] synthesize() → _synthesizeWithOpenAI');
          path = await _synthesizeWithOpenAI(text, outputPath: outputPath);
          break;
        case TTSProvider.mimo:
          debugPrint('[$_tag] synthesize() → _synthesizeWithMiMo');
          path = await _synthesizeWithMiMo(text, outputPath: outputPath);
          break;
        case TTSProvider.cosyvoice:
          debugPrint('[$_tag] synthesize() → _synthesizeWithCosyVoice');
          path = await _synthesizeWithCosyVoice(text, outputPath: outputPath);
          break;
        case TTSProvider.fishaudio:
          debugPrint('[$_tag] synthesize() → _synthesizeWithFishAudio');
          path = await _synthesizeWithFishAudio(text, outputPath: outputPath);
          break;
        case TTSProvider.edge:
          debugPrint('[$_tag] synthesize() → _synthesizeWithEdge');
          path = await _synthesizeWithEdge(text, outputPath: outputPath);
          break;
        case TTSProvider.sherpa:
          debugPrint('[$_tag] synthesize() → _synthesizeWithSherpa');
          path = await _synthesizeWithSherpa(text, outputPath: outputPath);
          break;
        case TTSProvider.system:
          debugPrint('[$_tag] synthesize() → _synthesizeWithSystem');
          path = await _synthesizeWithSystem(text, outputPath: outputPath);
          break;
      }
      debugPrint('[$_tag] synthesize() ✅ 完成: path=$path');
      return path;
    } catch (e, stack) {
      debugPrint('[$_tag] synthesize() ❌ 异常: $e');
      debugPrint('[$_tag] synthesize() 堆栈: $stack');
      rethrow;
    }
  }

  /// 预热系统 TTS 引擎（异步执行，不阻塞调用方）
  /// 建议在语音对话引擎初始化时调用，以便后续降级到系统 TTS 时无需等待绑定
  Future<void> warmUpSystemTts() async {
    debugPrint('[$_tag] warmUpSystemTts() 开始: initialized=$_systemTtsInitialized, tts=${_systemTts != null}');
    if (_systemTtsInitialized && _systemTts != null) {
      debugPrint('[$_tag] warmUpSystemTts() 已初始化，跳过');
      return;
    }
    try {
      await _initSystemTts();
      debugPrint('[$_tag] warmUpSystemTts() ✅ 预热完成');
    } catch (e) {
      debugPrint('[$_tag] warmUpSystemTts() ❌ 预热失败（非致命）: $e');
    }
  }

  /// 直接播放语音
  Future<void> speak(String text) async {
    debugPrint('[$_tag] speak() 调用: provider=$_provider, text长度=${text.length}, 前50字="${text.length > 50 ? text.substring(0, 50) : text}"');
    try {
      switch (_provider) {
        case TTSProvider.openai:
        case TTSProvider.mimo:
        case TTSProvider.cosyvoice:
        case TTSProvider.fishaudio:
        case TTSProvider.edge:
        case TTSProvider.sherpa:
          debugPrint('[$_tag] speak() → synthesize + _playAudio (provider=$_provider)');
          final path = await synthesize(text);
          debugPrint('[$_tag] speak() → 合成完成, 文件路径: $path');
          await _playAudio(path);
          debugPrint('[$_tag] speak() → 播放完成');
          break;
        case TTSProvider.system:
          debugPrint('[$_tag] speak() → _speakWithSystem');
          // 系统 TTS 直接播放，不需要生成文件
          await _speakWithSystem(text);
          debugPrint('[$_tag] speak() → 系统 TTS 播放完成');
          break;
      }
    } catch (e, stack) {
      debugPrint('[$_tag] speak() ❌ 异常: $e');
      debugPrint('[$_tag] speak() 堆栈: $stack');
      // ★★★ 关键修复：移除自动降级到系统 TTS 的逻辑 ★★★
      // 之前这里会"自动降级"导致：用户设置 mimo → mimo 超时 → 静默转 system 输出
      // 违反用户意图：用户明确选了 mimo，超时应该是错误而不是降级
      // 修复后：speak() 失败直接 rethrow，让上层（调用方）决定如何处理
      rethrow;
    }
  }

  /// 播放长文本（自动分句分段合成，避免卡死）
  ///
  /// [onProgress] 可选回调：(当前块序号, 总块数) → 可用于 UI 进度展示
  /// 返回是否正常播完（被打断返回 false）
  /// 
  /// 【V4 流式分句合成】边合成边播放：
  /// - MiMo 模式：1-2句/100字细粒度分块，首块即播（等1块即开始播放）
  /// - 其他模式：3句/200字分块，等2块后开始播放
  /// - 播放第N块时，并行合成第N+1块（流水线无缝衔接）
  /// - 大幅降低首字播放延迟（MiMo 短文本约2-5秒即可合成完成）
  Future<bool> speakLongText(
    String text, {
    void Function(int current, int total)? onProgress,
  }) async {
    debugPrint('[$_tag] speakLongText() 开始: provider=$_provider, 文本长度=${text.length}');
    
    // 清洗 think 标签内容，避免播报 AI 思考过程
    final cleanText = cleanThinkTags(text);
    debugPrint('[$_tag] speakLongText() think标签清洗: ${text.length}字 → ${cleanText.length}字');
    
    // ★ 检测是否包含 TTS 控制标签
    final hasControl = TTSStyleParser.hasControlDirective(cleanText);
    final segmentCount = hasControl ? TTSStyleParser.parseAll(cleanText).length : 0;
    debugPrint('[$_tag] speakLongText() TTS标签检测: hasControl=$hasControl, 段落数=$segmentCount');
    
    if (hasControl) {
      debugPrint('[$_tag] speakLongText() 检测到 TTS 控制标签，使用 TTS 标签分段模式');
      try {
        final path = await synthesize(cleanText);
        debugPrint('[$_tag] speakLongText() 合成完成: path=$path');
        await _playAudio(path);
        debugPrint('[$_tag] speakLongText() 播放完成');
        return true;
      } catch (e, stack) {
        debugPrint('[$_tag] speakLongText() TTS 标签模式失败: $e');
        debugPrint('[$_tag] speakLongText() 堆栈: $stack');
        return false;
      }
    }
    
    // 1. 分句：按常见标点切分（仅对无 TTS 标签的文本）
    final sentences = splitIntoSentences(cleanText);
    debugPrint('[$_tag] speakLongText() 分句结果: ${sentences.length}句');
    if (sentences.isEmpty) {
      debugPrint('[$_tag] speakLongText() ❌ 分句为空，直接返回 true');
      return true;
    }

    // ★ 系统 TTS 特殊处理：直接使用 speak() 播放整个文本
    // 系统 TTS 的 speak() 是直接播放的，不支持分块流水线模式
    // 分块会导致多个 speak() 调用冲突（后一个会中断前一个）
    if (_provider == TTSProvider.system) {
      debugPrint('[$_tag] speakLongText() 系统 TTS 模式：直接播放整个文本');
      try {
        await _speakWithSystem(cleanText);
        return true;
      } catch (e) {
        debugPrint('[$_tag] speakLongText() 系统 TTS 播放失败: $e');
        return false;
      }
    }

    // ★ 2. 根据 TTS 提供商选择分块策略
    // MiMo：细粒度分块（1-2句/100字），短文本合成快（2-5秒），首块即播
    // CosyVoice：细粒度分块（2句/100字），本地 Docker 推理快，首块即播
    // 其他：粗粒度分块（3句/200字），等2块后播放
    final isMiMo = _provider == TTSProvider.mimo;
    final isCosyVoice = _provider == TTSProvider.cosyvoice;
    final useFineChunking = isMiMo || isCosyVoice;
    final chunkSentenceCount = useFineChunking ? 2 : 3;
    final chunkMaxChars = useFineChunking ? 100 : 200;
    final preSynthCount = useFineChunking ? 1 : 2; // MiMo/CosyVoice: 只等1块即播；其他: 等2块
    
    debugPrint('[$_tag] speakLongText() 分块策略: provider=$_provider, isMiMo=$isMiMo, '
        'chunkSentenceCount=$chunkSentenceCount, chunkMaxChars=$chunkMaxChars, preSynthCount=$preSynthCount');

    // 3. 将短句合并成块
    final chunks = _buildChunks(sentences, chunkSentenceCount, chunkMaxChars);
    debugPrint('[$_tag] speakLongText() 分块结果: ${chunks.length}块, 各块字数: ${chunks.map((c) => c.length).toList()}');

    // 重置停止标志
    _stopRequested = false;

    // ============================
    // V4 流水线模式：边合成边播放
    // ============================
    final readyPaths = <String?>[]; // 已合成完成的路径（按序）
    final allTempFiles = <String>[]; // 所有临时文件（用于清理）
    final synthCompleters = <int, Completer<String?>>{}; // 正在合成的块的 Completer
    
    // 启动前 N 块的合成
    final initialCount = chunks.length < preSynthCount ? chunks.length : preSynthCount;
    for (var i = 0; i < initialCount; i++) {
      synthCompleters[i] = Completer<String?>();
      _synthChunkAsync(chunks[i], i, chunks.length, synthCompleters[i]!, allTempFiles);
    }
    int nextSynthIndex = initialCount;

    // 等待前 N 块合成完成
    for (var i = 0; i < initialCount; i++) {
      if (_stopRequested) {
        await _cleanupFiles(allTempFiles);
        return false;
      }
      try {
        final path = await synthCompleters[i]!.future;
        readyPaths.add(path);
        if (path != null) allTempFiles.add(path);
        onProgress?.call(i + 1, chunks.length);
      } catch (e) {
        debugPrint('[$_tag] ❌ chunk[$i] 合成失败: $e');
        readyPaths.add(null);
      }
    }

    debugPrint('[$_tag] 前 $initialCount 块合成完成，开始流水线播放');

    // 流水线播放：播放第 i 块时，同时启动第 i+preSynthCount 块的合成
    for (var i = 0; i < chunks.length; i++) {
      if (_stopRequested) {
        await _cleanupFiles(allTempFiles);
        return false;
      }

      // ★ 启动后续块的合成（提前 preSynthCount 块开始合成）
      final futureIndex = i + preSynthCount;
      if (futureIndex < chunks.length && !synthCompleters.containsKey(futureIndex)) {
        synthCompleters[futureIndex] = Completer<String?>();
        _synthChunkAsync(chunks[futureIndex], futureIndex, chunks.length, 
            synthCompleters[futureIndex]!, allTempFiles);
        nextSynthIndex = futureIndex + 1;
      }

      // ★ 等待当前块合成完成（如果还没完成）
      if (i >= readyPaths.length) {
        if (synthCompleters.containsKey(i)) {
          try {
            final path = await synthCompleters[i]!.future;
            while (readyPaths.length <= i) {
              readyPaths.add(null);
            }
            readyPaths[i] = path;
            if (path != null && !allTempFiles.contains(path)) allTempFiles.add(path);
            onProgress?.call(i + 1, chunks.length);
          } catch (e) {
            debugPrint('[$_tag] ❌ chunk[$i] 合成失败: $e');
            while (readyPaths.length <= i) {
              readyPaths.add(null);
            }
          }
        } else {
          // 还没启动合成，现在启动
          synthCompleters[i] = Completer<String?>();
          _synthChunkAsync(chunks[i], i, chunks.length, synthCompleters[i]!, allTempFiles);
          try {
            final path = await synthCompleters[i]!.future;
            while (readyPaths.length <= i) {
              readyPaths.add(null);
            }
            readyPaths[i] = path;
            if (path != null && !allTempFiles.contains(path)) allTempFiles.add(path);
            onProgress?.call(i + 1, chunks.length);
          } catch (e) {
            debugPrint('[$_tag] ❌ chunk[$i] 合成失败: $e');
            while (readyPaths.length <= i) {
              readyPaths.add(null);
            }
          }
        }
      }

      // 播放当前块
      if (i < readyPaths.length && readyPaths[i] != null) {
        debugPrint('[$_tag] 播放 chunk[$i/${chunks.length}] (${chunks[i].length}字)');
        try {
          await _playAudio(readyPaths[i]!);
        } catch (e) {
          debugPrint('[$_tag] ❌ chunk[$i] 播放失败: $e');
        }
      } else {
        debugPrint('[$_tag] ⚠️ chunk[$i] 无音频，跳过');
      }
    }

    // 清理所有临时文件
    await _cleanupFiles(allTempFiles);
    debugPrint('[$_tag] speakLongText() ✅ 全部完成, 共 ${chunks.length} 块');
    return true;
  }

  /// 将短句合并成块
  List<String> _buildChunks(List<String> sentences, int chunkSentenceCount, int chunkMaxChars) {
    final chunks = <String>[];
    for (var i = 0; i < sentences.length; i += chunkSentenceCount) {
      final chunk = sentences.skip(i).take(chunkSentenceCount).join('');
      if (chunk.length > chunkMaxChars) {
        // 超长块在标点处截断
        final trimmed = chunk.substring(0, chunkMaxChars);
        final lastPunct = trimmed.lastIndexOf(RegExp(r'[，。、；：！……？,.]'));
        final cutoff = lastPunct > chunkMaxChars ~/ 2 ? lastPunct + 1 : chunkMaxChars;
        chunks.add(trimmed.substring(0, cutoff));
      } else {
        chunks.add(chunk);
      }
    }
    return chunks;
  }

  /// 异步合成单个文本块（通过 Completer 通知完成）
  void _synthChunkAsync(String text, int index, int total, 
      Completer<String?> completer, List<String> allTempFiles) {
    // ★ MiMo 克隆音色合成较慢（需处理参考音频），使用更长超时
    // 普通 MiMo：15秒；MiMo 克隆：60秒；CosyVoice：60秒
    final timeout = _provider == TTSProvider.mimo 
        ? (_cloneReferenceAudioPath != null 
            ? const Duration(seconds: 60) 
            : const Duration(seconds: 15))
        : const Duration(seconds: 60);
    debugPrint('[$_tag] 异步合成 chunk[$index/$total] (${text.length}字), 超时=${timeout.inSeconds}s, isClone=${_cloneReferenceAudioPath != null}');
    
    () async {
      try {
        String path = await synthesize(text).timeout(timeout, onTimeout: () {
          debugPrint('[$_tag] ⚠️ chunk[$index] 合成超时(${timeout.inSeconds}s), 跳过');
          return '';
        });
        if (path.isNotEmpty) {
          final file = File(path);
          if (await file.exists() && await file.length() > 0) {
            debugPrint('[$_tag] chunk[$index] 合成成功: $path');
            if (!completer.isCompleted) completer.complete(path);
            return;
          }
        }
        debugPrint('[$_tag] ⚠️ chunk[$index] 合成结果无效，跳过');
        if (!completer.isCompleted) completer.complete(null);
      } catch (e) {
        debugPrint('[$_tag] ❌ chunk[$index] 合成失败: $e');
        if (!completer.isCompleted) completer.complete(null);
      }
    }();
  }

  /// 清理临时音频文件
  Future<void> _cleanupFiles(List<String> files) async {
    for (final f in files) {
      try { await File(f).delete(); } catch (_) {}
    }
  }

  /// 按标点分句
  @visibleForTesting
  /// @visibleForTesting 标记：此方法为公开以便测试访问
  List<String> splitIntoSentences(String text) {
    // 清理多余空白（\s+ 匹配所有空白字符：空格、制表符、换行等）
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];

    // 按句子结束标点分割（保留标点）
    // 支持中文标点：。！？；  和英文标点：.?!;  以及换行符 \n
    final parts = cleaned.split(RegExp(r'[。！？；.?!;\n]'));
    final sentences = parts
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 1)
        .toList();
    
    // ★ MiMo 流式优化：对超长句子（>80字）按逗号二次分句
    // 避免单个长句占用过多合成时间
    if (_provider == TTSProvider.mimo) {
      final refined = <String>[];
      for (final s in sentences) {
        if (s.length > 80) {
          // 按逗号分句
          final subParts = s.split(RegExp(r'[，,]'));
          var buffer = '';
          for (final sub in subParts) {
            final trimmed = sub.trim();
            if (trimmed.isEmpty) continue;
            if (buffer.isNotEmpty) buffer += '，';
            buffer += trimmed;
            // 累积到40字以上就切分
            if (buffer.length >= 40) {
              refined.add(buffer);
              buffer = '';
            }
          }
          if (buffer.isNotEmpty) refined.add(buffer);
        } else {
          refined.add(s);
        }
      }
      return refined;
    }
    
    return sentences;
  }
  
  /// 清洗 <think>...</think> 标签内容
  /// 
  /// 用于去除 AI 思考过程的标记，避免 TTS 播报出来
  /// 支持单行和多行格式的 think 标签
  @visibleForTesting
  /// 清洗 `<think>...</think>` 标签内容（公开以供测试）
  String cleanThinkTags(String text) {
    // 使用 dotAll 模式，让 . 匹配换行符
    // 匹配 <think> 和 </think> 之间的所有内容（包括标签本身）
    return text.replaceAll(RegExp(r'<think>[sS]*?</think>', multiLine: true), '');
  }
  
  /// 停止播放
  Future<void> stop() async {
    debugPrint('[$_tag] stop() 调用: isPlaying=$_isPlaying');
    try {
      _stopRequested = true;
      await _audioPlayer.stop();
      _isPlaying = false;
      debugPrint('[$_tag] stop() ✅ 完成');
    } catch (e) {
      debugPrint('[$_tag] stop() ❌ 错误: $e');
    }
  }

  /// 暂停播放
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  /// 恢复播放
  Future<void> resume() async {
    try {
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      debugPrint('TTS resume error: $e');
    }
  }

  /// 移动端自动降级保护
  ///
  /// 在 Android/iOS 上，如果使用 Sherpa-ONNX 可能导致 OOM，
  /// 此方法检查并进行自动降级处理。
  /// 降级后的 TTS 服务由 speak() 和 synthesize() 的 catch 块自动 fallback 到系统 TTS。
  ///
  /// 返回 true 表示已降级（当前为移动端 + Sherpa），false 表示无需降级
  bool _autoDowngradeProvider() {
    if (PlatformUtils.isMobile && _provider == TTSProvider.sherpa) {
      debugPrint('[$_tag] 移动端 + Sherpa 检测，已启用 OOM 保护（自动降级到系统 TTS）');
      return true;
    }
    return false;
  }

  /// 初始化 Sherpa-ONNX
  Future<void> _initSherpa() async {
    if (_sherpaInitialized) {
      debugPrint('[$_tag] Sherpa 已初始化，跳过');
      return;
    }

    // ★★★ 移除移动端硬编码禁用：恢复之前能正常工作的 sherpa-onnx TTS 路径 ★★★
    // 历史说明：之前为了防止 OOM 在移动端禁用了 Sherpa TTS，但这导致用户
    // 选择 sherpa 模型后完全无声。恢复原始实现，由用户自行选择。
    // 如果 OOM 真正发生，catch 块会捕获并允许上层降级。

    try {
      final modelService = voiceModelService;
      String? modelDir;
      String? modelFile;
      String? tokensFile;
      List<String> fstFiles = [];

      if (_sherpaModelId != null) {
        debugPrint('[$_tag] 查找 TTS 模型: $_sherpaModelId');
        // 通过 VoiceModelService 动态定位已下载模型
        final isReady = await modelService.isModelDownloaded(_sherpaModelId);
        debugPrint('[$_tag] 模型下载状态: $isReady');
        if (!isReady) {
          throw Exception(
            'TTS 模型未下载或文件不完整: $_sherpaModelId'
            '请在「设置 → 语音设置」中重新下载模型',
          );
        }
        modelFile = await modelService.findOnnxModel(_sherpaModelId);
        tokensFile = await modelService.findTokensFile(_sherpaModelId);
        fstFiles = await modelService.findFstFiles(_sherpaModelId);
        modelDir = await modelService.getModelDirectory(_sherpaModelId);
        debugPrint('[$_tag] onnx: $modelFile, tokens: $tokensFile, fst: ${fstFiles.length}个');
      } else {
        debugPrint('[$_tag] 未指定 sherpa 模型 ID，使用系统默认');
        final appDir = await getApplicationDocumentsDirectory();
        modelDir = '${appDir.path}/sherpa_models';
        modelFile = '$modelDir/model.onnx';
        tokensFile = '$modelDir/tokens.txt';
      }

      if (modelFile == null || !await File(modelFile).exists()) {
        throw Exception(
          'TTS 模型文件不存在: $modelFile'
          '请在「语音设置 → 选择 TTS 模型」中下载对应模型',
        );
      }

      final tokensExists = tokensFile != null && await File(tokensFile).exists();
      final lexiconFile = _sherpaModelId != null
          ? await modelService.findLexiconFile(_sherpaModelId)
          : null;
      final lexiconExists = lexiconFile != null && await File(lexiconFile).exists();

      // 构建 ruleFsts 字符串（多个 fst 用逗号分隔）
      // 优先用已知名字的 fst（date/phone/new_heteronym）
      String ruleFsts = '';
      if (fstFiles.isNotEmpty) {
        ruleFsts = fstFiles.join(',');
      } else if (modelDir != null) {
        // 尝试常见文件名
        final candidates = ['date.fst', 'phone.fst', 'new_heteronym.fst', 'rule.fst'];
        final found = <String>[];
        for (final c in candidates) {
          final f = File('$modelDir/$c');
          if (await f.exists()) found.add(f.path);
        }
        ruleFsts = found.join(',');
      }

      // 创建 VITS 模型配置
      final vitsModelConfig = OfflineTtsVitsModelConfig(
        model: modelFile,
        tokens: tokensExists ? tokensFile : '',
        lexicon: lexiconExists ? lexiconFile : '',
        dataDir: '',
      );
      
      // 创建模型配置
      final modelConfig = OfflineTtsModelConfig(
        vits: vitsModelConfig,
        numThreads: 2,
        provider: 'cpu',
      );
      
      // 创建 TTS 配置
      final ttsConfig = OfflineTtsConfig(
        model: modelConfig,
        ruleFsts: ruleFsts,
      );
      
      // 初始化 TTS
      initBindings();
      _sherpaTts = OfflineTts(ttsConfig);
      
      _sherpaInitialized = true;
      debugPrint('[$_tag] Sherpa-ONNX 初始化成功: $modelFile');
    } catch (e) {
      debugPrint('[$_tag] Sherpa-ONNX 初始化失败: $e');
      _sherpaInitialized = false;
      rethrow;
    }
  }

  /// 使用 Sherpa-ONNX 合成
  Future<String> _synthesizeWithSherpa(String text, {String? outputPath}) async {
    await _initSherpa();
    
    if (_sherpaTts == null) {
      throw Exception('Sherpa-ONNX 未初始化');
    }

    try {
      // 生成音频
      final audio = _sherpaTts!.generate(
        text: text,
        sid: _speakerId,
        speed: _speechRate,
      );
      
      if (audio.samples.isEmpty) {
        throw Exception('Sherpa 生成音频为空');
      }
      
      // 转换为 WAV 格式并保存
      final wavData = createWavFromSamples(
        audio.samples,
        sampleRate: audio.sampleRate > 0 ? audio.sampleRate : 24000,
        bitsPerSample: 16,
        channels: 1,
      );
      
      // 确定目标目录并确保存在
      final String targetDir;
      if (outputPath != null) {
        targetDir = File(outputPath).parent.path;
      } else {
        targetDir = (await getTemporaryDirectory()).path;
      }
      final dir = Directory(targetDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final filename = outputPath != null
          ? outputPath.split('/').last
          : 'tts_sherpa_${DateTime.now().millisecondsSinceEpoch}.wav';
      final path = '$targetDir/$filename';
      
      final file = File(path);
      await file.writeAsBytes(wavData);
      
      return path;
    } catch (e) {
      throw Exception('Sherpa 语音合成失败: $e');
    }
  }

  /// 获取 Sherpa 说话人 ID
  int _getSherpaSpeakerId(SherpaVoice voice) {
    switch (voice) {
      case SherpaVoice.zephyr:
        return 0;
      case SherpaVoice.af_sarah:
        return 1;
      case SherpaVoice.af_alloy:
        return 2;
      case SherpaVoice.af_fable:
        return 3;
      case SherpaVoice.af_onyx:
        return 4;
      case SherpaVoice.af_nova:
        return 5;
      case SherpaVoice.af_shimmer:
        return 6;
      case SherpaVoice.am_floyd:
        return 7;
      case SherpaVoice.am_eric:
        return 8;
    }
  }

  /// ★ 使用 Edge TTS 合成（微软免费神经网络语音，WebSocket 流式传输）
  /// 降级方案：当 MiMo 超时或失败时使用，无需 API Key，速度快（1-2秒）
  /// 直接通过 WebSocket 协议与微软 Edge TTS 服务通信
  Future<String> _synthesizeWithEdge(String text, {String? outputPath}) async {
    final voiceName = _edgeVoiceNames[_edgeVoice] ?? 'zh-CN-XiaoxiaoNeural';
    debugPrint('[$_tag] Edge TTS 请求: voice=$voiceName, text长度=${text.length}');

    // 清洗 TTS 控制标签，Edge TTS 不支持这些标签
    String cleanText = text;
    final hasControl = TTSStyleParser.hasControlDirective(text);
    if (hasControl) {
      final segments = TTSStyleParser.parseAll(text);
      cleanText = segments.map((s) => s.displayContent).join(' ');
      debugPrint('[$_tag] Edge TTS 清洗标签: ${text.length}字 → ${cleanText.length}字');
    }

    // Edge TTS WebSocket 端点（含 Sec-MS-GEC 安全令牌）
    final reqId = _generateRequestId();
    final secMsGec = _generateSecMsGec();
    final secMsGecVersion = '1-143.0.3650.75';
    final url = 'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1'
        '?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4'
        '&Sec-MS-GEC=$secMsGec'
        '&Sec-MS-GEC-Version=$secMsGecVersion'
        '&ConnectionId=$reqId';

    try {
      // ★ 使用 IOWebSocketChannel 支持自定义 HTTP 请求头（模拟 Edge 浏览器）
      final channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0',
          'Origin': 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold',
          'Pragma': 'no-cache',
          'Cache-Control': 'no-cache',
        },
      );

      // 等待 WebSocket 连接建立
      await channel.ready;

      // 1. 发送配置消息
      final configMessage = 'X-Timestamp:${_formatDate()}\r\n'
          'Content-Type:application/json; charset=utf-8\r\n'
          'Path:speech.config\r\n\r\n'
          '{"context":{"synthesis":{"audio":{"metadataoptions":{'
          '"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},'
          '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"'
          '}}}}\r\n';
      channel.sink.add(configMessage);

      // 2. 发送 SSML 消息
      final rateStr = '${(_speechRate * 100).round()}%';
      final ssml = '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="zh-CN">'
          '<voice name="$voiceName">'
          '<prosody rate="$rateStr">'
          '${_escapeXml(cleanText)}'
          '</prosody>'
          '</voice>'
          '</speak>';
      final ssmlMessage = 'X-RequestId:$reqId\r\n'
          'Content-Type:application/ssml+xml\r\n'
          'Path:ssml\r\n\r\n'
          '$ssml\r\n';
      channel.sink.add(ssmlMessage);

      // 3. 收集音频数据
      final audioChunks = <List<int>>[];
      var synthesisComplete = false;
      var gotAudio = false;

      await for (final message in channel.stream) {
        if (message is String) {
          // 文本消息：检查是否完成
          if (message.contains('Path:turn.end')) {
            synthesisComplete = true;
            break;
          }
        } else if (message is List<int>) {
          // 二进制消息：包含音频数据
          // Edge TTS 二进制消息格式：前2字节是header长度(大端)，然后是header文本，然后是音频数据
          if (message.length > 2) {
            final headerLen = (message[0] << 8) | message[1];
            if (message.length > headerLen + 2) {
              final audioData = message.sublist(headerLen + 2);
              audioChunks.add(audioData);
              gotAudio = true;
            }
          }
        }
      }

      channel.sink.close();

      if (!gotAudio || audioChunks.isEmpty) {
        throw Exception('Edge TTS: 未收到音频数据 (synthesisComplete=$synthesisComplete)');
      }

      // 合并所有音频块
      final totalLen = audioChunks.fold<int>(0, (sum, chunk) => sum + chunk.length);
      final audioBytes = Uint8List(totalLen);
      var offset = 0;
      for (final chunk in audioChunks) {
        audioBytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }

      debugPrint('[$_tag] Edge TTS 音频数据大小: ${audioBytes.length} bytes (MP3)');

      // 保存为 MP3 文件（just_audio 支持 MP3 播放）
      final tempDir = await getTemporaryDirectory();
      final filename = outputPath != null
          ? outputPath.replaceAll('.wav', '.mp3')
          : 'tts_edge_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final path = '${tempDir.path}/$filename';

      final file = File(path);
      await file.writeAsBytes(audioBytes);

      debugPrint('[$_tag] Edge TTS ✅ 合成完成: $path (${audioBytes.length} bytes)');
      return path;
    } catch (e, stack) {
      debugPrint('[$_tag] Edge TTS ❌ 合成失败: $e');
      debugPrint('[$_tag] Edge TTS 堆栈: $stack');
      throw Exception('Edge TTS 合成失败: $e');
    }
  }

  /// 生成 Edge TTS Sec-MS-GEC 安全令牌
  ///
  /// 算法：基于当前时间戳和 TrustedClientToken 生成 SHA-256 哈希
  /// 参考：https://github.com/travisvn/edge-tts-universal
  static String _generateSecMsGec() {
    const trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';
    const winEpoch = 11644473600; // Windows epoch 偏移量（1601→1970）
    const sToNs = 1e9;

    // 获取当前 Unix 时间戳
    double ticks = DateTime.now().millisecondsSinceEpoch / 1000.0;
    ticks += winEpoch;
    ticks -= ticks % 300; // 取整到 300 秒窗口
    ticks *= sToNs / 100;

    final strToHash = '${ticks.round()}$trustedClientToken';
    final hash = sha256.convert(utf8.encode(strToHash));
    return hash.toString().toUpperCase();
  }

  /// 生成 Edge TTS 请求 ID（32位十六进制）
  static String _generateRequestId() {
    final random = math.Random();
    return List.generate(32, (_) => random.nextInt(16).toRadixString(16)).join();
  }

  /// 格式化日期为 Edge TTS 所需格式
  static String _formatDate() {
    final now = DateTime.now().toUtc();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}T'
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}Z';
  }

  /// XML 特殊字符转义
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  @visibleForTesting
  Uint8List createWavFromSamples(
    Float32List samples, {
    required int sampleRate,
    required int bitsPerSample,
    required int channels,
  }) {
    // 转换为 16 位 PCM
    final pcmData = Int16List(samples.length);
    for (int i = 0; i < samples.length; i++) {
      final sample = (samples[i] * 32767).clamp(-32768.0, 32767.0);
      pcmData[i] = sample.toInt();
    }
    
    // 创建 WAV 文件头
    final wavHeader = _createWavHeader(
      dataSize: pcmData.length * 2,
      sampleRate: sampleRate,
      bitsPerSample: bitsPerSample,
      channels: channels,
    );
    
    // 合并头部和数据
    final wavData = Uint8List(wavHeader.length + pcmData.length * 2);
    wavData.setAll(0, wavHeader);
    
    final byteData = ByteData.sublistView(wavData, wavHeader.length);
    for (int i = 0; i < pcmData.length; i++) {
      byteData.setInt16(i * 2, pcmData[i], Endian.little);
    }
    
    return wavData;
  }

  /// 创建 WAV 文件头
  List<int> _createWavHeader({
    required int dataSize,
    required int sampleRate,
    required int bitsPerSample,
    required int channels,
  }) {
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final fileSize = 36 + dataSize;

    final header = <int>[];
    
    // RIFF header
    header.addAll('RIFF'.codeUnits);
    header.addAll(int32ToBytes(fileSize));
    header.addAll('WAVE'.codeUnits);
    
    // fmt sub-chunk
    header.addAll('fmt '.codeUnits);
    header.addAll(int32ToBytes(16));
    header.addAll(int16ToBytes(1));
    header.addAll(int16ToBytes(channels));
    header.addAll(int32ToBytes(sampleRate));
    header.addAll(int32ToBytes(byteRate));
    header.addAll(int16ToBytes(blockAlign));
    header.addAll(int16ToBytes(bitsPerSample));
    
    // data sub-chunk
    header.addAll('data'.codeUnits);
    header.addAll(int32ToBytes(dataSize));
    
    return header;
  }

  @visibleForTesting
  List<int> int32ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  @visibleForTesting
  List<int> int16ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
    ];
  }

  /// 播放音频文件（使用 just_audio 支持 stop/pause/resume）
  Future<void> _playAudio(String path) async {
    debugPrint('[$_tag] _playAudio() 开始: path=$path');
    try {
      // 检查文件是否存在
      final file = File(path);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      debugPrint('[$_tag] _playAudio() 文件检查: exists=$exists, size=$size bytes');

      if (!exists || size == 0) {
        debugPrint('[$_tag] _playAudio() ❌ 文件不存在或为空，跳过播放');
        return;
      }

      // ★ 取消之前的订阅，防止监听泄漏 + 重复订阅导致状态错乱
      await _playerStateSubscription?.cancel();
      _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
        _isPlaying = state.playing;
      });

      // 先停止之前的播放并重置
      try {
        await _audioPlayer.stop();
      } catch (_) {}

      // 使用 just_audio 播放，支持暂停/恢复/停止
      debugPrint('[$_tag] _playAudio() → setFilePath');
      await _audioPlayer.setFilePath(path);
      debugPrint('[$_tag] _playAudio() → play()');
      await _audioPlayer.play();
      _isPlaying = true;

      // ★★★ 等待播放完成（关键修复）★★★
      // play() 只是启动播放，不会等待播放完成。
      // 如果不等待，调用方可能在播放完成前就删除了音频文件。
      await _audioPlayer.processingStateStream.firstWhere(
        (state) => state == ProcessingState.completed,
        orElse: () => ProcessingState.idle,
      ).timeout(
        const Duration(minutes: 10),
        onTimeout: () {
          debugPrint('[$_tag] _playAudio() ⚠️ 播放超时(10min)，强制停止');
          return ProcessingState.idle;
        },
      );

      debugPrint('[$_tag] _playAudio() ✅ 播放完成');
    } catch (e, stack) {
      debugPrint('[$_tag] _playAudio() ❌ just_audio 失败: $e');
      debugPrint('[$_tag] _playAudio() 堆栈: $stack');
      // 回退到系统命令播放
      debugPrint('[$_tag] _playAudio() → 尝试系统命令播放');
      try {
        if (PlatformUtils.isMacOS) {
          await Process.run('afplay', [path]);
        } else if (PlatformUtils.isWindows) {
          await Process.run('start', ['', path], runInShell: true);
        } else if (PlatformUtils.isLinux) {
          await Process.run('aplay', [path]);
        }
        debugPrint('[$_tag] _playAudio() ✅ 系统命令播放完成');
      } catch (e2) {
        debugPrint('[$_tag] _playAudio() ❌ 系统命令播放也失败: $e2');
      }
    } finally {
      _isPlaying = false;
    }
  }

  /// 将多个 WAV 音频文件合并为一个连续的 WAV 文件
  ///
  /// 原理：保留第一个文件的 WAV 头部，删除后续文件的头部，
  /// 仅拼接 PCM 数据部分，然后更新合并后文件的总大小。
  ///
  /// [enableCrossfade] 是否启用交叉淡入淡出（默认 true），
  /// 在段落衔接处进行平滑过渡，消除语调硬切感。
  /// [crossfadeMs] 交叉淡入淡出时长（毫秒），默认 120ms。
  /// [enableNormalization] 是否启用音量归一化（默认 true），
  /// 统一各段音量，避免忽大忽小。
  Future<String> _concatenateWavFiles(
    List<String> filePaths, {
    bool enableCrossfade = true,
    int crossfadeMs = 120,
    bool enableNormalization = true,
  }) async {
    if (filePaths.isEmpty) throw Exception('没有音频文件可以合并');

    // 过滤掉不存在的文件
    final validFiles = <String>[];
    for (final path in filePaths) {
      if (await File(path).exists()) {
        validFiles.add(path);
      } else {
        debugPrint('[$_tag] _concatenateWavFiles: 跳过不存在的文件: $path');
      }
    }
    if (validFiles.isEmpty) throw Exception('所有音频文件都不存在，无法合并');
    if (validFiles.length == 1) return validFiles.first;

    final tempDir = await getTemporaryDirectory();
    final outPath = '${tempDir.path}/tts_combined_${DateTime.now().millisecondsSinceEpoch}.wav';

    debugPrint('[$_tag] _concatenateWavFiles: 合并 ${validFiles.length} 个文件 → $outPath');
    debugPrint('[$_tag]   crossfade=${enableCrossfade ? '${crossfadeMs}ms' : '关闭'}, normalization=${enableNormalization ? '开启' : '关闭'}');

    // 解析每个文件的 WAV 头部，提取 PCM 数据和元信息
    final fileDataList = <_WavFileData>[];
    int headerSize = 44;
    int sampleRate = 24000;
    int bitsPerSample = 16;
    int channels = 1;

    for (final path in validFiles) {
      final bytes = await File(path).readAsBytes();
      final offset = _findDataOffset(bytes);
      if (path == validFiles.first) {
        headerSize = offset;
        // 从 WAV 头部解析音频参数
        if (bytes.length >= 28) {
          sampleRate = bytes[24] | (bytes[25] << 8) | (bytes[26] << 16) | (bytes[27] << 24);
          channels = bytes[22] | (bytes[23] << 8);
          bitsPerSample = bytes[34] | (bytes[35] << 8);
        }
      }
      final pcmBytes = bytes.sublist(offset);
      fileDataList.add(_WavFileData(path: path, headerSize: offset, pcmBytes: pcmBytes));
    }

    debugPrint('[$_tag]   WAV 参数: sampleRate=$sampleRate, channels=$channels, bitsPerSample=$bitsPerSample, headerSize=$headerSize');

    // 音量归一化：统一各段 RMS 响度
    if (enableNormalization && fileDataList.length > 1) {
      _normalizeSegments(fileDataList, bitsPerSample, channels);
    }

    final int bytesPerSample = bitsPerSample ~/ 8;

    // 自适应交叉淡入淡出：根据相邻段落的音频特征差异自动调整时长
    // 差异越大 → crossfade 越长（平滑过渡），差异越小 → crossfade 越短（保持节奏）
    final adaptiveCrossfadeBytes = <int>[];
    if (enableCrossfade && fileDataList.length > 1) {
      for (int i = 0; i < fileDataList.length - 1; i++) {
        final prevSeg = fileDataList[i].pcmBytes;
        final nextSeg = fileDataList[i + 1].pcmBytes;

        // 计算相邻段落的 RMS 和过零率差异
        final double prevRms = _computeSegmentRms(prevSeg, bytesPerSample);
        final double nextRms = _computeSegmentRms(nextSeg, bytesPerSample);
        final double prevZcr = _computeZeroCrossingRate(prevSeg, bytesPerSample);
        final double nextZcr = _computeZeroCrossingRate(nextSeg, bytesPerSample);

        // RMS 差异比（归一化到 0~1）
        final maxRms = prevRms > nextRms ? prevRms : nextRms;
        final rmsDiff = maxRms > 0 ? (prevRms - nextRms).abs() / maxRms : 0.0;

        // 过零率差异（语速/频谱变化的代理指标）
        final zcrDiff = (prevZcr - nextZcr).abs();

        // 综合差异分值 → 映射到 crossfade 时长
        // 低差异（<0.3）→ 50ms，中差异（0.3~0.7）→ 80~120ms，高差异（>0.7）→ 150ms
        final diffScore = (rmsDiff * 0.6 + zcrDiff * 0.4).clamp(0.0, 1.0);
        int cfMs;
        if (diffScore < 0.3) {
          cfMs = 50;
        } else if (diffScore < 0.7) {
          cfMs = 80 + ((diffScore - 0.3) / 0.4 * 40).round();
        } else {
          cfMs = 120 + ((diffScore - 0.7) / 0.3 * 30).round();
        }
        cfMs = cfMs.clamp(30, 150);

        final cfBytes = (sampleRate * cfMs / 1000).round() * bytesPerSample * channels;
        adaptiveCrossfadeBytes.add(cfBytes);
        debugPrint('[$_tag]   边界 $i→${i + 1}: rmsDiff=${rmsDiff.toStringAsFixed(3)}, zcrDiff=${zcrDiff.toStringAsFixed(4)}, diffScore=${diffScore.toStringAsFixed(3)}, crossfade=${cfMs}ms');
      }
    }

    // 合并 PCM 数据（含自适应交叉淡入淡出）
    final outputPcm = <int>[];
    for (int i = 0; i < fileDataList.length; i++) {
      final current = fileDataList[i].pcmBytes;

      // 获取当前边界的 crossfade 字节数
      final cfBytes = (enableCrossfade && i < adaptiveCrossfadeBytes.length)
          ? adaptiveCrossfadeBytes[i]
          : 0;

      if (i == 0) {
        // 第一段：直接写入（去掉尾部交叉区域，留给淡出）
        if (cfBytes > 0 && current.length > cfBytes) {
          outputPcm.addAll(current.sublist(0, current.length - cfBytes));
        } else {
          outputPcm.addAll(current);
        }
      } else {
        final prev = fileDataList[i - 1].pcmBytes;

        if (cfBytes > 0) {
          // 获取前一段尾部和当前段头部用于交叉混合
          final prevTail = prev.length >= cfBytes
              ? prev.sublist(prev.length - cfBytes)
              : prev;
          final currHead = current.length >= cfBytes
              ? current.sublist(0, cfBytes)
              : current;

          // 交叉混合：前段淡出 + 当前段淡入
          final mixed = _crossfadeMix(prevTail, currHead, bytesPerSample, channels);
          outputPcm.addAll(mixed);

          // 写入当前段剩余部分（去掉头部交叉区域和尾部交叉区域）
          final remainingStart = cfBytes;
          // 获取下一段边界的 crossfade 字节数（用于去掉尾部）
          final nextCfBytes = (enableCrossfade && i < adaptiveCrossfadeBytes.length)
              ? adaptiveCrossfadeBytes[i]
              : 0;
          final remainingEnd = (i < fileDataList.length - 1 && current.length > nextCfBytes)
              ? current.length - nextCfBytes
              : current.length;
          if (remainingEnd > remainingStart) {
            outputPcm.addAll(current.sublist(remainingStart, remainingEnd));
          }
        } else {
          // 无交叉：直接拼接
          outputPcm.addAll(current);
        }
      }

      debugPrint('[$_tag]   段落 ${i + 1}: ${current.length} bytes PCM');
    }

    // 构建输出 WAV 文件
    final wavHeader = _createWavHeader(
      dataSize: outputPcm.length,
      sampleRate: sampleRate,
      bitsPerSample: bitsPerSample,
      channels: channels,
    );

    final outBytes = Uint8List(wavHeader.length + outputPcm.length);
    outBytes.setAll(0, wavHeader);
    for (int i = 0; i < outputPcm.length; i++) {
      outBytes[wavHeader.length + i] = outputPcm[i] & 0xFF;
    }

    await File(outPath).writeAsBytes(outBytes);

    debugPrint('[$_tag] _concatenateWavFiles ✅ 完成: ${outBytes.length} bytes (header=${wavHeader.length} + pcm=${outputPcm.length})');
    return outPath;
  }

  /// 交叉混合两段 PCM 数据
  ///
  /// 前段线性淡出（1→0），当前段线性淡入（0→1），
  /// 混合后的每个采样 = 前段 × 淡出系数 + 当前段 × 淡入系数。
  List<int> _crossfadeMix(
    List<int> tailPcm,
    List<int> headPcm,
    int bytesPerSample,
    int channels,
  ) {
    final len = tailPcm.length < headPcm.length ? tailPcm.length : headPcm.length;
    final result = List<int>.filled(len, 0);

    // 确保长度按采样对齐
    final alignedLen = (len ~/ (bytesPerSample * channels)) * bytesPerSample * channels;
    final totalSamples = alignedLen ~/ bytesPerSample;

    for (int s = 0; s < totalSamples; s++) {
      final t = totalSamples > 1 ? s / (totalSamples - 1) : 1.0;
      final fadeOut = 1.0 - t; // 前段淡出系数
      final fadeIn = t;        // 当前段淡入系数

      final byteOffset = s * bytesPerSample;
      if (byteOffset + bytesPerSample <= alignedLen) {
        if (bytesPerSample == 2) {
          // 16-bit PCM
          final prevSample = (tailPcm[byteOffset] | (tailPcm[byteOffset + 1] << 8)).toSigned(16);
          final currSample = (headPcm[byteOffset] | (headPcm[byteOffset + 1] << 8)).toSigned(16);
          final mixed = (prevSample * fadeOut + currSample * fadeIn).round().clamp(-32768, 32767);
          result[byteOffset] = mixed & 0xFF;
          result[byteOffset + 1] = (mixed >> 8) & 0xFF;
        } else {
          // 其他位深：直接复制当前段
          for (int b = 0; b < bytesPerSample; b++) {
            if (byteOffset + b < len) {
              result[byteOffset + b] = headPcm[byteOffset + b];
            }
          }
        }
      }
    }

    // 处理尾部未对齐的字节
    for (int i = alignedLen; i < len; i++) {
      result[i] = headPcm[i];
    }

    return result;
  }

  /// 音量归一化：统一各段的 RMS 响度
  ///
  /// 计算所有段落的平均 RMS，然后将每段缩放到目标 RMS 水平，
  /// 避免不同段落音量忽大忽小。
  void _normalizeSegments(
    List<_WavFileData> fileDataList,
    int bitsPerSample,
    int channels,
  ) {
    if (fileDataList.length < 2) return;

    final bytesPerSample = bitsPerSample ~/ 8;

    // 计算每段的 RMS
    final rmsValues = <double>[];
    for (final fd in fileDataList) {
      double sumSquares = 0;
      int sampleCount = 0;
      final pcm = fd.pcmBytes;
      for (int i = 0; i + bytesPerSample <= pcm.length; i += bytesPerSample) {
        int sample;
        if (bytesPerSample == 2) {
          sample = (pcm[i] | (pcm[i + 1] << 8)).toSigned(16);
        } else {
          sample = pcm[i];
        }
        sumSquares += sample * sample;
        sampleCount++;
      }
      final rms = sampleCount > 0 ? math.sqrt(sumSquares / sampleCount) : 0.0;
      rmsValues.add(rms);
    }

    // 计算目标 RMS（所有段落的平均值）
    final avgRms = rmsValues.reduce((a, b) => a + b) / rmsValues.length;
    debugPrint('[$_tag]   音量归一化: avgRMS=${avgRms.toStringAsFixed(1)}');

    if (avgRms < 1.0) return; // 太安静，跳过归一化

    // 对每段进行缩放
    for (int i = 0; i < fileDataList.length; i++) {
      final rms = rmsValues[i];
      if (rms < 1.0) continue; // 静音段跳过

      final scale = avgRms / rms;
      // 限制缩放范围，防止过度放大噪声
      final clampedScale = scale.clamp(0.3, 3.0);
      debugPrint('[$_tag]   段落 ${i + 1}: rms=${rms.toStringAsFixed(1)}, scale=${clampedScale.toStringAsFixed(3)}');

      if ((clampedScale - 1.0).abs() < 0.05) continue; // 差异太小，跳过

      // 应用缩放
      final pcm = fileDataList[i].pcmBytes;
      for (int j = 0; j + bytesPerSample <= pcm.length; j += bytesPerSample) {
        if (bytesPerSample == 2) {
          int sample = (pcm[j] | (pcm[j + 1] << 8)).toSigned(16);
          sample = (sample * clampedScale).round().clamp(-32768, 32767);
          pcm[j] = sample & 0xFF;
          pcm[j + 1] = (sample >> 8) & 0xFF;
        }
      }
    }
  }

  /// 计算 PCM 段落的 RMS（均方根）响度
  double _computeSegmentRms(List<int> pcmBytes, int bytesPerSample) {
    double sumSquares = 0;
    int count = 0;
    for (int i = 0; i + bytesPerSample <= pcmBytes.length; i += bytesPerSample) {
      int sample;
      if (bytesPerSample == 2) {
        sample = (pcmBytes[i] | (pcmBytes[i + 1] << 8)).toSigned(16);
      } else {
        sample = pcmBytes[i];
      }
      sumSquares += sample * sample;
      count++;
    }
    return count > 0 ? math.sqrt(sumSquares / count) : 0.0;
  }

  /// 计算 PCM 段落的过零率（Zero Crossing Rate）
  ///
  /// 过零率 = 信号穿过零点的次数 / 总采样数
  /// 高过零率 → 高频成分多（如摩擦音、气声），低过零率 → 低频为主（如元音、胸腔共鸣）
  /// 用于衡量相邻段落的频谱/语速差异。
  double _computeZeroCrossingRate(List<int> pcmBytes, int bytesPerSample) {
    if (pcmBytes.length < bytesPerSample * 2) return 0.0;
    int crossings = 0;
    int prevSample = 0;
    int count = 0;

    for (int i = 0; i + bytesPerSample <= pcmBytes.length; i += bytesPerSample) {
      int sample;
      if (bytesPerSample == 2) {
        sample = (pcmBytes[i] | (pcmBytes[i + 1] << 8)).toSigned(16);
      } else {
        sample = pcmBytes[i];
      }
      if (count > 0 && ((prevSample >= 0 && sample < 0) || (prevSample < 0 && sample >= 0))) {
        crossings++;
      }
      prevSample = sample;
      count++;
    }
    return count > 0 ? crossings / count : 0.0;
  }

  /// 查找 WAV 文件中 "data" 子块的偏移量（跳过头部后 PCM 数据的起始位置）
  int _findDataOffset(List<int> wavBytes) {
    for (int i = 0; i < wavBytes.length - 4; i++) {
      if (wavBytes[i] == 0x64 && wavBytes[i+1] == 0x61 &&
          wavBytes[i+2] == 0x74 && wavBytes[i+3] == 0x61) {
        return i + 8;
      }
    }
    return 44; // 默认
  }

  /// 流式合成语音
  Stream<List<int>> synthesizeStream(String text) async* {
    final path = await synthesize(text);
    final file = File(path);
    yield await file.readAsBytes();
  }

  /// 使用 OpenAI TTS 合成
  Future<String> _synthesizeWithOpenAI(String text, {String? outputPath}) async {
    if (_apiKey == null) {
      throw StateError('API key not configured');
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://api.openai.com/v1/audio/speech',
        data: {
          'model': 'tts-1',
          'voice': _voice.name,
          'input': text,
          'response_format': 'mp3',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        final audioBytes = response.data as List<int>;
        // ★ 修复：使用应用临时目录而非 /tmp/（Android 无 /tmp/ 权限）
        final tempDir = await getTemporaryDirectory();
        final path = outputPath ?? '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final file = File(path);
        await file.writeAsBytes(audioBytes);
        return path;
      } else {
        throw Exception('TTS API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to synthesize speech: $e');
    }
  }

  /// ★ CosyVoice 本地 Docker TTS 合成
  /// 
  /// CosyVoice 本地 Docker TTS 合成
  /// 
  /// CosyVoice2-0.5B 模型仅支持以下三种模式：
  /// - zero_shot: 零样本克隆（参考音频 + 参考文本，音色还原度最高）
  /// - cross_lingual: 跨语言克隆（只需参考音频，最便捷）
  /// - instruct2: 指令控制 V2（参考音频 + 自然语言指令控制情感/语速等）
  ///
  /// API 使用 Form 表单（multipart/form-data），响应为流式 PCM int16 数据
  /// 采样率：24000Hz（CosyVoice2-0.5B），需要添加 WAV 头部才能播放
  Future<String> _synthesizeWithCosyVoice(String text, {String? outputPath}) async {
    final baseUrl = _cosyvoiceBaseUrl ?? 'http://localhost:50000';
    
    // ★ 情感控制：解析 TTS 标签，提取情感描述
    final hasControl = TTSStyleParser.hasControlDirective(text);
    String cleanText = text;
    String? emotionInstructText; // 从 TTS 标签提取的情感指令
    
    if (hasControl) {
      final segments = TTSStyleParser.parseAll(text);
      // 提取纯文本
      cleanText = segments.map((s) => s.displayContent).join('');
      // 提取所有情感/风格描述，合并为 instruct_text
      final emotionParts = <String>[];
      for (final seg in segments) {
        if (seg.controlContent.isNotEmpty) {
          emotionParts.add(seg.controlContent);
        }
      }
      if (emotionParts.isNotEmpty) {
        emotionInstructText = emotionParts.join('，');
        debugPrint('[$_tag] CosyVoice 情感控制: 提取到情感指令="$emotionInstructText"');
      }
    }
    
    // ★ 决定推理模式：
    // 1. 如果有情感指令，自动使用 instruct2 模式（无论用户设置的是什么模式）
    // 2. 否则使用用户配置的默认模式
    final effectiveMode = emotionInstructText != null 
        ? CosyVoiceMode.instruct2 
        : _cosyvoiceMode;
    final effectiveInstructText = emotionInstructText 
        ?? _cosyvoiceInstructText 
        ?? '用自然的语气说话';
    
    debugPrint('[$_tag] CosyVoice 合成: mode=$effectiveMode (原始=$_cosyvoiceMode), baseUrl=$baseUrl, text长度=${cleanText.length}');
    if (emotionInstructText != null) {
      debugPrint('[$_tag] CosyVoice 情感指令: $emotionInstructText');
    }
    
    try {
      // 检查参考音频文件是否存在
      if (_cloneReferenceAudioPath != null) {
        final refFile = File(_cloneReferenceAudioPath);
        if (!await refFile.exists()) {
          throw StateError('CosyVoice 参考音频文件不存在: $_cloneReferenceAudioPath');
        }
        final refSize = await refFile.length();
        if (refSize < 1024) {
          throw StateError('CosyVoice 参考音频文件过小（${refSize} bytes），至少需要 3 秒音频');
        }
        debugPrint('[$_tag] CosyVoice 参考音频: $_cloneReferenceAudioPath (${refSize} bytes)');
      }
      
      // 使用 Dio 发送 multipart/form-data 请求
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      // 根据文本长度动态调整超时：CPU 推理约 10-15 秒/句
      final estimatedSeconds = (cleanText.length / 20 * 15).ceil().clamp(30, 300);
      dio.options.receiveTimeout = Duration(seconds: estimatedSeconds);
      
      String endpoint;
      FormData formData;
      
      switch (effectiveMode) {
        case CosyVoiceMode.zero_shot:
          if (_cloneReferenceAudioPath == null) {
            throw StateError('CosyVoice 零样本克隆模式需要提供参考音频路径 (cloneReferenceAudioPath)');
          }
          endpoint = '$baseUrl/inference_zero_shot';
          formData = FormData.fromMap({
            'tts_text': cleanText,
            'prompt_text': '',
            'prompt_wav': await MultipartFile.fromFile(_cloneReferenceAudioPath!),
          });
          break;
          
        case CosyVoiceMode.cross_lingual:
          if (_cloneReferenceAudioPath == null) {
            throw StateError('CosyVoice 跨语言克隆模式需要提供参考音频路径 (cloneReferenceAudioPath)');
          }
          endpoint = '$baseUrl/inference_cross_lingual';
          formData = FormData.fromMap({
            'tts_text': cleanText,
            'prompt_wav': await MultipartFile.fromFile(_cloneReferenceAudioPath!),
          });
          break;
          
        case CosyVoiceMode.instruct2:
          if (_cloneReferenceAudioPath == null) {
            throw StateError('CosyVoice instruct2 模式需要提供参考音频路径 (cloneReferenceAudioPath)');
          }
          endpoint = '$baseUrl/inference_instruct2';
          formData = FormData.fromMap({
            'tts_text': cleanText,
            'instruct_text': effectiveInstructText,
            'prompt_wav': await MultipartFile.fromFile(_cloneReferenceAudioPath!),
          });
          break;
      }
      
      debugPrint('[$_tag] CosyVoice 请求: endpoint=$endpoint, timeout=${estimatedSeconds}s');
      
      // 发送请求，接收二进制 PCM 数据
      final response = await dio.post<List<int>>(
        endpoint,
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      
      final pcmBytes = response.data!;
      if (pcmBytes.isEmpty) {
        throw Exception('CosyVoice 返回空音频数据，请检查服务是否正常运行');
      }
      
      debugPrint('[$_tag] CosyVoice 收到 PCM 数据: ${pcmBytes.length} bytes');
      
      // 将 PCM int16 数据转换为 WAV 格式（添加 WAV 头部）
      // CosyVoice2-0.5B 输出：24000Hz, 16-bit, 单声道
      const sampleRate = 24000;
      const bitsPerSample = 16;
      const numChannels = 1;
      final wavBytes = _pcmToWav(pcmBytes, sampleRate, bitsPerSample, numChannels);
      
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final tempPath = outputPath ?? 
          '${tempDir.path}/cosyvoice_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File(tempPath);
      await file.writeAsBytes(wavBytes);
      
      debugPrint('[$_tag] CosyVoice 合成完成: path=$tempPath, wavSize=${wavBytes.length} bytes');
      return tempPath;
      
    } on DioException catch (e) {
      // Dio 网络错误细分处理
      String errorMsg;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
          errorMsg = 'CosyVoice 连接超时，请确认 Docker 容器是否运行（docker ps）';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = 'CosyVoice 合成超时（文本可能过长），请尝试缩短文本';
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'CosyVoice 连接失败，请确认服务地址 $baseUrl 是否正确且容器已启动';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          // ★ 尝试从 bytes 响应中提取服务端错误信息
          String serverError = '';
          if (e.response?.data != null) {
            try {
              if (e.response!.data is List<int>) {
                final jsonStr = String.fromCharCodes(e.response!.data as List<int>);
                final decoded = jsonDecode(jsonStr);
                if (decoded is Map && decoded.containsKey('error')) {
                  serverError = decoded['error'].toString();
                }
              } else if (e.response!.data is Map) {
                serverError = e.response!.data['error']?.toString() ?? '';
              }
            } catch (_) {}
          }
          errorMsg = serverError.isNotEmpty
              ? 'CosyVoice 服务返回错误 ($statusCode)：$serverError'
              : 'CosyVoice 服务返回错误 ($statusCode)：${e.response?.data ?? "未知错误"}';
          break;
        default:
          errorMsg = 'CosyVoice 网络错误: ${e.message}';
      }
      debugPrint('[$_tag] CosyVoice DioException: $errorMsg');
      throw Exception(errorMsg);
    } catch (e, stack) {
      debugPrint('[$_tag] CosyVoice 合成失败: $e');
      debugPrint('[$_tag] CosyVoice 堆栈: $stack');
      rethrow;
    }
  }

  /// ★ Fish Audio S2 Pro (MLX) 语音合成
  /// 
  /// 基于 Apple Silicon MLX 框架的本地 TTS 服务，支持：
  /// - 基础 TTS（默认音色）
  /// - 零样本语音克隆（上传参考音频 + 可选文本转录）
  /// - 情感标签控制（[happy], [whisper], [sad] 等 15,000+ 内联标签）
  /// 
  /// 服务端点：POST /v1/tts（基础TTS + 克隆统一入口）
  Future<String> _synthesizeWithFishAudio(String text, {String? outputPath}) async {
    const defaultBaseUrl = 'http://localhost:50001';
    final baseUrl = _fishaudioBaseUrl ?? defaultBaseUrl;
    
    debugPrint('[$_tag] Fish Audio 合成: baseUrl=$baseUrl, text长度=${text.length}');
    debugPrint('[$_tag] Fish Audio 克隆: refAudio=${_fishaudioReferenceAudioPath}, refText=${_fishaudioReferenceText}');
    
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      // Fish Audio MLX 推理速度远快于 CosyVoice（RTF≈0.2-0.5 vs 3.5）
      // 但首次推理需要预热，给足超时
      final estimatedSeconds = (text.length / 50 * 5).ceil().clamp(30, 120);
      dio.options.receiveTimeout = Duration(seconds: estimatedSeconds);
      
      // 构建 FormData
      final formFields = <String, dynamic>{
        'text': text,
        'output_format': 'wav',
        'speed': _speechRate.toStringAsFixed(1),
      };
      
      // 如果有参考音频，添加语音克隆参数
      if (_fishaudioReferenceAudioPath != null && _fishaudioReferenceAudioPath!.isNotEmpty) {
        final refFile = File(_fishaudioReferenceAudioPath!);
        if (await refFile.exists()) {
          final refSize = await refFile.length();
          if (refSize < 1024) {
            throw StateError('Fish Audio 参考音频文件过小（${refSize} bytes），至少需要 10 秒音频');
          }
          debugPrint('[$_tag] Fish Audio 参考音频: $_fishaudioReferenceAudioPath (${refSize} bytes)');
          formFields['reference_audio'] = await MultipartFile.fromFile(_fishaudioReferenceAudioPath!);
          if (_fishaudioReferenceText != null && _fishaudioReferenceText!.isNotEmpty) {
            formFields['reference_text'] = _fishaudioReferenceText!;
          }
        } else {
          debugPrint('[$_tag] Fish Audio 参考音频文件不存在: $_fishaudioReferenceAudioPath，使用默认音色');
        }
      }
      
      final formData = FormData.fromMap(formFields);
      
      debugPrint('[$_tag] Fish Audio 请求: endpoint=$baseUrl/v1/tts, timeout=${estimatedSeconds}s');
      
      // 发送请求，接收 WAV 音频数据
      final response = await dio.post<List<int>>(
        '$baseUrl/v1/tts',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      
      final audioBytes = response.data!;
      if (audioBytes.isEmpty) {
        throw Exception('Fish Audio 返回空音频数据，请检查服务是否正常运行');
      }
      
      // 从响应头获取音频元数据
      final audioDuration = response.headers.value('X-Audio-Duration') ?? '?';
      final genTime = response.headers.value('X-Generation-Time') ?? '?';
      final rtf = response.headers.value('X-RTF') ?? '?';
      debugPrint('[$_tag] Fish Audio 收到 WAV 数据: ${audioBytes.length} bytes, 时长=${audioDuration}s, 耗时=${genTime}s, RTF=$rtf');
      
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final tempPath = outputPath ?? 
          '${tempDir.path}/fishaudio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File(tempPath);
      await file.writeAsBytes(audioBytes);
      
      debugPrint('[$_tag] Fish Audio 合成完成: path=$tempPath, wavSize=${audioBytes.length} bytes');
      return tempPath;
      
    } on DioException catch (e) {
      String errorMsg;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
          errorMsg = 'Fish Audio 连接超时，请确认 MLX 服务是否运行（python server.py）';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = 'Fish Audio 合成超时，请尝试缩短文本或检查模型是否已加载';
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'Fish Audio 连接失败，请确认服务地址 $baseUrl 是否正确且服务已启动';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          String serverError = '';
          try {
            if (e.response?.data is List<int>) {
              final jsonStr = String.fromCharCodes(e.response!.data as List<int>);
              final decoded = jsonDecode(jsonStr);
              if (decoded is Map && decoded.containsKey('detail')) {
                serverError = decoded['detail'].toString();
              }
            }
          } catch (_) {}
          errorMsg = serverError.isNotEmpty
              ? 'Fish Audio 服务返回错误 ($statusCode)：$serverError'
              : 'Fish Audio 服务返回错误 ($statusCode)';
          break;
        default:
          errorMsg = 'Fish Audio 网络错误: ${e.message}';
      }
      debugPrint('[$_tag] Fish Audio DioException: $errorMsg');
      throw Exception(errorMsg);
    } catch (e, stack) {
      debugPrint('[$_tag] Fish Audio 合成失败: $e');
      debugPrint('[$_tag] Fish Audio 堆栈: $stack');
      rethrow;
    }
  }

  /// 将 PCM 原始数据转换为 WAV 格式（添加 44 字节 WAV 头部）
  /// PCM 格式：16-bit signed integer, little-endian
  Uint8List _pcmToWav(List<int> pcmData, int sampleRate, int bitsPerSample, int numChannels) {
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = pcmData.length;
    final fileSize = dataSize + 36;
    
    final header = ByteData(44);
    // RIFF 标识
    header.setUint32(0, 0x52494646, Endian.big); // 'RIFF'
    header.setUint32(4, fileSize, Endian.little);
    header.setUint32(8, 0x57415645, Endian.big); // 'WAVE'
    // fmt 子块
    header.setUint32(12, 0x666d7420, Endian.big); // 'fmt '
    header.setUint32(16, 16, Endian.little); // 子块大小
    header.setUint16(20, 1, Endian.little); // PCM 格式
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    // data 子块
    header.setUint32(36, 0x64617461, Endian.big); // 'data'
    header.setUint32(40, dataSize, Endian.little);
    
    final result = Uint8List(44 + dataSize);
    result.setRange(0, 44, header.buffer.asUint8List());
    result.setRange(44, 44 + dataSize, pcmData);
    return result;
  }

  /// MiMo TTS 合成
  /// API 兼容 OpenAI 格式，使用 /v1/chat/completions 端点
  /// 响应中音频数据以 Base64 编码返回在 choices[0].message.audio.data
  /// ★ MiMo 音色 ID 映射：将拼音映射为 MiMo API 需要的中文 Voice ID
  /// MiMo 官方 API 的预置音色使用中文名称（冰糖、茉莉、苏打、白桦），
  /// 而应用内部存储使用拼音（bingtang、moli、suda、baihua），
  /// 需要在调用 API 时进行转换
  static const Map<String, String> _mimoVoiceIdMap = {
    'mimo_default': 'mimo_default',
    'bingtang': '冰糖',
    'moli': '茉莉',
    'suda': '苏打',
    'baihua': '白桦',
    'Mia': 'Mia',
    'Chloe': 'Chloe',
    'Milo': 'Milo',
    'Dean': 'Dean',
    'default_zh': 'mimo_default',
    'default_en': 'mimo_default',
  };

  /// 将内部音色 ID 转换为 MiMo API 需要的 Voice ID
  static String _resolveMiMoVoiceId(String voiceId) {
    return _mimoVoiceIdMap[voiceId] ?? voiceId;
  }

  Future<String> _synthesizeWithMiMo(String text, {String? outputPath}) async {
    debugPrint('[$_tag] _synthesizeWithMiMo() 入口: apiKey长度=${_apiKey?.length ?? 0}, '
        'mimoVoiceId=${_mimoVoiceId ?? "null"}, mimoVoice=${_mimoVoice.name}, '
        'cloneReferenceAudioPath=${_cloneReferenceAudioPath ?? "null"}, '
        'mimoBaseUrl=${_mimoBaseUrl ?? "null(将从SharedPreferences读取)"}');
    if (_apiKey == null || _apiKey.isEmpty) {
      throw StateError('MiMo API key not configured. Please set MiMo API key in voice settings.');
    }

    // 克隆音色模式：使用参考音频进行克隆合成
    if (_cloneReferenceAudioPath != null) {
      debugPrint('[$_tag] MiMo 克隆音色模式: referenceAudio=$_cloneReferenceAudioPath');
      return synthesizeWithMiMoClone(
        referenceAudioPath: _cloneReferenceAudioPath,
        text: text,
        outputPath: outputPath,
      );
    }

    // 优先使用构造参数，否则从 SharedPreferences 读取自定义地址
    final baseUrl = _mimoBaseUrl ?? await _getMiMoBaseUrl();
    final url = '$baseUrl/chat/completions';
    
    // ★ 修复：优先使用字符串音色 ID（_mimoVoiceId），回退到枚举名（_mimoVoice.name）
    // 然后通过 _resolveMiMoVoiceId 将拼音映射为 MiMo API 需要的中文 Voice ID
    final rawVoiceId = _mimoVoiceId ?? _mimoVoice.name;
    final voiceId = _resolveMiMoVoiceId(rawVoiceId);
    
    // 解析所有 TTS 控制指令
    var allSegments = TTSStyleParser.parseAll(text);
    debugPrint('[$_tag] MiMo TTS 请求: url=$url, voice=$voiceId (rawVoiceId=$rawVoiceId, mimoVoiceId=${_mimoVoiceId ?? "null"}, mimoVoice=${_mimoVoice.name}), text长度=${text.length}, 段落数=${allSegments.length}');
    
    // ★ 优化：多标签不再分段合成，直接将原始文本（保留所有 TTS 标签）作为一次 API 调用
    // MiMo 引擎本身支持解析多个 [tts:...] 标签，分段合成反而更慢且容易触发 429 限流
    if (allSegments.length > 1) {
      debugPrint('[$_tag] 检测到 ${allSegments.length} 个 TTS 标签，使用单次请求合并合成（MiMo 引擎原生支持多标签）');
    }
    
    // 单标签合成
    final ttsData = allSegments.first;
    if (ttsData.hasControl) {
      debugPrint('[$_tag] MiMo TTS 控制指令: type=${ttsData.type}, control=${ttsData.controlContent}');
    }
    
    try {
      final dio = Dio();
      // ★ 动态超时：短文本（≤100字）用15秒，中等文本用30秒，长文本用60秒
      // 流式分句合成时每块约50-100字，15秒足够
      final receiveTimeout = text.length <= 100 
          ? const Duration(seconds: 15) 
          : text.length <= 300 
              ? const Duration(seconds: 30) 
              : const Duration(seconds: 60);
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = receiveTimeout;
      debugPrint('[$_tag] MiMo TTS 超时设置: receiveTimeout=${receiveTimeout.inSeconds}s (textLen=${text.length})');
      
      // 构建请求数据
      final requestData = TTSStyleParser.buildMiMoRequest(
        text: text,
        voice: voiceId,
        format: 'wav',
        model: 'mimo-v2.5-tts',
      );

      debugPrint('[$_tag] MiMo TTS 即将发出 dio.post: url=$url, model=mimo-v2.5-tts, '
          'voice=$voiceId, textLength=${text.length}');
      await _waitForRateLimit();
      final response = await dio.post(
        url,
        data: requestData,
        options: Options(
          headers: {
            'api-key': _apiKey,
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );

      debugPrint('[$_tag] MiMo TTS 响应: statusCode=${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          throw Exception('MiMo TTS: No choices in response. Response: ${response.data}');
        }
        
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final audio = message?['audio'] as Map<String, dynamic>?;
        final base64Data = audio?['data'] as String?;
        
        if (base64Data == null || base64Data.isEmpty) {
          throw Exception('MiMo TTS: No audio data in response. message keys: ${message?.keys.toList()}');
        }
        
        // 解码 Base64 音频数据
        final audioBytes = base64Decode(base64Data);
        debugPrint('[$_tag] MiMo TTS 音频数据大小: ${audioBytes.length} bytes');
        // ★ 修复：使用应用临时目录而非 /tmp/（Android 无 /tmp/ 权限）
        final tempDir = await getTemporaryDirectory();
        final path = outputPath ?? '${tempDir.path}/tts_mimo_${DateTime.now().millisecondsSinceEpoch}.wav';
        final file = File(path);
        await file.writeAsBytes(audioBytes);
        debugPrint('[$_tag] MiMo TTS 音频文件已保存: $path');
        return path;
      } else {
        throw Exception('MiMo TTS API error: ${response.statusCode}, body: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('[$_tag] MiMo TTS DioException: type=${e.type}, message=${e.message}, statusCode=${e.response?.statusCode}');
      throw Exception('MiMo TTS 网络错误: ${e.type} - ${e.message}');
    } catch (e) {
      debugPrint('[$_tag] MiMo TTS 未知错误: $e');
      throw Exception('Failed to synthesize speech with MiMo: $e');
    }
  }

  /// 多标签分段合成
  ///
  /// 将包含多个 TTS 标签的文本拆分为多个段落，两两合并后合成音频，减少 API 调用次数避免 429 限流。
  Future<String> _synthesizeMultipleSegments(List<TTSControlData> segments, String url, String? outputPath, {String? voiceId}) async {
    final tempDir = await getTemporaryDirectory();
    final audioFiles = <String>[];

    // ★ 两两合并段落：5段→3次请求(2+2+1)，4段→2次(2+2)，3段→2次(2+1)
    final mergedTexts = <String>[];
    final mergedLabels = <String>[];
    for (int i = 0; i < segments.length; i += 2) {
      final first = segments[i];
      if (i + 1 < segments.length) {
        final second = segments[i + 1];
        mergedTexts.add('${first.originalContent} ${second.originalContent}');
        mergedLabels.add('段落 ${i + 1}+${i + 2}');
      } else {
        mergedTexts.add(first.originalContent);
        mergedLabels.add('段落 ${i + 1}');
      }
    }

    debugPrint('[$_tag] ========== 多标签分段合成开始（两两合并）==========');
    debugPrint('[$_tag] 原始段落数: ${segments.length}, 合并后请求数: ${mergedTexts.length}');

    for (int i = 0; i < mergedTexts.length; i++) {
      // 批次间延迟：避免连续请求触发 429 限流
      if (i > 0) {
        final delayMs = 2000 + (i * 1000); // 2s, 3s, 4s...
        debugPrint('[$_tag]   ⏳ 批次间延迟 ${delayMs}ms 避免限流...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }

      final mergedText = mergedTexts[i];
      final previewText = mergedText.length > 50 ? mergedText.substring(0, 50) : mergedText;
      debugPrint('[$_tag] --- 批次 ${i + 1}/${mergedTexts.length} (${mergedLabels[i]}) ---');
      debugPrint('[$_tag]   合并文本预览: $previewText...');
      debugPrint('[$_tag]   合并文本长度: ${mergedText.length}');

      try {
        final requestData = TTSStyleParser.buildMiMoRequest(
          text: mergedText,
          voice: voiceId ?? _resolveMiMoVoiceId(_mimoVoice.name),
          format: 'wav',
          model: 'mimo-v2.5-tts',
        );
        
        debugPrint('[$_tag]   请求数据: messages=${requestData['messages']}');
        
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 15);
        dio.options.receiveTimeout = const Duration(seconds: 90);
        
        // 429 限流重试：最多重试 3 次，指数退避
        Response? response;
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            await _waitForRateLimit();
            response = await dio.post(
              url,
              data: requestData,
              options: Options(
                headers: {
                  'api-key': _apiKey,
                  'Content-Type': 'application/json',
                },
                responseType: ResponseType.json,
                validateStatus: (status) => status != null && (status >= 200 && status < 300 || status == 429),
              ),
            );

            if (response.statusCode == 429) {
              final retryAfter = response.headers.value('retry-after');
              final waitMs = retryAfter != null
                  ? int.parse(retryAfter) * 1000
                  : (3000 * (1 << attempt)); // 3s, 6s, 12s
              debugPrint('[$_tag]   ⚠️ MiMo 429 限流，${waitMs}ms 后重试 (${attempt + 1}/3)');
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            break;
          } on DioException catch (e) {
            if (e.response?.statusCode == 429 && attempt < 2) {
              final waitMs = 3000 * (1 << attempt);
              debugPrint('[$_tag]   ⚠️ MiMo 429 限流(DioException)，${waitMs}ms 后重试 (${attempt + 1}/3)');
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            rethrow;
          }
        }

        if (response == null) {
          debugPrint('[$_tag]   ❌ 批次 ${i + 1} 请求失败（重试耗尽）');
          continue;
        }
        
        debugPrint('[$_tag]   响应状态: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices[0]['message'] as Map<String, dynamic>?;
            final audio = message?['audio'] as Map<String, dynamic>?;
            final base64Data = audio?['data'] as String?;
            
            if (base64Data != null && base64Data.isNotEmpty) {
              final audioBytes = base64Decode(base64Data);
              final segmentPath = '${tempDir.path}/tts_segment_$i.wav';
              await File(segmentPath).writeAsBytes(audioBytes);
              audioFiles.add(segmentPath);
              debugPrint('[$_tag]   ✅ 批次 ${i + 1} 合成成功: ${audioBytes.length} bytes');
            } else {
              debugPrint('[$_tag]   ❌ 批次 ${i + 1} 响应中无音频数据');
            }
          } else {
            debugPrint('[$_tag]   ❌ 批次 ${i + 1} 响应中无 choices');
          }
        } else {
          debugPrint('[$_tag]   ❌ 批次 ${i + 1} HTTP 错误: ${response.statusCode}');
        }
      } catch (e, stack) {
        debugPrint('[$_tag]   ❌ 批次 ${i + 1} 合成异常: $e');
        debugPrint('[$_tag]   堆栈: $stack');
      }
    }
    
    debugPrint('[$_tag] ========== 分段合成结果: ${audioFiles.length}/${mergedTexts.length} 成功 ==========');
    
    if (audioFiles.isEmpty) {
      throw Exception('所有段落合成失败');
    }
    
    // 拼接音频文件
    final finalPath = outputPath ?? '${tempDir.path}/tts_mimo_${DateTime.now().millisecondsSinceEpoch}.wav';
    final combinedPath = await _concatenateWavFiles(audioFiles);
    if (finalPath != combinedPath) {
      await File(combinedPath).copy(finalPath);
      try { await File(combinedPath).delete(); } catch (_) {}
    }
    
    // 清理临时文件
    for (final file in audioFiles) {
      try { await File(file).delete(); } catch (_) {}
    }
    
    debugPrint('[$_tag] 多段落合成完成: $finalPath');
    return finalPath;
  }

  /// 使用小米 MiMo TTS 声音克隆合成
  ///
  /// [referenceAudioPath] 参考音频文件路径（mp3 或 wav 格式）
  /// [text] 要合成的文本
  /// [outputPath] 可选的输出路径
  /// 
  /// 根据 MiMo API 要求：
  /// - voice 字段必须是 DataURL 格式：data:audio/wav;base64,XXXX
  /// - Base64 字符串大小不能超过 10MB
  /// - VoiceClone 模式下，user 消息可选（仅在有风格指令时添加），assistant 消息为合成文本
  Future<String> synthesizeWithMiMoClone({
    required String referenceAudioPath,
    required String text,
    String? outputPath,
  }) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw StateError('MiMo API key not configured. Please set MiMo API key in voice settings.');
    }

    // ★ 使用 AudioFormatUtils 基于文件头魔数检测实际格式，确保 MIME 类型与内容匹配
    // 内部已处理：文件读取、大小检查（10MB）、base64 编码、DataURL 构建
    // 这比仅靠扩展名更可靠（iOS 录音文件扩展名可能不准确）
    final voiceData = await AudioFormatUtils.prepareMiMoVoiceDataUrl(referenceAudioPath);

    // 使用 parseAll 解析所有 TTS 控制指令（支持多标签）
    var allSegments = TTSStyleParser.parseAll(text);
    debugPrint('[$_tag] MiMo VoiceClone 请求: text长度=${text.length}, 段落数=${allSegments.length}');

    // 优先使用构造参数，否则从 SharedPreferences 读取自定义地址
    final baseUrl = _mimoBaseUrl ?? await _getMiMoBaseUrl();
    final url = '$baseUrl/chat/completions';

    // ★ 优化：多标签不再分段合成，直接将原始文本（保留所有 TTS 标签）作为一次 API 调用
    // MiMo 引擎本身支持解析多个 [tts:...] 标签，分段合成反而更慢且容易触发 429 限流
    if (allSegments.length > 1) {
      debugPrint('[$_tag] VoiceClone 检测到 ${allSegments.length} 个 TTS 标签，使用单次请求合并合成（MiMo 引擎原生支持多标签）');
    }

    // 单标签合成
    final ttsData = allSegments.first;
    if (ttsData.hasControl) {
      debugPrint('[$_tag] MiMo VoiceClone 控制指令: type=${ttsData.type}, control=${ttsData.controlContent}');
    }

    try {
      final dio = Dio();
      // ★ VoiceClone 比普通 MiMo 慢（需处理参考音频），receiveTimeout 设为90秒
      // 外层 synthesize 总超时为2分钟，这里必须小于2分钟
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 90);

      // 构建请求数据
      final requestData = TTSStyleParser.buildMiMoCloneRequest(
        text: text,
        voiceDataUrl: voiceData,
        format: 'wav',
        model: 'mimo-v2.5-tts-voiceclone',
      );

      // 429 限流重试：最多重试 2 次，指数退避
      Response? response;
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          await _waitForRateLimit();
          response = await dio.post(
            url,
            data: requestData,
            options: Options(
              headers: {
                'api-key': _apiKey,
                'Content-Type': 'application/json',
              },
              responseType: ResponseType.json,
              validateStatus: (status) => status != null && (status >= 200 && status < 300 || status == 429),
            ),
          );

          if (response.statusCode == 429) {
            final retryAfter = response.headers.value('retry-after');
            final waitMs = retryAfter != null
                ? int.parse(retryAfter) * 1000
                : (2000 * (1 << attempt)); // 2s, 4s
            debugPrint('[$_tag] ⚠️ MiMo 429 限流，${waitMs}ms 后重试 (${attempt + 1}/2)');
            await Future.delayed(Duration(milliseconds: waitMs));
            continue;
          }
          break; // 2xx 成功，跳出重试循环
        } on DioException catch (e) {
          if (e.response?.statusCode == 429 && attempt < 1) {
            final waitMs = 2000 * (1 << attempt);
            debugPrint('[$_tag] ⚠️ MiMo 429 限流(DioException)，${waitMs}ms 后重试 (${attempt + 1}/2)');
            await Future.delayed(Duration(milliseconds: waitMs));
            continue;
          }
          rethrow;
        }
      }

      if (response == null) {
        throw Exception('MiMo VoiceClone 请求失败（重试耗尽）');
      }

      debugPrint('[$_tag] MiMo VoiceClone 响应: statusCode=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          throw Exception('MiMo VoiceClone: No choices in response');
        }

        final message = choices[0]['message'] as Map<String, dynamic>?;
        final audio = message?['audio'] as Map<String, dynamic>?;
        final base64Data = audio?['data'] as String?;

        if (base64Data == null || base64Data.isEmpty) {
          throw Exception('MiMo VoiceClone: No audio data in response');
        }

        // 解码 Base64 音频数据
        final resultAudioBytes = base64Decode(base64Data);
        debugPrint('[$_tag] MiMo VoiceClone 音频数据大小: ${resultAudioBytes.length} bytes');

        final tempDir = await getTemporaryDirectory();
        final path = outputPath ?? '${tempDir.path}/tts_clone_${DateTime.now().millisecondsSinceEpoch}.wav';
        final outFile = File(path);
        // 确保目录存在（macOS 沙盒下缓存目录可能被清理）
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(resultAudioBytes);
        debugPrint('[$_tag] MiMo VoiceClone 音频文件已保存: $path');
        return path;
      } else {
        throw Exception('MiMo VoiceClone API error: ${response.statusCode}, body: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('[$_tag] MiMo VoiceClone DioException: type=${e.type}, message=${e.message}, statusCode=${e.response?.statusCode}');
      throw Exception('MiMo VoiceClone 网络错误: ${e.type} - ${e.message}');
    } catch (e) {
      debugPrint('[$_tag] MiMo VoiceClone 未知错误: $e');
      throw Exception('Failed to synthesize speech with MiMo VoiceClone: $e');
    }
  }

  /// VoiceClone 多标签分段合成
  ///
  /// 将包含多个 TTS 标签的文本拆分为多个段落，两两合并后使用 VoiceClone API 合成，减少 API 调用次数避免 429 限流。
  Future<String> _synthesizeMultipleCloneSegments(
    List<TTSControlData> segments,
    String voiceData,
    String url,
    String? outputPath,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final audioFiles = <String>[];

    // ★ 两两合并段落：5段→3次请求(2+2+1)，4段→2次(2+2)，3段→2次(2+1)
    final mergedTexts = <String>[];
    final mergedLabels = <String>[];
    for (int i = 0; i < segments.length; i += 2) {
      final first = segments[i];
      if (i + 1 < segments.length) {
        final second = segments[i + 1];
        mergedTexts.add('${first.originalContent} ${second.originalContent}');
        mergedLabels.add('段落 ${i + 1}+${i + 2}');
      } else {
        mergedTexts.add(first.originalContent);
        mergedLabels.add('段落 ${i + 1}');
      }
    }

    debugPrint('[$_tag] ========== VoiceClone 多标签分段合成（两两合并）==========');
    debugPrint('[$_tag] 原始段落数: ${segments.length}, 合并后请求数: ${mergedTexts.length}');

    for (int i = 0; i < mergedTexts.length; i++) {
      // 批次间延迟：避免连续请求触发 429 限流
      if (i > 0) {
        final delayMs = 2000 + (i * 1000); // 2s, 3s, 4s...
        debugPrint('[$_tag]   ⏳ 批次间延迟 ${delayMs}ms 避免限流...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }

      final mergedText = mergedTexts[i];
      final previewText = mergedText.length > 50 ? mergedText.substring(0, 50) : mergedText;
      debugPrint('[$_tag] --- VoiceClone 批次 ${i + 1}/${mergedTexts.length} (${mergedLabels[i]}) ---');
      debugPrint('[$_tag]   合并文本预览: $previewText...');
      debugPrint('[$_tag]   合并文本长度: ${mergedText.length}');

      try {
        final requestData = TTSStyleParser.buildMiMoCloneRequest(
          text: mergedText,
          voiceDataUrl: voiceData,
          format: 'wav',
          model: 'mimo-v2.5-tts-voiceclone',
        );

        debugPrint('[$_tag]   请求数据: messages=${requestData['messages']}');

        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 90);

        // 429 限流重试：最多重试 3 次，指数退避
        Response? response;
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            await _waitForRateLimit();
            response = await dio.post(
              url,
              data: requestData,
              options: Options(
                headers: {
                  'api-key': _apiKey,
                  'Content-Type': 'application/json',
                },
                responseType: ResponseType.json,
                validateStatus: (status) => status != null && (status >= 200 && status < 300 || status == 429),
              ),
            );

            if (response.statusCode == 429) {
              final retryAfter = response.headers.value('retry-after');
              final waitMs = retryAfter != null
                  ? int.parse(retryAfter) * 1000
                  : (3000 * (1 << attempt)); // 3s, 6s, 12s
              debugPrint('[$_tag]   ⚠️ 429 限流，${waitMs}ms 后重试 (${attempt + 1}/3)');
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            break;
          } on DioException catch (e) {
            if (e.response?.statusCode == 429 && attempt < 2) {
              final waitMs = 3000 * (1 << attempt);
              debugPrint('[$_tag]   ⚠️ 429 限流(DioException)，${waitMs}ms 后重试 (${attempt + 1}/3)');
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            rethrow;
          }
        }

        if (response == null) {
          debugPrint('[$_tag]   ❌ 批次 ${i + 1} 请求失败（重试耗尽）');
          continue;
        }

        debugPrint('[$_tag]   响应状态: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final choices = data['choices'] as List<dynamic>?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices[0]['message'] as Map<String, dynamic>?;
            final audio = message?['audio'] as Map<String, dynamic>?;
            final base64Data = audio?['data'] as String?;

            if (base64Data != null && base64Data.isNotEmpty) {
              final audioBytes = base64Decode(base64Data);
              final segmentPath = '${tempDir.path}/tts_clone_segment_$i.wav';
              await File(segmentPath).writeAsBytes(audioBytes);
              audioFiles.add(segmentPath);
              debugPrint('[$_tag]   ✅ 批次 ${i + 1} 合成成功: ${audioBytes.length} bytes');
            } else {
              debugPrint('[$_tag]   ❌ 批次 ${i + 1} 响应中无音频数据');
            }
          } else {
            debugPrint('[$_tag]   ❌ 批次 ${i + 1} 响应中无 choices');
          }
        } else {
          debugPrint('[$_tag]   ❌ 批次 ${i + 1} HTTP 错误: ${response.statusCode}');
        }
      } catch (e, stack) {
        debugPrint('[$_tag]   ❌ 批次 ${i + 1} 合成异常: $e');
        debugPrint('[$_tag]   堆栈: $stack');
      }
    }

    debugPrint('[$_tag] ========== VoiceClone 分段合成结果: ${audioFiles.length}/${mergedTexts.length} 成功 ==========');

    if (audioFiles.isEmpty) {
      throw Exception('所有 VoiceClone 段落合成失败');
    }

    // 拼接音频文件
    final finalPath = outputPath ?? '${tempDir.path}/tts_clone_${DateTime.now().millisecondsSinceEpoch}.wav';
    final combinedPath = await _concatenateWavFiles(audioFiles);
    if (finalPath != combinedPath) {
      await File(combinedPath).copy(finalPath);
      try { await File(combinedPath).delete(); } catch (_) {}
    }

    // 清理临时文件
    for (final file in audioFiles) {
      try { await File(file).delete(); } catch (_) {}
    }

    debugPrint('[$_tag] VoiceClone 多段落合成完成: $finalPath');
    return finalPath;
  }

  /// 初始化系统 TTS
  ///
  /// Android TTS 引擎绑定是异步的，直接调用 API 会得到 "not bound to TTS engine" 错误。
  /// 修复方案：轮询 speak(' ') 直到返回 1（绑定成功），配合回调双重确认。
  /// 注意：speak('') 空字符串在 Android 上被静默忽略，不会触发引擎绑定！
  Future<void> _initSystemTts() async {
    if (_systemTtsInitialized) {
      debugPrint('[$_tag] _initSystemTts() 已初始化，跳过');
      return;
    }
    debugPrint('[$_tag] _initSystemTts() 开始初始化系统 TTS...');

    try {
      _systemTts = FlutterTts();

      if (PlatformUtils.isAndroid) {
        final bindCompleter = Completer<void>();

        _systemTts!.setCompletionHandler(() {
          _systemTtsBound = true;
          _systemTtsInitialized = true;
          if (!bindCompleter.isCompleted) bindCompleter.complete();
          _isPlaying = false;
        });
        _systemTts!.setStartHandler(() {
          _systemTtsBound = true;
          _systemTtsInitialized = true;
          if (!bindCompleter.isCompleted) bindCompleter.complete();
        });
        _systemTts!.setErrorHandler((msg) {
          debugPrint('[TTSService] Android TTS 错误: $msg');
          if (!bindCompleter.isCompleted) bindCompleter.complete();
          _isPlaying = false;
        });

        bool bound = false;
        for (int i = 0; i < 15 && !bound; i++) {
          try {
            final result = await _systemTts!.speak(' ');
            debugPrint('[TTSService] Android TTS 绑定尝试 ${i + 1}: speak 返回 $result');
            if (result == 1) {
              bound = true;
              _systemTtsBound = true;
              _systemTtsInitialized = true;
              if (!bindCompleter.isCompleted) bindCompleter.complete();
              break;
            }
          } catch (e) {
            debugPrint('[TTSService] Android TTS 绑定尝试 ${i + 1} 异常: $e');
          }
          await Future.delayed(const Duration(milliseconds: 600));
        }

        if (!bound) {
          debugPrint('[TTSService] Android TTS 轮询未绑定，等待回调...');
          await bindCompleter.future.timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('[TTSService] Android TTS 回调也超时，强制标记为已绑定');
              _systemTtsBound = true;
              _systemTtsInitialized = true;
            },
          );
        }

        try {
          await _systemTts!.setSharedInstance(true);
        } catch (_) {}

        try {
          await _systemTts!.setLanguage('zh-CN');
        } catch (_) {
          try {
            await _systemTts!.setLanguage('en-US');
          } catch (_) {}
        }

        // ★ 修复：应用系统 TTS 音色 ID
        // 之前 _systemVoiceId 被忽略，导致设置不同音色但始终使用默认音色
        if (_systemVoiceId != null && _systemVoiceId.isNotEmpty) {
          try {
            // Android/iOS 都使用 setVoice({"name": ..., "locale": ...})
            // name 一般是 voiceId 本身
            final voices = await _systemTts!.getVoices;
            if (voices != null) {
              final voiceList = voices.cast<Map<dynamic, dynamic>>();
              // 优先按 voiceId 匹配，其次按名字
              Map<String, String>? matched;
              for (final v in voiceList) {
                final vid = v['name']?.toString() ?? '';
                if (vid == _systemVoiceId) {
                  matched = {
                    'name': v['name']?.toString() ?? '',
                    'locale': v['locale']?.toString() ?? 'zh-CN',
                  };
                  break;
                }
              }
              if (matched != null) {
                await _systemTts!.setVoice(matched);
                debugPrint('[TTSService] ✅ 设置系统 TTS 音色: name=${matched['name']}, locale=${matched['locale']}');
              } else {
                // fallback: 直接用 voiceId 设置
                await _systemTts!.setVoice({
                  'name': _systemVoiceId,
                  'locale': 'zh-CN',
                });
                debugPrint('[TTSService] ⚠️ 未找到匹配音色，按 name=$_systemVoiceId 设置');
              }
            }
          } catch (e) {
            debugPrint('[TTSService] 设置系统 TTS 音色失败: $e');
          }
        }

      } else if (PlatformUtils.isIOS) {
        try {
          await _systemTts!.setLanguage('zh-CN');
        } catch (_) {
          try {
            await _systemTts!.setLanguage('en-US');
          } catch (_) {}
        }
        // ★ iOS 也需要设置系统 TTS 音色（之前遗漏）
        if (_systemVoiceId != null && _systemVoiceId.isNotEmpty) {
          try {
            final voices = await _systemTts!.getVoices;
            if (voices != null) {
              final voiceList = voices.cast<Map<dynamic, dynamic>>();
              Map<String, String>? matched;
              for (final v in voiceList) {
                final vid = v['name']?.toString() ?? '';
                if (vid == _systemVoiceId) {
                  matched = {
                    'name': v['name']?.toString() ?? '',
                    'locale': v['locale']?.toString() ?? 'zh-CN',
                  };
                  break;
                }
              }
              if (matched != null) {
                await _systemTts!.setVoice(matched);
                debugPrint('[TTSService] ✅ iOS 设置系统 TTS 音色: name=${matched['name']}, locale=${matched['locale']}');
              } else {
                await _systemTts!.setVoice({
                  'name': _systemVoiceId,
                  'locale': 'zh-CN',
                });
                debugPrint('[TTSService] ⚠️ iOS 未找到匹配音色，按 name=$_systemVoiceId 设置');
              }
            }
          } catch (e) {
            debugPrint('[TTSService] iOS 设置系统 TTS 音色失败: $e');
          }
        }
      } else if (PlatformUtils.isMacOS) {
        try {
          await _systemTts!.setSharedInstance(true);
        } catch (_) {}
        
        try {
          await _systemTts!.setLanguage('zh-CN');
        } catch (_) {
          try {
            await _systemTts!.setLanguage('en-US');
          } catch (_) {}
        }
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        try {
          await _systemTts!.getVoices;
        } catch (_) {
          try {
            await _systemTts!.setLanguage('zh-CN');
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (_) {}
        }
      } else if (PlatformUtils.isWindows) {
        try {
          await _systemTts!.setLanguage('zh-CN');
        } catch (_) {
          try {
            await _systemTts!.setLanguage('en-US');
          } catch (_) {}
        }
      }

      try {
        await _systemTts!.setSpeechRate(_speechRate);
      } catch (_) {}
      try {
        await _systemTts!.setPitch(1.0);
      } catch (_) {}

      _systemTts!.setCompletionHandler(() {
        _isPlaying = false;
      });
      _systemTts!.setErrorHandler((msg) {
        _isPlaying = false;
      });

      _systemTtsInitialized = true;
      debugPrint('[$_tag] _initSystemTts() ✅ 初始化完成: initialized=$_systemTtsInitialized, bound=$_systemTtsBound');
    } catch (e) {
      _systemTtsInitialized = false;
      debugPrint('[$_tag] _initSystemTts() ❌ 初始化失败: $e');
    }
  }

  /// 使用系统 TTS 直接播放
  Future<void> _speakWithSystem(String text) async {
    debugPrint('[$_tag] _speakWithSystem() 开始: text长度=${text.length}');
    if (!_systemTtsInitialized || _systemTts == null) {
      debugPrint('[$_tag] _speakWithSystem() 系统TTS未初始化，开始初始化...');
      await _initSystemTts();
    }
    
    if (_systemTts == null) {
      debugPrint('[$_tag] _speakWithSystem() ❌ _systemTts 为 null，初始化失败');
      throw Exception('系统 TTS 未初始化，请检查系统语音设置');
    }

    if (!_systemTtsBound && PlatformUtils.isAndroid) {
      debugPrint('[$_tag] _speakWithSystem() 引擎未绑定，尝试重新绑定...');
      final rebindResult = await _systemTts!.speak(' ');
      debugPrint('[$_tag] _speakWithSystem() 重新绑定结果: $rebindResult');
      if (rebindResult == 1) {
        _systemTtsBound = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    debugPrint('[$_tag] _speakWithSystem() 系统TTS已就绪: initialized=$_systemTtsInitialized, bound=$_systemTtsBound');

    const maxRetries = 3;
    String? lastError;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        _isPlaying = true;
        
        if (attempt == 0) {
          try {
            await _systemTts!.awaitSpeakCompletion(true);
          } catch (_) {}
        }

        debugPrint('[$_tag] _speakWithSystem() 第${attempt + 1}次 speak 调用');
        final result = await _systemTts!.speak(text);
        debugPrint('[$_tag] _speakWithSystem() speak 返回: $result');
        
        if (result == 1) {
          debugPrint('[$_tag] ✅ 系统 TTS speak 成功（第 ${attempt + 1} 次）');
          return;
        }
        
        // result == -1 表示引擎未绑定
        debugPrint('[$_tag] ⚠️ 系统 TTS speak 返回 $result（第 ${attempt + 1} 次，可能引擎未绑定）');
        
        if (attempt >= 1) {
          debugPrint('[$_tag] 第${attempt + 1}次失败，重建系统TTS实例...');
          _systemTtsBound = false;
          _systemTtsInitialized = false;
          try {
            await _systemTts!.stop();
          } catch (_) {}
          _systemTts = null;
          await _initSystemTts();
          
          if (_systemTts == null) {
            lastError = '重新初始化失败';
            debugPrint('[$_tag] ❌ 重建系统TTS实例失败');
            continue;
          }
          debugPrint('[$_tag] 系统TTS实例重建完成');
        } else {
          debugPrint('[$_tag] 等待1秒后重试...');
          await Future.delayed(const Duration(seconds: 1));
        }

        try {
          await _systemTts!.awaitSpeakCompletion(true);
        } catch (_) {}
        
        debugPrint('[$_tag] 重试 speak...');
        final retryResult = await _systemTts!.speak(text);
        debugPrint('[$_tag] 重试 speak 返回: $retryResult');
        if (retryResult == 1) {
          debugPrint('[$_tag] ✅ 系统 TTS speak 重试成功');
          return;
        }
        
        lastError = 'speak 返回 $retryResult';
        if (attempt < maxRetries - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        _isPlaying = false;
        lastError = e.toString();
        debugPrint('[TTSService] 系统 TTS speak 异常（第 ${attempt + 1} 次）: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    
    // 所有重试均失败，仅在最终失败时输出一条日志
    debugPrint('[TTSService] 系统 TTS 最终失败（静默跳过）: $lastError');
  }

  /// 使用系统 TTS 合成（保存到文件）
  Future<String> _synthesizeWithSystem(String text, {String? outputPath}) async {
    debugPrint('[$_tag] _synthesizeWithSystem() 开始: text长度=${text.length}');
    await _initSystemTts();
    
    if (_systemTts == null) {
      debugPrint('[$_tag] _synthesizeWithSystem() ❌ 系统 TTS 未初始化');
      throw Exception('系统 TTS 未初始化');
    }

    // ★★★ macOS 平台特殊处理 ★★★
    // flutter_tts 的 synthesizeToFile 在 macOS 上有已知问题：
    // 1. 路径嵌套：原生代码会把 Documents 目录前缀拼到已有的绝对路径上
    // 2. kAudioFileUnsupportedDataFormatError (2003334207)：AVAudioFile 格式不兼容
    // 因此 macOS 上直接使用 speak 播放，不走 synthesizeToFile
    if (Platform.isMacOS) {
      debugPrint('[$_tag] _synthesizeWithSystem() macOS: 跳过 synthesizeToFile，直接 speak 播放');
      await _speakWithSystem(text);
      return '';
    }

    try {
      // 确定输出路径
      final String path = outputPath ?? 
          '${(await getTemporaryDirectory()).path}/tts_system_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      debugPrint('[$_tag] _synthesizeWithSystem() → synthesizeToFile: $path');
      // 合成到文件（部分平台支持）
      await _systemTts!.synthesizeToFile(text, path);
      debugPrint('[$_tag] _synthesizeWithSystem() ✅ 合成完成: $path');
      
      return path;
    } catch (e) {
      debugPrint('[$_tag] _synthesizeWithSystem() ❌ synthesizeToFile 失败: $e');
      // 如果合成到文件失败，直接播放
      debugPrint('[$_tag] _synthesizeWithSystem() → 降级为直接 speak 播放');
      await _speakWithSystem(text);
      return ''; // 返回空路径，表示已直接播放
    }
  }

  /// 获取系统可用语音列表
  Future<List<Map<String, String>>> getAvailableSystemVoices() async {
    await _initSystemTts();
    
    if (_systemTts == null) {
      return [];
    }

    try {
      final voices = await _systemTts!.getVoices;
      return (voices as List).map((v) => {
        'name': v['name']?.toString() ?? '',
        'locale': v['locale']?.toString() ?? '',
      }).toList();
    } catch (e) {
      debugPrint('[TTS] Failed to get system voices: $e');
      return [];
    }
  }

  /// 获取可用的语音列表
  List<VoiceModel> get availableOpenAIVoices {
    return VoiceModel.values;
  }

  /// 获取可用的 Sherpa 语音列表
  List<SherpaVoiceInfo> get availableSherpaVoices {
    return SherpaVoiceInfo.presets;
  }

  /// 获取语音名称
  String getVoiceName(VoiceModel voice) {
    switch (voice) {
      case VoiceModel.alloy:
        return ' Alloy';
      case VoiceModel.echo:
        return ' Echo';
      case VoiceModel.fable:
        return ' Fable';
      case VoiceModel.onyx:
        return ' Onyx';
      case VoiceModel.nova:
        return ' Nova';
      case VoiceModel.shimmer:
        return ' Shimmer';
    }
  }

  /// 获取 Sherpa 语音名称
  String getSherpaVoiceName(SherpaVoice voice) {
    final info = SherpaVoiceInfo.presets.firstWhere(
      (v) => v.id == voice.name,
      orElse: () => SherpaVoiceInfo.presets.first,
    );
    return info.name;
  }

  /// 释放资源
  void dispose() {
    _playerStateSubscription?.cancel();
    _playerStateSubscription = null;
    // ★ 修复：释放 AudioPlayer，避免多实例冲突导致闪退
    try { _audioPlayer.dispose(); } catch (_) {}
    _sherpaTts?.free();
    _sherpaInitialized = false;
    _systemTts?.stop();
    _systemTtsInitialized = false;
  }
}

// Riverpod Providers

/// 创建 TTS 服务（根据用户设置）
/// 
/// 参数：
/// - provider: TTS 提供商类型（'sherpa' / 'system' / 'openai'）
/// - sherpaModelId: Sherpa 模型 ID
/// - ttsVoice: 音色 ID
/// - speechRate: 语速
TTSService createTTSService({
  required String provider,
  String? sherpaModelId,
  String? ttsVoice,
  double speechRate = 1.0,
  String? openaiApiKey,
  String? mimoApiKey,
  MiMoVoice mimoVoice = MiMoVoice.mimo_default,
  String? cloneReferenceAudioPath,
  String? cosyvoiceBaseUrl,
  CosyVoiceMode cosyvoiceMode = CosyVoiceMode.cross_lingual,
  String cosyvoiceInstructText = '用自然的语气说话',
  String? fishaudioBaseUrl,
  String? fishaudioReferenceAudioPath,
  String? fishaudioReferenceText,
}) {
  final ttsProvider = switch (provider) {
    'sherpa' => TTSProvider.sherpa,
    'system' => TTSProvider.system,
    'openai' => TTSProvider.openai,
    'mimo' => TTSProvider.mimo,
    'cosyvoice' => TTSProvider.cosyvoice,
    'fishaudio' => TTSProvider.fishaudio,
    _ => TTSProvider.sherpa, // 默认使用 Sherpa
  };
  
  return TTSService(
    provider: ttsProvider,
    apiKey: provider == 'mimo' ? mimoApiKey : openaiApiKey,
    mimoVoice: mimoVoice,
    cloneReferenceAudioPath: provider == 'cosyvoice' && cloneReferenceAudioPath != null && cloneReferenceAudioPath.isNotEmpty
        ? cloneReferenceAudioPath
        : (provider != 'cosyvoice' ? cloneReferenceAudioPath : null),
    sherpaModelId: sherpaModelId,
    speakerId: ttsVoice != null ? int.tryParse(ttsVoice) ?? 0 : 0,
    speechRate: speechRate,
    cosyvoiceBaseUrl: provider == 'cosyvoice' ? cosyvoiceBaseUrl : null,
    cosyvoiceMode: cosyvoiceMode,
    cosyvoiceInstructText: cosyvoiceInstructText,
    fishaudioBaseUrl: provider == 'fishaudio' ? fishaudioBaseUrl : null,
    fishaudioReferenceAudioPath: provider == 'fishaudio' ? fishaudioReferenceAudioPath : null,
    fishaudioReferenceText: provider == 'fishaudio' ? fishaudioReferenceText : null,
  );
}

final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService(
    provider: TTSProvider.openai,
    apiKey: null,
    voice: VoiceModel.alloy,
  );
});

final ttsStateProvider = StateProvider<AudioPlayerState>((ref) => AudioPlayerState.idle);

final currentAudioPathProvider = StateProvider<String?>((ref) => null);

final availableVoicesProvider = Provider<List<VoiceModel>>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return ttsService.availableOpenAIVoices;
});

final availableSherpaVoicesProvider = Provider<List<SherpaVoiceInfo>>((ref) {
  final ttsService = ref.watch(ttsServiceProvider);
  return ttsService.availableSherpaVoices;
});