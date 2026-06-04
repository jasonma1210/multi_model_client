/// 工作流定义
/// 
/// 定义工作流的结构，包括：
/// - 节点列表
/// - 边（连接）列表
/// - 变量定义
/// - 触发条件
library;

import 'dart:convert';
import 'workflow_node.dart';

/// 工作流定义
class WorkflowDefinition {
  /// 工作流 ID
  final String id;
  
  /// 工作流名称
  final String name;
  
  /// 描述
  final String? description;
  
  /// 版本
  final int version;
  
  /// 节点列表
  final List<WorkflowNode> nodes;
  
  /// 边（连接）列表
  final List<WorkflowEdge> edges;
  
  /// 全局变量定义
  final Map<String, VariableDefinition> variables;
  
  /// 触发条件
  final WorkflowTrigger trigger;
  
  /// 最大重试次数
  final int maxRetries;
  
  /// 超时时间
  final Duration? timeout;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 创建者
  final String? createdBy;
  
  /// 标签
  final List<String> tags;
  
  /// 配置
  final Map<String, dynamic> config;
  
  const WorkflowDefinition({
    required this.id,
    required this.name,
    this.description,
    this.version = 1,
    required this.nodes,
    required this.edges,
    this.variables = const {},
    required this.trigger,
    this.maxRetries = 3,
    this.timeout,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.tags = const [],
    this.config = const {},
  });
  
  /// 获取起始节点
  WorkflowNode? get startNode {
    try {
      return nodes.firstWhere((node) => node.type == NodeType.start);
    } catch (e) {
      return nodes.isNotEmpty ? nodes.first : null;
    }
  }
  
  /// 获取结束节点
  WorkflowNode? get endNode {
    try {
      return nodes.firstWhere((node) => node.type == NodeType.end);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取指定节点
  WorkflowNode? getNode(String nodeId) {
    try {
      return nodes.firstWhere((node) => node.id == nodeId);
    } catch (e) {
      return null;
    }
  }
  
  /// 获取节点的后续节点
  List<WorkflowNode> getNextNodes(String nodeId) {
    final nextNodeIds = edges
        .where((edge) => edge.sourceId == nodeId)
        .map((edge) => edge.targetId)
        .toList();
    
    return nodes.where((node) => nextNodeIds.contains(node.id)).toList();
  }
  
  /// 获取节点的前驱节点
  List<WorkflowNode> getPreviousNodes(String nodeId) {
    final prevNodeIds = edges
        .where((edge) => edge.targetId == nodeId)
        .map((edge) => edge.sourceId)
        .toList();
    
    return nodes.where((node) => prevNodeIds.contains(node.id)).toList();
  }
  
  /// 检查是否有环
  bool hasCycle() {
    final visited = <String>{};
    final recursionStack = <String>{};
    
    bool hasCycleDFS(String nodeId) {
      visited.add(nodeId);
      recursionStack.add(nodeId);
      
      final nextNodes = getNextNodes(nodeId);
      for (final nextNode in nextNodes) {
        if (!visited.contains(nextNode.id)) {
          if (hasCycleDFS(nextNode.id)) {
            return true;
          }
        } else if (recursionStack.contains(nextNode.id)) {
          return true;
        }
      }
      
      recursionStack.remove(nodeId);
      return false;
    }
    
    for (final node in nodes) {
      if (!visited.contains(node.id)) {
        if (hasCycleDFS(node.id)) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// 验证工作流定义
  WorkflowValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];
    
    // 检查是否有节点
    if (nodes.isEmpty) {
      errors.add('工作流没有节点');
    }
    
    // 检查是否有起始节点
    if (startNode == null) {
      warnings.add('工作流没有明确的起始节点');
    }
    
    // 检查是否有结束节点
    if (endNode == null) {
      warnings.add('工作流没有明确的结束节点');
    }
    
    // 检查是否有环
    if (hasCycle()) {
      errors.add('工作流存在循环依赖');
    }
    
    // 检查节点连接
    for (final node in nodes) {
      if (node.type != NodeType.start && getPreviousNodes(node.id).isEmpty) {
        warnings.add('节点 ${node.name} 没有前驱节点');
      }
      if (node.type != NodeType.end && getNextNodes(node.id).isEmpty) {
        warnings.add('节点 ${node.name} 没有后续节点');
      }
    }
    
    // 检查边的有效性
    for (final edge in edges) {
      if (getNode(edge.sourceId) == null) {
        errors.add('边的源节点不存在: ${edge.sourceId}');
      }
      if (getNode(edge.targetId) == null) {
        errors.add('边的目标节点不存在: ${edge.targetId}');
      }
    }
    
    if (errors.isNotEmpty) {
      return WorkflowValidationResult.invalid(errors, warnings: warnings);
    }
    
    return WorkflowValidationResult.valid(warnings: warnings);
  }
  
  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'nodes': nodes.map((n) => n.toJson()).toList(),
      'edges': edges.map((e) => e.toJson()).toList(),
      'variables': variables.map((k, v) => MapEntry(k, v.toJson())),
      'trigger': trigger.toJson(),
      'maxRetries': maxRetries,
      'timeout': timeout?.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'tags': tags,
      'config': config,
    };
  }
  
  /// 从 JSON 反序列化
  factory WorkflowDefinition.fromJson(Map<String, dynamic> json) {
    return WorkflowDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      version: json['version'] as int? ?? 1,
      nodes: (json['nodes'] as List).map((n) => WorkflowNode.fromJson(n as Map<String, dynamic>)).toList(),
      edges: (json['edges'] as List).map((e) => WorkflowEdge.fromJson(e as Map<String, dynamic>)).toList(),
      variables: (json['variables'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, VariableDefinition.fromJson(v as Map<String, dynamic>)),
      ) ?? {},
      trigger: WorkflowTrigger.fromJson(json['trigger'] as Map<String, dynamic>),
      maxRetries: json['maxRetries'] as int? ?? 3,
      timeout: json['timeout'] != null ? Duration(milliseconds: json['timeout'] as int) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
    );
  }
  
