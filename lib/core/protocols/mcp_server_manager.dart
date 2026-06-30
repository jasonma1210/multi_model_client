import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;

import '../storage/database.dart';
import '../storage/database_connection.dart';
import 'mcp_protocol.dart';
import 'mcp_server.dart';
import 'mcp_transports/mcp_streamable_http_transport.dart';

/// MCP服务器状态
enum McpServerStatus {
  stopped,      // 已停止
  starting,     // 启动中
  running,      // 运行中
  error,        // 错误
}

/// MCP服务器管理器
class McpServerManager {
  final AppDatabase _db = database;
  final _uuid = const Uuid();

  final Map<String, MCPClient> _connectedClients = {};
  final Map<String, Process> _runningProcesses = {};
  final Map<String, McpServerStatus> _serverStatuses = {};
  final Map<String, StreamSubscription> _stdoutSubscriptions = {};
  final Map<String, StreamSubscription> _stderrSubscriptions = {};
  final Map<String, McpStreamableHttpTransport> _httpTransports = {}; // v0.45.0

  final _statusController = StreamController<McpServerStatusEvent>.broadcast();
  final _logController = StreamController<McpServerLogEvent>.broadcast();

  /// 状态变更流
  Stream<McpServerStatusEvent> get statusStream => _statusController.stream;

  /// 日志流
  Stream<McpServerLogEvent> get logStream => _logController.stream;

  /// 初始化：加载内置预设服务器
  Future<void> initialize() async {
    await _initBuiltinServers();
    await _autoStartEnabledServers();
  }

  /// 初始化内置预设服务器
  Future<void> _initBuiltinServers() async {
    final builtinServers = [
      // Git服务器
      {
        'serverId': 'git',
        'name': 'Git 代码管理',
        'type': 'stdio',
        'command': 'npx',
        'args': jsonEncode(['-y', '@modelcontextprotocol/server-git']),
        'env': '{}',
        'isEnabled': false,
        'isAutoStart': false,
      },

      // GitHub服务器
      {
        'serverId': 'github',
        'name': 'GitHub',
        'type': 'stdio',
        'command': 'npx',
        'args': jsonEncode(['-y', '@modelcontextprotocol/server-github']),
        'env': jsonEncode({'GITHUB_PERSONAL_ACCESS_TOKEN': ''}),
        'isEnabled': false,
        'isAutoStart': false,
      },

      // Slack服务器
      {
        'serverId': 'slack',
        'name': 'Slack',
        'type': 'stdio',
        'command': 'npx',
        'args': jsonEncode(['-y', '@modelcontextprotocol/server-slack']),
        'env': jsonEncode({'SLACK_TOKEN': ''}),
        'isEnabled': false,
        'isAutoStart': false,
      },

      // 文件系统服务器 - 默认关闭（macOS沙盒限制，无法直接执行npx）
      {
        'serverId': 'filesystem',
        'name': '本地文件系统',
        'type': 'stdio',
        'command': 'npx',
        'args': jsonEncode(['-y', '@modelcontextprotocol/server-filesystem', '{working_dir}']),
        'env': '{}',
        'isEnabled': false,
        'isAutoStart': false,
      },

      // PostgreSQL服务器
      {
        'serverId': 'postgres',
        'name': 'PostgreSQL数据库',
        'type': 'stdio',
        'command': 'npx',
        'args': jsonEncode(['-y', '@modelcontextprotocol/server-postgres']),
        'env': jsonEncode({'POSTGRES_CONNECTION_STRING': ''}),
        'isEnabled': false,
        'isAutoStart': false,
      },

      // Google Drive服务器
      {
        'serverId': 'gdrive',
        'name': 'Google Drive',
        'type': 'stdio',
        'command': 'npx',
        'args': jsonEncode(['-y', '@modelcontextprotocol/server-gdrive']),
        'env': jsonEncode({'GOOGLE_OAUTH_CLIENT_ID': '', 'GOOGLE_OAUTH_CLIENT_SECRET': ''}),
        'isEnabled': false,
        'isAutoStart': false,
      },
    ];

    await _db.transaction(() async {
      for (final serverData in builtinServers) {
        final exists = await _db.getMcpServerConfigByServerId(serverData['serverId'] as String);
        if (exists == null) {
          await _db.insertMcpServerConfig(McpServerConfigsCompanion(
            id: Value(_uuid.v4()),
            serverId: Value(serverData['serverId'] as String),
            name: Value(serverData['name'] as String),
            type: Value(serverData['type'] as String),
            command: Value(serverData['command'] as String),
            args: Value(serverData['args'] as String),
            env: Value(serverData['env'] as String),
            isEnabled: Value(serverData['isEnabled'] as bool),
            isAutoStart: Value(serverData['isAutoStart'] as bool),
            createdAt: Value(DateTime.now()),
          ));
          debugPrint('已添加内置MCP服务器: ${serverData['name']}');
        }
      }
    });
  }

