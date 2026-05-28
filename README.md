# MJ Nexus - Multi-Modal AI Assistant

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.30.0-blue" alt="Version"/>
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
