/// 数据库连接 - LLM Studio 数据库连接管理模块
/// 
/// 功能：
/// - Drift 数据库连接管理
/// - 数据库文件路径配置
/// - 数据库迁移执行
/// - 后台数据库创建
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// 打开数据库连接
LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'multi_model_client.db'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // 手动执行迁移：确保所有必要的表和列存在
        
        // 0. 创建 memories 表（如果不存在）
        try {
          db.execute('''
            CREATE TABLE IF NOT EXISTS memories (
              id TEXT PRIMARY KEY,
              session_id TEXT,
              type TEXT NOT NULL,
              content TEXT NOT NULL,
              entity_tags TEXT,
              weight REAL DEFAULT 1.0,
              is_global INTEGER DEFAULT 0,
              is_archived INTEGER DEFAULT 0,
              embedding TEXT,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              last_accessed_at INTEGER
            )
          ''');
        } catch (e) {
          // 表已存在，忽略
        }
        
        // 1. 创建 documents 表（如果不存在）
        try {
          db.execute('''
            CREATE TABLE IF NOT EXISTS documents (
              id TEXT PRIMARY KEY,
              knowledge_base_id TEXT NOT NULL,
              file_name TEXT NOT NULL,
              file_path TEXT NOT NULL,
              file_type TEXT NOT NULL,
              file_size INTEGER NOT NULL,
              chunk_count INTEGER DEFAULT 0,
              status TEXT DEFAULT 'pending',
              error_message TEXT,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        } catch (e) {
          // 表已存在，忽略
        }
        
        // 2. 创建 document_chunks 表（如果不存在）
        try {
          db.execute('''
            CREATE TABLE IF NOT EXISTS document_chunks (
              id TEXT PRIMARY KEY,
              knowledge_base_id TEXT NOT NULL,
              document_id TEXT NOT NULL,
              content TEXT NOT NULL,
              chunk_index INTEGER NOT NULL,
              vector TEXT,
              metadata TEXT,
              created_at INTEGER NOT NULL
            )
          ''');
        } catch (e) {
          // 表已存在，忽略
        }
        
        // 2.1 如果 document_chunks 表缺少列，添加它们
        try {
          db.execute('ALTER TABLE document_chunks ADD COLUMN document_id TEXT');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE document_chunks ADD COLUMN metadata TEXT');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE document_chunks ADD COLUMN vector TEXT');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE document_chunks ADD COLUMN chunk_index INTEGER NOT NULL DEFAULT 0');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE document_chunks ADD COLUMN knowledge_base_id TEXT NOT NULL DEFAULT ""');
        } catch (e) {}
        
        // 3. 确保 sessions 表有所有必要的列
        try {
          db.execute('ALTER TABLE sessions ADD COLUMN enabled_skill TEXT');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE sessions ADD COLUMN enabled_knowledge_base_id TEXT');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE sessions ADD COLUMN enable_voice_input INTEGER DEFAULT 0');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE sessions ADD COLUMN enable_voice_output INTEGER DEFAULT 0');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE sessions ADD COLUMN enable_camera INTEGER DEFAULT 0');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE sessions ADD COLUMN enable_file_upload INTEGER DEFAULT 0');
        } catch (e) {}
        
        // 4. 确保 knowledge_bases 表有 description 和 document_count 列
        try {
          db.execute('ALTER TABLE knowledge_bases ADD COLUMN description TEXT');
        } catch (e) {}
        try {
          db.execute('ALTER TABLE knowledge_bases ADD COLUMN document_count INTEGER DEFAULT 0');
        } catch (e) {}
        
        // 5. 确保 memories 表有 embedding 列
        try {
          db.execute('ALTER TABLE memories ADD COLUMN embedding TEXT');
        } catch (e) {}
      },
    );
  });
}

// DAO methods extension
extension AppDatabaseDAO on AppDatabase {
  // Session DAO methods
  Future<int> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<List<Session>> getAllSessions() =>
      (select(sessions)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<Session?> getSession(String id) =>
      (select(sessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateSession(SessionsCompanion session) =>
      (update(sessions)..where((t) => t.id.equals(session.id.value)))
          .write(session);

  Future<int> deleteSession(String id) =>
      (delete(sessions)..where((t) => t.id.equals(id))).go();

  // Message DAO methods
  Future<int> insertMessage(MessagesCompanion message) =>
      into(messages).insert(message);

  Future<List<Message>> getSessionMessages(String sessionId) =>
      (select(messages)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<List<Message>> getAllMessages() => select(messages).get();

  Future<Message?> getMessage(String id) =>
      (select(messages)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> deleteSessionMessages(String sessionId) =>
      (delete(messages)..where((t) => t.sessionId.equals(sessionId))).go();

  // Model DAO methods
  Future<int> insertModel(ModelsCompanion model) =>
      into(models).insert(model);

  Future<List<Model>> getAllModels() => select(models).get();

  Future<Model?> getModel(String id) =>
      (select(models)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateModel(ModelsCompanion model) =>
      (update(models)..where((t) => t.id.equals(model.id.value))).write(model);

  Future<int> deleteModel(String id) =>
      (delete(models)..where((t) => t.id.equals(id))).go();

  // Memory DAO methods
  Future<int> insertMemory(MemoriesCompanion memory) =>
      into(memories).insert(memory);

  Future<List<Memory>> getSessionMemories(String sessionId) =>
      (select(memories)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.desc(t.weight)]))
          .get();

  Future<List<Memory>> getGlobalMemories() =>
      (select(memories)
            ..where((t) => t.isGlobal.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.weight)]))
          .get();

  Future<List<Memory>> getAllMemories() => select(memories).get();

  Future<int> updateMemory(MemoriesCompanion memory) =>
      (update(memories)..where((t) => t.id.equals(memory.id.value)))
          .write(memory);

  Future<int> deleteMemory(String id) =>
      (delete(memories)..where((t) => t.id.equals(id))).go();

  /// 获取记忆总数
  Future<int> getMemoryCount() async {
    final count = memories.id.count();
    final query = selectOnly(memories)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// 删除所有记忆
  Future<int> deleteAllMemories() => delete(memories).go();

  /// 删除所有消息
  Future<int> deleteAllMessages() => delete(messages).go();

  // Knowledge Base DAO methods
  Future<int> insertKnowledgeBase(KnowledgeBasesCompanion kb) =>
      into(knowledgeBases).insert(kb);

  Future<List<KnowledgeBase>> getAllKnowledgeBases() =>
      select(knowledgeBases).get();

  Future<KnowledgeBase?> getKnowledgeBase(String id) =>
      (select(knowledgeBases)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> deleteKnowledgeBase(String id) =>
      (delete(knowledgeBases)..where((t) => t.id.equals(id))).go();

  // Document DAO methods
  Future<int> insertDocument(DocumentsCompanion doc) =>
      into(documents).insert(doc);

  Future<List<Document>> getDocuments(String knowledgeBaseId) =>
      (select(documents)..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId)))
          .get();

  Future<Document?> getDocument(String id) =>
      (select(documents)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateDocument(DocumentsCompanion doc) =>
      (update(documents)..where((t) => t.id.equals(doc.id.value))).write(doc);

  Future<int> deleteDocument(String id) =>
      (delete(documents)..where((t) => t.id.equals(id))).go();

  Future<int> deleteKnowledgeBaseDocuments(String knowledgeBaseId) =>
      (delete(documents)..where((t) => t.knowledgeBaseId.equals(knowledgeBaseId))).go();

  // Document Chunk DAO methods
  Future<int> insertDocumentChunk(DocumentChunksCompanion chunk) =>
      into(documentChunks).insert(chunk);

  Future<List<DocumentChunk>> getKnowledgeBaseChunks(String kbId) =>
      (select(documentChunks)..where((t) => t.knowledgeBaseId.equals(kbId)))
          .get();

  Future<int> deleteKnowledgeBaseChunks(String kbId) =>
      (delete(documentChunks)..where((t) => t.knowledgeBaseId.equals(kbId)))
          .go();

  // Prompt Template DAO methods
  Future<int> insertPromptTemplate(PromptTemplatesCompanion template) =>
      into(promptTemplates).insert(template);

  Future<List<PromptTemplate>> getAllPromptTemplates() =>
      (select(promptTemplates)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<List<PromptTemplate>> getPromptTemplatesByCategory(String category) =>
      (select(promptTemplates)
            ..where((t) => t.category.equals(category))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<List<PromptTemplate>> getGlobalPromptTemplates() =>
      (select(promptTemplates)
            ..where((t) => t.isGlobal.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<List<PromptTemplate>> getBuiltinPromptTemplates() =>
      (select(promptTemplates)..where((t) => t.isBuiltin.equals(true))).get();

  Future<List<PromptTemplate>> getUserPromptTemplates() =>
      (select(promptTemplates)
            ..where((t) => t.isBuiltin.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<PromptTemplate?> getPromptTemplate(String id) =>
      (select(promptTemplates)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> updatePromptTemplate(PromptTemplatesCompanion template) =>
      (update(promptTemplates)..where((t) => t.id.equals(template.id.value)))
          .write(template);

  Future<int> deletePromptTemplate(String id) =>
      (delete(promptTemplates)..where((t) => t.id.equals(id))).go();

  // Session Prompt DAO methods
  Future<int> insertSessionPrompt(SessionPromptsCompanion sessionPrompt) =>
      into(sessionPrompts).insert(sessionPrompt);

  Future<List<SessionPrompt>> getSessionPrompts(String sessionId) =>
      (select(sessionPrompts)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<SessionPrompt?> getLatestSessionPrompt(String sessionId) =>
      (select(sessionPrompts)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> deleteSessionPrompts(String sessionId) =>
      (delete(sessionPrompts)..where((t) => t.sessionId.equals(sessionId)))
          .go();

  // Download Task DAO methods
  Future<int> insertDownloadTask(DownloadTasksCompanion task) =>
      into(downloadTasks).insert(task);

  Future<List<DownloadTask>> getAllDownloadTasks() =>
      (select(downloadTasks)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<DownloadTask?> getDownloadTask(String id) =>
      (select(downloadTasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateDownloadTask(DownloadTasksCompanion task) =>
      (update(downloadTasks)..where((t) => t.id.equals(task.id.value)))
          .write(task);

  Future<int> deleteDownloadTask(String id) =>
      (delete(downloadTasks)..where((t) => t.id.equals(id))).go();

  // MCP Server Config DAO methods
  Future<int> insertMcpServerConfig(McpServerConfigsCompanion config) =>
      into(mcpServerConfigs).insert(config);

  Future<List<McpServerConfig>> getAllMcpServerConfigs() =>
      select(mcpServerConfigs).get();

  Future<McpServerConfig?> getMcpServerConfig(String id) =>
      (select(mcpServerConfigs)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<McpServerConfig?> getMcpServerConfigByServerId(String serverId) =>
      (select(mcpServerConfigs)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  Future<int> updateMcpServerConfig(McpServerConfigsCompanion config) =>
      (update(mcpServerConfigs)..where((t) => t.id.equals(config.id.value)))
          .write(config);

  /// 通过 serverId 更新服务器配置
  Future<int> updateMcpServerConfigByServerId({
    required String serverId,
    String? name,
    String? type,
    String? command,
    String? args,
    String? env,
    bool? isEnabled,
    bool? isAutoStart,
  }) async {
    final existing = await getMcpServerConfigByServerId(serverId);
    if (existing == null) return 0;
    
    final companion = McpServerConfigsCompanion(
      id: Value(existing.id),
      serverId: Value(serverId),
      name: name != null ? Value(name) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
      command: command != null ? Value(command) : const Value.absent(),
      args: args != null ? Value(args) : const Value.absent(),
      env: env != null ? Value(env) : const Value.absent(),
      isEnabled: isEnabled != null ? Value(isEnabled) : const Value.absent(),
      isAutoStart: isAutoStart != null ? Value(isAutoStart) : const Value.absent(),
    );
    
    return (update(mcpServerConfigs)..where((t) => t.id.equals(existing.id)))
        .write(companion);
  }

  Future<int> deleteMcpServerConfig(String id) =>
      (delete(mcpServerConfigs)..where((t) => t.id.equals(id))).go();

  // Folder DAO methods
  Future<int> insertFolder(FoldersCompanion folder) =>
      into(folders).insert(folder);

  Future<List<Folder>> getAllFolders() =>
      (select(folders)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Future<Folder?> getFolder(String id) =>
      (select(folders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> updateFolder(FoldersCompanion folder) =>
      (update(folders)..where((t) => t.id.equals(folder.id.value)))
          .write(folder);

  Future<int> deleteFolder(String id) =>
      (delete(folders)..where((t) => t.id.equals(id))).go();

  // Session Folder related queries
  Future<List<Session>> getSessionsByFolder(String folderId) =>
      (select(sessions)
            ..where((t) => t.folderId.equals(folderId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.isPinned),
              (t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .get();

  Future<List<Session>> getUncategorizedSessions() =>
      (select(sessions)
            ..where((t) => t.folderId.isNull() & t.isArchived.equals(false))
            ..orderBy([
              (t) => OrderingTerm.desc(t.isPinned),
              (t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .get();

  Future<List<Session>> getArchivedSessions() =>
      (select(sessions)
            ..where((t) => t.isArchived.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  Future<List<Session>> getAllActiveSessions() =>
      (select(sessions)
            ..where((t) => t.isArchived.equals(false))
            ..orderBy([
              (t) => OrderingTerm.desc(t.isPinned),
              (t) => OrderingTerm.desc(t.updatedAt),
            ]))
          .get();
}

// Global database singleton — one connection for the entire app lifetime.
// Using a getter that creates a new instance every time was the root cause of
// "database is locked" errors (multiple writers on the same SQLite file).
AppDatabase? _databaseInstance;
AppDatabase get database {
  _databaseInstance ??= AppDatabase(openConnection());
  return _databaseInstance!;
}
