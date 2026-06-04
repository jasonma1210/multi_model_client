import 'dart:async';
import 'package:flutter/foundation.dart';
import 'skill.dart';
import 'native_skills/native_skills.dart';
import 'plugin_manifest.dart';
import 'plugin_sandbox.dart';

/// 技能调用记录
class SkillInvocation {
  final String id;
  final String skillId;
  final String skillName;
  final Map<String, dynamic> params;
  final SkillResult result;
  final DateTime timestamp;
  final Duration duration;
  final bool isPlugin;

  SkillInvocation({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.params,
    required this.result,
    required this.timestamp,
    required this.duration,
    this.isPlugin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'skillName': skillName,
      'params': params,
      'result': result.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'durationMs': duration.inMilliseconds,
      'isPlugin': isPlugin,
    };
  }
}

/// 技能事件类型
enum SkillEventType {
  /// 技能已注册
  registered,
  
  /// 技能已注销
  unregistered,
  
  /// 技能已启用
  enabled,
  
  /// 技能已禁用
  disabled,
  
  /// 技能执行开始
  executionStarted,
  
  /// 技能执行完成
  executionCompleted,
  
  /// 技能执行失败
  executionFailed,
}

/// 技能事件
class SkillEvent {
  final SkillEventType type;
  final String skillId;
  final String? message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  
  const SkillEvent({
    required this.type,
    required this.skillId,
    this.message,
    this.data,
    required this.timestamp,
  });
}

/// 技能调度器
/// 管理所有技能的注册、调度和执行
class SkillDispatcher {
  static final SkillDispatcher _instance = SkillDispatcher._internal();
  factory SkillDispatcher() => _instance;
  SkillDispatcher._internal() {
    _registerBuiltinSkills();
  }

  final Map<String, Skill> _skills = {};
  final Map<String, PluginManifest> _pluginManifests = {};
  final Map<String, bool> _skillEnabledStatus = {};
  final List<SkillInvocation> _invocationHistory = [];
  final _maxHistorySize = 100;

  final StreamController<SkillInvocation> _invocationController =
      StreamController<SkillInvocation>.broadcast();
  
  final StreamController<SkillEvent> _eventController =
      StreamController<SkillEvent>.broadcast();

  /// 技能调用流
  Stream<SkillInvocation> get invocationStream => _invocationController.stream;
  
  /// 技能事件流
  Stream<SkillEvent> get eventStream => _eventController.stream;

  /// 注册内置技能
  void _registerBuiltinSkills() {
    registerSkill(const CalculatorSkill());
    registerSkill(const CurrentTimeSkill());
    registerSkill(const SearchSkill());
    // 注册所有内置专家
    for (final expert in getAllBuiltinExperts()) {
      registerSkill(expert);
    }
  }

  /// 注册技能
  void registerSkill(Skill skill, {PluginManifest? manifest}) {
    _skills[skill.id] = skill;
    _skillEnabledStatus[skill.id] = true;
    
    if (manifest != null) {
      _pluginManifests[skill.id] = manifest;
    }
    
    _emitEvent(SkillEvent(
      type: SkillEventType.registered,
      skillId: skill.id,
      message: '技能已注册: ${skill.name}',
      timestamp: DateTime.now(),
    ));
    
    debugPrint('Skill registered: ${skill.id}');
  }

  /// 注销技能
  void unregisterSkill(String skillId) {
    final skill = _skills.remove(skillId);
    _pluginManifests.remove(skillId);
    _skillEnabledStatus.remove(skillId);
    
    if (skill != null) {
      _emitEvent(SkillEvent(
        type: SkillEventType.unregistered,
        skillId: skillId,
        message: '技能已注销: ${skill.name}',
        timestamp: DateTime.now(),
      ));
    }
    
    debugPrint('Skill unregistered: $skillId');
  }

  /// 获取技能
  Skill? getSkill(String skillId) {
    return _skills[skillId];
  }

  /// 获取所有技能
  List<Skill> getAllSkills() {
    return _skills.values.toList();
  }

  /// 按类型获取技能
  List<Skill> getSkillsByType(SkillType type) {
    return _skills.values.where((s) => s.type == type).toList();
  }

  /// 按分类获取技能
  List<Skill> getSkillsByCategory(String category) {
    return _skills.values.where((s) => s.category == category).toList();
  }
  
  /// 获取所有内置技能
  List<Skill> getBuiltinSkills() {
    return _skills.values.where((s) => s.isBuiltin).toList();
  }
  
  /// 获取所有插件技能
  List<Skill> getPluginSkills() {
    return _skills.values.where((s) => !s.isBuiltin).toList();
  }
  
