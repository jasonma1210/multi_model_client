// ignore_for_file: use_build_context_synchronously
/// 名灵回响 - 名灵画廊页面
///
/// 展示已创建的名灵角色列表
/// - 手机端：网格卡片布局
/// - Pad/桌面端：左侧人物列表侧边栏 + 右侧信息/对话
/// 支持创建新名灵、删除、进入对话、二次蒸馏
///
/// @author JianMa
/// @version 2.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart' show ResponsiveLayout;
import '../../../../core/providers/model_provider.dart';
import '../../data/spirit_repository.dart';
import '../../domain/spirit_persona.dart';
import '../../domain/spirit_skill.dart';
import '../../domain/spirit_distillation_service.dart';
import '../../../skill/domain/skill_dispatcher.dart';

class SpiritGalleryPage extends ConsumerStatefulWidget {
  const SpiritGalleryPage({super.key});

  @override
  ConsumerState<SpiritGalleryPage> createState() => _SpiritGalleryPageState();
}

class _SpiritGalleryPageState extends ConsumerState<SpiritGalleryPage> {
  /// Pad 端选中的名灵 ID
  String? _selectedPersonaId;

  /// 二次蒸馏进度
  bool _isRedistilling = false;
  String? _redistillMessage;
  double? _redistillProgress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(allSpiritPersonasProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveLayout.isTablet(context) || ResponsiveLayout.isDesktop(context);
    final personasAsync = ref.watch(allSpiritPersonasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('名灵回响'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '创建名灵',
            onPressed: () async {
              final result = await context.push('/spirit/create');
              if (result != null) {
                ref.invalidate(allSpiritPersonasProvider);
              }
            },
          ),
        ],
      ),
      body: personasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (personas) {
          if (personas.isEmpty) {
            return _buildEmptyState(theme);
          }
          // ★ Pad/桌面端：侧边栏布局
          if (isTablet) {
            return _buildTabletLayout(theme, personas);
          }
          // ★ 手机端：网格卡片布局
          return _buildMobileLayout(theme, personas);
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  手机端布局
  // ════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👻', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('还没有名灵', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 创建你的第一个名灵角色',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final result = await context.push('/spirit/create');
              if (result != null) {
                ref.invalidate(allSpiritPersonasProvider);
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('创建名灵'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, List<SpiritPersona> personas) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allSpiritPersonasProvider);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: personas.length,
        itemBuilder: (context, index) {
          return _buildPersonaCard(theme, personas[index]);
        },
      ),
    );
  }

  Widget _buildPersonaCard(ThemeData theme, SpiritPersona persona) {
    final statusColor = persona.isReady
        ? Colors.green
        : persona.isProcessing
            ? Colors.orange
            : Colors.red;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onLongPress: () => _confirmAndDelete(persona),
        child: Stack(
        children: [
          // 右上角 i 图标按钮
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onSurfaceVariant),
              tooltip: '查看详情',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () => _viewDetail(persona),
            ),
          ),

          // 主体内容
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(persona.avatarEmoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  persona.nickname,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    persona.domain,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (persona.description != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        persona.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (persona.isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: statusColor),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            persona.statusText,
                            style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontSize: 10),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (persona.isFailed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      persona.statusText,
                      style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontSize: 10),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                Center(
                  child: persona.isReady
                      ? FilledButton.tonalIcon(
                          onPressed: () => _enterChat(persona),
                          icon: Icon(
                            persona.clonedVoiceId != null
                                ? Icons.record_voice_over_rounded
                                : Icons.chat_rounded,
                            size: 16,
                          ),
                          label: Text(
                            persona.clonedVoiceId != null ? '语音对话' : '对话',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: persona.isFailed ? () => _showOptions(persona) : null,
                          icon: const Icon(Icons.error_outline, size: 16),
                          label: Text(
                            persona.isFailed ? '查看错误' : persona.statusText,
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  Pad/桌面端布局：左侧侧边栏 + 右侧内容
  // ════════════════════════════════════════════════════════════════

  Widget _buildTabletLayout(ThemeData theme, List<SpiritPersona> personas) {
    final selectedPersona = _selectedPersonaId != null
        ? personas.where((p) => p.id == _selectedPersonaId).firstOrNull
        : null;

    return Row(
      children: [
        // ★ 左侧侧边栏：人物列表
        SizedBox(
          width: 280,
          child: _buildSidebar(theme, personas),
        ),
        const VerticalDivider(width: 1),

        // ★ 右侧内容区：信息展示 / 对话
        Expanded(
          child: selectedPersona != null
              ? _buildDetailPanel(theme, selectedPersona)
              : _buildPlaceholder(theme),
        ),
      ],
    );
  }

  /// 左侧侧边栏
  Widget _buildSidebar(ThemeData theme, List<SpiritPersona> personas) {
    return Column(
      children: [
        // ★ 侧边栏头部：标题
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Text('名灵列表', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(height: 1),

        // 人物列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: personas.length,
            itemBuilder: (context, index) {
              final persona = personas[index];
              final isSelected = persona.id == _selectedPersonaId;
              return _buildSidebarItem(theme, persona, isSelected);
            },
          ),
        ),
      ],
    );
  }

  /// 侧边栏单个名灵项
  Widget _buildSidebarItem(ThemeData theme, SpiritPersona persona, bool isSelected) {
    final statusColor = persona.isReady
        ? Colors.green
        : persona.isProcessing
            ? Colors.orange
            : Colors.red;

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
      leading: Text(persona.avatarEmoji, style: const TextStyle(fontSize: 24)),
      title: Text(
        persona.nickname,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              persona.domain,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: persona.isReady
          ? Icon(Icons.chevron_right_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant)
          : persona.isProcessing
              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5, color: statusColor))
              : Icon(Icons.error_outline, size: 16, color: statusColor),
      onTap: () {
        setState(() => _selectedPersonaId = persona.id);
      },
      onLongPress: () => _confirmAndDelete(persona),
    );
  }

  /// 右侧详情面板
  Widget _buildDetailPanel(ThemeData theme, SpiritPersona persona) {
    final statusColor = persona.isReady
        ? Colors.green
        : persona.isProcessing
            ? Colors.orange
            : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ★ 标题：xx详情
          Text(
            '${persona.nickname}详情',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 头部：emoji + 领域 + 状态
          Row(
            children: [
              Text(persona.avatarEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  persona.domain,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              // 状态
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      persona.statusText,
                      style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 描述
          if (persona.description != null) ...[
            const SizedBox(height: 20),
            Text('描述', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                persona.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
          ],

          // 蒸馏 Prompt 预览
          if (persona.distilledPrompt != null) ...[
            const SizedBox(height: 20),
            Text('蒸馏 Prompt', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                persona.distilledPrompt!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // 搜索来源
          if (persona.searchSources.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('蒸馏来源', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: persona.searchSources.map((src) => Chip(
                label: Text(src, style: theme.textTheme.labelSmall),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],

          // 音色信息
          const SizedBox(height: 20),
          Text('音色', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                persona.clonedVoiceId != null ? Icons.record_voice_over : Icons.chat,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                persona.clonedVoiceId != null ? '已克隆专属音色' : '默认音色',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),

          // 操作按钮
          const SizedBox(height: 32),
          Row(
            children: [
              if (persona.isReady) ...[
                FilledButton.icon(
                  onPressed: () => _enterChat(persona),
                  icon: Icon(
                    persona.clonedVoiceId != null ? Icons.record_voice_over_rounded : Icons.chat_rounded,
                  ),
                  label: Text(persona.clonedVoiceId != null ? '语音对话' : '对话'),
                ),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: () => _viewDetail(persona),
                icon: const Icon(Icons.info_outline),
                label: const Text('查看详情'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _isRedistilling ? null : () => _redistill(persona),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('二次蒸馏'),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await _confirmDelete(persona);
                  if (confirmed) {
                    final repo = ref.read(spiritRepositoryProvider);
                    await repo.deletePersona(persona.id);
                    final dispatcher = SkillDispatcher();
                    final skillManager = SpiritSkillManager();
                    skillManager.unregisterSpiritSkill(persona.id, dispatcher);
                    setState(() => _selectedPersonaId = null);
                    ref.invalidate(allSpiritPersonasProvider);
                  }
                },
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                label: Text('删除', style: TextStyle(color: theme.colorScheme.error)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),

          // ★ 二次蒸馏进度条
          if (_isRedistilling) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _redistillMessage ?? '正在处理...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (_redistillProgress != null) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: _redistillProgress),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 右侧占位面板
  Widget _buildPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👻', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            '选择一个名灵查看详情',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  操作方法
  // ════════════════════════════════════════════════════════════════

  /// 查看名灵详情
  void _viewDetail(SpiritPersona persona) {
    context.push('/spirit/detail/${persona.id}');
  }

  /// 进入对话（直接跳转到对话模式选择界面，不再弹窗）
  void _enterChat(SpiritPersona persona) {
    final dispatcher = SkillDispatcher();
    final skillManager = SpiritSkillManager();
    skillManager.registerSpiritSkill(persona, dispatcher);

    // 直接跳转到对话模式选择界面（模型选择 + 音色选择 + 语音/文字模式）
    context.push('/spirit/chat/${persona.id}');
  }

  /// ★ 二次蒸馏（弹出模型选择对话框 + 进度条）
  Future<void> _redistill(SpiritPersona persona) async {
    // 获取所有可用模型
    final modelState = ref.read(modelProvider);
    final allModels = [...modelState.localModels, ...modelState.remoteModels];
    debugPrint('[SpiritGallery] 二次蒸馏点击: ${persona.nickname}, 可用模型数: ${allModels.length}');
    if (allModels.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可用的模型，请先配置模型')),
        );
      }
      return;
    }

    // 默认选中上次蒸馏使用的模型
    String selectedModelId = persona.lastUsedModelId ?? allModels.first.id;
    // 确保默认值在列表中
    if (!allModels.any((m) => m.id == selectedModelId)) {
      selectedModelId = allModels.first.id;
    }

    // 弹出模型选择对话框
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('二次蒸馏 · ${persona.nickname}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择用于蒸馏的模型，将重新搜索该人物信息并生成新的蒸馏 Prompt。',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedModelId,
                    isExpanded: true,
                    underline: Container(
                      height: 1,
                      color: Theme.of(ctx).colorScheme.outline,
                    ),
                    items: allModels.map((m) {
                      final isLocal = m.isLocal;
                      return DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            Icon(
                              isLocal ? Icons.computer : Icons.cloud,
                              size: 16,
                              color: isLocal ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                m.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedModelId = v);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, {'modelId': selectedModelId}),
                  child: const Text('开始蒸馏'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    final modelId = result['modelId'] as String;

    // 开始蒸馏，显示进度
    setState(() {
      _isRedistilling = true;
      _redistillMessage = '正在初始化...';
      _redistillProgress = null;
    });

    try {
      final distillService = SpiritDistillationService();
      final repo = ref.read(spiritRepositoryProvider);

      // 订阅蒸馏进度
      final progressSub = distillService.progressStream
          .where((p) => p.spiritId == persona.id)
          .listen((progress) {
        if (!mounted) return;
        setState(() {
          _redistillMessage = progress.message ?? '处理中...';
          _redistillProgress = progress.progress;
        });
      });

      // 执行二次蒸馏
      await distillService.redistillPersona(
        persona,
        modelId: modelId,
        onUpdate: (updated) => repo.updatePersona(updated),
      );

      progressSub.cancel();

      setState(() {
        _isRedistilling = false;
        _redistillMessage = null;
        _redistillProgress = null;
      });

      ref.invalidate(allSpiritPersonasProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${persona.nickname} 二次蒸馏完成')),
        );
      }
    } catch (e) {
      setState(() {
        _isRedistilling = false;
        _redistillMessage = null;
        _redistillProgress = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('二次蒸馏失败: $e')),
        );
      }
    }
  }

  /// 显示选项菜单
  void _showOptions(SpiritPersona persona) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('昵称: ${persona.nickname}'),
              subtitle: Text('领域: ${persona.domain} | 状态: ${persona.statusText}'),
            ),
            if (persona.isReady) ...[
              ListTile(
                leading: const Icon(Icons.record_voice_over_rounded),
                title: const Text('语音对话'),
                subtitle: const Text('按住说话 · 实时打断'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/spirit/chat/${persona.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('对话'),
                onTap: () {
                  Navigator.pop(context);
                  _enterChat(persona);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: const Text('二次蒸馏'),
              subtitle: const Text('重新搜索并蒸馏该人物'),
              onTap: () {
                Navigator.pop(context);
                _redistill(persona);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除名灵', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _confirmDelete(persona);
                if (confirmed) {
                  final repo = ref.read(spiritRepositoryProvider);
                  await repo.deletePersona(persona.id);
                  final dispatcher = SkillDispatcher();
                  final skillManager = SpiritSkillManager();
                  skillManager.unregisterSpiritSkill(persona.id, dispatcher);
                  ref.invalidate(allSpiritPersonasProvider);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ★ 长按删除：弹出确认对话框，确认后执行删除
  Future<void> _confirmAndDelete(SpiritPersona persona) async {
    final confirmed = await _confirmDelete(persona);
    if (!confirmed || !mounted) return;

    final repo = ref.read(spiritRepositoryProvider);
    await repo.deletePersona(persona.id);
    // 注销技能
    final dispatcher = SkillDispatcher();
    final skillManager = SpiritSkillManager();
    skillManager.unregisterSpiritSkill(persona.id, dispatcher);
    // 清除选中状态
    if (_selectedPersonaId == persona.id) {
      setState(() => _selectedPersonaId = null);
    }
    ref.invalidate(allSpiritPersonasProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除"${persona.nickname}"')),
      );
    }
  }

  /// 确认删除
  Future<bool> _confirmDelete(SpiritPersona persona) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除名灵"${persona.nickname}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
