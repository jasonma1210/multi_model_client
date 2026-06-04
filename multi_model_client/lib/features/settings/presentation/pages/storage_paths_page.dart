import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/services/model_path_cache.dart';
import '../../../../core/services/security_bookmark_service.dart';

/// 存储位置配置页面
class StoragePathsPage extends ConsumerStatefulWidget {
  const StoragePathsPage({super.key});

  @override
  ConsumerState<StoragePathsPage> createState() => _StoragePathsPageState();
}

class _StoragePathsPageState extends ConsumerState<StoragePathsPage> {
  Map<String, String> _currentPaths = {};
  bool _isLoading = true;
  bool _isScanning = false;

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
          title: const Text('存储位置配置'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                children: [
                  // 说明
                  Card(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                    subtitle: '本地模型文件存储位置（选择后自动扫描子目录中的gguf文件）',
                    currentPath: _currentPaths['models'] ?? '',
                    customPath: ref.watch(downloadPathProvider),
                    isScanning: _isScanning,
                    onSetPath: () => _selectModelPath(
                      ref.read(downloadPathProvider.notifier),
                    ),
                    onResetPath: () async {
                      await _resetPath(ref.read(downloadPathProvider.notifier));
                      ModelPathCache.instance.invalidate();
                    },
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
                    onResetPath: () =>
                        _resetPath(ref.read(backupPathProvider.notifier)),
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
                    onResetPath: () =>
                        _resetPath(ref.read(logPathProvider.notifier)),
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
      ),
    );
  }

  Future<void> _selectPath(String title, dynamic notifier) async {
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

  /// 选择模型下载目录，选择后自动递归扫描 gguf 文件并注册到模型列表
  /// 切换目录时会自动清除旧目录的模型，只保留新目录和应用文档目录下的模型
  Future<void> _selectModelPath(dynamic notifier) async {
    // macOS 使用 NSOpenPanel（一步创建 Bookmark），其他平台使用 FilePicker
    final selectedDirectory = await SecurityBookmarkService.instance
        .pickDirectoryWithBookmark(dialogTitle: '选择模型下载目录');

    if (selectedDirectory == null) return;

    // macOS 沙盒：确保访问权限已激活（NSOpenPanel 已自动创建书签）
    await SecurityBookmarkService.instance.startAccessing(selectedDirectory);

    await notifier.setPath(selectedDirectory);
    await _loadPaths();

    // 使模型路径缓存失效，确保后续加载能发现新目录下的模型
    ModelPathCache.instance.invalidate();

    if (!mounted) return;

    // 开始扫描该目录下所有 gguf 文件（同时清除旧目录模型）
    setState(() => _isScanning = true);

    final modelNotifier = ref.read(modelProvider.notifier);
    final foundCount = await modelNotifier.refreshModelsForDirectory(selectedDirectory);

    if (mounted) {
      setState(() => _isScanning = false);

      if (foundCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('目录已切换，发现 $foundCount 个 GGUF 模型（旧目录模型已移除）'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('目录已切换: $selectedDirectory\n未发现 GGUF 文件，支持自动扫描多级子目录'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
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
  final bool isScanning;
  final VoidCallback onSetPath;
  final VoidCallback onResetPath;

  const _StoragePathTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.currentPath,
    this.customPath,
    this.isScanning = false,
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
                if (isScanning) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '扫描gguf文件中...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                ],
                if (hasCustomPath && !isScanning)
                  TextButton(onPressed: onResetPath, child: const Text('恢复默认')),
                if (!isScanning) ...[
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onSetPath,
                    icon: const Icon(Icons.folder_open, size: 18),
                    label: const Text('选择目录'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
