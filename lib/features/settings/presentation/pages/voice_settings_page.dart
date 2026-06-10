import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_model_service.dart';
import '../../../../core/services/voice_clone_service.dart';
import '../../../../core/services/tts_director_template.dart';
import '../../../../generated/app_localizations.dart';

// 语音设置 Provider
final voiceSettingsProvider = StateNotifierProvider<VoiceSettingsNotifier, VoiceSettings>((ref) {
  return VoiceSettingsNotifier();
});

class VoiceSettings {
  final String ttsProvider; // sherpa, system, mimo
  /// ★ 新增：ASR provider 字段（之前缺失导致用户无法切换）
  final String asrProvider; // sherpa, system, openai
  final String ttsVoice;   // 音色 ID
  final double ttsSpeed;
  final bool autoPlayTts;
  final bool enableVad;

  // Sherpa-ONNX 本地模型选择
  final String selectedAsrModelId;
  final String selectedTtsModelId;

  // 系统 TTS 特定设置
  final double systemTtsSpeed;
  final double systemTtsPitch;

  // ★ 导演模式（MiMo v2.5 director mode）— MVP
  final bool enableDirectorMode;       // 是否启用导演模式
  final String directorTemplateId;     // 当前选中的导演模板 ID（'tsundere'/'mature_sister'/'yandere'）

  // ★ 音色设计（MiMo v2.5 voicedesign）— MVP 占位
  final String voiceDesignPrompt;      // 音色描述（用户自由编辑）

  // ★ V1.0 新增：用户自定义导演模板 JSON 列表
  final List<DirectorTemplate> customTemplates;

  // ★ Edge TTS 音色选择
  final String edgeVoice;  // EdgeVoice 枚举名称，如 'xiaoxiao', 'yunjian'

  // ★ CosyVoice 本地 Docker TTS 设置
  final String cosyvoiceBaseUrl;            // CosyVoice 服务地址，默认 http://localhost:50000
  final String cosyvoiceMode;               // 推理模式：zero_shot, cross_lingual, instruct2
  final String cosyvoiceInstructText;       // 指令文本（instruct2 模式使用）
  final String cosyvoiceReferenceAudioPath; // 参考音频文件路径（克隆音色必需）
  final String cosyvoiceVoiceId;            // CosyVoice 音色 ID: 'default' 或 'cv_xxx'（克隆音色）

  // ★ Fish Audio S2 Pro 本地 MLX TTS 设置
  final String fishaudioBaseUrl;            // Fish Audio 服务地址，默认 http://localhost:50001
  final String fishaudioReferenceAudioPath; // 参考音频文件路径（语音克隆时使用）
  final String fishaudioReferenceText;      // 参考音频文本转录（提升克隆质量）

  const VoiceSettings({
    this.ttsProvider = 'mimo',
    this.asrProvider = 'system',  // ★ 默认使用系统 ASR（兼容旧行为）
    this.ttsVoice = '0',
    this.ttsSpeed = 1.0,
    this.autoPlayTts = true,
    this.enableVad = true,
    this.selectedAsrModelId = 'sensevoice-int8',
    this.selectedTtsModelId = 'melo-zh-en',
    this.systemTtsSpeed = 0.5,  // flutter_tts 范围 0.0-1.0，默认 0.5
    this.systemTtsPitch = 1.0,
    this.enableDirectorMode = false,  // ★ 默认关闭（避免影响现有用户）
    this.directorTemplateId = 'tsundere',  // ★ 默认预置：傲娇
    this.voiceDesignPrompt = '年轻女性声音，温柔且略带磁性的中低音',  // ★ 默认音色描述
    this.customTemplates = const [],  // ★ V1.0：默认空
    this.edgeVoice = 'xiaoxiao',  // ★ Edge TTS 默认中文女声
    this.cosyvoiceBaseUrl = 'http://localhost:50000',  // ★ CosyVoice 默认地址
    this.cosyvoiceMode = 'cross_lingual',  // ★ CosyVoice 默认跨语言克隆模式
    this.cosyvoiceInstructText = '用自然的语气说话',  // ★ CosyVoice 默认指令
    this.cosyvoiceReferenceAudioPath = '',  // ★ CosyVoice 参考音频路径（空=未设置）
    this.cosyvoiceVoiceId = 'default',  // ★ CosyVoice 音色 ID（默认/克隆）
    this.fishaudioBaseUrl = 'http://localhost:50001',  // ★ Fish Audio 默认地址
    this.fishaudioReferenceAudioPath = '',  // ★ Fish Audio 参考音频路径（空=未设置）
    this.fishaudioReferenceText = '',  // ★ Fish Audio 参考音频文本转录
  });

  VoiceSettings copyWith({
    String? ttsProvider,
    String? asrProvider,
    String? ttsVoice,
    double? ttsSpeed,
    bool? autoPlayTts,
    bool? enableVad,
    String? selectedAsrModelId,
    String? selectedTtsModelId,
    double? systemTtsSpeed,
    double? systemTtsPitch,
    bool? enableDirectorMode,        // ★ 新增
    String? directorTemplateId,      // ★ 新增
    String? voiceDesignPrompt,       // ★ 新增
    List<DirectorTemplate>? customTemplates,  // ★ V1.0 新增
    String? edgeVoice,              // ★ Edge TTS 音色
    String? cosyvoiceBaseUrl,            // ★ CosyVoice 服务地址
    String? cosyvoiceMode,               // ★ CosyVoice 推理模式
    String? cosyvoiceInstructText,       // ★ CosyVoice 指令文本
    String? cosyvoiceReferenceAudioPath, // ★ CosyVoice 参考音频路径
    String? cosyvoiceVoiceId,            // ★ CosyVoice 音色 ID
    String? fishaudioBaseUrl,            // ★ Fish Audio 服务地址
    String? fishaudioReferenceAudioPath, // ★ Fish Audio 参考音频路径
    String? fishaudioReferenceText,      // ★ Fish Audio 参考音频文本转录
  }) {
    return VoiceSettings(
      ttsProvider: ttsProvider ?? this.ttsProvider,
      asrProvider: asrProvider ?? this.asrProvider,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      autoPlayTts: autoPlayTts ?? this.autoPlayTts,
      enableVad: enableVad ?? this.enableVad,
      selectedAsrModelId: selectedAsrModelId ?? this.selectedAsrModelId,
      selectedTtsModelId: selectedTtsModelId ?? this.selectedTtsModelId,
      systemTtsSpeed: systemTtsSpeed ?? this.systemTtsSpeed,
      systemTtsPitch: systemTtsPitch ?? this.systemTtsPitch,
      enableDirectorMode: enableDirectorMode ?? this.enableDirectorMode,    // ★
      directorTemplateId: directorTemplateId ?? this.directorTemplateId,      // ★
      voiceDesignPrompt: voiceDesignPrompt ?? this.voiceDesignPrompt,        // ★
      customTemplates: customTemplates ?? this.customTemplates,              // ★
      edgeVoice: edgeVoice ?? this.edgeVoice,                                // ★
      cosyvoiceBaseUrl: cosyvoiceBaseUrl ?? this.cosyvoiceBaseUrl,                // ★
      cosyvoiceMode: cosyvoiceMode ?? this.cosyvoiceMode,                         // ★
      cosyvoiceInstructText: cosyvoiceInstructText ?? this.cosyvoiceInstructText,  // ★
      cosyvoiceReferenceAudioPath: cosyvoiceReferenceAudioPath ?? this.cosyvoiceReferenceAudioPath,  // ★
      cosyvoiceVoiceId: cosyvoiceVoiceId ?? this.cosyvoiceVoiceId,                // ★
      fishaudioBaseUrl: fishaudioBaseUrl ?? this.fishaudioBaseUrl,                // ★
      fishaudioReferenceAudioPath: fishaudioReferenceAudioPath ?? this.fishaudioReferenceAudioPath,  // ★
      fishaudioReferenceText: fishaudioReferenceText ?? this.fishaudioReferenceText,  // ★
    );
  }
}

class VoiceSettingsNotifier extends StateNotifier<VoiceSettings> {
  VoiceSettingsNotifier() : super(const VoiceSettings()) {
    _loadSettings();
  }

  static const String _ttsProviderKey = 'tts_provider';
  static const String _asrProviderKey = 'asr_provider';  // ★ 新增
  static const String _selectedAsrModelKey = 'selected_asr_model_id';
  static const String _selectedTtsModelKey = 'selected_tts_model_id';
  static const String _ttsVoiceKey = 'tts_voice_id';
  // ★ 导演模式持久化 key
  static const String _enableDirectorModeKey = 'enable_director_mode';
  static const String _directorTemplateIdKey = 'director_template_id';
  static const String _voiceDesignPromptKey = 'voice_design_prompt';
  static const String _customTemplatesKey = 'tts_custom_director_templates_v1';
  static const String _edgeVoiceKey = 'edge_voice';  // ★ Edge TTS 音色
  static const String _cosyvoiceBaseUrlKey = 'cosyvoice_base_url';  // ★ CosyVoice 服务地址
  static const String _cosyvoiceModeKey = 'cosyvoice_mode';          // ★ CosyVoice 推理模式
  static const String _cosyvoiceInstructTextKey = 'cosyvoice_instruct_text';  // ★ CosyVoice 指令文本
  static const String _cosyvoiceRefAudioPathKey = 'cosyvoice_ref_audio_path';  // ★ CosyVoice 参考音频路径
  static const String _cosyvoiceVoiceIdKey = 'cosyvoice_voice_id';  // ★ CosyVoice 音色 ID
  static const String _fishaudioBaseUrlKey = 'fishaudio_base_url';  // ★ Fish Audio 服务地址
  static const String _fishaudioRefAudioPathKey = 'fishaudio_ref_audio_path';  // ★ Fish Audio 参考音频路径
  static const String _fishaudioRefTextKey = 'fishaudio_ref_text';  // ★ Fish Audio 参考音频文本

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载用户自定义导演模板
    final customJson = prefs.getString(_customTemplatesKey);
    List<DirectorTemplate> customs = const [];
    if (customJson != null && customJson.isNotEmpty) {
      try {
        customs = DirectorTemplateLibrary.loadAll(customTemplatesJson: customJson)
            .where((t) => !t.isPreset)
            .toList();
      } catch (_) {
        customs = const [];
      }
    }