  /// 添加或更新服务器配置
  Future<void> addOrUpdateServer({
    required String serverId,
    required String name,
    required String type,
    required String command,
    required List<String> args,
    required Map<String, String> env,
    required bool isEnabled,
    required bool isAutoStart,
    String? endpoint, // v0.45.0: Streamable HTTP 端点
    String? authToken, // v0.45.0: Bearer Token
  }) async {
    final exists = await _db.getMcpServerConfigByServerId(serverId);
    if (exists != null) {
      // 更新
      await _db.updateMcpServerConfigByServerId(
        serverId: serverId,
        name: name,
        type: type,
        command: command,
        args: jsonEncode(args),
        env: jsonEncode(env),
        isEnabled: isEnabled,
        isAutoStart: isAutoStart,
        endpoint: endpoint, // v0.45.0
        authToken: authToken, // v0.45.0
      );
      debugPrint('[McpServerManager] 更新服务器配置: $serverId');
    } else {
      // 插入
      await _db.insertMcpServerConfig(McpServerConfigsCompanion(
        id: Value(_uuid.v4()),
        serverId: Value(serverId),
        name: Value(name),
        type: Value(type),
        command: Value(command),
        args: Value(jsonEncode(args)),
        env: Value(jsonEncode(env)),
        isEnabled: Value(isEnabled),
        isAutoStart: Value(isAutoStart),
        endpoint: Value(endpoint), // v0.45.0
        authToken: Value(authToken), // v0.45.0
        createdAt: Value(DateTime.now()),
      ));
      debugPrint('[McpServerManager] 添加服务器配置: $serverId');
    }
  }

  /// 自动启动已启用的服务器
  Future<void> _autoStartEnabledServers() async {
    final configs = await _db.getAllMcpServerConfigs();

    for (final config in configs) {
      if (config.isAutoStart && config.isEnabled) {
        debugPrint('自动启动MCP服务器: ${config.name}');
        await startServer(config.serverId);
      }
    }
  }

  /// 启动指定MCP服务器
  Future<MCPClient?> startServer(String serverId) async {
    final config = await _db.getMcpServerConfigByServerId(serverId);
    if (config == null) {
      debugPrint('MCP服务器配置不存在: $serverId');
      return null;
    }

    // v0.45.0: Streamable HTTP 类型走 HTTP transport（移动端也可用）
    if (config.type == 'streamable_http') {
      return await _startStreamableHttpServer(serverId, config);
    }

    // ★★★ 移动端命令兼容性检查 ★★★
    // Android/iOS 不支持 npx/node/uvx 等外部命令，只能运行内置或 Python 类型
    final command = config.command;
    final isNpxCommand = command == 'npx' || command == 'npx.cmd';
    final isNodeCommand = command == 'node' || command == 'node.exe';
    final isUvxCommand = command == 'uvx' || command == 'uvx.exe';
    
    if (Platform.isAndroid || Platform.isIOS) {
      if (isNpxCommand || isNodeCommand || isUvxCommand) {
        debugPrint('[McpServerManager] ⚠️ 移动端不支持 $command 命令: $serverId');
        _updateStatus(serverId, McpServerStatus.error);
        _addLog(serverId, 'error', '移动端不支持 $command 命令，请在桌面端使用');
        return null;
      }
      if (command == 'python' || command == 'python3') {
        // Python 命令需要额外确认环境
        debugPrint('[McpServerManager] ⚠️ 移动端可能不支持 Python 命令: $serverId');
      }
    }

    // 如果已经在运行，先停止
    if (_serverStatuses[serverId] == McpServerStatus.running) {
      await stopServer(serverId);
    }

    try {
      _updateStatus(serverId, McpServerStatus.starting);
      _addLog(serverId, 'info', '正在启动服务器...');

      // 安全解析参数和环境变量
      List<String> args;
      Map<String, String> env;
      
      // 尝试解析 args
      final argsRaw = config.args ?? '[]';
      try {
        if (argsRaw.startsWith('[')) {
          // JSON 数组格式
          args = List<String>.from(jsonDecode(argsRaw));
        } else if (argsRaw.contains(',')) {
          // 旧格式：逗号分隔的字符串
          args = argsRaw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        } else {
          args = argsRaw.isNotEmpty ? [argsRaw] : [];
        }
      } catch (_) {
        args = argsRaw.isNotEmpty ? [argsRaw] : [];
      }
      
      // 尝试解析 env
      final envRaw = config.env ?? '{}';
      try {
        if (envRaw.startsWith('{')) {
          // JSON 对象格式
          env = Map<String, String>.from(jsonDecode(envRaw));
        } else {
          env = {};
        }
      } catch (_) {
        env = {};
      }
      
      final workingDir = await _getWorkingDirectory();

      // 替换参数中的占位符
      args = args.map((arg) => arg.replaceAll('{working_dir}', workingDir)).toList();

      // 启动子进程
      final process = await Process.start(
        config.command,
        args,
        environment: env,
        workingDirectory: workingDir,
      );

      _runningProcesses[serverId] = process;

      // 监听stdout
      _stdoutSubscriptions[serverId] = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            _addLog(serverId, 'stdout', line);
          });

