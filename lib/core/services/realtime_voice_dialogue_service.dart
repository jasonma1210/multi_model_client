/// 实时语音对话服务 - 全链路流式语音交互
/// 
/// 实现类似电话通话的实时语音对话：
/// - VAD 语音活动检测
/// - 实时 ASR 语音识别
/// - 流式 LLM 推理
/// - 流式 TTS 语音合成
/// - 语音打断（实验性）
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 语音对话状态
enum VoiceDialogueState {
  idle,       // 空闲
  listening,  // 监听中
  thinking,   // 思考中（LLM 推理）
  speaking,   // 说话中（TTS 播放）
  error,      // 错误
}

/// VAD 事件
enum VADEvent {
  speechStart,  // 语音开始
  speechEnd,    // 语音结束
}

/// 音频配置
class AudioConfig {
  final int sampleRate;
  final int channels;
  final double vadThreshold;
  final Duration silenceTimeout;

  const AudioConfig({
    this.sampleRate = 16000,
    this.channels = 1,
    this.vadThreshold = 0.5,
    this.silenceTimeout = const Duration(milliseconds: 2000),
  });
}

/// 实时语音对话服务
class RealtimeVoiceDialogueService {
  static final RealtimeVoiceDialogueService _instance = RealtimeVoiceDialogueService._();
  static RealtimeVoiceDialogueService get instance => _instance;

  RealtimeVoiceDialogueService._();

  /// 当前状态
  VoiceDialogueState _state = VoiceDialogueState.idle;
  VoiceDialogueState get state => _state;

  /// 音频配置
  final AudioConfig _config = const AudioConfig();

  /// 状态变更控制器
  final _stateController = StreamController<VoiceDialogueState>.broadcast();
  Stream<VoiceDialogueState> get stateStream => _stateController.stream;

  /// VAD 事件控制器
  final _vadController = StreamController<VADEvent>.broadcast();
  Stream<VADEvent> get vadStream => _vadController.stream;

  /// 打断事件控制器
  final _interruptController = StreamController<void>.broadcast();
  Stream<void> get interruptStream => _interruptController.stream;

  /// 是否正在说话
  bool _isSpeaking = false;

  /// 最后检测到语音的时间
  DateTime? _lastSpeechTime;

  /// 打断功能是否启用（实验性）
  bool _interruptionEnabled = false;

  /// 是否已停止
  bool _stopped = false;

  /// 开始语音对话
  Future<void> startDialogue() async {
    _stopped = false;
    _state = VoiceDialogueState.listening;
    _notifyState();
    
    debugPrint('[RealtimeVoice] 开始语音对话');
  }

  /// 处理音频块（VAD 检测）
  void processAudioChunk(Uint8List chunk) {
    if (_stopped) return;

    final energy = _calculateEnergy(chunk);
    final now = DateTime.now();

    if (energy > _config.vadThreshold) {
      if (!_isSpeaking) {
        _isSpeaking = true;
        _vadController.add(VADEvent.speechStart);
        debugPrint('[RealtimeVoice] 检测到语音开始');
      }
      _lastSpeechTime = now;
    } else if (_isSpeaking && _lastSpeechTime != null) {
      if (now.difference(_lastSpeechTime!) > _config.silenceTimeout) {
        _isSpeaking = false;
        _vadController.add(VADEvent.speechEnd);
        debugPrint('[RealtimeVoice] 检测到语音结束');
      }
    }
  }

  /// 计算音频能量（RMS）
  double _calculateEnergy(Uint8List chunk) {
    if (chunk.isEmpty) return 0;

    double sum = 0;
    final samples = chunk.length ~/ 2;
    
    for (int i = 0; i < chunk.length - 1; i += 2) {
      final sample = chunk[i] | (chunk[i + 1] << 8);
      sum += sample * sample;
    }
    
    return sqrt(sum / samples);
  }

  /// 设置状态为思考中
  void setThinking() {
    _state = VoiceDialogueState.thinking;
    _notifyState();
  }

  /// 设置状态为说话中
  void setSpeaking() {
    _state = VoiceDialogueState.speaking;
    _notifyState();
  }

  /// 设置状态为监听中
  void setListening() {
    _state = VoiceDialogueState.listening;
    _notifyState();
  }

  /// 设置错误状态
  void setError(String message) {
    _state = VoiceDialogueState.error;
    _notifyState();
    debugPrint('[RealtimeVoice] 错误: $message');
  }

  /// 启用打断功能（实验性）
  void enableInterruption() {
    _interruptionEnabled = true;
    debugPrint('[RealtimeVoice] 打断功能已启用（实验性）');
  }

  /// 禁用打断功能
  void disableInterruption() {
    _interruptionEnabled = false;
  }

  /// 检测到用户语音（用于打断）
  void onUserSpeechDetected() {
    if (!_interruptionEnabled) return;
    if (_state != VoiceDialogueState.speaking) return;

    debugPrint('[RealtimeVoice] 检测到用户语音，触发打断');
    _interruptController.add(null);
  }

  /// 停止语音对话
  Future<void> stopDialogue() async {
    _stopped = true;
    _state = VoiceDialogueState.idle;
    _isSpeaking = false;
    _lastSpeechTime = null;
    _notifyState();
    
    debugPrint('[RealtimeVoice] 停止语音对话');
  }

  void _notifyState() {
    _stateController.add(_state);
  }

  /// 释放资源
  void dispose() {
    _stateController.close();
    _vadController.close();
    _interruptController.close();
  }
}

/// Riverpod Provider
final realtimeVoiceDialogueProvider = Provider<RealtimeVoiceDialogueService>((ref) {
  return RealtimeVoiceDialogueService.instance;
});

final voiceDialogueStateProvider = StreamProvider<VoiceDialogueState>((ref) {
  return ref.watch(realtimeVoiceDialogueProvider).stateStream;
});
