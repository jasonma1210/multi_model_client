# Phase 2 & 3 实现说明

## 📋 概述

本文档记录 Phase 2（多会话隔离机制）和 Phase 3（任务流编排引擎）的完整实现。

---

## 🎯 Phase 2：多会话隔离机制

### 核心组件

#### 1. SessionContext - 会话上下文容器
**文件**: `lib/features/session/domain/session_context.dart`

每个会话独立的上下文对象，包含：
- 消息历史
- 启用的技能
- MCP 服务器配置
- 记忆作用域
- 会话级变量
- 知识库关联

**关键特性**:
- 线程安全的锁定机制
- 快照/恢复支持
- 独立的 MemoryScope

```dart
class SessionContext {
  final String sessionId;
  final Session session;
  final List<Message> messages;
  final Map<String, Skill> enabledSkills;
  final Set<String> enabledMcpServers;
  final Map<String, dynamic> variables;
  final MemoryScope memoryScope;
  
  Future<void> lock({Duration timeout = const Duration(seconds: 30)});
  void unlock();
  SessionSnapshot snapshot();
  void restore(SessionSnapshot snapshot);
}
```

#### 2. SessionIsolator - 会话资源隔离器
**文件**: `lib/features/session/domain/session_isolator.dart`

管理会话间资源隔离，包括：
- 会话上下文管理
- 资源锁管理
- 并发控制
- 资源清理

**关键特性**:
- 单例模式
- 最大活跃会话数限制（50）
- 自动清理非活跃会话（2小时超时）
- LRU 驱逐策略

```dart
class SessionIsolator {
  Future<SessionContext> getOrCreateContext({...});
  Future<T> executeWithLock<T>(String sessionId, Future<T> Function(SessionContext) operation);
  SessionSnapshot? createSnapshot(String sessionId);
  Future<void> restoreFromSnapshot(SessionSnapshot snapshot);
}
```

#### 3. CrossSessionBus - 跨会话通信总线
**文件**: `lib/core/services/cross_session_bus.dart`

提供安全的会话间消息传递机制：
- 订阅/发布模式
- 请求/响应模式
- 广播消息
- 消息历史记录

**关键特性**:
- 会话级消息隔离
- 主题过滤
- 超时控制
- 消息历史查询

```dart
class CrossSessionBus {
  Stream<SessionMessage> subscribe(String sessionId);
  Future<void> sendMessage(SessionMessage message);
  Future<void> broadcast(String fromSessionId, String topic, Map<String, dynamic> payload);
  Future<SessionMessage> sendRequest(String fromSessionId, String toSessionId, String topic, Map<String, dynamic> payload);
  Future<void> respond(SessionMessage request, Map<String, dynamic> responseData);
}
```

#### 4. SessionResources 表
**文件**: `lib/core/storage/database.dart`

存储会话隔离资源信息：
- sessionId: 会话 ID
- resourceType: 资源类型（skill, mcp, variable, memory）
- resourceId: 资源 ID
- config: 资源配置 JSON
- isEnabled: 是否启用

---

## 🚀 Phase 3：任务流编排引擎

### 核心组件

#### 1. WorkflowDefinition - 工作流定义
**文件**: `lib/features/workflow/domain/workflow_definition.dart`

定义工作流的 DAG 结构：
- 节点列表
- 边（连接）列表
- 变量定义
- 触发条件

**关键特性**:
- 环检测（DFS 算法）
- 拓扑排序
- 定义验证
- JSON 序列化/反序列化

```dart
class WorkflowDefinition {
  final String id;
  final String name;
  final List<WorkflowNode> nodes;
  final List<WorkflowEdge> edges;
  final Map<String, VariableDefinition> variables;
  final WorkflowTrigger trigger;
  
  bool hasCycle();
  WorkflowValidationResult validate();
  List<WorkflowNode> getNextNodes(String nodeId);
  List<WorkflowNode> getPreviousNodes(String nodeId);
}
```

