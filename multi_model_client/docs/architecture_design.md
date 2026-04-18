# 技术架构设计文档 - 大模型多平台客户端

**文档版本**: v1.0  
**设计负责人**: tech_lead  
**设计日期**: 第1周周四  
**文档状态**: 🔄 设计中

---

## 一、架构设计总览

### 1.1 架构设计目标

**核心目标**: 构建高性能、高可用、可扩展的移动端大模型客户端架构,支撑会话隔离、本地推理、全模态交互等核心能力。

**设计原则**:
1. **会话隔离**: 通过session_id实现全链路数据隔离,确保多会话无串扰
2. **本地优先**: 核心能力本地化,支持完全离线使用
3. **模块解耦**: 功能模块化,接口标准化,便于扩展和维护
4. **性能优化**: 内存管理、推理优化、流式处理,确保流畅体验
5. **安全合规**: 数据加密、权限管控、沙箱隔离,符合平台规范

### 1.2 整体架构图

```
┌─────────────────────────────────────────────────────────────────────┐
│                     UI交互层 (Flutter)                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │会话列表  │ │对话界面  │ │模型市场  │ │记忆管理  │ │知识库    │ │
│  │UI        │ │UI        │ │UI        │ │UI        │ │管理UI    │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │提示词    │ │技能市场  │ │音视频    │ │设置界面  │ │新手引导  │ │
│  │模板库UI  │ │UI        │ │对话UI    │ │UI        │ │UI        │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
├─────────────────────────────────────────────────────────────────────┤
│                     业务能力层 (Dart)                                │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │               会话管理中心 (Session Manager)                  │ │
│  │  - 会话创建/删除/切换  - 会话状态管理  - 会话实例调度        │ │
│  └──────────────────────────────────────────────────────────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │对话管理  │ │模型管理  │ │记忆管理  │ │RAG管理   │ │技能/MCP  │ │
│  │Service   │ │Service   │ │Service   │ │Service   │ │管理      │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                           │
│  │提示词    │ │URL内容   │ │音视频    │                           │
│  │管理      │ │总结管理  │ │交互管理  │                           │
│  └──────────┘ └──────────┘ └──────────┘                           │
├─────────────────────────────────────────────────────────────────────┤
│                     核心引擎层 (Dart + Native)                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │会话实例  │ │对话引擎  │ │模型推理  │ │Memory    │ │RAG引擎   │ │
│  │调度器    │ │Engine    │ │引擎      │ │引擎      │ │Engine    │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │插件引擎  │ │MCP客户端 │ │工具调用  │ │多模态    │ │URL解析   │ │
│  │Plugin    │ │MCP Client│ │调度器    │ │处理引擎  │ │引擎      │ │
│  │Engine    │ │          │ │Tool      │ │Multimodal│ │URLParser │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│  ┌──────────┐                                                      │
│  │平台适配  │                                                      │
│  │解析模块  │                                                      │
│  └──────────┘                                                      │
├─────────────────────────────────────────────────────────────────────┤
│                     基础能力层 (Native + Dart)                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │存储引擎  │ │音视频    │ │网络请求  │ │硬件加速  │ │权限管理  │ │
│  │Storage   │ │处理      │ │Network   │ │Hardware  │ │Permission│ │
│  │Engine    │ │AV        │ │Client    │ │Accelerate│ │Manager   │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│  ┌──────────┐                                                      │
│  │加密模块  │                                                      │
│  │Crypto    │                                                      │
│  └──────────┘                                                      │
├─────────────────────────────────────────────────────────────────────┤
│                     跨平台适配层 (Native)                            │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │         Flutter/Dart FFI (Foreign Function Interface)        │ │
│  └──────────────────────────────────────────────────────────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │平台原生  │ │CPU/GPU   │ │分享扩展  │ │后台任务  │           │
│  │API桥接   │ │架构适配  │ │Share     │ │Background│           │
│  │Platform  │ │CPU/GPU   │ │Extension │ │Task      │           │
│  │Bridge    │ │Adapt     │ │          │ │          │           │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
└─────────────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────────────┐
│         安全合规层 (贯穿所有层级)                                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │数据加密  │ │权限管控  │ │沙箱隔离  │ │密钥安全  │ │合规审计  │ │
│  │AES-256   │ │Permission│ │Sandbox   │ │Keychain/ │ │Compliance│ │
│  │Encryption│ │Control   │ │Isolation │ │Keystore  │ │Audit     │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│  ┌──────────┐                                                      │
│  │内容安全  │                                                      │
│  │过滤      │                                                      │
│  └──────────┘                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、核心架构模块详解

### 2.1 UI交互层 (Flutter)

#### 2.1.1 技术选型
- **框架**: Flutter 3.x
- **状态管理**: Riverpod (推荐) 或 Bloc
- **路由管理**: go_router
- **网络请求**: Dio
- **本地存储**: SharedPreferences + SecureStorage

#### 2.1.2 目录结构
```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
├── core/                        # 核心模块
│   ├── router/                  # 路由管理
│   │   └── app_router.dart
│   ├── theme/                   # 主题管理
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   ├── network/                 # 网络请求
│   │   ├── dio_client.dart
│   │   └── api_interceptor.dart
│   ├── storage/                 # 本地存储
│   │   ├── shared_prefs.dart
│   │   └── secure_storage.dart
│   └── constants/               # 常量定义
│       ├── app_constants.dart
│       └── route_constants.dart
├── features/                    # 功能模块
│   ├── session/                 # 会话管理模块
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   ├── chat/                    # 对话模块
│   ├── model/                   # 模型管理模块
│   ├── prompt/                  # 提示词管理模块
│   ├── memory/                  # 记忆管理模块
│   ├── rag/                     # RAG检索模块
│   ├── skill/                   # 技能插件模块
│   ├── av/                      # 音视频交互模块
│   ├── summary/                 # 内容总结模块
│   └── settings/                # 系统设置模块
├── shared/                      # 共享组件
│   ├── widgets/                 # 通用组件
│   ├── utils/                   # 工具类
│   └── services/                # 服务类
└── generated/                   # 自动生成代码
    └── l10n/                    # 国际化
