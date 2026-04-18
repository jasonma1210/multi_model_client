import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'mcp_protocol.dart';
import 'mcp_server.dart';

/// MCP 连接状态
enum MCPConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// MCP 连接事件
class MCPConnectionEvent {
  final String serverId;
  final MCPConnectionStatus status;
  final String? error;
  final DateTime timestamp;

  MCPConnectionEvent({
    required this.serverId,
    required this.status,
    this.error,
    required this.timestamp,
  });
}

/// MCP 消息
class MCPMessage {
  final String method;
  final Map<String, dynamic>? params;
  final DateTime timestamp;

  MCPMessage({
    required this.method,
    this.params,
    required this.timestamp,
  });
}

/// MCP 连接类
class MCPConnection {
  final String serverId;
  final String serverUrl;
  MCPConnectionStatus _status;
  WebSocketChannel? _channel;
  final StreamController<MCPMessage> _messageController = StreamController<MCPMessage>.broadcast();
  final StreamController<MCPConnectionEvent> _statusController = StreamController<MCPConnectionEvent>.broadcast();
  final Map<String, Completer<MCPResponse>> _pendingRequests = {};
  MCPClient? _client;
  List<MCPTool>? _availableTools;
  List<MCPResource>? _availableResources;
  List<MCPPrompt>? _availablePrompts;

  MCPConnection({
    required this.serverId,
    required this.serverUrl,
  }) : _status = MCPConnectionStatus.disconnected;

  /// 连接状态
  MCPConnectionStatus get status => _status;

  /// 消息流
  Stream<MCPMessage> get messageStream => _messageController.stream;

  /// 状态流
  Stream<MCPConnectionEvent> get statusStream => _statusController.stream;

  /// 获取客户端
  MCPClient? get client => _client;

  /// 获取可用工具
  List<MCPTool>? get availableTools => _availableTools;

  /// 获取可用资源
  List<MCPResource>? get availableResources => _availableResources;

  /// 获取可用提示
  List<MCPPrompt>? get availablePrompts => _availablePrompts;

