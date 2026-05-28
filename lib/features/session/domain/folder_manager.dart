import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../core/storage/database.dart';
import '../../../core/storage/database_connection.dart';
import '../data/repositories/session_repository.dart';

/// 文件夹管理器
class FolderManager {
  final AppDatabase _db = database;
  final _uuid = const Uuid();
  final SessionRepository _sessionRepository;

  FolderManager({SessionRepository? sessionRepository})
      : _sessionRepository = sessionRepository ?? SessionRepository();

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

    await _db.into(_db.folders).insert(folder);
    return (await _db.getFolder(id))!;
  }

  /// 更新文件夹
  Future<void> updateFolder(Folder folder) async {
    final updates = FoldersCompanion(
      id: Value(folder.id),
      name: Value(folder.name),
      color: Value(folder.color),
      icon: Value(folder.icon),
      sortOrder: Value(folder.sortOrder),
      updatedAt: Value(DateTime.now()),
    );

    await _db.updateFolder(updates);
  }

  /// 删除文件夹
  /// 删除前会将该文件夹下的所有会话移动到未分类（folderId设为null）
  Future<void> deleteFolder(String folderId) async {
    // 1. 将该文件夹下的所有会话移动到未分类
    final sessionsInFolder = await _db.getSessionsByFolder(folderId);
    for (final session in sessionsInFolder) {
      await _sessionRepository.updateSession(
        id: session.id,
        folderId: null,
      );
    }

    // 2. 删除文件夹
    await _db.deleteFolder(folderId);
  }

  /// 获取所有文件夹
  Future<List<Folder>> getFolders() async {
    return await _db.getAllFolders();
  }

  /// 获取单个文件夹
  Future<Folder?> getFolder(String id) async {
    return await _db.getFolder(id);
  }

  /// 移动会话到文件夹
  Future<void> moveSessionToFolder(String sessionId, String? folderId) async {
    await _sessionRepository.updateSession(
      id: sessionId,
      folderId: folderId,
    );
  }

  /// 置顶/取消置顶会话
  Future<void> pinSession(String sessionId, bool isPinned) async {
    await _sessionRepository.updateSession(
      id: sessionId,
      isPinned: isPinned,
    );
  }

  /// 归档/取消归档会话
  Future<void> archiveSession(String sessionId, bool isArchived) async {
    await _sessionRepository.updateSession(
      id: sessionId,
      isArchived: isArchived,
    );
  }

  /// 获取归档会话列表
  Future<List<Session>> getArchivedSessions() async {
    return await _db.getArchivedSessions();
  }

  /// 获取指定文件夹下的会话
  Future<List<Session>> getSessionsInFolder(String folderId) async {
    return await _db.getSessionsByFolder(folderId);
  }

  /// 获取未分类的会话（不在任何文件夹中）
  Future<List<Session>> getUncategorizedSessions() async {
    return await _db.getUncategorizedSessions();
  }

  /// 获取所有非归档会话（按置顶状态和更新时间排序）
  Future<List<Session>> getAllActiveSessions() async {
    return await _db.getAllActiveSessions();
  }

  /// 重命名文件夹
  Future<void> renameFolder(String folderId, String newName) async {
    final folder = await getFolder(folderId);
    if (folder != null) {
      final updated = folder.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await updateFolder(updated);
    }
  }

  /// 更新文件夹排序
  Future<void> updateFolderOrder(List<String> folderIds) async {
    for (int i = 0; i < folderIds.length; i++) {
      final folder = await getFolder(folderIds[i]);
      if (folder != null) {
        final updated = folder.copyWith(
          sortOrder: i,
          updatedAt: DateTime.now(),
        );
        await updateFolder(updated);
      }
    }
  }
}

/// Riverpod Provider
final folderManagerProvider = Provider<FolderManager>((ref) {
  return FolderManager();
});

/// 文件夹状态Provider
final foldersProvider = FutureProvider<List<Folder>>((ref) async {
  final manager = ref.watch(folderManagerProvider);
  return await manager.getFolders();
});

/// 归档会话Provider
final archivedSessionsProvider = FutureProvider<List<Session>>((ref) async {
  final manager = ref.watch(folderManagerProvider);
  return await manager.getArchivedSessions();
});