```

#### 2.1.3 状态管理设计

**使用Riverpod进行全局状态管理**:

```dart
// 会话状态Provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});

// 模型状态Provider
final modelProvider = StateNotifierProvider<ModelNotifier, ModelState>((ref) {
  return ModelNotifier();
});

// 对话状态Provider
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>((ref, sessionId) {
  return ChatNotifier(sessionId);
});
```

---

### 2.2 业务能力层 (Dart)

#### 2.2.1 会话管理中心 (Session Manager) ⭐ 核心模块

**职责**: 管理所有会话的生命周期,实现会话切换和隔离

**核心设计**:
```dart
class SessionManager {
  // 当前活跃会话
  SessionInstance? _activeSession;
  
  // 会话实例缓存
  final Map<String, SessionInstance> _sessionCache = {};
  
  // 切换会话
  Future<void> switchSession(String sessionId) async {
    // 1. 暂停当前会话,保存状态
    if (_activeSession != null) {
      await _activeSession!.pause();
    }
    
    // 2. 加载目标会话
    if (!_sessionCache.containsKey(sessionId)) {
      _sessionCache[sessionId] = await _loadSession(sessionId);
    }
    
    // 3. 激活目标会话
    _activeSession = _sessionCache[sessionId];
    await _activeSession!.resume();
  }
  
  // 创建新会话
  Future<SessionInstance> createSession({
    required String modelId,
    String? systemPrompt,
    Map<String, dynamic>? params,
  }) async {
    final sessionId = _generateSessionId();
    final session = SessionInstance(
      sessionId: sessionId,
      modelId: modelId,
      systemPrompt: systemPrompt,
      inferenceParams: params ?? {},
    );
    
    // 持久化到数据库
    await _sessionRepository.insert(session);
    
    _sessionCache[sessionId] = session;
    return session;
  }
  
  // 删除会话
  Future<void> deleteSession(String sessionId) async {
    // 1. 从缓存中移除
    _sessionCache.remove(sessionId);
    
    // 2. 删除数据库记录
    await _sessionRepository.delete(sessionId);
    
    // 3. 删除关联数据
    await _messageRepository.deleteBySession(sessionId);
    await _memoryRepository.deleteBySession(sessionId);
    // ... 其他关联数据
  }
}
```

**会话实例数据结构**:
```dart
class SessionInstance {
  final String sessionId;
  final String sessionName;
  final String modelId;
  final ModelConfig modelConfig;
  final Map<String, dynamic> inferenceParams;
  final String? systemPrompt;
  final List<Message> contextMessages;
  final List<String> enabledSkills;
  final List<String> boundKnowledgeBases;
  final bool enableGlobalMemory;
  
