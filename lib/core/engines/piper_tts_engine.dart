// ignore_for_file: non_constant_identifier_names
/// Piper TTS 引擎 - LLM Studio 本地语音合成模块
/// 
/// 功能：
/// - Piper 本地 TTS 引擎
/// - FFI 绑定实现
/// - 多音色支持
/// - 高质量语音合成
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

// Piper FFI bindings
class PiperBindings {
  final DynamicLibrary _lib;

  PiperBindings(this._lib);

  /// 加载Piper模型
  Pointer<Void> piper_load_model(
    Pointer<Utf8> modelPath,
  ) {
    return _lib.lookupFunction<
        Pointer<Void> Function(Pointer<Utf8>),
        Pointer<Void> Function(Pointer<Utf8>)>(
      'piper_load_model',
    )(modelPath);
  }

  /// 释放Piper模型
  void piper_free_model(Pointer<Void> model) {
    _lib.lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)>(
      'piper_free_model',
    )(model);
  }

  /// 文本转语音
  int piper_text_to_speech(
    Pointer<Void> model,
    Pointer<Utf8> text,
    Pointer<Float> audioBuffer,
    int bufferSize,
  ) {
    return _lib.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Utf8>, Pointer<Float>, Int32),
        int Function(Pointer<Void>, Pointer<Utf8>, Pointer<Float>, int)>(
      'piper_text_to_speech',
    )(model, text, audioBuffer, bufferSize);
  }

  /// 获取音频长度
  int piper_get_audio_length(
    Pointer<Void> model,
    Pointer<Utf8> text,
  ) {
    return _lib.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Utf8>),
        int Function(Pointer<Void>, Pointer<Utf8>)>(
      'piper_get_audio_length',
    )(model, text);
  }

  /// 获取采样率
  int piper_get_sample_rate(Pointer<Void> model) {
    return _lib.lookupFunction<
        Int32 Function(Pointer<Void>),
        int Function(Pointer<Void>)>(
      'piper_get_sample_rate',
    )(model);
  }
}

/// Piper TTS配置
class PiperConfig {
  final String modelPath;
  final String? speakerId;
  final double noiseScale;
  final double lengthScale;
  final double noiseW;

  PiperConfig({
    required this.modelPath,
    this.speakerId,
    this.noiseScale = 0.667,
    this.lengthScale = 1.0,
    this.noiseW = 0.8,
  });

  Map<String, dynamic> toJson() {
    return {
      'modelPath': modelPath,
      if (speakerId != null) 'speakerId': speakerId,
      'noiseScale': noiseScale,
      'lengthScale': lengthScale,
      'noiseW': noiseW,
    };
  }
}

/// 语音合成结果
class SynthesisResult {
  final Float32List audioData;
  final int sampleRate;
  final double durationSeconds;
  final String text;

  SynthesisResult({
    required this.audioData,
    required this.sampleRate,
    required this.durationSeconds,
    required this.text,
  });

  int get totalSamples => audioData.length;

  double get durationMinutes => durationSeconds / 60;
}

/// Piper TTS引擎
class PiperTTSEngine {
  PiperBindings? _bindings;
  Pointer<Void>? _model;
  PiperConfig? _config;

  /// 初始化引擎
  Future<void> initialize() async {
    final libPath = Platform.isIOS
        ? '@executable_path/Frameworks/libpiper.dylib'
        : Platform.isAndroid
            ? 'libpiper.so'
            : throw UnsupportedError('Unsupported platform');

    _bindings = PiperBindings(DynamicLibrary.open(libPath));
  }

  /// 加载模型
  Future<bool> loadModel(PiperConfig config) async {
    if (_bindings == null) await initialize();

    try {
      final modelPathPtr = config.modelPath.toNativeUtf8();

      _model = _bindings!.piper_load_model(modelPathPtr);

      calloc.free(modelPathPtr);

      if (_model == nullptr) {
        return false;
      }

      _config = config;
      return true;
    } catch (e) {
      debugPrint('Error loading Piper model: $e');
      return false;
    }
  }

  /// 检查模型是否已加载
  bool get isModelLoaded => _model != null && _model != nullptr;

  /// 获取当前配置
  PiperConfig? get config => _config;

  /// 合成语音
  Future<SynthesisResult?> synthesize(String text) async {
    if (_model == null || _model == nullptr) {
      throw StateError('Model not loaded');
    }

    try {
      final textPtr = text.toNativeUtf8();

      // 获取音频长度
      final audioLength = _bindings!.piper_get_audio_length(_model!, textPtr);

      if (audioLength <= 0) {
        calloc.free(textPtr);
        return null;
      }

      // 分配音频缓冲区
      final audioBuffer = calloc<Float>(audioLength);

      // 执行合成
      final result = _bindings!.piper_text_to_speech(
        _model!,
        textPtr,
        audioBuffer,
        audioLength,
      );

      calloc.free(textPtr);

      if (result <= 0) {
        calloc.free(audioBuffer);
        return null;
      }

      // 获取采样率
      final sampleRate = _bindings!.piper_get_sample_rate(_model!);

      // 复制音频数据
      final audioData = Float32List.fromList(
        audioBuffer.asTypedList(result),
      );

      calloc.free(audioBuffer);

      // 计算时长
      final durationSeconds = audioData.length / sampleRate;

      return SynthesisResult(
        audioData: audioData,
        sampleRate: sampleRate,
        durationSeconds: durationSeconds,
        text: text,
      );
    } catch (e) {
      debugPrint('Error synthesizing speech: $e');
      return null;
    }
  }

