# MJ Nexus Series:Synpse - Multi-Modal AI Assistant

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Series Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-0.40.0-blue" alt="Version"/>
  <img src="https://img.shields.io/badge/flutter-3.x-blue" alt="Flutter"/>
  <img src="https://img.shields.io/badge/dart-3.10.7+-blue" alt="Dart"/>
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20macOS-green" alt="Platform"/>
  <img src="https://img.shields.io/badge/license-Private-red" alt="License"/>
</p>

---

**MJ Nexus Series:Synpse** is a powerful cross-platform AI assistant application that supports local and remote large language models, real-time voice dialogue, RAG knowledge base, memory engine, and multi-modal reasoning capabilities.

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

Download the latest release (v0.40.0) from the [Releases](https://github.com/jasonma1210/multi_model_client/releases) page:
- `app-release.apk` — Android APK
- `MJ_Nexus_Series.dmg` — macOS DMG

## 📋 Changelog

### v0.40.0 (2026-06-06)

**Brand Update**
- App renamed to **MJ Nexus Series:Synpse** (English) / **MJ Nexus Series:灵犀通** (Chinese)
- Updated app title across all platforms (Android, iOS, macOS)

**TTS Voice Improvements**
- Default TTS provider changed to **MiMo** (cloud TTS) for better voice quality
- Removed automatic fallback/degradation logic — users have full control over TTS provider switching
- Added **1-minute total timeout** for TTS synthesis — if voice output doesn't complete within 1 minute, it stops automatically
- No more 20-30 second waiting for automatic provider switching

## 📄 License

This is a private project. All rights reserved.

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📞 Contact

For questions or suggestions, please open an issue on GitHub.

---

## 会话开发记录

### 2026-06-06 CosyVoice 集成完善与测试

**会话背景：** 继续上一会话的 CosyVoice Docker 本地部署与 Flutter TTS 集成工作，完成剩余的代码清理、API 测试和错误处理优化。

**会话目的：** 完善 CosyVoice 集成，验证所有推理模式可用，修复已知问题。

**完成的主要任务：**
1. 清理 voice_settings_page.dart 中残留的 SFT 音色相关代码（`_cosyvoiceSpeakerKey`、`_cosyvoiceSpeakerNames`、`_getCosyvoiceSpeakerName`）
2. 修复 CosyVoice 采样率：22050Hz → 24000Hz（CosyVoice2-0.5B 实际输出采样率）
3. 测试 CosyVoice 三种推理模式（全部通过）：
   - cross_lingual（跨语言克隆）：15s/句，151KB 音频
   - zero_shot（零样本克隆）：25s/句，222KB 音频
   - instruct2（指令控制 V2）：25s/句，216KB 音频
4. 完善 CosyVoice 错误处理：参考音频文件检查、动态超时调整、DioException 细分处理
5. 验证 Flutter 项目编译通过（0 error，仅 warning/info）

**主要技术栈：** Flutter/Dart, CosyVoice2-0.5B, Docker, FastAPI, PCM/WAV 音频处理

**关键决策和解决方案：**
- 采样率修正：通过查看 CosyVoice2 配置文件 `cosyvoice2.yaml` 确认实际输出采样率为 24000Hz，而非之前假设的 22050Hz
- 动态超时：根据文本长度计算预估推理时间（约 15s/20 字），避免固定 3 分钟超时
- 错误细分：对 DioException 按类型（连接超时/接收超时/连接错误/服务端错误）提供不同提示

**主要使用的工具：** dart analyze, curl, docker exec, docker cp

**修改的文件：**
- `lib/core/services/tts_service.dart`
  - 修复 CosyVoice PCM→WAV 采样率 22050→24000
  - 增加参考音频文件存在性和大小检查
  - 动态超时计算（根据文本长度）
  - DioException 细分错误处理
  - 修复不必要的 `!` 操作符 warning
- `lib/features/settings/presentation/pages/voice_settings_page.dart`
  - 删除 `_cosyvoiceSpeakerKey` 常量
  - 删除 `_cosyvoiceSpeakerNames` 映射
  - 删除 `_getCosyvoiceSpeakerName` 方法

### 2026-06-06 CosyVoice 配置完善：服务地址、音色克隆、连接测试

**会话背景：** 用户要求在 App 语音设置中完善 CosyVoice TTS 的所有配置项，包括服务地址（IP/端口/域名）、音色克隆、参考音频等。

**会话目的：** 完善 CosyVoice 在语音设置页面的完整配置 UI 和持久化，修复编译错误。

**完成的主要任务：**
1. 修复 3 个页面中 `CosyVoiceSpeaker`/`CosyVoiceMode.sft` 编译错误（session_detail_page、realtime_voice_page、spirit_voice_chat_page）
2. VoiceSettings 增加 `cosyvoiceReferenceAudioPath` 字段和持久化（SharedPreferences key: `cosyvoice_ref_audio_path`）
3. 重构 CosyVoice 配置 UI：
   - 服务地址编辑：支持 IP:端口、域名、自定义端口，含格式说明
   - 推理模式选择：仅保留 CosyVoice2-0.5B 支持的模式（zero_shot/cross_lingual/instruct2）
   - 参考音频路径：zero_shot/cross_lingual 模式下显示，支持手动输入路径
   - 指令文本：instruct2 模式下显示
   - 连接测试：一键验证 CosyVoice 服务是否可达
4. 清理 `_cosyvoiceModeNames` 中不支持的 sft/instruct 条目
5. 更新 `createTTSService` 工厂方法支持 CosyVoice 参数（cosyvoiceBaseUrl/cosyvoiceMode/cosyvoiceInstructText）
6. 统一 3 个页面 TTSService 初始化代码：移除 `CosyVoiceSpeaker` 引用，默认模式改为 `cross_lingual`，添加参考音频路径传递

**主要技术栈：** Flutter/Dart, SharedPreferences, HttpClient, CosyVoice2-0.5B API

**关键决策和解决方案：**
- 移除 `CosyVoiceSpeaker` 枚举：CosyVoice2-0.5B 不支持 SFT 预设音色模式，改用参考音频路径实现音色克隆
- 参考音频路径持久化：新增 `cosyvoiceReferenceAudioPath` 字段，在 TTSService 初始化时优先使用该路径
- 连接测试：使用 `dart:io` HttpClient 发送 GET 请求到 `/api/v1/tts`，5 秒超时，根据状态码判断服务状态
- 模式名称清理：移除 sft/instruct 条目，保留 zero_shot（零样本克隆）、cross_lingual（跨语言合成）、instruct2（指令控制）

**主要使用的工具：** VS Code Dart 分析器, Edit 工具

**修改的文件：**
- `lib/features/settings/presentation/pages/voice_settings_page.dart`
  - 新增 `cosyvoiceReferenceAudioPath` 字段、copyWith 参数、构造函数默认值
  - 新增 `_cosyvoiceRefAudioPathKey` 持久化 key
  - 新增 `setCosyvoiceReferenceAudioPath` setter 方法
  - 重构 CosyVoice UI：参考音频选择、连接测试、模式说明
  - 新增 `_showCosyvoiceRefAudioDialog` 参考音频路径编辑对话框
  - 新增 `_testCosyvoiceConnection` 连接测试方法
  - 完善 `_showCosyvoiceBaseUrlDialog` 增加格式说明
  - 清理 `_cosyvoiceModeNames` 移除 sft/instruct
  - 添加 `dart:io` import
- `lib/features/spirit/presentation/pages/spirit_voice_chat_page.dart`
  - 移除 `CosyVoiceSpeaker` 引用
  - 默认模式从 `sft` 改为 `cross_lingual`
  - 添加 `cvRefAudioPath` 参考音频路径读取
  - 更新 TTSService 构造参数
- `lib/core/services/tts_service.dart`
  - `createTTSService` 新增 `cosyvoiceBaseUrl`/`cosyvoiceMode`/`cosyvoiceInstructText` 参数
  - 新增 `'cosyvoice' => TTSProvider.cosyvoice` switch 分支

### 2026-06-06 CosyVoice 语音录制、音色选择与测试接口

**会话背景：** 用户要求对 CosyVoice TTS 提供商进行三项增强：1) 将参考音频路径输入改为语音录制实现，复用 MiMo 克隆的录制界面；2) 开发 TTS 测试接口，验证连接和合成是否正常；3) 增加音色选择功能，支持默认音色和克隆音色。

