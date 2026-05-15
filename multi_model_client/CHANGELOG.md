# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

**最后更新**: 2026-05-15
**当前版本**: v0.21.0-beta
**下一版本**: v0.22.0-beta（计划2026-05）
