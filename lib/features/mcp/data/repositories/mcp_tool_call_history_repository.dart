// v0.45.0: MCP 工具调用历史持久化 Repository
//
// 职责：
// 1. 把 McpToolCallRecord 写入 mcp_tool_call_histories 表
// 2. 更新调用状态（status/result/error/completedAt）
// 3. 分页查询历史记录（支持状态筛选 + toolName 模糊搜索）
// 4. 启动时清理旧记录（保留最近 1000 条）
//
// 参考实现：lib/features/session/data/repositories/message_repository.dart
// 设计原则：直接使用全局 database singleton，不通过构造注入（与现有 Repository 一致）

import 'package:drift/drift.dart';
import '../../../../core/storage/database.dart';
import '../../../../core/storage/database_connection.dart';
import '../../providers/mcp_tool_call_provider.dart';

class McpToolCallHistoryRepository {
  final AppDatabase _db;

  /// v0.45.0: 支持注入测试用 AppDatabase（生产环境使用全局 singleton）
  McpToolCallHistoryRepository({AppDatabase? db}) : _db = db ?? database;

  /// 插入一条调用记录（status=running 时调用）
  Future<void> insert(McpToolCallRecord record) async {
    try {
      await _db.insertMcpToolCallHistory(
        McpToolCallHistoriesCompanion.insert(
          id: record.id,
          sessionId: Value(record.sessionId),
          messageId: Value(record.messageId),
          serverId: record.serverId,
          serverName: record.serverName,
          toolName: record.toolName,
          arguments: Value(record.arguments),
          status: record.status.name,
          startedAt: record.startedAt.millisecondsSinceEpoch,
          result: Value(record.result),
          error: Value(record.error),
          completedAt: record.completedAt == null
              ? const Value.absent()
              : Value(record.completedAt!.millisecondsSinceEpoch),
        ),
      );
    } catch (e) {
      // 持久化失败不应阻塞 UI，仅记录日志
      // ignore: avoid_print
      print('[McpToolCallHistoryRepository] insert failed: $e');
    }
  }

  /// 更新调用状态（complete/fail/cancel 时调用）
  Future<void> updateStatus(
    String id, {
    String? status,
    String? result,
    String? error,
    DateTime? completedAt,
  }) async {
    try {
      await _db.updateMcpToolCallHistoryStatus(
        id: id,
        status: status,
        result: result,
        error: error,
        completedAt: completedAt?.millisecondsSinceEpoch,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[McpToolCallHistoryRepository] updateStatus failed: $e');
    }
  }

  /// 分页查询历史记录
  Future<List<McpToolCallRecord>> getRecent({
    int limit = 20,
    int offset = 0,
    String? statusFilter,
    String? toolNameSearch,
  }) async {
    final rows = await _db.getRecentMcpToolCallHistories(
      limit: limit,
      offset: offset,
      statusFilter: statusFilter,
      toolNameSearch: toolNameSearch,
    );
    return rows.map(_toRecord).toList();
  }

  /// 获取记录总数（用于分页 UI）
  Future<int> getCount({
    String? statusFilter,
    String? toolNameSearch,
  }) async {
    return _db.getMcpToolCallHistoryCount(
      statusFilter: statusFilter,
      toolNameSearch: toolNameSearch,
    );
  }

  /// 清理旧记录，保留最近 [keepLatestN] 条
  Future<void> cleanupOlderThan(int keepLatestN) async {
    await _db.cleanupOldMcpToolCallHistories(keepLatestN);
  }

  /// Drift 行 → McpToolCallRecord 转换
  McpToolCallRecord _toRecord(McpToolCallHistory row) {
    return McpToolCallRecord(
      id: row.id,
      sessionId: row.sessionId,
      messageId: row.messageId,
      serverId: row.serverId,
      serverName: row.serverName,
      toolName: row.toolName,
      arguments: row.arguments ?? '',
      result: row.result,
      error: row.error,
      status: McpToolCallStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => McpToolCallStatus.failed,
      ),
      startedAt: DateTime.fromMillisecondsSinceEpoch(row.startedAt),
      completedAt: row.completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
    );
  }
}
