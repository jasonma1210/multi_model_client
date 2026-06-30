// v0.43.0 实现 MCP 工具浏览与手动调用面板
//
// 用途：
// 1. 列出当前会话启用的 MCP 服务器的所有工具
// 2. 允许用户手动调用工具（用于测试 & 调试）
// 3. 调用记录会自动进入 mcpToolCallProvider，由 McpToolCallCard 实时显示
//
// 流程：
// - 用户选择 server → 看到该 server 下的所有工具
// - 用户点击工具 → 弹出参数输入对话框
// - 用户提交 → 调用 SessionMcpToolManager.callSessionTool
// - 调用过程/结果通过 mcpToolCallProvider 暴露给 UI

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/protocols/mcp_protocol.dart';
import '../../../../core/protocols/mcp_server_manager.dart';
import '../../../session/domain/session_mcp_tool_manager.dart';
import '../../data/repositories/mcp_tool_call_history_repository.dart';
import '../../providers/mcp_tool_call_provider.dart';

class McpToolExplorerPage extends ConsumerStatefulWidget {
  final String sessionId;

  const McpToolExplorerPage({super.key, required this.sessionId});

  @override
  ConsumerState<McpToolExplorerPage> createState() =>
      _McpToolExplorerPageState();
}

class _McpToolExplorerPageState extends ConsumerState<McpToolExplorerPage> {
  late final SessionMcpToolManager _toolManager;
  bool _loading = true;
  String? _error;
  Map<String, List<MCPTool>> _toolsByServer = {};
  Map<String, String> _serverNames = {};
  String? _expandedServerId;
  // v0.44.0: 调用历史筛选状态
  McpToolCallStatus? _statusFilter;
  // v0.45.0: DB 分页历史状态
  int _historyOffset = 0;
  int _historyTotal = 0;
  bool _historyLoading = false;
  String? _toolNameSearch;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  final McpToolCallHistoryRepository _historyRepo =
      McpToolCallHistoryRepository();

  @override
  void initState() {
    super.initState();
    _toolManager = SessionMcpToolManager(McpServerManager());
    _loadTools();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  /// v0.45.0: 从 DB 加载调用历史（分页 + 筛选 + 搜索）
  Future<void> _loadHistory({bool reset = true}) async {
    if (_historyLoading) return;
    setState(() => _historyLoading = true);
    try {
      final offset = reset ? 0 : _historyOffset;
      final notifier = ref.read(mcpToolCallProvider.notifier);
      await notifier.loadHistory(
        sessionId: widget.sessionId,
        limit: 20,
        offset: offset,
        statusFilter: _statusFilter?.name,
        toolNameSearch: _toolNameSearch,
      );
      final total = await _historyRepo.getCount(
        statusFilter: _statusFilter?.name,
        toolNameSearch: _toolNameSearch,
      );
      _historyOffset = offset + 20;
      _historyTotal = total;
    } catch (e) {
      debugPrint('[McpExplorer] loadHistory failed: $e');
    } finally {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _toolNameSearch = value.trim().isEmpty ? null : value.trim();
      _loadHistory(reset: true);
    });
  }

