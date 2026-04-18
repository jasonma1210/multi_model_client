import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/model_download/download_task_manager.dart';
import '../../../../core/services/hardware_compatibility_checker.dart';
import '../../../../core/storage/database.dart';

/// 下载管理页面
/// 显示所有下载任务、进度，支持断点续传
class DownloadsPage extends ConsumerStatefulWidget {
  const DownloadsPage({super.key});

  @override
  ConsumerState<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends ConsumerState<DownloadsPage> {
  late final DownloadTaskManager _taskManager;
  final HardwareCompatibilityChecker _hardwareChecker = HardwareCompatibilityChecker();
  
  List<DownloadTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taskManager = DownloadTaskManager(Dio());
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
      // 静默处理刷新错误
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
    );
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
        return IconButton(icon: const Icon(Icons.folder_open), onPressed: () => _openFolder(task.savePath), tooltip: '打开文件夹');
      case 'error':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: () => _retryTask(task.id), tooltip: '重试'),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteTask(task.id), tooltip: '删除'),
          ],
        );
      default:
        return IconButton(icon: const Icon(Icons.close), onPressed: () => _cancelTask(task.id), tooltip: '取消');
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

  Future<void> _deleteTask(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除任务'),
        content: const Text('确定要删除这个下载任务吗？这将同时删除已下载的文件。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _taskManager.deleteTask(taskId);
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务已删除')),
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

      // 使用平台命令打开文件夹
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