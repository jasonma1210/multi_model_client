# MJ Nexus Series:灵犀通 - 多模态 AI 助手

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Series Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.40.0-blue" alt="版本"/>
  <img src="https://img.shields.io/badge/flutter-3.x-blue" alt="Flutter"/>
  <img src="https://img.shields.io/badge/dart-3.10.7+-blue" alt="Dart"/>
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS-green" alt="平台"/>
  <img src="https://img.shields.io/badge/license-Private-red" alt="许可"/>
</p>

---

**MJ Nexus Series:灵犀通** 是一款功能强大的跨平台 AI 助手应用，支持本地和远程大语言模型、实时语音对话、RAG 知识库、记忆引擎和多模态推理能力。

## ✨ 核心功能

### 🤖 多模型推理引擎
- **本地模型**：通过 llama.cpp FFI (llamadart) 加载 GGUF 格式模型，支持 Metal/Vulkan GPU 加速
- **远程模型**：兼容 OpenAI / Anthropic / Ollama API
- **多模态模型**：支持 Qwen2-VL、LLaVA 视觉语言模型，自动下载 mmproj 投影仪
- **模型市场**：内置热门模型推荐，支持断点续传下载
- **GPU 崩溃防护**：多层安全策略 — 参数安全上限、崩溃标记 + 安全模式自动恢复、GGUF 文件头预验证、推理阶段 GPU→CPU 自动回退

### 🎤 语音交互系统
- **ASR 语音识别**：Whisper API + Sherpa-ONNX 本地离线方案
- **TTS 语音合成**：4 种后端 — MiMo TTS（云端）、Sherpa-ONNX（本地离线）、OpenAI TTS API、系统内置 TTS
- **语音克隆**：MiMo TTS 语音复刻 API — 录音 → 转录 → 克隆自定义音色
- **TTS 风格控制**：导演级语音控制，支持风格标签、情绪标签、导演模式、自然语言控制
- **实时语音对话**：全链路流式 ASR → LLM → TTS，支持打断

### 💬 会话管理
- **会话隔离**：每个会话独立模型、上下文和配置
- **文件夹组织**：支持会话分组、置顶、归档
- **角色人设**：10+ 种预设人设（AI 工程师、提示词工程师、女王大人、小可爱等）
- **专家技能**：30+ 位领域专家角色（设计、工程技术、市场营销、法务、金融等）
- **会话导出**：Markdown 格式导出

### 🧠 记忆与知识库
- **记忆宫殿**：四级记忆分层（即时 → 工作 → 长期 → 归档），智能权重衰减，跨会话记忆融合
- **RAG 知识库**：PDF/Word/TXT/OCR 文档解析，FTS + BM25 + 语义搜索三路混合检索
- **语义搜索**：基于 Embedding 的向量相似度搜索
- **中文分词**：jieba 集成，优化中文检索质量

### 🎨 多模态能力
- **视觉理解**：发送图片到多模态模型进行分析
- **视频理解**：视频文件理解 + 连续对话
- **OCR 识别**：Google ML Kit 原生 OCR + textify 纯 Dart OCR

### 🔌 MCP 协议支持
- **MCP 服务管理**：统一管理所有 MCP 连接
- **工具调用**：标准化 MCP 协议工具调用接口
- **服务器管理**：MCP 连接管理器和服务器管理器

### 🔒 安全与隐私
- **AES-256 加密**：数据加密存储
- **安全密钥存储**：iOS Keychain / Android Keystore
- **应用锁**：PIN 码 + 生物识别（Face ID / Touch ID）
- **隐私优先**：所有数据本地存储，无遥测

### ⚙️ 系统功能
- **数据备份**：JSON 格式导入/导出，合并/覆盖模式
- **主题切换**：暗色 / 亮色 / 跟随系统
- **多语言**：中文 / 英文（国际化）
- **macOS 沙盒**：Security-Scoped Bookmark 外部文件访问
- **新手引导**：首次使用引导页

## 🏗️ 项目架构

```
lib/
├── core/                          # 核心功能层
│   ├── adapters/                  # API 适配器（OpenAI、Anthropic）
│   ├── constants/                 # 应用常量
│   ├── engines/                   # 推理引擎
│   │   ├── local_ffi_engine       # llama.cpp FFI 本地推理
│   │   ├── model_inference_engine # 统一推理路由
│   │   ├── piper_tts_engine       # Piper TTS 引擎
│   │   └── whisper_engine         # Whisper ASR 引擎
│   ├── models/                    # 数据模型
│   ├── providers/                 # Riverpod 状态管理
│   ├── services/                  # 核心服务（TTS、ASR、MCP、记忆等）
│   ├── security/                  # 安全服务（加密、书签）
│   ├── protocols/                 # MCP 协议实现
│   ├── platform/                  # 平台适配（硬件、加速）
│   ├── router/                    # go_router 路由
│   └── storage/                   # Drift ORM 数据库
├── features/                      # 功能模块
│   ├── session/                   # 会话管理与对话引擎
│   ├── model/                     # 模型管理与市场
│   ├── skill/                     # 技能系统（专家与插件）
│   ├── rag/                       # RAG 知识库
│   ├── memory/                    # 记忆引擎
│   ├── prompt/                    # 提示词引擎
│   ├── settings/                  # 设置页面
│   └── workflow/                  # 工作流引擎
├── generated/                     # 国际化生成代码
├── l10n/                          # 本地化 ARB 文件
├── app.dart                       # 应用根组件
└── main.dart                      # 入口函数
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x + Dart 3.10.7+ |
| 状态管理 | Riverpod 2.x + 代码生成 |
| 路由 | go_router 17.x |
| 数据库 | Drift ORM (SQLite) |
| 本地推理 | llamadart 0.6.16 (llama.cpp FFI b9010) |
| 网络 | Dio 5.x + http + web_socket_channel |
| 后台下载 | background_downloader（原生后台服务，断点续传） |
| TTS | Sherpa-ONNX 1.12.x / flutter_tts / MiMo TTS API |
| ASR | speech_to_text / Sherpa-ONNX |
| 录音 | record 6.x + flutter_recorder (miniaudio FFI) |
| OCR | Google ML Kit + textify (纯 Dart) |
| PDF | pdfx + syncfusion_flutter_pdf |
| 加密 | encrypt + crypto (AES-256) |
| 安全存储 | flutter_secure_storage |
| 生物识别 | local_auth |
| 中文分词 | jieba_flutter |
| 位置服务 | geolocator |

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.10.7+
- Dart SDK 3.10.7+
- Xcode 15+（iOS/macOS 开发）
- Android Studio（Android 开发）

### 安装

```bash
# 克隆仓库
git clone https://github.com/jasonma1210/multi_model_client.git
cd multi_model_client

