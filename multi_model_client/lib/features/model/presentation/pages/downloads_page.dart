import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/model_download/download_task_manager.dart';
import '../../../../core/storage/database.dart';
import '../../../../core/models/model_entry.dart';
import '../../../../core/providers/model_provider.dart';

/// 下载管理页面
/// 显示所有下载任务、进度，支持断点续传
class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  late final DownloadTaskManager _taskManager;
  List<DownloadTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taskManager = DownloadTaskManager.instance;
    _loadTasks();
    // 监听进度通知器，实时更新 UI
    _taskManager.progressNotifier.addListener(_onProgressUpdate);
  }

  @override
  void dispose() {
    _taskManager.progressNotifier.removeListener(_onProgressUpdate);
    super.dispose();
  }

  /// 进度更新回调
  void _onProgressUpdate() {
    if (!mounted) return;
    // 刷新任务列表以显示最新进度
    _refreshTasks();
  }

  /// 刷新任务列表（不显示加载状态）
  Future<void> _refreshTasks() async {
    try {
      final tasks = await _taskManager.getAllTasks();
      if (mounted) {
        setState(() => _tasks = tasks);
      }
    } catch (e) {
      debugPrint('[downloads_page] Error: $e');
    }
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskManager.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('下载管理'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? _buildEmptyState(theme)
              : _buildTaskList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_rounded,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无下载任务',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去模型市场下载模型吧',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/model-market'),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('浏览模型市场'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(ThemeData theme) {
    // 按状态分组
    final downloadingTasks = _tasks.where((t) => 
        t.status == 'downloading' || t.status == 'pending').toList();
    final pausedTasks = _tasks.where((t) => t.status == 'paused').toList();
    final completedTasks = _tasks.where((t) => t.status == 'completed').toList();
    final errorTasks = _tasks.where((t) => t.status == 'error').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (downloadingTasks.isNotEmpty) ...[
          _buildSectionHeader(theme, '正在下载', downloadingTasks.length),
          ...downloadingTasks.map((t) => _buildTaskCard(theme, t)),
          const SizedBox(height: 16),
        ],
        if (pausedTasks.isNotEmpty) ...[
          _buildSectionHeader(theme, '已暂停', pausedTasks.length),
          ...pausedTasks.map((t) => _buildTaskCard(theme, t)),
          const SizedBox(height: 16),
        ],
        if (completedTasks.isNotEmpty) ...[
          _buildSectionHeader(theme, '已完成', completedTasks.length),
          ...completedTasks.map((t) => _buildTaskCard(theme, t)),
          const SizedBox(height: 16),
        ],
        if (errorTasks.isNotEmpty) ...[
          _buildSectionHeader(theme, '下载失败', errorTasks.length),
          ...errorTasks.map((t) => _buildTaskCard(theme, t)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count', style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(ThemeData theme, DownloadTask task) {
    final status = task.status;
    // 优先使用内存中的实时进度（progressNotifier），而非数据库中的节流进度
    final liveProgress = _taskManager.progressNotifier.value[task.id];
    final int displayDownloaded;
    final int displayTotal;
    final double progress;

    if (liveProgress != null && liveProgress.status == DownloadStatus.downloading) {
      // 下载中：使用内存实时进度
      displayDownloaded = liveProgress.downloadedBytes;
      displayTotal = liveProgress.totalBytes;
      progress = displayTotal > 0 ? displayDownloaded / displayTotal : 0.0;
    } else {
      // 非下载中（暂停/完成/错误）：使用数据库记录
      displayDownloaded = task.downloadedBytes;
      displayTotal = task.totalBytes;
      progress = displayTotal > 0 ? displayDownloaded / displayTotal : 0.0;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: status == 'completed' ? () => _navigateToModelLoad(task) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusIcon(status),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.modelId, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(task.source, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _buildActionButtons(theme, task, status),
                ],
              ),
            if (status == 'downloading' || status == 'paused') ...[
              const SizedBox(height: 12),
              _buildProgressBar(theme, displayDownloaded, displayTotal, progress),
            ],
            if (status == 'error') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text('下载失败: ${task.error ?? "未知错误"}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onErrorContainer))),
                  ],
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  /// 跳转到模型加载页面
  ///
  /// 关键修复：下载任务的 modelId 是 HuggingFace 模型 ID（可能含 `/`），
  /// 而 modelProvider 中的模型使用 UUID 作为 ID。
  /// 需要通过 savePath（文件路径）匹配到正确的模型 ID，再用 UUID 路由。
  void _navigateToModelLoad(DownloadTask task) {
    final modelState = ref.read(modelProvider);
    
    // 通过 savePath 匹配 modelProvider 中的模型
    // 下载任务的 savePath 格式: /path/to/dir/filename.gguf
    // 模型的 filePath 也是同一个文件路径
    final matchedModel = modelState.models.where((m) {
      if (m.filePath == null) return false;
      // 精确匹配
      if (m.filePath == task.savePath) return true;
      // 兼容：task.savePath 可能是目录下的文件，model.filePath 也可能是
      if (task.savePath.isNotEmpty && m.filePath!.contains(task.savePath)) return true;
      return false;
    }).firstOrNull;
    
    if (matchedModel != null) {
      // 找到已注册模型，使用 UUID 路由
      debugPrint('[downloads_page] 找到匹配模型: ${matchedModel.id} (${matchedModel.displayName})');
      context.go('/model/${matchedModel.id}/load');
    } else {
      // 模型未在 provider 中注册（下载完成时用户不在市场页）
      // 尝试从文件路径推断并注册模型
      debugPrint('[downloads_page] 模型未在 provider 中注册，尝试自动注册: ${task.modelId}');
      _autoRegisterAndNavigate(task);
    }
  }

  /// 自动注册已下载模型并跳转
  Future<void> _autoRegisterAndNavigate(DownloadTask task) async {
    try {
      final filePath = task.savePath;
      if (filePath.isEmpty || !await File(filePath).exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('模型文件未找到，请重新下载'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      // 从 task.modelId 提取显示名（去掉路径前缀）
      final displayName = task.modelId.split('/').last;
      
      // 自动注册到 modelProvider
      final addedModel = await ref.read(modelProvider.notifier).addLocalModel(
        displayName: displayName,
        filePath: filePath,
      );

      debugPrint('[downloads_page] 自动注册模型成功: ${addedModel.id}');
      
      if (mounted) {
        context.go('/model/${addedModel.id}/load');
      }
    } catch (e) {
      debugPrint('[downloads_page] 自动注册模型失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载模型失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'downloading':
        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      case 'paused':
        return const Icon(Icons.pause_circle_outline, color: Colors.orange);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'error':
        return const Icon(Icons.error, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.grey);
    }
  }

  Widget _buildProgressBar(ThemeData theme, int downloadedBytes, int totalBytes, double progress) {
    final downloadedMB = (downloadedBytes / 1024 / 1024).toStringAsFixed(1);
    final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: theme.colorScheme.surfaceContainerHighest),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$downloadedMB / $totalMB MB', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('${(progress * 100).toStringAsFixed(1)}%', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, DownloadTask task, String status) {
    switch (status) {
      case 'downloading':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.pause), onPressed: () => _pauseTask(task.id), tooltip: '暂停'),
            IconButton(icon: const Icon(Icons.close), onPressed: () => _cancelTask(task.id), tooltip: '取消'),
          ],
        );
      case 'paused':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.play_arrow), onPressed: () => _resumeTask(task.id), tooltip: '继续'),
            IconButton(icon: const Icon(Icons.close), onPressed: () => _cancelTask(task.id), tooltip: '取消'),
          ],
        );
      case 'completed':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: Colors.green),
              onPressed: () => _navigateToModelLoad(task),
              tooltip: '加载模型',
            ),
            IconButton(icon: const Icon(Icons.folder_open), onPressed: () => _openFolder(task.savePath), tooltip: '打开文件夹'),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteTask(task.id), tooltip: '删除'),
          ],
        );
      case 'error':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _retryTask(task.id), tooltip: '重试'),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteTask(task.id), tooltip: '删除'),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.close), onPressed: () => _cancelTask(task.id), tooltip: '取消'),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteTask(task.id), tooltip: '删除'),
          ],
        );
    }
  }

  Future<void> _pauseTask(String taskId) async {
    try {
      await _taskManager.pauseTask(taskId);
      await _loadTasks();
    } catch (e) {
      debugPrint('暂停任务失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('暂停失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _resumeTask(String taskId) async {
    try {
      await _taskManager.resumeTask(taskId);
      await _loadTasks();
    } catch (e) {
      debugPrint('恢复任务失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelTask(String taskId) async {
    try {
      await _taskManager.cancelTask(taskId);
      await _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('下载已取消')),
        );
      }
    } catch (e) {
      debugPrint('取消任务失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    // 获取任务信息
    final tasks = await _taskManager.getAllTasks();
    final task = tasks.where((t) => t.id == taskId).firstOrNull;

    // 确认对话框（级联删除提示）
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除模型'),
        content: Text(
          '确定要删除「${task?.modelId ?? "此模型"}」吗？\n\n'
          '删除后以下内容将全部清除，此操作不可恢复：\n'
          '• 模型文件\n'
          '• 模型列表中的记录\n'
          '• 所有基于该模型的会话及聊天记录',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 1. 通过 filePath 匹配 modelProvider 中的模型（task.modelId 是 HuggingFace ID，不是 UUID）
      ModelEntry? matchedModel;
      if (task != null && task.savePath.isNotEmpty) {
        final modelState = ref.read(modelProvider);
        matchedModel = modelState.models.where((m) {
          if (m.filePath == null) return false;
          // 精确匹配文件路径
          if (m.filePath == task.savePath) return true;
          // 兼容：文件在同一目录下
          if (m.filePath!.contains(task.savePath)) return true;
          return false;
        }).firstOrNull;
      }

      // 2. 删除已下载的文件
      if (task != null && task.savePath.isNotEmpty) {
        final file = File(task.savePath);
        if (await file.exists()) {
          await file.delete();
        }
        // 也删除目录中的其他文件（如 mmproj 等）
        final dirPath = task.savePath.substring(0, task.savePath.lastIndexOf('/'));
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }

      // 3. 级联删除：模型列表中的记录 + 所有关联会话
      if (matchedModel != null) {
        try {
          await ref.read(modelProvider.notifier).deleteModel(matchedModel.id);
          debugPrint('[DownloadsPage] 已级联删除模型及关联会话: ${matchedModel.id} (${matchedModel.displayName})');
        } catch (e) {
          debugPrint('[DownloadsPage] 级联删除模型失败: $e');
        }
      } else {
        debugPrint('[DownloadsPage] 未找到匹配的模型记录，跳过级联删除');
      }

      // 3. 删除数据库中的下载任务记录
      await _taskManager.deleteTask(taskId);
      await _loadTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('模型及关联会话已删除'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('删除任务失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _retryTask(String taskId) async {
    try {
      await _taskManager.retryTask(taskId);
      await _loadTasks();
    } catch (e) {
      debugPrint('重试任务失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重试失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _openFolder(String path) async {
    if (path.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('路径无效'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    final directory = File(path).parent;
    final dirPath = directory.path;

    try {
      // 检查目录是否存在
      if (!await directory.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('目录不存在: $dirPath'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      // ★ 修复：iOS 上无法用 `open` 命令打开文件夹，改为显示文件信息
      if (Platform.isIOS || Platform.isAndroid) {
        // 移动端：列出目录中的文件并显示
        final files = <String>[];
        await for (final entity in directory.list()) {
          final name = entity.path.split('/').last;
          final size = entity is File ? ' (${(await entity.length() / 1024 / 1024).toStringAsFixed(1)} MB)' : '/';
          files.add(name + size);
        }
        if (mounted) {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('模型文件目录', style: Theme.of(ctx).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(dirPath, style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    const Divider(),
                    if (files.isEmpty)
                      const Text('目录为空（文件可能未下载完成）', style: TextStyle(color: Colors.orange))
                    else
                      ...files.map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          Icon(f.endsWith('/') ? Icons.folder : Icons.insert_drive_file, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Flexible(child: Text(f, overflow: TextOverflow.ellipsis)),
                        ]),
                      )),
                  ],
                ),
              ),
            ),
          );
        }
        return;
      }

      // 桌面端：使用平台命令打开文件夹
      final result = await Process.run('open', [dirPath]);
      
      if (result.exitCode != 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('打开文件夹失败: ${result.stderr}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开文件夹失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}