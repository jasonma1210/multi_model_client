import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'mcp_protocol.dart';

/// MCP服务器实现
/// 提供工具调用、资源访问等功能
class MCPServer {
  final String name;
  final String version;
  final MCPServerCapabilities capabilities;

  final Map<String, MCPTool> _tools = {};
  final Map<String, MCPResource> _resources = {};
  final Map<String, MCPPrompt> _prompts = {};

  final StreamController<MCPNotification> _notificationController =
      StreamController.broadcast();

  MCPServer({
    required this.name,
    required this.version,
    MCPServerCapabilities? capabilities,
  }) : capabilities = capabilities ?? MCPServerCapabilities(
          resources: true,
          prompts: true,
          tools: true,
          logging: true,
        );

  /// 注册工具
  void registerTool(
    String name,
    String description,
    Map<String, dynamic> inputSchema,
    Future<MCPToolResult> Function(Map<String, dynamic> arguments) handler,
  ) {
    _tools[name] = MCPTool(
      name: name,
      description: description,
      inputSchema: inputSchema,
    );
    _toolHandlers[name] = handler;
  }

  final Map<String, Future<MCPToolResult> Function(Map<String, dynamic>)> _toolHandlers = {};

  /// 注册资源
  void registerResource(
    String uri,
    String name,
    String? description,
    String? mimeType,
    Future<MCPResourceContent> Function() handler,
  ) {
    _resources[uri] = MCPResource(
      uri: uri,
      name: name,
      description: description,
      mimeType: mimeType,
    );
    _resourceHandlers[uri] = handler;
  }

  final Map<String, Future<MCPResourceContent> Function()> _resourceHandlers = {};

  /// 注册提示
  void registerPrompt(
    String name,
    String? description,
    List<MCPPromptArgument> arguments,
    Future<List<MCPContent>> Function(Map<String, String> args) handler,
  ) {
    _prompts[name] = MCPPrompt(
      name: name,
      description: description,
      arguments: arguments,
    );
    _promptHandlers[name] = handler;
  }

  final Map<String, Future<List<MCPContent>> Function(Map<String, String>)> _promptHandlers = {};

  /// 处理请求
  Future<MCPResponse> handleRequest(MCPRequest request) async {
    try {
      final result = await _handleRequest(request);
      return MCPResponse(
        result: result,
        id: request.id!,
      );
    } on MCPError catch (e) {
      return MCPResponse(
        error: e,
        id: request.id!,
      );
    } catch (e) {
      return MCPResponse(
        error: MCPError.internalError(e.toString()),
        id: request.id!,
      );
    }
  }

  Future<Map<String, dynamic>> _handleRequest(MCPRequest request) async {
    switch (request.method) {
      case 'initialize':
        return _handleInitialize(request.params);

      case 'resources/list':
        return _handleResourcesList();

      case 'resources/read':
        return _handleResourcesRead(request.params);

      case 'prompts/list':
        return _handlePromptsList();

      case 'prompts/get':
        return _handlePromptsGet(request.params);

      case 'tools/list':
        return _handleToolsList();

      case 'tools/call':
        return _handleToolsCall(request.params);

      case 'shutdown':
        return _handleShutdown();

      default:
        throw MCPError.methodNotFound(request.method);
    }
  }

  /// 处理初始化
  Map<String, dynamic> _handleInitialize(Map<String, dynamic>? params) {
    return {
      'protocolVersion': mcpVersion,
      'capabilities': capabilities.toJson(),
      'serverInfo': {
        'name': name,
        'version': version,
      },
    };
  }

  /// 处理资源列表
  Map<String, dynamic> _handleResourcesList() {
    return {
      'resources': _resources.values.map((r) => r.toJson()).toList(),
    };
  }

  /// 处理资源读取
  Future<Map<String, dynamic>> _handleResourcesRead(Map<String, dynamic>? params) async {
    final uri = params?['uri'] as String?;
    if (uri == null) {
      throw MCPError.invalidParams('Missing uri parameter');
    }

    final handler = _resourceHandlers[uri];
    if (handler == null) {
      throw MCPError.invalidParams('Resource not found: $uri');
    }

    final content = await handler();
    return {
      'contents': [content.toJson()],
    };
  }

  /// 处理提示列表
  Map<String, dynamic> _handlePromptsList() {
    return {
      'prompts': _prompts.values.map((p) => p.toJson()).toList(),
    };
  }

