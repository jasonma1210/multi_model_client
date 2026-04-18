import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'asr_service.dart';
import 'tts_service.dart';
import 'tts_service.dart' show VoiceModel;
import '../../features/session/domain/dialogue_engine.dart';

/// 实时语音对话状态
enum VoiceDialogState {
  idle,           // 空闲状态
  listening,      // 正在聆听（等待用户说话）
  recognizing,   // 正在识别（用户说话中）
  thinking,      // 正在思考（LLM 处理中）
  speaking,      // 正在说话（TTS 播放中）
  interrupted,   // 被用户打断
  error,         // 错误状态
}

/// 语音对话配置
class VoiceDialogConfig {
  // ASR 配置
  final ASRService? asrService;
  final String? asrLanguage;

  // TTS 配置
  final TTSService? ttsService;
  final VoiceModel voiceModel;

  // LLM 配置
  final String modelId;
  final String? systemPrompt;

  // VAD 配置
  final int silenceThresholdMs;
  final int minSpeechDurationMs;

  // 其他配置
  final bool autoPlay;      // 是否自动播放 TTS
  final bool enableInterrupt; // 是否允许打断

  const VoiceDialogConfig({
    this.asrService,
    this.asrLanguage = 'zh',
    this.ttsService,
    this.voiceModel = VoiceModel.alloy,
    this.modelId = 'default',
    this.systemPrompt,
    this.silenceThresholdMs = 700,
    this.minSpeechDurationMs = 250,
    this.autoPlay = true,
    this.enableInterrupt = true,
  });
}

/// 实时语音对话引擎
/// 整合 ASR → LLM → TTS 完整链路
class VoiceDialogEngine {
  // 使用 dynamic 兼容 Ref 和 ConsumerRef
  final dynamic _ref;
  final VoiceDialogConfig _config;

  // 状态管理
  VoiceDialogState _state = VoiceDialogState.idle;
  final _stateController = StreamController<VoiceDialogState>.broadcast();
  Stream<VoiceDialogState> get stateStream => _stateController.stream;
  VoiceDialogState get state => _state;

  // 音频录制（使用 record 包，跨平台支持）
  AudioRecorder? _recorder;
  String? _tempAudioPath;

  // 当前对话
  String? _currentSessionId;
  String? _lastRecognizedText;
  String? _lastResponseText;

  // 被打断时的回调
  Function()? onInterrupted;

  VoiceDialogEngine(this._ref, [this._config = const VoiceDialogConfig()]);

  /// 开始语音对话
  Future<void> startDialog(String sessionId) async {
    _currentSessionId = sessionId;
    await _startListening();
  }

  /// 停止语音对话
  Future<void> stopDialog() async {
    await _stopListening();
    _updateState(VoiceDialogState.idle);
    _currentSessionId = null;
  }

  /// 开始聆听（等待用户说话）
  Future<void> _startListening() async {
    _updateState(VoiceDialogState.listening);

    // 启动音频录制
    await _startRecording();

    // TODO: 启动 VAD 检测
    // 检测到语音后切换到 recognizing 状态
  }

  /// 停止聆听
  Future<void> _stopListening() async {
    await _stopRecording();
  }

  /// 打断当前对话
  Future<void> interrupt() async {
    if (!_config.enableInterrupt) return;

    // 停止 TTS 播放
    // 停止 ASR 识别
    await _stopRecording();

    _updateState(VoiceDialogState.interrupted);
    onInterrupted?.call();

    // 重新开始聆听
    await _startListening();
  }

  /// 启动音频录制（使用 record 包，macOS/iOS/Android/Linux 通用）
  Future<void> _startRecording() async {
    try {
      _recorder = AudioRecorder();
      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        print('[VoiceDialogEngine] Microphone permission denied');
        return;
      }

      final dir = await getTemporaryDirectory();
      _tempAudioPath =
          '${dir.path}/voice_dialog_${DateTime.now().millisecondsSinceEpoch}.wav';

      // macOS/iOS 用 WAV 格式（ASR 兼容性更好）
      final encoder = Platform.isIOS || Platform.isMacOS
          ? AudioEncoder.wav
          : AudioEncoder.aacLc;

      await _recorder!.start(
        RecordConfig(
          encoder: encoder,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _tempAudioPath!,
      );
    } catch (e) {
      print('[VoiceDialogEngine] Failed to start recording: $e');
    }
  }

  /// 停止音频录制
  Future<void> _stopRecording() async {
    try {
      await _recorder?.stop();
      _recorder?.dispose();
      _recorder = null;
    } catch (e) {
      print('[VoiceDialogEngine] Failed to stop recording: $e');
    }
  }

  /// 识别音频（ASR）
  Future<String> _recognizeAudio() async {
    if (_tempAudioPath == null) {
      throw StateError('No audio recorded');
    }

    _updateState(VoiceDialogState.recognizing);

    final asrService = _config.asrService ?? ASRService();
    final text = await asrService.recognizeFile(
      _tempAudioPath!,
      language: _config.asrLanguage,
    );

    _lastRecognizedText = text;
    return text;
  }

  /// 处理用户输入（LLM）
  Future<String> _processWithLLM(String text) async {
    _updateState(VoiceDialogState.thinking);

    // 使用对话引擎处理
    // 这里需要集成现有的对话引擎
    final dialogueEngine = _ref.read(dialogueEngineProvider);

    // 发送消息并获取响应
    // TODO: 实现真正的对话调用
    final response = '这是对 "${text}" 的回复'; // 占位符

    _lastResponseText = response;
    return response;
  }

  /// 合成语音（TTS）
  Future<String> _synthesizeSpeech(String text) async {
    _updateState(VoiceDialogState.speaking);

    final ttsService = _config.ttsService ?? TTSService();
    final audioPath = await ttsService.synthesize(text);

    return audioPath;
  }

  /// 播放音频
  Future<void> _playAudio(String audioPath) async {
    // 使用系统播放器播放音频
    // macOS: afplay, Linux: aplay, Windows: start
    String player;
    if (Platform.isMacOS) {
      player = 'afplay';
    } else if (Platform.isLinux) {
      player = 'aplay';
    } else {
      player = 'start'; // Windows
    }

    try {
      await Process.run(player, [audioPath]);
    } catch (e) {
      print('Failed to play audio: $e');
    }
  }

  /// 更新状态
  void _updateState(VoiceDialogState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// 释放资源
  void dispose() {
    _stopRecording();
    _stateController.close();
  }

  // Getter
  String? get lastRecognizedText => _lastRecognizedText;
  String? get lastResponseText => _lastResponseText;
  String? get currentSessionId => _currentSessionId;
}

/// 语音对话状态 Provider
final voiceDialogStateProvider = StateProvider<VoiceDialogState>((ref) => VoiceDialogState.idle);

/// 语音对话引擎 Provider
final voiceDialogEngineProvider = Provider.family<VoiceDialogEngine, VoiceDialogConfig>(
  (ref, config) => VoiceDialogEngine(ref, config),
);

/// 默认语音对话引擎
final defaultVoiceDialogEngineProvider = Provider<VoiceDialogEngine>((ref) {
  return VoiceDialogEngine(ref);
});