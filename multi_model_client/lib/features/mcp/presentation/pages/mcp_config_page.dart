import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/mcp_config_manager.dart';
import '../../../../core/services/mcp_service_manager.dart';

/// MCP 配置管理页面
/// 提供完整的 MCP 服务配置功能
class McpConfigPage extends ConsumerStatefulWidget {
  const McpConfigPage({super.key});

  @override
  ConsumerState<McpConfigPage> createState() => _McpConfigPageState();
}

class _McpConfigPageState extends ConsumerState<McpConfigPage> with SingleTickerProviderStateMixin {
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
      _jsonController.text = const JsonEncoder.withIndent('  ').convert(content);
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
    
    return Scaffold(
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
        children: [
          _buildConfigMcpTab(theme),
          _buildRemoteMcpTab(theme),
        ],
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
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
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
                        Icon(Icons.error_outline, color: theme.colorScheme.error, size: 16),
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
        _jsonError = 'JSON 格式错误: ${e.toString().replaceAll('FormatException:', '')}';
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('配置已保存'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(milliseconds: 1500),
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
    final filteredServers = _searchQuery.isEmpty
        ? FeaturedMcpServers.servers
        : FeaturedMcpServers.search(_searchQuery);

    return Column(
      children: [
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
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
                        final isConfigured = _configuredServers.containsKey(serverId);
                        
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
                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.vpn_key, size: 14, color: theme.colorScheme.error),
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
  Widget _buildActionButton(String serverId, Map<String, dynamic> server, bool isConfigured, ThemeData theme) {
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
  Future<void> _addServer(String serverId, Map<String, dynamic> server, ThemeData theme) async {
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
      if (server['workingDirectory'] != null && server['workingDirectory'].toString().isNotEmpty) {
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
}
