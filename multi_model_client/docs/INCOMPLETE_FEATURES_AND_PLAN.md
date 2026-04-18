# 项目待完成功能清单与实施计划

**制定日期**: 2026-04-05
**技术负责人**: AI Assistant
**项目状态**: 核心架构完成，进入功能完善阶段

---

## 一、未完成功能总览

### 统计概览

| 类别 | TODO数量 | 优先级 | 预计时间 |
|:---|:---|:---|:---|
| 核心引擎功能 | 14 | 高 | 2周 |
| UI功能完善 | 9 | 高 | 1周 |
| 测试用例 | 13 | 中 | 2周 |
| 原生集成 | 4 | 高 | 3周 |
| 文档完善 | 2 | 低 | 3天 |
| **总计** | **42** | - | **8周** |

---

## 二、核心引擎功能待完成 (14项)

### 2.1 加密服务 (2项) - 优先级：高

#### TODO 1: 实现AES加密
**文件**: `lib/core/security/encryption_service.dart:44`

**当前状态**: 仅有接口定义，无实际实现

**待实现内容**:
```dart
// TODO: Implement actual AES encryption using platform channels
Future<Uint8List> encrypt(Uint8List data, String key) async {
  // 1. 通过Platform Channel调用原生加密
  // 2. 使用AES-256-GCM加密算法
  // 3. 返回加密后的数据
}
```

**实现方案**:
1. 创建iOS原生加密插件 (Swift + CommonCrypto)
2. 创建Android原生加密插件 (Kotlin + Cipher)
3. 通过Platform Channel桥接到Flutter
4. 添加密钥管理 (FlutterSecureStorage)

**预计时间**: 3天

#### TODO 2: 实现AES解密
**文件**: `lib/core/security/encryption_service.dart:53`

**当前状态**: 仅有接口定义，无实际实现

**待实现内容**:
```dart
// TODO: Implement actual AES decryption using platform channels
Future<Uint8List> decrypt(Uint8List encryptedData, String key) async {
  // 1. 通过Platform Channel调用原生解密
  // 2. 使用AES-256-GCM解密算法
  // 3. 返回解密后的原始数据
}
```

**实现方案**: 与加密功能一起实现

**预计时间**: 1天 (与加密功能同步完成)

---

### 2.2 模型推理引擎 (7项) - 优先级：高

#### TODO 3: 获取模型配置
**文件**: `lib/core/engines/model_inference_engine.dart:11`

**当前状态**: 未实现

**待实现内容**:
```dart
// TODO: Get model config from repository
Future<ModelConfig> _getModelConfig(String modelId) async {
  // 1. 从ModelRepository获取模型配置
  // 2. 解析模型参数
  // 3. 返回配置对象
}
```

**实现方案**: 集成ModelRepository

**预计时间**: 0.5天

#### TODO 4: 加载实际模型
**文件**: `lib/core/engines/model_inference_engine.dart:15`

**当前状态**: 未实现

**待实现内容**:
```dart
// TODO: Load actual model
Future<void> loadModel(String modelId) async {
  // 1. 检查模型是否已下载
  // 2. 调用LlamaInferenceEngine.loadModel()
  // 3. 初始化推理上下文
  // 4. 缓存已加载的模型
}
```

**实现方案**: 集成LlamaInferenceEngine

**预计时间**: 2天

#### TODO 5: 实现模型下载
**文件**: `lib/core/engines/model_inference_engine.dart:40`

**当前状态**: 未实现

**待实现内容**:
```dart
// TODO: Implement model download with progress tracking
Future<void> downloadModel(String modelId, {Function(double)? onProgress}) async {
  // 1. 获取模型下载URL
  // 2. 使用Dio下载模型文件
  // 3. 支持断点续传
  // 4. 实时报告下载进度
  // 5. 验证模型文件完整性
}
```

**实现方案**: 使用Dio实现带进度的文件下载

**预计时间**: 2天

#### TODO 6-9: 其他模型管理功能
**文件**: `lib/core/engines/model_inference_engine.dart:46, 52, 58, 66`

**待实现内容**:
- TODO 6: 获取模型信息
- TODO 7: 获取所有可用模型
- TODO 8: 检测模型能力
- TODO 9: 实现加载状态流

**实现方案**: 集成ModelRepository和状态管理

**预计时间**: 1天

---

### 2.3 记忆引擎 (2项) - 优先级：中

