import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../core/storage/database.dart';
import '../../../core/storage/database_connection.dart';

/// 文件夹服务
class FolderService {
  final AppDatabase _db = database;
  final _uuid = const Uuid();

  /// 创建文件夹
  Future<Folder> createFolder({
    required String name,
    String color = '#007AFF',
    String icon = 'folder',
    int sortOrder = 0,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final folder = FoldersCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.insertFolder(folder);
    return (await _db.getFolder(id))!;
  }

  /// 获取所有文件夹
  Future<List<Folder>> getAllFolders() async {
    return await _db.getAllFolders();
  }

  /// 获取文件夹
  Future<Folder?> getFolder(String id) async {
    return await _db.getFolder(id);
  }

  /// 更新文件夹
  Future<Folder> updateFolder({
    required String id,
    String? name,
    String? color,
    String? icon,
    int? sortOrder,
  }) async {
    final folder = FoldersCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      icon: icon != null ? Value(icon) : const Value.absent(),
      sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await _db.updateFolder(folder);
    return (await _db.getFolder(id))!;
  }

  /// 删除文件夹
  Future<void> deleteFolder(String id) async {
    // 将文件夹下的会话移动到未分类
    final sessionsInFolder = await _db.getSessionsByFolder(id);
    for (final session in sessionsInFolder) {
      await _db.updateSession(
        SessionsCompanion(
          id: Value(session.id),
          folderId: const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }

    await _db.deleteFolder(id);
  }

  /// 移动会话到文件夹
  Future<void> moveSessionToFolder(String sessionId, String? folderId) async {
    await _db.updateSession(
      SessionsCompanion(
        id: Value(sessionId),
        folderId: folderId != null ? Value(folderId) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 置顶/取消置顶会话
  Future<void> togglePinSession(String sessionId, bool isPinned) async {
    await _db.updateSession(
      SessionsCompanion(
        id: Value(sessionId),
        isPinned: Value(isPinned),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 归档/取消归档会话
  Future<void> toggleArchiveSession(String sessionId, bool isArchived) async {
    await _db.updateSession(
      SessionsCompanion(
        id: Value(sessionId),
        isArchived: Value(isArchived),
        // 归档时移除文件夹关联
        folderId: isArchived ? const Value.absent() : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 获取文件夹下的会话
  Future<List<Session>> getSessionsByFolder(String folderId) async {
    return await _db.getSessionsByFolder(folderId);
  }

  /// 获取未分类会话
  Future<List<Session>> getUncategorizedSessions() async {
    return await _db.getUncategorizedSessions();
  }

  /// 获取归档会话
  Future<List<Session>> getArchivedSessions() async {
    return await _db.getArchivedSessions();
  }

  /// 获取所有活动会话（非归档）
  Future<List<Session>> getAllActiveSessions() async {
    return await _db.getAllActiveSessions();
  }

  /// 更新文件夹排序
  Future<void> reorderFolders(List<String> folderIds) async {
    for (int i = 0; i < folderIds.length; i++) {
      await updateFolder(id: folderIds[i], sortOrder: i);
    }
  }
}

/// 文件夹状态
class FolderState {
  final List<Folder> folders;
  final List<Session> uncategorizedSessions;
  final List<Session> archivedSessions;
  final bool isLoading;
  final String? error;

  const FolderState({
    this.folders = const [],
    this.uncategorizedSessions = const [],
    this.archivedSessions = const [],
    this.isLoading = false,
    this.error,
  });

  FolderState copyWith({
    List<Folder>? folders,
    List<Session>? uncategorizedSessions,
    List<Session>? archivedSessions,
    bool? isLoading,
    String? error,
  }) {
    return FolderState(
      folders: folders ?? this.folders,
      uncategorizedSessions: uncategorizedSessions ?? this.uncategorizedSessions,
      archivedSessions: archivedSessions ?? this.archivedSessions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 文件夹颜色选项
class FolderColors {
  static const List<String> colors = [
    '#007AFF', // 蓝色
    '#34C759', // 绿色
    '#FF9500', // 橙色
    '#FF3B30', // 红色
    '#AF52DE', // 紫色
    '#5856D6', // 靛蓝
    '#FF2D55', // 粉红
    '#5AC8FA', // 青色
    '#FFCC00', // 黄色
    '#8E8E93', // 灰色
  ];

  static const List<String> icons = [
    'folder',
    'folder_open',
    'work',
    'school',
    'favorite',
    'star',
    'bookmark',
    'label',
    'chat',
    'computer',
  ];
}