  /// 获取插件清单
  PluginManifest? getPluginManifest(String skillId) {
    return _pluginManifests[skillId];
  }
  
  /// 检查技能是否启用
  bool isSkillEnabled(String skillId) {
    return _skillEnabledStatus[skillId] ?? false;
  }
  
  /// 启用技能
  void enableSkill(String skillId) {
    if (_skills.containsKey(skillId)) {
      _skillEnabledStatus[skillId] = true;
      _emitEvent(SkillEvent(
        type: SkillEventType.enabled,
        skillId: skillId,
        timestamp: DateTime.now(),
      ));
    }
  }
  
  /// 禁用技能
  void disableSkill(String skillId) {
    if (_skills.containsKey(skillId)) {
      _skillEnabledStatus[skillId] = false;
      _emitEvent(SkillEvent(
        type: SkillEventType.disabled,
        skillId: skillId,
        timestamp: DateTime.now(),
      ));
    }
  }
  
  /// 获取所有启用的技能
  List<Skill> getEnabledSkills() {
    return _skills.entries
        .where((entry) => _skillEnabledStatus[entry.key] ?? false)
        .map((entry) => entry.value)
        .toList();
  }

  /// 搜索技能
  List<Skill> searchSkills(String query) {
    final lowerQuery = query.toLowerCase();
    return _skills.values.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          s.description.toLowerCase().contains(lowerQuery) ||
          (s.tags?.any((t) => t.toLowerCase().contains(lowerQuery)) ?? false);
    }).toList();
  }

  /// 调度执行技能
  Future<SkillResult> dispatch(
    String skillId,
    Map<String, dynamic> params, {
    bool recordInvocation = true,
    bool useSandbox = false,
  }) async {
    final skill = _skills[skillId];
    if (skill == null) {
      throw SkillNotFoundException(skillId);
    }
    
    // 检查技能是否启用
    if (!isSkillEnabled(skillId)) {
      return SkillResult.error('技能已禁用: $skillId');
    }

    final startTime = DateTime.now();
    SkillResult result;
    bool isPlugin = _pluginManifests.containsKey(skillId);

    // 发送执行开始事件
    _emitEvent(SkillEvent(
      type: SkillEventType.executionStarted,
      skillId: skillId,
      timestamp: DateTime.now(),
    ));

    try {
      // 验证参数
      final validatedParams = skill.validateParams(params);

      // 如果使用沙箱且是插件技能
      if (useSandbox && isPlugin) {
        final manifest = _pluginManifests[skillId]!;
        final sandboxConfig = SandboxConfig.fromManifest(manifest);
        final sandbox = PluginSandbox(config: sandboxConfig);
        
        final sandboxResult = await sandbox.execute(
          () => skill.execute(validatedParams),
          operationName: skill.name,
        );
        
        if (sandboxResult.success) {
          result = SkillResult.success(sandboxResult.data);
        } else {
          result = SkillResult.error(sandboxResult.error ?? '沙箱执行失败');
        }
      } else {
        // 直接执行
        result = await skill.execute(validatedParams);
      }
    } on SkillValidationException catch (e) {
      result = SkillResult.error('参数验证失败: ${e.message}');
    } catch (e) {
      result = SkillResult.error('执行失败: $e');
    }

    final duration = DateTime.now().difference(startTime);

    // 发送执行完成/失败事件
    _emitEvent(SkillEvent(
      type: result.success ? SkillEventType.executionCompleted : SkillEventType.executionFailed,
      skillId: skillId,
      message: result.success ? '执行成功' : result.error,
      timestamp: DateTime.now(),
    ));

    // 记录调用
    if (recordInvocation) {
      final invocation = SkillInvocation(
        id: '${startTime.millisecondsSinceEpoch}_$skillId',
        skillId: skillId,
        skillName: skill.name,
        params: params,
        result: result,
        timestamp: startTime,
        duration: duration,
        isPlugin: isPlugin,
      );
      _recordInvocation(invocation);
    }

    return result;
  }

  /// 批量调度技能
  Future<List<SkillResult>> dispatchBatch(
    List<SkillDispatchRequest> requests, {
    bool continueOnError = true,
    bool useSandbox = false,
  }) async {
    final results = <SkillResult>[];

    for (final request in requests) {
      try {
        final result = await dispatch(
          request.skillId, 
          request.params,
          useSandbox: useSandbox,
        );
        results.add(result);

        if (!result.success && !continueOnError) {
          break;
        }
      } catch (e) {
        results.add(SkillResult.error(e.toString()));
        if (!continueOnError) {
          break;
        }
      }
    }

    return results;
  }

  /// 记录调用历史
  void _recordInvocation(SkillInvocation invocation) {
    _invocationHistory.add(invocation);
    _invocationController.add(invocation);

    // 限制历史记录大小
    if (_invocationHistory.length > _maxHistorySize) {
      _invocationHistory.removeAt(0);
    }
  }
  
  /// 发送事件
  void _emitEvent(SkillEvent event) {
    _eventController.add(event);
  }

  /// 获取调用历史
  List<SkillInvocation> getInvocationHistory({String? skillId, int? limit}) {
    var history = List<SkillInvocation>.from(_invocationHistory);

    if (skillId != null) {
      history = history.where((i) => i.skillId == skillId).toList();
    }

    if (limit != null && history.length > limit) {
      history = history.sublist(history.length - limit);
    }

    return history;
  }

  /// 清空调用历史
  void clearInvocationHistory() {
    _invocationHistory.clear();
  }

  /// 获取技能调用统计
  Map<String, dynamic> getSkillStatistics(String skillId) {
    final invocations =
        _invocationHistory.where((i) => i.skillId == skillId).toList();

    if (invocations.isEmpty) {
      return {
        'totalCalls': 0,
        'successCount': 0,
        'errorCount': 0,
        'successRate': 0.0,
        'averageDurationMs': 0,
      };
    }

    final successCount = invocations.where((i) => i.result.success).length;
    final errorCount = invocations.length - successCount;
    final totalDuration = invocations.fold<Duration>(
      Duration.zero,
      (sum, i) => sum + i.duration,
    );

    return {
      'totalCalls': invocations.length,
      'successCount': successCount,
      'errorCount': errorCount,
      'successRate': successCount / invocations.length,
      'averageDurationMs': totalDuration.inMilliseconds / invocations.length,
    };
  }

  /// 获取所有技能调用统计
  Map<String, Map<String, dynamic>> getAllStatistics() {
    final stats = <String, Map<String, dynamic>>{};
    for (final skillId in _skills.keys) {
      stats[skillId] = getSkillStatistics(skillId);
    }
    return stats;
  }

  /// 生成技能调用提示词
  String generateSkillPrompt(String skillId) {
    final skill = _skills[skillId];
    if (skill == null) {
      throw SkillNotFoundException(skillId);
    }

    return skill.getExecutePrompt();
  }

  /// 生成所有技能提示词
  String generateAllSkillsPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('# 可用技能列表');
    buffer.writeln();

    // 按分类分组
    final categories = <String, List<Skill>>{};
    for (final skill in _skills.values) {
      final category = skill.category ?? '其他';
      categories.putIfAbsent(category, () => []).add(skill);
    }

    for (final entry in categories.entries) {
      buffer.writeln('## ${entry.key}');
      buffer.writeln();

      for (final skill in entry.value) {
        buffer.writeln('### ${skill.name}');
        buffer.writeln('- ID: `${skill.id}`');
        buffer.writeln('- 描述: ${skill.description}');
        buffer.writeln('- 类型: ${skill.type.name}');
        buffer.writeln('- 来源: ${_pluginManifests.containsKey(skill.id) ? '插件' : '内置'}');
        if (skill.tags != null && skill.tags!.isNotEmpty) {
          buffer.writeln('- 标签: ${skill.tags!.join(', ')}');
        }
        buffer.writeln();
      }
    }

    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln('要使用技能，请使用以下格式调用:');
    buffer.writeln('```json');
    buffer.writeln('{');
    buffer.writeln('  "skill": "技能ID",');
    buffer.writeln('  "params": {');
    buffer.writeln('    "参数名": "参数值"');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln('```');

    return buffer.toString();
  }
  
  /// 获取插件统计信息
  Map<String, dynamic> getPluginStatistics() {
    final pluginSkills = getPluginSkills();
    final builtinSkills = getBuiltinSkills();
    
    return {
      'totalSkills': _skills.length,
      'builtinSkills': builtinSkills.length,
      'pluginSkills': pluginSkills.length,
      'enabledSkills': getEnabledSkills().length,
      'disabledSkills': _skills.length - getEnabledSkills().length,
      'totalInvocations': _invocationHistory.length,
      'pluginInvocations': _invocationHistory.where((i) => i.isPlugin).length,
    };
  }

  /// 释放资源
  void dispose() {
    _invocationController.close();
    _eventController.close();
  }
}

/// 技能调度请求
class SkillDispatchRequest {
  final String skillId;
  final Map<String, dynamic> params;
  final bool useSandbox;

  const SkillDispatchRequest({
    required this.skillId,
    required this.params,
    this.useSandbox = false,
  });
}