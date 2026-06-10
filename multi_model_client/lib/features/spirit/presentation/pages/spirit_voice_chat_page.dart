// ignore_for_file: use_build_context_synchronously
/// 名灵回响 - 语音对话页面
///
/// 参考主流语音对话实现，支持：
/// - 按住说话（Press-to-Talk）
/// - ASR 语音识别
/// - LLM 流式推理（注入名灵蒸馏 prompt）
/// - TTS 语音合成（使用名灵克隆音色）
/// - 实时打断（AI 说话时按住即可打断）
/// - 上滑取消录音
///
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/model_provider.dart';
import '../../../../core/services/asr_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/voice_clone_service.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../features/session/domain/dialogue_engine.dart';
import '../../../../features/session/domain/session_manager.dart';
import '../../../../features/session/data/repositories/session_repository.dart';
import '../../../../core/storage/database_connection.dart';
import '../../data/spirit_repository.dart';
import '../../domain/spirit_persona.dart';
import '../../domain/spirit_skill.dart';
import '../../../skill/domain/skill_dispatcher.dart';

/// MIMO 可用音色列表
const List<MapEntry<String, String>> _mimoVoiceOptions = [
  MapEntry('Chloe', '温柔女声'),
  MapEntry('Alex', '沉稳男声'),
  MapEntry('Bella', '甜美女声'),
  MapEntry('Marcus', '磁性男声'),
  MapEntry('Emily', '清亮女声'),
  MapEntry('Ethan', '低沉男声'),
];

/// 语音状态
enum _VoiceState {
  idle,
  recording,
  recognizing,
  thinking,
  speaking,
  error,
}

/// 名灵语音对话页面
class SpiritVoiceChatPage extends ConsumerStatefulWidget {
  final String spiritId;
  final String modelId;

  const SpiritVoiceChatPage({super.key, required this.spiritId, this.modelId = ''});

  @override
  ConsumerState<SpiritVoiceChatPage> createState() => _SpiritVoiceChatPageState();
}

