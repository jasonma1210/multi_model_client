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
  BoolColumn get isSpirit => boolean().withDefault(const Constant(false))(); // 名灵回响会话标记
  // v0.42.0: 项目归属（可空，兼容老数据）
  TextColumn get projectId => text().nullable()();
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
  BoolColumn get hasImages => boolean().withDefault(const Constant(false))(); // 是否包含图片（多模态）
  IntColumn get tokenCount => integer().nullable()();
  TextColumn get toolCallInfo => text().nullable()(); // JSON format
  // v0.42.0: 思考过程
  TextColumn get thinking => text().nullable()();
  IntColumn get thinkingTokens => integer().withDefault(const Constant(0))();
  BoolColumn get showThinking => boolean().withDefault(const Constant(true))();
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
  // 🔧 新增字段：多模态支持
  BoolColumn get isMultimodal => boolean().withDefault(const Constant(false))(); // 是否支持视觉
  TextColumn get mmprojPath => text().nullable()(); // mmproj 投影仪文件路径
  TextColumn get mmprojFileName => text().nullable()(); // mmproj 文件名
  // 🔧 新增字段：模型状态
  BoolColumn get isLoaded => boolean().withDefault(const Constant(false))(); // 是否已加载
  TextColumn get downloadStatus => text().withDefault(const Constant('pending'))(); // pending, downloading, completed, failed
  // v0.42.0: 思考预算配置
  TextColumn get thinkingMode => text().withDefault(const Constant('adaptive'))();
  // 'disabled' | 'enabled' | 'adaptive'
  IntColumn get thinkingBudget => integer().nullable()();
  BoolColumn get supportsThinking => boolean().withDefault(const Constant(false))();
  IntColumn get minThinkingBudget => integer().withDefault(const Constant(1024))();
  IntColumn get maxThinkingBudget => integer().withDefault(const Constant(100000))();
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

/// 应用日志表 - 记录错误和异常
class AppLogs extends Table {
  TextColumn get id => text()();
  TextColumn get level => text()(); // 'error', 'warning', 'info', 'debug'
  TextColumn get category => text()(); // 'ui', 'network', 'database', 'model', 'tts', 'asr', 'other'
  TextColumn get title => text()(); // 日志标题/简要描述
  TextColumn get message => text()(); // 日志详细内容
  TextColumn get stackTrace => text().nullable()(); // 堆栈跟踪
  TextColumn get deviceInfo => text().nullable()(); // 设备信息 JSON
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 会话总结表 - 存储会话的压缩记忆（无限上下文核心）
@DataClassName('SessionSummary')
class SessionSummaries extends Table {
  TextColumn get sessionId => text()();
  TextColumn get summary => text().withDefault(const Constant(''))(); // 压缩后的总结
  TextColumn get systemPrompt => text().nullable()(); // 系统提示词（不变）
  TextColumn get activeMessagesJson => text().nullable()(); // 活跃消息 JSON
  IntColumn get maxContextTokens => integer().withDefault(const Constant(32768))(); // 最大上下文
  IntColumn get compressionCount => integer().withDefault(const Constant(0))(); // 压缩次数
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sessionId};
}

/// 插件注册表 - 存储已安装的插件信息
@DataClassName('PluginRegistry')
class PluginRegistries extends Table {
  TextColumn get id => text()(); // 插件 ID（反向域名格式）
  TextColumn get name => text()(); // 插件名称
  TextColumn get version => text()(); // 插件版本
  TextColumn get author => text().nullable()(); // 作者
  TextColumn get description => text().nullable()(); // 描述
  TextColumn get repository => text().nullable()(); // GitHub 仓库地址
  TextColumn get entryPoint => text().withDefault(const Constant('lib/main.dart'))(); // 入口文件
  TextColumn get installPath => text()(); // 安装路径
  TextColumn get permissions => text().nullable()(); // JSON array - 所需权限
  TextColumn get config => text().nullable()(); // JSON - 插件配置
  TextColumn get status => text().withDefault(const Constant('installed'))(); // installed/disabled/error
  TextColumn get errorMessage => text().nullable()(); // 错误信息
  DateTimeColumn get installedAt => dateTime()(); // 安装时间
  DateTimeColumn get updatedAt => dateTime().nullable()(); // 更新时间
  DateTimeColumn get lastUsedAt => dateTime().nullable()(); // 最后使用时间

