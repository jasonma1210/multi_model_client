# 项目实施概览

**文档版本：** 1.0
**创建日期：** 2026-04-09
**项目：** Multi-Model Client

---

## 1. 项目概述

Multi-Model Client 是一款跨平台（iOS/Android/macOS/Windows）的智能对话助手，采用 Flutter + Dart 开发，支持本地大语言模型（gguf格式）和云端API（OpenAI/Anthropic等）。

**技术栈：**
- **框架**：Flutter 3.x
- **语言**：Dart 3.x
- **架构**：Clean Architecture + Feature-First
- **状态管理**：Riverpod
- **数据库**：Drift ORM + SQLite
- **本地模型**：llama.cpp (FFI绑定)

---

## 2. 核心功能模块

### 2.1 功能模块列表

| 模块 | 功能 | 状态 | 优先级 |
|:---|:---|:---:|:---:|
| **多模型管理** | 本地gguf模型加载、云端API接入、模型下载 | ✅ | P0 |
| **会话隔离** | 会话绝对隔离、生命周期管理、文件夹分类 | ✅ | P0 |
| **系统提示词** | 全局/会话级提示词、模板库、动态变量 | ✅ | P1 |
| **记忆引擎** | 四层记忆架构（瞬时/工作/短期/长期） | ✅ | P1 |
| **RAG引擎** | 知识库管理、文档解析、向量化检索 | ✅ | P1 |
| **MCP工具** | MCP 1.0协议支持、内置6个MCP服务器 | ✅ | P1 |
| **音视频交互** | ASR语音识别、TTS语音合成、语音对话 | ⚠️ | P2 |
| **内容总结** | URL解析、主流平台解析、多模式总结 | ✅ | P2 |
| **系统设置** | 数据管理、界面配置、权限管理 | ✅ | P1 |

### 2.2 架构设计

```
lib/
├── core/                    # 核心层（18个子模块）
│   ├── adapters/           # API适配器（OpenAI/Anthropic）
│   ├── engines/            # 核心引擎（LLM/TTS/Whisper）
│   ├── interfaces/         # 接口定义
│   ├── models/             # 数据模型
│   ├── platform/           # 平台相关（硬件检测/加速）
│   ├── protocols/          # 协议实现（MCP）
│   ├── services/           # 业务服务
│   └── storage/            # 数据存储（Drift/SQLite）
│
├── features/                # 功能模块（9个）
│   ├── av/                # 音视频
│   ├── memory/            # 记忆引擎
│   ├── model/             # 模型管理
│   ├── prompt/            # 提示词
│   ├── rag/               # RAG检索
│   ├── session/           # 会话管理
│   ├── settings/          # 设置
│   ├── skill/             # 技能插件
│   └── summary/           # 内容摘要
│
└── shared/                  # 共享组件
```

---

## 3. 项目统计

### 3.1 代码统计

| 指标 | 数量 |
|:---|:---:|
| 总源文件 | 74个 Dart文件 |
| 总代码量 | ~30,000行 |
| 测试文件 | 10个 |
| 文档文件 | 83个 |

### 3.2 目录结构

```
multi_model_client/
├── lib/                    # 源代码
│   ├── core/              # 核心层
│   ├── features/          # 功能模块
│   └── shared/            # 共享组件
├── test/                  # 单元测试
├── docs/                  # 文档
├── macos/                 # macOS原生代码
├── ios/                   # iOS原生代码
├── android/               # Android原生代码
└── scripts/               # 构建脚本
```

---

## 4. 平台支持

| 平台 | 支持状态 | 完成度 | 硬件加速 |
|:---|:---:|:---:|:---|
| macOS | ✅ 完整支持 | 100% | Metal |
| iOS | ✅ 框架就绪 | 85% | Metal |
| Android | ⚠️ 基础支持 | 70% | NNAPI |
| Windows | ⚠️ 部分支持 | 60% | CUDA |

---

## 5. 依赖包

### 5.1 核心依赖

| 包名 | 版本 | 用途 |
|:---|:---:|:---|
| flutter_riverpod | ^2.4.0 | 状态管理 |
| drift | ^2.14.0 | 数据库ORM |
| sqlite3_flutter_libs | ^0.5.18 | SQLite支持 |
| go_router | ^13.0.0 | 路由导航 |
| dio | ^5.4.0 | HTTP客户端 |
| path_provider | ^2.1.0 | 文件路径 |
| flutter_secure_storage | ^9.0.0 | 安全存储 |
| ffi | ^2.1.0 | 原生调用 |

### 5.2 UI依赖

| 包名 | 版本 | 用途 |
|:---|:---:|:---|
| flutter_markdown | ^0.6.18 | Markdown渲染 |
| flutter_tts | ^4.0.0 | 语音合成 |
| intl | ^0.18.0 | 国际化 |

---

## 6. 构建指南

### 6.1 环境要求

- Flutter SDK: 3.x
- Dart: 3.x
- Xcode: 15+ (macOS/iOS构建)
- Android Studio: 2022+ (Android构建)

### 6.2 构建命令

```bash
# 获取依赖
flutter pub get

# 分析代码
flutter analyze

# 运行测试
flutter test

# 构建macOS
flutter build macos

# 构建iOS模拟器
flutter build ios --simulator --no-codesign

# 构建Android
flutter build apk --debug
```

---

## 7. 已知限制

1. **iOS真机测试**：需要Apple Developer账号和真机
2. **Windows CUDA**：需要NVIDIA显卡和CUDA Toolkit
3. **Android NNAPI**：部分设备可能不支持
4. **本地模型**：需要下载gguf格式模型文件

---

## 8. 后续开发计划

### 8.1 短期计划（1-2周）
- 完善单元测试（覆盖率60%+）
- 性能优化（推理速度≥30 tok/s）
- 用户文档完善

### 8.2 中期计划（1-3个月）
- iOS真机测试和优化
- Android完整支持
- 语音对话功能完善

### 8.3 长期计划（3-6个月）
- 视频理解功能
- 插件市场
- 企业版功能

---

## 9. 贡献指南

欢迎提交Pull Request！请参考：
- `docs/06_dev_guides/CONTRIBUTION_GUIDE.md`
- `docs/06_dev_guides/CODING_STANDARDS.md`

---

## 10. 许可证

本项目仅供学习和研究使用。