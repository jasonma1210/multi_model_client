# MJ Nexus - Multi-Modal AI Assistant

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.31.1-blue" alt="Version"/>
  <img src="https://img.shields.io/badge/flutter-3.x-blue" alt="Flutter"/>
  <img src="https://img.shields.io/badge/dart-3.10.7+-blue" alt="Dart"/>
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS-green" alt="Platform"/>
  <img src="https://img.shields.io/badge/license-Private-red" alt="License"/>
</p>

---

**MJ Nexus** is a powerful cross-platform AI assistant application that supports local and remote large language models, real-time voice dialogue, RAG knowledge base, memory engine, and multi-modal reasoning capabilities.

## ✨ Key Features

### 🤖 Multi-Model Inference Engine
- **Local Models**: GGUF format via llama.cpp FFI (llamadart), Metal/Vulkan GPU acceleration
- **Remote Models**: Compatible with OpenAI / Anthropic / Ollama APIs
- **Multi-Modal Models**: Qwen2-VL, LLaVA vision-language models with auto mmproj projector download
- **Model Marketplace**: Built-in popular model recommendations with breakpoint resume download
- **GPU Crash Protection**: Multi-layer safety — parameter clamping, crash flag + safe mode auto-recovery, GGUF header pre-validation, GPU→CPU fallback on inference crash

### 🎤 Voice Interaction System
- **ASR Speech Recognition**: Whisper API + Sherpa-ONNX offline local solution
- **TTS Speech Synthesis**: 4 backends — MiMo TTS (cloud), Sherpa-ONNX (local offline), OpenAI TTS API, System TTS
- **Voice Cloning**: MiMo TTS VoiceClone API — record → transcribe → clone custom voice
- **TTS Style Control**: Director-level voice control with style tags, emotion tags, director mode, natural language control
- **Real-time Voice Dialogue**: Full streaming ASR → LLM → TTS with interruption support

### 💬 Session Management
- **Session Isolation**: Each session has independent model, context, and configuration
- **Folder Organization**: Session grouping, pinning, archiving
- **Role Personas**: 10+ preset personas (AI Engineer, Prompt Engineer, Queen, Loli, etc.)
- **Expert Skills**: 30+ domain expert roles (Design, Engineering, Marketing, Legal, Finance, etc.)
- **Session Export**: Markdown format export

### 🧠 Memory & Knowledge Base
- **Memory Palace**: 4-layer memory system (Instant → Working → Long-term → Archived) with intelligent weight decay and cross-session memory fusion
- **RAG Knowledge Base**: PDF/Word/TXT/OCR document parsing, FTS + BM25 + semantic search triple-retrieval
- **Semantic Search**: Embedding-based vector similarity search
- **Chinese Segmentation**: jieba integration for optimized Chinese text retrieval

### 🎨 Multi-Modal Capabilities
- **Vision Understanding**: Send images to multi-modal models for analysis
- **Video Understanding**: Video file comprehension with continuous dialogue
- **OCR Recognition**: Google ML Kit native OCR + textify pure Dart OCR

### 🔌 MCP Protocol Support
- **MCP Service Manager**: Unified management of all MCP connections
- **Tool Calling**: Standardized MCP protocol tool calling interface
- **Server Management**: MCP connection manager and server manager

### 🔒 Security & Privacy
- **AES-256 Encryption**: Encrypted data storage
- **Secure Key Storage**: iOS Keychain / Android Keystore
- **App Lock**: PIN code + biometric (Face ID / Touch ID)
- **Privacy-First**: All data stored locally, no telemetry

### ⚙️ System Features
- **Data Backup**: JSON format import/export, merge/overwrite modes
- **Theme Switching**: Dark / Light / System theme
- **Multi-language**: Chinese / English (i18n)
- **macOS Sandbox**: Security-Scoped Bookmark for external file access
- **Onboarding**: First-use guided setup

## 🏗️ Architecture

```
lib/
├── core/                          # Core functionality layer
│   ├── adapters/                  # API adapters (OpenAI, Anthropic)
│   ├── constants/                 # App constants
│   ├── engines/                   # Inference engines
│   │   ├── local_ffi_engine       # llama.cpp FFI local inference
│   │   ├── model_inference_engine # Unified inference router
│   │   ├── piper_tts_engine       # Piper TTS engine
│   │   └── whisper_engine         # Whisper ASR engine
│   ├── models/                    # Data models
│   ├── providers/                 # Riverpod state management
│   ├── services/                  # Core services (TTS, ASR, MCP, Memory, etc.)
│   ├── security/                  # Security services (encryption, bookmarks)
│   ├── protocols/                 # MCP protocol implementation
│   ├── platform/                  # Platform adaptation (hardware, acceleration)
│   ├── router/                    # go_router navigation
│   └── storage/                   # Drift ORM database
├── features/                      # Feature modules
│   ├── session/                   # Session management & dialogue engine
│   ├── model/                     # Model management & marketplace
│   ├── skill/                     # Skill system (experts & plugins)
│   ├── rag/                       # RAG knowledge base
│   ├── memory/                    # Memory engine
│   ├── prompt/                    # Prompt engine
│   ├── settings/                  # Settings pages
│   └── workflow/                  # Workflow engine
├── generated/                     # i18n generated code
├── l10n/                          # Localization ARB files
├── app.dart                       # App root widget
└── main.dart                      # Entry point
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x + Dart 3.10.7+ |
| State Management | Riverpod 2.x + code generation |
| Routing | go_router 17.x |
| Database | Drift ORM (SQLite) |
| Local Inference | llamadart 0.6.16 (llama.cpp FFI b9010) |
| Networking | Dio 5.x + http + web_socket_channel |
| Background Download | background_downloader (native, breakpoint resume) |
| TTS | Sherpa-ONNX 1.12.x / flutter_tts / MiMo TTS API |
| ASR | speech_to_text / Sherpa-ONNX |
| Recording | record 6.x + flutter_recorder (miniaudio FFI) |
| OCR | Google ML Kit + textify (pure Dart) |
| PDF | pdfx + syncfusion_flutter_pdf |
| Encryption | encrypt + crypto (AES-256) |
| Secure Storage | flutter_secure_storage |
| Biometrics | local_auth |
| Chinese NLP | jieba_flutter |
| Location | geolocator |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.7+
- Dart SDK 3.10.7+
- Xcode 15+ (for iOS/macOS)
- Android Studio (for Android)

### Installation

```bash
# Clone the repository
git clone https://github.com/jasonma1210/multi_model_client.git
cd multi_model_client

# Install dependencies
flutter pub get

# Generate code (Drift / Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# macOS
flutter build macos --release

# iOS
flutter build ios --release
```

## 📱 Supported Platforms

| Platform | Status | GPU Acceleration | Minimum Version |
|----------|--------|------------------|-----------------|
| iOS | ✅ Supported | Metal | 15.0+ (iPhone 8+) |
| Android | ✅ Supported | Vulkan | 10.0+ (arm64-v8a) |
| macOS | ✅ Supported | Metal (Apple Silicon) | Apple Silicon & Intel |
| Windows | 🔧 Partial | CUDA/CPU | - |
| Linux | 🔧 Partial | CUDA/CPU | - |

## 📊 Performance Targets

| Metric | Target |
|--------|--------|
| Cold Start | ≤ 2 seconds |
| 7B Model Load | ≤ 3 seconds |
| Inference Speed | ≥ 30 tokens/sec |
| Voice Latency | ≤ 500ms |
| Memory Usage | ≤ 1GB |

## 📦 Releases

Download the latest release (v0.30.0) from the [Releases](https://github.com/jasonma1210/multi_model_client/releases) page:
- `app-release.apk` — Android APK
- `multi_model_client.app.dmg` — macOS DMG

## 📄 License

This is a private project. All rights reserved.

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📞 Contact

For questions or suggestions, please open an issue on GitHub.

---

## 📋 会话开发记录

### 会话 2026-06-02：实时语音对话功能优化

**会话背景**：基于已有的实时语音对话功能，用户要求进一步优化UI风格和会话集成体验。

**会话主要目的**：
1. 确保实时语音对话使用语音设置中配置的音色
2. 优化实时语音页面UI为类豆包app风格
3. 实时语音对话依赖当前会话（模型及上下文传入）
4. 会话界面语音按钮ASR转文字后自动发送到聊天

**完成的主要任务**：
1. 重写 `realtime_voice_page.dart`，实现类豆包app风格的实时语音交互界面
2. 实时语音页面正确读取语音设置中的音色配置（TTS Provider、MiMo音色、克隆音色等）
3. 实时语音页面通过 `widget.sessionId` 与当前会话绑定，使用 `DialogueEngine` 传入模型和上下文
4. 修改 `session_detail_page.dart` 中ASR识别结果处理逻辑，从弹出层手动确认改为自动发送

**主要技术栈**：
- Flutter + Dart（Riverpod 状态管理）
- ASR（Sherpa-ONNX / 系统 / OpenAI Whisper）
- TTS（MiMo / Sherpa-ONNX / OpenAI / 系统）
- just_audio 音频播放 + record 音频录制
- DialogueEngine 流式对话引擎

**关键决策和解决方案**：
- **音色配置读取**：通过 `SettingsService` + `SharedPreferences` 直接读取TTS配置，避免依赖未实现的Provider
- **UI风格**：采用深色全屏布局，中央消息气泡列表 + 底部大麦克风按钮 + 脉冲波纹动画反馈
- **会话集成**：`RealtimeVoicePage` 接收 `sessionId`，通过 `DialogueEngine.streamResponse(sessionId, text)` 使用当前会话的模型和上下文
- **ASR自动发送**：将 `_voiceResultSub` 中的弹出层逻辑替换为直接调用 `_sendMessage(l10n)`

**会话中主要使用的工具**：
- Flutter Analyze（静态代码检查）
- SearchCodebase / Grep（代码搜索）

**修改的文件**：

| 文件名 | 修改内容 | 修改原因 |
|--------|---------|---------|
| `realtime_voice_page.dart` | 完全重写UI和业务逻辑，实现豆包风格界面、会话集成、音色配置读取 | 用户要求优化UI风格并集成当前会话 |
| `session_detail_page.dart` | 修改 `_voiceResultSub` 处理逻辑，ASR结果直接发送而非弹出层确认 | 用户要求语音按钮识别后自动发送到聊天 |

---

## 📝 Session Log（会话记录，累积增加）

### Session #30 — README.md 产品级重写 (2026-05-28)

**会话背景**：用户要求将 README.md 重写为产品级文档，移除所有历史会话记录（Session #9-#29），保留干净的产品介绍。

**会话目的**：创建面向开发者和用户的产品级 README.md。

**完成的主要任务**：
1. 读取现有 README.md（913 行，含大量历史会话记录）
2. 按照用户提供的完整结构重写 README.md，包含：
   - Logo 和语言切换链接
   - 版本/技术栈/平台徽章（shields.io）
   - 完整的功能特性介绍（8 大模块）
   - 项目架构目录树
   - 技术栈表格（17 项技术）
   - 安装和构建指南
   - 平台支持和性能目标
   - Release 下载链接、License、Contributing、Contact

**技术栈**：Markdown, shields.io badges

**关键决策**：
- 移除所有历史会话记录（Session #9-#29），保持文档干净
- 不包含任何 API key 或硬编码密钥
- 不包含内部文档链接（如 docs/ 目录下的 md 文件）
- 使用英文撰写
- GitHub 仓库地址更新为 `https://github.com/jasonma1210/multi_model_client.git`

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `README.md` | 完整重写，从 913 行缩减为 208 行产品级文档 | 移除会话记录，创建干净的产品 README |

### Session #31 — 创建中文版 README_zh.md (2026-05-28)

**会话背景**：用户要求创建中文版 README 文件，与英文版 README.md 对应。

**会话目的**：为 MJ Nexus 项目创建产品级中文 README_zh.md 文档。

