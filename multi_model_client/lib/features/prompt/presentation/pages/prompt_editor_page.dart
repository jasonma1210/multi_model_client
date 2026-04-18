import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/database.dart';
import '../../data/prompt_providers.dart';
import '../../domain/prompt_engine.dart';

class PromptEditorPage extends ConsumerStatefulWidget {
  final PromptTemplate? template;

  const PromptEditorPage({super.key, this.template});

  @override
  ConsumerState<PromptEditorPage> createState() => _PromptEditorPageState();
}

class _PromptEditorPageState extends ConsumerState<PromptEditorPage> {
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  String _selectedCategory = PromptCategory.general;
  bool _isGlobal = false;
  final List<TextEditingController> _variableControllers = [];
  final PromptEngine _promptEngine = PromptEngine();

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _contentController = TextEditingController(text: widget.template?.content ?? '');
    _selectedCategory = widget.template?.category ?? PromptCategory.general;
    _isGlobal = widget.template?.isGlobal ?? false;

    // Parse existing variables
    if (widget.template?.variables != null) {
      final variables = jsonDecode(widget.template!.variables!) as List;
      for (var v in variables) {
        _variableControllers.add(TextEditingController(text: v as String));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    for (var c in _variableControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? '编辑模板' : '创建模板'),
        actions: [
          TextButton(
            onPressed: _saveTemplate,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '模板名称',
                hintText: '输入模板名称',
                border: OutlineInputBorder(),
              ),
              enabled: widget.template?.isBuiltin != true,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Category selector
            Text('分类', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTheme.spacingS),
            Wrap(
              spacing: AppTheme.spacingS,
              runSpacing: AppTheme.spacingS,
              children: PromptCategory.all.map((category) {
                return ChoiceChip(
                  label: Text(PromptCategory.getDisplayName(category)),
                  selected: _selectedCategory == category,
                  onSelected: widget.template?.isBuiltin != true
                      ? (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                          }
                        }
                      : null,
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Global toggle
            SwitchListTile(
              title: const Text('全局模板'),
              subtitle: const Text('可跨会话使用'),
              value: _isGlobal,
              onChanged: widget.template?.isBuiltin ?? true
                  ? (value) => setState(() => _isGlobal = value)
                  : null,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Variables section
            _buildVariablesSection(theme),
            const SizedBox(height: AppTheme.spacingL),

            // Content editor
            Text('模板内容', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTheme.spacingS),
            _buildContentEditor(theme),
            const SizedBox(height: AppTheme.spacingL),

            // Preview section
            _buildPreviewSection(theme),
            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildVariablesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('变量', style: theme.textTheme.titleSmall),
            TextButton.icon(
              onPressed: _addVariable,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加变量'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        if (_variableControllers.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    '在模板内容中使用 {{变量名}} 格式，系统会自动识别变量',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: AppTheme.spacingS,
            runSpacing: AppTheme.spacingS,
            children: List.generate(_variableControllers.length, (index) {
              return _VariableChip(
                controller: _variableControllers[index],
                onDelete: () => _removeVariable(index),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildContentEditor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: const InputDecoration(
              hintText: '输入模板内容...\n\n使用 {{变量名}} 格式定义变量，例如：\n请翻译成 {{target_language}}\n{{content}}',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppTheme.spacingM),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          '提示：使用 {{变量名}} 格式定义变量',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(ThemeData theme) {
    final content = _contentController.text;
    final variables = _extractVariablesFromContent(content);
    final preview = _promptEngine.previewTemplate(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('预览', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.preview,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '变量: ${variables.isEmpty ? "无" : variables.join(", ")}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: AppTheme.spacingM),
              Text(
                preview.isEmpty ? '输入模板内容后查看预览...' : preview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: preview.isEmpty ? theme.colorScheme.outline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Set<String> _extractVariablesFromContent(String content) {
    return _promptEngine.extractVariables(content);
  }

  void _addVariable() {
    setState(() {
      _variableControllers.add(TextEditingController());
    });
  }

  void _removeVariable(int index) {
    setState(() {
      _variableControllers[index].dispose();
      _variableControllers.removeAt(index);
    });
  }

  Future<void> _saveTemplate() async {
    final name = _nameController.text.trim();
    final content = _contentController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入模板名称')),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入模板内容')),
      );
      return;
    }

    final variables = _variableControllers
        .map((c) => c.text.trim())
        .where((v) => v.isNotEmpty)
        .toList();

    final notifier = ref.read(promptTemplateNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateTemplate(
        id: widget.template!.id,
        name: name,
        content: content,
        variables: variables,
        category: _selectedCategory,
        isGlobal: _isGlobal,
      );
    } else {
      final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
      await notifier.createTemplate(
        id: id,
        name: name,
        content: content,
        variables: variables,
        category: _selectedCategory,
        isGlobal: _isGlobal,
        isBuiltin: false,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? '模板已更新' : '模板已创建')),
      );
      context.pop();
    }
  }
}

class _VariableChip extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDelete;

  const _VariableChip({
    required this.controller,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: SizedBox(
        width: 100,
        child: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            hintText: '变量名',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDelete,
    );
  }
}
