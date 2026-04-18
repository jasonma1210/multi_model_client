import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/voice_model_service.dart';
import '../../../../l10n/app_localizations.dart';

// 语音设置 Provider
final voiceSettingsProvider = StateNotifierProvider<VoiceSettingsNotifier, VoiceSettings>((ref) {
  return VoiceSettingsNotifier();
});

class VoiceSettings {
  final String ttsProvider; // sherpa, system
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

  const VoiceSettings({
    this.ttsProvider = 'sherpa',
    this.ttsVoice = '0',
    this.ttsSpeed = 1.0,
    this.autoPlayTts = true,
    this.enableVad = true,
    this.selectedAsrModelId = 'sensevoice-int8',
    this.selectedTtsModelId = 'melo-zh-en',
    this.systemTtsSpeed = 0.5,  // flutter_tts 范围 0.0-1.0，默认 0.5
    this.systemTtsPitch = 1.0,
  });

  VoiceSettings copyWith({
    String? ttsProvider,
    String? ttsVoice,
    double? ttsSpeed,
    bool? autoPlayTts,
    bool? enableVad,
    String? selectedAsrModelId,
    String? selectedTtsModelId,
    double? systemTtsSpeed,
    double? systemTtsPitch,
  }) {
    return VoiceSettings(
      ttsProvider: ttsProvider ?? this.ttsProvider,
      ttsVoice: ttsVoice ?? this.ttsVoice,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      autoPlayTts: autoPlayTts ?? this.autoPlayTts,
      enableVad: enableVad ?? this.enableVad,
      selectedAsrModelId: selectedAsrModelId ?? this.selectedAsrModelId,
      selectedTtsModelId: selectedTtsModelId ?? this.selectedTtsModelId,
      systemTtsSpeed: systemTtsSpeed ?? this.systemTtsSpeed,
      systemTtsPitch: systemTtsPitch ?? this.systemTtsPitch,
    );
  }
}

class VoiceSettingsNotifier extends StateNotifier<VoiceSettings> {
  VoiceSettingsNotifier() : super(const VoiceSettings()) {
    _loadSettings();
  }

  static const String _ttsProviderKey = 'tts_provider';
  static const String _selectedAsrModelKey = 'selected_asr_model_id';
  static const String _selectedTtsModelKey = 'selected_tts_model_id';
  static const String _ttsVoiceKey = 'tts_voice_id';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      ttsProvider: prefs.getString(_ttsProviderKey) ?? 'sherpa',
      selectedAsrModelId: prefs.getString(_selectedAsrModelKey) ?? 'sensevoice-int8',
      selectedTtsModelId: prefs.getString(_selectedTtsModelKey) ?? 'melo-zh-en',
      ttsVoice: prefs.getString(_ttsVoiceKey) ?? '0',
    );
  }

  void setTtsProvider(String value) {
    state = state.copyWith(ttsProvider: value);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_ttsProviderKey, value);
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
];

class VoiceSettingsPage extends ConsumerWidget {
  const VoiceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider);
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
      await service.downloadModel(
        modelId: model.id,
        onProgress: (progress) {
          if (progressKey.currentState != null) {
            progressKey.currentState!.updateProgress(progress.progress);
          }
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} 下载完成')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('下载失败: $e')),
        );
      }
    }
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

// 模型下载项
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
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    final service = VoiceModelService();
    final downloaded = await service.isModelDownloaded(widget.model.id);
    if (mounted) {
      setState(() => _isDownloaded = downloaded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        _isDownloaded ? Icons.check_circle : Icons.download,
        color: _isDownloaded ? Colors.green : theme.colorScheme.primary,
      ),
      title: Text(widget.model.name),
      subtitle: Text(
        '${widget.model.description}\n${VoiceModelService.formatFileSize(widget.model.fileSize)}',
        maxLines: 2,
      ),
      trailing: _isDownloaded
          ? const Text('已下载', style: TextStyle(color: Colors.green))
          : _isDownloading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: () {
                    setState(() => _isDownloading = true);
                    widget.onDownload();
                  },
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
  double _progress = 0.0;

  void updateProgress(double value) {
    if (mounted) {
      setState(() => _progress = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('下载 ${widget.model.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 16),
          Text('${(_progress * 100).toStringAsFixed(1)}%'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('取消'),
        ),
      ],
    );
  }
}