    // ★ 修复：与 settingsService.getTtsProvider() 默认值对齐——首次加载时把默认值持久化
    // 之前 voiceSettingsPage 内部默认是 'mimo'，而 settingsService 默认是 'system'，
    // 导致 SharedPreferences 里没存 'tts_provider' 时，TTS 实际走的是 system。
    // 现在：首次加载时把 voiceSettingsPage 用的默认值同步写回 SharedPreferences，
    // 让 settingsService 也能读到这个值。
    final effectiveTtsProvider = prefs.getString(_ttsProviderKey) ?? 'mimo';
    if (!prefs.containsKey(_ttsProviderKey)) {
      await prefs.setString(_ttsProviderKey, effectiveTtsProvider);
      debugPrint('[VoiceSettings] 首次加载：持久化 tts_provider 默认值 = "$effectiveTtsProvider"');
    }
    final effectiveTtsVoice = prefs.getString(_ttsVoiceKey) ??
        (effectiveTtsProvider == 'mimo' ? 'mimo_default' : '0');
    if (!prefs.containsKey(_ttsVoiceKey)) {
      await prefs.setString(_ttsVoiceKey, effectiveTtsVoice);
      debugPrint('[VoiceSettings] 首次加载：持久化 tts_voice 默认值 = "$effectiveTtsVoice"');
    }

