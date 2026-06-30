// v0.43.0 测试 MCP 工具调用 Provider
//
// 覆盖：
// 1. start() 创建记录并返回唯一 ID
// 2. complete() 标记成功 + 记录结果
// 3. fail() 标记失败 + 记录错误
// 4. cancel() 标记取消
// 5. activeCalls 仅返回 pending/running 记录
// 6. clear() 清空所有记录
// 7. 超过 50 条记录时自动截断
//
// v0.45.0 扩展：
// 8. toMap / fromMap 往返一致性
// 9. sessionId / messageId 透传
// 10. copyWith 保留 sessionId / messageId（修复回归验证）
// 11. loadHistory 合并逻辑（内存活跃 + DB 历史，去重 by id）
// 12. loadHistory 分页与过滤

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mj_nexus/core/storage/database.dart';
import 'package:mj_nexus/features/mcp/data/repositories/mcp_tool_call_history_repository.dart';
import 'package:mj_nexus/features/mcp/providers/mcp_tool_call_provider.dart';

void main() {
  group('McpToolCallNotifier', () {
    test('start 创建新记录并返回唯一 ID', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      final id1 = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{"path":"/tmp/a.txt"}',
      );
      final id2 = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'write_file',
        arguments: '{"path":"/tmp/b.txt","content":"hi"}',
      );

      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));

      final state = container.read(mcpToolCallProvider);
      expect(state.records.length, 2);
      // 最新记录在前
      expect(state.records.first.toolName, 'write_file');
      expect(state.records.last.toolName, 'read_file');
    });

    test('complete 标记成功 + 保存结果', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      final id = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
      );
      notifier.complete(id, result: '文件内容...');

      final record = container.read(mcpToolCallProvider).records.first;
      expect(record.status, McpToolCallStatus.success);
      expect(record.result, '文件内容...');
      expect(record.completedAt, isNotNull);
      expect(record.duration, isNotNull);
    });

    test('fail 标记失败 + 保存错误', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      final id = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
      );
      notifier.fail(id, error: 'File not found');

      final record = container.read(mcpToolCallProvider).records.first;
      expect(record.status, McpToolCallStatus.failed);
      expect(record.error, 'File not found');
    });

    test('cancel 标记取消', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      final id = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
      );
      notifier.cancel(id);

      final record = container.read(mcpToolCallProvider).records.first;
      expect(record.status, McpToolCallStatus.canceled);
    });

    test('activeCalls 仅返回 pending/running 记录', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      final id1 = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
      );
      final id2 = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'list',
        arguments: '{}',
      );
      notifier.complete(id1, result: 'ok');

      final active = container.read(mcpToolCallProvider).activeCalls;
      expect(active.length, 1);
      expect(active.first.id, id2);
      expect(active.first.status, McpToolCallStatus.running);
    });

    test('clear 清空所有记录', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
      );
      notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'list',
        arguments: '{}',
      );
      expect(container.read(mcpToolCallProvider).records.length, 2);

      notifier.clear();
      expect(container.read(mcpToolCallProvider).records.length, 0);
    });

    test('超过 50 条记录时自动截断为最新 50 条', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      for (int i = 0; i < 60; i++) {
        notifier.start(
          serverId: 'fs',
          serverName: 'Filesystem',
          toolName: 't$i',
          arguments: '{}',
        );
      }

      final records = container.read(mcpToolCallProvider).records;
      expect(records.length, 50);
      // 最新记录在前
      expect(records.first.toolName, 't59');
    });

    test('不存在的 ID 调用 complete/fail/cancel 不应崩溃', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(mcpToolCallProvider.notifier);

      // 不应抛异常
      expect(
        () => notifier.complete('nonexistent', result: 'x'),
        returnsNormally,
      );
      expect(
        () => notifier.fail('nonexistent', error: 'x'),
        returnsNormally,
      );
      expect(
        () => notifier.cancel('nonexistent'),
        returnsNormally,
      );
    });
  });

  group('McpToolCallRecord', () {
    test('duration 仅在 completed 后非空', () {
      final now = DateTime.now();
      final running = McpToolCallRecord(
        id: '1',
        serverId: 's',
        serverName: 'S',
        toolName: 't',
        arguments: '{}',
        status: McpToolCallStatus.running,
        startedAt: now,
      );
      final done = running.copyWith(
        status: McpToolCallStatus.success,
        result: 'ok',
        completedAt: now.add(const Duration(milliseconds: 123)),
      );
      expect(running.duration, isNull);
      expect(done.duration, const Duration(milliseconds: 123));
    });
  });

  // ===== v0.45.0 扩展测试 =====

  group('McpToolCallRecord v0.45.0 序列化', () {
    test('toMap / fromMap 往返一致性', () {
      // 使用毫秒精度，避免微秒在 toMap/fromMap 中丢失
      final now = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch,
      );
      final original = McpToolCallRecord(
        id: 'rec-1',
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{"path":"/tmp/a.txt"}',
        status: McpToolCallStatus.success,
        startedAt: now,
        completedAt: now.add(const Duration(milliseconds: 500)),
        result: '文件内容',
        sessionId: 'sess-1',
        messageId: 'msg-1',
      );
      final map = original.toMap();
      final restored = McpToolCallRecord.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.sessionId, original.sessionId);
      expect(restored.messageId, original.messageId);
      expect(restored.serverId, original.serverId);
      expect(restored.serverName, original.serverName);
      expect(restored.toolName, original.toolName);
      expect(restored.arguments, original.arguments);
      expect(restored.result, original.result);
      expect(restored.status, original.status);
      expect(restored.startedAt, original.startedAt);
      expect(restored.completedAt, original.completedAt);
    });

    test('copyWith 保留 sessionId / messageId（修复回归验证）', () {
      final now = DateTime.now();
      final running = McpToolCallRecord(
        id: '1',
        serverId: 's',
        serverName: 'S',
        toolName: 't',
        arguments: '{}',
        status: McpToolCallStatus.running,
        startedAt: now,
        sessionId: 'sess-x',
        messageId: 'msg-x',
      );

      // 模拟 complete 流程
      final done = running.copyWith(
        status: McpToolCallStatus.success,
        result: 'ok',
        completedAt: now.add(const Duration(milliseconds: 100)),
      );

      expect(done.sessionId, 'sess-x', reason: 'complete 后 sessionId 应保留');
      expect(done.messageId, 'msg-x', reason: 'complete 后 messageId 应保留');
      expect(done.status, McpToolCallStatus.success);
      expect(done.result, 'ok');
    });

    test('copyWith 显式覆盖 sessionId / messageId', () {
      final now = DateTime.now();
      final original = McpToolCallRecord(
        id: '1',
        serverId: 's',
        serverName: 'S',
        toolName: 't',
        arguments: '{}',
        status: McpToolCallStatus.running,
        startedAt: now,
        sessionId: 'old-session',
        messageId: 'old-msg',
      );
      final updated = original.copyWith(
        sessionId: 'new-session',
        messageId: 'new-msg',
      );
      expect(updated.sessionId, 'new-session');
      expect(updated.messageId, 'new-msg');
    });
  });

  group('McpToolCallNotifier v0.45.0 持久化', () {
    test('start 透传 sessionId / messageId 到内存与 DB', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);
      final notifier = McpToolCallNotifier(historyRepo: repo);

      final id = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
        sessionId: 'sess-1',
        messageId: 'msg-1',
      );

      // 内存状态检查
      final record = notifier.state.records.first;
      expect(record.id, id);
      expect(record.sessionId, 'sess-1');
      expect(record.messageId, 'msg-1');

      // DB 持久化检查（fire-and-forget，需短暂等待）
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final dbRecords = await repo.getRecent();
      expect(dbRecords, isNotEmpty);
      expect(dbRecords.first.id, id);
      expect(dbRecords.first.sessionId, 'sess-1');
      expect(dbRecords.first.messageId, 'msg-1');
    });

    test('complete 后 sessionId / messageId 仍在内存状态中保留', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);
      final notifier = McpToolCallNotifier(historyRepo: repo);

      final id = notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'write_file',
        arguments: '{}',
        sessionId: 'sess-keep',
        messageId: 'msg-keep',
      );
      notifier.complete(id, result: 'done');

      final record = notifier.state.records.first;
      expect(record.status, McpToolCallStatus.success);
      expect(record.sessionId, 'sess-keep', reason: 'complete 后 sessionId 应保留');
      expect(record.messageId, 'msg-keep', reason: 'complete 后 messageId 应保留');
    });

    test('loadHistory 合并 DB 历史与内存活跃记录（去重 by id）', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      // 预置 DB 历史记录
      final now = DateTime.now();
      await repo.insert(McpToolCallRecord(
        id: 'db-1',
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
        status: McpToolCallStatus.success,
        startedAt: now.subtract(const Duration(minutes: 5)),
        completedAt: now.subtract(const Duration(minutes: 4)),
        result: 'db result',
      ));

      // 内存中放一条活跃记录
      final notifier = McpToolCallNotifier(historyRepo: repo);
      notifier.start(
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'list',
        arguments: '{}',
      );

      await notifier.loadHistory();

      final records = notifier.state.records;
      // DB 1 条 + 内存活跃 1 条 = 2 条
      expect(records.length, 2);
      // 去重：内存活跃记录的 id 不应与 DB 记录重复
      final ids = records.map((r) => r.id).toSet();
      expect(ids.length, 2, reason: '记录 id 不应重复');
    });

    test('loadHistory 支持状态过滤与工具名搜索', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = McpToolCallHistoryRepository(db: db);

      final base = DateTime.now();
      // 插入 3 条不同状态/工具名的记录
      await repo.insert(McpToolCallRecord(
        id: 'r1',
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'write_file',
        arguments: '{}',
        status: McpToolCallStatus.success,
        startedAt: base,
      ));
      await repo.insert(McpToolCallRecord(
        id: 'r2',
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'read_file',
        arguments: '{}',
        status: McpToolCallStatus.failed,
        startedAt: base.add(const Duration(milliseconds: 1)),
      ));
      await repo.insert(McpToolCallRecord(
        id: 'r3',
        serverId: 'fs',
        serverName: 'Filesystem',
        toolName: 'list_dir',
        arguments: '{}',
        status: McpToolCallStatus.success,
        startedAt: base.add(const Duration(milliseconds: 2)),
      ));

      final notifier = McpToolCallNotifier(historyRepo: repo);

      // 状态过滤：仅 success
      await notifier.loadHistory(statusFilter: 'success');
      final successRecords = notifier.state.records;
      expect(successRecords.length, 2);
      expect(successRecords.every((r) => r.status == McpToolCallStatus.success),
          isTrue);

      // 工具名搜索：包含 'file'
      await notifier.loadHistory(toolNameSearch: 'file');
      final fileRecords = notifier.state.records;
      expect(fileRecords.length, 2);
      expect(
        fileRecords.every((r) => r.toolName.contains('file')),
        isTrue,
      );
    });
  });
}
