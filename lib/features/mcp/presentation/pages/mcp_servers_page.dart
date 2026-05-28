import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/mcp_config_manager.dart';

/// MCP 服务器管理页面 - 两个选项卡
class McpServersPage extends ConsumerStatefulWidget {
  const McpServersPage({super.key});

  @override
  ConsumerState<McpServersPage> createState() => _McpServersPageState();
}

class _McpServersPageState extends ConsumerState<McpServersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 配置 MCP 选项卡
  final _jsonController = TextEditingController();
  final _configManager = McpConfigManager();
  String? _jsonError;
  Map<String, dynamic>? _parsedConfig;
  bool _isLoadingConfig = true;
  bool _isSaving = false;

  // 远程 MCP 服务选项卡
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, dynamic>? _configuredServers;
  bool _isLoadingRemote = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadLocalConfig();
    _loadConfiguredServers();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _isLoadingRemote) {
      _loadConfiguredServers();
    }
  }

  Future<void> _loadLocalConfig() async {
    try {
      final config = await _configManager.loadConfig();
      setState(() {
        _jsonController.text = const JsonEncoder.withIndent(
          '  ',
        ).convert(config);
        _isLoadingConfig = false;
      });
      _parseJson();
    } catch (e) {
      setState(() {
        _jsonController.text = const JsonEncoder.withIndent(
          '  ',
        ).convert({'mcpServers': {}});
        _isLoadingConfig = false;
      });
      _parseJson();
    }
  }

  Future<void> _loadConfiguredServers() async {
    final servers = await _configManager.getServers();
    setState(() {
      _configuredServers = servers;
      _isLoadingRemote = false;
    });
  }

  void _parseJson() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _jsonError = null;
        _parsedConfig = null;
      });
      return;
    }

    try {
      final parsed = json.decode(text);
      if (parsed is! Map<String, dynamic>) {
        throw const FormatException('JSON 必须是对象格式');
      }
      if (!parsed.containsKey('mcpServers')) {
        throw const FormatException('必须包含 mcpServers 字段');
      }

      setState(() {
        _parsedConfig = parsed;
        _jsonError = null;
      });
    } catch (e) {
      setState(() {
        _jsonError = 'JSON 格式错误: $e';
        _parsedConfig = null;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_parsedConfig == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await _configManager.saveConfig(_parsedConfig!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('配置已保存'),
            behavior: SnackBarBehavior.floating,
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
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _addServer(
    String serverId,
    Map<String, dynamic> serverConfig,
  ) async {
    try {
      final serverEntry = {
        'command': serverConfig['command'] ?? 'npx',
        'args': serverConfig['args'] ?? [],
        'env': serverConfig['env'] ?? {},
      };

      if (serverConfig['workingDirectory'] != null &&
          serverConfig['workingDirectory'].toString().isNotEmpty) {
        serverEntry['workingDirectory'] = serverConfig['workingDirectory'];
      }

      await _configManager.addServer(serverId, serverEntry);
      await _loadConfiguredServers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加 $serverId'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  Future<void> _removeServer(String serverId) async {
    try {
      await _configManager.removeServer(serverId);
      await _loadConfiguredServers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已移除 $serverId'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移除失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jsonController.dispose();
    _searchController.dispose();
    super.dispose();
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
          title: Text('MCP 服务器', style: theme.textTheme.headlineMedium),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '配置 MCP', icon: Icon(Icons.settings)),
              Tab(text: '远程 MCP 服务', icon: Icon(Icons.cloud)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildConfigTab(theme), _buildRemoteTab(theme)],
        ),
      ),
    );
  }

  /// 配置 MCP 选项卡 - JSON 编辑器
  Widget _buildConfigTab(ThemeData theme) {
    if (_isLoadingConfig) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 说明
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    '编辑 mcp.json 配置文件，添加或修改 MCP 服务器',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // JSON 编辑器
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _jsonError != null
                      ? theme.colorScheme.error
                      : theme.dividerColor,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: TextField(
                controller: _jsonController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      '{\n  "mcpServers": {\n    "server-name": {\n      "command": "npx",\n      "args": ["-y", "@package/name"]\n    }\n  }\n}',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppTheme.spacingM),
                  errorText: _jsonError,
                ),
                onChanged: (_) => _parseJson(),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // 解析结果
          if (_parsedConfig != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    '${_parsedConfig!['mcpServers'].keys.length} 个服务器已配置',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppTheme.spacingM),

          // 保存按钮
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _parsedConfig != null && !_isSaving
                  ? _saveConfig
                  : null,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? '保存中...' : '保存配置'),
            ),
          ),
        ],
      ),
    );
  }

  /// 远程 MCP 服务选项卡 - Featured 服务器
  Widget _buildRemoteTab(ThemeData theme) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    var filteredServers = _searchQuery.isEmpty
        ? FeaturedMcpServers.servers
        : FeaturedMcpServers.search(_searchQuery);

    // ★ 移动端隐藏 npx/node 命令的 MCP 服务（移动端不支持 npx/node/uvx）
    if (isMobile) {
      filteredServers = filteredServers.where((s) {
        final cmd = (s['command'] as String? ?? '').toLowerCase();
        return cmd != 'npx' && cmd != 'node' && cmd != 'uvx' && cmd != 'python';
      }).toList();
    }

    if (_isLoadingRemote) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索 MCP 服务...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              filled: true,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        // 服务列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            itemCount: filteredServers.length,
            itemBuilder: (context, index) {
              final server = filteredServers[index];
              final serverId = server['id'] as String;
              final isConfigured =
                  _configuredServers?.containsKey(serverId) ?? false;

              return _buildRemoteServerCard(
                server,
                serverId,
                isConfigured,
                theme,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建远程服务卡片
  Widget _buildRemoteServerCard(
    Map<String, dynamic> server,
    String serverId,
    bool isConfigured,
    ThemeData theme,
  ) {
    final name = server['name'] as String? ?? serverId;
    final description = server['description'] as String? ?? '';
    final env = server['env'] as Map<String, dynamic>? ?? {};
    final needsEnv = env.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(server['category'] as String?),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // 添加/移除按钮
                _buildActionButton(serverId, server, isConfigured, theme),
              ],
            ),

            // 环境变量提示
            if (needsEnv) ...[
              const SizedBox(height: AppTheme.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.vpn_key,
                      size: 14,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '需要配置环境变量',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建添加/移除按钮
  Widget _buildActionButton(
    String serverId,
    Map<String, dynamic> serverConfig,
    bool isConfigured,
    ThemeData theme,
  ) {
    if (isConfigured) {
      return OutlinedButton.icon(
        onPressed: () => _removeServer(serverId),
        icon: const Icon(Icons.remove, size: 18),
        label: const Text('移除'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error),
        ),
      );
    } else {
      return FilledButton.icon(
        onPressed: () => _addServer(serverId, serverConfig),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('添加'),
      );
    }
  }

  /// 获取分类图标
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'filesystem':
        return Icons.folder;
      case 'developer':
        return Icons.code;
      case 'database':
        return Icons.storage;
      case 'communication':
        return Icons.chat;
      case 'productivity':
        return Icons.task_alt;
      case 'api':
        return Icons.api;
      default:
        return Icons.extension;
    }
  }
}
