/// ASR 语音识别服务 - LLM Studio 语音输入模块
/// 
/// 负责：
/// - 语音转文字识别
/// - 多种 ASR 后端支持（OpenAI Whisper / Sherpa-ONNX）
/// - 音频格式处理
/// 
/// 支持的 ASR 后端：
/// - OpenAI Whisper API（云端，高精度）
/// - Sherpa-ONNX（本地离线，支持中英日韩粤）
/// - 阿里云 ASR（云端）
/// - 腾讯云 ASR（云端）
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_model_service.dart';
import 'asset_model_service.dart';

/// ASR 提供商类型
enum ASRProvider {
  openai,    // OpenAI Whisper API
  aliyun,    // 阿里云 ASR
  tencent,   // 腾讯云 ASR
  sherpa,    // Sherpa-ONNX 本地离线识别
  system,    // 系统语音识别（iOS/Android/macOS/Windows 原生）
}

/// 语音识别服务 (ASR)
/// 支持多种后端：OpenAI Whisper、阿里云 ASR、腾讯云 ASR、Sherpa-ONNX、系统语音识别
class ASRService {
  // 当前使用的提供商（暴露给外部）
  final ASRProvider _provider;
  
  /// 获取当前 ASR 提供商类型
  ASRProvider get provider => _provider;
  
  final String? _apiKey;
  
  // Sherpa-ONNX 相关
  OfflineRecognizer? _recognizer;
  final String? _modelPath;
  final String? _tokensPath;
  final String? _ruleFst;
  /// Sherpa 模型 ID（对应 VoiceModelService 中的模型 id，优先于 _modelPath）
  final String? _sherpaModelId;
  bool _initialized = false;
  
  // 系统语音识别 (speech_to_text) 相关
  stt.SpeechToText? _systemSpeech;
  bool _systemSpeechInitialized = false;
  /// 系统语音识别语言（默认中文）
  final String _systemLocaleId;

  ASRService({
    ASRProvider provider = ASRProvider.system,  // 默认使用系统语音识别
    String? apiKey,
    String? modelPath,
    String? tokensPath,
    String? ruleFst,
    String? sherpaModelId,
    String systemLocaleId = 'zh_CN',
  })  : _provider = provider,
        _apiKey = apiKey,
        _modelPath = modelPath,
        _tokensPath = tokensPath,
        _ruleFst = ruleFst,
        _sherpaModelId = sherpaModelId,
        _systemLocaleId = systemLocaleId;

