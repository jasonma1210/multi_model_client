// v0.43.0 实现 A2A (Agent-to-Agent) 协议 v0.2
//
// 参考：https://a2a-protocol.org/latest/specification/
// 与 MCP 的关系：
// - MCP：Agent ↔ 工具（资源/提示/工具）
// - A2A：Agent ↔ Agent（任务委派/状态同步/流式响应）
//
// 核心对象：
// - AgentCard: Agent 自描述（能力、技能、接口）
// - Task: 委派给 Agent 的任务（带生命周期）
// - Message: 任务中的消息
// - Part: 消息内容（text / file / data）
// - Artifact: 任务产出物

/// A2A 协议版本
const a2aVersion = '0.2.0';

// ════════════════════════════════════════════════════════════════════════════
//  Agent Card
// ════════════════════════════════════════════════════════════════════════════

/// Agent 能力
class AgentCapabilities {
  /// 是否支持流式响应
  final bool streaming;

  /// 是否支持 push notification
  final bool pushNotifications;

  /// 是否返回状态转换历史
  final bool stateTransitionHistory;

  const AgentCapabilities({
    this.streaming = true,
    this.pushNotifications = false,
    this.stateTransitionHistory = false,
  });

  Map<String, dynamic> toJson() => {
        'streaming': streaming,
        'pushNotifications': pushNotifications,
        'stateTransitionHistory': stateTransitionHistory,
      };

  factory AgentCapabilities.fromJson(Map<String, dynamic> json) => AgentCapabilities(
        streaming: json['streaming'] as bool? ?? true,
        pushNotifications: json['pushNotifications'] as bool? ?? false,
        stateTransitionHistory: json['stateTransitionHistory'] as bool? ?? false,
      );
}

/// Agent 技能（描述能做什么）
class AgentSkill {
  final String id;
  final String name;
  final String description;
  final List<String>? tags; // ['research', 'analysis']
  final List<String>? examples; // 示例输入
  final List<AgentSkillInput>? inputModes;
  final List<AgentSkillOutput>? outputModes;

  const AgentSkill({
    required this.id,
    required this.name,
    required this.description,
    this.tags,
    this.examples,
    this.inputModes,
    this.outputModes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (tags != null) 'tags': tags,
        if (examples != null) 'examples': examples,
        if (inputModes != null) 'inputModes': inputModes!.map((m) => m.name).toList(),
        if (outputModes != null) 'outputModes': outputModes!.map((m) => m.name).toList(),
      };

  factory AgentSkill.fromJson(Map<String, dynamic> json) => AgentSkill(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
        examples: (json['examples'] as List<dynamic>?)?.cast<String>(),
      );
}

enum AgentSkillInput { text, file, data }
enum AgentSkillOutput { text, file, data }

/// Agent 接口（URL + 传输协议）
class AgentInterface {
  final String url;
  final String protocol; // 'jsonrpc' | 'grpc' | 'http+json'

  const AgentInterface({required this.url, this.protocol = 'jsonrpc'});

  Map<String, dynamic> toJson() => {'url': url, 'protocol': protocol};
  factory AgentInterface.fromJson(Map<String, dynamic> json) =>
      AgentInterface(url: json['url'] as String, protocol: json['protocol'] as String? ?? 'jsonrpc');
}

/// Agent Card - Agent 自描述
class AgentCard {
  final String name;
  final String description;
  final String url;
  final String version;
  final AgentCapabilities capabilities;
  final List<AgentSkill> skills;
  final List<AgentInterface> interfaces;
  final Map<String, dynamic>? provider; // {organization, url}
  final List<String>? defaultInputModes;
  final List<String>? defaultOutputModes;

