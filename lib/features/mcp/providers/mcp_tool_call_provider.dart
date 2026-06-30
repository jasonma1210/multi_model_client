// v0.43.0 实现 MCP 工具调用 Provider
//
// 职责：
// 1. 跟踪当前会话/全局已调用的 MCP 工具列表
// 2. 提供 start/update/complete/fail 生命周期方法
// 3. 最多保留最近 50 条调用记录，避免内存膨胀
// 4. 通过 Riverpod StateNotifier 暴露给 UI
//
// 用法：
// ```dart
// final notifier = ref.read(mcpToolCallProvider.notifier);
// final callId = notifier.start(
//   serverId: 'filesystem',
//   toolName: 'read_file',
//   arguments: {'path': '/tmp/a.txt'},
// );
// // ... 工具执行中 ...
// notifier.complete(callId, result: '文件内容...');
// // 或
// notifier.fail(callId, error: '文件不存在');
// ```

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/mcp_tool_call_history_repository.dart';

/// MCP 工具调用状态
enum McpToolCallStatus {
  pending, // 已入队，尚未发送
  running, // 正在执行
  success, // 成功返回
  failed, // 执行失败
  canceled, // 用户取消
}

/// MCP 工具单次调用记录
@immutable
class McpToolCallRecord {
  /// 调用 ID（UUID v4）
  final String id;

  /// 工具所属 MCP Server ID
  final String serverId;

  /// Server 显示名（快照，避免 Server 改名后 UI 错乱）
  final String serverName;

  /// 工具名
  final String toolName;

  /// 入参 JSON 字符串
  final String arguments;

  /// 返回结果（成功时）
  final String? result;

  /// 错误信息（失败时）
  final String? error;

  /// 当前状态
  final McpToolCallStatus status;

  /// 调用开始时间
  final DateTime startedAt;

  /// 完成时间（成功 / 失败 / 取消时）
  final DateTime? completedAt;

  /// v0.45.0: 关联会话 ID（用于跨会话查询历史）
  final String? sessionId;

  /// v0.45.0: 关联消息 ID（用于追溯触发源）
  final String? messageId;

  const McpToolCallRecord({
    required this.id,
    required this.serverId,
    required this.serverName,
    required this.toolName,
    required this.arguments,
    required this.status,
    required this.startedAt,
    this.result,
    this.error,
    this.completedAt,
    this.sessionId,
    this.messageId,
  });

  /// 耗时（未完成返回 null）
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  McpToolCallRecord copyWith({
    String? result,
    String? error,
    McpToolCallStatus? status,
    DateTime? completedAt,
    String? sessionId,
    String? messageId,
  }) {
    return McpToolCallRecord(
      id: id,
      serverId: serverId,
      serverName: serverName,
      toolName: toolName,
      arguments: arguments,
      result: result ?? this.result,
      error: error ?? this.error,
      status: status ?? this.status,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      sessionId: sessionId ?? this.sessionId,
      messageId: messageId ?? this.messageId,
    );
  }

  /// v0.45.0: 序列化为 Map（用于持久化 + UI 传输）
  Map<String, dynamic> toMap() => {
        'id': id,
        'sessionId': sessionId,
        'messageId': messageId,
        'serverId': serverId,
        'serverName': serverName,
        'toolName': toolName,
        'arguments': arguments,
        'result': result,
        'error': error,
        'status': status.name,
        'startedAt': startedAt.millisecondsSinceEpoch,
        'completedAt': completedAt?.millisecondsSinceEpoch,
      };

  /// v0.45.0: 从 Map 反序列化
  factory McpToolCallRecord.fromMap(Map<String, dynamic> m) =>
      McpToolCallRecord(
        id: m['id'] as String,
        sessionId: m['sessionId'] as String?,
        messageId: m['messageId'] as String?,
        serverId: m['serverId'] as String,
        serverName: m['serverName'] as String,
        toolName: m['toolName'] as String,
        arguments: m['arguments'] as String? ?? '',
        result: m['result'] as String?,
        error: m['error'] as String?,
        status: McpToolCallStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => McpToolCallStatus.failed,
        ),
        startedAt:
            DateTime.fromMillisecondsSinceEpoch(m['startedAt'] as int),
        completedAt: m['completedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['completedAt'] as int),
      );
}

/// MCP 工具调用状态容器
@immutable
class McpToolCallState {
  /// 按调用顺序排列的记录（最新在前）
  final List<McpToolCallRecord> records;

  /// 单个会话最多保留的记录数
  static const int maxRecords = 50;

  const McpToolCallState({this.records = const []});

  /// 当前正在执行的工具调用（用于显示 Loading 状态）
  List<McpToolCallRecord> get activeCalls =>
      records.where((r) =>
          r.status == McpToolCallStatus.running ||
          r.status == McpToolCallStatus.pending).toList();