  // 状态管理
  SessionState _state = SessionState.inactive;
  
  // 对话引擎实例
  ChatEngine? _chatEngine;
  
  // 暂停会话
  Future<void> pause() async {
    _state = SessionState.paused;
    await _chatEngine?.pause();
    await _saveContext();
  }
  
  // 恢复会话
  Future<void> resume() async {
    _state = SessionState.active;
    await _loadContext();
    _chatEngine = ChatEngine(modelId: modelId);
  }
}
```

#### 2.2.2 对话管理服务 (Chat Service)

**职责**: 管理对话流程,包括上下文管理、流式响应、工具调用

**核心设计**:
```dart
class ChatService {
  final SessionInstance _session;
  final ChatEngine _engine;
  
  // 发送消息
  Stream<ChatResponse> sendMessage(String content) async* {
    // 1. 构建上下文
    final context = await _buildContext(content);
    
    // 2. 注入系统提示词
    final prompt = _buildPrompt(context);
    
    // 3. 调用对话引擎
    await for (final chunk in _engine.chat(prompt)) {
      yield ChatResponse(
        sessionId: _session.sessionId,
        content: chunk.content,
        isComplete: chunk.isComplete,
      );
    }
    
    // 4. 保存对话历史
    await _saveHistory(content, response);
    
    // 5. 触发记忆提取
    await _triggerMemoryExtraction();
  }
  
  // 构建上下文
  Future<List<Message>> _buildContext(String query) async {
    final messages = <Message>[];
    
    // 1. 加载会话历史
    messages.addAll(await _loadHistory());
    
    // 2. 注入记忆 (如果开启)
    if (_session.enableGlobalMemory) {
      final memories = await _memoryService.retrieve(query, _session.sessionId);
      messages.addAll(_formatMemories(memories));
    }
    
    // 3. 注入RAG内容 (如果绑定知识库)
    if (_session.boundKnowledgeBases.isNotEmpty) {
      final ragContent = await _ragService.retrieve(query, _session.boundKnowledgeBases);
      messages.addAll(_formatRagContent(ragContent));
    }
    
    return messages;
  }
}
```

---

### 2.3 核心引擎层 (Dart + Native)

#### 2.3.1 模型推理引擎 (Model Inference Engine)

**职责**: 管理本地和远程模型的加载、推理、生命周期

**架构设计**:
```
ModelInferenceEngine (Dart)
├── LocalModelEngine (Native FFI)
│   ├── llama.cpp Bridge
│   ├── Model Loader
│   ├── Inference Context
│   └── GPU Acceleration (Metal/Vulkan)
└── RemoteModelEngine (Dart)
    ├── OpenAI API Client
    ├── Anthropic API Client
    └── Custom API Client
```

**接口设计**:
```dart
abstract class ModelEngine {
  // 加载模型
  Future<void> load(String modelId);
  
  // 卸载模型
  Future<void> unload();
  
  // 推理
  Stream<InferenceResult> infer({
    required String prompt,
    required InferenceParams params,
  });
  
  // 获取模型信息
  ModelInfo getModelInfo();
}

class LocalModelEngine implements ModelEngine {
  // FFI桥接
  final LlamaCppBridge _bridge;
  
  @override
  Stream<InferenceResult> infer({
    required String prompt,
    required InferenceParams params,
  }) async* {
    // 调用原生推理
    await for (final token in _bridge.infer(prompt, params)) {
      yield InferenceResult(
        token: token.text,
        isComplete: token.isComplete,
        tokensPerSecond: token.speed,
      );
    }
  }
}
```

**原生层实现 (iOS Swift)**:
```swift
class LlamaCppBridge {
    private var context: OpaquePointer?
    
    func loadModel(path: String, params: ModelParams) throws {
        // 初始化llama.cpp上下文
        let modelPath = path.cString(using: .utf8)
        context = llama_load_model_from_file(modelPath, params.toLlamaParams())
    }
    
