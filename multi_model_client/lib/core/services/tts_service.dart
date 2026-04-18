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
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'voice_model_service.dart';

/// TTS 提供商类型
enum TTSProvider {
  openai,    // OpenAI TTS API (云端)
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

/// 语音合成服务 (TTS)
class TTSService {
  // 当前使用的提供商
  final TTSProvider _provider;
  final String? _apiKey;
  final VoiceModel _voice;
  final SherpaVoice _sherpaVoice;
  final double _speechRate;
  /// Sherpa 模型 ID（对应 VoiceModelService 中的模型 id，用于定位解压后目录）
  final String? _sherpaModelId;
  /// 说话人 ID（当模型支持多说话人时使用）
  final int _speakerId;
  
  /// 系统 TTS 音色（语言代码，如 zh-CN, en-US）
  final String? _systemVoice;

  // Sherpa-ONNX 实例
  OfflineTts? _sherpaTts;
  bool _sherpaInitialized = false;
  
  // 系统 TTS 实例
  FlutterTts? _systemTts;
  bool _systemTtsInitialized = false;
  
  // just_audio 播放器实例（用于 stop/pause/resume 控制）
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  TTSService({
    TTSProvider provider = TTSProvider.openai,
    String? apiKey,
    VoiceModel voice = VoiceModel.alloy,
    SherpaVoice sherpaVoice = SherpaVoice.zephyr,
    double speechRate = 1.0,  // 默认语速 1x
    String? sherpaModelId,
    int speakerId = 0,
    String? systemVoice,
  })  : _provider = provider,
        _apiKey = apiKey,
        _voice = voice,
        _sherpaVoice = sherpaVoice,
        _speechRate = speechRate,
        _sherpaModelId = sherpaModelId,
        _speakerId = speakerId,
        _systemVoice = systemVoice;

  /// 合成语音（返回音频文件路径）
  Future<String> synthesize(String text, {String? outputPath}) async {
    switch (_provider) {
      case TTSProvider.openai:
        return await _synthesizeWithOpenAI(text, outputPath: outputPath);
      case TTSProvider.sherpa:
        return await _synthesizeWithSherpa(text, outputPath: outputPath);
      case TTSProvider.system:
        return await _synthesizeWithSystem(text, outputPath: outputPath);
    }
  }

  /// 直接播放语音
  Future<void> speak(String text) async {
    switch (_provider) {
      case TTSProvider.openai:
        final path = await synthesize(text);
        await _playAudio(path);
        break;
      case TTSProvider.sherpa:
        final path = await synthesize(text);
        await _playAudio(path);
        break;
      case TTSProvider.system:
        // 系统 TTS 直接播放，不需要生成文件
        await _speakWithSystem(text);
        break;
    }
  }

  /// 播放长文本（自动分句分段合成，避免卡死）
  ///
  /// [onProgress] 可选回调：(当前句子数, 总句子数) → 可用于 UI 进度展示
  /// 返回是否正常播完（被打断返回 false）
  Future<bool> speakLongText(
    String text, {
    void Function(int current, int total)? onProgress,
  }) async {
    // 1. 分句：按常见标点切分
    final sentences = _splitIntoSentences(text);
    if (sentences.isEmpty) return true;

    // 2. 将短句合并成块（每块最多 5 句或 200 字，避免 sherpa-onnx 分太多批次）
    final chunks = <String>[];
    for (var i = 0; i < sentences.length; i += 5) {
      final chunk = sentences.skip(i).take(5).join('');
      if (chunk.length > 250) {
        // 如果单句超长，进一步截断到 200 字
        final trimmed = chunk.substring(0, 200);
        final lastPunct = trimmed.lastIndexOf(RegExp(r'[，。、；：！……？]'));
        final cutoff = lastPunct > 100 ? lastPunct + 1 : 200;
        chunks.add(trimmed.substring(0, cutoff));
      } else {
        chunks.add(chunk);
      }
    }

    // 3. 逐块合成 + 播放（每块最多 15 秒超时）
    const chunkTimeout = Duration(seconds: 15);
    for (var i = 0; i < chunks.length; i++) {
      // 被打断检测：检查 _isPlaying 状态（由外部 stop() 控制）
      if (!_isPlaying && i > 0) {
        return false;
      }
      onProgress?.call(i + 1, chunks.length);
      try {
        // 单块加超时，防止 sherpa-onnx 卡死
        await speak(chunks[i]).timeout(
          chunkTimeout,
          onTimeout: () {
            debugPrint('[TTS] chunk $i timeout after ${chunkTimeout.inSeconds}s, skipping');
          },
        );
      } catch (e) {
        debugPrint('[TTS] speakLongText chunk $i failed: $e, skipping');
        // 单块失败跳过，继续下一块
      }
    }
    return true;
  }

