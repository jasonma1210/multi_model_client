import 'dialogue_interface.dart' show Message;

abstract class IMemoryEngine {
  Future<void> extractMemory(String sessionId, List<Message> messages);
  Future<List<MemoryItem>> retrieveMemories(String sessionId, String query);
  Future<void> updateMemoryWeight(String memoryId, double weight);
  Future<void> archiveMemory(String memoryId);
  Future<void> deleteMemory(String memoryId);
  Future<void> manualAddMemory(String sessionId, String content, {bool isGlobal = false});
}

class MemoryItem {
  final String id;
  final String? sessionId;
  final String content;
  final MemoryType type;
  final double weight;
  final bool isGlobal;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;

  const MemoryItem({
    required this.id,
    this.sessionId,
    required this.content,
    required this.type,
    required this.weight,
    required this.isGlobal,
    required this.createdAt,
    this.lastAccessedAt,
  });
}

enum MemoryType {
  instant,
  working,
  longTerm,
  archived,
}

class MemoryExtractionResult {
  final List<String> entities;
  final List<String> facts;
  final List<String> preferences;

  const MemoryExtractionResult({
    required this.entities,
    required this.facts,
    required this.preferences,
  });
}
