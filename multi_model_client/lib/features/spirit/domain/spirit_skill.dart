/// 名灵回响 - 名灵专家技能
///
/// 将蒸馏完成的 SpiritPersona 动态注册为 ExpertSkill
/// 通过 system prompt 注入实现角色扮演
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';

import '../../skill/domain/skill.dart';
import '../../skill/domain/skill_dispatcher.dart';
import 'spirit_persona.dart';

/// 名灵专家技能
///
/// 与内置 ExpertSkill 不同，名灵技能是动态创建的，
/// 其 expertPrompt 来自蒸馏结果，并可绑定克隆音色
class SpiritExpertSkill extends Skill {
  /// 关联的名灵角色
  final SpiritPersona persona;

  SpiritExpertSkill({
    required this.persona,
  }) : super(
          id: 'spirit.${persona.id}',
          name: '${persona.avatarEmoji} ${persona.nickname}',
          description: persona.description ?? '${persona.domain}领域的${persona.nickname}数字分身',
          type: SkillType.expert,
          isBuiltin: false,
          expertPrompt: persona.distilledPrompt ?? '',
          emoji: persona.avatarEmoji,
          domain: persona.domain,
          category: '名灵回响 Spirit Echo',
          tags: ['名灵', '角色扮演', persona.domain, persona.nickname],
        );

  @override
  Future<SkillResult> execute(Map<String, dynamic> params) async {
    if (persona.distilledPrompt == null || persona.distilledPrompt!.isEmpty) {
      return SkillResult.error('名灵角色尚未完成蒸馏');
    }

    if (!persona.isReady) {
      return SkillResult.error('名灵角色状态异常: ${persona.statusText}');
    }

    return SkillResult.success({
      'systemPrompt': persona.distilledPrompt,
      'expertName': persona.nickname,
      'spiritId': persona.id,
      'clonedVoiceId': persona.clonedVoiceId,
      'mimoVoiceId': persona.mimoVoiceId,
    }, metadata: {
      'type': 'spirit',
      'spiritId': persona.id,
      'nickname': persona.nickname,
      'domain': persona.domain,
      'hasClonedVoice': persona.clonedVoiceId != null,
    });
  }

  /// 更新关联的 persona（如蒸馏完成后）
  SpiritExpertSkill updatePersona(SpiritPersona newPersona) {
    return SpiritExpertSkill(persona: newPersona);
  }
}

/// 名灵技能管理器
///
/// 管理动态注册/注销名灵技能到 SkillDispatcher
class SpiritSkillManager {
  static const String _tag = 'SpiritSkillManager';

  /// 已注册的名灵技能缓存
  final Map<String, SpiritExpertSkill> _registeredSkills = {};

  /// 注册名灵技能到调度器
  void registerSpiritSkill(SpiritPersona persona, SkillDispatcher dispatcher) {
    if (!persona.isReady) {
      debugPrint('[$_tag] 名灵未就绪，跳过注册: ${persona.nickname}');
      return;
    }

    final skill = SpiritExpertSkill(persona: persona);
    dispatcher.registerSkill(skill);
    _registeredSkills[persona.id] = skill;
    debugPrint('[$_tag] 注册名灵技能: ${persona.nickname} (${persona.id})');
  }

  /// 注销名灵技能
  void unregisterSpiritSkill(String personaId, SkillDispatcher dispatcher) {
    final skill = _registeredSkills[personaId];
    if (skill != null) {
      dispatcher.unregisterSkill(skill.id);
      _registeredSkills.remove(personaId);
      debugPrint('[$_tag] 注销名灵技能: $personaId');
    }
  }

  /// 批量注册就绪的名灵
  void registerAllReady(List<SpiritPersona> personas, SkillDispatcher dispatcher) {
    for (final persona in personas) {
      if (persona.isReady) {
        registerSpiritSkill(persona, dispatcher);
      }
    }
  }

  /// 获取已注册的名灵技能
  SpiritExpertSkill? getRegisteredSkill(String personaId) {
    return _registeredSkills[personaId];
  }

  /// 获取所有已注册的名灵技能
  List<SpiritExpertSkill> getAllRegisteredSkills() {
    return _registeredSkills.values.toList();
  }

  /// 清除所有注册
  void clearAll(SkillDispatcher dispatcher) {
    for (final skill in _registeredSkills.values) {
      dispatcher.unregisterSkill(skill.id);
    }
    _registeredSkills.clear();
    debugPrint('[$_tag] 清除所有名灵技能注册');
  }
}
