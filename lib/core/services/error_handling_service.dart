/// 错误处理服务 - LLM Studio 异常管理模块
/// 
/// 功能：
/// - 全局错误捕获
/// - 错误日志记录
/// - 错误上报机制
/// - 崩溃分析
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// 全局错误处理服务
class ErrorHandlingService {
  final List<AppError> _errorLog = [];
  static const int _maxErrorLogSize = 500;

  // 错误上报回调
  Function(AppError)? onErrorReported;

  /// 记录错误
  void logError(AppError error) {
    _errorLog.insert(0, error);

    // 保持错误日志大小
    while (_errorLog.length > _maxErrorLogSize) {
      _errorLog.removeLast();
    }

    // 打印调试信息
    debugPrint('[Error] ${error.type.name}: ${error.message}');

    // 调用上报回调
    onErrorReported?.call(error);
  }

  /// 记录普通错误
  void recordError(dynamic error, StackTrace? stackTrace, {String? context}) {
    logError(AppError(
      type: ErrorType.general,
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: context,
      timestamp: DateTime.now(),
    ));
  }

  /// 记录网络错误
  void recordNetworkError(dynamic error, String? url, {String? method}) {
    logError(AppError(
      type: ErrorType.network,
      message: error.toString(),
      context: 'URL: $url, Method: $method',
      timestamp: DateTime.now(),
    ));
  }

  /// 记录数据库错误
  void recordDatabaseError(dynamic error, String? operation) {
    logError(AppError(
      type: ErrorType.database,
      message: error.toString(),
      context: 'Operation: $operation',
      timestamp: DateTime.now(),
    ));
  }

  /// 记录 UI 错误
  void recordUIError(dynamic error, String? widget, {String? action}) {
    logError(AppError(
      type: ErrorType.ui,
      message: error.toString(),
      context: 'Widget: $widget, Action: $action',
      timestamp: DateTime.now(),
    ));
  }

  /// 记录 API 错误
  void recordApiError(int? statusCode, String? message, String? endpoint) {
    logError(AppError(
      type: ErrorType.api,
      message: message ?? 'Unknown API error',
      context: 'Status: $statusCode, Endpoint: $endpoint',
      timestamp: DateTime.now(),
    ));
  }

  /// 获取所有错误
  List<AppError> getErrors() => List.unmodifiable(_errorLog);

  /// 获取最近的错误
  List<AppError> getRecentErrors({int limit = 50}) {
    return _errorLog.take(limit).toList();
  }

  /// 按类型获取错误
  List<AppError> getErrorsByType(ErrorType type) {
    return _errorLog.where((e) => e.type == type).toList();
  }

  /// 清空错误日志
  void clearErrors() {
    _errorLog.clear();
  }

  /// 导出错误日志
  Future<String> exportErrorLog() async {
    final appDir = await getApplicationDocumentsDirectory();
    final errorLogDir = Directory('${appDir.path}/logs');
    if (!await errorLogDir.exists()) {
      await errorLogDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filePath = '${errorLogDir.path}/error_log_$timestamp.json';

    final errorData = _errorLog.map((e) => {
      'type': e.type.name,
      'message': e.message,
      'context': e.context,
      'stackTrace': e.stackTrace,
      'timestamp': e.timestamp.toIso8601String(),
    }).toList();

    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(errorData),
    );

    return filePath;
  }
}

/// 应用错误
class AppError {
  final ErrorType type;
  final String message;
  final String? stackTrace;
  final String? context;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.stackTrace,
    this.context,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'message': message,
    'context': context,
    'stackTrace': stackTrace,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// 错误类型
enum ErrorType {
  general,
  network,
  database,
  api,
  ui,
  auth,
  security,
}

/// 应用日志服务
class AppLoggingService {
  final List<LogEntry> _logs = [];
  static const int _maxLogSize = 1000;

  // 日志级别
  static const int logLevelDebug = 0;
  static const int logLevelInfo = 1;
  static const int logLevelWarning = 2;
  static const int logLevelError = 3;

  int _currentLogLevel = logLevelInfo;

  /// 设置日志级别
  void setLogLevel(int level) {
    _currentLogLevel = level;
  }

  /// 记录调试日志
  void debug(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// 记录信息日志
  void info(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, tag: tag, data: data);
  }

  /// 记录警告日志
  void warning(String message, {String? tag, Map<String, dynamic>? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// 记录错误日志
  void error(String message, {String? tag, Map<String, dynamic>? data, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, data: data, stackTrace: stackTrace);
  }

  void _log(LogLevel level, String message, {String? tag, Map<String, dynamic>? data, StackTrace? stackTrace}) {
    if (level.level < _currentLogLevel) return;

    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      data: data,
      stackTrace: stackTrace?.toString(),
      timestamp: DateTime.now(),
    );

    _logs.insert(0, entry);

    while (_logs.length > _maxLogSize) {
      _logs.removeLast();
    }

    // 打印调试信息
    final prefix = level.icon;
    final tagStr = tag != null ? '[$tag] ' : '';
    debugPrint('$prefix $tagStr$message');
  }

  /// 获取所有日志
  List<LogEntry> getLogs() => List.unmodifiable(_logs);

  /// 获取最近的日志
  List<LogEntry> getRecentLogs({int limit = 100}) {
    return _logs.take(limit).toList();
  }

  /// 按级别获取日志
  List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((l) => l.level == level).toList();
  }

  /// 清空日志
  void clearLogs() {
    _logs.clear();
  }

  /// 导出日志
  Future<String> exportLogs() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filePath = '${logDir.path}/app_log_$timestamp.json';

    final logData = _logs.map((l) => {
      'level': l.level.name,
      'message': l.message,
      'tag': l.tag,
      'data': l.data,
      'timestamp': l.timestamp.toIso8601String(),
    }).toList();

    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(logData),
    );

    return filePath;
  }
}

/// 日志级别
enum LogLevel {
  debug(0, '🔍', 'DEBUG'),
  info(1, 'ℹ️', 'INFO'),
  warning(2, '⚠️', 'WARNING'),
  error(3, '❌', 'ERROR');

  final int level;
  final String icon;
  final String name;

  const LogLevel(this.level, this.icon, this.name);
}

/// 日志条目
class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? data;
  final String? stackTrace;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.data,
    this.stackTrace,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// Riverpod Providers

// 错误处理服务 Provider
final errorHandlingServiceProvider = Provider<ErrorHandlingService>((ref) {
  return ErrorHandlingService();
});

// 应用日志服务 Provider
final appLoggingServiceProvider = Provider<AppLoggingService>((ref) {
  return AppLoggingService();
});

// 错误日志 Provider
final errorLogProvider = Provider<List<AppError>>((ref) {
  final service = ref.watch(errorHandlingServiceProvider);
  return service.getRecentErrors();
});

// 应用日志 Provider
final appLogProvider = Provider<List<LogEntry>>((ref) {
  final service = ref.watch(appLoggingServiceProvider);
  return service.getRecentLogs();
});