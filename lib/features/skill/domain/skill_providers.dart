import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'skill.dart';
import 'skill_dispatcher.dart';

/// 技能调度器 Provider
final skillDispatcherProvider = Provider<SkillDispatcher>((ref) {
  return SkillDispatcher();
});

/// 所有技能 Provider
final allSkillsProvider = Provider<List<Skill>>((ref) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getAllSkills();
});

/// 按类型筛选的技能 Provider
final skillsByTypeProvider = Provider.family<List<Skill>, SkillType>((ref, type) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getSkillsByType(type);
});

/// 按分类筛选的技能 Provider
final skillsByCategoryProvider = Provider.family<List<Skill>, String>((ref, category) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getSkillsByCategory(category);
});

/// 技能搜索 Provider
final skillSearchProvider = Provider.family<List<Skill>, String>((ref, query) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.searchSkills(query);
});

/// 单个技能 Provider
final skillProvider = Provider.family<Skill?, String>((ref, skillId) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getSkill(skillId);
});

/// 技能调用历史 Provider
final skillInvocationHistoryProvider = Provider.family<List<SkillInvocation>, String?>((ref, skillId) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getInvocationHistory(skillId: skillId);
});

/// 技能统计 Provider
final skillStatisticsProvider = Provider.family<Map<String, dynamic>, String>((ref, skillId) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getSkillStatistics(skillId);
});

/// 所有技能统计 Provider
final allSkillStatisticsProvider = Provider<Map<String, Map<String, dynamic>>>((ref) {
  final dispatcher = ref.watch(skillDispatcherProvider);
  return dispatcher.getAllStatistics();
});
