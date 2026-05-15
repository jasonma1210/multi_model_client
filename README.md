# MJ Nexus - 多模型 AI 助手

<div align="center">

**一款支持本地/远程模型的多模型 AI 助手应用**

[![Version](https://img.shields.io/badge/version-0.21.0--beta-blue.svg)](https://github.com/jasonma1210/multi_model_client/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[English](README_EN.md) | 中文

</div>

---

## 📱 项目简介

MJ Nexus 是一款功能强大的多模型 AI 助手应用，支持本地模型推理和远程 API 调用，集成了语音对话、RAG 知识库、记忆引擎等先进功能。基于 Flutter 构建，支持 Android、iOS 和 macOS 平台。

---

## ✨ 核心功能

### 🤖 多模型支持

| 功能 | 描述 |
|------|------|
| **远程 API** | OpenAI (GPT-3.5/4)、Anthropic (Claude 3.5) 等主流大模型 |
| **本地推理** | 基于 llama.cpp FFI，支持 GGUF 格式模型本地运行 |
| **模型管理** | HuggingFace / ModelScope 模型搜索、下载、断点续传 |
| **硬件适配** | 自动检测设备能力，智能配置上下文大小 |

### 💬 会话管理

- **多会话并行** — 同时管理多个独立对话
- **会话隔离机制** — 每个会话拥有独立的上下文和资源
- **上下文自动压缩** — 智能压缩历史消息，防止 token 超限
- **会话导出** — 支持 Markdown / JSON 格式导出

### 🧠 记忆引擎

- **短期记忆** — 自动提取对话关键信息
- **长期记忆** — 持久化存储，跨会话共享
- **语义检索** — 基于向量化的智能记忆检索
- **重要性评分** — 自动评估记忆权重

### 📚 RAG 知识库

- **多格式支持** — PDF、Word、Excel、Markdown、TXT
- **智能分块** — 自动文档切分和向量化
- **语义检索** — 基于 embedding 的相似度搜索
- **引用追踪** — 显示答案来源文档

### 🎙️ 语音功能

- **TTS 语音合成** — Sherpa-ONNX 本地离线 TTS，中文优化
- **ASR 语音识别** — 实时语音转文字，支持中间结果
- **语音克隆** — 异步克隆任务，自定义音色
- **语音对话** — 完整的语音交互体验

### 🔄 任务流编排

- **DAG 工作流** — 有向无环图定义复杂任务流程
- **状态机管理** — 任务状态追踪和转换
- **执行引擎** — 自动调度和执行工作流节点
- **跨会话协调** — 多会话间的任务协同

### 🔌 MCP 协议

- **JSON-RPC 2.0** — 完整的协议实现
- **工具注册** — 动态注册和调用工具
- **资源管理** — 资源注册和访问控制
- **提示模板** — 可复用的提示词系统

---

## 🛠️ 技术架构

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

## 📦 技术栈

| 类别 | 技术 |
|------|------|
| **框架** | Flutter 3.10+ / Dart 3.10+ |
| **状态管理** | Riverpod 2.x |
| **数据库** | Drift (SQLite ORM) |
| **本地推理** | llamadart (llama.cpp FFI) |
| **语音合成** | Sherpa-ONNX |
| **语音识别** | speech_to_text |
| **OCR** | Google ML Kit / Apple Vision |
| **网络** | Dio / WebSocket |
| **加密** | AES-256 / flutter_secure_storage |

---

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.10.7
- Dart SDK >= 3.10.7
- Android Studio / Xcode (根据目标平台)

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/jasonma1210/multi_model_client.git
cd multi_model_client

# 安装依赖
flutter pub get

# 运行代码生成
flutter pub run build_runner build

# 运行应用
flutter run
```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# macOS
flutter build macos --release

# iOS
flutter build ios --release
```

---

## 📂 项目结构

```
lib/
├── app.dart                    # 应用入口
├── core/                       # 核心层
│   ├── engines/               # 推理引擎
│   │   ├── local_ffi_engine.dart    # 本地 llama.cpp 引擎
│   │   ├── model_inference_engine.dart # 模型推理接口
│   │   └── voice_dialogue_service.dart # 语音对话服务
│   ├── services/              # 核心服务
│   │   ├── context_compressor_service.dart # 上下文压缩
│   │   ├── tts_service.dart          # TTS 服务
│   │   └── voice_clone_service.dart  # 语音克隆
│   ├── storage/               # 数据存储
│   │   └── database.dart           # Drift 数据库定义
│   └── platform/              # 平台适配
├── features/                  # 功能模块
│   ├── session/              # 会话管理
│   │   ├── domain/
│   │   │   ├── dialogue_engine.dart  # 对话引擎
│   │   │   └── workflow_*.dart       # 工作流引擎
│   │   └── presentation/
│   │       └── pages/               # UI 页面
│   ├── model/                # 模型管理
│   ├── settings/             # 设置
│   └── knowledge/            # 知识库
└── shared/                   # 共享组件
```

---

## 📊 版本历史

### v0.21.0-beta (2026-05-15)

**✨ 新增功能**
- 多会话隔离机制 (Phase 2)
- 任务流编排引擎 (Phase 3)
- 异步语音克隆功能
- 上下文自动压缩和系统能力检测
- 模型删除级联功能

**🔧 改进优化**
- OCR 内存优化
- 数据库分页查询
- macOS 上下文大小优化
- TTS 句子分割修复

**🐛 问题修复**
- 修复 Null check operator 崩溃
- 修复 Message.isImportant 错误
- 修复 TTS 播放不一致问题
- 修复上下文超限崩溃

[查看完整更新日志](multi_model_client/CHANGELOG.md)

---

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出建议！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

---

## 📧 联系方式

- GitHub: [@jasonma1210](https://github.com/jasonma1210)
- 项目链接: [https://github.com/jasonma1210/multi_model_client](https://github.com/jasonma1210/multi_model_client)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给个 Star 支持一下！⭐**

</div>
