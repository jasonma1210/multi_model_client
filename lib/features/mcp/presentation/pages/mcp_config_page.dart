import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mcp_config_manager.dart';
import '../../../../core/protocols/mcp_server_manager.dart';

/// MCP 配置管理页面
/// 提供完整的 MCP 服务配置功能
class McpConfigPage extends ConsumerStatefulWidget {
  const McpConfigPage({super.key});

  @override
  ConsumerState<McpConfigPage> createState() => _McpConfigPageState();
}

class _McpConfigPageState extends ConsumerState<McpConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // JSON 编辑器相关
  late TextEditingController _jsonController;
  bool _isJsonValid = true;
  String? _jsonError;
  bool _isSaving = false;

  // 已配置的服务器
  Map<String, dynamic> _configuredServers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _jsonController = TextEditingController();
    _loadConfiguredServers();
    _loadJsonContent();
  }

  Future<void> _loadConfiguredServers() async {
    final configManager = McpConfigManager();
    final servers = await configManager.getServers();
    setState(() {
      _configuredServers = servers;
      _isLoading = false;
    });
  }

  Future<void> _loadJsonContent() async {
    final configManager = McpConfigManager();
    final content = await configManager.loadConfig();
    setState(() {
      _jsonController.text = const JsonEncoder.withIndent(
        '  ',
      ).convert(content);
      _isJsonValid = true;
      _jsonError = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _jsonController.dispose();
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
          title: const Text('MCP 服务配置'),
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
          children: [_buildConfigMcpTab(theme), _buildRemoteMcpTab(theme)],
        ),
      ),
    );
  }

  /// 第一个选项卡：配置 MCP（JSON 编辑器）
  Widget _buildConfigMcpTab(ThemeData theme) {
    return Column(
      children: [
        // JSON 编辑器说明
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '编辑 mcp.json 配置文件，添加或修改 MCP 服务器',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        // JSON 编辑器
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'mcp.json',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isJsonValid
                            ? theme.colorScheme.outline
                            : theme.colorScheme.error,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _jsonController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12),
                        border: InputBorder.none,
                        hintText: '{\n  "mcpServers": {\n    \n  }\n}',
                        hintStyle: TextStyle(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      onChanged: (value) {
                        _validateJson(value);
                      },
                    ),
                  ),
                ),

                // JSON 验证提示
                if (_jsonError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _jsonError!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 保存按钮
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isJsonValid && !_isSaving ? _saveJson : null,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSaving ? '保存中...' : '保存配置'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _validateJson(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _isJsonValid = false;
        _jsonError = '配置文件不能为空';
      });
      return;
    }

    try {
      final parsed = jsonDecode(value);
      if (parsed is! Map) {
        setState(() {
          _isJsonValid = false;
          _jsonError = '配置文件必须是 JSON 对象';
        });
        return;
      }

      setState(() {
        _isJsonValid = true;
        _jsonError = null;
      });
    } catch (e) {
      setState(() {
        _isJsonValid = false;
        _jsonError =
            'JSON 格式错误: ${e.toString().replaceAll('FormatException:', '')}';
      });
    }
  }

  Future<void> _saveJson() async {
    if (!_isJsonValid) return;

    setState(() => _isSaving = true);

    try {
      final configManager = McpConfigManager();
      final config = jsonDecode(_jsonController.text) as Map<String, dynamic>;
      await configManager.saveConfig(config);

      // 刷新已配置的服务器列表
      await _loadConfiguredServers();

      // ★★★ 同步所有服务器到数据库 ★★★
      final serverManager = McpServerManager();
      final servers = config['mcpServers'] as Map<String, dynamic>? ?? {};
      
      for (final entry in servers.entries) {
        final serverId = entry.key;
        final serverConfig = entry.value as Map<String, dynamic>;
        final command = serverConfig['command'] as String? ?? '';
        
        List<String> args = [];
        final argsRaw = serverConfig['args'];
        if (argsRaw is List) {
          args = argsRaw.map((e) => e.toString()).toList();
        }
        
        Map<String, String> envMap = {};
        final envRaw = serverConfig['env'];
        if (envRaw is Map) {
          envMap = envRaw.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
        
        try {
          await serverManager.addOrUpdateServer(
            serverId: serverId,
            name: serverConfig['name'] as String? ?? serverId,
            type: serverConfig['type'] as String? ?? (command.contains('python') ? 'python' : 'stdio'),
            command: command,
            args: args,
            env: envMap,
            isEnabled: true,
            isAutoStart: true,
            endpoint: serverConfig['endpoint'] as String?, // v0.45.0
            authToken: serverConfig['authToken'] as String?, // v0.45.0
          );
          debugPrint('[McpConfig] ✅ DB 同步完成: $serverId');
        } catch (e) {
          debugPrint('[McpConfig] ⚠️ DB 同步失败: $serverId - $e');
        }
      }

      // 自动测试所有服务器连接
      final results = <String, bool>{};
      
      for (final entry in servers.entries) {
        final serverId = entry.key;
        try {
          debugPrint('[McpConfig] 测试服务器: $serverId');
          final client = await serverManager.startServer(serverId);
          results[serverId] = client != null;
          if (client != null) {
            debugPrint('[McpConfig] ✅ 服务器可��: $serverId');
          }
        } catch (e) {
          results[serverId] = false;
          debugPrint('[McpConfig] ❌ 服务器连接失败: $serverId - $e');
        }
      }
      
      final successCount = results.values.where((v) => v).length;
      final totalCount = servers.length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(totalCount > 0 
                ? '配置已保存，$successCount/$totalCount 个服务连接成功'
                : '配置已保存'),
            backgroundColor: successCount == totalCount && totalCount > 0
                ? Colors.green
                : successCount > 0 
                    ? Colors.orange 
                    : Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
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

  /// 第二个选项卡：远程 MCP 服务
  Widget _buildRemoteMcpTab(ThemeData theme) {
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

    return Column(
      children: [
        // v0.45.0: 添加自定义 HTTP MCP 服务按钮
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddHttpServerDialog(theme),
              icon: const Icon(Icons.add_link),
              label: const Text('添加 Streamable HTTP MCP 服务'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索 MCP 服务（支持 mcp.so）...',
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onSubmitted: (value) => _searchRemoteMcp(value),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: '从 mcp.so 搜索',
                onPressed: () => _searchRemoteMcp(_searchQuery),
              ),
            ],
          ),
        ),

        // Mobile warning
        if (isMobile)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_android, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('移动端仅支持内置类型服务，npx/node 命令不可用', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

        // 服务器列表
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredServers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '未找到匹配的 MCP 服务',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredServers.length,
                  itemBuilder: (context, index) {
                    final server = filteredServers[index];
                    final serverId = server['id'] as String;
                    final isConfigured = _configuredServers.containsKey(
                      serverId,
                    );

                    return _buildServerCard(
                      serverId: serverId,
                      server: server,
                      theme: theme,
                      isConfigured: isConfigured,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 构建服务器卡片
  Widget _buildServerCard({
    required String serverId,
    required Map<String, dynamic> server,
    required ThemeData theme,
    required bool isConfigured,
  }) {
    final name = server['name'] as String? ?? serverId;
    final description = server['description'] as String? ?? '';
    // 安全解析 env 字段
    Map<String, dynamic> env = {};
    final envRaw = server['env'];
    if (envRaw is Map) {
      env = Map<String, dynamic>.from(envRaw);
    }
    final needsEnv = env.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isConfigured
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(server['category'] as String?),
                    color: isConfigured
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
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
    Map<String, dynamic> server,
    bool isConfigured,
    ThemeData theme,
  ) {
    if (isConfigured) {
      // 已配置：显示红色移除按钮
      return ElevatedButton.icon(
        onPressed: () => _removeServer(serverId, theme),
        icon: const Icon(Icons.remove, size: 18),
        label: const Text('移除'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
        ),
      );
    } else {
      // 未配置：显示蓝色添加按钮
      return ElevatedButton.icon(
        onPressed: () => _addServer(serverId, server, theme),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('添加'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      );
    }
  }

  /// 添加服务器到 mcp.json
  Future<void> _addServer(
    String serverId,
    Map<String, dynamic> server,
    ThemeData theme,
  ) async {
    try {
      final configManager = McpConfigManager();

      // 构建服务器配置
      final serverEntry = <String, dynamic>{
        'command': server['command'] ?? 'npx',
        'args': server['args'] ?? <String>[],
      };

      // 添加环境变量（空值，用户需要自行配置）
      if (server['env'] != null && (server['env'] as Map).isNotEmpty) {
        final env = <String, String>{};
        for (final key in (server['env'] as Map).keys) {
          env[key as String] = '';
        }
        serverEntry['env'] = env;
      }

      // 如果需要工作目录
      if (server['workingDirectory'] != null &&
          server['workingDirectory'].toString().isNotEmpty) {
        serverEntry['workingDirectory'] = server['workingDirectory'];
      }

      await configManager.addServer(serverId, serverEntry);

      // 刷新列表和 JSON 编辑器
      await _loadConfiguredServers();
      await _loadJsonContent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已添加 $serverId 到 MCP 配置'),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败: $e'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  /// 从 mcp.json 移除服务器
  Future<void> _removeServer(String serverId, ThemeData theme) async {
    try {
      final configManager = McpConfigManager();
      await configManager.removeServer(serverId);

      // 刷新列表和 JSON 编辑器
      await _loadConfiguredServers();
      await _loadJsonContent();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已从 MCP 配置中移除 $serverId'),
            backgroundColor: theme.colorScheme.secondary,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移除失败: $e'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
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

  /// 从 mcp.so 搜索远程 MCP 服务
  Future<void> _searchRemoteMcp(String query) async {
    if (query.trim().isEmpty) return;
    
    try {
      final results = await FeaturedMcpServers.searchMcpSo(query.trim());
      
      if (mounted && results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('从 mcp.so 找到 ${results.length} 个结果'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('mcp.so 未找到匹配结果'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('[McpConfig] mcp.so 搜索失败: $e');
    }
  }

  /// v0.45.0: 添加自定义 Streamable HTTP MCP 服务对话框
  Future<void> _showAddHttpServerDialog(ThemeData theme) async {
    final nameController = TextEditingController();
    final endpointController = TextEditingController();
    final tokenController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('添加 HTTP MCP 服务'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '服务名称',
                      hintText: '例如：远程文件系统',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: endpointController,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint URL',
                      hintText: 'https://api.example.com/mcp',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tokenController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Auth Token（可选）',
                      hintText: 'Bearer Token',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('保存并测试'),
              ),
            ],
          ),
        ) ??
        false;

    // 在 dispose 之前读取值
    final name = nameController.text.trim().isEmpty
        ? 'http-mcp-${DateTime.now().millisecondsSinceEpoch}'
        : nameController.text.trim();
    final endpoint = endpointController.text.trim();
    final token = tokenController.text.trim().isEmpty
        ? null
        : tokenController.text.trim();

    nameController.dispose();
    endpointController.dispose();
    tokenController.dispose();

    if (!confirmed) return;

    if (endpoint.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Endpoint URL 不能为空')),
      );
      return;
    }

    final serverId = 'http-${DateTime.now().millisecondsSinceEpoch}';
    final serverManager = McpServerManager();

    try {
      await serverManager.addOrUpdateServer(
        serverId: serverId,
        name: name,
        type: 'streamable_http',
        command: '', // HTTP 类型不需要 command
        args: const [],
        env: const {},
        isEnabled: true,
        isAutoStart: false,
        endpoint: endpoint,
        authToken: token,
      );

      // 立即测试连接
      final client = await serverManager.startServer(serverId);
      if (!mounted) return;
      if (client != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('✅ $name 连接成功'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadConfiguredServers();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ $name 连接失败，请检查 Endpoint 和 Token'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('添加失败: $e')),
      );
    }
  }
}
