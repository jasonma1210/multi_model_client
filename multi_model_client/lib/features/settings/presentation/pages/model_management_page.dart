import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/model_entry.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/security_bookmark_service.dart';
import '../../../../core/widgets/model_avatar.dart';

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
  ConsumerState<ModelManagementPage> createState() =>
      _ModelManagementPageState();
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
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
    final mmprojs = state.mmprojModels;

    return Stack(
      children: [
        if (locals.isEmpty && mmprojs.isEmpty)
          _buildEmpty(context, theme, ref)
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
              if (locals.isNotEmpty) ...[
                ...locals.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LocalModelCard(model: m),
                  ),
                ),
              ],
              // mmproj 投影仪列表（如果有）
              if (mmprojs.isNotEmpty) ...[
                const SizedBox(height: 8),
                _MmprojSection(models: mmprojs),
              ],
            ],
          ),
        // 底部按钮
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Row(
            children: [
              // 导入本地文件
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _importLocalFile(context, ref),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('导入模型'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 去模型市场下载
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenMarket,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('下载模型'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 导入本地 GGUF 模型文件
  Future<void> _importLocalFile(BuildContext context, WidgetRef ref) async {
    // 使用 FilePicker 选取文件夹
    // macOS 使用 NSOpenPanel（一步创建 Bookmark），其他平台使用 FilePicker
    final result = await SecurityBookmarkService.instance
        .pickDirectoryWithBookmark(dialogTitle: '选择模型文件夹');

    if (result == null) return;

    // macOS 沙盒：确保访问权限已激活
    await SecurityBookmarkService.instance.startAccessing(result);

    // 查找文件夹中的 .gguf 文件
    final dir = Directory(result);
    if (!await dir.exists()) return;

    List<FileSystemEntity> ggufFiles = [];
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.gguf')) {
        ggufFiles.add(entity);
      }
    }

    if (ggufFiles.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('未找到 GGUF 模型文件'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 逐个导入找到的模型
    for (final file in ggufFiles) {
      final fileName = file.path
          .split('/')
          .last
          .replaceAll('.gguf', '')
          .replaceAll('_', ' ');
      try {
        await ref
            .read(modelProvider.notifier)
            .addLocalModel(displayName: fileName, filePath: file.path);
      } catch (e) {
        debugPrint('导入模型失败: $e');
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导入 ${ggufFiles.length} 个模型'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标容器
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有本地模型',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '您可以从模型市场下载 GGUF 量化模型，\n或者导入已有的本地 .gguf 文件。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
      elevation: 0,
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 模型头像：随机背景色 + 首字母
                  ModelAvatar(
                    modelName: model.displayName,
                    size: 52,
                    isLoaded: model.isLoaded,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // 标签行
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            // 多模态图标（支持图片/视频理解）
                            if (model.supportsMultimodal)
                              _ModelTag(
                                icon: Icons.image_outlined,
                                label: 'Vision',
                                color: Colors.purple,
                              ),
                            if (model.parameterSize != null)
                              _ModelTag(
                                label: '${model.parameterSize}B',
                                color: Colors.indigo,
                              ),
                            if (model.quantLevel != null)
                              _ModelTag(
                                label: model.quantLevel!,
                                color: Colors.blue,
                              ),
                            if (model.isLoaded)
                              _ModelTag(
                                icon: Icons.check_circle_outline,
                                label: '已加载',
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 操作按钮
                  _ModelCardActions(model: model),
                ],
              ),
              if (model.filePath != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          model.filePath!.split('/').last,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.shade500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.displayName,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '已加载并就绪',
                  style: TextStyle(color: Colors.green.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.green.shade400),
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
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                    onTap: () => _showAddRemoteDialog(
                      context,
                      ref,
                      RemoteProtocol.openai,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProtocolCard(
                    title: 'Anthropic',
                    subtitle: 'Claude 3.5 Sonnet\nClaude 3 Haiku',
                    icon: '🌟',
                    color: const Color(0xFFD4741A),
                    onTap: () => _showAddRemoteDialog(
                      context,
                      ref,
                      RemoteProtocol.anthropic,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProtocolCard(
                    title: 'Ollama',
                    subtitle: '本地 Ollama\n服务集成',
                    icon: '🦙',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _showAddRemoteDialog(
                      context,
                      ref,
                      RemoteProtocol.ollama,
                    ),
                  ),
                ),
              ],
            ),
            if (remotes.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                '已配置的远程模型',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ...remotes.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RemoteModelCard(model: m),
                ),
              ),
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
    BuildContext context,
    WidgetRef ref,
    RemoteProtocol protocol,
  ) async {
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
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _protocolColor(
                    config.protocol,
                  ).withValues(alpha: 0.12),
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _ModelTag(
                          label: _protocolLabel(config.protocol),
                          color: _protocolColor(config.protocol),
                        ),
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
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
                  if (action == 'delete') {
                    _confirmDeleteRemoteModel(context, ref);
                  }
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
      case RemoteProtocol.openai:
        return '🤖';
      case RemoteProtocol.anthropic:
        return '🌟';
      case RemoteProtocol.ollama:
        return '🦙';
    }
  }

  String _protocolLabel(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return 'OpenAI';
      case RemoteProtocol.anthropic:
        return 'Anthropic';
      case RemoteProtocol.ollama:
        return 'Ollama';
    }
  }

  Color _protocolColor(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return const Color(0xFF10A37F);
      case RemoteProtocol.anthropic:
        return const Color(0xFFD4741A);
      case RemoteProtocol.ollama:
        return const Color(0xFF7C3AED);
    }
  }

  /// 确认删除远程模型（仅删除关联会话，不删除模型文件）
  Future<void> _confirmDeleteRemoteModel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模型'),
        content: Text(
          '确认删除「${model.displayName}」？\n\n'
          '注意：所有基于该模型的会话及聊天记录将被删除，此操作不可恢复！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // 模型列表中删除：先删除关联会话，再删除模型记录
      await ref.read(modelProvider.notifier).deleteModel(model.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已删除模型及关联会话'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
  ConsumerState<_AddRemoteModelSheet> createState() =>
      _AddRemoteModelSheetState();
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
  late bool _supportsMultimodal;
  bool _showApiKey = false;
  bool _isSaving = false;

  // 预设模型列表
  Map<RemoteProtocol, List<String>> get _presetModels => {
    RemoteProtocol.openai: [
      'gpt-4o',
      'gpt-4o-mini',
      'gpt-4-turbo',
      'gpt-3.5-turbo',
      'o1',
      'o1-mini',
      'o3-mini',
    ],
    RemoteProtocol.anthropic: [
      'claude-3-5-sonnet-20241022',
      'claude-3-5-haiku-20241022',
      'claude-3-opus-20240229',
      'claude-3-sonnet-20240229',
    ],
    RemoteProtocol.ollama: [
      'llama3.2',
      'llama3.1:8b',
      'qwen2.5:7b',
      'mistral:7b',
      'gemma2:9b',
      'phi3.5',
      'deepseek-r1:8b',
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
    _baseUrlController = TextEditingController(
      text: existing?.baseUrl ?? preset.baseUrl,
    );
    // Ollama 默认 API Key 为 "ollama"，其他协议使用空或已有值
    _apiKeyController = TextEditingController(
      text:
          existing?.apiKey ??
          (widget.protocol == RemoteProtocol.ollama ? 'ollama' : ''),
    );
    _modelIdController = TextEditingController(
      text: existing?.modelId ?? preset.modelId,
    );
    _temperature = existing?.temperature ?? preset.temperature;
    _topP = existing?.topP ?? preset.topP;
    _maxTokens = existing?.maxTokens ?? preset.maxTokens;
    _maxTokensController = TextEditingController(text: '$_maxTokens');
    _supportsMultimodal =
        widget.existingModel?.isMultimodal ?? true; // 远程模型默认支持多模态
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
          apiKey: apiKey.isNotEmpty
              ? apiKey
              : 'ollama', // 默认使用 ollama 作为 API Key
        );
    }
  }

  String _defaultName(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return 'GPT-4o';
      case RemoteProtocol.anthropic:
        return 'Claude 3.5 Sonnet';
      case RemoteProtocol.ollama:
        return 'Ollama - llama3.2';
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
        left: 24,
        right: 24,
        top: 16,
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
                width: 36,
                height: 4,
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
                  child: Text(
                    _protocolIcon(widget.protocol),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.existingModel != null
                          ? '编辑模型'
                          : '添加 ${_protocolLabel(widget.protocol)} 模型',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _protocolDesc(widget.protocol),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
                  icon: Icon(
                    _showApiKey ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _showApiKey = !_showApiKey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 模型 ID
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  '模型 ID',
                  _modelIdController,
                  Icons.smart_toy_outlined,
                ),
                const SizedBox(height: 6),
                // 预设模型快选
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (_presetModels[widget.protocol] ?? []).map((m) {
                    final isSelected = _modelIdController.text == m;
                    return ActionChip(
                      label: Text(
                        m,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      backgroundColor: isSelected ? color : null,
                      onPressed: () {
                        _modelIdController.text = m;
                        // 同步更新名称
                        if (_nameController.text ==
                            _defaultName(widget.protocol)) {
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
              title: const Text(
                '推理参数（高级）',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              tilePadding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildSlider(
                  'Temperature',
                  _temperature,
                  0.0,
                  2.0,
                  (v) => setState(() => _temperature = v),
                ),
                _buildSlider(
                  'Top P',
                  _topP,
                  0.0,
                  1.0,
                  (v) => setState(() => _topP = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Max Tokens',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
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

            // 多模态开关
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '支持多模态',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: _supportsMultimodal,
                        onChanged: (v) =>
                            setState(() => _supportsMultimodal = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _supportsMultimodal
                        ? '✅ 已启用：可发送图片给模型进行分析（如截图、照片等）'
                        : '❌ 已禁用：仅支持纯文本对话',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _supportsMultimodal
                          ? Colors.green
                          : theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 提示：多模态模型需要具备视觉理解能力。远程 API（OpenAI/Anthropic）默认支持；本地模型需使用 VL/Vision 版本（如 llava、Qwen2-VL 等）。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
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
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
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
      await ref
          .read(modelProvider.notifier)
          .updateRemoteConfig(
            widget.existingModel!.id,
            config,
            displayName: name,
            isMultimodal: _supportsMultimodal,
          );
    } else {
      await ref
          .read(modelProvider.notifier)
          .addRemoteModel(
            displayName: name,
            config: config,
            isMultimodal: _supportsMultimodal,
          );
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  String _protocolIcon(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return '🤖';
      case RemoteProtocol.anthropic:
        return '🌟';
      case RemoteProtocol.ollama:
        return '🦙';
    }
  }

  String _protocolLabel(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return 'OpenAI';
      case RemoteProtocol.anthropic:
        return 'Anthropic';
      case RemoteProtocol.ollama:
        return 'Ollama';
    }
  }

  String _protocolDesc(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return '兼容 OpenAI v1 标准 API';
      case RemoteProtocol.anthropic:
        return '原生 Anthropic Messages API';
      case RemoteProtocol.ollama:
        return '本地 Ollama 服务（默认 API Key: ollama）';
    }
  }

  Color _protocolColor(RemoteProtocol p) {
    switch (p) {
      case RemoteProtocol.openai:
        return const Color(0xFF10A37F);
      case RemoteProtocol.anthropic:
        return const Color(0xFFD4741A);
      case RemoteProtocol.ollama:
        return const Color(0xFF7C3AED);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  通用小工具
// ════════════════════════════════════════════════════════════════════════════

/// 模型标签组件
class _ModelTag extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;

  const _ModelTag({this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 模型卡片操作按钮
class _ModelCardActions extends ConsumerWidget {
  final ModelEntry model;

  const _ModelCardActions({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      itemBuilder: (_) => [
        if (model.isLoaded)
          const PopupMenuItem(
            value: 'unload',
            child: ListTile(
              leading: Icon(Icons.eject_outlined),
              title: Text('卸载'),
              dense: true,
            ),
          ),
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
      onSelected: (action) => _handleAction(context, ref, action),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    switch (action) {
      case 'unload':
        ref.read(modelProvider.notifier).setModelLoaded(model.id, false);
        break;
      case 'edit':
        await _showEditLocalModelDialog(context, ref);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('删除模型'),
            content: Text(
              '确认删除「${model.displayName}」？\n\n'
              '注意：所有基于该模型的会话及聊天记录将被删除，此操作不可恢复！',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('确认删除'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          // 模型列表中删除：删除关联会话 + 模型记录（不删除模型文件）
          final deletedCount = await ref.read(modelProvider.notifier).deleteModelSessionsOnly(model.id);
          // 从模型列表中移除
          await ref.read(modelProvider.notifier).removeModelFromList(model.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已删除模型及 $deletedCount 个关联会话'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        break;
    }
  }

  Future<void> _showEditLocalModelDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final supportsMultimodal = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          _EditLocalModelDialog(initialValue: model.supportsMultimodal),
    );

    if (supportsMultimodal != null) {
      await ref
          .read(modelProvider.notifier)
          .updateLocalModelMultimodal(model.id, supportsMultimodal);
    }
  }
}

// 编辑本地模型多模态设置对话框

class _EditLocalModelDialog extends StatefulWidget {
  final bool initialValue;

  const _EditLocalModelDialog({required this.initialValue});

  @override
  State<_EditLocalModelDialog> createState() => _EditLocalModelDialogState();
}

class _EditLocalModelDialogState extends State<_EditLocalModelDialog> {
  late bool _supportsMultimodal;

  @override
  void initState() {
    super.initState();
    _supportsMultimodal = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(width: 8),
          Text('编辑本地模型'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 多模态开关
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '支持多模态',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _supportsMultimodal,
                      onChanged: (v) => setState(() => _supportsMultimodal = v),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _supportsMultimodal ? '✅ 已启用：可发送图片给模型进行分析' : '❌ 已禁用：仅支持纯文本对话',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _supportsMultimodal
                        ? Colors.green
                        : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 提示：本地模型需要是 VL/Vision 版本（如 llava、Qwen2-VL、llama3.2-vision 等）才能支持图片输入。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _supportsMultimodal),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  mmproj 投影仪列表区域
// ════════════════════════════════════════════════════════════════════════════

class _MmprojSection extends ConsumerWidget {
  final List<ModelEntry> models;
  const _MmprojSection({required this.models});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分隔标题
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.view_in_ar_rounded,
                size: 18,
                color: Colors.purple.shade600,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '多模态投影仪 (mmproj)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    Text(
                      'mmproj 是多模态 image-to-text 的必要组件，不可单独加载',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.purple.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${models.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // mmproj 列表
        ...models.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MmprojCard(model: m),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  mmproj 投影仪卡片
// ════════════════════════════════════════════════════════════════════════════

class _MmprojCard extends ConsumerWidget {
  final ModelEntry model;
  const _MmprojCard({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.purple.shade50,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.view_in_ar_rounded,
                color: Colors.purple.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // 名称和说明
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '不可直接加载，需配合多模态模型使用',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.purple.shade600,
                    ),
                  ),
                  if (model.filePath != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      model.filePath!.split('/').last,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 删除按钮
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: '删除',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除 mmproj'),
        content: Text(
          '确认删除「${model.displayName}」？\n\n此文件是多模态投影仪，删除后将无法支持图片/视频理解功能。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
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
  }
}
