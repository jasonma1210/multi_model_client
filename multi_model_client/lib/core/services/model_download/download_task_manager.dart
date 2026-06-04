import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:background_downloader/background_downloader.dart' as bgd;

import '../../storage/database.dart';
import '../../storage/database_connection.dart';

/// 下载任务状态
enum DownloadStatus {
  pending,      // 等待中
  downloading,  // 下载中
  paused,       // 已暂停
  completed,    // 已完成
  error,        // 错误
  failed,       // 永久失败（超过最大重试次数）
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

  /// 复制并更新状态
  DownloadProgress copyWith({
    String? taskId,
    String? modelId,
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    String? error,
    String? hash,
  }) {
    return DownloadProgress(
      taskId: taskId ?? this.taskId,
      modelId: modelId ?? this.modelId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
      hash: hash ?? this.hash,
    );
  }
}

/// 下载任务管理器（单例模式）
///
/// 使用 background_downloader 实现原生后台下载，相比 Dio：
/// 1. App 被划掉后仍能继续下载（Android WorkManager / iOS BackgroundSession）
/// 2. 自动支持断点续传
/// 3. 稳定的暂停/恢复/取消
///
/// 核心功能保证：
/// - 下载能够开始：自动重试机制，最多3次
/// - 正确的进度显示：实时更新，支持断点续传
/// - 能够暂停：完整支持 pause/resume
/// - 能够结束：支持取消下载，清理资源
/// - 文件完整性：文件大小验证 + SHA256 哈希校验（可选）
class DownloadTaskManager {
  static DownloadTaskManager? _instance;

  final AppDatabase _db = database;
  final _uuid = const Uuid();

  // 任务重试配置
  static const int maxRetries = 3;
  final Map<String, int> _retryCount = {};

  // 进度通知器
  final ValueNotifier<Map<String, DownloadProgress>> progressNotifier =
      ValueNotifier<Map<String, DownloadProgress>>({});

  // 存储预期哈希值
  final Map<String, String> _expectedHashes = {};

  // 存储 taskId -> modelId 映射
  final Map<String, String> _taskModelMap = {};

  // 存储 taskId -> totalBytes（从下载任务获取）
  final Map<String, int> _taskTotalBytes = {};

  // 存储 taskId -> 下载 URL（用于恢复下载）
  final Map<String, String> _taskUrls = {};

  // 存储 taskId -> 保存路径（用于恢复下载）
  final Map<String, String> _taskPaths = {};

  // 标记是否已初始化
  bool _isInitialized = false;

  // 活跃监听器计数（防止重复初始化）
  bool _listenerSetup = false;

  /// 获取单例实例
  static DownloadTaskManager get instance {
    _instance ??= DownloadTaskManager._internal();
    return _instance!;
  }

  /// 内部构造函数（私有）
  DownloadTaskManager._internal();