  /// 按标点分句
  List<String> _splitIntoSentences(String text) {
    // 清理空白
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];

    // 按句子结束标点分割（保留标点）
    final parts = cleaned.split(RegExp(r'[。！？；\n]'));
    return parts
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 1)
        .toList();
  }

  /// 停止播放
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('TTS stop error: $e');
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

  /// 初始化 Sherpa-ONNX
  Future<void> _initSherpa() async {
    if (_sherpaInitialized) return;

    try {
      final modelService = voiceModelService;
      String? modelDir;
      String? modelFile;
      String? tokensFile;
      List<String> fstFiles = [];

      if (_sherpaModelId != null) {
        // 通过 VoiceModelService 动态定位已下载模型
        final isReady = await modelService.isModelDownloaded(_sherpaModelId!);
        if (!isReady) {
          throw Exception('TTS 模型未下载，请先在「语音设置」中下载模型: $_sherpaModelId');
        }
        modelFile = await modelService.findOnnxModel(_sherpaModelId!);
        tokensFile = await modelService.findTokensFile(_sherpaModelId!);
        fstFiles = await modelService.findFstFiles(_sherpaModelId!);
        modelDir = await modelService.getModelDirectory(_sherpaModelId!);
      } else {
        // 兼容旧逻辑：固定 sherpa_models 目录（已废弃，仅保留向后兼容）
        final appDir = await getApplicationDocumentsDirectory();
        modelDir = '${appDir.path}/sherpa_models';
        modelFile = '$modelDir/model.onnx';
        tokensFile = '$modelDir/tokens.txt';
      }

      if (modelFile == null || !await File(modelFile).exists()) {
        throw Exception(
          'TTS 模型文件不存在: $modelFile\n'
          '请在「语音设置 → 选择 TTS 模型」中下载对应模型',
        );
      }

      final tokensExists = tokensFile != null && await File(tokensFile).exists();
      final lexiconFile = _sherpaModelId != null
          ? await modelService.findLexiconFile(_sherpaModelId!)
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
        tokens: tokensExists ? tokensFile! : '',
        lexicon: lexiconExists ? lexiconFile! : '',
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
      print('[TTSService] Sherpa-ONNX 初始化成功: $modelFile');
    } catch (e) {
      print('[TTSService] Sherpa-ONNX 初始化失败: $e');
      _sherpaInitialized = false;
      rethrow;
    }
  }

  /// 获取 Sherpa 模型目录（兼容旧逻辑，已废弃）
  @Deprecated('Use VoiceModelService.getModelDirectory instead')
  Future<String> _getSherpaModelDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = '${appDir.path}/sherpa_models';
    final dir = Directory(modelDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return modelDir;
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
      
      if (audio == null || audio.samples.isEmpty) {
        throw Exception('Sherpa 生成音频为空');
      }
      
      // 转换为 WAV 格式并保存
      final wavData = _createWavFromSamples(
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

  /// 从 Float32List 创建 WAV 数据
  Uint8List _createWavFromSamples(
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
    header.addAll(_int32ToBytes(fileSize));
    header.addAll('WAVE'.codeUnits);
    
    // fmt sub-chunk
    header.addAll('fmt '.codeUnits);
    header.addAll(_int32ToBytes(16));
    header.addAll(_int16ToBytes(1));
    header.addAll(_int16ToBytes(channels));
    header.addAll(_int32ToBytes(sampleRate));
    header.addAll(_int32ToBytes(byteRate));
    header.addAll(_int16ToBytes(blockAlign));
    header.addAll(_int16ToBytes(bitsPerSample));
    
    // data sub-chunk
    header.addAll('data'.codeUnits);
    header.addAll(_int32ToBytes(dataSize));
    
    return header;
  }

  List<int> _int32ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  List<int> _int16ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
    ];
  }

  /// 播放音频文件（使用 just_audio 支持 stop/pause/resume）
  Future<void> _playAudio(String path) async {
    try {
      // 使用 just_audio 播放，支持暂停/恢复/停止
      await _audioPlayer.setFilePath(path);
      _audioPlayer.playerStateStream.listen((state) {
        _isPlaying = state.playing;
      });
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e) {
      // 回退到系统命令播放
      debugPrint('just_audio failed, falling back to system player: $e');
      if (Platform.isMacOS) {
        await Process.run('afplay', [path]);
      } else if (Platform.isWindows) {
        await Process.run('start', ['', path], runInShell: true);
      } else if (Platform.isLinux) {
        await Process.run('aplay', [path]);
      }
    }
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
        final path = outputPath ?? '/tmp/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
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

  /// 初始化系统 TTS
  Future<void> _initSystemTts() async {
    if (_systemTtsInitialized) return;

    try {
      _systemTts = FlutterTts();
      
      // 设置语速和音调
      await _systemTts!.setSpeechRate(_speechRate);
      
      // 设置语言（如果指定）
      if (_systemVoice != null) {
        await _systemTts!.setLanguage(_systemVoice);
      }
      
      // macOS 特定设置
      if (Platform.isMacOS) {
        // 获取可用声音列表
        final voices = await _systemTts!.getVoices;
        debugPrint('[TTS] Available system voices: $voices');
      }
      
      _systemTtsInitialized = true;
      debugPrint('[TTSService] 系统 TTS 初始化成功');
    } catch (e) {
      debugPrint('[TTSService] 系统 TTS 初始化失败: $e');
      _systemTtsInitialized = false;
      rethrow;
    }
  }

  /// 使用系统 TTS 直接播放
  Future<void> _speakWithSystem(String text) async {
    await _initSystemTts();
    
    if (_systemTts == null) {
      throw Exception('系统 TTS 未初始化');
    }

    try {
      _isPlaying = true;
      await _systemTts!.speak(text);
      
      // 等待播放完成
      _systemTts!.setCompletionHandler(() {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      throw Exception('系统语音合成失败: $e');
    }
  }

  /// 使用系统 TTS 合成（保存到文件）
  Future<String> _synthesizeWithSystem(String text, {String? outputPath}) async {
    await _initSystemTts();
    
    if (_systemTts == null) {
      throw Exception('系统 TTS 未初始化');
    }

    try {
      // 确定输出路径
      final String path = outputPath ?? 
          '${(await getTemporaryDirectory()).path}/tts_system_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // 合成到文件（部分平台支持）
      await _systemTts!.synthesizeToFile(text, path);
      
      return path;
    } catch (e) {
      // 如果合成到文件失败，直接播放
      debugPrint('[TTS] synthesizeToFile not supported, falling back to direct speak: $e');
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
/// - systemVoice: 系统 TTS 语言代码
TTSService createTTSService({
  required String provider,
  String? sherpaModelId,
  String? ttsVoice,
  double speechRate = 1.0,
  String? systemVoice,
  String? openaiApiKey,
}) {
  final ttsProvider = switch (provider) {
    'sherpa' => TTSProvider.sherpa,
    'system' => TTSProvider.system,
    'openai' => TTSProvider.openai,
    _ => TTSProvider.sherpa, // 默认使用 Sherpa
  };
  
  return TTSService(
    provider: ttsProvider,
    apiKey: openaiApiKey,
    sherpaModelId: sherpaModelId,
    speakerId: ttsVoice != null ? int.tryParse(ttsVoice) ?? 0 : 0,
    speechRate: speechRate,
    systemVoice: systemVoice,
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