  /// 初始化 Sherpa-ONNX 识别器
  /// 
  /// 模型查找优先级：
  /// 1. VoiceModelService（用户在语音设置中下载的模型）
  /// 2. AssetModelService（按需下载的模型）
  Future<void> initSherpa() async {
    if (_initialized) return;

    String? resolvedModelPath = _modelPath;
    String? resolvedTokensPath = _tokensPath;
    String? resolvedRuleFst = _ruleFst;

    // 优先通过 sherpaModelId 从 VoiceModelService 定位已解压模型
    final sherpaModelId = _sherpaModelId;
    if (sherpaModelId != null) {
      final modelService = voiceModelService;
      final isReady = await modelService.isModelDownloaded(sherpaModelId);
      
      if (isReady) {
        // 用户已下载模型
        resolvedModelPath = await modelService.findOnnxModel(sherpaModelId);
        resolvedTokensPath = await modelService.findTokensFile(sherpaModelId);
        final fstFiles = await modelService.findFstFiles(sherpaModelId);
        resolvedRuleFst = fstFiles.isNotEmpty ? fstFiles.first : null;
      } else {
        // 用户未下载，尝试从预捆绑资源中查找
        debugPrint('[ASRService] 用户模型未下载，尝试从预捆绑资源中查找: $sherpaModelId');
        final assetService = AssetModelService.instance;
        final assetPath = await assetService.getResourcePath(sherpaModelId);
        
        if (assetPath != null) {
          // 预捆绑模型存在
          resolvedModelPath = assetPath;
          // 尝试查找 tokens 文件
          final dir = Directory(assetPath).parent;
          if (await dir.exists()) {
            final files = await dir.list().toList();
            for (final file in files) {
              if (file.path.endsWith('tokens.txt')) {
                resolvedTokensPath = file.path;
                break;
              }
            }
          }
          debugPrint('[ASRService] 使用预捆绑模型: $resolvedModelPath');
        } else {
          throw Exception(
            'ASR 模型未下载，请先在「语音设置」中下载模型: $_sherpaModelId\n'
            '或等待首次启动时自动解压预捆绑模型'
          );
        }
      }
    }

    if (resolvedModelPath == null || !await File(resolvedModelPath).exists()) {
      throw Exception(
        'ASR 模型文件不存在: $resolvedModelPath\n'
        '请在「语音设置 → 选择 ASR 模型」中下载对应模型',
      );
    }
    if (resolvedTokensPath == null || !await File(resolvedTokensPath).exists()) {
      throw StateError('Sherpa tokens.txt 文件不存在: $resolvedTokensPath');
    }
    
    // 根据模型类型选择配置
    final modelPathLower = resolvedModelPath.toLowerCase();
    OfflineModelConfig modelConfig;
    
    if (modelPathLower.contains('sense_voice') ||
        modelPathLower.contains('sensevoice') ||
        modelPathLower.contains('sense-voice')) {
      // SenseVoice 模型
      modelConfig = OfflineModelConfig(
        senseVoice: OfflineSenseVoiceModelConfig(model: resolvedModelPath),
        tokens: resolvedTokensPath,
        numThreads: 4,
        provider: 'cpu',
      );
    } else if (modelPathLower.contains('whisper')) {
      // Whisper 模型需要 encoder/decoder 两个文件
      // 查找 encoder 文件
      String? encoderPath;
      String? decoderPath;
      final sherpaModelId = _sherpaModelId;
      if (sherpaModelId != null) {
        final modelService = voiceModelService;
        final dir = await modelService.getModelDirectory(sherpaModelId);
        if (dir != null) {
          final d = Directory(dir);
          await for (final f in d.list(recursive: true)) {
            if (f is File) {
              final n = f.path.split(Platform.pathSeparator).last;
              if (n.contains('encoder') && n.endsWith('.onnx')) encoderPath = f.path;
              if (n.contains('decoder') && n.endsWith('.onnx')) decoderPath = f.path;
            }
          }
        }
      }
      encoderPath ??= resolvedModelPath;
      decoderPath ??= resolvedModelPath;
      modelConfig = OfflineModelConfig(
        whisper: OfflineWhisperModelConfig(
          encoder: encoderPath,
          decoder: decoderPath,
        ),
        tokens: resolvedTokensPath,
        numThreads: 4,
        provider: 'cpu',
      );
    } else if (modelPathLower.contains('paraformer')) {
      // Paraformer 模型
      modelConfig = OfflineModelConfig(
        paraformer: OfflineParaformerModelConfig(model: resolvedModelPath),
        tokens: resolvedTokensPath,
        numThreads: 4,
        provider: 'cpu',
      );
    } else {
      // 默认使用 SenseVoice
      modelConfig = OfflineModelConfig(
        senseVoice: OfflineSenseVoiceModelConfig(model: resolvedModelPath),
        tokens: resolvedTokensPath,
        numThreads: 4,
        provider: 'cpu',
      );
    }
    
    final config = OfflineRecognizerConfig(
      model: modelConfig,
      ruleFsts: resolvedRuleFst ?? '',
      ruleFars: '',
      maxActivePaths: 4,
    );
    
    // 初始化 sherpa-onnx 绑定
    initBindings();
    
    _recognizer = OfflineRecognizer(config);
    _initialized = true;
    debugPrint('[ASRService] Sherpa-ONNX 初始化成功: $resolvedModelPath');
  }

  /// 识别音频文件
  Future<String> recognizeFile(String filePath, {String? language}) async {
    switch (_provider) {
      case ASRProvider.openai:
        return await _recognizeWithWhisper(filePath, language: language);
      case ASRProvider.aliyun:
        return await _recognizeWithAliyun(filePath, language: language);
      case ASRProvider.tencent:
        return await _recognizeWithTencent(filePath, language: language);
      case ASRProvider.sherpa:
        return await _recognizeWithSherpa(filePath);
      case ASRProvider.system:
        // 系统语音识别不支持文件识别，只支持实时录音
        throw UnimplementedError('系统语音识别不支持文件识别，请使用实时语音识别');
    }
  }