#### TODO 10: 调用LLM提取记忆
**文件**: `lib/features/memory/domain/memory_engine.dart:40`

**当前状态**: 仅创建简单记忆，未使用LLM提取

**待实现内容**:
```dart
// TODO: Call LLM for extraction
Future<void> extractMemory(String sessionId, List<Message> messages) async {
  // 1. 构建记忆提取Prompt
  // 2. 调用LLM分析对话
  // 3. 提取实体、事实、偏好
  // 4. 存储到数据库
}
```

**实现方案**:
1. 设计记忆提取Prompt模板
2. 集成DialogueEngine调用LLM
3. 解析LLM返回的JSON
4. 存储结构化记忆

**预计时间**: 2天

#### TODO 11: 实现语义检索
**文件**: `lib/features/memory/domain/memory_engine.dart:70`

**当前状态**: 仅支持关键词匹配

**待实现内容**:
```dart
// TODO: Implement semantic search using embeddings
Future<List<MemoryItem>> retrieveMemories(String sessionId, String query) async {
  // 1. 为查询生成向量嵌入
  // 2. 计算与记忆向量的相似度
  // 3. 返回最相关的记忆
}
```

**实现方案**:
1. 集成句子嵌入模型
2. 添加向量存储字段
3. 实现向量相似度计算

**预计时间**: 3天

---

### 2.4 RAG引擎 (3项) - 优先级：中

#### TODO 12: 实现文档删除
**文件**: `lib/features/rag/domain/rag_engine.dart:47`

**当前状态**: 未实现

**待实现内容**:
```dart
// TODO: Implement document removal
Future<void> removeDocument(String kbId, String documentId) async {
  // 1. 查询文档的所有chunks
  // 2. 删除相关chunks
  // 3. 更新知识库统计信息
}
```

**实现方案**: 添加文档跟踪表，实现级联删除

**预计时间**: 0.5天

#### TODO 13: 实现语义检索
**文件**: `lib/features/rag/domain/rag_engine.dart:56`

**当前状态**: 仅支持关键词匹配

**待实现内容**: 与记忆引擎语义检索类似

**预计时间**: 2天

#### TODO 14: 生成向量嵌入
**文件**: `lib/features/rag/domain/rag_engine.dart:117`

**当前状态**: 未实现

**待实现内容**:
```dart
// TODO: Generate embeddings for all chunks
Future<void> generateEmbeddings(String kbId) async {
  // 1. 遍历所有文档chunks
  // 2. 为每个chunk生成向量嵌入
  // 3. 存储向量到数据库
}
```

**实现方案**: 批量调用嵌入模型API

**预计时间**: 2天

---

## 三、UI功能完善 (9项) - 优先级：高

### 3.1 设置页面功能 (7项)

#### TODO 15-21: 设置页面导航和功能

**文件**: `lib/features/settings/presentation/pages/settings_page.dart`

**待实现功能**:

| TODO | 行号 | 功能 | 预计时间 |
|:---|:---|:---|:---|
| 15 | 39 | 导航到模型管理页面 | 0.5天 |
| 16 | 56 | 导航到记忆设置页面 | 0.5天 |
| 17 | 73 | 导航到知识库管理页面 | 0.5天 |
| 18 | 90 | 显示存储信息 | 0.5天 |
| 19 | 100 | 显示备份选项 | 1天 |
| 20 | 221 | 实现清除缓存 | 0.5天 |
| 21 | - | 模型选择对话框 | 1天 |

**实现方案**: 创建对应的页面和对话框组件

---

### 3.2 会话页面功能 (2项)

#### TODO 22-23: 会话管理功能

**文件**: `lib/features/session/presentation/pages/`

**待实现功能**:

| TODO | 文件 | 功能 | 预计时间 |
|:---|:---|:---|:---|
| 22 | session_list_page.dart:49 | 显示会话选项菜单 | 0.5天 |
| 23 | session_list_page.dart:135 | 模型选择功能 | 1天 |

**实现方案**: 
- 添加PopupMenuButton实现会话选项
- 创建模型选择对话框

---

## 四、测试用例待编写 (13项) - 优先级：中

### 4.1 单元测试 (6项)

**文件**: `test/` 目录

**待编写测试**:

| 测试项 | 测试内容 | 预计时间 |
|:---|:---|:---|
| 存储引擎测试 | 数据库CRUD操作 | 1天 |
| 会话管理测试 | SessionManager功能 | 1天 |
| 对话引擎测试 | DialogueEngine功能 | 1天 |
| 记忆引擎测试 | MemoryEngine功能 | 1天 |
| RAG引擎测试 | RAGEngine功能 | 1天 |
| FFI引擎测试 | 原生引擎集成 | 2天 |