    func infer(prompt: String, params: InferenceParams) -> AsyncStream<Token> {
        return AsyncStream { continuation in
            // 创建推理上下文
            let ctx = llama_new_context_with_model(model, params.toLlamaContextParams())
            
            // 分词
            let tokens = llama_tokenize(ctx, prompt, true)
            
            // 流式推理
            for i in 0..<tokens.count {
                let token = llama_decode(ctx, batch)
                let text = llama_token_to_piece(ctx, token)
                
                continuation.yield(Token(text: text, isComplete: false))
            }
            
            continuation.yield(Token(text: "", isComplete: true))
            continuation.finish()
        }
    }
}
```

#### 2.3.2 Memory引擎 (Memory Engine)

**职责**: 分层记忆管理、自动提取、向量检索、权重衰减

**架构设计**:
```
MemoryEngine
├── InstantMemory (瞬时记忆)
│   └── 当前轮对话实时保留
├── WorkingMemory (工作记忆)
│   ├── 滑动窗口
│   └── 动态摘要
├── LongTermMemory (长时记忆)
│   ├── 会话专属记忆
│   ├── 全局记忆
│   ├── 向量化存储 (sqlite-vss)
│   └── 权重管理
└── ArchivedMemory (归档记忆)
    └── 冷存储
```

**数据结构**:
```dart
class Memory {
  final String id;
  final String sessionId; // null表示全局记忆
  final MemoryType type; // instant/working/long_term/archived
  final String content;
  final List<double> embedding; // 向量嵌入
  final double weight; // 权重 0-1
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final List<String> entityTags; // 实体标签
  final bool isGlobal; // 是否全局记忆
}
```

**核心流程**:
```dart
class MemoryEngine {
  // 记忆提取 (每轮对话后触发)
  Future<void> extractMemory(String sessionId, List<Message> messages) async {
    // 1. 使用LLM提取实体、事实、偏好
    final extracted = await _llmExtract(messages);
    
    // 2. 向量化
    final embedding = await _vectorize(extracted.content);
    
    // 3. 存储到长时记忆
    final memory = Memory(
      sessionId: sessionId,
      type: MemoryType.longTerm,
      content: extracted.content,
      embedding: embedding,
      weight: 0.8, // 初始权重
      entityTags: extracted.entities,
    );
    
    await _memoryRepository.insert(memory);
  }
  
  // 记忆检索
  Future<List<Memory>> retrieve(String query, String? sessionId) async {
    // 1. Query向量化
    final queryEmbedding = await _vectorize(query);
    
    // 2. 向量检索 (sqlite-vss)
    final memories = await _memoryRepository.vectorSearch(
      queryEmbedding,
      sessionId: sessionId,
      limit: 10,
    );
    
    // 3. 权重衰减计算
    final now = DateTime.now();
    for (final memory in memories) {
      final daysSinceAccess = now.difference(memory.lastAccessedAt).inDays;
      final decayFactor = exp(-0.01 * daysSinceAccess);
      memory.weight = memory.weight * decayFactor;
    }
    
    // 4. 更新访问时间和计数
    await _updateAccess(memories);
    
    return memories;
  }
}
```

#### 2.3.3 RAG引擎 (RAG Engine)

**职责**: 知识库管理、文档解析、向量化、检索

**架构设计**:
```
RAGEngine
├── KnowledgeBaseManager
│   ├── 知识库创建/删除
│   ├── 文档上传
│   └── 绑定管理
├── DocumentProcessor
│   ├── 文档解析 (PDF/Word/TXT/MD/Excel)
│   ├── OCR提取 (图片)
│   ├── ASR转写 (音视频)
│   └── 语义分块
├── EmbeddingEngine
│   ├── 本地向量化模型
│   └── 云端向量化API
└── VectorStore
    └── sqlite-vss