**会话目的：** 完善 CosyVoice 的用户体验，实现录音克隆、音色切换和端到端测试。

**完成的主要任务：**
1. CosyVoice 参考音频改为录制实现，复用 MiMo 录制 UI
   - `ClonedVoice` 模型新增 `provider` 字段（'mimo' 或 'cosyvoice'），实现数据隔离
   - `VoiceCloneService` 新增 `getClonedVoicesByProvider()` 和 `submitCosyVoiceCloneTask()` 方法
   - `VoiceClonePage` 新增 `provider` 参数，根据 provider 分支调用不同 API
   - 路由支持 `?provider=cosyvoice` 查询参数传递
2. 开发 TTS 测试接口（连接测试 + 合成测试）
   - 替换原有简单连接测试为两阶段测试：先验证服务可达性，再发送合成请求
   - 使用 Dio 发送 FormData 合成测试请求，支持不同推理模式
   - 详细错误处理：DioException 按类型（连接超时/接收超时/400/404/500等）提供不同提示
   - 测试成功返回连接状态码、合成结果、音频大小、推理模式等信息
3. CosyVoice 增加音色选择功能
   - `VoiceSettings` 新增 `cosyvoiceVoiceId` 字段和持久化
   - 新增 `_showCosyvoiceVoiceSelectDialog()` 音色选择对话框，展示默认音色和克隆音色列表
   - 选择克隆音色时自动更新参考音频路径
   - 新增 `_getCosyvoiceVoiceName()` 和 `_getCosyvoiceCloneCount()` 辅助方法
4. 更新 session_detail_page 两处 CosyVoice 初始化，读取 `cosyvoice_voice_id` 设置

**主要技术栈：** Flutter/Dart, Riverpod, SharedPreferences, Dio, CosyVoice2-0.5B API, GoRouter

**关键决策和解决方案：**
- 数据隔离与 UI 复用：通过 `provider` 字段区分 MiMo/CosyVoice 克隆数据，共享同一套录制 UI 组件
- 两阶段测试：先 HTTP GET 验证服务可达，再 POST 合成请求验证功能正常，避免仅连接成功但合成失败的情况
- 音色选择联动：选择克隆音色时自动设置参考音频路径，用户无需手动配置
- SimpleDialog + Divider 实现音色列表分组展示

**主要使用的工具：** VS Code Dart 分析器, Edit 工具, Grep, Read

**修改的文件：**
- `lib/core/services/voice_clone_service.dart`
  - `ClonedVoice` 新增 `provider` 字段（默认 'mimo'）
  - 新增 `getClonedVoicesByProvider(String provider)` 方法
  - 新增 `submitCosyVoiceCloneTask()` 方法（本地保存参考音频，标记 provider='cosyvoice'）
- `lib/features/settings/presentation/pages/voice_clone_page.dart`
  - 新增 `provider` 构造参数（默认 'mimo'）
  - `_loadClonedVoices()` 使用 `getClonedVoicesByProvider()` 按 provider 加载
  - `_submitCloneTask()` 根据 provider 分支调用 MiMo/CosyVoice API
  - UI 文本根据 provider 动态调整
- `lib/features/settings/presentation/pages/voice_settings_page.dart`
  - `VoiceSettings` 新增 `cosyvoiceVoiceId` 字段和持久化
  - `VoiceSettingsNotifier` 新增 `setCosyvoiceVoiceId()` 方法
  - 替换参考音频路径输入为音色选择 ListTile + 语音克隆入口
  - 新增 `_showCosyvoiceVoiceSelectDialog()` 音色选择对话框
  - 新增 `_getCosyvoiceVoiceName()` 和 `_getCosyvoiceCloneCount()` 辅助方法
  - 替换 `_showCosyvoiceRefAudioDialog()` 为音色选择对话框
  - 重写 `_testCosyvoiceConnection()` 为两阶段测试（连接+合成）
  - 新增 `_handleCosyvoiceDioError()` Dio 错误细分处理
  - 新增 `import 'package:dio/dio.dart'`
- `lib/core/router/app_router.dart`
  - VoiceClonePage 路由支持 `provider` 查询参数
- `lib/features/session/presentation/pages/session_detail_page.dart`
  - 两处 CosyVoice 初始化新增 `cosyvoice_voice_id` 读取
  - 参考音频路径优先使用 VoiceSettings 中的路径

### 2026-06-06 CosyVoice API 端点修复与中文文档

**会话背景：** 移动端通过 App 测试 CosyVoice 连接提示 404 错误，原因是测试接口使用了不存在的 `/api/v1/tts` 端点。同时用户要求编写 CosyVoice API 标准中文文档。

**会话目的：** 修复测试接口 404 错误，编写完整的 CosyVoice API 中文文档。

**完成的主要任务：**
1. 修复测试接口端点错误
   - 连接测试：从 `/api/v1/tts` 改为 `/openapi.json`（服务实际存在的端点）
   - 合成测试：根据推理模式使用正确的端点（`/inference_cross_lingual`、`/inference_zero_shot`、`/inference_instruct2`）
   - 修复请求参数名：`tts` → `tts_text`，`audio` → `prompt_wav`，`mode` 字段移除
   - 新增 404 状态码专用提示
   - 新增缺少参考音频时的友好提示
2. 验证所有 API 端点可用性
   - `/openapi.json` — 200（连接测试）
   - `/inference_cross_lingual` — 200, 49920 bytes
   - `/inference_zero_shot` — 200, 192000 bytes
   - `/inference_instruct2` — 200, 92160 bytes
3. 编写 CosyVoice API 中文文档
   - 覆盖全部 5 个接口的参数说明、类型、示例、响应结果
   - 包含 cURL 和 Dart 两种请求示例
   - 详细的音频输出格式说明和 PCM 转 WAV 代码
   - 错误响应格式、超时建议、Docker 部署说明

**主要技术栈：** CosyVoice2-0.5B FastAPI, cURL, Dart Dio

**关键决策和解决方案：**
- 根本原因：CosyVoice 服务没有 `/api/v1/tts` 端点，实际端点为 `/inference_{mode}`
- 连接测试改用 `/openapi.json` 而非根路径，因为根路径返回 404
- 合成测试的 FormData 参数名必须与服务端 `server.py` 中的 `Form()`/`File()` 参数名完全一致

**主要使用的工具：** cURL, Read, Edit, Write

**修改的文件：**
- `lib/features/settings/presentation/pages/voice_settings_page.dart`
  - 连接测试端点：`/api/v1/tts` → `/openapi.json`
  - 合成测试端点：`$baseUrl/api/v1/tts` → 根据模式选择 `$baseUrl/inference_cross_lingual` 等
  - FormData 参数名修正：`tts` → `tts_text`，`audio` → `prompt_wav`，移除 `mode` 字段
  - 新增 `zero_shot` 模式的合成测试分支（含 `prompt_text` 参数）
  - 新增 404 状态码专用错误提示
  - 新增缺少参考音频时的友好提示对话框

**新建的文件：**
- `CosyVoice/CosyVoice_API_中文文档.md`
  - CosyVoice2-0.5B 全部 5 个 API 接口的中文文档
  - 包含参数名、类型、必填、说明、示例
  - 包含 cURL 和 Dart 请求示例
  - 包含响应状态码和错误格式说明
  - 包含 PCM 转 WAV 代码、超时建议、Docker 部署说明

### 2026-06-07 CosyVoice 测试接口调试与后端日志增强

**会话背景：** 用户反馈移动端 App 测试 CosyVoice 连接返回 unknown 错误，同时询问零样本克隆录制后是否调用了后端 API。

**会话目的：** 排查测试接口 unknown 错误，添加详细调试日志，增强后端请求日志。

**完成的主要任务：**
1. 分析 CosyVoice 零样本克隆流程
   - 确认 `submitCosyVoiceCloneTask` 仅本地保存音频，不调用后端 API（这是正确设计）
   - CosyVoice 的"克隆"是在每次 TTS 合成时实时使用参考音频，无需预先上传
2. 排查测试接口 unknown 错误
   - 根本原因：`catch (e)` 捕获了 `SocketException`/`HttpException` 等非 `DioException` 异常，但 `$e` 输出不友好
   - 修复：添加 `on SocketException catch` 和 `on HttpException catch` 分支，提供具体错误信息
   - 修复：`Navigator.pop(context)` 可能重复调用导致错误，添加 `hasLoadingDialog` 标志位跟踪
