import 'dart:async';
import 'package:flutter/foundation.dart';
import 'skill.dart';
import 'native_skills/native_skills.dart';

/// 技能调用记录
class SkillInvocation {
  final String id;
  final String skillId;
  final String skillName;
  final Map<String, dynamic> params;
  final SkillResult result;
  final DateTime timestamp;
  final Duration duration;

  SkillInvocation({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.params,
    required this.result,
    required this.timestamp,
    required this.duration,
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
    };
  }
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
  final List<SkillInvocation> _invocationHistory = [];
  final _maxHistorySize = 100;

  final StreamController<SkillInvocation> _invocationController =
      StreamController<SkillInvocation>.broadcast();

  /// 技能调用流
  Stream<SkillInvocation> get invocationStream => _invocationController.stream;

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
  void registerSkill(Skill skill) {
    _skills[skill.id] = skill;
    debugPrint('Skill registered: ${skill.id}');
  }

  /// 注销技能
  void unregisterSkill(String skillId) {
    _skills.remove(skillId);
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
  }) async {
    final skill = _skills[skillId];
    if (skill == null) {
      throw SkillNotFoundException(skillId);
    }

    final startTime = DateTime.now();
    SkillResult result;

    try {
      // 验证参数
      final validatedParams = skill.validateParams(params);

      // 执行技能
      result = await skill.execute(validatedParams);
    } on SkillValidationException catch (e) {
      result = SkillResult.error('参数验证失败: ${e.message}');
    } catch (e) {
      result = SkillResult.error('执行失败: $e');
    }

    final duration = DateTime.now().difference(startTime);

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
      );
      _recordInvocation(invocation);
    }

    return result;
  }

  /// 批量调度技能
  Future<List<SkillResult>> dispatchBatch(
    List<SkillDispatchRequest> requests, {
    bool continueOnError = true,
  }) async {
    final results = <SkillResult>[];

    for (final request in requests) {
      try {
        final result = await dispatch(request.skillId, request.params);
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

  /// 释放资源
  void dispose() {
    _invocationController.close();
  }
}

/// 技能调度请求
class SkillDispatchRequest {
  final String skillId;
  final Map<String, dynamic> params;

  const SkillDispatchRequest({
    required this.skillId,
    required this.params,
  });
}