  @override
  Set<Column> get primaryKey => {id};
}

/// 会话资源表 - 存储会话隔离资源信息（Phase 2）
@DataClassName('SessionResource')
class SessionResources extends Table {
  TextColumn get sessionId => text()(); // 关联会话 ID
  TextColumn get resourceType => text()(); // 资源类型: skill, mcp, variable, memory
  TextColumn get resourceId => text()(); // 资源 ID
  TextColumn get config => text().nullable()(); // JSON - 资源配置
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))(); // 是否启用
  DateTimeColumn get createdAt => dateTime()(); // 创建时间
  DateTimeColumn get updatedAt => dateTime()(); // 更新时间

  @override
  Set<Column> get primaryKey => {sessionId, resourceType, resourceId};
}

/// 工作流定义表 - 存储工作流定义（Phase 3）
@DataClassName('WorkflowDefinitionRecord')
class WorkflowDefinitions extends Table {
  TextColumn get id => text()(); // 工作流 ID
  TextColumn get name => text()(); // 工作流名称
  TextColumn get description => text().nullable()(); // 描述
  IntColumn get version => integer().withDefault(const Constant(1))(); // 版本
  TextColumn get definitionJson => text()(); // 完整定义 JSON
  TextColumn get tags => text().nullable()(); // JSON array - 标签
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))(); // 是否启用
  TextColumn get triggerType => text().withDefault(const Constant('manual'))(); // 触发类型
  TextColumn get triggerConfig => text().nullable()(); // JSON - 触发配置
  TextColumn get createdBy => text().nullable()(); // 创建者
  DateTimeColumn get createdAt => dateTime()(); // 创建时间
  DateTimeColumn get updatedAt => dateTime()(); // 更新时间

  @override
  Set<Column> get primaryKey => {id};
}

/// 工作流执行记录表 - 存储工作流执行历史（Phase 3）
@DataClassName('WorkflowExecutionRecord')
class WorkflowExecutions extends Table {
  TextColumn get instanceId => text()(); // 实例 ID
  TextColumn get workflowId => text()(); // 关联工作流 ID
  TextColumn get status => text()(); // pending/running/completed/failed/cancelled
  TextColumn get inputVariablesJson => text().nullable()(); // JSON - 输入变量
  TextColumn get outputVariablesJson => text().nullable()(); // JSON - 输出变量
  TextColumn get nodeStatesJson => text().nullable()(); // JSON - 节点状态
  TextColumn get errorMessage => text().nullable()(); // 错误信息
  DateTimeColumn get startTime => dateTime().nullable()(); // 开始时间
  DateTimeColumn get endTime => dateTime().nullable()(); // 结束时间
  DateTimeColumn get createdAt => dateTime()(); // 创建时间

  @override
  Set<Column> get primaryKey => {instanceId};
}

