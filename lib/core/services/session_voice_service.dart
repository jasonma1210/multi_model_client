/// 会话语音服务 - LLM Studio 语音播报模块
/// 
/// 功能：
/// - 会话语音播报状态管理
/// - 语音输出开关
/// - 会话级语音设置
/// - 状态持久化
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 会话语音播报状态管理
class SessionVoiceOutputNotifier extends StateNotifier<Map<String, bool>> {
  final SharedPreferences _prefs;
  static const String _keyPrefix = 'session_voice_output_';

  SessionVoiceOutputNotifier(this._prefs) : super({}) {
    _loadAllSessions();
  }

  /// 从本地加载所有会话的语音设置
  void _loadAllSessions() {
    // 这里可以后续优化为从数据库读取所有会话 ID
    // 目前先返回空状态
  }

  /// 获取会话的语音播报状态
  bool getSessionVoiceOutput(String sessionId) {
    return state[sessionId] ?? false;
  }

  /// 设置会话的语音播报状态
  Future<void> setSessionVoiceOutput(String sessionId, bool enabled) async {
    state = {...state, sessionId: enabled};
    await _prefs.setBool('$_keyPrefix$sessionId', enabled);
  }

  /// 切换会话的语音播报状态
  Future<void> toggleSessionVoiceOutput(String sessionId) async {
    final current = getSessionVoiceOutput(sessionId);
    await setSessionVoiceOutput(sessionId, !current);
  }

  /// 加载指定会话的语音设置
  Future<void> loadSessionVoiceOutput(String sessionId) async {
    final enabled = _prefs.getBool('$_keyPrefix$sessionId') ?? false;
    state = {...state, sessionId: enabled};
  }

  /// 删除会话的语音设置
  Future<void> removeSessionVoiceOutput(String sessionId) async {
    final newState = Map<String, bool>.from(state);
    newState.remove(sessionId);
    state = newState;
    await _prefs.remove('$_keyPrefix$sessionId');
  }
}

/// 全局 TTS 配置状态
class TTSConfigState {
  final String provider;      // 当前 TTS 提供商
  final String? apiKey;       // API Key (如果有)
  final String voice;         // 当前音色
  final double speed;         // 语速
  final bool isConfigured;   // 是否已配置完成
  final bool isFirstUse;     // 是否首次使用

  const TTSConfigState({
    this.provider = '',
    this.apiKey,
    this.voice = 'default',
    this.speed = 1.0,
    this.isConfigured = false,
    this.isFirstUse = true,
  });

  TTSConfigState copyWith({
    String? provider,
    String? apiKey,
    String? voice,
    double? speed,
    bool? isConfigured,
    bool? isFirstUse,
  }) {
    return TTSConfigState(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      voice: voice ?? this.voice,
      speed: speed ?? this.speed,
      isConfigured: isConfigured ?? this.isConfigured,
      isFirstUse: isFirstUse ?? this.isFirstUse,
    );
  }
}

/// TTS 配置状态管理
class TTSConfigNotifier extends StateNotifier<TTSConfigState> {
  final SharedPreferences _prefs;

  static const String _providerKey = 'tts_provider';
  static const String _voiceKey = 'tts_voice';
  static const String _speedKey = 'tts_speed';
  static const String _firstUseKey = 'tts_first_use';
  static const String _configuredKey = 'tts_configured';

  TTSConfigNotifier(this._prefs) : super(const TTSConfigState()) {
    _loadConfig();
  }

  void _loadConfig() {
    final provider = _prefs.getString(_providerKey) ?? '';
    final voice = _prefs.getString(_voiceKey) ?? 'default';
    final speed = _prefs.getDouble(_speedKey) ?? 1.0;
    final isFirstUse = _prefs.getBool(_firstUseKey) ?? true;
    final isConfigured = _prefs.getBool(_configuredKey) ?? false;

    state = TTSConfigState(
      provider: provider,
      voice: voice,
      speed: speed,
      isFirstUse: isFirstUse,
      isConfigured: isConfigured,
    );
  }

  /// 设置 TTS 提供商
  Future<void> setProvider(String provider) async {
    state = state.copyWith(provider: provider);
    await _prefs.setString(_providerKey, provider);
    await _prefs.setBool(_configuredKey, provider.isNotEmpty);
    await _prefs.setBool(_firstUseKey, false);
  }

  /// 设置音色
  Future<void> setVoice(String voice) async {
    state = state.copyWith(voice: voice);
    await _prefs.setString(_voiceKey, voice);
  }

  /// 设置语速
  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _prefs.setDouble(_speedKey, speed);
  }

  /// 完成首次配置
  Future<void> completeFirstUse() async {
    state = state.copyWith(isFirstUse: false);
    await _prefs.setBool(_firstUseKey, false);
  }

  /// 检查是否需要首次配置引导
  bool get needsFirstTimeSetup => state.isFirstUse || !state.isConfigured;
}

/// 会话语音播报 Provider
final sessionVoiceOutputProvider =
    StateNotifierProvider<SessionVoiceOutputNotifier, Map<String, bool>>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

/// TTS 配置 Provider
final ttsConfigProvider =
    StateNotifierProvider<TTSConfigNotifier, TTSConfigState>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

/// 当前会话是否开启语音播报
final currentSessionVoiceOutputProvider = Provider.family<bool, String>((ref, sessionId) {
  final voiceOutputs = ref.watch(sessionVoiceOutputProvider);
  return voiceOutputs[sessionId] ?? false;
});