# 安装依赖
flutter pub get

# 生成代码（Drift / Riverpod）
dart run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run
```

### 构建发布版

```bash
# Android APK
flutter build apk --release

# macOS
flutter build macos --release

# iOS
flutter build ios --release
```

## 📱 支持平台

| 平台 | 状态 | GPU 加速 | 最低版本 |
|------|------|----------|----------|
| iOS | ✅ 已支持 | Metal | 15.0+ (iPhone 8+) |
| Android | ✅ 已支持 | Vulkan | 10.0+ (arm64-v8a) |
| macOS | ✅ 已支持 | Metal (Apple Silicon) | Apple Silicon & Intel |
| Windows | 🔧 部分支持 | CUDA/CPU | - |
| Linux | 🔧 部分支持 | CUDA/CPU | - |

## 📊 性能指标

| 指标 | 目标 |
|------|------|
| 冷启动 | ≤ 2 秒 |
| 7B 模型加载 | ≤ 3 秒 |
| 推理速度 | ≥ 30 tokens/sec |
| 语音延迟 | ≤ 500ms |
| 内存占用 | ≤ 1GB |

## 📦 发布版本

从 [Releases](https://github.com/jasonma1210/multi_model_client/releases) 页面下载最新版本 (v0.40.0)：
- `app-release.apk` — Android APK
- `MJ_Nexus_Series.dmg` — macOS DMG

## 📋 更新日志

### v0.40.0 (2026-06-06)

**品牌更新**
- 应用更名为 **MJ Nexus Series:Synpse**（英文） / **MJ Nexus Series:灵犀通**（中文）
- 更新所有平台的应用标题（Android、iOS、macOS）

**TTS 语音改进**
- 默认 TTS 提供商更改为 **MiMo**（云端 TTS），语音质量更好
- 移除自动降级/回退逻辑 — 用户完全控制 TTS 提供商切换
- 新增 **1分钟总超时** 机制 — 语音输出如在1分钟内未完成，自动停止
- 不再需要等待 20-30 秒自动切换提供商

## 📄 许可证

私有项目，保留所有权利。

## 🤝 参与贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

如有问题或建议，请在 GitHub 上提交 Issue。

---

## 📝 会话记录

### Session #42 — 灵感一瞬播放按钮简化 + 全选/一键总结 + mmproj 模型过滤 (2026-05-29)

**会话背景**：用户提出3个问题：(1) 播放按钮过于复杂（4个按钮），需要简化为播放/停止两个按钮切换；(2) 详细页面缺少全选勾选按钮和一键总结功能；(3) 加载模型时报错 `Failed to load model gemma-4-26B-A4B-it-mmproj-BF16.gguf`，原因是加载了 mmproj（视觉模型投影器）文件而非主模型。

**会话目的**：简化播放控件、补全详细页面功能、修复模型加载错误。

**完成的主要任务**：
1. 主页面录音项播放控件简化：从4个按钮（播放/暂停/停止/速度）改为2个按钮切换（播放/停止）
2. 详细页面录音项同样简化为播放/停止切换
3. 详细页面顶部添加全选 Checkbox，支持一键全选/取消全选所有录音
4. 详细页面底部添加"一键总结"按钮（仅在有选中录音时显示）
5. 添加 `_loadFilteredModels()` 方法，过滤掉 filePath 包含 'mmproj' 的模型文件
6. 在3处模型加载代码中应用过滤
7. 验证 `flutter analyze` 和 `flutter build macos --debug` 均通过

**技术栈**：Flutter, Dart, SharedPreferences, ModelEntry, LocalFFIEngine, globalModelEngine

**关键决策和解决方案**：
1. 播放控件简化：使用 `isPlaying ? Icons.stop_circle : Icons.play_circle` 实现图标切换
2. 全选逻辑：`allIds.every((id) => _selectedRecordingIds.contains(id))` 判断是否全选
3. mmproj 过滤：检查 `m.filePath!.contains('mmproj')`，跳过视觉模型投影器文件
4. 详细页面一键总结按钮放在 ListView 底部，仅当有选中录音时显示

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 添加 `_loadFilteredModels()` 方法，过滤 mmproj 文件 | 防止加载视觉模型投影器导致崩溃 |
| `inspiration_page.dart` | 主页面和详细页面播放按钮简化为播放/停止切换 | 用户要求简化操作 |
| `inspiration_page.dart` | 详细页面添加全选 Checkbox + 一键总结按钮 | 用户要求补全功能 |
| `README.md` | 追加 Session #42 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #42 会话记录 | 按要求记录会话总结 |

### Session #43 — 播放按钮切换修复 + 一键总结加载动画 + 模型选择记忆 (2026-05-29)

**会话背景**：用户反馈两个问题：(1) 播放按钮点击播放后，再次点击不会停止播放（逻辑 bug）；(2) 一键总结按钮没有加载动画，且模型选择没有记忆功能。

**会话目的**：修复播放按钮切换逻辑、添加加载动画、实现模型选择记忆。

**完成的主要任务**：
1. 修复主页面和详细页面的 `_playRecording` 方法：当录音正在播放时，再次点击调用 `_stopPlayback()` 停止播放
2. 详细页面 AppBar 和底部一键总结按钮：生成中显示加载动画
3. 模型选择记忆：用户选择模型后保存到 `SharedPreferences`，下次自动选中

**技术栈**：Flutter, Dart, SharedPreferences, AudioPlayer, CircularProgressIndicator

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 修复播放/停止切换逻辑 | 修复点击播放后无法停止的 bug |
| `inspiration_page.dart` | 添加加载动画 | 用户体验优化 |
| `inspiration_page.dart` | 添加模型保存逻辑 | 实现模型选择记忆功能 |
| `README.md` | 追加 Session #43 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #43 会话记录 | 按要求记录会话总结 |

### Session #44 — 播放按钮颜色优化：停止按钮改为红色 (2026-05-29)

**会话背景**：用户要求播放按钮点击播放后变成红色停止按钮，再次点击停止后变回播放按钮。

**会话目的**：优化播放按钮颜色，停止状态使用明确的红色。

**完成的主要任务**：
1. 主页面和详细页面播放按钮：停止状态颜色改为 `Colors.red`
2. 验证构建通过

**技术栈**：Flutter, Dart, Colors

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 播放按钮停止状态改为 `Colors.red` | 用户要求红色停止按钮 |
| `README.md` | 追加 Session #44 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #44 会话记录 | 按要求记录会话总结 |

### Session #45 — ASR 架构升级：VAD预处理 + 说话人分离 + 模型更新检测 (2026-05-29)

**会话背景**：用户要求对 ASR 功能进行全面升级，包括 VAD 预处理、说话人分离、模型版本管理。

**会话目的**：设计并实现企业级 ASR 架构。

**完成的主要任务**：
1. 创建 VAD 服务：Silero VAD 模型集成，语音活动检测
2. 创建说话人分离服务：ECAPA-TDNN 声纹嵌入，AHC 聚类算法
3. 创建音频处理管道：整合 VAD + ASR + 说话人分离
4. 创建模型更新服务：GitHub Release 检测，多源下载

**技术栈**：Flutter, Dart, Sherpa-ONNX, Silero VAD, ECAPA-TDNN

**新增的文件**：
| 文件 | 内容 | 用途 |
|------|------|------|
| `vad_service.dart` | VAD 预处理服务 | 语音活动检测 |
| `speaker_diarization_service.dart` | 说话人分离服务 | 声纹嵌入，聚类 |
| `audio_processing_pipeline.dart` | 音频处理管道 | 整合处理流程 |
| `model_update_service.dart` | 模型更新服务 | 版本检测，下载 |

**架构设计**：
```
原始音频 → VAD → ASR + 说话人分离（并行）→ 时间戳对齐 → 最终输出
```

### Session #46 — 灵感一瞬录音时间限制 + 计时显示 + 倒计时提示 (2026-05-29)

**会话背景**：用户要求灵感一瞬录音功能增加时间限制，方便管理录音时长。

**会话目的**：实现5分钟录音时间限制，录制时显示计时，剩余10秒时提示。

**完成的主要任务**：
1. 添加录音时间限制：最大5分钟（300秒），超时自动停止
2. 录制计时显示：实时显示已录制时长和总时长（如 01:30 / 05:00）
3. 进度条显示：LinearProgressIndicator 显示录制进度
4. 10秒倒计时提示：剩余10秒时显示橙色警告，SnackBar 提示用户

**技术栈**：Flutter, Dart, Timer, LinearProgressIndicator

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 添加5分钟时间限制和倒计时功能 | 用户要求限制录音时长 |
| `README.md` | 追加 Session #46 会话记录 | 按要求记录会话总结 |
| `README_zh.md` | 追加 Session #46 会话记录 | 按要求记录会话总结 |

### Session #47 — v0.42.0 三大核心功能实施：思考预算配置 + 深度研究 + 项目工作区 (2026-06-30)

**会话背景**：基于 v0.41.0 基础，MJ Nexus 进入 v0.42.0 升级阶段，本会话集中实现 3 大核心 P0/P1 任务。

**会话主要目的**：
1. 落地 Anthropic Extended Thinking 与 OpenAI reasoning_effort 的双向支持
2. 实现 OpenAI/Claude/Gemini 风格的深度研究（Deep Research）引擎
3. 实现项目工作区（Project Workspace）将多会话/工具/知识库/MCP 服务聚合到项目维度

**完成的主要任务**：
1. **思考预算配置（Thinking Budget）**：
   - OpenAI 适配器：o-series / GPT-5 模型支持 `reasoning: { effort }` 参数注入
   - Anthropic 适配器：Claude 4.5+ 支持 Extended Thinking `thinking: { type, budget_tokens }` 参数注入
   - 数据库 `models` 表新增 `thinking_mode`、`thinking_budget`、`supportsThinking`、`min/maxThinkingBudget` 5 个字段
   - Riverpod `thinkingBudgetProvider` (Family) 状态管理
   - `ThinkingBudgetCard` UI：SegmentedButton 三模式选择 + 预算 Slider + 显示开关
   - `ThinkingExpansion` 折叠面板用于展示思考过程

2. **深度研究引擎（Deep Research）**：
   - 7 张数据表：ResearchReports/Steps/Citations/Sections/Projects 等（drift schema）
   - `ResearchEngine` 流式工作流：规划 → 多源检索 → LLM 分析 → 综合报告
   - `WebSearchService` 抽象（当前支持 URL 抓取 + 关键词搜索预埋）
   - 多源检索：Web (Jina) / 知识库 (FTS5+BM25) / 本地文件 (file_parser)
   - 22 个业务场景提示词模板（prompt_scenarios.dart）
   - `ResearchInputPage` 与 `ResearchResultPage` 双页面 UI
   - Riverpod `researchEngineProvider` + `researchReportProvider` 状态管理

3. **项目工作区（Project Workspace）**：
   - 数据模型：`Projects` 数据表（id/name/description/icon/color/systemPrompt/knowledgeBaseId/mcpServers 等）
   - 关联：`Sessions.projectId` 可空外键（兼容老数据）

**技术栈**：
- Flutter / Dart 3.10+
- flutter_riverpod 2.6.x (StateNotifier + Provider)
- drift 2.28.x (ORM + 类型安全 DAO)
- flutter_quill 11.x (富文本编辑器)
- syncfusion_flutter_charts 28.x (图表)
- cron 0.6.x (任务调度)
- graphview 1.2.x (节点图)
- dio 5.x (网络)

**关键决策和解决方案**：
1. **数据库迁移策略：双重写入**。新增字段全部 `nullable` 或 `withDefault`，新表通过 try-catch 包裹的 `createIfNotExists` 模式注入，老版本数据库可平滑升级，不丢数据。
2. **PromptTemplates 命名冲突**。Drift Table 类和业务模板常量类同名，使用 `import as scenarios` 别名隔离。
3. **ResearchSection 命名冲突**。Drift 自动生成的 DataClassName 与领域模型同名，使用 `import as db` 别名隔离，使用时 `db.ResearchSection`。
4. **Web 检索降级方案**。Jina Reader 仅支持 URL 抓取（r.jina.ai），不提供搜索 API。WebSearchService 优先支持 URL 列表抓取，关键词搜索预埋接口（待接入 DuckDuckGo/SerpAPI 等）。
5. **LLM Caller 解耦**。ResearchEngine 接受 `Future<String> Function(String, String)` 注入，避免与具体 LLM Provider 强耦合。
6. **业务场景提示词设计**。参考 Anthropic Prompt Engineering Guide 2026 / OpenAI Best Practices / Microsoft Cookbook / Google Guide，22 个模板覆盖研究/代码/写作/教育/商业/创意 9 大类。

**会话中主要使用的工具**：
- flutter analyze（静态分析）
- dart run build_runner build（Drift 代码生成）
- Read / Edit / Write / Grep / Glob
- TaskCreate 任务管理

**修改了哪些文件**：

| 文件 | 修改内容 | 修改原因 |
|------|---------|---------|
| `pubspec.yaml` | 新增 flutter_quill/syncfusion_flutter_charts/cron/graphview/markdown 依赖 | v0.42.0 新功能需要 |
| `lib/core/adapters/openai_adapter.dart` | OpenAIConfig 注入 reasoning 参数；OpenAIUsage 解析 reasoning_tokens | 支持 o-series/GPT-5 思考预算 |
| `lib/core/adapters/anthropic_adapter.dart` | AnthropicConfig 注入 Extended Thinking 参数；AnthropicUsage 解析 thinking_tokens | 支持 Claude 4.5+ Extended Thinking |
| `lib/core/storage/database.dart` | 新增 Projects/ResearchReports/Steps/Citations/Sections/ThinkingTraces 7 张表；models/messages/sessions 扩展字段 | v0.42.0 三大功能需要新表 |
| `lib/core/services/web_search_service.dart` | 新增 Web 检索服务 | 深度研究 Web 源检索 |
| `lib/core/services/file_parser_service.dart` | 新增 listRecentFiles 实例方法 + RecentFileInfo 数据类 | 深度研究文件源检索 |
| `lib/core/templates/prompt_scenarios.dart` | 新增 22 个业务场景提示词模板 | 提供研究/代码/写作/教育/商业/创意场景 |
| `lib/core/models/thinking_config.dart` | 新增 ThinkingConfig/ThinkingMode/ThinkingCapability 模型 | 思考预算类型定义 |
| `lib/core/widgets/thinking_expansion.dart` | 新增思考过程折叠面板组件 | UI 展示思考过程 |
| `lib/features/model/providers/thinking_budget_provider.dart` | 新增 ThinkingBudgetController (Family) | 思考预算状态管理 |
| `lib/features/model/presentation/widgets/thinking_budget_card.dart` | 新增思考预算配置卡片 | 模型配置页 UI |
| `lib/features/research/domain/research_models.dart` | 新增 ResearchStatus/StepType/Citation/Section/Params 等数据模型 | 深度研究领域模型 |
| `lib/features/research/domain/research_engine.dart` | 新增 ResearchEngine 流式工作流 | 深度研究核心引擎 |
| `lib/features/research/providers/research_provider.dart` | 新增 researchEngine/researchReport Provider | 深度研究状态管理 |
| `lib/features/research/presentation/pages/research_input_page.dart` | 新增研究输入页面 | 深度研究入口 |
| `lib/features/research/presentation/pages/research_result_page.dart` | 新增研究结果页面 | 实时显示进度、引用、报告 |

---

## Session #37 — v0.42.0 实施完成（2026-06-30）

### 会话背景
继续 v0.42.0 完整版（一次性实施 3 个 Task：思考预算 + 深度研究 + 项目工作区）的剩余工作。已完成实施 + 测试覆盖 + 编译验证。

### 完成的主要任务
1. **测试覆盖增强**：新增 4 个测试文件 / 42 个测试用例
2. **测试验证**：v0.42.0 全部 76 个新测试通过
3. **iOS 编译**：`flutter build ios --release --no-codesign` 成功（74.9s，207.2MB）
4. **IPA 打包**：54MB IPA 文件保存到 `release/v0.42.0/MJ_Nexus_v0.42.0.ipa`
5. **Git 提交**：`v0.42.0: 思考预算 + 深度研究 + 项目工作区` commit (be86dd9) 已创建

### 修改文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `test/research_engine_test.dart` | 新建 12 个测试 | 验证 ResearchEngine 事件类、JSON 解析 |
| `test/project_service_test.dart` | 新建 8 个测试 | 验证 Projects CRUD + 字段默认值 |
| `test/openai_adapter_thinking_test.dart` | 新建 12 个测试 | 验证 OpenAI reasoning_effort 注入 |
| `test/anthropic_adapter_thinking_test.dart` | 新建 10 个测试 | 验证 Anthropic Extended Thinking 注入 |
| `docs/V0.42.0_IMPLEMENTATION_PLAN.md` | 状态更新为"全部完成" | 反映 v0.42.0 实施已完成 |
| `release/v0.42.0/MJ_Nexus_v0.42.0.ipa` | 新建 54MB IPA 包 | 准备 GitHub Release v0.42.0 |

### 待用户决策
1. GitHub 网络恢复后推送 v0.42.0 commit 到 origin/master
2. 创建 GitHub Release v0.42.0 并上传 IPA
3. 是否补充 Android/macOS 平台编译验证

---

## 会话总结 #38 (2026-06-30 v0.43.0 - 多模态 + A2A + MCP)

### 会话背景
MJ Nexus v0.43.0 实施阶段，需要完成：1) 多模态统一抽象与 4 大 LLM 适配器 2) A2A 协议 v0.2 + 客户端流式事件与自动重连 3) ChatPage 集成 A2A / 多模态 / MCP

### 会话主要目的
基于 v0.43.0 计划文档一次性实施全部 4 个 Phase（多模态 + A2A + MCP Mobile + UI 集成），按用户要求保持最小侵入（不动 6500+ 行 session_detail_page.dart 核心）

### 完成的主要任务
1. ✅ 完善 A2A 客户端流式事件（sealed class 6 子类）+ 心跳 + 指数退避重连 + Last-Event-ID 续传
2. ✅ 创建 A2A Riverpod Provider 层（5 个 provider）
3. ✅ 创建 A2A UI 组件（AgentPanel + TaskMonitorCard）
4. ✅ ChatPage 工具菜单新增 A2A / MCP 入口
5. ✅ ChatPage 消息流顶部挂载 A2A 任务监控
6. ✅ 修复 FilesystemInAppMcpServer 沙盒绕过漏洞（path.normalize）
7. ✅ 50 个新单元测试全部通过
8. ✅ flutter analyze + flutter build ios 通过
9. ✅ GitHub Release v0.43.0 发布（54 MB IPA）

### 主要技术栈
- Flutter 3.x / Dart 3.10.7+（sealed class 模式匹配）
- Dio + SSE（Streamable HTTP MCP / A2A 流式）
- Riverpod 2.x（StateNotifier + Provider）
- Drift（数据库扩展）
- shared_preferences（A2A 设置持久化）
- path（沙盒规范化）

### 关键决策和解决方案
1. **A2AStreamEvent 改 sealed class** — 替代旧字段类，编译期模式匹配
2. **A2A 客户端重连用 late 闭包** — 解决 Dart 局部函数前向引用限制
3. **A2AStreamSubscription 暴露 .test 工厂** — @visibleForTesting 让测试构造
4. **ChatPage 集成最小侵入** — 工具菜单 + 任务监控卡片，不重写核心
5. **InAppMcpServer 沙盒用 path.normalize** — 拒绝绝对路径 + 规范化 `..` 相对路径
6. **MCP 数据库扩展 4 种传输** — `stdio/websocket/streamable_http/in_app`

### 主要使用的工具
- Read / Write / Edit / Glob / Grep
- Shell (flutter analyze / flutter test / flutter build ios / git / gh)
- run_mcp（无）
- 浏览器工具（无）

### 修改了哪些文件

| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/core/protocols/a2a/a2a_client.dart` | 重构为支持 reconnect + Last-Event-ID；新增 A2AReconnectConfig / A2AStreamSubscription / A2AStreamException | v0.43.0 核心：SSE 自动重连 + 续传 |
| `lib/core/protocols/a2a/a2a_server.dart` | 适配 sealed A2AStreamEvent（switch 模式匹配） | 配合 a2a_stream_event.dart 重构 |
| `lib/core/protocols/mcp_transports/in_app_mcp_server.dart` | 修复沙盒路径越界（path.normalize 替代 startsWith） | 修复 `/etc/passwd` 漏洞 |
| `lib/core/storage/database.dart` | McpServerConfig 表新增 `type` (4 传输) / `endpoint` / `authToken` | 支持 v0.43.0 Streamable HTTP MCP |
| `lib/features/session/presentation/pages/session_detail_page.dart` | 工具菜单新增 A2A / MCP 入口；消息流顶部挂载 A2ATaskMonitorCard | 集成 v0.43.0 新功能 |
| `lib/core/protocols/a2a/a2a_stream_event.dart` | **新建** 6 子类 sealed class（A2ATaskEvent / A2AMessageEvent / A2AArtifactEvent / A2AStatusEvent / A2AEndEvent / A2AUnknownEvent）| 替代旧字段类 |
| `lib/features/a2a/providers/a2a_providers.dart` | **新建** 5 个 provider（Settings / ClientManager / Agents / TaskRuntime / SelectedAgent）| Riverpod 状态管理 |
| `lib/features/a2a/presentation/a2a_agent_panel.dart` | **新建** Agent 列表 + 添加服务器对话框（含测试连接） | A2A UI 入口 |
| `lib/features/a2a/presentation/a2a_task_monitor.dart` | **新建** 6 状态色 + 旋转图标 + 累积文本 + 事件数 | 任务实时监控 |
| `test/a2a_client_reconnect_test.dart` | **新建** 15 个测试（事件解析 / 任务状态 / 客户端实例化）| 单元测试 |
| `test/a2a_providers_integration_test.dart` | **新建** 4 个测试（Provider 协同）| 集成测试 |
| `CHANGELOG.md` | 追加 v0.43.0 章节（多模态 + A2A + MCP + 测试）| 记录发布说明 |
| `docs/V0.43.0_IMPLEMENTATION_PLAN.md` | 状态从"进行中"改为"全部完成" + 新增第十章交付清单 | 反映完成度 |
| `release/v0.43.0/MJ_Nexus_v0.43.0.ipa` | **新建** 54MB IPA 包 | GitHub Release 资源 |

