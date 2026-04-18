import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../protocols/mcp_connection_manager.dart';
import '../protocols/mcp_protocol.dart' show MCPTool, MCPToolResult, MCPContent;
import '../protocols/mcp_server_manager.dart';
import 'mcp_config_manager.dart';

/// MCP 工具调用信息
class MCPToolCall {
  final String id;
  final String serverId;
  final String serverName;
  final String toolName;
  final Map<String, dynamic> arguments;
  final DateTime timestamp;
  MCPToolResult? result;
  bool isLoading;
  String? error;

  MCPToolCall({
    required this.id,
    required this.serverId,
    required this.serverName,
    required this.toolName,
    required this.arguments,
    required this.timestamp,
    this.result,
    this.isLoading = false,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serverId': serverId,
    'serverName': serverName,
    'toolName': toolName,
    'arguments': arguments,
    'timestamp': timestamp.toIso8601String(),
    'result': result?.toJson(),
    'isLoading': isLoading,
    'error': error,
  };
}

/// MCP 服务管理器
/// 统一管理所有 MCP 连接，提供工具调用接口
class MCPServiceManager {
  static final MCPServiceManager _instance = MCPServiceManager._internal();
  factory MCPServiceManager() => _instance;
  MCPServiceManager._internal();

  final MCPConnectionManager _connectionManager = MCPConnectionManager();
  final McpServerManager _serverManager = McpServerManager();
  final Map<String, MCPToolCall> _activeToolCalls = {};
  final _toolCallsController = StreamController<List<MCPToolCall>>.broadcast();
  
  /// 当前会话启用的 MCP 服务器
  final Map<String, Set<String>> _sessionEnabledServers = {};
  
  /// 是否已初始化
  bool _isInitialized = false;
  
  /// 初始化 MCP 服务管理器
  Future<void> initialize() async {
    if (_isInitialized) return;
    debugPrint('[MCPServiceManager] 正在初始化...');
    
    // 加载 mcp.json 配置
    final configManager = McpConfigManager();
    final servers = await configManager.getServers();
    
    debugPrint('[MCPServiceManager] 从 mcp.json 加载了 ${servers.length} 个服务器配置');
    
    // 将配置写入数据库（供 McpServerManager 使用）
    for (final entry in servers.entries) {
      final serverId = entry.key;
      final config = entry.value as Map<String, dynamic>;
      
      // 解析 args（可能是 List 或字符串）
      List<String> args;
      if (config['args'] is List) {
        args = List<String>.from(config['args']);
      } else if (config['args'] is String) {
        try {
          args = List<String>.from(jsonDecode(config['args']));
        } catch (_) {
          args = [];
        }
      } else {
        args = [];
      }
      
      // 解析 env（可能是 Map 或字符串）
      Map<String, String> env;
      if (config['env'] is Map) {
        env = Map<String, String>.from(config['env'].map((k, v) => MapEntry(k.toString(), v.toString())));
      } else if (config['env'] is String) {
        try {
          final decoded = jsonDecode(config['env']) as Map<String, dynamic>;
          env = decoded.map((k, v) => MapEntry(k, v.toString()));
        } catch (_) {
          env = {};
        }
      } else {
        env = {};
      }
      
      // 写入数据库
      await _serverManager.addOrUpdateServer(
        serverId: serverId,
        name: config['name'] ?? serverId,
        type: 'stdio',
        command: config['command'] ?? 'npx',
        args: args,
        env: env,
        isEnabled: false,
        isAutoStart: false,
      );
    }
    
    // 初始化内置服务器
    await _serverManager.initialize();
    _isInitialized = true;
    debugPrint('[MCPServiceManager] 初始化完成');
  }
  
  /// 已连接的 MCP 服务器
  final Set<String> _connectedServerIds = {};

  /// 工具调用流
  Stream<List<MCPToolCall>> get toolCallsStream => _toolCallsController.stream;
  
  /// 全局状态流
  Stream<MCPConnectionEvent> get globalStatusStream => _connectionManager.globalStatusStream;

  /// 获取当前会话启用的 MCP 服务器
  Set<String> getEnabledServers(String sessionId) {
    return _sessionEnabledServers[sessionId] ?? {};
  }

  /// 启用 MCP 服务器
  Future<void> enableServer(String sessionId, String serverId) async {
    try {
      // 确保已初始化
      await initialize();
      
      debugPrint('[MCPServiceManager] 启用服务器: $serverId');
      
      // 使用 McpServerManager 启动 stdio 模式的服务器
      final client = await _serverManager.startServer(serverId);
      if (client != null) {
        _connectedServerIds.add(serverId);
        _sessionEnabledServers[sessionId] ??= {};
        _sessionEnabledServers[sessionId]!.add(serverId);
        debugPrint('[MCPServiceManager] 服务器已启动: $serverId');
      } else {
        debugPrint('[MCPServiceManager] 服务器启动失败: $serverId');
      }
    } catch (e) {
      debugPrint('[MCPServiceManager] 连接服务器失败: $e');
      rethrow;
    }
  }