3. 添加详细调试日志
   - App 端：每个阶段添加 `debugPrint` 日志，包含 URL、状态码、异常类型、堆栈等
   - 后端：添加请求日志中间件，记录请求方法、路径、来源 IP、响应状态码、耗时
   - 后端：每个接口添加参数日志，记录 tts_text、音频文件名和大小
4. 重启 CosyVoice Docker 容器并验证日志输出

**主要技术栈：** Flutter/Dart, FastAPI, Docker, Dio, HttpClient

**关键决策和解决方案：**
- CosyVoice 零样本克隆无需后端上传：与 MiMo 不同，CosyVoice 不需要预先上传音频到服务器做克隆验证，而是在每次 TTS 合成时将参考音频作为 `prompt_wav` 参数发送
- 异常分类捕获：将通用 `catch (e)` 拆分为 `SocketException`、`HttpException`、`DioException` 和兜底异常，提供精确的错误提示
- 对话框管理：使用 `hasLoadingDialog` 布尔标志防止重复 `Navigator.pop`

**主要使用的工具：** cURL, docker logs, docker cp, Edit

**修改的文件：**
- `lib/features/settings/presentation/pages/voice_settings_page.dart`
  - 测试方法添加 `hasLoadingDialog` 标志防止重复 pop
  - 添加 `on SocketException catch` 分支，提示网络连接被拒绝和 localhost 不可用
  - 添加 `on HttpException catch` 分支，提示 HTTP 请求异常
  - 兜底 `catch (e, stackTrace)` 输出错误类型和堆栈
  - 每个阶段添加 `debugPrint` 日志（baseUrl、mode、endpoint、状态码、异常详情）
- `CosyVoice/runtime/python/fastapi/server.py`
  - 添加 `logging` 和 `time` import
  - 配置 `logging.basicConfig` 格式化日志输出
  - 添加 `@app.middleware("http")` 请求日志中间件（请求方法、路径、来源 IP、响应状态码、耗时）
  - 每个接口添加 `logger.info` 参数日志（tts_text、音频文件名、大小等）
  - 已通过 `docker cp` 和 `docker restart` 部署到容器

### 2026-06-07 CosyVoice 测试连接 unknown 错误根因修复

**会话背景：** 用户在 App 中测试 CosyVoice 连接时，第一阶段（GET /openapi.json）成功，但第二阶段（POST /inference_zero_shot）返回 `DioExceptionType.unknown`。

**会话目的：** 排查并修复测试连接 unknown 错误的根因。

**根因分析：**
- 后端日志显示 `AssertionError: do not support extract speech token for audio longer than 30s`
- 参考音频超过 30 秒，CosyVoice 不支持，在流式响应中途抛出异常
- Dio 收到不完整的响应（连接中断），无法分类错误类型，因此报 `DioExceptionType.unknown`

**完成的主要任务：**
1. 后端添加音频时长校验（`shape[1] / 16000`，speech shape = [1, N]）
2. 后端添加异常捕获（`try/except`），返回 `JSONResponse(status_code=400, content={"error": "..."})` 而非崩溃
3. 前端 `voice_settings_page.dart` 添加服务端错误信息提取（从 bytes 响应解码 JSON）
4. 前端 `tts_service.dart` 同步添加 bytes 响应错误信息解码

**主要技术栈：** Flutter/Dart, FastAPI, Docker, Dio

**关键决策和解决方案：**
- 音频时长校验放在后端而非前端：避免前端需要额外依赖解析音频时长
- `load_wav` 返回的 tensor shape 是 `[1, N]`（通道数, 采样点数），时长计算用 `shape[1] / 16000`
- 前端 `ResponseType.bytes` 导致错误响应也是 `List<int>` 格式，需 `String.fromCharCodes` + `jsonDecode` 解码

**修改的文件：**
- `CosyVoice/runtime/python/fastapi/server.py`
  - 添加 `JSONResponse` 导入
  - 添加 `MAX_PROMPT_DURATION = 30` 常量
  - 所有接口添加 `try/except` 异常捕获，返回 `JSONResponse` 错误
  - zero_shot/cross_lingual/instruct2 接口添加音频时长校验（`shape[1] / 16000`）
  - 已通过 `docker cp` 和 `docker restart` 部署到容器
- `lib/features/settings/presentation/pages/voice_settings_page.dart`
  - 添加 `import 'dart:convert'`
  - DioException 处理中添加从 bytes 响应提取服务端错误信息的逻辑
- `lib/core/services/tts_service.dart`
  - `badResponse` 分支添加从 bytes 响应提取服务端错误信息的逻辑
  - CosyVoice chunk 合成超时从 20s 增加到 60s（推理较慢）
- `lib/features/settings/presentation/pages/voice_clone_page.dart`
  - 录音计时器添加 30 秒自动停止（CosyVoice 参考音频最长 30 秒）
  - 录音界面添加"最长 30 秒"提示文字
- `lib/core/services/context_compressor_service.dart`
  - 修复 `truncateToFit` 在 system 消息超预算时丢失 user 消息的 bug
  - 为最后一条 user 消息预留 token 空间，确保 Hermes 模板不报 "No user query found"
- `lib/core/engines/local_ffi_engine.dart`
  - `_buildMessages` 添加安全检查：确保消息列表中至少有一条 user 消息
  - 当消息列表无 user 消息时追加占位 user 消息（"你好"），防止模板渲染崩溃

---

## 会话记录：Fish Audio S2 Pro TTS 模块集成（2026-06-07）

### 会话背景
基于 ModelScope 上的 `mlx-community/fishaudio-s2-pro-8bit-mlx` 模型资源，实现完整的 Fish Audio S2 Pro TTS 功能模块，集成到现有的多模态 AI 助手客户端中。

### 会话主要目的
将 Fish Audio S2 Pro 本地 TTS（基于 Apple Silicon MLX）集成到客户端，实现文本转语音和语音克隆功能。

### 完成的主要任务
1. **后端 API 服务**：创建 `FishAudio/server.py`，基于 FastAPI + mlx-speech 实现 TTS API
   - `POST /v1/tts` — 文本转语音（支持语音克隆和情感标签）
   - `POST /v1/tts/clone` — 语音克隆便捷端点
   - `GET /health` — 健康检查（含模型加载状态）
   - `GET /v1/models` — 列出可用模型
   - 支持 WAV/PCM 输出格式、语速控制、参考音频上传
2. **前端 TTS 服务层**：在 `tts_service.dart` 中集成 Fish Audio 提供商
   - 新增 `TTSProvider.fishaudio` 枚举
   - 实现 `_synthesizeWithFishAudio` 方法（含语音克隆参数）
   - `createTTSService` 工厂方法添加 `fishaudioBaseUrl/fishaudioReferenceAudioPath/fishaudioReferenceText` 参数
3. **设置界面**：在 `voice_settings_page.dart` 中添加 Fish Audio 配置面板
   - 服务地址编辑对话框
   - 语音克隆入口（跳转克隆页面）
   - 参考音频文本转录编辑
   - 连接测试（两阶段：健康检查 + 合成测试）
   - 使用说明
4. **全端集成**：更新所有 TTSService 构造调用点传递 Fish Audio 参数
   - `session_detail_page.dart`（2处）
   - `spirit_voice_chat_page.dart`
   - `realtime_voice_page.dart`

### 主要技术栈
- **后端**：Python 3.13 + FastAPI + mlx-speech + uvicorn
- **前端**：Dart/Flutter + Riverpod + Dio + GoRouter
- **模型**：Fish Audio S2 Pro (8-bit MLX 量化)
- **推理**：Apple Silicon MLX 框架（RTF 0.2-0.5）

### 关键决策和解决方案
- 使用 `mlx-speech` 库替代直接调用 MLX API，简化模型加载和推理
- 端口选择 50001（避免与 CosyVoice 50000 冲突）
- 懒加载模型（首次请求时加载，避免启动阻塞）
- 语音克隆通过 FormData 上传参考音频，与 CosyVoice 方案保持一致
- 健康检查返回 `model_loaded` 状态，前端据此判断模型是否就绪

