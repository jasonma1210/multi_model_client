import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// MCP 配置文件管理器
/// 负责读写全局的 mcp.json 配置文件
class McpConfigManager {
  static final McpConfigManager _instance = McpConfigManager._internal();
  factory McpConfigManager() => _instance;
  McpConfigManager._internal();

  File? _configFile;
  Map<String, dynamic>? _cachedConfig;

  /// 获取配置文件路径
  Future<File> get configFile async {
    if (_configFile != null) return _configFile!;
    
    final dir = await getApplicationSupportDirectory();
    _configFile = File('${dir.path}/mcp.json');
    
    // 如果文件不存在，创建默认配置
    if (!await _configFile!.exists()) {
      await _configFile!.writeAsString(jsonEncode({'mcpServers': {}}));
    }
    
    return _configFile!;
  }

  /// 加载配置文件
  Future<Map<String, dynamic>> loadConfig() async {
    try {
      final file = await configFile;
      final content = await file.readAsString();
      final parsed = jsonDecode(content);
      _cachedConfig = parsed is Map<String, dynamic> ? parsed : {'mcpServers': {}};
      return _cachedConfig!;
    } catch (e) {
      debugPrint('加载 MCP 配置失败: $e');
      _cachedConfig = {'mcpServers': {}};
      return _cachedConfig!;
    }
  }

  /// 保存配置文件
  Future<void> saveConfig(Map<String, dynamic> config) async {
    try {
      final file = await configFile;
      await file.writeAsString(jsonEncode(config));
      _cachedConfig = config;
    } catch (e) {
      debugPrint('保存 MCP 配置失败: $e');
    }
  }

  /// 获取所有已配置的服务器
  Future<Map<String, dynamic>> getServers() async {
    final config = await loadConfig();
    return config['mcpServers'] is Map ? Map<String, dynamic>.from(config['mcpServers']) : {};
  }
  
  /// 获取所有已配置的服务器（getServers 的别名）
  Future<Map<String, dynamic>> getConfiguredServers() => getServers();

  /// 添加服务器配置
  Future<void> addServer(String serverId, Map<String, dynamic> serverConfig) async {
    final config = await loadConfig();
    final servers = config['mcpServers'] is Map ? Map<String, dynamic>.from(config['mcpServers']) : {};
    
    servers[serverId] = serverConfig;
    config['mcpServers'] = servers;
    
    await saveConfig(config);
    debugPrint('[McpConfigManager] 添加服务器: $serverId');
  }

  /// 移除服务器配置
  Future<void> removeServer(String serverId) async {
    final config = await loadConfig();
    final servers = config['mcpServers'] is Map ? Map<String, dynamic>.from(config['mcpServers']) : {};
    
    servers.remove(serverId);
    config['mcpServers'] = servers;
    
    await saveConfig(config);
    debugPrint('[McpConfigManager] 移除服务器: $serverId');
  }

  /// 检查服务器是否已配置
  Future<bool> hasServer(String serverId) async {
    final servers = await getServers();
    return servers.containsKey(serverId);
  }

  /// 获取服务器配置
  Future<Map<String, dynamic>?> getServer(String serverId) async {
    final servers = await getServers();
    return servers[serverId] as Map<String, dynamic>?;
  }

  /// 更新服务器配置
  Future<void> updateServer(String serverId, Map<String, dynamic> serverConfig) async {
    final config = await loadConfig();
    final servers = config['mcpServers'] is Map ? Map<String, dynamic>.from(config['mcpServers']) : {};
    
    if (servers.containsKey(serverId)) {
      servers[serverId] = serverConfig;
      config['mcpServers'] = servers;
      await saveConfig(config);
    }
  }

  /// 清除缓存，强制重新加载
  void clearCache() {
    _cachedConfig = null;
  }
}

