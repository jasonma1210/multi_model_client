import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:path_provider/path_provider.dart';

import '../../storage/database.dart';
import '../../storage/database_connection.dart';
import '../../providers/settings_provider.dart';

/// 下载任务状态
enum DownloadStatus {
  pending,      // 等待中
  downloading,  // 下载中
  paused,       // 已暂停
  completed,    // 已完成
  error,        // 错误
}

/// 下载任务管理器
class DownloadTaskManager {
  final AppDatabase _db = database;
  final Dio _dio;
  final _uuid = const Uuid();
  final SettingsService _settingsService;

  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, double> _progressMap = {};

  // 节流：记录上次写数据库的时间，每500ms最多写一次
  final Map<String, DateTime> _lastDbWriteTime = {};

  /// 进度通知器
  final ValueNotifier<Map<String, DownloadProgress>> progressNotifier = ValueNotifier({});

  DownloadTaskManager(this._dio, {SettingsService? settingsService}) 
      : _settingsService = settingsService ?? SettingsService();

  /// 创建下载任务
  Future<DownloadTask> createTask({
    required String modelId,
    required String url,
    required String savePath,
    required String source,
    String? quantLevel,
    Map<String, dynamic>? metadata,
    String? expectedHash, // 预期的文件哈希值（SHA256）
    String? hashAlgorithm, // 哈希算法，默认SHA256
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final task = DownloadTasksCompanion(
      id: Value(id),
      modelId: Value(modelId),
      url: Value(url),
      savePath: Value(savePath),
      status: Value(DownloadStatus.pending.name),
      progress: const Value(0),
      totalBytes: const Value(0),
      downloadedBytes: const Value(0),
      source: Value(source),
      quantLevel: Value(quantLevel),
      metadata: Value(metadata?.toString()),
      createdAt: Value(now),
    );

    await _db.insertDownloadTask(task);

    // 存储哈希值到内存，用于下载完成后校验
    if (expectedHash != null) {
      _expectedHashes[id] = expectedHash;
      _hashAlgorithms[id] = hashAlgorithm ?? 'sha256';
    }

    return (await _db.getDownloadTask(id))!;
  }

  // 存储预期哈希值
  final Map<String, String> _expectedHashes = {};
  final Map<String, String> _hashAlgorithms = {};

  /// 开始下载
  Future<void> startDownload(String taskId, {Function(DownloadProgress)? onProgress}) async {
    final task = await _db.getDownloadTask(taskId);
    if (task == null) {
      throw StateError('Task not found: $taskId');
    }

    // 创建取消令牌
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    try {
      // 更新状态为下载中
      await _updateTaskStatus(taskId, DownloadStatus.downloading);

      // 确保目录存在
      final file = File(task.savePath);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 检查是否支持断点续传
      int downloadedBytes = 0;
      if (await file.exists()) {
        downloadedBytes = await file.length();
        debugPrint('断点续传: 已下载 $downloadedBytes bytes');
      }

      // 获取文件总大小
      // 策略：先尝试 HEAD 请求获取 Content-Length（完整文件大小）
      // 对于断点续传，服务器返回的 Content-Length 是剩余部分，
      // 所以总大小 = 已下载 + Content-Length
      int totalBytes = task.totalBytes;
      if (totalBytes <= 0) {
        try {
          final headResponse = await _dio.head(task.url);
          final contentLength = headResponse.headers.value('content-length');
          if (contentLength != null) {
            totalBytes = int.parse(contentLength);
            debugPrint('文件总大小 (HEAD): $totalBytes bytes');
          }
        } catch (e) {
          debugPrint('获取文件大小失败: $e');
        }
      }

      // 执行下载
      await _dio.download(
        task.url,
        task.savePath,
        cancelToken: cancelToken,
        deleteOnError: false,
        options: Options(
          headers: downloadedBytes > 0 ? {'Range': 'bytes=$downloadedBytes-'} : null,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
        onReceiveProgress: (received, total) async {
          // 解析真实进度
          // dio.download 的 received/total 含义取决于是否有 Range header：
          // - 无 Range（首次下载）：received = 累计已接收，total = 文件总大小
          // - 有 Range（断点续传）：received = 本轮已接收，total = 本轮 Content-Length
          //   但 dio 在 206 响应时，total 是 Accept-Range 之后的大小（剩余部分）
          int actualReceived;
          int actualTotal;

          if (downloadedBytes > 0 && total > 0) {
            // 断点续传：dio 的 total 是服务器返回的剩余部分大小
            actualTotal = downloadedBytes + total;
            actualReceived = downloadedBytes + received;
          } else if (total > 0) {
            // 首次下载且服务器返回了总大小
            actualReceived = received;
            actualTotal = total;
          } else {
            // 服务器不返回 content-length（total == -1）
            actualReceived = downloadedBytes + received;
            actualTotal = totalBytes > 0 ? totalBytes : 0;
          }

          final progress = actualTotal > 0 ? (actualReceived / actualTotal) : 0.0;

          // 更新总大小（如果之前未知，用 onReceiveProgress 里的值修正）
          if (totalBytes <= 0 && actualTotal > 0) {
            totalBytes = actualTotal;
          }

          // 节流：每 500ms 最多写一次数据库，避免大量并发写导致锁
          final now = DateTime.now();
          final lastWrite = _lastDbWriteTime[taskId];
          if (lastWrite == null || now.difference(lastWrite).inMilliseconds >= 500) {
            _lastDbWriteTime[taskId] = now;
            try {
              await _db.updateDownloadTask(DownloadTasksCompanion(
                id: Value(taskId),
                downloadedBytes: Value(actualReceived),
                totalBytes: Value(actualTotal),
                progress: Value((progress * 100).toInt()),
              ));
            } catch (e) {
              // 进度写数据库失败不影响下载，忽略
              debugPrint('进度写数据库失败 (忽略): $e');
            }
          }

          // 更新进度通知（内存操作，不涉及数据库，无需节流）
          final progressInfo = DownloadProgress(
            taskId: taskId,
            modelId: task.modelId,
            status: DownloadStatus.downloading,
            progress: progress,
            downloadedBytes: actualReceived,
            totalBytes: actualTotal,
          );

          progressNotifier.value = {
            ...progressNotifier.value,
            taskId: progressInfo,
          };

          // 回调
          onProgress?.call(progressInfo);
        },
      );

      // 下载完成，进行哈希校验
      final actualHash = await _calculateFileHash(task.savePath);
      final expectedHash = _expectedHashes[taskId];

      if (expectedHash != null && actualHash != null) {
        if (actualHash.toLowerCase() != expectedHash.toLowerCase()) {
          throw StateError('文件哈希校验失败: 预期 $expectedHash, 实际 $actualHash');
        }
        debugPrint('文件哈希校验通过: $actualHash');
      }

      await _updateTaskStatus(taskId, DownloadStatus.completed);

      final completedProgress = DownloadProgress(
        taskId: taskId,
        modelId: task.modelId,
        status: DownloadStatus.completed,
        progress: 1.0,
        downloadedBytes: await file.length(),
        totalBytes: await file.length(),
        hash: actualHash,
      );

      progressNotifier.value = {
        ...progressNotifier.value,
        taskId: completedProgress,
      };

      // 清理哈希存储
      _expectedHashes.remove(taskId);
      _hashAlgorithms.remove(taskId);

    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // 用户取消，不更新为错误状态
        debugPrint('Download cancelled: $taskId');
      } else {
        // 更新为错误状态
        await _updateTaskStatus(taskId, DownloadStatus.error, error: e.toString());

        final errorProgress = DownloadProgress(
          taskId: taskId,
          modelId: task.modelId,
          status: DownloadStatus.error,
          progress: 0.0,
          downloadedBytes: 0,
          totalBytes: 0,
          error: e.toString(),
        );

        progressNotifier.value = {
          ...progressNotifier.value,
          taskId: errorProgress,
        };
      }
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  /// 暂停下载
  Future<void> pauseDownload(String taskId) async {
    final cancelToken = _cancelTokens[taskId];
    if (cancelToken != null) {
      cancelToken.cancel('User paused');
      _cancelTokens.remove(taskId);
    }

    await _updateTaskStatus(taskId, DownloadStatus.paused);
  }

  /// 恢复下载
  Future<void> resumeDownload(String taskId, {Function(DownloadProgress)? onProgress}) async {
    final task = await _db.getDownloadTask(taskId);
    if (task == null) return;

    await startDownload(taskId, onProgress: onProgress);
  }

  /// 取消下载
  Future<void> cancelDownload(String taskId) async {
    _cancelTokens[taskId]?.cancel('User cancelled');
    _cancelTokens.remove(taskId);

    // 删除任务记录
    await _db.deleteDownloadTask(taskId);
    final updated1 = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated1.remove(taskId);
    progressNotifier.value = updated1;
  }

  /// 删除已下载的文件
  Future<void> deleteDownloadedFile(String taskId) async {
    final task = await _db.getDownloadTask(taskId);
    if (task == null) return;

    final file = File(task.savePath);
    if (await file.exists()) {
      await file.delete();
    }

    await _db.deleteDownloadTask(taskId);
    final updated2 = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated2.remove(taskId);
    progressNotifier.value = updated2;
  }

  /// 获取所有下载任务
  Future<List<DownloadTask>> getAllTasks() async {
    return await _db.getAllDownloadTasks();
  }

  /// 获取指定任务
  Future<DownloadTask?> getTask(String taskId) async {
    return await _db.getDownloadTask(taskId);
  }

  /// 更新任务状态
  Future<void> _updateTaskStatus(String taskId, DownloadStatus status, {String? error}) async {
    // 只有在完成(completed)时才设置 completedAt，暂停(paused)时不设置
    Value<DateTime?> completedAtValue;
    if (status == DownloadStatus.completed) {
      completedAtValue = Value(DateTime.now());
    } else if (status == DownloadStatus.paused) {
      // 暂停时清除 completedAt（如果有值的话）
      completedAtValue = const Value(null);
    } else {
      completedAtValue = const Value.absent();
    }
    
    await _db.updateDownloadTask(DownloadTasksCompanion(
      id: Value(taskId),
      status: Value(status.name),
      error: Value(error),
      completedAt: completedAtValue,
    ));
  }

  /// 暂停任务
  Future<void> pauseTask(String taskId) async {
    debugPrint('暂停任务: $taskId');
    final token = _cancelTokens[taskId];
    if (token != null) {
      token.cancel('Paused by user');
      _cancelTokens.remove(taskId);
      debugPrint('取消令牌已移除');
    }
    await _updateTaskStatus(taskId, DownloadStatus.paused);
    
    // 更新进度通知器状态
    final currentProgress = progressNotifier.value[taskId];
    if (currentProgress != null) {
      progressNotifier.value = {
        ...progressNotifier.value,
        taskId: DownloadProgress(
          taskId: taskId,
          modelId: currentProgress.modelId,
          status: DownloadStatus.paused,
          progress: currentProgress.progress,
          downloadedBytes: currentProgress.downloadedBytes,
          totalBytes: currentProgress.totalBytes,
        ),
      };
    }
    debugPrint('任务已暂停: $taskId');
  }

  /// 恢复任务（重新开始下载，支持断点续传）
  Future<void> resumeTask(String taskId) async {
    final task = await _db.getDownloadTask(taskId);
    if (task == null) {
      debugPrint('恢复任务失败: 任务不存在 $taskId');
      return;
    }
    
    debugPrint('恢复任务: $taskId, 当前状态: ${task.status}, 已下载: ${task.downloadedBytes} bytes');
    
    // 检查文件是否存在，获取已下载大小
    final file = File(task.savePath);
    int downloadedBytes = 0;
    if (await file.exists()) {
      downloadedBytes = await file.length();
      debugPrint('断点续传: 文件存在，已下载 $downloadedBytes bytes');
    } else {
      debugPrint('断点续传: 文件不存在，从头开始下载');
    }
    
    // 更新数据库中的已下载字节数
    await _db.updateDownloadTask(DownloadTasksCompanion(
      id: Value(taskId),
      downloadedBytes: Value(downloadedBytes),
      status: Value(DownloadStatus.downloading.name),
    ));
    
    // 重新开始下载（会自动使用 Range header 断点续传）
    await startDownload(taskId);
  }

  /// 取消任务
  Future<void> cancelTask(String taskId) async {
    debugPrint('取消任务: $taskId');
    final token = _cancelTokens[taskId];
    if (token != null) {
      token.cancel('Cancelled by user');
      _cancelTokens.remove(taskId);
      debugPrint('取消令牌已移除');
      // 等待 dio 的 catch 回调处理完毕，再操作数据库，避免竞争锁
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    // 删除已下载的部分文件
    try {
      final task = await _db.getDownloadTask(taskId);
      if (task != null) {
        final file = File(task.savePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('已删除部分下载文件: ${task.savePath}');
        }
      }
    } catch (e) {
      debugPrint('删除部分下载文件失败: $e');
    }
    
    // 清理节流记录
    _lastDbWriteTime.remove(taskId);
    
    try {
      await _db.deleteDownloadTask(taskId);
    } catch (e) {
      debugPrint('取消任务删除数据库记录失败: $e');
      // 即使删除失败也继续清理内存状态
    }
    
    // 从进度通知器中移除
    final updated = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated.remove(taskId);
    progressNotifier.value = updated;
    
    debugPrint('任务已取消: $taskId');
  }

  /// 重试任务
  Future<void> retryTask(String taskId) async {
    await _updateTaskStatus(taskId, DownloadStatus.downloading, error: null);
    await startDownload(taskId);
  }

  /// 删除任务
  Future<void> deleteTask(String taskId) async {
    debugPrint('删除任务: $taskId');
    final token = _cancelTokens[taskId];
    if (token != null) {
      token.cancel('Deleted by user');
      _cancelTokens.remove(taskId);
      // 等待 dio 的 catch 回调处理完毕
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    // 删除已下载的文件
    try {
      final task = await _db.getDownloadTask(taskId);
      if (task != null) {
        final file = File(task.savePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('已删除下载文件: ${task.savePath}');
        }
      }
    } catch (e) {
      debugPrint('删除下载文件失败: $e');
    }
    
    // 清理节流记录
    _lastDbWriteTime.remove(taskId);
    
    try {
      await _db.deleteDownloadTask(taskId);
    } catch (e) {
      debugPrint('删除任务数据库记录失败: $e');
    }
    
    // 从进度通知器中移除
    final updated = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated.remove(taskId);
    progressNotifier.value = updated;
    
    debugPrint('任务已删除: $taskId');
  }

  /// 释放资源
  void dispose() {
    for (final token in _cancelTokens.values) {
      token.cancel('Manager disposed');
    }
    _cancelTokens.clear();
    _expectedHashes.clear();
    _hashAlgorithms.clear();
    _lastDbWriteTime.clear();
    progressNotifier.dispose();
  }

  /// 计算文件哈希值（SHA256）
  Future<String?> _calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('计算文件哈希失败: $e');
      return null;
    }
  }

  /// 验证文件哈希
  Future<bool> verifyFileHash(String filePath, String expectedHash) async {
    final actualHash = await _calculateFileHash(filePath);
    if (actualHash == null) return false;
    return actualHash.toLowerCase() == expectedHash.toLowerCase();
  }

  /// 获取下载任务的文件哈希
  Future<String?> getDownloadedFileHash(String taskId) async {
    final task = await _db.getDownloadTask(taskId);
    if (task == null) return null;

    return await _calculateFileHash(task.savePath);
  }
}

/// 下载进度信息
class DownloadProgress {
  final String taskId;
  final String modelId;
  final DownloadStatus status;
  final double progress; // 0.0 - 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String? error;
  final String? hash; // 文件哈希值

  DownloadProgress({
    required this.taskId,
    required this.modelId,
    required this.status,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    this.error,
    this.hash,
  });

  /// 进度百分比
  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';

  /// 已下载大小（MB）
  String get downloadedMB => '${(downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB';

  /// 总大小（MB）
  String get totalMB => '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';

  /// 总大小（GB）
  String get totalGB => '${(totalBytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';

  /// 是否完成
  bool get isCompleted => status == DownloadStatus.completed;

  /// 是否错误
  bool get isError => status == DownloadStatus.error;

  /// 是否可恢复
  bool get canResume => status == DownloadStatus.paused || status == DownloadStatus.error;
}
