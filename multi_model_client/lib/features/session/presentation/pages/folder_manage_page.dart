import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/database.dart';
import '../../domain/folder_service.dart';

/// 文件夹管理页面
class FolderManagePage extends ConsumerStatefulWidget {
  const FolderManagePage({super.key});

  @override
  ConsumerState<FolderManagePage> createState() => _FolderManagePageState();
}

class _FolderManagePageState extends ConsumerState<FolderManagePage> {
  final FolderService _folderService = FolderService();
  List<Folder> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    try {
      final folders = await _folderService.getAllFolders();
      setState(() {
        _folders = folders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e'), backgroundColor: Colors.red, duration: const Duration(milliseconds: 1500)),
        );
      }
    }
  }

  Future<void> _createFolder() async {
    final result = await showDialog<_FolderData>(
      context: context,
      builder: (ctx) => const _FolderEditDialog(),
    );

    if (result != null) {
      try {
        await _folderService.createFolder(
          name: result.name,
          color: result.color,
          icon: result.icon,
          sortOrder: _folders.length,
        );
        await _loadFolders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件夹创建成功'), duration: Duration(milliseconds: 1500)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('创建失败: $e'), backgroundColor: Colors.red, duration: const Duration(milliseconds: 1500)),
          );
        }
      }
    }
  }

  Future<void> _editFolder(Folder folder) async {
    final result = await showDialog<_FolderData>(
      context: context,
      builder: (ctx) => _FolderEditDialog(
        initialName: folder.name,
        initialColor: folder.color,
        initialIcon: folder.icon,
      ),
    );

    if (result != null) {
      try {
        await _folderService.updateFolder(
          id: folder.id,
          name: result.name,
          color: result.color,
          icon: result.icon,
        );
        await _loadFolders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件夹更新成功'), duration: Duration(milliseconds: 1500)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: $e'), backgroundColor: Colors.red, duration: const Duration(milliseconds: 1500)),
          );
        }
      }
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除文件夹'),
        content: Text('确定要删除 "${folder.name}" 吗？文件夹下的会话将移动到未分类。'),
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

    if (confirmed == true) {
      try {
        await _folderService.deleteFolder(folder.id);
        await _loadFolders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('文件夹已删除'), duration: Duration(milliseconds: 1500)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red, duration: const Duration(milliseconds: 1500)),
          );
        }
      }
    }
  }

  Future<void> _reorderFolders(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = _folders.removeAt(oldIndex);
    _folders.insert(newIndex, item);

    setState(() {});

    try {
      await _folderService.reorderFolders(_folders.map((f) => f.id).toList());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('排序失败: $e'), backgroundColor: Colors.red, duration: const Duration(milliseconds: 1500)),
        );
      }
      await _loadFolders();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder_open':
        return Icons.folder_open_outlined;
      case 'work':
        return Icons.work_outline;
      case 'school':
        return Icons.school_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      case 'star':
        return Icons.star_outline;
      case 'bookmark':
        return Icons.bookmark_outline;
      case 'label':
        return Icons.label_outline;
      case 'chat':
        return Icons.chat_outlined;
      case 'computer':
        return Icons.computer_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('文件夹管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createFolder,
            tooltip: '新建文件夹',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
              ? _buildEmptyState(theme)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _folders.length,
                  onReorder: _reorderFolders,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    return _FolderListItem(
                      key: ValueKey(folder.id),
                      folder: folder,
                      iconData: _getIconData(folder.icon),
                      color: _getColor(folder.color),
                      onEdit: () => _editFolder(folder),
                      onDelete: () => _deleteFolder(folder),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无文件夹',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 创建文件夹',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderListItem extends StatelessWidget {
  final Folder folder;
  final IconData iconData;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FolderListItem({
    required super.key,
    required this.folder,
    required this.iconData,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: color),
        ),
        title: Text(folder.name),
        subtitle: Text(
          '创建于 ${_formatDate(folder.createdAt)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: '编辑',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _FolderData {
  final String name;
  final String color;
  final String icon;

  _FolderData({required this.name, required this.color, required this.icon});
}

class _FolderEditDialog extends StatefulWidget {
  final String? initialName;
  final String? initialColor;
  final String? initialIcon;

  const _FolderEditDialog({
    this.initialName,
    this.initialColor,
    this.initialIcon,
  });

  @override
  State<_FolderEditDialog> createState() => _FolderEditDialogState();
}

class _FolderEditDialogState extends State<_FolderEditDialog> {
  late final TextEditingController _nameController;
  late String _selectedColor;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedColor = widget.initialColor ?? FolderColors.colors[0];
    _selectedIcon = widget.initialIcon ?? FolderColors.icons[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'folder_open':
        return Icons.folder_open_outlined;
      case 'work':
        return Icons.work_outline;
      case 'school':
        return Icons.school_outlined;
      case 'favorite':
        return Icons.favorite_outline;
      case 'star':
        return Icons.star_outline;
      case 'bookmark':
        return Icons.bookmark_outline;
      case 'label':
        return Icons.label_outline;
      case 'chat':
        return Icons.chat_outlined;
      case 'computer':
        return Icons.computer_outlined;
      default:
        return Icons.folder_outlined;
    }
  }

  Color _getColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑文件夹' : '新建文件夹'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '文件夹名称',
                hintText: '输入文件夹名称',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text('选择颜色', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FolderColors.colors.map((color) {
                final isSelected = _selectedColor == color;
                final colorValue = _getColor(color);
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorValue,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorValue.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('选择图标', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FolderColors.icons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getColor(_selectedColor).withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: _getColor(_selectedColor))
                          : null,
                    ),
                    child: Icon(
                      _getIconData(icon),
                      color: isSelected
                          ? _getColor(_selectedColor)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(
                context,
                _FolderData(
                  name: name,
                  color: _selectedColor,
                  icon: _selectedIcon,
                ),
              );
            }
          },
          child: Text(isEditing ? '保存' : '创建'),
        ),
      ],
    );
  }
}