/// 流行的 MCP 服务器模板
class FeaturedMcpServers {
  static const List<Map<String, dynamic>> servers = [
    // 文件系统
    {
      'id': 'filesystem',
      'name': '文件系统',
      'description': '访问和管理本地文件系统',
      'category': 'filesystem',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-filesystem'],
      'env': {},
      'workingDirectory': '',
    },
    // GitHub
    {
      'id': 'github',
      'name': 'GitHub',
      'description': 'GitHub 仓库管理、PR、Issue 操作',
      'category': 'developer',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-github'],
      'env': {'GITHUB_PERSONAL_ACCESS_TOKEN': ''},
    },
    // 顺序思考
    {
      'id': 'sequential-thinking',
      'name': '顺序思考',
      'description': '使用结构化思考模式解决问题',
      'category': 'productivity',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-sequential-thinking'],
      'env': {},
    },
    // 高德地图
    {
      'id': 'amap-maps',
      'name': '高德地图',
      'description': '地图服务、路径规划、POI搜索',
      'category': 'api',
      'command': 'npx',
      'args': ['-y', '@amap/amap-maps-mcp-server'],
      'env': {'AMAP_MAPS_API_KEY': ''},
    },
    // Slack
    {
      'id': 'slack',
      'name': 'Slack',
      'description': '发送消息到 Slack 频道',
      'category': 'communication',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-slack'],
      'env': {'SLACK_BOT_TOKEN': '', 'SLACK_TEAM_ID': ''},
    },
    // PostgreSQL
    {
      'id': 'postgres',
      'name': 'PostgreSQL',
      'description': '连接 PostgreSQL 数据库',
      'category': 'database',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-postgres'],
      'env': {'POSTGRES_CONNECTION_STRING': ''},
    },
    // SQLite
    {
      'id': 'sqlite',
      'name': 'SQLite',
      'description': '连接 SQLite 数据库',
      'category': 'database',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-sqlite'],
      'env': {'SQLITE_DB_PATH': ''},
    },
    // Puppeteer
    {
      'id': 'puppeteer',
      'name': '浏览器自动化',
      'description': '使用 Puppeteer 控制浏览器',
      'category': 'developer',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-puppeteer'],
      'env': {},
    },
    // Brave Search
    {
      'id': 'brave-search',
      'name': 'Brave 搜索',
      'description': '使用 Brave 进行网络搜索',
      'category': 'api',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-brave-search'],
      'env': {'BRAVE_API_KEY': ''},
    },
    // Fetch / HTTP
    {
      'id': 'fetch',
      'name': 'HTTP 请求',
      'description': '发送 HTTP 请求获取网页内容',
      'category': 'developer',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-fetch'],
      'env': {},
    },
    // Google Maps
    {
      'id': 'google-maps',
      'name': 'Google 地图',
      'description': 'Google 地图服务、路径规划',
      'category': 'api',
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-google-maps'],
      'env': {'GOOGLE_MAPS_API_KEY': ''},
    },
    // Notion
    {
      'id': 'notion',
      'name': 'Notion',
      'description': '连接 Notion 工作区',
      'category': 'productivity',
      'command': 'npx',
      'args': ['-y', '@notionhq/assistant-mcp-server'],
      'env': {'NOTION_API_KEY': ''},
    },
  ];

  /// 按类别分组
  static Map<String, List<Map<String, dynamic>>> getGroupedByCategory() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final server in servers) {
      final category = server['category'] as String;
      grouped.putIfAbsent(category, () => []).add(server);
    }
    return grouped;
  }

  /// 搜索服务器
  static List<Map<String, dynamic>> search(String query) {
    if (query.isEmpty) return servers;
    final lowerQuery = query.toLowerCase();
    return servers.where((s) {
      return (s['name'] as String).toLowerCase().contains(lowerQuery) ||
             (s['description'] as String).toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 从 mcp.so 搜索远程 MCP 服务
  /// API: https://mcp.so/api/servers?q=query
  static Future<List<Map<String, dynamic>>> searchMcpSo(String query) async {
    try {
      final url = Uri.https('mcp.so', '/api/servers', {'q': query, 'limit': '20'});
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['servers'] is List) {
          return (data['servers'] as List).map((s) => {
            'id': s['slug'] ?? s['id'] ?? '',
            'name': s['name'] ?? '',
            'description': s['description'] ?? '',
            'category': s['category'] ?? 'remote',
            'command': s['command'] ?? 'npx',
            'args': s['args'] is List ? s['args'] : [],
            'env': s['env'] is Map ? s['env'] : {},
            'source': 'mcp.so',
            'url': 'https://mcp.so/server/${s['slug'] ?? ''}',
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('[FeaturedMcpServers] mcp.so 搜索失败: $e');
    }
    return [];
  }

  /// 判断服务是否在移动端可用
  static bool isMobileCompatible(Map<String, dynamic> server) {
    final command = (server['command'] as String?) ?? '';
    return !(command == 'npx' || command == 'npx.cmd' || 
             command == 'node' || command == 'node.exe' ||
             command == 'uvx' || command == 'uvx.exe');
  }
}