  /// 初始化单例（必须在使用前调用）
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[DownloadTaskManager] 单例已初始化，跳过');
      return;
    }

    debugPrint('[DownloadTaskManager] 开始初始化...');

    try {
      // 启动 background_downloader（v9.x 必须调用）
      await bgd.FileDownloader().start();
      debugPrint('[DownloadTaskManager] background_downloader 启动成功');

      // 设置后台下载任务更新监听（只设置一次）
      if (!_listenerSetup) {
        _setupDownloadListener();
        _listenerSetup = true;
      }

      // 注册 App 生命周期监听
      _setupLifecycleObserver();

      _isInitialized = true;
      debugPrint('[DownloadTaskManager] ✅ 单例初始化完成');
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 初始化失败: $e');
      rethrow;
    }
  }

  /// 设置下载任务更新监听
  void _setupDownloadListener() {
    debugPrint('[DownloadTaskManager] 设置下载任务监听器...');

    bgd.FileDownloader().updates.listen(
      (update) {
        if (update is bgd.TaskProgressUpdate) {
          _onProgressUpdate(update);
        } else if (update is bgd.TaskStatusUpdate) {
          _onStatusUpdate(update);
        }
      },
      onError: (e) {
        debugPrint('[DownloadTaskManager] ❌ 监听器错误: $e');
      },
    );

    debugPrint('[DownloadTaskManager] 下载任务监听器设置完成');
  }

  /// 进度平滑处理：防止跳跃
  final Map<String, double> _lastProgress = {};

  /// 处理进度更新
  void _onProgressUpdate(bgd.TaskProgressUpdate update) {
    final taskId = update.task.taskId;
    final modelId = _taskModelMap[taskId] ?? '';

    // 从 update 获取原始进度（0.0 - 1.0）
    final rawProgress = update.progress.clamp(0.0, 1.0);

    // 获取文件总大小
    int totalBytes = _taskTotalBytes[taskId] ?? 0;

    // 如果 totalBytes 为 0，尝试从 expectedFileSize 获取
    if (totalBytes <= 0 && update.hasExpectedFileSize && update.expectedFileSize > 0) {
      totalBytes = update.expectedFileSize;
      _taskTotalBytes[taskId] = totalBytes;
      debugPrint('[DownloadTaskManager] 获取到文件大小: $totalBytes bytes');

      // 立即更新数据库中的 totalBytes
      _db.updateDownloadTask(DownloadTasksCompanion(
        id: Value(taskId),
        totalBytes: Value(totalBytes),
      )).catchError((e) {
        debugPrint('[DownloadTaskManager] 更新 totalBytes 失败: $e');
        return 0; // 返回默认值以满足类型要求
      });
    }

    // 计算已下载字节数
    int downloadedBytes;
    double displayProgress;

    if (totalBytes > 0) {
      downloadedBytes = (rawProgress * totalBytes).round();
      displayProgress = rawProgress;
    } else {
      // 如果不知道总大小，使用原始进度作为估算
      downloadedBytes = 0;
      displayProgress = rawProgress;
    }

    // 🔧 进度平滑处理：防止异常跳跃
    // 断点续传时进度回退是正常的（44%→34%），不需要过滤
    // 只有在 totalBytes 变化时可能出现计算跳跃，此时记录当前进度即可
    _lastProgress[taskId] = displayProgress;

    // 更新进度通知器
    final progressInfo = DownloadProgress(
      taskId: taskId,
      modelId: modelId,
      status: DownloadStatus.downloading,
      progress: displayProgress,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
    );

    progressNotifier.value = {
      ...progressNotifier.value,
      taskId: progressInfo,
    };

    // 更新数据库（节流：每 2 秒更新一次）
    _throttledDbUpdate(taskId, downloadedBytes, totalBytes, (displayProgress * 100).round());
  }

  /// 节流更新数据库
  final Map<String, DateTime> _lastDbWriteTime = {};

  void _throttledDbUpdate(String taskId, int downloadedBytes, int totalBytes, int progressPercent) {
    final now = DateTime.now();
    final lastWrite = _lastDbWriteTime[taskId];

    if (lastWrite == null || now.difference(lastWrite).inMilliseconds >= 2000) {
      _lastDbWriteTime[taskId] = now;
      _db.updateDownloadTask(DownloadTasksCompanion(
        id: Value(taskId),
        downloadedBytes: Value(downloadedBytes),
        totalBytes: Value(totalBytes > 0 ? totalBytes : 0),
        progress: Value(progressPercent.clamp(0, 100)),
      )).catchError((e) {
        debugPrint('[DownloadTaskManager] 数据库更新失败: $e');
        return 0; // 返回默认值以满足类型要求
      });
    }
  }

  /// 处理状态更新
  Future<void> _onStatusUpdate(bgd.TaskStatusUpdate update) async {
    final taskId = update.task.taskId;
    final modelId = _taskModelMap[taskId] ?? '';

    // 转换状态
    final status = _mapBgdStatus(update.status);

    debugPrint('[DownloadTaskManager] 📋 状态更新: taskId=$taskId, bgdStatus=${update.status} → $status');

    switch (status) {
      case DownloadStatus.completed:
        await _handleDownloadComplete(taskId, modelId, update.task.filename);
        break;

      case DownloadStatus.paused:
        await _handleDownloadPaused(taskId, modelId);
        break;

      case DownloadStatus.error:
      case DownloadStatus.failed:
        final errorMsg = update.exception?.toString() ?? '下载失败';
        await _handleDownloadError(taskId, modelId, errorMsg);
        break;

      case DownloadStatus.downloading:
        // 检查是否从暂停状态恢复，如果是则更新数据库状态
        final currentTask = await _db.getDownloadTask(taskId);
        if (currentTask != null && currentTask.status == 'paused') {
          debugPrint('[DownloadTaskManager] 🔄 检测到从暂停恢复，更新数据库状态: $taskId');
          await _updateTaskStatus(taskId, DownloadStatus.downloading);
        }
        break;

      case DownloadStatus.pending:
        // 等待中，不需要额外处理
        break;
    }
  }

  /// 映射 background_downloader 状态到本地状态
  DownloadStatus _mapBgdStatus(bgd.TaskStatus status) {
    switch (status) {
      case bgd.TaskStatus.enqueued:
      case bgd.TaskStatus.waitingToRetry:
      case bgd.TaskStatus.running:
        return DownloadStatus.downloading;
      case bgd.TaskStatus.paused:
        return DownloadStatus.paused;
      case bgd.TaskStatus.complete:
        return DownloadStatus.completed;
      case bgd.TaskStatus.failed:
        return DownloadStatus.failed;
      case bgd.TaskStatus.canceled:
      case bgd.TaskStatus.notFound:
        return DownloadStatus.error;
    }
  }

  /// 处理下载暂停
  Future<void> _handleDownloadPaused(String taskId, String modelId) async {
    debugPrint('[DownloadTaskManager] ⏸️ 任务已暂停: $taskId');

    await _updateTaskStatus(taskId, DownloadStatus.paused);

    // 获取当前进度并更新状态为 paused
    final currentProgress = progressNotifier.value[taskId];
    if (currentProgress != null) {
      final pausedProgress = currentProgress.copyWith(status: DownloadStatus.paused);
      progressNotifier.value = {
        ...progressNotifier.value,
        taskId: pausedProgress,
      };
    }
  }

  /// 处理下载完成
  Future<void> _handleDownloadComplete(String taskId, String modelId, String filename) async {
    debugPrint('[DownloadTaskManager] ✅ 下载完成，开始验证: $taskId');

    try {
      // 从数据库获取任务信息
      final task = await _db.getDownloadTask(taskId);
      if (task == null) {
        debugPrint('[DownloadTaskManager] ❌ 任务不存在: $taskId');
        return;
      }

      final effectiveModelId = task.modelId;
      final savePath = task.savePath;
      final expectedSize = task.totalBytes;

      debugPrint('[DownloadTaskManager] 任务详情: modelId=$effectiveModelId, path=$savePath, expectedSize=$expectedSize');

      // 验证保存路径
      if (savePath.isEmpty) {
        await _handleDownloadError(taskId, effectiveModelId, '保存路径为空');
        return;
      }

      var file = File(savePath);

      // 验证文件是否存在
      if (!await file.exists()) {
        // 数据库中的 savePath 找不到文件，尝试从 background_downloader 的实际路径查找
        debugPrint('[DownloadTaskManager] ⚠️ savePath 未找到文件: $savePath，尝试查找实际路径...');

        // 尝试通过 bgd.Task.filePath() 获取实际文件位置
        try {
          final allTasks = await bgd.FileDownloader().allTasks();
          final bgdTask = allTasks.where((t) => t.taskId == taskId).firstOrNull as bgd.DownloadTask?;
          if (bgdTask != null) {
            final actualPath = await bgdTask.filePath();
            debugPrint('[DownloadTaskManager] bgd 实际路径: $actualPath');
            final actualFile = File(actualPath);
            if (await actualFile.exists()) {
              // 找到了！将文件移动到正确的 savePath
              debugPrint('[DownloadTaskManager] 📦 在 bgd 路径找到文件，移动到正确位置...');
              final targetDir = Directory(savePath.substring(0, savePath.lastIndexOf('/')));
              if (!await targetDir.exists()) {
                await targetDir.create(recursive: true);
              }
              await actualFile.rename(savePath);
              file = File(savePath);
              debugPrint('[DownloadTaskManager] ✅ 文件已移动到: $savePath');
            }
          }
        } catch (e) {
          debugPrint('[DownloadTaskManager] 查找 bgd 路径失败: $e');
        }

        // 再次检查
        if (!await file.exists()) {
          debugPrint('[DownloadTaskManager] ❌ 文件不存在: $savePath');
          await _handleDownloadError(taskId, effectiveModelId, '文件未找到: $savePath');
          return;
        }
      }

      // 获取实际文件大小
      final fileSize = await file.length();
      debugPrint('[DownloadTaskManager] 文件大小: $fileSize bytes');

      // 验证文件大小（防止下载到错误页面）
      if (fileSize < 1024) {
        // 文件太小，可能是错误页面或重定向
        final content = await file.readAsString().catchError((_) => '');
        final displayContent = content.length > 200 ? content.substring(0, 200) : content;
        debugPrint('[DownloadTaskManager] ❌ 文件内容前200字符: $displayContent');
        await _handleDownloadError(taskId, effectiveModelId, '文件大小异常: $fileSize bytes（可能是下载失败或访问了错误页面）');
        return;
      }

      // 如果有预期大小，验证是否匹配
      if (expectedSize > 0) {
        // 允许 1% 的误差（处理某些服务器返回不精确大小的情况）
        final sizeDiff = (fileSize - expectedSize).abs();
        final tolerance = expectedSize * 0.01;
        if (sizeDiff > tolerance) {
          debugPrint('[DownloadTaskManager] ⚠️ 文件大小不匹配: 预期 $expectedSize, 实际 $fileSize, 误差 ${(sizeDiff / expectedSize * 100).toStringAsFixed(1)}%');
          // 不强制失败，允许继续
        } else {
          debugPrint('[DownloadTaskManager] ✅ 文件大小验证通过 (误差 ${(sizeDiff / expectedSize * 100).toStringAsFixed(1)}%)');
        }
      }

      // 如果有预期哈希，执行哈希验证
      final expectedHash = _expectedHashes[taskId];
      if (expectedHash != null && expectedHash.isNotEmpty) {
        debugPrint('[DownloadTaskManager] 🔐 开始哈希验证...');
        final actualHash = await _calculateFileHashInBackground(savePath);
        if (actualHash != null) {
          if (actualHash.toLowerCase() == expectedHash.toLowerCase()) {
            debugPrint('[DownloadTaskManager] ✅ 哈希验证通过: $actualHash');
          } else {
            debugPrint('[DownloadTaskManager] ❌ 哈希验证失败: 预期 $expectedHash, 实际 $actualHash');
            await _handleDownloadError(taskId, effectiveModelId, '哈希验证失败，文件可能已损坏');
            return;
          }
        } else {
          debugPrint('[DownloadTaskManager] ⚠️ 哈希计算失败，跳过验证');
        }
      }

      // 更新数据库为完成状态
      await _db.updateDownloadTask(DownloadTasksCompanion(
        id: Value(taskId),
        status: Value(DownloadStatus.completed.name),
        downloadedBytes: Value(fileSize),
        totalBytes: Value(fileSize),
        progress: const Value(100),
        completedAt: Value(DateTime.now()),
      ));

      // 更新进度通知器
      final completedProgress = DownloadProgress(
        taskId: taskId,
        modelId: effectiveModelId,
        status: DownloadStatus.completed,
        progress: 1.0,
        downloadedBytes: fileSize,
        totalBytes: fileSize,
      );

      progressNotifier.value = {
        ...progressNotifier.value,
        taskId: completedProgress,
      };

      debugPrint('[DownloadTaskManager] ✅ 下载完成: $filename ($fileSize bytes)');

      // 清理
      _expectedHashes.remove(taskId);
      _retryCount.remove(taskId);
      _taskTotalBytes.remove(taskId);
      _lastDbWriteTime.remove(taskId);

    } catch (e, stack) {
      debugPrint('[DownloadTaskManager] ❌ 下载完成处理异常: $e\n$stack');
      await _handleDownloadError(taskId, modelId, '下载完成处理失败: $e');
    }
  }

  /// 处理下载错误
  Future<void> _handleDownloadError(String taskId, String modelId, String error) async {
    debugPrint('[DownloadTaskManager] ❌ 下载错误: $taskId - $error');

    // 检查是否超过最大重试次数
    final retries = (_retryCount[taskId] ?? 0) + 1;
    _retryCount[taskId] = retries;

    if (retries < maxRetries) {
      debugPrint('[DownloadTaskManager] 🔄 第 $retries/$maxRetries 次重试: $taskId');
      // background_downloader 会自动重试
      return;
    }

    debugPrint('[DownloadTaskManager] ❌ 超过最大重试次数 ($maxRetries)，标记为失败');

    await _updateTaskStatus(taskId, DownloadStatus.error, error: error);

    // 获取当前进度信息
    final currentProgress = progressNotifier.value[taskId];

    final errorProgress = DownloadProgress(
      taskId: taskId,
      modelId: modelId,
      status: DownloadStatus.error,
      progress: currentProgress?.progress ?? 0.0,
      downloadedBytes: currentProgress?.downloadedBytes ?? 0,
      totalBytes: currentProgress?.totalBytes ?? 0,
      error: error,
    );

    progressNotifier.value = {
      ...progressNotifier.value,
      taskId: errorProgress,
    };
  }

  /// App 生命周期观察者
  void _setupLifecycleObserver() {
    WidgetsBinding.instance.addObserver(
      _AppLifecycleObserver(
        onResume: _onAppResumed,
        onPause: _onAppPaused,
      ),
    );
    debugPrint('[DownloadTaskManager] 生命周期观察者已注册');
  }

  void _onAppPaused() {
    debugPrint('[DownloadTaskManager] ⏸️ App 进入后台，下载继续（background_downloader 托管）');
  }

  void _onAppResumed() {
    debugPrint('[DownloadTaskManager] ▶️ App 恢复，检查下载状态');
    // 恢复后台任务
    bgd.FileDownloader().resumeFromBackground();
    // 同步数据库中的任务状态
    _syncTaskStatus();
  }

  /// 同步任务状态
  Future<void> _syncTaskStatus() async {
    debugPrint('[DownloadTaskManager] 同步任务状态...');

    try {
      final tasks = await _db.getAllDownloadTasks();
      final allBgdTasks = await bgd.FileDownloader().allTasks();

      for (final task in tasks) {
        if (task.status == 'downloading' || task.status == 'pending') {
          // 检查任务是否仍在 background_downloader 中
          final found = allBgdTasks.any((t) => t.taskId == task.id);

          if (!found) {
            debugPrint('[DownloadTaskManager] 任务不在队列中: ${task.id}，检查文件状态...');

            // 任务不在队列中，可能已完成或失败
            final file = File(task.savePath);
            if (await file.exists()) {
              final fileSize = await file.length();
              final totalSize = task.totalBytes;

              if (totalSize > 0 && (fileSize - totalSize).abs() < totalSize * 0.01) {
                // 文件大小匹配，认为已完成
                await _db.updateDownloadTask(DownloadTasksCompanion(
                  id: Value(task.id),
                  status: Value(DownloadStatus.completed.name),
                  downloadedBytes: Value(fileSize),
                  progress: const Value(100),
                  completedAt: Value(DateTime.now()),
                ));
                debugPrint('[DownloadTaskManager] ✅ 任务已完成: ${task.id}');
              } else {
                // 文件不完整，设为错误
                await _db.updateDownloadTask(DownloadTasksCompanion(
                  id: Value(task.id),
                  status: Value(DownloadStatus.error.name),
                  error: Value('文件不完整: $fileSize / $totalSize bytes'),
                ));
                debugPrint('[DownloadTaskManager] ❌ 文件不完整: ${task.id}');
              }
            } else {
              // 文件不存在，设为错误
              await _db.updateDownloadTask(DownloadTasksCompanion(
                id: Value(task.id),
                status: Value(DownloadStatus.error.name),
                error: const Value('文件不存在'),
              ));
              debugPrint('[DownloadTaskManager] ❌ 文件不存在: ${task.id}');
            }
          }
        }
      }

      debugPrint('[DownloadTaskManager] 任务状态同步完成');
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 同步任务状态失败: $e');
    }
  }

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 创建下载任务
  ///
  /// [modelId] 模型唯一标识
  /// [url] 下载 URL
  /// [savePath] 保存路径（包含文件名）
  /// [source] 来源（HuggingFace / ModelScope / Local）
  /// [quantLevel] 量化等级（Q4_K_M, Q8_0 等）
  /// [metadata] 额外元数据
  /// [expectedHash] 预期文件哈希（可选，用于完整性校验）
  Future<DownloadTask> createTask({
    required String modelId,
    required String url,
    required String savePath,
    required String source,
    String? quantLevel,
    Map<String, dynamic>? metadata,
    String? expectedHash,
    String? hashAlgorithm,
  }) async {
    debugPrint('[DownloadTaskManager] 创建下载任务: modelId=$modelId, url=$url');

    // 检查是否已有相同 modelId + savePath 的任务
    final existingTasks = await _db.getAllDownloadTasks();
    final duplicateTask = existingTasks.where((t) =>
      t.modelId == modelId && t.savePath == savePath &&
      (t.status == 'completed' || t.status == 'downloading' || t.status == 'pending')
    ).firstOrNull;

    if (duplicateTask != null) {
      debugPrint('[DownloadTaskManager] 发现重复下载任务，复用: ${duplicateTask.id}');
      return duplicateTask;
    }

    // 生成任务 ID（使用 UUID）
    final taskId = _uuid.v4();
    final now = DateTime.now();

    final task = DownloadTasksCompanion(
      id: Value(taskId),
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
    debugPrint('[DownloadTaskManager] 任务已存入数据库: $taskId');

    // 存储哈希值
    if (expectedHash != null && expectedHash.isNotEmpty) {
      _expectedHashes[taskId] = expectedHash;
      debugPrint('[DownloadTaskManager] 存储预期哈希: ${expectedHash.substring(0, 8)}...');
    }

    // 存储 taskId -> modelId 映射
    _taskModelMap[taskId] = modelId;

    // 存储 URL 和路径（用于恢复下载）
    _taskUrls[taskId] = url;
    _taskPaths[taskId] = savePath;

    return (await _db.getDownloadTask(taskId))!;
  }

  /// 开始下载
  ///
  /// 使用 background_downloader 实现后台下载：
  /// 1. App 被划掉后仍能继续下载
  /// 2. 自动支持断点续传
  /// 3. 稳定的暂停/恢复/取消
  Future<void> startDownload(String taskId, {Function(DownloadProgress)? onProgress}) async {
    debugPrint('[DownloadTaskManager] 🚀 开始下载: $taskId');

    final task = await _db.getDownloadTask(taskId);
    if (task == null) {
      debugPrint('[DownloadTaskManager] ❌ 任务不存在: $taskId');
      throw StateError('Task not found: $taskId');
    }

    // 检查任务是否已完成
    if (task.status == 'completed') {
      debugPrint('[DownloadTaskManager] 任务已完成，跳过: $taskId');
      onProgress?.call(DownloadProgress(
        taskId: taskId,
        modelId: task.modelId,
        status: DownloadStatus.completed,
        progress: 1.0,
        downloadedBytes: task.totalBytes,
        totalBytes: task.totalBytes,
      ));
      return;
    }

    // 检查文件是否已存在（用于断点续传）
    final file = File(task.savePath);
    final existingSize = await file.exists() ? await file.length() : 0;
    debugPrint('[DownloadTaskManager] 已有文件大小: $existingSize bytes');

    // 获取文件总大小
    int totalBytes = task.totalBytes;
    if (totalBytes <= 0) {
      totalBytes = _taskTotalBytes[taskId] ?? 0;
    }

    // 创建 background_downloader 任务
    //
    // ⚠️ 关键路径配置说明：
    // background_downloader 的 filePath = p.join(baseDirectoryPath, directory, filename)
    // - 如果 baseDirectory = applicationDocuments，会加上 getApplicationDocumentsDirectory() 前缀
    // - 如果 directory 传完整绝对路径，会导致路径重复拼接
    //   例如：/Data/Documents + /Data/Documents/models = /Data/Documents/Data/Documents/models（错误！）
    // - 解决方案：使用 BaseDirectory.root（base路径为 "/"），directory 传完整绝对路径
    //
    // 最终路径：p.join("/", "/Data/Documents/models", "file.gguf") = "/Data/Documents/models/file.gguf" ✅
    final saveDir = task.savePath.substring(0, task.savePath.lastIndexOf('/'));
    final saveFileName = task.savePath.split('/').last;

    final bgdTask = bgd.DownloadTask(
      taskId: taskId,
      url: task.url,
      filename: saveFileName,
      directory: saveDir,
      baseDirectory: bgd.BaseDirectory.root,
      retries: maxRetries - (_retryCount[taskId] ?? 0),
      updates: bgd.Updates.statusAndProgress, // 同时监听状态和进度
      allowPause: true, // 允许暂停和自动恢复（断点续传）
      // 存储额外信息
      metaData: '{"modelId":"${task.modelId}","totalBytes":$totalBytes}',
      // 添加必要的请求头，模拟浏览器访问
      headers: const {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': '*/*',
        'Accept-Encoding': 'identity', // 禁用压缩，确保文件完整性
        'Connection': 'keep-alive',
      },
    );

    // 存储映射信息
    _taskModelMap[taskId] = task.modelId;
    _taskUrls[taskId] = task.url;
    _taskPaths[taskId] = task.savePath;

    if (totalBytes > 0) {
      _taskTotalBytes[taskId] = totalBytes;
    }

    // 更新状态为下载中
    await _updateTaskStatus(taskId, DownloadStatus.downloading);

    // 如果有断点，显示续传进度
    if (existingSize > 0 && totalBytes > 0) {
      final resumeProgress = DownloadProgress(
        taskId: taskId,
        modelId: task.modelId,
        status: DownloadStatus.downloading,
        progress: existingSize / totalBytes,
        downloadedBytes: existingSize,
        totalBytes: totalBytes,
      );

      progressNotifier.value = {
        ...progressNotifier.value,
        taskId: resumeProgress,
      };

      debugPrint('[DownloadTaskManager] 📥 断点续传: ${(existingSize / totalBytes * 100).toStringAsFixed(1)}%');
      onProgress?.call(resumeProgress);
    }

    // 入队下载
    try {
      await bgd.FileDownloader().enqueue(bgdTask);
      debugPrint('[DownloadTaskManager] ✅ 下载任务已入队: $taskId');
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 入队失败: $e');
      await _handleDownloadError(taskId, task.modelId, '下载启动失败: $e');
      rethrow;
    }
  }

  /// 暂停下载
  Future<void> pauseDownload(String taskId) async {
    debugPrint('[DownloadTaskManager] ⏸️ 暂停下载: $taskId');

    try {
      final allTasks = await bgd.FileDownloader().allTasks();
      final bgdTask = allTasks.where((t) => t.taskId == taskId).firstOrNull as bgd.DownloadTask?;

      if (bgdTask != null) {
        final success = await bgd.FileDownloader().pause(bgdTask);
        if (success) {
          debugPrint('[DownloadTaskManager] ✅ 暂停成功: $taskId');
        } else {
          debugPrint('[DownloadTaskManager] ⚠️ 暂停失败（任务可能已结束）: $taskId');
        }
      } else {
        debugPrint('[DownloadTaskManager] ⚠️ 任务不在队列中: $taskId');
      }
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 暂停下载异常: $e');
    }
  }

  /// 恢复下载
  Future<void> resumeDownload(String taskId, {Function(DownloadProgress)? onProgress}) async {
    debugPrint('[DownloadTaskManager] ▶️ 恢复下载: $taskId');

    try {
      // 检查任务在数据库中的状态
      final dbTask = await _db.getDownloadTask(taskId);
      if (dbTask == null) {
        debugPrint('[DownloadTaskManager] ❌ 任务不存在: $taskId');
        return;
      }

      // 如果任务已完成，不需要恢复
      if (dbTask.status == 'completed') {
        debugPrint('[DownloadTaskManager] ✅ 任务已完成，无需恢复: $taskId');
        onProgress?.call(DownloadProgress(
          taskId: taskId,
          modelId: dbTask.modelId,
          status: DownloadStatus.completed,
          progress: 1.0,
          downloadedBytes: dbTask.totalBytes,
          totalBytes: dbTask.totalBytes,
        ));
        return;
      }

      // 如果任务正在下载中，也不需要恢复
      if (dbTask.status == 'downloading') {
        debugPrint('[DownloadTaskManager] ✅ 任务正在下载中: $taskId');
        return;
      }

      // 检查任务是否在后台队列中
      final allTasks = await bgd.FileDownloader().allTasks();
      final bgdTask = allTasks.where((t) => t.taskId == taskId).firstOrNull as bgd.DownloadTask?;

      if (bgdTask != null) {
        // 任务在队列中，直接恢复
        final success = await bgd.FileDownloader().resume(bgdTask);
        if (success) {
          debugPrint('[DownloadTaskManager] ✅ 恢复成功: $taskId');
          await _updateTaskStatus(taskId, DownloadStatus.downloading);
        } else {
          debugPrint('[DownloadTaskManager] ⚠️ 恢复失败: $taskId');
        }
      } else {
        // 任务不在队列中，检查文件是否存在断点
        final file = File(dbTask.savePath);
        final existingSize = await file.exists() ? await file.length() : 0;
        
        if (existingSize > 0 && dbTask.totalBytes > existingSize) {
          // 文件有部分下载，重新入队（background_downloader 会自动断点续传）
          debugPrint('[DownloadTaskManager] 📥 检测到断点，重新入队: $taskId (已有 $existingSize bytes)');
          await startDownload(taskId, onProgress: onProgress);
        } else {
          // 没有断点，重新从头开始下载
          debugPrint('[DownloadTaskManager] 🔄 无断点，重新开始下载: $taskId');
          await _updateTaskStatus(taskId, DownloadStatus.downloading);
          await startDownload(taskId, onProgress: onProgress);
        }
      }
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 恢复下载异常: $e');
    }
  }

  /// 取消下载
  Future<void> cancelDownload(String taskId) async {
    debugPrint('[DownloadTaskManager] 🛑 取消下载: $taskId');

    try {
      await bgd.FileDownloader().cancelTaskWithId(taskId);
      debugPrint('[DownloadTaskManager] background_downloader 取消成功');
    } catch (e) {
      debugPrint('[DownloadTaskManager] background_downloader 取消失败: $e');
    }

    try {
      await _db.deleteDownloadTask(taskId);
    } catch (e) {
      debugPrint('[DownloadTaskManager] 删除数据库记录失败: $e');
    }

    // 从内存中清理
    final updated1 = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated1.remove(taskId);
    progressNotifier.value = updated1;

    _cleanupTask(taskId);
    debugPrint('[DownloadTaskManager] 任务已取消: $taskId');
  }

  /// 删除已下载的文件
  Future<void> deleteDownloadedFile(String taskId) async {
    debugPrint('[DownloadTaskManager] 🗑️ 删除文件: $taskId');

    try {
      final task = await _db.getDownloadTask(taskId);
      if (task == null) return;

      final file = File(task.savePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('[DownloadTaskManager] 文件已删除: ${task.savePath}');
      }
    } catch (e) {
      debugPrint('[DownloadTaskManager] 删除文件失败: $e');
    }

    try {
      await _db.deleteDownloadTask(taskId);
    } catch (e) {
      debugPrint('[DownloadTaskManager] 删除数据库记录失败: $e');
    }

    final updated2 = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated2.remove(taskId);
    progressNotifier.value = updated2;

    _taskModelMap.remove(taskId);
    _taskTotalBytes.remove(taskId);
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
    Value<DateTime?> completedAtValue;
    if (status == DownloadStatus.completed) {
      completedAtValue = Value(DateTime.now());
    } else if (status == DownloadStatus.paused) {
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

  /// 暂停任务（与 pauseDownload 相同）
  Future<void> pauseTask(String taskId) async {
    debugPrint('[DownloadTaskManager] ⏸️ 暂停任务: $taskId');
    await pauseDownload(taskId);
  }

  /// 恢复任务（与 resumeDownload 相同）
  Future<void> resumeTask(String taskId) async {
    debugPrint('[DownloadTaskManager] ▶️ 恢复任务: $taskId');
    await resumeDownload(taskId);
  }

  /// 取消任务（同时删除文件）
  Future<void> cancelTask(String taskId) async {
    debugPrint('[DownloadTaskManager] 🛑 取消任务: $taskId');

    try {
      await bgd.FileDownloader().cancelTaskWithId(taskId);
    } catch (e) {
      debugPrint('[DownloadTaskManager] background_downloader 取消失败: $e');
    }

    // 删除部分下载文件
    try {
      final task = await _db.getDownloadTask(taskId);
      if (task != null) {
        final file = File(task.savePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('[DownloadTaskManager] 部分文件已删除: ${task.savePath}');
        }
      }
    } catch (e) {
      debugPrint('[DownloadTaskManager] 删除部分文件失败: $e');
    }

    // 删除数据库记录
    try {
      await _db.deleteDownloadTask(taskId);
    } catch (e) {
      debugPrint('[DownloadTaskManager] 删除数据库记录失败: $e');
    }

    // 从内存中清理
    final updated = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated.remove(taskId);
    progressNotifier.value = updated;

    _cleanupTask(taskId);
    debugPrint('[DownloadTaskManager] 任务已取消: $taskId');
  }

  /// 重试任务
  Future<void> retryTask(String taskId) async {
    debugPrint('[DownloadTaskManager] 🔄 重试任务: $taskId');

    await _updateTaskStatus(taskId, DownloadStatus.downloading, error: null);
    _retryCount[taskId] = 0; // 重置重试计数

    try {
      await startDownload(taskId);
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 重试失败: $e');
      await _handleDownloadError(taskId, _taskModelMap[taskId] ?? '', '重试失败: $e');
    }
  }

  /// 删除任务（同时删除文件）
  Future<void> deleteTask(String taskId) async {
    debugPrint('[DownloadTaskManager] 🗑️ 删除任务: $taskId');

    // 先从内存中清理，避免触发不必要的刷新
    _cleanupTask(taskId);
    final updated = Map<String, DownloadProgress>.from(progressNotifier.value);
    updated.remove(taskId);
    progressNotifier.value = updated;

    try {
      await bgd.FileDownloader().cancelTaskWithId(taskId);
      debugPrint('[DownloadTaskManager] 已取消 background_downloader 任务: $taskId');
    } catch (e) {
      debugPrint('[DownloadTaskManager] background_downloader 取消失败: $e');
    }

    // 删除已下载的文件
    try {
      final task = await _db.getDownloadTask(taskId);
      if (task != null) {
        final file = File(task.savePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('[DownloadTaskManager] 已删除文件: ${task.savePath}');
        }
      }
    } catch (e) {
      debugPrint('[DownloadTaskManager] 删除文件失败: $e');
    }

    // 删除数据库记录
    try {
      final deleted = await _db.deleteDownloadTask(taskId);
      debugPrint('[DownloadTaskManager] 数据库删除结果: $deleted 条记录');
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 删除数据库记录失败: $e');
      // 重新抛出异常，让调用者知道删除失败
      rethrow;
    }

    debugPrint('[DownloadTaskManager] ✅ 任务已删除: $taskId');
  }

  /// 清除已完成的任务记录（只删除记录，不删除文件）
  Future<int> clearCompletedTasks() async {
    debugPrint('[DownloadTaskManager] 清除已完成任务记录...');

    try {
      final tasks = await _db.getAllDownloadTasks();
      final completedTasks = tasks.where((t) => t.status == 'completed').toList();

      int deletedCount = 0;
      for (final task in completedTasks) {
        try {
          await _db.deleteDownloadTask(task.id);
          _taskModelMap.remove(task.id);
          _taskTotalBytes.remove(task.id);
          _taskUrls.remove(task.id);
          _taskPaths.remove(task.id);
          deletedCount++;
        } catch (e) {
          debugPrint('[DownloadTaskManager] 删除任务记录失败: ${task.id}, error: $e');
        }
      }

      debugPrint('[DownloadTaskManager] 已清除 $deletedCount 条记录');
      return deletedCount;
    } catch (e) {
      debugPrint('[DownloadTaskManager] 清除任务失败: $e');
      return 0;
    }
  }

  /// 清理任务相关的内存数据
  void _cleanupTask(String taskId) {
    _taskModelMap.remove(taskId);
    _expectedHashes.remove(taskId);
    _retryCount.remove(taskId);
    _taskTotalBytes.remove(taskId);
    _taskUrls.remove(taskId);
    _taskPaths.remove(taskId);
    _lastDbWriteTime.remove(taskId);
  }

  /// 释放资源
  void dispose() {
    debugPrint('[DownloadTaskManager] 释放资源...');
    progressNotifier.dispose();
    _expectedHashes.clear();
    _taskModelMap.clear();
    _retryCount.clear();
    _taskTotalBytes.clear();
    _taskUrls.clear();
    _taskPaths.clear();
    _lastDbWriteTime.clear();
    debugPrint('[DownloadTaskManager] 资源已释放');
  }

  /// 在后台线程计算文件哈希值
  ///
  /// 使用流式读取，避免一次性加载整个文件到内存
  /// 这样可以支持几 GB 甚至更大的文件
  Future<String?> _calculateFileHashInBackground(String filePath) async {
    try {
      debugPrint('[DownloadTaskManager] 🔐 计算文件哈希: $filePath');
      return await compute(_computeFileHash, filePath);
    } catch (e) {
      debugPrint('[DownloadTaskManager] ❌ 计算哈希失败: $e');
      return null;
    }
  }

  /// 验证文件哈希
  Future<bool> verifyFileHash(String filePath, String expectedHash) async {
    final actualHash = await _calculateFileHashInBackground(filePath);
    if (actualHash == null) return false;
    return actualHash.toLowerCase() == expectedHash.toLowerCase();
  }

  /// 获取下载任务的文件哈希
  Future<String?> getDownloadedFileHash(String taskId) async {
    final task = await _db.getDownloadTask(taskId);
    if (task == null) return null;
    return await _calculateFileHashInBackground(task.savePath);
  }
}

/// 在后台线程计算文件 SHA256 哈希
/// 
/// 使用流式读取，避免一次性加载整个文件到内存
/// 这样可以支持几 GB 甚至更大的文件
Future<String> _computeFileHash(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw Exception('File not found: $filePath');
  }
  
  final output = AccumulatorSink<Digest>();
  final input = sha256.startChunkedConversion(output);
  
  // 流式读取文件，分块处理
  await for (final chunk in file.openRead()) {
    input.add(chunk);
  }
  
  input.close();
  final digest = output.events.single;
  
  return digest.toString();
}

/// 用于累积哈希结果的辅助类
class AccumulatorSink<T> implements Sink<T> {
  final List<T> events = [];
  
  @override
  void add(T event) {
    events.add(event);
  }
  
  @override
  void close() {}
}

/// App 生命周期观察者
class _AppLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  _AppLifecycleObserver({
    required this.onResume,
    required this.onPause,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}