      // 监听stderr
      _stderrSubscriptions[serverId] = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            _addLog(serverId, 'stderr', line);
          });

      // 创建MCP客户端并连接
      final client = MCPClient(
        clientInfo: MCPClientInfo(
          name: 'Flutter AI Assistant',
          version: '1.0.0',
        ),
        sendRequest: (request) async {
          process.stdin.writeln(request);
          await process.stdin.flush();

          // 等待响应（简化实现，实际应该解析stdout获取响应）
          // 这里需要更复杂的实现来正确处理JSON-RPC响应
          return '{"jsonrpc":"2.0","result":{},"id":"1"}';
        },
      );

      await client.initialize();
      _connectedClients[serverId] = client;

      _updateStatus(serverId, McpServerStatus.running);
      _addLog(serverId, 'info', '服务器启动成功');

      // 更新数据库状态
      await _db.updateMcpServerConfig(McpServerConfigsCompanion(
        id: Value(config.id),
        lastConnectedTime: Value(DateTime.now()),
        lastError: const Value(null),
      ));

      return client;
    } catch (e, stackTrace) {
      _updateStatus(serverId, McpServerStatus.error);
      _addLog(serverId, 'error', '启动失败: $e');
      debugPrint('启动MCP服务器失败: $e\n$stackTrace');

      // 更新数据库错误信息
      await _db.updateMcpServerConfig(McpServerConfigsCompanion(
        id: Value(config.id),
        lastError: Value(e.toString()),
      ));

      return null;
    }
  }

  /// v0.45.0: 启动 Streamable HTTP MCP 服务器
  ///
  /// 使用 McpStreamableHttpTransport 发送 JSON-RPC 请求到远程 HTTP endpoint，
  /// 适配为 MCPClient 的 sendRequest 回调，复用现有 callTool 链路。
  Future<MCPClient?> _startStreamableHttpServer(
    String serverId,
    McpServerConfig config,
  ) async {
    if (config.endpoint == null || config.endpoint!.isEmpty) {
      _updateStatus(serverId, McpServerStatus.error);
      _addLog(serverId, 'error', 'Streamable HTTP endpoint 未配置');
      return null;
    }

    // 如果已经在运行，先停止
    if (_serverStatuses[serverId] == McpServerStatus.running) {
      await stopServer(serverId);
    }

    try {
      _updateStatus(serverId, McpServerStatus.starting);
      _addLog(serverId, 'info', '正在连接 HTTP MCP 服务器...');

      final transport = McpStreamableHttpTransport(
        endpoint: config.endpoint!,
        headers: {
          if (config.authToken != null && config.authToken!.isNotEmpty)
            'Authorization': 'Bearer ${config.authToken}',
        },
      );
      _httpTransports[serverId] = transport;

      // 1. 发送 initialize 请求
      final initReq = MCPRequest(
        jsonrpc: '2.0',
        id: '1',
        method: 'initialize',
        params: {
          'protocolVersion': '2025-03-26',
          'clientInfo': {'name': 'mj_nexus', 'version': '0.45.0'},
        },
      );
      await transport.connect(initReq);

      // 2. 构造 transport→MCPClient 适配器
      final client = MCPClient(
        clientInfo: MCPClientInfo(name: 'mj_nexus', version: '0.45.0'),
        sendRequest: (String reqJson) async {
          final req = MCPRequest.fromJson(
              jsonDecode(reqJson) as Map<String, dynamic>);
          final resp = await transport.send(req);
          return jsonEncode(resp.toJson());
        },
      );
      await client.initialize();
      _connectedClients[serverId] = client;

      _updateStatus(serverId, McpServerStatus.running);
      _addLog(serverId, 'info', 'HTTP MCP 服务器连接成功');

      // 更新数据库状态
      await _db.updateMcpServerConfig(McpServerConfigsCompanion(
        id: Value(config.id),
        lastConnectedTime: Value(DateTime.now()),
        lastError: const Value(null),
      ));

      return client;
    } catch (e, stackTrace) {
      _updateStatus(serverId, McpServerStatus.error);
      _addLog(serverId, 'error', 'HTTP MCP 连接失败: $e');
      debugPrint('启动 HTTP MCP 服务器失败: $e\n$stackTrace');

      await _httpTransports[serverId]?.close();
      _httpTransports.remove(serverId);
      _connectedClients.remove(serverId);

      await _db.updateMcpServerConfig(McpServerConfigsCompanion(
        id: Value(config.id),
        lastError: Value(e.toString()),
      ));

      return null;
    }
  }

  /// 停止服务器
  Future<void> stopServer(String serverId) async {
    _addLog(serverId, 'info', '正在停止服务器...');

    // 断开客户端
    _connectedClients.remove(serverId);

    // v0.45.0: 关闭 HTTP transport（如有）
    await _httpTransports[serverId]?.close();
    _httpTransports.remove(serverId);

    // 取消监听
    _stdoutSubscriptions[serverId]?.cancel();
    _stdoutSubscriptions.remove(serverId);

    _stderrSubscriptions[serverId]?.cancel();
    _stderrSubscriptions.remove(serverId);

    // 杀死进程
    _runningProcesses[serverId]?.kill();
    _runningProcesses.remove(serverId);

    _updateStatus(serverId, McpServerStatus.stopped);
    _addLog(serverId, 'info', '服务器已停止');
  }

  /// 重启服务器
  Future<MCPClient?> restartServer(String serverId) async {
    await stopServer(serverId);
    await Future.delayed(const Duration(milliseconds: 500));
    return await startServer(serverId);
  }

  /// 获取服务器工具列表
  Future<List<MCPTool>> getServerTools(String serverId) async {
    final client = _connectedClients[serverId];
    if (client == null || !client.isInitialized) {
      debugPrint('服务器未连接: $serverId');
      return [];
    }

    try {
      return await client.listTools();
    } catch (e) {
      debugPrint('获取工具列表失败: $e');
      return [];
    }
  }

  /// 调用服务器工具
  Future<MCPToolResult> callTool(
    String serverId,
    String toolName,
    Map<String, dynamic> arguments, {
    bool requireConfirmation = false,
  }) async {
    final client = _connectedClients[serverId];
    if (client == null || !client.isInitialized) {
      throw StateError('服务器未连接: $serverId');
    }

    // 敏感操作确认
    if (requireConfirmation) {
      // 这里应该弹出确认对话框，由用户确认
      // 简化实现：直接允许
      _addLog(serverId, 'info', '执行敏感工具: $toolName');
    }

    try {
      _addLog(serverId, 'info', '调用工具: $toolName');
      final result = await client.callTool(toolName, arguments);
      _addLog(serverId, 'info', '工具调用成功');
      return result;
    } catch (e) {
      _addLog(serverId, 'error', '工具调用失败: $e');
      rethrow;
    }
  }

  /// 获取会话工具列表
  Future<List<MCPTool>> getSessionTools(List<String> serverIds) async {
    final List<MCPTool> allTools = [];

    for (final serverId in serverIds) {
      final tools = await getServerTools(serverId);
      allTools.addAll(tools);
    }

    return allTools;
  }

  /// 获取所有服务器配置
  Future<List<McpServerConfig>> getAllConfigs() async {
    return await _db.getAllMcpServerConfigs();
  }

  /// 更新服务器配置
  Future<void> updateConfig(String serverId, {
    bool? isEnabled,
    bool? isAutoStart,
    Map<String, String>? env,
  }) async {
    final config = await _db.getMcpServerConfigByServerId(serverId);
    if (config == null) return;

    await _db.updateMcpServerConfig(McpServerConfigsCompanion(
      id: Value(config.id),
      isEnabled: isEnabled != null ? Value(isEnabled) : const Value.absent(),
      isAutoStart: isAutoStart != null ? Value(isAutoStart) : const Value.absent(),
      env: env != null ? Value(jsonEncode(env)) : const Value.absent(),
    ));
  }

  /// 获取服务器状态
  McpServerStatus getServerStatus(String serverId) {
    return _serverStatuses[serverId] ?? McpServerStatus.stopped;
  }

  /// 更新服务器状态
  void _updateStatus(String serverId, McpServerStatus status) {
    _serverStatuses[serverId] = status;
    _statusController.add(McpServerStatusEvent(
      serverId: serverId,
      status: status,
      timestamp: DateTime.now(),
    ));
  }

  /// 添加日志
  void _addLog(String serverId, String level, String message) {
    _logController.add(McpServerLogEvent(
      serverId: serverId,
      level: level,
      message: message,
      timestamp: DateTime.now(),
    ));
  }

  /// 获取工作目录
  Future<String> _getWorkingDirectory() async {
    // 返回应用文档目录（沙盒内，可读写）
    // 使用 path_provider 获取应用支持目录
    try {
      final dir = await _getAppSupportDirectory();
      if (dir != null && await Directory(dir).exists()) {
        return dir;
      }
    } catch (_) {
      // ignore: non-critical error
    }
    
    // 降级：返回临时目录
    try {
      final tempDir = Directory.systemTemp.path;
      return tempDir;
    } catch (_) {
      // ignore: non-critical error
    }
    
    // 最终降级：返回当前目录
    return Directory.current.path;
  }
  
  String? _cachedAppSupportDir;
  
  Future<String?> _getAppSupportDirectory() async {
    if (_cachedAppSupportDir != null) return _cachedAppSupportDir;
    
    try {
      // 尝试从 path_provider 获取
      // 由于这是一个纯 Dart 类，不直接依赖 Flutter，需要使用其他方式
      // 在 macOS 上，使用 NSSearchPathForDirectoriesInDomains 或等效方法
      final process = await Process.run(
        'getconf', 
        ['DARWIN_USER_DIR'],
      );
      if (process.exitCode == 0) {
        _cachedAppSupportDir = '${process.stdout.toString().trim()}/Application Support';
        return _cachedAppSupportDir;
      }
    } catch (_) {
      // ignore: non-critical error
    }
    
    return null;
  }

  /// 健康检查
  Future<void> healthCheck() async {
    for (final serverId in _runningProcesses.keys) {
      final process = _runningProcesses[serverId];
      if (process != null) {
        final exitCode = await process.exitCode.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => -1,
        );

        if (exitCode != -1) {
          // 进程已退出
          debugPrint('MCP服务器异常退出: $serverId, exitCode: $exitCode');
          _updateStatus(serverId, McpServerStatus.error);
          _addLog(serverId, 'error', '进程异常退出，退出码: $exitCode');

          // 尝试重启
          if (_serverStatuses[serverId] == McpServerStatus.running) {
            debugPrint('尝试重启MCP服务器: $serverId');
            await restartServer(serverId);
          }
        }
      }
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    // 停止所有服务器
    for (final serverId in _runningProcesses.keys.toList()) {
      await stopServer(serverId);
    }

    _statusController.close();
    _logController.close();
  }
}

/// MCP服务器状态事件
class McpServerStatusEvent {
  final String serverId;
  final McpServerStatus status;
  final DateTime timestamp;

  McpServerStatusEvent({
    required this.serverId,
    required this.status,
    required this.timestamp,
  });
}

/// MCP服务器日志事件
class McpServerLogEvent {
  final String serverId;
  final String level;
  final String message;
  final DateTime timestamp;

  McpServerLogEvent({
    required this.serverId,
    required this.level,
    required this.message,
    required this.timestamp,
  });
}
