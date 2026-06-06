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
