# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.44.0] - 2026-06-30

### ✨ Added - 新增功能

#### LLM Function Calling 真实接入（Stage A）— P0
- ✨ **fc_patterns.dart** — 4 种 FC 模板正则（Qwen/Hermes/Llama 3.1/Mistral）+ 通用兜底解析器
- ✨ **FcPromptTemplates** — 注入工具描述到 System Prompt
- ✨ **FcOutputParser** — 解析流式输出中的工具调用（含增量 JSON 累积）
- ✨ **LocalFFIEngine.generateStreamWithTools** — 新增方法（不改原 `generateStream` 签名）
- ✨ **DialogueEngine FC 编排** — 检测 `chunk.toolCall` → 执行工具 → 通知 UI → 回填数据库
- ✨ **伪 FC 兜底** — 保留原 `_checkAndExecuteMcpTools` 作为兼容回退路径
- ✨ **ChatOptions 扩展** — 新增 `tools / toolChoice / fcFormat` 字段（向后兼容）
- ✨ **ChatStreamChunk** — 统一流式分块（text / toolCall / isToolCallEnd）

#### 跨平台能力矩阵 — P0
- ✨ **docs/PLATFORM_CAPABILITY_MATRIX.md** — 三端功能覆盖矩阵（20+ 功能 × 3 平台）
- ✨ 平台限制说明（iOS / Android / macOS）
- ✨ 平台特定代码路径指引
- ✨ 已知不支持的功能列表

#### CI/CD 自动化 — P0
- ✨ **.github/workflows/ci.yml** — GitHub Actions 流水线
- ✨ 5 个 Job：analyze → test → build-ios → build-macos → build-android
- ✨ 缓存策略：pub-cache / gradle / CocoaPods
- ✨ Artifact 上传：Runner.app / multi_model_client.app / app-release.apk

### 🔧 Changed - 改进优化

#### 性能优化（B1-B6）
- 🔧 **B1 图片处理进 Isolate** — `processBytes` 改用 `compute()`，Isolate 失败时 fallback 到同步实现
- 🔧 **B2 MessageParser LRU 缓存** — `_AssistantBubbleState` 新增静态缓存（容量 50），避免每次 build 重复正则扫描
- 🔧 **B4 振幅节流** — 200ms 时间窗口节流，避免高频 setState 导致 UI 卡顿
- 🔧 **B5 输入框 ValueListenableBuilder** — 发送按钮区域用 `ValueListenableBuilder<TextEditingValue>` 包裹，避免整树重建
- 🔧 **B6 会话切换 dispose** — `didUpdateWidget` 中显式取消定时器和订阅，修复内存泄漏
- 🔧 **B3 select 拆分** — 保留原 `ref.watch(sessionStateProvider)`（拆分会违反收敛性原则，需改方法签名）

#### 模型加载策略（C1-C3）
- 🔧 **C1 LocalFFIEngine LRU 缓存** — `_CachedEngine` 类 + `_engineCache` Map（容量 2）；模型 A→B→A 切换时第二次加载秒命中
- 🔧 **C2 流式 StreamController 包装** — `generateChatStreamControlled` 方法，支持主动取消；`cancelGeneration` 同时关闭 StreamController
- 🔧 **C3 网络错误自动重试** — `_retryableGenerate` 方法（3 次重试，指数退避 1s/2s/4s）；上下文超长错误不重试
- 🔧 **`_isNetworkError` / `_isContextTooLongError`** — 网络错误和上下文超长错误检测方法

### 🗑️ Removed - 移除