  /// 禁用 MCP 服务器
  Future<void> disableServer(String sessionId, String serverId) async {
    _sessionEnabledServers[sessionId]?.remove(serverId);
    if (_sessionEnabledServers[sessionId]?.isEmpty ?? true) {
      _sessionEnabledServers.remove(sessionId);
    }
    // 如果没有会话使用此服务器，停止服务器
    bool isUsed = _sessionEnabledServers.values.any((set) => set.contains(serverId));
    if (!isUsed) {
      _connectedServerIds.remove(serverId);
      await _serverManager.stopServer(serverId);
    }
  }

  /// 获取服务器状态
  MCPConnectionStatus? getServerStatus(String serverId) {
    return _connectionManager.getConnection(serverId)?.status;
  }

  /// 获取所有可用工具（跨所有已连接服务器）
  Future<Map<String, List<MCPTool>>> getAvailableTools(String sessionId) async {
    // 确保已初始化
    await initialize();
    
    final enabledIds = _sessionEnabledServers[sessionId] ?? {};
    final allTools = <String, List<MCPTool>>{};
    
    for (final serverId in enabledIds) {
      // 使用 McpServerManager 获取工具
      final tools = await _serverManager.getServerTools(serverId);
      if (tools.isNotEmpty) {
        allTools[serverId] = tools;
      }
    }
    
    return allTools;
  }

  /// 调用 MCP 工具
  Future<MCPToolCall> callTool({
    required String sessionId,
    required String serverId,
    required String serverName,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    final toolCall = MCPToolCall(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: serverId,
      serverName: serverName,
      toolName: toolName,
      arguments: arguments,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    
    _activeToolCalls[toolCall.id] = toolCall;
    _notifyToolCallsChanged();
    
    try {
      debugPrint('[MCPServiceManager] 调用工具: $toolName (server: $serverId)');
      // 使用 McpServerManager 调用工具
      final result = await _serverManager.callTool(serverId, toolName, arguments);
      
      toolCall.result = result;
      toolCall.isLoading = false;
      debugPrint('[MCPServiceManager] 工具调用成功: ${toolName}, 结果: ${result.content.length} items');
    } catch (e) {
      debugPrint('[MCPServiceManager] 工具调用失败: $e');
      toolCall.error = e.toString();
      toolCall.isLoading = false;
    }
    
    _notifyToolCallsChanged();
    return toolCall;
  }

  /// 解析文本中的工具调用并执行
  /// 支持 JSON 格式的工具调用
  Future<List<MCPToolCall>> parseAndExecuteTools({
    required String sessionId,
    required String text,
  }) async {
    final results = <MCPToolCall>[];
    final availableTools = await getAvailableTools(sessionId);
    
    if (availableTools.isEmpty) {
      return results;
    }
    
    // 尝试从文本中解析 JSON 工具调用
    // 格式: {"tool": "name", "args": {...}} 或 <tool_call>...</tool_call>
    final toolCallPatterns = [
      // JSON 格式
      RegExp(r'\{[^{}]*"tool"\s*:\s*"([^"]+)"[^{}]*"args"\s*:\s*(\{[^}]*\})[^}]*\}'),
      // XML 格式
      RegExp(r'<tool_call>\s*<name>([^<]+)</name>\s*<args>([^<]+)</args>\s*</tool_call>', caseSensitive: false),
    ];
    
    for (final pattern in toolCallPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        String? toolName;
        Map<String, dynamic>? args;
        
        if (pattern == toolCallPatterns[0]) {
          // JSON 格式
          toolName = match.group(1);
          final argsStr = match.group(2);
          if (argsStr != null) {
            try {
              args = jsonDecode(argsStr) as Map<String, dynamic>;
            } catch (_) {}
          }
        } else {
          // XML 格式
          toolName = match.group(1)?.trim();
          final argsStr = match.group(2)?.trim();
          if (argsStr != null) {
            try {
              args = jsonDecode(argsStr) as Map<String, dynamic>;
            } catch (_) {
              args = {'raw': argsStr};
            }
          }
        }
        
        if (toolName != null && args != null) {
          // 查找支持此工具的服务器
          for (final entry in availableTools.entries) {
            final hasTool = entry.value.any((t) => t.name == toolName);
            if (hasTool) {
              final serverId = entry.key;
              final serverName = serverId; // 简化处理
              final toolCall = await callTool(
                sessionId: sessionId,
                serverId: serverId,
                serverName: serverName,
                toolName: toolName,
                arguments: args,
              );
              results.add(toolCall);
              break;
            }
          }
        }
      }
    }
    
    return results;
  }

  /// 清理会话的工具调用记录
  void clearToolCalls(String sessionId) {
    _activeToolCalls.removeWhere((_, call) => call.timestamp.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch - 300000); // 5分钟前
    _notifyToolCallsChanged();
  }

  /// 断开所有连接
  Future<void> disconnectAll() async {
    await _connectionManager.disconnectAll();
  }

  void _notifyToolCallsChanged() {
    _toolCallsController.add(_activeToolCalls.values.toList());
  }

  void dispose() {
    _connectionManager.dispose();
    _toolCallsController.close();
  }
}

/// 全局 MCP 服务管理器实例
final mcpServiceManager = MCPServiceManager();
