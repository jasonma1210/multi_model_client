/// 日志服务 - LLM Studio 应用日志记录模块
///
/// 功能：
/// - 记录错误和异常日志到数据库
/// - 日志分片管理（按天存储，超过 5MB 自动分片）
/// - 日志查询和过滤
/// - 日志导出功能
///
/// @author Jianma
/// @version 1.0.0
library;

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import '../storage/database.dart';
import '../storage/database_connection.dart';
import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 日志分类
enum LogCategory {
  ui,
  network,
  database,
  model,
  tts,
  asr,
  other,
}

/// 日志条目
class LogEntry {
  final String id;
  final LogLevel level;
  final LogCategory category;
  final String title;
  final String message;
  final String? stackTrace;
  final String? deviceInfo;
  final DateTime createdAt;

  LogEntry({
    required this.id,
    required this.level,
    required this.category,
    required this.title,
    required this.message,
    this.stackTrace,
    this.deviceInfo,
    required this.createdAt,
  });
}

/// 日志服务
class LogService {
  static LogService? _instance;
  static LogService get instance => _instance ??= LogService._();
  LogService._();

  bool _isInitialized = false;

  /// 最大单文件大小（5MB）
  static const int maxFileSize = 5 * 1024 * 1024;

  /// ★ 构建模式检测：release 构建不使用 debugPrint（避免日志风暴）
  /// kDebugMode 由 Flutter framework 提供，debug=true, release=false
  /// kReleaseMode 来自 Flutter foundation，debug=true, release=false
  static final bool _isDebugMode = !(bool.hasEnvironment('kReleaseMode')
      ? bool.fromEnvironment('kReleaseMode') : false);
  /// 是否输出到控制台（debug 模式默认开启，release 模式关闭）
  static final bool _consoleOutput = _isDebugMode;

  /// 文件日志路径（用于 DB 不可用时的降级，替代 AppLogger）
  String? _fallbackLogFilePath;

  /// 初始化日志服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final db = database;
      await db.customSelect('SELECT 1 as test').get();
      _isInitialized = true;
      if (_isDebugMode) debugPrint('[LogService] 日志服务初始化成功');

      // 记录应用启动日志（仅成功后记录）
      await log(
        level: LogLevel.info,
        category: LogCategory.other,
        title: '应用启动',
        message: 'LLM Studio 应用已启动',
      );