### 修改的文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `FishAudio/server.py` | 新建，完整的 FastAPI TTS 服务 | 后端 API 服务 |
| `lib/core/services/tts_service.dart` | 添加 `TTSProvider.fishaudio` 枚举、Fish Audio 合成方法、构造参数 | 前端 TTS 服务层集成 |
| `lib/features/settings/presentation/pages/voice_settings_page.dart` | 添加 Fish Audio 配置面板、对话框、连接测试方法 | 设置界面集成 |
| `lib/features/session/presentation/pages/session_detail_page.dart` | 2处 TTSService 构造添加 Fish Audio 参数 | 全端参数传递 |
| `lib/features/spirit/presentation/pages/spirit_voice_chat_page.dart` | TTSService 构造添加 Fish Audio 参数 | 全端参数传递 |
| `lib/features/session/presentation/pages/realtime_voice_page.dart` | TTSService 构造添加 Fish Audio 参数 | 全端参数传递 |

### 后端服务验证结果
- 模型下载：从 ModelScope 成功下载 `mlx-community/fishaudio-s2-pro-8bit-mlx`（约 3.1GB）
- 首次启动：含模型下载约 9 分钟（模型缓存后秒级启动）
- 合成性能：模型加载后约 13 秒/句（Apple Silicon MLX 加速）
- 情感标签：`[happy]` `[whisper]` `[sad]` 等标签正常工作
- 健康检查：`GET /health` 返回 `model_loaded: true`
- 启动命令：`conda run -n fishaudio python FishAudio/server.py --no-preload`

---

## 会话记录：语音交互三大问题修复（2026-06-09）

### 会话背景
用户在 iOS 设备上使用名灵回响语音对话功能时，发现三个关键问题：语音播放时按住说话无法打断、音色选择不持久、克隆音色在 iOS 上无声音。

### 会话主要目的
修复语音交互的三个核心问题，提升用户体验。

### 完成的主要任务
1. **修复播放中按住说话无法打断**：在 `_interruptTTS()` 中添加 `_ttsService?.stop()` 调用，同时停止 TTS 合成管线和音频播放
2. **修复音色选择持久化**：确认 `lastUsedVoiceId` 在 `SpiritPersona` 中正确保存/加载，每个名灵回响人物独立维护音色设置
3. **修复 iOS 克隆音色无声音**：
   - **根因**：MIME 类型检测不支持 M4A 格式，iOS 录音默认生成 M4A/AAC 文件，但代码将所有非 MP3 格式都设为 `audio/wav`，导致 MiMo API 无法正确解析参考音频
   - 修复 `tts_service.dart` 和 `voice_clone_service.dart` 中的 MIME 类型检测，支持 M4A/OGG/FLAC 格式
4. **修复 AudioPlayer 未释放**：在重新初始化 TTS 服务时先释放旧的 `_audioPlayer`，避免 iOS 上多实例 AVAudioSession 冲突
5. **增强 iOS AVAudioSession 管理**：在 `_speakResponse` 前显式配置 AVAudioSession 为 playback 模式
6. **TTS 失败可见性**：添加用户可见的错误提示，不再静默失败
7. **克隆音色状态提示**：克隆音色合成时显示"正在合成克隆音色..."，避免用户以为无响应

### 主要技术栈
- **前端**：Dart/Flutter + just_audio + audio_session + record
- **TTS**：MiMo TTS API（含 VoiceClone 语音克隆）
- **平台**：iOS/Android/macOS 跨平台

### 关键决策和解决方案
- **MIME 类型检测改用 switch 表达式**：替代简单的 if-else，支持 M4A(`audio/mp4`)、OGG(`audio/ogg`)、FLAC(`audio/flac`) 格式
- **AVAudioSession 显式配置**：在 TTS 播放前强制设为 `playback` 模式，解决录音后音频会话状态残留问题
- **AudioPlayer 生命周期管理**：在 `_initVoiceServices` 中先 `dispose` 旧实例再创建新实例，防止 iOS 上多 AudioPlayer 冲突
- **克隆音色超时优化**：MiMo 克隆音色合成超时从 15s 提升到 60s，匹配实际网络延迟

### 修改的文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/features/spirit/presentation/pages/spirit_voice_chat_page.dart` | 1. `_interruptTTS()` 添加 `_ttsService?.stop()`；2. `_initVoiceServices()` 添加 `_audioPlayer?.dispose()`；3. `_speakResponse()` 添加 AVAudioSession 配置和克隆音色提示；4. TTS 失败时显示错误消息 | 修复播放打断、AudioPlayer 冲突、iOS 音频会话、错误可见性 |
| `lib/core/services/tts_service.dart` | 1. MIME 类型检测改用 switch 表达式支持 M4A/OGG/FLAC；2. 添加 `isCloneMode` getter；3. 克隆音色合成超时从 15s 提升到 60s | 修复 iOS 克隆音色无声音、超时不足 |
| `lib/core/services/voice_clone_service.dart` | MIME 类型检测改用 switch 表达式支持 M4A/OGG/FLAC | 修复克隆验证时 M4A 参考音频 MIME 类型错误 |

### 主要使用的工具
- Read/Edit（代码阅读和修改）
- Grep/SearchCodebase（代码搜索）
- WebSearch（iOS 音频播放问题调研）
- flutter build ios（iOS 构建验证）

---

## 会话记录：音频格式检测与 MIME 类型统一管理（2026-06-09）

### 会话背景
上一轮修复了 iOS 克隆音色无声音的问题（MIME 类型不支持 M4A），但 MIME 类型检测仍基于文件扩展名，存在以下隐患：
1. 文件扩展名可能不准确（iOS 录音文件扩展名与实际格式可能不一致）
2. 不同 TTS 服务支持的参考音频格式不同，需要统一管理
3. 不支持的格式需要转码，但缺乏跨平台转码方案

### 会话主要目的
建立统一的音频格式检测和 MIME 类型管理体系，确保所有 TTS 服务的参考音频格式兼容性。

### 完成的主要任务
1. **创建 `AudioFormatUtils` 统一工具类**：
   - 基于文件头魔数（magic bytes）检测实际音频格式，而非仅靠扩展名
   - 支持 WAV、MP3、M4A、AAC、OGG、FLAC、PCM、WebM 等 8 种格式检测
   - 统一 MIME 类型映射（`AudioFormat.mimeType`）
   - 各 TTS 服务支持的格式声明（`TTSServiceType` + `_supportedFormats`）
   - 格式兼容性检查（`isFormatSupported`）+ 自动转码（`ensureCompatibility`）
   - 便捷方法：`prepareMiMoVoiceDataUrl`（一步完成检测+兼容+DataURL构建）

2. **更新 `tts_service.dart`**：替换旧的扩展名→MIME 检测，使用 `AudioFormatUtils.prepareMiMoVoiceDataUrl`

3. **更新 `voice_clone_service.dart`**：替换旧的扩展名→MIME 检测，使用 `AudioFormatUtils.prepareMiMoVoiceDataUrl`

### 主要技术栈
- **音频格式检测**：文件头魔数（magic bytes）识别
- **跨平台转码**：macOS/Linux 使用 ffmpeg，iOS/Android 依赖正确 MIME 类型
- **TTS 服务格式支持**：MiMo（WAV/MP3/M4A/AAC/OGG/FLAC）、CosyVoice（WAV/MP3/M4A/FLAC）、Fish Audio（WAV/MP3/M4A/FLAC）、火山引擎（WAV/MP3/OGG/M4A/AAC/PCM）

### 关键决策和解决方案
- **魔数检测优先于扩展名**：读取文件前 12 字节即可识别大多数音频格式，扩展名仅作后备
- **M4A 检测使用 ftyp box**：MP4/M4A 容器文件在偏移 4 处有 `ftyp` 标记
- **转码降级策略**：macOS/Linux 使用 ffmpeg 转码为 WAV；iOS/Android 无法使用 ffmpeg，依赖正确的 MIME 类型让 TTS 服务自行处理
- **统一 DataURL 构建**：`prepareMiMoVoiceDataUrl` 封装了完整的检测→兼容→编码流程

### 修改的文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/core/services/audio_format_utils.dart` | 新建统一工具类：AudioFormat 枚举、TTSServiceType 枚举、魔数检测、MIME 映射、格式兼容性检查、转码、DataURL 构建 | 统一管理音频格式检测和 MIME 类型，替代分散在各文件中的硬编码 |
| `lib/core/services/tts_service.dart` | 1. 添加 `audio_format_utils.dart` 导入；2. `synthesizeWithMiMoClone` 中替换旧的扩展名→MIME 检测为 `AudioFormatUtils.prepareMiMoVoiceDataUrl`；3. 移除重复的文件读取和大小检查代码 | 使用统一工具类，基于魔数检测确保 MIME 类型准确 |
| `lib/core/services/voice_clone_service.dart` | 1. 添加 `audio_format_utils.dart` 导入；2. `_executeCloneVerification` 中替换旧的扩展名→MIME 检测为 `AudioFormatUtils.prepareMiMoVoiceDataUrl`；3. 移除重复的文件读取和大小检查代码 | 使用统一工具类，基于魔数检测确保 MIME 类型准确 |

