// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/interfaces/session_interface.dart';
import '../../../../core/models/model_entry.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/services/voice_clone_service.dart';
import '../../../../core/services/knowledge_base_service.dart';
import '../../../../core/services/file_parser_service.dart';
import '../../../../core/services/asr_service.dart';
import '../../../../core/services/voice_dialog_engine.dart';
import '../../../../core/services/asr_input_service.dart';
import '../../../../core/services/location_service.dart';
import 'realtime_voice_page.dart';
import '../../../../core/storage/database.dart';
import '../../../../core/providers/database_provider.dart';
import 'package:mj_nexus/generated/app_localizations.dart';
import 'package:mj_nexus/generated/app_localizations_en.dart';
// voice_settings_page.dart import removed — _speakText now reads directly from SharedPreferences
import '../../domain/session_manager.dart';
import '../../domain/dialogue_engine.dart';
import '../../../../core/engines/model_inference_engine.dart';
import '../widgets/message_bubble.dart';
import '../../../../core/interfaces/dialogue_interface.dart' show WebSearchResponseData;
import '../../../skill/domain/skill.dart';
import '../../../skill/domain/skill_dispatcher.dart';

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
    final theme = Theme.of(context);
    final isEnabled = color != theme.colorScheme.surfaceContainerHighest;

    return Material(
      type: MaterialType.circle,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 工具菜单项（底部弹出面板中的每行）
class _ToolMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // 图标框
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            // 标题 + 副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isActive ? theme.colorScheme.primary : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 激活指示点
            if (isActive)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
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
  DateTime _lastStreamUpdate = DateTime.now();
  int _nextUpdateThreshold = 32;
  // 会话功能开关状态
  bool _webSearchEnabled = false;
  
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
  StreamSubscription<String>? _voiceIntermediateSub;
  /// 浮窗气泡实时转写文本
  String _voiceBubbleText = '';
  /// 是否正在发送消息（防止重复发送）
  bool _isSending = false;
  // ============ 语音识别结果弹出层 ============
  /// 是否显示语音识别结果弹出层
  bool _showVoiceOverlay = false;
  /// 语音识别结果弹出层文本控制器
  final TextEditingController _voiceOverlayController = TextEditingController();

  // ============ 流式响应优化 ============
  /// 滚动节流标记（避免帧时间回退）
  bool _isScrollingToBottom = false;
  /// 最后滚动时间戳（用于节流）
  DateTime _lastScrollTime = DateTime.now();
  
  // 网络搜索模式
  WebSearchMode _currentSearchMode = WebSearchMode.tavily;
  String _tavilyApiKey = '';
  // 已选择的图片列表（用于多模态）
  List<XFile> _selectedImages = [];
  // 已选择的文件列表
  List<XFile> _selectedFiles = [];
  
  // 推理统计信息
  int? _currentTokenCount;
  double? _currentTokensPerSecond;
  // 当前流式搜索数据（用于 UI 展示搜索引用卡片）
  WebSearchResponseData? _currentWebSearchData;
  
  // Skill 相关状态
  final SkillDispatcher _skillDispatcher = SkillDispatcher();
  String? _activeExpertId; // 当前激活的专家
  final Set<String> _activeMcpTools = {}; // 当前激活的 MCP 工具
  String? _activeKnowledgeBaseId; // 当前关联的知识库 ID
  List<KnowledgeBase> _knowledgeBases = []; // 可用的知识库列表

  // 文件处理状态
  bool _isProcessingFiles = false;
  double _fileProcessingProgress = 0.0;
  String _fileProcessingStatus = '';

  // ============ 上下文使用率追踪 ============
  double _contextUsageRatio = 0.0;
  int _contextUsedTokens = 0;
  int _contextMaxTokens = 0;
  bool _isCompressing = false;
  Timer? _contextPollTimer;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    // 立即初始化会话（关键修复：不再用 addPostFrameCallback 延迟切换）
    _initSession();
    
    // 加载搜索配置（异步）
    _loadSearchConfig();
    
    // 加载知识库列表
    _loadKnowledgeBases();
    
    // 初始化语音对话引擎
    _initVoiceDialogEngine();
    
    // 监听消息列表变化，自动滚动到底部
    _scrollController.addListener(_onScroll);

    // 定时轮询上下文使用率（每 3 秒更新一次进度条）
    _contextPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _updateContextUsage();
    });
  }
  
  @override
  void didUpdateWidget(SessionDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 sessionId 变化时，重新初始化会话
    if (oldWidget.sessionId != widget.sessionId) {
      debugPrint('[SessionDetail] sessionId 变化: ${oldWidget.sessionId} -> ${widget.sessionId}');
      // 重置状态
      _streamingText = '';
      _isGenerating = false;
      _currentTokenCount = null;
      _currentTokensPerSecond = null;
      _currentWebSearchData = null;
      _activeExpertId = null;
      _activeMcpTools.clear();
      _activeKnowledgeBaseId = null;
      _selectedImages = [];
      _selectedFiles = [];
      // 重新初始化会话
      _initSession();
    }
  }
  
  /// 初始化会话：确保 SessionManager 的 activeSession 与当前页面 sessionId 一致
  /// 关键修复：从 addPostFrameCallback 移到 initState，避免第一帧渲染时 activeSession 为 null
  Future<void> _initSession() async {
    try {
      final sessionManager = ref.read(sessionManagerProvider);
      final currentState = sessionManager.currentState;
      
      // 如果当前活跃会话不是我们要的，切换
      if (currentState.activeSession?.id != widget.sessionId) {
        debugPrint('[SessionDetail] 切换到会话: ${widget.sessionId}');
        await sessionManager.switchSession(widget.sessionId);
      } else {
        debugPrint('[SessionDetail] 会话已匹配，跳过切换: ${widget.sessionId}');
      }
      
      if (!mounted) return;
      
      // ✅ 新增：检查并预加载模型，避免用户发消息时才报错"模型未加载"
      final activeSession = sessionManager.currentState.activeSession;
      if (activeSession != null && activeSession.modelId.isNotEmpty) {
        final modelId = activeSession.modelId;
        final engine = globalModelEngine;
        
        if (!engine.isModelReady(modelId)) {
          debugPrint('[SessionDetail] 模型 $modelId 未就绪，尝试预加载...');
          try {
            await engine.loadModel(modelId);
            debugPrint('[SessionDetail] 模型 $modelId 预加载成功');
            // 同步更新 modelProvider 的 isLoaded 状态
            if (mounted) {
              ref.read(modelProvider.notifier).setModelLoaded(modelId, true);
            }
          } catch (e) {
            debugPrint('[SessionDetail] 模型 $modelId 预加载失败: $e');
            // 预加载失败不阻断页面渲染，用户发消息时 dialogue_engine 会再次尝试并给出提示
          }
        } else {
          debugPrint('[SessionDetail] 模型 $modelId 已就绪');
        }
      }
      
      if (!mounted) return;
      
      // 加载之前选中的技能
      if (activeSession != null && activeSession.enabledSkill != null) {
        setState(() {
          _activeExpertId = activeSession.enabledSkill;
        });
      }
      
      if (mounted) {
        // 切换会话后，滚动到底部显示最新消息
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      debugPrint('[SessionDetail] 初始化会话失败: $e');
    }
  }

  /// 自动加载模型（当检测到模型未加载时调用）
  Future<void> _autoLoadModel() async {
    try {
      final sessionManager = ref.read(sessionManagerProvider);
      final activeSession = sessionManager.currentState.activeSession;
      if (activeSession == null || activeSession.modelId.isEmpty) return;

      final modelId = activeSession.modelId;
      final engine = globalModelEngine;

      if (engine.isModelReady(modelId)) return;

      debugPrint('[SessionDetail] 自动加载模型: $modelId');
      await engine.loadModel(modelId);

      if (mounted) {
        ref.read(modelProvider.notifier).setModelLoaded(modelId, true);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('模型加载完成，可以开始对话'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('[SessionDetail] 自动加载模型失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('模型加载失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 退出会话并清理资源：卸载模型 + 返回首页（保留会话在列表中）
  Future<void> _exitAndCleanup() async {
    // ★ 关键修复：在任何异步操作前，同步保存所有需要的引用
    // 避免 await 后 Widget 已销毁导致 ref.read() 抛出 Bad state
    final sessionManager = ref.read(sessionManagerProvider);
    final activeSession = sessionManager.currentState.activeSession;
    final modelId = activeSession?.modelId ?? '';
    final engine = globalModelEngine;
    final bool shouldUnload = modelId.isNotEmpty && engine.isModelReady(modelId);
    
    // 立即导航回首页（不等待模型卸载，避免阻塞UI）
    if (mounted) {
      context.go('/');
    }
    
    // 后台异步卸载模型（不阻塞导航，不依赖 mounted）
    if (shouldUnload) {
      try {
        debugPrint('[SessionDetail] 退出会话，后台卸载模型: $modelId');
        await engine.unloadModel(modelId);
        debugPrint('[SessionDetail] 模型 $modelId 已卸载');
      } catch (e) {
        debugPrint('[SessionDetail] 后台卸载模型失败: $e');
      }
    }
  }
  
  /// 初始化语音对话引擎
  Future<void> _initVoiceDialogEngine() async {
    // 创建语音对话配置
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.initialize();
    
    // ★★★ 添加调试日志 ★★★
    final asrProvider = settingsService.getAsrProvider();
    final ttsProvider = settingsService.getTtsProvider();
    debugPrint('[SessionDetail] _initVoiceDialogEngine: asrProvider=$asrProvider, ttsProvider=$ttsProvider');
    
    // 从 SharedPreferences 读取选中的 Sherpa 模型 ID
    final prefs = await SharedPreferences.getInstance();
    final selectedAsrModelId = prefs.getString('selected_asr_model_id') ?? 'sensevoice-int8';
    final selectedTtsModelId = prefs.getString('selected_tts_model_id') ?? 'melo-zh-en';
    final ttsVoiceId = prefs.getString('tts_voice_id') ?? '0';
    final speakerId = int.tryParse(ttsVoiceId) ?? 0;
    debugPrint('[SessionDetail] selectedAsrModelId=$selectedAsrModelId, selectedTtsModelId=$selectedTtsModelId');
    
    // 获取会话状态获取模型信息
    final sessionState = ref.read(sessionStateProvider);
    final modelId = sessionState.activeSession?.modelId ?? 'default';
    
    // 创建 ASR 和 TTS 服务
    ASRService? asrService;
    TTSService? ttsService;
    
    // 初始化 ASR 服务 - 支持 openai、sherpa、system 三种提供商
    if (asrProvider == 'openai' || asrProvider == 'sherpa' || asrProvider == 'system') {
      ASRProvider asrProviderEnum;
      String? apiKey;
      String? sherpaModelId;
      
      if (asrProvider == 'system') {
        // 系统语音识别：使用 speech_to_text 包，无需 API Key 和模型
        asrProviderEnum = ASRProvider.system;
      } else if (asrProvider == 'openai') {
        asrProviderEnum = ASRProvider.openai;
        apiKey = settingsService.getTavilyApiKey();
      } else {
        // sherpa
        asrProviderEnum = ASRProvider.sherpa;
        apiKey = settingsService.getTavilyApiKey();
        sherpaModelId = selectedAsrModelId;
      }
      
      asrService = ASRService(
        provider: asrProviderEnum,
        apiKey: apiKey,
        sherpaModelId: sherpaModelId,
      );
      // 初始化微信风格语音录入服务
      _asrInputService = AsrInputService(asrService);
      _initAsrInputSubscriptions();
      
      // ★ 优化：预热 ASR 模型，减少首次录音延迟
      // 在后台异步执行，不阻塞页面加载
      _asrInputService!.warmUp();
    }
    
    // 初始化 TTS 服务
    if (ttsProvider == 'openai' || ttsProvider == 'sherpa' || ttsProvider == 'system' || ttsProvider == 'mimo') {
      String? apiKey;
      TTSProvider ttsProviderEnum;
      
      switch (ttsProvider) {
        case 'openai':
          ttsProviderEnum = TTSProvider.openai;
          apiKey = settingsService.getTavilyApiKey();
          break;
        case 'mimo':
          ttsProviderEnum = TTSProvider.mimo;
          apiKey = settingsService.getMimoApiKey();
          break;
        case 'sherpa':
          ttsProviderEnum = TTSProvider.sherpa;
          break;
        case 'system':
        default:
          ttsProviderEnum = TTSProvider.system;
          break;
      }
      
      // 读取语速设置
      final systemTtsSpeed = prefs.getDouble('system_tts_speed') ?? 0.5;
      // 读取 MiMo 音色设置（与 VoiceSettings 共用 tts_voice_id key）
      final mimoVoiceStr = prefs.getString('tts_voice_id') ?? 'Chloe';
      
      // 克隆音色处理：如果 voice ID 以 clone_ 开头，查找参考音频路径
      String? cloneReferenceAudioPath;
      MiMoVoice mimoVoice;
      if (mimoVoiceStr.startsWith('clone_')) {
        // 克隆音色模式 - 从 VoiceCloneService 加载参考音频路径
        try {
          final cloneService = VoiceCloneService();
          final voices = await cloneService.getClonedVoices();
          final cloneId = mimoVoiceStr.substring(6); // 去掉 'clone_' 前缀
          final cloneVoice = voices.where((v) => v.id == cloneId).firstOrNull;
          if (cloneVoice != null && cloneVoice.isReady) {
            cloneReferenceAudioPath = cloneVoice.referenceAudioPath;
          }
        } catch (e) {
          debugPrint('[SessionDetail] Failed to load clone voice: $e');
        }
        mimoVoice = MiMoVoice.Chloe; // 克隆模式下回退默认值
      } else {
        mimoVoice = MiMoVoice.values.firstWhere(
          (v) => v.name == mimoVoiceStr,
          orElse: () => MiMoVoice.Chloe,
        );
      }
      
      ttsService = TTSService(
        provider: ttsProviderEnum,
        apiKey: apiKey,
        mimoVoice: mimoVoice,
        cloneReferenceAudioPath: cloneReferenceAudioPath,
        sherpaModelId: ttsProvider == 'sherpa' ? selectedTtsModelId : null,
        speakerId: speakerId,
        speechRate: ttsProvider == 'system' ? systemTtsSpeed : 1.0,
      );
      
      // ★ 修复：非系统 TTS 时，预热系统 TTS 引擎作为降级备用
      // 避免主 TTS 失败时降级到系统 TTS 还需要等待引擎绑定
      if (ttsProviderEnum != TTSProvider.system) {
        ttsService.warmUpSystemTts();
      }
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
    _voiceIntermediateSub?.cancel();

    _voiceAmplitudeSub = _asrInputService?.amplitudeStream.listen((amp) {
      if (mounted) setState(() => _voiceAmplitude = amp);
    });

    // 最终识别结果 → 弹出微信风格可编辑弹出层
    _voiceResultSub = _asrInputService?.resultStream.listen((text) {
      if (mounted) {
        setState(() {
          _isVoiceRecognizing = false;
          _isVoiceRecording = false;
          _voiceAmplitude = 0.0;
          _voiceBubbleText = '';
        });
        HapticFeedback.lightImpact();
        final trimmed = text.trim();
        if (trimmed.isNotEmpty) {
          _messageController.text = trimmed;
          final l10n = AppLocalizations.of(context) ?? _createFallbackLocalizations();
          _sendMessage(l10n);
        }
      }
    });

    // 中间结果 → 浮窗气泡实时更新（系统ASR支持实时转写）
    _voiceIntermediateSub = _asrInputService?.intermediateTextStream.listen((text) {
      if (mounted && _isVoiceRecording) {
        setState(() {
          _voiceBubbleText = text;
        });
      }
    });

    _voiceErrorSub = _asrInputService?.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _isVoiceRecognizing = false;
          _isVoiceRecording = false;
          _voiceAmplitude = 0.0;
          _voiceBubbleText = '';
        });
        // ★ 修复：增加错误提示时长，确保用户能看到
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  /// 按住说话开始
  Future<void> _onVoiceRecordStart() async {
    if (_isVoiceRecording) return;
    
    // ★★★ 懒加载：如果 ASR 服务尚未初始化，先初始化 ★★★
    if (_asrInputService == null) {
      await _initVoiceDialogEngine();
      if (_asrInputService == null) return; // 初始化失败，放弃
    }
    
    // ★★★ 每次开始录音前，根据最新设置动态创建 ASR 服务 ★★★
    final settingsService = ref.read(settingsServiceProvider);
    await settingsService.initialize();
    final asrProvider = settingsService.getAsrProvider();
    final prefs = await SharedPreferences.getInstance();
    final selectedAsrModelId = prefs.getString('selected_asr_model_id') ?? 'sensevoice-int8';
    
    debugPrint('[SessionDetail] _onVoiceRecordStart: 重新读取设置 asrProvider=$asrProvider');
    _asrInputService!.createAsrService(asrProvider, sherpaModelId: selectedAsrModelId);
    
    // 如果正在识别，打断它
    if (_isVoiceRecognizing) {
      _isVoiceRecognizing = false;
    }
    
    // 停止 TTS 播放
    try {
      final ttsProvider = ref.read(ttsServiceProvider);
      await ttsProvider.stop();
    } catch (_) {
      // ignore: non-critical error
    }
    
    setState(() {
      _isVoiceRecording = true;
      _voiceBubbleText = ''; // 清空浮窗气泡文本
    });
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
    _voiceOverlayController.dispose();
    // 清理语音对话引擎
    _voiceStateSubscription?.cancel();
    _voiceDialogEngine?.dispose();
    // 清理微信语音录入
    _voiceAmplitudeSub?.cancel();
    _voiceResultSub?.cancel();
    _voiceErrorSub?.cancel();
    _voiceIntermediateSub?.cancel();
    _asrInputService?.dispose();
    // 清理缓存的 TTS 服务
    _cachedTtsService?.stop();
    // 清理上下文轮询定时器
    _contextPollTimer?.cancel();
    
    // ✅ 模型卸载已移至 _exitAndCleanup() 中统一处理，避免：
    // 1. dispose 中使用 ref.read() 导致 Bad state 异常
    // 2. 与 _exitAndCleanup() 的双重卸载竞态
    // 3. dispose 后异步回调（.then）执行时 Widget 已销毁
    
    super.dispose();
  }

  /// macOS 兼容：创建备用本地化实例
  /// 当 AppLocalizations.of(context) 返回 null 时使用（IME 触发重建时可能发生）
  AppLocalizations _createFallbackLocalizations() {
    debugPrint('[SessionDetail] ⚠️ AppLocalizations.of(context) 返回 null，使用备用英文本地化');
    return AppLocalizationsEn();
  }

  @override
  Widget build(BuildContext context) {
    // sessionStateProvider 现在是 StateNotifierProvider，直接拿 SessionState，无 AsyncValue
    final sessionState = ref.watch(sessionStateProvider);
    final theme = Theme.of(context);
    // ✅ macOS 兼容：IME 触发重建时 AppLocalizations.of(context) 可能暂时返回 null
    final l10n = AppLocalizations.of(context) ?? _createFallbackLocalizations();

    // 会话初始化已移至 initState._initSession()，不再需要 addPostFrameCallback

    // 使用 PopScope 拦截返回导航，退出时销毁会话并卸载模型
    return PopScope(
      canPop: false, // 拦截返回，手动处理
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _exitAndCleanup();
      },
      child: Scaffold(
        // ★ 修复：移除 appBar 自带的 top padding，改用 SafeArea 包裹整个 body
        // 防止 Android 状态栏遮挡内容
        appBar: _buildAppBar(sessionState, theme, l10n),
        body: SafeArea(
          top: true,
          bottom: false, // 底部由输入区域的 SafeArea 处理
          child: Column(
            children: [
              // Messages area
              Expanded(
                child: sessionState.error != null
                    ? _buildErrorState(sessionState.error!, StackTrace.empty, l10n)
                    : sessionState.activeSession == null
                        ? _buildLoadingState(l10n)
                        : _buildMessagesList(sessionState, theme, l10n),
              ),

              // 语音浮窗气泡（录音中显示）
              if (_isVoiceRecording) _buildVoiceFloatingBubble(theme),

              // 语音识别结果弹出层（微信风格，可编辑）
              if (_showVoiceOverlay) _buildVoiceOverlay(theme, l10n),

              // Input area - 使用 SafeArea 包裹防止底部溢出
              SafeArea(
                top: false,
                child: _buildInputArea(context, theme, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SessionState sessionState, ThemeData theme, AppLocalizations l10n) {
    final session = sessionState.activeSession;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _exitAndCleanup(),
        tooltip: '返回',
      ),
      title: session == null
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
                  modelId: session.modelId,
                  size: 36,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session.name,
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
                          Expanded(
                            child: Text(
                              _isGenerating ? l10n.generating : session.modelId,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
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
              value: 'edit_model_params',
              child: ListTile(
                leading: const Icon(Icons.tune_outlined),
                title: const Text('修改参数'),
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
              // 开启时蓝色（主题主色），未开启时白色
              color: isVoiceEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
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
    debugPrint('[VoiceOutput] 用户切换语音播报: ${session.enableVoiceOutput} → $newEnabled');

    // 更新会话状态
    final sessionManager = ref.read(sessionManagerProvider);
    await sessionManager.updateSessionVoiceOutput(
      session.id,
      newEnabled,
    );

    // 如果开启语音播报，检查 TTS 是否已配置
    if (newEnabled) {
      debugPrint('[VoiceOutput] 语音播报已开启，检查 TTS 配置...');
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.inputAreaMaxWidth(context) ?? double.infinity,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveLayout.chatHorizontalPadding(context),
                  vertical: AppTheme.spacingL,
                ),
                itemCount: messages.length + (_isGenerating ? 1 : 0),
                itemBuilder: (context, index) {
                  // 最后一项：显示实时流式内容（优先显示流式文本，无则显示打字指示器）
                  if (index == messages.length && _isGenerating) {
                    return RepaintBoundary(
                      child: _buildStreamingBubble(theme, state.activeSession?.modelId ?? 'default'),
                    );
                  }

                  final message = messages[index];
                  return RepaintBoundary(
                    child: MessageBubble(
                      message: message,
                      modelId: state.activeSession?.modelId ?? 'default',
                    ),
                  );
                },
              ),
            ),
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
    // 将搜索数据转换为 WebSearchSummary
    WebSearchSummary? searchSummary;
    if (_currentWebSearchData != null) {
      searchSummary = WebSearchSummary(
        keywordCount: _currentWebSearchData!.keywords.length,
        referenceCount: _currentWebSearchData!.results.length,
        keywords: _currentWebSearchData!.keywords,
        results: _currentWebSearchData!.results
            .map((r) => WebSearchResult(
                  title: r['title'] ?? '',
                  url: r['url'] ?? '',
                ))
            .toList(),
      );
    }

    return StreamingMessageBubble(
      streamingText: _streamingText,
      modelId: modelId,
      tokenCount: _currentTokenCount,
      tokensPerSecond: _currentTokensPerSecond,
      webSearchSummary: searchSummary,
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

  /// 构建语音浮窗气泡（录音中显示在输入框上方）
  /// - 实时显示语音转文字结果
  /// - 支持编辑气泡内文字
  /// - 松开后文字填入输入框
  Widget _buildVoiceFloatingBubble(ThemeData theme) {
    final hasText = _voiceBubbleText.isNotEmpty;
    final isCancelled = _voiceDragOffset < -60;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: isCancelled
            ? Colors.grey.shade200
            : theme.colorScheme.primaryContainer,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 44,
            maxHeight: 120,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // 麦克风图标 + 录音动画
              if (isCancelled)
                Icon(Icons.cancel, color: Colors.red, size: 20)
              else
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              // 转写文本区域
              Expanded(
                child: hasText
                    ? Text(
                        _voiceBubbleText,
                        style: TextStyle(
                          color: isCancelled
                              ? Colors.red
                              : theme.colorScheme.onPrimaryContainer,
                          fontSize: 14,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        isCancelled ? '松手取消' : '正在聆听...',
                        style: TextStyle(
                          color: isCancelled
                              ? Colors.red
                              : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
              // 取消提示
              if (isCancelled) ...[
                const SizedBox(width: 8),
                Text(
                  '↑ 取消',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建语音识别结果弹出层（微信风格，可编辑）
  Widget _buildVoiceOverlay(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(Icons.mic, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '语音识别结果',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () {
                    setState(() {
                      _showVoiceOverlay = false;
                      _voiceOverlayController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
          // 可编辑文本区域
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _voiceOverlayController,
                maxLines: null,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: '语音识别内容...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
            ),
          ),
          // 底部按钮栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                // 取消按钮
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showVoiceOverlay = false;
                        _voiceOverlayController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                // 发送按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final text = _voiceOverlayController.text.trim();
                      if (text.isNotEmpty) {
                        _messageController.text = text;
                        _sendMessage(l10n);
                      }
                      setState(() {
                        _showVoiceOverlay = false;
                        _voiceOverlayController.clear();
                      });
                    },
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('发送'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        onTap: () async {
          // 如果尚未初始化，先懒加载再提示用户
          if (_asrInputService == null) {
            // 尝试懒加载语音服务
            await _initVoiceDialogEngine();
            if (mounted && _asrInputService == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('语音服务初始化中，请稍后重试'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
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
  Widget _voiceModeToggleButton({
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
    
    // 获取当前会话的 MCP 服务器
    final sessionState = ref.read(sessionStateProvider);
    final enabledMcpJson = sessionState.activeSession?.enabledMcpServerIds;
    final List<String> enabledMcpIds = enabledMcpJson != null && enabledMcpJson.isNotEmpty
        ? (enabledMcpJson.startsWith('[') 
            ? List<String>.from(jsonDecode(enabledMcpJson))
            : [enabledMcpJson])
        : [];
    
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
                    )                  ).toList(),
                  ),
                  
                  
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

  /// 更新上下文使用率（从当前会话消息列表计算 token 估算，包含 system 消息注入）
  void _updateContextUsage() {
    try {
      final engine = ref.read(dialogueEngineProvider);
      final sessionState = ref.read(sessionStateProvider);
      final messages = sessionState.messages;
      if (messages.isNotEmpty) {
        engine.updateContextUsageWithSystemPrompts(widget.sessionId, messages);
      }
      final usage = engine.getContextUsage();
      if (mounted) {
        setState(() {
          _contextUsedTokens = usage.used;
          _contextMaxTokens = usage.max;
          _contextUsageRatio = usage.ratio.clamp(0.0, 1.0);
        });
      }
    } catch (_) {
      // 非致命错误，忽略
    }
  }

  /// 手动压缩上下文（点击进度条触发）
  Future<void> _compressContext() async {
    if (_isCompressing || _isGenerating) return;
    setState(() => _isCompressing = true);
    try {
      final engine = ref.read(dialogueEngineProvider);
      await engine.autoCompressContext(widget.sessionId);
      // 等待异步操作完成后再更新使用率
      await Future.delayed(const Duration(milliseconds: 200));
      await _updateContextUsageAsync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('上下文已压缩'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      debugPrint('[SessionDetail] 手动压缩失败: $e');
    } finally {
      if (mounted) setState(() => _isCompressing = false);
    }
  }

  /// 异步更新上下文使用率（等待完成）
  Future<void> _updateContextUsageAsync() async {
    try {
      final engine = ref.read(dialogueEngineProvider);
      final sessionState = ref.read(sessionStateProvider);
      final messages = sessionState.messages;
      if (messages.isNotEmpty) {
        await engine.updateContextUsageWithSystemPrompts(widget.sessionId, messages);
      }
      final usage = engine.getContextUsage();
      if (mounted) {
        setState(() {
          _contextUsedTokens = usage.used;
          _contextMaxTokens = usage.max;
          _contextUsageRatio = usage.ratio.clamp(0.0, 1.0);
        });
      }
    } catch (_) {}
  }

  /// WorkBuddy 风格输入区域
  Widget _buildInputArea(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final maxWidth = ResponsiveLayout.inputAreaMaxWidth(context);
    final hPad = ResponsiveLayout.chatHorizontalPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: hPad > 16 ? hPad - 4 : 12,
            vertical: 16, // 增加垂直边距，避免上下贴边
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 文件处理进度条
                if (_isProcessingFiles) _buildFileProcessingIndicator(theme),
                // 已选择的图片预览
                if (_selectedImages.isNotEmpty) _buildImagePreview(theme),
                // 已选择的文件列表
                if (_selectedFiles.isNotEmpty) _buildFilePreview(theme),
                // 输入行
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // + 号按钮：点击后从下往上弹出工具菜单
                    _ToolButton(
                      icon: Icons.add,
                      isActive: false,
                      onTap: () => _showToolMenu(context, theme, l10n),
                      tooltip: '更多工具',
                    ),
                    const SizedBox(width: 4),
                    // 🎤 左侧：语音/键盘切换按钮
                    _buildVoiceModeToggleButton(theme),
                    const SizedBox(width: 8),
                    // 中间：文本输入框 或 语音按钮
                    Expanded(
                      child: _isVoiceMode
                          ? _buildVoiceRecordButton(theme, l10n)
                          : _buildTextInputField(theme, l10n),
                    ),
                    const SizedBox(width: 8),
                    // 上下文使用率进度条（仅文本模式显示，始终可见）
                    if (!_isVoiceMode) _buildContextProgressIndicator(theme),
                    const SizedBox(width: 4),
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
            ),
          ),
        ),
      ),
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
        HapticFeedback.lightImpact();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isVoiceMode
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(
            color: _isVoiceMode
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
          boxShadow: _isVoiceMode
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          _isVoiceMode ? Icons.keyboard : Icons.mic,
          size: 20,
          color: _isVoiceMode
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 上下文使用率圆形进度条（发送按钮左侧）
  /// 默认灰色空环，上下文累加时灰白填充，高阈值时橙/红警告
  /// 点击可手动压缩上下文
  Widget _buildContextProgressIndicator(ThemeData theme) {
    final hasModel = _contextMaxTokens > 0;
    final ratio = hasModel ? _contextUsageRatio.clamp(0.0, 1.0) : 0.0;

    // 颜色渐变：灰(0-60%) → 深灰(60-80%) → 橙(80-90%) → 红(>90%)
    final Color fillColor;
    final Color textColor;
    final Color glowColor;
    if (!hasModel) {
      fillColor = theme.colorScheme.outline.withValues(alpha: 0.3);
      textColor = theme.colorScheme.outline;
      glowColor = Colors.transparent;
    } else if (ratio >= 0.9) {
      fillColor = theme.colorScheme.error;
      textColor = theme.colorScheme.onError;
      glowColor = theme.colorScheme.error.withValues(alpha: 0.4);
    } else if (ratio >= 0.8) {
      fillColor = theme.colorScheme.secondary;
      textColor = theme.colorScheme.onSecondary;
      glowColor = theme.colorScheme.secondary.withValues(alpha: 0.3);
    } else if (ratio >= 0.6) {
      fillColor = theme.colorScheme.onSurfaceVariant;
      textColor = theme.colorScheme.onSurfaceVariant;
      glowColor = Colors.transparent;
    } else {
      fillColor = theme.colorScheme.outline;
      textColor = theme.colorScheme.outline;
      glowColor = Colors.transparent;
    }

    final percentText = hasModel ? (ratio * 100).toInt() : 0;
    final tokenText = hasModel
        ? (_contextMaxTokens >= 1024
            ? '${(_contextUsedTokens / 1024).toStringAsFixed(1)}K/${(_contextMaxTokens / 1024).toStringAsFixed(0)}K'
            : '$_contextUsedTokens/$_contextMaxTokens')
        : '未加载模型';

    return Container(
      decoration: glowColor != Colors.transparent
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: GestureDetector(
        onTap: (hasModel && !_isCompressing) ? _compressContext : null,
        onLongPress: (hasModel && !_isCompressing) ? _compressContext : null,
        child: Tooltip(
          message: _isCompressing
              ? '正在压缩上下文...'
              : hasModel
                  ? '上下文: $tokenText ($percentText%)\n点击或长按压缩上下文'
                  : '模型加载后显示上下文使用率',
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 底层：灰色轨道（始终可见）
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 3,
                  color: theme.colorScheme.surfaceContainerHighest,
                  strokeCap: StrokeCap.round,
                ),
                // 上层：填充进度
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 3,
                  color: fillColor,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                ),
                // 中心：压缩中动画 或 百分比数字
                if (_isCompressing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: hasModel ? textColor : theme.colorScheme.primary,
                      backgroundColor: Colors.transparent,
                    ),
                  )
                else
                  Text(
                    hasModel ? '$percentText' : '–',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
              ],
            ),
          ),
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
    return RepaintBoundary(
      child: Container(
        height: 80,
        padding: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedImages.length,
          itemBuilder: (context, index) {
            final image = _selectedImages[index];
            return RepaintBoundary(
              child: Stack(
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
            ),
          );
        },
      ),
    ),
    );
  }

  /// 文件处理进度指示器
  Widget _buildFileProcessingIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _fileProcessingStatus,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${(_fileProcessingProgress * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _fileProcessingProgress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              minHeight: 4,
            ),
          ),
        ],
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

  /// 灵感一瞬浮动按钮
  Widget _buildInspirationFab(ThemeData theme) {
    return FloatingActionButton(
      onPressed: () => _showInspirationPanel(context, theme),
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      tooltip: '灵感一瞬',
      child: const Icon(Icons.lightbulb_outline),
    );
  }

  /// 显示灵感一瞬面板
  void _showInspirationPanel(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InspirationPanel(theme: theme),
    );
  }

  /// 从下往上弹出工具菜单（类似 QQ 附件菜单效果）
  void _showToolMenu(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              // 工具列表
              _ToolMenuItem(
                icon: Icons.language,
                label: '网络搜索',
                subtitle: _webSearchEnabled
                    ? '已开启：${DialogueEngine.getSearchModeName(_currentSearchMode)}'
                    : '已关闭',
                isActive: _webSearchEnabled,
                onTap: () {
                  Navigator.pop(ctx);
                  _showSearchModeSheet(context);
                },
              ),
              _ToolMenuItem(
                icon: Icons.image,
                label: '上传图片',
                subtitle: '从相册选择或拍照',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImageFromGallery();
                },
              ),
              _ToolMenuItem(
                icon: Icons.attach_file,
                label: '添加文档',
                subtitle: 'PDF、TXT、Markdown',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMultipleFiles();
                },
              ),
              _ToolMenuItem(
                icon: Icons.auto_awesome,
                label: '技能',
                subtitle: _activeExpertId != null ? '已激活' : '专家模式、工具技能',
                isActive: _activeExpertId != null,
                onTap: () {
                  Navigator.pop(ctx);
                  _showSkillBottomSheet(context);
                },
              ),
              _ToolMenuItem(
                icon: Icons.library_books,
                label: '知识库',
                subtitle: _activeKnowledgeBaseId != null ? '已激活' : '从知识库检索内容',
                isActive: _activeKnowledgeBaseId != null,
                onTap: () {
                  Navigator.pop(ctx);
                  _showKnowledgeBaseSheet(context);
                },
              ),
              _ToolMenuItem(
                icon: Icons.record_voice_over_rounded,
                label: '实时语音',
                subtitle: '持续语音对话，支持打断',
                onTap: () {
                  Navigator.pop(ctx);
                  _openRealtimeVoicePage();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
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
                    // ignore: deprecated_member_use
                    groupValue: tempSearchMode,
                    // ignore: deprecated_member_use
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
                    // ignore: deprecated_member_use
                    groupValue: tempSearchMode,
                    // ignore: deprecated_member_use
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
                    // ignore: deprecated_member_use
                    groupValue: tempSearchMode,
                    // ignore: deprecated_member_use
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

  void _openRealtimeVoicePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealtimeVoicePage(sessionId: widget.sessionId),
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
  /// 限制：llama.cpp 只支持图片 + 文本文件（pdf/txt/md）
  Future<void> _pickMultipleFiles() async {
    debugPrint('DEBUG: _pickMultipleFiles called');
    
    try {
      // 只允许图片 + 文本文件（pdf/txt/md）
      const typeGroup = XTypeGroup(
        label: '图片和文档',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'pdf', 'txt', 'md'],
      );

      debugPrint('DEBUG: Calling openFiles...');
      
      // 使用 file_selector 选择文件
      final files = await openFiles(acceptedTypeGroups: [typeGroup]);

      debugPrint('DEBUG: openFiles returned ${files.length} files');
      
      if (files.isNotEmpty) {
        int imageCount = 0;
        int fileCount = 0;
        
        // llama.cpp 支持的文件类型
        const supportedImageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'];
        const supportedDocExts = ['pdf', 'txt', 'md'];
        
        setState(() {
          for (final file in files) {
            final ext = file.name.toLowerCase().split('.').last;
            // 图片文件添加到 _selectedImages
            if (supportedImageExts.contains(ext)) {
              debugPrint('DEBUG: Adding image - name: ${file.name}');
              _selectedImages.add(file);
              imageCount++;
            } else if (supportedDocExts.contains(ext)) {
              // 文本文件添加到 _selectedFiles（pdf/txt/md）
              debugPrint('DEBUG: Adding document - name: ${file.name}');
              _selectedFiles.add(file);
              fileCount++;
            } else {
              // 不支持的文件类型，跳过
              debugPrint('DEBUG: Skipping unsupported file - name: ${file.name}');
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

  /// 从相册选择图片（使用 image_picker）
  Future<void> _pickImageFromGallery() async {
    debugPrint('DEBUG: _pickImageFromGallery called');
    
    try {
      // 让用户选择图片来源：相册 or 拍照
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) {
        debugPrint('DEBUG: User cancelled image source selection');
        return;
      }

      // 使用 image_picker 选择图片
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
        debugPrint('DEBUG: Added image: ${pickedFile.name}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已选择图片: ${pickedFile.name}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法选择图片: $e'),
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

    // ★ 防重复发送：如果正在发送中，则不重复调用
    if (_isSending) {
      debugPrint('[SessionDetail] ⚠️ _sendMessage 正在执行中，跳过重复调用');
      return;
    }
    _isSending = true;

    // 确保会话已加载完成
    final currentSessionState = ref.read(sessionStateProvider);
    if (currentSessionState.activeSession == null) {
      debugPrint('[SessionDetailPage] ⚠️ activeSession is null, waiting for session to load...');
      // 等待会话加载完成
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        final state = ref.read(sessionStateProvider);
        if (state.activeSession != null) break;
      }
      final recheckState = ref.read(sessionStateProvider);
      if (recheckState.activeSession == null) {
        debugPrint('[SessionDetailPage] ❌ Session still not loaded after waiting');
        _isSending = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('会话加载中，请稍后再试')),
          );
        }
        return;
      }
    }

    // ★★★ 自动上下文压缩：使用率超过 90% 时在发送前自动压缩 ★★★
    if (_contextUsageRatio >= 0.9 && !_isCompressing) {
      debugPrint('[SessionDetail] 上下文使用率 ${( _contextUsageRatio * 100).toInt()}% ≥ 90%，自动压缩...');
      setState(() => _isCompressing = true);
      try {
        final engine = ref.read(dialogueEngineProvider);
        await engine.autoCompressContext(widget.sessionId);
        // 等待异步操作完成后再更新使用率
        await Future.delayed(const Duration(milliseconds: 300));
        await _updateContextUsageAsync();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('上下文已自动压缩'), duration: Duration(seconds: 2)),
          );
        }
      } catch (e) {
        debugPrint('[SessionDetail] 自动压缩失败: $e');
      } finally {
        if (mounted) setState(() => _isCompressing = false);
      }
    }

    // 检查是否需要位置信息
    final locationService = LocationService.instance;
    String? locationContext;
    
    if (locationService.needsLocation(text)) {
      debugPrint('[位置服务] 用户消息需要位置信息: $text');
      
      // 检查权限状态
      final permissionStatus = await locationService.checkPermission();
      
      if (permissionStatus == LocationPermissionStatus.denied) {
        // 权限被拒绝，提示用户授权
        final shouldRequest = await _showLocationPermissionDialog();
        if (shouldRequest == true) {
          final newStatus = await locationService.requestPermission();
          if (newStatus == LocationPermissionStatus.whileInUse || 
              newStatus == LocationPermissionStatus.always) {
            final location = await locationService.getCurrentLocation();
            if (location != null) {
              locationContext = await locationService.buildLocationContext();
              debugPrint('[位置服务] 已获取位置: ${location.shortDescription}');
            }
          } else if (newStatus == LocationPermissionStatus.deniedForever) {
            // 永久拒绝，引导用户去设置
            await _showLocationSettingsDialog();
          }
        }
      } else if (permissionStatus == LocationPermissionStatus.whileInUse ||
                 permissionStatus == LocationPermissionStatus.always) {
        // 已授权，获取位置
        final location = await locationService.getCurrentLocation();
        if (location != null) {
          locationContext = await locationService.buildLocationContext();
          debugPrint('[位置服务] 已获取位置: ${location.shortDescription}');
        }
      } else if (permissionStatus == LocationPermissionStatus.serviceDisabled) {
        // 位置服务未开启，提示用户
        await _showLocationServiceDisabledDialog();
      }
    }
    
    // ★★★ 新消息来时，立即停止当前 TTS 播放 ★★★
    // 必须同时停止 Riverpod TTS 和缓存的 TTS 实例（两者可能是不同对象）
    try {
      // 停止 Riverpod 提供的 TTS 服务
      final ttsProvider = ref.read(ttsServiceProvider);
      await ttsProvider.stop();
    } catch (_) {
      // ignore: non-critical error
    }
    // 停止缓存的 TTS 服务实例（实际播放音频的实例）
    try {
      await _cachedTtsService?.stop();
    } catch (_) {
      // ignore: non-critical error
    }
    // ★ 重置播报状态，确保新 AI 回复可以正常触发语音播报
    _isSpeaking = false;

    // 多模态检查：如果用户选择了图片，仅本地模型需要检查是否支持视觉
    final hasImages = _selectedImages.isNotEmpty;
    if (hasImages) {
      final modelState = ref.read(modelProvider);
      final sessionState = ref.read(sessionStateProvider);
      final modelId = sessionState.activeSession?.modelId ?? '';

      if (modelId.isNotEmpty) {
        final model = modelState.models.where((m) => m.id == modelId).firstOrNull;
        // 仅当是本地模型且明确不支持多模态时才阻止
        // 远程/Ollama 模型：model.supportsMultimodal 默认返回 true，不会走到这里
        if (model != null && model.isLocal && !model.supportsMultimodal) {
          _isSending = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('当前本地模型不支持图片输入，请使用带 "vl/vision" 关键字的视觉模型，或移除图片'),
              duration: Duration(milliseconds: 2000),
            ),
          );
          return;
        }
      }
      // 远程模型 / 找不到模型 → 允许发送，让 API 端决定
      debugPrint('[多模态] 图片处理：直接将图片 base64 发给模型 API');
    }
    
    // 检查文件上传 - 文档解析使用内置服务，无需额外插件
    final hasFiles = _selectedFiles.isNotEmpty;
    if (hasFiles) {
      debugPrint('[多模态] 文档使用内置解析服务处理');
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
      _currentWebSearchData = null; // 清空搜索数据
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
          if (ext == 'png') {
            mimeType = 'image/png';
          } else if (ext == 'gif') {
            mimeType = 'image/gif';
          } else if (ext == 'webp') {
            mimeType = 'image/webp';
          } else if (ext == 'bmp') {
            mimeType = 'image/bmp';
          }
          
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
      final totalFiles = filesToSend.length;
      
      // 设置处理状态
      setState(() {
        _isProcessingFiles = true;
        _fileProcessingProgress = 0.0;
        _fileProcessingStatus = '正在处理文件...';
      });
      
      for (int i = 0; i < filesToSend.length; i++) {
        final file = filesToSend[i];
        final progress = (i + 1) / totalFiles;
        
        // 更新进度
        setState(() {
          _fileProcessingProgress = progress * 0.8; // 80% 用于文件解析
          _fileProcessingStatus = '正在解析 ${file.name}...';
        });
        
        debugPrint('[DEBUG] 处理文件: ${file.name} (${i+1}/$totalFiles)');
        try {
          // 获取文件的完整路径
          final filePath = file.path;
          debugPrint('[DEBUG] file.path = "$filePath"');
          
          if (filePath.isNotEmpty) {
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
      
      // 文件处理完成
      setState(() {
        _isProcessingFiles = false;
        _fileProcessingProgress = 1.0;
      });
      
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
            debugPrint('[知识库RAG] 上下文构建完成，长度: ${knowledgeContext.length}');
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
      // locationContext = 位置信息上下文（由推理引擎以 system 消息形式注入）
      await for (final response in dialogueEngine.streamResponse(
        widget.sessionId,
        finalContent,
        enableWebSearch: _webSearchEnabled,
        knowledgeContext: knowledgeContext,
        locationContext: locationContext,
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
          // 更新搜索数据（首次拿到搜索结果时）
          if (response.webSearchData != null && _currentWebSearchData == null) {
            _currentWebSearchData = response.webSearchData;
          }
          // ✅ 优化：减少 setState 频率，防止 ANR（每 50ms 或 32 字符更新一次）
          final now = DateTime.now();
          final shouldUpdateByTime = now.difference(_lastStreamUpdate).inMilliseconds >= 50;
          final shouldUpdateByLength = _streamingText.length >= _nextUpdateThreshold;
          final hasNewStats = _currentTokenCount != null || _currentTokensPerSecond != null;
          
          if (shouldUpdateByTime || shouldUpdateByLength || hasNewStats) {
            if (shouldUpdateByLength) {
              _nextUpdateThreshold = _streamingText.length + 32; // 每 32 字符触发
            }
            _lastStreamUpdate = now;
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

          // ★ 修复：TTS 播报改为非阻塞，避免 TTS 卡死导致整个会话 UI 冻住
          // 不使用 await，让 TTS 在后台执行，主流程立即继续
          debugPrint('[SessionDetail] 流式响应完成，触发 TTS 播报: 响应长度=${response.content.length}');
          _playAssistantVoice(response.content);
        }
      }
    } catch (e, stack) {
      debugPrint('[SessionDetail] ❌ _sendMessage 错误: $e');
      debugPrint('[SessionDetail] ❌ _sendMessage 堆栈: $stack');
      if (mounted) {
        try {
          final errMsg = e.toString();
          // ✅ 识别不同类型的错误，给出对应的诊断建议
          String displayMessage;
          
          if (errMsg.contains('401')) {
            // 401 认证错误
            displayMessage = 'API 认证失败 (401)：请检查 API Key 是否正确、是否过期';
          } else if (errMsg.contains('未加载') || errMsg.contains('not loaded') || errMsg.contains('未就绪')) {
            // 本地模型未加载 → 自动尝试加载
            displayMessage = '模型正在加载中，请稍候...';
            _autoLoadModel();
          } else if (errMsg.contains('API Key 为空') || errMsg.contains('apiKey 为空')) {
            // API Key 未设置
            displayMessage = 'API Key 未设置，请到模型设置中添加 API Key';
          } else if (errMsg.contains('网络') || errMsg.contains('network') || errMsg.contains('connection')) {
            // 网络错误
            displayMessage = '网络连接失败，请检查网络并重试';
          } else {
            displayMessage = '发送消息失败: ${errMsg.length > 50 ? '${errMsg.substring(0, 50)}...' : errMsg}';
          }
          
          if (mounted && context.mounted) {
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
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('请在 IDE 控制台查看详细调试日志 [ModelInferenceEngine]'),
                        duration: Duration(milliseconds: 1500),
                      ),
                    );
                  }
                },
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            
            // ✅ 修复：有 action 的 SnackBar 也需要在 1.5s 后自动关闭
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            });
          }
        } catch (innerError) {
          // ★ macOS 安全保护：context 可能已失效（IMK 框架干扰）
          debugPrint('[SessionDetail] ⚠️ 错误处理本身失败 (macOS 兼容): $innerError');
        }
      }
    } finally {
      _isSending = false;
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _streamingText = ''; // 清空流式文本（已保存到数据库）
          // 保留统计信息用于显示
        });
      }
      // 推理完成后刷新上下文使用率
      _updateContextUsage();
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
  /// 根据用户在语音设置中的选择，使用对应的 TTS 引擎
  /// 不播报 reasoning/thinking 内容，只播报实际回答
  /// 是否正在播报语音（防止重叠调用导致界面卡死）
  bool _isSpeaking = false;
  /// 缓存的 TTS 服务实例（避免每次创建新实例导致系统TTS绑定丢失）
  TTSService? _cachedTtsService;
  /// 缓存的 TTS 设置指纹（用于检测设置是否变化）
  String _ttsSettingsFingerprint = '';

  Future<void> _playAssistantVoice(String text) async {
    debugPrint('[VoiceOutput] ========== TTS 播报流程开始 ==========');
    debugPrint('[VoiceOutput] 原始文本长度: ${text.length}, 前100字: ${text.length > 100 ? text.substring(0, 100) : text}');
    
    if (text.isEmpty) {
      debugPrint('[VoiceOutput] ❌ 文本为空，直接返回');
      return;
    }
    
    // 防止重叠调用
    if (_isSpeaking) {
      debugPrint('[VoiceOutput] ⚠️ 正在播报中，跳过本次请求');
      return;
    }

    // ★ 全局超时保护：整个 TTS 流程最多 60 秒，防止引擎卡死
    try {
      debugPrint('[VoiceOutput] 调用 _doPlayAssistantVoice（60s超时保护）');
      await _doPlayAssistantVoice(text).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('[VoiceOutput] ⚠️ TTS 全局超时（60s），强制结束');
          _isSpeaking = false;
        },
      );
      debugPrint('[VoiceOutput] ========== TTS 播报流程正常结束 ==========');
    } catch (e, stack) {
      debugPrint('[VoiceOutput] ❌ TTS 异常: $e');
      debugPrint('[VoiceOutput] 堆栈: $stack');
      _isSpeaking = false;
    }
  }

  /// 实际的 TTS 播报逻辑（被 _playAssistantVoice 超时包裹）
  Future<void> _doPlayAssistantVoice(String text) async {
    // ★★★ 清洗 reasoning 内容，只保留实际回答 ★★★
    String cleanedText = _cleanReasoningForTTS(text);
    debugPrint('[VoiceOutput] [步骤1] 文本清洗: 原始${text.length}字 → 清洗后${cleanedText.length}字');
    debugPrint('[VoiceOutput] [步骤1] 清洗后前100字: ${cleanedText.length > 100 ? cleanedText.substring(0, 100) : cleanedText}');
    if (cleanedText.trim().isEmpty) {
      debugPrint('[VoiceOutput] ❌ 清洗后文本为空，跳过播报');
      return;
    }

    // 获取当前会话状态
    final sessionState = ref.read(sessionStateProvider);
    final session = sessionState.activeSession;
    debugPrint('[VoiceOutput] [步骤2] 会话状态: session=${session != null ? "存在" : "null"}, enableVoiceOutput=${session?.enableVoiceOutput}');

    // 检查是否开启了语音播报
    if (session == null) {
      debugPrint('[VoiceOutput] ❌ activeSession 为 null，跳过播报');
      return;
    }
    if (!session.enableVoiceOutput) {
      debugPrint('[VoiceOutput] ❌ session.enableVoiceOutput=false，语音播报未开启');
      return;
    }

    try {
      // ★ 修复：直接从 SharedPreferences 读取 TTS 设置，
      // 避免 voiceSettingsProvider 异步加载竞态导致读到默认值 'system'
      final settingsService = ref.read(settingsServiceProvider);
      await settingsService.initialize();
      final prefs = await SharedPreferences.getInstance();
      var ttsProvider = settingsService.getTtsProvider();
      final ttsModelId = prefs.getString('selected_tts_model_id') ?? 'melo-zh-en';
      final ttsVoice = prefs.getString('tts_voice_id') ?? '0';
      final ttsSpeed = prefs.getDouble('system_tts_speed') ?? 0.5;

      debugPrint('[VoiceOutput] [步骤3] SharedPreferences 读取完成:');
      debugPrint('[VoiceOutput]   tts_provider = "$ttsProvider"');
      debugPrint('[VoiceOutput]   selected_tts_model_id = "$ttsModelId"');
      debugPrint('[VoiceOutput]   tts_voice_id = "$ttsVoice"');
      debugPrint('[VoiceOutput]   system_tts_speed = $ttsSpeed');

      // ★★★ 移动端 OOM 保护 ★★★
      // 使用本地 LLM 模型时，原生内存已被大量占用（可达 50GB+），
      // 再用 Sherpa TTS 加载另一个 ONNX 模型会导致系统 OOM kill。
      // 移动端自动降级为系统 TTS（不占用额外原生内存）。
      final isMobile = Platform.isAndroid || Platform.isIOS;
      final isLocalModel = session.modelId.startsWith('local-') || 
                           session.modelId.startsWith('ffi-') ||
                           session.modelId.contains('gguf');
      debugPrint('[VoiceOutput] [步骤4] OOM检测: isMobile=$isMobile, isLocalModel=$isLocalModel, modelId=${session.modelId}');
      if (isMobile && isLocalModel && ttsProvider == 'sherpa') {
        debugPrint('[VoiceOutput] ⚠️ 移动端+本地模型：Sherpa TTS 降级为系统 TTS（防止 OOM）');
        ttsProvider = 'system';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💡 已自动切换为系统语音（节省内存）'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }

      debugPrint('[VoiceOutput] [步骤5] 最终 TTS 引擎: $ttsProvider, 模型: $ttsModelId, 音色: $ttsVoice, 语速: $ttsSpeed');

      // ★ 修复：为 MiMo TTS 传入 apiKey 和 mimoVoice
      String? ttsApiKey;
      MiMoVoice mimoVoice = MiMoVoice.Chloe;
      String? cloneRefAudioPath;
      if (ttsProvider == 'mimo') {
        // ★ 修复：使用异步方法读取 API Key（支持加密存储）
        ttsApiKey = await settingsService.getMimoApiKeyAsync();
        debugPrint('[VoiceOutput] [步骤6] MiMo API Key 读取结果: ${ttsApiKey != null ? "已配置(${ttsApiKey.length}字符)" : "null"}');
        if (ttsApiKey == null || ttsApiKey.isEmpty) {
          debugPrint('[VoiceOutput] ⚠️ MiMo API Key 未配置，降级为系统 TTS');
          ttsProvider = 'system';
        } else {
          // 读取用户选择的 MiMo 音色
          final mimoVoiceStr = ttsVoice.isNotEmpty ? ttsVoice : 'Chloe';
          if (mimoVoiceStr.startsWith('clone_')) {
            // 克隆音色模式
            try {
              final cloneService = VoiceCloneService();
              final voices = await cloneService.getClonedVoices();
              final cloneId = mimoVoiceStr.substring(6);
              final cloneVoice = voices.where((v) => v.id == cloneId).firstOrNull;
              if (cloneVoice != null && cloneVoice.isReady) {
                cloneRefAudioPath = cloneVoice.referenceAudioPath;
              }
            } catch (e) {
              debugPrint('[VoiceOutput] Failed to load clone voice: $e');
            }
            debugPrint('[VoiceOutput] [步骤6] MiMo 克隆音色: cloneId=${mimoVoiceStr.substring(6)}, audioPath=$cloneRefAudioPath');
          } else {
            mimoVoice = MiMoVoice.values.firstWhere(
              (v) => v.name == mimoVoiceStr,
              orElse: () => MiMoVoice.Chloe,
            );
          }
          debugPrint('[VoiceOutput] [步骤6] MiMo 音色: $mimoVoice (原始值: "$ttsVoice")');
        }
      }

      // ★ 优化：使用缓存的 TTS 服务实例，避免每次创建新实例导致系统TTS绑定丢失
      final settingsFingerprint = '$ttsProvider|$ttsModelId|$ttsVoice|$ttsSpeed|$ttsApiKey';
      final needRecreate = _cachedTtsService == null || _ttsSettingsFingerprint != settingsFingerprint;
      debugPrint('[VoiceOutput] [步骤7] TTS服务缓存: cached=${_cachedTtsService != null}, fingerprint匹配=${_ttsSettingsFingerprint == settingsFingerprint}, 需要重建=$needRecreate');
      if (needRecreate) {
        debugPrint('[VoiceOutput] [步骤7] 创建 TTSService: provider=$_getTTSProvider(ttsProvider), apiKey=${ttsApiKey != null ? "有" : "无"}, mimoVoice=$mimoVoice, speechRate=$ttsSpeed');
        _cachedTtsService = TTSService(
          provider: _getTTSProvider(ttsProvider),
          apiKey: ttsApiKey,
          mimoVoice: mimoVoice,
          cloneReferenceAudioPath: cloneRefAudioPath,
          speechRate: ttsSpeed,
          sherpaModelId: ttsProvider == 'sherpa' ? ttsModelId : null,
          speakerId: ttsVoice.isNotEmpty ? int.tryParse(ttsVoice) ?? 0 : 0,
        );
        _ttsSettingsFingerprint = settingsFingerprint;
        // 仅 system TTS 需要预热（MiMo/OpenAI/Sherpa 不需要系统 TTS 绑定）
        if (ttsProvider == 'system') {
          debugPrint('[VoiceOutput] [步骤7] 开始预热系统 TTS...');
          await _cachedTtsService!.warmUpSystemTts();
          debugPrint('[VoiceOutput] [步骤7] 系统 TTS 预热完成');
        } else {
          debugPrint('[VoiceOutput] [步骤7] 非 system TTS ($ttsProvider)，跳过系统 TTS 预热');
        }
      }

      // 使用 speakLongText 自动分句分块，避免长文本卡死
      debugPrint('[VoiceOutput] [步骤8] 调用 speakLongText, 文本长度: ${cleanedText.length}');
      final completed = await _cachedTtsService!.speakLongText(cleanedText);
      debugPrint('[VoiceOutput] [步骤8] speakLongText 返回: completed=$completed');
      if (!completed) {
        debugPrint('[VoiceOutput] ⚠️ speakLongText 返回 false（可能被停止）');
      }
      debugPrint('[VoiceOutput] ✅ 语音播报已完成: completed=$completed');
    } catch (e, stack) {
      debugPrint('[VoiceOutput] ❌ 语音播报失败: $e');
      debugPrint('[VoiceOutput] 堆栈: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('语音播报失败: ${e.toString().split('\n').first}'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: '设置',
              textColor: Colors.white,
              onPressed: () => context.push('/settings/voice'),
            ),
          ),
        );
      }
    } finally {
      _isSpeaking = false;
      debugPrint('[VoiceOutput] [finally] _isSpeaking 已重置为 false');
    }
  }

  /// 清洗 TTS 文本，移除 reasoning/thinking 内容
  /// 移除 <|channel|>thought...<|channel|>、Thinking Process: 等标签
  String _cleanReasoningForTTS(String text) {
    if (text.isEmpty) return text;

    String cleaned = text;

    // 移除 <|channel>thought...<|channel|> 格式（Qwen 系列）
    // 匹配 <|channel|>thought 开始到 <|channel|> 结束的内容
    final thoughtPattern = RegExp(r'<\|channel\|>thought[\s\S]*?<\|channel\|>');
    cleaned = cleaned.replaceAll(thoughtPattern, '');

    // 移除 <|channel|> 单独出现的情况
    cleaned = cleaned.replaceAll(RegExp(r'<\|channel\|>'), '');

    // 移除 Thinking Process: 开头的整段
    cleaned = cleaned.replaceAll(RegExp(r'Thinking Process:[\s\S]*?(?=\n\n|\n[A-Z]|$)'), '');

    // 移除 <thinking>...</thinking> 标签
    cleaned = cleaned.replaceAll(RegExp(r'<thinking>[\s\S]*?</thinking>'), '');

    // 移除其他 XML 格式标签 <|...|>
    cleaned = cleaned.replaceAll(RegExp(r'<\|[^|]+\|>'), '');

    // 清理多余空行
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned.trim();
  }

  /// 将字符串转换为 TTSProvider 枚举
  TTSProvider _getTTSProvider(String provider) {
    switch (provider) {
      case 'sherpa':
        return TTSProvider.sherpa;
      case 'openai':
        return TTSProvider.openai;
      case 'mimo':
        return TTSProvider.mimo;
      case 'system':
      default:
        return TTSProvider.system;
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
      case 'edit_model_params':
        _showModelParamsDialog(l10n);
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


  // ─────────────────────────────────────────────────────────────────
  //  「修改参数」Dialog：模型推理参数 + 系统提示词（人设）
  // ─────────────────────────────────────────────────────────────────

  void _showModelParamsDialog(AppLocalizations l10n) {
    final sessionState = ref.read(sessionStateProvider);
    final session = sessionState.activeSession;
    if (session == null) return;

    final modelState = ref.read(modelProvider);
    final model = modelState.models.where((m) => m.id == session.modelId).firstOrNull;

    showDialog(
      context: context,
      builder: (dialogContext) => _ModelParamsDialog(
        session: session,
        model: model,
        sessionId: widget.sessionId,
        onSaved: (newSystemPrompt) {
          // 系统提示词已通过 SessionConfig 保存，此处可以额外提示
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('参数已更新，将在下次对话时生效')),
            );
          }
        },
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

  /// 显示位置权限请求对话框
  Future<bool?> _showLocationPermissionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Text('需要位置权限'),
          ],
        ),
        content: const Text(
          '您的问题可能需要位置信息来回答。是否允许应用获取您的位置信息？\n\n位置信息仅用于回答您的问题，不会用于其他用途。',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('拒绝'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('允许'),
          ),
        ],
      ),
    );
  }

  /// 显示位置服务未开启对话框
  Future<void> _showLocationServiceDisabledDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('位置服务未开启'),
          ],
        ),
        content: const Text(
          '您的设备位置服务已关闭。请在系统设置中开启位置服务后重试。',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('去设置'),
          ),
        ],
      ),
    );

    if (result == true) {
      await LocationService.instance.openLocationSettings();
    }
  }

  /// 显示位置权限永久拒绝对话框
  Future<void> _showLocationSettingsDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_disabled, color: Colors.red),
            SizedBox(width: 8),
            Text('位置权限被拒绝'),
          ],
        ),
        content: const Text(
          '您已永久拒绝位置权限。请在系统设置中手动开启位置权限。',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('去设置'),
          ),
        ],
      ),
    );

    if (result == true) {
      await LocationService.instance.openAppSettings();
    }
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
                // ignore: deprecated_member_use
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
          final time = msg.createdAt.toString().substring(0, 19);
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

