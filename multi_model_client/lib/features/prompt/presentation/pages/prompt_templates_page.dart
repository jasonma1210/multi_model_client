import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/database.dart';
import '../../data/prompt_providers.dart';
import '../../domain/prompt_engine.dart';

class PromptTemplatesPage extends ConsumerStatefulWidget {
  const PromptTemplatesPage({super.key});

  @override
  ConsumerState<PromptTemplatesPage> createState() =>
      _PromptTemplatesPageState();
}

class _PromptTemplatesPageState extends ConsumerState<PromptTemplatesPage> {
  @override
  void initState() {
    super.initState();
    // Initialize builtin templates on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(promptTemplateNotifierProvider.notifier)
          .initializeBuiltinTemplates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(filteredPromptTemplatesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        title: const Text('提示词模板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditor(context),
            tooltip: '创建模板',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryChips(selectedCategory),
          // Templates list
          Expanded(
            child: templatesAsync.when(
              data: (templates) {
                if (templates.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildTemplatesList(templates, theme);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('加载失败: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditor(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChips(String? selectedCategory) {
    final categories = ['all', ...PromptCategory.all];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spacingS),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == (selectedCategory ?? 'all');
          final displayName = category == 'all'
              ? '全部'
              : PromptCategory.getDisplayName(category);

          return FilterChip(
            label: Text(displayName),
            selected: isSelected,
            onSelected: (selected) {
              ref.read(selectedCategoryProvider.notifier).state =
                  category == 'all' ? null : category;
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            '暂无模板',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            '点击下方按钮创建第一个提示词模板',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList(
      List<PromptTemplate> templates, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _PromptTemplateCard(
          template: template,
          onTap: () => _navigateToEditor(context, template: template),
          onDelete: () => _confirmDelete(context, template),
        );
      },
    );
  }

  void _navigateToEditor(BuildContext context, {PromptTemplate? template}) {
    context.push('/settings/prompts/editor', extra: template);
  }

  Future<void> _confirmDelete(BuildContext context, PromptTemplate template) async {
    if (template.isBuiltin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('内置模板无法删除')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模板 "${template.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(promptTemplateNotifierProvider.notifier)
          .deleteTemplate(template.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('模板已删除')),
        );
      }
    }
  }
}

class _PromptTemplateCard extends ConsumerWidget {
  final PromptTemplate template;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PromptTemplateCard({
    required this.template,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final promptEngine = ref.read(promptEngineProvider);
    final variables = template.variables != null
        ? (jsonDecode(template.variables!) as List).cast<String>()
        : <String>[];
    final preview = promptEngine.previewTemplate(template.content);

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (template.isBuiltin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: AppTheme.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        '内置',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  if (template.isGlobal)
                    Padding(
                      padding: const EdgeInsets.only(left: AppTheme.spacingS),
                      child: Icon(
                        Icons.public,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      if (!template.isBuiltin)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20),
                              SizedBox(width: 8),
                              Text('删除'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    PromptCategory.getDisplayName(template.category),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (variables.isNotEmpty) ...[
                    const SizedBox(width: AppTheme.spacingM),
                    Icon(
                      Icons.code,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${variables.length} 个变量',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  preview,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