---

### 4.2 UI测试 (4项)

**待编写测试**:

| 测试项 | 测试内容 | 预计时间 |
|:---|:---|:---|
| 会话列表页测试 | SessionListPage交互 | 0.5天 |
| 会话详情页测试 | SessionDetailPage交互 | 0.5天 |
| 设置页测试 | SettingsPage交互 | 0.5天 |
| 路由导航测试 | GoRouter路由 | 0.5天 |

---

### 4.3 集成测试 (3项)

**待编写测试**:

| 测试项 | 测试内容 | 预计时间 |
|:---|:---|:---|
| 端到端会话流程 | 创建会话到对话完成 | 1天 |
| 记忆提取检索 | 完整的记忆流程 | 1天 |
| RAG检索增强 | 知识库管理到检索 | 1天 |

---

## 五、原生集成待完成 (4项) - 优先级：高

### 5.1 iOS原生库编译 (2项)

**待编译库**:
1. **libllama.dylib** - llama.cpp iOS版本
   - 支持Metal加速
   - arm64架构
   - 预计时间: 1周

2. **libwhisper.dylib** - Whisper.cpp iOS版本
   - 支持Core ML加速
   - arm64架构
   - 预计时间: 1周

---

### 5.2 Android原生库编译 (2项)

**待编译库**:
1. **libllama.so** - llama.cpp Android版本
   - 支持Vulkan加速
   - arm64-v8a架构
   - 预计时间: 1周

2. **libwhisper.so** - Whisper.cpp Android版本
   - 支持NNAPI加速
   - arm64-v8a架构
   - 预计时间: 1周

---

## 六、其他待完成 (2项) - 优先级：低

### 6.1 Session管理优化

#### TODO: 删除会话相关数据
**文件**: `lib/features/session/data/repositories/session_repository.dart:72`

**待实现内容**:
```dart
// TODO: Delete session memories and other related data
Future<void> deleteSession(String id) async {
  // 1. 删除会话消息
  // 2. 删除会话记忆
  // 3. 删除会话知识库
  // 4. 删除会话本身
}
```

**预计时间**: 0.5天

---

### 6.2 对话引擎优化

#### TODO: 实现取消功能
**文件**: `lib/features/session/domain/dialogue_engine.dart:90`

**待实现内容**:
```dart
// TODO: Implement cancellation
Future<void> cancelGeneration(String sessionId) async {
  // 1. 取消当前生成任务
  // 2. 清理推理上下文
}
```

**预计时间**: 0.5天

---

## 七、实施计划与时间表

### 7.1 第一阶段：核心功能完善 (2周)

**目标**: 完成所有核心引擎功能

| 周次 | 任务 | 负责人 | 交付物 |
|:---|:---|:---|:---|
| Week 1-2 | 加密服务实现 | 开发A | AES加密/解密功能 |
| Week 1-2 | 模型推理引擎完善 | 开发B | 模型加载/下载功能 |
| Week 2 | 记忆引擎优化 | 开发C | LLM提取+语义检索 |
| Week 2 | RAG引擎完善 | 开发D | 语义检索+向量嵌入 |

---

### 7.2 第二阶段：UI功能完善 (1周)

**目标**: 完成所有UI交互功能

| 周次 | 任务 | 负责人 | 交付物 |
|:---|:---|:---|:---|
| Week 3 | 设置页面功能 | 开发A | 7个设置页面功能 |
| Week 3 | 会话页面功能 | 开发B | 模型选择+会话选项 |

---

### 7.3 第三阶段：原生集成 (3周)

**目标**: 完成原生引擎编译和集成

| 周次 | 任务 | 负责人 | 交付物 |
|:---|:---|:---|:---|
| Week 4-5 | iOS原生库编译 | 开发C | libllama.dylib + libwhisper.dylib |
| Week 4-5 | Android原生库编译 | 开发D | libllama.so + libwhisper.so |
| Week 6 | 原生库集成测试 | 全员 | 双端运行验证 |

---

### 7.4 第四阶段：测试用例编写 (2周)

**目标**: 达到80%测试覆盖率