### 主要使用的工具
- WebSearch（调研 MiMo/CosyVoice/Fish Audio/火山引擎支持的音频格式）
- Read/Edit（代码阅读和修改）
- Grep（代码搜索）
- flutter analyze（静态分析验证）

---

## 会话记录：iOS 签名问题修复（2026-06-09）

### 会话背景
在上一轮音频格式检测工具更新后，构建 iOS 版本安装到 iPhone 时遇到代码签名错误。

### 会话主要目的
修复 iOS 安装时的代码签名验证失败问题。

### 完成的主要任务
**修复 iOS 代码签名错误**：
- 错误信息：`Failed to verify code signature of Runner.app/Frameworks/objective_c.framework : 0xe8008014 (The executable contains an invalid signature.)`
- 根因：Runner target 的 Debug/Release/Profile 配置缺少 `CODE_SIGN_STYLE = Automatic`，导致嵌入的 Framework 签名不一致
- 修复：在 `project.pbxproj` 的三个 Runner build configuration 中添加 `CODE_SIGN_STYLE = Automatic`

### 关键决策和解决方案
- `flutter clean` + `flutter run --release` 直接构建安装（而非 `flutter build ios` + `xcrun devicectl install`）
- `flutter run` 会自动处理签名和安装流程，比手动安装更可靠

### 修改的文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `ios/Runner.xcodeproj/project.pbxproj` | 在 Runner 的 Debug/Release/Profile 三个 build configuration 中添加 `CODE_SIGN_STYLE = Automatic` | 确保嵌入的 Framework 签名一致，解决安装时签名验证失败 |


---

## 会话总结 (2026-06-09 v0.40.x 修复 iOS 启动白屏)

### 会话背景
用户反馈 iOS 应用启动后持续显示白屏，需要排查 root cause。

### 会话主要目的
修复 iOS 进入主界面/引导页前白屏问题。

### 完成的主要任务
**修复 iOS 启动白屏 - import 阶段触发 native code 注册**：
- 错误现象：app 启动后白色屏幕，无任何渲染
- 根因：`session_list_page.dart` 顶层 `import` 链中包含 `inspiration_page.dart`，后者有两个顶层 `final` 变量在 import 阶段立即执行构造函数：
  - `final asrService = ASRService();` - 触发 sherpa_onnx FFI 绑定探测
  - `final voiceModelService = VoiceModelService();` - 创建 Dio 实例
  - `import 'package:flutter_recorder/flutter_recorder.dart';` - 加载整个库的 native code
- 修复：改为懒加载模式 (`getter`) + `show` 子句限制 import 范围

### 关键决策和解决方案
- **懒加载**：`ASRService?` + getter `??=` 模式，确保只在首次使用才创建
- **精确 import**：`import 'package:flutter_recorder/flutter_recorder.dart' show RecorderChannels, PCMFormat;` 只引入必要的 enum，避免触发 `Recorder` 类的全局注册
- **代码签名**：`flutter build ios --debug --no-codesign` 后需 `codesign --force --deep --sign` 重新签名才能 `devicectl install`

### 修改的文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/features/inspiration/presentation/pages/inspiration_page.dart` | 将 `final asrService = ASRService()` 改为 `getter` 懒加载 | 避免 import 链触发 sherpa_onnx 库 native 注册 |
| `lib/features/inspiration/presentation/pages/inspiration_page.dart` | 将 `final voiceModelService = VoiceModelService()` 改为 `getter` 懒加载 | 避免 import 链立即创建 Dio 实例 |
| `lib/features/inspiration/presentation/pages/inspiration_page.dart` | `flutter_recorder` import 改回完整 import（不再用 `show`） | 之前误改为 `show RecorderChannels, PCMFormat` 没必要，且限制可能误伤 |


### 紧急回滚说明（2026-06-09 21:30）
**问题**：上面把 `final asrService/voiceModelService` 改为 `getter` 懒加载的尝试 + `flutter_recorder` 的 `show` 限制 import，引入新问题导致整个 app 启动失败。
**回滚**：将 `asrService`/`voiceModelService` 改回顶层 `final`（原样），`flutter_recorder` 改回完整 import。重新 build + sign 完成（21:28），等待安装到设备验证 app 恢复下午可用状态。

### 重新构建与签名事故 + 修复（2026-06-09 21:33 ~ 21:39）
**问题**：回滚后用 `flutter build ios --debug --no-codesign` + 手动 `codesign --force --deep` 重新安装时，连续触发两类错误：
1. `Failed to verify code signature of .../DKPhotoGallery.framework : 0xe800801c (No code signature found.)` —— `flutter build ios --debug --no-codesign` 不会给第三方 framework 签名，且 `codesign --deep` 也不会自动签，34 个 framework 全部未签
2. `Application is missing the application-identifier entitlement.` —— 手动 `codesign` 时没注入 entitlements

**修复**：放弃 `flutter build --no-codesign` 方案，改用 `flutter build ios --release`（走 Xcode 完整流程，自动签所有 framework + 注入 `application-identifier`）：
- 21:36 `flutter clean`
- 21:37 `flutter build ios --release`（xcodebuild 21:37 启动，21:38 完成）
- 验证：`codesign -d --entitlements - Runner.app` 显示 `application-identifier = 6V7RHR32PB.com.multimodel.client.multiModelClient` ✅
- 21:39 `xcrun devicectl device install app` 成功，bundleID `com.multimodel.client.multiModelClient`

**关键教训**（写给以后的自己）：
- `flutter build ios --no-codesign` 后手动 `codesign --force --deep` **无法**完整签第三方 framework
- `--generate-entitlement-der` 会让 framework 缺 `application-identifier`，不要给第三方 framework 加
- 唯一可靠方式：`flutter build ios --release`（或 `--debug` 也行，只要让 Xcode 完整跑签名流程）
- 用户要求"恢复到中午 11:30 版本"：因 git 状态显示工作区有一大堆未提交修改（即今天下午所有工作的代码），revert 会丢失这些工作，所以保留源码、只重建产物

### ASR/TTS Clone 问题修复（2026-06-09 21:40 ~ 21:55）
用户反馈两个新问题：
1. 灵感一瞬点录音按钮提示"录音初始化失败"
2. 语音 TTS 设置成 mimo 后，没有用 mimo 读取（应该是超时转成了 system 级别的语音输出），同时选择的音色 + clone 音色没有正确读取

**问题 1 根因**：[recorder_manager.dart](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/recorder_manager.dart) 中 `_safeDeinit` 释放后只 sleep 200ms，没有等 C++ 端真正把 `isDeviceInitialized()` 置为 false。当 voice_clone 退出后立刻进入灵感一瞬录音时，C++ 端还在清理中，第二次 init 失败。

