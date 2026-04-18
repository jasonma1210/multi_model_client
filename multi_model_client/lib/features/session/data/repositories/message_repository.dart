import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../../../../core/storage/database.dart';
import '../../../../core/storage/database_connection.dart';

class MessageRepository {
  final AppDatabase _db = database;
  final _uuid = const Uuid();

  Future<Message> createMessage({
    required String sessionId,
    required String role,
    required String content,
    String type = 'text',
    int? tokenCount,
    String? toolCallInfo,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final message = MessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      role: Value(role),
      content: Value(content),
      type: Value(type),
      tokenCount: Value(tokenCount),
      toolCallInfo: Value(toolCallInfo),
      createdAt: Value(now),
    );

    await _db.insertMessage(message);
    return (await _db.getSessionMessages(sessionId))
        .lastWhere((m) => m.id == id);
  }

  Future<List<Message>> getSessionMessages(String sessionId) async {
    return await _db.getSessionMessages(sessionId);
  }

  Future<void> deleteSessionMessages(String sessionId) async {
    await _db.deleteSessionMessages(sessionId);
  }
}
