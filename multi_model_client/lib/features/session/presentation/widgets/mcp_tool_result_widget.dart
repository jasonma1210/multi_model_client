import 'package:flutter/material.dart';
import '../../../../core/protocols/mcp_protocol.dart' show MCPToolResult, MCPContent, MCPTool;

/// MCP 工具调用结果展示组件
class McpToolResultWidget extends StatelessWidget {
  final MCPToolResult result;
  final String toolName;
  final VoidCallback? onCopy;
  final VoidCallback? onRetry;

  const McpToolResultWidget({
    super.key,
    required this.result,
    required this.toolName,
    this.onCopy,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = result.isError ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isError
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 工具名称标题
            Row(
              children: [
                Icon(
                  Icons.build,
                  size: 16,
                  color: isError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🔧 $toolName',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isError
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (onCopy != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: onCopy,
                    tooltip: '复制结果',
                    iconSize: 16,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 内容展示
            ...result.content.map((content) => _buildContent(context, content)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MCPContent content) {
    final theme = Theme.of(context);

    switch (content.type) {
      case 'text':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content.text ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        );

      case 'image':
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🖼️ 图片',
                style: theme.textTheme.labelMedium,
              ),
              if (content.data != null)
                Text(
                  'Base64数据 (${content.data!.length} bytes)',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        );

      case 'resource':
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content.data ?? '未知资源',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content.text ?? content.data ?? '未知内容',
            style: theme.textTheme.bodySmall,
          ),
        );
    }
  }
}

/// MCP 工具调用进度指示器
class McpToolCallProgress extends StatelessWidget {
  final String toolName;
  final String? statusMessage;

  const McpToolCallProgress({
    super.key,
    required this.toolName,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔧 $toolName',
                    style: theme.textTheme.titleSmall,
                  ),
                  if (statusMessage != null)
                    Text(
                      statusMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MCP 工具调用确认对话框
class McpToolCallConfirmDialog extends StatelessWidget {
  final String toolName;
  final String toolDescription;
  final Map<String, dynamic> arguments;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const McpToolCallConfirmDialog({
    super.key,
    required this.toolName,
    required this.toolDescription,
    required this.arguments,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.build, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('确认调用工具'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                toolName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (toolDescription.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  toolDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                '参数:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _formatJson(arguments),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('确认调用'),
        ),
      ],
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    _prettyPrint(json, buffer, 0);
    return buffer.toString();
  }

  void _prettyPrint(dynamic json, StringBuffer buffer, int indent) {
    final spaces = '  ' * indent;

    if (json is Map) {
      buffer.writeln('{');
      final entries = json.entries.toList();
      for (var i = 0; i < entries.length; i++) {
        buffer.write('$spaces  "${entries[i].key}": ');
        _prettyPrint(entries[i].value, buffer, indent + 1);
        if (i < entries.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$spaces}');
    } else if (json is List) {
      buffer.writeln('[');
      for (var i = 0; i < json.length; i++) {
        buffer.write('$spaces  ');
        _prettyPrint(json[i], buffer, indent + 1);
        if (i < json.length - 1) buffer.write(',');
        buffer.writeln();
      }
      buffer.write('$spaces]');
    } else if (json is String) {
      buffer.write('"${json.replaceAll('"', '\\"')}"');
    } else {
      buffer.write(json.toString());
    }
  }
}

/// MCP 工具列表展示组件
class McpToolListWidget extends StatelessWidget {
  final List<MCPTool> tools;
  final Function(MCPTool)? onToolTap;
  final Function(MCPTool)? onToolInfo;

  const McpToolListWidget({
    super.key,
    required this.tools,
    this.onToolTap,
    this.onToolInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无可用工具',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.build,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              tool.name,
              style: theme.textTheme.titleSmall,
            ),
            subtitle: tool.description != null
                ? Text(
                    tool.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onToolInfo != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => onToolInfo!(tool),
                    tooltip: '查看详情',
                  ),
                if (onToolTap != null)
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => onToolTap!(tool),
                    tooltip: '调用工具',
                  ),
              ],
            ),
            onTap: onToolTap != null ? () => onToolTap!(tool) : null,
          ),
        );
      },
    );
  }
}