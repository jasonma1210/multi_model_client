// v0.43.0 实现 MCP 工具调用卡片 UI
//
// 用途：在 ChatPage 中显示 MCP 工具调用的实时状态
// 展示：工具名、参数摘要、结果、耗时、状态徽标
// 交互：可展开/收起参数和结果的详细 JSON

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/mcp_tool_call_provider.dart';

/// MCP 工具调用卡片（ChatPage 嵌入式）
///
/// - 监听 [mcpToolCallProvider]
/// - 有活跃调用时显示头部 Summary Card
/// - 收起状态：仅显示当前活跃调用的工具名 + 旋转图标
/// - 展开状态：显示最近 5 条调用的完整记录
class McpToolCallCard extends ConsumerStatefulWidget {
  /// 是否默认展开
  final bool initiallyExpanded;

  /// v0.45.0: 重新执行回调（null 时不显示「重新执行」菜单项）
  final void Function(McpToolCallRecord record)? onRerun;

  const McpToolCallCard({
    super.key,
    this.initiallyExpanded = false,
    this.onRerun,
  });

  @override
  ConsumerState<McpToolCallCard> createState() => _McpToolCallCardState();
}

class _McpToolCallCardState extends ConsumerState<McpToolCallCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(mcpToolCallProvider);

    if (state.records.isEmpty) return const SizedBox.shrink();

    final active = state.activeCalls;
    final isRunning = active.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isRunning
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRunning
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, state, isRunning),
          if (_expanded) _buildBody(theme, state.records),
        ],
      ),
    );
  }

  /// 头部：状态图标 + 标题 + 展开按钮
  Widget _buildHeader(ThemeData theme, McpToolCallState state, bool isRunning) {
    final active = state.activeCalls;
    final totalCount = state.records.length;
    final title = isRunning
        ? 'MCP 工具执行中（${active.length}）'
        : 'MCP 工具调用（$totalCount）';

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _McpStatusIcon(isRunning: isRunning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isRunning)
              TextButton(
                onPressed: () {
                  for (final call in active) {
                    ref.read(mcpToolCallProvider.notifier).cancel(call.id);
                  }
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('取消', style: TextStyle(fontSize: 12)),
              ),
            Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// 主体：最近 5 条调用的详细记录
  Widget _buildBody(ThemeData theme, List<McpToolCallRecord> records) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          for (final record in records.take(5)) ...[
            _McpCallItem(
              record: record,
              theme: theme,
              onRerun: widget.onRerun == null
                  ? null
                  : () => widget.onRerun!(record),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// 单条 MCP 工具调用详情项
class _McpCallItem extends StatefulWidget {
  final McpToolCallRecord record;
  final ThemeData theme;
  final VoidCallback? onRerun; // v0.45.0: 重新执行回调

  const _McpCallItem({
    required this.record,
    required this.theme,
    this.onRerun,
  });

  @override
  State<_McpCallItem> createState() => _McpCallItemState();
}

class _McpCallItemState extends State<_McpCallItem> {
  bool _showArgs = false;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final theme = widget.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：状态点 + 工具名 + 耗时
          Row(
            children: [
              _StatusDot(status: r.status),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall,
                    children: [
                      TextSpan(
                        text: r.serverName,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: ' › ',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextSpan(
                        text: r.toolName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _StatusBadge(status: r.status),
              _CopyMenu(record: r, onRerun: widget.onRerun),
            ],
          ),
          const SizedBox(height: 4),
          // 参数摘要（可展开）
          if (r.arguments.isNotEmpty)
            InkWell(
              onTap: () => setState(() => _showArgs = !_showArgs),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      _showArgs ? Icons.expand_more : Icons.chevron_right,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '参数',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (!_showArgs)
                      Expanded(
                        child: Text(
                          _truncate(r.arguments, 80),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (_showArgs)
            _CodeBlock(text: _prettyJson(r.arguments), theme: theme),
          // 结果/错误（可展开）
          if (r.result != null)
            InkWell(
              onTap: () => setState(() => _showResult = !_showResult),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      _showResult ? Icons.expand_more : Icons.chevron_right,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '结果',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (!_showResult)
                      Expanded(
                        child: Text(
                          _truncate(r.result!, 80),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (_showResult)
            _CodeBlock(text: _prettyJson(r.result!), theme: theme),
          if (r.error != null) ...[
            const SizedBox(height: 2),
            _ErrorBlock(error: r.error!, theme: theme),
          ],
          // 耗时
          if (r.duration != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 11,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  '${r.duration!.inMilliseconds} ms',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…';
  }

  static String _prettyJson(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final parsed = jsonDecode(raw);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(parsed);
    } catch (_) {
      return raw;
    }
  }
}

/// 状态点（圆形）
class _StatusDot extends StatelessWidget {
  final McpToolCallStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color get _color {
    switch (status) {
      case McpToolCallStatus.pending:
        return Colors.grey;
      case McpToolCallStatus.running:
        return Colors.blue;
      case McpToolCallStatus.success:
        return Colors.green;
      case McpToolCallStatus.failed:
        return Colors.red;
      case McpToolCallStatus.canceled:
        return Colors.orange;
    }
  }
}

/// 状态徽标（圆角文字）
class _StatusBadge extends StatelessWidget {
  final McpToolCallStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case McpToolCallStatus.pending:
        return '等待';
      case McpToolCallStatus.running:
        return '执行中';
      case McpToolCallStatus.success:
        return '成功';
      case McpToolCallStatus.failed:
        return '失败';
      case McpToolCallStatus.canceled:
        return '已取消';
    }
  }

  Color get _color {
    switch (status) {
      case McpToolCallStatus.pending:
        return Colors.grey;
      case McpToolCallStatus.running:
        return Colors.blue;
      case McpToolCallStatus.success:
        return Colors.green;
      case McpToolCallStatus.failed:
        return Colors.red;
      case McpToolCallStatus.canceled:
        return Colors.orange;
    }
  }
}

/// 头部状态图标
class _McpStatusIcon extends StatefulWidget {
  final bool isRunning;
  const _McpStatusIcon({required this.isRunning});

  @override
  State<_McpStatusIcon> createState() => _McpStatusIconState();
}

class _McpStatusIconState extends State<_McpStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    if (widget.isRunning) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(_McpStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.isRunning && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRunning) {
      return const Icon(Icons.extension_outlined, size: 18, color: Colors.grey);
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Transform.rotate(
        angle: _ctrl.value * 6.28,
        child: const Icon(Icons.extension, size: 18, color: Colors.blue),
      ),
    );
  }
}

/// JSON 代码块
class _CodeBlock extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _CodeBlock({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'monospace',
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// 错误块
class _ErrorBlock extends StatelessWidget {
  final String error;
  final ThemeData theme;
  const _ErrorBlock({required this.error, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 14, color: Colors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.red,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// v0.45.0: 复制菜单（调用信息 / JSON / 结果 / Markdown / 重新执行）
class _CopyMenu extends StatelessWidget {
  final McpToolCallRecord record;
  final VoidCallback? onRerun; // v0.45.0: 重新执行回调
  const _CopyMenu({required this.record, this.onRerun});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.copy_outlined, size: 14),
      tooltip: '复制',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 160),
      onSelected: (value) => _onSelected(context, value),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'call', child: Text('复制调用信息')),
        const PopupMenuItem(value: 'json', child: Text('复制 JSON')), // v0.45.0
        if (record.result != null)
          const PopupMenuItem(value: 'result', child: Text('复制结果')),
        const PopupMenuItem(value: 'markdown', child: Text('复制为 Markdown')),
        if (onRerun != null)
          const PopupMenuItem(value: 'rerun', child: Text('重新执行')), // v0.45.0
      ],
    );
  }

  void _onSelected(BuildContext context, String action) {
    // v0.45.0: 重新执行不走剪贴板
    if (action == 'rerun') {
      onRerun?.call();
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    String data;
    switch (action) {
      case 'call':
        data = '${record.serverName} › ${record.toolName}\n${record.arguments}';
        break;
      case 'json': // v0.45.0: 复制美化后的入参 JSON
        data = _pretty(record.arguments);
        break;
      case 'result':
        data = record.result ?? '';
        break;
      case 'markdown':
        data = _toMarkdown(record);
        break;
      default:
        return;
    }
    Clipboard.setData(ClipboardData(text: data));
    messenger.showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _toMarkdown(McpToolCallRecord r) {
    final buf = StringBuffer();
    buf.writeln('## ${r.serverName} › ${r.toolName}');
    buf.writeln();
    buf.writeln('- 状态: ${_statusLabel(r.status)}'
        '${r.duration != null ? ' · 耗时: ${r.duration!.inMilliseconds}ms' : ''}');
    if (r.arguments.isNotEmpty) {
      buf.writeln('- 参数:');
      buf.writeln('```json');
      buf.writeln(_pretty(r.arguments));
      buf.writeln('```');
    }
    if (r.result != null) {
      buf.writeln('- 结果:');
      buf.writeln('```json');
      buf.writeln(_pretty(r.result!));
      buf.writeln('```');
    }
    if (r.error != null) {
      buf.writeln('- 错误:');
      buf.writeln('```');
      buf.writeln(r.error);
      buf.writeln('```');
    }
    return buf.toString();
  }

  static String _statusLabel(McpToolCallStatus s) {
    switch (s) {
      case McpToolCallStatus.pending:
        return '等待';
      case McpToolCallStatus.running:
        return '执行中';
      case McpToolCallStatus.success:
        return '成功';
      case McpToolCallStatus.failed:
        return '失败';
      case McpToolCallStatus.canceled:
        return '已取消';
    }
  }

  static String _pretty(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final parsed = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (_) {
      return raw;
    }
  }
}
