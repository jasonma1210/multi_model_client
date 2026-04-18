import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/models/model_entry.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════
//  模型管理页（重构版）
//  路由: /settings/models
//  功能：
//   - 本地模型列表 + 参数配置（效果图）
//   - 远程模型：OpenAI / Anthropic / Ollama 三协议
//   - 模型市场入口
// ════════════════════════════════════════════════════════════════════════════

class ModelManagementPage extends ConsumerStatefulWidget {
  const ModelManagementPage({super.key});

  @override
  ConsumerState<ModelManagementPage> createState() => _ModelManagementPageState();
}

class _ModelManagementPageState extends ConsumerState<ModelManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 进入页面时扫描本地模型
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelProvider.notifier).scanDownloadedModels();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('模型管理'),
        centerTitle: false,
        actions: [
          // 进入模型市场
          TextButton.icon(
            onPressed: () => context.go('/model-market'),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text('模型市场'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.storage_outlined, size: 18), text: '本地模型'),
            Tab(icon: Icon(Icons.cloud_outlined, size: 18), text: '远程 API'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LocalModelsTab(onOpenMarket: () => context.go('/model-market')),
          const _RemoteModelsTab(),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  本地模型 Tab
// ════════════════════════════════════════════════════════════════════════════

class _LocalModelsTab extends ConsumerWidget {
  final VoidCallback onOpenMarket;
  const _LocalModelsTab({required this.onOpenMarket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(modelProvider);
    final locals = state.localModels;

    return Stack(
      children: [
        if (locals.isEmpty)
          _buildEmpty(context, theme)
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              // 已加载的模型提示
              if (state.loadedModel != null) ...[
                _LoadedModelBanner(model: state.loadedModel!),
                const SizedBox(height: 12),
              ],
              // 模型列表
              ...locals.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LocalModelCard(model: m),
              )),
            ],
          ),
        // 底部按钮
        Positioned(
          left: 16, right: 16, bottom: 24,
          child: Row(
            children: [
              // 导入本地文件
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _importLocalFile(context, ref),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('导入本地文件'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 去模型市场下载
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenMarket,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('去下载模型'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.storage_outlined, size: 44, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text('还没有本地模型', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '您可以从模型市场下载 GGUF 量化模型，\n或者导入已有的本地 .gguf 文件。',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importLocalFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gguf'],
      dialogTitle: '选择 GGUF 模型文件',
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final fileName = file.name.replaceAll('.gguf', '').replaceAll('_', ' ');

    await ref.read(modelProvider.notifier).addLocalModel(
      displayName: fileName,
      filePath: file.path!,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导入：$fileName'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  本地模型卡片
// ════════════════════════════════════════════════════════════════════════════

class _LocalModelCard extends ConsumerWidget {
  final ModelEntry model;
  const _LocalModelCard({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/model/${model.id}/load'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 图标 + 加载状态
                  Stack(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.memory_rounded, color: Colors.white, size: 24),
                      ),
                      if (model.isLoaded)
                        Positioned(
                          right: 0, bottom: 0,
                          child: Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (model.parameterSize != null) ...[
                              _SmallTag('${model.parameterSize}B', Colors.indigo.shade400),
                              const SizedBox(width: 4),
                            ],
                            if (model.quantLevel != null) ...[
                              _SmallTag(model.quantLevel!, Colors.blue.shade400),
                              const SizedBox(width: 4),
                            ],
                            if (model.isLoaded)
                              _SmallTag('已加载', Colors.green.shade600),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 操作菜单
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'load',
                        child: ListTile(
                          leading: Icon(Icons.rocket_launch_outlined),
                          title: Text('加载/配置'),
                          dense: true,
                        ),
                      ),
                      PopupMenuItem(
                        value: model.isLoaded ? 'unload' : 'load',
                        child: ListTile(
                          leading: Icon(model.isLoaded ? Icons.eject_outlined : Icons.play_circle_outline),
                          title: Text(model.isLoaded ? '卸载' : '加载'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('删除', style: TextStyle(color: Colors.red)),
                          dense: true,
                        ),
                      ),
                    ],
                    onSelected: (action) => _handleAction(context, ref, action),
                  ),
                ],
              ),
              if (model.filePath != null) ...[
                const SizedBox(height: 8),
                Text(
                  model.filePath!.split('/').last,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'load':
        context.go('/model/${model.id}/load');
        break;
      case 'unload':
        ref.read(modelProvider.notifier).setModelLoaded(model.id, false);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除模型'),
            content: Text('确认删除「${model.displayName}」？\n注意：这只会从列表中移除记录，不会删除磁盘上的文件。'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          ref.read(modelProvider.notifier).deleteModel(model.id);
        }
        break;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  已加载模型 Banner
// ════════════════════════════════════════════════════════════════════════════

class _LoadedModelBanner extends StatelessWidget {
  final ModelEntry model;
  const _LoadedModelBanner({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${model.displayName} 已加载并就绪',
              style: TextStyle(color: Colors.green.shade800, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  远程模型 Tab（OpenAI / Anthropic / Ollama）
// ════════════════════════════════════════════════════════════════════════════

class _RemoteModelsTab extends ConsumerWidget {
  const _RemoteModelsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remotes = ref.watch(modelProvider).remoteModels;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // 协议快速添加
            Text(
              '选择协议类型',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ProtocolCard(
                    title: 'OpenAI',
                    subtitle: 'GPT-4o, GPT-3.5\n及所有兼容 API',
                    icon: '🤖',
                    color: const Color(0xFF10A37F),
                    onTap: () => _showAddRemoteDialog(context, ref, RemoteProtocol.openai),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProtocolCard(
                    title: 'Anthropic',
                    subtitle: 'Claude 3.5 Sonnet\nClaude 3 Haiku',
                    icon: '🌟',
                    color: const Color(0xFFD4741A),
                    onTap: () => _showAddRemoteDialog(context, ref, RemoteProtocol.anthropic),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProtocolCard(
                    title: 'Ollama',
                    subtitle: '本地 Ollama\n服务集成',
                    icon: '🦙',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _showAddRemoteDialog(context, ref, RemoteProtocol.ollama),
                  ),
                ),
              ],
            ),
            if (remotes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '已配置的远程模型',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...remotes.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RemoteModelCard(model: m),
              )),
            ] else ...[
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '还没有配置远程模型\n点击上方协议类型快速添加',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _showAddRemoteDialog(
      BuildContext context, WidgetRef ref, RemoteProtocol protocol) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddRemoteModelSheet(protocol: protocol),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  协议卡片
// ════════════════════════════════════════════════════════════════════════════

class _ProtocolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ProtocolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.add_rounded, size: 14, color: color),
                  const SizedBox(width: 2),
                  Text(
                    '添加',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  远程模型卡片
// ════════════════════════════════════════════════════════════════════════════

class _RemoteModelCard extends ConsumerWidget {
  final ModelEntry model;
  const _RemoteModelCard({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = model.remoteConfig!;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 协议图标
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _protocolColor(config.protocol).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _protocolIcon(config.protocol),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _SmallTag(_protocolLabel(config.protocol), _protocolColor(config.protocol)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            config.modelId,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      config.baseUrl,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('编辑'),
                      dense: true,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('删除', style: TextStyle(color: Colors.red)),
                      dense: true,
                    ),
                  ),
                ],
                onSelected: (action) {
                  if (action == 'edit') _showEditDialog(context, ref);
                  if (action == 'delete') ref.read(modelProvider.notifier).deleteModel(model.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddRemoteModelSheet(
        protocol: model.remoteConfig!.protocol,
        existingModel: model,
      ),
    );
  }

  String _protocolIcon(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return '🤖';
      case RemoteProtocol.anthropic: return '🌟';
      case RemoteProtocol.ollama: return '🦙';
    }
  }

  String _protocolLabel(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return 'OpenAI';
      case RemoteProtocol.anthropic: return 'Anthropic';
      case RemoteProtocol.ollama: return 'Ollama';
    }
  }

  Color _protocolColor(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return const Color(0xFF10A37F);
      case RemoteProtocol.anthropic: return const Color(0xFFD4741A);
      case RemoteProtocol.ollama: return const Color(0xFF7C3AED);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  添加/编辑远程模型 Bottom Sheet
// ════════════════════════════════════════════════════════════════════════════

class _AddRemoteModelSheet extends ConsumerStatefulWidget {
  final RemoteProtocol protocol;
  final ModelEntry? existingModel;

  const _AddRemoteModelSheet({required this.protocol, this.existingModel});

  @override
  ConsumerState<_AddRemoteModelSheet> createState() => _AddRemoteModelSheetState();
}

class _AddRemoteModelSheetState extends ConsumerState<_AddRemoteModelSheet> {
  late TextEditingController _nameController;
  late TextEditingController _baseUrlController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelIdController;
  late TextEditingController _maxTokensController;
  late double _temperature;
  late double _topP;
  late int _maxTokens;
  bool _showApiKey = false;
  bool _isSaving = false;

  // 预设模型列表
  Map<RemoteProtocol, List<String>> get _presetModels => {
    RemoteProtocol.openai: [
      'gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo',
      'o1', 'o1-mini', 'o3-mini',
    ],
    RemoteProtocol.anthropic: [
      'claude-3-5-sonnet-20241022', 'claude-3-5-haiku-20241022',
      'claude-3-opus-20240229', 'claude-3-sonnet-20240229',
    ],
    RemoteProtocol.ollama: [
      'llama3.2', 'llama3.1:8b', 'qwen2.5:7b', 'mistral:7b',
      'gemma2:9b', 'phi3.5', 'deepseek-r1:8b',
    ],
  };

  @override
  void initState() {
    super.initState();
    final existing = widget.existingModel?.remoteConfig;
    final preset = _defaultConfig(widget.protocol);

    _nameController = TextEditingController(
      text: widget.existingModel?.displayName ?? _defaultName(widget.protocol),
    );
    _baseUrlController = TextEditingController(text: existing?.baseUrl ?? preset.baseUrl);
    // Ollama 默认 API Key 为 "ollama"，其他协议使用空或已有值
    _apiKeyController = TextEditingController(
      text: existing?.apiKey ?? (widget.protocol == RemoteProtocol.ollama ? 'ollama' : ''),
    );
    _modelIdController = TextEditingController(text: existing?.modelId ?? preset.modelId);
    _temperature = existing?.temperature ?? preset.temperature;
    _topP = existing?.topP ?? preset.topP;
    _maxTokens = existing?.maxTokens ?? preset.maxTokens;
    _maxTokensController = TextEditingController(text: '$_maxTokens');
  }

  RemoteModelConfig _defaultConfig(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return RemoteModelConfig.openAIPreset();
      case RemoteProtocol.anthropic:
        return RemoteModelConfig.anthropicPreset();
      case RemoteProtocol.ollama:
        // 使用全局 Ollama 配置（包括 API Key）
        final settingsService = ref.read(settingsServiceProvider);
        final apiKey = settingsService.getOllamaApiKey();
        return RemoteModelConfig.ollamaPreset(
          baseUrl: settingsService.getOllamaBaseUrl(),
          modelId: settingsService.getOllamaDefaultModel(),
          apiKey: apiKey.isNotEmpty ? apiKey : 'ollama', // 默认使用 ollama 作为 API Key
        );
    }
  }

  String _defaultName(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return 'GPT-4o';
      case RemoteProtocol.anthropic: return 'Claude 3.5 Sonnet';
      case RemoteProtocol.ollama: return 'Ollama - llama3.2';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelIdController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _protocolColor(widget.protocol);

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖动把手
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 协议标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_protocolIcon(widget.protocol), style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.existingModel != null ? '编辑模型' : '添加 ${_protocolLabel(widget.protocol)} 模型',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _protocolDesc(widget.protocol),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 名称
            _buildTextField('显示名称', _nameController, Icons.label_outlined),
            const SizedBox(height: 12),

            // Base URL
            _buildTextField(
              'API 地址 (Base URL)',
              _baseUrlController,
              Icons.link_rounded,
              hint: _defaultConfig(widget.protocol).baseUrl,
            ),
            const SizedBox(height: 12),

            // API Key
            TextField(
              controller: _apiKeyController,
              obscureText: !_showApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: widget.protocol == RemoteProtocol.anthropic
                    ? 'sk-ant-...'
                    : widget.protocol == RemoteProtocol.ollama
                        ? 'ollama'
                        : 'sk-...',
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showApiKey = !_showApiKey),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // 模型 ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('模型 ID', _modelIdController, Icons.smart_toy_outlined),
                const SizedBox(height: 6),
                // 预设模型快选
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: (_presetModels[widget.protocol] ?? []).map((m) {
                    final isSelected = _modelIdController.text == m;
                    return ActionChip(
                      label: Text(m, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : null)),
                      backgroundColor: isSelected ? color : null,
                      onPressed: () {
                        _modelIdController.text = m;
                        // 同步更新名称
                        if (_nameController.text == _defaultName(widget.protocol)) {
                          _nameController.text = m;
                        }
                        setState(() {});
                      },
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 推理参数（可折叠）
            ExpansionTile(
              title: const Text('推理参数（高级）', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              tilePadding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildSlider('Temperature', _temperature, 0.0, 2.0, (v) => setState(() => _temperature = v)),
                _buildSlider('Top P', _topP, 0.0, 1.0, (v) => setState(() => _topP = v)),
                Row(
                  children: [
                    Expanded(child: Text('Max Tokens', style: theme.textTheme.bodyMedium)),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                        ),
                        controller: _maxTokensController,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _maxTokens = int.tryParse(v) ?? 4096,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
            const SizedBox(height: 16),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.existingModel != null ? '保存修改' : '添加模型',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSlider(
    String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Expanded(
          child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 36,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    final config = RemoteModelConfig(
      protocol: widget.protocol,
      baseUrl: _baseUrlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      modelId: _modelIdController.text.trim(),
      temperature: _temperature,
      topP: _topP,
      maxTokens: _maxTokens,
    );

    if (widget.existingModel != null) {
      await ref.read(modelProvider.notifier).updateRemoteConfig(
            widget.existingModel!.id, config, displayName: name);
    } else {
      await ref.read(modelProvider.notifier).addRemoteModel(
            displayName: name, config: config);
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  String _protocolIcon(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return '🤖';
      case RemoteProtocol.anthropic: return '🌟';
      case RemoteProtocol.ollama: return '🦙';
    }
  }

  String _protocolLabel(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return 'OpenAI';
      case RemoteProtocol.anthropic: return 'Anthropic';
      case RemoteProtocol.ollama: return 'Ollama';
    }
  }

  String _protocolDesc(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return '兼容 OpenAI v1 标准 API';
      case RemoteProtocol.anthropic: return '原生 Anthropic Messages API';
      case RemoteProtocol.ollama: return '本地 Ollama 服务（默认 API Key: ollama）';
    }
  }

  Color _protocolColor(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai: return const Color(0xFF10A37F);
      case RemoteProtocol.anthropic: return const Color(0xFFD4741A);
      case RemoteProtocol.ollama: return const Color(0xFF7C3AED);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  通用小工具
// ════════════════════════════════════════════════════════════════════════════

class _SmallTag extends StatelessWidget {
  final String label;
  final Color color;
  const _SmallTag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