```

**文档解析流程**:
```dart
class DocumentProcessor {
  Future<List<DocumentChunk>> process(String filePath) async {
    // 1. 识别文件类型
    final fileType = _detectFileType(filePath);
    
    // 2. 提取文本
    String text;
    switch (fileType) {
      case FileType.pdf:
        text = await _pdfExtractor.extract(filePath);
        break;
      case FileType.word:
        text = await _wordExtractor.extract(filePath);
        break;
      case FileType.image:
        text = await _ocrEngine.extract(filePath);
        break;
      case FileType.audio:
        text = await _asrEngine.transcribe(filePath);
        break;
      // ...
    }
    
    // 3. 语义分块
    final chunks = await _semanticChunker.chunk(text);
    
    // 4. 向量化
    for (final chunk in chunks) {
      chunk.embedding = await _embeddingEngine.embed(chunk.content);
    }
    
    return chunks;
  }
}
```

---

### 2.4 基础能力层 (Native + Dart)

#### 2.4.1 存储引擎 (Storage Engine)

**技术选型**: SQLite + drift ORM + sqlite-vss

**数据库设计**:
```dart
// drift表定义
@DataClassName('Session')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get modelId => text()();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get inferenceParams => text().map(const JsonConverter())();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Message')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get role => text()(); // user/assistant/system
  TextColumn get content => text()();
  TextColumn get type => text().withDefault(const Constant('text'))();
  IntColumn get tokenCount => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Memory')
class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().nullable()(); // null表示全局记忆
  TextColumn get type => text()(); // instant/working/long_term/archived
  TextColumn get content => text()();
  RealColumn get weight => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime()();
  IntColumn get accessCount => integer().withDefault(const Constant(0))();
  BoolColumn get isGlobal => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**向量存储 (sqlite-vss)**:
```sql
-- 创建向量表
CREATE VIRTUAL TABLE IF NOT EXISTS memory_vectors USING vss0(
  embedding(1536)  -- 假设使用1536维向量
);

-- 向量检索
SELECT m.*, v.distance
FROM memories m
JOIN memory_vectors v ON m.id = v.rowid
WHERE m.session_id = ? OR m.is_global = 1
ORDER BY vss_search(v.embedding, ?)
LIMIT 10;
```

#### 2.4.2 音视频处理 (AV Processing)

**架构设计**:
```
AVProcessingEngine
├── ASREngine
│   ├── LocalWhisper (Whisper.cpp FFI)
│   ├── PlatformASR (iOS Speech/Android SpeechRecognizer)
│   └── CloudASR (OpenAI/阿里云/腾讯云)
├── TTSEngine
│   ├── LocalPiper (Piper TTS FFI)
│   ├── PlatformTTS (iOS AVSpeechSynthesizer/Android TextToSpeech)
│   └── CloudTTS
├── AudioCapture
│   ├── iOS AVAudioRecorder
│   └── Android AudioRecord
├── VideoCapture
│   ├── iOS AVCaptureSession
│   └── Android CameraX
└── VADDetector (语音活动检测)
```

**ASR流程**:
```dart
class ASREngine {
  // 流式识别
  Stream<ASRResult> transcribeStream(Stream<AudioChunk> audioStream) async* {
    // 1. VAD检测
    await for (final chunk in audioStream) {
      if (_vadDetector.isSpeech(chunk)) {
        // 2. 送到ASR引擎
        final result = await _whisperEngine.transcribe(chunk);
        yield ASRResult(
          text: result.text,
          isFinal: result.isFinal,
          confidence: result.confidence,
        );
      }
    }
  }
}
```

---

### 2.5 跨平台适配层 (Native)

#### 2.5.1 FFI桥接设计

**Dart FFI接口**:
```dart
// 定义C函数签名
final DynamicLibrary _lib = DynamicLibrary.open('libnative.so');

final Pointer<Utf8> Function(Pointer<Utf8> modelPath) llamaLoadModel = 
    _lib.lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('llama_load_model')
    .asFunction();

final void Function(Pointer<Utf8> context, Pointer<Utf8> prompt) llamaInfer = 
    _lib.lookup<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>>('llama_infer')
    .asFunction();
```

**iOS原生实现 (Swift)**:
```swift
// LlamaCppBridge.swift
@_cdecl("llama_load_model")
public func llamaLoadModel(modelPath: UnsafePointer<CChar>) -> OpaquePointer? {
    let path = String(cString: modelPath)
    return LlamaWrapper.shared.loadModel(path: path)
}

@_cdecl("llama_infer")
public func llamaInfer(context: OpaquePointer, prompt: UnsafePointer<CChar>) {
    let promptText = String(cString: prompt)
    LlamaWrapper.shared.infer(context: context, prompt: promptText)
}
```

