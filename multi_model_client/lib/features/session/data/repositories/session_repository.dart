import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../../core/storage/database.dart';
import '../../../../core/storage/database_connection.dart';

class SessionRepository {
  final AppDatabase _db = database;
  final _uuid = const Uuid();

  Future<Session> createSession({
    required String name,
    required String modelId,
    String? folderId,
    String? systemPrompt,
    Map<String, dynamic>? inferenceParams,
    bool isSpirit = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final session = SessionsCompanion(
      id: Value(id),
      name: Value(name),
      modelId: Value(modelId),
      folderId: Value(folderId),
      systemPrompt: Value(systemPrompt),
      inferenceParams: Value(inferenceParams?.toString()),
      isSpirit: Value(isSpirit),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await _db.insertSession(session);
    return (await _db.getSession(id))!;
  }

  Future<List<Session>> getAllSessions() async {
    return await _db.getAllSessions();
  }

  Future<Session?> getSession(String id) async {
    return await _db.getSession(id);
  }

  Future<void> updateSession({
    required String id,
    String? name,
    String? modelId,
    String? folderId,
    String? systemPrompt,
    Map<String, dynamic>? inferenceParams,
    bool? isPinned,
    bool? isArchived,
    bool? enableVoiceOutput,
    String? enabledSkill,
    String? enabledKnowledgeBaseId,
  }) async {
    final updates = SessionsCompanion(
      id: Value(id),
      updatedAt: Value(DateTime.now()),
      name: name != null ? Value(name) : const Value.absent(),
      modelId: modelId != null ? Value(modelId) : const Value.absent(),
      folderId: folderId != null ? Value(folderId) : const Value.absent(),
      systemPrompt: systemPrompt != null ? Value(systemPrompt) : const Value.absent(),
      inferenceParams: inferenceParams != null ? Value(inferenceParams.toString()) : const Value.absent(),
      isPinned: isPinned != null ? Value(isPinned) : const Value.absent(),
      isArchived: isArchived != null ? Value(isArchived) : const Value.absent(),
      enableVoiceOutput: enableVoiceOutput != null ? Value(enableVoiceOutput) : const Value.absent(),
      enabledSkill: enabledSkill != null ? Value(enabledSkill) : const Value.absent(),
      enabledKnowledgeBaseId: enabledKnowledgeBaseId != null ? Value(enabledKnowledgeBaseId) : const Value.absent(),
    );

    await _db.updateSession(updates);
  }
  
  /// 更新会话的技能
  Future<void> updateEnabledSkill(String id, String? skillId) async {
    final updates = SessionsCompanion(
      id: Value(id),
      updatedAt: Value(DateTime.now()),
      enabledSkill: Value(skillId),
    );

    await _db.updateSession(updates);
  }

  Future<void> deleteSession(String id) async {
    // Delete all related data first
    await _db.deleteSessionMessages(id);

    // Delete session memories
    await (_db.delete(_db.memories)
          ..where((m) => m.sessionId.equals(id)))
        .go();

    // Delete session knowledge bases and their chunks
    final knowledgeBases = await (_db.select(_db.knowledgeBases)
          ..where((kb) => kb.sessionId.equals(id)))
        .get();

    for (final kb in knowledgeBases) {
      // Delete document chunks for this knowledge base
      await (_db.delete(_db.documentChunks)
            ..where((dc) => dc.knowledgeBaseId.equals(kb.id)))
          .go();
    }

    // Delete knowledge bases
    await (_db.delete(_db.knowledgeBases)
          ..where((kb) => kb.sessionId.equals(id)))
        .go();

    // Finally delete the session
    await _db.deleteSession(id);
  }

  /// 搜索会话（按名称模糊匹配）
  Future<List<Session>> searchSessions(String query) async {
    if (query.isEmpty) {
      return await getAllSessions();
    }
    final allSessions = await getAllSessions();
    final lowerQuery = query.toLowerCase();
    return allSessions
        .where((s) => s.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 根据会话 ID 重命名会话
  Future<void> renameSession(String id, String newName) async {
    await updateSession(id: id, name: newName);
  }

  /// 更新会话的 MCP 服务器列表
  Future<void> updateEnabledMcpServers(String id, List<String> enabledServerIds) async {
    // 使用 jsonEncode 生成正确的 JSON 数组字符串，如 ["filesystem","github"]
    final serversJson = enabledServerIds.isNotEmpty 
        ? jsonEncode(enabledServerIds)
        : null;
    
    final updates = SessionsCompanion(
      id: Value(id),
      updatedAt: Value(DateTime.now()),
      enabledMcpServerIds: Value(serversJson),
    );

    await _db.updateSession(updates);
  }

  /// 查找名灵会话（按 enabledSkill 匹配 spiritId）
  /// 同一个名灵角色只会有一个会话
  Future<Session?> findSpiritSession(String spiritId) async {
    final all = await getAllSessions();
    final skillId = 'spirit.$spiritId';
    try {
      return all.firstWhere(
        (s) => s.isSpirit && s.enabledSkill == skillId,
      );
    } catch (_) {
      return null;
    }
  }

  /// 获取所有非名灵会话（首页列表使用）
  Future<List<Session>> getNonSpiritSessions() async {
    final all = await getAllSessions();
    return all.where((s) => !s.isSpirit).toList();
  }
}
