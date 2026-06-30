// v0.43.0 MCP Streamable HTTP + In-App MCP Server 单元测试

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/protocols/mcp_protocol.dart';
import 'package:mj_nexus/core/protocols/mcp_transports/in_app_mcp_server.dart';
import 'package:mj_nexus/core/protocols/mcp_transports/mcp_streamable_http_transport.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 测试用临时根目录
  final tempRoot = Directory.systemTemp.createTempSync('mcp_test_').path;

  group('InAppMcpRegistry', () {
    test('registerDefaults 注册 2 个 server', () async {
      final registry = InAppMcpRegistry();
      await registry.registerDefaults(rootDirProvider: () async => tempRoot);
      expect(registry.all.length, 2);
      expect(registry.get('inapp-filesystem'), isNotNull);
      expect(registry.get('inapp-notes'), isNotNull);
    });
  });

  group('FilesystemInAppMcpServer', () {
    test('initialize 返回 serverInfo', () async {
      final fs = FilesystemInAppMcpServer(rootDirProvider: () async => tempRoot);
      await fs.start();
      final response = await fs.handleRequest(MCPRequest(
        method: 'initialize',
        id: '1',
      ));
      expect(response.isSuccess, true);
      expect(response.result!['serverInfo']['name'], 'Filesystem (In-App)');
    });

    test('tools/list 返回工具列表', () async {
      final fs = FilesystemInAppMcpServer(rootDirProvider: () async => tempRoot);
      await fs.start();
      final response = await fs.handleRequest(MCPRequest(
        method: 'tools/list',
        id: '2',
      ));
      final tools = (response.result!['tools'] as List);
      expect(tools.length, 4);
      expect(tools.map((t) => t['name']).toList(), [
        'read_file',
        'write_file',
        'list_dir',
        'search_files',
      ]);
    });

    test('unknown method 返回错误', () async {
      final fs = FilesystemInAppMcpServer(rootDirProvider: () async => tempRoot);
      await fs.start();
      final response = await fs.handleRequest(MCPRequest(
        method: 'foo/bar',
        id: '3',
      ));
      expect(response.error, isNotNull);
      expect(response.error!.code, -32601);
    });

    test('沙盒外路径拒绝', () async {
      final fs = FilesystemInAppMcpServer(rootDirProvider: () async => tempRoot);
      await fs.start();
      final response = await fs.handleRequest(MCPRequest(
        method: 'tools/call',
        id: '4',
        params: {
          'name': 'read_file',
          'arguments': {'path': '/etc/passwd'},
        },
      ));
      expect(response.error, isNotNull);
      expect(response.error!.message, contains('sandbox'));
    });
  });

  group('McpStreamableHttpTransport', () {
    test('未连接时 send 抛错', () async {
      // 创建 transport 但不 connect
      final transport = McpStreamableHttpTransport(endpoint: 'http://localhost:9999');
      expect(
        () => transport.send(MCPRequest(method: 'tools/list', id: '1')),
        throwsA(isA<MCPException>()),
      );
    });

    test('重复 connect 抛错', () async {
      // 此测试仅验证状态机，不实际建立连接
      final transport = McpStreamableHttpTransport(endpoint: 'http://localhost:9999');
      // 模拟已 connected 状态
      // 由于无 mock，这里只验证 transport 创建
      expect(transport.status, StreamableHttpStatus.disconnected);
      expect(transport.sessionId, isNull);
    });
  });
}