class _SpiritVoiceChatPageState extends ConsumerState<SpiritVoiceChatPage>
    with TickerProviderStateMixin {
  // ── 状态 ──
  _VoiceState _state = _VoiceState.idle;
  String _userText = '';
  String _aiText = '';
  String _statusText = '按住说话';
  String? _errorMsg;

  // ── 名灵数据 ──
  SpiritPersona? _persona;
  String? _sessionId;
  bool _isInitializing = true;

  // ── 服务 ──
  ASRService? _asrService;
  AudioRecorder? _recorder;
  String? _tempAudioPath;

  TTSService? _ttsService;
  AudioPlayer? _audioPlayer;
  bool _ttsInterrupted = false;

  DialogueEngine? _dialogueEngine;

  // ── 动画 ──
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  // ── 消息列表 ──
  final List<_VoiceMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // ★ 克隆音色列表
  List<ClonedVoice> _clonedVoices = [];

  // ── 手势 ──
  bool _isDisposed = false;
  bool _isPressed = false;
  bool _isCancelled = false;
  double _dragOffsetY = 0.0;
  static const double _cancelThreshold = -80.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initChat();
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

  /// 初始化名灵对话：加载角色 → 查找或创建会话 → 初始化语音服务 → 加载历史消息
  Future<void> _initChat() async {
    try {
      // 1. 加载名灵角色
      final repo = ref.read(spiritRepositoryProvider);
      final persona = await repo.getPersonaById(widget.spiritId);

      if (persona == null || !persona.isReady) {
        if (mounted) {
          setState(() => _isInitializing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('名灵角色不存在或未就绪')),
          );
          Navigator.pop(context);
        }
        return;
      }

      // 2. 注册技能
      final dispatcher = SkillDispatcher();
      final skillManager = SpiritSkillManager();
      skillManager.registerSpiritSkill(persona, dispatcher);

      // 3. 查找已有会话或创建新会话（同一个名灵只创建一个会话）
      final sessionRepo = SessionRepository();
      var session = await sessionRepo.findSpiritSession(persona.id);

      if (session == null) {
        // 首次对话，创建新会话（标记为名灵会话）
        session = await sessionRepo.createSession(
          name: '${persona.avatarEmoji} ${persona.nickname}',
          modelId: widget.modelId,
          isSpirit: true,
        );
        // 设置技能
        await sessionRepo.updateEnabledSkill(session.id, 'spirit.${persona.id}');
        // 名灵语音对话始终启用语音输出（注入 TTS 控制标签）
        await sessionRepo.updateSession(
          id: session.id,
          enableVoiceOutput: true,
        );
      } else {
        // 已有会话，更新模型（如果用户选择了不同的模型）
        if (widget.modelId.isNotEmpty && session.modelId != widget.modelId) {
          await sessionRepo.updateSession(
            id: session.id,
            modelId: widget.modelId,
          );
          session = (await sessionRepo.getSession(session.id))!;
        }
        // 确保已有会话也启用语音输出（旧会话可能没有设置）
        if (!session.enableVoiceOutput) {
          await sessionRepo.updateSession(
            id: session.id,
            enableVoiceOutput: true,
          );
        }
      }

      // 切换到会话
      final sessionManager = ref.read(sessionManagerProvider);
      await sessionManager.switchSession(session.id);

      _persona = persona;
      _sessionId = session.id;

      // 4. 加载历史消息到语音对话界面
      await _loadHistoryMessages(session.id);

      // 5. 初始化语音服务
      await _initVoiceServices(persona);

      // 6. ★ 加载所有克隆音色列表
      await _loadClonedVoices();

      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 初始化失败: $e');
      if (mounted) {
        setState(() => _isInitializing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化失败: $e')),
        );
      }
    }
  }

  /// ★ 加载所有克隆音色列表
  Future<void> _loadClonedVoices() async {
    try {
      final cloneService = VoiceCloneService();
      final voices = await cloneService.getClonedVoices();
      if (mounted) {
        setState(() => _clonedVoices = voices);
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 加载克隆音色失败: $e');
    }
  }

  /// 加载历史消息到语音对话界面
  Future<void> _loadHistoryMessages(String sessionId) async {
    try {
      final db = database;
      final messages = await db.getSessionMessages(sessionId);
      if (messages.isNotEmpty) {
        final historyMessages = messages.map((m) {
          return _VoiceMessage(
            text: m.content,
            isUser: m.role == 'user',
            timestamp: m.createdAt,
          );
        }).toList();
        _messages.addAll(historyMessages);
        debugPrint('[SpiritVoiceChat] 加载了 ${historyMessages.length} 条历史消息');
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 加载历史消息失败: $e');
    }
  }

  /// 初始化 ASR + TTS 服务（参考 RealtimeVoicePage）
  Future<void> _initVoiceServices(SpiritPersona persona) async {
    try {
      final settingsService = ref.read(settingsServiceProvider);
      await settingsService.initialize();
      final prefs = await SharedPreferences.getInstance();

      // ── ASR 配置 ──
      final asrProvider = settingsService.getAsrProvider();
      final selectedAsrModelId =
          prefs.getString('selected_asr_model_id') ?? 'sensevoice-int8';

      final asrProviderEnum = switch (asrProvider) {
        'sherpa' => ASRProvider.sherpa,
        'system' => ASRProvider.system,
        'openai' => ASRProvider.openai,
        'aliyun' => ASRProvider.aliyun,
        'tencent' => ASRProvider.tencent,
        'whisper' => ASRProvider.openai,
        _ => ASRProvider.system,
      };

      _asrService = ASRService(
        provider: asrProviderEnum,
        sherpaModelId: selectedAsrModelId,
      );

      // ── TTS 配置 ──
      var ttsProvider = settingsService.getTtsProvider();
      final ttsModelId = prefs.getString('selected_tts_model_id') ?? 'melo-zh-en';
      var ttsVoice = prefs.getString('tts_voice_id') ?? '0';
      final ttsSpeed = prefs.getDouble('system_tts_speed') ?? 0.5;

      // ★ 名灵音色优先级：lastUsedVoiceId > clonedVoiceId > 默认
      // 如果 lastUsedVoiceId 以 clone_ 开头，使用克隆音色
      // 如果 lastUsedVoiceId 是 MIMO 预设音色名，使用对应预设
      String? ttsApiKey;
      MiMoVoice mimoVoice = MiMoVoice.mimo_default;
      String? cloneRefAudioPath;

      final effectiveVoiceId = persona.lastUsedVoiceId ??
          (persona.clonedVoiceId != null ? 'clone_${persona.clonedVoiceId}' : null) ??
          'mimo_default';

      // 强制使用 mimo 作为 TTS 提供者
      ttsProvider = 'mimo';

      if (effectiveVoiceId.startsWith('clone_')) {
        // 克隆音色
        final cloneId = effectiveVoiceId.substring(6);
        ttsVoice = cloneId;
        try {
          final cloneService = VoiceCloneService();
          final voices = await cloneService.getClonedVoices();
          final cloneVoice = voices.where((v) => v.id == cloneId).firstOrNull;
          if (cloneVoice != null && cloneVoice.isReady) {
            cloneRefAudioPath = cloneVoice.referenceAudioPath;
            debugPrint('[SpiritVoiceChat] 克隆音色加载成功: ${cloneVoice.name}, refAudio=$cloneRefAudioPath');
          } else {
            debugPrint('[SpiritVoiceChat] 克隆音色未就绪或未找到: id=$cloneId');
          }
        } catch (e) {
          debugPrint('[SpiritVoiceChat] 加载克隆音色失败: $e');
        }
      } else if (persona.clonedVoiceId != null && !effectiveVoiceId.startsWith('clone_')) {
        // 用户选择了非克隆音色，但 persona 有克隆音色
        // 尊重用户选择，使用 MIMO 预设音色
        mimoVoice = MiMoVoice.values.firstWhere(
          (v) => v.name == effectiveVoiceId,
          orElse: () => MiMoVoice.mimo_default,
        );
        ttsVoice = mimoVoice.name;
        debugPrint('[SpiritVoiceChat] 使用 MIMO 预设音色: ${mimoVoice.name}');
      } else {
        // 无克隆音色，使用 MIMO 预设音色
        mimoVoice = MiMoVoice.values.firstWhere(
          (v) => v.name == effectiveVoiceId,
          orElse: () => MiMoVoice.mimo_default,
        );
        ttsVoice = mimoVoice.name;
      }

      // 获取 MIMO API Key
      ttsApiKey = await settingsService.getMimoApiKeyAsync();
      if (ttsApiKey == null || ttsApiKey.isEmpty) {
        debugPrint('[SpiritVoiceChat] ⚠️ MIMO API Key 未设置，TTS 将降级为系统语音');
        ttsProvider = 'system';
      }

      final isMobile = Platform.isAndroid || Platform.isIOS;
      final sessionState = ref.read(sessionStateProvider);
      final session = sessionState.activeSession;
      final modelId = session?.modelId ?? '';
      final isLocalModel = modelId.startsWith('local-') ||
          modelId.startsWith('ffi-') ||
          modelId.contains('gguf');
      if (isMobile && isLocalModel && ttsProvider == 'sherpa') {
        ttsProvider = 'system';
      }

      final ttsProviderEnum = switch (ttsProvider) {
        'sherpa' => TTSProvider.sherpa,
        'system' => TTSProvider.system,
        'openai' => TTSProvider.openai,
        'mimo' => TTSProvider.mimo,
        'edge' => TTSProvider.edge,
        'cosyvoice' => TTSProvider.cosyvoice,
        _ => TTSProvider.system,
      };

      // ★ 读取 Edge TTS 音色设置
      final edgeVoiceStr = prefs.getString('edge_voice') ?? 'xiaoxiao';
      final edgeVoice = EdgeVoice.values.firstWhere(
        (v) => v.name == edgeVoiceStr,
        orElse: () => EdgeVoice.xiaoxiao,
      );

      // ★ 读取 CosyVoice 设置
      final cvBaseUrl = prefs.getString('cosyvoice_base_url') ?? 'http://localhost:50000';
      final cvModeStr = prefs.getString('cosyvoice_mode') ?? 'cross_lingual';
      final cvInstructText = prefs.getString('cosyvoice_instruct_text') ?? '用自然的语气说话';
      final cvRefAudioPath = prefs.getString('cosyvoice_ref_audio_path') ?? '';
      final cvMode = CosyVoiceMode.values.firstWhere(
        (v) => v.name == cvModeStr,
        orElse: () => CosyVoiceMode.cross_lingual,
      );

      // ★ 修复：先释放旧的 TTS 服务实例，避免多实例冲突
      _ttsService?.dispose();
      _ttsService = TTSService(
        provider: ttsProviderEnum,
        apiKey: ttsApiKey,
        mimoVoice: mimoVoice,
        mimoVoiceId: effectiveVoiceId.startsWith('clone_') ? null : effectiveVoiceId, // ★ 修复：传入字符串音色 ID
        cloneReferenceAudioPath: ttsProvider == 'cosyvoice' && cvRefAudioPath.isNotEmpty ? cvRefAudioPath : cloneRefAudioPath,
        sherpaModelId: ttsModelId,
        speechRate: ttsSpeed,
        speakerId: int.tryParse(ttsVoice) ?? 0,
        cosyvoiceBaseUrl: ttsProvider == 'cosyvoice' ? cvBaseUrl : null,
        cosyvoiceMode: cvMode,
        cosyvoiceInstructText: cvInstructText,
        fishaudioBaseUrl: ttsProvider == 'fishaudio' ? prefs.getString('fishaudio_base_url') ?? 'http://localhost:50001' : null,
        fishaudioReferenceAudioPath: ttsProvider == 'fishaudio' ? prefs.getString('fishaudio_reference_audio_path') : null,
        fishaudioReferenceText: ttsProvider == 'fishaudio' ? prefs.getString('fishaudio_reference_text') : null,
      );

      // ★ 修复：先释放旧的 AudioPlayer，避免 iOS 上多实例 AVAudioSession 冲突
      await _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      _dialogueEngine = ref.read(dialogueEngineProvider);

      debugPrint(
          '[SpiritVoiceChat] 语音服务初始化完成: ASR=${asrProviderEnum.name}, TTS=${ttsProviderEnum.name}, cloneRef=${cloneRefAudioPath != null ? "有" : "无"}');

      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('[SpiritVoiceChat] 语音服务初始化失败: $e');
      debugPrint('[SpiritVoiceChat] $st');
      if (mounted) {
        setState(() {
          _errorMsg = '语音服务初始化失败: $e';
          _state = _VoiceState.error;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopRecording();
    _ttsService?.dispose();
    _audioPlayer?.dispose();
    _asrService?.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  //  UI 构建
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isInitializing) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_persona != null)
                Text(_persona!.avatarEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('正在唤醒名灵...'),
            ],
          ),
        ),
      );
    }

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
    final emoji = _persona?.avatarEmoji ?? '👻';
    final nickname = _persona?.nickname ?? '名灵';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                size: 20, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      nickname,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
              Icons.settings_outlined,
              size: 20,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            onPressed: _showConfigDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final emoji = _persona?.avatarEmoji ?? '👻';
    final nickname = _persona?.nickname ?? '名灵';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            '与 $nickname 对话',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '按住下方按钮说话',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '松手后 $nickname 自动回复并朗读',
            style: theme.textTheme.bodySmall?.copyWith(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI 说话时按住可打断',
            style: theme.textTheme.bodySmall?.copyWith(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
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
    final emoji = _persona?.avatarEmoji ?? '👻';
    final showTranslate = !isUser && msg.isMainlyEnglish;

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
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
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
                  bottomLeft:
                      isUser ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight:
                      isUser ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  // ★ 翻译区域
                  if (showTranslate) ...[
                    const SizedBox(height: 6),
                    if (msg.translatedText != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2A1A) : const Color(0xFFF0F7F0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.translate, size: 11, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text('中文翻译', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.translatedText!,
                              style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.85), height: 1.5),
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: () => _translateVoiceMessage(msg),
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.translate, size: 13, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                              const SizedBox(width: 3),
                              Text('翻译', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary.withValues(alpha: 0.7))),
                            ],
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(msg.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.35),
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
              child: Icon(Icons.person_rounded,
                  size: 16, color: theme.colorScheme.tertiary),
            ),
          ],
        ],
      ),
    );
  }

  /// ★ 翻译语音消息
  Future<void> _translateVoiceMessage(_VoiceMessage msg) async {
    try {
      final container = ProviderScope.containerOf(context);
      final engine = container.read(dialogueEngineProvider);
      final plainText = msg.text
          .replaceAll(RegExp(r'\[tts[^\]]*\]'), '')
          .replaceAll(RegExp(r'\[/tts\]'), '')
          .trim();
      final result = await engine.translateText(plainText, targetLang: '中文');
      if (mounted) {
        setState(() {
          msg.translatedText = result;
        });
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 翻译失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('翻译失败: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
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
          // 用户识别文本
          if (_userText.isNotEmpty &&
              (_state == _VoiceState.recognizing ||
                  _state == _VoiceState.thinking))
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
          // AI 思考文本
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
          // 错误信息
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
                    : _state == _VoiceState.speaking
                        ? '按住打断'
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
    final isProcessing =
        _state == _VoiceState.recognizing || _state == _VoiceState.thinking;
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
                  _buildRippleRing(80 + _pulseController.value * 20,
                      theme.colorScheme.error.withValues(alpha: 0.08)),
                  _buildRippleRing(80 + _pulseController.value * 40,
                      theme.colorScheme.error.withValues(alpha: 0.04)),
                ],
                if (isSpeaking) ...[
                  _buildRippleRing(80 + _pulseController.value * 20,
                      theme.colorScheme.secondary.withValues(alpha: 0.08)),
                  _buildRippleRing(80 + _pulseController.value * 40,
                      theme.colorScheme.secondary.withValues(alpha: 0.04)),
                ],
                if (isProcessing) ...[
                  _buildRippleRing(80 + _pulseController.value * 16,
                      theme.colorScheme.tertiary.withValues(alpha: 0.06)),
                ],
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isPressed ? 76 : 68,
                  height: _isPressed ? 76 : 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isCancelled
                        ? LinearGradient(
                            colors: [
                              Colors.grey.shade500,
                              Colors.grey.shade600
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : isActive
                            ? LinearGradient(
                                colors: [
                                  theme.colorScheme.error,
                                  theme.colorScheme.error
                                      .withValues(alpha: 0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : isSpeaking
                                ? LinearGradient(
                                    colors: [
                                      theme.colorScheme.secondary,
                                      theme.colorScheme.secondary
                                          .withValues(alpha: 0.8)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : isProcessing
                                    ? LinearGradient(
                                        colors: [
                                          theme.colorScheme.tertiary,
                                          theme.colorScheme.tertiary
                                              .withValues(alpha: 0.8)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.primary
                                              .withValues(alpha: 0.8)
                                        ],
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
                            .withValues(
                                alpha: isActive && !_isCancelled ? 0.4 : 0.2),
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

    // ★ 实时打断：AI 说话时按住即打断
    if (_state == _VoiceState.speaking) {
      _interruptTTS();
    }

    // ★★★ 如果 AI 正在思考/生成，打断当前回复，允许用户重新说话 ★★★
    if (_state == _VoiceState.thinking || _state == _VoiceState.recognizing) {
      debugPrint('[SpiritVoiceChat] ⚡ AI 正在生成，打断当前回复');
      if (_dialogueEngine != null) {
        _dialogueEngine!.cancelGeneration(_sessionId!);
      }
      _ttsInterrupted = true;
      _pulseController.stop();
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

    // ★★★ iOS/macOS AVAudioSession 恢复 ★★★
    // 取消录音时也需恢复，避免后续 TTS 无法播放
    if (Platform.isIOS || Platform.isMacOS) {
      AudioSession.instance.then((session) {
        session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
        ));
      }).catchError((_) {});
    }

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
      // ★ 修复：先释放旧的录音器实例，避免资源冲突
      await _recorder?.stop();
      _recorder?.dispose();
      _recorder = null;

      _recorder = AudioRecorder();

      // ★★★ iOS 关键修复：禁用 record 包内部的 AVAudioSession 管理 ★★★
      // record 包默认 manageAudioSession=true，会内部设置 AVAudioSession
      // 与外部 audio_session 包冲突，导致 iOS 崩溃
      if (Platform.isIOS || Platform.isMacOS) {
        try {
          await _recorder!.ios?.manageAudioSession(false);
          debugPrint('[SpiritVoiceChat] ✅ 已禁用 record 包内部 AVAudioSession 管理');
        } catch (e) {
          debugPrint('[SpiritVoiceChat] ⚠️ 禁用 manageAudioSession 失败: $e');
        }
      }

      final hasPermission = await _recorder!.hasPermission();
      if (!hasPermission) {
        _recorder?.dispose();
        _recorder = null;
        setState(() {
          _errorMsg = '麦克风权限被拒绝';
          _state = _VoiceState.error;
        });
        return;
      }

      // ★★★ iOS AVAudioSession 配置 ★★★
      if (Platform.isIOS || Platform.isMacOS) {
        try {
          final session = await AudioSession.instance;
          await session.configure(AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
            avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
            avAudioSessionMode: AVAudioSessionMode.measurement,
          ));
        } catch (_) {}
      }

      final dir = await getTemporaryDirectory();
      _tempAudioPath =
          '${dir.path}/spirit_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder!.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          // ★★★ iOS 关键修复：禁用 record 包内部 AVAudioSession 管理 ★★★
          iosConfig: IosRecordConfig(manageAudioSession: false),
        ),
        path: _tempAudioPath!,
      );
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 启动录音失败: $e');
      // ★ 修复：录音失败时清理录音器实例
      _recorder?.dispose();
      _recorder = null;
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

      // ★★★ iOS/macOS AVAudioSession 恢复 ★★★
      // 录音结束后恢复为播放模式，让 TTS 可以正常播放
      if (Platform.isIOS || Platform.isMacOS) {
        try {
          final session = await AudioSession.instance;
          await session.configure(AudioSessionConfiguration(
            avAudioSessionCategory: AVAudioSessionCategory.playback,
          ));
          debugPrint('[SpiritVoiceChat] ✅ AVAudioSession 恢复为 playback');
        } catch (e) {
          debugPrint('[SpiritVoiceChat] ⚠️ AVAudioSession 恢复失败: $e');
        }
      }

      if (_tempAudioPath != null && !_isDisposed) {
        await _recognizeAudio();
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 停止录音失败: $e');
    }
  }

  void _stopRecording() {
    _recorder?.stop();
    _recorder?.dispose();
    _recorder = null;
  }

  // ════════════════════════════════════════════════════════════════
  //  ASR 识别
  // ════════════════════════════════════════════════════════════════

  Future<void> _recognizeAudio() async {
    if (_tempAudioPath == null || _asrService == null) return;

    setState(() {
      _state = _VoiceState.recognizing;
      _statusText = '正在识别...';
    });

    try {
      String audioPath = _tempAudioPath!;

      // Sherpa 需要 wav 格式
      if (!audioPath.toLowerCase().endsWith('.wav') &&
          _asrService!.provider == ASRProvider.sherpa) {
        final dir = await getTemporaryDirectory();
        final wavPath =
            '${dir.path}/spirit_voice_converted_${DateTime.now().millisecondsSinceEpoch}.wav';
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
      debugPrint('[SpiritVoiceChat] 识别失败: $e');
      setState(() {
        _errorMsg = '识别失败: $e';
        _state = _VoiceState.error;
      });
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  LLM 推理（流式）
  // ════════════════════════════════════════════════════════════════

  Future<void> _processWithLLM(String text) async {
    _ttsInterrupted = false;

    setState(() {
      _state = _VoiceState.thinking;
      _statusText = '正在思考...';
      _aiText = '';
    });

    _pulseController.repeat();

    try {
      if (_dialogueEngine != null && _sessionId != null) {
        debugPrint(
            '[SpiritVoiceChat] 开始流式推理: sessionId=$_sessionId, spiritId=${widget.spiritId}');
        final responseStream = _dialogueEngine!.streamResponse(
          _sessionId!,
          text,
        );

        String fullResponse = '';
        int chunkCount = 0;
        await for (final chunk in responseStream) {
          chunkCount++;
          if (_isDisposed) break;
          if (!chunk.isComplete) {
            fullResponse += chunk.content;
          } else {
            fullResponse = chunk.content;
          }
          if (mounted) {
            setState(() {
              _aiText = fullResponse;
            });
          }
        }

        debugPrint(
            '[SpiritVoiceChat] 流式推理完成: chunkCount=$chunkCount, len=${fullResponse.length}, interrupted=$_ttsInterrupted');

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
          // 响应为空或被打断，恢复 idle
          debugPrint('[SpiritVoiceChat] 跳过TTS，恢复 idle');
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
      debugPrint('[SpiritVoiceChat] LLM 处理失败: $e');
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

  // ════════════════════════════════════════════════════════════════
  //  TTS 语音合成 + 播放 + 打断
  // ════════════════════════════════════════════════════════════════

  Future<void> _speakResponse(String text) async {
    if (_ttsService == null || _isDisposed) {
      _onTTSComplete();
      return;
    }

    // ★★★ iOS/macOS: 确保 AVAudioSession 为播放模式 ★★★
    // 录音结束后虽然恢复了 playback，但某些情况下可能被重置
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
        ));
        debugPrint('[SpiritVoiceChat] ✅ AVAudioSession 已配置为 playback');
      } catch (e) {
        debugPrint('[SpiritVoiceChat] ⚠️ AVAudioSession 配置失败: $e');
      }
    }

    setState(() {
      _state = _VoiceState.speaking;
      // ★ 修复：克隆音色合成较慢，提示用户等待
      final isClone = _ttsService?.isCloneMode ?? false;
      _statusText = isClone ? '正在合成克隆音色...' : '正在回复...';
      _ttsInterrupted = false;
    });

    _pulseController.repeat();

    try {
      debugPrint('[SpiritVoiceChat] 开始TTS合成 (speakLongText)');
      // ★ 使用 speakLongText 分句流式合成，避免长文本单次请求超时
      // VoiceClone 模式下单次请求可能超过60秒，分句后每块约50-100字，2-10秒即可完成
      final completed = await _ttsService!.speakLongText(text);
      
      if (_isDisposed) {
        _onTTSComplete();
        return;
      }
      if (_ttsInterrupted || !completed) {
        return;
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] TTS 播放失败: $e');
      // ★ 修复：TTS 失败时通知用户，而不是静默失败
      if (mounted && !_isDisposed) {
        setState(() {
          _errorMsg = '语音播放失败: $e';
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isDisposed) {
            setState(() => _errorMsg = null);
          }
        });
      }
    }

    if (!_isDisposed && _state != _VoiceState.idle) {
      _onTTSComplete();
    }
  }

  /// 等待音频播放完成或被打断
  Future<void> _waitForPlaybackComplete() async {
    const maxWait = Duration(minutes: 3);
    final startTime = DateTime.now();

    final completer = Completer<void>();
    StreamSubscription? subscription;

    subscription = _audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed &&
          !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      while (!completer.isCompleted && !_isDisposed && !_ttsInterrupted) {
        if (DateTime.now().difference(startTime) > maxWait) {
          debugPrint('[SpiritVoiceChat] TTS 播放超过 3 分钟，强制结束');
          break;
        }

        try {
          await completer.future.timeout(const Duration(milliseconds: 100));
          break;
        } on TimeoutException {
          continue;
        }
      }
    } finally {
      await subscription.cancel();
      try {
        await _audioPlayer?.stop();
      } catch (_) {}
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

  /// ★ 实时打断：AI 说话时按住按钮立即打断
  void _interruptTTS() {
    _ttsInterrupted = true;
    _ttsService?.stop(); // ★ 修复：停止 TTS 合成和播放，防止合成完成后又自动播放
    _audioPlayer?.stop();
    _pulseController.stop();

    HapticFeedback.mediumImpact();

    setState(() {
      _state = _VoiceState.idle;
      _statusText = '按住说话';
      _userText = '';
      _aiText = '';
    });

    debugPrint('[SpiritVoiceChat] TTS 已被打断');
  }

  // ════════════════════════════════════════════════════════════════
  //  工具方法
  // ════════════════════════════════════════════════════════════════

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

  /// 显示配置对话框：切换模型和音色
  void _showConfigDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final modelState = ref.read(modelProvider);
    final localModels = modelState.localModels;
    final remoteModels = modelState.remoteModels;

    // 当前使用的模型
    final sessionState = ref.read(sessionStateProvider);
    final currentModelId = sessionState.activeSession?.modelId ?? widget.modelId;

    // ★ 当前使用的音色：优先使用 lastUsedVoiceId（包含 clone_ 前缀）
    String currentVoiceId = _persona?.lastUsedVoiceId ?? 'Chloe';
    // 如果 lastUsedVoiceId 为空但有克隆音色，使用克隆音色
    if (currentVoiceId == 'Chloe' && _persona?.clonedVoiceId != null && _persona!.clonedVoiceId!.isNotEmpty) {
      currentVoiceId = 'clone_${_persona!.clonedVoiceId}';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedModelId = currentModelId;
        String selectedVoiceId = currentVoiceId;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // 构建模型选项
            final modelItems = <DropdownMenuItem<String>>[];
            for (final model in localModels) {
              modelItems.add(DropdownMenuItem(
                value: model.id,
                child: Row(
                  children: [
                    Icon(Icons.computer_rounded, size: 16, color: model.isLoaded ? Colors.green : Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(model.displayName, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ));
            }
            for (final model in remoteModels) {
              modelItems.add(DropdownMenuItem(
                value: model.id,
                child: Row(
                  children: [
                    Icon(Icons.cloud_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(model.displayName, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ));
            }

            // ★ 构建音色选项：所有克隆音色 + MIMO 预设音色
            final voiceItems = <DropdownMenuItem<String>>[];
            // 克隆音色分组
            final readyClones = _clonedVoices.where((v) => v.isReady).toList();
            if (readyClones.isNotEmpty) {
              for (final clone in readyClones) {
                voiceItems.add(DropdownMenuItem(
                  value: 'clone_${clone.id}',
                  child: Row(
                    children: [
                      const Icon(Icons.record_voice_over, size: 16, color: Colors.purple),
                      const SizedBox(width: 8),
                      Expanded(child: Text(clone.name, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('克隆', style: TextStyle(fontSize: 9, color: Colors.purple)),
                      ),
                    ],
                  ),
                ));
              }
            }
            // MIMO 预设音色分组
            const mimoVoiceDesc = {
              'Chloe': '默认女声',
              'mimo_default': '默认音色 V2',
              'default_zh': '中文女声',
              'default_en': '英文女声',
            };
            for (final voice in MiMoVoice.values) {
              final desc = mimoVoiceDesc[voice.name] ?? voice.name;
              voiceItems.add(DropdownMenuItem(
                value: voice.name,
                child: Row(
                  children: [
                    Icon(Icons.record_voice_over, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(voice.name)),
                    const SizedBox(width: 6),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ));
            }

            return AlertDialog(
              title: const Text('对话配置'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 模型选择
                  Text('对话模型', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: modelItems.any((i) => i.value == selectedModelId) ? selectedModelId : null,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Text('选择模型'),
                      items: modelItems,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedModelId = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 音色选择
                  Text('对话音色', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: voiceItems.any((i) => i.value == selectedVoiceId) ? selectedVoiceId : null,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Text('选择音色'),
                      items: voiceItems,
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedVoiceId = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ★ 清除上下文按钮（放在 content 中，避免 actions 中 Spacer 导致大色块）
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await _clearContext();
                      },
                      icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                      label: Text('清除上下文', style: TextStyle(color: theme.colorScheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await _applyConfig(selectedModelId, selectedVoiceId);
                  },
                  child: const Text('应用'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// ★ 清除上下文
  Future<void> _clearContext() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清除上下文'),
        content: const Text('确定要清除所有对话记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final manager = ref.read(sessionManagerProvider);
      if (_sessionId != null) {
        await manager.clearMessages(_sessionId!);
        // 清空本地消息列表
        setState(() {
          _messages.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('上下文已清除'), duration: Duration(seconds: 1)),
          );
        }
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 清除上下文失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清除失败: $e')),
        );
      }
    }
  }

  /// 应用配置变更
  Future<void> _applyConfig(String modelId, String voiceId) async {
    try {
      // 1. 更新 persona 保存的选择
      if (_persona != null) {
        final repo = ref.read(spiritRepositoryProvider);
        await repo.updatePersona(_persona!.copyWith(
          lastUsedModelId: modelId,
          lastUsedVoiceId: voiceId,
        ));
      }

      // 2. 更新会话模型
      if (_sessionId != null && modelId.isNotEmpty) {
        final sessionRepo = SessionRepository();
        await sessionRepo.updateSession(id: _sessionId!, modelId: modelId);
      }

      // 3. 重新初始化 TTS 服务（音色变更）
      if (_persona != null) {
        // 更新 persona 的音色信息
        final updatedPersona = _persona!.copyWith(
          lastUsedModelId: modelId,
          lastUsedVoiceId: voiceId,
        );
        _persona = updatedPersona;

        // 重新初始化 TTS
        await _initVoiceServices(updatedPersona);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('配置已更新'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      debugPrint('[SpiritVoiceChat] 应用配置失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('配置更新失败: $e')),
        );
      }
    }
  }
}

/// 语音消息数据
class _VoiceMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  String? translatedText; // ★ 翻译结果

  _VoiceMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.translatedText,
  });

  /// 检测文本是否主要为英文
  bool get isMainlyEnglish {
    final cleaned = text.replaceAll(RegExp(r'[\s\d\p{P}]', unicode: true), '');
    if (cleaned.isEmpty) return false;
    final englishChars = RegExp(r'[a-zA-Z]').allMatches(cleaned).length;
    final chineseChars = RegExp(r'[\u4e00-\u9fff]').allMatches(cleaned).length;
    return englishChars > chineseChars * 2 && englishChars > 10;
  }
}
