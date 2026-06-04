/// 会话上下文容器
/// 
/// 每个会话独立的上下文对象，包含：
/// - 消息历史
/// - 启用的技能
/// - MCP 服务器配置
/// - 记忆作用域
/// - 会话级变量
/// - 知识库关联
library;

import 'dart:async';
import '../../../core/storage/database.dart' show Session, Message;
import '../../skill/domain/skill.dart';

/// 会话上下文
class SessionContext {
  /// 会话 ID
  final String sessionId;
  
  /// 会话配置
  final Session session;
  
  /// 消息历史
  final List<Message> messages;
  
  /// 启用的技能集合
  final Map<String, Skill> enabledSkills;
  
  /// 启用的 MCP 服务器 ID
  final Set<String> enabledMcpServers;
  
  /// 会话级变量
  final Map<String, dynamic> variables;
  
  /// 记忆作用域
  final MemoryScope memoryScope;
  
  /// 关联的知识库 ID
  final String? knowledgeBaseId;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后活跃时间
  DateTime lastActiveAt;
  
  /// 是否已锁定（防止并发修改）
  bool _isLocked = false;
  
  /// 锁定的 Completer
  Completer<void>? _lockCompleter;
  
  SessionContext({
    required this.sessionId,
    required this.session,
    List<Message>? messages,
    Map<String, Skill>? enabledSkills,
    Set<String>? enabledMcpServers,
    Map<String, dynamic>? variables,
    MemoryScope? memoryScope,
    this.knowledgeBaseId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) : messages = messages ?? [],
       enabledSkills = enabledSkills ?? {},
       enabledMcpServers = enabledMcpServers ?? {},
       variables = variables ?? {},
       memoryScope = memoryScope ?? MemoryScope(sessionId: sessionId),
       createdAt = createdAt ?? DateTime.now(),
       lastActiveAt = lastActiveAt ?? DateTime.now();
  
  /// 是否已锁定
  bool get isLocked => _isLocked;
  
  /// 获取会话锁
  Future<void> lock({Duration timeout = const Duration(seconds: 30)}) async {
    if (!_isLocked) {
      _isLocked = true;
      return;
    }
    
    // 等待锁释放
    _lockCompleter ??= Completer<void>();
    
    try {
      await _lockCompleter!.future.timeout(timeout);
      _isLocked = true;
    } on TimeoutException {
      throw SessionContextException('获取会话锁超时: $sessionId');
    }
  }
  
  /// 释放会话锁
  void unlock() {
    _isLocked = false;
    _lockCompleter?.complete();
    _lockCompleter = null;
  }
  
  /// 创建快照
  SessionSnapshot snapshot() {
    return SessionSnapshot(
      sessionId: sessionId,
      sessionData: session,
      messages: List.from(messages),
      enabledSkillIds: enabledSkills.keys.toList(),
      enabledMcpServerIds: enabledMcpServers.toList(),
      variables: Map.from(variables),
      knowledgeBaseId: knowledgeBaseId,
      createdAt: createdAt,
      snapshotTime: DateTime.now(),
    );
  }
  
  /// 从快照恢复
  void restore(SessionSnapshot snapshot) {
    messages.clear();
    messages.addAll(snapshot.messages);
    
    variables.clear();
    variables.addAll(snapshot.variables);
  }
  
  /// 添加消息
  void addMessage(Message message) {
    messages.add(message);
    lastActiveAt = DateTime.now();
  }
  
  /// 清空消息
  void clearMessages() {
    messages.clear();
    lastActiveAt = DateTime.now();
  }
  
  /// 设置变量
  void setVariable(String key, dynamic value) {
    variables[key] = value;
    lastActiveAt = DateTime.now();
  }
  
  /// 获取变量
  dynamic getVariable(String key) {
    return variables[key];
  }
  
  /// 启用技能
  void enableSkill(Skill skill) {
    enabledSkills[skill.id] = skill;
    lastActiveAt = DateTime.now();
  }
  
  /// 禁用技能
  void disableSkill(String skillId) {
    enabledSkills.remove(skillId);
    lastActiveAt = DateTime.now();
  }
  
  /// 启用 MCP 服务器
  void enableMcpServer(String serverId) {
    enabledMcpServers.add(serverId);
    lastActiveAt = DateTime.now();
  }
  
  /// 禁用 MCP 服务器
  void disableMcpServer(String serverId) {
    enabledMcpServers.remove(serverId);
    lastActiveAt = DateTime.now();
  }
  
  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'messageCount': messages.length,
      'enabledSkillIds': enabledSkills.keys.toList(),
      'enabledMcpServerIds': enabledMcpServers.toList(),
      'variables': variables,
      'knowledgeBaseId': knowledgeBaseId,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
    };
  }
  
  @override
  String toString() {
    return 'SessionContext(sessionId: $sessionId, messages: ${messages.length}, skills: ${enabledSkills.length})';
  }
}