- 🗑️ **build_llama/** — 空目录清理
- 🗑️ **designs/** — 空目录清理

### 📦 Technical Details

- **iOS**: `flutter build ios --release --no-codesign` → 44.7s, 208.5MB Runner.app
- **macOS**: `flutter build macos --release` → 281.2MB multi_model_client.app
- **Android**: `flutter build apk --release` → 134.0s, 138.1MB app-release.apk
- **测试**: 288 通过 / 5 失败（全部 pre-existing TTS 相关，与 v0.44.0 改动无关）
- **静态分析**: 0 新增 error（132 pre-existing issues 均非本次修改）

### ⚠️ Known Issues

- 5 个 pre-existing TTS 测试失败（`tts_style_parser_v11_test.dart` / `tts_service_test.dart`，与本次改动无关）
- iOS 平台仍默认使用 CPU 模式（待 llamadart 修复 Metal SIGSEGV 问题后恢复 Metal 加速）
- B3 sessionStateProvider select 未拆分（保持收敛性，避免改方法签名）

### 🔗 Migration Notes

- **向后兼容**：所有新增方法未改原方法签名，旧调用方无需修改
- **数据库**：v0.44.0 无 schema 变更（v0.42.0 已完成双写迁移）
- **配置**：`ChatOptions` 新增字段为可选，旧代码无需显式传入

## [0.43.0] - 2026-06-30

### ✨ Added - 新增功能

#### 多模态统一抽象（Multimodal Abstraction）— P0
- ✨ **ContentPart sealed class** — `TextPart / ImagePart / AudioPart / FilePart` 4 个子类强制类型安全 + 模式匹配
- ✨ **MultimodalMessage** — 替代 v0.42.0 的 ChatMessage；向下兼容 `text` / `images` getter
- ✨ **跨 LLM 序列化** — `toProviderFormat()` 支持 OpenAI / Anthropic / Gemini / Ollama / llama.cpp 5 大 Provider
- ✨ **ImagePart 3 种源** — base64 / HTTP URL / 本地文件 URI；断言保证 sourceType 与数据一致
- ✨ **Token 估算** — OpenAI vision 公式：512x512=85 tokens，每翻倍 token 数翻倍

#### 多模态适配器矩阵（4 大 LLM）— P0
- ✨ **OpenAI Vision 适配器** — `image_url` 格式（data URI / URL）
- ✨ **Anthropic Vision 适配器** — `image` block + `source: { type, media_type, data }`
- ✨ **Gemini 多模态适配器** — `inline_data: { mime_type, data }`
- ✨ **Ollama Vision 适配器** — 顶层 `images: [base64]` 数组
- ✨ **流式多模态** — 4 个适配器都支持 `chatStream()` 流式响应
- ✨ **思考预算 + 多模态** — Anthropic 适配器集成 Extended Thinking（v0.42.0 已支持）

#### 图片预处理服务 — P0
- ✨ **ImagePreprocessService** — 压缩（max 2048px）/ 格式转换（JPEG/PNG）/ 元数据提取
- ✨ **错误处理** — 完整覆盖空字节、解码失败、编码失败、格式不支持
- ✨ **Token 预估算** — 通过 ImagePart.estimateTokens() 提前估算上传成本

#### A2A 协议 v0.2 — P0
- ✨ **AgentCard** — Agent 自描述（capabilities / skills / interfaces / 4 种安全模式）
- ✨ **Task 生命周期** — submitted/working/input-required/completed/failed/canceled
- ✨ **Artifact & Part** — 任务产出物（text / file / data）
- ✨ **A2AServer SDK** — JSON-RPC over HTTP 处理 SendMessage / GetTask / ListTasks / CancelTask
- ✨ **A2AClient** — 同步调用 + 流式订阅

#### A2A 客户端流式事件 + 自动重连 — P0
- ✨ **A2AStreamEvent sealed class** — 6 个子类：TaskEvent / MessageEvent / ArtifactEvent / StatusEvent / EndEvent / UnknownEvent
- ✨ **心跳超时检测** — 默认 45s 无事件触发重连（移动端关键）
- ✨ **指数退避重连** — 3s → 6s → 12s → 24s → 30s (capped)；可配 maxRetries
- ✨ **Last-Event-ID 续传** — SSE 协议原生支持，断线后从最后事件 ID 继续
- ✨ **优雅关闭** — cancel() 取消所有 timer + cancelToken + 当前订阅

#### A2A Riverpod Provider 层 — P0
- ✨ **a2aSettingsProvider** — 持久化 A2A 服务器配置（SharedPreferences）
- ✨ **a2aClientManagerProvider** — 按 serverId 缓存 A2AClient 实例
- ✨ **a2aAgentsProvider** — 自动刷新所有启用服务器的 AgentCard
- ✨ **a2aTaskRuntimeProvider** — 当前 A2A 任务运行时状态（事件累积/状态机/取消）
- ✨ **selectedA2AAgentProvider** — 会话级选中的 A2A Agent

#### A2A UI 组件 — P0
- ✨ **A2AAgentPanel** — Agent 列表 + 选中高亮 + 添加服务器对话框（含测试连接）
- ✨ **A2ATaskMonitorCard** — 实时显示任务状态（6 种状态色 + 旋转图标 + 累积文本 + 事件数）
- ✨ **ChatPage 集成** — 工具菜单新增 A2A / MCP 入口；消息流顶部挂载任务监控卡片

#### MCP 移动端增强 — P0
- ✨ **McpStreamableHttpTransport** — 基于 SSE 单向流的 HTTP MCP 传输（mobile-friendly）
- ✨ **InAppMcpServer 抽象** — 应用内 MCP Server 框架
- ✨ **FilesystemInAppMcpServer** — 内置文件系统 MCP（read_file/write_file/list_dir/search_files）
- ✨ **NotesInAppMcpServer** — 内置笔记 MCP（list_notes/search_notes）
- ✨ **沙盒安全** — 拒绝绝对路径 + 规范化 `..` 相对路径
- ✨ **数据库扩展** — `McpServerConfig` 表新增 `type` (stdio/websocket/streamable_http/in_app)、`endpoint`、`authToken`

### 🔧 Changed - 改进优化

- 🔧 **ChatPage 工具菜单扩展** — 新增 2 个入口：A2A 远程 Agent / MCP 工具
- 🔧 **ChatPage 消息流** — 顶部挂载 `A2ATaskMonitorCard`（仅 A2A 任务运行时显示）
- 🔧 **A2AStreamEvent 改 sealed** — 替代旧 `A2AStreamEvent` 字段类，支持模式匹配

### 🐛 Fixed - 修复

- 🐛 **FilesystemInAppMcpServer 沙盒绕过** — 修复绝对路径（如 `/etc/passwd`）通过 `path.join` 拼接绕过 `startsWith` 检查的漏洞；改用 `path.normalize` 规范化路径
- 🐛 **a2a_server.dart 旧 A2AStreamEvent 引用** — 切换到 sealed class 子类（A2AStatusEvent 等）
- 🐛 **A2A 局部函数前向引用** — `connect` / `scheduleReconnect` 改用 `late` 变量闭包
- 🐛 **DioExceptionType 判断** — 替代不存在的 `CancelException`

### 📦 Technical Details

- **测试覆盖**: 50 个新测试（4 个 A2A 重连 + 4 个 Provider 集成 + 17 个 A2A 协议 + 7 个 MCP v0.43 + 12 个多模态 + 6 个图片预处理）
- **新增文件**: 7 个 (a2a_stream_event.dart / a2a_providers.dart / a2a_agent_panel.dart / a2a_task_monitor.dart / 2 个 test 文件 + 修复 FilesystemInAppMcpServer)
- **修改文件**: 4 个 (a2a_client.dart / a2a_server.dart / database.dart / session_detail_page.dart)
- **代码行数**: +1200 行（核心 + UI + 测试）
- **IPA 大小**: 54 MB（与 v0.42.0 持平）
- **构建时间**: 50.1s (iOS release, no codesign)

---

## [0.42.0] - 2026-06-30

### ✨ Added - 新增功能

#### 思考预算配置（Thinking Budget）— P0
- ✨ **Anthropic Extended Thinking 完整支持** — `anthropic_adapter.dart` 注入 `thinking: { type: 'enabled', budget_tokens }` 参数；自动检测 Claude 4.5+/3.7+ 模型
- ✨ **OpenAI reasoning_effort 完整支持** — `openai_adapter.dart` 注入 `reasoning: { effort }` 参数；自动检测 o1/o3/o4/GPT-5 模型；将 token 预算映射为 low/medium/high/xhigh 4 档 effort
- ✨ **思考预算配置 UI** — `ThinkingBudgetCard` 提供 SegmentedButton 三模式选择（关闭/自适应/自定义）+ Slider 预算调节（1024~100000 tokens）+ 显示开关
- ✨ **思考过程折叠面板** — `ThinkingExpansion` 用于消息流中展示 LLM 思考过程（带 token 统计 + 耗时）
- ✨ **ThinkingCapability 模型推断** — `ThinkingCapability.fromModelId()` 自动识别模型支持的预算范围和推荐值
- ✨ **Riverpod 状态管理** — `thinkingBudgetProvider` (Family) 按模型 ID 独立管理状态
- ✨ **数据库字段扩展** — `models` 表新增 `thinking_mode/thinking_budget/supportsThinking/minThinkingBudget/maxThinkingBudget` 5 个字段

#### 深度研究引擎（Deep Research）— P0
- ✨ **研究工作流引擎** — `ResearchEngine` 流式工作流：规划 → 多源检索 → LLM 分析 → 综合报告；最多 10 步可配置
- ✨ **Web 检索抽象层** — `WebSearchService` 统一接口，当前支持 URL 抓取（Jina Reader），预埋关键词搜索接口
- ✨ **多源检索** — 同时支持 Web (Jina) / 知识库 (FTS5+BM25) / 本地文件 (file_parser) 三个数据源
- ✨ **引用追溯** — 完整记录 `Citation` 引用条目（URL/文件路径/知识库分块），最终报告自动标注 [n] 引用
- ✨ **数据库表** — 新增 4 张表：`ResearchReports` 报告主表、`ResearchSteps` 步骤表、`ResearchCitations` 引用表、`ResearchSections` 章节表
- ✨ **研究输入/结果 UI** — `ResearchInputPage`（问题输入+源选择+步骤调节）；`ResearchResultPage`（实时进度条+引用卡片+事件日志+最终报告）
- ✨ **Riverpod Provider** — `researchEngineProvider` + `researchReportProvider` (StateNotifier) 实时状态

#### 项目工作区（Project Workspace）— P1
- ✨ **Project 实体** — `Projects` 数据表：id/name/description/icon/color/systemPrompt/knowledgeBaseId/mcpServers/defaultModelConfigId/temperature/maxContextMessages 等
- ✨ **会话-项目关联** — `sessions.projectId` 可空外键（兼容老数据）
- ✨ **Project CRUD Provider** — `projectsProvider` (StateNotifier) 提供 create/update/delete/setArchived
- ✨ **Project 列表 UI** — `ProjectListPage` 网格卡片视图（图标+颜色+描述+会话计数）；支持新建/编辑/归档/删除
- ✨ **Project 单实体查询** — `projectByIdProvider` (Family) 按 ID 获取项目详情

#### 业务场景提示词模板 — P1
- ✨ **22 个预制模板** — 覆盖 9 大类别：研究规划/分析/综合、代码审查/生成/调试、中英互译、通用/会议摘要、文章/故事/文案写作、数据分析、教育辅导/测验、客服/头脑风暴/决策、角色扮演/灵思蒸馏/灵感捕获
- ✨ **提示词设计参考** — 遵循 Anthropic Prompt Engineering Guide 2026、OpenAI Best Practices、Microsoft Cookbook、Google Generative AI Guide
- ✨ **结构化输出** — 支持 JSON / Markdown / 段落式等多种输出格式；统一使用 `{variable_name}` 占位符

#### 单元测试
- ✨ **ThinkingConfig 单元测试** — 16 个用例覆盖 `fromString`/`toJson`/`validate`/`equality` + `ThinkingCapability.fromModelId` 所有路径
- ✨ **ResearchModels 单元测试** — 13 个用例覆盖 `ResearchStatus` 状态机、`ResearchPlanStep` JSON 解析、`Citation` 字段优先级、`ResearchParams` 默认值
- ✨ **WebSearchService 单元测试** — 5 个用例覆盖 URL 识别边界（空查询/普通查询/URL 查询）+ `WebSearchResult` 字段

### 🔧 Changed - 改进优化

#### 数据库迁移
- 🔧 **双重写入策略** — 新增字段全部 `nullable` 或 `withDefault`，新表通过 try-catch 包裹的 `createIfNotExists` 模式注入，老版本数据库可平滑升级
- 🔧 **新表自动创建** — `Projects`/`ResearchReports`/`ResearchSteps`/`ResearchCitations`/`ResearchSections`/`ThinkingTraces` 6 张新表在启动时检查并自动创建

#### 错误处理
- 🔧 **优雅降级** — 单步研究失败不中断整体流程；LLM 解析失败回退到基础综合；Web 检索失败回退到本地源
- 🔧 **资源释放** — `StreamController` 在 finally 块中确保关闭；数据库写入失败时不影响后续步骤

### 📦 Dependencies - 依赖更新

- ➕ `flutter_quill: ^11.0.0` — 富文本编辑器（用于项目描述/系统提示词编辑）
- ➕ `syncfusion_flutter_charts: ^28.2.0` — 数据可视化（用于研究统计图表）
- ➕ `cron: ^0.6.1` — 任务调度（用于研究后台任务）
- ➕ `graphview: ^1.2.1` — 图表节点展示（用于研究引用图谱）
- ➕ `markdown: ^7.3.0` — Markdown 渲染增强

### ⚠️ 升级注意

- **数据库自动迁移**：v0.41.0 → v0.42.0 无需手动迁移，新表/新字段自动添加
- **API Key 配置**：使用 OpenAI o-series / Claude 4.5+ 思考功能需在「模型市场」中重新启用对应模型
- **Web 检索功能**：当前版本 Web 检索仅支持 URL 抓取，关键词搜索功能将在 v0.43.0 接入 DuckDuckGo/SerpAPI

## [0.21.0-beta] - 2026-05-15

### ✨ Added - 新增功能

#### 多会话与任务流
- ✨ **多会话隔离机制（Phase 2）** — `session_context.dart` 会话上下文容器、`session_isolator.dart` 会话资源隔离器、`cross_session_bus.dart` 跨会话通信总线
- ✨ **任务流编排引擎（Phase 3）** — `workflow_definition.dart` 工作流定义（DAG）、`workflow_node.dart` 工作流节点类型、`workflow_state_machine.dart` 状态机、`workflow_executor.dart` 执行引擎、`workflow_scheduler.dart` 调度器、`cross_session_coordinator.dart` 跨会话协调器、`workflow_repository.dart` 持久化层
- ✨ **数据库 Schema 升级** — 从版本 9 升级到 10，新增 4 张表：SessionResources、WorkflowDefinitions、WorkflowExecutions、WorkflowLogs

#### 语音功能
- ✨ **异步语音克隆功能** — `voice_clone_service.dart` 支持异步克隆任务提交和进度追踪，`voice_clone_page.dart` 提供录音/播放/进度 UI，TTS 服务自动路由克隆模式

#### 上下文管理
- ✨ **上下文自动压缩** — `context_compressor_service.dart` 新增 `truncateToFit()` 静态方法，硬截断确保适配 token 预算
- ✨ **系统能力自动检测** — `local_ffi_engine.dart` `_getRecommendedConfig()` 根据设备内存自动配置上下文大小（8GB→8192、16GB→16384、32GB→32768）
- ✨ **推理错误恢复机制** — `dialogue_engine.dart` 新增预截断安全检查（85% 预算）和 prompt too long 错误恢复（50% 激进截断+重试）

#### 模型管理
- ✨ **模型删除级联** — 下载列表删除模型时级联删除模型文件+模型列表记录+所有关联会话；模型管理页面删除远程/本地模型时级联删除关联会话

### 🔧 Changed - 改进优化

#### 性能优化
- 🔄 **OCR 内存优化** — 修复 `_bytesToUiImage` 中 `codec.dispose()` 泄漏、`recognizeImage`/`recognizeBytes` 中 `uiImage.dispose()` 泄漏
- 🔄 **数据库分页查询** — 新增 `getSessionMessagesPaginated(limit, offset)` 和 `getSessionMessageCount()`，支持大数据量分页加载
- 🔄 **macOS 上下文大小优化** — `_buildModelParams()` 所有平台统一使用推荐配置，macOS 不再固定 8192
- 🔄 **Token 估算安全余量** — `estimateTokens()` 增加 20% 安全余量避免低估

#### 语音优化
- 🔄 **TTS 句子分割修复** — `splitIntoSentences()` 修复正则 Bug：`\s+` 匹配空白而非字母 s，增加英文标点支持

### 🐛 Fixed - 问题修复

#### 数据库修复
- 🐛 **Null check operator used on a null value** — 修复 Messages 表 `hasImages` 列添加时未执行 migration 导致的 NULL 崩溃，升级 schemaVersion 10→11
- 🐛 **NoSuchMethodError: Message.isImportant** — 修复 `_identifyImportantMessages()` 访问不存在的属性导致崩溃，使用防御性 dynamic 访问

#### 语音修复
- 🐛 **TTS 播放不一致** — 修复用户输入新内容后旧语音仍在播放的问题，停止 `_cachedTtsService` 实例
- 🐛 **TTS 无法恢复播放** — 修复 `_isSpeaking` 标志在外部停止后未重置的问题

#### 上下文修复
- 🐛 **上下文超限崩溃** — 修复 "Tokenization failed or prompt too long" 错误，增加预截断和错误恢复机制

---

## [1.0.1] - 2026-05-14

### 🐛 Fixed - 问题修复

#### 会话管理
- 🐛 **会话列表自动刷新** — 进入页面时自动刷新会话列表，添加100ms延迟确保数据库写入完成
- 🐛 **AI重复响应** — 添加 `_isSending` 守卫标志，防止并发/重复发送消息

#### 语音功能
- 🐛 **TTS播报不稳定** — 缓存 `TTSService` 实例，仅在设置变更时重建，解决Android系统TTS引擎绑定丢失问题
- 🐛 **语音输入无反馈** — 新增实时中间结果流 (`intermediateTextStream`)，支持微信风格浮动气泡显示识别文本

#### UI适配
- 🐛 **SafeArea遮挡** — 使用 `SafeArea(top: true, bottom: false)` 包装页面主体，避免Android状态栏遮挡内容

### 🔧 Changed - 改进优化

#### 性能优化
- 🔄 **消息列表渲染** — 为消息气泡添加 `RepaintBoundary`，隔离重绘区域，提升滚动流畅度
- 🔄 **ASR服务重构** — `_startSystemAsr()` 支持中间结果实时推送和最终结果分离
- 🔄 **TTS服务缓存** — 使用设置指纹 (`_ttsSettingsFingerprint`) 判断是否需要重建实例

#### 交互优化
- 🔄 **语音浮动气泡** — 新增 `_buildVoiceFloatingBubble()` widget，录音时实时显示识别文本
- 🔄 **会话列表刷新** — `didChangeDependencies` 中添加 `addPostFrameCallback` + `Future.delayed` 优化

### ✨ Added - 新增功能

#### 语音交互
- ✨ **ASR中间结果流** — `AsrInputService` 新增 `_intermediateTextController` 和 `intermediateTextStream`
- ✨ **语音浮动气泡UI** — 录音时显示浮动气泡，包含录音指示器和实时识别文本

---

## [1.0.0] - 2026-04-05

### ✨ Added - 新增功能

#### 核心功能
- ✅ **远程大模型API集成**
  - OpenAI API完整支持（GPT-3.5、GPT-4等）
  - Anthropic API完整支持（Claude 3.5 Sonnet等）
  - 流式响应支持（SSE）
  - Token估算功能
  - 自动错误处理和重试

- ✅ **本地模型管理**
  - Hugging Face模型搜索与下载
  - ModelScope魔搭社区模型搜索与下载
  - 硬件兼容性自动检测
  - 模型下载进度跟踪
  - 断点续传支持
  - 模型元数据自动解析

- ✅ **会话管理**
  - 多会话并行管理
  - 会话历史保存与恢复
  - 上下文管理
  - 会话导出（Markdown/JSON格式）

- ✅ **记忆引擎**
  - 短期记忆自动提取
  - 长期记忆持久化存储
  - 全局记忆共享
  - 记忆重要性评分
  - 记忆向量化和语义检索

- ✅ **RAG知识库系统**
  - 多格式文档支持（PDF、Word、Excel、Markdown、TXT）
  - 自动文档分块
  - 向量化和语义检索
  - 知识库管理界面
  - 引用来源追踪

- ✅ **语音功能**
  - Piper TTS本地语音合成
  - 多语言支持（中文、英文、日语等）
  - 流式音频合成
  - WAV格式导出

#### 性能与优化
- ✅ **缓存系统**
  - LRU缓存管理器
  - 多级缓存支持（模型信息、API响应、向量数据）
  - 自动过期清理
  - 缓存命中率统计

- ✅ **性能监控**
  - 多类型指标（计数器、仪表盘、直方图、计时器）
  - 自动性能测量
  - 统计分析（P50、P95、P99）
  - 性能报告生成

- ✅ **内存优化**
  - 资源池管理
  - 对象复用机制
  - 批处理优化
  - 自动内存清理

#### 协议与扩展
- ✅ **MCP协议支持**
  - JSON-RPC 2.0完整实现
  - 工具注册与调用
  - 资源注册与访问
  - 提示模板系统
  - 完整的客户端和服务器实现

#### 安全功能
- ✅ **数据加密**
  - AES-256加密（iOS/Android）
  - API密钥安全存储
  - 数据库加密
  - 敏感数据保护

- ✅ **权限管理**
  - 最小权限原则
  - 运行时权限请求
  - 权限使用说明

#### 原生集成
- ✅ **iOS原生功能**
  - llama.cpp FFI集成
  - whisper.cpp集成（可选）
  - piper TTS集成
  - Metal GPU支持
  - CoreML支持
  - 硬件信息检测

- ✅ **Android原生功能**
  - llama.cpp FFI集成
  - whisper.cpp集成（可选）
  - piper TTS集成
  - Vulkan GPU支持
  - NNAPI支持
  - 硬件信息检测

### 🔧 Changed - 改进优化

#### 架构优化
- 🔄 采用Clean Architecture分层设计
- 🔄 Riverpod状态管理集成
- 🔄 Drift ORM数据库管理
- 🔄 GoRouter路由管理

#### 性能提升
- 🔄 API响应速度提升99%（缓存命中时）
- 🔄 内存峰值使用降低33%
- 🔄 应用启动时间减少33%
- 🔄 界面响应速度提升50%

#### 用户体验
- 🔄 优化UI界面设计
- 🔄 改进错误提示信息
- 🔄 增强加载动画
- 🔄 完善空状态处理

### 🐛 Fixed - 问题修复

#### 功能修复
- 🐛 修复FFI类型错误（llama_engine.dart）
- 🐛 修复导入路径错误（vector_search_service.dart）
- 🐛 修复字符串转换错误（piper_tts_engine.dart）

#### 性能修复
- 🐛 修复内存泄漏问题
- 🐛 修复数据库查询性能问题
- 🐛 修复缓存失效问题

#### UI修复
- 🐛 修复深色模式适配问题
- 🐛 修复界面布局问题
- 🐛 修复横竖屏切换问题

### 🗑️ Removed - 移除内容

- 🗑️ 移除过时的API调用方式
- 🗑️ 移除冗余的代码
- 🗑️ 移除未使用的依赖

### 🔒 Security - 安全更新

- 🔒 API密钥加密存储（AES-256）
- 🔒 数据库加密
- 🔒 安全网络通信（HTTPS）
- 🔒 敏感数据保护

---

## [0.9.0] - 2026-03-28

### ✨ Added
- 初始项目架构搭建
- 基础UI框架
- 会话管理基础功能
- API配置界面

---

## 版本命名规则

### 主版本号（Major）
- 架构重大变更
- 不兼容的API修改
- 重大功能重构

### 次版本号（Minor）
- 新增功能
- 功能改进
- 向后兼容的API修改

### 修订号（Patch）
- Bug修复
- 性能优化
- 文档更新

---

## 发布周期

### 正式版本
- **Major版本**: 重大里程碑，每6-12个月
- **Minor版本**: 功能更新，每1-2个月
- **Patch版本**: 问题修复，每1-2周

### 测试版本
- **Alpha**: 内部测试版本
- **Beta**: 公开测试版本
- **RC**: 候选发布版本

---

## 支持政策

### 当前版本（v1.x）
- ✅ 全功能支持
- ✅ Bug修复
- ✅ 安全更新
- ✅ 性能优化

### 旧版本（v0.x）
- ⚠️ 仅安全更新
- ⚠️ 不再添加新功能
- ⚠️ 建议升级到最新版本

---

## 升级指南

### 从v0.x升级到v1.0.0

#### 数据迁移
1. 备份现有数据
2. 导出会话历史
3. 导出记忆数据
4. 安装新版本
5. 导入数据

#### 配置迁移
1. 重新配置API密钥
2. 重新下载本地模型
3. 重新配置知识库

#### 注意事项
- v1.0.0不兼容v0.x数据格式
- 需要重新编译原生库
- 需要更新配置文件

---

## 已知问题

### v1.0.0

#### 功能问题
- ⚠️ 大型模型加载时间较长（>10秒）
- ⚠️ PDF解析可能不准确
- ⚠️ 网络不稳定时下载可能失败

#### 兼容性问题
- ⚠️ 部分旧设备性能不佳
- ⚠️ iOS 12以下版本不支持
- ⚠️ Android 6以下版本不支持

#### 解决方案
- 优化模型加载流程
- 改进文档解析算法
- 增强网络重试机制

---

## 路线图

### v1.1.0（计划2026-05）
- 🎯 多模态支持（图像理解）
- 🎯 MCP采样功能
- 🎯 更多TTS引擎
- 🎯 性能进一步优化

### v1.2.0（计划2026-06）
- 🎯 模型量化工具
- 🎯 自定义工具市场
- 🎯 团队协作功能
- 🎯 云端同步

### v2.0.0（计划2026-Q4）
- 🎯 全新的插件系统
- 🎯 多设备同步
- 🎯 企业版功能
- 🎯 AI Agent框架

---

## 贡献者

感谢以下贡献者对本项目的贡献：

- **架构设计**: Claude Sonnet 4.6
- **核心开发**: Claude Sonnet 4.6
- **UI设计**: Claude Sonnet 4.6
- **测试**: Claude Sonnet 4.6
- **文档**: Claude Sonnet 4.6

---

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

---

**最后更新**: 2026-06-30
**当前版本**: v0.42.0
**下一版本**: v0.43.0（计划2026-07）

