import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/settings_provider.dart';

/// 存储位置配置页面
class StoragePathsPage extends ConsumerStatefulWidget {
  const StoragePathsPage({super.key});

  @override
  ConsumerState<StoragePathsPage> createState() => _StoragePathsPageState();
}

class _StoragePathsPageState extends ConsumerState<StoragePathsPage> {
  Map<String, String> _currentPaths = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final settingsService = ref.read(settingsServiceProvider);
    final paths = await settingsService.getAllStoragePaths();
    if (mounted) {
      setState(() {
        _currentPaths = paths;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('存储位置配置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              children: [
                // 说明
                Card(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            '自定义各类型文件的存储位置。留空则使用默认路径。',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                // 模型下载目录
                _StoragePathTile(
                  icon: Icons.download,
                  title: '模型下载目录',
                  subtitle: '本地模型文件存储位置',
                  currentPath: _currentPaths['models'] ?? '',
                  customPath: ref.watch(downloadPathProvider),
                  onSetPath: () => _selectPath(
                    '选择模型下载目录',
                    ref.read(downloadPathProvider.notifier),
                  ),
                  onResetPath: () => _resetPath(
                    ref.read(downloadPathProvider.notifier),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingS),

                // 知识库目录
                _StoragePathTile(
                  icon: Icons.folder_outlined,
                  title: '知识库目录',
                  subtitle: '上传的文档和向量数据存储位置',
                  currentPath: _currentPaths['knowledge_base'] ?? '',
                  customPath: ref.watch(knowledgeBasePathProvider),
                  onSetPath: () => _selectPath(
                    '选择知识库目录',
                    ref.read(knowledgeBasePathProvider.notifier),
                  ),
                  onResetPath: () => _resetPath(
                    ref.read(knowledgeBasePathProvider.notifier),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingS),

                // 备份目录
                _StoragePathTile(
                  icon: Icons.backup_outlined,
                  title: '备份目录',
                  subtitle: '数据备份文件存储位置',
                  currentPath: _currentPaths['backups'] ?? '',
                  customPath: ref.watch(backupPathProvider),
                  onSetPath: () => _selectPath(
                    '选择备份目录',
                    ref.read(backupPathProvider.notifier),
                  ),
                  onResetPath: () => _resetPath(
                    ref.read(backupPathProvider.notifier),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingS),

                // 日志目录
                _StoragePathTile(
                  icon: Icons.description_outlined,
                  title: '日志目录',
                  subtitle: '应用日志文件存储位置',
                  currentPath: _currentPaths['logs'] ?? '',
                  customPath: ref.watch(logPathProvider),
                  onSetPath: () => _selectPath(
                    '选择日志目录',
                    ref.read(logPathProvider.notifier),
                  ),
                  onResetPath: () => _resetPath(
                    ref.read(logPathProvider.notifier),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // 数据库目录（只读显示）
                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingS),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Icon(
                        Icons.storage,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: const Text('数据库目录'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '应用数据库文件存储位置（不可修改）',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentPaths['database'] ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.lock_outline, size: 18),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXXL),

                // 操作按钮
                FilledButton.icon(
                  onPressed: _loadPaths,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新路径'),
                ),
              ],
            ),
    );
  }

  Future<void> _selectPath(
    String title,
    dynamic notifier,
  ) async {
    final selectedDirectory = await FilePicker.getDirectoryPath(
      dialogTitle: title,
    );

    if (selectedDirectory != null) {
      await notifier.setPath(selectedDirectory);
      await _loadPaths();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('目录已更新: $selectedDirectory'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resetPath(dynamic notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复默认'),
        content: const Text('确定要恢复默认路径吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.setPath(null);
      await _loadPaths();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已恢复默认路径'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _StoragePathTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String currentPath;
  final String? customPath;
  final VoidCallback onSetPath;
  final VoidCallback onResetPath;

  const _StoragePathTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.currentPath,
    this.customPath,
    required this.onSetPath,
    required this.onResetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCustomPath = customPath != null && customPath!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: theme.textTheme.titleSmall),
                          if (hasCustomPath) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '自定义',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Text(
                currentPath,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasCustomPath)
                  TextButton(
                    onPressed: onResetPath,
                    child: const Text('恢复默认'),
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onSetPath,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('选择目录'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