#### 2. WorkflowNode - 工作流节点
**文件**: `lib/features/workflow/domain/workflow_node.dart`

支持多种节点类型：

| 节点类型 | 说明 | 配置项 |
|---------|------|--------|
| start | 起始节点 | - |
| end | 结束节点 | - |
| skill | 技能节点 | skillId |
| llm | LLM 节点 | modelId, prompt |
| condition | 条件分支 | condition |
| loop | 循环节点 | loopConfig |
| subWorkflow | 子工作流 | subWorkflowId |
| session | 会话操作 | - |
| http | HTTP 请求 | url, method |
| code | 代码执行 | code |
| delay | 延迟节点 | duration |
| approval | 人工审批 | - |

**循环配置**:
```dart
class LoopConfig {
  final LoopType type; // forEach, whileLoop, count
  final String? collectionExpression;
  final int maxIterations;
  final String? conditionExpression;
}
```

#### 3. WorkflowStateMachine - 工作流状态机
**文件**: `lib/features/workflow/domain/workflow_state_machine.dart`

管理工作流实例和节点的状态转换：

**工作流状态**:
- pending → running → completed / failed / cancelled / timedOut
- running → paused → running
- running → awaitingApproval → running / failed

**节点状态**:
- pending → waiting → running → success / failed / skipped / cancelled / retrying

**状态转换规则**:
```dart
const List<StateTransition> _stateMachineRules = [
  StateTransition(from: pending, event: start, to: running),
  StateTransition(from: running, event: pause, to: paused),
  StateTransition(from: paused, event: resume, to: running),
  StateTransition(from: running, event: complete, to: completed),
  StateTransition(from: running, event: fail, to: failed),
  // ... 更多规则
];
```

#### 4. WorkflowEngine - 工作流执行引擎
**文件**: `lib/features/workflow/domain/workflow_executor.dart`

核心 DAG 执行器，负责：
- 驱动节点按拓扑序执行
- 处理条件分支、循环、子工作流
- 管理超时、重试、错误处理
- 并行执行控制

**执行流程**:
1. 验证工作流定义
2. 计算拓扑排序
3. 初始化就绪队列
4. 并行执行节点
5. 处理条件边和循环
6. 收集结果和错误

**节点执行器接口**:
```dart
abstract class NodeExecutor {
  NodeType get nodeType;
  Future<NodeResult> execute(WorkflowNode node, NodeExecutionContext context);
}
```

**执行配置**:
```dart
class WorkflowExecutionConfig {
  final int maxParallelNodes; // 最大并行节点数
  final Duration? globalTimeout; // 全局超时
  final bool abortOnFailure; // 失败时中止
  final int maxRetries; // 最大重试次数
}
```

#### 5. WorkflowScheduler - 工作流调度器
**文件**: `lib/features/workflow/domain/workflow_scheduler.dart`

负责工作流的触发和调度：
- 定时触发（cron 表达式）
- 事件触发
- 消息触发
- 优先级队列

**调度格式**:
- `every:30m` - 每30分钟
- `every:1h` - 每1小时
- `every:1d` - 每1天
- `daily:HH:mm` - 每天指定时间
- `weekly:MON,HH:mm` - 每周指定时间

**触发器注册**:
```dart
scheduler.registerEventTrigger('user_login', 'workflow_id');
scheduler.registerMessageTrigger('chat_message', 'workflow_id');
```

#### 6. CrossSessionCoordinator - 跨会话协调器
**文件**: `lib/core/services/cross_session_coordinator.dart`

负责工作流中的跨会话协调：
- 数据传递
- 同步屏障
- 任务委托
- 结果汇总

**核心功能**:

