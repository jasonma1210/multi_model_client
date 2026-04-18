import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/interfaces/session_interface.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/knowledge_base_service.dart';
import '../../../../core/services/file_parser_service.dart';
import '../../../../core/services/asr_service.dart';
import '../../../../core/services/voice_dialog_engine.dart';
import '../../../../core/services/asr_input_service.dart';
import '../../../../core/storage/database.dart';
import '../../../../core/storage/database_connection.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/session_manager.dart';
import '../../domain/dialogue_engine.dart';
import '../widgets/feature_toggle_button.dart';
import '../../../skill/domain/skill.dart';
import '../../../skill/domain/skill_dispatcher.dart';
import '../../../skill/domain/native_skills/native_skills.dart';

class SessionDetailPage extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailPage({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}


/// 工具按钮（图标）
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _ToolButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// 语音对话脉冲动画
class _VoicePulseAnimation extends StatefulWidget {
  final Color color;
  
  const _VoicePulseAnimation({required this.color});
  
  @override
  State<_VoicePulseAnimation> createState() => _VoicePulseAnimationState();
}

class _VoicePulseAnimationState extends State<_VoicePulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 1.0 - (_animation.value - 1.0) * 2),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

/// 操作按钮（发送/停止）
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor ?? Colors.white,
        ),
      ),
    );
  }
}