  /// 从 JSON 字符串反序列化
  factory WorkflowDefinition.fromJsonString(String jsonString) {
    return WorkflowDefinition.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
  
  /// 序列化为 JSON 字符串
  String toJsonString() => jsonEncode(toJson());
  
  /// 创建副本
  WorkflowDefinition copyWith({
    String? id,
    String? name,
    String? description,
    int? version,
    List<WorkflowNode>? nodes,
    List<WorkflowEdge>? edges,
    Map<String, VariableDefinition>? variables,
    WorkflowTrigger? trigger,
    int? maxRetries,
    Duration? timeout,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    List<String>? tags,
    Map<String, dynamic>? config,
  }) {
    return WorkflowDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      variables: variables ?? this.variables,
      trigger: trigger ?? this.trigger,
      maxRetries: maxRetries ?? this.maxRetries,
      timeout: timeout ?? this.timeout,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      config: config ?? this.config,
    );
  }
  
  @override
  String toString() {
    return 'WorkflowDefinition(id: $id, name: $name, nodes: ${nodes.length})';
  }
}

/// 工作流边（连接）
class WorkflowEdge {
  /// 边 ID
  final String id;
  
  /// 源节点 ID
  final String sourceId;
  
  /// 目标节点 ID
  final String targetId;
  
  /// 条件表达式（可选）
  final String? condition;
  
  /// 标签
  final String? label;
  
  /// 配置
  final Map<String, dynamic> config;
  
  const WorkflowEdge({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.condition,
    this.label,
    this.config = const {},
  });
  
  /// 是否是条件边
  bool get isConditional => condition != null && condition!.isNotEmpty;
  
  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'targetId': targetId,
      'condition': condition,
      'label': label,
      'config': config,
    };
  }
  
  /// 从 JSON 反序列化
  factory WorkflowEdge.fromJson(Map<String, dynamic> json) {
    return WorkflowEdge(
      id: json['id'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      condition: json['condition'] as String?,
      label: json['label'] as String?,
      config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
    );
  }
}

/// 变量定义
class VariableDefinition {
  /// 变量名
  final String name;
  
  /// 变量类型
  final VariableType type;
  
  /// 默认值
  final dynamic defaultValue;
  
  /// 描述
  final String? description;
  
  /// 是否必需
  final bool required;
  
  /// 是否是输入变量
  final bool isInput;
  
  /// 是否是输出变量
  final bool isOutput;
  
  const VariableDefinition({
    required this.name,
    required this.type,
    this.defaultValue,
    this.description,
    this.required = false,
    this.isInput = false,
    this.isOutput = false,
  });
  
  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'defaultValue': defaultValue,
      'description': description,
      'required': required,
      'isInput': isInput,
      'isOutput': isOutput,
    };
  }
  
  /// 从 JSON 反序列化
  factory VariableDefinition.fromJson(Map<String, dynamic> json) {
    return VariableDefinition(
      name: json['name'] as String,
      type: VariableType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VariableType.string,
      ),
      defaultValue: json['defaultValue'],
      description: json['description'] as String?,
      required: json['required'] as bool? ?? false,
      isInput: json['isInput'] as bool? ?? false,
      isOutput: json['isOutput'] as bool? ?? false,
    );
  }
}

/// 变量类型
enum VariableType {
  string,
  number,
  boolean,
  array,
  object,
}

/// 工作流触发器
class WorkflowTrigger {
  /// 触发类型
  final TriggerType type;
  
  /// 触发配置
  final Map<String, dynamic> config;
  
  const WorkflowTrigger({
    required this.type,
    this.config = const {},
  });
  
  /// 手动触发
  factory WorkflowTrigger.manual() {
    return const WorkflowTrigger(type: TriggerType.manual);
  }
  
  /// 定时触发
  factory WorkflowTrigger.schedule(String cronExpression) {
    return WorkflowTrigger(
      type: TriggerType.schedule,
      config: {'cron': cronExpression},
    );
  }
  
  /// 事件触发
  factory WorkflowTrigger.event(String eventType) {
    return WorkflowTrigger(
      type: TriggerType.event,
      config: {'eventType': eventType},
    );
  }
  
  /// 消息触发
  factory WorkflowTrigger.message(String topic) {
    return WorkflowTrigger(
      type: TriggerType.message,
      config: {'topic': topic},
    );
  }
  
  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'config': config,
    };
  }
  
  /// 从 JSON 反序列化
  factory WorkflowTrigger.fromJson(Map<String, dynamic> json) {
    return WorkflowTrigger(
      type: TriggerType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TriggerType.manual,
      ),
      config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
    );
  }
}

/// 触发类型
enum TriggerType {
  /// 手动触发
  manual,
  
  /// 定时触发
  schedule,
  
  /// 事件触发
  event,
  
  /// 消息触发
  message,
}

/// 工作流验证结果
class WorkflowValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const WorkflowValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  
  factory WorkflowValidationResult.valid({List<String> warnings = const []}) {
    return WorkflowValidationResult(isValid: true, warnings: warnings);
  }
  
  factory WorkflowValidationResult.invalid(List<String> errors, {List<String> warnings = const []}) {
    return WorkflowValidationResult(isValid: false, errors: errors, warnings: warnings);
  }
}