/// 工作流节点定义
///
/// 定义工作流中的各类任务节点：
/// - SkillNode: 调用技能执行
/// - LLMNode: 调用 LLM 模型
/// - ConditionNode: 条件分支
/// - LoopNode: 循环节点
/// - SubWorkflowNode: 子工作流
/// - SessionNode: 会话操作
/// - StartNode / EndNode: 起止节点
library;

/// 节点类型
enum NodeType {
  /// 起始节点
  start,

  /// 结束节点
  end,

  /// 技能节点 - 调用 Skill
  skill,

  /// LLM 节点 - 调用大模型
  llm,

  /// 条件分支节点
  condition,

  /// 循环节点
  loop,

  /// 子工作流节点
  subWorkflow,

  /// 会话操作节点
  session,

  /// HTTP 请求节点
  http,

  /// 代码执行节点
  code,

  /// 延迟节点
  delay,

  /// 人工审批节点
  approval,
}

/// 节点状态
enum NodeStatus {
  /// 待执行
  pending,

  /// 等待前置条件满足
  waiting,

  /// 执行中
  running,

  /// 成功
  success,

  /// 失败
  failed,

  /// 已跳过
  skipped,

  /// 已取消
  cancelled,

  /// 重试中
  retrying,
}

/// 节点执行结果
class NodeResult {
  /// 是否成功
  final bool success;

  /// 输出数据
  final Map<String, dynamic> output;

  /// 错误信息
  final String? error;

  /// 执行耗时
  final Duration? duration;

  /// 重试次数
  final int retryCount;

  const NodeResult({
    required this.success,
    this.output = const {},
    this.error,
    this.duration,
    this.retryCount = 0,
  });

  /// 成功结果
  factory NodeResult.success(Map<String, dynamic> output, {Duration? duration}) {
    return NodeResult(success: true, output: output, duration: duration);
  }

  /// 失败结果
  factory NodeResult.failure(String error, {int retryCount = 0}) {
    return NodeResult(success: false, error: error, retryCount: retryCount);
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'output': output,
        'error': error,
        'duration': duration?.inMilliseconds,
        'retryCount': retryCount,
      };