  Future<void> _loadTools() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final serverIds = await _toolManager.getSessionServerIds(widget.sessionId);
      final serverManager = McpServerManager();
      final allConfigs = await serverManager.getAllConfigs();
      final configByServerId = {
        for (final c in allConfigs) c.serverId: c,
      };
      final result = <String, List<MCPTool>>{};
      final names = <String, String>{};
      for (final serverId in serverIds) {
        final tools = await serverManager.getServerTools(serverId);
        result[serverId] = tools;
        names[serverId] = configByServerId[serverId]?.name ?? serverId;
      }
      if (!mounted) return;
      setState(() {
        _toolsByServer = result;
        _serverNames = names;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP 工具浏览'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新工具列表',
            onPressed: _loadTools,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text('加载失败：$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadTools,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    if (_toolsByServer.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.extension_off,
                  size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              const Text('当前会话未启用任何 MCP 服务器', textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                '请在工具菜单的「MCP 工具」入口中添加',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // v0.44.0: 调用历史筛选区
        _buildHistorySection(theme),
        const SizedBox(height: 8),
        for (final entry in _toolsByServer.entries) ...[
          _buildServerSection(theme, entry.key, entry.value),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// v0.45.0: 调用历史区（DB 分页 + 搜索 + 筛选）
  Widget _buildHistorySection(ThemeData theme) {
    final state = ref.watch(mcpToolCallProvider);
    final records = state.records;
    final hasMore = _historyOffset < _historyTotal;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
            child: Row(
              children: [
                const Icon(Icons.history, size: 16),
                const SizedBox(width: 6),
                Text('调用历史',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                if (_historyTotal > 0)
                  Text('$_historyTotal',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      )),
                const Spacer(),
                if (records.isNotEmpty || _historyTotal > 0)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: const Text('清空', style: TextStyle(fontSize: 12)),
                    onPressed: () async {
                      await _historyRepo.cleanupOlderThan(0);
                      ref.read(mcpToolCallProvider.notifier).clear();
                      _historyOffset = 0;
                      _historyTotal = 0;
                      if (mounted) setState(() {});
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),
          // v0.45.0: 搜索框
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: '搜索工具名...',
                hintStyle: const TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 16),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // 状态筛选 Chip 行
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _filterChip(theme, '全部', null),
                const SizedBox(width: 4),
                _filterChip(theme, '执行中', McpToolCallStatus.running),
                const SizedBox(width: 4),
                _filterChip(theme, '成功', McpToolCallStatus.success),
                const SizedBox(width: 4),
                _filterChip(theme, '失败', McpToolCallStatus.failed),
              ],
            ),
          ),
          if (records.isEmpty && !_historyLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '暂无调用历史',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final r in records.take(20))
                    _HistoryItem(record: r, theme: theme),
                ],
              ),
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: OutlinedButton.icon(
                  onPressed: _historyLoading
                      ? null
                      : () => _loadHistory(reset: false),
                  icon: _historyLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.expand_more, size: 16),
                  label: Text(
                    _historyLoading ? '加载中...' : '加载更多',
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(ThemeData theme, String label, McpToolCallStatus? status) {
    final selected = _statusFilter == status;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _statusFilter = selected ? null : status;
        });
        _loadHistory(reset: true); // v0.45.0: DB 端筛选
      },
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildServerSection(ThemeData theme, String serverId, List<MCPTool> tools) {
    final expanded = _expandedServerId == serverId;
    final serverName = _serverNames[serverId] ?? serverId;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              _expandedServerId = expanded ? null : serverId;
            }),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.dns_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(serverName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        Text('$serverId · ${tools.length} 个工具',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            for (final tool in tools) _buildToolTile(theme, serverId, serverName, tool),
          ],
        ],
      ),
    );
  }

  Widget _buildToolTile(ThemeData theme, String serverId, String serverName, MCPTool tool) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.build_outlined, size: 18),
      title: Text(tool.name, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        tool.description ?? '(无描述)',
        style: theme.textTheme.bodySmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.play_arrow, size: 18),
      onTap: () => _showInvokeDialog(context, serverId, serverName, tool),
    );
  }

  Future<void> _showInvokeDialog(
    BuildContext context,
    String serverId,
    String serverName,
    MCPTool tool,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final argsJson = await showDialog<String>(
      context: context,
      builder: (_) => _ToolInvokeDialog(tool: tool),
    );
    if (argsJson == null) return;

    Map<String, dynamic> arguments;
    try {
      final parsed = jsonDecode(argsJson);
      arguments = parsed is Map<String, dynamic>
          ? parsed
          : (parsed as Map).cast<String, dynamic>();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('参数 JSON 解析失败: $e')),
      );
      return;
    }

    await _invokeTool(serverId, serverName, tool.name, arguments);
  }

  Future<void> _invokeTool(
    String serverId,
    String serverName,
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    // v0.45.0: 写工具二次确认（防止误操作）
    if (_isWriteTool(toolName)) {
      final confirmed = await _showWriteConfirmDialog(context, toolName);
      if (!confirmed) return;
    }

    final notifier = ref.read(mcpToolCallProvider.notifier);
    final callId = notifier.start(
      serverId: serverId,
      serverName: serverName,
      toolName: toolName,
      arguments: jsonEncode(arguments),
      sessionId: widget.sessionId, // v0.45.0: 关联会话
    );

    try {
      final result = await _toolManager.callSessionTool(
        widget.sessionId,
        serverId,
        toolName,
        arguments,
      );

      if (!mounted) return;
      if (result.isError == true) {
        final errorText = result.content
                .map((c) => c.text ?? '')
                .where((s) => s.isNotEmpty)
                .join('\n');
        notifier.fail(callId, error: errorText.isEmpty ? '工具返回错误' : errorText);
      } else {
        // MCP 工具结果通常是 content 列表，序列化为 JSON
        final text = result.content
            .map((c) => c.text ?? c.data ?? '')
            .where((s) => s.isNotEmpty)
            .join('\n');
        notifier.complete(callId, result: text.isEmpty ? '(空结果)' : text);
      }
    } catch (e) {
      if (!mounted) return;
      notifier.fail(callId, error: e.toString());
    }
  }

  /// v0.45.0: 判断是否为写工具（需要二次确认）
  bool _isWriteTool(String name) {
    final lower = name.toLowerCase();
    return lower.contains('write') ||
        lower.contains('delete') ||
        lower.contains('move') ||
        lower.contains('create') ||
        lower.contains('remove') ||
        lower.contains('update');
  }

  /// v0.45.0: 写工具二次确认对话框
  Future<bool> _showWriteConfirmDialog(
      BuildContext ctx, String toolName) async {
    final result = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('确认执行写操作'),
        content: Text('工具「$toolName」可能修改数据。确认要执行吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认执行'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// 工具调用参数输入对话框
class _ToolInvokeDialog extends StatefulWidget {
  final MCPTool tool;
  const _ToolInvokeDialog({required this.tool});

  @override
  State<_ToolInvokeDialog> createState() => _ToolInvokeDialogState();
}

class _ToolInvokeDialogState extends State<_ToolInvokeDialog> {
  late final TextEditingController _controller;
  String? _schemaHint;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initialJsonFromSchema(widget.tool.inputSchema));
    _schemaHint = _summarizeSchema(widget.tool.inputSchema);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _initialJsonFromSchema(Map<String, dynamic>? schema) {
    if (schema == null) return '{}';
    try {
      final props = schema['properties'] as Map<String, dynamic>?;
      if (props == null || props.isEmpty) return '{}';
      final empty = <String, dynamic>{};
      for (final key in props.keys) {
        empty[key] = '';
      }
      return const JsonEncoder.withIndent('  ').convert(empty);
    } catch (_) {
      return '{}';
    }
  }

  String? _summarizeSchema(Map<String, dynamic>? schema) {
    if (schema == null) return null;
    try {
      final props = schema['properties'] as Map<String, dynamic>?;
      if (props == null || props.isEmpty) return null;
      final buf = StringBuffer('参数: ');
      buf.writeAll(
        props.keys.map((k) {
          final p = props[k] as Map<String, dynamic>?;
          final type = p?['type'] ?? 'any';
          return '$k: $type';
        }),
        ', ',
      );
      return buf.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('调用 ${widget.tool.name}'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.tool.description != null) ...[
              Text(widget.tool.description!, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
            ],
            if (_schemaHint != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_schemaHint!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    )),
              ),
              const SizedBox(height: 8),
            ],
            const Text('参数 (JSON 格式):'),
            const SizedBox(height: 4),
            TextField(
              controller: _controller,
              maxLines: 8,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: '{}',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('调用'),
        ),
      ],
    );
  }
}

/// v0.44.0: 历史记录项（紧凑展示）
class _HistoryItem extends StatelessWidget {
  final McpToolCallRecord record;
  final ThemeData theme;

  const _HistoryItem({required this.record, required this.theme});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(record.status);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.serverName} › ${record.toolName}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (record.error != null)
                  Text(
                    record.error!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.red),
                  )
                else if (record.result != null)
                  Text(
                    record.result!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
          if (record.duration != null)
            Text(
              '${record.duration!.inMilliseconds}ms',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(McpToolCallStatus s) {
    switch (s) {
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
