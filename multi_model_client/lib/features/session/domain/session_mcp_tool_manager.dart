import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../core/storage/database.dart';
import '../../../core/storage/database_connection.dart';
import '../../../core/protocols/mcp_server_manager.dart';
import '../../../core/protocols/mcp_protocol.dart';

/// 会话MCP工具管理器
class SessionMcpToolManager {
  final AppDatabase _db = database;
  final McpServerManager _serverManager;

  SessionMcpToolManager(this._serverManager);

  /// 获取会话启用的MCP服务器ID列表
  Future<List<String>> getSessionServerIds(String sessionId) async {
    final session = await _db.getSession(sessionId);
    if (session == null) return [];

    final serverIdsJson = session.enabledMcpServerIds;
    if (serverIdsJson == null || serverIdsJson.isEmpty) return [];

    try {
      final decoded = jsonDecode(serverIdsJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      // 兼容旧格式：逗号分隔的字符串
      debugPrint('解析会话MCP服务器列表失败，尝试兼容旧格式: $e');
      return serverIdsJson
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
  }

  /// 设置会话启用的MCP服务器
  Future<void> setSessionServers(String sessionId, List<String> serverIds) async {
    await _db.updateSession(SessionsCompanion(
      id: Value(sessionId),
      enabledMcpServerIds: Value(jsonEncode(serverIds)),
    ));
  }

  /// 启用会话MCP服务器
  Future<void> enableSessionServer(String sessionId, String serverId) async {
    final serverIds = await getSessionServerIds(sessionId);
    if (!serverIds.contains(serverId)) {
      serverIds.add(serverId);
      await setSessionServers(sessionId, serverIds);
    }
  }

  /// 禁用会话MCP服务器
  Future<void> disableSessionServer(String sessionId, String serverId) async {
    final serverIds = await getSessionServerIds(sessionId);
    serverIds.remove(serverId);
    await setSessionServers(sessionId, serverIds);
  }

  /// 获取会话所有可用工具
  Future<List<SessionTool>> getSessionTools(String sessionId) async {
    final serverIds = await getSessionServerIds(sessionId);
    final List<SessionTool> sessionTools = [];

    for (final serverId in serverIds) {
      final tools = await _serverManager.getServerTools(serverId);

      for (final tool in tools) {
        sessionTools.add(SessionTool(
          serverId: serverId,
          tool: tool,
        ));
      }
    }

    return sessionTools;
  }

  /// 调用会话工具
  Future<MCPToolResult> callSessionTool(
    String sessionId,
    String serverId,
    String toolName,
    Map<String, dynamic> arguments, {
    bool requireConfirmation = false,
  }) async {
    // 检查工具是否属于该会话
    final serverIds = await getSessionServerIds(sessionId);
    if (!serverIds.contains(serverId)) {
      throw StateError('会话未启用该MCP服务器: $serverId');
    }

    return await _serverManager.callTool(
      serverId,
      toolName,
      arguments,
      requireConfirmation: requireConfirmation,
    );
  }

  /// 转换为Function Calling格式
  List<Map<String, dynamic>> toFunctionCallingFormat(List<SessionTool> tools) {
    return tools.map((sessionTool) {
      final tool = sessionTool.tool;

      return {
        'type': 'function',
        'function': {
          'name': '${sessionTool.serverId}_${tool.name}',
          'description': tool.description ?? '',
          'parameters': tool.inputSchema ?? {},
        },
      };
    }).toList();
  }

  /// 从Function Calling响应解析工具调用
  ToolCallInfo? parseToolCallInfo(Map<String, dynamic> functionCall) {
    final functionName = functionCall['name'] as String?;

    if (functionName == null) return null;

    // 解析serverId和toolName
    final parts = functionName.split('_');
    if (parts.length < 2) return null;

    final serverId = parts[0];
    final toolName = parts.sublist(1).join('_');

    final arguments = functionCall['arguments'];
    Map<String, dynamic> argsMap = {};

    if (arguments is String) {
      try {
        argsMap = jsonDecode(arguments);
      } catch (e) {
        debugPrint('解析工具参数失败: $e');
      }
    } else if (arguments is Map<String, dynamic>) {
      argsMap = arguments;
    }

    return ToolCallInfo(
      serverId: serverId,
      toolName: toolName,
      arguments: argsMap,
    );
  }
}

/// 会话工具（包含服务器来源）
class SessionTool {
  final String serverId;
  final MCPTool tool;

  SessionTool({
    required this.serverId,
    required this.tool,
  });

  /// 工具唯一标识
  String get id => '${serverId}_${tool.name}';

  /// 工具显示名称
  String get displayName => '[$serverId] ${tool.name}';
}

/// 工具调用信息
class ToolCallInfo {
  final String serverId;
  final String toolName;
  final Map<String, dynamic> arguments;

  ToolCallInfo({
    required this.serverId,
    required this.toolName,
    required this.arguments,
  });
}

/// MCP工具调用历史记录
class McpToolCallHistory {
  final String sessionId;
  final String messageId;
  final String serverId;
  final String toolName;
  final Map<String, dynamic> arguments;
  final MCPToolResult? result;
  final DateTime timestamp;
  final bool isSuccess;

  McpToolCallHistory({
    required this.sessionId,
    required this.messageId,
    required this.serverId,
    required this.toolName,
    required this.arguments,
    this.result,
    required this.timestamp,
    required this.isSuccess,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'messageId': messageId,
      'serverId': serverId,
      'toolName': toolName,
      'arguments': arguments,
      'result': result?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'isSuccess': isSuccess,
    };
  }

  factory McpToolCallHistory.fromJson(Map<String, dynamic> json) {
    return McpToolCallHistory(
      sessionId: json['sessionId'] as String,
      messageId: json['messageId'] as String,
      serverId: json['serverId'] as String,
      toolName: json['toolName'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
      result: json['result'] != null
          ? MCPToolResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSuccess: json['isSuccess'] as bool,
    );
  }
}