  factory NodeResult.fromJson(Map<String, dynamic> json) {
    return NodeResult(
      success: json['success'] as bool,
      output: Map<String, dynamic>.from(json['output'] as Map? ?? {}),
      error: json['error'] as String?,
      duration:
          json['duration'] != null ? Duration(milliseconds: json['duration'] as int) : null,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// 工作流节点
class WorkflowNode {
  /// 节点 ID
  final String id;

  /// 节点名称
  final String name;

  /// 节点类型
  final NodeType type;

  /// 节点描述
  final String? description;

  /// 节点配置
  final Map<String, dynamic> config;

  /// 输入映射（变量名 -> 表达式）
  final Map<String, String> inputMapping;

  /// 输出映射（变量名 -> 表达式）
  final Map<String, String> outputMapping;

  /// 超时时间
  final Duration? timeout;

  /// 最大重试次数（覆盖工作流级别）
  final int? maxRetries;

  /// 重试延迟
  final Duration retryDelay;

  /// 条件表达式（用于条件节点）
  final String? condition;

  /// 循环配置（用于循环节点）
  final LoopConfig? loopConfig;

  /// 子工作流 ID（用于子工作流节点）
  final String? subWorkflowId;

  /// 位置信息（用于 UI 渲染）
  final NodePosition? position;

  /// 自定义标签
  final List<String> tags;

  /// 是否并行执行
  final bool parallel;

  /// 优先级（数值越大优先级越高）
  final int priority;

  const WorkflowNode({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.config = const {},
    this.inputMapping = const {},
    this.outputMapping = const {},
    this.timeout,
    this.maxRetries,
    this.retryDelay = const Duration(seconds: 1),
    this.condition,
    this.loopConfig,
    this.subWorkflowId,
    this.position,
    this.tags = const [],
    this.parallel = false,
    this.priority = 0,
  });

  /// 是否是起始节点
  bool get isStart => type == NodeType.start;

  /// 是否是结束节点
  bool get isEnd => type == NodeType.end;

  /// 是否是任务节点（需要执行的节点）
  bool get isTask => !isStart && !isEnd;

  /// 是否是分支节点
  bool get isBranch => type == NodeType.condition;

  /// 是否是循环节点
  bool get isLoop => type == NodeType.loop;

  /// 是否需要审批
  bool get needsApproval => type == NodeType.approval;

  /// 获取技能 ID（用于技能节点）
  String? get skillId => config['skillId'] as String?;

  /// 获取模型 ID（用于 LLM 节点）
  String? get modelId => config['modelId'] as String?;

  /// 获取提示词（用于 LLM 节点）
  String? get prompt => config['prompt'] as String?;

  /// 获取 HTTP URL（用于 HTTP 节点）
  String? get httpUrl => config['url'] as String?;

  /// 获取 HTTP 方法（用于 HTTP 节点）
  String get httpMethod => config['method'] as String? ?? 'GET';

  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'config': config,
      'inputMapping': inputMapping,
      'outputMapping': outputMapping,
      'timeout': timeout?.inMilliseconds,
      'maxRetries': maxRetries,
      'retryDelay': retryDelay.inMilliseconds,
      'condition': condition,
      'loopConfig': loopConfig?.toJson(),
      'subWorkflowId': subWorkflowId,
      'position': position?.toJson(),
      'tags': tags,
      'parallel': parallel,
      'priority': priority,
    };
  }

  /// 从 JSON 反序列化
  factory WorkflowNode.fromJson(Map<String, dynamic> json) {
    return WorkflowNode(
      id: json['id'] as String,
      name: json['name'] as String,
      type: NodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NodeType.skill,
      ),
      description: json['description'] as String?,
      config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
      inputMapping: Map<String, String>.from(json['inputMapping'] as Map? ?? {}),
      outputMapping: Map<String, String>.from(json['outputMapping'] as Map? ?? {}),
      timeout: json['timeout'] != null
          ? Duration(milliseconds: json['timeout'] as int)
          : null,
      maxRetries: json['maxRetries'] as int?,
      retryDelay: Duration(milliseconds: json['retryDelay'] as int? ?? 1000),
      condition: json['condition'] as String?,
      loopConfig: json['loopConfig'] != null
          ? LoopConfig.fromJson(json['loopConfig'] as Map<String, dynamic>)
          : null,
      subWorkflowId: json['subWorkflowId'] as String?,
      position: json['position'] != null
          ? NodePosition.fromJson(json['position'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      parallel: json['parallel'] as bool? ?? false,
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// 创建副本
  WorkflowNode copyWith({
    String? id,
    String? name,
    NodeType? type,
    String? description,
    Map<String, dynamic>? config,
    Map<String, String>? inputMapping,
    Map<String, String>? outputMapping,
    Duration? timeout,
    int? maxRetries,
    Duration? retryDelay,
    String? condition,
    LoopConfig? loopConfig,
    String? subWorkflowId,
    NodePosition? position,
    List<String>? tags,
    bool? parallel,
    int? priority,
  }) {
    return WorkflowNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      config: config ?? this.config,
      inputMapping: inputMapping ?? this.inputMapping,
      outputMapping: outputMapping ?? this.outputMapping,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      condition: condition ?? this.condition,
      loopConfig: loopConfig ?? this.loopConfig,
      subWorkflowId: subWorkflowId ?? this.subWorkflowId,
      position: position ?? this.position,
      tags: tags ?? this.tags,
      parallel: parallel ?? this.parallel,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() {
    return 'WorkflowNode(id: $id, name: $name, type: ${type.name})';
  }
}

/// 循环配置
class LoopConfig {
  /// 循环类型
  final LoopType type;

  /// 集合表达式（for-each 循环）
  final String? collectionExpression;

  /// 最大迭代次数
  final int maxIterations;

  /// 条件表达式（while 循环）
  final String? conditionExpression;

  /// 循环变量名
  final String loopVariable;

  /// 当前索引变量名
  final String indexVariable;

  const LoopConfig({
    required this.type,
    this.collectionExpression,
    this.maxIterations = 100,
    this.conditionExpression,
    this.loopVariable = 'item',
    this.indexVariable = 'index',
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'collectionExpression': collectionExpression,
        'maxIterations': maxIterations,
        'conditionExpression': conditionExpression,
        'loopVariable': loopVariable,
        'indexVariable': indexVariable,
      };

  factory LoopConfig.fromJson(Map<String, dynamic> json) {
    return LoopConfig(
      type: LoopType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LoopType.forEach,
      ),
      collectionExpression: json['collectionExpression'] as String?,
      maxIterations: json['maxIterations'] as int? ?? 100,
      conditionExpression: json['conditionExpression'] as String?,
      loopVariable: json['loopVariable'] as String? ?? 'item',
      indexVariable: json['indexVariable'] as String? ?? 'index',
    );
  }
}

/// 循环类型
enum LoopType {
  /// for-each 循环
  forEach,

  /// while 循环
  whileLoop,

  /// 计数循环
  count,
}

/// 节点位置（UI 渲染用）
class NodePosition {
  final double x;
  final double y;

  const NodePosition({this.x = 0, this.y = 0});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory NodePosition.fromJson(Map<String, dynamic> json) {
    return NodePosition(
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// 节点执行上下文
class NodeExecutionContext {
  /// 节点 ID
  final String nodeId;

  /// 工作流实例 ID
  final String workflowInstanceId;

  /// 会话 ID
  final String? sessionId;

  /// 当前变量
  final Map<String, dynamic> variables;

  /// 上游节点输出
  final Map<String, NodeResult> upstreamResults;

  /// 执行开始时间
  final DateTime startTime;

  /// 重试次数
  final int retryCount;

  const NodeExecutionContext({
    required this.nodeId,
    required this.workflowInstanceId,
    this.sessionId,
    this.variables = const {},
    this.upstreamResults = const {},
    required this.startTime,
    this.retryCount = 0,
  });

  /// 获取变量值
  dynamic getVariable(String name) => variables[name];

  /// 获取上游节点输出
  NodeResult? getUpstreamResult(String nodeId) => upstreamResults[nodeId];

  /// 创建副本
  NodeExecutionContext copyWith({
    Map<String, dynamic>? variables,
    Map<String, NodeResult>? upstreamResults,
    int? retryCount,
  }) {
    return NodeExecutionContext(
      nodeId: nodeId,
      workflowInstanceId: workflowInstanceId,
      sessionId: sessionId,
      variables: variables ?? this.variables,
      upstreamResults: upstreamResults ?? this.upstreamResults,
      startTime: startTime,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
