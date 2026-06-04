library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/services/asr_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/session/domain/dialogue_engine.dart';
import '../../../../features/session/domain/session_manager.dart';
import '../../../../core/services/voice_clone_service.dart';

enum _VoiceState {
  idle,
  recording,
  recognizing,
  thinking,
  speaking,
  error,
}

class RealtimeVoicePage extends ConsumerStatefulWidget {
  final String sessionId;

  const RealtimeVoicePage({super.key, required this.sessionId});

  @override
  ConsumerState<RealtimeVoicePage> createState() => _RealtimeVoicePageState();
}

class _RealtimeVoicePageState extends ConsumerState<RealtimeVoicePage>
    with TickerProviderStateMixin {
  _VoiceState _state = _VoiceState.idle;
  String _userText = '';
  String _aiText = '';
  String _statusText = '按住说话';
  String? _errorMsg;

  ASRService? _asrService;
  AudioRecorder? _recorder;
  String? _tempAudioPath;

  TTSService? _ttsService;
  AudioPlayer? _audioPlayer;
  bool _ttsInterrupted = false;

  DialogueEngine? _dialogueEngine;

  late AnimationController _pulseController;
  late AnimationController _rippleController;

  final List<_VoiceMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isDisposed = false;
  bool _isPressed = false;
  bool _isCancelled = false;
  double _dragOffsetY = 0.0;
  static const double _cancelThreshold = -80.0;

  String _sessionName = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSessionInfo();
    _initServices();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
  }

  void _loadSessionInfo() {
    final sessionState = ref.read(sessionStateProvider);
    final session = sessionState.activeSession;
    if (session != null) {
      _sessionName = session.name;
    }
  }

  Future<void> _initServices() async {
    try {
      final settingsService = ref.read(settingsServiceProvider);
      await settingsService.initialize();
      final prefs = await SharedPreferences.getInstance();

      final ttsProvider = settingsService.getTtsProvider();
      final ttsModelId = prefs.getString('selected_tts_model_id') ?? 'melo-zh-en';
      final ttsVoice = prefs.getString('tts_voice_id') ?? '0';
      final ttsSpeed = prefs.getDouble('system_tts_speed') ?? 0.5;
      final asrProvider = settingsService.getAsrProvider();
      final selectedAsrModelId = prefs.getString('selected_asr_model_id') ?? 'sensevoice-int8';

      var resolvedTtsProvider = ttsProvider;

      final isMobile = Platform.isAndroid || Platform.isIOS;
      final sessionState = ref.read(sessionStateProvider);
      final session = sessionState.activeSession;
      final modelId = session?.modelId ?? '';
      final isLocalModel = modelId.startsWith('local-') || modelId.startsWith('ffi-') || modelId.contains('gguf');
      if (isMobile && isLocalModel && resolvedTtsProvider == 'sherpa') {
        resolvedTtsProvider = 'system';
      }

      final ttsProviderEnum = switch (resolvedTtsProvider) {
        'sherpa' => TTSProvider.sherpa,
        'system' => TTSProvider.system,
        'openai' => TTSProvider.openai,
        'mimo' => TTSProvider.mimo,
        _ => TTSProvider.system,
      };

      final asrProviderEnum = switch (asrProvider) {
        'sherpa' => ASRProvider.sherpa,
        'system' => ASRProvider.system,
        'openai' => ASRProvider.openai,
        'aliyun' => ASRProvider.aliyun,
        'tencent' => ASRProvider.tencent,
        'whisper' => ASRProvider.openai,
        _ => ASRProvider.system,
      };

      String? ttsApiKey;
      MiMoVoice mimoVoice = MiMoVoice.Chloe;
      String? cloneRefAudioPath;
      if (resolvedTtsProvider == 'mimo') {
        ttsApiKey = await settingsService.getMimoApiKeyAsync();
        final mimoVoiceStr = prefs.getString('tts_voice_id') ?? 'Chloe';
        debugPrint('[RealtimeVoicePage] MiMo音色原始值: $mimoVoiceStr');
        if (mimoVoiceStr.startsWith('clone_')) {
          try {
            final cloneService = VoiceCloneService();
            final voices = await cloneService.getClonedVoices();
            final cloneId = mimoVoiceStr.substring(6);
            debugPrint('[RealtimeVoicePage] 查找克隆音色: cloneId=$cloneId, 可用数量=${voices.length}');
            final cloneVoice = voices.where((v) => v.id == cloneId).firstOrNull;
            if (cloneVoice != null && cloneVoice.isReady) {
              cloneRefAudioPath = cloneVoice.referenceAudioPath;
              debugPrint('[RealtimeVoicePage] 克隆音色加载成功: ${cloneVoice.name}, path=$cloneRefAudioPath');
            } else {
              debugPrint('[RealtimeVoicePage] 克隆音色未找到或未就绪: found=${cloneVoice != null}, ready=${cloneVoice?.isReady}');
            }
          } catch (e) {
            debugPrint('[RealtimeVoicePage] Failed to load clone voice: $e');
          }
        } else {
          mimoVoice = MiMoVoice.values.firstWhere(
            (v) => v.name == mimoVoiceStr,
            orElse: () => MiMoVoice.Chloe,
          );
        }

        if (ttsApiKey == null || ttsApiKey.isEmpty) {
          resolvedTtsProvider = 'system';
        }
      }

      debugPrint('[RealtimeVoicePage] TTS配置: provider=$resolvedTtsProvider, mimoVoice=${mimoVoice.name}, cloneRef=${cloneRefAudioPath != null ? "有" : "无"}');

      _asrService = ASRService(
        provider: asrProviderEnum,
        sherpaModelId: selectedAsrModelId,
      );

      _ttsService = TTSService(
        provider: ttsProviderEnum,
        apiKey: ttsApiKey,
        mimoVoice: mimoVoice,
        cloneReferenceAudioPath: cloneRefAudioPath,
        sherpaModelId: ttsModelId,
        speechRate: ttsSpeed,
        speakerId: int.tryParse(ttsVoice) ?? 0,
      );

      _audioPlayer = AudioPlayer();
      _dialogueEngine = ref.read(dialogueEngineProvider);

      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('[RealtimeVoicePage] 初始化服务失败: $e');
      debugPrint('[RealtimeVoicePage] $st');
      if (mounted) {
        setState(() {
          _errorMsg = '初始化失败: $e';
          _state = _VoiceState.error;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopRecording();
    _audioPlayer?.dispose();
    _asrService?.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(theme),
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildChatList(theme),
            ),
            _buildVoiceControlArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _sessionName.isNotEmpty ? _sessionName : '实时语音对话',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(theme),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.record_voice_over_rounded,
            size: 48,
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            '按住下方按钮说话',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '松手后 AI 自动回复并朗读',
            style: theme.textTheme.bodySmall?.copyWith(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildMessageBubble(msg, theme);
      },
    );
  }

  Widget _buildMessageBubble(_VoiceMessage msg, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              child: Icon(Icons.smart_toy_rounded, size: 16, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary.withValues(alpha: 0.12)
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.15),
              child: Icon(Icons.person_rounded, size: 16, color: theme.colorScheme.tertiary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceControlArea(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_userText.isNotEmpty && (_state == _VoiceState.recognizing || _state == _VoiceState.thinking))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Text(
                _userText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (_aiText.isNotEmpty && _state == _VoiceState.thinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
              child: Text(
                _aiText,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
              child: Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          _buildPressToTalkButton(theme),
          const SizedBox(height: 8),
          Text(
            _isCancelled
                ? '松手取消'
                : _isPressed
                    ? '上滑取消 · 松手发送'
                    : '按住说话',
            style: theme.textTheme.labelSmall?.copyWith(
              color: _isCancelled
                  ? theme.colorScheme.error
                  : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressToTalkButton(ThemeData theme) {
    final isActive = _state == _VoiceState.recording;
    final isProcessing = _state == _VoiceState.recognizing || _state == _VoiceState.thinking;
    final isSpeaking = _state == _VoiceState.speaking;

    return GestureDetector(
      onPanStart: (_) => _onPressStart(),
      onPanUpdate: (details) => _onPanUpdate(details),
      onPanEnd: (_) => _onPressEnd(),
      onPanCancel: () => _onPressEnd(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rippleController]),
        builder: (context, child) {
          return SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isActive) ...[
                  _buildRippleRing(80 + _pulseController.value * 20, theme.colorScheme.error.withValues(alpha: 0.08)),
                  _buildRippleRing(80 + _pulseController.value * 40, theme.colorScheme.error.withValues(alpha: 0.04)),
                ],
                if (isSpeaking) ...[
                  _buildRippleRing(80 + _pulseController.value * 20, theme.colorScheme.secondary.withValues(alpha: 0.08)),
                  _buildRippleRing(80 + _pulseController.value * 40, theme.colorScheme.secondary.withValues(alpha: 0.04)),
                ],
                if (isProcessing) ...[
                  _buildRippleRing(80 + _pulseController.value * 16, theme.colorScheme.tertiary.withValues(alpha: 0.06)),
                ],
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isPressed ? 76 : 68,
                  height: _isPressed ? 76 : 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isCancelled
                        ? LinearGradient(
                            colors: [Colors.grey.shade500, Colors.grey.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : isActive
                            ? LinearGradient(
                                colors: [theme.colorScheme.error, theme.colorScheme.error.withValues(alpha: 0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : isSpeaking
                                ? LinearGradient(
                                    colors: [theme.colorScheme.secondary, theme.colorScheme.secondary.withValues(alpha: 0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : isProcessing
                                    ? LinearGradient(
                                        colors: [theme.colorScheme.tertiary, theme.colorScheme.tertiary.withValues(alpha: 0.8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isCancelled
                                ? Colors.grey
                                : isActive
                                    ? theme.colorScheme.error
                                    : isSpeaking
                                        ? theme.colorScheme.secondary
                                        : isProcessing
                                            ? theme.colorScheme.tertiary
                                            : theme.colorScheme.primary)
                            .withValues(alpha: isActive && !_isCancelled ? 0.4 : 0.2),
                        blurRadius: isActive && !_isCancelled ? 20 : 12,
                        spreadRadius: isActive && !_isCancelled ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isCancelled
                        ? Icons.delete_outline_rounded
                        : isActive
                            ? Icons.mic_rounded
                            : isSpeaking
                                ? Icons.volume_up_rounded
                                : isProcessing
                                    ? Icons.hourglass_top_rounded
                                    : Icons.mic_none_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRippleRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  按住说话核心逻辑
  // ════════════════════════════════════════════════════════════════

  void _onPressStart() {
    if (_asrService == null) {
      setState(() => _errorMsg = '语音服务未初始化');
      return;
    }

    if (_state == _VoiceState.speaking) {
      _interruptTTS();
    }

    if (_state != _VoiceState.idle && _state != _VoiceState.error && _state != _VoiceState.speaking) {
      return;
    }

    setState(() {
      _isPressed = true;
      _isCancelled = false;
      _dragOffsetY = 0.0;
      _state = _VoiceState.recording;
      _statusText = '正在聆听...';
      _userText = '';
      _aiText = '';
      _errorMsg = null;
    });

    HapticFeedback.mediumImpact();
    _pulseController.repeat();
    _startRecording();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isPressed || _state != _VoiceState.recording) return;

    setState(() {
      _dragOffsetY = details.localPosition.dy;
      final wasCancelled = _isCancelled;
      _isCancelled = _dragOffsetY < _cancelThreshold;
      if (_isCancelled && !wasCancelled) {
        HapticFeedback.mediumImpact();
      }
      _statusText = _isCancelled ? '松手取消' : '正在聆听...（上滑取消）';
    });
  }

  void _onPressEnd() {
    if (!_isPressed) return;

    final cancelled = _isCancelled;

    setState(() {
      _isPressed = false;
      _isCancelled = false;
      _dragOffsetY = 0.0;
    });

    _pulseController.stop();

    if (cancelled) {
      HapticFeedback.lightImpact();
      _cancelRecording();
    } else if (_state == _VoiceState.recording) {
      HapticFeedback.lightImpact();
      _stopRecordingAndProcess();
    }
  }

  void _cancelRecording() {
    _recorder?.stop();
    _recorder?.dispose();
    _recorder = null;
    _tempAudioPath = null;

    setState(() {
      _state = _VoiceState.idle;
      _statusText = '已取消';
      _userText = '';
      _aiText = '';
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _state == _VoiceState.idle) {
        setState(() => _statusText = '按住说话');
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      _recorder = AudioRecorder();
      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        setState(() {
          _errorMsg = '麦克风权限被拒绝';
          _state = _VoiceState.error;
        });
        return;
      }

      final dir = await getTemporaryDirectory();
      _tempAudioPath =
          '${dir.path}/realtime_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder!.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _tempAudioPath!,
      );
    } catch (e) {
      debugPrint('[RealtimeVoicePage] 启动录音失败: $e');
      setState(() {
        _errorMsg = '录音失败: $e';
        _state = _VoiceState.error;
      });
    }
  }

  Future<void> _stopRecordingAndProcess() async {
    try {
      await _recorder?.stop();
      _recorder?.dispose();
      _recorder = null;

      if (_tempAudioPath != null && !_isDisposed) {
        await _recognizeAudio();
      }
    } catch (e) {
      debugPrint('[RealtimeVoicePage] 停止录音失败: $e');
    }
  }

  void _stopRecording() {
    _recorder?.stop();
    _recorder?.dispose();
    _recorder = null;
  }

  Future<void> _recognizeAudio() async {
    if (_tempAudioPath == null || _asrService == null) return;

    setState(() {
      _state = _VoiceState.recognizing;
      _statusText = '正在识别...';
    });

    try {
      String audioPath = _tempAudioPath!;

      if (!audioPath.toLowerCase().endsWith('.wav') && _asrService!.provider == ASRProvider.sherpa) {
        final dir = await getTemporaryDirectory();
        final wavPath = '${dir.path}/realtime_voice_converted_${DateTime.now().millisecondsSinceEpoch}.wav';
        final converted = await _asrService!.convertAudioFormat(audioPath, wavPath);
        audioPath = converted;
      }

      final text = await _asrService!.recognizeFile(audioPath);

      if (text.trim().isEmpty) {
        setState(() {
          _userText = '';
          _state = _VoiceState.idle;
          _statusText = '按住说话';
        });
        return;
      }

      final userMsg = text.trim();
      setState(() {
        _userText = userMsg;
        _messages.add(_VoiceMessage(
          text: userMsg,
          isUser: true,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();

      await _processWithLLM(userMsg);
    } catch (e) {
      debugPrint('[RealtimeVoicePage] 识别失败: $e');
      setState(() {
        _errorMsg = '识别失败: $e';
        _state = _VoiceState.error;
      });
    }
  }

  Future<void> _processWithLLM(String text) async {
    // ★★★ 修复 V76：每次新对话前重置 _ttsInterrupted ★★★
    // 上一轮 TTS 被打断时 _ttsInterrupted=true，如果不重置，
    // 下一轮 await for 循环会在第一个 chunk 就 break，导致 fullResponse 为空
    _ttsInterrupted = false;

    setState(() {
      _state = _VoiceState.thinking;
      _statusText = '正在思考...';
      _aiText = '';
    });

    _pulseController.repeat();

    try {
      if (_dialogueEngine != null) {
        debugPrint('[RealtimeVoicePage] 开始流式推理: sessionId=${widget.sessionId}');
        final responseStream = _dialogueEngine!.streamResponse(
          widget.sessionId,
          text,
        );

        String fullResponse = '';
        int chunkCount = 0;
        await for (final chunk in responseStream) {
          chunkCount++;
          if (_isDisposed) break;
          // ★ 修复：只累加中间 token，isComplete=true 时的 yield 是完整的 responseBuffer，
          //   不能再累加，否则会导致"输出的 content 变成 2 遍"。
          if (!chunk.isComplete) {
            fullResponse += chunk.content;
          } else {
            // 完成信号：直接用完整内容覆盖（防止中途丢 token 时内容不完整）
            fullResponse = chunk.content;
          }
          if (mounted) {
            setState(() {
              _aiText = fullResponse;
            });
          }
        }

        debugPrint('[RealtimeVoicePage] 流式推理完成: chunkCount=$chunkCount, fullResponse.length=${fullResponse.length}, _ttsInterrupted=$_ttsInterrupted');

        if (fullResponse.isNotEmpty && !_isDisposed && !_ttsInterrupted) {
          setState(() {
            _messages.add(_VoiceMessage(
              text: fullResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _aiText = '';
          });
          _scrollToBottom();

          await _speakResponse(fullResponse);
        } else if (!_isDisposed) {
          // ★★★ V77 修复：所有"非 happy path"都恢复 idle ★★★
          // 覆盖场景：
          //   1. fullResponse 为空（被 _cleanThinkTags 全部清洗）
          //   2. _ttsInterrupted=true（用户打断 LLM 思考，跳过 TTS）
          //   3. dialogue_engine 注入"模型未产生输出..."
          // 不恢复 → state 永远卡 thinking/speaking → 后续按说话无效
          debugPrint('[RealtimeVoicePage] 跳过TTS（响应为空或被打断），恢复 idle 状态');
          if (mounted) {
            setState(() {
              _aiText = '';
              _userText = '';
            });
          }
          _onTTSComplete();
        }
      }
    } catch (e) {
      debugPrint('[RealtimeVoicePage] LLM 处理失败: $e');
      // ★★★ V77 修复：异常时也恢复 idle，避免状态卡死 ★★★
      if (mounted) {
        setState(() {
          _errorMsg = '处理失败: $e';
          _state = _VoiceState.idle;
          _statusText = '按住说话';
          _aiText = '';
          _userText = '';
        });
      }
      _pulseController.stop();
    }
  }

  Future<void> _speakResponse(String text) async {
    // ★★★ V77 修复：所有 early return 都必须恢复状态 ★★★
    // 旧代码：_ttsService==null 或 _isDisposed 时直接 return，
    // 但此时 state 已经是 thinking（由 _processWithLLM 设置），
    // 不恢复 → state 永远卡 thinking → 后续按说话无效
    if (_ttsService == null || _isDisposed) {
      _onTTSComplete();
      return;
    }

    setState(() {
      _state = _VoiceState.speaking;
      _statusText = '正在回复...';
      _ttsInterrupted = false;
    });

    _pulseController.repeat();

    try {
      debugPrint('[RealtimeVoicePage] 开始TTS合成，音色来自语音设置');
      final audioPath = await _ttsService!.synthesize(text);

      if (_isDisposed) {
        _onTTSComplete();
        return;
      }
      if (_ttsInterrupted) {
        // 被打断时 _interruptTTS 已恢复 state，直接退出
        return;
      }

      if (audioPath.isNotEmpty) {
        // ★★★ V77 修复：播放前先 stop 上一轮的音频 ★★★
        // 旧代码：播放完成后不 stop，player 留在 completed 状态
        // 下一轮 setFilePath 可能无法正确重置 player 内部状态
        try { await _audioPlayer!.stop(); } catch (_) {}
        await _audioPlayer!.setFilePath(audioPath);
        await _audioPlayer!.play();

        // ★★★ 修复 V75：用 processingStateStream + completion future 替代轮询 ★★★
        await _waitForPlaybackComplete();
      }
    } catch (e) {
      debugPrint('[RealtimeVoicePage] TTS 播放失败: $e');
    }

    // ★★★ 修复 V75：无论 audioPath 是否为空、TTS 是否被打断，都确保 state 恢复 ★★★
    // 旧代码：audioPath.isEmpty 时不调 _onTTSComplete() → state 永远卡 speaking
    // 旧代码：_ttsInterrupted 时 return 不调 _onTTSComplete() → state 不一致
    // 修复：只在 _interruptTTS 已恢复 state 时跳过，其他情况都恢复
    if (!_isDisposed && _state != _VoiceState.idle) {
      _onTTSComplete();
    }
  }

  /// 等待音频播放完成或被打断
  ///
  /// ★★★ V77 修复：使用 playerStateStream 替代 processingStateStream ★★★
  /// 旧方案问题：
  ///   1. processingStateStream 的 completed 事件可能在 timeout 检查间隙被吞掉
  ///   2. completer.future.timeout(50ms) 每次创建新 future，completed 信号可能丢失
  ///   3. 导致正常播放完成后方法挂起，直到 3 分钟超时
  /// 新方案：
  ///   1. 监听 playerStateStream（更可靠，包含 playing/completed 等完整状态）
  ///   2. 用 Completer + 100ms 轮询检查中断信号
  ///   3. 播放完成后 stop() 重置 player，确保下次可复用
  Future<void> _waitForPlaybackComplete() async {
    const maxWait = Duration(minutes: 3);
    final startTime = DateTime.now();

    final completer = Completer<void>();
    StreamSubscription? subscription;

    subscription = _audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed && !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      while (!completer.isCompleted && !_isDisposed && !_ttsInterrupted) {
        if (DateTime.now().difference(startTime) > maxWait) {
          debugPrint('[RealtimeVoicePage] TTS 播放超过 3 分钟，强制结束');
          break;
        }

        // 等待完成信号，每 100ms 检查一次中断
        try {
          await completer.future.timeout(const Duration(milliseconds: 100));
          // completed → 正常退出
          debugPrint('[RealtimeVoicePage] TTS 播放正常完成');
          break;
        } on TimeoutException {
          // 超时 = 还没播放完，检查中断信号后继续
          continue;
        }
      }
    } finally {
      await subscription.cancel();
      // ★★★ V77 修复：播放完成后始终 stop() 重置 player ★★★
      // 无论正常完成还是被打断/超时，都 stop 以确保下次可复用
      try { await _audioPlayer?.stop(); } catch (_) {}
    }
  }

  void _onTTSComplete() {
    _pulseController.stop();

    if (mounted) {
      setState(() {
        _state = _VoiceState.idle;
        _statusText = '按住说话';
        _userText = '';
        _aiText = '';
      });
    }
  }

  void _interruptTTS() {
    _ttsInterrupted = true;
    _audioPlayer?.stop();
    _pulseController.stop();

    HapticFeedback.mediumImpact();

    setState(() {
      _state = _VoiceState.idle;
      _statusText = '按住说话';
      _userText = '';
      _aiText = '';
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getStatusColor(ThemeData theme) {
    switch (_state) {
      case _VoiceState.recording:
      case _VoiceState.recognizing:
        return theme.colorScheme.primary;
      case _VoiceState.thinking:
        return theme.colorScheme.tertiary;
      case _VoiceState.speaking:
        return theme.colorScheme.secondary;
      case _VoiceState.error:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _VoiceMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _VoiceMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