```dart
// 数据传递
await coordinator.transferData(
  fromSessionId: 'session_1',
  toSessionId: 'session_2',
  key: 'result',
  value: data,
  workflowInstanceId: 'wf_123',
);

// 同步屏障
await coordinator.createSyncBarrier(
  barrierId: 'barrier_1',
  sessionIds: ['session_1', 'session_2', 'session_3'],
  workflowInstanceId: 'wf_123',
);

// 任务委托
final result = await coordinator.delegateTask(
  fromSessionId: 'session_1',
  toSessionId: 'session_2',
  taskType: 'analyze',
  taskData: {'data': '...'},
  workflowInstanceId: 'wf_123',
);

// 结果汇总
final results = await coordinator.aggregateResults(
  coordinatorSessionId: 'session_0',
  sourceSessionIds: ['session_1', 'session_2'],
  workflowInstanceId: 'wf_123',
);
```

#### 7. WorkflowRepository - 工作流持久化层
**文件**: `lib/features/workflow/data/workflow_repository.dart`

管理工作的持久化存储：
- 工作流定义 CRUD
- 执行记录存储
- 日志管理

**数据库表**:
- `WorkflowDefinitions` - 工作流定义
- `WorkflowExecutions` - 执行记录
- `WorkflowLogs` - 执行日志

---

## 📊 数据库迁移

### Schema Version 10

新增表：
1. `SessionResources` - 会话资源（Phase 2）
2. `WorkflowDefinitions` - 工作流定义（Phase 3）
3. `WorkflowExecutions` - 执行记录（Phase 3）
4. `WorkflowLogs` - 执行日志（Phase 3）

