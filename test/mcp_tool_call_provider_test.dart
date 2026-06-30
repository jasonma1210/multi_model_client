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

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
