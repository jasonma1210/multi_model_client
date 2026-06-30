// v0.43.0 实现 In-App Dart MCP Server
//
// 移动端加载 MCP 的核心方案：
// - iOS 沙盒禁止 spawn stdio 子进程
// - 解决方案：将 MCP Server 用 Dart 实现，在 App 内 in-process 启动
// - 优势：免网络延迟、零依赖、离线工作、用户隐私保护

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../mcp_protocol.dart';

/// In-App MCP Server 抽象基类
abstract class InAppMcpServer {
  final String serverId;
  final String name;
  final String version;
  final String description;

  /// 工具列表
  List<MCPTool> get tools;

  /// 资源列表
  List<MCPResource> get resources;

  /// 提示列表
  List<MCPPrompt> get prompts;

  /// 启动 server
  Future<void> start();

  /// 关闭 server
  Future<void> close();

  /// 处理 JSON-RPC 请求
  Future<MCPResponse> handleRequest(MCPRequest request);

  const InAppMcpServer({
    required this.serverId,
    required this.name,
    required this.version,
    required this.description,
  });
}

/// 内置 Filesystem MCP Server
class FilesystemInAppMcpServer extends InAppMcpServer {
  String? _rootDir;

  /// 根目录提供者（默认使用 path_provider，可注入用于测试）
  final Future<String> Function() rootDirProvider;

  FilesystemInAppMcpServer({Future<String> Function()? rootDirProvider})
      : rootDirProvider = rootDirProvider ?? _defaultRootDirProvider,
        super(
          serverId: 'inapp-filesystem',
          name: 'Filesystem (In-App)',
          version: '1.0.0',
          description: '本地文件系统访问（受沙盒保护）',
        );

  static Future<String> _defaultRootDirProvider() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  @override
  List<MCPTool> get tools => [
        MCPTool(
          name: 'read_file',
          description: '读取文件内容',
          inputSchema: const {
            'type': 'object',
            'properties': {
              'path': {'type': 'string', 'description': '文件路径（相对于 rootDir）'},
            },
            'required': ['path'],
          },
        ),
        MCPTool(
          name: 'write_file',
          description: '写入文件内容',
          inputSchema: const {
            'type': 'object',
            'properties': {
              'path': {'type': 'string'},
              'content': {'type': 'string'},
            },
            'required': ['path', 'content'],
          },
        ),
        MCPTool(
          name: 'list_dir',
          description: '列出目录内容',
          inputSchema: const {
            'type': 'object',
            'properties': {
              'path': {'type': 'string', 'default': '.'},
            },
          },
        ),
        MCPTool(
          name: 'search_files',
          description: '按关键词搜索文件名',
          inputSchema: const {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
            },
            'required': ['query'],
          },
        ),
      ];

  @override
  List<MCPResource> get resources => const [];

  @override
  List<MCPPrompt> get prompts => const [];

  @override
  Future<void> start() async {
    _rootDir = await rootDirProvider();
    debugPrint('[FilesystemMcp] started, root: $_rootDir');
  }

  @override
  Future<void> close() async {
    debugPrint('[FilesystemMcp] closed');
  }

  @override
  Future<MCPResponse> handleRequest(MCPRequest request) async {
    try {
      switch (request.method) {
        case 'initialize':
          return MCPResponse(
            id: request.id ?? '',
            result: {
              'protocolVersion': mcpVersion,
              'serverInfo': {'name': name, 'version': version},
              'capabilities': {'tools': {}},
            },
          );
        case 'tools/list':
          return MCPResponse(
            id: request.id ?? '',
            result: {'tools': tools.map(_toolToJson).toList()},
          );
        case 'tools/call':
          final params = request.params ?? {};
          final toolName = params['name'] as String?;
          final args = params['arguments'] as Map<String, dynamic>? ?? {};
          return await _callTool(request.id ?? '', toolName ?? '', args);
        default:
          return MCPResponse(
            id: request.id ?? '',
            error: MCPError(code: -32601, message: 'Method not found: ${request.method}'),
          );
      }
    } catch (e, stack) {
      debugPrint('[FilesystemMcp] error: $e\n$stack');
      return MCPResponse(
        id: request.id ?? '',
        error: MCPError(code: -32603, message: 'Internal error: $e'),
      );
    }
  }

  Future<MCPResponse> _callTool(String id, String toolName, Map<String, dynamic> args) async {
    if (_rootDir == null) await start();
    final root = _rootDir!;

    switch (toolName) {
      case 'read_file':
        final path = args['path'] as String;
        final fullPath = '$root/$path';
        if (!_isWithinSandbox(fullPath, root)) {
          return MCPResponse(id: id, error: MCPError(code: -32602, message: 'Path out of sandbox: $path'));
        }
        final file = File(fullPath);
        if (!await file.exists()) {
          return MCPResponse(id: id, error: MCPError(code: -32602, message: 'File not found: $path'));
        }
        final content = await file.readAsString();
        return MCPResponse(
          id: id,
          result: {'content': [{'type': 'text', 'text': content}]},
        );

      case 'write_file':
        final path = args['path'] as String;
        final content = args['content'] as String;
        final fullPath = '$root/$path';
        if (!_isWithinSandbox(fullPath, root)) {
          return MCPResponse(id: id, error: MCPError(code: -32602, message: 'Path out of sandbox: $path'));
        }
        final file = File(fullPath);
        await file.writeAsString(content);
        return MCPResponse(
          id: id,
          result: {'content': [{'type': 'text', 'text': 'Written'}]},
        );

      case 'list_dir':
        final path = (args['path'] as String?) ?? '.';
        final fullPath = '$root/$path';
        if (!_isWithinSandbox(fullPath, root)) {
          return MCPResponse(id: id, error: MCPError(code: -32602, message: 'Path out of sandbox: $path'));
        }
        final dir = Directory(fullPath);
        if (!await dir.exists()) {
          return MCPResponse(id: id, error: MCPError(code: -32602, message: 'Directory not found: $path'));
        }
        final entries = await dir.list().toList();
        final listing = entries.map((e) => e.path.replaceFirst(root, '')).join('\n');
        return MCPResponse(
          id: id,
          result: {'content': [{'type': 'text', 'text': listing}]},
        );

      case 'search_files':
        final query = args['query'] as String;
        final dir = Directory(root);
        final results = <String>[];
        await for (final entity in dir.list(recursive: true)) {
          if (entity.path.toLowerCase().contains(query.toLowerCase())) {
            results.add(entity.path.replaceFirst(root, ''));
            if (results.length >= 50) break;
          }
        }
        return MCPResponse(
          id: id,
          result: {'content': [{'type': 'text', 'text': results.join('\n')}]},
        );

      default:
        return MCPResponse(id: id, error: MCPError(code: -32601, message: 'Unknown tool: $toolName'));
    }
  }

  /// 检查路径是否在沙盒内
  /// - 拒绝绝对路径
  /// - 规范化 ../ 等相对路径段
  /// - 解析后必须真正位于 root 之下
  bool _isWithinSandbox(String requestedPath, String root) {
    if (path.isAbsolute(requestedPath)) return false;
    final normalized = path.normalize(path.join(root, requestedPath));
    final normalizedRoot = path.normalize(root);
    return normalized == normalizedRoot ||
        normalized.startsWith('${normalizedRoot}${Platform.pathSeparator}');
  }

  Map<String, dynamic> _toolToJson(MCPTool tool) => {
        'name': tool.name,
        'description': tool.description,
        'inputSchema': tool.inputSchema,
      };
}

