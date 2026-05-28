/// 日志列表页面 - LLM Studio 设置中的日志管理
///
/// 功能：
/// - 显示所有日志条目（按时间倒序）
/// - 按级别/分类筛选日志
/// - 多选日志导出
/// - 删除日志
///
/// @author Jianma
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/log_service.dart';

/// 日志级别筛选 Provider
final logLevelFilterProvider = StateProvider<LogLevel?>((ref) => null);

/// 日志分类筛选 Provider
final logCategoryFilterProvider = StateProvider<LogCategory?>((ref) => null);

/// 日志多选 Provider
final logSelectionProvider = StateProvider<Set<String>>((ref) => {});

class LogListPage extends ConsumerStatefulWidget {
  const LogListPage({super.key});

  @override
  ConsumerState<LogListPage> createState() => _LogListPageState();
}

class _LogListPageState extends ConsumerState<LogListPage> {
  List<LogEntry> _logs = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  int _offset = 0;
  static const int _pageSize = 50;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _offset = 0;
    });

    try {
      final levelFilter = ref.read(logLevelFilterProvider);
      final categoryFilter = ref.read(logCategoryFilterProvider);

      final logs = await LogService.instance.getLogs(
        level: levelFilter,
        category: categoryFilter,
        limit: _pageSize,
        offset: 0,
      );

      setState(() {
        _logs = logs;
        _hasMore = logs.length >= _pageSize;
        _offset = logs.length;
      });
    } catch (e) {
      debugPrint('加载日志失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final levelFilter = ref.read(logLevelFilterProvider);
      final categoryFilter = ref.read(logCategoryFilterProvider);

      final logs = await LogService.instance.getLogs(
        level: levelFilter,
        category: categoryFilter,
        limit: _pageSize,
        offset: _offset,
      );

      setState(() {
        _logs.addAll(logs);
        _hasMore = logs.length >= _pageSize;
        _offset += logs.length;
      });
    } catch (e) {
      debugPrint('加载更多日志失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exportLogs() async {
    final selectedIds = ref.read(logSelectionProvider);
    
    try {
      // 先将日志导出到临时目录
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final tempFilePath = '${tempDir.path}/llm_studio_logs_$timestamp.txt';
      
      // 导出日志到临时文件
      final exportedPath = await LogService.instance.exportLogs(
        selectedIds.isEmpty ? [] : selectedIds.toList(),
        tempFilePath,
      );

      if (exportedPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('导出失败：没有日志可导出'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 使用 share_plus 分享文件
      await Share.shareXFiles(
        [XFile(exportedPath)],
        subject: 'LLM Studio 日志导出',
      );

      // 清除选择
      ref.read(logSelectionProvider.notifier).state = {};
    } catch (e) {
      debugPrint('导出日志失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedLogs() async {
    final selectedIds = ref.read(logSelectionProvider);
    if (selectedIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${selectedIds.length} 条日志吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await LogService.instance.deleteLogs(selectedIds.toList());
      if (success) {
        ref.read(logSelectionProvider.notifier).state = {};
        _loadLogs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('删除成功'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = ref.watch(logSelectionProvider).length;
    final levelFilter = ref.watch(logLevelFilterProvider);
    final categoryFilter = ref.watch(logCategoryFilterProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('日志管理'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings'),
          ),
          actions: [
            if (selectedCount > 0) ...[
              Text('$selectedCount 已选'),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteSelectedLogs,
                tooltip: '删除选中',
              ),
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                onPressed: _exportLogs,
                tooltip: '导出选中',
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                onPressed: _exportLogs,
                tooltip: '导出全部',
              ),
            ],
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                if (value == 'clear_filters') {
                  ref.read(logLevelFilterProvider.notifier).state = null;
                  ref.read(logCategoryFilterProvider.notifier).state = null;
                } else if (value.startsWith('level_')) {
                  final level = LogLevel.values.firstWhere(
                    (e) => e.toString().split('.').last == value.substring(6),
                  );
                  ref.read(logLevelFilterProvider.notifier).state =
                      levelFilter == level ? null : level;
                } else if (value.startsWith('category_')) {
                  final category = LogCategory.values.firstWhere(
                    (e) => e.toString().split('.').last == value.substring(9),
                  );
                  ref.read(logCategoryFilterProvider.notifier).state =
                      categoryFilter == category ? null : category;
                }
                _loadLogs();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_filters',
                  child: Text('清除筛选'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Text('日志级别'),
                ),
                ...LogLevel.values.map((level) => PopupMenuItem(
                  value: 'level_${level.toString().split('.').last}',
                  child: Row(
                    children: [
                      if (levelFilter == level) const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                      _buildLevelChip(level, theme),
                    ],
                  ),
                )),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Text('日志分类'),
                ),
                ...LogCategory.values.map((category) => PopupMenuItem(
                  value: 'category_${category.toString().split('.').last}',
                  child: Row(
                    children: [
                      if (categoryFilter == category) const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                      Text(category.toString().split('.').last),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
        body: _isLoading && _logs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bug_report_outlined, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('暂无日志', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('应用运行过程中的错误和异常会被记录在这里',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            )),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadLogs,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _logs.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _logs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final log = _logs[index];
                        final isSelected = ref.watch(logSelectionProvider).contains(log.id);

                        return _LogListItem(
                          log: log,
                          isSelected: isSelected,
                          onTap: () => context.push('/settings/logs/${log.id}'),
                          onLongPress: () {
                            final current = ref.read(logSelectionProvider);
                            if (current.contains(log.id)) {
                              ref.read(logSelectionProvider.notifier).state =
                                  current.difference({log.id});
                            } else {
                              ref.read(logSelectionProvider.notifier).state =
                                  current.union({log.id});
                            }
                          },
                          onSelect: () {
                            final current = ref.read(logSelectionProvider);
                            if (current.contains(log.id)) {
                              ref.read(logSelectionProvider.notifier).state =
                                  current.difference({log.id});
                            } else {
                              ref.read(logSelectionProvider.notifier).state =
                                  current.union({log.id});
                            }
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildLevelChip(LogLevel level, ThemeData theme) {
    Color color;
    switch (level) {
      case LogLevel.error:
        color = Colors.red;
        break;
      case LogLevel.warning:
        color = Colors.orange;
        break;
      case LogLevel.info:
        color = Colors.blue;
        break;
      case LogLevel.debug:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        level.toString().split('.').last,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

class _LogListItem extends StatelessWidget {
  final LogEntry log;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSelect;

  const _LogListItem({
    required this.log,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color levelColor;
    IconData levelIcon;
    switch (log.level) {
      case LogLevel.error:
        levelColor = Colors.red;
        levelIcon = Icons.error;
        break;
      case LogLevel.warning:
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      case LogLevel.info:
        levelColor = Colors.blue;
        levelIcon = Icons.info;
        break;
      case LogLevel.debug:
        levelColor = Colors.grey;
        levelIcon = Icons.bug_report;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 选择框
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelect(),
              ),
              // 级别图标
              Icon(levelIcon, color: levelColor, size: 20),
              const SizedBox(width: 12),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: levelColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.level.toString().split('.').last.toUpperCase(),
                            style: TextStyle(color: levelColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          log.category.toString().split('.').last,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      log.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}