    state = state.copyWith(
      ttsProvider: effectiveTtsProvider,
      asrProvider: prefs.getString(_asrProviderKey) ?? 'system',  // ★ 新增
      selectedAsrModelId: prefs.getString(_selectedAsrModelKey) ?? 'sensevoice-int8',
      selectedTtsModelId: prefs.getString(_selectedTtsModelKey) ?? 'melo-zh-en',
      // ★ 修复：MiMo 默认音色应为 'mimo_default'，而非 '0'（Sherpa 音色 ID）
      ttsVoice: effectiveTtsVoice,
      // ★ 导演模式加载（默认关闭，避免影响现有用户）
      enableDirectorMode: prefs.getBool(_enableDirectorModeKey) ?? false,
      directorTemplateId: prefs.getString(_directorTemplateIdKey) ?? 'tsundere',
      voiceDesignPrompt: prefs.getString(_voiceDesignPromptKey)
          ?? '年轻女性声音，温柔且略带磁性的中低音',
      // ★ V1.0：用户自定义模板
      customTemplates: customs,
      // ★ Edge TTS 音色
      edgeVoice: prefs.getString(_edgeVoiceKey) ?? 'xiaoxiao',
      // ★ CosyVoice 配置
      cosyvoiceBaseUrl: prefs.getString(_cosyvoiceBaseUrlKey) ?? 'http://localhost:50000',
      cosyvoiceMode: prefs.getString(_cosyvoiceModeKey) ?? 'cross_lingual',
      cosyvoiceInstructText: prefs.getString(_cosyvoiceInstructTextKey) ?? '用自然的语气说话',
      cosyvoiceReferenceAudioPath: prefs.getString(_cosyvoiceRefAudioPathKey) ?? '',
      cosyvoiceVoiceId: prefs.getString(_cosyvoiceVoiceIdKey) ?? 'default',
      // ★ Fish Audio 配置
      fishaudioBaseUrl: prefs.getString(_fishaudioBaseUrlKey) ?? 'http://localhost:50001',
      fishaudioReferenceAudioPath: prefs.getString(_fishaudioRefAudioPathKey) ?? '',
      fishaudioReferenceText: prefs.getString(_fishaudioRefTextKey) ?? '',
    );
  }

  // ============================================================================
  // ★ 导演模式 setter（V1.0 完整接入 TTSService 时会调用）
  // ============================================================================

  /// 切换导演模式开关
  void setEnableDirectorMode(bool value) {
    state = state.copyWith(enableDirectorMode: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_enableDirectorModeKey, value);
    });
  }

  /// 选择导演模板
  void setDirectorTemplateId(String value) {
    state = state.copyWith(directorTemplateId: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_directorTemplateIdKey, value);
    });
  }

  /// 编辑音色描述（voicedesign 模型用）
  void setVoiceDesignPrompt(String value) {
    state = state.copyWith(voiceDesignPrompt: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_voiceDesignPromptKey, value);
    });
  }

  // ============================================================================
  // ★ V1.0 用户自定义导演模板增删改（持久化到 SharedPreferences）
  // ============================================================================

  /// 添加用户自定义模板
  void addCustomTemplate(DirectorTemplate template) {
    final updated = [...state.customTemplates, template];
    state = state.copyWith(customTemplates: updated);
    _saveCustomTemplates(updated);
  }

  /// 删除用户自定义模板
  void deleteCustomTemplate(String id) {
    final updated = state.customTemplates.where((t) => t.id != id).toList();
    state = state.copyWith(customTemplates: updated);
    _saveCustomTemplates(updated);
    // 如果删除的是当前选中的模板，切换回默认预置
    if (state.directorTemplateId == id) {
      setDirectorTemplateId('tsundere');
    }
  }

  /// 更新用户自定义模板
  void updateCustomTemplate(DirectorTemplate template) {
    final updated = state.customTemplates
        .map((t) => t.id == template.id ? template : t)
        .toList();
    state = state.copyWith(customTemplates: updated);
    _saveCustomTemplates(updated);
  }

  /// 内部：序列化保存到 SharedPreferences
  void _saveCustomTemplates(List<DirectorTemplate> templates) {
    final json = DirectorTemplateLibrary.encodeCustomTemplates(templates);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_customTemplatesKey, json);
    });
  }

  /// 获取当前导演描述（拼接模板角色/场景/指导）
  ///
  /// 返回完整 director 描述字符串，可直接放入 MiMo API 的 user 消息
  String? getCurrentDirectorPrompt() {
    if (!state.enableDirectorMode) return null;
    final template = DirectorTemplatePresets.findById(state.directorTemplateId);
    if (template == null) return null;
    return template.composed;
  }

  void setTtsProvider(String value) {
    // ★ 修复：切换 TTS Provider 时更新默认音色
    // MiMo 默认音色为 'mimo_default'，Sherpa 为 '0'，Edge 为 'xiaoxiao'
    String defaultVoice;
    switch (value) {
      case 'mimo':
        defaultVoice = 'mimo_default';
        break;
      case 'edge':
        defaultVoice = 'xiaoxiao';
        break;
      case 'system':
        defaultVoice = '';
        break;
      case 'cosyvoice':
        defaultVoice = 'default';
        break;
      case 'fishaudio':
        defaultVoice = 'default';
        break;
      default:
        defaultVoice = '0'; // Sherpa 等
    }
    state = state.copyWith(ttsProvider: value, ttsVoice: defaultVoice);

    SharedPreferences.getInstance().then((prefs) async {
      await prefs.setString(_ttsProviderKey, value);
      await prefs.setString(_ttsVoiceKey, defaultVoice);

      // ★ 修复：用户主动切换 TTS Provider 时，如果目标是 mimo/edge/cosyvoice/fishaudio 等非 system，
      // 自动把 SharedPreferences 中所有显式为 false 的 session_voice_output_* 改为 true，
      // 解决"配了 MiMo 但会话详情页没声音"的 UX 问题。
      // 用户如果之后在会话页手动关闭，会被持久化为 false，保留他的选择。
      // 反复切换 mimo → edge → cosyvoice 都会再次触发，让"配 provider = 期望发声"的意图贯通。
      if (value != 'system') {
        final keys = prefs.getKeys().where((k) => k.startsWith('session_voice_output_'));
        debugPrint('[VoiceSettings] setTtsProvider: → $value，自动开启 ${keys.length} 个会话的语音播报');
        for (final key in keys) {
          if (prefs.getBool(key) == false) {
            await prefs.setBool(key, true);
          }
        }
      }
    });
  }

  /// ★ 新增：设置 ASR provider
  /// 之前没有这个方法，导致用户无法在 UI 中切换 ASR provider
  void setAsrProvider(String value) {
    state = state.copyWith(asrProvider: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_asrProviderKey, value);
    });
  }

  void setTtsVoice(String value) {
    state = state.copyWith(ttsVoice: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_ttsVoiceKey, value);
    });
  }

  void setSelectedAsrModelId(String value) {
    state = state.copyWith(selectedAsrModelId: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_selectedAsrModelKey, value);
    });
  }

  void setSelectedTtsModelId(String value) {
    final voices = VoiceModelService().getTtsVoices(value);
    final defaultVoice = voices.isNotEmpty ? voices.first['id']! : '0';
    state = state.copyWith(selectedTtsModelId: value, ttsVoice: defaultVoice);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_selectedTtsModelKey, value);
      prefs.setString(_ttsVoiceKey, defaultVoice);
    });
  }

  void setTtsSpeed(double value) {
    state = state.copyWith(ttsSpeed: value);
  }

  /// ★ 设置 Edge TTS 音色
  void setEdgeVoice(String value) {
    state = state.copyWith(edgeVoice: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_edgeVoiceKey, value);
    });
  }

  // ============================================================================
  // ★ CosyVoice 设置方法
  // ============================================================================

  void setCosyvoiceBaseUrl(String value) {
    state = state.copyWith(cosyvoiceBaseUrl: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_cosyvoiceBaseUrlKey, value);
    });
  }

  void setCosyvoiceMode(String value) {
    state = state.copyWith(cosyvoiceMode: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_cosyvoiceModeKey, value);
    });
  }

  void setCosyvoiceInstructText(String value) {
    state = state.copyWith(cosyvoiceInstructText: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_cosyvoiceInstructTextKey, value);
    });
  }

  void setCosyvoiceReferenceAudioPath(String value) {
    state = state.copyWith(cosyvoiceReferenceAudioPath: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_cosyvoiceRefAudioPathKey, value);
    });
  }

  void setCosyvoiceVoiceId(String value) {
    state = state.copyWith(cosyvoiceVoiceId: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_cosyvoiceVoiceIdKey, value);
    });
  }

  // ============================================================================
  // ★ Fish Audio 设置方法
  // ============================================================================

  void setFishAudioBaseUrl(String value) {
    state = state.copyWith(fishaudioBaseUrl: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_fishaudioBaseUrlKey, value);
    });
  }

  void setFishAudioReferenceAudioPath(String value) {
    state = state.copyWith(fishaudioReferenceAudioPath: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_fishaudioRefAudioPathKey, value);
    });
  }

  void setFishAudioReferenceText(String value) {
    state = state.copyWith(fishaudioReferenceText: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_fishaudioRefTextKey, value);
    });
  }

  void setAutoPlayTts(bool value) {
    state = state.copyWith(autoPlayTts: value);
  }

  void setEnableVad(bool value) {
    state = state.copyWith(enableVad: value);
  }

  Future<void> setSystemTtsSpeed(double value) async {
    state = state.copyWith(systemTtsSpeed: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('system_tts_speed', value);
  }

  Future<void> setSystemTtsPitch(double value) async {
    state = state.copyWith(systemTtsPitch: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('system_tts_pitch', value);
  }
}

// TTS 提供商选项
const ttsProviderOptions = [
  {'id': 'sherpa', 'name': 'Sherpa-ONNX', 'desc': '本地离线 TTS，中文优化（推荐）'},
  {'id': 'edge', 'name': 'Edge TTS', 'desc': '微软免费神经网络语音，无需 API Key，速度快'},
  {'id': 'system', 'name': '系统语音合成', 'desc': '使用系统自带的 TTS 引擎'},
  {'id': 'mimo', 'name': '小米 MiMo TTS', 'desc': '云端语音合成，音色丰富，需 API Key'},
  {'id': 'cosyvoice', 'name': 'CosyVoice', 'desc': '阿里开源 TTS，支持语音克隆/指令控制，需本地 Docker'},
  {'id': 'fishaudio', 'name': 'Fish Audio', 'desc': 'Apple Silicon MLX 本地 TTS，支持语音克隆/情感标签，速度快'},
];

class VoiceSettingsPage extends ConsumerStatefulWidget {
  const VoiceSettingsPage({super.key});

  @override
  ConsumerState<VoiceSettingsPage> createState() => _VoiceSettingsPageState();
}

class _VoiceSettingsPageState extends ConsumerState<VoiceSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(voiceSettingsProvider);
    // 监听克隆音色列表，自动刷新
    final clonedVoicesAsync = ref.watch(clonedVoicesProvider);
    final clonedVoices = clonedVoicesAsync.valueOrNull ?? [];
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: Text(l10n.voiceSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // ASR 设置
          _SettingsSection(
            title: '语音识别 (ASR)',
            children: [
              // ★ 新增：ASR 识别引擎选择
              ListTile(
                leading: const Icon(Icons.engineering, color: Colors.green),
                title: const Text('ASR 识别引擎'),
                subtitle: Text(_getAsrProviderName(settings.asrProvider)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAsrProviderSelectDialog(context, ref, settings.asrProvider),
              ),
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.green),
                title: const Text('Sherpa-ONNX 本地识别'),
                subtitle: const Text('离线语音识别，支持中英日韩粤'),
              ),
              SwitchListTile(
                title: const Text('语音活动检测 (VAD)'),
                subtitle: const Text('自动检测语音开始和结束'),
                value: settings.enableVad,
                onChanged: (value) {
                  ref.read(voiceSettingsProvider.notifier).setEnableVad(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.model_training),
                title: const Text('选择 ASR 模型'),
                subtitle: Text(_getAsrModelName(settings.selectedAsrModelId)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAsrModelSelectDialog(context, ref, settings.selectedAsrModelId),
              ),
              _buildModelDownloadTile(
                context: context,
                title: '下载 ASR 模型',
                modelType: VoiceModelType.asr,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // TTS 设置
          _SettingsSection(
            title: '语音合成 (TTS)',
            children: [
              ListTile(
                title: const Text('合成提供商'),
                subtitle: Text(ttsProviderOptions
                    .firstWhere((p) => p['id'] == settings.ttsProvider, orElse: () => ttsProviderOptions.first)['name']!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTtsProviderDialog(context, ref, settings.ttsProvider),
              ),

              // Sherpa-ONNX TTS 设置
              if (settings.ttsProvider == 'sherpa') ...[
                ListTile(
                  leading: const Icon(Icons.model_training),
                  title: const Text('选择 TTS 模型'),
                  subtitle: Text(_getTtsModelName(settings.selectedTtsModelId)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTtsModelSelectDialog(context, ref, settings.selectedTtsModelId),
                ),
                ListTile(
                  title: const Text('语音音色'),
                  subtitle: Text(_getVoiceName(settings.selectedTtsModelId, settings.ttsVoice)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSherpaVoiceDialog(context, ref, settings.selectedTtsModelId, settings.ttsVoice),
                ),
                _buildModelDownloadTile(
                  context: context,
                  title: '下载 TTS 模型',
                  modelType: VoiceModelType.tts,
                ),
              ],

              // 系统 TTS 设置

              // Edge TTS 设置
              if (settings.ttsProvider == 'edge') ...[
                ListTile(
                  leading: const Icon(Icons.record_voice_over, color: Colors.blue),
                  title: const Text('Edge TTS 音色'),
                  subtitle: Text(_getEdgeVoiceName(settings.edgeVoice)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showEdgeVoiceSelectDialog(context, ref, settings.edgeVoice),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey),
                  title: Text('Edge TTS 说明'),
                  subtitle: Text('微软免费神经网络语音，无需 API Key，支持 16 种中文音色，需联网'),
                ),
              ],

              // ★ CosyVoice 设置
              if (settings.ttsProvider == 'cosyvoice') ...[
                ListTile(
                  leading: const Icon(Icons.link, color: Colors.orange),
                  title: const Text('CosyVoice 服务地址'),
                  subtitle: Text(settings.cosyvoiceBaseUrl),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showCosyvoiceBaseUrlDialog(context, ref, settings.cosyvoiceBaseUrl),
                ),
                ListTile(
                  leading: const Icon(Icons.tune, color: Colors.deepPurple),
                  title: const Text('推理模式'),
                  subtitle: Text(_getCosyvoiceModeName(settings.cosyvoiceMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCosyvoiceModeSelectDialog(context, ref, settings.cosyvoiceMode),
                ),
                // Instruct2 模式：编辑指令文本
                if (settings.cosyvoiceMode == 'instruct2')
                  ListTile(
                    leading: const Icon(Icons.chat_bubble, color: Colors.teal),
                    title: const Text('指令文本'),
                    subtitle: Text(settings.cosyvoiceInstructText),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showCosyvoiceInstructDialog(context, ref, settings.cosyvoiceInstructText),
                  ),
                // 音色选择（默认音色 / 克隆音色）
                if (settings.cosyvoiceMode != 'instruct2')
                  ListTile(
                    leading: const Icon(Icons.record_voice_over, color: Colors.orange),
                    title: const Text('音色'),
                    subtitle: FutureBuilder<String>(
                      future: _getCosyvoiceVoiceName(settings.cosyvoiceVoiceId),
                      initialData: settings.cosyvoiceVoiceId == 'default' ? '默认音色' : '加载中...',
                      builder: (_, snap) => Text(snap.data ?? '默认音色'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showCosyvoiceVoiceSelectDialog(context, ref, settings.cosyvoiceVoiceId),
                  ),
                // 语音克隆（录制参考音频）
                if (settings.cosyvoiceMode == 'zero_shot' || settings.cosyvoiceMode == 'cross_lingual')
                  ListTile(
                    leading: const Icon(Icons.mic, color: Colors.teal),
                    title: const Text('语音克隆'),
                    subtitle: FutureBuilder<int>(
                      future: _getCosyvoiceCloneCount(),
                      initialData: 0,
                      builder: (_, snap) => Text(snap.data == 0
                          ? '录制参考音频创建克隆音色'
                          : '已创建 ${snap.data} 个克隆音色'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/voice/clone?provider=cosyvoice'),
                  ),
                // Cross-lingual 模式说明
                if (settings.cosyvoiceMode == 'cross_lingual')
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.grey),
                    title: Text('跨语言合成说明'),
                    subtitle: Text('使用参考音频的音色合成不同语言的语音，需在克隆音色中录制参考音频'),
                  ),
                // Zero-shot 模式说明
                if (settings.cosyvoiceMode == 'zero_shot')
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.grey),
                    title: Text('零样本克隆说明'),
                    subtitle: Text('通过参考音频克隆音色，需在克隆音色中录制参考音频并选择对应克隆音色'),
                  ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // 连接测试
                ListTile(
                  leading: const Icon(Icons.wifi_tethering, color: Colors.green),
                  title: const Text('测试连接'),
                  subtitle: const Text('验证 CosyVoice 服务是否可达并测试合成'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _testCosyvoiceConnection(context, settings),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey),
                  title: Text('CosyVoice 说明'),
                  subtitle: Text('阿里开源 TTS 引擎，需本地 Docker 部署 CosyVoice2-0.5B。支持零样本克隆、跨语言合成、指令控制等模式'),
                ),
              ],

              // ★ Fish Audio S2 Pro 设置
              if (settings.ttsProvider == 'fishaudio') ...[
                ListTile(
                  leading: const Icon(Icons.link, color: Colors.cyan),
                  title: const Text('Fish Audio 服务地址'),
                  subtitle: Text(settings.fishaudioBaseUrl),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showFishAudioBaseUrlDialog(context, ref, settings.fishaudioBaseUrl),
                ),
                // 语音克隆（上传参考音频）
                ListTile(
                  leading: const Icon(Icons.mic, color: Colors.teal),
                  title: const Text('语音克隆'),
                  subtitle: Text(settings.fishaudioReferenceAudioPath.isEmpty
                      ? '上传参考音频创建克隆音色'
                      : '已设置参考音频'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/voice/clone?provider=fishaudio'),
                ),
                // 参考音频文本转录
                if (settings.fishaudioReferenceAudioPath.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.text_fields, color: Colors.indigo),
                    title: const Text('参考音频文本'),
                    subtitle: Text(settings.fishaudioReferenceText.isEmpty
                        ? '未设置（可选，提升克隆质量）'
                        : settings.fishaudioReferenceText),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showFishAudioRefTextDialog(context, ref, settings.fishaudioReferenceText),
                  ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // 连接测试
                ListTile(
                  leading: const Icon(Icons.wifi_tethering, color: Colors.green),
                  title: const Text('测试连接'),
                  subtitle: const Text('验证 Fish Audio 服务是否可达并测试合成'),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _testFishAudioConnection(context, settings),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey),
                  title: Text('Fish Audio 说明'),
                  subtitle: Text('基于 Apple Silicon MLX 的本地 TTS，支持语音克隆和情感标签（如 [happy] [whisper] [sad]）。需运行 Python 服务端'),
                ),
              ],

              // MiMo TTS 设置
              if (settings.ttsProvider == 'mimo') ...[
                ListTile(
                  leading: const Icon(Icons.key, color: Colors.amber),
                  title: const Text('MiMo API Key'),
                  subtitle: const Text('小米 MiMo 平台 API Key'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showMiMoApiKeyDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.link, color: Colors.blue),
                  title: const Text('自定义 API 地址'),
                  subtitle: const Text('默认: api.xiaomimimo.com（如遇 DNS 问题可配置代理地址）'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showMiMoBaseUrlDialog(context),
                ),
                FutureBuilder<bool>(
                  future: SharedPreferences.getInstance().then((p) => p.getBool('use_local_proxy') ?? false),
                  builder: (context, snapshot) {
                    final useProxy = snapshot.data ?? false;
                    return SwitchListTile(
                      secondary: const Icon(Icons.dns, color: Colors.green),
                      title: const Text('启用本地代理'),
                      subtitle: const Text('通过本地服务转发请求（解决跨域/统一端点）'),
                      value: useProxy,
                      onChanged: (value) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('use_local_proxy', value);
                        if (context.mounted) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(value ? '本地代理已启用' : '本地代理已禁用')),
                          );
                        }
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.indigo),
                  title: const Text('代理状态'),
                  subtitle: const Text('查看代理服务运行状态和请求日志'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/proxy'),
                ),
                ListTile(
                  leading: const Icon(Icons.record_voice_over, color: Colors.purple),
                  title: const Text('音色'),
                  subtitle: Text(_getMiMoVoiceName(settings.ttsVoice, clonedVoices)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMiMoVoiceSelectDialog(context, clonedVoices),
                ),
                ListTile(
                  leading: const Icon(Icons.mic, color: Colors.teal),
                  title: const Text('语音克隆'),
                  subtitle: Text(clonedVoices.isEmpty
                      ? '录制参考音频创建克隆音色'
                      : '已创建 ${clonedVoices.length} 个克隆音色'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/voice/clone'),
                ),

                // ============================================================================
                // ★ 导演模式（MiMo v2.5 director mode）— MVP
                // ============================================================================
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.movie_creation, color: Colors.deepPurple),
                  title: const Text('导演模式（MiMo v2.5）'),
                  subtitle: Text(settings.enableDirectorMode
                      ? '已启用 · 当前模板：${_getDirectorTemplateName(settings.directorTemplateId)}'
                      : '关闭 · 启用后将从角色/场景/指导三维度控制语音'),
                  trailing: Switch(
                    value: settings.enableDirectorMode,
                    onChanged: (value) {
                      ref.read(voiceSettingsProvider.notifier).setEnableDirectorMode(value);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? '已启用导演模式' : '已关闭导演模式'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                if (settings.enableDirectorMode)
                  ListTile(
                    leading: const Icon(Icons.style, color: Colors.deepPurple),
                    title: const Text('选择导演模板'),
                    subtitle: Text(_getDirectorTemplateName(settings.directorTemplateId)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDirectorTemplateSelectDialog(context, ref, settings.directorTemplateId),
                  ),
                if (settings.enableDirectorMode)
                  ListTile(
                    leading: const Icon(Icons.preview, color: Colors.deepPurple),
                    title: const Text('预览导演描述'),
                    subtitle: Text(
                      _getDirectorTemplateDescription(settings.directorTemplateId),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showDirectorPreviewDialog(context, settings.directorTemplateId),
                  ),
                // ★ V1.0：我的模板（用户自定义）
                ListTile(
                  leading: const Icon(Icons.folder_special, color: Colors.indigo),
                  title: const Text('我的模板'),
                  subtitle: Text(settings.customTemplates.isEmpty
                      ? '未创建自定义模板'
                      : '已创建 ${settings.customTemplates.length} 个 · 点击管理'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/voice/director-templates'),
                ),
                // ★ 音色设计（voicedesign 模型）— MVP 占位，V1.0 完整接入 API
                ListTile(
                  leading: const Icon(Icons.tune, color: Colors.pink),
                  title: const Text('音色描述（voice design · V1.0）'),
                  subtitle: Text(
                    settings.voiceDesignPrompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showVoiceDesignEditDialog(context, ref, settings.voiceDesignPrompt),
                ),
              ],

              if (settings.ttsProvider == 'system') ...[
                ListTile(
                  leading: const Icon(Icons.volume_up, color: Colors.blue),
                  title: const Text('系统语音合成'),
                  subtitle: const Text('使用 macOS/Windows/iOS/Android 内置 TTS'),
                ),
                ListTile(
                  title: const Text('语速'),
                  subtitle: Slider(
                    value: settings.systemTtsSpeed,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(settings.systemTtsSpeed * 2).toStringAsFixed(1)}x',
                    onChanged: (value) {
                      ref.read(voiceSettingsProvider.notifier).setSystemTtsSpeed(value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('音调'),
                  subtitle: Slider(
                    value: settings.systemTtsPitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    label: settings.systemTtsPitch.toStringAsFixed(1),
                    onChanged: (value) {
                      ref.read(voiceSettingsProvider.notifier).setSystemTtsPitch(value);
                    },
                  ),
                ),
              ],

              SwitchListTile(
                title: const Text('自动播放语音'),
                subtitle: const Text('AI 回复时自动播放语音'),
                value: settings.autoPlayTts,
                onChanged: (value) {
                  ref.read(voiceSettingsProvider.notifier).setAutoPlayTts(value);
                },
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // 语音参数
          _SettingsSection(
            title: '语音参数',
            children: [
              ListTile(
                title: const Text('语速'),
                subtitle: Slider(
                  value: settings.ttsSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${settings.ttsSpeed.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    ref.read(voiceSettingsProvider.notifier).setTtsSpeed(value);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }

  String _getAsrModelName(String modelId) {
    final model = VoiceModelService.asrModels.where((m) => m.id == modelId).firstOrNull;
    return model?.name ?? modelId;
  }

  /// ★ 新增：ASR provider 名称映射
  String _getAsrProviderName(String providerId) {
    return switch (providerId) {
      'sherpa' => 'Sherpa-ONNX 本地识别（推荐）',
      'system' => '系统语音识别（实时转写）',
      'openai' => 'OpenAI Whisper API',
      _ => providerId,
    };
  }

  /// ★ 新增：ASR provider 选择对话框
  void _showAsrProviderSelectDialog(BuildContext context, WidgetRef ref, String currentProvider) {
    final providers = [
      {'id': 'system', 'name': '系统语音识别（实时转写）', 'desc': '使用系统自带的语音识别引擎，实时显示识别结果'},
      {'id': 'sherpa', 'name': 'Sherpa-ONNX 本地识别', 'desc': '离线识别，中英日韩粤支持，需要下载模型'},
      {'id': 'openai', 'name': 'OpenAI Whisper', 'desc': '云端识别，精度高但需网络和 API Key'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择 ASR 识别引擎'),
        content: SizedBox(
          width: double.maxFinite,
          height: 350,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: providers.length,
            itemBuilder: (_, i) {
              final p = providers[i];
              return RadioListTile<String>(
                title: Text(p['name']!),
                subtitle: Text(p['desc']!, maxLines: 2),
                value: p['id']!,
                groupValue: currentProvider,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(voiceSettingsProvider.notifier).setAsrProvider(value);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已切换到 ${p['name']}'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  String _getTtsModelName(String modelId) {
    final model = VoiceModelService.ttsModels.where((m) => m.id == modelId).firstOrNull;
    return model?.name ?? modelId;
  }

  String _getVoiceName(String ttsModelId, String voiceId) {
    final voices = VoiceModelService().getTtsVoices(ttsModelId);
    final voice = voices.where((v) => v['id'] == voiceId).firstOrNull;
    return voice?['name'] ?? voiceId;
  }

  void _showAsrModelSelectDialog(BuildContext context, WidgetRef ref, String currentModelId) {
    final models = VoiceModelService().getAsrModels();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择 ASR 模型'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: models.length,
            itemBuilder: (_, i) {
              final m = models[i];
              return RadioListTile<String>(
                title: Text(m.name),
                subtitle: Text(m.description, maxLines: 2),
                value: m.id,
                groupValue: currentModelId,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(voiceSettingsProvider.notifier).setSelectedAsrModelId(v);
                  }
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ],
      ),
    );
  }

  void _showTtsModelSelectDialog(BuildContext context, WidgetRef ref, String currentModelId) {
    final models = VoiceModelService().getTtsModels();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择 TTS 模型'),
        content: SizedBox(
          width: double.maxFinite,
          height: 450,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: models.length,
            itemBuilder: (_, i) {
              final m = models[i];
              return RadioListTile<String>(
                title: Text(m.name),
                subtitle: Text(
                  '${m.description}  •  ${VoiceModelService.formatFileSize(m.fileSize)}',
                  maxLines: 2,
                ),
                value: m.id,
                groupValue: currentModelId,
                onChanged: (v) {
                  if (v != null) {
                    ref.read(voiceSettingsProvider.notifier).setSelectedTtsModelId(v);
                  }
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ],
      ),
    );
  }

  void _showSherpaVoiceDialog(BuildContext context, WidgetRef ref, String ttsModelId, String currentVoice) {
    final voices = VoiceModelService().getTtsVoices(ttsModelId);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择语音音色'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: voices.length,
            itemBuilder: (ctx, index) {
              final voice = voices[index];
              final isSelected = voice['id'] == currentVoice;
              return ListTile(
                leading: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.record_voice_over),
                title: Text(voice['name']!),
                subtitle: Text(voice['desc']!),
                selected: isSelected,
                onTap: () {
                  ref.read(voiceSettingsProvider.notifier).setTtsVoice(voice['id']!);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showTtsProviderDialog(BuildContext context, WidgetRef ref, String currentProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择 TTS 提供商'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: ttsProviderOptions.map((provider) {
              return RadioListTile<String>(
                title: Text(provider['name']!, overflow: TextOverflow.ellipsis),
                subtitle: Text(provider['desc']!, maxLines: 2, overflow: TextOverflow.ellipsis),
                value: provider['id']!,
                groupValue: currentProvider,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(voiceSettingsProvider.notifier).setTtsProvider(value);
                  }
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildModelDownloadTile({
    required BuildContext context,
    required String title,
    required VoiceModelType modelType,
  }) {
    return FutureBuilder<bool>(
      future: _checkHasUpdateAsync(modelType),
      builder: (context, snapshot) {
        final hasUpdate = snapshot.data ?? false;
        
        return ListTile(
          leading: Icon(
            hasUpdate ? Icons.system_update : Icons.download,
            color: hasUpdate ? Colors.red : Colors.blue,
          ),
          title: Text(title),
          subtitle: Text(hasUpdate ? '有新版本可更新' : '点击管理模型'),
          trailing: hasUpdate
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'UPDATE',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              : const Icon(Icons.chevron_right),
          onTap: () => _showModelDownloadDialog(context, modelType),
        );
      },
    );
  }

  Future<bool> _checkHasUpdateAsync(VoiceModelType type) async {
    final service = VoiceModelService();
    final models = type == VoiceModelType.asr ? service.getAsrModels() : service.getTtsModels();
    for (final model in models) {
      if (await service.hasNewVersion(model.id)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _showModelDownloadDialog(BuildContext context, VoiceModelType modelType) async {
    final service = VoiceModelService();
    final models = modelType == VoiceModelType.asr ? service.getAsrModels() : service.getTtsModels();
    final title = modelType == VoiceModelType.asr ? 'ASR 语音识别模型' : 'TTS 语音合成模型';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    return _ModelDownloadItem(
                      model: model,
                      onDownload: () => _startModelDownload(context, model),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startModelDownload(BuildContext context, VoiceModelInfo model) async {
    final service = VoiceModelService();

    if (!context.mounted) return;

    final progressKey = GlobalKey<_DownloadProgressState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DownloadProgressDialog(
        key: progressKey,
        model: model,
        onCancel: () {
          service.pauseDownload(model.id);
          Navigator.pop(ctx);
        },
      ),
    );

    try {
      // ★ 修复：根据模型类型选择正确的下载方法
      // isDirectDownload=true 走 downloadModelDirect（直链，无需解压）
      // 其他走 downloadModel（tar.bz2，需要解压）
      if (model.isDirectDownload) {
        await service.downloadModelDirect(
          modelId: model.id,
          onProgress: (progress) {
            if (progressKey.currentState != null) {
              progressKey.currentState!.updateProgress(progress);
            }
          },
        );
      } else {
        await service.downloadModel(
          modelId: model.id,
          onProgress: (progress) {
            if (progressKey.currentState != null) {
              progressKey.currentState!.updateProgress(progress);
            }
          },
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} 下载完成')),
        );
      }
    } catch (e) {
      if (progressKey.currentState != null) {
        progressKey.currentState!.updateProgress(
          VoiceModelDownloadProgress(
            modelId: model.id,
            progress: 0.0,
            status: 'error',
            error: e.toString(),
          ),
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e')),
        );
      }
    }
  }
  // ══════════════════════════════════════════════════════════════════════════
  // MiMo TTS 辅助方法
  // ══════════════════════════════════════════════════════════════════════════

  /// ★ Edge TTS 音色名称映射
  static const Map<String, String> _edgeVoiceDisplayNames = {
    'xiaoxiao': '晓晓 (女声·温暖自然)',
    'xiaoyi': '晓依 (女声·活泼)',
    'yunjian': '云健 (男声·沉稳)',
    'xiaochen': '晓辰 (女声·甜美)',
    'xiaohan': '晓涵 (女声·温柔)',
    'xiaomeng': '晓梦 (女声·可爱)',
    'xiaomo': '晓墨 (女声·成熟)',
    'xiaoqiu': '晓秋 (女声·知性)',
    'xiaorui': '晓睿 (女声·温暖)',
    'xiaoshuang': '晓双 (女声·童声)',
    'xiaoxuan': '晓萱 (女声·优雅)',
    'xiaoyan': '晓妍 (女声·专业)',
    'xiaozhen': '晓甄 (女声·新闻)',
    'yunxi': '云希 (男声·阳光)',
    'yunxia': '云夏 (男声·少年)',
    'yunyang': '云扬 (男声·新闻)',
  };

  /// ★ 获取 Edge TTS 音色显示名称
  String _getEdgeVoiceName(String edgeVoiceId) {
    return _edgeVoiceDisplayNames[edgeVoiceId] ?? edgeVoiceId;
  }

  /// ★ Edge TTS 音色选择对话框
  void _showEdgeVoiceSelectDialog(BuildContext context, WidgetRef ref, String currentVoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择 Edge TTS 音色'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _edgeVoiceDisplayNames.length,
            itemBuilder: (ctx, index) {
              final voiceId = _edgeVoiceDisplayNames.keys.elementAt(index);
              final voiceName = _edgeVoiceDisplayNames.values.elementAt(index);
              return RadioListTile<String>(
                title: Text(voiceName),
                value: voiceId,
                groupValue: currentVoice,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(voiceSettingsProvider.notifier).setEdgeVoice(value);
                    Navigator.pop(ctx);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ★ CosyVoice 辅助方法
  // ============================================================================

  /// CosyVoice 推理模式映射（CosyVoice2-0.5B 仅支持以下模式）
  static const Map<String, String> _cosyvoiceModeNames = {
    'zero_shot': '零样本克隆',
    'cross_lingual': '跨语言合成',
    'instruct2': '指令控制',
  };

  String _getCosyvoiceModeName(String mode) {
    return _cosyvoiceModeNames[mode] ?? mode;
  }

  /// CosyVoice 服务地址编辑对话框
  void _showCosyvoiceBaseUrlDialog(BuildContext context, WidgetRef ref, String currentUrl) {
    final controller = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CosyVoice 服务地址'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://192.168.1.100:50000',
                labelText: '服务地址（IP:端口 或 域名）',
                helperText: 'CosyVoice Docker 服务 API 地址',
                prefixIcon: Icon(Icons.dns),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            const Text(
              '格式说明：\n'
              '• 本机: http://localhost:50000\n'
              '• 局域网: http://192.168.x.x:50000\n'
              '• 域名: https://tts.example.com\n'
              '• 自定义端口: http://10.0.0.1:8080',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(voiceSettingsProvider.notifier).setCosyvoiceBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// CosyVoice 推理模式选择对话框
  void _showCosyvoiceModeSelectDialog(BuildContext context, WidgetRef ref, String currentMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择推理模式'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _cosyvoiceModeNames.length,
            itemBuilder: (ctx, index) {
              final modeId = _cosyvoiceModeNames.keys.elementAt(index);
              final modeName = _cosyvoiceModeNames.values.elementAt(index);
              return RadioListTile<String>(
                title: Text(modeName),
                value: modeId,
                groupValue: currentMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(voiceSettingsProvider.notifier).setCosyvoiceMode(value);
                    Navigator.pop(ctx);
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// CosyVoice SFT 音色选择对话框
  /// CosyVoice 指令文本编辑对话框
  void _showCosyvoiceInstructDialog(BuildContext context, WidgetRef ref, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('指令文本'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '例如：用悲伤的语气说话',
            labelText: '指令文本',
            helperText: '控制语音的情感、语速、语气等',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(voiceSettingsProvider.notifier).setCosyvoiceInstructText(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// ★ 获取 CosyVoice 音色名称
  Future<String> _getCosyvoiceVoiceName(String voiceId) async {
    if (voiceId == 'default') return '默认音色';
    if (voiceId.startsWith('cv_')) {
      final service = VoiceCloneService();
      final voices = await service.getClonedVoicesByProvider('cosyvoice');
      final match = voices.where((v) => v.id == voiceId).firstOrNull;
      if (match != null) return '${match.name}（克隆）';
    }
    return voiceId;
  }

  /// ★ 获取 CosyVoice 克隆音色数量
  Future<int> _getCosyvoiceCloneCount() async {
    final service = VoiceCloneService();
    final voices = await service.getClonedVoicesByProvider('cosyvoice');
    return voices.length;
  }

  /// ★ CosyVoice 音色选择对话框（默认音色 + 克隆音色）
  Future<void> _showCosyvoiceVoiceSelectDialog(BuildContext context, WidgetRef ref, String currentVoiceId) async {
    final service = VoiceCloneService();
    final clonedVoices = await service.getClonedVoicesByProvider('cosyvoice');

    final presetVoices = [
      {'id': 'default', 'name': '默认音色', 'desc': 'CosyVoice2-0.5B 内置音色'},
    ];
    final cloneVoices = clonedVoices.map((v) => <String, String>{
      'id': v.id,
      'name': v.name,
      'desc': v.isReady ? '克隆音色' : v.isProcessing ? '处理中...' : '克隆失败',
    }).toList();
    final voices = <Map<String, String>>[...presetVoices];
    if (cloneVoices.isNotEmpty) {
      voices.add({'id': '__divider__', 'name': '-- 克隆音色 --', 'desc': ''});
      voices.addAll(cloneVoices);
    }

    if (!context.mounted) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择音色'),
        children: voices.map((v) {
          if (v['id'] == '__divider__') return const Divider();
          final isSelected = currentVoiceId == v['id'];
          final isCloneVoice = (v['id'] ?? '').startsWith('cv_');
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, v['id']),
            child: ListTile(
              leading: isCloneVoice
                  ? const Icon(Icons.mic, color: Colors.teal)
                  : const Icon(Icons.record_voice_over, color: Colors.orange),
              title: Text(v['name'] ?? ''),
              subtitle: Text(v['desc'] ?? ''),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              dense: true,
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      ref.read(voiceSettingsProvider.notifier).setCosyvoiceVoiceId(selected);
      // 选择克隆音色时，自动更新参考音频路径
      if (selected.startsWith('cv_')) {
        final match = clonedVoices.where((v) => v.id == selected).firstOrNull;
        if (match != null) {
          ref.read(voiceSettingsProvider.notifier).setCosyvoiceReferenceAudioPath(match.referenceAudioPath);
        }
      }
    }
  }

  /// ★ 测试 CosyVoice 服务连接 + 合成测试
  Future<void> _testCosyvoiceConnection(BuildContext context, VoiceSettings settings) async {
    // 显示加载中
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在测试连接...'),
          ],
        ),
      ),
    );

    // ★ 跟踪当前是否有加载对话框需要关闭
    bool hasLoadingDialog = true;

    try {
      final baseUrl = settings.cosyvoiceBaseUrl;
      debugPrint('★ [CosyVoice测试] 开始测试, baseUrl=$baseUrl, mode=${settings.cosyvoiceMode}');

      // ★ 第一阶段：连接测试 — 请求 OpenAPI 文档验证服务可达
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse('$baseUrl/openapi.json');
      debugPrint('★ [CosyVoice测试] 第一阶段: GET $uri');
      final request = await client.getUrl(uri);
      final response = await request.close();
      final statusCode = response.statusCode;
      await response.drain<void>();
      debugPrint('★ [CosyVoice测试] 第一阶段完成: 状态码=$statusCode');

      if (statusCode >= 500) {
        if (hasLoadingDialog && context.mounted) {
          Navigator.pop(context);
          hasLoadingDialog = false;
        }
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('服务异常'),
              ]),
              content: Text('CosyVoice 服务返回异常状态码: $statusCode\n地址: $baseUrl\n\n请检查服务是否正常运行'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (statusCode == 404) {
        if (hasLoadingDialog && context.mounted) {
          Navigator.pop(context);
          hasLoadingDialog = false;
        }
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('服务未找到'),
              ]),
              content: Text('地址 $baseUrl 未找到 CosyVoice 服务\n状态码: 404\n\n请检查：\n1. IP 和端口是否正确\n2. CosyVoice Docker 容器是否正在运行'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 连接可达，尝试合成测试
      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('连接成功，正在测试合成...'),
              ],
            ),
          ),
        );
        hasLoadingDialog = true;
      }

      // ★ 第二阶段：合成测试 — 使用正确的 CosyVoice API 端点
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      final mode = settings.cosyvoiceMode;
      String endpoint;
      FormData formData;

      if (mode == 'instruct2') {
        endpoint = '$baseUrl/inference_instruct2';
        String? refAudioPath = settings.cosyvoiceReferenceAudioPath;
        debugPrint('★ [CosyVoice测试] instruct2模式: refAudioPath=$refAudioPath');
        if (refAudioPath.isNotEmpty && await File(refAudioPath).exists()) {
          formData = FormData.fromMap({
            'tts_text': '你好，这是合成测试。',
            'instruct_text': settings.cosyvoiceInstructText,
            'prompt_wav': await MultipartFile.fromFile(refAudioPath, filename: refAudioPath.split('/').last),
          });
        } else {
          if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('需要参考音频'),
                ]),
                content: const Text('instruct2 模式需要参考音频才能测试合成。\n请先录制或选择参考音频。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      } else if (mode == 'zero_shot') {
        endpoint = '$baseUrl/inference_zero_shot';
        String? refAudioPath = settings.cosyvoiceReferenceAudioPath;
        debugPrint('★ [CosyVoice测试] zero_shot模式: refAudioPath=$refAudioPath');
        if (refAudioPath.isNotEmpty && await File(refAudioPath).exists()) {
          formData = FormData.fromMap({
            'tts_text': '你好，这是合成测试。',
            'prompt_text': '',
            'prompt_wav': await MultipartFile.fromFile(refAudioPath, filename: refAudioPath.split('/').last),
          });
        } else {
          if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('需要参考音频'),
                ]),
                content: const Text('零样本克隆模式需要参考音频才能测试合成。\n请先录制或选择参考音频。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      } else {
        // cross_lingual（默认）
        endpoint = '$baseUrl/inference_cross_lingual';
        String? refAudioPath = settings.cosyvoiceReferenceAudioPath;
        debugPrint('★ [CosyVoice测试] cross_lingual模式: refAudioPath=$refAudioPath');
        if (refAudioPath.isNotEmpty && await File(refAudioPath).exists()) {
          formData = FormData.fromMap({
            'tts_text': '你好，这是合成测试。',
            'prompt_wav': await MultipartFile.fromFile(refAudioPath, filename: refAudioPath.split('/').last),
          });
        } else {
          if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('需要参考音频'),
                ]),
                content: const Text('跨语言克隆模式需要参考音频才能测试合成。\n请先录制或选择参考音频。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      debugPrint('★ [CosyVoice测试] 第二阶段: POST $endpoint');
      final synthResponse = await dio.post<dynamic>(
        endpoint,
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      debugPrint('★ [CosyVoice测试] 第二阶段完成: 状态码=${synthResponse.statusCode}, 数据类型=${synthResponse.data.runtimeType}');

      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
      }

      if (synthResponse.statusCode == 200 && synthResponse.data != null) {
        final data = synthResponse.data;
        final audioSize = data is List<int> ? data.length : 0;
        debugPrint('★ [CosyVoice测试] 合成成功: 音频大小=$audioSize bytes');
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('测试成功'),
              ]),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CosyVoice 服务连接正常'),
                  const SizedBox(height: 8),
                  Text('地址: $baseUrl'),
                  Text('连接状态码: $statusCode'),
                  Text('合成测试: 通过'),
                  Text('音频大小: ${(audioSize / 1024).toStringAsFixed(1)} KB'),
                  const SizedBox(height: 8),
                  Text('推理模式: ${_getCosyvoiceModeName(mode)}'),
                  if (settings.cosyvoiceVoiceId != 'default')
                    Text('音色: ${settings.cosyvoiceVoiceId}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        }
      } else {
        debugPrint('★ [CosyVoice测试] 合成异常: 状态码=${synthResponse.statusCode}');
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('合成测试异常'),
              ]),
              content: Text('连接成功但合成返回异常\n状态码: ${synthResponse.statusCode}\n地址: $baseUrl'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        }
      }
    } on DioException catch (e) {
      debugPrint('★ [CosyVoice测试] DioException: type=${e.type}, message=${e.message}, uri=${e.requestOptions.uri}');
      if (e.response != null) {
        debugPrint('★ [CosyVoice测试] 响应: statusCode=${e.response?.statusCode}, data=${e.response?.data}');
      }
      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
      }
      // ★ 尝试从错误响应中提取服务端错误信息
      String serverError = '';
      if (e.response?.data != null) {
        try {
          if (e.response!.data is List<int>) {
            final jsonStr = String.fromCharCodes(e.response!.data as List<int>);
            final decoded = jsonDecode(jsonStr);
            if (decoded is Map && decoded.containsKey('error')) {
              serverError = decoded['error'].toString();
            }
          } else if (e.response!.data is Map) {
            serverError = e.response!.data['error']?.toString() ?? '';
          }
        } catch (_) {}
      }
      final errMsg = serverError.isNotEmpty ? serverError : _handleCosyvoiceDioError(e);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('测试失败'),
            ]),
            content: Text(errMsg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } on SocketException catch (e) {
      debugPrint('★ [CosyVoice测试] SocketException: ${e.message}, address=${e.address}, port=${e.port}');
      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
      }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('连接失败'),
            ]),
            content: Text('无法连接到 CosyVoice 服务\n地址: ${settings.cosyvoiceBaseUrl}\n错误: 网络连接被拒绝\n\n请检查：\n1. 服务是否已启动\n2. IP 地址和端口是否正确\n3. 如果使用模拟器，localhost 不可用，请使用局域网 IP（如 192.168.x.x）'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } on HttpException catch (e) {
      debugPrint('★ [CosyVoice测试] HttpException: ${e.message}');
      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
      }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('HTTP 错误'),
            ]),
            content: Text('HTTP 请求异常\n地址: ${settings.cosyvoiceBaseUrl}\n错误: ${e.message}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('★ [CosyVoice测试] 未知异常: $e');
      debugPrint('★ [CosyVoice测试] 堆栈: $stackTrace');
      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
      }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('测试失败'),
            ]),
            content: Text('无法连接到 CosyVoice 服务\n地址: ${settings.cosyvoiceBaseUrl}\n错误类型: ${e.runtimeType}\n错误信息: $e\n\n请检查：\n1. 服务是否已启动\n2. IP 地址和端口是否正确\n3. 如果使用模拟器，localhost 不可用，请使用局域网 IP'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// CosyVoice Dio 错误处理
  String _handleCosyvoiceDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查 CosyVoice 服务是否启动\n地址: ${e.requestOptions.uri}';
      case DioExceptionType.sendTimeout:
        return '发送超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '接收超时，CosyVoice 推理响应过慢';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return '请求参数错误 (400)\n请检查推理模式和参考音频是否正确';
        } else if (statusCode == 404) {
          return 'API 端点不存在 (404)\n请确认 CosyVoice 服务版本是否正确';
        } else if (statusCode == 500) {
          return 'CosyVoice 服务内部错误 (500)\n请检查 Docker 容器日志';
        }
        return '服务返回错误 ($statusCode)\n${e.response?.data ?? ""}';
      case DioExceptionType.connectionError:
        return '网络连接失败\n请检查 CosyVoice 服务是否启动\n地址: ${e.requestOptions.uri}';
      default:
        return '网络错误: ${e.message ?? e.type.name}';
    }
  }

  // ============================================================================
  // ★ Fish Audio 对话框和测试方法
  // ============================================================================

  /// Fish Audio 服务地址编辑对话框
  void _showFishAudioBaseUrlDialog(BuildContext context, WidgetRef ref, String currentUrl) {
    final controller = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fish Audio 服务地址'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://localhost:50001',
                labelText: '服务地址（IP:端口）',
                helperText: 'Fish Audio MLX 本地服务 API 地址',
                prefixIcon: Icon(Icons.dns),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            const Text(
              '格式说明：\n'
              '• 本机: http://localhost:50001\n'
              '• 局域网: http://192.168.x.x:50001\n'
              '• 启动命令: conda run -n fishaudio python server.py',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(voiceSettingsProvider.notifier).setFishAudioBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// Fish Audio 参考音频文本编辑对话框
  void _showFishAudioRefTextDialog(BuildContext context, WidgetRef ref, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('参考音频文本转录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '输入参考音频对应的文字内容',
                labelText: '文本转录',
                helperText: '可选，提供后可提升语音克隆质量',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '提示：提供参考音频的文本转录可以让模型更准确地克隆音色和语调',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(voiceSettingsProvider.notifier).setFishAudioReferenceText(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// Fish Audio 连接测试
  Future<void> _testFishAudioConnection(BuildContext context, VoiceSettings settings) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在测试 Fish Audio 连接...'),
          ],
        ),
      ),
    );

    bool hasLoadingDialog = true;

    try {
      final baseUrl = settings.fishaudioBaseUrl;
      debugPrint('★ [FishAudio测试] 开始测试, baseUrl=$baseUrl');

      // 第一阶段：健康检查
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final uri = Uri.parse('$baseUrl/health');
      debugPrint('★ [FishAudio测试] GET $uri');
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(const Utf8Decoder()).join();
      debugPrint('★ [FishAudio测试] 状态码=${response.statusCode}, body=$body');

      if (response.statusCode != 200) {
        if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('连接失败'),
              ]),
              content: Text('Fish Audio 服务返回异常状态码: ${response.statusCode}\n地址: $baseUrl'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
            ),
          );
        }
        return;
      }

      // 解析健康状态
      final healthJson = jsonDecode(body) as Map<String, dynamic>;
      final modelLoaded = healthJson['model_loaded'] == true;

      if (!modelLoaded) {
        if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('模型未就绪'),
              ]),
              content: const Text('Fish Audio 服务已连接，但模型尚未加载完成。\n\n首次启动需要下载模型（约 1.5GB），请稍后再试。'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
            ),
          );
        }
        return;
      }

      // 第二阶段：合成测试
      if (hasLoadingDialog && context.mounted) {
        Navigator.pop(context);
        hasLoadingDialog = false;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('连接成功，正在测试合成...'),
              ],
            ),
          ),
        );
        hasLoadingDialog = true;
      }

      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      final formData = FormData.fromMap({
        'text': '你好，这是 Fish Audio 语音合成测试。',
        'output_format': 'wav',
        'speed': '1.0',
      });

      final ttsResponse = await dio.post<List<int>>(
        '$baseUrl/v1/tts',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      final audioBytes = ttsResponse.data!;
      final audioDuration = ttsResponse.headers.value('X-Audio-Duration') ?? '?';
      final genTime = ttsResponse.headers.value('X-Generation-Time') ?? '?';
      final rtf = ttsResponse.headers.value('X-RTF') ?? '?';

      if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('测试成功'),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fish Audio 服务连接正常，语音合成成功！'),
                const SizedBox(height: 12),
                Text('音频时长: ${audioDuration}s'),
                Text('生成耗时: ${genTime}s'),
                Text('RTF (实时率): $rtf'),
                Text('音频大小: ${(audioBytes.length / 1024).toStringAsFixed(1)} KB'),
                const SizedBox(height: 8),
                const Text('提示：在文本中使用 [happy] [whisper] [sad] 等标签控制情感',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
          ),
        );
      }

    } on HttpException catch (e) {
      debugPrint('★ [FishAudio测试] HttpException: ${e.message}');
      if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('连接失败'),
            ]),
            content: Text('无法连接到 Fish Audio 服务\n地址: ${settings.fishaudioBaseUrl}\n错误: ${e.message}\n\n请检查：\n1. 服务是否已启动（python server.py）\n2. 端口是否正确（默认 50001）'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
          ),
        );
      }
    } catch (e) {
      debugPrint('★ [FishAudio测试] 异常: $e');
      if (hasLoadingDialog && context.mounted) { Navigator.pop(context); hasLoadingDialog = false; }
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('测试失败'),
            ]),
            content: Text('Fish Audio 测试异常\n错误: $e\n\n请检查服务是否正常运行'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('确定'))],
          ),
        );
      }
    }
  }

  String _getMiMoVoiceName(String voiceId, List<ClonedVoice> clonedVoices) {
    if (voiceId.startsWith('clone_')) {
      final clone = clonedVoices.where((v) => v.id == voiceId.substring(6)).firstOrNull;
      if (clone != null) {
        String suffix;
        if (clone.isProcessing) {
          suffix = '(处理中)';
        } else if (clone.isFailed) {
          suffix = '(失败)';
        } else {
          suffix = '(克隆)';
        }
        return '${clone.name}$suffix';
      }
      return '未知克隆音色';
    }
    // MiMo 默认音色列表
    final voiceNames = {
      'mimo_default': 'MiMo-默认',
      'bingtang': '冰糖',
      'moli': '茉莉',
      'suda': '苏打',
      'baihua': '白桦',
      'Mia': 'Mia',
      'Chloe': 'Chloe',
      'Milo': 'Milo',
      'Dean': 'Dean',
    };
    return voiceNames[voiceId] ?? voiceId;
  }

  Future<void> _showMiMoApiKeyDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentKey = prefs.getString('mimo_api_key') ?? '';
    final controller = TextEditingController(text: currentKey);
    if (!context.mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置 MiMo API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入小米 MiMo API Key',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await prefs.setString('mimo_api_key', result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MiMo API Key 已保存')),
        );
      }
    }
  }

  Future<void> _showMiMoBaseUrlDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUrl = prefs.getString('mimo_base_url') ?? '';
    final controller = TextEditingController(text: currentUrl);
    if (!context.mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('自定义 MiMo API 地址'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://api.xiaomimimo.com/v1',
                border: OutlineInputBorder(),
                helperText: '留空使用默认地址，支持自定义代理/镜像地址',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '如果遇到 DNS 解析失败（MiMo API 无法访问），可以配置代理地址或镜像服务。',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 清空表示使用默认
              Navigator.pop(ctx, '');
            },
            child: const Text('恢复默认'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    if (result != null) {
      if (result.isEmpty) {
        await prefs.remove('mimo_base_url');
      } else {
        // 确保 URL 格式正确
        String normalized = result;
        if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
          normalized = 'https://$normalized';
        }
        if (!normalized.endsWith('/v1')) {
          normalized = '$normalized/v1';
        }
        await prefs.setString('mimo_base_url', normalized);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.isEmpty ? '已恢复默认 API 地址' : 'MiMo API 地址已保存')),
        );
      }
    }
  }

  Future<void> _showMiMoVoiceSelectDialog(BuildContext context, List<ClonedVoice> clonedVoices) async {
    // MiMo 官方默认音色列表
    final presetVoices = [
      {'id': 'mimo_default', 'name': 'MiMo-默认', 'desc': '因部署集群而异，中国集群默认为冰糖，其他集群默认为Mia'},
      {'id': 'bingtang', 'name': '冰糖', 'desc': '中文 女性'},
      {'id': 'moli', 'name': '茉莉', 'desc': '中文 女性'},
      {'id': 'suda', 'name': '苏打', 'desc': '中文 男性'},
      {'id': 'baihua', 'name': '白桦', 'desc': '中文 男性'},
      {'id': 'Mia', 'name': 'Mia', 'desc': '英文 女性'},
      {'id': 'Chloe', 'name': 'Chloe', 'desc': '英文 女性'},
      {'id': 'Milo', 'name': 'Milo', 'desc': '英文 男性'},
      {'id': 'Dean', 'name': 'Dean', 'desc': '英文 男性'},
    ];
    final cloneVoices = clonedVoices.map((v) => <String, String>{
      'id': 'clone_${v.id}',
      'name': v.name,
      'desc': v.isProcessing ? '克隆处理中...' : v.isFailed ? '克隆失败' : '克隆音色',
    }).toList();
    final voices = <Map<String, String>>[...presetVoices];
    if (cloneVoices.isNotEmpty) {
      voices.add({'id': '__divider__', 'name': '-- 克隆音色 --', 'desc': ''});
      voices.addAll(cloneVoices);
    }
    final currentVoice = ref.read(voiceSettingsProvider).ttsVoice;
    if (!context.mounted) return;
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择音色'),
        children: voices.map((v) {
          if (v['id'] == '__divider__') return const Divider();
          final isSelected = currentVoice == v['id'];
          final isCloneVoice = (v['id'] ?? '').startsWith('clone_');
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, v['id']),
            child: ListTile(
              leading: isCloneVoice
                  ? const Icon(Icons.mic, color: Colors.teal)
                  : const Icon(Icons.record_voice_over, color: Colors.purple),
              title: Text(v['name'] ?? ''),
              subtitle: Text(v['desc'] ?? ''),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              dense: true,
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      ref.read(voiceSettingsProvider.notifier).setTtsVoice(selected);
    }
  }

  // ============================================================================
  // ★ 导演模式辅助方法（MiMo v2.5 director mode）— MVP
  // ============================================================================

  /// 获取导演模板的中文显示名
  String _getDirectorTemplateName(String id) {
    final t = DirectorTemplatePresets.findById(id);
    return t?.name ?? '未选择';
  }

  /// 获取导演模板的简短描述（前 50 字）
  String _getDirectorTemplateDescription(String id) {
    final t = DirectorTemplatePresets.findById(id);
    if (t == null) return '';
    final full = t.role;
    return full.length > 50 ? '${full.substring(0, 50)}…' : full;
  }

  /// 显示导演模板选择对话框
  void _showDirectorTemplateSelectDialog(
    BuildContext context,
    WidgetRef ref,
    String currentId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择导演模板'),
        content: SizedBox(
          width: double.maxFinite,
          height: 380,
          child: ListView(
            shrinkWrap: true,
            children: DirectorTemplatePresets.all.map((t) {
              final isSelected = t.id == currentId;
              return InkWell(
                onTap: () {
                  ref.read(voiceSettingsProvider.notifier).setDirectorTemplateId(t.id);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已切换到「${t.name}」模板'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.movie_creation, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示导演描述完整预览
  void _showDirectorPreviewDialog(BuildContext context, String templateId) {
    final t = DirectorTemplatePresets.findById(templateId);
    if (t == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('「${t.name}」导演描述预览'),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.2),
              ),
            ),
            child: SelectableText(
              t.composed,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: t.composed));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            child: const Text('复制'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示音色描述编辑对话框
  void _showVoiceDesignEditDialog(
    BuildContext context,
    WidgetRef ref,
    String currentPrompt,
  ) {
    final controller = TextEditingController(text: currentPrompt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑音色描述'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '用自然语言描述想要的音色（如：年轻女性声音、温柔且略带磁性的中低音）。\n此描述会在 V1.0 版本中传递给 MiMo voicedesign 模型生成专属音色。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '例如：年轻女性声音，温柔且略带磁性的中低音',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('音色描述不能为空')),
                );
                return;
              }
              ref.read(voiceSettingsProvider.notifier).setVoiceDesignPrompt(text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('音色描述已保存（V1.0 完整启用）'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

// 设置区块组件
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacingS,
            bottom: AppTheme.spacingS,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

// 模型下载项组件
class _ModelDownloadItem extends StatefulWidget {
  final VoiceModelInfo model;
  final VoidCallback onDownload;

  const _ModelDownloadItem({
    required this.model,
    required this.onDownload,
  });

  @override
  State<_ModelDownloadItem> createState() => _ModelDownloadItemState();
}

class _ModelDownloadItemState extends State<_ModelDownloadItem> {
  bool _isDownloaded = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final service = VoiceModelService();
    final downloaded = await service.isModelDownloaded(widget.model.id);
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return ListTile(
      title: Text(model.name),
      subtitle: Text(
        '${model.description}\n${VoiceModelService.formatFileSize(model.fileSize)}',
        maxLines: 2,
      ),
      trailing: _isChecking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _isDownloaded
              ? const Icon(Icons.check_circle, color: Colors.green)
              : FilledButton(
                  onPressed: widget.onDownload,
                  child: const Text('下载'),
                ),
    );
  }
}

// 下载进度对话框
class _DownloadProgressDialog extends StatefulWidget {
  final VoiceModelInfo model;
  final VoidCallback onCancel;

  const _DownloadProgressDialog({
    super.key,
    required this.model,
    required this.onCancel,
  });

  @override
  State<_DownloadProgressDialog> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<_DownloadProgressDialog> {
  double _progress = 0;
  String _status = 'downloading'; // downloading, extracting, completed, error
  String? _errorMessage;
  // 0..0.8 = 下载, 0.8..1.0 = 解压（UI 端平滑过渡用）
  String _statusText = '下载中';

  void updateProgress(VoiceModelDownloadProgress progress) {
    if (mounted) {
      setState(() {
        _progress = progress.progress;
        _status = progress.status;
        _errorMessage = progress.error;
        // ★ 状态文本映射
        _statusText = switch (progress.status) {
          'downloading' => '下载中 ${(progress.progress * 100).toStringAsFixed(1)}%',
          'extracting' => '解压中...',
          'completed' => '下载完成',
          'error' => '下载失败',
          'paused' => '已暂停',
          _ => '准备中...',
        };
      });
    }
  }

  bool get _isCompleted => _status == 'completed';
  bool get _isError => _status == 'error';

  @override
  Widget build(BuildContext context) {
    // ★ 进度条：下载阶段显示真实进度（0-1），解压阶段显示 0.95（已接近完成）
    final displayProgress = _status == 'extracting'
        ? 0.95
        : (_status == 'completed' ? 1.0 : _progress);

    return AlertDialog(
      title: Text('下载 ${widget.model.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: displayProgress),
          const SizedBox(height: 16),
          Text(_statusText,
              style: TextStyle(
                color: _isError ? Colors.red : (_isCompleted ? Colors.green : null),
                fontWeight: _isCompleted || _isError ? FontWeight.bold : null,
              )),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text('错误: $_errorMessage',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        // ★ 完成时显示"完成"按钮，错误时显示"关闭"，下载中显示"取消"
        if (_isCompleted)
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('完成', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        else if (_isError)
          TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('关闭'),
          )
        else
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('取消'),
          ),
      ],
    );
  }
}