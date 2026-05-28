import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/database.dart';
import '../../../../core/services/knowledge_base_service.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../generated/app_localizations.dart';

/// 知识库服务 Provider
final knowledgeBaseServiceProvider = Provider<KnowledgeBaseService>((ref) {
  final db = ref.watch(databaseProvider);
  return KnowledgeBaseService(db);
});

/// 知识库列表 Provider
final knowledgeBaseListProvider = FutureProvider<List<KnowledgeBase>>((
  ref,
) async {
  final service = ref.watch(knowledgeBaseServiceProvider);
  return await service.getAllKnowledgeBases();
});

class KnowledgeBaseItem {
  final String id;
  final String name;
  final String description;
  final int documentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeBaseItem({
    required this.id,
    required this.name,
    required this.description,
    required this.documentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeBaseItem.fromDb(KnowledgeBase kb) {
    return KnowledgeBaseItem(
      id: kb.id,
      name: kb.name,
      description: kb.description ?? '',
      documentCount: kb.documentCount,
      createdAt: kb.createdAt,
      updatedAt: kb.updatedAt,
    );
  }
}

class KnowledgeBaseManagementPage extends ConsumerWidget {
  const KnowledgeBaseManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final knowledgeBasesAsync = ref.watch(knowledgeBaseListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings'),
          ),
          title: Text(l10n.knowledgeBase),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateKnowledgeBaseDialog(context, ref),
              tooltip: '创建知识库',
            ),
          ],
        ),
        body: knowledgeBasesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('加载失败: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(knowledgeBaseListProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
          data: (knowledgeBases) {
            if (knowledgeBases.isEmpty) {
              return _buildEmptyState(context, ref);
            }
            return _buildKnowledgeBaseList(context, ref, knowledgeBases);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.library_books_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有知识库',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '创建知识库来存储和管理文档\n让 AI 能够基于你的资料进行问答',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showCreateKnowledgeBaseDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('创建知识库'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKnowledgeBaseList(
    BuildContext context,
    WidgetRef ref,
    List<KnowledgeBase> knowledgeBases,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: knowledgeBases.length,
      itemBuilder: (context, index) {
        final kb = knowledgeBases[index];
        final item = KnowledgeBaseItem.fromDb(kb);
        return _KnowledgeBaseCard(
          knowledgeBase: item,
          onTap: () => context.go('/settings/knowledge/${kb.id}'),
          onDelete: () => _showDeleteDialog(context, ref, kb),
          onEdit: () => _showEditDialog(context, ref, kb),
        );
      },
    );
  }

  void _showCreateKnowledgeBaseDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('创建知识库'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '知识库名称',
                hintText: '输入知识库名称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: '描述（可选）',
                hintText: '简单描述这个知识库',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  final service = ref.read(knowledgeBaseServiceProvider);
                  await service.createKnowledgeBase(
                    name: name,
                    description: descController.text.trim(),
                  );
                  ref.invalidate(knowledgeBaseListProvider);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('已创建知识库: $name')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
                  }
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, KnowledgeBase kb) {
    final nameController = TextEditingController(text: kb.name);
    final descController = TextEditingController(text: kb.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑知识库'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '知识库名称',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: '描述',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final service = ref.read(knowledgeBaseServiceProvider);
                await service.updateKnowledgeBase(
                  id: kb.id,
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                );
                ref.invalidate(knowledgeBaseListProvider);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('已更新')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    KnowledgeBase kb,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除知识库 "${kb.name}" 吗？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(knowledgeBaseServiceProvider);
      await service.deleteKnowledgeBase(kb.id);
      ref.invalidate(knowledgeBaseListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已删除知识库: ${kb.name}')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }
}

class _KnowledgeBaseCard extends StatelessWidget {
  final KnowledgeBaseItem knowledgeBase;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _KnowledgeBaseCard({
    required this.knowledgeBase,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.library_books,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      knowledgeBase.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (knowledgeBase.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        knowledgeBase.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${knowledgeBase.documentCount} 个文档',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(knowledgeBase.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('编辑'),
                      dense: true,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('删除', style: TextStyle(color: Colors.red)),
                      dense: true,
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays < 1) return '今天';
    if (diff.inDays < 7) return '${diff.inDays} 天前';
    return '${dt.month}月${dt.day}日';
  }
}
