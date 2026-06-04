import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// 应用日志服务（开发调试工具）
/// 提供分级日志记录，支持控制台输出和文件存储
/// 
/// 注意：此为开发调试工具，release 构建中默认关闭控制台输出。
/// 生产环境日志请使用 LogService（数据库存储）。
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  /// 日志级别
  static const int levelDebug = 0;
  static const int levelInfo = 1;
  static const int levelWarning = 2;
  static const int levelError = 3;

  /// 当前日志级别
  int _currentLevel = levelDebug;
  
  /// 日志文件路径
  String? _logFilePath;
  
  /// 是否初始化
  bool _initialized = false;
  
  /// 是否启用控制台输出（release 构建默认关闭）
  bool _enableConsoleOutput = false;
  
  /// 日志节流：记录每个 tag 上次输出 debugPrint 的时间
  final Map<String, int> _lastOutputTime = {};
  
  /// 节流间隔（毫秒）：同一 tag 在 1 秒内只输出 1 次 debugPrint
  static const int _throttleIntervalMs = 1000;

  /// 初始化日志服务
  Future<void> init({int minLevel = levelDebug, bool enableConsoleOutput = false}) async {
    if (_initialized) return;
    
    _currentLevel = minLevel;
    _enableConsoleOutput = enableConsoleOutput;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
      _logFilePath = '${logDir.path}/app_$timestamp.log';
      
      _initialized = true;
      info('AppLogger', '日志服务初始化完成，日志文件: $_logFilePath');
    } catch (e) {
      debugPrint('AppLogger 初始化失败: $e');
    }
  }

  /// 设置日志级别
  void setLevel(int level) {
    _currentLevel = level;
  }

  /// 调试日志
  void debug(String tag, String message) {
    if (_currentLevel > levelDebug) return;
    _log('DEBUG', tag, message);
  }

  /// 信息日志
  void info(String tag, String message) {
    if (_currentLevel > levelInfo) return;
    _log('INFO', tag, message);
  }

  /// 警告日志
  void warning(String tag, String message) {
    if (_currentLevel > levelWarning) return;
    _log('WARN', tag, message);
  }

  /// 错误日志
  void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (_currentLevel > levelError) return;
    String fullMessage = message;
    if (error != null) {
      fullMessage += '\nError: $error';
    }
    if (stackTrace != null) {
      fullMessage += '\nStackTrace: $stackTrace';
    }
    _log('ERROR', tag, fullMessage);
  }

  /// 内部日志记录
  void _log(String level, String tag, String message) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logLine = '[$timestamp] [$level] [$tag] $message';
    
    // 仅在控制台输出启用时输出到 debugPrint
    if (_enableConsoleOutput) {
      // 日志节流：同一 tag 在 _throttleIntervalMs 内只输出 1 次 debugPrint
      final now = DateTime.now().millisecondsSinceEpoch;
      final lastTime = _lastOutputTime[tag] ?? 0;
      final shouldOutput = (now - lastTime) >= _throttleIntervalMs;
      
      if (shouldOutput) {
        _lastOutputTime[tag] = now;
        // 控制台输出（已节流）
        if (level == 'DEBUG') {
          debugPrint(logLine);
        } else if (level == 'ERROR') {
          debugPrint('\x1B[31m$logLine\x1B[0m'); // 红色
        } else if (level == 'WARN') {
          debugPrint('\x1B[33m$logLine\x1B[0m'); // 黄色
        } else {
          debugPrint(logLine);
        }
      }
    }
    
    // 写入文件（不受节流和 consoleOutput 影响，确保完整记录）
    _writeToFile(logLine);
  }

  /// 写入文件
  Future<void> _writeToFile(String line) async {
    if (_logFilePath == null) return;
    
    try {
      final file = File(_logFilePath!);
      await file.writeAsString('$line\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('写入日志失败: $e');
    }
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFilePath;

  /// 读取最近 N 行的日志
  Future<List<String>> readLastLines(int lines) async {
    if (_logFilePath == null) return [];
    
    try {
      final file = File(_logFilePath!);
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      final allLines = content.split('\n');
      
      if (allLines.length <= lines) {
        return allLines.where((l) => l.isNotEmpty).toList();
      }
      
      return allLines.sublist(allLines.length - lines).where((l) => l.isNotEmpty).toList();
    } catch (e) {
      debugPrint('读取日志失败: $e');
      return [];
    }
  }

  /// 清理旧日志（保留最近 N 天）
  Future<void> cleanOldLogs({int keepDays = 7}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) return;
      
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final dateFormat = DateFormat('yyyyMMdd');
      
      await for (final entity in logDir.list()) {
        if (entity is File && entity.path.endsWith('.log')) {
          final fileName = entity.path.split('/').last;
          final dateStr = fileName.replaceAll('app_', '').replaceAll('.log', '');
          try {
            final fileDate = dateFormat.parse(dateStr);
            if (fileDate.isBefore(cutoffDate)) {
              await entity.delete();
              info('AppLogger', '已清理旧日志: $fileName');
            }
          } catch (_) {
            // 忽略无法解析的文件名
          }
        }
      }
    } catch (e) {
      debugPrint('清理旧日志失败: $e');
    }
  }
}

/// 全局日志实例
final appLogger = AppLogger();

/// 便捷方法
void logDebug(String tag, String message) => appLogger.debug(tag, message);
void logInfo(String tag, String message) => appLogger.info(tag, message);
void logWarning(String tag, String message) => appLogger.warning(tag, message);
void logError(String tag, String message, [Object? error, StackTrace? stackTrace]) => 
    appLogger.error(tag, message, error, stackTrace);