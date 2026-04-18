/// 数据库定义 - LLM Studio 数据模型模块
/// 
/// 功能：
/// - Drift ORM 表定义
/// - 数据模型定义（Sessions/Messages/Models/Memories 等）
/// - 数据库迁移管理
/// - 查询接口生成
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:drift/drift.dart';

part 'database.g.dart';

@DataClassName('Session')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get folderId => text().nullable()();
  TextColumn get modelId => text()();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get inferenceParams => text().nullable()(); // JSON format
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get enableGlobalMemory => boolean().withDefault(const Constant(true))();
  BoolColumn get enableVideoUnderstanding => boolean().withDefault(const Constant(false))();
  TextColumn get enabledMcpServerIds => text().nullable()(); // JSON array of MCP server IDs
  BoolColumn get enableWebSearch => boolean().withDefault(const Constant(false))();
  BoolColumn get enableVoiceInput => boolean().withDefault(const Constant(false))(); // 语音输入
  BoolColumn get enableVoiceOutput => boolean().withDefault(const Constant(false))(); // 语音输出
  TextColumn get enabledSkill => text().nullable()(); // 当前启用的技能 ID
  BoolColumn get enableCamera => boolean().withDefault(const Constant(false))(); // 摄像头
  BoolColumn get enableFileUpload => boolean().withDefault(const Constant(true))(); // 文件上传（默认开启）
  TextColumn get enabledKnowledgeBaseId => text().nullable()(); // 当前关联的知识库 ID
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Message')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get role => text()(); // 'user', 'assistant', 'system', 'tool'
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(const Constant('text'))(); // 'text', 'image', 'audio', 'video'
  IntColumn get tokenCount => integer().nullable()();
  TextColumn get toolCallInfo => text().nullable()(); // JSON format
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Model')
class Models extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'local', 'remote'
  TextColumn get source => text()(); // 'gguf', 'openai', 'anthropic', etc.
  TextColumn get path => text().nullable()(); // for local models
  TextColumn get apiConfig => text().nullable()(); // JSON format for remote models
  TextColumn get capabilities => text().nullable()(); // JSON format
  TextColumn get defaultParams => text().nullable()(); // JSON format
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Memory')
class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().nullable()(); // null for global memories
  TextColumn get type => text()(); // 'instant', 'working', 'long_term', 'archived'
  TextColumn get content => text()();
  TextColumn get entityTags => text().nullable()(); // JSON format
  RealColumn get weight => real().withDefault(const Constant(1.0))();
  BoolColumn get isGlobal => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get embedding => text().nullable()(); // JSON format for vector embeddings
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('KnowledgeBase')
class KnowledgeBases extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()(); // 知识库描述
  IntColumn get documentCount => integer().withDefault(const Constant(0))(); // 文档数量
  TextColumn get sessionId => text().nullable()(); // null for global knowledge bases
  BoolColumn get isGlobal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 文档表 - 存储上传的文档元数据