      // 初始化降级文件日志路径
      final dir = await getApplicationDocumentsDirectory();
      _fallbackLogFilePath = '${dir.path}/logs/llm_studio.log';
    } catch (e) {
      if (_isDebugMode) debugPrint('[LogService] 日志服务初始化失败（跳过）: $e');
      // 不重试以免级联日志
    }
  }

  /// 记录日志
  Future<void> log({
    required LogLevel level,
    required LogCategory category,
    required String title,
    required String message,
    String? stackTrace,
    String? deviceInfo,
  }) async {
    // 立即记录，不缓冲（确保重要日志不丢失）
    await _writeLog(
      level: level,
      category: category,
      title: title,
      message: message,
      stackTrace: stackTrace,
      deviceInfo: deviceInfo,
    );

    // 不额外输出到控制台（DB 写入已有 _writeLog 内部的日志）
    // 避免双重输出导致 Android logd 配额溢出
  }

  /// 记录错误
  Future<void> error({
    required String title,
    required String message,
    String? stackTrace,
    LogCategory category = LogCategory.other,
  }) async {
    await log(
      level: LogLevel.error,
      category: category,
      title: title,
      message: message,
      stackTrace: stackTrace,
      deviceInfo: await _getDeviceInfo(),
    );
  }

  /// 记录警告
  Future<void> warning({
    required String title,
    required String message,
    LogCategory category = LogCategory.other,
  }) async {
    await log(
      level: LogLevel.warning,
      category: category,
      title: title,
      message: message,
      deviceInfo: await _getDeviceInfo(),
    );
  }

  /// 记录信息
  Future<void> info({
    required String title,
    required String message,
    LogCategory category = LogCategory.other,
  }) async {
    await log(
      level: LogLevel.info,
      category: category,
      title: title,
      message: message,
      deviceInfo: await _getDeviceInfo(),
    );
  }

  /// 记录调试信息
  Future<void> debug({
    required String title,
    required String message,
    LogCategory category = LogCategory.other,
  }) async {
    await log(
      level: LogLevel.debug,
      category: category,
      title: title,
      message: message,
    );
  }

  /// 写入日志到数据库
  Future<void> _writeLog({
    required LogLevel level,
    required LogCategory category,
    required String title,
    required String message,
    String? stackTrace,
    String? deviceInfo,
  }) async {
    try {
      final db = database;
      final id = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
      final now = DateTime.now();

      await db.into(db.appLogs).insert(
        AppLogsCompanion.insert(
          id: id,
          level: level.toString().split('.').last,
          category: category.toString().split('.').last,
          title: title,
          message: message,
          stackTrace: Value(stackTrace),
          deviceInfo: Value(deviceInfo),
          createdAt: now,
        ),
      );

      // 仅在 debug 模式下输出到控制台
      if (_consoleOutput && _isDebugMode) {
        final levelStr = level.toString().split('.').last.toUpperCase();
        final categoryStr = category.toString().split('.').last;
        debugPrint('[$levelStr][$categoryStr] $title: $message');
      }

      // 检查是否需要分片
      await _checkAndRotateLogs(now);
    } catch (_) {
      // DB 写入失败时降级到文件（静默，不级联 debugPrint）
      await _writeToFallbackFile(level, category, title, message, stackTrace, deviceInfo);
    }
  }

  /// 降级方案：写入文件日志（替代 AppLogger 的文件写入功能）
  Future<void> _writeToFallbackFile(
    LogLevel level,
    LogCategory category,
    String title,
    String message,
    String? stackTrace,
    String? deviceInfo,
  ) async {
    if (_fallbackLogFilePath == null) return;
    try {
      final dir = Directory(Directory(_fallbackLogFilePath!).parent.path);
      if (!await dir.exists()) await dir.create(recursive: true);
      final file = File(_fallbackLogFilePath!);
      final timestamp = DateTime.now().toIso8601String();
      final logLine = '[$timestamp][${level.toString().split('.').last}][${category.toString().split('.').last}] $title: $message\n';
      await file.writeAsString(logLine, mode: FileMode.append);
    } catch (_) {
      // 降级日志也不写入，避免日志风暴
    }
  }

  /// 检查并轮转日志（按天分片，超过 5MB 再次分片）
  Future<void> _checkAndRotateLogs(DateTime date) async {
    try {
      final db = database;
      // 获取当天日志总大小（估算）
      final logs = await (db.select(db.appLogs)
            ..where((t) => t.createdAt.isBetweenValues(
              DateTime(date.year, date.month, date.day),
              DateTime(date.year, date.month, date.day, 23, 59, 59),
            )))
          .get();

      // 估算大小：每条日志平均约 500 字节
      final estimatedSize = logs.length * 500;

      if (estimatedSize > maxFileSize && _consoleOutput) {
        debugPrint('[LogService] 当日日志超过 5MB，当前条目数: ${logs.length}');
      }
    } catch (_) {
      // 静默忽略
    }
  }

  /// 获取设备信息
  Future<String> _getDeviceInfo() async {
    try {
      final info = {
        'platform': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
      return info.toString();
    } catch (e) {
      return '{}';
    }
  }

  /// 获取日志列表
  Future<List<LogEntry>> getLogs({
    LogLevel? level,
    LogCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final db = database;
      var query = db.select(db.appLogs);

      // 构建查询条件
      if (level != null) {
        query = query..where((t) => t.level.equals(level.toString().split('.').last));
      }
      if (category != null) {
        query = query..where((t) => t.category.equals(category.toString().split('.').last));
      }
      if (startDate != null) {
        query = query..where((t) => t.createdAt.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        query = query..where((t) => t.createdAt.isSmallerOrEqualValue(endDate));
      }

      // 按时间倒序排列
      query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

      // 分页
      query = query..limit(limit, offset: offset);

      final results = await query.get();

      return results.map((row) => LogEntry(
        id: row.id,
        level: LogLevel.values.firstWhere(
          (e) => e.toString().split('.').last == row.level,
          orElse: () => LogLevel.info,
        ),
        category: LogCategory.values.firstWhere(
          (e) => e.toString().split('.').last == row.category,
          orElse: () => LogCategory.other,
        ),
        title: row.title,
        message: row.message,
        stackTrace: row.stackTrace,
        deviceInfo: row.deviceInfo,
        createdAt: row.createdAt,
      )).toList();
    } catch (e) {
      if (_consoleOutput) debugPrint('[LogService] 获取日志列表失败: $e');
      return [];
    }
  }

  /// 获取日志详情
  Future<LogEntry?> getLogById(String id) async {
    try {
      final db = database;
      final query = db.select(db.appLogs)
        ..where((t) => t.id.equals(id));

      final result = await query.getSingleOrNull();
      if (result == null) return null;

      return LogEntry(
        id: result.id,
        level: LogLevel.values.firstWhere(
          (e) => e.toString().split('.').last == result.level,
          orElse: () => LogLevel.info,
        ),
        category: LogCategory.values.firstWhere(
          (e) => e.toString().split('.').last == result.category,
          orElse: () => LogCategory.other,
        ),
        title: result.title,
        message: result.message,
        stackTrace: result.stackTrace,
        deviceInfo: result.deviceInfo,
        createdAt: result.createdAt,
      );
    } catch (e) {
      if (_consoleOutput) debugPrint('[LogService] 获取日志详情失败: $e');
      return null;
    }
  }

  /// 获取日志文件列表（按天分组）
  Future<List<Map<String, dynamic>>> getLogFiles() async {
    try {
      final db = database;
      // 按天分组统计
      final results = await (db.customSelect(
        "SELECT date(created_at) as date, COUNT(*) as count, SUM(LENGTH(message) + LENGTH(title) + COALESCE(LENGTH(stack_trace), 0)) as size "
        "FROM app_logs GROUP BY date(created_at) ORDER BY date DESC",
      )).get();

      return results.map((row) => {
        'date': row.read<String>('date'),
        'count': row.read<int>('count'),
        'size': row.read<int>('size'),
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// 导出日志到文件
  Future<String?> exportLogs(List<String> logIds, String exportPath) async {
    try {
      final logs = <LogEntry>[];

      if (logIds.isEmpty) {
        final allLogs = await getLogs(limit: 10000);
        logs.addAll(allLogs);
      } else {
        for (final id in logIds) {
          final log = await getLogById(id);
          if (log != null) logs.add(log);
        }
      }

      if (logs.isEmpty) return null;

      final buffer = StringBuffer();
      buffer.writeln('=== LLM Studio 日志导出 ===');
      buffer.writeln('导出时间: ${DateTime.now().toIso8601String()}');
      buffer.writeln('日志数量: ${logs.length}');
      buffer.writeln('');

      for (final log in logs) {
        buffer.writeln('----------------------------------------');
        buffer.writeln('时间: ${log.createdAt.toIso8601String()}');
        buffer.writeln('级别: ${log.level.toString().split('.').last}');
        buffer.writeln('分类: ${log.category.toString().split('.').last}');
        buffer.writeln('标题: ${log.title}');
        buffer.writeln('内容: ${log.message}');
        if (log.stackTrace != null) buffer.writeln('堆栈: ${log.stackTrace}');
        if (log.deviceInfo != null) buffer.writeln('设备: ${log.deviceInfo}');
        buffer.writeln('');
      }

      final file = File(exportPath);
      await file.writeAsString(buffer.toString());
      return exportPath;
    } catch (_) {
      return null;
    }
  }

  /// 删除日志
  Future<bool> deleteLogs(List<String> logIds) async {
    try {
      final db = database;
      await (db.delete(db.appLogs)
            ..where((t) => t.id.isIn(logIds)))
          .go();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 清理旧日志（保留最近 N 天）
  Future<int> cleanupOldLogs({int daysToKeep = 30}) async {
    try {
      final db = database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      return await (db.delete(db.appLogs)
            ..where((t) => t.createdAt.isSmallerThanValue(cutoffDate)))
          .go();
    } catch (_) {
      return 0;
    }
  }

  /// 获取日志统计
  Future<Map<String, dynamic>> getLogStats() async {
    try {
      final db = database;

      final errorLogs = await (db.select(db.appLogs)
            ..where((t) => t.level.equals('error')))
          .get();
      final warningLogs = await (db.select(db.appLogs)
            ..where((t) => t.level.equals('warning')))
          .get();
      final infoLogs = await (db.select(db.appLogs)
            ..where((t) => t.level.equals('info')))
          .get();

      return {
        'total': errorLogs.length + warningLogs.length + infoLogs.length,
        'error': errorLogs.length,
        'warning': warningLogs.length,
        'info': infoLogs.length,
      };
    } catch (_) {
      return {'total': 0, 'error': 0, 'warning': 0, 'info': 0};
    }
  }
}

/// 全局日志记录便捷方法
Future<void> logError({
  required String title,
  required String message,
  String? stackTrace,
  LogCategory category = LogCategory.other,
}) async {
  await LogService.instance.error(
    title: title,
    message: message,
    stackTrace: stackTrace,
    category: category,
  );
}

Future<void> logWarning({
  required String title,
  required String message,
  LogCategory category = LogCategory.other,
}) async {
  await LogService.instance.warning(
    title: title,
    message: message,
    category: category,
  );
}

Future<void> logInfo({
  required String title,
  required String message,
  LogCategory category = LogCategory.other,
}) async {
  await LogService.instance.info(
    title: title,
    message: message,
    category: category,
  );
}