**Android原生实现 (Kotlin)**:
```kotlin
// LlamaCppBridge.kt
class LlamaCppBridge {
    companion object {
        init {
            System.loadLibrary("native")
        }
    }
    
    external fun llamaLoadModel(modelPath: String): Long
    external fun llamaInfer(context: Long, prompt: String)
}
```

#### 2.5.2 平台特性适配

**iOS特性**:
- Share Extension (分享扩展)
- Core ML加速 (Whisper.cpp)
- Metal加速 (llama.cpp)
- Keychain密钥存储
- Background Tasks

**Android特性**:
- Intent Filter (分享接收)
- NNAPI加速
- Vulkan加速
- Keystore密钥存储
- Foreground Service (后台推理)

---

## 三、会话隔离架构详细设计 ⭐

### 3.1 会话隔离核心机制

**设计目标**: 确保多个会话之间的数据和上下文完全隔离,无任何串扰

**隔离维度**:
1. **数据隔离**: 数据库记录通过session_id隔离
2. **上下文隔离**: 每个会话独立的对话引擎实例
3. **配置隔离**: 每个会话独立的模型、提示词、参数配置
4. **记忆隔离**: 会话专属记忆vs全局记忆
5. **知识库隔离**: 会话专属知识库vs全局知识库
6. **技能隔离**: 会话级技能开关

### 3.2 数据库隔离设计

**所有数据表必须包含session_id字段**:
```sql
-- 对话历史表
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,  -- 会话隔离标识
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (session_id) REFERENCES sessions(id)
);

-- 创建索引
CREATE INDEX idx_messages_session ON messages(session_id);

-- 查询时必须带session_id
SELECT * FROM messages WHERE session_id = ? ORDER BY created_at DESC;
```

### 3.3 内存隔离设计

**每个会话独立的对话引擎实例**:
```dart
class ChatEngine {
  final String sessionId;
  final String modelId;
  final List<Message> _contextMessages = [];
  
  ChatEngine({required this.sessionId, required this.modelId});
  
  // 每个实例维护自己的上下文
  void addToContext(Message message) {
    _contextMessages.add(message);
  }
}

// 会话管理器为每个会话创建独立的引擎实例
class SessionManager {
  final Map<String, ChatEngine> _engines = {};
  
  ChatEngine getEngine(String sessionId) {
    if (!_engines.containsKey(sessionId)) {
      _engines[sessionId] = ChatEngine(
        sessionId: sessionId,
        modelId: _getSessionModel(sessionId),
      );
    }
    return _engines[sessionId];
  }
}
```

### 3.4 会话切换流程

```
用户点击切换会话
    ↓
SessionManager.switchSession(targetSessionId)
    ↓
1. 暂停当前会话
   - 保存对话上下文到数据库
   - 保存引擎状态到内存
   - 卸载模型上下文 (如需切换模型)
    ↓
2. 加载目标会话
   - 从数据库加载会话配置
   - 创建/恢复对话引擎实例
   - 加载模型上下文 (如需切换模型)
    ↓
3. 激活目标会话
   - 更新UI状态
   - 恢复对话历史显示
   - 恢复输入框内容
    ↓
切换完成,无上下文串扰
```

---

## 四、数据流设计

### 4.1 对话数据流

```
用户输入
    ↓
ChatService.sendMessage(content)
    ↓
┌─────────────────────────────┐
│ 构建上下文                   │
│ 1. 加载会话历史              │
│ 2. 注入记忆 (如开启)         │
│ 3. 注入RAG内容 (如绑定)      │
│ 4. 注入系统提示词            │
└─────────────────────────────┘
    ↓
构建完整Prompt
    ↓
┌─────────────────────────────┐
│ 模型推理                     │
│ - 本地: ModelEngine.infer() │
│ - 远程: API调用              │
└─────────────────────────────┘
    ↓
流式响应输出
    ↓
保存对话历史
    ↓
触发记忆提取 (异步)
    ↓
更新UI
```

### 4.2 状态管理数据流

```
User Action (UI事件)
    ↓
Provider/Notifier
    ↓
State Update
    ↓
UI Rebuild (Flutter)
    ↓
Persistence (异步)
    ↓
Database
```

---