/// 记忆作用域
/// 
/// 管理会话级和全局记忆
class MemoryScope {
  /// 会话 ID
  final String sessionId;
  
  /// 会话级记忆
  final Map<String, dynamic> _sessionMemory = {};
  
  /// 全局记忆引用
  final Map<String, dynamic> _globalMemory = {};
  
  MemoryScope({required this.sessionId});
  
  /// 设置会话级记忆
  void setSessionMemory(String key, dynamic value) {
    _sessionMemory[key] = value;
  }
  
  /// 获取会话级记忆
  dynamic getSessionMemory(String key) {
    return _sessionMemory[key];
  }
  
  /// 设置全局记忆
  void setGlobalMemory(String key, dynamic value) {
    _globalMemory[key] = value;
  }
  
  /// 获取全局记忆
  dynamic getGlobalMemory(String key) {
    return _globalMemory[key];
  }
  
  /// 获取所有会话级记忆
  Map<String, dynamic> get allSessionMemory => Map.unmodifiable(_sessionMemory);
  
  /// 获取所有全局记忆
  Map<String, dynamic> get allGlobalMemory => Map.unmodifiable(_globalMemory);
  
  /// 清空会话级记忆
  void clearSessionMemory() {
    _sessionMemory.clear();
  }
}

/// 会话快照
class SessionSnapshot {
  final String sessionId;
  final Session sessionData;
  final List<Message> messages;
  final List<String> enabledSkillIds;
  final List<String> enabledMcpServerIds;
  final Map<String, dynamic> variables;
  final String? knowledgeBaseId;
  final DateTime createdAt;
  final DateTime snapshotTime;
  
  const SessionSnapshot({
    required this.sessionId,
    required this.sessionData,
    required this.messages,
    required this.enabledSkillIds,
    required this.enabledMcpServerIds,
    required this.variables,
    this.knowledgeBaseId,
    required this.createdAt,
    required this.snapshotTime,
  });
  
  /// 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'messageCount': messages.length,
      'enabledSkillIds': enabledSkillIds,
      'enabledMcpServerIds': enabledMcpServerIds,
      'variables': variables,
      'knowledgeBaseId': knowledgeBaseId,
      'createdAt': createdAt.toIso8601String(),
      'snapshotTime': snapshotTime.toIso8601String(),
    };
  }
  
  /// 从 JSON 反序列化
  factory SessionSnapshot.fromJson(Map<String, dynamic> json) {
    return SessionSnapshot(
      sessionId: json['sessionId'] as String,
      sessionData: Session.fromJson(json['sessionData'] as Map<String, dynamic>),
      messages: (json['messages'] as List).map((m) => Message.fromJson(m as Map<String, dynamic>)).toList(),
      enabledSkillIds: List<String>.from(json['enabledSkillIds'] as List),
      enabledMcpServerIds: List<String>.from(json['enabledMcpServerIds'] as List),
      variables: Map<String, dynamic>.from(json['variables'] as Map),
      knowledgeBaseId: json['knowledgeBaseId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      snapshotTime: DateTime.parse(json['snapshotTime'] as String),
    );
  }
  
  /// 快照年龄
  Duration get age => DateTime.now().difference(snapshotTime);
}

/// 会话上下文异常
class SessionContextException implements Exception {
  final String message;
  
  const SessionContextException(this.message);
  
  @override
  String toString() => 'SessionContextException: $message';
}