  /// 最近的工具调用（最近 5 条）
  List<McpToolCallRecord> get recentCalls => records.take(5).toList();

  McpToolCallState copyWith({List<McpToolCallRecord>? records}) {
    return McpToolCallState(records: records ?? this.records);
  }
}

/// MCP 工具调用 Notifier
class McpToolCallNotifier extends StateNotifier<McpToolCallState> {
  McpToolCallNotifier({McpToolCallHistoryRepository? historyRepo})
      : _historyRepo = historyRepo ?? McpToolCallHistoryRepository(),
        super(const McpToolCallState());

  /// v0.45.0: 持久化 Repository（fire-and-forget，不阻塞 UI）
  final McpToolCallHistoryRepository _historyRepo;

  /// 记录一次工具调用开始
  ///
  /// 返回调用 ID（用于后续更新）
  String start({
    required String serverId,
    required String serverName,
    required String toolName,
    required String arguments,
    String? sessionId, // v0.45.0: 关联会话
    String? messageId, // v0.45.0: 关联消息
  }) {
    final id = _generateId();
    final record = McpToolCallRecord(
      id: id,
      serverId: serverId,
      serverName: serverName,
      toolName: toolName,
      arguments: arguments,
      status: McpToolCallStatus.running,
      startedAt: DateTime.now(),
      sessionId: sessionId,
      messageId: messageId,
    );
    state = state.copyWith(records: [record, ...state.records].take(McpToolCallState.maxRecords).toList());
    _historyRepo.insert(record); // v0.45.0: 持久化（fire-and-forget）
    return id;
  }

  /// 标记工具调用成功
  void complete(String callId, {required String result}) {
    _updateRecord(callId, (r) => r.copyWith(
          status: McpToolCallStatus.success,
          result: result,
          completedAt: DateTime.now(),
        ));
    _historyRepo.updateStatus(callId,
        status: McpToolCallStatus.success.name,
        result: result,
        completedAt: DateTime.now()); // v0.45.0: 持久化
  }

  /// 标记工具调用失败
  void fail(String callId, {required String error}) {
    _updateRecord(callId, (r) => r.copyWith(
          status: McpToolCallStatus.failed,
          error: error,
          completedAt: DateTime.now(),
        ));
    _historyRepo.updateStatus(callId,
        status: McpToolCallStatus.failed.name,
        error: error,
        completedAt: DateTime.now()); // v0.45.0: 持久化
  }

  /// 标记工具调用被取消
  void cancel(String callId) {
    _updateRecord(callId, (r) => r.copyWith(
          status: McpToolCallStatus.canceled,
          completedAt: DateTime.now(),
        ));
    _historyRepo.updateStatus(callId,
        status: McpToolCallStatus.canceled.name,
        completedAt: DateTime.now()); // v0.45.0: 持久化
  }

  /// 清除所有记录
  void clear() {
    state = const McpToolCallState();
  }

  /// v0.45.0: 从 DB 加载历史记录到内存状态
  ///
  /// 合并 DB 历史与当前内存活跃记录（避免覆盖正在执行的调用）。
  /// 供 McpToolExplorerPage 首屏加载和分页使用。
  Future<void> loadHistory({
    String? sessionId,
    int limit = 20,
    int offset = 0,
    String? statusFilter,
    String? toolNameSearch,
  }) async {
    final dbRecords = await _historyRepo.getRecent(
      limit: limit,
      offset: offset,
      statusFilter: statusFilter,
      toolNameSearch: toolNameSearch,
    );
    // 合并：DB 历史 + 内存活跃记录（去重 by id）
    final activeIds = state.activeCalls.map((r) => r.id).toSet();
    final merged = <McpToolCallRecord>[];
    for (final r in dbRecords) {
      if (!activeIds.contains(r.id)) merged.add(r);
    }
    merged.addAll(state.activeCalls);
    merged.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    state = state.copyWith(
        records: merged.take(McpToolCallState.maxRecords).toList());
  }

  void _updateRecord(String callId, McpToolCallRecord Function(McpToolCallRecord) updater) {
    final updated = state.records.map((r) {
      if (r.id != callId) return r;
      return updater(r);
    }).toList();
    state = state.copyWith(records: updated);
  }

  int _seq = 0;
  String _generateId() {
    _seq += 1;
    return 'mcp-${DateTime.now().microsecondsSinceEpoch}-$_seq';
  }
}

/// MCP 工具调用 Riverpod Provider
final mcpToolCallProvider =
    StateNotifierProvider<McpToolCallNotifier, McpToolCallState>((ref) {
  return McpToolCallNotifier();
});
