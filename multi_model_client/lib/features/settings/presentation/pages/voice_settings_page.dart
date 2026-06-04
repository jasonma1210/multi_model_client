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

  const VoiceSettings({
    this.ttsProvider = 'sherpa',
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

    state = state.copyWith(
      ttsProvider: prefs.getString(_ttsProviderKey) ?? 'sherpa',
      asrProvider: prefs.getString(_asrProviderKey) ?? 'system',  // ★ 新增
      selectedAsrModelId: prefs.getString(_selectedAsrModelKey) ?? 'sensevoice-int8',
      selectedTtsModelId: prefs.getString(_selectedTtsModelKey) ?? 'melo-zh-en',
      ttsVoice: prefs.getString(_ttsVoiceKey) ?? '0',
      // ★ 导演模式加载（默认关闭，避免影响现有用户）
      enableDirectorMode: prefs.getBool(_enableDirectorModeKey) ?? false,
      directorTemplateId: prefs.getString(_directorTemplateIdKey) ?? 'tsundere',
      voiceDesignPrompt: prefs.getString(_voiceDesignPromptKey)
          ?? '年轻女性声音，温柔且略带磁性的中低音',
      // ★ V1.0：用户自定义模板
      customTemplates: customs,
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
    state = state.copyWith(ttsProvider: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_ttsProviderKey, value);
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
  {'id': 'system', 'name': '系统语音合成', 'desc': '使用系统自带的 TTS 引擎'},
  {'id': 'mimo', 'name': '小米 MiMo TTS', 'desc': '云端语音合成，音色丰富，需 API Key'},
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
              '如果遇到 DNS 解析失败（api.xiaomimimo.com 无法访问），可以配置代理地址或镜像服务。',
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