  const AgentCard({
    required this.name,
    required this.description,
    required this.url,
    this.version = a2aVersion,
    this.capabilities = const AgentCapabilities(),
    this.skills = const [],
    this.interfaces = const [],
    this.provider,
    this.defaultInputModes,
    this.defaultOutputModes,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'url': url,
        'version': version,
        'capabilities': capabilities.toJson(),
        'skills': skills.map((s) => s.toJson()).toList(),
        'interfaces': interfaces.map((i) => i.toJson()).toList(),
        if (provider != null) 'provider': provider,
        if (defaultInputModes != null) 'defaultInputModes': defaultInputModes,
        if (defaultOutputModes != null) 'defaultOutputModes': defaultOutputModes,
      };

  factory AgentCard.fromJson(Map<String, dynamic> json) => AgentCard(
        name: json['name'] as String,
        description: json['description'] as String,
        url: json['url'] as String,
        version: json['version'] as String? ?? a2aVersion,
        capabilities: json['capabilities'] != null
            ? AgentCapabilities.fromJson(json['capabilities'] as Map<String, dynamic>)
            : const AgentCapabilities(),
        skills: (json['skills'] as List<dynamic>?)
                ?.map((s) => AgentSkill.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
        interfaces: (json['interfaces'] as List<dynamic>?)
                ?.map((i) => AgentInterface.fromJson(i as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

// ════════════════════════════════════════════════════════════════════════════
//  Part
// ════════════════════════════════════════════════════════════════════════════

/// 消息内容 - 多种 Part 类型
sealed class Part {
  const Part();
  Map<String, dynamic> toJson();
}

class TextPart extends Part {
  final String text;
  const TextPart(this.text);
  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};
}

class FilePart extends Part {
  final String? fileUri; // 或 base64
  final String? mimeType;
  final String? name;
  const FilePart({this.fileUri, this.mimeType, this.name});
  @override
  Map<String, dynamic> toJson() => {
        'type': 'file',
        if (fileUri != null) 'file': {'uri': fileUri, 'mimeType': mimeType, 'name': name},
      };
}

class DataPart extends Part {
  final Map<String, dynamic> data;
  const DataPart(this.data);
  @override
  Map<String, dynamic> toJson() => {'type': 'data', 'data': data};
}

// ════════════════════════════════════════════════════════════════════════════
//  Message + Artifact
// ════════════════════════════════════════════════════════════════════════════

/// 消息
class A2AMessage {
  final String messageId;
  final String role; // 'user' | 'agent'
  final List<Part> parts;
  final String? contextId; // 任务上下文 ID
  final String? taskId; // 关联任务 ID
  final String? referenceTaskIds; // 引用的历史任务
  final String? metadata;

  const A2AMessage({
    required this.messageId,
    required this.role,
    required this.parts,
    this.contextId,
    this.taskId,
    this.referenceTaskIds,
    this.metadata,
  });

  String get text => parts.whereType<TextPart>().map((p) => p.text).join('\n');

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'role': role,
        'parts': parts.map((p) => p.toJson()).toList(),
        if (contextId != null) 'contextId': contextId,
        if (taskId != null) 'taskId': taskId,
        if (referenceTaskIds != null) 'referenceTaskIds': referenceTaskIds,
        if (metadata != null) 'metadata': metadata,
      };

  factory A2AMessage.fromJson(Map<String, dynamic> json) {
    final partsJson = json['parts'] as List<dynamic>? ?? [];
    return A2AMessage(
      messageId: json['messageId'] as String,
      role: json['role'] as String,
      parts: partsJson.map((p) => _parsePart(p as Map<String, dynamic>)).toList(),
      contextId: json['contextId'] as String?,
      taskId: json['taskId'] as String?,
      referenceTaskIds: json['referenceTaskIds'] as String?,
      metadata: json['metadata'] as String?,
    );
  }

  static Part _parsePart(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'text') return TextPart(json['text'] as String? ?? '');
    if (type == 'file') {
      final file = json['file'] as Map<String, dynamic>?;
      return FilePart(
        fileUri: file?['uri'] as String?,
        mimeType: file?['mimeType'] as String?,
        name: file?['name'] as String?,
      );
    }
    if (type == 'data') return DataPart(json['data'] as Map<String, dynamic>? ?? {});
    return TextPart('');
  }
}

/// 任务产出物
class Artifact {
  final String artifactId;
  final String? name;
  final String? description;
  final List<Part> parts;
  final Map<String, dynamic>? metadata;

  const Artifact({
    required this.artifactId,
    required this.parts,
    this.name,
    this.description,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'artifactId': artifactId,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        'parts': parts.map((p) => p.toJson()).toList(),
        if (metadata != null) 'metadata': metadata,
      };

  factory Artifact.fromJson(Map<String, dynamic> json) {
    final partsJson = json['parts'] as List<dynamic>? ?? [];
    return Artifact(
      artifactId: json['artifactId'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      parts: partsJson.map((p) => A2AMessage._parsePart(p as Map<String, dynamic>)).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Task
// ════════════════════════════════════════════════════════════════════════════

/// 任务状态
enum TaskState {
  submitted, // 已提交
  working, // 处理中
  inputRequired, // 需要用户输入
  completed, // 已完成
  failed, // 失败
  canceled, // 已取消
  unknown;

  String get wireName => name;

  static TaskState fromWireName(String name) {
    return TaskState.values.firstWhere(
      (s) => s.name == name,
      orElse: () => TaskState.unknown,
    );
  }
}

/// 任务状态对象
class TaskStatus {
  final TaskState state;
  final A2AMessage? message; // 状态变化时附带的 message
  final String? reason; // 失败原因
  final DateTime? timestamp;

  const TaskStatus({
    required this.state,
    this.message,
    this.reason,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'state': state.name,
        if (message != null) 'message': message!.toJson(),
        if (reason != null) 'reason': reason,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };

  factory TaskStatus.fromJson(Map<String, dynamic> json) => TaskStatus(
        state: TaskState.fromWireName(json['state'] as String? ?? 'unknown'),
        message: json['message'] != null ? A2AMessage.fromJson(json['message'] as Map<String, dynamic>) : null,
        reason: json['reason'] as String?,
        timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp'] as String) : null,
      );
}

/// 任务 - A2A 核心对象
class A2ATask {
  final String id;
  final String contextId; // 会话上下文 ID
  final TaskStatus status;
  final List<A2AMessage> history;
  final List<Artifact> artifacts;
  final Map<String, dynamic>? metadata;

  const A2ATask({
    required this.id,
    required this.contextId,
    required this.status,
    this.history = const [],
    this.artifacts = const [],
    this.metadata,
  });

  TaskState get state => status.state;

  A2ATask copyWith({
    TaskStatus? status,
    List<A2AMessage>? history,
    List<Artifact>? artifacts,
  }) {
    return A2ATask(
      id: id,
      contextId: contextId,
      status: status ?? this.status,
      history: history ?? this.history,
      artifacts: artifacts ?? this.artifacts,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contextId': contextId,
        'status': status.toJson(),
        'history': history.map((m) => m.toJson()).toList(),
        'artifacts': artifacts.map((a) => a.toJson()).toList(),
        if (metadata != null) 'metadata': metadata,
      };

  factory A2ATask.fromJson(Map<String, dynamic> json) {
    final historyJson = json['history'] as List<dynamic>? ?? [];
    final artifactsJson = json['artifacts'] as List<dynamic>? ?? [];
    return A2ATask(
      id: json['id'] as String,
      contextId: json['contextId'] as String,
      status: TaskStatus.fromJson(json['status'] as Map<String, dynamic>),
      history: historyJson.map((m) => A2AMessage.fromJson(m as Map<String, dynamic>)).toList(),
      artifacts: artifactsJson.map((a) => Artifact.fromJson(a as Map<String, dynamic>)).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
