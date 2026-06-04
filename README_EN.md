# MJ Nexus - Multi-Model AI Assistant

<div align="center">

**A powerful multi-model AI assistant with local/remote model support**

[![Version](https://img.shields.io/badge/version-0.35.0--beta-blue.svg)](https://github.com/jasonma1210/multi_model_client/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

English | [中文](README.md)

</div>

---

## 📱 Overview

MJ Nexus is a feature-rich multi-model AI assistant application that supports both local model inference and remote API calls. It integrates advanced features such as voice dialogue, RAG knowledge base, and memory engine. Built with Flutter, it supports Android, iOS, and macOS platforms.

---

## ✨ Core Features

### 🤖 Multi-Model Support

| Feature | Description |
|---------|-------------|
| **Remote APIs** | OpenAI (GPT-3.5/4), Anthropic (Claude 3.5), and other mainstream LLMs |
| **Local Inference** | llama.cpp FFI-based local model execution with GGUF format support |
| **Model Management** | HuggingFace / ModelScope model search, download, and resume support |
| **Hardware Adaptation** | Auto-detect device capabilities, intelligent context size configuration |

### 💬 Session Management

- **Multi-Session Parallel** — Manage multiple independent conversations simultaneously
- **Session Isolation** — Each session has independent context and resources
- **Auto Context Compression** — Smart compression of history messages to prevent token overflow
- **Session Export** — Export in Markdown / JSON formats

### 🧠 Memory Engine

- **Short-term Memory** — Auto-extract key information from conversations
- **Long-term Memory** — Persistent storage with cross-session sharing
- **Semantic Retrieval** — Vector-based intelligent memory search
- **Importance Scoring** — Automatic memory weight evaluation

### 📚 RAG Knowledge Base

- **Multi-format Support** — PDF, Word, Excel, Markdown, TXT
- **Smart Chunking** — Automatic document splitting and vectorization
- **Semantic Search** — Embedding-based similarity search
- **Citation Tracking** — Display source documents for answers

### 🎙️ Voice Features

- **TTS Synthesis** — Sherpa-ONNX local offline TTS, optimized for Chinese
- **ASR Recognition** — Real-time speech-to-text with intermediate results
- **Voice Cloning** — Async cloning tasks with custom voice tones
- **Voice Dialogue** — Complete voice interaction experience

### 🔄 Workflow Orchestration

- **DAG Workflow** — Directed Acyclic Graph for complex task definitions
- **State Machine** — Task state tracking and transitions
- **Execution Engine** — Automatic scheduling and execution of workflow nodes
- **Cross-Session Coordination** — Task collaboration across multiple sessions

### 🔌 MCP Protocol

- **JSON-RPC 2.0** — Complete protocol implementation
- **Tool Registration** — Dynamic tool registration and invocation
- **Resource Management** — Resource registration and access control
- **Prompt Templates** — Reusable prompt system

---

## 🛠️ Technical Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Pages     │ │   Widgets   │ │   State (Riverpod)      ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                    Domain Layer                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │  Dialogue   │ │   Memory    │ │   Workflow Engine        ││
│  │  Engine     │ │   Engine    │ │   (DAG + State Machine) ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                    Core Layer                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Local     │ │   Remote    │ │   Context Compressor    ││
│  │   FFI       │ │   API       │ │   + Token Estimator     ││
│  │  (llama.cpp)│ │  (OpenAI..) │ │                         ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│                    Data Layer                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐│
│  │   Drift     │ │   Shared    │ │   Secure Storage        ││
│  │   (SQLite)  │ │  Prefs      │ │   (AES-256)             ││
│  └─────────────┘ └─────────────┘ └─────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.10+ / Dart 3.10+ |
| **State Management** | Riverpod 2.x |
| **Database** | Drift (SQLite ORM) |
| **Local Inference** | llamadart (llama.cpp FFI) |
| **Text-to-Speech** | Sherpa-ONNX |
| **Speech Recognition** | speech_to_text |
| **OCR** | Google ML Kit / Apple Vision |
| **Networking** | Dio / WebSocket |
| **Encryption** | AES-256 / flutter_secure_storage |

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7
- Android Studio / Xcode (depending on target platform)

### Installation

```bash
# Clone the repository
git clone https://github.com/jasonma1210/multi_model_client.git
cd multi_model_client

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run the application
flutter run
```

### Build Release

```bash
# Android APK
flutter build apk --release

# macOS
flutter build macos --release

# iOS
flutter build ios --release
```

---

## 📂 Project Structure

```
lib/
├── app.dart                    # App entry point
├── core/                       # Core layer
│   ├── engines/               # Inference engines
│   │   ├── local_ffi_engine.dart    # Local llama.cpp engine
│   │   ├── model_inference_engine.dart # Model inference interface
│   │   └── voice_dialogue_service.dart # Voice dialogue service
│   ├── services/              # Core services
│   │   ├── context_compressor_service.dart # Context compression
│   │   ├── tts_service.dart          # TTS service
│   │   └── voice_clone_service.dart  # Voice cloning
│   ├── storage/               # Data storage
│   │   └── database.dart           # Drift database definition
│   └── platform/              # Platform adaptation
├── features/                  # Feature modules
│   ├── session/              # Session management
│   │   ├── domain/
│   │   │   ├── dialogue_engine.dart  # Dialogue engine
│   │   │   └── workflow_*.dart       # Workflow engine
│   │   └── presentation/
│   │       └── pages/               # UI pages
│   ├── model/                # Model management
│   ├── settings/             # Settings
│   └── knowledge/            # Knowledge base
└── shared/                   # Shared components
```

---

## 📊 Version History

### v0.35.0-beta (2026-06-04)

**✨ New Features**
- Real-time voice conversation page (ASR → LLM → TTS full pipeline streaming)
- Manual context compression (one-click compress all messages into a summary)
- TTS director mode prompt template system
- Voice cloning service (MIMO API integration)
- Inspiration feature (recording, ASR transcription, summary, mind map)
- Streaming TTS service (double-buffered playback, parallel synthesis and playback)
- Smart context manager (5-layer architecture)
- Model path cache service
- Document generation service (Markdown/PDF/XMind)
- 7 new professional skills (social media, concert planning, etc.)
- Log system service
- Security bookmark service (macOS sandbox)
- Plugin download service
- Voice Activity Detection (VAD) service
- Speaker diarization service
- Memory palace service & memory compression engine
- Memory retrieval service
- Media ingestion pipeline service
- Mirror service

**🔧 Improvements**
- Fixed real-time voice conversation stuck after 1 round (TTS playback state recovery, audio player reset)
- Fixed context compression summary not included in subsequent conversations
- Rewrote autoCompressContext: all messages compressed into a single summary
- Added compression summary injection logic: ensure subsequent conversations include summary and system description
- UI color system and icon system refactoring
- Expert skill icon configuration (Material Icons replacing Emoji)

**🐛 Bug Fixes**
- Fixed _speakResponse early return not restoring state causing conversation stuck
- Fixed _waitForPlaybackComplete hanging until 3-minute timeout
- Fixed audio player not stop after playback causing next round anomaly
- Fixed _processWithLLM catch block not restoring idle state
- Fixed system messages being skipped in _buildStructuredMessages and _buildStructuredMessagesWithContent

### v0.21.0-beta (2026-05-15)

**✨ New Features**
- Multi-session isolation mechanism (Phase 2)
- Workflow orchestration engine (Phase 3)
- Async voice cloning functionality
- Auto context compression and system capability detection
- Model deletion cascade feature

**🔧 Improvements**
- OCR memory optimization
- Database pagination support
- macOS context size optimization
- TTS sentence splitting fix

**🐛 Bug Fixes**
- Fixed Null check operator crash
- Fixed Message.isImportant error
- Fixed TTS playback inconsistency
- Fixed context overflow crash

[View Full Changelog](multi_model_client/CHANGELOG.md)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Create a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

---

## 📧 Contact

- GitHub: [@jasonma1210](https://github.com/jasonma1210)
- Project Link: [https://github.com/jasonma1210/multi_model_client](https://github.com/jasonma1210/multi_model_client)

---

<div align="center">

**⭐ If you find this project helpful, please give it a Star! ⭐**

</div>
