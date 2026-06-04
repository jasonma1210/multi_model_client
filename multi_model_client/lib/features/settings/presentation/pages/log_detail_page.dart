/// 日志详情页面 - LLM Studio 设置中的日志详情查看
///
/// 功能：
/// - 显示日志完整内容
/// - 显示堆栈跟踪信息
/// - 显示设备信息
/// - 复制日志内容
/// - 导出单条日志
///
/// @author Jianma
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/log_service.dart';

class LogDetailPage extends ConsumerStatefulWidget {
  final String logId;

  const LogDetailPage({super.key, required this.logId});

  @override
  ConsumerState<LogDetailPage> createState() => _LogDetailPageState();
}

class _LogDetailPageState extends ConsumerState<LogDetailPage> {
  LogEntry? _log;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogDetail();
  }

  Future<void> _loadLogDetail() async {
    try {
      final log = await LogService.instance.getLogById(widget.logId);
      setState(() {
        _log = log;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('加载日志详情失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_log == null) return;

    final content =
        '''[${_log!.level.toString().split('.').last.toUpperCase()}] ${_log!.title}
时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_log!.createdAt)}
分类: ${_log!.category.toString().split('.').last}

${_log!.message}

${_log!.stackTrace != null ? '堆栈跟踪:\n${_log!.stackTrace}' : ''}
${_log!.deviceInfo != null ? '设备信息:\n${_log!.deviceInfo}' : ''}
''';

    await Clipboard.setData(ClipboardData(text: content));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制到剪贴板'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportLog() async {
    if (_log == null) return;

    try {
      // 先将日志导出到临时目录
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/log_${_log!.id}.txt';

      final exportPath = await LogService.instance.exportLogs([
        _log!.id,
      ], tempFilePath);

      if (exportPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('导出失败'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 使用 share_plus 分享文件
      await Share.shareXFiles([XFile(exportPath)], subject: 'LLM Studio 日志详情');
    } catch (e) {
      debugPrint('导出日志失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('日志详情'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings/logs'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_log == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('日志详情'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings/logs'),
          ),
        ),
        body: const Center(child: Text('日志不存在或已被删除')),
      );
    }

    Color levelColor;
    IconData levelIcon;
    switch (_log!.level) {
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

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('日志详情'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings/logs'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: '复制',
            ),
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              onPressed: _exportLog,
              tooltip: '导出',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 级别和分类
              Row(
                children: [
                  Icon(levelIcon, color: levelColor, size: 28),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _log!.level.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _log!.category.toString().split('.').last,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 时间
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(_log!.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 标题
              _SectionTitle(title: '标题'),
              const SizedBox(height: 8),
              Text(
                _log!.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // 内容
              _SectionTitle(title: '内容'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  _log!.message,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
              const SizedBox(height: 24),

              // 堆栈跟踪
              if (_log!.stackTrace != null && _log!.stackTrace!.isNotEmpty) ...[
                _SectionTitle(title: '堆栈跟踪'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SelectableText(
                    _log!.stackTrace!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.5,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 设备信息
              if (_log!.deviceInfo != null && _log!.deviceInfo!.isNotEmpty) ...[
                _SectionTitle(title: '设备信息'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    _log!.deviceInfo!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