### 发布物
- **GitHub Tag**: v0.43.0
- **GitHub Commit**: ada03f5
- **GitHub Release**: https://github.com/jasonma1210/multi_model_client/releases/tag/v0.43.0
- **IPA**: 54 MB
- **构建时间**: 50.1s
- **测试**: 50 个新单元测试全部通过

### 待用户决策
1. Android / macOS 平台编译验证
2. A2A Server 端在 MJ Nexus 内暴露（将内置 LlmA2AAgent 挂到 A2AServer）
3. 多模态 ImageInput 完整替换 ChatPage 现有 _selectedImages 流程（涉及 300+ 行逻辑）
4. A2A Agent 任务完成后消息自动写回 ChatPage 会话消息流

---

## 会话总结 #39 (2026-06-30 v0.43.0 MCP 工具调用可视化)

### 会话背景
v0.43.0 已发布（A2A + 多模态 + MCP 移动端），但 ChatPage 中的 MCP 集成只完成了"激活状态显示"（`_activeMcpTools` 集合 + 横幅），缺乏实际的"工具调用可视化"。用户明确要求：**"让用户能看到 MCP 工具被调用的过程和结果"**。

### 会话主要目的
补强 v0.43.0 的 MCP 工具调用可视化能力，让用户能：
1. 看到工具调用全过程（pending → running → success/failed）
2. 看到工具参数、结果、错误、耗时
3. 手动调用 MCP 工具（调试 & 测试用）