class _SessionDetailPageState extends ConsumerState<SessionDetailPage>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late AnimationController _sendButtonController;
  bool _isGenerating = false;
  /// 流式生成中的实时文本（用于在完整保存前实时显示）
  String _streamingText = '';
  bool _hasSwitchedSession = false;
  // 会话功能开关状态
  bool _webSearchEnabled = false;
  bool _cameraEnabled = false;
  
  // ============ 语音对话相关状态 ============
  /// 语音对话引擎
  VoiceDialogEngine? _voiceDialogEngine;
  /// 当前语音对话状态
  VoiceDialogState _voiceDialogState = VoiceDialogState.idle;
  /// 语音对话状态订阅
  StreamSubscription<VoiceDialogState>? _voiceStateSubscription;
  /// 语音对话识别文本（实时显示）
  String _voiceRecognizedText = '';

  // ============ 微信风格语音录入相关状态 ============
  /// 微信风格语音录入服务
  AsrInputService? _asrInputService;
  /// 是否正在录音（微信按住说话）
  bool _isVoiceRecording = false;
  /// 实时音量（0.0~1.0）
  double _voiceAmplitude = 0.0;
  /// 是否正在识别
  bool _isVoiceRecognizing = false;
  /// 语音录入滑动偏移（用于取消）
  double _voiceDragOffset = 0.0;
  /// 是否处于语音输入模式（true=显示按住说话按钮，false=显示文本输入框）
  bool _isVoiceMode = false;
  /// 语音录入订阅
  StreamSubscription<double>? _voiceAmplitudeSub;
  StreamSubscription<String>? _voiceResultSub;
  StreamSubscription<String>? _voiceErrorSub;

  // ============ 流式响应优化 ============
  /// 滚动节流标记（避免帧时间回退）
  bool _isScrollingToBottom = false;
  /// 最后滚动时间戳（用于节流）
  DateTime _lastScrollTime = DateTime.now();
  
  // 网络搜索模式
  WebSearchMode _currentSearchMode = WebSearchMode.tavily;
  String _tavilyApiKey = '';
  String _duckduckgoApiKey = '';
  // 已选择的图片列表（用于多模态）
  List<XFile> _selectedImages = [];
  // 已选择的文件列表
  List<XFile> _selectedFiles = [];
  
  // 推理统计信息
  int? _currentTokenCount;
  double? _currentTokensPerSecond;
  
  // Skill 相关状态
  final SkillDispatcher _skillDispatcher = SkillDispatcher();
  String? _activeExpertId; // 当前激活的专家
  String? _activeKnowledgeBaseId; // 当前关联的知识库 ID
  List<KnowledgeBase> _knowledgeBases = []; // 可用的知识库列表
  
  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 加载搜索配置（异步）
    _loadSearchConfig();
    
    // 加载知识库列表
    _loadKnowledgeBases();
    
    // 初始化语音对话引擎
    _initVoiceDialogEngine();
    
    // 监听消息列表变化，自动滚动到底部
    _scrollController.addListener(_onScroll);
  }
  
  /// 初始化语音对话引擎
  Future<void> _initVoiceDialogEngine() async {
    // 创建语音对话配置
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.initialize();
    
    final asrProvider = settingsService.getAsrProvider();
    final ttsProvider = settingsService.getTtsProvider();
    
    // 从 SharedPreferences 读取选中的 Sherpa 模型 ID
    final prefs = await SharedPreferences.getInstance();
    final selectedAsrModelId = prefs.getString('selected_asr_model_id') ?? 'sensevoice-int8';
    final selectedTtsModelId = prefs.getString('selected_tts_model_id') ?? 'melo-zh-en';
    final ttsVoiceId = prefs.getString('tts_voice_id') ?? '0';
    final speakerId = int.tryParse(ttsVoiceId) ?? 0;
    
    // 获取会话状态获取模型信息
    final sessionState = ref.read(sessionStateProvider);
    final modelId = sessionState.activeSession?.modelId ?? 'default';
    
    // 创建 ASR 和 TTS 服务
    ASRService? asrService;
    TTSService? ttsService;
    
    // 初始化 ASR 服务
    if (asrProvider == 'openai' || asrProvider == 'sherpa') {
      final apiKey = settingsService.getTavilyApiKey();
      asrService = ASRService(
        provider: asrProvider == 'openai' ? ASRProvider.openai : ASRProvider.sherpa,
        apiKey: apiKey,
        sherpaModelId: asrProvider == 'sherpa' ? selectedAsrModelId : null,
      );
      // 初始化微信风格语音录入服务
      _asrInputService = AsrInputService(asrService);
      _initAsrInputSubscriptions();
    }
    
    // 初始化 TTS 服务
    if (ttsProvider == 'openai' || ttsProvider == 'sherpa' || ttsProvider == 'system') {
      final apiKey = ttsProvider == 'openai' ? settingsService.getTavilyApiKey() : null;
      final ttsProviderEnum = switch (ttsProvider) {
        'openai' => TTSProvider.openai,
        'sherpa' => TTSProvider.sherpa,
        'system' => TTSProvider.system,
        _ => TTSProvider.sherpa,
      };
      
      // 读取语速设置
      final systemTtsSpeed = prefs.getDouble('system_tts_speed') ?? 0.5;
      
      ttsService = TTSService(
        provider: ttsProviderEnum,
        apiKey: apiKey,
        sherpaModelId: ttsProvider == 'sherpa' ? selectedTtsModelId : null,
        speakerId: speakerId,
        speechRate: ttsProvider == 'system' ? systemTtsSpeed : 1.0,
      );
    }
    
    // 创建语音对话引擎
    _voiceDialogEngine = VoiceDialogEngine(
      ref,
      VoiceDialogConfig(
        asrService: asrService,
        ttsService: ttsService,
        modelId: modelId,
        asrLanguage: 'zh',
        enableInterrupt: true,
        autoPlay: true,
      ),
    );
    
    // 订阅状态变化
    _voiceStateSubscription = _voiceDialogEngine!.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _voiceDialogState = state;
        });
        
        // 当识别完成时，将文本填入输入框
        if (state == VoiceDialogState.thinking && 
            _voiceDialogEngine!.lastRecognizedText != null) {
          _voiceRecognizedText = _voiceDialogEngine!.lastRecognizedText!;
        }
        
        // 当说话完成后，重新开始聆听
        if (state == VoiceDialogState.idle && 
            _voiceRecognizedText.isNotEmpty) {
          _voiceRecognizedText = '';
        }
      }
    });
  }

  /// 初始化微信语音录入订阅
  void _initAsrInputSubscriptions() {
    _voiceAmplitudeSub?.cancel();
    _voiceResultSub?.cancel();
    _voiceErrorSub?.cancel();

    _voiceAmplitudeSub = _asrInputService?.amplitudeStream.listen((amp) {
      if (mounted) setState(() => _voiceAmplitude = amp);
    });

    _voiceResultSub = _asrInputService?.resultStream.listen((text) {
      if (mounted) {
        setState(() {
          _isVoiceRecognizing = false;
          _isVoiceRecording = false;
          _voiceAmplitude = 0.0;
        });
        // 填入输入框
        _messageController.text = text;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
        // 震动反馈
        HapticFeedback.lightImpact();
      }
    });

    _voiceErrorSub = _asrInputService?.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _isVoiceRecognizing = false;
          _isVoiceRecording = false;
          _voiceAmplitude = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), duration: const Duration(milliseconds: 1500)),
        );
      }
    });
  }

  /// 按住说话开始
  Future<void> _onVoiceRecordStart() async {
    if (_asrInputService == null || _isVoiceRecording) return;
    
    // 如果正在识别，打断它
    if (_isVoiceRecognizing) {
      _isVoiceRecognizing = false;
    }
    
    // 停止 TTS 播放
    try {
      final ttsProvider = ref.read(ttsServiceProvider);
      await ttsProvider.stop();
    } catch (_) {}
    
    setState(() => _isVoiceRecording = true);
    await _asrInputService!.startRecording();
  }

  /// 松开说话结束
  Future<void> _onVoiceRecordEnd(bool cancelled) async {
    if (!_isVoiceRecording || _asrInputService == null) return;
    setState(() {
      _isVoiceRecording = false;
      _isVoiceRecognizing = true;
      _voiceAmplitude = 0.0;
    });
    await _asrInputService!.stopRecording(cancelled: cancelled);
  }

  /// 加载知识库列表
  Future<void> _loadKnowledgeBases() async {
    try {
      final db = ref.read(databaseProvider);
      final service = KnowledgeBaseService(db);
      final kbs = await service.getAllKnowledgeBases();
      if (mounted) {
        setState(() {
          _knowledgeBases = kbs;
        });
      }
      
      // 加载当前会话关联的知识库
      final sessionManager = ref.read(sessionManagerProvider);
      final activeSession = sessionManager.currentState.activeSession;
      if (activeSession != null && activeSession.enabledKnowledgeBaseId != null) {
        setState(() {
          _activeKnowledgeBaseId = activeSession.enabledKnowledgeBaseId;
        });
      }
    } catch (e) {
      debugPrint('加载知识库失败: $e');
    }
  }
  
  /// 滚动监听器 - 保持滚动到底部
  void _onScroll() {
    // 如果用户手动滚动到顶部，允许查看历史消息
    // 否则自动滚动到底部
  }
  
  /// 滚动到聊天底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  /// 加载搜索配置
  Future<void> _loadSearchConfig() async {
    final settingsService = ref.read(settingsServiceProvider);
    
    // 确保 SettingsService 已初始化
    await settingsService.initialize();
    
    if (!mounted) return;
    
    final searchMode = settingsService.getSearchMode();
    final tavilyApiKey = settingsService.getTavilyApiKey();
    final webSearchEnabled = settingsService.getWebSearchEnabled();
    
    if (mounted) {
      setState(() {
        _currentSearchMode = WebSearchMode.values[searchMode.index];
        _tavilyApiKey = tavilyApiKey ?? '';
        _webSearchEnabled = webSearchEnabled;
      });
    }
    
    // 同步到 DialogueEngine
    final engine = ref.read(dialogueEngineProvider);
    engine.setWebSearchMode(_currentSearchMode);
    if (tavilyApiKey != null) {
      engine.setTavilyApiKey(tavilyApiKey);
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    // 清理语音对话引擎
    _voiceStateSubscription?.cancel();
    _voiceDialogEngine?.dispose();
    // 清理微信语音录入
    _voiceAmplitudeSub?.cancel();
    _voiceResultSub?.cancel();
    _voiceErrorSub?.cancel();
    _asrInputService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // sessionStateProvider 现在是 StateNotifierProvider，直接拿 SessionState，无 AsyncValue
    final sessionState = ref.watch(sessionStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // 如果还没有切换到当前会话，先切换
    if (!_hasSwitchedSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          final sessionManager = ref.read(sessionManagerProvider);
          final currentState = sessionManager.currentState;

          // 如果当前活跃会话不是我们要的，切换
          if (currentState.activeSession?.id != widget.sessionId) {
            await sessionManager.switchSession(widget.sessionId);
          }
          
          // 等待状态更新后再读取
          await Future.delayed(const Duration(milliseconds: 100));
          
          // 加载之前选中的技能
          final activeSession = sessionManager.currentState.activeSession;
          if (activeSession != null && activeSession.enabledSkill != null) {
            setState(() {
              _activeExpertId = activeSession.enabledSkill;
            });
          }
          
          if (mounted) setState(() => _hasSwitchedSession = true);
          
          // 切换会话后，滚动到底部显示最新消息
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        } catch (e) {
          debugPrint('切换会话失败: $e');
          if (mounted) setState(() => _hasSwitchedSession = true);
        }
      });
    }

    return Scaffold(
      appBar: _buildAppBar(sessionState, theme, l10n),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: sessionState.error != null
                ? _buildErrorState(sessionState.error!, StackTrace.empty, l10n)
                : sessionState.isLoading && sessionState.activeSession == null
                    ? _buildLoadingState(l10n)
                    : _buildMessagesList(sessionState, theme, l10n),
          ),

          // Input area
          _buildInputArea(context, theme, l10n),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SessionState sessionState, ThemeData theme, AppLocalizations l10n) {
    final session = sessionState.activeSession;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/');
          }
        },
        tooltip: '返回',
      ),
      title: session == null && sessionState.isLoading
          ? Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(l10n.loading, style: theme.textTheme.titleMedium),
              ],
            )
          : Row(
              children: [
                AppTheme.buildModelAvatar(
                  modelId: session?.modelId ?? 'default',
                  size: 36,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session?.name ?? l10n.sessions,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          AppTheme.buildStatusIndicator(
                            isActive: !_isGenerating,
                            size: 6,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            _isGenerating ? l10n.generating : session?.modelId ?? 'Unknown',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        // 语音播报按钮
        _buildVoiceOutputButton(context, sessionState),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () => _exportSession(),
          tooltip: l10n.exportSession,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleSessionOption(value, l10n),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.rename),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'change_model',
              child: ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text(l10n.changeModel),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'edit_system_prompt',
              child: ListTile(
                leading: const Icon(Icons.psychology_outlined),
                title: const Text('修改人设'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: ListTile(
                leading: const Icon(Icons.clear_all),
                title: Text(l10n.clearMessages),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建语音播报按钮
  Widget _buildVoiceOutputButton(BuildContext context, SessionState sessionState) {
    return Consumer(
      builder: (context, ref, child) {
        // 从 Provider 获取当前会话的语音播报状态
        final isVoiceEnabled = sessionState.activeSession?.enableVoiceOutput ?? false;

        return Tooltip(
          message: isVoiceEnabled ? '关闭语音播报' : '开启语音播报',
          child: IconButton(
            icon: Icon(
              isVoiceEnabled ? Icons.volume_up : Icons.volume_up_outlined,
              color: isVoiceEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => _toggleVoiceOutput(sessionState),
          ),
        );
      },
    );
  }

  /// 切换语音播报状态
  Future<void> _toggleVoiceOutput(SessionState sessionState) async {
    if (sessionState.activeSession == null) return;

    final session = sessionState.activeSession!;
    final newEnabled = !session.enableVoiceOutput;

    // 更新会话状态
    final sessionManager = ref.read(sessionManagerProvider);
    await sessionManager.updateSessionVoiceOutput(
      session.id,
      newEnabled,
    );

    // 如果开启语音播报，检查 TTS 是否已配置
    if (newEnabled) {
      await _checkAndPromptTTSConfiguration();
    }

    setState(() {});
  }

  /// 检查 TTS 配置并提示用户
  Future<void> _checkAndPromptTTSConfiguration() async {
    if (!mounted) return;

    // 检查 TTS 配置状态
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.initialize();
    
    final ttsProvider = settingsService.getTtsProvider();
    
    // 检查是否需要配置
    bool needsConfig = false;
    String message = '';
    
    // OpenAI TTS 需要 API Key
    if (ttsProvider == 'openai') {
      final apiKey = settingsService.getTavilyApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        needsConfig = true;
        message = '您选择了 OpenAI TTS，需要配置 API Key。\n\n'
            '请先在设置中输入您的 API Key（用于 TTS）。';
      }
    }
    
    if (needsConfig) {
      // 显示配置提示对话框
      _showTTSConfigRequiredDialog(message);
    } else {
      // 已配置，显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 语音播报已开启'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  /// 显示 TTS 配置缺失对话框
  void _showTTSConfigRequiredDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('需要配置 TTS'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后再说'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // 跳转到语音设置页面
              context.push('/settings/voice');
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 显示 TTS 设置引导对话框
  void _showTTSSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.record_voice_over, color: Colors.blue),
            SizedBox(width: 8),
            Text('语音播报设置'),
          ],
        ),
        content: const Text(
          '您已开启语音播报功能。\n\n'
          '请先在设置中选择 TTS 提供商并配置相关参数，以便 AI 回复时自动播放语音。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后再说'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // 跳转到语音设置页面
              context.push('/settings/voice');
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            l10n.loadingMessages,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, StackTrace stack, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.failedToLoadMessages,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton.icon(
              onPressed: () async {
                // 重新切换会话以刷新状态
                try {
                  final sessionManager = ref.read(sessionManagerProvider);
                  await sessionManager.switchSession(widget.sessionId);
                } catch (e) {
                  debugPrint('重试切换会话失败: $e');
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(SessionState state, ThemeData theme, AppLocalizations l10n) {
    final messages = state.messages;

    if (messages.isEmpty && !_isGenerating) {
      return _buildEmptyState(theme, l10n);
    }

    return Column(
      children: [
        // 语音对话状态条（当有语音对话活动时显示）
        if (_voiceDialogState != VoiceDialogState.idle)
          _buildVoiceDialogStatusBar(theme),
        
        // 消息列表
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingM),
            itemCount: messages.length + (_isGenerating ? 1 : 0),
            itemBuilder: (context, index) {
              // 最后一项：显示实时流式内容（优先显示流式文本，无则显示打字指示器）
              if (index == messages.length && _isGenerating) {
                return _buildStreamingBubble(theme, state.activeSession?.modelId ?? 'default');
              }

              final message = messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: _MessageBubble(
                  message: message,
                  modelId: state.activeSession?.modelId ?? 'default',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// 构建语音对话状态条
  Widget _buildVoiceDialogStatusBar(ThemeData theme) {
    // 根据状态获取颜色和描述
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (_voiceDialogState) {
      case VoiceDialogState.listening:
        statusColor = Colors.red;
        statusIcon = Icons.mic;
        statusText = '正在聆听，请说话...';
        break;
      case VoiceDialogState.recognizing:
        statusColor = Colors.orange;
        statusIcon = Icons.hearing;
        statusText = '正在识别...';
        break;
      case VoiceDialogState.thinking:
        statusColor = Colors.blue;
        statusIcon = Icons.psychology;
        statusText = '正在思考...';
        break;
      case VoiceDialogState.speaking:
        statusColor = Colors.green;
        statusIcon = Icons.volume_up;
        statusText = '正在说话...';
        break;
      case VoiceDialogState.interrupted:
        statusColor = Colors.grey;
        statusIcon = Icons.pause;
        statusText = '对话已中断';
        break;
      case VoiceDialogState.error:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusText = '语音对话出错';
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // 状态图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 18,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          // 状态文本
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                // 如果有识别文本，显示它
                if (_voiceRecognizedText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '"$_voiceRecognizedText"',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // 停止按钮
          IconButton(
            icon: Icon(Icons.close, color: statusColor),
            onPressed: () => _toggleVoiceDialog(),
            tooltip: '停止语音对话',
            iconSize: 20,
          ),
        ],
      ),
    );
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(milliseconds: 1500)),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              l10n.startConversationTitle,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              l10n.sendMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 流式回复气泡：实时显示生成中的文本，无文本时显示打字指示器
  Widget _buildStreamingBubble(ThemeData theme, String modelId) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildModelAvatar(
            modelId: modelId,
            size: 36,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 实时文本内容（Markdown 渲染）
                  if (_streamingText.isNotEmpty)
                    MarkdownBody(
                      data: _streamingText,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15, height: 1.5),
                        code: TextStyle(
                          color: theme.colorScheme.onSurface,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  // 打字指示器（当无实时文本时显示）
                  if (_streamingText.isEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 200)),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  // 实时速度显示
                  if (_currentTokenCount != null || _currentTokensPerSecond != null) ...[
                    const SizedBox(height: 8),
                    _buildStreamingStatsBadge(theme),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建流式统计徽章
  Widget _buildStreamingStatsBadge(ThemeData theme) {
    final parts = <String>[];
    if (_currentTokenCount != null) {
      parts.add('$_currentTokenCount tokens');
    }
    if (_currentTokensPerSecond != null) {
      parts.add('${_currentTokensPerSecond!.toStringAsFixed(1)} tok/s');
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          parts.join(' • '),
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  
  /// 构建语音对话按钮
  Widget _buildVoiceDialogButton(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _voiceDialogState != VoiceDialogState.idle;
    
    // 根据状态返回不同的图标
    IconData icon;
    Color iconColor;
    Color bgColor;
    
    switch (_voiceDialogState) {
      case VoiceDialogState.listening:
      case VoiceDialogState.recognizing:
        icon = Icons.mic;
        bgColor = Colors.red;
        iconColor = Colors.white;
        break;
      case VoiceDialogState.thinking:
        icon = Icons.psychology;
        bgColor = Colors.orange;
        iconColor = Colors.white;
        break;
      case VoiceDialogState.speaking:
        icon = Icons.volume_up;
        bgColor = Colors.blue;
        iconColor = Colors.white;
        break;
      default:
        icon = Icons.mic_none;
        bgColor = isActive ? theme.colorScheme.primaryContainer : Colors.transparent;
        iconColor = isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    }
    
    return Tooltip(
      message: _getVoiceDialogTooltip(),
      child: GestureDetector(
        onTap: () => _toggleVoiceDialog(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
              // 语音对话激活时添加脉冲动画效果
              if (_voiceDialogState == VoiceDialogState.listening ||
                  _voiceDialogState == VoiceDialogState.speaking)
                Positioned.fill(
                  child: _VoicePulseAnimation(
                    color: bgColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 获取语音对话按钮的提示文本
  String _getVoiceDialogTooltip() {
    switch (_voiceDialogState) {
      case VoiceDialogState.idle:
        return '开始语音对话';
      case VoiceDialogState.listening:
        return '正在聆听...';
      case VoiceDialogState.recognizing:
        return '正在识别...';
      case VoiceDialogState.thinking:
        return '正在思考...';
      case VoiceDialogState.speaking:
        return '正在说话...';
      case VoiceDialogState.interrupted:
        return '被打断';
      case VoiceDialogState.error:
        return '语音对话错误';
    }
  }

  /// 构建微信风格语音录入按钮
  /// - 按住说话，松开识别
  /// - 上滑取消
  Widget _buildVoiceInputButton(ThemeData theme) {
    return SizedBox(
      width: 44,
      height: 44,
      child: GestureDetector(
        onPanStart: (_) => _onVoiceRecordStart(),
        onPanUpdate: (details) {
          if (!_isVoiceRecording) return;
          setState(() {
            _voiceDragOffset = details.localPosition.dy;
          });
          // 超过阈值震动提示
          if (_voiceDragOffset < -60) {
            HapticFeedback.lightImpact();
          }
        },
        onPanEnd: (_) {
          if (!_isVoiceRecording) return;
          final cancelled = _voiceDragOffset < -60;
          _voiceDragOffset = 0;
          _onVoiceRecordEnd(cancelled);
        },
        onTap: () {
          // 如果没初始化，显示提示
          if (_asrInputService == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请先在设置中配置并下载语音模型'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: _VoiceInputButtonContent(
          isRecording: _isVoiceRecording,
          isRecognizing: _isVoiceRecognizing,
          amplitude: _voiceAmplitude,
          isCancelling: _isVoiceRecording && _voiceDragOffset < -60,
          theme: theme,
        ),
      ),
    );
  }

  /// 切换语音/键盘模式按钮
  Widget _VoiceModeToggleButton({
    required bool isVoiceRecording,
    required bool isVoiceRecognizing,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    if (isVoiceRecording || isVoiceRecognizing) {
      // 录音中显示转圈
      return SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.red.shade400),
        ),
      );
    }
    // 正常显示键盘图标
    return Tooltip(
      message: '按住麦克风键说话',
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.keyboard,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
  
  /// 切换语音对话状态
  Future<void> _toggleVoiceDialog() async {
    if (_voiceDialogEngine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('语音对话引擎未初始化'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    try {
      if (_voiceDialogState == VoiceDialogState.idle) {
        // 开始语音对话
        await _voiceDialogEngine!.startDialog(widget.sessionId);
      } else {
        // 停止语音对话
        await _voiceDialogEngine!.stopDialog();
      }
    } catch (e) {
      debugPrint('语音对话切换失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('语音对话失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSkillBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final allSkills = _skillDispatcher.getAllSkills();
    final toolSkills = allSkills.where((s) => s.type == SkillType.native).toList();
    final expertSkills = allSkills.where((s) => s.type == SkillType.expert).toList();
    
    // 按领域分组
    final domainGroups = <String, List<Skill>>{};
    for (final skill in expertSkills) {
      final domain = skill.domain ?? skill.category ?? '其他';
      domainGroups.putIfAbsent(domain, () => []).add(skill);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('技能中心', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text('管理'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/settings/skills');
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // 当前激活的专家
                  if (_activeExpertId != null) ...[
                    _buildActiveExpertBanner(theme),
                    const SizedBox(height: 16),
                  ],
                  
                  // 工具技能
                  Text('🧰 工具技能', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: toolSkills.map((skill) => ActionChip(
                      avatar: Icon(_getSkillIcon(skill.icon), size: 16),
                      label: Text(skill.name),
                      onPressed: () {
                        // 执行工具技能
                        _executeToolSkill(skill);
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 专家技能（按领域分组）
                  Text('👨‍💼 专家技能', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  
                  ...domainGroups.entries.map((entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          entry.key,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.value.map((expert) {
                          final isActive = _activeExpertId == expert.id;
                          return GestureDetector(
                            onTap: () => _toggleExpert(expert),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(expert.emoji ?? '👤', style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    expert.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isActive
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.check_circle, size: 12, color: theme.colorScheme.onPrimary),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  )),
                  
                  const SizedBox(height: 16),
                  
                  // 帮助说明
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '选择专家后，AI 将以该专家角色回答问题；点击工具可快速执行',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 当前激活的专家横幅
  Widget _buildActiveExpertBanner(ThemeData theme) {
    final expert = _skillDispatcher.getSkill(_activeExpertId!);
    if (expert == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(expert.emoji ?? '👤', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('当前专家: ${expert.name}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(expert.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurfaceVariant),
            onPressed: () => setState(() => _activeExpertId = null),
            tooltip: '取消专家',
          ),
        ],
      ),
    );
  }

  /// 切换专家
  void _toggleExpert(Skill expert) async {
    final sessionId = widget.sessionId;
    
    // 保存技能到数据库
    final sessionManager = ref.read(sessionManagerProvider);
    await sessionManager.updateEnabledSkill(sessionId, expert.id);
    
    setState(() {
      if (_activeExpertId == expert.id) {
        _activeExpertId = null; // 取消选择
      } else {
        _activeExpertId = expert.id; // 选择新专家
      }
    });
    Navigator.pop(context); // 关闭底部弹窗
    
    if (_activeExpertId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已激活专家: ${expert.name}'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  /// 执行工具技能
  Future<void> _executeToolSkill(Skill skill) async {
    try {
      final result = await _skillDispatcher.dispatch(skill.id, {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.success ? '${skill.name}: ${result.data}' : '执行失败: ${result.error}'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('执行失败: $e')),
        );
      }
    }
  }

  IconData _getSkillIcon(String? iconName) {
    switch (iconName) {
      case 'calculate': return Icons.calculate;
      case 'schedule': return Icons.schedule;
      case 'search': return Icons.search;
      default: return Icons.extension;
    }
  }

  /// WorkBuddy 风格输入区域
  Widget _buildInputArea(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 已选择的图片预览
        if (_selectedImages.isNotEmpty) _buildImagePreview(theme),
        // 已选择的文件列表
        if (_selectedFiles.isNotEmpty) _buildFilePreview(theme),
        // 输入行
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 地球图标（网络搜索）- 点击选择搜索模式
            _ToolButton(
              icon: Icons.language,
              isActive: _webSearchEnabled,
              onTap: () => _showSearchModeSheet(context),
              tooltip: '网络搜索 (${DialogueEngine.getSearchModeName(_currentSearchMode)})',
            ),
            const SizedBox(width: 4),
            // 摄像头拍照
            _ToolButton(
              icon: Icons.camera_alt_outlined,
              isActive: _cameraEnabled,
              onTap: _showCameraSheet,
              tooltip: '拍照',
            ),
            const SizedBox(width: 4),
            // 文件上传
            _ToolButton(
              icon: Icons.attach_file,
              isActive: false,
              onTap: _pickMultipleFiles,
              tooltip: '添加文件',
            ),
            const SizedBox(width: 4),
            // 技能
            _ToolButton(
              icon: Icons.auto_awesome,
              isActive: _activeExpertId != null,
              onTap: () => _showSkillBottomSheet(context),
              tooltip: '技能',
            ),
            const SizedBox(width: 4),
            // 知识库
            _ToolButton(
              icon: Icons.library_books,
              isActive: _activeKnowledgeBaseId != null,
              onTap: () => _showKnowledgeBaseSheet(context),
              tooltip: '知识库',
            ),
            const SizedBox(width: 4),
            // 🎤 左侧：语音/键盘切换按钮
            _buildVoiceModeToggleButton(theme),
            const SizedBox(width: 4),
            // 中间：文本输入框 或 语音按钮
            Expanded(
              child: _isVoiceMode
                  ? _buildVoiceRecordButton(theme, l10n)
                  : _buildTextInputField(theme, l10n),
            ),
            const SizedBox(width: 6),
            // 右侧：发送按钮（仅文本模式显示，语音模式下隐藏）
            if (!_isVoiceMode)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isGenerating
                    ? _ActionButton(
                        key: const ValueKey('stop'),
                        icon: Icons.stop,
                        color: theme.colorScheme.error,
                        onTap: _stopGeneration,
                      )
                    : _ActionButton(
                        key: const ValueKey('send'),
                        icon: Icons.send,
                        color: (_messageController.text.trim().isNotEmpty ||
                                _selectedImages.isNotEmpty ||
                                _selectedFiles.isNotEmpty)
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        onTap: () => _sendMessage(l10n),
                        iconColor: (_messageController.text.trim().isNotEmpty ||
                                _selectedImages.isNotEmpty ||
                                _selectedFiles.isNotEmpty)
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
              ),
          ],
        ),
      ],
    );
  }

  /// 构建语音/键盘切换按钮（左侧）
  Widget _buildVoiceModeToggleButton(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (_isVoiceRecording) {
          _onVoiceRecordEnd(false);
        }
        setState(() => _isVoiceMode = !_isVoiceMode);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isVoiceMode ? Icons.keyboard : Icons.mic,
          size: 20,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  /// 构建按住说话按钮（语音模式）
  Widget _buildVoiceRecordButton(ThemeData theme, AppLocalizations l10n) {
    final isCancelled = _isVoiceRecording && _voiceDragOffset < -60;
    return GestureDetector(
      onPanStart: (_) => _onVoiceRecordStart(),
      onPanUpdate: (details) {
        if (!_isVoiceRecording) return;
        setState(() => _voiceDragOffset = details.localPosition.dy);
        if (_voiceDragOffset < -60) {
          HapticFeedback.lightImpact();
        }
      },
      onPanEnd: (_) {
        if (!_isVoiceRecording) return;
        final cancelled = _voiceDragOffset < -60;
        _voiceDragOffset = 0;
        _onVoiceRecordEnd(cancelled);
      },
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCancelled
              ? Colors.grey.shade300
              : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: _isVoiceRecording
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isCancelled ? Icons.delete_outline : Icons.mic,
                    color: isCancelled
                        ? Colors.red
                        : theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCancelled ? '松手取消' : '松开结束',
                    style: TextStyle(
                      color: isCancelled
                          ? Colors.red
                          : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Text(
                '按住说话',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// 构建文本输入框（文本模式）
  Widget _buildTextInputField(ThemeData theme, AppLocalizations l10n) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: l10n.typeMessage,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(l10n),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  /// 图片预览区域
  Widget _buildImagePreview(ThemeData theme) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          final image = _selectedImages[index];
          return Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(image.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedImages.removeAt(index));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: theme.colorScheme.onError,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 文件预览区域
  Widget _buildFilePreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _selectedFiles.map<Widget>((XFile file) {
          // 从文件名提取扩展名
          final ext = file.name.contains('.') 
              ? file.name.split('.').last 
              : '';
          return Chip(
            avatar: Icon(
              _getFileIcon(ext),
              size: 16,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              file.name,
              style: theme.textTheme.bodySmall,
            ),
            deleteIcon: Icon(
              Icons.close,
              size: 14,
              color: theme.colorScheme.error,
            ),
            onDeleted: () {
              setState(() => _selectedFiles.remove(file));
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  /// 获取文件图标
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 显示搜索模式选择底部弹窗
  void _showSearchModeSheet(BuildContext context) {
    // 本地状态，用于确认前预览
    WebSearchMode tempSearchMode = _currentSearchMode;
    String tempTavilyApiKey = _tavilyApiKey;
    bool tempWebSearchEnabled = _webSearchEnabled;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // 标题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '网络搜索设置',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // 启用/关闭开关
                      Switch(
                        value: tempWebSearchEnabled,
                        onChanged: (value) {
                          setSheetState(() => tempWebSearchEnabled = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Tavily API (国内推荐)
                ListTile(
                  leading: Radio<WebSearchMode>(
                    value: WebSearchMode.tavily,
                    groupValue: tempSearchMode,
                    onChanged: (value) {
                      setSheetState(() => tempSearchMode = value!);
                    },
                  ),
                  title: const Text('Tavily 🌐'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('国内推荐，需要 API Key'),
                      if (tempSearchMode == WebSearchMode.tavily) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: TextEditingController(text: tempTavilyApiKey),
                          decoration: InputDecoration(
                            hintText: '输入 Tavily API Key',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (value) {
                            tempTavilyApiKey = value;
                          },
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            // 打开 tavily 注册页面
                          },
                          child: Text(
                            '点击获取: tavily.com (免费1000次/天)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    setSheetState(() => tempSearchMode = WebSearchMode.tavily);
                  },
                ),
                const Divider(),
                // DuckDuckGo
                ListTile(
                  leading: Radio<WebSearchMode>(
                    value: WebSearchMode.duckduckgo,
                    groupValue: tempSearchMode,
                    onChanged: (value) {
                      setSheetState(() => tempSearchMode = value!);
                    },
                  ),
                  title: const Text('DuckDuckGo'),
                  subtitle: const Text('免费，但国内可能无法访问'),
                  onTap: () {
                    setSheetState(() => tempSearchMode = WebSearchMode.duckduckgo);
                  },
                ),
                const Divider(),
                // Wikipedia
                ListTile(
                  leading: Radio<WebSearchMode>(
                    value: WebSearchMode.wikipedia,
                    groupValue: tempSearchMode,
                    onChanged: (value) {
                      setSheetState(() => tempSearchMode = value!);
                    },
                  ),
                  title: const Text('Wikipedia'),
                  subtitle: const Text('免费百科，仅限知识类查询'),
                  onTap: () {
                    setSheetState(() => tempSearchMode = WebSearchMode.wikipedia);
                  },
                ),
                const SizedBox(height: 8),
                // 当前状态提示
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tempWebSearchEnabled
                          ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tempWebSearchEnabled ? Icons.check_circle : Icons.info_outline,
                          size: 20,
                          color: tempWebSearchEnabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tempWebSearchEnabled
                                ? '网络搜索已启用，当前模式: ${DialogueEngine.getSearchModeName(tempSearchMode)}'
                                : '网络搜索已关闭',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 确认按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        // 保存配置
                        await _saveSearchConfig(
                          tempSearchMode,
                          tempTavilyApiKey,
                          tempWebSearchEnabled,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tempWebSearchEnabled
                                    ? '网络搜索已启用 (${DialogueEngine.getSearchModeName(tempSearchMode)})'
                                    : '网络搜索已关闭',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('确认'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// 显示知识库选择底部弹窗
  void _showKnowledgeBaseSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.library_books, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '选择知识库',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 知识库列表
              if (_knowledgeBases.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '还没有知识库',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/settings/knowledge');
                        },
                        child: const Text('去创建知识库 →'),
                      ),
                    ],
                  ),
                )
              else ...[
                // 无知识库选项
                ListTile(
                  leading: Icon(
                    Icons.block,
                    color: _activeKnowledgeBaseId == null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('不使用知识库'),
                  trailing: _activeKnowledgeBaseId == null
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () async {
                    await _setKnowledgeBase(null);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const Divider(),
                // 知识库列表
                ..._knowledgeBases.map((kb) => ListTile(
                  leading: Icon(
                    Icons.library_books,
                    color: _activeKnowledgeBaseId == kb.id
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(kb.name),
                  subtitle: Text('${kb.documentCount} 个文档'),
                  trailing: _activeKnowledgeBaseId == kb.id
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () async {
                    await _setKnowledgeBase(kb.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                )),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 设置当前会话关联的知识库
  Future<void> _setKnowledgeBase(String? knowledgeBaseId) async {
    try {
      final sessionManager = ref.read(sessionManagerProvider);
      await sessionManager.updateSession(
        widget.sessionId,
        enabledKnowledgeBaseId: knowledgeBaseId,
      );
      
      setState(() {
        _activeKnowledgeBaseId = knowledgeBaseId;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(knowledgeBaseId == null
                ? '已取消关联知识库'
                : '已关联知识库'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('设置失败: $e')),
        );
      }
    }
  }
  
  /// 保存搜索配置到持久化存储
  Future<void> _saveSearchConfig(
    WebSearchMode mode,
    String apiKey,
    bool enabled,
  ) async {
    final settingsService = ref.read(settingsServiceProvider);
    final engine = ref.read(dialogueEngineProvider);
    
    // 保存到持久化存储
    await settingsService.setSearchMode(SearchMode.values[mode.index]);
    await settingsService.setTavilyApiKey(apiKey);
    await settingsService.setWebSearchEnabled(enabled);
    
    // 更新本地状态
    if (mounted) {
      setState(() {
        _currentSearchMode = mode;
        _tavilyApiKey = apiKey;
        _webSearchEnabled = enabled;
      });
    }
    
    // 同步到 DialogueEngine
    engine.setWebSearchMode(mode);
    if (mode == WebSearchMode.tavily && apiKey.isNotEmpty) {
      engine.setTavilyApiKey(apiKey);
    }
  }

  /// 显示相机/相册选择底部弹窗
  void _showCameraSheet() {
    // 检测平台：macOS 和移动设备都支持相机
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final isMacOS = Platform.isMacOS;
    final supportsCamera = isMobile || isMacOS;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // 拍照选项 - macOS 和移动设备都显示
              if (supportsCamera)
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: const Text('拍照'),
                  subtitle: Text(isMacOS ? '使用摄像头拍摄照片' : '使用相机拍摄照片'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto(useCamera: true);
                  },
                ),
              // 从相册选择 - 所有平台都可用
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text('从相册选择'),
                subtitle: const Text('从照片库中选择图片'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto(useCamera: false);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 拍照或从相册选择
  Future<void> _takePhoto({required bool useCamera}) async {
    // 检查平台
    final isMobile = Platform.isAndroid || Platform.isIOS;
    final isMacOS = Platform.isMacOS;
    
    try {
      XFile? image;
      
      debugPrint('Platform: ${Platform.operatingSystem}, isMobile: $isMobile, isMacOS: $isMacOS, useCamera: $useCamera');
      
      if (useCamera) {
        // 尝试使用相机拍摄
        // macOS 和移动设备都支持相机
        if (isMobile || isMacOS) {
          image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85,
          );
          
          if (image == null && mounted) {
            // 相机不可用，提示用户
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('无法访问相机，请确保已授权相机权限'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // 其他桌面平台
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('桌面应用不支持相机拍摄，请从相册选择图片'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      } else {
        // 从相册选择
        image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      }

      if (image != null) {
        setState(() {
          _selectedImages.add(image!);
          _cameraEnabled = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已添加图片: ${image.name}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法访问: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 多文件选择 - 根据文件类型分别添加到图片列表或文件列表
  Future<void> _pickMultipleFiles() async {
    debugPrint('DEBUG: _pickMultipleFiles called');
    
    try {
      // macOS 上使用更宽松的配置
      const typeGroup = XTypeGroup(
        label: '所有文件',
      );

      debugPrint('DEBUG: Calling openFiles...');
      
      // 使用 file_selector 选择文件
      final files = await openFiles(acceptedTypeGroups: [typeGroup]);

      debugPrint('DEBUG: openFiles returned ${files.length} files');
      
      if (files.isNotEmpty) {
        int imageCount = 0;
        int fileCount = 0;
        
        setState(() {
          for (final file in files) {
            final ext = file.name.toLowerCase().split('.').last;
            // 图片文件添加到 _selectedImages
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'].contains(ext)) {
              debugPrint('DEBUG: Adding image - name: ${file.name}');
              _selectedImages.add(file);
              imageCount++;
            } else {
              // 其他文件添加到 _selectedFiles（文档）
              debugPrint('DEBUG: Adding document - name: ${file.name}');
              _selectedFiles.add(file);
              fileCount++;
            }
          }
        });
        
        debugPrint('DEBUG: _selectedImages: ${_selectedImages.length}, _selectedFiles: ${_selectedFiles.length}');
        
        if (mounted) {
          final parts = <String>[];
          if (imageCount > 0) parts.add('$imageCount 张图片');
          if (fileCount > 0) parts.add('$fileCount 个文档');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已选择 ${parts.join("和")}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        debugPrint('DEBUG: No files selected or result is empty');
      }
    } catch (e, stack) {
      debugPrint('DEBUG: File picker error: $e');
      debugPrint('DEBUG: Stack trace: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法选择文件: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(AppLocalizations l10n) async {
    final text = _messageController.text.trim();

    // 如果文本为空，且没有图片/文件，则不发送
    if (text.isEmpty && _selectedImages.isEmpty && _selectedFiles.isEmpty) {
      return;
    }

    // 如果正在生成中，则不发送
    if (_isGenerating) return;
    
    // 新消息来时，自动停止当前 TTS 播放
    try {
      final ttsProvider = ref.read(ttsServiceProvider);
      await ttsProvider.stop();
    } catch (_) {}

    // 多模态检查：如果用户选择了图片但模型不支持，提示用户
    final hasImages = _selectedImages.isNotEmpty;
    if (hasImages) {
      final modelState = ref.read(modelProvider);
      final sessionState = ref.read(sessionStateProvider);
      final modelId = sessionState.activeSession?.modelId ?? '';
      final model = modelState.models.where((m) => m.id == modelId).firstOrNull;
      if (model != null && !model.supportsMultimodal) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('当前模型不支持多模态（图片/视频），请选择纯文本模型或移除图片'),
            duration: Duration(milliseconds: 1500),
          ),
        );
        return;
      }
    }

    // 保存要发送的内容
    final imagesToSend = List<XFile>.from(_selectedImages);
    final filesToSend = List<XFile>.from(_selectedFiles);
    final textToSend = text;

    // 清空输入
    _messageController.clear();
    setState(() {
      _isGenerating = true;
      _streamingText = ''; // 清空之前的流式文本
      _selectedImages = [];
      _selectedFiles = [];
    });

    // 构建包含文件内容的消息内容
    String finalContent = textToSend;
    
    // 处理图片：读取图片数据并发送给多模态模型
    if (imagesToSend.isNotEmpty) {
      final imageDataList = <Map<String, String>>[];
      for (final img in imagesToSend) {
        try {
          final bytes = await img.readAsBytes();
          final base64Data = base64Encode(bytes);
          final ext = img.name.toLowerCase().split('.').last;
          String mimeType = 'image/jpeg';
          if (ext == 'png') mimeType = 'image/png';
          else if (ext == 'gif') mimeType = 'image/gif';
          else if (ext == 'webp') mimeType = 'image/webp';
          else if (ext == 'bmp') mimeType = 'image/bmp';
          
          imageDataList.add({
            'name': img.name,
            'mimeType': mimeType,
            'data': base64Data,
          });
          debugPrint('[图片] 已加载: ${img.name}, 大小: ${bytes.length} bytes');
        } catch (e) {
          debugPrint('[图片] 加载失败: ${img.name}, 错误: $e');
        }
      }
      
      if (imageDataList.isNotEmpty) {
        // 将图片数据编码为 JSON 字符串传递给对话引擎
        final imageJson = json.encode(imageDataList);
        // 在消息中标记有多模态图片数据
        finalContent = '$textToSend\n\n[多模态图片数据:$imageJson]';
        debugPrint('[图片] 准备发送 ${imageDataList.length} 张图片给模型');
      }
    }
    
    // 处理文件：解析文件内容并注入消息
    debugPrint('[DEBUG] filesToSend.isNotEmpty = ${filesToSend.isNotEmpty}, count = ${filesToSend.length}');
    if (filesToSend.isNotEmpty) {
      final fileContents = StringBuffer();
      for (final file in filesToSend) {
        debugPrint('[DEBUG] 处理文件: ${file.name}');
        try {
          // 获取文件的完整路径
          final filePath = file.path;
          debugPrint('[DEBUG] file.path = "$filePath"');
          
          if (filePath != null && filePath.isNotEmpty) {
            debugPrint('[文件上传] 正在解析文件: ${file.name}, 路径: $filePath');
            
            // 检查文件是否存在
            final fileExists = await File(filePath).exists();
            debugPrint('[DEBUG] 文件是否存在: $fileExists');
            
            if (!fileExists) {
              fileContents.writeln('[文件: ${file.name}]（文件不存在，可能已被移动或删除）');
              continue;
            }
            
            final content = await FileParserService.parseFile(filePath);
            debugPrint('[DEBUG] 文件解析完成，内容长度: ${content.length}');
            
            final truncatedContent = content.length > 5000 
                ? '${content.substring(0, 5000)}\n\n...（内容过长，已截断）' 
                : content;
            fileContents.writeln('📄 文件: ${file.name}');
            fileContents.writeln('---');
            fileContents.writeln(truncatedContent);
            fileContents.writeln('\n---\n');
            debugPrint('[文件上传] 文件解析成功: ${file.name}, 内容长度: ${content.length}');
          } else {
            // 如果无法获取路径，尝试直接读取文件数据
            debugPrint('[DEBUG] file.path 为空，尝试读取文件数据');
            try {
              final bytes = await file.readAsBytes();
              debugPrint('[DEBUG] 读取到 ${bytes.length} bytes');
              fileContents.writeln('[文件: ${file.name}]（路径不可用，但有 ${bytes.length} bytes 数据）');
            } catch (e2) {
              debugPrint('[DEBUG] 读取文件数据也失败: $e2');
              fileContents.writeln('[文件: ${file.name}]（无法读取文件内容：路径为空且无法读取数据）');
            }
          }
        } catch (e) {
          debugPrint('[文件上传] 文件解析失败: ${file.name}, 错误: $e');
          fileContents.writeln('[文件: ${file.name}]（解析失败: $e）');
        }
      }
      finalContent = '$finalContent\n\n${fileContents.toString()}';
      debugPrint('[DEBUG] finalContent 长度: ${finalContent.length}');
    }

    try {
      final dialogueEngine = ref.read(dialogueEngineProvider);

      // ✅ RAG 流程：先用用户问题检索知识库，将相关内容作为独立上下文传给推理引擎
      // 知识库检索结果不拼接到用户消息，保持用户原始输入干净
      String? knowledgeContext;
      if (_activeKnowledgeBaseId != null && textToSend.isNotEmpty) {
        try {
          final db = ref.read(databaseProvider);
          final kbService = KnowledgeBaseService(db);
          debugPrint('[知识库RAG] 开始检索: knowledgeBaseId=$_activeKnowledgeBaseId, query=$textToSend');
          final results = await kbService.searchKnowledgeBase(
            _activeKnowledgeBaseId!,
            textToSend,
            limit: 3,
          );
          debugPrint('[知识库RAG] 检索到 ${results.length} 条相关内容');
          if (results.isNotEmpty) {
            // 构建带编号的知识库上下文，方便 AI 引用
            final buffer = StringBuffer();
            for (int i = 0; i < results.length; i++) {
              final content = results[i].content.trim();
              if (content.isNotEmpty) {
                buffer.writeln('[片段 ${i + 1}]');
                buffer.writeln(content);
                if (i < results.length - 1) buffer.writeln();
              }
            }
            knowledgeContext = buffer.toString().trim();
            debugPrint('[知识库RAG] 上下文构建完成，长度: ${knowledgeContext!.length}');
          } else {
            debugPrint('[知识库RAG] 未检索到相关内容，跳过知识库注入');
          }
        } catch (e, stack) {
          debugPrint('[知识库RAG] 检索失败: $e');
          debugPrint('[知识库RAG] 堆栈: $stack');
          // 检索失败不影响正常对话，knowledgeContext 保持 null
        }
      }

      // 使用流式回复，实时更新 UI
      // finalContent = 用户输入 + 文件解析内容（干净，无知识库内容）
      // knowledgeContext = 知识库检索结果（由推理引擎以 RAG system 消息形式注入）
      await for (final response in dialogueEngine.streamResponse(
        widget.sessionId,
        finalContent,
        enableWebSearch: _webSearchEnabled,
        knowledgeContext: knowledgeContext,
      )) {
        if (!mounted) break;

        if (!response.isComplete) {
          // 累积 token 并实时更新 UI
          _streamingText += response.content;
          // 更新统计信息
          if (response.tokenCount != null) {
            _currentTokenCount = response.tokenCount;
          }
          if (response.tokensPerSecond != null) {
            _currentTokensPerSecond = response.tokensPerSecond;
          }
          // ✅ 优化：减少 setState 频率，避免帧时间回退
          // 只在文本长度达到一定阈值时才更新 UI（每 8-16 个字符更新一次）
          final shouldUpdate = _streamingText.length % 16 < response.content.length ||
                              _currentTokenCount != null ||
                              _currentTokensPerSecond != null;
          if (shouldUpdate) {
            setState(() {});
          }

          // ✅ 优化滚动：使用节流避免频繁 animateTo
          _scheduleScrollToBottom();
        }

        // ✅ 关键修复：生成完成时，dialogue_engine 内部已调用 refreshCurrentSession()
        // SessionManager 会推送新的 SessionState（包含完整消息）到 sessionStateStream
        // StreamProvider 会自动收到更新并重建 UI，无需在这里 invalidate
        // 之前的 ref.invalidate(sessionStateProvider) 会导致 StreamProvider 重订阅，
        // 期间会短暂收到空数据（AsyncValue.loading），消息列表清空！
        if (response.isComplete) {
          // 保存最终统计信息
          if (response.tokenCount != null) {
            _currentTokenCount = response.tokenCount;
          }
          if (response.tokensPerSecond != null) {
            _currentTokensPerSecond = response.tokensPerSecond;
          }
          // 滚动到最底部确保最新消息可见
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          // 如果开启了语音播报，播放 AI 回复的语音
          await _playAssistantVoice(response.content);
        }
      }
    } catch (e) {
      if (mounted) {
        final errMsg = e.toString();
        // ✅ 识别不同类型的错误，给出对应的诊断建议
        String displayMessage;
        
        if (errMsg.contains('401')) {
          // 401 认证错误
          displayMessage = 'API 认证失败 (401)：请检查 API Key 是否正确、是否过期';
        } else if (errMsg.contains('未加载') || errMsg.contains('not loaded') || errMsg.contains('未就绪')) {
          // 本地模型未加载
          displayMessage = '模型尚未加载，请在模型页面加载后再对话';
        } else if (errMsg.contains('API Key 为空') || errMsg.contains('apiKey 为空')) {
          // API Key 未设置
          displayMessage = 'API Key 未设置，请到模型设置中添加 API Key';
        } else if (errMsg.contains('网络') || errMsg.contains('network') || errMsg.contains('connection')) {
          // 网络错误
          displayMessage = '网络连接失败，请检查网络并重试';
        } else {
          displayMessage = '发送消息失败: ${errMsg.length > 50 ? '${errMsg.substring(0, 50)}...' : errMsg}';
        }
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        final snackBar = SnackBar(
          content: Text(displayMessage),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(milliseconds: 1500),
          action: SnackBarAction(
            label: '查看日志',
            textColor: Colors.white,
            onPressed: () {
              // 提示用户在控制台查看详细日志
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('请在 IDE 控制台查看详细调试日志 [ModelInferenceEngine]'),
                  duration: Duration(milliseconds: 1500),
                ),
              );
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        
        // ✅ 修复：有 action 的 SnackBar 也需要在 1.5s 后自动关闭
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _streamingText = ''; // 清空流式文本（已保存到数据库）
          _cameraEnabled = false;
          // 保留统计信息用于显示
        });
      }
    }
  }

  void _stopGeneration() {
    final dialogueEngine = ref.read(dialogueEngineProvider);
    dialogueEngine.cancelGeneration(widget.sessionId);
    setState(() => _isGenerating = false);
  }

  /// ✅ 流式响应优化：节流滚动到底部
  /// 避免频繁调用 animateTo 导致帧时间回退错误
  void _scheduleScrollToBottom() {
    if (!_scrollController.hasClients || _isScrollingToBottom) return;
    
    final now = DateTime.now();
    // 节流：至少间隔 50ms 才允许下一次滚动
    if (now.difference(_lastScrollTime).inMilliseconds < 50) return;
    
    _isScrollingToBottom = true;
    _lastScrollTime = now;
    
    // 使用 postFrameCallback 确保在帧结束后重置标记
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        final maxExtent = _scrollController.position.maxScrollExtent;
        final currentOffset = _scrollController.offset;
        
        // 只有当内容超出视口时才滚动
        if (maxExtent > currentOffset) {
          // 使用 jumpTo 而不是 animateTo，避免动画冲突
          _scrollController.jumpTo(maxExtent);
        }
      } catch (e) {
        debugPrint('Scroll error: $e');
      } finally {
        _isScrollingToBottom = false;
      }
    });
  }

  /// 播放 AI 回复的语音
  Future<void> _playAssistantVoice(String text) async {
    if (text.isEmpty) return;

    // 获取当前会话状态
    final sessionState = ref.read(sessionStateProvider);
    final session = sessionState.activeSession;

    // 检查是否开启了语音播报
    if (session == null || !session.enableVoiceOutput) return;

    try {
      // 获取 TTS 设置
      final settingsService = ref.read(settingsServiceProvider);
      await settingsService.initialize();
      
      // 获取 TTS 提供商配置
      final ttsProviderStr = settingsService.getTtsProvider();
      
      // 根据配置选择 TTS 提供商
      TTSProvider provider = TTSProvider.sherpa; // 默认使用 Sherpa-ONNX
      String? apiKey;
      
      // 解析 TTS 提供商
      if (ttsProviderStr == 'sherpa') {
        provider = TTSProvider.sherpa;
      } else if (ttsProviderStr == 'openai') {
        provider = TTSProvider.openai;
        apiKey = settingsService.getTavilyApiKey();
      } else if (ttsProviderStr == 'system') {
        provider = TTSProvider.system;
      } else {
        // 默认使用 Sherpa-ONNX
        provider = TTSProvider.sherpa;
      }
      
      // 创建 TTS 服务实例
      final prefs2 = await SharedPreferences.getInstance();
      final selectedTtsModelId = prefs2.getString('selected_tts_model_id') ?? 'melo-zh-en';
      final ttsVoiceId2 = prefs2.getString('tts_voice_id') ?? '0';
      final systemTtsSpeed = prefs2.getDouble('system_tts_speed') ?? 0.5;
      
      final ttsService = TTSService(
        provider: provider,
        apiKey: apiKey,
        sherpaModelId: provider == TTSProvider.sherpa ? selectedTtsModelId : null,
        speakerId: int.tryParse(ttsVoiceId2) ?? 0,
        speechRate: provider == TTSProvider.system ? systemTtsSpeed : 1.0,
      );

      // 使用 speakLongText 自动分句分块，避免长文本卡死
      // 注意：不使用 await，让 TTS 在后台异步播放，不阻塞 UI
      // 用户可以继续发送新消息
      ttsService.speakLongText(text).then((_) {
        debugPrint('语音播报已完成');
      }).catchError((e) {
        debugPrint('语音播报失败: $e');
      });

      debugPrint('语音播报已启动（异步）: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      debugPrint('语音播报初始化失败: $e');
      // 语音播报失败不中断对话流程
    }
  }

  void _handleSessionOption(String option, AppLocalizations l10n) {
    switch (option) {
      case 'rename':
        _showRenameDialog(l10n);
        break;
      case 'change_model':
        _showChangeModelDialog(l10n);
        break;
      case 'edit_system_prompt':
        _showSystemPromptDialog(l10n);
        break;
      case 'clear':
        _confirmClearMessages(l10n);
        break;
      case 'delete':
        _confirmDeleteSession(l10n);
        break;
    }
  }

  void _showRenameDialog(AppLocalizations l10n) {
    final sessionState = ref.read(sessionStateProvider);
    final currentName = sessionState.activeSession?.name ?? '';
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renameSession),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.newName,
            prefixIcon: const Icon(Icons.edit_outlined),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty || newName == currentName) {
                Navigator.pop(dialogContext);
                return;
              }
              Navigator.pop(dialogContext);
              try {
                final manager = ref.read(sessionManagerProvider);
                await manager.renameSession(widget.sessionId, newName);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.sessionRenamed)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('重命名失败: $e')),
                  );
                }
              }
            },
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
  }


  void _showSystemPromptDialog(AppLocalizations l10n) {
    final sessionState = ref.read(sessionStateProvider);
    final currentPrompt = sessionState.activeSession?.systemPrompt ?? '';
    final controller = TextEditingController(text: currentPrompt);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('修改人设'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '设置当前会话的系统提示词（人设），定义 AI 助手的角色和行为。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '例如：你是一位专业的产品经理...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final manager = ref.read(sessionManagerProvider);
                await manager.updateSessionConfig(
                  widget.sessionId,
                  SessionConfig(
                    name: sessionState.activeSession?.name ?? '',
                    modelId: sessionState.activeSession?.modelId ?? '',
                    systemPrompt: controller.text.trim(),
                  ),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('人设已更新')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新失败: $e')),
                  );
                }
              }
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showChangeModelDialog(AppLocalizations l10n) {
    final sessionState = ref.read(sessionStateProvider);
    final currentModelId = sessionState.activeSession?.modelId ?? '';
    String selectedModelId = currentModelId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l10n.changeModel),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          content: FutureBuilder<List<({String id, String displayName})>>(
            future: _getAvailableModels(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 56,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final models = snapshot.data!;
              final validValue = models.any((m) => m.id == currentModelId)
                  ? currentModelId
                  : (models.isNotEmpty ? models.first.id : null);

              return DropdownButtonFormField<String>(
                value: validValue,
                decoration: InputDecoration(
                  labelText: l10n.selectModel,
                  prefixIcon: const Icon(Icons.smart_toy_outlined),
                ),
                items: models
                    .map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text('${m.displayName} (${m.id})',
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => selectedModelId = value);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final manager = ref.read(sessionManagerProvider);
                  await manager.updateSessionConfig(
                    widget.sessionId,
                    SessionConfig(
                      name: sessionState.activeSession?.name ?? '',
                      modelId: selectedModelId,
                      systemPrompt: sessionState.activeSession?.systemPrompt,
                    ),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已切换模型')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('切换失败: $e')),
                    );
                  }
                }
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearMessages(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearMessages),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: Text(l10n.clearMessagesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final manager = ref.read(sessionManagerProvider);
              try {
                await manager.clearMessages(widget.sessionId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.messagesCleared)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('清空失败: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSession() async {
    final sessionState = ref.read(sessionStateProvider);
    final session = sessionState.activeSession;
    if (session == null) return;

    final messages = sessionState.messages;
    if (messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有消息可导出')),
      );
      return;
    }

    try {
      // 构建 CSV 数据
      final rows = <List<String>>[
        ['序号', '角色', '时间', '内容'],
        ...messages.asMap().entries.map((e) {
          final msg = e.value;
          final role = msg.role == 'user' ? '用户' : msg.role == 'assistant' ? '助手' : msg.role;
          final time = msg.createdAt?.toString().substring(0, 19) ?? '';
          final content = msg.content.replaceAll('\n', ' ').replaceAll('\r', '');
          return ['${e.key + 1}', role, time, content];
        }),
      ];

      // 转换为 CSV 格式
      final csvData = Csv().encode(rows);

      // 生成文件名
      final name = session.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final timestamp = DateTime.now().toString().substring(0, 19).replaceAll(':', '-');
      final fileName = '${name}_$timestamp.csv';

      // 保存到下载目录
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导出到: $filePath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isMacOS || Platform.isIOS) {
      return Directory('/Users/${Platform.environment['USER']}/Downloads');
    } else if (Platform.isWindows) {
      return Directory('${Platform.environment['USERPROFILE']}\\Downloads');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return dir;
    }
  }

  void _confirmDeleteSession(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: Text(l10n.deleteSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // 关闭确认对话框
              final sessionManager = ref.read(sessionManagerProvider);
              await sessionManager.deleteSession(widget.sessionId);
              if (mounted) {
                context.go('/'); // 返回首页而非 pop（避免 go_router 空栈崩溃）
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.sessionDeleted)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<List<({String id, String displayName})>> _getAvailableModels() async {
    final modelState = ref.read(modelProvider);
    return modelState.models.map((m) => (id: m.id, displayName: m.displayName)).toList();
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final String modelId;
  /// 可选的统计信息（从流式响应传入）
  final int? tokenCount;
  final double? tokensPerSecond;

  const _MessageBubble({
    required this.message,
    required this.modelId,
    this.tokenCount,
    this.tokensPerSecond,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == 'user';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          AppTheme.buildModelAvatar(
            modelId: modelId,
            size: 36,
          ),
          const SizedBox(width: AppTheme.spacingM),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () => _copyMessage(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 消息内容
                      isUser
                          ? _buildSimpleText(context, theme)
                          : _buildMarkdownContent(context, theme),
                      
                      // 底部操作栏（复制按钮）
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: isUser 
                            ? MainAxisAlignment.end 
                            : MainAxisAlignment.start,
                        children: [
                          // 统计信息（仅助手消息显示）
                          if (!isUser && (tokenCount != null || tokensPerSecond != null)) ...[
                            _buildStatsBadge(theme),
                            const SizedBox(width: 12),
                          ],
                          // 复制按钮
                          GestureDetector(
                            onTap: () => _copyMessage(context),
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: isUser
                                  ? theme.colorScheme.onPrimary.withValues(alpha: 0.6)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                _formatTime(message.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),

        if (isUser) ...[
          const SizedBox(width: AppTheme.spacingM),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建简单文本内容（用户消息）
  Widget _buildSimpleText(BuildContext context, ThemeData theme) {
    return Text(
      message.content,
      style: TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  /// 构建 Markdown 内容（助手消息）
  Widget _buildMarkdownContent(BuildContext context, ThemeData theme) {
    return SelectionArea(
      child: MarkdownBody(
        data: _cleanMarkdown(message.content),
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          // 标题样式
          h1: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          h2: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          h3: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          h4: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          h5: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          h6: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          // 段落
          p: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15,
            height: 1.6,
          ),
          // 列表
          listBullet: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 15,
          ),
          listIndent: 20,
          // 代码块
          code: TextStyle(
            color: theme.colorScheme.onSurface,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          // 行内代码
          codeblockAlign: WrapAlignment.start,
          // 引用
          blockquote: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 15,
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.only(left: 16),
          // 链接
          a: TextStyle(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          // 粗体/斜体
          strong: const TextStyle(fontWeight: FontWeight.bold),
          em: const TextStyle(fontStyle: FontStyle.italic),
          // 水平线
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          tableHead: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tableBody: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
          ),
          tableBorder: TableBorder.all(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
          tableCellsPadding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  /// 清理 Markdown 内容，移除可能导致格式问题的原始符号
  String _cleanMarkdown(String content) {
    // 移除行首多余的 $ 符号（LaTeX /mathjax 残留）
    // 但保留合理的表格分隔符等
    String cleaned = content;
    
    // 移除孤立的 $ 符号（不是 $...$ 数学公式）
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(?<!\$)\$(?!\$)'),
      (match) => '',
    );
    
    // 移除连续的特殊符号序列（如 *** 转为 ---）
    cleaned = cleaned.replaceAll(RegExp(r'\*{3,}'), '---');
    
    // 移除行尾多余的 \
    cleaned = cleaned.replaceAll(RegExp(r'\\+\s*$', multiLine: true), '');
    
    return cleaned;
  }

  /// 构建统计信息徽章
  Widget _buildStatsBadge(ThemeData theme) {
    final parts = <String>[];
    
    if (tokenCount != null) {
      parts.add('$tokenCount tokens');
    }
    
    if (tokensPerSecond != null) {
      parts.add('${tokensPerSecond!.toStringAsFixed(1)} tok/s');
    }
    
    if (parts.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        parts.join(' • '),
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

/// 微信风格语音录入按钮内容组件
/// 显示状态：空闲 / 录音中 / 识别中
class _VoiceInputButtonContent extends StatelessWidget {
  final bool isRecording;
  final bool isRecognizing;
  final double amplitude;
  final bool isCancelling;
  final ThemeData theme;

  const _VoiceInputButtonContent({
    required this.isRecording,
    required this.isRecognizing,
    required this.amplitude,
    required this.isCancelling,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // 识别中：旋转图标
    if (isRecognizing && !isRecording) {
      return _RecognizingMicButton(theme: theme);
    }

    // 录音中：红色麦克风 + 波形
    if (isRecording) {
      return _RecordingMicButton(
        amplitude: amplitude,
        isCancelling: isCancelling,
        theme: theme,
      );
    }

    // 空闲状态：普通麦克风
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.mic,
        color: theme.colorScheme.onPrimaryContainer,
        size: 22,
      ),
    );
  }
}

/// 识别中的麦克风按钮（旋转动画）
class _RecognizingMicButton extends StatefulWidget {
  final ThemeData theme;
  const _RecognizingMicButton({required this.theme});

  @override
  State<_RecognizingMicButton> createState() => _RecognizingMicButtonState();
}

class _RecognizingMicButtonState extends State<_RecognizingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.theme.colorScheme.tertiaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.autorenew,
          color: widget.theme.colorScheme.onTertiaryContainer,
          size: 22,
        ),
      ),
    );
  }
}

/// 录音中的麦克风按钮（红色 + 波形）
class _RecordingMicButton extends StatelessWidget {
  final double amplitude;
  final bool isCancelling;
  final ThemeData theme;

  const _RecordingMicButton({
    required this.amplitude,
    required this.isCancelling,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 麦克风容器：36x36（确保总高 < 44）
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCancelling ? Colors.grey : Colors.red.shade400,
            shape: BoxShape.circle,
            boxShadow: isCancelling
                ? null
                : [
                    BoxShadow(
                      color: Colors.red.withAlpha(80),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 音量波形（缩小到 32x32）
              if (!isCancelling)
                CustomPaint(
                  size: const Size(32, 32),
                  painter: _MicWaveformPainter(amplitude: amplitude),
                ),
              // 图标（缩小到 18）
              Icon(
                isCancelling ? Icons.delete_outline : Icons.mic,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
        // 提示文字：紧凑排列
        const SizedBox(height: 1),
        Text(
          isCancelling ? '取消' : '录音',
          style: TextStyle(
            fontSize: 8,
            color: isCancelling
                ? Colors.red
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 麦克风波形绘制器
class _MicWaveformPainter extends CustomPainter {
  final double amplitude;
  _MicWaveformPainter({required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitude < 0.03) return;
    final paint = Paint()
      ..color = Colors.white.withAlpha((amplitude * 180).clamp(60, 200).toInt())
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const bars = 6;
    for (int i = 0; i < bars; i++) {
      final angle = (i / bars) * 2 * 3.14159265359;
      final maxR = size.width / 2 - 5;
      final minR = maxR * 0.35;
      // 用 sin 让高度随角度变化，更有声波感
      final waveH = amplitude * (minR + (i % 2 == 0 ? maxR - minR : (maxR - minR) * 0.6));
      final x1 = cx + minR * math.cos(angle);
      final y1 = cy + minR * math.sin(angle);
      final x2 = cx + (minR + waveH) * math.cos(angle);
      final y2 = cy + (minR + waveH) * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_MicWaveformPainter old) => old.amplitude != amplitude;
}
