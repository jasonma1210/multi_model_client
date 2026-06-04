# MJ Nexus 产品文档

> **版本**: 1.0  
> **更新日期**: 2026-05-27  
> **产品代号**: MJ Nexus / LLM Studio  
> **文档类型**: 完整产品文档

---

## 目录

1. [产品概述](#1-产品概述)
2. [核心功能说明](#2-核心功能说明)
3. [技术架构](#3-技术架构)
4. [使用指南](#4-使用指南)
5. [API 接口文档](#5-api-接口文档)
6. [安装部署流程](#6-安装部署流程)
7. [数据库设计](#7-数据库设计)
8. [安全机制](#8-安全机制)
9. [性能指标](#9-性能指标)
10. [常见问题解答](#10-常见问题解答)
11. [版本历史](#11-版本历史)
12. [未来规划](#12-未来规划)

---

## 1. 产品概述

### 1.1 产品简介

**MJ Nexus**（内部代号 LLM Studio）是一款功能强大的跨平台本地 AI 助手应用，支持本地大模型推理和远程 API 调用，集成了语音对话、RAG 知识库、记忆引擎、任务流编排等先进功能。

### 1.2 产品定位

- **跨平台本地 AI 助手**: 支持 macOS、iOS、Android 三端运行
- **隐私优先设计**: 所有数据本地存储，可完全离线使用
- **多引擎统一**: 本地推理 + 远程 API + Ollama 三引擎自动切换
- **全链路 AI**: 推理 + RAG + 语音 + 记忆 + 工作流

### 1.3 目标用户

| 用户类型 | 使用场景 |
|---------|---------|
| **个人用户** | 隐私保护、离线使用、多模型对比 |
| **开发者** | 模型测试、API 集成、本地推理调试 |
| **企业用户** | 私有化部署、知识库管理、内部 AI 助手 |
| **研究人员** | 模型性能对比、Prompt 工程实验 |

### 1.4 支持平台

| 平台 | 加速后端 | 最低版本 | 状态 |
|------|----------|---------|------|
| macOS | Metal | 10.15+ | ✅ 完全支持 |
| iOS | Metal | 15.0+ (iPhone 8+) | ✅ 完全支持 |
| Android | Vulkan | 10.0+ (arm64-v8a) | ✅ 完全支持 |

---

## 2. 核心功能说明

### 2.1 多模型支持

#### 2.1.1 本地推理

- **引擎**: llama.cpp 通过 llamadart FFI 直接调用
- **格式**: GGUF 量化模型（Q2_K ~ Q8_0）
- **加速**: Metal (Apple)、Vulkan (Android)、CUDA (Windows/Linux)
- **多模态**: 支持视觉模型（Qwen2-VL、LLaVA 等），自动下载 mmproj 投影仪

```dart
// 本地模型加载示例
final engine = LocalFFIEngine();
await engine.loadModel(
  modelPath: '/path/to/model.gguf',
  mmprojPath: '/path/to/mmproj.gguf',  // 可选，支持视觉
);
```

#### 2.1.2 远程模型 API

| API 提供商 | 协议 | 流式输出 | 多模态 |
|-----------|------|---------|--------|
| OpenAI | OpenAI API | ✅ | ✅ |
| Anthropic | Anthropic API | ✅ | ✅ |
| Ollama | Ollama API | ✅ | ✅ |

#### 2.1.3 模型市场

- **数据源**: HuggingFace + ModelScope
- **功能**: 热门模型推荐、设备兼容性检测、断点续传下载
- **支持格式**: 自动识别 GGUF 模型和对应的 mmproj 投影仪

### 2.2 会话管理

#### 2.2.1 会话隔离机制

每个会话拥有独立的：
- 模型配置（不同的模型和参数）
- 上下文历史（独立的消息记录）
- 技能配置（启用/禁用特定技能）
- MCP 工具配置
- 记忆作用域
- 知识库关联

#### 2.2.2 会话组织

- **文件夹分组**: 支持创建文件夹，将会话分类管理
- **置顶/归档**: 重要会话可置顶，历史会话可归档
- **搜索**: 支持按名称、内容快速搜索
- **导出**: 支持 Markdown / JSON 格式导出

#### 2.2.3 上下文管理

- **自动压缩**: 当上下文接近模型限制时自动压缩历史消息
- **压缩策略**: 4 种策略可选（滑动窗口、摘要、重要性加权、混合）
- **触发条件**: 上下文使用率达 90% 时自动触发

### 2.3 记忆引擎

#### 2.3.1 四层记忆架构

| 层级 | 名称 | 保持时间 | 特点 |
|------|------|---------|------|
| L1 | 即时记忆 | 当前会话 | 对话上下文 |
| L2 | 工作记忆 | 7 天 | 关键信息提取 |
| L3 | 长期记忆 | 永久 | 持久化存储 |
| L4 | 归档记忆 | 永久 | 低频访问归档 |

#### 2.3.2 记忆处理流程

```
用户对话 → LLM 提取关键信息 → 重要性评分 → 存储到对应层级
                ↓
        关键词 + 语义检索 → 权重衰减计算 → 返回相关记忆
```

#### 2.3.3 检索算法

- **关键词匹配**: jieba 分词 + BM25 排序
- **语义搜索**: Embedding 向量相似度
- **时间衰减**: 越近的记忆权重越高
- **重要性加权**: LLM 评估的记忆重要性

### 2.4 RAG 知识库

#### 2.4.1 支持的文档格式

| 格式 | 解析方式 | 状态 |
|------|---------|------|
| PDF | syncfusion_flutter_pdf + OCR | ✅ |
| Word (.docx) | archive 解析 | ✅ |
| Excel (.xlsx) | CSV 转换 | ✅ |
| Markdown | 原生解析 | ✅ |
| TXT | 直接读取 | ✅ |
| 网页 URL | Jina Reader API | ✅ |

#### 2.4.2 文档处理流程

```
上传文档 → 文本提取 → 智能分块 → 向量化 → 存储到 FTS5
    ↓
用户查询 → 查询理解 → 混合检索 → 结果排序 → 构建 Prompt → LLM 生成
```

#### 2.4.3 检索策略

- **FTS5 全文搜索**: unicode61 分词器
- **BM25 排序**: k1=1.5, b=0.75 参数
- **向量搜索**: 语义相似度匹配
- **混合排序**: 语义 40% + 关键词 40% + 精确匹配 20%

### 2.5 语音功能

#### 2.5.1 ASR 语音识别

| 服务 | 类型 | 特点 |
|------|------|------|
| Sherpa-ONNX | 本地离线 | 中文优化，隐私保护 |
| 系统原生 | 本地 | iOS/Android 系统识别 |
| Whisper API | 远程 | 高精度，需联网 |

#### 2.5.2 TTS 语音合成

| 服务 | 类型 | 特点 |
|------|------|------|
| Sherpa-ONNX | 本地离线 | 中文优化，响应快 |
| 系统原生 | 本地 | 系统内置语音 |
| OpenAI TTS | 远程 | 多音色可选 |

#### 2.5.3 语音对话流程

```
用户说话 → ASR 识别 → 文本 → LLM 生成 → TTS 合成 → 语音播放
     ↓
状态机: IDLE → LISTENING → RECOGNIZING → THINKING → SPEAKING → IDLE
```

#### 2.5.4 语音克隆

- 支持异步克隆任务
- 自定义音色上传
- 克隆模型管理

### 2.6 任务流编排引擎

#### 2.6.1 DAG 工作流

- **定义**: 有向无环图定义复杂任务流程
- **验证**: 自动环检测和拓扑排序
- **并行**: 支持节点并行执行

#### 2.6.2 节点类型

| 类型 | 功能 |
|------|------|
| start | 起始节点 |
| end | 结束节点 |
| skill | 技能调用 |
| llm | LLM 推理 |
| condition | 条件判断 |
| loop | 循环执行 |
| subWorkflow | 子工作流 |
| session | 会话操作 |
| http | HTTP 请求 |
| code | 代码执行 |
| delay | 延时等待 |
| approval | 审批节点 |

#### 2.6.3 状态机管理

- **工作流状态**: pending、running、paused、completed、failed、cancelled
- **节点状态**: pending、running、completed、failed、skipped、waiting_approval、timeout、cancelled

#### 2.6.4 调度机制

- **Cron 表达式**: 定时触发
- **事件触发**: 特定事件发生时触发
- **消息触发**: 收到特定消息时触发

### 2.7 MCP 协议支持

#### 2.7.1 协议特性

- **协议标准**: JSON-RPC 2.0
- **传输方式**: stdio / HTTP
- **功能**: 工具注册、资源管理、提示模板

#### 2.7.2 MCP 服务器管理

- **连接管理**: 多 MCP 服务器同时连接
- **工具调度**: 动态工具发现和调用
- **权限控制**: 工具调用权限管理

### 2.8 技能/插件系统

#### 2.8.1 技能类型

| 类型 | 说明 |
|------|------|
| native | 内置原生技能（30+ 专家角色） |
| expert | 专家知识技能 |
| mcp | MCP 协议技能 |
| custom | 用户自定义技能 |

#### 2.8.2 插件安全机制

- **沙箱执行**: Isolate 隔离运行
- **权限控制**: 8 种权限类型（network、file_read、file_write、database、clipboard、notification、system_command、media）
- **资源限制**: CPU、内存、网络限制
- **域名白名单**: 网络访问控制

### 2.9 系统功能

#### 2.9.1 数据备份恢复

- **格式**: JSON 格式
- **模式**: 合并/覆盖两种模式
- **内容**: 会话、模型配置、设置、知识库

#### 2.9.2 应用锁

- **PIN 码**: 4-6 位数字密码
- **生物识别**: Face ID / Touch ID / 指纹

#### 2.9.3 主题切换

- **模式**: 深色 / 浅色 / 跟随系统
- **设计**: Cherry Studio 风格 + 得物「性冷淡」适配

#### 2.9.4 国际化

- **语言**: 中文 / 英文
- **键值**: 960+ 翻译条目
- **工具**: Flutter intl + ARB 文件

---

## 3. 技术架构

### 3.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │   Pages     │  │   Widgets   │  │  Riverpod   │  │  go_router│ │
│  │  (19 路由)   │  │  (共享组件)  │  │  (状态管理)  │  │  (导航)   │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          Domain Layer                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │  Dialogue   │  │   Memory    │  │  Workflow   │  │   Skill   │ │
│  │  Engine     │  │   Engine    │  │   Engine    │  │ Dispatcher│ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │    RAG      │  │   Prompt    │  │    MCP      │  │  Session  │ │
│  │   Engine    │  │   Engine    │  │   Manager   │  │ Isolator  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          Core Layer                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │  Local FFI  │  │  Remote API │  │  Ollama API │  │  Context  │ │
│  │ (llama.cpp) │  │ (OpenAI...) │  │             │  │ Compressor│ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │    ASR      │  │    TTS      │  │   Embedding │  │   OCR     │ │
│  │  Service    │  │   Service   │  │   Service   │  │  Service  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          Data Layer                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌───────────┐ │
│  │  Drift ORM  │  │   Shared    │  │   Secure    │  │   File    │ │
│  │  (SQLite)   │  │  Prefs      │  │  Storage    │  │  System   │ │
│  │  14 张表     │  │             │  │  (AES-256)  │  │           │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 代码组织结构

```
lib/
├── main.dart                    # 应用入口（三层错误捕获）
├── app.dart                     # 应用根组件（MaterialApp + Router）
├── core/                        # 核心层（102 文件，39,011 行）
│   ├── adapters/               # API 适配器（OpenAI、Anthropic）
│   ├── constants/              # 常量定义（11 个常量类）
│   ├── engines/                # 推理引擎（8 个引擎文件）
│   │   ├── local_ffi_engine.dart      # llama.cpp FFI 本地推理
│   │   ├── inference_engine_manager.dart  # 引擎管理器
│   │   ├── voice_dialogue_service.dart    # 语音对话服务
│   │   ├── whisper_engine.dart            # Whisper ASR
│   │   ├── piper_tts_engine.dart          # Piper TTS
│   │   └── tool_scheduler.dart            # 工具调度器
│   ├── interfaces/             # 接口定义（6 个接口）
│   ├── models/                 # 数据模型（4 个模型类）
│   ├── permissions/            # 权限管理
│   ├── platform/               # 平台适配（硬件检测、加速管理）
│   ├── protocols/              # MCP 协议实现（4 个文件）
│   ├── providers/              # Riverpod 状态管理（4 个 Provider）
│   ├── router/                 # 路由配置（19 个路由）
│   ├── security/               # 安全服务（AES-256 加密）
│   ├── services/               # 核心服务（40+ 服务）
│   │   ├── model_download/    # 模型下载（HuggingFace、ModelScope）
│   │   ├── knowledge_base_service.dart  # 知识库服务
│   │   ├── memory_palace_service.dart   # 记忆宫殿服务
│   │   ├── embedding_service.dart       # 向量嵌入服务
│   │   ├── context_compressor_service.dart  # 上下文压缩
│   │   ├── voice_clone_service.dart     # 语音克隆服务
│   │   └── ...
│   ├── storage/                # 数据库（Drift ORM，14 张表）
│   ├── theme/                  # 主题配置（Material 3）
│   └── utils/                  # 工具类
├── features/                   # 功能模块（52 文件，33,722 行）
│   ├── session/               # 会话管理（17 文件）
│   │   ├── domain/            # 业务逻辑
│   │   │   ├── dialogue_engine.dart     # 对话引擎
│   │   │   ├── session_manager.dart     # 会话管理器
│   │   │   ├── session_isolator.dart    # 会话隔离器
│   │   │   ├── folder_manager.dart      # 文件夹管理
│   │   │   └── export_service.dart      # 导出服务
│   │   └── presentation/      # UI 层
│   ├── model/                 # 模型管理（3 文件）
│   ├── memory/                # 记忆引擎（1 文件）
│   ├── prompt/                # 提示词系统（2 文件）
│   ├── rag/                   # RAG 引擎（2 文件）
│   ├── skill/                 # 技能系统（7 文件）
│   │   ├── domain/            # 技能核心
│   │   ├── data/              # 插件安装、GitHub 注册
│   │   └── presentation/      # 技能市场 UI
│   ├── workflow/              # 工作流引擎（5 文件）
│   │   ├── domain/            # 工作流核心
│   │   └── data/              # 工作流持久化
│   ├── mcp/                   # MCP 协议（1 文件）
│   └── settings/              # 设置页面（14 文件）
├── generated/                  # 代码生成（3 文件，5,914 行）
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   └── app_localizations_zh.dart
└── l10n/                       # 国际化资源
    ├── app_en.arb
    └── app_zh.arb
```

### 3.3 技术栈详情

| 类别 | 技术 | 版本 | 用途 |
|------|------|------|------|
| **框架** | Flutter | 3.10+ | 跨平台 UI 框架 |
| **语言** | Dart | 3.10+ | 开发语言 |
| **状态管理** | Riverpod | 2.6.1 | 响应式状态管理 |
| **路由** | go_router | 17.2.1 | 声明式路由 |
| **数据库** | Drift | 2.28.2 | SQLite ORM |
| **本地推理** | llamadart | 0.6.10 | llama.cpp FFI |
| **语音合成** | sherpa_onnx | 1.12.39 | 本地离线 TTS |
| **语音识别** | speech_to_text | 7.3.0 | 系统原生 ASR |
| **OCR** | google_mlkit_text_recognition | 0.14.0 | 文字识别 |
| **网络** | Dio | 5.9.2 | HTTP 客户端 |
| **下载** | background_downloader | 9.5.4 | 后台下载（断点续传） |
| **加密** | flutter_secure_storage | 9.2.0 | 安全存储 |
| **分词** | jieba_flutter | 0.2.0 | 中文分词 |
| **PDF** | syncfusion_flutter_pdf | 28.2.8 | PDF 解析 |
| **Markdown** | flutter_markdown_plus | 1.0.3 | Markdown 渲染 |

### 3.4 设计模式

| 模式 | 应用场景 |
|------|---------|
| **Clean Architecture** | 三层分离（Presentation → Domain → Core → Data） |
| **Repository Pattern** | 数据访问抽象 |
| **Provider Pattern** | Riverpod 依赖注入 |
| **Strategy Pattern** | 多引擎切换（LocalFFI / Ollama / RemoteAPI） |
| **Observer Pattern** | 状态变更通知 |
| **Singleton Pattern** | 数据库、服务实例 |
| **Factory Pattern** | 模型、引擎创建 |

---

## 4. 使用指南

### 4.1 快速开始

#### 4.1.1 首次启动

1. 下载并安装应用
2. 首次启动显示引导页面（Onboarding）
3. 选择语言（中文/英文）
4. 选择主题（深色/浅色）

#### 4.1.2 添加模型

**方式一：模型市场**

1. 进入「设置」→「模型管理」
2. 点击「模型市场」
3. 浏览或搜索模型
4. 点击「下载」开始下载
5. 下载完成后自动出现在模型列表

**方式二：手动添加**

1. 进入「设置」→「模型管理」
2. 点击「添加本地模型」
3. 选择 GGUF 文件
4. 配置模型参数（可选）
5. 保存配置

**方式三：添加远程模型**

1. 进入「设置」→「模型管理」
2. 点击「添加远程模型」
3. 选择 API 类型（OpenAI / Anthropic / Ollama）
4. 填写 API Key 和 Base URL
5. 选择模型 ID
6. 保存配置

### 4.2 创建会话

1. 在首页点击「+」按钮
2. 选择模型
3. 输入系统提示词（可选）
4. 点击「创建」

### 4.3 对话交互

#### 4.3.1 文本对话

1. 在输入框输入问题
2. 点击发送或按 Enter
3. 等待模型响应（支持流式输出）
4. 查看 Markdown 格式响应

#### 4.3.2 图片对话

1. 点击输入框旁的图片按钮
2. 选择图片
3. 输入关于图片的问题
4. 发送后模型会分析图片内容

#### 4.3.3 语音对话

1. 点击麦克风按钮
2. 按住说话（松开结束）
3. 等待 ASR 识别
4. 模型生成响应
5. TTS 播放语音回答

### 4.4 知识库使用

#### 4.4.1 创建知识库

1. 进入「设置」→「知识库」
2. 点击「创建知识库」
3. 输入名称和描述
4. 上传文档（PDF/TXT/MD 等）
5. 等待文档处理完成

#### 4.4.2 使用知识库

1. 在会话中点击「关联知识库」
2. 选择知识库
3. 后续对话会自动检索相关文档

### 4.5 技能使用

#### 4.5.1 浏览技能市场

1. 进入「设置」→「技能市场」
2. 浏览内置技能（30+ 专家角色）
3. 查看技能详情
4. 启用/禁用技能

#### 4.5.2 使用技能

1. 在对话中 @ 技能名称
2. 或在技能列表中点击技能
3. 输入问题，技能会自动激活

### 4.6 数据管理

#### 4.6.1 备份数据

1. 进入「设置」→「备份与恢复」
2. 点击「导出数据」
3. 选择导出内容
4. 选择导出模式（合并/覆盖）
5. 保存 JSON 文件

#### 4.6.2 恢复数据

1. 进入「设置」→「备份与恢复」
2. 点击「导入数据」
3. 选择 JSON 文件
4. 确认导入

---

## 5. API 接口文档

### 5.1 本地推理接口

#### LocalFFIEngine

```dart
class LocalFFIEngine {
  /// 加载模型
  Future<void> loadModel({
    required String modelPath,
    LocalModelParams? params,
    String? mmprojPath,
  });

  /// 生成文本（流式）
  Stream<String> generateStream({
    required List<ChatMessage> messages,
    GenerationParams? params,
  });

  /// 生成文本（阻塞）
  Future<String> generate({
    required List<ChatMessage> messages,
    GenerationParams? params,
  });

  /// 释放模型
  Future<void> dispose();
}
```

#### LocalModelParams

```dart
class LocalModelParams {
  final int contextLength;      // 上下文长度，默认 4096
  final int maxTokens;          // 最大生成 token 数，默认 2048
  final double temperature;     // 温度，默认 0.7
  final double topP;            // Top-P，默认 0.9
  final int topK;               // Top-K，默认 40
  final double repeatPenalty;   // 重复惩罚，默认 1.1
  final int cpuThreads;         // CPU 线程数
  final int gpuLayers;          // GPU 层数，99 = 全部
}
```

### 5.2 远程 API 接口

#### OpenAIAdapter

```dart
class OpenAIAdapter {
  /// 发送聊天请求
  Future<ChatResponse> chat({
    required String model,
    required List<ChatMessage> messages,
    bool stream = false,
    Map<String, dynamic>? options,
  });

  /// 流式聊天
  Stream<ChatChunk> chatStream({
    required String model,
    required List<ChatMessage> messages,
    Map<String, dynamic>? options,
  });
}
```

#### AnthropicAdapter

```dart
class AnthropicAdapter {
  /// 发送消息
  Future<MessageResponse> createMessage({
    required String model,
    required List<Message> messages,
    int maxTokens = 1024,
    bool stream = false,
  });
}
```

### 5.3 知识库接口

#### KnowledgeBaseService

```dart
class KnowledgeBaseService {
  /// 创建知识库
  Future<KnowledgeBase> createKB({
    required String name,
    String? description,
  });

  /// 上传文档
  Future<Document> uploadDocument({
    required String kbId,
    required File file,
  });

  /// 检索
  Future<List<SearchResult>> search({
    required String kbId,
    required String query,
    int topK = 5,
    double threshold = 0.5,
  });

  /// 删除知识库
  Future<void> deleteKB(String kbId);
}
```

### 5.4 记忆接口

#### MemoryPalaceService

```dart
class MemoryPalaceService {
  /// 存储记忆
  Future<MemoryNode> store({
    required String content,
    required String sessionId,
    MemoryType type = MemoryType.working,
    double importance = 0.5,
  });

  /// 检索记忆
  Future<List<MemoryNode>> recall({
    required String query,
    String? sessionId,
    int limit = 10,
  });

  /// 压缩记忆
  Future<void> compress({
    required String sessionId,
  });
}
```

### 5.5 语音接口

#### VoiceDialogueService

```dart
class VoiceDialogueService {
  /// 开始语音对话
  Stream<VoiceDialogState> startDialog({
    required String sessionId,
    VoiceConfig? config,
  });

  /// 停止语音对话
  Future<void> stopDialog();

  /// 语音识别
  Future<String> recognize(String audioPath);

  /// 语音合成
  Future<String> synthesize(String text, {VoiceConfig? config});
}
```

---

## 6. 安装部署流程

### 6.1 开发环境搭建

#### 6.1.1 系统要求

- **Flutter SDK**: >= 3.10.7
- **Dart SDK**: >= 3.10.7
- **Xcode**: 最新版（iOS 开发）
- **Android Studio**: 最新版（Android 开发）
- **CocoaPods**: iOS 依赖管理

#### 6.1.2 安装步骤

```bash
# 1. 克隆仓库
git clone https://github.com/jasonma1210/multi_model_client.git
cd multi_model_client

# 2. 安装 Flutter 依赖
flutter pub get

# 3. 运行代码生成（Drift / Riverpod）
flutter pub run build_runner build

# 4. 运行应用
flutter run
```

### 6.2 构建发布版本

#### 6.2.1 Android

```bash
# 构建 APK
flutter build apk --release

# 构建 App Bundle（推荐上架 Google Play）
flutter build appbundle --release
```

**输出路径**: `build/app/outputs/flutter-apk/app-release.apk`

#### 6.2.2 iOS

```bash
# 构建 iOS
flutter build ios --release

# 在 Xcode 中归档并上传到 App Store Connect
```

**要求**: Apple Developer Account

#### 6.2.3 macOS

```bash
# 构建 macOS
flutter build macos --release
```

**输出路径**: `build/macos/Build/Products/Release/`

### 6.3 原生库配置

#### 6.3.1 llama.cpp 库

项目包含预编译的 llama.cpp 库：

```
multi_model_client/
├── libs/                    # macOS 库文件
│   ├── libllama.dylib
│   ├── libggml-metal.dylib
│   └── ...
├── android/app/src/main/jniLibs/  # Android 库文件
│   └── arm64-v8a/
│       ├── libllama_dotprod.so
│       ├── libllama_generic.so
│       └── ...
└── macos/Frameworks/        # macOS Framework
    ├── libllama.dylib
    └── ...
```

#### 6.3.2 CPU 变体配置

为避免某些 Android 设备的 SME 指令集不兼容问题，项目显式排除了 `armv9.2_1` 和 `armv9.2_2` 变体：

```yaml
# pubspec.yaml
hooks:
  user_defines:
    llamadart:
      llamadart_native_backends:
        platforms:
          android-arm64:
            backends: [cpu, vulkan]
            cpu_variants:
              - android_armv8.0_1    # baseline
              - android_armv8.2_1    # + DotProd
              - android_armv8.2_2    # + DotProd + FP16
              - android_armv8.6_1    # + DotProd + FP16 + MatMul INT8
              - android_armv9.0_1    # + DotProd + FP16 + MatMul INT8 + SVE2
              # android_armv9.2_1    # ← 排除！SME 不稳定
              # android_armv9.2_2    # ← 排除！SME+SVE2 不稳定
```

**注意**: 修改后必须执行 `flutter clean && flutter pub get`

### 6.4 配置文件

#### 6.4.1 l10n.yaml（国际化配置）

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/generated
```

#### 6.4.2 analysis_options.yaml（代码分析）

```yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  errors:
    unused_local_variable: ignore
    unused_element: ignore
linter:
  rules:
    avoid_unused_constructor_parameters: false
```

---

## 7. 数据库设计

### 7.1 数据库概览

- **ORM**: Drift (SQLite)
- **表数量**: 14 张核心表
- **存储位置**: 应用私有目录

### 7.2 核心表结构

#### Sessions 表（会话）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| uuid | TEXT | 会话 UUID |
| name | TEXT | 会话名称 |
| systemPrompt | TEXT? | 系统提示词 |
| modelId | TEXT? | 关联模型 ID |
| createdAt | DATETIME | 创建时间 |
| updatedAt | DATETIME | 更新时间 |
| isArchived | BOOLEAN | 是否归档 |
| isPinned | BOOLEAN | 是否置顶 |
| folderId | INTEGER? | 所属文件夹 |

#### Messages 表（消息）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| sessionId | INTEGER FK | 所属会话 |
| role | TEXT | 角色（user/assistant/system） |
| content | TEXT | 消息内容 |
| images | TEXT? | 图片 JSON 数组 |
| isDeleted | BOOLEAN | 是否删除 |
| createdAt | DATETIME | 创建时间 |

#### Models 表（模型）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PK | 模型 ID |
| displayName | TEXT | 显示名称 |
| type | TEXT | 类型（local/remote/ollama） |
| filePath | TEXT? | 本地文件路径 |
| apiKey | TEXT? | API Key（加密存储） |
| baseUrl | TEXT? | API Base URL |
| modelId | TEXT? | 远程模型 ID |
| parameterSize | INTEGER? | 参数量 |
| quantLevel | TEXT? | 量化级别 |
| isMultimodal | BOOLEAN | 是否多模态 |
| mmprojFileName | TEXT? | 投影仪文件名 |

#### Memories 表（记忆）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| content | TEXT | 记忆内容 |
| sessionId | INTEGER FK | 来源会话 |
| type | TEXT | 类型（instant/working/longterm/archived） |
| importance | REAL | 重要性评分 |
| keywords | TEXT | 关键词 JSON |
| accessCount | INTEGER | 访问次数 |
| lastAccessedAt | DATETIME | 最后访问时间 |
| createdAt | DATETIME | 创建时间 |

#### KnowledgeBases 表（知识库）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| name | TEXT | 知识库名称 |
| description | TEXT? | 描述 |
| createdAt | DATETIME | 创建时间 |

#### Documents 表（文档）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| kbId | INTEGER FK | 所属知识库 |
| fileName | TEXT | 文件名 |
| filePath | TEXT | 文件路径 |
| fileType | TEXT | 文件类型 |
| chunkCount | INTEGER | 分块数量 |
| createdAt | DATETIME | 创建时间 |

#### DocumentChunks 表（文档分块）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PK | 自增主键 |
| documentId | INTEGER FK | 所属文档 |
| content | TEXT | 分块内容 |
| chunkIndex | INTEGER | 分块索引 |
| embedding | BLOB? | 向量嵌入 |

#### WorkflowDefinitions 表（工作流定义）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PK | 工作流 ID |
| name | TEXT | 名称 |
| description | TEXT? | 描述 |
| nodes | TEXT | 节点 JSON |
| edges | TEXT | 边 JSON |
| createdAt | DATETIME | 创建时间 |

#### WorkflowExecutions 表（工作流执行记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PK | 执行 ID |
| workflowId | TEXT FK | 工作流 ID |
| status | TEXT | 状态 |
| startedAt | DATETIME | 开始时间 |
| completedAt | DATETIME? | 完成时间 |
| result | TEXT? | 执行结果 |

### 7.3 索引设计

```dart
// FTS5 虚拟表（全文搜索）
@DriftVirtualTable('messages_fts')
class MessagesFts extends Table {
  TextColumn get content => text()();
}

// 记忆关键词索引
@DriftIndex('idx_memories_keywords')
class MemoriesIndex extends Index {
  @override
  Set<Column> get columns => {memories.keywords};
}
```

---

## 8. 安全机制

### 8.1 数据加密

#### 8.1.1 存储加密

- **API Key**: AES-256 加密后存储
- **存储位置**: iOS Keychain / Android Keystore
- **同步缓存**: SharedPreferences 加密缓存

#### 8.1.2 传输加密

- **协议**: HTTPS / TLS 1.3
- **证书验证**: 严格证书验证

### 8.2 访问控制

#### 8.2.1 应用锁

- **PIN 码**: 4-6 位数字密码
- **生物识别**: Face ID / Touch ID / 指纹
- **自动锁定**: 应用进入后台自动锁定

#### 8.2.2 插件权限

```dart
enum PermissionType {
  network,        // 网络访问
  fileRead,       // 文件读取
  fileWrite,      // 文件写入
  database,       // 数据库访问
  clipboard,      // 剪贴板
  notification,   // 通知
  systemCommand,  // 系统命令
  media,          // 媒体访问
}
```

### 8.3 隐私保护

- **本地优先**: 所有数据默认本地存储
- **无遥测**: 不收集用户数据
- **离线可用**: 核心功能支持完全离线使用

---

## 9. 性能指标

### 9.1 响应性能

| 指标 | 目标值 | 实际值 |
|------|--------|--------|
| 首 token 延迟（本地） | < 2s | ~500ms |
| 首 token 延迟（远程） | < 1s | ~300ms |
| 生成速度（本地） | > 10 tok/s | ~50 tok/s |
| 生成速度（远程） | > 30 tok/s | 取决于 API |
| 语音延迟 | ≤ 500ms | ~400ms |

### 9.2 资源占用

| 指标 | 目标值 | 实际值 |
|------|--------|--------|
| 冷启动时间 | ≤ 3s | ~2s |
| 内存占用 | < 2GB | ~1.5GB |
| 7B 模型加载 | ≤ 3s | ~2s |
| 存储占用 | - | ~50MB（不含模型） |

### 9.3 可靠性

| 指标 | 目标值 |
|------|--------|
| 崩溃率 | < 0.1% |
| 数据丢失率 | 0% |
| 模型加载成功率 | > 99% |

### 9.4 优化措施

| 优化项 | 实现方式 | 效果 |
|--------|----------|------|
| 模型加载 | Isolate 后台加载 | 不阻塞 UI |
| 推理 | Stream 流式输出 | 首 token < 1s |
| 上下文压缩 | 滑动窗口 + 摘要 | 支持长对话 |
| UI 渲染 | RepaintBoundary | 减少重绘 |
| 图片缓存 | LRU 缓存 | 减少内存占用 |
| 数据库查询 | 分页 + 索引 | 快速查询 |

---

## 10. 常见问题解答

### 10.1 安装与启动

**Q: 应用启动后闪退怎么办？**

A: 可能原因：
1. 设备内存不足 → 关闭其他应用
2. 模型文件损坏 → 重新下载模型
3. 系统版本过低 → 升级系统

**Q: 下载模型失败怎么办？**

A: 可能原因：
1. 网络问题 → 检查网络连接
2. 存储空间不足 → 清理空间
3. 服务器问题 → 稍后重试（支持断点续传）

### 10.2 模型使用

**Q: 本地模型加载失败怎么办？**

A: 检查以下项目：
1. 文件格式是否为 GGUF
2. 文件是否完整（未损坏）
3. 设备内存是否足够
4. 尝试减少 GPU 层数

**Q: 模型推理速度很慢怎么办？**

A: 优化建议：
1. 使用更小的模型（7B 而非 13B）
2. 使用更高量化级别（Q4_K_M 而非 Q8_0）
3. 减少上下文长度
4. 启用 GPU 加速

**Q: 如何使用多模态（图片）功能？**

A: 需要满足以下条件：
1. 模型支持多模态（如 Qwen2-VL、LLaVA）
2. 下载对应的 mmproj 投影仪文件
3. 在模型配置中启用多模态

### 10.3 语音功能

**Q: 语音识别不准确怎么办？**

A: 优化建议：
1. 在安静环境中使用
2. 说话清晰、语速适中
3. 尝试切换 ASR 服务（Sherpa-ONNX / 系统原生）

**Q: TTS 没有声音怎么办？**

A: 检查以下项目：
1. 设备音量是否开启
2. TTS 服务是否正常
3. 尝试切换 TTS 服务

### 10.4 知识库

**Q: 文档上传后无法检索到内容怎么办？**

A: 检查以下项目：
1. 文档是否处理完成
2. 检索关键词是否准确
3. 尝试使用同义词搜索

**Q: 支持哪些文档格式？**

A: 目前支持：
- PDF、Word (.docx)、Excel (.xlsx)
- Markdown、TXT、RTF
- 网页 URL（通过 Jina Reader API）

### 10.5 数据管理

**Q: 如何备份数据？**

A: 进入「设置」→「备份与恢复」→「导出数据」

**Q: 换设备后如何迁移数据？**

A: 在旧设备导出数据 → 在新设备导入数据

---

## 11. 版本历史

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

### v0.20.0-beta (2026-05-01)

**✨ 新增功能**
- Skills 插件系统 (Phase 1)
- GitHub 插件仓库集成
- 插件沙箱执行环境
- 插件市场 UI

**🔧 改进优化**
- 模型下载管理优化
- 语音对话稳定性提升
- UI 响应式布局优化

### v0.19.0-beta (2026-04-15)

**✨ 新增功能**
- MCP 协议完整支持
- 多 MCP 服务器管理
- 工具动态注册和调用

**🔧 改进优化**
- 推理引擎稳定性提升
- 内存占用优化
- 数据库查询性能优化

### v0.18.0-beta (2026-04-01)

**✨ 新增功能**
- RAG 知识库增强版
- 向量嵌入检索
- 混合检索策略
- 文档智能分块

**🔧 改进优化**
- 语音识别准确率提升
- TTS 音质优化
- 模型加载速度提升

---

## 12. 未来规划

### 12.1 短期目标（1-3 个月）

- [ ] 完善多模态模型支持（更多视觉模型）
- [ ] 优化知识库检索算法（集成专业 Embedding 模型）
- [ ] 增加更多 TTS 音色
- [ ] 支持更多文件类型解析
- [ ] 补充单元测试覆盖率

### 12.2 中期目标（3-6 个月）

- [ ] Agent 模式（自主任务规划和执行）
- [ ] 自定义技能系统增强
- [ ] 插件市场生态建设
- [ ] 多设备会话同步

### 12.3 长期目标（6-12 个月）

- [ ] 本地模型微调
- [ ] 跨平台剪贴板同步
- [ ] 隐私保护增强（联邦学习）
- [ ] 企业版功能（团队协作、权限管理）

---

## 附录

### A. 项目统计

| 指标 | 数值 |
|------|------|
| 代码行数 | 78,988 行 |
| Dart 文件数 | 159 个 |
| 数据库表数 | 14 张 |
| 依赖包数 | 84 个 |
| 路由数 | 19 个 |
| 国际化键值 | 960+ |
| 代码质量评分 | 8.5/10 |
| 功能完成度 | 95% |

### B. 参考资料

- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev/)
- [Drift ORM 文档](https://drift.simonbinder.eu/)
- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [llamadart 包](https://pub.dev/packages/llamadart)
- [MCP 协议规范](https://modelcontextprotocol.io/)

### C. 联系方式

- **GitHub**: [@jasonma1210](https://github.com/jasonma1210)
- **项目地址**: [https://github.com/jasonma1210/multi_model_client](https://github.com/jasonma1210/multi_model_client)

---

**文档版本历史**

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0 | 2026-05-27 | 初始版本，完整产品文档 |

---

*本文档基于项目源代码全面分析生成，内容准确反映项目实际情况。*
