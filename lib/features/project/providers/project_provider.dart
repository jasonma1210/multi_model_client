/// 项目工作区 Provider（v0.42.0）
///
/// 管理 Project 实体的 CRUD 与状态。
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/database.dart';
import '../../model/providers/thinking_budget_provider.dart' show appDatabaseProvider;

/// 项目列表 Provider
final projectsProvider =
    StateNotifierProvider<ProjectsController, List<Project>>((ref) {
  final controller = ProjectsController(ref);
  controller.load();
  return controller;
});

/// 单个项目 Provider（Family）
final projectByIdProvider =
    Provider.family<Project?, String>((ref, id) {
  final projects = ref.watch(projectsProvider);
  try {
    return projects.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});

/// 项目控制器
class ProjectsController extends StateNotifier<List<Project>> {
  final Ref _ref;
  static const _uuid = Uuid();

  ProjectsController(this._ref) : super(const []);

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  /// 加载所有项目
  Future<void> load({bool includeArchived = false}) async {
    state = await _db.getAllProjects(includeArchived: includeArchived);
  }

  /// 创建项目
  Future<Project> create({
    required String name,
    String? description,
    String icon = '📁',
    String color = '#6750A4',
    String? systemPrompt,
    String? knowledgeBaseId,
    String? defaultModelConfigId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.createProject(ProjectsCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      icon: Value(icon),
      color: Value(color),
      systemPrompt: Value(systemPrompt),
      knowledgeBaseId: Value(knowledgeBaseId),
      defaultModelConfigId: Value(defaultModelConfigId),
      createdAt: now,
      updatedAt: now,
    ));
    await load();
    return (await _db.getProjectById(id))!;
  }

  /// 更新项目
  Future<void> update(Project project) async {
    await _db.updateProject(ProjectsCompanion(
      id: Value(project.id),
      name: Value(project.name),
      description: Value(project.description),
      icon: Value(project.icon),
      color: Value(project.color),
      systemPrompt: Value(project.systemPrompt),
      knowledgeBaseId: Value(project.knowledgeBaseId),
      defaultModelConfigId: Value(project.defaultModelConfigId),
      mcpServers: Value(project.mcpServers),
      temperature: Value(project.temperature),
      maxContextMessages: Value(project.maxContextMessages),
      sortOrder: Value(project.sortOrder),
      isArchived: Value(project.isArchived),
      createdAt: Value(project.createdAt),
      updatedAt: Value(DateTime.now()),
    ));
    await load();
  }

  /// 归档/取消归档
  Future<void> setArchived(String projectId, bool archived) async {
    final project = await _db.getProjectById(projectId);
    if (project == null) return;
    await update(project.copyWith(
      isArchived: archived,
      updatedAt: DateTime.now(),
    ));
  }

  /// 删除项目
  Future<void> delete(String projectId) async {
    await _db.deleteProject(projectId);
    await load();
  }
}