/// 内置 Notes MCP Server（占位实现）
class NotesInAppMcpServer extends InAppMcpServer {
  NotesInAppMcpServer()
      : super(
          serverId: 'inapp-notes',
          name: 'Notes (In-App)',
          version: '1.0.0',
          description: '本地笔记访问（基于知识库）',
        );

  @override
  List<MCPTool> get tools => [
        MCPTool(
          name: 'list_notes',
          description: '列出最近笔记',
          inputSchema: const {
            'type': 'object',
            'properties': {'limit': {'type': 'integer', 'default': 10}},
          },
        ),
        MCPTool(
          name: 'search_notes',
          description: '关键词搜索笔记',
          inputSchema: const {
            'type': 'object',
            'properties': {
              'query': {'type': 'string'},
              'limit': {'type': 'integer', 'default': 5},
            },
            'required': ['query'],
          },
        ),
      ];

  @override
  List<MCPResource> get resources => const [];

  @override
  List<MCPPrompt> get prompts => const [];

  @override
  Future<void> start() async {
    debugPrint('[NotesMcp] started');
  }

  @override
  Future<void> close() async {
    debugPrint('[NotesMcp] closed');
  }

  @override
  Future<MCPResponse> handleRequest(MCPRequest request) async {
    try {
      switch (request.method) {
        case 'initialize':
          return MCPResponse(
            id: request.id ?? '',
            result: {
              'protocolVersion': mcpVersion,
              'serverInfo': {'name': name, 'version': version},
              'capabilities': {'tools': {}},
            },
          );
        case 'tools/list':
          return MCPResponse(
            id: request.id ?? '',
            result: {
              'tools': tools
                  .map((t) => {
                        'name': t.name,
                        'description': t.description,
                        'inputSchema': t.inputSchema,
                      })
                  .toList(),
            },
          );
        case 'tools/call':
          return MCPResponse(
            id: request.id ?? '',
            result: {
              'content': [
                {'type': 'text', 'text': 'Notes MCP server is a placeholder. Integrate with Drift knowledge_base table.'},
              ],
            },
          );
        default:
          return MCPResponse(
            id: request.id ?? '',
            error: MCPError(code: -32601, message: 'Method not found: ${request.method}'),
          );
      }
    } catch (e, stack) {
      debugPrint('[NotesMcp] error: $e\n$stack');
      return MCPResponse(
        id: request.id ?? '',
        error: MCPError(code: -32603, message: 'Internal error: $e'),
      );
    }
  }
}

/// In-App MCP Server 注册表
class InAppMcpRegistry {
  final Map<String, InAppMcpServer> _servers = {};

  InAppMcpRegistry();

  /// 注册并启动所有内置 server
  Future<void> registerDefaults({Future<String> Function()? rootDirProvider}) async {
    final fs = FilesystemInAppMcpServer(rootDirProvider: rootDirProvider);
    final notes = NotesInAppMcpServer();
    await fs.start();
    await notes.start();
    _servers[fs.serverId] = fs;
    _servers[notes.serverId] = notes;
    debugPrint('[InAppMcpRegistry] registered ${_servers.length} servers');
  }

  InAppMcpServer? get(String serverId) => _servers[serverId];

  List<InAppMcpServer> get all => _servers.values.toList();

  Future<void> closeAll() async {
    for (final server in _servers.values) {
      await server.close();
    }
    _servers.clear();
  }
}
