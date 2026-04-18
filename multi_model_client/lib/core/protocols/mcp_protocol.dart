/// MCP (Model Context Protocol) 协议定义
/// 参考: https://modelcontextprotocol.io/

/// MCP版本
const mcpVersion = '2024-11-05';

/// MCP消息类型
enum MCPMessageType {
  request,
  response,
  notification,
}

/// MCP方法
enum MCPMethod {
  // 生命周期
  initialize,
  initialized,
  shutdown,

  // 资源
  resourcesList,
  resourcesRead,
  resourcesSubscribe,
  resourcesUnsubscribe,

  // 提示
  promptsList,
  promptsGet,

  // 工具
  toolsList,
  toolsCall,

  // 采样
  samplingCreateMessage,
}

/// MCP请求
class MCPRequest {
  final String jsonrpc;
  final String method;
  final Map<String, dynamic>? params;
  final String? id;

  MCPRequest({
    this.jsonrpc = '2.0',
    required this.method,
    this.params,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      if (params != null) 'params': params,
      if (id != null) 'id': id,
    };
  }

  factory MCPRequest.fromJson(Map<String, dynamic> json) {
    return MCPRequest(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
      id: json['id'] as String?,
    );
  }
}

/// MCP响应
class MCPResponse {
  final String jsonrpc;
  final Map<String, dynamic>? result;
  final MCPError? error;
  final String id;

  MCPResponse({
    this.jsonrpc = '2.0',
    this.result,
    this.error,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      if (result != null) 'result': result,
      if (error != null) 'error': error!.toJson(),
      'id': id,
    };
  }

  factory MCPResponse.fromJson(Map<String, dynamic> json) {
    return MCPResponse(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] != null
          ? MCPError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      id: json['id'] as String,
    );
  }

  bool get isSuccess => error == null;
}

/// MCP错误
class MCPError {
  final int code;
  final String message;
  final dynamic data;

  MCPError({
    required this.code,
    required this.message,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (data != null) 'data': data,
    };
  }

  factory MCPError.fromJson(Map<String, dynamic> json) {
    return MCPError(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'],
    );
  }

  // 标准错误码
  static MCPError parseError([String? message]) => MCPError(
        code: -32700,
        message: message ?? 'Parse error',
      );

  static MCPError invalidRequest([String? message]) => MCPError(
        code: -32600,
        message: message ?? 'Invalid request',
      );

  static MCPError methodNotFound([String? method]) => MCPError(
        code: -32601,
        message: 'Method not found: ${method ?? ''}',
      );

  static MCPError invalidParams([String? message]) => MCPError(
        code: -32602,
        message: message ?? 'Invalid params',
      );

  static MCPError internalError([String? message]) => MCPError(
        code: -32603,
        message: message ?? 'Internal error',
      );
}

/// MCP通知
class MCPNotification {
  final String jsonrpc;
  final String method;
  final Map<String, dynamic>? params;

  MCPNotification({
    this.jsonrpc = '2.0',
    required this.method,
    this.params,
  });

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'method': method,
      if (params != null) 'params': params,
    };
  }

  factory MCPNotification.fromJson(Map<String, dynamic> json) {
    return MCPNotification(
      jsonrpc: json['jsonrpc'] as String? ?? '2.0',
      method: json['method'] as String,
      params: json['params'] as Map<String, dynamic>?,
    );
  }
}

/// MCP资源
class MCPResource {
  final String uri;
  final String name;
  final String? description;
  final String? mimeType;

  MCPResource({
    required this.uri,
    required this.name,
    this.description,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'name': name,
      if (description != null) 'description': description,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }

  factory MCPResource.fromJson(Map<String, dynamic> json) {
    return MCPResource(
      uri: json['uri'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }
}

/// MCP资源内容
class MCPResourceContent {
  final String uri;
  final String? mimeType;
  final String? text;
  final String? blob; // Base64编码的二进制数据

  MCPResourceContent({
    required this.uri,
    this.mimeType,
    this.text,
    this.blob,
  });

  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      if (mimeType != null) 'mimeType': mimeType,
      if (text != null) 'text': text,
      if (blob != null) 'blob': blob,
    };
  }

  factory MCPResourceContent.fromJson(Map<String, dynamic> json) {
    return MCPResourceContent(
      uri: json['uri'] as String,
      mimeType: json['mimeType'] as String?,
      text: json['text'] as String?,
      blob: json['blob'] as String?,
    );
  }
}

/// MCP工具
class MCPTool {
  final String name;
  final String? description;
  final Map<String, dynamic>? inputSchema;

  MCPTool({
    required this.name,
    this.description,
    this.inputSchema,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (inputSchema != null) 'inputSchema': inputSchema,
    };
  }