  /// 处理提示获取
  Future<Map<String, dynamic>> _handlePromptsGet(Map<String, dynamic>? params) async {
    final name = params?['name'] as String?;
    if (name == null) {
      throw MCPError.invalidParams('Missing name parameter');
    }

    final handler = _promptHandlers[name];
    if (handler == null) {
      throw MCPError.invalidParams('Prompt not found: $name');
    }

    final arguments = Map<String, String>.from(params?['arguments'] ?? {});
    final messages = await handler(arguments);

    return {
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  /// 处理工具列表
  Map<String, dynamic> _handleToolsList() {
    return {
      'tools': _tools.values.map((t) => t.toJson()).toList(),
    };
  }

  /// 处理工具调用
  Future<Map<String, dynamic>> _handleToolsCall(Map<String, dynamic>? params) async {
    final name = params?['name'] as String?;
    if (name == null) {
      throw MCPError.invalidParams('Missing name parameter');
    }

    final handler = _toolHandlers[name];
    if (handler == null) {
      throw MCPError.invalidParams('Tool not found: $name');
    }

    final arguments = Map<String, dynamic>.from(params?['arguments'] ?? {});
    final result = await handler(arguments);

    return result.toJson();
  }

  /// 处理关闭
  Map<String, dynamic> _handleShutdown() {
    return {};
  }

  /// 发送通知
  void sendNotification(String method, Map<String, dynamic>? params) {
    final notification = MCPNotification(
      method: method,
      params: params,
    );
    _notificationController.add(notification);
  }

  /// 监听通知
  Stream<MCPNotification> get notifications => _notificationController.stream;

  /// 释放资源
  void dispose() {
    _notificationController.close();
    _tools.clear();
    _resources.clear();
    _prompts.clear();
    _toolHandlers.clear();
    _resourceHandlers.clear();
    _promptHandlers.clear();
  }
}

/// MCP客户端实现
/// 用于连接到MCP服务器
class MCPClient {
  final MCPClientInfo clientInfo;
  final Future<String> Function(String request) _sendRequest;

  MCPServerCapabilities? _serverCapabilities;
  MCPClientInfo? _serverInfo;
  bool _initialized = false;

  MCPClient({
    required this.clientInfo,
    required Future<String> Function(String request) sendRequest,
  }) : _sendRequest = sendRequest;

  /// 初始化连接
  Future<MCPInitializeResult> initialize() async {
    final request = MCPRequest(
      method: 'initialize',
      params: {
        'protocolVersion': mcpVersion,
        'capabilities': {},
        'clientInfo': clientInfo.toJson(),
      },
      id: _generateId(),
    );

    final responseStr = await _sendRequest(jsonEncode(request.toJson()));
    final responseJson = jsonDecode(responseStr) as Map<String, dynamic>;
    final response = MCPResponse.fromJson(responseJson);

    if (!response.isSuccess) {
      throw MCPError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = MCPInitializeResult.fromJson(response.result!);
    _serverCapabilities = result.capabilities;
    _serverInfo = result.serverInfo;
    _initialized = true;

    // 发送initialized通知
    await sendNotification('notifications/initialized');

    return result;
  }

  /// 列出可用工具
  Future<List<MCPTool>> listTools() async {
    _checkInitialized();

    final request = MCPRequest(
      method: 'tools/list',
      id: _generateId(),
    );

    final response = await _sendRequestWithResponse(request);

    return (response.result!['tools'] as List<dynamic>)
        .map((t) => MCPTool.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// 调用工具
  Future<MCPToolResult> callTool(
    String name,
    Map<String, dynamic> arguments,
  ) async {
    _checkInitialized();

    final request = MCPRequest(
      method: 'tools/call',
      params: {
        'name': name,
        'arguments': arguments,
      },
      id: _generateId(),
    );

    final response = await _sendRequestWithResponse(request);
    return MCPToolResult.fromJson(response.result!);
  }

  /// 列出可用资源
  Future<List<MCPResource>> listResources() async {
    _checkInitialized();

    final request = MCPRequest(
      method: 'resources/list',
      id: _generateId(),
    );

    final response = await _sendRequestWithResponse(request);

    return (response.result!['resources'] as List<dynamic>)
        .map((r) => MCPResource.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// 读取资源
  Future<MCPResourceContent> readResource(String uri) async {
    _checkInitialized();

    final request = MCPRequest(
      method: 'resources/read',
      params: {'uri': uri},
      id: _generateId(),
    );

    final response = await _sendRequestWithResponse(request);

    return MCPResourceContent.fromJson(
      (response.result!['contents'] as List<dynamic>).first as Map<String, dynamic>,
    );
  }

  /// 列出可用提示
  Future<List<MCPPrompt>> listPrompts() async {
    _checkInitialized();

    final request = MCPRequest(
      method: 'prompts/list',
      id: _generateId(),
    );

    final response = await _sendRequestWithResponse(request);

    return (response.result!['prompts'] as List<dynamic>)
        .map((p) => MCPPrompt.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// 获取提示
  Future<List<MCPContent>> getPrompt(
    String name,
    Map<String, String> arguments,
  ) async {
    _checkInitialized();

    final request = MCPRequest(
      method: 'prompts/get',
      params: {
        'name': name,
        'arguments': arguments,
      },
      id: _generateId(),
    );

    final response = await _sendRequestWithResponse(request);

    return (response.result!['messages'] as List<dynamic>)
        .map((m) => MCPContent.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// 发送通知
  Future<void> sendNotification(String method, [Map<String, dynamic>? params]) async {
    final notification = MCPNotification(
      method: method,
      params: params,
    );

    await _sendRequest(jsonEncode(notification.toJson()));
  }

  /// 发送请求并获取响应
  Future<MCPResponse> _sendRequestWithResponse(MCPRequest request) async {
    final responseStr = await _sendRequest(jsonEncode(request.toJson()));
    final responseJson = jsonDecode(responseStr) as Map<String, dynamic>;
    final response = MCPResponse.fromJson(responseJson);

    if (!response.isSuccess) {
      throw MCPError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    return response;
  }

  /// 生成请求ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// 检查是否已初始化
  void _checkInitialized() {
    if (!_initialized) {
      throw StateError('Client not initialized. Call initialize() first.');
    }
  }

  /// 获取服务器能力
  MCPServerCapabilities? get serverCapabilities => _serverCapabilities;

  /// 获取服务器信息
  MCPClientInfo? get serverInfo => _serverInfo;

  /// 是否已初始化
  bool get isInitialized => _initialized;
}