/// v0.42.0 新增：项目/工作区表
@DataClassName('Project')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().withDefault(const Constant('📁'))();
  TextColumn get color => text().withDefault(const Constant('#6750A4'))();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get knowledgeBaseId => text().nullable()();
  TextColumn get mcpServers => text().nullable()(); // JSON array
  TextColumn get defaultModelConfigId => text().nullable()();
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  IntColumn get maxContextMessages => integer().withDefault(const Constant(20))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v0.42.0 新增：研究报告主表
@DataClassName('ResearchReport')
class ResearchReports extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().nullable()(); // 可选关联到会话
  TextColumn get query => text()();
  TextColumn get title => text()();
  TextColumn get summary => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  // pending | planning | searching | analyzing | synthesizing | completed | failed
  IntColumn get totalSteps => integer().withDefault(const Constant(0))();
  IntColumn get completedSteps => integer().withDefault(const Constant(0))();
  IntColumn get totalTokens => integer().withDefault(const Constant(0))();
  IntColumn get inputTokens => integer().withDefault(const Constant(0))();
  IntColumn get outputTokens => integer().withDefault(const Constant(0))();
  IntColumn get thinkingTokens => integer().withDefault(const Constant(0))();
  TextColumn get modelConfigId => text().nullable()();
  TextColumn get enabledSources => text().nullable()(); // JSON array
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v0.42.0 新增：研究步骤表
@DataClassName('ResearchStep')
class ResearchSteps extends Table {
  TextColumn get id => text()();
  TextColumn get reportId => text()();
  IntColumn get stepIndex => integer()();
  TextColumn get type => text()(); // planning | search | analyze | synthesize
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get searchQuery => text().nullable()();
  TextColumn get inputData => text().nullable()(); // JSON
  TextColumn get outputData => text().nullable()(); // JSON
  TextColumn get status => text().withDefault(const Constant('pending'))();
  // pending | running | completed | failed
  IntColumn get tokensUsed => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v0.42.0 新增：研究引用来源表
@DataClassName('ResearchCitation')
class ResearchCitations extends Table {
  TextColumn get id => text()();
  TextColumn get reportId => text()();
  IntColumn get citationIndex => integer()();
  TextColumn get sourceType => text()(); // web | file | knowledge_base | rss
  TextColumn get url => text().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get title => text()();
  TextColumn get snippet => text().nullable()();
  RealColumn get relevanceScore => real().nullable()();
  DateTimeColumn get fetchedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v0.42.0 新增：研究报告章节表
@DataClassName('ResearchSection')
class ResearchSections extends Table {
  TextColumn get id => text()();
  TextColumn get reportId => text()();
  IntColumn get sectionIndex => integer()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get citationIds => text().nullable()(); // JSON array
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v0.42.0 新增：思考过程表（用于消息关联的思考内容）
@DataClassName('ThinkingTrace')
class ThinkingTraces extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text()();
  TextColumn get sessionId => text()();
  TextColumn get thinking => text()();
  IntColumn get thinkingTokens => integer().withDefault(const Constant(0))();
  TextColumn get modelConfigId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v0.42.0 新增：提示词场景模板表
@DataClassName('PromptScenario')
class PromptScenarios extends Table {
  TextColumn get id => text()();
  TextColumn get scenarioKey => text().unique()(); // 业务场景标识
  TextColumn get displayName => text()();
  TextColumn get category => text()(); // research | code | writing | analysis | translation | education | etc
  TextColumn get description => text().nullable()();
  TextColumn get systemPrompt => text()();
  TextColumn get userPromptTemplate => text().nullable()();
  TextColumn get variables => text().nullable()(); // JSON array of variable names
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 工作流执行日志表 - 存储执行过程日志（Phase 3）
@DataClassName('WorkflowLog')
class WorkflowLogs extends Table {
  TextColumn get id => text()(); // 日志 ID
  TextColumn get instanceId => text()(); // 关联实例 ID
  TextColumn get nodeId => text()(); // 节点 ID
  TextColumn get level => text()(); // debug/info/warning/error
  TextColumn get message => text()(); // 日志消息
  TextColumn get dataJson => text().nullable()(); // JSON - 附加数据
  DateTimeColumn get timestamp => dateTime()(); // 时间戳

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
  AppLogs,
  SessionSummaries,
  PluginRegistries,
  SessionResources,
  WorkflowDefinitions,
  WorkflowExecutions,
  WorkflowLogs,
  // v0.42.0 新增
  Projects,
  ResearchReports,
  ResearchSteps,
  ResearchCitations,
  ResearchSections,
  ThinkingTraces,
  PromptScenarios,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 12;

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
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.createTable(documentChunks);
        } catch (_) {
          // 忽略：安全错误
        }
        
