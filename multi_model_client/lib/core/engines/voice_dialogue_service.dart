/// 语音对话服务 - LLM Studio 实时语音交互模块
/// 
/// 功能：
/// - 实时语音对话（ASR → LLM → TTS）
/// - 状态机管理（聆听/处理/说话）
/// - 打断机制
/// - VAD 语音活动检测
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:math' show sqrt;
import 'dart:typed_data';

/// 语音对话状态
enum VoiceDialogueState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

/// 语音对话事件
class VoiceDialogueEvent {
  final VoiceDialogueState state;
  final String? transcript;
  final String? responseText;
  final Uint8List? audioData;
  final String? errorMessage;

  VoiceDialogueEvent({
    required this.state,
    this.transcript,
    this.responseText,
    this.audioData,
    this.errorMessage,
  });
}

/// 语音对话配置
class VoiceDialogueConfig {
  final String asrModelPath;    // Whisper模型路径
  final String ttsModelPath;    // TTS模型路径
  final String language;       // 语言设置
  final double vadThreshold;   // VAD阈值
  final int silenceTimeoutMs;  // 静音超时时间
  final bool autoPlay;         // 自动播放响应
  final double ttsSpeed;       // TTS语速

  const VoiceDialogueConfig({
    this.asrModelPath = '',
    this.ttsModelPath = '',
    this.language = 'zh',
    this.vadThreshold = 0.5,
    this.silenceTimeoutMs = 2000,
    this.autoPlay = true,
    this.ttsSpeed = 1.0,
  });
}

/// 实时语音对话服务
///
/// 整合ASR(Whisper)和TTS(Piper)，实现语音对话功能
class VoiceDialogueService {
  VoiceDialogueConfig _config;
  VoiceDialogueState _state = VoiceDialogueState.idle;

  // Stream controllers
  final _eventController = StreamController<VoiceDialogueEvent>.broadcast();
  final _audioInputController = StreamController<double>.broadcast();

  // Audio buffers
  final List<double> _audioBuffer = [];
  static const int _bufferSize = 4096;

  // VAD (Voice Activity Detection) state
  bool _isSpeechActive = false;
  DateTime? _speechStartTime;

  // Callbacks
  Function(String)? onTranscript;
  Function(String)? onLLMResponse;

  VoiceDialogueService({VoiceDialogueConfig? config})
      : _config = config ?? const VoiceDialogueConfig();

  /// 事件流
  Stream<VoiceDialogueEvent> get eventStream => _eventController.stream;

  /// 当前状态
  VoiceDialogueState get state => _state;

  /// 配置服务
  void configure(VoiceDialogueConfig config) {
    _config = config;
  }

  /// 开始语音对话
  Future<void> start() async {
    _updateState(VoiceDialogueState.listening);
    _audioBuffer.clear();
    _isSpeechActive = false;
  }

  /// 停止语音对话
  Future<void> stop() async {
    _updateState(VoiceDialogueState.idle);
    _audioBuffer.clear();
  }

  /// 暂停语音输入
  void pauseListening() {
    if (_state == VoiceDialogueState.listening) {
      _updateState(VoiceDialogueState.idle);
    }
  }

  /// 恢复语音输入
  void resumeListening() {
    if (_state == VoiceDialogueState.idle) {
      _updateState(VoiceDialogueState.listening);
    }
  }

  /// 处理音频输入（由麦克风调用）
  void processAudioInput(List<double> samples) {
    if (_state != VoiceDialogueState.listening) return;

    // Add to buffer
    _audioBuffer.addAll(samples);

    // Buffer overflow protection
    while (_audioBuffer.length > _bufferSize * 10) {
      _audioBuffer.removeRange(0, _bufferSize);
    }

    // Simple VAD: detect speech
    final amplitude = _calculateRMS(samples);
    if (amplitude > _config.vadThreshold) {
      if (!_isSpeechActive) {
        _isSpeechActive = true;
        _speechStartTime = DateTime.now();
      }
    } else {
      // Check for silence timeout
      if (_isSpeechActive && _speechStartTime != null) {
        final silenceDuration = DateTime.now().difference(_speechStartTime!);
        if (silenceDuration.inMilliseconds > _config.silenceTimeoutMs) {
          _processAudioBuffer();
        }
      }
    }
  }