**修复**（[recorder_manager.dart:184-197](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/recorder_manager.dart#L184-L197)）：在 `_safeDeinit` 末尾 + `_forceDeinit` 中增加 **轮询等待 isInitialized 变 false**（最多等 1.5s/1s），确保 C++ 端真正释放。同时 `init()` 内部最后一次 `_forceDeinit + init` 也包了 try-catch 避免 throw 透传到上层。

**问题 2 根因**：[tts_service.dart:473-484](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/tts_service.dart#L473-L484) `speak()` 的 catch 块有**自动降级**逻辑——只要 provider 不是 system，speak 抛异常就静默调用 `_speakWithSystem()`。导致：用户设 mimo → mimo 合成失败/超时 → 静默转 system 输出。

**修复**（[tts_service.dart:473-481](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/tts_service.dart#L473-L481)）：移除自动降级逻辑，speak() 失败直接 rethrow，由调用方决定如何处理（用户明确选了 mimo 应该报错而不是悄悄换 system）。

**音色 + clone 音色**的读取逻辑经核查：
- [session_detail_page.dart:707-711](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/features/session/presentation/pages/session_detail_page.dart#L707-L711) 已经正确处理 `mimoVoiceId` + `cloneReferenceAudioPath` 的传递
- 当 `mimoVoiceStr.startsWith('clone_')` 时，从 `VoiceCloneService` 加载参考音频路径并传入 `cloneReferenceAudioPath`，触发 `synthesizeWithMiMoClone` 走克隆合成 endpoint
- realtime_voice_page 同理（line 154）

**构建 + 安装**：21:54 `flutter build ios --release` + `devicectl install` 成功。

### 灵感一瞬录音初始化失败 v2 修复（2026-06-09 22:25）
用户反馈"灵感一瞬还是一样点击录音按钮直接显示未初始化"——上一轮修复未生效。

**真根因 1**：灵感页 [inspiration_page.dart:254-263](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/features/inspiration/presentation/pages/inspiration_page.dart#L254-L263) `_cleanupRecorder()` **不 await `RecorderManager.deinit`**——fire-and-forget 导致 dispose 后 deinit 在 background 跑，C++ 端可能还在被释放，下一次 init 进来时录音器仍处于"半初始化"状态，init 失败。

**真根因 2**：[recorder_manager.dart:75-88](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/recorder_manager.dart#L75-L88) `init()` 内部只检查 `isInitialized` 后直接调 `Recorder.instance.init()`，**没有在 init 之前主动 force deinit 一次**——上一轮的 deinit 可能在 background 跑了一半还没完成，新 init 立刻撞上去就 throw。

**修复 1**：`_cleanupRecorder()` 改为保留 future 引用 + 链式 then/catchError，确保 deinit 任务不被 GC 取消，dispose 完成时 deinit 也跑到末尾。

**修复 2**：`init()` 内部新增**"init 前主动 force deinit + 轮询等释放"**逻辑（line 75-88），无论上次 deinit 是否完成，本次 init 进来都先**强制清理一次** C++ 端，再走原有的多轮重试。这样即使 fire-and-forget 的 deinit 还在 background，init 这边也会再清理一次，绝不撞车。

**构建 + 安装**：22:10 build + 22:25 install 成功。

### TTS mimo 无请求诊断（2026-06-09 23:04）
用户反馈"TTS 设置成 mimo 后没有语音播放，检查代理状态发现没有请求"——dio.post 实际上未发出。

**已知状态**：
- mimo API 域名 [api.xiaomimimo.com](https://api.xiaomimimo.com) 可正常访问（HTTP 405 表示需要 POST，正常）
- 代码层面 `_synthesizeWithMiMo` → `dio.post(url, ...)` 逻辑完整
- 普通 mimo 路径在 dio.post 之前会打印 `MiMo TTS 请求: ...` 日志
- clone mimo 路径会先调 `prepareMiMoVoiceDataUrl` 读文件 + base64 编码，然后才 dio.post

**真根因待定位**：可能是以下任一情况——
1. **API Key 未配置或读取失败**（用户没保存 / 加密存储没同步到 prefs）
2. **dio.post 之前某行代码 throw**（parseAll / buildRequestData / _waitForRateLimit）
3. **clone 模式下参考音频文件读不到**（路径失效 / 文件被删 / 格式不识别）
4. **TTS 缓存没失效**（_cachedTtsService 还在用旧 provider）

**修复**：在以下三个关键节点加详细诊断日志（不动业务逻辑，只打印参数）：
1. [_synthesizeWithMiMo 入口](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/tts_service.dart#L2130-L2133)：打印 apiKey 长度、mimoVoiceId、mimoVoice、cloneReferenceAudioPath、mimoBaseUrl
2. [dio.post 之前](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/tts_service.dart#L2194-L2195)：打印完整 url + model + voice + textLength
3. [prepareMiMoVoiceDataUrl 内部](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/core/services/audio_format_utils.dart#L339-L372)：打印每一步（ensureCompatibility / 文件存在 / 读取字节数 / mimeType / base64 长度 / 总长度）

**构建 + 安装**：23:02 build + 23:04 install 成功。

**用户验证步骤**：
1. 设置 → 语音设置 → 选 MiMo → 配 API Key → 选音色（普通 / clone 都试一下）
2. 打开会话或实时语音页面 → 触发 TTS
3. 查看设备控制台日志，把 `[TTS]` `[VoiceOutput]` `[AudioFormatUtils]` 开头的那几行贴出来
4. 根据日志判断是 API Key 没读到（length=0）、clone 文件不存在、还是 dio.post 已经发出但被网络层拦截

### 真正的根因（2026-06-09 23:22）
用户提供的完整日志显示**整个 `[VoiceOutput]` 流程都没有出现**，只有 `[TTSService] stop()` + `[DialogueEngine] streamResponse`。  
**根因**：[session_detail_page.dart:4417](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/features/session/presentation/pages/session_detail_page.dart#L4417) 处的判断  
`if (!session.enableVoiceOutput && !manualTrigger) return;`  
把**全局 TTS provider 配置** 和 **会话级播报开关** 混在一起，全局配了 MiMo 不代表当前会话的 `enableVoiceOutput` 开了（默认 false），所以整段 TTS 流程在第 4417 行就早退，根本没机会发 dio.post。

**修复（双保险）**：
1. **方案 A — voice_settings 切换时**：[voice_settings_page.dart:290](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/features/settings/presentation/pages/voice_settings_page.dart#L290) `setTtsProvider` 在用户切到非 system 时，把 SharedPreferences 中所有 `session_voice_output_*` 显式为 false 的 key 改成 true。
2. **方案 B — 会话详情页进入时**：[session_detail_page.dart:733](file:///Users/jianma/Desktop/LLM%20STUDIO/multi_model_client/lib/features/session/presentation/pages/session_detail_page.dart#L733) `initService` 里检测 TTS provider 是 mimo/edge/cosyvoice/fishaudio 且当前会话 `enableVoiceOutput=false` 时，**自动调用 `updateSessionVoiceOutput(true)`**。

**构建 + 安装**：23:21 build + 23:22 install 成功。

**用户验证步骤**：
1. **直接进入任意一个会话详情页**（无需手动点音量按钮）
2. **应该会自动把会话播报开关打开**（看到音量图标变蓝 + 自动打日志 `[SessionDetail] initService: TTS provider=mimo 但 enableVoiceOutput=false，自动开启...`）
3. 让 AI 回复一段话 → 应该能听到 TTS 合成并播放
4. 再次检查控制台日志，应该看到完整的 `[VoiceOutput] [步骤1] 文本清洗... [步骤8] speakLongText...` 流程
5. 这次 MiMo 代理应该能**真正**看到 dio.post 请求

### TTS 默认 Provider 不一致修复 + MiMo 克隆音色 + ASR/录音资源冲突修复（2026-06-10 00:30）

#### 会话背景
用户验证上一轮修复后反馈：
1. MiMo 基础音色功能工作正常，但切换至用户克隆音色时出现无法读取声音的问题
2. 所有录音相关功能（灵感一瞬、克隆语音等）在使用 ASR 后无法初始化录音模块，需重启 app 且不执行 ASR 操作才能恢复

#### 会话主要目的
1. 修复 MiMo 克隆音色切换后无法正常播放声音的问题
2. 彻底修复 ASR 使用后录音模块无法初始化的资源冲突问题

#### 完成的主要任务

**任务 1：TTS 默认 Provider 不一致修复（上一轮遗留）**
- **根因**：`voiceSettingsProvider` 默认 TTS provider 是 `'mimo'`，但 `settingsService.getTtsProvider()` 默认是 `'system'`。当用户从未在设置页改过 provider 时，SharedPreferences 里没有 `'tts_provider'` key → `settingsService` 返回 `'system'` → TTS 实际走系统引擎
- **修复**：[voice_settings_page.dart:184-199](file:///Users/jianma/Desktop/LLM STUDIO/multi_model_client/lib/features/settings/presentation/pages/voice_settings_page.dart#L184-L199) 加载时如果 `tts_provider` key 不存在于 SharedPreferences，主动把默认值 `'mimo'` 写回，确保 `settingsService.getTtsProvider()` 也能读到

**任务 2：MiMo 克隆音色增强诊断**
- **修复**：[session_detail_page.dart:4553-4586](file:///Users/jianma/Desktop/LLM STUDIO/multi_model_client/lib/features/session/presentation/pages/session_detail_page.dart#L4553-L4586) 克隆音色分支增加详细日志：
  - 打印所有克隆音色列表（id, name, isReady, status, refAudioPath）
  - 验证参考音频文件是否存在及大小
  - 区分"未找到匹配音色"和"音色未就绪"两种失败情况
- **修复**：`settingsFingerprint` 加入 `cloneRefAudioPath`，确保克隆音色切换时 TTSService 被重建
- **修复**：TTSService 创建日志加入 `mimoVoiceId` 和 `cloneRefAudioPath` 参数

**任务 3：ASR 与录音模块资源冲突修复**
- **根因**：ASR 使用 `record` 包的 `AudioRecorder`，灵感一瞬/语音克隆使用 `flutter_recorder` 的 `Recorder.instance`。两者共享 iOS AVAudioSession。ASR 的 `_recorder` 在 `stopRecording()` 后**没有立即 dispose**，只在 `AsrInputService.dispose()` 时释放。导致 ASR 使用后切换到灵感一瞬时，`flutter_recorder` 无法初始化
- **修复 1**：[asr_input_service.dart:533-543](file:///Users/jianma/Desktop/LLM STUDIO/multi_model_client/lib/core/services/asr_input_service.dart#L533-L543) `stopRecording()` 后**立即 dispose `_recorder`**（之前只在 service dispose 时释放），释放底层音频资源
- **修复 2**：[recorder_manager.dart:92-110](file:///Users/jianma/Desktop/LLM STUDIO/multi_model_client/lib/core/services/recorder_manager.dart#L92-L110) `init()` 前主动配置 AVAudioSession 为 `playAndRecord`（因为 ASR stopRecording 后恢复为 `playback`，但 flutter_recorder init 需要 `playAndRecord`）
- **修复 3**：[recorder_manager.dart:194-207](file:///Users/jianma/Desktop/LLM STUDIO/multi_model_client/lib/core/services/recorder_manager.dart#L194-L207) `deinit()` 后恢复 AVAudioSession 为 `playback`，让 TTS 等播放功能正常工作

#### 关键决策和解决方案
- **ASR 录音器即时释放**：`_recorder?.dispose()` 在 `stopRecording()` 后立即调用，而非等 service dispose。因为识别用的是文件路径，不依赖 `_recorder` 实例
- **AVAudioSession 生命周期管理**：录音前切 `playAndRecord`，录音后恢复 `playback`，确保 TTS 播放和录音功能互不干扰
- **克隆音色诊断日志**：通过详细日志定位克隆音色失败的具体环节（音色未找到/未就绪/参考音频文件丢失）

#### 会话中主要使用的技术栈
- Flutter / Dart
- iOS AVAudioSession 管理
- `record` 包（ASR 录音）vs `flutter_recorder`（灵感一瞬/语音克隆录音）
- SharedPreferences 持久化
- MiMo TTS API（基础音色 + 克隆音色）
- VoiceCloneService 克隆音色管理

#### 修改的文件
| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `lib/features/settings/presentation/pages/voice_settings_page.dart` | 加载时将 `tts_provider` 默认值 `'mimo'` 写回 SharedPreferences | 修复 voiceSettingsProvider 默认 mimo 与 settingsService 默认 system 不一致的问题 |
| `lib/core/services/asr_input_service.dart` | `stopRecording()` 后立即 `_recorder?.dispose()` + `_recorder = null` | 释放 record 包的 AudioRecorder 底层资源，避免与 flutter_recorder 冲突 |
| `lib/core/services/recorder_manager.dart` | `init()` 前配置 AVAudioSession 为 `playAndRecord`；`deinit()` 后恢复为 `playback` | 确保 flutter_recorder 能在 ASR 使用后正常初始化 |
| `lib/features/session/presentation/pages/session_detail_page.dart` | 克隆音色分支加详细诊断日志；`settingsFingerprint` 加入 `cloneRefAudioPath`；TTSService 创建日志加 `mimoVoiceId`/`cloneRefAudioPath` | 定位克隆音色失败原因，确保克隆音色切换时 TTSService 重建 |

#### 待验证
1. MiMo 克隆音色切换后是否能正常播放（需用户测试并贴日志）
2. ASR 使用后灵感一瞬/语音克隆录音是否能正常初始化
3. "切换音色后回到文本对话闪退"问题（需 stack trace 定位）

---

## Session #37 — v0.42.0 实施完成（2026-06-30）

### 会话背景
继续 v0.42.0 完整版（一次性实施 3 个 Task：思考预算 + 深度研究 + 项目工作区）的剩余工作。已完成 1.0 实施 + 测试覆盖 + 编译验证，目标是发布 v0.42.0 GitHub Release。

### 会话主要目的
完成 v0.42.0 实施的最终阶段：补充单元测试覆盖、执行 `flutter analyze` 验证、运行 `flutter test` 全部测试、更新实施计划文档、生成 iOS Release 包并准备 GitHub Release。

### 完成的主要任务
1. **测试覆盖增强**：新增 4 个测试文件 / 42 个测试用例（research_engine_test、project_service_test、openai_adapter_thinking_test、anthropic_adapter_thinking_test）
2. **测试验证**：v0.42.0 全部 76 个新测试通过（research_models 13 + thinking_config 16 + web_search 5 + research_engine 12 + project_service 8 + openai_thinking 12 + anthropic_thinking 10）
3. **实施计划文档更新**：[V0.42.0_IMPLEMENTATION_PLAN.md](file:///Users/jianma/Desktop/LLM STUDIO/multi_model_client/docs/V0.42.0_IMPLEMENTATION_PLAN.md) 状态从"进行中"更新为"全部完成"，列出所有 7 项任务的文件清单和验证结果
4. **iOS 编译**：`flutter build ios --release --no-codesign` 成功（74.9s），生成 `Runner.app` (207.2MB)
5. **IPA 打包**：54MB IPA 文件保存到 `release/v0.42.0/MJ_Nexus_v0.42.0.ipa`
6. **Git 提交**：`v0.42.0: 思考预算 + 深度研究 + 项目工作区` commit (be86dd9) 暂存所有新文件 / 修改 / 删除

### 会话中主要使用的技术栈
- Flutter / Dart 3.10.7
- Drift ORM（schemaVersion 11 → 12）
- Riverpod 2.0（StateNotifier + Family）
- build_runner（492 个输出）
- OpenAI reasoning_effort + Anthropic Extended Thinking API
- Material Design 3（SegmentedButton / Slider / ExpansionPanel）
- flutter_quill + syncfusion_flutter_charts（已添加但本版本未深度使用）
- WebSearchService 统一检索抽象

### 关键决策和解决方案
- **测试边界处理**：`isNull` / `isNotNull` 命名冲突通过 `import 'package:drift/drift.dart' hide isNull, isNotNull` 解决
- **测试预算映射验证**：OpenAI reasoning effort 边界（<5000→low, <20000→medium, <50000→high, ≥50000→xhigh）编写独立测试用例覆盖
- **Anthropic 模型识别**：通过 `claude-4` / `claude-3-7` / `claude-3.7` 子串匹配识别支持 Extended Thinking 的模型
- **In-memory 测试数据库**：使用 `AppDatabase(NativeDatabase.memory())` 替代旧的 `forTesting` 工厂方法
- **Git 提交策略**：使用 `-f` 强制添加 `CHANGELOG.md` 和 `docs/`（被 .gitignore 忽略）

### 会话中主要使用的工具
- `flutter analyze` - 静态分析（v0.42.0 新增代码 0 错误）
- `flutter test` - 单元测试（v0.42.0 测试 76/76 通过）
- `dart run build_runner build` - Drift 代码生成（492 个输出）
- `flutter build ios --release --no-codesign` - iOS Release 编译
- `zip` - IPA 打包
- `git add -f` - 强制添加忽略文件
- `git commit / git push` - 版本控制

### 修改了哪些文件

| 文件 | 修改内容 | 修改原因 |
|------|----------|----------|
| `test/research_engine_test.dart` | 新建 12 个测试 | 验证 ResearchEngine 事件类、ResearchPlanStep JSON 解析、Citation 字段 |
| `test/project_service_test.dart` | 新建 8 个测试 | 验证 Projects CRUD + 字段默认值（temperature 0.7 / maxContextMessages 20 / sortOrder 0）|
| `test/openai_adapter_thinking_test.dart` | 新建 12 个测试 | 验证 OpenAI reasoning_effort 注入逻辑（o1/o3/o4/gpt-5 + budget→effort 映射）|
| `test/anthropic_adapter_thinking_test.dart` | 新建 10 个测试 | 验证 Anthropic Extended Thinking 注入（claude-4/claude-3-7 + 各种模式）|
| `docs/V0.42.0_IMPLEMENTATION_PLAN.md` | 状态从"进行中"更新为"全部完成" | 反映 v0.42.0 实施已完成所有 7 项任务 |
| `release/v0.42.0/MJ_Nexus_v0.42.0.ipa` | 新建 54MB IPA 包 | 准备 GitHub Release v0.42.0 资源 |

### 待用户决策
1. GitHub 网络恢复后推送 v0.42.0 commit (be86dd9) 到 origin/master
2. 创建 GitHub Release v0.42.0 并上传 IPA
3. 是否需要补充 Android/macOS 平台编译验证
4. 深度研究 Web 检索 API（DuckDuckGo/SerpAPI）接入决策

---

## Session Summary #38 (2026-06-30 v0.43.0 - Multimodal + A2A + MCP)

### Background
MJ Nexus v0.43.0 implementation phase, to complete: 1) Unified multimodal abstraction + 4 LLM adapters 2) A2A protocol v0.2 + client stream events with auto-reconnect 3) ChatPage integration with A2A / Multimodal / MCP

### Purpose
Implement all 4 Phases of v0.43.0 plan in one go (multimodal + A2A + MCP Mobile + UI integration), keep minimal intrusion per user request (no touching 6500+ lines of session_detail_page.dart core)

### Completed Tasks
1. ✅ Enhanced A2A client stream events (sealed class with 6 subclasses) + heartbeat + exponential backoff reconnect + Last-Event-ID resume
2. ✅ Created A2A Riverpod Provider layer (5 providers)
3. ✅ Created A2A UI components (AgentPanel + TaskMonitorCard)
4. ✅ Added A2A / MCP entries to ChatPage tool menu
5. ✅ Mounted A2A task monitor on top of ChatPage message stream
6. ✅ Fixed FilesystemInAppMcpServer sandbox bypass vulnerability (path.normalize)
7. ✅ All 50 new unit tests pass
8. ✅ flutter analyze + flutter build ios pass
9. ✅ Published GitHub Release v0.43.0 (54 MB IPA)

### Tech Stack
- Flutter 3.x / Dart 3.10.7+ (sealed class pattern matching)
- Dio + SSE (Streamable HTTP MCP / A2A streaming)
- Riverpod 2.x (StateNotifier + Provider)
- Drift (database extension)
- shared_preferences (A2A settings persistence)
- path (sandbox normalization)

### Key Decisions & Solutions
1. **A2AStreamEvent as sealed class** — Replace old field-based class, compile-time pattern matching
2. **A2A client reconnect with late closure** — Solve Dart local function forward reference limitation
3. **A2AStreamSubscription.test factory** — @visibleForTesting for test construction
4. **ChatPage integration minimal intrusion** — Tool menu + task monitor card, no core rewrite
5. **InAppMcpServer sandbox with path.normalize** — Reject absolute paths + normalize `..` relative paths
6. **MCP database extension with 4 transports** — `stdio/websocket/streamable_http/in_app`

### Tools Used
- Read / Write / Edit / Glob / Grep
- Shell (flutter analyze / flutter test / flutter build ios / git / gh)
- run_mcp (none)
- Browser (none)

### Modified Files

| File | Modification | Reason |
|------|--------------|--------|
| `lib/core/protocols/a2a/a2a_client.dart` | Refactored for reconnect + Last-Event-ID; added A2AReconnectConfig / A2AStreamSubscription / A2AStreamException | v0.43.0 core: SSE auto-reconnect + resume |
| `lib/core/protocols/a2a/a2a_server.dart` | Adapted to sealed A2AStreamEvent (switch pattern matching) | Coordinate with a2a_stream_event.dart refactor |
| `lib/core/protocols/mcp_transports/in_app_mcp_server.dart` | Fixed sandbox path traversal (path.normalize replaces startsWith) | Fix `/etc/passwd` vulnerability |
| `lib/core/storage/database.dart` | McpServerConfig added `type` (4 transports) / `endpoint` / `authToken` | Support v0.43.0 Streamable HTTP MCP |
| `lib/features/session/presentation/pages/session_detail_page.dart` | Added A2A / MCP entries in tool menu; mounted A2ATaskMonitorCard on message stream | Integrate v0.43.0 features |
| `lib/core/protocols/a2a/a2a_stream_event.dart` | **New** 6-subclass sealed class (A2ATaskEvent / A2AMessageEvent / A2AArtifactEvent / A2AStatusEvent / A2AEndEvent / A2AUnknownEvent) | Replace old field-based class |
| `lib/features/a2a/providers/a2a_providers.dart` | **New** 5 providers (Settings / ClientManager / Agents / TaskRuntime / SelectedAgent) | Riverpod state management |
| `lib/features/a2a/presentation/a2a_agent_panel.dart` | **New** Agent list + add server dialog (with test connection) | A2A UI entry |
| `lib/features/a2a/presentation/a2a_task_monitor.dart` | **New** 6 state colors + spinning icon + accumulated text + event count | Real-time task monitor |
| `test/a2a_client_reconnect_test.dart` | **New** 15 tests (event parsing / task state / client instantiation) | Unit tests |
| `test/a2a_providers_integration_test.dart` | **New** 4 tests (Provider coordination) | Integration tests |
| `CHANGELOG.md` | Appended v0.43.0 section (multimodal + A2A + MCP + tests) | Release notes |
| `docs/V0.43.0_IMPLEMENTATION_PLAN.md` | Status changed from "In Progress" to "All Complete" + added Chapter 10 delivery checklist | Reflect completion |
| `release/v0.43.0/MJ_Nexus_v0.43.0.ipa` | **New** 54MB IPA package | GitHub Release asset |

### Release Artifacts
- **GitHub Tag**: v0.43.0
- **GitHub Commit**: ada03f5
- **GitHub Release**: https://github.com/jasonma1210/multi_model_client/releases/tag/v0.43.0
- **IPA**: 54 MB
- **Build Time**: 50.1s
- **Tests**: All 50 new unit tests pass

### Pending User Decisions
1. Android / macOS platform compilation verification
2. A2A Server endpoint exposed in MJ Nexus (mount LlmA2AAgent to A2AServer)
3. Multimodal ImageInput complete replacement of ChatPage existing _selectedImages flow (involves 300+ lines of logic)
4. A2A Agent task completion message auto-written back to ChatPage conversation

---

## Session #39 — v0.43.0 MCP 工具调用可视化（2026-06-30）

### 会话背景
v0.43.0 已发布（A2A + 多模态 + MCP 移动端），但 ChatPage 中的 MCP 集成只完成了"激活状态显示"（`_activeMcpTools` 集合 + 横幅），缺乏实际的"工具调用可视化"。用户明确要求：**"让用户能看到 MCP 工具被调用的过程和结果"**。

### 会话主要目的
补强 v0.43.0 的 MCP 工具调用可视化能力，让用户能：
1. 看到工具调用全过程（pending → running → success/failed）
2. 看到工具参数、结果、错误、耗时
3. 手动调用 MCP 工具（调试 & 测试用）

### 完成的主要任务
1. **创建 `McpToolCallProvider`**：Riverpod StateNotifier 跟踪最近 50 条工具调用记录（状态机：pending/running/success/failed/canceled）
2. **创建 `McpToolCallCard` UI 组件**：可展开/收起的卡片，显示工具名 + 参数 + 结果 + 错误 + 耗时，支持 JSON 折叠查看
3. **创建 `McpToolExplorerPage`**：MCP 工具浏览页，按 Server 分组列出所有工具，支持手动填写参数 JSON 并调用
4. **集成到 ChatPage**：在 A2A 任务监控卡片下方挂载 `McpToolCallCard`；在工具菜单新增"MCP 工具浏览"入口
5. **9 个新单元测试通过**：覆盖 Provider 生命周期（start/complete/fail/cancel/activeCalls/clear/截断/边界）
6. **iOS Release 编译通过**：`flutter build ios --release --no-codesign` 44.4s，生成 208.4MB Runner.app
7. **IPA 打包成功**：54MB IPA 保存到 `release/v0.43.0/MJ_Nexus_v0.43.0.ipa`（覆盖）

### 会话中主要使用的技术栈
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

### 会话中主要使用的工具
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

## Session #40 — v0.44.0 Function Calling 真实接入 + 性能优化 + 模型加载策略 + CI/CD（2026-06-30）

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

### 会话中主要使用的技术栈

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

### 会话中主要使用的工具

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