  /// 流式合成语音
  Stream<Float32List> synthesizeStream(String text, {int chunkSize = 4096}) async* {
    if (_model == null || _model == nullptr) {
      throw StateError('Model not loaded');
    }

    try {
      final textPtr = text.toNativeUtf8();

      // 获取音频长度
      final audioLength = _bindings!.piper_get_audio_length(_model!, textPtr);

      if (audioLength <= 0) {
        calloc.free(textPtr);
        return;
      }

      // 分配音频缓冲区
      final audioBuffer = calloc<Float>(audioLength);

      // 执行合成
      final result = _bindings!.piper_text_to_speech(
        _model!,
        textPtr,
        audioBuffer,
        audioLength,
      );

      calloc.free(textPtr);

      if (result <= 0) {
        calloc.free(audioBuffer);
        return;
      }

      // 分块返回音频数据
      for (var i = 0; i < result; i += chunkSize) {
        final end = (i + chunkSize < result) ? i + chunkSize : result;
        final chunk = Float32List.fromList(
          audioBuffer.asTypedList(result).sublist(i, end),
        );
        yield chunk;

        // 添加小延迟以模拟流式效果
        await Future.delayed(const Duration(milliseconds: 10));
      }

      calloc.free(audioBuffer);
    } catch (e) {
      debugPrint('Error streaming speech: $e');
    }
  }

  /// 将Float32音频转换为PCM16
  Int16List convertToPCM16(Float32List audioData) {
    final pcmData = Int16List(audioData.length);

    for (var i = 0; i < audioData.length; i++) {
      // 将-1.0到1.0的浮点值转换为-32768到32767的整数值
      final sample = (audioData[i] * 32767).clamp(-32768.0, 32767.0);
      pcmData[i] = sample.toInt();
    }

    return pcmData;
  }

  /// 将音频数据转换为WAV格式
  Uint8List convertToWAV(
    Float32List audioData, {
    int sampleRate = 22050,
    int numChannels = 1,
    int bitsPerSample = 16,
  }) {
    final pcmData = convertToPCM16(audioData);
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = pcmData.length * 2;

    final wavData = Uint8List(44 + dataSize);
    final byteData = ByteData.view(wavData.buffer);

    // RIFF header
    wavData.setAll(0, [0x52, 0x49, 0x46, 0x46]); // "RIFF"
    byteData.setUint32(4, 36 + dataSize, Endian.little);
    wavData.setAll(8, [0x57, 0x41, 0x56, 0x45]); // "WAVE"

    // fmt chunk
    wavData.setAll(12, [0x66, 0x6D, 0x74, 0x20]); // "fmt "
    byteData.setUint32(16, 16, Endian.little); // Chunk size
    byteData.setUint16(20, 1, Endian.little); // Audio format (PCM)
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    wavData.setAll(36, [0x64, 0x61, 0x74, 0x61]); // "data"
    byteData.setUint32(40, dataSize, Endian.little);

    // PCM data
    for (var i = 0; i < pcmData.length; i++) {
      byteData.setInt16(44 + i * 2, pcmData[i], Endian.little);
    }

    return wavData;
  }

  /// 保存音频到文件
  Future<bool> saveToWAV(
    String filePath,
    Float32List audioData, {
    int sampleRate = 22050,
  }) async {
    try {
      final wavData = convertToWAV(audioData, sampleRate: sampleRate);
      final file = File(filePath);
      await file.writeAsBytes(wavData);
      return true;
    } catch (e) {
      debugPrint('Error saving WAV file: $e');
      return false;
    }
  }

  /// 释放资源
  void dispose() {
    if (_model != null && _model != nullptr) {
      _bindings!.piper_free_model(_model!);
      _model = null;
    }
  }

  /// 获取可用的模型列表
  static List<Map<String, String>> getAvailableModels() {
    return [
      {
        'name': 'English (US)',
        'id': 'en_US-lessac-medium',
        'language': 'en-US',
        'quality': 'medium',
      },
      {
        'name': 'English (UK)',
        'id': 'en_GB-alba-medium',
        'language': 'en-GB',
        'quality': 'medium',
      },
      {
        'name': '中文',
        'id': 'zh_CN-huayan-medium',
        'language': 'zh-CN',
        'quality': 'medium',
      },
      {
        'name': '日本語',
        'id': 'ja_JP-medium',
        'language': 'ja-JP',
        'quality': 'medium',
      },
    ];
  }

  /// 下载模型
  static Future<bool> downloadModel(
    String modelId,
    String savePath, {
    Function(double progress)? onProgress,
  }) async {
    try {
      // 构建下载URL
      final url = 'https://huggingface.co/rhasspy/piper-voices/resolve/main/$modelId.onnx';

      // 使用Dio下载
      final dio = Dio();
      await dio.download(
        url,
        path.join(savePath, '$modelId.onnx'),
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error downloading model: $e');
      return false;
    }
  }
}