        // 2. 列添加迁移
        try {
          await m.addColumn(memories, memories.embedding);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(documentChunks, documentChunks.vector);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(sessions, sessions.enableVoiceInput);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(sessions, sessions.enableVoiceOutput);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(sessions, sessions.enableCamera);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(sessions, sessions.enableFileUpload);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(sessions, sessions.enabledSkill);
        } catch (_) {
          // 忽略：安全错误
        }
        // 修复：添加 messages 表的 hasImages 列（之前遗漏）
        try {
          await m.addColumn(messages, messages.hasImages);
        } catch (_) {
          // 忽略：列已存在
        }
        // 修复：将现有记录中 has_images 为 NULL 的更新为默认值 false
        try {
          await customStatement(
            'UPDATE messages SET has_images = 0 WHERE has_images IS NULL',
          );
        } catch (_) {
          // 忽略
        }
        // 修复：将现有记录中 type 为 NULL 的更新为默认值 'text'
        try {
          await customStatement(
            "UPDATE messages SET type = 'text' WHERE type IS NULL",
          );
        } catch (_) {
          // 忽略
        }
        // 修复：将 sessions 表中可能为 NULL 的布尔列更新为默认值
        try {
          await customStatement(
            "UPDATE sessions SET is_pinned = 0 WHERE is_pinned IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET is_archived = 0 WHERE is_archived IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_global_memory = 1 WHERE enable_global_memory IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_video_understanding = 0 WHERE enable_video_understanding IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_web_search = 0 WHERE enable_web_search IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_voice_input = 0 WHERE enable_voice_input IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_voice_output = 0 WHERE enable_voice_output IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_camera = 0 WHERE enable_camera IS NULL",
          );
        } catch (_) {}
        try {
          await customStatement(
            "UPDATE sessions SET enable_file_upload = 1 WHERE enable_file_upload IS NULL",
          );
        } catch (_) {}
        // v7: 知识库增强 - 添加 enabledKnowledgeBaseId 列
        try {
          await m.addColumn(sessions, sessions.enabledKnowledgeBaseId);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(knowledgeBases, knowledgeBases.description);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.addColumn(knowledgeBases, knowledgeBases.documentCount);
        } catch (_) {
          // 忽略：安全错误
        }
        // v8: 会话总结表 - 无限上下文核心
        try {
          await m.createTable(sessionSummaries);
        } catch (_) {
          // 忽略：安全错误
        }
        // v9: 插件注册表 - Skills 插件系统
        try {
          await m.createTable(pluginRegistries);
        } catch (_) {
          // 忽略：安全错误
        }
        // v10: 多会话隔离 & 任务流编排引擎
        try {
          await m.createTable(sessionResources);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.createTable(workflowDefinitions);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.createTable(workflowExecutions);
        } catch (_) {
          // 忽略：安全错误
        }
        try {
          await m.createTable(workflowLogs);
        } catch (_) {
          // 忽略：安全错误
        }
        // v12: 思考预算 / 深度研究 / 项目工作区 / 思考过程 / 提示词场景
        // 双重写入策略：所有 v0.42.0 新表使用 try-catch 幂等创建
        try {
          await m.createTable(projects);
        } catch (_) {
          // 忽略：表已存在
        }
        try {
          await m.createTable(researchReports);
        } catch (_) {
          // 忽略：表已存在
        }
        try {
          await m.createTable(researchSteps);
        } catch (_) {
          // 忽略：表已存在
        }
        try {
          await m.createTable(researchCitations);
        } catch (_) {
          // 忽略：表已存在
        }
        try {
          await m.createTable(researchSections);
        } catch (_) {
          // 忽略：表已存在
        }
        try {
          await m.createTable(thinkingTraces);
        } catch (_) {
          // 忽略：表已存在
        }
        try {
          await m.createTable(promptScenarios);
        } catch (_) {
          // 忽略：表已存在
        }
        // sessions 表新增 projectId 字段（兼容老数据）
        try {
          await m.addColumn(sessions, sessions.projectId);
        } catch (_) {
          // 忽略：列已存在
        }
        // models 表新增 thinking 相关字段
        try {
          await m.addColumn(models, models.thinkingMode);
        } catch (_) {
          // 忽略：列已存在
        }
        try {
          await m.addColumn(models, models.thinkingBudget);
        } catch (_) {
          // 忽略：列已存在
        }
        try {
          await m.addColumn(models, models.supportsThinking);
        } catch (_) {
          // 忽略：列已存在
        }
        try {
          await m.addColumn(models, models.minThinkingBudget);
        } catch (_) {
          // 忽略：列已存在
        }
        try {
          await m.addColumn(models, models.maxThinkingBudget);
        } catch (_) {
          // 忽略：列已存在
        }
        // messages 表新增 thinking 字段
        try {
          await m.addColumn(messages, messages.thinking);
        } catch (_) {
          // 忽略：列已存在
        }
        try {
          await m.addColumn(messages, messages.thinkingTokens);
        } catch (_) {
          // 忽略：列已存在
        }
        try {
          await m.addColumn(messages, messages.showThinking);
        } catch (_) {
          // 忽略：列已存在
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  Memory DAO methods (for MemoryPalace and Memory services)
  // ════════════════════════════════════════════════════════════════════════

  /// 创建记忆
  Future<int> createMemory(MemoriesCompanion memory) =>
      into(memories).insert(memory);

  /// 获取所有记忆
  Future<List<Memory>> getAllMemories() => select(memories).get();

  /// 更新记忆
  Future<int> updateMemory(MemoriesCompanion memory) =>
      (update(memories)..where((t) => t.id.equals(memory.id.value)))
          .write(memory);

  /// 删除记忆
  Future<int> deleteMemory(String id) =>
      (delete(memories)..where((t) => t.id.equals(id))).go();

  // ════════════════════════════════════════════════════════════════════════
  //  SessionSummary DAO methods (for ChatMemory service)
  // ════════════════════════════════════════════════════════════════════════

  /// 获取所有会话总结
  Future<List<SessionSummary>> getSessionSummaries() =>
      select(sessionSummaries).get();

  /// 获取指定会话的总结
  Future<SessionSummary?> getSessionSummary(String sessionId) =>
      (select(sessionSummaries)..where((t) => t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  /// 插入会话总结
  Future<int> insertSessionSummary({
    required String sessionId,
    required String summary,
    String? systemPrompt,
    String? activeMessagesJson,
    int maxContextTokens = 32768,
  }) =>
      into(sessionSummaries).insert(
        SessionSummariesCompanion.insert(
          sessionId: sessionId,
          summary: Value(summary),
          systemPrompt: Value(systemPrompt),
          activeMessagesJson: Value(activeMessagesJson),
          maxContextTokens: Value(maxContextTokens),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

  /// 更新会话总结
  Future<int> updateSessionSummary({
    required String sessionId,
    String? summary,
    String? systemPrompt,
    String? activeMessagesJson,
    int? maxContextTokens,
    int? compressionCount,
  }) =>
      (update(sessionSummaries)..where((t) => t.sessionId.equals(sessionId))).write(
        SessionSummariesCompanion(
          summary: summary != null ? Value(summary) : const Value.absent(),
          systemPrompt: systemPrompt != null ? Value(systemPrompt) : const Value.absent(),
          activeMessagesJson: activeMessagesJson != null ? Value(activeMessagesJson) : const Value.absent(),
          maxContextTokens: maxContextTokens != null ? Value(maxContextTokens) : const Value.absent(),
          compressionCount: compressionCount != null ? Value(compressionCount) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// 删除会话总结
  Future<int> deleteSessionSummary(String sessionId) =>
      (delete(sessionSummaries)..where((t) => t.sessionId.equals(sessionId))).go();

  // ════════════════════════════════════════════════════════════════════════
  //  PluginRegistry DAO methods (for Plugin system)
  // ════════════════════════════════════════════════════════════════════════

  /// 创建插件记录
  Future<int> createPlugin(PluginRegistriesCompanion plugin) =>
      into(pluginRegistries).insert(plugin);

  /// 获取所有插件
  Future<List<PluginRegistry>> getAllPlugins() =>
      select(pluginRegistries).get();

  /// 获取指定插件
  Future<PluginRegistry?> getPlugin(String id) =>
      (select(pluginRegistries)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 获取已安装的插件
  Future<List<PluginRegistry>> getInstalledPlugins() =>
      (select(pluginRegistries)..where((t) => t.status.equals('installed'))).get();

  /// 获取已启用的插件
  Future<List<PluginRegistry>> getEnabledPlugins() =>
      (select(pluginRegistries)..where((t) => t.status.equals('installed') | t.status.equals('enabled'))).get();

  /// 更新插件状态
  Future<int> updatePluginStatus(String id, String status, {String? errorMessage}) =>
      (update(pluginRegistries)..where((t) => t.id.equals(id))).write(
        PluginRegistriesCompanion(
          status: Value(status),
          errorMessage: errorMessage != null ? Value(errorMessage) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// 更新插件最后使用时间
  Future<int> updatePluginLastUsed(String id) =>
      (update(pluginRegistries)..where((t) => t.id.equals(id))).write(
        PluginRegistriesCompanion(
          lastUsedAt: Value(DateTime.now()),
        ),
      );

  /// 删除插件记录
  Future<int> deletePlugin(String id) =>
      (delete(pluginRegistries)..where((t) => t.id.equals(id))).go();

  /// 检查插件是否存在
  Future<bool> pluginExists(String id) async {
    final plugin = await getPlugin(id);
    return plugin != null;
  }

  /// 获取插件数量
  Future<int> getPluginCount() async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM plugin_registry',
      readsFrom: {pluginRegistries},
    ).getSingle();
    return count.data['count'] as int;
  }

  // ════════════════════════════════════════════════════════════════════════
  //  SessionResources DAO methods (for Session Isolation - Phase 2)
  // ════════════════════════════════════════════════════════════════════════

  /// 创建会话资源记录
  Future<int> createSessionResource(SessionResourcesCompanion resource) =>
      into(sessionResources).insert(resource);

  /// 获取会话的所有资源
  Future<List<SessionResource>> getSessionResources(String sessionId) =>
      (select(sessionResources)..where((t) => t.sessionId.equals(sessionId))).get();

  /// 获取会话的特定类型资源
  Future<List<SessionResource>> getSessionResourcesByType(String sessionId, String resourceType) =>
      (select(sessionResources)
            ..where((t) => t.sessionId.equals(sessionId) & t.resourceType.equals(resourceType)))
          .get();

  /// 更新会话资源
  Future<int> updateSessionResource(SessionResourcesCompanion resource) =>
      (update(sessionResources)
            ..where((t) =>
                t.sessionId.equals(resource.sessionId.value) &
                t.resourceType.equals(resource.resourceType.value) &
                t.resourceId.equals(resource.resourceId.value)))
          .write(resource);

  /// 删除会话资源
  Future<int> deleteSessionResource(String sessionId, String resourceType, String resourceId) =>
      (delete(sessionResources)
            ..where((t) =>
                t.sessionId.equals(sessionId) &
                t.resourceType.equals(resourceType) &
                t.resourceId.equals(resourceId)))
          .go();

  /// 删除会话的所有资源
  Future<int> deleteAllSessionResources(String sessionId) =>
      (delete(sessionResources)..where((t) => t.sessionId.equals(sessionId))).go();

  // ════════════════════════════════════════════════════════════════════════
  //  WorkflowDefinitions DAO methods (Workflow Engine - Phase 3)
  // ════════════════════════════════════════════════════════════════════════

  /// 保存工作流定义
  Future<int> saveWorkflowDefinition(WorkflowDefinitionsCompanion definition) =>
      into(workflowDefinitions).insert(definition,
          onConflict: DoUpdate((_) => definition));

  /// 获取所有工作流定义
  Future<List<WorkflowDefinitionRecord>> getAllWorkflowDefinitions() =>
      select(workflowDefinitions).get();

  /// 获取启用的工作流定义
  Future<List<WorkflowDefinitionRecord>> getEnabledWorkflowDefinitions() =>
      (select(workflowDefinitions)..where((t) => t.isEnabled.equals(true))).get();

  /// 获取指定工作流定义
  Future<WorkflowDefinitionRecord?> getWorkflowDefinition(String id) =>
      (select(workflowDefinitions)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 更新工作流定义
  Future<int> updateWorkflowDefinition(WorkflowDefinitionsCompanion definition) =>
      (update(workflowDefinitions)..where((t) => t.id.equals(definition.id.value)))
          .write(definition);

  /// 删除工作流定义
  Future<int> deleteWorkflowDefinition(String id) =>
      (delete(workflowDefinitions)..where((t) => t.id.equals(id))).go();

  // ════════════════════════════════════════════════════════════════════════
  //  WorkflowExecutions DAO methods (Workflow Engine - Phase 3)
  // ════════════════════════════════════════════════════════════════════════

  /// 保存执行记录
  Future<int> saveWorkflowExecution(WorkflowExecutionsCompanion execution) =>
      into(workflowExecutions).insert(execution,
          onConflict: DoUpdate((_) => execution));

  /// 获取执行记录
  Future<WorkflowExecutionRecord?> getWorkflowExecution(String instanceId) =>
      (select(workflowExecutions)..where((t) => t.instanceId.equals(instanceId)))
          .getSingleOrNull();

  /// 获取工作流的所有执行记录
  Future<List<WorkflowExecutionRecord>> getWorkflowExecutions(String workflowId) =>
      (select(workflowExecutions)
            ..where((t) => t.workflowId.equals(workflowId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// 获取最近的执行记录
  Future<List<WorkflowExecutionRecord>> getRecentWorkflowExecutions({int limit = 20}) =>
      (select(workflowExecutions)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  /// 更新执行记录状态
  Future<int> updateWorkflowExecutionStatus(
    String instanceId,
    String status, {
    String? errorMessage,
  }) =>
      (update(workflowExecutions)..where((t) => t.instanceId.equals(instanceId))).write(
        WorkflowExecutionsCompanion(
          status: Value(status),
          errorMessage: errorMessage != null ? Value(errorMessage) : const Value.absent(),
          endTime: Value(DateTime.now()),
        ),
      );

  /// 删除执行记录
  Future<int> deleteWorkflowExecution(String instanceId) =>
      (delete(workflowExecutions)..where((t) => t.instanceId.equals(instanceId))).go();

  // ════════════════════════════════════════════════════════════════════════
  //  WorkflowLogs DAO methods (Workflow Engine - Phase 3)
  // ════════════════════════════════════════════════════════════════════════

  /// 保存工作流日志
  Future<int> saveWorkflowLog(WorkflowLogsCompanion log) =>
      into(workflowLogs).insert(log);

  /// 获取执行实例的日志
  Future<List<WorkflowLog>> getWorkflowLogs(String instanceId) =>
      (select(workflowLogs)
            ..where((t) => t.instanceId.equals(instanceId))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();

  /// 获取节点日志
  Future<List<WorkflowLog>> getWorkflowNodeLogs(String instanceId, String nodeId) =>
      (select(workflowLogs)
            ..where((t) => t.instanceId.equals(instanceId) & t.nodeId.equals(nodeId))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();

  /// 删除执行实例的所有日志
  Future<int> deleteWorkflowLogs(String instanceId) =>
      (delete(workflowLogs)..where((t) => t.instanceId.equals(instanceId))).go();

  // ════════════════════════════════════════════════════════════════════════
  //  v0.42.0: Projects DAO methods
  // ════════════════════════════════════════════════════════════════════════

  /// 创建项目
  Future<int> createProject(ProjectsCompanion project) =>
      into(projects).insert(project);

  /// 获取所有项目（未归档）
  Future<List<Project>> getAllProjects({bool includeArchived = false}) {
    final query = select(projects);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    query.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    return query.get();
  }

  /// 根据 ID 获取项目
  Future<Project?> getProjectById(String id) =>
      (select(projects)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 更新项目
  Future<int> updateProject(ProjectsCompanion project) =>
      (update(projects)..where((t) => t.id.equals(project.id.value)))
          .write(project);

  /// 删除项目
  Future<int> deleteProject(String id) =>
      (delete(projects)..where((t) => t.id.equals(id))).go();

  /// 获取项目内的所有会话
  Future<List<Session>> getSessionsByProject(String projectId) =>
      (select(sessions)..where((t) => t.projectId.equals(projectId))).get();

  /// 将会话绑定到项目
  Future<int> bindSessionToProject(String sessionId, String projectId) =>
      (update(sessions)..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(projectId: Value(projectId)),
      );

  /// 解绑会话
  Future<int> unbindSessionFromProject(String sessionId) =>
      (update(sessions)..where((t) => t.id.equals(sessionId))).write(
        const SessionsCompanion(),
      );

  // ════════════════════════════════════════════════════════════════════════
  //  v0.42.0: Research Reports DAO methods
  // ════════════════════════════════════════════════════════════════════════

  /// 创建研究报告
  Future<int> createResearchReport(ResearchReportsCompanion report) =>
      into(researchReports).insert(report);

  /// 更新研究报告
  Future<int> updateResearchReport(String id, ResearchReportsCompanion report) =>
      (update(researchReports)..where((t) => t.id.equals(id))).write(report);

  /// 获取研究报告
  Future<ResearchReport?> getResearchReport(String id) =>
      (select(researchReports)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 获取会话的所有研究报告
  Future<List<ResearchReport>> getResearchReportsBySession(String sessionId) =>
      (select(researchReports)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  /// 删除研究报告
  Future<int> deleteResearchReport(String id) =>
      (delete(researchReports)..where((t) => t.id.equals(id))).go();

  // ── ResearchSteps DAO ──

  /// 创建研究步骤
  Future<int> createResearchStep(ResearchStepsCompanion step) =>
      into(researchSteps).insert(step);

  /// 更新研究步骤
  Future<int> updateResearchStep(String id, ResearchStepsCompanion step) =>
      (update(researchSteps)..where((t) => t.id.equals(id))).write(step);

  /// 获取报告的所有步骤
  Future<List<ResearchStep>> getResearchStepsByReport(String reportId) =>
      (select(researchSteps)
            ..where((t) => t.reportId.equals(reportId))
            ..orderBy([(t) => OrderingTerm.asc(t.stepIndex)]))
          .get();

  /// 删除研究步骤
  Future<int> deleteResearchStepsByReport(String reportId) =>
      (delete(researchSteps)..where((t) => t.reportId.equals(reportId))).go();

  // ── ResearchCitations DAO ──

  /// 批量创建引用
  Future<void> createResearchCitations(List<ResearchCitationsCompanion> items) async {
    await batch((b) => b.insertAll(researchCitations, items));
  }

  /// 获取报告的所有引用
  Future<List<ResearchCitation>> getResearchCitationsByReport(String reportId) =>
      (select(researchCitations)
            ..where((t) => t.reportId.equals(reportId))
            ..orderBy([(t) => OrderingTerm.asc(t.citationIndex)]))
          .get();

  // ── ResearchSections DAO ──

  /// 批量创建章节
  Future<void> createResearchSections(List<ResearchSectionsCompanion> items) async {
    await batch((b) => b.insertAll(researchSections, items));
  }

  /// 获取报告的所有章节
  Future<List<ResearchSection>> getResearchSectionsByReport(String reportId) =>
      (select(researchSections)
            ..where((t) => t.reportId.equals(reportId))
            ..orderBy([(t) => OrderingTerm.asc(t.sectionIndex)]))
          .get();

  // ════════════════════════════════════════════════════════════════════════
  //  v0.42.0: Thinking Traces DAO methods
  // ════════════════════════════════════════════════════════════════════════

  /// 创建思考记录
  Future<int> createThinkingTrace(ThinkingTracesCompanion trace) =>
      into(thinkingTraces).insert(trace);

  /// 获取消息的思考记录
  Future<ThinkingTrace?> getThinkingTraceByMessage(String messageId) =>
      (select(thinkingTraces)..where((t) => t.messageId.equals(messageId)))
          .getSingleOrNull();

  /// 获取会话的所有思考记录
  Future<List<ThinkingTrace>> getThinkingTracesBySession(String sessionId) =>
      (select(thinkingTraces)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  // ════════════════════════════════════════════════════════════════════════
  //  v0.42.0: Prompt Scenarios DAO methods
  // ════════════════════════════════════════════════════════════════════════

  /// 批量创建或更新提示词场景
  Future<void> upsertPromptScenarios(List<PromptScenariosCompanion> items) async {
    await batch((b) => b.insertAll(
          promptScenarios,
          items,
          mode: InsertMode.insertOrReplace,
        ));
  }

  /// 获取所有提示词场景
  Future<List<PromptScenario>> getAllPromptScenarios() =>
      (select(promptScenarios)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  /// 按分类获取提示词场景
  Future<List<PromptScenario>> getPromptScenariosByCategory(String category) =>
      (select(promptScenarios)
            ..where((t) => t.category.equals(category))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  /// 根据 key 获取场景
  Future<PromptScenario?> getPromptScenarioByKey(String scenarioKey) =>
      (select(promptScenarios)..where((t) => t.scenarioKey.equals(scenarioKey)))
          .getSingleOrNull();

  // ════════════════════════════════════════════════════════════════════════
  //  v0.42.0: Models 思考配置 DAO methods
  // ════════════════════════════════════════════════════════════════════════

  /// 根据 ID 获取模型
  Future<Model?> getModelById(String id) =>
      (select(models)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 更新模型（部分更新）
  Future<int> updateModel(ModelsCompanion model) {
    return (update(models)..where((t) => t.id.equals(model.id.value)))
        .write(model);
  }

  /// 更新模型的思考配置
  Future<int> updateModelThinkingConfig({
    required String modelId,
    required String thinkingMode,
    int? thinkingBudget,
  }) {
    return (update(models)..where((t) => t.id.equals(modelId))).write(
      ModelsCompanion(
        thinkingMode: Value(thinkingMode),
        thinkingBudget: Value(thinkingBudget),
      ),
    );
  }
}
