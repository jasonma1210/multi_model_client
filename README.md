# MJ Nexus - Multi-Modal AI Assistant

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

---

**MJ Nexus** is a powerful cross-platform (iOS / Android / macOS) local AI assistant application with support for local and remote large language models, real-time voice dialogue, RAG knowledge base retrieval, memory engine, and multi-modal reasoning capabilities.

## ✨ Key Features

### 🤖 Multi-Model Support
- **Local Models**: GGUF format support via llama.cpp FFI direct loading
- **Remote Models**: Compatible with OpenAI / Anthropic / Ollama APIs
- **Multi-Modal Models**: Vision language models like Qwen2-VL, LLaVA with automatic mmproj projector download
- **Model Marketplace**: Built-in popular model recommendations with breakpoint resume download

### 💬 Session Management
- **Session Isolation**: Each session has independent model, context, and configuration
- **Folder Organization**: Support for session grouping, pinning, and archiving
- **Session Export**: Export sessions as Markdown format
- **Search & Rename**: Quick session search and rename functionality

### 🧠 Memory & Knowledge Base
- **Layered Memory Engine**: Instant → Working → Long-term → Archived with intelligent weight decay
- **RAG Knowledge Base**: Support for PDF/Word/TXT/image OCR document parsing, FTS+BM25 hybrid retrieval
- **Semantic Search**: Embedding-based vector similarity search

### 🎤 Voice Dialogue
- **ASR Speech Recognition**: Whisper API support, optional offline local solution
- **TTS Speech Synthesis**: OpenAI TTS API, system TTS support
- **Real-time Voice Dialogue**: Full链路 streaming interaction ASR → LLM → TTS with interruption support

### 🎨 Multi-Modal Capabilities
- **Vision Understanding**: Send images to multi-modal models for analysis
- **Video Understanding**: Video file comprehension with continuous dialogue
- **OCR Recognition**: Google ML Kit / native system OCR integration

### ⚙️ System Features
- **Data Backup**: JSON format import/export, merge/overwrite modes
- **App Lock**: PIN code + biometric (Face ID / Touch ID)
- **Theme Switching**: Dark/Light/System theme
- **Multi-language**: Chinese/English

## 🏗️ Architecture

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # Constants
│   ├── database/              # Drift ORM database
│   ├── engines/              # Inference engines
│   │   ├── local_ffi_engine  # llama.cpp FFI local inference
│   │   ├── ollama_engine     # Ollama API
│   │   └── remote_api_engine # OpenAI/Anthropic API
│   ├── providers/            # Riverpod state management
│   ├── services/             # Core services
│   │   ├── model_download/   # Model download (resume support)
│   │   ├── asr_service       # Speech recognition
│   │   ├── tts_service       # Speech synthesis
│   │   ├── knowledge_base   # Knowledge base
│   │   └── memory_engine     # Memory engine
│   └── router/               # go_router navigation
├── features/                  # Feature modules
│   ├── session/              # Session management
│   ├── model/                # Model management
│   ├── settings/             # Settings pages
│   └── ...
└── shared/                   # Shared components
```

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| State Management | Riverpod |
| Routing | go_router |
| Database | Drift ORM (SQLite) |
| Local Inference | llama.cpp FFI (llamadart) |
| Networking | Dio |
| Background Download | background_downloader |
| Speech Synthesis | flutter_tts / Sherpa-ONNX |
| OCR | Google ML Kit / textify |

## 🚀 Getting Started

### Requirements

- Flutter SDK 3.10.7+
- Dart SDK 3.10.7+
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

```bash
# Clone the project
git clone https://github.com/your-repo/mj-nexus.git
cd mj-nexus/multi_model_client

# Install dependencies
flutter pub get

# Generate code (Drift / Riverpod)
flutter pub run build_runner build

# Run the app
flutter run
```

### Building for Release

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# macOS
flutter build macos --release
```

## 📱 Supported Platforms

- ✅ iOS 15.0+ (iPhone 8+, Metal acceleration)
- ✅ Android 10.0+ (arm64-v8a, Vulkan acceleration)
- ✅ macOS (Apple Silicon & Intel)

## 🔒 Security Features

- AES-256 encrypted data storage
- Secure API key storage (iOS Keychain / Android Keystore)
- App lock (PIN code + biometrics)
- Privacy-first design, data stored locally only

## 📊 Performance Targets

| Metric | Target |
|--------|--------|
| Cold Start | ≤ 2 seconds |
| 7B Model Load | ≤ 3 seconds |
| Inference Speed | ≥ 30 tokens/sec |
| Voice Latency | ≤ 500ms |
| Memory Usage | ≤ 1GB |

## 📄 License

This is a private project following relevant open source licenses.

## 🤝 Contributing

Issues and Pull Requests are welcome!

## 📞 Contact

For questions or suggestions, please contact the development team.