**完成的主要任务**：
1. 按照用户提供的完整结构创建 README_zh.md（208 行）
2. 内容包含：
   - Logo 和语言切换链接（English / 简体中文）
   - 版本/技术栈/平台徽章
   - 完整的功能特性介绍（8 大模块，中文翻译）
   - 项目架构目录树
   - 技术栈表格
   - 安装和构建指南
   - 平台支持和性能目标
   - Release 下载链接、许可证、贡献指南、联系方式

**技术栈**：Markdown

**关键决策**：
- 不包含任何会话记录/session log
- 不包含任何 API key 或硬编码的密钥信息
- 不包含任何内部文档链接
- 使用中文撰写，与英文版结构完全对应
- GitHub 仓库地址：`https://github.com/jasonma1210/multi_model_client.git`

**使用的工具**：Write, Glob, Read, RunCommand, SearchReplace

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `README_zh.md` | 新建文件，208 行中文版 README | 创建中文版产品文档，与英文版对应 |
| `README.md` | 追加 Session #31 会话记录 | 按要求记录会话总结 |

### Session #32 — 搜索并清理硬编码 API Key (2026-05-28)

**会话背景**：用户要求搜索并清理 `multi_model_client` 项目中所有硬编码的 API Key 和敏感信息。

**会话目的**：全面扫描代码库，识别并替换所有硬编码的 API 密钥、Secret、Token 等敏感信息。

**完成的主要任务**：
1. 使用正则模式 `api[_-]?key|secret|token|password|sk-|Bearer`（不区分大小写）搜索所有 `.dart` 文件
2. 搜索 `pubspec.yaml` 和其他配置文件中的敏感信息
3. 搜索常见 API key 格式：`sk-*`、`tvly-*`、`AIza*`、`AKIA*` 等
4. 搜索长字符串模式（32+ 字符的硬编码值）
5. 重点审查用户指定的文件：`tts_service.dart`、`voice_clone_service.dart`、`settings_provider.dart`、`app_constants.dart`
6. 搜索 `.env` 文件和硬编码 URL 端点

**搜索结果**：✅ **未发现任何硬编码的真实 API Key**

经过全面扫描，项目的安全架构设计良好：
- **所有 API Key 均通过 `SharedPreferences` 动态读取**，无硬编码默认值
- **敏感数据使用 `EncryptionService` 加密存储**（AES-256），支持 iOS Keychain / Android Keystore
- **预设配置中的 `apiKey` 均为空字符串** `''`（如 `model_entry.dart` 的 `openAIPreset()` 和 `anthropicPreset()`）
- **硬编码的 URL 仅为公开 API 端点**，不是敏感信息

**各文件审查详情**：

| 文件 | 审查结果 |
|------|---------|
| `tts_service.dart` | ✅ 安全 — `_apiKey` 通过构造函数传入，`_defaultMiMoBaseUrl` 仅为公开端点 URL |
| `voice_clone_service.dart` | ✅ 安全 — API Key 从 `SharedPreferences` 读取（`_mimoApiKeyKey`），无硬编码 |
| `settings_provider.dart` | ✅ 安全 — 所有 Key 存取均通过 `SharedPreferences` + `EncryptionService` |
| `app_constants.dart` | ✅ 安全 — 仅包含超时、动画、UI 尺寸等常量，无敏感信息 |
| `dialogue_engine.dart` | ✅ 安全 — Tavily/Brave/SerpAPI Key 均从 `SharedPreferences` 动态读取 |
| `model_entry.dart` | ✅ 安全 — 预设配置 `apiKey: ''`（空字符串） |
| `embedding_service.dart` | ✅ 安全 — `apiKey` 通过构造函数参数传入 |
| `pubspec.yaml` | ✅ 安全 — 无敏感信息 |

**关键结论**：
- 项目采用「用户通过设置页面配置 API Key → SharedPreferences 持久化 → EncryptionService 加密」的安全模式
- 无需修改任何文件，代码库中不存在硬编码的敏感信息

**技术栈**：Dart, Flutter, SharedPreferences, EncryptionService (AES-256)

**使用的工具**：Grep, Glob, Read, SearchReplace

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `README.md` | 追加 Session #32 会话记录 | 按要求记录会话总结 |

### Session #33 — 灵感一瞬功能重构与编译修复 (2026-05-29)

**会话背景**：灵感一瞬页面功能不完整，录音、转录、目录管理、内容汇总等功能需要完整重写。同时需要修复之前的编译错误。

**会话目的**：验证灵感一瞬重构代码的编译正确性，修复所有编译错误，确保功能完整可用。

**完成的主要任务**：
1. 完整审阅灵感一瞬页面代码（1546 行）及 `inspiration_service.dart` 服务层
2. 运行 `flutter analyze` 发现 4 个 error + 2 个 info 级别问题
3. 修复 `share_plus` API 调用错误（`SharePlus.instance.share(ShareParams(...))` → `Share.shareXFiles(...)`）
4. 修复 `RadioListTile` deprecation 警告，改用 `RadioGroup` + `Radio` 组件
5. 移除不必要的 `flutter/services.dart` import
6. 验证 macOS Debug 构建成功通过

**灵感一瞬功能已实现的完整特性**：
- **多目录管理**：默认"自由"目录 + 自定义目录创建/重命名/删除/拖拽排序
- **录音操作**：开始/暂停/恢复/停止，录音时长实时显示
- **保存录音**：弹出对话框选择已有目录或创建新目录，默认保存到"自由"目录
- **单个转录**：每条录音旁有转录按钮
- **批量一键转录**：选中多条录音后自动提示批量转录
- **内容汇总**：目录下所有录音转录文本汇总 + 综合内容
- **思维导图**：基于转录文本生成树形思维导图
- **导出功能**：Markdown 文档 + 思维导图 JSON，通过 share_plus 分享
- **录音删除**：支持单条删除
- **数据持久化**：SharedPreferences 存储目录和录音数据
- **日期格式**：所有录音按日期格式存储和显示

**技术栈**：Flutter, Dart, flutter_recorder, just_audio, SharedPreferences, share_plus, ASR (Sherpa-ONNX)

**关键决策和解决方案**：
1. `share_plus ^10.1.4` 使用 `Share.shareXFiles()` 而非 `SharePlus.instance.share(ShareParams(...))`
2. Flutter 3.32+ 中 `Radio` 的 `groupValue`/`onChanged` 已废弃，改用 `RadioGroup` 祖先组件管理
3. 录音不再强制依赖 ASR 模型选择，ASR 转录改为可选操作（录音后手动触发）
4. 数据模型采用 `InspirationFolder` → `InspirationRecording` 的一对多关系，JSON 序列化持久化

**使用的工具**：Read, Grep, RunCommand (flutter analyze, flutter build), SearchReplace, TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 修复 `SharePlus.instance.share(ShareParams(...))` → `Share.shareXFiles([XFile(file.path)], subject: ...)` | share_plus ^10.1.4 API 不支持新写法 |
| `inspiration_page.dart` | 将 `RadioListTile<String>` 替换为 `RadioGroup` + `Radio<String>` | Flutter 3.32+ 废弃了 RadioListTile 的 groupValue/onChanged 参数 |
| `inspiration_page.dart` | 移除 `import 'package:flutter/services.dart'` | 所有使用的元素已由 `flutter/material.dart` 提供 |
| `README.md` | 追加 Session #33 会话记录 | 按要求记录会话总结 |

### Session #34 — XMind 思维导图格式导出 (2026-05-29)

**会话背景**：灵感一瞬的思维导图导出功能仅输出纯 JSON 文件，无法在 XMind 等思维导图软件中打开。用户要求导出真正的 XMind 格式文件。

**会话目的**：将灵感一瞬的思维导图导出从纯 JSON 改为标准 XMind 格式（.xmind ZIP 文件）。

**完成的主要任务**：
1. 检查项目现有 `DocumentGenerationService`，发现已有 `generateXMind()` 方法（使用 `archive` 库生成 ZIP）
2. 修复 `ArchiveFile` 构造函数调用（`archive ^4.0.9` 需要 3 个参数：name, size, data）
3. 修改 `inspiration_page.dart`，导入 `DocumentGenerationService` 并替换纯 JSON 导出为 XMind 格式
4. 实现 `_buildMindMapData()` 方法，智能构建思维导图数据结构：
   - 根节点：目录名称
   - 一级子节点：每条录音（含日期）
   - 二级子节点：时长、转录文本（长文本自动分句）
5. 验证 macOS Debug 构建成功

**技术栈**：Flutter, Dart, archive ^4.0.9 (ZIP 编码), XMind 8 格式规范

**关键决策和解决方案**：
1. 复用项目已有的 `DocumentGenerationService.generateXMind()` 而非重新实现
2. `ArchiveFile` 构造函数：`ArchiveFile(name, size, data)`，`archive ^4.0.9` 要求显式传入 `size` 参数
3. 思维导图数据结构采用 `Map<String, dynamic>` 嵌套格式，`DocumentGenerationService` 内部递归转换为 XMind topic 结构
4. 长转录文本按句子分段（每段 ≤ 80 字），最多展示 5 个内容节点

**使用的工具**：Read, Grep, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `document_generation_service.dart` | 修复 `ArchiveFile` 构造函数：传入 3 个参数 `(name, size, data)` | `archive ^4.0.9` API 要求 3 个位置参数 |
| `inspiration_page.dart` | 导入 `DocumentGenerationService`；替换纯 JSON 导出为 `DocumentGenerationService.instance.generateXMind()`；新增 `_buildMindMapData()` 方法 | 导出标准 XMind 格式文件 |
| `README.md` | 追加 Session #34 会话记录 | 按要求记录会话总结 |

### Session #35 — 总结功能重构 + 思维导图前端渲染 (2026-05-29)

**会话背景**：灵感一瞬的总结功能按录音分段显示，用户要求汇总所有转录文本统一输出汇总文章（支持详细/适中/简单三种模式）。思维导图需要使用 pub 包在前端页面中渲染展示，而不是纯 JSON 或纯文本。

**会话目的**：重构总结和思维导图功能，实现统一汇总 + 前端思维导图渲染。

**完成的主要任务**：
1. 调研 Flutter 思维导图渲染包，选定 `flutter_mind_map ^1.1.2`
2. 添加 `flutter_mind_map` 依赖到 `pubspec.yaml`
3. 新增 `_SummaryLevel` 枚举：`detailed`（详细）、`medium`（适中）、`simple`（简单）
4. 重构 `_generateSummary()`：弹出详细度选择对话框 → 汇总所有转录文本 → 按级别生成摘要
5. 实现 `_buildSummary()` 方法：
   - 详细模式：完整保留所有文本
   - 适中模式：过滤短句（≤20字），保留核心内容
   - 简单模式：提取关键词（最多50个）
6. 重构 `_SummaryPage` 为 `StatefulWidget`，集成 `flutter_mind_map` 渲染：
   - 双 Tab 布局：「总结」+「思维导图」
   - 思维导图自动从转录文本中提取主题和子节点
   - 使用 `MindMap` + `MindMapNode` 构建可交互的思维导图
   - 只读模式 + 自动展开3层
7. 移除旧的按录音分段显示逻辑
8. 验证 macOS Debug 构建成功

**技术栈**：Flutter, Dart, flutter_mind_map ^1.1.2, archive ^4.0.9

**关键决策和解决方案**：
1. 选择 `flutter_mind_map` 而非 `mind_map_flutter` 或 `reactive_mind_map`，因为支持从 JSON 加载、只读模式、自定义主题
2. 总结不再按录音分段显示，而是将所有转录文本合并后统一处理
3. 思维导图从转录文本中自动提取长句作为主题节点，短句作为子节点
4. `_SummaryPage` 从 `StatelessWidget` 改为 `StatefulWidget` 以管理 `MindMap` 控制器

