/// 项目选择器组件（v0.42.0）
///
/// 用于在会话创建/编辑时选择归属项目。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/project_provider.dart';

/// 项目选择器（紧凑型）
class ProjectSelectorChip extends ConsumerWidget {
  final String? selectedProjectId;
  final ValueChanged<String?> onChanged;

  const ProjectSelectorChip({
    required this.selectedProjectId,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = selectedProjectId == null
        ? null
        : ref.watch(projectByIdProvider(selectedProjectId!));

    return ActionChip(
      avatar: project == null
          ? const Icon(Icons.folder_off, size: 18)
          : Text(project.icon, style: const TextStyle(fontSize: 16)),
      label: Text(project?.name ?? '选择项目'),
      onPressed: () => _showPicker(context, ref),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final projects = ref.watch(projectsProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '选择项目',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.folder_off),
                title: const Text('无项目'),
                selected: selectedProjectId == null,
                onTap: () {
                  onChanged(null);
                  Navigator.of(ctx).pop();
                },
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: projects.length,
                  itemBuilder: (_, i) {
                    final p = projects[i];
                    return ListTile(
                      leading: Text(p.icon, style: const TextStyle(fontSize: 20)),
                      title: Text(p.name),
                      subtitle: p.description == null ? null : Text(p.description!),
                      selected: selectedProjectId == p.id,
                      onTap: () {
                        onChanged(p.id);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

/// 项目选择器（全屏对话框）
class ProjectPickerDialog extends ConsumerStatefulWidget {
  final String? initialProjectId;

  const ProjectPickerDialog({this.initialProjectId, super.key});

  @override
  ConsumerState<ProjectPickerDialog> createState() => _ProjectPickerDialogState();
}

class _ProjectPickerDialogState extends ConsumerState<ProjectPickerDialog> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialProjectId;
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);

    return AlertDialog(
      title: const Text('选择项目'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              value: null,
              groupValue: _selectedId,
              title: const Text('不关联项目'),
              onChanged: (v) => setState(() => _selectedId = v),
            ),
            const Divider(),
            ...projects.map((p) {
              return RadioListTile<String?>(
                value: p.id,
                groupValue: _selectedId,
                title: Row(
                  children: [
                    Text(p.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p.name)),
                  ],
                ),
                subtitle: p.description == null ? null : Text(p.description!),
                onChanged: (v) => setState(() => _selectedId = v),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedId),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

/// 显示项目选择对话框并返回选中的项目 ID
Future<String?> showProjectPicker(BuildContext context, {String? initial}) {
  return showDialog<String?>(
    context: context,
    builder: (_) => ProjectPickerDialog(initialProjectId: initial),
  );
}
