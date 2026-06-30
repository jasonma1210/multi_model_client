// v0.43.0 实现 A2A 任务监控 UI
//
// 用途：在 ChatPage 中显示 A2A 任务的实时状态
// 展示：当前状态、累积文本、已收到事件数、重连状态

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/protocols/a2a/a2a_client.dart';
import '../../../core/protocols/a2a/a2a_protocol.dart';
import '../providers/a2a_providers.dart';

/// A2A 任务状态卡片
class A2ATaskMonitorCard extends ConsumerWidget {
  /// 任务完成后的回调（用于把结果写回 ChatPage 消息列表）
  final void Function(String text)? onCompleted;

  /// 取消按钮回调
  final VoidCallback? onCancel;

  const A2ATaskMonitorCard({
    super.key,
    this.onCompleted,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final task = ref.watch(a2aTaskRuntimeProvider);

    if (task == null) return const SizedBox.shrink();

    // 状态变化时触发回调
    ref.listen(a2aTaskRuntimeProvider, (prev, next) {
      if (next == null) return;
      if (next.state == TaskState.completed && onCompleted != null) {
        onCompleted!(next.accumulatedText ?? '');
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(task.state, theme),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getBorderColor(task.state, theme),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusIcon(state: task.state),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${task.agentName} · ${_stateLabel(task.state)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getForegroundColor(task.state, theme),
                  ),
                ),
              ),
              if (task.state == TaskState.working ||
                  task.state == TaskState.submitted)
                IconButton(
                  tooltip: '取消任务',
                  icon: const Icon(Icons.stop_circle_outlined, size: 20),
                  onPressed: () {
                    ref.read(a2aTaskRuntimeProvider.notifier).cancel();
                    onCancel?.call();
                  },
                ),
            ],
          ),
          // v0.43.0: 重连状态条
          if (task.reconnectState == A2AReconnectState.reconnecting)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _ReconnectBanner(task: task),
            ),
          if (task.accumulatedText != null && task.accumulatedText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: SingleChildScrollView(
                child: Text(
                  task.accumulatedText!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${task.events.length} 个事件',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.outline,
                ),
              ),
              if (task.retryAttempt > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '已重试 ${task.retryAttempt} 次',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _stateLabel(TaskState state) {
    switch (state) {
      case TaskState.submitted:
        return '已提交';
      case TaskState.working:
        return '执行中';
      case TaskState.inputRequired:
        return '等待输入';
      case TaskState.completed:
        return '已完成';
      case TaskState.failed:
        return '失败';
      case TaskState.canceled:
        return '已取消';
      case TaskState.unknown:
        return '未知';
    }
  }

  Color _getBackgroundColor(TaskState state, ThemeData theme) {
    switch (state) {
      case TaskState.working:
      case TaskState.submitted:
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
      case TaskState.completed:
        return Colors.green.withValues(alpha: 0.08);
      case TaskState.failed:
      case TaskState.canceled:
        return theme.colorScheme.errorContainer.withValues(alpha: 0.3);
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getBorderColor(TaskState state, ThemeData theme) {
    switch (state) {
      case TaskState.working:
      case TaskState.submitted:
        return theme.colorScheme.primary.withValues(alpha: 0.4);
      case TaskState.completed:
        return Colors.green.withValues(alpha: 0.4);
      case TaskState.failed:
      case TaskState.canceled:
        return theme.colorScheme.error.withValues(alpha: 0.4);
      default:
        return theme.colorScheme.outlineVariant;
    }
  }

  Color _getForegroundColor(TaskState state, ThemeData theme) {
    switch (state) {
      case TaskState.working:
      case TaskState.submitted:
        return theme.colorScheme.primary;
      case TaskState.completed:
        return Colors.green.shade800;
      case TaskState.failed:
      case TaskState.canceled:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}

class _StatusIcon extends StatefulWidget {
  final TaskState state;
  const _StatusIcon({required this.state});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = widget.state == TaskState.working ||
        widget.state == TaskState.submitted;

    if (!isRunning) {
      return Icon(_staticIcon, size: 18, color: _color);
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.rotate(
        angle: _ctrl.value * 6.28,
        child: Icon(_staticIcon, size: 18, color: _color),
      ),
    );
  }

  IconData get _staticIcon {
    switch (widget.state) {
      case TaskState.working:
      case TaskState.submitted:
        return Icons.sync;
      case TaskState.inputRequired:
        return Icons.input;
      case TaskState.completed:
        return Icons.check_circle;
      case TaskState.failed:
        return Icons.error;
      case TaskState.canceled:
        return Icons.cancel;
      case TaskState.unknown:
        return Icons.help;
    }
  }

  Color get _color {
    switch (widget.state) {
      case TaskState.working:
      case TaskState.submitted:
        return Colors.blue;
      case TaskState.completed:
        return Colors.green;
      case TaskState.failed:
      case TaskState.canceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// v0.43.0: 重连状态横幅
class _ReconnectBanner extends StatelessWidget {
  final A2ATaskRuntime task;
  const _ReconnectBanner({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backoff = task.nextBackoff;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(Colors.orange),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              backoff != null
                  ? '连接已断开，${(backoff.inMilliseconds / 1000).toStringAsFixed(1)}s 后重连（第 ${task.retryAttempt} 次）'
                  : '正在重连（第 ${task.retryAttempt} 次）...',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