  /// 连接到 MCP 服务器
  Future<void> connect() async {
    if (_status == MCPConnectionStatus.connected || _status == MCPConnectionStatus.connecting) {
      return;
    }

    try {
      _updateStatus(MCPConnectionStatus.connecting);

      // 创建 WebSocket 连接
      if (serverUrl.startsWith('ws://') || serverUrl.startsWith('wss://')) {
        _channel = IOWebSocketChannel.connect(serverUrl);
      } else if (serverUrl.startsWith('http://') || serverUrl.startsWith('https://')) {
        // 将 HTTP URL 转换为 WebSocket URL
        final wsUrl = serverUrl.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://');
        _channel = IOWebSocketChannel.connect(wsUrl);
      } else {
        throw ArgumentError('Invalid server URL: $serverUrl');
      }

      // 监听消息
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // 创建 MCP 客户端
      _client = MCPClient(
        clientInfo: MCPClientInfo(
          name: 'LLM Studio',
          version: '1.0.0',
        ),
        sendRequest: _sendRequest,
      );

      // 初始化连接
      await _client!.initialize();

      // 获取可用工具、资源和提示
      await _refreshCapabilities();

      _updateStatus(MCPConnectionStatus.connected);
    } catch (e) {
      _updateStatus(MCPConnectionStatus.error, error: e.toString());
      throw MCPConnectionException('Failed to connect: $e');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _channel?.sink.close();
    _channel = null;
    _client = null;
    _availableTools = null;
    _availableResources = null;
    _availablePrompts = null;
    _updateStatus(MCPConnectionStatus.disconnected);
  }

  /// 调用工具
  Future<MCPToolResult> callTool(String toolName, Map<String, dynamic> arguments) async {
    if (_client == null || !_client!.isInitialized) {
      throw StateError('Client not connected');
    }
    return await _client!.callTool(toolName, arguments);
  }

  /// 列出资源
  Future<List<MCPResource>> listResources() async {
    if (_client == null || !_client!.isInitialized) {
      throw StateError('Client not connected');
    }
    return await _client!.listResources();
  }

  /// 读取资源
  Future<MCPResourceContent> readResource(String uri) async {
    if (_client == null || !_client!.isInitialized) {
      throw StateError('Client not connected');
    }
    return await _client!.readResource(uri);
  }

  /// 列出提示
  Future<List<MCPPrompt>> listPrompts() async {
    if (_client == null || !_client!.isInitialized) {
      throw StateError('Client not connected');
    }
    return await _client!.listPrompts();
  }

  /// 获取提示
  Future<List<MCPContent>> getPrompt(String name, Map<String, String> arguments) async {
    if (_client == null || !_client!.isInitialized) {
      throw StateError('Client not connected');
    }
    return await _client!.getPrompt(name, arguments);
  }

  /// 订阅提示
  Stream<MCPMessage> subscribePrompts() async* {
    await for (final message in _messageController.stream) {
      if (message.method.startsWith('prompts/')) {
        yield message;
      }
    }
  }

  /// 发送请求
  Future<String> _sendRequest(String request) async {
    if (_channel == null) {
      throw StateError('WebSocket not connected');
    }

    final requestJson = jsonDecode(request) as Map<String, dynamic>;
    final id = requestJson['id'] as String?;

    if (id != null) {
      final completer = Completer<MCPResponse>();
      _pendingRequests[id] = completer;

      _channel!.sink.add(request);

      final response = await completer.future;
      return jsonEncode(response.toJson());
    } else {
      // 通知消息，不需要等待响应
      _channel!.sink.add(request);
      return '{}';
    }
  }

  /// 处理收到的消息
  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;

      // 检查是否是响应
      if (json.containsKey('id') && json.containsKey('result')) {
        final id = json['id'] as String;
        final completer = _pendingRequests.remove(id);
        if (completer != null) {
          completer.complete(MCPResponse.fromJson(json));
        }
      }
      // 检查是否是错误响应
      else if (json.containsKey('id') && json.containsKey('error')) {
        final id = json['id'] as String;
        final completer = _pendingRequests.remove(id);
        if (completer != null) {
          completer.complete(MCPResponse.fromJson(json));
        }
      }
      // 通知消息
      else if (json.containsKey('method') && !json.containsKey('id')) {
        _messageController.add(MCPMessage(
          method: json['method'] as String,
          params: json['params'] as Map<String, dynamic>?,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      debugPrint('Error parsing MCP message: $e');
    }
  }

  /// 处理错误
  void _onError(error) {
    debugPrint('MCP WebSocket error: $error');
    _updateStatus(MCPConnectionStatus.error, error: error.toString());
  }

  /// 处理连接关闭
  void _onDone() {
    _updateStatus(MCPConnectionStatus.disconnected);
  }

  /// 更新状态
  void _updateStatus(MCPConnectionStatus status, {String? error}) {
    _status = status;
    _statusController.add(MCPConnectionEvent(
      serverId: serverId,
      status: status,
      error: error,
      timestamp: DateTime.now(),
    ));
  }

  /// 刷新能力列表
  Future<void> _refreshCapabilities() async {
    if (_client == null) return;

    try {
      _availableTools = await _client!.listTools();
    } catch (e) {
      debugPrint('Failed to list tools: $e');
    }

    try {
      _availableResources = await _client!.listResources();
    } catch (e) {
      debugPrint('Failed to list resources: $e');
    }

    try {
      _availablePrompts = await _client!.listPrompts();
    } catch (e) {
      debugPrint('Failed to list prompts: $e');
    }
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}

/// MCP 连接管理器
class MCPConnectionManager {
  final Map<String, MCPConnection> _connections = {};
  final StreamController<MCPConnectionEvent> _globalStatusController = StreamController<MCPConnectionEvent>.broadcast();

  /// 全局状态流
  Stream<MCPConnectionEvent> get globalStatusStream => _globalStatusController.stream;

  /// 连接到 MCP 服务器
  Future<MCPConnection> connect(String serverId, String serverUrl) async {
    // 如果已存在连接，先断开
    if (_connections.containsKey(serverId)) {
      await _connections[serverId]!.disconnect();
    }

    // 创建新连接
    final connection = MCPConnection(
      serverId: serverId,
      serverUrl: serverUrl,
    );

    // 监听状态变化
    connection.statusStream.listen((event) {
      _globalStatusController.add(event);
    });

    // 连接
    await connection.connect();

    _connections[serverId] = connection;
    return connection;
  }

  /// 断开指定服务器的连接
  Future<void> disconnect(String serverId) async {
    final connection = _connections[serverId];
    if (connection != null) {
      await connection.disconnect();
      _connections.remove(serverId);
    }
  }

  /// 断开所有连接
  Future<void> disconnectAll() async {
    for (final connection in _connections.values) {
      await connection.disconnect();
    }
    _connections.clear();
  }

  /// 获取连接
  MCPConnection? getConnection(String serverId) {
    return _connections[serverId];
  }

  /// 获取所有连接
  List<MCPConnection> getAllConnections() {
    return _connections.values.toList();
  }

  /// 调用工具
  Future<MCPToolResult> callTool(
    String serverId,
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    final connection = _connections[serverId];
    if (connection == null) {
      throw StateError('Server not connected: $serverId');
    }
    return await connection.callTool(toolName, arguments);
  }

  /// 列出资源
  Future<List<MCPResource>> listResources(String serverId) async {
    final connection = _connections[serverId];
    if (connection == null) {
      throw StateError('Server not connected: $serverId');
    }
    return await connection.listResources();
  }

  /// 读取资源
  Future<MCPResourceContent> readResource(String serverId, String uri) async {
    final connection = _connections[serverId];
    if (connection == null) {
      throw StateError('Server not connected: $serverId');
    }
    return await connection.readResource(uri);
  }

  /// 列出所有可用工具（跨所有连接）
  Future<Map<String, List<MCPTool>>> listAllTools() async {
    final result = <String, List<MCPTool>>{};
    for (final entry in _connections.entries) {
      if (entry.value.status == MCPConnectionStatus.connected) {
        result[entry.key] = entry.value.availableTools ?? [];
      }
    }
    return result;
  }

  /// 释放资源
  Future<void> dispose() async {
    await disconnectAll();
    _globalStatusController.close();
  }
}

/// MCP 连接异常
class MCPConnectionException implements Exception {
  final String message;

  MCPConnectionException(this.message);

  @override
  String toString() => 'MCPConnectionException: $message';
}
