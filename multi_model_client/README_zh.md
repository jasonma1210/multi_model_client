# MJ Nexus - 多模态 AI 助手

<p align="center">
  <img src="assets/mj_nexus_logo.png" width="120" alt="MJ Nexus Logo"/>
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README_zh.md">简体中文</a>
</p>

---

**MJ Nexus** 是一款功能强大的跨平台（iOS / Android / macOS）本地 AI 助手应用，支持本地与远程大语言模型、实时语音对话、RAG 知识库检索、记忆引擎和多模态推理能力。

## ✨ 核心特性

### 🤖 多模型支持
- **本地模型**：支持 GGUF 格式模型，通过 llama.cpp FFI 直接加载运行
- **远程模型**：兼容 OpenAI / Anthropic / Ollama API
- **多模态模型**：支持 Qwen2-VL、LLaVA 等视觉语言模型，自动下载 mmproj 投影仪
- **模型市场**：内置热门模型推荐，支持断点续传下载

### 💬 会话管理
- **会话隔离**：每个会话拥有独立的模型、上下文、配置，互不干扰
- **文件夹管理**：支持会话分组、置顶、归档
- **会话导出**：支持导出为 Markdown 格式
- **搜索重命名**：快速搜索和重命名会话

### 🧠 记忆与知识库
- **分层记忆引擎**：瞬时 → 工作 → 长时 → 归档，智能权重衰减
- **RAG 知识库**：支持 PDF/Word/TXT/图片 OCR 文档解析，FTS+BM25 混合检索
- **语义搜索**：基于 Embedding 的向量相似度检索

### 🎤 语音对话
- **ASR 语音识别**：支持 Whisper API，本地离线方案可选
- **TTS 语音合成**：支持 OpenAI TTS API，系统 TTS
- **实时语音对话**：ASR → LLM → TTS 全链路流式交互，支持打断

### 🎨 多模态能力
- **视觉理解**：发送图片给多模态模型进行分析
- **视频理解**：支持视频文件理解与连续对话
- **OCR 识别**：集成 Google ML Kit / 系统原生 OCR

### ⚙️ 系统功能
- **数据备份**：JSON 格式导入/导出，合并/覆盖模式
- **应用锁**：PIN 码 + 生物识别（Face ID / Touch ID）
- **主题切换**：深色/浅色/系统主题
- **多语言**：中文/英文

## 🏗️ 技术架构

```
lib/
├── core/                      # 核心功能
│   ├── constants/             # 常量定义
│   ├── database/              # Drift ORM 数据库
│   ├── engines/               # 推理引擎
│   │   ├── local_ffi_engine   # llama.cpp FFI 本地推理
│   │   ├── ollama_engine     # Ollama API
│   │   └── remote_api_engine # OpenAI/Anthropic API
│   ├── providers/             # Riverpod 状态管理
│   ├── services/              # 核心服务
│   │   ├── model_download/    # 模型下载（断点续传）
│   │   ├── asr_service        # 语音识别
│   │   ├── tts_service        # 语音合成
│   │   ├── knowledge_base     # 知识库
│   │   └── memory_engine      # 记忆引擎
│   └── router/                # go_router 路由
├── features/                  # 功能模块
│   ├── session/               # 会话管理
│   ├── model/                 # 模型管理
│   ├── settings/              # 设置页面
│   └── ...
└── shared/                    # 共享组件
```

## 🛠️ 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.x |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 数据库 | Drift ORM (SQLite) |
| 本地推理 | llama.cpp FFI (llamadart) |
| 网络 | Dio |
| 后台下载 | background_downloader |
| 语音合成 | flutter_tts / Sherpa-ONNX |
| OCR | Google ML Kit / textify |

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.10.7+
- Dart SDK 3.10.7+
- Xcode (iOS 开发)
- Android Studio (Android 开发)

### 安装步骤

```bash
# 克隆项目
git clone https://github.com/your-repo/mj-nexus.git
cd mj-nexus/multi_model_client

# 安装依赖
flutter pub get

# 生成代码（Drift / Riverpod）
flutter pub run build_runner build

# 运行应用
flutter run
```

### 构建发布

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# macOS
flutter build macos --release
```

## 📱 支持的平台

- ✅ iOS 15.0+ (iPhone 8 及以上，Metal 加速)
- ✅ Android 10.0+ (arm64-v8a，Vulkan 加速)
- ✅ macOS (Apple Silicon Intel)

## 🔒 安全特性

- AES-256 数据加密存储
- API 密钥安全存储 (iOS Keychain / Android Keystore)
- 应用锁（PIN 码 + 生物识别）
- 隐私优先设计，数据仅本地存储

## 📊 性能目标

| 指标 | 目标值 |
|------|--------|
| 冷启动 | ≤ 2 秒 |
| 7B 模型加载 | ≤ 3 秒 |
| 推理速度 | ≥ 30 tokens/秒 |
| 语音延迟 | ≤ 500ms |
| 内存占用 | ≤ 1GB |

## 📄 许可证

本项目为私有项目，遵循相关开源协议。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

如有问题或建议，请联系开发团队。