  factory MCPTool.fromJson(Map<String, dynamic> json) {
    return MCPTool(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema: json['inputSchema'] as Map<String, dynamic>?,
    );
  }
}

/// MCP工具调用结果
class MCPToolResult {
  final List<MCPContent> content;
  final bool? isError;

  MCPToolResult({
    required this.content,
    this.isError,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((c) => c.toJson()).toList(),
      if (isError != null) 'isError': isError,
    };
  }

  factory MCPToolResult.fromJson(Map<String, dynamic> json) {
    return MCPToolResult(
      content: (json['content'] as List<dynamic>)
          .map((c) => MCPContent.fromJson(c as Map<String, dynamic>))
          .toList(),
      isError: json['isError'] as bool?,
    );
  }
}

/// MCP内容
class MCPContent {
  final String type;
  final String? text;
  final String? data;
  final String? mimeType;

  MCPContent({
    required this.type,
    this.text,
    this.data,
    this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (text != null) 'text': text,
      if (data != null) 'data': data,
      if (mimeType != null) 'mimeType': mimeType,
    };
  }

  factory MCPContent.fromJson(Map<String, dynamic> json) {
    return MCPContent(
      type: json['type'] as String,
      text: json['text'] as String?,
      data: json['data'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }

  factory MCPContent.text(String text) => MCPContent(type: 'text', text: text);
  factory MCPContent.image(String data, String mimeType) =>
      MCPContent(type: 'image', data: data, mimeType: mimeType);
  factory MCPContent.resource(String uri, String mimeType) =>
      MCPContent(type: 'resource', data: uri, mimeType: mimeType);
}

/// MCP提示
class MCPPrompt {
  final String name;
  final String? description;
  final List<MCPPromptArgument>? arguments;

  MCPPrompt({
    required this.name,
    this.description,
    this.arguments,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (arguments != null)
        'arguments': arguments!.map((a) => a.toJson()).toList(),
    };
  }

  factory MCPPrompt.fromJson(Map<String, dynamic> json) {
    return MCPPrompt(
      name: json['name'] as String,
      description: json['description'] as String?,
      arguments: (json['arguments'] as List<dynamic>?)
          ?.map((a) => MCPPromptArgument.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// MCP提示参数
class MCPPromptArgument {
  final String name;
  final String? description;
  final bool required;

  MCPPromptArgument({
    required this.name,
    this.description,
    this.required = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'required': required,
    };
  }

  factory MCPPromptArgument.fromJson(Map<String, dynamic> json) {
    return MCPPromptArgument(
      name: json['name'] as String,
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
    );
  }
}

/// MCP服务器能力
class MCPServerCapabilities {
  final bool? resources;
  final bool? prompts;
  final bool? tools;
  final bool? logging;

  MCPServerCapabilities({
    this.resources,
    this.prompts,
    this.tools,
    this.logging,
  });

  Map<String, dynamic> toJson() {
    return {
      if (resources != null)
        'resources': {'supported': resources},
      if (prompts != null)
        'prompts': {'supported': prompts},
      if (tools != null)
        'tools': {'supported': tools},
      if (logging != null)
        'logging': {'supported': logging},
    };
  }

  factory MCPServerCapabilities.fromJson(Map<String, dynamic> json) {
    return MCPServerCapabilities(
      resources: json['resources']?['supported'] as bool?,
      prompts: json['prompts']?['supported'] as bool?,
      tools: json['tools']?['supported'] as bool?,
      logging: json['logging']?['supported'] as bool?,
    );
  }
}

/// MCP客户端信息
class MCPClientInfo {
  final String name;
  final String version;

  MCPClientInfo({
    required this.name,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
    };
  }

  factory MCPClientInfo.fromJson(Map<String, dynamic> json) {
    return MCPClientInfo(
      name: json['name'] as String,
      version: json['version'] as String,
    );
  }
}

/// MCP初始化结果
class MCPInitializeResult {
  final String protocolVersion;
  final MCPServerCapabilities capabilities;
  final MCPClientInfo serverInfo;

  MCPInitializeResult({
    required this.protocolVersion,
    required this.capabilities,
    required this.serverInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'protocolVersion': protocolVersion,
      'capabilities': capabilities.toJson(),
      'serverInfo': serverInfo.toJson(),
    };
  }

  factory MCPInitializeResult.fromJson(Map<String, dynamic> json) {
    return MCPInitializeResult(
      protocolVersion: json['protocolVersion'] as String,
      capabilities: MCPServerCapabilities.fromJson(
        json['capabilities'] as Map<String, dynamic>,
      ),
      serverInfo: MCPClientInfo.fromJson(
        json['serverInfo'] as Map<String, dynamic>,
      ),
    );
  }
}