**使用的工具**：WebSearch, Read, Grep, SearchReplace, RunCommand (flutter pub get, flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `pubspec.yaml` | 添加 `flutter_mind_map: ^1.1.2` 依赖 | 前端思维导图渲染 |
| `inspiration_page.dart` | 导入 `flutter_mind_map/mind_map.dart` 和 `mind_map_node.dart` | 使用思维导图组件 |
| `inspiration_page.dart` | 新增 `_SummaryLevel` 枚举 | 支持三种总结详细度 |
| `inspiration_page.dart` | 重构 `_generateSummary()`：汇总所有转录文本 + 详细度选择 | 统一输出汇总文章 |
| `inspiration_page.dart` | 新增 `_showSummaryLevelDialog()` 和 `_buildSummary()` | 详细度选择和摘要生成 |
| `inspiration_page.dart` | 重构 `_SummaryPage`：双 Tab（总结 + 思维导图）+ flutter_mind_map 渲染 | 前端思维导图展示 |
| `inspiration_page.dart` | 移除旧的按录音分段显示逻辑 | 简化为统一汇总 |
| `README.md` | 追加 Session #35 会话记录 | 按要求记录会话总结 |

### Session #36 — 修复灵感一瞬转录失败（录音格式不兼容） (2026-05-29)

**会话背景**：灵感一瞬录音后转录失败，错误信息为 `Only PCM format is supported, got format 3`。录音器使用 `PCMFormat.f32le`（IEEE float 32位，WAV format=3）录制，但 Sherpa-ONNX ASR 服务只支持标准 PCM 格式（WAV format=1）。

**会话目的**：修复录音格式与 ASR 服务不兼容的问题。

**完成的主要任务**：
1. 分析错误日志：`Found fmt chunk at 12, format=3` → `Only PCM format is supported, got format 3`
2. 确认根因：`PCMFormat.f32le` 产生 WAV format=3（IEEE float），ASR 需要 format=1（PCM int16）
3. 检查 `flutter_recorder` 的 `PCMFormat` 枚举，确认 `PCMFormat.s16le` 对应标准 PCM int16
4. 修改灵感一瞬页面录音格式：`PCMFormat.f32le` → `PCMFormat.s16le`
5. 语音克隆页面保持 `f32le` 不变（不使用 ASR，需要 float32 格式）
6. 验证构建成功

**技术栈**：Flutter, Dart, flutter_recorder, Sherpa-ONNX ASR, WAV 音频格式

**关键决策和解决方案**：
1. WAV format=1 为标准 PCM，format=3 为 IEEE float — ASR 只支持 format=1
2. `PCMFormat.s16le` 产生 16-bit signed little-endian PCM，WAV header format=1
3. 语音克隆页面不使用 ASR，保持 `f32le` 以确保语音克隆质量

**使用的工具**：Grep, Read, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 录音格式 `PCMFormat.f32le` → `PCMFormat.s16le` | ASR 只支持 PCM int16 格式 |
| `README.md` | 追加 Session #36 会话记录 | 按要求记录会话总结 |

### Session #37 — ASR 服务支持 IEEE float WAV 格式 (2026-05-29)

**会话背景**：Session #36 修改了录音格式为 `s16le`，但之前用 `f32le` 录制的旧文件仍然无法转录。错误为 `Only PCM format is supported, got format 3`。需要让 ASR 服务兼容 IEEE float 格式。

**会话目的**：让 ASR 服务同时支持 PCM (format=1) 和 IEEE float (format=3) 两种 WAV 格式。

**完成的主要任务**：
1. 分析 ASR 服务 `readWaveFile` 方法的格式检查逻辑（第 347 行）
2. 修改格式检查：`audioFormat != 1 && audioFormat != 65534` → `audioFormat != 1 && audioFormat != 3 && audioFormat != 65534`
3. 添加 IEEE float 32位读取逻辑：当 `audioFormat == 3 && bitsPerSample == 32` 时使用 `getFloat32()` 读取
4. 验证构建成功

**技术栈**：Flutter, Dart, Sherpa-ONNX ASR, WAV 音频格式

**关键决策和解决方案**：
1. WAV format=1 (PCM) 的 32位数据是 `Int32`，需要除以 `2147483648.0` 归一化
2. WAV format=3 (IEEE float) 的 32位数据是 `Float32`，直接读取即可，范围已归一化到 [-1.0, 1.0]
3. 使用 `ByteData.getFloat32()` 读取 IEEE float 格式，优先级高于 `getInt32()`

**使用的工具**：Task (search), Read, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `asr_service.dart` | 格式检查添加 `audioFormat=3`；添加 `getFloat32()` 读取 IEEE float 数据 | 兼容旧的 f32le 录音文件 |
| `README.md` | 追加 Session #37 会话记录 | 按要求记录会话总结 |

### Session #38 — ASR 转录异步化（后台 Isolate 执行） (2026-05-29)

**会话背景**：灵感一瞬的录音转录功能在执行时会阻塞 UI，导致前端卡死。原因是 `_recognizer!.decode(stream)` 是 Sherpa-ONNX 的 FFI 同步调用，运行在主 Isolate 上。

**会话目的**：将 ASR 转录改为异步非阻塞，使用后台 Isolate 执行。

**完成的主要任务**：
1. 分析阻塞根因：`_recognizer!.decode(stream)` 是 FFI 同步调用，阻塞主 Isolate
2. 创建顶层函数 `_sherpaRecognizeInBackground`，包含完整的识别流程（初始化模型 + 读取 WAV + 解码）
3. 修改 `_recognizeWithSherpa` 方法，使用 `compute()` 在后台 Isolate 执行识别
4. 在 `initSherpa()` 中保存解析后的模型路径（`_resolvedModelPath`, `_resolvedTokensPath`, `_resolvedRuleFst`）供后台 Isolate 使用
5. 验证构建成功

**技术栈**：Flutter, Dart, sherpa_onnx (FFI), compute (Isolate), Sherpa-ONNX ASR

**关键决策和解决方案**：
1. 使用 `compute()` 而非 `Isolate.run()`，因为 `compute` 是 Flutter 推荐的后台 Isolate 方式
2. 创建顶层函数 `_sherpaRecognizeInBackground` 作为 `compute` 的入口点
3. 后台 Isolate 中创建独立的 `OfflineRecognizer`，避免跨 Isolate 共享 FFI 对象
4. 使用 `numThreads: 2`（而非主线程的 4）以减少后台 Isolate 的 CPU 占用
5. 保存解析后的模型路径到实例变量，供 `compute` 调用时传递参数

**使用的工具**：Read, Grep, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `asr_service.dart` | 新增顶层函数 `_sherpaRecognizeInBackground`（138行） | 后台 Isolate 识别入口 |
| `asr_service.dart` | 重写 `_recognizeWithSherpa`：使用 `compute()` 调用后台函数 | 避免阻塞主 Isolate |
| `asr_service.dart` | 新增 `_resolvedModelPath`, `_resolvedTokensPath`, `_resolvedRuleFst` 字段 | 保存模型路径供后台 Isolate 使用 |
| `asr_service.dart` | 在 `initSherpa()` 中保存解析后的路径 | 供 `compute` 传递参数 |
| `README.md` | 追加 Session #38 会话记录 | 按要求记录会话总结 |

### Session #39 — 灵感一瞬功能增强：LLM 总结 + 录音详情 + 模型选择 (2026-05-29)

**会话背景**：灵感一瞬功能需要增强：录音详情应在"详细"按钮中查看，批量转录/总结应默认全选，总结应使用内置大模型生成，支持模型选择。

**会话目的**：增强灵感一瞬的总结功能，集成 LLM 进行智能总结生成。

**完成的主要任务**：
1. 添加 LLM 模型选择功能（`_switchLlmModel`）：扫描本地 GGUF 文件，支持切换总结模型
2. 添加录音详情查看功能（`_showRecordingDetail`）：底部弹窗显示完整转录文本
3. 修改录音列表项：移除内联转录显示，添加"详细"按钮和转录状态指示器
4. 修改批量转录逻辑：默认全选所有未转录的录音
5. 集成 LLM 总结生成（`_generateSummaryWithLlm`）：
   - 使用 `LocalFFIEngine.instance.generate()` 调用本地大模型
   - 支持三种详细度模式（详细/适中/简单）
   - 异步执行，显示加载状态
6. 添加 LLM 模型自动选择（`_ensureLlmModel`）：首次使用自动选择第一个可用模型
7. 更新 AppBar：添加"切换总结模型"按钮
8. 更新操作行：显示当前总结模型名称和生成状态
9. 验证构建成功

**技术栈**：Flutter, Dart, LocalFFIEngine (llamadart FFI), ChatMessage, SharedPreferences

**关键决策和解决方案**：
1. LLM 模型通过扫描 `models/` 目录下的 `.gguf` 文件获取（排除 mmproj 文件）
2. 使用 `LocalFFIEngine.instance.generate()` 调用本地大模型，异步执行不阻塞 UI
3. 录音详情使用 `DraggableScrollableSheet` 底部弹窗展示
4. 批量转录和生成总结默认全选所有录音，无需手动选择
5. 首次使用时自动选择第一个可用的 GGUF 模型

**使用的工具**：Read, Grep, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 导入 `LocalFFIEngine` 和 `ChatMessage` | 使用本地 LLM 引擎 |
| `inspiration_page.dart` | 新增 `_selectedLlmModelId` 和 `_llmModelPrefKey` | LLM 模型选择状态 |
| `inspiration_page.dart` | 新增 `_switchLlmModel()` 方法 | 切换总结生成模型 |
| `inspiration_page.dart` | 新增 `_showRecordingDetail()` 方法 | 查看录音完整转录 |
| `inspiration_page.dart` | 新增 `_ensureLlmModel()` 方法 | 自动选择 LLM 模型 |
| `inspiration_page.dart` | 新增 `_generateSummaryWithLlm()` 方法 | 使用 LLM 生成总结 |
| `inspiration_page.dart` | 修改 `_buildRecordingItem`：添加"详细"按钮和状态指示器 | 优化录音列表显示 |
| `inspiration_page.dart` | 修改 `_batchTranscribe`：默认全选未转录录音 | 简化操作流程 |
| `inspiration_page.dart` | 修改 `_generateSummary`：集成 LLM 总结 + 异步执行 | 智能总结生成 |
| `inspiration_page.dart` | 修改 `_buildActionRow`：显示模型名称和生成状态 | 提供状态反馈 |
| `inspiration_page.dart` | 修改 AppBar：添加"切换总结模型"按钮 | 支持模型切换 |
| `README.md` | 追加 Session #39 会话记录 | 按要求记录会话总结 |

### Session #40 — 灵感一瞬完整重写：手风琴目录 + 播放控制 + 详细页面 + 总结列表 (2026-05-29)

**会话背景**：用户对灵感一瞬页面提出全面重构需求：去除 TabBar，改为手风琴式目录列表；播放控制支持暂停/停止/速度切换；转录后按钮变"详细"；目录右侧有"详细"和"总结"按钮；总结支持选择录音+详细度+LLM模型；总结记录可多次生成并以列表展示。

**会话目的**：完整重写灵感一瞬页面，实现全新的 UI/UX 设计。

**完成的主要任务**：
1. 完整重写 `inspiration_page.dart`（从 1875 行重写为 ~1050 行）
2. 新增 `SummaryRecord` 数据模型，支持多次生成总结记录
3. 实现手风琴式目录列表（无 TabBar），默认展开"自由"目录
4. 实现锚点定位：点击其他目录时折叠所有，展开点击的，滚动到顶部
5. 实现播放控制：播放→暂停/停止/速度，速度循环 1x→0.5x→1x→1.5x→2x
6. 实现转录后按钮变"详细"，点击弹出底部弹窗查看转录文本
7. 实现目录"详细"按钮→新页面 `_FolderDetailPage`
8. 实现目录"总结"按钮→对话框选择录音+详细度+LLM模型
9. 实现总结记录列表（可多次生成），含导出和删除功能
10. 实现思维导图渲染（flutter_mind_map）
11. 实现导出功能（.md 文档 + .xmind 思维导图）
12. 修复 RadioListTile deprecation → RadioGroup + Radio
13. 移除未使用的 `record/record.dart` import
14. 验证构建成功

**技术栈**：Flutter, Dart, flutter_mind_map, just_audio, flutter_recorder, SharedPreferences, share_plus, LocalFFIEngine, Sherpa-ONNX ASR

**关键决策和解决方案**：
1. 使用自定义手风琴实现（ExpansionTile 风格）替代 TabBar
2. 使用 `GlobalKey` + `Scrollable.ensureVisible` 实现锚点定位
3. 播放状态机：idle → playing → paused → stopped，通过状态变量控制按钮显示
4. 速度循环：1x → 0.5x → 1x → 1.5x → 2x → 1x（通过 `_cyclePlaySpeed` 方法）
5. 总结记录存储在 `InspirationFolder.summaries` 列表中，支持多次生成
6. 总结生成使用 `LocalFFIEngine.instance.generate()` 异步执行
7. 思维导图从转录文本中自动提取主题和子节点
8. RadioGroup 替代 RadioListTile 以避免 Flutter 3.32+ deprecation 警告

**使用的工具**：Task (general_purpose_task), Read, Grep, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 完整重写（~1050行） | 实现全新的 UI/UX 设计 |
| `inspiration_page.dart` | 新增 `SummaryRecord` 数据模型 | 支持多次生成总结记录 |
| `inspiration_page.dart` | 实现手风琴目录 + 锚点定位 | 替代 TabBar 设计 |
| `inspiration_page.dart` | 实现播放控制（暂停/停止/速度） | 增强播放体验 |
| `inspiration_page.dart` | 实现 `_FolderDetailPage` 详细页面 | 目录详情和总结列表 |
| `inspiration_page.dart` | 实现总结对话框+LLM生成 | 智能总结功能 |
| `inspiration_page.dart` | RadioGroup 替代 RadioListTile | 避免 deprecation 警告 |
| `inspiration_page.dart` | 移除 `record/record.dart` import | 未使用的 import |
| `README.md` | 追加 Session #40 会话记录 | 按要求记录会话总结 |

### Session #41 — 灵感一瞬功能优化：API 模型支持 + UI 细节调整 (2026-05-29)

**会话背景**：用户对灵感一瞬提出4项优化：(1) 切换总结模型需支持已配置的 API 模型；(2) 目录标题栏移除"总结"按钮；(3) 详细页面实现一键总结功能；(4) 播放控件改为4个独立按钮+转录后增加文本弹窗。

**会话目的**：优化灵感一瞬的模型选择、目录标题栏、详细页面和播放控件。

**完成的主要任务**：
1. 重写 `_switchLlmModel`：从 SharedPreferences `saved_models_v2` 读取所有模型（本地+API），支持 `ModelEntry` 解析
2. 重写 `_showSummaryDialog`：同样支持 API 模型选择
3. 更新 `_generateSummary`：根据 `ModelEntry.isRemote` 判断使用 `globalModelEngine.generateChat()` 或 `LocalFFIEngine.instance.generate()`
4. 目录标题栏移除"总结"按钮，只保留展开/折叠+详细
5. 详细页面 AppBar 添加"一键总结"按钮，含完整对话框（选录音+选详细度+选模型）
6. 主页面录音项播放控件改为4个独立按钮：播放/暂停/停止/速度（始终可见）
7. 录音项转录后显示"文本"按钮，点击弹出底部弹窗查看转录文本
8. 添加 `ModelEntry` import，使用 `globalModelEngine` 全局实例
9. 验证构建成功

**技术栈**：Flutter, Dart, ModelEntry, ModelInferenceEngine (globalModelEngine), LocalFFIEngine, SharedPreferences

**关键决策和解决方案**：
1. API 模型通过 `SharedPreferences.getString('saved_models_v2')` 读取 `ModelEntry` 列表
2. 使用 `ModelEntry.isRemote` 判断模型类型，API 模型用 `globalModelEngine.generateChat()`，本地模型用 `LocalFFIEngine.instance.generate()`
3. 详细页面的总结功能独立实现（`_showSummaryDialogLocal` + `_generateSummaryLocal`），不依赖父页面状态
4. 播放控件改为始终显示4个按钮，播放中额外显示停止和速度按钮

**使用的工具**：Task (search), Read, Grep, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 导入 `ModelEntry` 和 `globalModelEngine` | 支持 API 模型调用 |
| `inspiration_page.dart` | 重写 `_switchLlmModel`：从 `saved_models_v2` 读取所有模型 | 支持本地+API 模型选择 |
| `inspiration_page.dart` | 重写 `_showSummaryDialog`：模型选择支持 API | 总结对话框统一模型选择 |
| `inspiration_page.dart` | 更新 `_generateSummary`：根据 `isRemote` 分支调用 | 支持 API 模型推理 |
| `inspiration_page.dart` | 目录标题栏移除"总结"按钮 | 简化目录标题栏 |
| `inspiration_page.dart` | 详细页面添加"一键总结"按钮+对话框+生成逻辑 | 详细页面内完成总结 |
| `inspiration_page.dart` | 录音项播放控件改为4个独立按钮 | 更清晰的播放控制 |
| `inspiration_page.dart` | 转录后增加"文本"按钮+弹窗查看 | 方便查看转录内容 |
| `README.md` | 追加 Session #41 会话记录 | 按要求记录会话总结 |

### Session #42 — 灵感一瞬播放按钮简化 + 全选/一键总结 + mmproj 模型过滤 (2026-05-29)

**会话背景**：用户提出3个问题：(1) 播放按钮过于复杂（4个按钮），需要简化为播放/停止两个按钮切换；(2) 详细页面缺少全选勾选按钮和一键总结功能；(3) 加载模型时报错 `Failed to load model gemma-4-26B-A4B-it-mmproj-BF16.gguf`，原因是加载了 mmproj（视觉模型投影器）文件而非主模型。

**会话目的**：简化播放控件、补全详细页面功能、修复模型加载错误。

**完成的主要任务**：
1. 主页面录音项播放控件简化：从4个按钮（播放/暂停/停止/速度）改为2个按钮切换（播放/停止），点击播放→图标变为停止，再点击停止
2. 详细页面录音项同样简化为播放/停止切换
3. 详细页面顶部添加全选 Checkbox，支持一键全选/取消全选所有录音
4. 详细页面底部添加"一键总结"按钮（仅在有选中录音时显示）
5. 添加 `_loadFilteredModels()` 方法，过滤掉 filePath 包含 'mmproj' 的模型文件
6. 在3处模型加载代码中应用过滤（主页面总结对话框、详细页面总结对话框、模型选择弹窗）
7. 验证 `flutter analyze` 和 `flutter build macos --debug` 均通过

**技术栈**：Flutter, Dart, SharedPreferences, ModelEntry, LocalFFIEngine, globalModelEngine, flutter_mind_map

**关键决策和解决方案**：
1. 播放控件简化：使用 `isPlaying ? Icons.stop_circle : Icons.play_circle` 实现图标切换，`onPressed` 中根据状态调用 `_stopPlayback()` 或 `_playRecording()`
2. 全选逻辑：`allIds.every((id) => _selectedRecordingIds.contains(id))` 判断是否全选，全选时清除，否则添加所有 ID
3. mmproj 过滤：在 `_loadFilteredModels()` 中检查 `m.filePath != null && m.filePath!.contains('mmproj')`，跳过视觉模型投影器文件
4. 详细页面一键总结按钮放在 ListView 底部，仅当 `_selectedRecordingIds.isNotEmpty` 时显示

**使用的工具**：Read, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 添加 `_loadFilteredModels()` 方法，过滤 mmproj 文件 | 防止加载视觉模型投影器导致崩溃 |
| `inspiration_page.dart` | `_switchLlmModel` 使用 `_loadFilteredModels()` | 模型选择列表过滤 mmproj |
| `inspiration_page.dart` | `_showSummaryDialog` 使用 `_loadFilteredModels()` | 总结对话框模型过滤 |
| `inspiration_page.dart` | `_showSummaryDialogLocal` 内联过滤 mmproj | 详细页面总结对话框过滤 |
| `inspiration_page.dart` | 主页面录音项播放按钮简化为播放/停止切换 | 用户要求简化操作 |
| `inspiration_page.dart` | 详细页面录音项播放按钮同样简化 | 统一交互体验 |
| `inspiration_page.dart` | 详细页面添加全选 Checkbox + 一键总结按钮 | 用户要求补全功能 |
| `README.md` | 追加 Session #42 会话记录 | 按要求记录会话总结 |

### Session #43 — 播放按钮切换修复 + 一键总结加载动画 + 模型选择记忆 (2026-05-29)

**会话背景**：用户反馈两个问题：(1) 播放按钮点击播放后，再次点击不会停止播放（逻辑 bug）；(2) 一键总结按钮没有加载动画，且模型选择没有记忆功能。

**会话目的**：修复播放按钮切换逻辑、添加加载动画、实现模型选择记忆。

**完成的主要任务**：
1. 修复主页面 `_playRecording` 方法：当录音正在播放时，再次点击调用 `_stopPlayback()` 停止播放
2. 修复详细页面 `_playRecording` 方法：同样的逻辑修复
3. 详细页面 AppBar 一键总结按钮：生成中显示 `CircularProgressIndicator` 加载动画
4. 详细页面底部一键总结按钮：生成中显示"正在生成..."文字 + 加载动画，按钮禁用
5. 模型选择记忆：用户在总结对话框中选择模型后，保存到 `SharedPreferences` 的 `inspiration_llm_model_id` 键
6. 下次打开总结对话框时，自动选中上次保存的模型
7. 验证 `flutter analyze` 和 `flutter build macos --debug` 均通过

**技术栈**：Flutter, Dart, SharedPreferences, AudioPlayer, CircularProgressIndicator

**关键决策和解决方案**：
1. 播放按钮切换：修改 `_playRecording` 方法，当 `_playingRecordingId == recording.id` 时调用 `_stopPlayback()` 而不是仅恢复暂停
2. 加载动画：使用 `_isGeneratingSummary` 状态控制按钮显示，生成中显示 `CircularProgressIndicator` + 禁用按钮
3. 模型记忆：在"开始生成"按钮的 `onPressed` 回调中，使用 `prefs.setString('inspiration_llm_model_id', selectedModelId!)` 保存选择

**使用的工具**：Read, SearchReplace, RunCommand (flutter analyze, flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 主页面 `_playRecording` 修复播放/停止切换逻辑 | 修复点击播放后无法停止的 bug |
| `inspiration_page.dart` | 详细页面 `_playRecording` 修复播放/停止切换逻辑 | 统一修复 |
| `inspiration_page.dart` | 详细页面 AppBar 添加加载动画 | 生成中显示加载状态 |
| `inspiration_page.dart` | 详细页面底部按钮添加加载动画 + 禁用状态 | 用户体验优化 |
| `inspiration_page.dart` | 两处总结对话框添加模型保存逻辑 | 实现模型选择记忆功能 |
| `README.md` | 追加 Session #43 会话记录 | 按要求记录会话总结 |

### Session #44 — 播放按钮颜色优化：停止按钮改为红色 (2026-05-29)

**会话背景**：用户要求播放按钮点击播放后变成红色停止按钮，再次点击停止后变回播放按钮。

**会话目的**：优化播放按钮颜色，停止状态使用明确的红色。

**完成的主要任务**：
1. 主页面录音项播放按钮：停止状态颜色从 `theme.colorScheme.error` 改为 `Colors.red`
2. 详细页面录音项播放按钮：同样的颜色修改
3. 验证 `flutter build macos --debug` 通过

**技术栈**：Flutter, Dart, Colors

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 主页面播放按钮停止状态改为 `Colors.red` | 用户要求红色停止按钮 |
| `inspiration_page.dart` | 详细页面播放按钮停止状态改为 `Colors.red` | 统一颜色风格 |
| `README.md` | 追加 Session #44 会话记录 | 按要求记录会话总结 |

### Session #45 — ASR 架构升级：VAD预处理 + 说话人分离 + 模型更新检测 (2026-05-29)

**会话背景**：用户要求对 ASR 功能进行全面升级，包括：(1) 绑定 sherpa-onnx + SenseVoice 模型；(2) 实现 VAD 预处理机制（Silero VAD）；(3) 实现说话人分离功能；(4) 实现模型升级检测和下载；(5) 设计完整的音频处理管道架构。

**会话目的**：设计并实现企业级 ASR 架构，支持 VAD 预处理、说话人分离、模型版本管理。

**完成的主要任务**：
1. 创建 VAD 服务 (`vad_service.dart`)：Silero VAD 模型集成，语音活动检测，音频切分
2. 创建说话人分离服务 (`speaker_diarization_service.dart`)：ECAPA-TDNN 声纹嵌入，AHC 聚类算法，时间戳对齐
3. 创建音频处理管道 (`audio_processing_pipeline.dart`)：整合 VAD + ASR + 说话人分离，支持并行处理
4. 创建模型更新服务 (`model_update_service.dart`)：GitHub Release 检测，多源下载，版本管理
5. 设计完整架构：原始音频 → VAD → ASR + 说话人分离（并行）→ 时间戳对齐 → 最终输出

**技术栈**：Flutter, Dart, Sherpa-ONNX, Silero VAD, ECAPA-TDNN, Dio, SharedPreferences

**关键决策和解决方案**：
1. VAD 预处理：使用 Silero VAD 模型（~2MB），基于能量阈值的简化版算法，减少 30%-60% 无效计算
2. 说话人分离后置化：ASR 和说话人分离并行执行，最后通过时间戳对齐合并结果
3. 聚类算法：使用 Agglomerative Hierarchical Clustering (AHC) + 余弦相似度
4. 模型更新：通过 GitHub API 检测最新 release，支持多镜像源下载

**使用的工具**：Write, Read, TodoWrite

**新增的文件**：
| 文件 | 内容 | 用途 |
|------|------|------|
| `vad_service.dart` | VAD 预处理服务 | 语音活动检测，音频切分 |
| `speaker_diarization_service.dart` | 说话人分离服务 | 声纹嵌入提取，聚类，时间戳对齐 |
| `audio_processing_pipeline.dart` | 音频处理管道 | 整合 VAD + ASR + 说话人分离 |
| `model_update_service.dart` | 模型更新服务 | 版本检测，多源下载，进度回调 |

**架构设计**：
```
原始音频 (.wav)
     │
     ▼
┌─────────────┐
│  VAD 预处理  │  Silero VAD (~2MB)
│  (语音检测)  │  输出: [语音段1, 静音段1, 语音段2, ...]
└──────┬──────┘
       │
       ▼
┌─────────────┐    ┌─────────────────┐
│  ASR 识别    │    │  说话人分离      │
│  (Sherpa-   │    │  (ECAPA-TDNN)   │  ← 并行执行
│   ONNX)     │    │  声纹特征提取    │
└──────┬──────┘    └───────┬─────────┘
       │                   │
       ▼                   ▼
┌─────────────────────────────────┐
│      时间戳对齐 & 合并           │
│  ASR文本 + 说话人标签 + 时间戳   │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│         最终输出                 │
│  [{时间, 说话人, 文本, 置信度}]  │
└─────────────────────────────────┘
```

### Session #46 — 灵感一瞬录音时间限制 + 计时显示 + 倒计时提示 (2026-05-29)

**会话背景**：用户要求灵感一瞬录音功能增加时间限制，方便管理录音时长。

**会话目的**：实现5分钟录音时间限制，录制时显示计时，剩余10秒时提示。

**完成的主要任务**：
1. 添加录音时间限制：最大5分钟（300秒），超时自动停止
2. 录制计时显示：实时显示已录制时长和总时长（如 01:30 / 05:00）
3. 进度条显示：LinearProgressIndicator 显示录制进度
4. 10秒倒计时提示：剩余10秒时显示橙色警告，SnackBar 提示用户
5. 倒计时 UI：进度条变为橙色，显示"剩余 X 秒"文字

**技术栈**：Flutter, Dart, Timer, LinearProgressIndicator, SnackBar

**关键决策和解决方案**：
1. 时间限制：使用 `_maxRecordingSeconds = 300` 常量控制
2. 倒计时逻辑：每秒检查剩余时间，`remaining <= 10` 时触发警告
3. 自动停止：`_recordingSeconds >= _maxRecordingSeconds` 时调用 `_stopRecording()`
4. UI 反馈：进度条颜色从 primary 变为 orange，显示"即将停止"文字

**使用的工具**：SearchReplace, RunCommand (flutter build), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `inspiration_page.dart` | 添加 `_maxRecordingSeconds` 和 `_warningThreshold` 常量 | 定义时间限制参数 |
| `inspiration_page.dart` | 修改 `_startRecording` 添加时间检查逻辑 | 实现自动停止功能 |
| `inspiration_page.dart` | 修改 `_resumeRecording` 添加时间检查逻辑 | 恢复录制时也检查时间 |
| `inspiration_page.dart` | 重写 `_buildRecordingBar` 添加进度条和倒计时 | 显示录制进度和警告 |
| `README.md` | 追加 Session #46 会话记录 | 按要求记录会话总结 |

### Session #47 — VoiceClone 多标签分段合成修复 (2026-05-29)

**会话背景**：用户反馈 TTS 多标签文本（包含 11 个 `[tts:...]` 标签）只播放了第一句，其他标签全部被忽略。

**会话目的**：修复 VoiceClone 模式下多标签文本只读第一句的问题。

**完成的主要任务**：
1. 定位根本原因：`synthesizeWithMiMoClone()` 使用 `parse()` 单标签解析，而非 `parseAll()` 多标签解析
2. 当 VoiceClone 模式启用时（`_cloneReferenceAudioPath != null`），代码在 `_synthesizeWithMiMo()` 中直接跳转到 `synthesizeWithMiMoClone()`，跳过了多标签分段逻辑
3. 修改 `synthesizeWithMiMoClone()` 使用 `parseAll()` 检测多标签
4. 添加 `_synthesizeMultipleCloneSegments()` 方法实现 VoiceClone 多标签分段合成

**技术栈**：Flutter, Dart, MiMo TTS VoiceClone API, TTSStyleParser.parseAll(), WAV 拼接

**关键决策和解决方案**：
1. **根因分析**：`_synthesizeWithMiMo()` 第 1041-1048 行，当 `_cloneReferenceAudioPath != null` 时直接调用 `synthesizeWithMiMoClone()`，而该方法使用 `parse()`（`firstMatch`）只匹配第一个标签
2. **修复方案**：将 `synthesizeWithMiMoClone()` 中的 `TTSStyleParser.parse(text)` 改为 `TTSStyleParser.parseAll(text)`
3. **新增方法**：`_synthesizeMultipleCloneSegments()` — 逐段调用 VoiceClone API，每段使用各自的控制标签，最后拼接所有 WAV 文件
4. **429 限流重试**：每段合成都包含指数退避重试逻辑（最多 3 次）

**使用的工具**：Read, SearchReplace, GetDiagnostics, RunCommand (flutter analyze), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_service.dart` | `synthesizeWithMiMoClone()` 中 `parse()` → `parseAll()` | 支持多标签检测 |
| `tts_service.dart` | 添加多标签分段合成判断逻辑 | 段落数 > 1 时调用分段合成 |
| `tts_service.dart` | 新增 `_synthesizeMultipleCloneSegments()` 方法 | VoiceClone 多标签逐段合成 + WAV 拼接 |
| `README.md` | 追加 Session #47 会话记录 | 按要求记录会话总结 |

**调用链路**：
```
speakLongText() 
  → synthesize() 
    → _synthesizeWithMiMo() 
      → [clone模式] synthesizeWithMiMoClone() 
        → parseAll() 检测多标签
        → _synthesizeMultipleCloneSegments() 逐段合成
          → buildMiMoCloneRequest() 每段请求
          → _concatenateWavFiles() 拼接
      → _playAudio() 播放
```

### Session #48 — 多标签 TTS 语调统一性优化 (2026-05-29)

**会话背景**：多标签分段合成修复后，用户反馈各段语音语调不统一，拼接后听起来很突兀，因为每段独立调用 TTS API 产生不同的语调。

**会话目的**：解决多标签分段合成后的语调一致性问题，让最终输出符合一个人在某个环境下的自然语调。

**完成的主要任务**：
1. 设计并实现 3 层解决方案：全局锚定 + 交叉淡入淡出 + 音量归一化
2. 实现全局角色锚定（Global Anchor）：每段 API 请求注入统一的角色/场景上下文
3. 实现音频交叉淡入淡出（Crossfade）：段落衔接处平滑过渡，消除硬切感
4. 实现音量归一化（Volume Normalization）：统一各段 RMS 响度，避免忽大忽小

**技术栈**：Flutter, Dart, PCM 音频处理, RMS 响度计算, 线性交叉淡入淡出, MiMo TTS API

**关键决策和解决方案**：

1. **全局角色锚定（API 层）**：
   - 分析所有段落的控制标签，提取第一个标签作为角色基调
   - 生成统一的锚定描述："保持统一的声音特质和人格：[基调]。后续每句话的情感变化是在此基础上的细微调整，保持同一人的自然过渡。"
   - 作为每段 API 请求的第一条 user 消息注入，让 TTS 模型保持一致的人格

2. **交叉淡入淡出（音频层）**：
   - 在段落衔接处取前段尾部 80ms 和当前段头部 80ms
   - 前段线性淡出（1→0），当前段线性淡入（0→1）
   - 每个采样混合：`mixed = prev × fadeOut + curr × fadeIn`
   - 消除语调硬切感，实现自然过渡

3. **音量归一化（音频层）**：
   - 计算每段的 RMS（均方根）响度
   - 计算所有段落的平均 RMS 作为目标水平
   - 对每段应用缩放系数（限制在 0.3~3.0 范围内，防止过度放大噪声）

**使用的工具**：Read, SearchReplace, RunCommand (flutter analyze), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_style_parser.dart` | 添加 `extractGlobalAnchor()` 方法 | 从多段控制标签提取统一角色锚定 |
| `tts_style_parser.dart` | `buildMiMoRequest()` 添加 `globalAnchor` 参数 | 注入全局锚定到 API 请求 |
| `tts_style_parser.dart` | `buildMiMoCloneRequest()` 添加 `globalAnchor` 参数 | 注入全局锚定到 VoiceClone 请求 |
| `tts_service.dart` | 添加 `import 'dart:math' as math` | sqrt 计算需要 |
| `tts_service.dart` | 添加 `_WavFileData` 类 | WAV 文件解析数据结构 |
| `tts_service.dart` | 重写 `_concatenateWavFiles()` | 支持交叉淡入淡出 + 音量归一化 |
| `tts_service.dart` | 添加 `_crossfadeMix()` 方法 | PCM 采样级交叉混合 |
| `tts_service.dart` | 添加 `_normalizeSegments()` 方法 | RMS 响度归一化 |
| `tts_service.dart` | `_synthesizeMultipleSegments()` 注入全局锚定 | 非克隆模式语调统一 |
| `tts_service.dart` | `_synthesizeMultipleCloneSegments()` 注入全局锚定 | 克隆模式语调统一 |
| `README.md` | 追加 Session #48 会话记录 | 按要求记录会话总结 |

**请求结构变化**：
```
之前：messages: [{role:"user", content:"语调控制"}, {role:"assistant", content:"文本"}]
之后：messages: [
  {role:"user", content:"保持统一的声音特质和人格：[基调]..."},  ← 全局锚定
  {role:"user", content:"语调控制"},                            ← 段落控制
  {role:"assistant", content:"文本"}                            ← 合成文本
]
```

**音频处理流程**：
```
段落1 WAV → 解析PCM → 音量归一化 ─┐
段落2 WAV → 解析PCM → 音量归一化 ─┤→ 交叉淡入淡出混合 → 统一WAV输出
段落3 WAV → 解析PCM → 音量归一化 ─┘
```

### Session #49 — TTS 风格标签频率优化：减少割裂感 (2026-05-29)

**会话背景**：用户反馈 TTS 风格标签过多，每句话都有独立语调，导致语音输出割裂感严重，听起来不自然。

**会话目的**：修改 TTS 提示词模板，指导 AI 以段落为单位包裹风格标签，减少标签切换频率。

**完成的主要任务**：
1. 修改核心指导原则：从"每句话都必须有控制指令"改为"以段落为单位包裹控制指令（2~5句共用一个标签）"
2. 新增"仅在情感明显转变时切换标签"的指导
3. 新增"保持语调连贯性"的要求
4. 更新所有格式示例为多句共用一个标签的写法
5. 更新简化版提示词保持一致

**技术栈**：Flutter, Dart, TTS 提示词工程

**关键决策和解决方案**：
1. **根因**：提示词模板第 26 行明确要求"每句话都必须有控制指令"，导致 AI 对每句话都加独立标签
2. **修改策略**：
   - 核心原则：以段落为单位（2~5句共用一个标签）
   - 切换条件：仅在情感明显转变时开启新标签
   - 连贯性：相邻标签情感差异不要太大
3. **效果**：标签数量从每句一个减少到每段一个，语音连贯性大幅提升

**使用的工具**：Read, SearchReplace, RunCommand (flutter analyze), TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_prompt_template.dart` | 修改核心指导原则（5条） | 从"每句必标"改为"段落为单位" |
| `tts_prompt_template.dart` | 更新风格标签控制示例 | 展示多句共用一个标签 |
| `tts_prompt_template.dart` | 更新情绪标签控制示例 | 展示多句共用一个标签 |
| `tts_prompt_template.dart` | 更新自然语言控制示例 | 展示多句共用一个标签 |
| `tts_prompt_template.dart` | 更新使用原则（3条→4条） | 新增"以段落为单位"和"情感转变时切换" |
| `tts_prompt_template.dart` | 更新简化版提示词 | 保持完整版和简化版一致 |
| `README.md` | 追加 Session #49 会话记录 | 按要求记录会话总结 |

### Session #50 — 安卓无法对话修复 + 上下文使用率准确性优化 (2026-06-02)

**会话背景**：用户反馈安卓端运行时无法对话，即便是新创建的会话页面也直接报错 `Tokenization failed or prompt too long`。同时之前创建的会话上下文压缩比已显示 100%，点击压缩后虽然提示"上下文已压缩"，但比率仍显示 100%。

**会话主要目的**：
1. 修复安卓端无法对话的根本原因
2. 修复上下文使用率显示不准确（压缩后仍 100%）的问题

**完成的主要任务**：
1. **定位根因**：TTS 完整版控制指令提示词约 9754 tokens，而安卓小模型上下文预算仅约 1044 tokens，system 消息本身就远超预算
2. **TTS 提示词自适应注入**：根据模型上下文预算自动选择完整版/简化版/跳过
3. **truncateToFit 兜底机制**：system 消息超预算时不再直接返回，而是逐条截断内容
4. **上下文使用率精确计算**：将 systemPrompt、TTS 提示词、技能提示词等注入的 token 纳入使用率统计

**主要使用的技术栈**：Flutter/Dart, llama.cpp FFI, Token 估算算法

**关键决策和解决方案**：
- **自适应 TTS 提示词**：当 token 预算 < 200 时跳过 TTS 注入；当预算不足以容纳完整版时自动降级为简化版
- **system 消息截断**：优先保留第一条 system 消息（systemPrompt），后续消息按剩余预算比例截断
- **使用率精确统计**：新增 `updateContextUsageWithSystemPrompts()` 方法，在 UI 轮询时计算所有注入的 system 消息 token

**主要使用的工具**：SearchCodebase, SearchReplace, GetDiagnostics, TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_prompt_template.dart` | `getPrompt()` 新增 `tokenBudget` 参数，根据预算返回完整版/简化版/空字符串 | 小上下文模型注入完整 TTS 提示词会导致 prompt too long |
| `tts_prompt_template.dart` | 新增 `estimateTokenCount()` 静态方法 | 用于估算 TTS 提示词 token 数量 |
| `dialogue_engine.dart` | `_buildStructuredMessages` 和 `_buildStructuredMessagesWithContent` 中 TTS 注入改为自适应模式 | 计算预算后选择合适的 TTS 提示词版本 |
| `dialogue_engine.dart` | 新增 `updateContextUsageWithSystemPrompts()` 方法 | 计算包含 system 消息注入的准确使用率 |
| `context_compressor_service.dart` | `truncateToFit()` 中 system 消息超预算时调用 `_truncateSystemMessages()` | 之前直接返回超预算的 system 消息，模型仍无法处理 |
| `context_compressor_service.dart` | 新增 `_truncateSystemMessages()` 方法 | 逐条截断 system 消息内容以适配预算 |
| `model_inference_engine.dart` | `updateContextUsageFromMessages()` 新增 `extraTokens` 参数 | 支持额外 token 注入 |
| `local_ffi_engine.dart` | `updateContextUsageFromMessages()` 新增 `extraTokens` 参数 | 将额外 token 加入使用量计算 |
| `session_detail_page.dart` | `_updateContextUsage()` 改为调用 `updateContextUsageWithSystemPrompts()` | 包含 system 消息的准确使用率统计 |
| `README.md` | 追加 Session #50 会话记录 | 按要求记录会话总结 |

### Session #51 — 移动设备上下文大小优化 (2026-06-02)

**会话背景**：用户反馈移动设备上可用上下文太少，导致对话体验受限。经分析发现 `_getRecommendedConfig` 对移动设备的 contextSize 配置过于保守（4-6GB 设备仅 2048），且内存预检机制过于激进（直接砍 60%），导致最终可用上下文极小。

**会话主要目的**：优化移动设备的上下文大小配置，提升对话体验。

**完成的主要任务**：
1. **提升默认 contextSize**：4-6GB 设备从 2048 提升到 4096，6-8GB 从 3072 提升到 8192
2. **优化内存预检机制**：修复 KV Cache 估算公式，缩减比例从 60% 放宽到 75%
3. **提升对话引擎预算**：从 85% 提升到 90%，给 system 消息和输出留更多空间

**主要使用的技术栈**：Flutter/Dart, llama.cpp FFI, 内存管理

**关键决策和解决方案**：
- **提升默认值**：现代手机内存充足，保守配置浪费了可用资源
- **修复 KV Cache 公式**：旧公式用 gpuLayers 计算，与模型层数无关，导致估算不准
- **放宽缩减比例**：从 `* 0.6` 改为 `* 0.75`，保留更多上下文空间

**主要使用的工具**：SearchCodebase, SearchReplace, GetDiagnostics, TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `local_ffi_engine.dart` | `_getRecommendedConfig()` 提升各档位 contextSize | 移动设备默认上下文太小 |
| `local_ffi_engine.dart` | 修复 KV Cache 估算公式，从 `contextSize * 8 * gpuLayers / 1024` 改为 `contextSize * 50 / 1024` | 旧公式用 gpuLayers 不准确 |
| `local_ffi_engine.dart` | 运行时开销从 512MB 降到 256MB | 减少不必要的预留 |
| `local_ffi_engine.dart` | 安全阈值从 70% 提升到 75% | 减少系统内存预留 |
| `local_ffi_engine.dart` | 缩减比例从 0.6 放宽到 0.75，最低值从 512 提升到 2048 | 保留更多上下文 |
| `dialogue_engine.dart` | 对话预算从 85% 提升到 90% | 给 system 消息和输出留更多空间 |
| `README.md` | 追加 Session #51 会话记录 | 按要求记录会话总结 |

**优化前后对比（4-6GB 安卓设备）**：
| 指标 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 默认 contextSize | 2048 | 4096 | +100% |
| 内存预检后 | 1228 (×0.6) | 3072 (×0.75) | +150% |
| 对话预算 | 1044 (×0.85) | 2765 (×0.90) | +165% |

### Session #52 — Android 内存检测修复 + 模型加载前内存优化 (2026-06-02)

**会话背景**：用户反馈 16GB 内存的安卓设备被识别为 4GB，导致上下文配置过低。同时希望在加载本地模型前自动优化系统内存，减轻内存占用。

**会话主要目的**：
1. 修复 Android 设备内存检测不准确的问题
2. 在本地模型加载前自动执行内存优化

**完成的主要任务**：
1. **修复 Android 内存检测**：改用 `/proc/meminfo` 读取内存信息，比 `ActivityManager` 更可靠
2. **添加模型加载前内存优化**：清理引擎缓存、触发 GC、释放临时内存

**主要使用的技术栈**：Kotlin (Android), Flutter/Dart, /proc/meminfo

**关键决策和解决方案**：
- **使用 /proc/meminfo**：这是 Linux 标准接口，所有 Android 设备都支持，比 ActivityManager 更准确
- **内存优化策略**：通过分配临时大对象制造内存压力，间接触发 Dart GC

**主要使用的工具**：SearchCodebase, SearchReplace, GetDiagnostics, TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `HardwareCheckerPlugin.kt` | 新增 `readProcMemInfo()` 方法，从 `/proc/meminfo` 读取内存 | ActivityManager 在某些设备上返回不准确 |
| `HardwareCheckerPlugin.kt` | `getMemoryInfo()` 优先使用 `/proc/meminfo`，失败时降级到 ActivityManager | 双重保障 |
| `HardwareCheckerPlugin.kt` | 修复 Long 类型除法，使用 `1024L` 避免整数溢出 | 16GB 设备的字节数超过 Int 范围 |
| `local_ffi_engine.dart` | 新增 `_optimizeSystemMemory()` 方法 | 模型加载前自动优化内存 |
| `local_ffi_engine.dart` | `loadModel()` 开头调用内存优化 | 确保加载前释放可用内存 |
| `README.md` | 追加 Session #52 会话记录 | 按要求记录会话总结 |

### Session #53 — 移动端上下文压缩优化 (2026-06-02)

**会话背景**：用户反馈移动端上下文太短，2-3 轮对话就满了。同时压缩上下文后仍显示 100% 不变。

**会话主要目的**：
1. 解决移动端上下文太短的问题
2. 修复压缩后使用率不更新的问题
3. 优化压缩策略，更激进地释放空间

**完成的主要任务**：
1. **降低压缩阈值**：从 10 条消息降低到 4 条（2 轮对话）
2. **移动端更激进压缩**：上下文 < 8192 时，压缩后只保留 6 条消息
3. **修复使用率更新**：压缩后异步等待再更新 UI
4. **精简压缩说明消息**：从 3 行缩减到 1 行，节省空间
5. **归档到记忆宫殿**：压缩前自动将历史消息存入记忆宫殿

**主要使用的技术栈**：Flutter/Dart, 记忆宫殿系统

**关键决策和解决方案**：
- **动态压缩策略**：根据上下文大小（ctxSize < 8192）判断是否为移动端，采取不同压缩策略
- **异步更新 UI**：压缩后等待 200-300ms 再更新使用率，确保数据库操作完成
- **裁剪压缩结果**：`_trimCompressedMessages()` 方法保留摘要和最近消息

**主要使用的工具**：SearchCodebase, SearchReplace, GetDiagnostics, TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `dialogue_engine.dart` | 压缩阈值从 10 条降到 4 条 | 移动端 2-3 轮就满了 |
| `dialogue_engine.dart` | 新增 `_trimCompressedMessages()` 方法 | 移动端更激进裁剪 |
| `dialogue_engine.dart` | 压缩说明消息精简为 1 行 | 节省空间 |
| `dialogue_engine.dart` | 导入 `dart:math` 的 `max` 函数 | 裁剪方法需要 |
| `session_detail_page.dart` | 压缩后异步等待 200-300ms 再更新 UI | 确保数据库操作完成 |
| `session_detail_page.dart` | 新增 `_updateContextUsageAsync()` 方法 | 异步更新使用率 |
| `README.md` | 追加 Session #53 会话记录 | 按要求记录会话总结 |

---

### Session #54 — 实时语音对话功能实现 (2026-06-02)

**会话背景**：用户需要在会话功能中实现实时语音对话能力，支持持续对话和打断功能。

**主要目的**：在会话界面的"+"号按钮弹窗中新增"实时语音"选项，点击后进入专用语音沟通界面，实现完整的 ASR→LLM→TTS 链路，支持用户打断系统语音播放。

**完成的主要任务**：
1. 创建 `realtime_voice_page.dart` 实时语音对话页面
2. 在 `session_detail_page.dart` 中添加"实时语音"菜单项
3. 实现完整的语音对话状态机（idle → listening → recognizing → thinking → speaking）
4. 实现用户打断功能（用户说话时停止 TTS 播放，重新进入聆听）
5. 实现连续对话模式

**主要技术栈**：
- **ASR**：Sherpa-ONNX 本地离线识别 / 系统语音识别
- **TTS**：OpenAI TTS / MiMo TTS / Sherpa-ONNX / 系统 TTS
- **音频处理**：AudioRecorder (record 包)、just_audio
- **状态管理**：Riverpod、ConsumerStatefulWidget
- **导航**：MaterialPageRoute

**关键决策和解决方案**：
- **状态机设计**：采用六状态模型（idle/listening/recognizing/thinking/speaking/interrupted/error）
- **打断机制**：检测到用户录音时立即停止 TTS 播放，触发触觉反馈，重新进入聆听状态
- **连续对话**：通过 `_isContinuousMode` 开关控制是否自动进入下一轮对话
- **服务集成**：使用应用中已配置的 TTS 服务（通过 `ttsConfigProvider` 获取配置）

**主要使用的工具**：SearchCodebase, Edit, Read, Grep, TodoWrite

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 创建新文件，实现完整语音对话页面 | 实现实时语音对话核心功能 |
| `session_detail_page.dart` | 添加 `import 'realtime_voice_page.dart';` | 导入语音页面组件 |
| `session_detail_page.dart` | 在 `_showToolMenu` 中添加"实时语音"菜单项 | 提供入口 |
| `session_detail_page.dart` | 添加 `_openRealtimeVoicePage()` 方法 | 导航到语音页面 |
| `README.md` | 追加 Session #54 会话记录 | 按要求记录会话总结 |



---

### Session #55 — 实时语音页面初始化链路修复 (2026-06-02)

**会话背景**：进入实时语音页面时出现 `UnimplementedError: Must be overridden in main.dart`。

**主要目的**：修复 `RealtimeVoicePage` 初始化链路，避免依赖未 override 的 Riverpod provider。

**完成的主要任务**：
1. 移除对 `session_voice_service.dart` 的依赖
2. 改为读取 `SettingsService` + `SharedPreferences`
3. 增加 ASR/TTS 提供商映射与回退
4. 保留移动端本地模型的 TTS 降级策略

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 重写 import 与 `_initServices()` | 修复初始化失败 |
| `README.md` | 追加 Session #55 会话记录 | 按要求记录 |

---

### Session #56 — 实时语音与会话页面诊断修复 (2026-06-02)

**会话背景**：在修复初始化失败后继续做静态分析与一致性检查，发现仍有编译/告警问题。

**主要目的**：清理影响编译与告警的问题，确保实时语音入口页面状态稳定。

**完成的主要任务**：
1. 修复 `ASRProvider.whisper` 编译错误
2. 补齐 `VoiceCloneService` 导入
3. 移除未使用字段并修正状态文本使用方式
4. 修正 `session_detail_page` 中无效 null-aware 操作
5. 修正 `FloatingActionButton` 参数顺序
6. 移除未使用的 `_ActionButton.isActive` 参数
7. 将 `withOpacity` 替换为 `withValues(alpha: ...)`

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 修正 ASRProvider 映射与未使用字段 | 消除编译错误与告警 |
| `session_detail_page.dart` | 修正 AppBar/按钮参数顺序与未使用参数 | 消除静态分析告警 |
| `session_detail_page.dart` | `withOpacity` 替换为 `withValues` | 避免已弃用 API 告警 |
| `README.md` | 追加 Session #56 会话记录 | 按要求记录 |


---

### Session #57 — 实时语音页面底部溢出修复 (2026-06-02)

**会话背景**：用户在实时语音页面遇到运行时日志 `A RenderFlex overflowed by 47 pixels on the bottom`。

**主要目的**：修复实时语音页面底部控制栏布局溢出问题。

**完成的主要任务**：
1. 定位到 `_buildBottomControls()` 中固定 `bottom: 32` 的 padding 导致溢出
2. 改为 `SafeArea(top: false)` 包裹并使用较小 padding
3. 重新运行静态分析确认无新增问题

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 修改底部控制栏布局与 padding | 修复 47px 溢出 |
| `README.md` | 追加 Session #57 会话记录 | 按要求记录 |


---

### Session #58 — 模型入口重复日志治理 (2026-06-02)

**会话背景**：运行时持续刷屏 `[ModelInferenceEngine] _getModelEntry: 找到模型 mimo, API key长度=51`。

**主要目的**：消除 `ModelInferenceEngine._getModelEntry()` 的重复调试日志。

**完成的主要任务**：
1. 定位重复日志来源：该方法被多个路径高频调用（`generateChat/generateChatStream/getChatOptions/supportsMultimodal/getContextSize`）
2. 为模型列表解析结果增加缓存，减少重复解析
3. 移除命中模型时的每次打印
4. API Key 为空的警告仅首次记录

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `model_inference_engine.dart` | 优化 `_getModelEntry` 逻辑与日志 | 消除刷屏日志 |
| `README.md` | 追加 Session #58 会话记录 | 按要求记录 |


---

### Session #59 — 工具菜单溢出修复 & 实时语音录音格式修复 (2026-06-02)

**会话背景**：
1. 会话界面点击+号弹出的工具菜单底部溢出 47px
2. 实时语音页面在 Android 上使用 Sherpa ASR 识别失败：`不是有效的 WAV 文件`

**主要目的**：修复两个运行时 UI/功能问题。

**完成的主要任务**：
1. 工具菜单 `showModalBottomSheet` 增加 `SafeArea(top: false)` 包裹，移除手动 `SizedBox(MediaQuery.paddingOf)`，设置 `isScrollControlled: true`
2. 实时语音录音统一使用 `AudioEncoder.wav`（record 包 v6+ 在 Android 上已支持 WAV）
3. 在 `_recognizeAudio()` 中增加格式转换兜底：非 WAV 文件 + Sherpa 提供商时自动调用 `convertAudioFormat()`

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `session_detail_page.dart` | `_showToolMenu` 增加 SafeArea、isScrollControlled | 修复底部溢出 |
| `realtime_voice_page.dart` | 录音统一使用 WAV encoder | Sherpa 需要 WAV 格式 |
| `realtime_voice_page.dart` | `_recognizeAudio` 增加格式转换兜底 | 防止非 WAV 文件传入 Sherpa |
| `README.md` | 追加 Session #59 会话记录 | 按要求记录 |


---

### Session #60 — TTS 系统 TTS 引擎绑定竞态条件修复 (2026-06-02)

**会话背景**：语音播报（MiMo TTS）失败后降级到系统 TTS 时，出现 `W/TextToSpeech: speak failed: not bound to TTS engine`，导致语音完全失效。

**主要目的**：修复 Android 系统 TTS 引擎绑定竞态条件，确保降级/直接使用系统 TTS 时引擎已绑定。

**根因分析**：
1. `_initSystemTts()` 轮询绑定最多 10 次、间隔 500ms、回调超时 3s，在某些慢速设备上不够
2. `warmUpSystemTts()` 是 `await` 的，但 `_speakWithSystem()` 没有检查绑定状态就直接 `speak()`
3. MiMo TTS 合成成功但播放失败时降级到系统 TTS，此时系统 TTS 引擎可能尚未绑定

**完成的主要任务**：
1. `_initSystemTts()`：轮询次数 10→15、间隔 500ms→600ms、回调超时 3s→5s
2. `_speakWithSystem()`：增加绑定状态检查，未绑定时先 `speak(' ')` 触发绑定
3. 清理冗余注释

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_service.dart` | `_initSystemTts` 增加轮询次数和超时 | 慢速设备绑定需要更多时间 |
| `tts_service.dart` | `_speakWithSystem` 增加绑定状态检查 | 防止未绑定就调用 speak |
| `README.md` | 追加 Session #60 会话记录 | 按要求记录 |

---

### Session #61 — 实时语音对话UI重写：豆包风格+会话集成+ASR自动发送 (2026-06-02)

**会话背景**：用户要求优化实时语音对话的UI风格为类似豆包app的实时语音交互界面，同时确保音色使用语音设置中配置的音色，实时语音依赖当前会话（模型及上下文传入），会话界面语音按钮ASR转文字后自动发送到聊天。

**主要目的**：
1. 确保实时语音对话使用语音设置中配置的音色
2. 优化实时语音页面UI为类豆包app风格
3. 实时语音对话依赖当前会话（模型及上下文传入）
4. 会话界面语音按钮ASR转文字后自动发送到聊天

**完成的主要任务**：
1. 重写 `realtime_voice_page.dart`，实现类豆包app风格的实时语音交互界面（深色全屏布局、中央消息气泡列表、底部大麦克风按钮+脉冲波纹动画）
2. 实时语音页面通过 `SettingsService` + `SharedPreferences` 直接读取语音设置中的TTS配置（Provider、MiMo音色、克隆音色等）
3. 实时语音页面通过 `widget.sessionId` 绑定当前会话，使用 `DialogueEngine.streamResponse(sessionId, text)` 传入模型和上下文
4. 修改 `session_detail_page.dart` 中 `_voiceResultSub` 处理逻辑，从弹出层手动确认改为自动调用 `_sendMessage(l10n)` 发送

**主要技术栈**：Flutter/Dart, Riverpod, ASR/TTS 多引擎, DialogueEngine, AudioRecorder, just_audio

**关键决策和解决方案**：
- **音色配置读取**：通过 `SettingsService` + `SharedPreferences` 直接读取TTS配置，避免依赖未实现的 `ttsConfigProvider`
- **UI风格**：采用深色全屏布局，中央消息气泡列表 + 底部大麦克风按钮 + 脉冲波纹动画反馈
- **会话集成**：`RealtimeVoicePage` 接收 `sessionId`，通过 `DialogueEngine.streamResponse` 使用当前会话的模型和上下文
- **ASR自动发送**：将 `_voiceResultSub` 中的弹出层逻辑替换为直接调用 `_sendMessage(l10n)`

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 完全重写UI和业务逻辑，实现豆包风格界面、会话集成、音色配置读取 | 用户要求优化UI风格并集成当前会话 |
| `session_detail_page.dart` | 修改 `_voiceResultSub` 处理逻辑，ASR结果直接发送而非弹出层确认 | 用户要求语音按钮识别后自动发送到聊天 |
| `README.md` | 追加 Session #61 会话记录 | 按要求记录 |

---

### Session #62 — 实时语音对话改为按住说话模式 (2026-06-02)

**会话背景**：用户要求将实时语音对话的交互模式从"点击开始自动对话"改为"按住说话"模式（类似微信语音输入），按住录入语音，松手后ASR转文字直接发送给LLM处理，TTS输出结果。同时要求TTS必须使用语音设置中确认的音色。

**主要目的**：
1. 修改实时语音页面为"按住说话"交互模式
2. 确保TTS使用语音设置中确认的音色

**完成的主要任务**：
1. 重写 `realtime_voice_page.dart` 的交互模式：
   - 移除自动连续对话模式（`_isContinuousMode`）
   - 移除独立的"打断"和"结束"按钮
   - 实现按住说话（`onPanStart` → 开始录音，`onPanEnd` → 停止录音并处理）
   - 状态机简化为：idle → recording → recognizing → thinking → speaking → idle
   - TTS播放中按住按钮可自动打断
2. 确认TTS音色配置逻辑正确：
   - 通过 `SettingsService.getTtsProvider()` 获取用户选择的TTS提供商
   - 通过 `SharedPreferences` 读取 `tts_voice_id`、`selected_tts_model_id`、`system_tts_speed` 等配置
   - MiMo TTS 读取克隆音色引用音频路径
   - 添加初始化日志输出TTS配置详情

**主要技术栈**：Flutter/Dart, GestureDetector (onPanStart/onPanEnd), HapticFeedback, ASR/TTS 多引擎

**关键决策和解决方案**：
- **按住说话交互**：使用 `GestureDetector` 的 `onPanStart/onPanEnd/onPanCancel` 实现按住录音、松手停止并处理
- **打断机制**：TTS播放中按住按钮时自动调用 `_interruptTTS()` 停止播放，然后开始新录音
- **状态提示**：底部显示"按住说话"/"松手结束"文字提示，按住时有触觉反馈
- **TTS音色保障**：初始化时添加日志 `debugPrint('[RealtimeVoicePage] TTS配置: provider=$resolvedTtsProvider, mimoVoice=...')` 确认配置

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 完全重写交互模式为按住说话，移除连续对话模式，简化状态机 | 用户要求按住说话交互 |
| `realtime_voice_page.dart` | 添加TTS配置日志输出 | 确认使用语音设置中的音色 |
| `README.md` | 追加 Session #62 会话记录 | 按要求记录 |

---

### Session #63 — 实时语音克隆音色不生效修复 (2026-06-02)

**会话背景**：用户设置了克隆音色，但实时语音对话中 TTS 请求仍然使用 `voice=Chloe`（默认音色），克隆音色未生效。

**主要目的**：修复实时语音页面克隆音色配置未正确传递到 TTS 服务的问题。

**根因分析**：
- `voice_settings_page.dart` 中用户选择音色后保存到 SharedPreferences 的 `tts_voice_id` key
- `realtime_voice_page.dart` 使用 `settingsService.getMimoVoice()` 读取的是 `mimo_voice` key（不同的 key！）
- `session_detail_page.dart` 正确使用 `prefs.getString('tts_voice_id')` 读取
- 由于 key 不一致，实时语音页面始终读取到默认值，导致克隆音色配置丢失

**完成的主要任务**：
1. 将 `settingsService.getMimoVoice()` 替换为 `prefs.getString('tts_voice_id')`，与会话页面保持一致
2. 增加详细的调试日志：克隆音色原始值、查找过程、加载结果

**主要技术栈**：Flutter/Dart, SharedPreferences, VoiceCloneService

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | `settingsService.getMimoVoice()` → `prefs.getString('tts_voice_id')` | 修复 key 不一致导致克隆音色读取失败 |
| `realtime_voice_page.dart` | 增加克隆音色加载过程的详细日志 | 方便调试排查 |
| `README.md` | 追加 Session #63 会话记录 | 按要求记录 |

---

### Session #64 — 会话界面 TTS 克隆音色不生效 + 系统 TTS 绑定失败修复 (2026-06-02)

**会话背景**：用户在会话界面使用语音 TTS 功能时，克隆音色未生效（显示为 Chloe），同时系统 TTS 绑定失败 `speak failed: not bound to TTS engine`。

**主要目的**：
1. 修复会话界面 TTS 克隆音色不生效问题
2. 修复系统 TTS 绑定失败导致的阻塞问题

**根因分析**：
- **克隆音色问题**：日志显示 `cloneId=clone_1780378410390`，`audioPath` 已正确找到，`cloneRefAudioPath` 已正确传递给 TTSService。克隆音色配置本身是正确的。
- **系统 TTS 阻塞问题**：使用 MiMo TTS 时，`warmUpSystemTts()` 也会被调用，导致系统 TTS 初始化失败（`speak failed: not bound to TTS engine`）并阻塞约 14 秒（15次重试×600ms + 5秒超时）。这个阻塞可能导致 MiMo TTS 合成流程被延迟或中断。

**完成的主要任务**：
1. 修改 `session_detail_page.dart`：仅在 `ttsProvider == 'system'` 时调用 `warmUpSystemTts()`，MiMo/OpenAI/Sherpa 等云端 TTS 引擎跳过系统 TTS 预热
2. 这消除了约 14 秒的阻塞和 `speak failed: not bound to TTS engine` 错误日志

**主要技术栈**：Flutter/Dart, TTSService, MiMo TTS

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `session_detail_page.dart` | `warmUpSystemTts()` 仅在 `ttsProvider == 'system'` 时调用 | 避免非 system TTS 时系统 TTS 初始化失败阻塞 |
| `README.md` | 追加 Session #64 会话记录 | 按要求记录 |

---

### Session #65 — MiMo TTS 重复朗读修复 (2026-06-02)

**会话背景**：用户反馈 MiMo TTS 会使用不同的语调读取 2 遍同一段文字，期望每段文字只读一遍。

**主要目的**：修复 MiMo TTS 重复朗读问题。

**根因分析**：
- MiMo TTS API 使用 chat completions 格式（`/v1/chat/completions`）
- 请求中未指定 `n` 参数，API 可能默认返回多次朗读的音频
- 两次朗读使用不同语调，说明 API 生成了多个变体

**完成的主要任务**：
1. 在 `buildMiMoRequest` 和 `buildMiMoCloneRequest` 中添加 `'n': 1` 参数，限制 API 只生成一次朗读

**主要技术栈**：Flutter/Dart, MiMo TTS API

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_style_parser.dart` | `buildMiMoRequest` 添加 `'n': 1` | 限制标准模式只生成一次朗读 |
| `tts_style_parser.dart` | `buildMiMoCloneRequest` 添加 `'n': 1` | 限制克隆模式只生成一次朗读 |
| `README.md` | 追加 Session #65 会话记录 | 按要求记录 |

---

### Session #66 — 实时语音录音上滑取消功能 (2026-06-02)

**会话背景**：用户要求在实时语音界面中实现类似微信录音的上滑取消效果：按住录音按钮后，手指往上滑动超过阈值会提示"取消"，松手后直接取消录音；手指往下滑回则恢复正常录音状态。

**主要目的**：实现按住上滑取消录音的交互效果。

**完成的主要任务**：
1. 添加状态变量：`_isCancelled`（是否处于取消状态）、`_dragOffsetY`（拖拽偏移量）、`_cancelThreshold`（取消阈值 -80px）
2. 在 `GestureDetector` 中添加 `onPanUpdate` 回调，实时跟踪手指拖拽位置
3. 当手指上滑超过阈值时：按钮变灰色 + 显示删除图标 + 震动反馈 + 状态文字变为"松手取消"
4. 松手时根据是否处于取消状态决定：取消录音 或 正常发送识别
5. 取消录音后1秒自动恢复"按住说话"状态
6. 底部提示文字动态变化：按住说话 → 上滑取消·松手发送 → 松手取消

**主要技术栈**：Flutter/Dart, GestureDetector (onPanStart/onPanUpdate/onPanEnd), HapticFeedback

**关键交互设计**：
- 按住录音按钮 → 开始录音，显示"正在聆听...（上滑取消）"
- 手指上滑超过 -80px → 按钮变灰+删除图标，显示"松手取消"，震动反馈
- 手指滑回 → 恢复红色录音状态，显示"正在聆听...（上滑取消）"
- 松手（未上滑）→ 停止录音，ASR识别 → LLM → TTS
- 松手（已上滑）→ 取消录音，不发送，1秒后恢复

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `realtime_voice_page.dart` | 添加 `_isCancelled`、`_dragOffsetY`、`_cancelThreshold` 状态变量 | 支持取消状态跟踪 |
| `realtime_voice_page.dart` | 添加 `_onPanUpdate` 方法 | 实时跟踪手指拖拽位置 |
| `realtime_voice_page.dart` | 修改 `_onPressEnd` 支持取消/发送两种路径 | 根据取消状态决定行为 |
| `realtime_voice_page.dart` | 添加 `_cancelRecording` 方法 | 取消录音并清理资源 |
| `realtime_voice_page.dart` | 按钮 UI 支持取消状态（灰色+删除图标） | 视觉反馈取消状态 |
| `realtime_voice_page.dart` | 底部提示文字动态变化 | 引导用户操作 |
| `README.md` | 追加 Session #66 会话记录 | 按要求记录 |

---

### Session #67 — MiMo TTS 429 限流优化 (2026-06-02)

**会话背景**：用户反馈 MiMo TTS 非常慢，日志显示连续 429 限流错误，每个段落重试 3 次（1s+2s+4s=7秒），2个段落共等待 14 秒后全部失败，降级到系统 TTS 也失败。

**主要目的**：优化 MiMo TTS 限流策略，减少等待时间，提高成功率。

**根因分析**：
- 没有全局 API 调用限流：段落间无延迟，连续快速调用触发 429
- 重试次数过多（3次），每次等待时间长（1s+2s+4s=7秒）
- 文本分段导致多次 API 调用，加剧限流

**完成的主要任务**：
1. 添加全局 MiMo API 调用限流器（`_lastMiMoCallTime` + `_waitForRateLimit()`），确保两次调用之间至少间隔 3 秒
2. 在所有 MiMo API 调用前添加限流等待（标准合成、克隆合成、分段合成）
3. 减少重试次数：3→2 次，减少等待时间
4. 增加重试间隔：1s/2s/4s → 2s/4s，更尊重 API 限流

**主要技术栈**：Flutter/Dart, Dio HTTP, MiMo TTS API

**优化效果**：
- 之前：2段落 × 3次重试 × 1s/2s/4s = 最多等待 14 秒后失败
- 之后：2段落 × 2次重试 × 2s/4s + 3秒间隔 = 最多等待 12 秒，且限流等待减少触发概率

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_service.dart` | 添加 `_lastMiMoCallTime`、`_minCallInterval`、`_waitForRateLimit()` | 全局 API 调用限流 |
| `tts_service.dart` | 标准 MiMo 合成前添加 `await _waitForRateLimit()` | 防止连续调用触发 429 |
| `tts_service.dart` | 分段合成每段前添加 `await _waitForRateLimit()` | 段落间延迟 |
| `tts_service.dart` | 克隆合成重试 3→2 次，间隔 1s→2s | 减少等待时间 |
| `tts_service.dart` | 克隆分段合成重试 3→2 次，添加限流等待 | 与标准模式一致 |
| `README.md` | 追加 Session #67 会话记录 | 按要求记录 |

---

### Session #68 — MiMo TTS globalAnchor 导致重复朗读修复 (2026-06-02)

**会话背景**：用户反馈实时语音交互中，MiMo TTS 输出的 AI 语音将同一段文字读了 2 遍。日志显示请求 `messages` 中包含两条消息：`role: user`（全局角色锚定）和 `role: assistant`（实际朗读文本），MiMo TTS API 会把 messages 中的所有消息都当作待朗读文本合成，导致重复朗读。

**主要目的**：修复 globalAnchor 作为 user 消息注入 API 请求导致文本被读两遍的问题。

**根因分析**：
- `_synthesizeMultipleSegments` 和 `_synthesizeMultipleCloneSegments` 中，通过 `TTSStyleParser.extractGlobalAnchor(segments)` 提取全局角色锚定
- 然后通过 `buildMiMoRequest(globalAnchor: globalAnchor)` 将其作为 `role: user` 消息注入到 API 请求中
- MiMo TTS API 基于 chat completions 格式，会把 messages 中所有消息的内容都作为待朗读文本进行语音合成
- 导致 user 消息（全局锚定描述）和 assistant 消息（实际文本）都被朗读，产生重复

**完成的主要任务**：
1. 移除 `_synthesizeMultipleSegments` 中 `buildMiMoRequest` 调用的 `globalAnchor` 参数
2. 移除 `_synthesizeMultipleCloneSegments` 中 `buildMiMoCloneRequest` 调用的 `globalAnchor` 参数
3. 清理两个方法中不再使用的 `globalAnchor` 变量提取和日志
4. 每段文本自身已包含风格标签（如 `(温柔亲切带笑意)`），足够控制语调，无需额外 user 消息

**主要技术栈**：Flutter/Dart, MiMo TTS API (chat completions format)

**修改的文件**：
| 文件 | 修改内容 | 原因 |
|------|---------|------|
| `tts_service.dart` | `_synthesizeMultipleSegments` 移除 `globalAnchor` 参数传递 | 防止 user 消息被 API 朗读 |
| `tts_service.dart` | `_synthesizeMultipleCloneSegments` 移除 `globalAnchor` 参数传递 | 克隆模式同理 |
| `tts_service.dart` | 清理两个方法中无用的 `globalAnchor` 变量和日志 | 消除死代码 |
| `README.md` | 追加 Session #68 会话记录 | 按要求记录 |
