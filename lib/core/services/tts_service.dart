// ignore_for_file: constant_identifier_names
/// TTS 语音合成服务 - LLM Studio 语音输出模块
/// 
/// 负责：
/// - 文本转语音合成
/// - 多种 TTS 后端支持（OpenAI / Sherpa-ONNX / 系统内置）
/// - 长文本分块处理
/// - 音频播放控制
/// 
/// 支持的 TTS 后端：
/// - OpenAI TTS API（云端，高质量）
/// - Sherpa-ONNX（本地离线，中文优化）
/// - 系统内置 TTS（macOS/Windows/iOS/Android）
/// 
/// @author JianMa
/// @version 1.1.0
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
import 'voice_model_service.dart';
import 'tts_style_parser.dart';
import '../platform/platform_utils.dart';

/// TTS 提供商类型
enum TTSProvider {
  openai,    // OpenAI TTS API (云端)
  mimo,      // 小米 MiMo TTS API (云端，中文优化)
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
enum MiMoVoice {
  Chloe,         // MiMo 默认音色
  mimo_default,  // MiMo 默认音色 (V2)
  default_zh,    // 中文女声
  default_en,    // 英文女声
}

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
  /// 小米 MiMo TTS 音色
  final MiMoVoice _mimoVoice;
  /// 克隆音色参考音频路径（非空时使用克隆模式）
  final String? _cloneReferenceAudioPath;
  /// 小米 MiMo TTS 基础 URL（可选，默认使用官方端点）
  final String? _mimoBaseUrl;
  final double _speechRate;
  /// Sherpa 模型 ID（对应 VoiceModelService 中的模型 id，用于定位解压后目录）
  final String? _sherpaModelId;
  /// 说话人 ID（当模型支持多说话人时使用）
  final int _speakerId;
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
    MiMoVoice mimoVoice = MiMoVoice.Chloe,
    String? cloneReferenceAudioPath,
    String? mimoBaseUrl,
    double speechRate = 1.0,  // 默认语速 1x
    String? sherpaModelId,
    int speakerId = 0,
  })  : _provider = provider,
        _apiKey = apiKey,
        _voice = voice,
        _mimoVoice = mimoVoice,
        _cloneReferenceAudioPath = cloneReferenceAudioPath,
        _mimoBaseUrl = mimoBaseUrl,
        _speechRate = speechRate,
        _sherpaModelId = sherpaModelId,
        _speakerId = speakerId;

  /// 合成语音（返回音频文件路径）
  Future<String> synthesize(String text, {String? outputPath}) async {
    debugPrint('[$_tag] synthesize() 开始: provider=$_provider, text长度=${text.length}');
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
      // Sherpa 失败时（如移动端 OOM 保护），自动降级到系统 TTS
      if (_provider == TTSProvider.sherpa) {
        debugPrint('[$_tag] Sherpa 合成失败，自动降级到系统 TTS: $e');
        return await _synthesizeWithSystem(text, outputPath: outputPath);
      }
      // MiMo 失败时降级到系统 TTS
      if (_provider == TTSProvider.mimo) {
        debugPrint('[$_tag] MiMo 合成失败，自动降级到系统 TTS: $e');
        return await _synthesizeWithSystem(text, outputPath: outputPath);
      }
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
      // 任何 TTS 失败时，如果 provider 不是 system，尝试降级到 system
      if (_provider != TTSProvider.system) {
        debugPrint('[$_tag] TTS $_provider 播放失败，降级到系统 TTS: $e');
        try {
          await _speakWithSystem(text);
          debugPrint('[$_tag] 系统 TTS 降级播放成功');
        } catch (fallbackError) {
          // 系统 TTS 也失败，静默处理（_speakWithSystem 内部已有重试和日志）
          debugPrint('[$_tag] 系统 TTS 降级也失败: $fallbackError');
        }
      } else {
        rethrow;
      }
    }
  }

  /// 播放长文本（自动分句分段合成，避免卡死）
  ///
  /// [onProgress] 可选回调：(当前块序号, 总块数) → 可用于 UI 进度展示
  /// 返回是否正常播完（被打断返回 false）
  /// 
  /// 【修复 V2】改为「先全部合成 → WAV 合并 → 一次性播放」的两阶段方案，
  /// 彻底消除旧方案「逐块合成+播放」导致的块间音频断层/跳跃问题。
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
      // 包含 TTS 标签：直接调用 synthesize，内部会自动按标签分段合成
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

    // 2. 将短句合并成块（每块最多 5 句或 250 字）
    final chunks = <String>[];
    for (var i = 0; i < sentences.length; i += 5) {
      final chunk = sentences.skip(i).take(5).join('');
      if (chunk.length > 250) {
        final trimmed = chunk.substring(0, 200);
        final lastPunct = trimmed.lastIndexOf(RegExp(r'[，。、；：！……？]'));
        final cutoff = lastPunct > 100 ? lastPunct + 1 : 200;
        chunks.add(trimmed.substring(0, cutoff));
      } else {
        chunks.add(chunk);
      }
    }
    debugPrint('[$_tag] speakLongText() 分块结果: ${chunks.length}块');

    // 重置停止标志
    _stopRequested = false;

    // ============================
    // 阶段一：预合成所有音频块
    // ============================
    debugPrint('[$_tag] ===== 阶段一：预合成全部 ${chunks.length} 个音频块 =====');
    final tempFiles = <String>[];
    const firstChunkTimeout = Duration(seconds: 30);
    const chunkTimeout = Duration(seconds: 15);

    for (var i = 0; i < chunks.length; i++) {
      if (_stopRequested) {
        debugPrint('[$_tag] 用户停止，退出预合成（已合成 $i/${chunks.length} 块）');
        for (final f in tempFiles) {
          try { await File(f).delete(); } catch (_) {}
        }
        return false;
      }
      onProgress?.call(i + 1, chunks.length);
      final timeout = i == 0 ? firstChunkTimeout : chunkTimeout;
      debugPrint('[$_tag] 合成 chunk[$i/${chunks.length}], 超时=${timeout.inSeconds}s');
      try {
        final path = await synthesize(chunks[i]).timeout(
          timeout,
          onTimeout: () {
            debugPrint('[$_tag] ⚠️ chunk[$i] 合成超时, 跳过');
            return '';
          },
        );
        if (path.isNotEmpty) {
          // 验证文件确实存在且非空
          final file = File(path);
          if (await file.exists()) {
            final size = await file.length();
            if (size > 0) {
              tempFiles.add(path);
              debugPrint('[$_tag] chunk[$i] 合成成功: $path ($size bytes)');
            } else {
              debugPrint('[$_tag] ⚠️ chunk[$i] 文件为空，跳过: $path');
            }
          } else {
            debugPrint('[$_tag] ⚠️ chunk[$i] 文件不存在，跳过: $path');
          }
        }
      } catch (e) {
        debugPrint('[$_tag] ❌ chunk[$i] 合成失败: $e, 跳过');
      }
    }

    if (tempFiles.isEmpty) {
      debugPrint('[$_tag] 未合成任何音频, 跳过播放');
      return true;
    }

    // ============================
    // 阶段二：将所有 WAV 文件合并为一个（消除块间播放间隔）
    // ============================
    debugPrint('[$_tag] ===== 阶段二：合并 ${tempFiles.length} 个 WAV 文件 =====');
    String combinedPath;
    try {
      combinedPath = await _concatenateWavFiles(tempFiles);
      debugPrint('[$_tag] 合并完成: $combinedPath');
    } catch (e) {
      debugPrint('[$_tag] ❌ WAV 合并失败: $e, 回退到单文件播放');
      combinedPath = tempFiles.first;
    }

    // ============================
    // 阶段三：一次性播放合并后的完整音频
    // ============================
    debugPrint('[$_tag] ===== 阶段三：播放合并音频 =====');
    try {
      await _playAudio(combinedPath);
      debugPrint('[$_tag] 合并音频播放完成');
    } catch (e) {
      debugPrint('[$_tag] ❌ 合并音频播放失败: $e');
    }

    // ============================
    // 阶段四：清理临时文件
    // ============================
    debugPrint('[$_tag] ===== 阶段四：清理临时文件 =====');
    for (final f in tempFiles) {
      try { await File(f).delete(); } catch (_) {}
    }
    if (combinedPath != tempFiles.first) {
      try { await File(combinedPath).delete(); } catch (_) {}
    }

    debugPrint('[$_tag] speakLongText() ✅ 全部完成, 共 ${tempFiles.length} 块');
    return true;
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
    return parts
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 1)
        .toList();
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

    // ★★★ 移动端 OOM 保护：Sherpa-ONNX VITS 模型在手机上加载会导致 OOM ★★★
    if (PlatformUtils.isMobile) {
      // 不尝试加载 Sherpa 模型，直接抛异常让上层降级
      throw Exception(
        '移动端不支持 Sherpa-ONNX 本地 TTS（内存不足）。n'
        '已自动切换为系统 TTS，请使用系统内置语音引擎。',
      );
    }

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

  /// 使用小米 MiMo TTS 合成
  ///
  /// API 兼容 OpenAI 格式，使用 /v1/chat/completions 端点
  /// 响应中音频数据以 Base64 编码返回在 choices[0].message.audio.data
  Future<String> _synthesizeWithMiMo(String text, {String? outputPath}) async {
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
    
    // 解析所有 TTS 控制指令
    final allSegments = TTSStyleParser.parseAll(text);
    debugPrint('[$_tag] MiMo TTS 请求: url=$url, voice=${_mimoVoice.name}, text长度=${text.length}, 段落数=${allSegments.length}');
    
    // 多标签分段合成
    if (allSegments.length > 1) {
      debugPrint('[$_tag] 检测到多个 TTS 标签，分段合成...');
      return _synthesizeMultipleSegments(allSegments, url, outputPath);
    }
    
    // 单标签合成
    final ttsData = allSegments.first;
    if (ttsData.hasControl) {
      debugPrint('[$_tag] MiMo TTS 控制指令: type=${ttsData.type}, control=${ttsData.controlContent}');
    }
    
    try {
      final dio = Dio();
      // ★ 添加连接超时和接收超时，防止网络卡死
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      
      // 构建请求数据
      final requestData = TTSStyleParser.buildMiMoRequest(
        text: text,
        voice: _mimoVoice.name,
        format: 'wav',
        model: 'mimo-v2.5-tts',
      );

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
  /// 将包含多个 TTS 标签的文本拆分为多个段落，逐段合成后拼接音频。
  Future<String> _synthesizeMultipleSegments(List<TTSControlData> segments, String url, String? outputPath) async {
    final tempDir = await getTemporaryDirectory();
    final audioFiles = <String>[];

    debugPrint('[$_tag] ========== 多标签分段合成开始 ==========');
    debugPrint('[$_tag] 总段落数: ${segments.length}');

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final previewText = segment.displayContent.length > 30
          ? segment.displayContent.substring(0, 30)
          : segment.displayContent;
      debugPrint('[$_tag] --- 段落 ${i + 1}/${segments.length} ---');
      debugPrint('[$_tag]   type=${segment.type}, hasControl=${segment.hasControl}');
      debugPrint('[$_tag]   displayContent: $previewText...');
      debugPrint('[$_tag]   originalContent长度: ${segment.originalContent.length}');

      try {
        final requestData = TTSStyleParser.buildMiMoRequest(
          text: segment.originalContent,
          voice: _mimoVoice.name,
          format: 'wav',
          model: 'mimo-v2.5-tts',
        );
        
        debugPrint('[$_tag]   请求数据: messages=${requestData['messages']}');
        
        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 15);
        dio.options.receiveTimeout = const Duration(seconds: 60);
        
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
              debugPrint('[$_tag]   ✅ 段落 ${i + 1} 合成成功: ${audioBytes.length} bytes');
            } else {
              debugPrint('[$_tag]   ❌ 段落 ${i + 1} 响应中无音频数据: data=$data');
            }
          } else {
            debugPrint('[$_tag]   ❌ 段落 ${i + 1} 响应中无 choices');
          }
        } else {
          debugPrint('[$_tag]   ❌ 段落 ${i + 1} HTTP 错误: ${response.statusCode}');
        }
      } catch (e, stack) {
        debugPrint('[$_tag]   ❌ 段落 ${i + 1} 合成异常: $e');
        debugPrint('[$_tag]   堆栈: $stack');
      }
    }
    
    debugPrint('[$_tag] ========== 分段合成结果: ${audioFiles.length}/${segments.length} 成功 ==========');
    
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

    // 读取参考音频文件
    final audioFile = File(referenceAudioPath);
    if (!await audioFile.exists()) {
      throw Exception('参考音频文件不存在: $referenceAudioPath');
    }

    final audioBytes = await audioFile.readAsBytes();
    final base64Audio = base64Encode(audioBytes);
    
    // 检查文件大小（Base64 字符串不能超过 10MB）
    if (base64Audio.length > 10 * 1024 * 1024) {
      throw Exception('参考音频文件过大（最大 10MB），当前: ${(base64Audio.length / 1024 / 1024).toStringAsFixed(2)}MB');
    }

    // voice 字段必须是 DataURL 格式: data:{MIME_TYPE};base64,$BASE64_AUDIO
    // MIME 类型必须与实际音频格式匹配：audio/wav 或 audio/mpeg
    final ext = referenceAudioPath.toLowerCase().split('.').last;
    final mimeType = (ext == 'mp3' || ext == 'mpeg') ? 'audio/mpeg' : 'audio/wav';
    final voiceData = 'data:$mimeType;base64,$base64Audio';

    // 使用 parseAll 解析所有 TTS 控制指令（支持多标签）
    final allSegments = TTSStyleParser.parseAll(text);
    debugPrint('[$_tag] MiMo VoiceClone 请求: text长度=${text.length}, audioSize=${audioBytes.length} bytes, 段落数=${allSegments.length}');

    // 优先使用构造参数，否则从 SharedPreferences 读取自定义地址
    final baseUrl = _mimoBaseUrl ?? await _getMiMoBaseUrl();
    final url = '$baseUrl/chat/completions';

    // 多标签分段合成
    if (allSegments.length > 1) {
      debugPrint('[$_tag] VoiceClone 检测到多个 TTS 标签(${allSegments.length}段)，分段合成...');
      return _synthesizeMultipleCloneSegments(allSegments, voiceData, url, outputPath);
    }

    // 单标签合成
    final ttsData = allSegments.first;
    if (ttsData.hasControl) {
      debugPrint('[$_tag] MiMo VoiceClone 控制指令: type=${ttsData.type}, control=${ttsData.controlContent}');
    }

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

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
  /// 将包含多个 TTS 标签的文本拆分为多个段落，逐段使用 VoiceClone API 合成后拼接音频。
  /// 通过全局角色锚定确保所有段落保持一致的人格语调。
  Future<String> _synthesizeMultipleCloneSegments(
    List<TTSControlData> segments,
    String voiceData,
    String url,
    String? outputPath,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final audioFiles = <String>[];

    debugPrint('[$_tag] ========== VoiceClone 多标签分段合成开始 ==========');
    debugPrint('[$_tag] 总段落数: ${segments.length}');

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final previewText = segment.displayContent.length > 30
          ? segment.displayContent.substring(0, 30)
          : segment.displayContent;
      debugPrint('[$_tag] --- VoiceClone 段落 ${i + 1}/${segments.length} ---');
      debugPrint('[$_tag]   type=${segment.type}, hasControl=${segment.hasControl}');
      debugPrint('[$_tag]   displayContent: $previewText...');
      debugPrint('[$_tag]   originalContent长度: ${segment.originalContent.length}');

      try {
        final requestData = TTSStyleParser.buildMiMoCloneRequest(
          text: segment.originalContent,
          voiceDataUrl: voiceData,
          format: 'wav',
          model: 'mimo-v2.5-tts-voiceclone',
        );

        debugPrint('[$_tag]   请求数据: messages=${requestData['messages']}');

        final dio = Dio();
        dio.options.connectTimeout = const Duration(seconds: 30);
        dio.options.receiveTimeout = const Duration(seconds: 60);

        // 429 限流重试：最多重试 2 次
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
              debugPrint('[$_tag]   ⚠️ 429 限流，${waitMs}ms 后重试 (${attempt + 1}/2)');
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            break;
          } on DioException catch (e) {
            if (e.response?.statusCode == 429 && attempt < 1) {
              final waitMs = 2000 * (1 << attempt);
              debugPrint('[$_tag]   ⚠️ 429 限流(DioException)，${waitMs}ms 后重试 (${attempt + 1}/2)');
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            rethrow;
          }
        }

        if (response == null) {
          debugPrint('[$_tag]   ❌ 段落 ${i + 1} 请求失败（重试耗尽）');
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
              debugPrint('[$_tag]   ✅ 段落 ${i + 1} 合成成功: ${audioBytes.length} bytes');
            } else {
              debugPrint('[$_tag]   ❌ 段落 ${i + 1} 响应中无音频数据');
            }
          } else {
            debugPrint('[$_tag]   ❌ 段落 ${i + 1} 响应中无 choices');
          }
        } else {
          debugPrint('[$_tag]   ❌ 段落 ${i + 1} HTTP 错误: ${response.statusCode}');
        }
      } catch (e, stack) {
        debugPrint('[$_tag]   ❌ 段落 ${i + 1} 合成异常: $e');
        debugPrint('[$_tag]   堆栈: $stack');
      }
    }

    debugPrint('[$_tag] ========== VoiceClone 分段合成结果: ${audioFiles.length}/${segments.length} 成功 ==========');

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

      } else if (PlatformUtils.isIOS) {
        try {
          await _systemTts!.setLanguage('zh-CN');
        } catch (_) {
          try {
            await _systemTts!.setLanguage('en-US');
          } catch (_) {}
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
  MiMoVoice mimoVoice = MiMoVoice.Chloe,
  String? cloneReferenceAudioPath,
}) {
  final ttsProvider = switch (provider) {
    'sherpa' => TTSProvider.sherpa,
    'system' => TTSProvider.system,
    'openai' => TTSProvider.openai,
    'mimo' => TTSProvider.mimo,
    _ => TTSProvider.sherpa, // 默认使用 Sherpa
  };
  
  return TTSService(
    provider: ttsProvider,
    apiKey: provider == 'mimo' ? mimoApiKey : openaiApiKey,
    mimoVoice: mimoVoice,
    cloneReferenceAudioPath: cloneReferenceAudioPath,
    sherpaModelId: sherpaModelId,
    speakerId: ttsVoice != null ? int.tryParse(ttsVoice) ?? 0 : 0,
    speechRate: speechRate,
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