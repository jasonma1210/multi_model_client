# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**MJ Nexus** (multi_model_client/) is a cross-platform Flutter AI assistant supporting:
- Local LLM inference via llama.cpp FFI (llamadart)
- Remote model APIs (OpenAI, Anthropic, Ollama)
- Voice dialogue (ASR/TTS)
- RAG knowledge base with OCR document parsing
- Memory engine with layered storage
- MCP (Model Context Protocol) integration

## Common Commands

```bash
cd multi_model_client

# Install dependencies
flutter pub get

# Generate Drift/Riverpod code (required after DB or provider changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Run linter
flutter analyze

# Run app
flutter run

# Build release
flutter build apk --release          # Android
flutter build ios --release          # iOS
flutter build macos --release        # macOS

# Clean build (required after pubspec.yaml changes)
flutter clean && flutter pub get
```

## Architecture

```
lib/
├── core/                    # Core functionality
│   ├── engines/             # Inference engines (local_ffi, ollama, remote_api)
│   ├── services/            # 40+ services (ASR, TTS, RAG, memory, etc.)
│   ├── storage/             # Drift ORM database (database.dart)
│   ├── providers/           # Riverpod state management
│   ├── router/              # go_router navigation
│   └── ...
├── features/                # Feature modules (session, model, settings, rag, memory, mcp, av, skill, prompt, summary)
└── shared/                  # Shared components
```

## Key Patterns

- **State Management**: Riverpod with code generation (`riverpod_annotation`, `riverpod_generator`)
- **Database**: Drift ORM - table definitions in `lib/core/storage/database.dart`, generated code in `database.g.dart`
- **Inference Engines**: Pluggable architecture via `ModelInferenceEngine` interface in `lib/core/engines/`
- **Services**: Heavy business logic in `lib/core/services/` - many with async streaming for real-time features

## Important Configuration

- **pubspec.yaml**: Contains llamadart CPU variant exclusions (排除 armv9.2_1/2 due to SME instability)
- **analysis_options.yaml**: Lint configuration (some unused warnings ignored)
- **llamadart native assets**: After modifying pubspec.yaml hooks, run `flutter clean && flutter pub get`

## Platform Notes

- iOS 15.0+, Android 10.0+, macOS supported
- Local inference uses llama.cpp FFI via llamadart package
- OCR uses Google ML Kit (Android) / Vision framework (iOS)
- Background downloads via background_downloader package