  /// 使用 Sherpa-ONNX 识别音频文件
  Future<String> _recognizeWithSherpa(String filePath) async {
    if (!_initialized) {
      await initSherpa();
    }
    
    if (_recognizer == null) {
      throw StateError('Sherpa 识别器未初始化');
    }
    
    try {
      // 读取音频文件
      final waveData = await readWaveFile(filePath);
      if (waveData == null) {
        throw Exception('无法读取音频文件: $filePath');
      }
      
      // 创建识别器输入 - 使用 Float32List
      final stream = _recognizer!.createStream();
      final floatData = Float32List.fromList(waveData.map((e) => e).toList());
      stream.acceptWaveform(samples: floatData, sampleRate: 16000);
      
      // 执行识别 - 使用 decode 方法
      _recognizer!.decode(stream);
      
      // 获取识别结果
      final result = _recognizer!.getResult(stream);
      final text = result.text;
      
      // 释放资源
      stream.free();
      
      return text;
    } catch (e) {
      throw Exception('Sherpa 识别失败: $e');
    }
  }

  /// 读取 WAV 文件并返回音频数据（支持多种格式）
  @visibleForTesting
  Future<List<double>?> readWaveFile(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      // 解析 WAV 文件头
      if (bytes.length < 44) return null;
      
      // 检查 RIFF 头
      final riff = String.fromCharCodes(bytes.sublist(0, 4));
      if (riff != 'RIFF') {
        debugPrint('[ASRService] Not a valid WAV file: $riff');
        return null;
      }
      
      // 查找 fmt 和 data chunk（跳过所有非 data chunk）
      int fmtOffset = 12;
      int audioFormat = 1; // 默认 PCM
      int numChannels = 1;
      int sampleRate = 16000;
      int bitsPerSample = 16;
      int dataOffset = -1;
      int dataSize = 0;
      
      while (fmtOffset < bytes.length - 8) {
        if (fmtOffset + 8 > bytes.length) break;
        final chunkId = String.fromCharCodes(bytes.sublist(fmtOffset, fmtOffset + 4));
        if (chunkId.length != 4) break;
        final chunkSize = ByteData.sublistView(bytes, fmtOffset + 4, fmtOffset + 8).getUint32(0, Endian.little);
        
        if (chunkId == 'fmt ') {
          audioFormat = ByteData.sublistView(bytes, fmtOffset + 8, fmtOffset + 10).getUint16(0, Endian.little);
          numChannels = ByteData.sublistView(bytes, fmtOffset + 10, fmtOffset + 12).getUint16(0, Endian.little);
          sampleRate = ByteData.sublistView(bytes, fmtOffset + 12, fmtOffset + 16).getUint32(0, Endian.little);
          bitsPerSample = ByteData.sublistView(bytes, fmtOffset + 22, fmtOffset + 24).getUint16(0, Endian.little);
          
          debugPrint('[ASRService] Found fmt chunk at $fmtOffset, size=$chunkSize, format=$audioFormat, bits=$bitsPerSample');
          
          // WAVEFORMATEXTENSIBLE (65534) 头部是 40 字节
          if (audioFormat == 65534 && chunkSize >= 40) {
            // 读取实际位深
            final samples = ByteData.sublistView(bytes, fmtOffset + 22, fmtOffset + 24).getUint16(0, Endian.little);
            if (samples > 0) bitsPerSample = samples;
            debugPrint('[ASRService] WAVEFORMATEXTENSIBLE, using bitsPerSample=$bitsPerSample');
          }
        } else if (chunkId == 'data') {
          dataOffset = fmtOffset + 8;
          dataSize = chunkSize;
          debugPrint('[ASRService] Found data chunk at $fmtOffset, dataOffset=$dataOffset, size=$dataSize');
          // 继续查找，可能有多个 data chunk，取第一个有内容的
          break;
        } else {
          debugPrint('[ASRService] Skipping chunk: $chunkId at $fmtOffset, size=$chunkSize');
        }
        
        // 移动到下一个 chunk
        final nextOffset = fmtOffset + 8 + chunkSize;
        // 对齐到偶数
        fmtOffset = (nextOffset % 2 == 0) ? nextOffset : nextOffset + 1;
      }
      
      if (dataOffset < 0) {
        debugPrint('[ASRService] No data chunk found');
        return null;
      }
      
      debugPrint('[ASRService] WAV: format=$audioFormat, channels=$numChannels, rate=$sampleRate, bits=$bitsPerSample, dataOffset=$dataOffset');
      
      // 支持 PCM (1) 和 WAVEFORMATEXTENSIBLE (65534)
      if (audioFormat != 1 && audioFormat != 65534) {
        debugPrint('[ASRService] Only PCM format is supported, got format $audioFormat');
        return null;
      }
      
      // 如果是 WAVEFORMATEXTENSIBLE，尝试读取实际的编码格式
      if (audioFormat == 65534) {
        // SubFormat 位于 fmtOffset + 24，GUID 格式
        // 常见的 PCM GUID: {00000001-0000-0010-8000-00AA00389B71}
        // 前 16 字节是 GUID，后 2 字节通常是数据格式
        // 但由于字节序问题，直接检查 bitsPerSample 更可靠
        debugPrint('[ASRService] WAVEFORMATEXTENSIBLE, trusting bitsPerSample=$bitsPerSample');
        // 只要 bitsPerSample 是 16/24/32，就认为是 PCM
        if (bitsPerSample != 16 && bitsPerSample != 24 && bitsPerSample != 32) {
          debugPrint('[ASRService] Unexpected bitsPerSample for WAVEFORMATEXTENSIBLE: $bitsPerSample');
          // 尝试从文件推断
        }
      }
      
      // 计算音频样本
      final samples = <double>[];
      final bytesPerSample = bitsPerSample ~/ 8;
      final blockSize = bytesPerSample * numChannels;
      
      for (int i = dataOffset; i < dataOffset + dataSize && i + bytesPerSample <= bytes.length; i += blockSize) {
        // 只取第一个通道
        double sample;
        if (bitsPerSample == 16) {
          sample = ByteData.sublistView(bytes, i, i + 2).getInt16(0, Endian.little) / 32768.0;
        } else if (bitsPerSample == 32) {
          sample = ByteData.sublistView(bytes, i, i + 4).getInt32(0, Endian.little) / 2147483648.0;
        } else if (bitsPerSample == 8) {
          sample = (bytes[i] - 128) / 128.0;
        } else {
          debugPrint('[ASRService] Unsupported bits per sample: $bitsPerSample');
          return null;
        }
        samples.add(sample.clamp(-1.0, 1.0));
      }
      
      // 如果是立体声，已经在上面的循环中只取了第一个通道
      // 如果需要混合立体声到单声道，需要修改上面的逻辑
      
      return samples;
    } catch (e) {
      debugPrint('[ASRService] Error reading WAV file: $e');
      return null;
    }
  }

  /// 流式识别（实时）- 使用 VAD 简单实现
  Stream<String> recognizeStreamRealTime(Stream<List<int>> audioStream, {String? language}) async* {
    if (!_initialized) {
      await initSherpa();
    }
    
    final buffer = <int>[];
    bool isSpeaking = false;
    int silenceCount = 0;
    const int silenceThreshold = 30; // 约 300ms 静音认为说话结束
    
    // 能量阈值判断（简单的 VAD）
    const double energyThreshold = 0.01;
    
    await for (final chunk in audioStream) {
      buffer.addAll(chunk);
      
      // 计算音频能量
      final energy = calculateEnergy(chunk);
      
      if (energy > energyThreshold) {
        // 检测到人声
        if (!isSpeaking) {
          isSpeaking = true;
          silenceCount = 0;
        }
      } else {
        // 静音
        silenceCount++;
      }
      
      // 如果检测到说话结束，进行识别
      if (isSpeaking && silenceCount > silenceThreshold && buffer.isNotEmpty) {
        // 识别当前片段
        final result = await _recognizeAudioBuffer(buffer);
        if (result.isNotEmpty) {
          yield result;
        }
        
        // 重置
        buffer.clear();
        isSpeaking = false;
        silenceCount = 0;
      }
    }
    
    // 处理剩余音频
    if (buffer.isNotEmpty) {
      final result = await _recognizeAudioBuffer(buffer);
      if (result.isNotEmpty) {
        yield result;
      }
    }
  }
  
  /// 计算音频能量（简单 RMS）
  @visibleForTesting
  double calculateEnergy(List<int> chunk) {
    if (chunk.length < 2) return 0;
    
    double sum = 0;
    for (int i = 0; i < chunk.length - 1; i += 2) {
      // 16-bit PCM 小端序
      final sample = chunk[i] | (chunk[i + 1] << 8);
      final signedSample = sample > 32767 ? sample - 65536 : sample;
      sum += signedSample * signedSample;
    }
    
    final rms = (sum / (chunk.length / 2)).abs();
    return rms / 32768.0; // 归一化
  }
  
  /// 识别音频缓冲区
  Future<String> _recognizeAudioBuffer(List<int> audioData) async {
    if (_recognizer == null) {
      return '';
    }
    
    try {
      // 创建临时文件用于识别
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/asr_temp_${DateTime.now().millisecondsSinceEpoch}.wav');
      
      // 添加 WAV 头
      final wavData = addWavHeader(audioData);
      await tempFile.writeAsBytes(wavData);
      
      // 使用 sherpa 读取并识别
      final waveData = readWave(tempFile.path);
      // readWave 返回非空 WaveData
      
      final stream = _recognizer!.createStream();
      stream.acceptWaveform(samples: waveData.samples, sampleRate: waveData.sampleRate);
      _recognizer!.decode(stream);
      final result = _recognizer!.getResult(stream);
      final text = result.text;
      
      // 释放资源
      stream.free();
      
      // 清理临时文件
      await tempFile.delete();
      
      return text;
    } catch (e) {
      debugPrint('ASR buffer recognition error: $e');
      return '';
    }
  }
  
  /// 为 PCM 数据添加 WAV 头
  @visibleForTesting
  List<int> addWavHeader(List<int> pcmData) {
    const sampleRate = 16000;
    const numChannels = 1;
    const bitsPerSample = 16;
    
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;
    
    final header = <int>[];
    
    // RIFF header
    header.addAll('RIFF'.codeUnits);
    header.addAll(intToBytes(fileSize, 4));
    header.addAll('WAVE'.codeUnits);
    
    // fmt subchunk
    header.addAll('fmt '.codeUnits);
    header.addAll(intToBytes(16, 4)); // Subchunk1Size
    header.addAll(intToBytes(1, 2));  // AudioFormat (1 = PCM)
    header.addAll(intToBytes(numChannels, 2));
    header.addAll(intToBytes(sampleRate, 4));
    header.addAll(intToBytes(sampleRate * numChannels * bitsPerSample ~/ 8, 4)); // ByteRate
    header.addAll(intToBytes(numChannels * bitsPerSample ~/ 8, 2)); // BlockAlign
    header.addAll(intToBytes(bitsPerSample, 2));
    
    // data subchunk
    header.addAll('data'.codeUnits);
    header.addAll(intToBytes(dataSize, 4));
    
    return [...header, ...pcmData];
  }
  
  /// 整数转字节数组
  @visibleForTesting
  List<int> intToBytes(int value, int byteCount) {
    final bytes = <int>[];
    for (int i = 0; i < byteCount; i++) {
      bytes.add((value >> (8 * i)) & 0xFF);
    }
    return bytes;
  }

  /// 使用 OpenAI Whisper API 识别
  Future<String> _recognizeWithWhisper(String filePath, {String? language}) async {
    if (_apiKey == null) {
      throw StateError('API key not configured');
    }

    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;

      final dio = Dio();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
        'model': 'whisper-1',
        'language': ?language,
        'response_format': 'json',
      });

      final response = await dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['text'] as String;
      } else {
        throw Exception('Whisper API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to recognize audio: $e');
    }
  }

  /// 使用阿里云 ASR 识别
  Future<String> _recognizeWithAliyun(String filePath, {String? language}) async {
    // 阿里云 ASR 需要使用 RPC 方式调用
    throw UnimplementedError('Aliyun ASR not yet implemented');
  }

  /// 使用腾讯云 ASR 识别
  Future<String> _recognizeWithTencent(String filePath, {String? language}) async {
    // 腾讯云 ASR 需要签名验证
    throw UnimplementedError('Tencent ASR not yet implemented');
  }

  /// 音频格式转换
  Future<String> convertAudioFormat(String inputPath, String outputPath) async {
    final result = await Process.run('ffmpeg', [
      '-i', inputPath,
      '-acodec', 'pcm_s16le',
      '-ac', '1',
      '-ar', '16000',
      '-y',
      outputPath,
    ]);

    if (result.exitCode == 0) {
      return outputPath;
    } else {
      throw Exception('Audio conversion failed: ${result.stderr}');
    }
  }
  
  /// 释放资源
  void dispose() {
    _recognizer?.free();
    _recognizer = null;
    _initialized = false;
    _systemSpeech?.cancel();
    _systemSpeech = null;
    _systemSpeechInitialized = false;
  }

  // ========== 系统语音识别 (speech_to_text) ==========

  /// 初始化系统语音识别
  Future<void> _initSystemSpeech() async {
    if (_systemSpeechInitialized) return;

    try {
      _systemSpeech = stt.SpeechToText();
      final available = await _systemSpeech!.initialize(
        onError: (error) {
          debugPrint('[ASRService] 系统语音识别错误: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('[ASRService] 系统语音识别状态: $status');
        },
      );

      if (!available) {
        throw Exception('系统语音识别不可用');
      }

      _systemSpeechInitialized = true;
      debugPrint('[ASRService] 系统语音识别初始化成功');
    } catch (e) {
      debugPrint('[ASRService] 系统语音识别初始化失败: $e');
      rethrow;
    }
  }

  /// 使用系统语音识别进行实时识别
  /// 返回识别结果的 Stream
  Stream<String> recognizeWithSystem({
    Function(String)? onResult,
    Function()? onDone,
    Function(String)? onError,
  }) async* {
    await _initSystemSpeech();

    if (_systemSpeech == null) {
      throw Exception('系统语音识别未初始化');
    }

    final controller = StreamController<String>();

    // 开始监听
    await _systemSpeech!.listen(
      onResult: (result) {
        final text = result.recognizedWords;
        if (text.isNotEmpty) {
          controller.add(text);
          onResult?.call(text);
        }
        if (result.finalResult) {
          controller.close();
          onDone?.call();
        }
      },
      listenFor: const Duration(seconds: 30), // 最长识别时间
      pauseFor: const Duration(seconds: 3), // 静音多久后认为结束
      localeId: _systemLocaleId,
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );

    yield* controller.stream;
  }

  /// 检查系统语音识别是否可用
  Future<bool> isSystemSpeechAvailable() async {
    try {
      final speech = stt.SpeechToText();
      return await speech.initialize();
    } catch (e) {
      return false;
    }
  }

  /// 获取系统支持的语音识别语言
  Future<List<stt.LocaleName>> getSystemLocales() async {
    await _initSystemSpeech();
    if (_systemSpeech == null) return [];
    return await _systemSpeech!.locales();
  }

  /// 停止系统语音识别
  void stopSystemSpeech() {
    _systemSpeech?.stop();
  }

  /// 取消系统语音识别
  void cancelSystemSpeech() {
    _systemSpeech?.cancel();
  }
}

/// 语音活动检测 (VAD)
class VADService {
  final int silenceThresholdMs;
  final int minSpeechDurationMs;
  final int sampleRate;

  VADService({
    this.silenceThresholdMs = 700,
    this.minSpeechDurationMs = 250,
    this.sampleRate = 16000,
  });

  bool detectSpeechEnd(List<double> audioSamples) {
    double sum = 0;
    for (final sample in audioSamples) {
      sum += sample * sample;
    }
    final rms = sum / audioSamples.length;
    return rms < 0.01;
  }

  double calculateEnergy(List<double> audioSamples) {
    double sum = 0;
    for (final sample in audioSamples) {
      sum += sample * sample;
    }
    return sum / audioSamples.length;
  }
}

// Riverpod Providers

final asrServiceProvider = Provider<ASRService>((ref) {
  return ASRService(
    provider: ASRProvider.openai,
    apiKey: null,
  );
});

final vadServiceProvider = Provider<VADService>((ref) {
  return VADService();
});

enum ASRState {
  idle,
  recording,
  recognizing,
  completed,
  error,
}

final asrStateProvider = StateProvider<ASRState>((ref) => ASRState.idle);
final asrResultProvider = StateProvider<String?>((ref) => null);