/// 插件沙箱执行器
/// 
/// 提供隔离的执行环境，限制插件的权限和资源访问
/// 支持：
/// - 权限控制（文件/网络/数据库等）
/// - 资源限制（内存/CPU/执行时间）
/// - 隔离执行（Isolate）
/// - 安全审计日志
library;

import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'plugin_manifest.dart';

/// 沙箱配置
class SandboxConfig {
  /// 最大执行时间（毫秒）
  final int maxExecutionTimeMs;
  
  /// 最大内存使用（字节）
  final int maxMemoryBytes;
  
  /// 允许的权限列表
  final List<PluginPermission> allowedPermissions;
  
  /// 允许的网络域名（白名单）
  final List<String> allowedDomains;
  
  /// 允许的文件路径前缀（白名单）
  final List<String> allowedFilePaths;
  
  /// 是否启用详细日志
  final bool enableVerboseLogging;
  
  const SandboxConfig({
    this.maxExecutionTimeMs = 30000, // 30 秒
    this.maxMemoryBytes = 100 * 1024 * 1024, // 100 MB
    this.allowedPermissions = const [],
    this.allowedDomains = const [],
    this.allowedFilePaths = const [],
    this.enableVerboseLogging = false,
  });
  
  /// 从插件清单创建配置
  factory SandboxConfig.fromManifest(PluginManifest manifest) {
    final config = manifest.config ?? {};
    
    return SandboxConfig(
      maxExecutionTimeMs: config['maxExecutionTimeMs'] as int? ?? 30000,
      maxMemoryBytes: config['maxMemoryBytes'] as int? ?? 100 * 1024 * 1024,
      allowedPermissions: manifest.permissions,
      allowedDomains: (config['allowedDomains'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      allowedFilePaths: (config['allowedFilePaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
  
  /// 创建严格配置
  factory SandboxConfig.strict() {
    return const SandboxConfig(
      maxExecutionTimeMs: 10000,
      maxMemoryBytes: 50 * 1024 * 1024,
      allowedPermissions: [],
      allowedDomains: [],
      allowedFilePaths: [],
    );
  }
  
  /// 创建宽松配置
  factory SandboxConfig.lenient() {
    return const SandboxConfig(
      maxExecutionTimeMs: 60000,
      maxMemoryBytes: 500 * 1024 * 1024,
      allowedPermissions: PluginPermission.values,
      allowedDomains: ['*'],
      allowedFilePaths: ['/'],
    );
  }
}

/// 沙箱执行结果
class SandboxExecutionResult {
  /// 是否成功
  final bool success;
  
  /// 返回数据
  final dynamic data;
  
  /// 错误信息
  final String? error;
  
  /// 执行时间（毫秒）
  final int executionTimeMs;
  
  /// 内存使用峰值（字节）
  final int peakMemoryBytes;
  
  /// 安全审计日志
  final List<SecurityAuditEntry> auditLog;
  
  const SandboxExecutionResult({
    required this.success,
    this.data,
    this.error,
    required this.executionTimeMs,
    required this.peakMemoryBytes,
    this.auditLog = const [],
  });
}

/// 安全审计条目
class SecurityAuditEntry {
  final DateTime timestamp;
  final SecurityEventType eventType;
  final String description;
  final bool allowed;
  final Map<String, dynamic>? details;
  
  const SecurityAuditEntry({
    required this.timestamp,
    required this.eventType,
    required this.description,
    required this.allowed,
    this.details,
  });
}

/// 安全事件类型
enum SecurityEventType {
  /// 文件访问
  fileAccess,
  
  /// 网络请求
  networkRequest,
  
  /// 数据库访问
  databaseAccess,
  
  /// 系统命令执行
  systemCommand,
  
  /// 权限提升尝试
  privilegeEscalation,
  
  /// 资源超限
  resourceLimitExceeded,
}

/// 沙箱权限检查器
class SandboxPermissionChecker {
  final SandboxConfig config;
  final List<SecurityAuditEntry> _auditLog = [];
  
  SandboxPermissionChecker({required this.config});
  
  /// 获取审计日志
  List<SecurityAuditEntry> get auditLog => List.unmodifiable(_auditLog);
  
  /// 检查文件访问权限
  bool checkFileAccess(String filePath, {bool isWrite = false}) {
    final permission = isWrite ? PluginPermission.fileWrite : PluginPermission.fileRead;
    
    if (!config.allowedPermissions.contains(permission)) {
      _logEvent(SecurityAuditEntry(
        timestamp: DateTime.now(),
        eventType: SecurityEventType.fileAccess,
        description: '文件访问被拒绝: $filePath',
        allowed: false,
        details: {'filePath': filePath, 'isWrite': isWrite},
      ));
      return false;
    }
    
    // 检查路径白名单
    if (config.allowedFilePaths.isNotEmpty) {
      final isAllowed = config.allowedFilePaths.any(
        (prefix) => filePath.startsWith(prefix),
      );
      
      if (!isAllowed) {
        _logEvent(SecurityAuditEntry(
          timestamp: DateTime.now(),
          eventType: SecurityEventType.fileAccess,
          description: '文件路径不在白名单: $filePath',
          allowed: false,
          details: {'filePath': filePath},
        ));
        return false;
      }
    }
    
    _logEvent(SecurityAuditEntry(
      timestamp: DateTime.now(),
      eventType: SecurityEventType.fileAccess,
      description: '文件访问允许: $filePath',
      allowed: true,
      details: {'filePath': filePath, 'isWrite': isWrite},
    ));
    
    return true;
  }
  
  /// 检查网络请求权限
  bool checkNetworkAccess(String url) {
    if (!config.allowedPermissions.contains(PluginPermission.network)) {
      _logEvent(SecurityAuditEntry(
        timestamp: DateTime.now(),
        eventType: SecurityEventType.networkRequest,
        description: '网络访问被拒绝: $url',
        allowed: false,
        details: {'url': url},
      ));
      return false;
    }
    
    // 检查域名白名单
    if (config.allowedDomains.isNotEmpty && !config.allowedDomains.contains('*')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final isAllowed = config.allowedDomains.any(
          (domain) => uri.host == domain || uri.host.endsWith('.$domain'),
        );
        
        if (!isAllowed) {
          _logEvent(SecurityAuditEntry(
            timestamp: DateTime.now(),
            eventType: SecurityEventType.networkRequest,
            description: '域名不在白名单: ${uri.host}',
            allowed: false,
            details: {'url': url, 'host': uri.host},
          ));
          return false;
        }
      }
    }
    
    _logEvent(SecurityAuditEntry(
      timestamp: DateTime.now(),
      eventType: SecurityEventType.networkRequest,
      description: '网络访问允许: $url',
      allowed: true,
      details: {'url': url},
    ));
    
    return true;
  }
  
  /// 检查数据库访问权限
  bool checkDatabaseAccess() {
    final allowed = config.allowedPermissions.contains(PluginPermission.database);
    
    _logEvent(SecurityAuditEntry(
      timestamp: DateTime.now(),
      eventType: SecurityEventType.databaseAccess,
      description: allowed ? '数据库访问允许' : '数据库访问被拒绝',
      allowed: allowed,
    ));
    
    return allowed;
  }
  
  /// 检查系统命令执行权限
  bool checkSystemCommandAccess(String command) {
    final allowed = config.allowedPermissions.contains(PluginPermission.systemCommand);
    
    _logEvent(SecurityAuditEntry(
      timestamp: DateTime.now(),
      eventType: SecurityEventType.systemCommand,
      description: allowed ? '系统命令执行允许: $command' : '系统命令执行被拒绝: $command',
      allowed: allowed,
      details: {'command': command},
    ));
    
    return allowed;
  }
  
  /// 记录安全事件
  void _logEvent(SecurityAuditEntry entry) {
    _auditLog.add(entry);
    if (config.enableVerboseLogging) {
      debugPrint('[Sandbox] ${entry.eventType.name}: ${entry.description} (allowed: ${entry.allowed})');
    }
  }
}

/// 插件沙箱执行器
class PluginSandbox {
  final SandboxConfig config;
  late final SandboxPermissionChecker _permissionChecker;
  
  PluginSandbox({required this.config}) {
    _permissionChecker = SandboxPermissionChecker(config: config);
  }
  
  /// 获取权限检查器
  SandboxPermissionChecker get permissionChecker => _permissionChecker;
  
  /// 在沙箱中执行函数
  Future<SandboxExecutionResult> execute<T>(
    Future<T> Function() function, {
    String? operationName,
  }) async {
    final stopwatch = Stopwatch()..start();
    int peakMemory = 0;
    
    try {
      // 创建超时 Future
      final timeoutFuture = Future.delayed(
        Duration(milliseconds: config.maxExecutionTimeMs),
      );
      
      // 执行函数
      final resultFuture = function();
      
      // 等待执行完成或超时
      final result = await Future.any([resultFuture, timeoutFuture]);
      
      stopwatch.stop();
      
      // 检查是否超时
      if (result == null && stopwatch.elapsedMilliseconds >= config.maxExecutionTimeMs) {
        return SandboxExecutionResult(
          success: false,
          error: '执行超时: ${config.maxExecutionTimeMs}ms',
          executionTimeMs: stopwatch.elapsedMilliseconds,
          peakMemoryBytes: peakMemory,
          auditLog: _permissionChecker.auditLog,
        );
      }
      
      return SandboxExecutionResult(
        success: true,
        data: result,
        executionTimeMs: stopwatch.elapsedMilliseconds,
        peakMemoryBytes: peakMemory,
        auditLog: _permissionChecker.auditLog,
      );
    } catch (e) {
      stopwatch.stop();
      
      return SandboxExecutionResult(
        success: false,
        error: '执行失败: $e',
        executionTimeMs: stopwatch.elapsedMilliseconds,
        peakMemoryBytes: peakMemory,
        auditLog: _permissionChecker.auditLog,
      );
    }
  }
  
  /// 在 Isolate 中执行函数（更严格的隔离）
  Future<SandboxExecutionResult> executeInIsolate<T>(
    Future<T> Function() function, {
    String? operationName,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // 创建 ReceivePort 接收结果
      final receivePort = ReceivePort();
      
      // 启动 Isolate
      final isolate = await Isolate.spawn(
        _isolateEntry,
        _IsolateParams(
          sendPort: receivePort.sendPort,
          function: function,
        ),
      );
      
      // 设置超时
      final timeout = Duration(milliseconds: config.maxExecutionTimeMs);
      final result = await receivePort.first.timeout(
        timeout,
        onTimeout: () {
          receivePort.close();
          isolate.kill(priority: Isolate.immediate);
          return _IsolateResult.error('执行超时: ${config.maxExecutionTimeMs}ms');
        },
      );
      
      stopwatch.stop();
      
      // 清理
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
      
      if (result.isSuccess) {
        return SandboxExecutionResult(
          success: true,
          data: result.data,
          executionTimeMs: stopwatch.elapsedMilliseconds,
          peakMemoryBytes: 0, // Isolate 中难以获取
          auditLog: _permissionChecker.auditLog,
        );
      } else {
        return SandboxExecutionResult(
          success: false,
          error: result.error,
          executionTimeMs: stopwatch.elapsedMilliseconds,
          peakMemoryBytes: 0,
          auditLog: _permissionChecker.auditLog,
        );
      }
    } catch (e) {
      stopwatch.stop();
      
      return SandboxExecutionResult(
        success: false,
        error: 'Isolate 执行失败: $e',
        executionTimeMs: stopwatch.elapsedMilliseconds,
        peakMemoryBytes: 0,
        auditLog: _permissionChecker.auditLog,
      );
    }
  }
  
  /// Isolate 入口
  static void _isolateEntry(_IsolateParams params) async {
    try {
      final result = await params.function();
      params.sendPort.send(_IsolateResult.success(result));
    } catch (e) {
      params.sendPort.send(_IsolateResult.error(e.toString()));
    }
  }
}

/// Isolate 参数
class _IsolateParams {
  final SendPort sendPort;
  final Future<dynamic> Function() function;
  
  const _IsolateParams({
    required this.sendPort,
    required this.function,
  });
}

/// Isolate 结果
class _IsolateResult {
  final bool isSuccess;
  final dynamic data;
  final String? error;
  
  const _IsolateResult({
    required this.isSuccess,
    this.data,
    this.error,
  });
  
  factory _IsolateResult.success(dynamic data) {
    return _IsolateResult(isSuccess: true, data: data);
  }
  
  factory _IsolateResult.error(String error) {
    return _IsolateResult(isSuccess: false, error: error);
  }
}

/// 沙箱异常
class SandboxException implements Exception {
  final String message;
  final SecurityEventType? eventType;
  
  const SandboxException(this.message, {this.eventType});
  
  @override
  String toString() => 'SandboxException: $message';
}