| 周次 | 任务 | 负责人 | 交付物 |
|:---|:---|:---|:---|
| Week 7 | 单元测试 | 开发A+B | 6个测试套件 |
| Week 7-8 | UI测试 | 开发C | 4个Widget测试 |
| Week 8 | 集成测试 | 开发D | 3个端到端测试 |

---

## 八、优先级排序

### P0 (必须完成)

1. **加密服务** - 安全性要求
2. **模型推理引擎** - 核心功能
3. **原生库编译** - 运行依赖
4. **基础测试** - 质量保证

### P1 (重要功能)

5. **UI功能完善** - 用户体验
6. **语义检索** - 核心特性
7. **集成测试** - 稳定性保证

### P2 (优化功能)

8. **LLM记忆提取** - 智能化优化
9. **向量嵌入** - 性能优化
10. **高级测试** - 全面覆盖

---

## 九、资源需求

### 人员需求

| 角色 | 人数 | 技能要求 | 工作内容 |
|:---|:---|:---|:---|
| Flutter开发 | 2人 | Dart, Flutter, Riverpod | UI和业务逻辑 |
| 原生开发 | 1人 | Swift, Kotlin, C++ | iOS/Android原生库 |
| 测试工程师 | 1人 | Flutter测试, 集成测试 | 测试用例编写 |
| 技术负责人 | 1人 | 架构设计, 代码审查 | 项目管理 |

### 硬件需求

- MacBook Pro (M1/M2) - iOS编译
- Android设备 (arm64) - Android测试
- iPhone设备 - iOS测试

### 软件需求

- Xcode 15+
- Android Studio Hedgehog+
- Flutter SDK 3.10+
- llama.cpp源码
- Whisper.cpp源码

---

## 十、风险管理

### 技术风险

| 风险项 | 影响 | 概率 | 应对措施 |
|:---|:---|:---|:---|
| 原生库编译失败 | 高 | 中 | 准备备用方案，使用预编译库 |
| 语义检索性能差 | 中 | 中 | 使用缓存和索引优化 |
| 模型加载内存溢出 | 高 | 低 | 实现模型分块加载 |
| 测试覆盖率不足 | 中 | 低 | 分阶段测试，优先核心功能 |

### 进度风险

| 风险项 | 影响 | 概率 | 应对措施 |
|:---|:---|:---|:---|
| 人员不足 | 高 | 中 | 合理分配任务，必要时延期 |
| 技术难点攻克慢 | 中 | 高 | 提前技术预研，准备备选方案 |
| 测试发现重大Bug | 高 | 中 | 预留buffer时间，优先修复 |

---

## 十一、质量指标

### 代码质量

- 测试覆盖率: ≥ 80%
- 代码规范: Flutter Lints 0 errors
- 文档完整性: 100%
- 注释覆盖率: ≥ 60%

### 性能指标

- 应用启动时间: < 2秒
- 会话加载时间: < 500ms
- 消息响应时间: < 100ms
- 内存占用: < 500MB (运行时)

### 稳定性指标

- 崩溃率: < 0.1%
- ANR率 (Android): < 0.1%
- UI卡顿率: < 5%

---

## 十二、验收标准

### 功能验收

- ✅ 所有TODO项已实现
- ✅ 所有测试用例通过
- ✅ 核心功能可用
- ✅ UI交互流畅

### 性能验收

- ✅ 启动时间达标
- ✅ 内存占用达标
- ✅ 无明显卡顿

### 质量验收

- ✅ 代码审查通过
- ✅ 测试覆盖率达标
- ✅ 无严重Bug
- ✅ 文档完整

---

## 十三、总结

### 项目当前状态

- **已完成**: 核心架构、数据层、业务引擎、UI框架
- **待完成**: 功能细节、原生集成、测试用例
- **总进度**: 70% → 预计8周后达到95%

### 关键里程碑

1. ✅ **2026-04-05**: 核心架构完成，编译成功
2. 📅 **2026-04-19**: 核心功能完善完成
3. 📅 **2026-04-26**: UI功能完善完成
4. 📅 **2026-05-17**: 原生集成完成
5. 📅 **2026-05-31**: 测试完成，准备发布

### 下一步行动

1. **立即**: 组建开发团队，分配任务
2. **本周**: 开始加密服务和模型引擎开发
3. **下周**: 开始原生库编译准备
4. **持续**: 每日站会，每周评审

---

**制定人**: AI Assistant (技术负责人)
**确认日期**: 2026-04-05
**计划周期**: 8周 (2026-04-05 至 2026-05-31)
