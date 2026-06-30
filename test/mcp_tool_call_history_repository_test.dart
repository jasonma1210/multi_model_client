// v0.45.0 测试 MCP 工具调用历史 Repository
//
// 使用 NativeDatabase.memory() 内存数据库，每个测试用例独立隔离。
// 覆盖：
// 1. insert + getRecent 基本流程
// 2. updateStatus 状态流转
// 3. 分页（limit / offset）
// 4. statusFilter 过滤
// 5. toolNameSearch 模糊匹配
// 6. getCount 总数
// 7. cleanupOlderThan 清理
// 8. sessionId / messageId 字段持久化
// 9. fire-and-forget 容错

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/storage/database.dart';
import 'package:mj_nexus/features/mcp/data/repositories/mcp_tool_call_history_repository.dart';
import 'package:mj_nexus/features/mcp/providers/mcp_tool_call_provider.dart';

void main() {
  // 测试辅助：构造一条记录
  McpToolCallRecord makeRecord({
    required String id,
    String toolName = 'read_file',
    String status = 'running',
    String? sessionId,
    String? messageId,
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? error,
  }) {
    return McpToolCallRecord(
      id: id,
      serverId: 'fs',
      serverName: 'Filesystem',
      toolName: toolName,
      arguments: '{}',
      status: McpToolCallStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => McpToolCallStatus.running,
      ),
      startedAt: startedAt ?? DateTime.now(),
      completedAt: completedAt,
      result: result,
      error: error,
      sessionId: sessionId,
      messageId: messageId,
    );
  }

  group('McpToolCallHistoryRepository', () {
    test('insert + getRecent 基本流程', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      final record = makeRecord(
        id: 'r-1',
        toolName: 'read_file',
        status: 'success',
        result: 'file content',
        startedAt: DateTime(2026, 6, 30, 10, 0),
        completedAt: DateTime(2026, 6, 30, 10, 0, 0, 500),
      );
      await repo.insert(record);

      final results = await repo.getRecent();
      expect(results.length, 1);
      expect(results.first.id, 'r-1');
      expect(results.first.toolName, 'read_file');
      expect(results.first.status, McpToolCallStatus.success);
      expect(results.first.result, 'file content');
    });

    test('updateStatus 状态流转 pending → success', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      await repo.insert(makeRecord(id: 'r-2', status: 'running'));

      final completedAt = DateTime.now();
      await repo.updateStatus(
        'r-2',
        status: 'success',
        result: 'ok',
        completedAt: completedAt,
      );

      final results = await repo.getRecent();
      expect(results.length, 1);
      expect(results.first.status, McpToolCallStatus.success);
      expect(results.first.result, 'ok');
      expect(results.first.completedAt, isNotNull);
    });

    test('updateStatus 状态流转 pending → failed', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      await repo.insert(makeRecord(id: 'r-3', status: 'running'));
      await repo.updateStatus(
        'r-3',
        status: 'failed',
        error: 'permission denied',
        completedAt: DateTime.now(),
      );

      final results = await repo.getRecent();
      expect(results.first.status, McpToolCallStatus.failed);
      expect(results.first.error, 'permission denied');
    });

    test('分页 limit / offset', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      // 插入 25 条记录（startedAt 递增，确保排序稳定）
      final base = DateTime(2026, 6, 30, 10, 0);
      for (int i = 0; i < 25; i++) {
        await repo.insert(makeRecord(
          id: 'p-$i',
          status: 'success',
          startedAt: base.add(Duration(milliseconds: i)),
        ));
      }

      // 第一页：20 条
      final page1 = await repo.getRecent(limit: 20, offset: 0);
      expect(page1.length, 20);
      // 按 startedAt DESC，最新在前
      expect(page1.first.id, 'p-24');

      // 第二页：5 条
      final page2 = await repo.getRecent(limit: 20, offset: 20);
      expect(page2.length, 5);
      expect(page2.last.id, 'p-0');
    });

    test('statusFilter 过滤', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      await repo.insert(makeRecord(id: 's-1', status: 'success'));
      await repo.insert(makeRecord(id: 's-2', status: 'failed'));
      await repo.insert(makeRecord(id: 's-3', status: 'success'));

      final successOnly = await repo.getRecent(statusFilter: 'success');
      expect(successOnly.length, 2);
      expect(successOnly.every((r) => r.status == McpToolCallStatus.success),
          isTrue);

      final failedOnly = await repo.getRecent(statusFilter: 'failed');
      expect(failedOnly.length, 1);
      expect(failedOnly.first.id, 's-2');
    });

    test('toolNameSearch 模糊匹配', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      await repo.insert(makeRecord(id: 't-1', toolName: 'write_file'));
      await repo.insert(makeRecord(id: 't-2', toolName: 'read_file'));
      await repo.insert(makeRecord(id: 't-3', toolName: 'list_dir'));

      final fileResults = await repo.getRecent(toolNameSearch: 'file');
      expect(fileResults.length, 2);
      expect(fileResults.every((r) => r.toolName.contains('file')), isTrue);

      final dirResults = await repo.getRecent(toolNameSearch: 'dir');
      expect(dirResults.length, 1);
      expect(dirResults.first.toolName, 'list_dir');
    });

    test('getCount 总数与筛选计数', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      for (int i = 0; i < 5; i++) {
        await repo.insert(makeRecord(
          id: 'c-$i',
          status: i.isEven ? 'success' : 'failed',
        ));
      }

      final total = await repo.getCount();
      expect(total, 5);

      final successCount = await repo.getCount(statusFilter: 'success');
      expect(successCount, 3);

      final failedCount = await repo.getCount(statusFilter: 'failed');
      expect(failedCount, 2);
    });

    test('cleanupOlderThan 保留最近 N 条', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      final base = DateTime(2026, 6, 30, 10, 0);
      for (int i = 0; i < 100; i++) {
        await repo.insert(makeRecord(
          id: 'cl-$i',
          status: 'success',
          startedAt: base.add(Duration(milliseconds: i)),
        ));
      }

      await repo.cleanupOlderThan(50);

      final remaining = await repo.getCount();
      expect(remaining, 50);

      // 验证保留的是最新的 50 条
      final records = await repo.getRecent(limit: 100);
      expect(records.length, 50);
      // 最新的记录 id 是 cl-99
      expect(records.first.id, 'cl-99');
      // 最旧的保留记录 id 是 cl-50
      expect(records.last.id, 'cl-50');
    });

    test('sessionId / messageId 字段持久化', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      await repo.insert(makeRecord(
        id: 'sm-1',
        sessionId: 'session-abc',
        messageId: 'message-xyz',
      ));

      final results = await repo.getRecent();
      expect(results.length, 1);
      expect(results.first.sessionId, 'session-abc');
      expect(results.first.messageId, 'message-xyz');
    });

    test('fire-and-forget: insert 失败不抛异常', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      // 关闭数据库后再插入，应触发异常但被 Repository 捕获
      await db.close();

      // 不应抛异常（fire-and-forget 模式）
      await expectLater(
        repo.insert(makeRecord(id: 'closed-db')),
        completes,
      );

      // updateStatus 同样不应抛异常
      await expectLater(
        repo.updateStatus('closed-db', status: 'failed'),
        completes,
      );
    });
  });
}