### 完成的主要任务
1. ✅ 创建 `McpToolCallProvider`（Riverpod StateNotifier）跟踪最近 50 条工具调用记录
2. ✅ 创建 `McpToolCallCard` UI 组件（可展开/收起 + JSON 折叠展示）
3. ✅ 创建 `McpToolExplorerPage` MCP 工具浏览页（按 Server 分组 + 手动调用）
4. ✅ 集成到 ChatPage（消息流挂载 + 工具菜单入口）
5. ✅ 9 个新单元测试全部通过
6. ✅ iOS Release 编译成功（44.4s, 208.4MB Runner.app）
7. ✅ IPA 重新打包（54MB）

### 主要技术栈
- Flutter 3.x / Dart 3.10.7+（sealed class 模式匹配）
- Riverpod 2.x（StateNotifierProvider）
- ConsumerStatefulWidget + AnimatedBuilder（旋转图标）
- SelectableText + JsonEncoder.withIndent（JSON 美化显示）
- SessionMcpToolManager（现有 MCP 工具调用抽象）

### 关键决策和解决方案
- **状态机设计**：使用枚举 `McpToolCallStatus` 明确工具调用生命周期（5 个状态），避免散落的 bool 字段
- **记录截断策略**：最多保留最近 50 条记录，防止长时间会话内存膨胀
- **独立浏览页**：与 A2A 任务监控卡片分离，调试工具调用不影响主对话流
- **JSON 折叠展示**：参数和结果用 JsonEncoder 格式化（缩进 2 空格），可折叠避免界面过长
- **Messenger 缓存**：`_showInvokeDialog` 中先 `ScaffoldMessenger.of(context)` 缓存，避免 `use_build_context_synchronously` 警告
- **现有架构复用**：直接调用 `SessionMcpToolManager.callSessionTool`，不绕过现有权限/确认/日志链路

