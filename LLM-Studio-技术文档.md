# LLM Studio 技术文档

> 多平台 AI 助手应用 - 技术架构与实现详解
> 
> 版本：1.0.0 | 更新日期：2026-04-21

---

## 目录

1. [项目概述](#1-项目概述)
2. [技术架构](#2-技术架构)
3. [核心模块](#3-核心模块)
4. [功能实现](#4-功能实现)
5. [数据模型](#5-数据模型)
6. [推理引擎](#6-推理引擎)
7. [服务层](#7-服务层)
8. [UI 层](#8-ui-层)
9. [性能优化](#9-性能优化)
10. [未来规划](#10-未来规划)

---

## 1. 项目概述

### 1.1 项目目标

LLM Studio 是一款多平台 AI 助手应用，支持：

- **本地大模型推理**：通过 llama.cpp FFI 直接加载 GGUF 模型
- **远程模型 API**：OpenAI、Anthropic、Ollama
- **多会话管理**：支持多个并行对话
- **知识库 RAG**：基于 FTS5 + BM25 的本地知识库检索
- **语音对话**：ASR 语音识别 + TTS 语音合成
- **多模态支持**：图片理解（需要 mmproj 投影仪）

### 1.2 支持平台

| 平台 | 加速后端 | 状态 |
|------|----------|------|
| macOS | Metal | ✅ |
| iOS | Metal | ✅ |
| Android | Vulkan | ✅ |
| Windows | CUDA/CPU | ✅ |
| Linux | CUDA/CPU | ✅ |

### 1.3 技术栈

| 层级 | 技术选型 |
|------|----------|
| 框架 | Flutter 3.x |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 数据库 | Drift (SQLite) |
| 本地推理 | llama.cpp (via llamadart) |
| 网络请求 | Dio |
| 中文分词 | jieba_flutter |

---

## 2. 技术架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI Layer                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ SessionList │  │ SessionDetail│  │  Settings   │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Provider Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ModelProvider│  │SessionProvider│ │SettingsProvider│         │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Service Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │DialogueEngine│ │RAGService   │  │VoiceService │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Inference Engine Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │LocalFFIEngine│ │OllamaEngine │  │RemoteAPIEngine│            │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Data Layer                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Drift DB   │  │SharedPrefs  │  │ File System │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用根组件
├── core/
│   ├── constants/              # 常量定义
│   ├── engines/                # 推理引擎
│   │   ├── local_ffi_engine.dart      # llama.cpp FFI 本地推理
│   │   ├── inference_engine_manager.dart  # 引擎管理器
│   │   ├── model_inference_engine.dart    # 推理引擎接口
│   │   ├── voice_dialogue_service.dart    # 语音对话服务
│   │   └── ...
│   ├── interfaces/             # 接口定义
│   ├── models/                 # 数据模型
│   │   └── model_entry.dart    # 模型实体
│   ├── network/                # 网络请求
│   ├── permissions/            # 权限管理
│   ├── platform/               # 平台相关
│   ├── providers/              # Riverpod Providers
│   │   ├── model_provider.dart      # 模型状态管理
│   │   ├── settings_provider.dart   # 设置状态管理
│   │   └── session_provider.dart    # 会话状态管理
│   ├── router/                 # 路由配置
│   ├── security/               # 安全服务
│   ├── services/               # 业务服务
│   │   ├── dialogue_engine.dart     # 对话引擎
│   │   ├── rag_service.dart         # RAG 知识库服务
│   │   ├── asr_service.dart         # 语音识别服务
│   │   ├── tts_service.dart         # 语音合成服务
│   │   ├── knowledge_base_service.dart  # 知识库服务
│   │   └── ...
│   ├── storage/                # 数据库
│   │   └── database.dart       # Drift 数据库定义
│   ├── theme/                  # 主题
│   └── utils/                  # 工具类
├── features/                   # 功能模块
│   ├── session/               # 会话功能
│   │   ├── presentation/      # UI 层
│   │   ├── domain/            # 业务逻辑
│   │   └── data/              # 数据层
│   ├── model/                 # 模型管理
│   ├── settings/              # 设置
│   └── ...
└── shared/                     # 共享组件
```

---

## 3. 核心模块

### 3.1 推理引擎架构

#### LocalFFIEngine（本地 FFI 引擎）

使用 `llamadart` 包通过 FFI 直接调用 llama.cpp：

```dart
class LocalFFIEngine {
  static final LocalFFIEngine _instance = LocalFFIEngine._();
  
  LlamaEngine? _llamaEngine;
  
  /// 加载 GGUF 模型
  Future<void> loadModel({
    required String modelPath,
    LocalModelParams? params,
    String? mmprojPath,  // 多模态投影仪
  }) async {
    _llamaEngine = LlamaEngine(LlamaBackend());
    await _llamaEngine!.loadModel(fullModelPath, modelParams: modelParams);
    
    // 加载 mmproj 投影仪（支持视觉模型）
    if (mmprojPath != null) {
      await _llamaEngine!.loadMultimodalProjector(mmprojFullPath);
    }
  }
}
```

**关键特性**：
- 使用 Isolate 避免阻塞 UI
- 支持 Metal/CUDA/Vulkan 加速
- 支持多模态（图片理解）
- 流式输出

#### InferenceEngineManager（引擎管理器）

自动选择最优推理引擎：

```dart
class InferenceEngineManager {
  // 引擎选择优先级
  // 1. LocalFFIEngine（本地 FFI）
  // 2. Ollama API（本地服务）
  // 3. RemoteAPI（远程 API）
  
  Future<void> loadModel(ModelEntry model) async {
    switch (model.type) {
      case ModelType.local:
        if (_isLocalFFISupported()) {
          await _localFFIEngine.loadModel(...);
        } else {
          // 回退到 Ollama
        }
      case ModelType.remote:
      case ModelType.ollama:
        // 使用远程 API
    }
  }
}
```

### 3.2 状态管理

使用 Riverpod 进行状态管理：

#### ModelProvider

```dart
class ModelNotifier extends StateNotifier<ModelState> {
  // 模型列表 CRUD
  Future<ModelEntry> addLocalModel({...});
  Future<ModelEntry> addRemoteModel({...});
  Future<void> removeModel(String id);
  Future<void> updateModel(ModelEntry model);
  
  // 模型持久化（SharedPreferences）
  Future<void> _persist();
}
```

#### SessionProvider

```dart
class SessionNotifier extends StateNotifier<SessionState> {
  // 会话 CRUD
  Future<Session> createSession({String? modelId, String? systemPrompt});
  Future<void> deleteSession(String id);
  Future<void> renameSession(String id, String newName);
  
  // 消息管理
  Future<void> addMessage(String sessionId, Message message);
  Future<List<Message>> getMessages(String sessionId);
}
```

### 3.3 数据库设计

使用 Drift ORM 定义数据库表：

```dart
// Sessions 表
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  TextColumn get name => text()();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get modelId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// Messages 表
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  TextColumn get role => text()();  // user/assistant/system
  TextColumn get content => text()();
  TextColumn get images => text().nullable()();  // JSON 数组
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
```

---

## 4. 功能实现

### 4.1 本地模型推理

#### 模型加载流程

```
1. 用户选择本地 GGUF 模型
2. ModelProvider 获取模型信息
3. InferenceEngineManager 选择 LocalFFIEngine
4. LocalFFIEngine.loadModel() 执行：
   a. 查找模型文件（支持递归搜索子目录）
   b. 创建 LlamaEngine 实例
   c. 加载 GGUF 模型到内存
   d. 加载 mmproj 投影仪（如果支持多模态）
   e. 检测视觉支持状态
5. 返回加载成功
```

#### 支持的文件格式

| 类型 | 扩展名 | 说明 |
|------|--------|------|
| 模型文件 | .gguf | GGUF 量化模型 |
| 投影仪 | mmproj-*.gguf | 多模态视觉投影仪 |

### 4.2 远程模型 API

#### 支持的 API

| API | 协议 | 流式 | 多模态 |
|-----|------|------|--------|
| OpenAI | OpenAI API | ✅ | ✅ |
| Anthropic | Anthropic API | ✅ | ✅ |
| Ollama | Ollama API | ✅ | ✅ |

#### 请求示例

```dart
// OpenAI API
final response = await dio.post(
  'https://api.openai.com/v1/chat/completions',
  data: {
    'model': 'gpt-4o',
    'messages': messages,
    'stream': true,
  },
  options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
);
```

### 4.3 知识库 RAG

#### 架构

```
用户查询 → 知识库检索 → 相关文档 → 构建提示词 → LLM 生成 → 返回答案
```

#### 检索算法

- **FTS5**：全文搜索，使用 unicode61 分词器
- **BM25**：关键词排序，k1=1.5, b=0.75
- **中文分词**：滑动窗口 n-gram（2-4 字）

#### 文档处理流程

```
1. 用户上传文档（PDF/TXT/MD）
2. FileParserService 解析文本
3. 文本分块（chunk）
4. 存储到 SQLite（FTS5 虚拟表）
5. 检索时使用 FTS5 + BM25 混合排序
```

### 4.4 语音对话

#### 完整链路

```
用户说话 → ASR 识别 → 文本 → LLM 生成 → TTS 合成 → 语音播放
```

#### 状态机

```
IDLE → LISTENING → RECOGNIZING → THINKING → SPEAKING → IDLE
```

#### 支持的服务

| 服务 | 功能 | 说明 |
|------|------|------|
| OpenAI Whisper | ASR | 语音识别 |
| OpenAI TTS | TTS | 语音合成 |
| System TTS | TTS | 系统语音 |

### 4.5 多模态支持

#### 实现原理

```
1. 用户上传图片
2. 将图片转为 base64
3. 写入临时文件（llamadart 需要文件路径）
4. 构建 LlamaChatMessage.withContent([
     LlamaImageContent(path: tmpPath),
     LlamaTextContent(text)
   ])
5. 发送给 llama.cpp 推理
6. 模型输出文本响应
```

#### 支持的模型类型

- **VL 模型**：内置视觉权重（Llama-Vision、Qwen2.5-VL）
- **纯文本模型 + mmproj**：Gemma 4 + mmproj 投影仪

---

## 5. 数据模型

### 5.1 ModelEntry

```dart
class ModelEntry {
  final String id;
  final String displayName;
  final ModelType type;  // local/remote/ollama
  final String? filePath;  // 本地模型文件路径
  final LocalModelParams? localParams;  // 本地推理参数
  final RemoteModelConfig? remoteConfig;  // 远程 API 配置
  final bool isLoaded;
  final int? parameterSize;
  final String? quantLevel;  // Q4_K_M, Q5_K_M, etc.
  final bool? isMultimodal;
  final String? mmprojFileName;  // 多模态投影仪文件名
}
```

### 5.2 LocalModelParams

```dart
class LocalModelParams {
  final double temperature;
  final int? maxTokens;
  final int cpuThreads;
  final int gpuLayers;  // 99 = 全部 GPU
  final int topK;
  final double repeatPenalty;
  final double topP;
  // ...
}
```

### 5.3 Message

```dart
class Message {
  final String id;
  final String sessionId;
  final String role;  // user/assistant/system
  final String content;
  final List<ImageData>? images;  // 多模态图片
  final DateTime createdAt;
}
```

---

## 6. 推理引擎

### 6.1 llama.cpp 加速后端

| 平台 | 后端 | 说明 |
|------|------|------|
| macOS | Metal | Apple Silicon GPU 加速 |
| iOS | Metal | Apple GPU 加速 |
| Android | Vulkan | Android GPU 加速 |
| Windows | CUDA | NVIDIA GPU 加速 |
| Linux | CUDA | NVIDIA GPU 加速 |

### 6.2 模型参数调优

```dart
// GPU 层数设置
final gpuLayers = Platform.isAndroid ? 20 : 99;  // 安卓降低以避免 OOM

// 上下文窗口
final contextSize = Platform.isAndroid ? 2048 : 8192;

// 量化级别选择
// Q2_K: 最小，2.5bit/param
// Q4_K_M: 推荐，4bit/param，平衡质量和大小
// Q5_K_S: 较高质量
// Q8_0: 接近原始精度
```

---

## 7. 服务层

### 7.1 DialogueEngine

对话引擎核心类：

```dart
class DialogueEngine {
  final ModelEntry model;
  final InferenceEngineManager engineManager;
  
  /// 发送消息并获取流式响应
  Stream<String> sendMessage({
    required String content,
    List<ImageData>? images,
    String? systemPrompt,
  });
  
  /// 上下文管理
  List<ChatMessage> _messages = [];
  void _manageContext();  // 上下文压缩
}
```

### 7.2 RAGService

知识库检索服务：

```dart
class RAGService {
  /// 文档上传
  Future<void> uploadDocument(KnowledgeBase kb, File file);
  
  /// 语义检索
  Future<List<SearchResult>> search(String kbId, String query);
  
  /// 构建 RAG 提示词
  String buildPrompt(String query, List<SearchResult> results);
}
```

### 7.3 VoiceService

语音服务：

```dart
class VoiceService {
  /// 语音识别 (ASR)
  Future<String> recognize(String audioPath);
  
  /// 语音合成 (TTS)
  Future<String> synthesize(String text, {VoiceConfig? config});
  
  /// 实时语音对话
  Stream<VoiceDialogState> startDialog();
}
```

---

## 8. UI 层

### 8.1 页面路由

使用 go_router：

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => SessionListPage()),
    GoRoute(path: '/session/:id', builder: (_, state) => SessionDetailPage()),
    GoRoute(path: '/settings', builder: (_, __) => SettingsPage()),
    GoRoute(path: '/settings/models', builder: (_, __) => ModelSettingsPage()),
    GoRoute(path: '/model-market', builder: (_, __) => ModelMarketPage()),
    GoRoute(path: '/model/:id/load', builder: (_, state) => ModelLoadPage()),
  ],
);
```

### 8.2 核心页面

| 页面 | 路由 | 功能 |
|------|------|------|
| SessionListPage | / | 会话列表 |
| SessionDetailPage | /session/:id | 对话详情 |
| SettingsPage | /settings | 设置 |
| ModelSettingsPage | /settings/models | 模型管理 |
| ModelMarketPage | /model-market | 模型市场 |
| ModelLoadPage | /model/:id/load | 模型加载参数 |

---

## 9. 性能优化

### 9.1 已实现的优化

| 优化项 | 实现方式 | 效果 |
|--------|----------|------|
| 模型加载 | Isolate 后台加载 | 不阻塞 UI |
| 推理 | Stream 流式输出 | 首 token < 1s |
| 图片处理 | 临时文件复用 | 减少 I/O |
| 上下文压缩 | 滑动窗口 + 摘要 | 支持长对话 |
| UI 渲染 | RepaintBoundary | 减少重绘 |
| 图片缓存 | LRU 缓存 | 减少内存占用 |

### 9.2 性能指标

| 指标 | 目标值 | 实际值 |
|------|--------|--------|
| 首 token 延迟 | < 1s | ~500ms |
| 推理吞吐量 | > 30 tok/s | ~50 tok/s |
| 内存占用 | < 2GB | ~1.5GB |
| 冷启动时间 | < 3s | ~2s |

---

## 10. 未来规划

### 10.1 短期目标

- [ ] 完善多模态模型支持
- [ ] 优化知识库检索算法
- [ ] 增加更多 TTS 音色
- [ ] 支持更多文件类型解析

### 10.2 中期目标

- [ ] MCP 协议支持
- [ ] Agent 模式
- [ ] 自定义技能系统
- [ ] 插件市场

### 10.3 长期目标

- [ ] 跨平台剪贴板同步
- [ ] 多设备会话同步
- [ ] 本地模型微调
- [ ] 隐私保护增强

---

## 附录

### A. 配置示例

```yaml
# model_config.yaml
models:
  - name: "Qwen2.5-7B"
    path: "models/qwen2.5-7b-q4_k_m.gguf"
    type: "local"
    gpu_layers: 99
    
  - name: "GPT-4o"
    type: "remote"
    api: "openai"
    model_id: "gpt-4o"
```

### B. 错误码

| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| E001 | 模型文件不存在 | 重新下载模型 |
| E002 | 模型加载失败 | 检查 GGUF 文件完整性 |
| E003 | API 请求失败 | 检查网络连接 |
| E004 | 内存不足 | 减少 GPU 层数或使用更小的模型 |

### C. 参考资料

- [llamadart](https://github.com/abetlen/llama.dart)
- [llama.cpp](https://github.com/ggerganov/llama.cpp)
- [Flutter Riverpod](https://riverpod.dev/)
- [Drift ORM](https://drift.simonbinder.eu/)

---

*本文档由 LLM Studio 自动生成*