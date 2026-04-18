# Multi-Model Client

A multi-platform LLM client with session isolation, memory engine, RAG, and full-modal interaction.

## Project Overview

This project is a comprehensive mobile application that supports iOS and Android platforms, providing:

- Multi-model management (local and remote)
- Session isolation
- System prompt management
- Intelligent content summarization
- Strong memory engine
- RAG (Retrieval Augmented Generation)
- Skills plugin system
- Multi-modal audio/video interaction

## Architecture

The project follows Clean Architecture principles with the following structure:

```
lib/
├── core/               # Core functionality
│   ├── constants/      # Application constants
│   ├── storage/        # Database and storage
│   ├── network/        # Network layer
│   ├── router/         # Navigation
│   ├── theme/          # Theming
│   └── utils/          # Utilities
├── features/           # Feature modules
│   ├── session/        # Session management
│   ├── model/          # Model management
│   ├── prompt/         # System prompts
│   ├── summary/        # Content summarization
│   ├── memory/         # Memory engine
│   ├── rag/            # RAG engine
│   ├── skill/          # Skills/Plugins
│   ├── av/             # Audio/Video
│   └── settings/       # Settings
├── shared/             # Shared components
│   ├── widgets/        # Reusable widgets
│   ├── extensions/     # Extensions
│   └── mixins/         # Mixins
├── app.dart            # App configuration
└── main.dart           # Entry point
```

## Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: go_router
- **Database**: SQLite with Drift ORM
- **Network**: Dio
- **Local Storage**: SharedPreferences, FlutterSecureStorage
- **Markdown**: flutter_markdown
- **Code Highlighting**: highlight

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK 3.10.7 or higher
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate database code:
   ```bash
   flutter pub run build_runner build
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Development Roadmap

### Phase 1 (Week 1-2): Requirements & Architecture
- Requirements finalization
- Technical architecture design
- Product prototype design
- Technology selection
- Development environment setup
- Task breakdown and scheduling

### Phase 2 (Week 3-4): Core Infrastructure
- Flutter framework setup
- Storage engine development
- Encryption module
- Permission management
- Model inference engine integration
- Audio/video processing engine

### Phase 3 (Week 5-8): Core Business Modules
- Session management center
- Dialogue engine
- Model management module
- URL parsing engine
- System prompt module
- Memory engine
- RAG engine
- Skills plugin engine
- MCP client
- Multi-modal interaction module

### Phase 4 (Week 7-9): UI Development & Integration
- UI design completion
- Main interface development
- Model marketplace UI
- Prompt template library
- Memory management UI
- Knowledge base management UI
- Settings UI
- Frontend-backend integration
- Onboarding flow
- Share extension development
- Device adaptation

### Phase 5 (Week 10-11): Testing & Optimization
- Full functional testing
- Bug fixes and regression
- Performance testing and optimization
- Memory leak detection
- Compatibility testing
- Security penetration testing
- Vulnerability fixes
- App store compliance adaptation

### Phase 6 (Week 12): Release & Launch
- Beta release
- User feedback collection
- Issue fixes and optimization
- App store submission preparation
- App Store publication
- Play Store publication

## Features

### Multi-Model Management
- Support for local gguf models
- Support for remote OpenAI-compatible APIs
- Model marketplace with download management
- Model capability detection

### Session Isolation
- Complete isolation between sessions
- Independent context and configuration per session
- Session templates for quick setup
- Session folders and organization

### System Prompt Management
- Global and session-level prompts
- Prompt template library
- Dynamic variables in prompts
- Real-time prompt updates

### Intelligent Content Summarization
- URL content extraction and summarization
- Platform-specific parsers (Douyin, Xiaohongshu, Bilibili, Zhihu, Weibo)
- Share extension integration
- Multiple summarization modes

### Memory Engine
- Layered memory architecture (instant, working, long-term, archived)
- Automatic memory extraction
- Memory retrieval and ranking
- Session-isolated and global memories

### RAG Engine
- Knowledge base management
- Document parsing and chunking
- Vector storage and retrieval
- Integration with dialogue engine

### Skills & Plugins
- Native built-in skills
- Custom skill definition
- MCP protocol support
- Unified tool scheduling

### Multi-Modal Interaction
- ASR (speech recognition)
- TTS (speech synthesis)
- Real-time voice dialogue
- Video understanding

## Security

- AES-256 encryption for local data
- Secure storage for API keys
- Sandboxed JavaScript execution
- Privacy-focused design

## Performance Targets

- Cold start: ≤2 seconds
- Model loading (7B): ≤3 seconds
- Inference speed: ≥30 tokens/second
- Voice dialogue latency: ≤500ms
- Memory usage: ≤1GB

## Compatibility

- iOS 15.0+
- Android 10.0+
- Support for mainstream device models
- Coverage rate ≥95%

## License

This project is private and not publicly licensed.

## Contact

For questions or issues, please contact the development team.