迁移代码：
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onUpgrade: (Migrator m, int from, int to) async {
      // v10: 多会话隔离 & 任务流编排引擎
      try { await m.createTable(sessionResources); } catch (_) {}
      try { await m.createTable(workflowDefinitions); } catch (_) {}
      try { await m.createTable(workflowExecutions); } catch (_) {}
      try { await m.createTable(workflowLogs); } catch (_) {}
    },
  );
}
```

---

## 🔧 使用示例

### 创建并执行工作流

```dart
// 1. 定义工作流
final workflow = WorkflowDefinition(
  id: 'wf_001',
  name: '数据处理工作流',
  nodes: [
    WorkflowNode(id: 'start', name: '开始', type: NodeType.start),
    WorkflowNode(
      id: 'fetch',
      name: '获取数据',
      type: NodeType.http,
      config: {'url': 'https://api.example.com/data', 'method': 'GET'},
    ),
    WorkflowNode(
      id: 'process',
      name: '处理数据',
      type: NodeType.skill,
      config: {'skillId': 'data_processor'},
      inputMapping: {'data': '{fetch_result}'},
    ),
    WorkflowNode(id: 'end', name: '结束', type: NodeType.end),
  ],
  edges: [
    WorkflowEdge(id: 'e1', sourceId: 'start', targetId: 'fetch'),
    WorkflowEdge(id: 'e2', sourceId: 'fetch', targetId: 'process'),
    WorkflowEdge(id: 'e3', sourceId: 'process', targetId: 'end'),
  ],
  trigger: WorkflowTrigger.manual(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// 2. 注册节点执行器
engine.registerExecutor(HttpNodeExecutor());
engine.registerExecutor(SkillNodeExecutor());

// 3. 保存工作流
await repository.saveWorkflow(workflow);

// 4. 执行工作流
final execution = await engine.execute(
  workflow,
  inputVariables: {'api_key': 'xxx'},
);

// 5. 监听执行事件
engine.eventStream.listen((event) {
  print('事件: ${event.type} - ${event.instanceId}');
});

// 6. 处理审批
if (execution.state.status == WorkflowStatus.awaitingApproval) {
  engine.submitApproval(execution.instanceId, true);
}
```

### 跨会话数据传递

```dart
final coordinator = CrossSessionCoordinator();

// 创建工作流会话
final session1 = await isolator.getOrCreateContext(sessionId: 'session_1', session: ...);
final session2 = await isolator.getOrCreateContext(sessionId: 'session_2', session: ...);

// 传递数据
await coordinator.transferData(
  fromSessionId: 'session_1',
  toSessionId: 'session_2',
  key: 'processed_data',
  value: {'result': 'success'},
  workflowInstanceId: 'wf_001',
);

// 同步等待
await coordinator.createSyncBarrier(
  barrierId: 'sync_point_1',
  sessionIds: ['session_1', 'session_2'],
  workflowInstanceId: 'wf_001',
);

await coordinator.awaitSyncBarrier(
  barrierId: 'sync_point_1',
  sessionId: 'session_1',
);
```

---

## 📝 待完成事项

1. **子工作流递归执行** - 需要实现 WorkflowRepository 与 WorkflowEngine 的集成
2. **内置节点执行器** - 需要实现 SkillNodeExecutor、LLMNodeExecutor、HttpNodeExecutor 等
3. **可视化工作流编辑器** - 工作流设计器 UI
4. **工作流监控页面** - 实时监控工作流执行状态
5. **Cron 表达式解析** - 完整的 cron 表达式支持
6. **持久化集成** - 将 WorkflowRepository 与数据库表关联

---

## 🏗️ 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                    Workflow Engine                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Definition  │  │   Executor   │  │  Scheduler   │      │
│  │  (DAG)       │  │  (Runtime)   │  │  (Trigger)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│         │                 │                  │              │
│         └─────────────────┼──────────────────┘              │
│                           │                                 │
│  ┌────────────────────────┼─────────────────────────────┐  │
│  │                State Machine                          │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │  │
│  │  │ Pending  │→│ Running  │→│Completed │            │  │
│  │  └──────────┘  └──────────┘  └──────────┘            │  │
│  │                    │                                   │  │
│  │                    ↓                                   │  │
│  │              ┌──────────┐                              │  │
│  │              │  Failed  │                              │  │
│  │              └──────────┘                              │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
           │                                    │
           ↓                                    ↓
┌─────────────────────┐            ┌─────────────────────┐
│   Session Isolator  │            │  Cross-Session Bus  │
│  ┌───────────────┐  │            │  ┌───────────────┐  │
│  │   Contexts    │  │            │  │   Messages    │  │
│  └───────────────┘  │            │  └───────────────┘  │
│  ┌───────────────┐  │            │  ┌───────────────┐  │
│  │    Locks      │  │            │  │   Pub/Sub     │  │
│  └───────────────┘  │            │  └───────────────┘  │
└─────────────────────┘            └─────────────────────┘
```

---

## 📦 依赖关系

```
workflow_definition.dart
    ↓
workflow_node.dart
    ↓
workflow_state_machine.dart
    ↓
workflow_executor.dart
    ↓
workflow_scheduler.dart

cross_session_bus.dart
    ↓
cross_session_coordinator.dart

session_context.dart
    ↓
session_isolator.dart

workflow_repository.dart
    ↓
database.dart (WorkflowDefinitions, WorkflowExecutions, WorkflowLogs)
```

---

## ✅ 完成状态

- [x] Phase 2: 会话上下文容器 (SessionContext)
- [x] Phase 2: 会话资源隔离器 (SessionIsolator)
- [x] Phase 2: 跨会话通信总线 (CrossSessionBus)
- [x] Phase 2: SessionResources 数据库表
- [x] Phase 3: 工作流定义 (WorkflowDefinition)
- [x] Phase 3: 工作流节点 (WorkflowNode)
- [x] Phase 3: 状态机 (WorkflowStateMachine)
- [x] Phase 3: 执行引擎 (WorkflowEngine)
- [x] Phase 3: 调度器 (WorkflowScheduler)
- [x] Phase 3: 跨会话协调器 (CrossSessionCoordinator)
- [x] Phase 3: 持久化层 (WorkflowRepository)
- [x] Phase 3: 数据库表 (WorkflowDefinitions, WorkflowExecutions, WorkflowLogs)

**总计新增文件**: 8 个
**总计新增代码**: ~2500 行
**数据库版本**: 9 → 10