  /// 处理音频缓冲区中的数据
  Future<void> _processAudioBuffer() async {
    if (_audioBuffer.isEmpty) return;

    _updateState(VoiceDialogueState.processing);

    try {
      // TODO: Integrate with WhisperASREngine for actual transcription
      // For now, this is a placeholder that would call the ASR engine
      final transcript = await _transcribeAudio(_audioBuffer);

      if (transcript.isNotEmpty) {
        _eventController.add(VoiceDialogueEvent(
          state: _state,
          transcript: transcript,
        ));

        onTranscript?.call(transcript);

        // Send to LLM if callback is set
        if (onLLMResponse != null) {
          final response = await onLLMResponse!(transcript);
          await _speakResponse(response);
        }
      }

      // Clear buffer and resume listening
      _audioBuffer.clear();
      _isSpeechActive = false;
      _speechStartTime = null;

      if (_config.autoPlay) {
        _updateState(VoiceDialogueState.listening);
      } else {
        _updateState(VoiceDialogueState.idle);
      }
    } catch (e) {
      _updateState(VoiceDialogueState.error);
      _eventController.add(VoiceDialogueEvent(
        state: VoiceDialogueState.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// 音频转文字（ASR）
  Future<String> _transcribeAudio(List<double> audioSamples) async {
    // Placeholder: In production, this would call WhisperASREngine
    // For now, return empty string - actual implementation would be:
    // final asr = WhisperASREngine();
    // await asr.loadModel(WhisperModel(modelPath: _config.asrModelPath));
    // final result = await asr.transcribe(audioSamples);
    // return result.text;
    return '';
  }

  /// 文字转语音（TTS）
  Future<void> _speakResponse(String text) async {
    if (text.isEmpty) return;

    _updateState(VoiceDialogueState.speaking);

    try {
      // Placeholder: In production, this would call PiperTTSEngine
      // final tts = PiperTTSEngine();
      // await tts.loadModel(PiperConfig(modelPath: _config.ttsModelPath));
      // final audioData = await tts.synthesize(text);

      // Notify about audio data
      _eventController.add(VoiceDialogueEvent(
        state: VoiceDialogueState.speaking,
        responseText: text,
      ));

      // Wait for speech to complete
      await Future.delayed(Duration(milliseconds: text.length * 50));

      // Return to listening state
      _updateState(VoiceDialogueState.listening);
    } catch (e) {
      _updateState(VoiceDialogueState.error);
      _eventController.add(VoiceDialogueEvent(
        state: VoiceDialogueState.error,
        errorMessage: 'TTS error: $e',
      ));
    }
  }

  /// 直接输入文本进行语音合成
  Future<Uint8List?> synthesize(String text) async {
    _updateState(VoiceDialogueState.speaking);

    try {
      // Placeholder for TTS synthesis
      // In production, would use PiperTTSEngine
      await Future.delayed(const Duration(milliseconds: 100));

      _updateState(VoiceDialogueState.idle);
      return null;
    } catch (e) {
      _updateState(VoiceDialogueState.error);
      return null;
    }
  }

  /// 直接输入音频进行识别
  Future<String> recognize(Uint8List audioData) async {
    _updateState(VoiceDialogueState.processing);

    try {
      // Placeholder for ASR
      // In production, would use WhisperASREngine
      await Future.delayed(const Duration(milliseconds: 100));

      _updateState(VoiceDialogueState.idle);
      return '';
    } catch (e) {
      _updateState(VoiceDialogueState.error);
      return '';
    }
  }

  /// 计算RMS（均方根）用于VAD
  double _calculateRMS(List<double> samples) {
    if (samples.isEmpty) return 0.0;

    double sum = 0.0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    return sqrt(sum / samples.length);
  }

  /// 更新状态并发送事件
  void _updateState(VoiceDialogueState newState) {
    _state = newState;
    _eventController.add(VoiceDialogueEvent(state: newState));
  }

  /// 释放资源
  void dispose() {
    _audioBuffer.clear();
    _eventController.close();
    _audioInputController.close();
  }
}