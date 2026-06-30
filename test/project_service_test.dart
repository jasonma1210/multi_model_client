/// ProjectProvider 单元测试（v0.42.0）
///
/// 验证 ProjectsController 的核心数据流。
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/storage/database.dart';

void main() {
  group('Projects CRUD', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('创建并获取项目', () async {
      final id = 'p1';
      await db.createProject(ProjectsCompanion.insert(
        id: id,
        name: '测试项目',
        description: const Value('描述'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final project = await db.getProjectById(id);
      expect(project, isNotNull);
      expect(project!.name, '测试项目');
      expect(project.icon, '📁'); // 默认
      expect(project.color, '#6750A4'); // 默认
      expect(project.isArchived, false); // 默认
    });

    test('getAllProjects 包含未归档项目', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: 'A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await db.createProject(ProjectsCompanion.insert(
        id: 'p2',
        name: 'B',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final all = await db.getAllProjects(includeArchived: false);
      expect(all.length, 2);
    });

    test('getAllProjects(includeArchived: false) 排除归档项目', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: 'A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await db.createProject(ProjectsCompanion.insert(
        id: 'p2',
        name: 'B',
        isArchived: const Value(true),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final all = await db.getAllProjects(includeArchived: false);
      expect(all.length, 1);
      expect(all.first.id, 'p1');

      final withArchived = await db.getAllProjects(includeArchived: true);
      expect(withArchived.length, 2);
    });

    test('更新项目', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: '原名',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await db.updateProject(ProjectsCompanion(
        id: const Value('p1'),
        name: const Value('新名'),
        updatedAt: Value(DateTime.now()),
      ));

      final p = await db.getProjectById('p1');
      expect(p!.name, '新名');
    });

    test('删除项目', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: 'A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final deleted = await db.deleteProject('p1');
      expect(deleted, 1);

      final p = await db.getProjectById('p1');
      expect(p, isNull);
    });
  });

  group('Projects 字段默认值', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('temperature 默认 0.7', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: 'A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final p = await db.getProjectById('p1');
      expect(p!.temperature, 0.7);
    });

    test('maxContextMessages 默认 20', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: 'A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final p = await db.getProjectById('p1');
      expect(p!.maxContextMessages, 20);
    });

    test('sortOrder 默认 0', () async {
      await db.createProject(ProjectsCompanion.insert(
        id: 'p1',
        name: 'A',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      final p = await db.getProjectById('p1');
      expect(p!.sortOrder, 0);
    });
  });
}