// ════════════════════════════════════════════════════════════════════════════
//  「修改参数」对话框 —— 含人设 + 模型参数，保存后立即生效
// ════════════════════════════════════════════════════════════════════════════

class _ModelParamsDialog extends ConsumerStatefulWidget {
  final dynamic session; // ChatSession / SessionEntry
  final ModelEntry? model;
  final String sessionId;
  final void Function(String? newSystemPrompt) onSaved;

  const _ModelParamsDialog({
    required this.session,
    required this.model,
    required this.sessionId,
    required this.onSaved,
  });

  @override
  ConsumerState<_ModelParamsDialog> createState() => _ModelParamsDialogState();
}

class _ModelParamsDialogState extends ConsumerState<_ModelParamsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _systemPromptController = TextEditingController();
  late LocalModelParams _params;
  late RemoteModelConfig? _remoteConfig;
  bool _isSaving = false;

  bool get _isLocalModel => widget.model?.isLocal == true;
  bool get _isRemoteModel => widget.model?.isRemote == true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 初始化系统提示词（优先读 session 的，再读 model 的）
    final sessionPrompt = widget.session?.systemPrompt as String?;
    final modelPrompt = widget.model?.localParams?.systemPrompt;
    _systemPromptController.text = sessionPrompt ?? modelPrompt ?? '';
    // 初始化本地模型参数
    _params = widget.model?.localParams ?? const LocalModelParams();
    // 初始化远程模型参数
    _remoteConfig = widget.model?.remoteConfig;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      insetPadding: isWide
          ? EdgeInsets.symmetric(
              horizontal: (screenWidth - 560) / 2,
              vertical: 40,
            )
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 标题栏 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(
                      Icons.tune_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '修改参数',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (widget.model != null)
                          Text(
                            widget.model!.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Tab 栏 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TabBar(
                controller: _tabController,
                labelStyle: theme.textTheme.labelLarge,
                unselectedLabelStyle: theme.textTheme.labelLarge,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                tabs: const [
                  Tab(text: '人设 & 提示词'),
                  Tab(text: '推理参数'),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── 内容区 ──
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSystemPromptTab(theme),
                  _buildParamsTab(theme),
                ],
              ),
            ),

            // ── 底部按钮 ──
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveAll,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 16),
                    label: const Text('保存并生效'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 人设 & 系统提示词 Tab ──
  Widget _buildSystemPromptTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 说明文字
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '设置当前会话专属的系统提示词（人设），让 AI 扮演特定角色。\n例如：「你是萝莉音调的可爱助手」「你是女王大人，说话冷漠有气场」',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 快速人设预设
          Text(
            '快速选择',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kPersonaPresets.map((preset) {
              return ActionChip(
                label: Text(preset['label']!),
                onPressed: () {
                  _systemPromptController.text = preset['prompt']!;
                },
                padding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: theme.textTheme.labelSmall,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 系统提示词输入框
          Text(
            '自定义提示词',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _systemPromptController,
            maxLines: 7,
            decoration: InputDecoration(
              hintText: '输入系统提示词，例如：你是一位专业的技术作家，善于用通俗语言解释复杂概念...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_systemPromptController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _systemPromptController.clear()),
                  icon: const Icon(Icons.clear, size: 14),
                  label: const Text('清除'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 推理参数 Tab ──
  Widget _buildParamsTab(ThemeData theme) {
    if (_isLocalModel) {
      return _buildLocalParamsContent(theme);
    } else if (_isRemoteModel) {
      return _buildRemoteParamsContent(theme);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '当前会话未绑定模型，无法配置参数',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalParamsContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 温度
          _ParamRow(
            label: '温度',
            tooltip: '控制输出随机性。越低越确定（0=完全确定），越高越发散（建议创意 0.8，代码 0.2）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _params.temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 200,
                    onChanged: (v) => setState(() => _params = _params.copyWith(temperature: v)),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    _params.temperature.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Top P
          _ParamRow(
            label: 'Top P',
            tooltip: '核采样：从累积概率达到 P 的词中选择（0.9 = 高质量，0.5 = 保守）',
            child: Row(
              children: [
                Switch(
                  value: _params.topPEnabled,
                  onChanged: (v) => setState(() => _params = _params.copyWith(topPEnabled: v)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _params.topP,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    onChanged: _params.topPEnabled
                        ? (v) => setState(() => _params = _params.copyWith(topP: v))
                        : null,
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    _params.topP.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Top K
          _ParamRow(
            label: 'Top K',
            tooltip: '只从概率最高的 K 个词中采样。值越小越保守，值越大越发散',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _params.topK.toDouble(),
                    min: 1,
                    max: 200,
                    divisions: 199,
                    onChanged: (v) => setState(() => _params = _params.copyWith(topK: v.round())),
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${_params.topK}',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 重复惩罚
          _ParamRow(
            label: '重复惩罚',
            tooltip: '防止重复内容。1.0 = 无惩罚，1.2 表示重复词概率降低 20%',
            child: Row(
              children: [
                Switch(
                  value: _params.repeatPenaltyEnabled,
                  onChanged: (v) => setState(() => _params = _params.copyWith(repeatPenaltyEnabled: v)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _params.repeatPenalty,
                    min: 1.0,
                    max: 2.0,
                    divisions: 100,
                    onChanged: _params.repeatPenaltyEnabled
                        ? (v) => setState(() => _params = _params.copyWith(repeatPenalty: v))
                        : null,
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    _params.repeatPenalty.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // GPU 层数
          _ParamRow(
            label: 'GPU 层数',
            tooltip: '卸载到 GPU 的模型层数。99 = 全部卸载（最快），0 = 纯 CPU（最慢）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _params.gpuLayers.toDouble(),
                    min: 0,
                    max: 99,
                    divisions: 99,
                    onChanged: (v) => setState(() => _params = _params.copyWith(gpuLayers: v.round())),
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${_params.gpuLayers}',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // CPU 线程
          _ParamRow(
            label: 'CPU 线程',
            tooltip: '推理使用的 CPU 线程数，建议等于 CPU 核心数',
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: _params.cpuThreads > 1
                      ? () => setState(() => _params = _params.copyWith(cpuThreads: _params.cpuThreads - 1))
                      : null,
                ),
                Text('${_params.cpuThreads}', style: theme.textTheme.bodyMedium),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _params.cpuThreads < 64
                      ? () => setState(() => _params = _params.copyWith(cpuThreads: _params.cpuThreads + 1))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 快速模式（思考模式）
          _ParamRow(
            label: '思考模式',
            tooltip: '启用后，模型将输出思考过程（Chain-of-Thought），适合数学、逻辑推理等复杂问题。关闭则为快速模式，直接给出答案',
            child: Row(
              children: [
                Expanded(
                  child: Switch(
                    value: _params.enableReasoning,
                    onChanged: (v) => setState(() => _params = _params.copyWith(enableReasoning: v)),
                  ),
                ),
                Text(
                  _params.enableReasoning ? '开启' : '关闭（快速模式）',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _params.enableReasoning ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 最大 Token 数
          _ParamRow(
            label: '限制响应长度',
            tooltip: '开启后限制单次回复最大 token 数',
            child: Row(
              children: [
                Switch(
                  value: _params.limitResponseLength,
                  onChanged: (v) => setState(() => _params = _params.copyWith(limitResponseLength: v)),
                ),
                if (_params.limitResponseLength) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: '${_params.maxTokens ?? 2048}',
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        isDense: true,
                        border: OutlineInputBorder(),
                        suffixText: 'tok',
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0) {
                          setState(() => _params = _params.copyWith(maxTokens: n));
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteParamsContent(ThemeData theme) {
    final config = _remoteConfig;
    if (config == null) {
      return const Center(child: Text('暂无远程模型配置'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 温度
          _ParamRow(
            label: '温度',
            tooltip: '控制输出随机性（0=确定，2=最发散）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 200,
                    onChanged: (v) => setState(() => _remoteConfig = config.copyWith(temperature: v)),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    config.temperature.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Top P
          _ParamRow(
            label: 'Top P',
            tooltip: '核采样阈值（0.9 = 高质量）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.topP,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    onChanged: (v) => setState(() => _remoteConfig = config.copyWith(topP: v)),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    config.topP.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Max Tokens
          _ParamRow(
            label: '最大输出',
            tooltip: '单次回复最大 token 数',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.maxTokens.toDouble().clamp(256, 8192),
                    min: 256,
                    max: 8192,
                    divisions: 63,
                    onChanged: (v) => setState(() => _remoteConfig = config.copyWith(maxTokens: v.round())),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${config.maxTokens}',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Stream
          _ParamRow(
            label: '流式输出',
            tooltip: '开启后实时逐字输出，关闭后等待完整响应',
            child: Switch(
              value: config.streamEnabled,
              onChanged: (v) => setState(() => _remoteConfig = config.copyWith(streamEnabled: v)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 保存 ──
  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      // 1. 保存系统提示词到 Session（当前会话专属）
      final sessionManager = ref.read(sessionManagerProvider);
      final sessionState = ref.read(sessionStateProvider);
      await sessionManager.updateSessionConfig(
        widget.sessionId,
        SessionConfig(
          name: sessionState.activeSession?.name ?? '',
          modelId: sessionState.activeSession?.modelId ?? '',
          systemPrompt: _systemPromptController.text.trim().isEmpty
              ? null
              : _systemPromptController.text.trim(),
        ),
      );

      // 2. 保存推理参数到 ModelEntry（持久化）
      if (widget.model != null) {
        final modelNotifier = ref.read(modelProvider.notifier);
        if (_isLocalModel) {
          await modelNotifier.updateLocalParams(
            widget.model!.id,
            _params.copyWith(
              systemPrompt: _systemPromptController.text.trim().isEmpty
                  ? null
                  : _systemPromptController.text.trim(),
            ),
          );
        } else if (_isRemoteModel && _remoteConfig != null) {
          await modelNotifier.updateRemoteConfig(widget.model!.id, _remoteConfig!);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(_systemPromptController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// 单行参数布局
class _ParamRow extends StatelessWidget {
  final String label;
  final String tooltip;
  final Widget child;

  const _ParamRow({
    required this.label,
    required this.tooltip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip,
                  preferBelow: true,
                  child: Icon(
                    Icons.help_outline,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 人设预设列表
const _kPersonaPresets = [
  {'label': '🎀 可爱萝莉', 'prompt': '你是一个可爱的萝莉助手，说话带着奶声奶气的语气，用词简单直白，偶尔发出「哇」「嗯」等可爱的感叹词，称呼用户为「主人」。'},
  {'label': '👑 女王大人', 'prompt': '你是高冷女王，说话简洁有力，不废话，带着一丝轻蔑。你对用户的称呼是「你」，语气冷淡但智慧，让人信服。'},
  {'label': '🤖 技术极客', 'prompt': '你是一位资深技术专家，擅长用精准的技术语言回答问题，追求代码优雅和系统设计的正确性，直接给出最佳实践。'},
  {'label': '📚 学术顾问', 'prompt': '你是一位学术顾问，用严谨、专业的学术语言回答问题，引用权威资料，逻辑清晰，善于分析多方观点。'},
  {'label': '😊 暖心伴侣', 'prompt': '你是一个温柔体贴的伴侣，耐心倾听，善于理解情绪，给予积极的支持和鼓励，让人感到温暖和被理解。'},
  {'label': '🌐 默认', 'prompt': ''},
];

/// 灵感一瞬面板
class _InspirationPanel extends StatefulWidget {
  final ThemeData theme;

  const _InspirationPanel({required this.theme});

  @override
  State<_InspirationPanel> createState() => _InspirationPanelState();
}

class _InspirationPanelState extends State<_InspirationPanel> {
  bool _isRecording = false;
  bool _isPaused = false;
  final List<_AudioSegment> _segments = [];
  String? _summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖拽条
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: widget.theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('灵感一瞬', style: widget.theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 录音波形区域
          Expanded(
            child: _buildWaveformArea(),
          ),

          // 段落列表
          if (_segments.isNotEmpty) _buildSegmentsList(),

          // 录音控制按钮
          _buildRecordingControls(),

          // 操作按钮
          _buildActionButtons(),

          // 底部安全区域
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }

  Widget _buildWaveformArea() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 录音状态指示
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording
                  ? widget.theme.colorScheme.primaryContainer
                  : widget.theme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 48,
              color: _isRecording
                  ? widget.theme.colorScheme.primary
                  : widget.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? '录音中...' : '点击开始录音',
            style: widget.theme.textTheme.bodyLarge,
          ),
          if (_isRecording)
            Text(
              _isPaused ? '已暂停' : '正在录制',
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: widget.theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentsList() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _segments.length,
        itemBuilder: (context, index) {
          final segment = _segments[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '段落 ${index + 1}',
                  style: widget.theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  segment.transcription ?? '待转录',
                  style: widget.theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 暂停/继续
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _isRecording ? _togglePause : null,
            iconSize: 32,
          ),
          // 停止（触发转录）
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _isRecording ? _stopAndTranscribe : null,
            iconSize: 32,
            color: widget.theme.colorScheme.error,
          ),
          // 播放
          IconButton(
            icon: const Icon(Icons.headphones),
            onPressed: _segments.isNotEmpty ? _playLastSegment : null,
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // 一键总结
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('一键总结'),
              onPressed: _segments.isNotEmpty ? _generateSummary : null,
            ),
          ),
          const SizedBox(width: 12),
          // 生成思维导图
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.account_tree),
              label: const Text('思维导图'),
              onPressed: _segments.isNotEmpty ? _generateMindMap : null,
            ),
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopAndTranscribe() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
      // 添加一个示例段落
      _segments.add(_AudioSegment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        transcription: '这是一段示例转录文本，实际使用时会调用ASR服务进行语音识别。',
      ));
    });
  }

  void _playLastSegment() {
    // 播放最后一段录音
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('播放功能开发中...')),
    );
  }

  void _generateSummary() {
    setState(() {
      _summary = '## 灵感总结\n\n'
          '基于${_segments.length}段录音的总结：\n\n'
          '${_segments.map((s) => '- ${s.transcription}').join('\n')}';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('灵感总结'),
        content: SingleChildScrollView(
          child: Text(_summary!),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              // 复制到剪贴板
              Clipboard.setData(ClipboardData(text: _summary!));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            child: const Text('复制'),
          ),
        ],
      ),
    );
  }

  void _generateMindMap() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('思维导图'),
        content: const Text('思维导图生成功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 音频段落数据类
class _AudioSegment {
  final String id;
  final String? transcription;

  _AudioSegment({required this.id, this.transcription});
}