@DataClassName('Document')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get knowledgeBaseId => text()();
  TextColumn get fileName => text()(); // 文件名
  TextColumn get filePath => text()(); // 本地文件路径
  TextColumn get fileType => text()(); // pdf, md, ppt, txt 等
  IntColumn get fileSize => integer()(); // 文件大小（字节）
  IntColumn get chunkCount => integer().withDefault(const Constant(0))(); // 分块数量
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, processing, completed, failed
  TextColumn get errorMessage => text().nullable()(); // 错误信息
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DocumentChunk')
class DocumentChunks extends Table {
  TextColumn get id => text()();
  TextColumn get knowledgeBaseId => text()();
  TextColumn get documentId => text()(); // 关联文档
  TextColumn get content => text()(); // 分块内容
  IntColumn get chunkIndex => integer()(); // 分块索引
  TextColumn get vector => text().nullable()(); // JSON format for vector embeddings (可选)
  TextColumn get metadata => text().nullable()(); // JSON format
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PromptTemplate')
class PromptTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get content => text()();
  TextColumn get variables => text().nullable()(); // JSON format
  TextColumn get category => text().withDefault(const Constant('general'))(); // 模板分类
  BoolColumn get isGlobal => boolean().withDefault(const Constant(false))(); // 全局模板
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 会话提示词表 - 存储每个会话使用的提示词实例
@DataClassName('SessionPrompt')
class SessionPrompts extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get templateId => text().nullable()(); // 关联的模板ID
  TextColumn get promptContent => text()(); // 实际使用的提示词内容
  TextColumn get variables => text().nullable()(); // JSON format - 使用的变量值
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DownloadTask')
class DownloadTasks extends Table {
  TextColumn get id => text()();
  TextColumn get modelId => text()();
  TextColumn get url => text()();
  TextColumn get savePath => text()();
  TextColumn get status => text()(); // 'pending', 'downloading', 'paused', 'completed', 'error'
  IntColumn get progress => integer().withDefault(const Constant(0))(); // 0-100
  IntColumn get totalBytes => integer().withDefault(const Constant(0))();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  TextColumn get source => text()(); // 'huggingface', 'modelscope', 'local'
  TextColumn get quantLevel => text().nullable()(); // 'Q4_K_M', etc.
  TextColumn get metadata => text().nullable()(); // JSON format
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('McpServerConfig')
class McpServerConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get serverId => text()(); // Unique identifier
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'stdio', 'http'
  TextColumn get command => text()(); // Command to start server
  TextColumn get args => text().nullable()(); // JSON array of arguments
  TextColumn get env => text().nullable()(); // JSON object for environment variables
  BoolColumn get isEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get isAutoStart => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get lastConnectedTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 文件夹表
@DataClassName('Folder')
class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().withDefault(const Constant('#007AFF'))();
  TextColumn get icon => text().withDefault(const Constant('folder'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Sessions,
  Messages,
  Models,
  Memories,
  KnowledgeBases,
  Documents,
  DocumentChunks,
  PromptTemplates,
  SessionPrompts,
  DownloadTasks,
  McpServerConfigs,
  Folders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // 始终无条件添加所有可能缺失的列，不依赖 schemaVersion 判断。
        // 原因：用户的 DB 文件 user_version 可能已被旧代码设为较高值（比如 5），
        // 导致 if (from < N) 跳过了真正需要的迁移，列实际不存在。
        // 使用 try-catch 处理"列已存在"的正常情况。
        
        // 1. 新表创建：如果 documents/documentChunks 表不存在，则创建
        // 兼容旧版本：无论 from 是什么版本，都尝试创建缺失的表
        try {
          await m.createTable(documents);
        } catch (_) {}
        try {
          await m.createTable(documentChunks);
        } catch (_) {}
        
        // 2. 列添加迁移
        try {
          await m.addColumn(memories, memories.embedding);
        } catch (_) {}
        try {
          await m.addColumn(documentChunks, documentChunks.vector);
        } catch (_) {}
        try {
          await m.addColumn(sessions, sessions.enableVoiceInput);
        } catch (_) {}
        try {
          await m.addColumn(sessions, sessions.enableVoiceOutput);
        } catch (_) {}
        try {
          await m.addColumn(sessions, sessions.enableCamera);
        } catch (_) {}
        try {
          await m.addColumn(sessions, sessions.enableFileUpload);
        } catch (_) {}
        try {
          await m.addColumn(sessions, sessions.enabledSkill);
        } catch (_) {}
        // v7: 知识库增强 - 添加 enabledKnowledgeBaseId 列
        try {
          await m.addColumn(sessions, sessions.enabledKnowledgeBaseId);
        } catch (_) {}
        try {
          await m.addColumn(knowledgeBases, knowledgeBases.description);
        } catch (_) {}
        try {
          await m.addColumn(knowledgeBases, knowledgeBases.documentCount);
        } catch (_) {}
      },
    );
  }
}