## 五、性能优化设计

### 5.1 模型推理优化

**优化策略**:
1. **模型量化**: 使用INT4/INT5量化模型,减少内存占用
2. **GPU加速**: iOS使用Metal,Android使用Vulkan
3. **动态内存管理**: 根据设备内存动态调整上下文窗口
4. **并发推理**: 多核CPU并行解码
5. **缓存优化**: 缓存KV状态,避免重复计算

**实现**:
```dart
class InferenceOptimizer {
  // 根据设备内存动态调整参数
  InferenceParams adjustParams(InferenceParams params) {
    final deviceMemory = _getDeviceMemory();
    
    if (deviceMemory < 4 * 1024) { // < 4GB
      return params.copyWith(
        maxContextTokens: 2048,
        batchSize: 128,
      );
    } else if (deviceMemory < 6 * 1024) { // < 6GB
      return params.copyWith(
        maxContextTokens: 4096,
        batchSize: 256,
      );
    } else {
      return params; // 使用默认参数
    }
  }
}
```

### 5.2 内存管理优化

**优化策略**:
1. **对象池**: 复用频繁创建的对象
2. **懒加载**: 按需加载会话历史和记忆
3. **分页加载**: 对话历史分页加载,避免一次加载过多
4. **图片缓存**: 使用CachedNetworkImage缓存图片
5. **及时释放**: 会话切换时及时释放不需要的资源

### 5.3 UI性能优化

**优化策略**:
1. **虚拟列表**: 使用flutter_list_view实现虚拟滚动
2. **避免重建**: 使用const Widget,避免不必要的重建
3. **图片优化**: 压缩图片,使用缩略图
4. **异步加载**: 使用FutureBuilder/StreamBuilder异步加载
5. **防抖节流**: 输入框防抖,避免频繁触发

---

## 六、安全设计

### 6.1 数据加密

**加密策略**:
- **存储加密**: 所有用户数据使用AES-256加密
- **密钥管理**: 使用Keychain(iOS)/Keystore(Android)存储密钥
- **传输加密**: 所有网络请求使用HTTPS
- **敏感数据**: API密钥等敏感数据使用SecureStorage存储

**实现**:
```dart
class CryptoEngine {
  // 加密数据
  Future<String> encrypt(String plaintext) async {
    final key = await _getOrCreateKey();
    final encrypted = await _aesEncrypt(plaintext, key);
    return encrypted;
  }
  
  // 解密数据
  Future<String> decrypt(String ciphertext) async {
    final key = await _getOrCreateKey();
    final decrypted = await _aesDecrypt(ciphertext, key);
    return decrypted;
  }
  
  // 获取或创建密钥
  Future<String> _getOrCreateKey() async {
    // 从Keychain/Keystore获取密钥,不存在则创建
    final key = await _secureStorage.read(key: 'encryption_key');
    if (key == null) {
      final newKey = _generateAESKey();
      await _secureStorage.write(key: 'encryption_key', value: newKey);
      return newKey;
    }
    return key;
  }
}
```

### 6.2 沙箱隔离

**自定义JS技能沙箱**:
```dart
class JavaScriptSandbox {
  final QuickJsRuntime _runtime;
  
  JavaScriptSandbox() {
    _runtime = QuickJsRuntime();
    
    // 注入安全的API
    _runtime.injectGlobalFunction('httpGet', (String url) {
      // 限制可访问的域名
      if (!_isAllowedDomain(url)) {
        throw Exception('Domain not allowed');
      }
      return _httpClient.get(url);
    });
    
    // 禁用危险API
    _runtime.disableFileSystem();
    _runtime.disableNetwork();
  }
  
  // 执行脚本
  Future<dynamic> execute(String script) async {
    return await _runtime.evaluate(script);
  }
}
```

### 6.3 权限管理

**最小权限原则**:
```dart
class PermissionManager {
  // 相机权限
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  // 麦克风权限
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
  
  // 存储权限
  Future<bool> requestStoragePermission() async {
    // Android 10+使用分区存储,无需权限
    if (Platform.isAndroid && await _getAndroidVersion() >= 29) {
      return true;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  
  // 记录权限使用
  void logPermissionUsage(String permission) {
    _permissionUsageLog.add(PermissionUsage(
      permission: permission,
      timestamp: DateTime.now(),
    ));
  }
}
```