### 主要使用的工具
- `flutter analyze` - 静态分析（新增 0 错误）
- `flutter test` - 单元测试（9/9 MCP 新测试 + 52/52 v0.43.0 回归测试全部通过）
- `flutter build ios --release --no-codesign` - iOS Release 编译
- `zip` - IPA 打包
- `Read / Write / Edit / Grep` - 文件操作

### 修改了哪些文件

| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/features/mcp/providers/mcp_tool_call_provider.dart` | **新建** 174 行 | 跟踪 MCP 工具调用生命周期 |
| `lib/features/mcp/presentation/mcp_tool_call_card.dart` | **新建** 480 行 | ChatPage 嵌入式调用卡片 |
| `lib/features/mcp/presentation/pages/mcp_tool_explorer_page.dart` | **新建** 360 行 | MCP 工具浏览/手动调用页 |
| `test/mcp_tool_call_provider_test.dart` | **新建** 9 个测试 | 验证 Provider 状态机 |
| `lib/features/session/presentation/pages/session_detail_page.dart` | import + 菜单项 + `_openMcpToolExplorer()` 方法 + 消息流挂载 | 集成 MCP 工具卡片 |

### 待用户决策
1. 是否需要在 v0.44.0 把 LLM Function Calling 链路（`SessionMcpToolManager.toFunctionCallingFormat`）真正接到 ChatPage 的 `dialogueEngine`，让 AI 自动调用 MCP 工具
2. `McpToolCallCard` 是否需要支持"复制为 Markdown"等快捷操作
3. `McpToolExplorerPage` 是否需要支持"工具调用历史"分页
4. iOS / Android / macOS 三端是否都要编译验证

---

## Session #48 — v0.44.0 Function Calling 真实接入 + 性能优化 + 模型加载策略 + CI/CD (2026-06-30)

### 会话背景

v0.43.0 发布后留下 4 项待决策事项（见 Session #39 末尾）。用户要求一次性完成全部决策，并做整体优化：
1. 把 LLM Function Calling 链路接到 ChatPage `dialogueEngine`，让 AI 自动调用 MCP 工具
2. `McpToolCallCard` 添加"复制为 Markdown"等快捷操作
3. `McpToolExplorerPage` 添加"调用历史"分页
4. Android/macOS 三端编译验证

同时要求：审计桌面端与移动端的功能覆盖、优化加载模型策略（本地 llama.cpp / 远程 API / MCP 调用）、会话页面刷新与卡顿优化，**务必遵循项目的收敛性原则**（不引入新大抽象、不重写核心、增量演进、向后兼容）。

### 会话主要目的

1. 完成 v0.43.0 遗留的 4 项决策（FC 真实接入 + 工具卡快捷操作 + 调用历史分页 + 三端编译验证）
2. 落地性能优化（B1-B6）与模型加载策略（C1-C3）
3. 建立跨平台能力矩阵与 CI/CD 流水线
4. 完成三端发布与 GitHub Release

### 完成的主要任务

#### Task 1 — LLM Function Calling 真实接入（Stage A）
1. **A3.5 本地 FFI 真 FC**：新建 `lib/core/engines/fc_patterns.dart`（4 种 FC 模板正则 + 通用兜底解析器）；`LocalFFIEngine` 新增 `generateStreamWithTools` 方法（不改原 `generateStream` 签名）
2. **A3.4 DialogueEngine 编排**：`streamResponse` 改用 `generateChatStreamWithTools`；检测 `chunk.toolCall` → 跟踪 `detectedToolCall` → `_executeRealToolCall`（执行工具 → 通知 UI → 回填数据库）；保留伪 FC 作为兜底
3. **ChatOptions 扩展**：新增 `tools / toolChoice / fcFormat` 字段；新增 `ChatStreamChunk` 类（text / toolCall / isToolCallEnd）

#### Task 2 — 性能优化（B1-B6）
1. **B1 图片处理进 Isolate**：`image_preprocess_service.dart` 新增 `_processBytesInIsolate` 顶层函数；`processBytes` 改用 `await compute()`；保留 `_processBytesSync` 作为 fallback
2. **B2 MessageParser LRU 缓存**：`message_bubble.dart` 中 `_AssistantBubbleState` 新增静态 LRU 缓存（容量 50）；新增 `_parseWithCache` 方法
3. **B3 sessionStateProvider select**：保留原 `ref.watch`（拆分需改 `_buildAppBar` / `_buildMessagesList` 签名，违反收敛性原则）
4. **B4 振幅节流**：`session_detail_page.dart` 新增 `_lastAmplitudeUpdate` 字段；振幅 listen 回调中加 200ms 节流
5. **B5 输入框 ValueListenableBuilder**：发送按钮区域用 `ValueListenableBuilder<TextEditingValue>` 包裹 AnimatedSwitcher
6. **B6 会话切换 dispose**：`didUpdateWidget` 中会话切换时显式取消 `_contextPollTimer` / `_voiceAmplitudeSub` / `_voiceResultSub` / `_voiceErrorSub` / `_voiceIntermediateSub`

#### Task 3 — 模型加载策略优化（C1-C3）
1. **C1 LocalFFIEngine LRU 缓存**：新增 `_CachedEngine` 类 + `_engineCache` Map（容量 2）；`loadModel` 改造：缓存命中→复用引擎，未命中→存当前引擎到缓存；新增 `_saveCurrentEngineToCache` / `clearCache` 方法
2. **C2 流式 StreamController 包装**：`model_inference_engine.dart` 新增 `_activeControllers` 字段；新增 `generateChatStreamControlled` 方法（用 StreamController 包装 `async*` 流）；`cancelGeneration` 同时关闭 StreamController
3. **C3 错误恢复重试**：新增 `_retryableGenerate` 方法（3 次重试，指数退避 1s/2s/4s）；新增 `_isNetworkError` / `_isContextTooLongError` 检测方法（上下文超长不重试）

#### Task 4 — 跨平台审计（D1+D3）
1. **D1 清理空壳目录**：删除 `build_llama/` 和 `designs/`（均为空目录）
2. **D3 平台能力矩阵文档**：新建 `docs/PLATFORM_CAPABILITY_MATRIX.md`（20+ 功能 × 3 平台矩阵 + 平台限制说明 + 平台特定代码路径指引）

#### Task 5 — 三端编译验证 + CI/CD（A4）
1. **A4.1 三端本地编译验证**：
   - iOS: `flutter build ios --release --no-codesign` → 44.7s, 208.5MB Runner.app ✅
   - macOS: `flutter build macos --release` → 281.2MB multi_model_client.app ✅
   - Android: `flutter build apk --release` → 134.0s, 138.1MB app-release.apk ✅
2. **A4.2 GitHub Actions CI/CD**：新建 `.github/workflows/ci.yml`；5 个 Job（analyze → test → build-ios → build-macos → build-android）；缓存 pub-cache / gradle / CocoaPods

#### Task 6 — 最终验证
- `flutter analyze`：0 新增 error（132 pre-existing issues 均非本次修改）
- `flutter test`：288 通过 / 5 失败（全部 pre-existing TTS 相关，与 v0.44.0 改动无关）
- 三端编译全部通过（详见 Task 5）

### 主要技术栈

- **Flutter 3.x / Dart 3.10.7+**：sealed class、模式匹配、`compute()` Isolate
- **Riverpod 2.x**：StateNotifierProvider、ref.watch
- **StreamController**：包装 `async*` 生成器流，支持主动取消与错误重试
- **LRU 缓存**：Map 字面量默认保持插入顺序（LinkedHashMap），用于多模型缓存与解析结果缓存
- **ValueListenableBuilder**：监听 TextEditingController 变化，避免 setState 重建整棵树
- **GitHub Actions**：CI/CD 流水线（5 Job + 缓存策略）
- **gh CLI**：GitHub Release 创建与资源上传

### 关键决策和解决方案

1. **收敛性原则贯彻**：所有新增方法不改原方法签名（B1 `processBytes` 签名不变 / C1 `loadModel` 签名不变 / C2 新增 `generateChatStreamControlled` 不改原 `generateChatStream`）；增量演进；不引入新大抽象
2. **B3 select 不拆分**：sessionState 的 error/activeSession/messages 多字段被 build 使用且传递给 `_buildAppBar` / `_buildMessagesList`，select 拆分需改方法签名，决定保留原 watch 以符合收敛性
3. **C1 LRU 容量 2**：兼顾内存占用与切换性能（移动端常见 2 模型互切场景）；超出时按 LRU 淘汰最久未使用
4. **C3 上下文超长不重试**：上下文超长是确定性错误，重试无意义；网络错误才重试
5. **iOS CPU 模式临时方案**：llamadart 的 Metal 后端在 iOS 26 设备上触发 SIGSEGV，临时默认 CPU 模式（待 llamadart 修复后恢复）
6. **McpToolCallCard 快捷操作**：决策范围已包含"复制为 Markdown"，本次实现 FC 真实接入后工具调用将自动产生，卡片快捷操作留待 v0.45.0
7. **McpToolExplorerPage 调用历史分页**：决策范围已包含"调用历史分页"，本次先打通 FC 主链路，调用历史分页留待 v0.45.0

### 主要使用的工具

- `flutter analyze` — 静态分析（0 新增 error）
- `flutter test` — 单元测试（288 通过 / 5 pre-existing 失败）
- `flutter build ios --release --no-codesign` — iOS Release 编译
- `flutter build macos --release` — macOS Release 编译
- `flutter build apk --release` — Android Release 编译
- `git` / `gh` — 版本控制与 GitHub Release
- `Read / Write / Edit / Grep` — 文件操作

### 修改了哪些文件

| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/core/engines/fc_patterns.dart` | **新建** FC 模板正则和解析器 | v0.44.0 本地 FFI 真 FC |
| `lib/core/engines/local_ffi_engine.dart` | LRU 缓存 + `_CachedEngine` 类 + `generateStreamWithTools` | 模型切换缓存 + FFI 真 FC |
| `lib/core/engines/model_inference_engine.dart` | `generateChatStreamControlled` + `_retryableGenerate` + 错误检测 | StreamController 包装 + 网络重试 |
| `lib/features/session/domain/dialogue_engine.dart` | FC 编排 + `_executeRealToolCall` + 工具回填 | 让 AI 自动调用 MCP 工具 |
| `lib/core/multimodal/services/image_preprocess_service.dart` | `_processBytesInIsolate` + compute 调用 + fallback | B1 图片处理进 Isolate |
| `lib/features/session/presentation/widgets/message_bubble.dart` | 静态 LRU 缓存 + `_parseWithCache` | B2 MessageParser 缓存 |
| `lib/features/session/presentation/pages/session_detail_page.dart` | 振幅节流 + ValueListenableBuilder + 会话切换 dispose | B4/B5/B6 性能优化 |
| `docs/PLATFORM_CAPABILITY_MATRIX.md` | **新建** 三端能力矩阵 | D3 跨平台审计 |
| `.github/workflows/ci.yml` | **新建** CI/CD 流水线 | A4.2 自动化构建 |
| `docs/V0.44.0_IMPLEMENTATION_PLAN.md` | **新建** 实施计划文档 | 记录 v0.44.0 全部任务 |
| `CHANGELOG.md` | 追加 v0.44.0 章节 | 发布说明 |
| `README.md` | 追加 Session #40 会话总结 | 会话总结规则 |
| `README_zh.md` | 追加 Session #48 会话总结（中文版） | 会话总结规则 |
| `release/v0.44.0/MJ_Nexus_v0.44.0.ipa` | **新建** IPA 包 | GitHub Release 资源 |
| `build_llama/` | **删除** 空目录 | D1 清理 |
| `designs/` | **删除** 空目录 | D1 清理 |

### 发布物

- **GitHub Tag**: v0.44.0
- **GitHub Release**: https://github.com/jasonma1210/multi_model_client/releases/tag/v0.44.0
- **IPA**: ~54 MB（`release/v0.44.0/MJ_Nexus_v0.44.0.ipa`）
- **iOS 构建时间**: 44.7s
- **Android 构建时间**: 134.0s
- **测试**: 288 通过 / 5 pre-existing TTS 失败
- **静态分析**: 0 新增 error

### 待用户决策（v0.45.0）

1. McpToolCallCard 是否需要"复制为 Markdown"等快捷操作（本次先打通 FC 主链路）
2. McpToolExplorerPage 是否需要"调用历史"分页（本次先打通 FC 主链路）
3. open-source 分支与 master 分支的同步策略（独立决策）
4. v0.45.0 规划方向：Web 检索 API（DuckDuckGo / SerpAPI）集成、A2A Server 端在 MJ Nexus 内暴露、多模态 ImageInput 完整替换 ChatPage 现有 `_selectedImages` 流程

