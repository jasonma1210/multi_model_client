import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mcp_config_manager.dart';

/// MCP 配置对话框 - 类似于 LM Studio 的 mcp.json 配置
class McpConfigDialog extends ConsumerStatefulWidget {
  const McpConfigDialog({super.key});

  @override
  ConsumerState<McpConfigDialog> createState() => _McpConfigDialogState();
}

class _McpConfigDialogState extends ConsumerState<McpConfigDialog> {
  final _jsonController = TextEditingController();
  final _configManager = McpConfigManager();
  String? _errorMessage;
  Map<String, dynamic>? _parsedConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await _configManager.loadConfig();
      setState(() {
        _jsonController.text = const JsonEncoder.withIndent('  ').convert(config);
        _isLoading = false;
      });
      _parseJson();
    } catch (e) {
      setState(() {
        _jsonController.text = const JsonEncoder.withIndent('  ').convert({
          'mcpServers': {},
        });
        _isLoading = false;
      });
      _parseJson();
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _parseJson() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = null;
        _parsedConfig = null;
      });
      return;
    }

    try {
      final parsed = json.decode(text);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('JSON 必须是对象格式');
      }
      
      // 验证格式
      if (!parsed.containsKey('mcpServers')) {
        throw const FormatException('必须包含 mcpServers 字段');
      }

      setState(() {
        _parsedConfig = parsed;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'JSON 格式错误: $e';
        _parsedConfig = null;
      });
    }
  }

  Future<void> _applyConfig() async {
    if (_parsedConfig == null) return;
    
    try {
      await _configManager.saveConfig(_parsedConfig!);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MCP 配置已保存'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.extension, color: theme.colorScheme.primary),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  'MCP 服务器配置',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // 说明
            Text(
              '配置 MCP 服务器，格式类似于 LM Studio 的 mcp.json',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // JSON 输入框或加载中
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Text(
                'MCP 配置 (JSON):',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Expanded(
                child: TextField(
                  controller: _jsonController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: '{\n  "mcpServers": {\n    "server-name": {\n      "command": "npx",\n      "args": ["-y", "@package/name"]\n    }\n  }\n}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    errorText: _errorMessage,
                  ),
                  onChanged: (_) => _parseJson(),
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingM),
            
            // 解析结果
            if (_parsedConfig != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      '解析成功: ${_parsedConfig!['mcpServers'].keys.length} 个服务器',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
            ],
            
            // 按钮行
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: AppTheme.spacingM),
                FilledButton(
                  onPressed: _parsedConfig != null ? _applyConfig : null,
                  child: const Text('保存'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}