---

## 七、扩展性设计

### 7.1 插件化架构

**自定义技能插件**:
```dart
abstract class Skill {
  String get name;
  String get description;
  Map<String, dynamic> get parametersSchema;
  
  Future<dynamic> execute(Map<String, dynamic> params);
}

class SkillRegistry {
  final Map<String, Skill> _skills = {};
  
  void register(Skill skill) {
    _skills[skill.name] = skill;
  }
  
  Future<dynamic> execute(String name, Map<String, dynamic> params) async {
    final skill = _skills[name];
    if (skill == null) {
      throw Exception('Skill not found: $name');
    }
    return await skill.execute(params);
  }
}
```

### 7.2 平台解析插件

**平台解析器接口**:
```dart
abstract class PlatformParser {
  String get platformName;
  bool canParse(String url);
  Future<ParseResult> parse(String url);
}

class PlatformParserRegistry {
  final List<PlatformParser> _parsers = [];
  
  void register(PlatformParser parser) {
    _parsers.add(parser);
  }
  
  Future<ParseResult> parse(String url) async {
    for (final parser in _parsers) {
      if (parser.canParse(url)) {
        return await parser.parse(url);
      }
    }
    throw Exception('No parser found for URL: $url');
  }
}
```

---

## 八、技术选型总结

| 技术领域 | 选型 | 版本 | 理由 |
|:---|:---|:---|:---|
| 跨平台框架 | Flutter | 3.16+ | 单代码库,高性能渲染,成熟生态 |
| 状态管理 | Riverpod | 2.4+ | 类型安全,依赖注入,测试友好 |
| 路由管理 | go_router | 13.0+ | 声明式路由,深链接支持 |
| 网络请求 | Dio | 5.4+ | 拦截器,流式请求,文件上传 |
| 数据库 | SQLite + drift | 2.14+ | 跨平台,类型安全,ORM支持 |
| 向量存储 | sqlite-vss | 0.1+ | 轻量级,跨平台兼容 |
| 模型推理 | llama.cpp | latest | 移动端最佳性能 |
| ASR引擎 | Whisper.cpp | latest | 离线可用,多语言支持 |
| TTS引擎 | Piper TTS | latest | 轻量级,离线可用 |
| 加密 | AES-256 | - | 行业标准 |
| 密钥存储 | Keychain/Keystore | - | 硬件级安全 |

---

## 九、架构决策记录 (ADR)

### ADR-001: 会话隔离架构
**决策**: 通过session_id实现全链路数据隔离,每个会话独立的对话引擎实例  
**理由**: 确保多会话无上下文串扰,符合产品核心需求  
**影响**: 数据库设计必须包含session_id字段,所有查询必须带session_id过滤

### ADR-002: 本地优先设计
**决策**: 核心能力本地化,支持完全离线使用  
**理由**: 保护用户隐私,降低网络依赖,提升用户体验  
**影响**: 必须集成llama.cpp、Whisper.cpp等本地引擎,增加包体积

### ADR-003: Flutter跨平台框架
**决策**: 使用Flutter作为跨平台框架  
**理由**: 单代码库,高性能渲染,成熟生态,降低开发成本  
**影响**: 原生能力通过FFI桥接,需要编写iOS/Android原生代码

### ADR-004: sqlite-vss向量存储
**决策**: 使用sqlite-vss作为向量存储方案  
**理由**: 轻量级,跨平台兼容,与SQLite共用存储  
**影响**: 向量检索性能可能不如专业向量数据库,但满足移动端需求

---

## 十、架构演进路线图

### 第一阶段 (V1.0)
- ✅ 五层架构设计
- ✅ 会话隔离架构
- ✅ 本地模型推理
- ✅ 基础音视频能力

### 第二阶段 (V1.5)
- 📋 云端记忆同步
- 📋 多设备同步
- 📋 桌面端适配 (Windows/macOS)

### 第三阶段 (V2.0)
- 📋 Agent工作流编排
- 📋 多Agent协作
- 📋 自定义模型微调

---

**文档状态**: 🔄 设计中,持续完善  
**下一步**: 完善详细接口设计,输出API文档

**架构师**: tech_lead  
**更新时间**: 第1周周四
