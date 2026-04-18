import '../storage/database.dart' show KnowledgeBase;

abstract class IRAGEngine {
  Future<void> createKnowledgeBase(String name, {String? sessionId});
  Future<void> deleteKnowledgeBase(String kbId);
  Future<void> addDocument(String kbId, DocumentConfig config);
  Future<void> removeDocument(String kbId, String documentId);
  Future<List<RetrievalResult>> retrieve(String kbId, String query, {int topK = 5});
  Future<void> processDocument(String kbId, String documentPath);
}

class DocumentConfig {
  final String path;
  final String type; // 'pdf', 'word', 'txt', 'markdown', etc.
  final ChunkingStrategy chunkingStrategy;

  const DocumentConfig({
    required this.path,
    required this.type,
    required this.chunkingStrategy,
  });
}

class ChunkingStrategy {
  final int chunkSize;
  final int overlap;
  final ChunkingMethod method;

  const ChunkingStrategy({
    this.chunkSize = 500,
    this.overlap = 50,
    this.method = ChunkingMethod.semantic,
  });
}

enum ChunkingMethod {
  fixed,
  semantic,
  sentence,
}

class RetrievalResult {
  final String content;
  final double score;
  final Map<String, dynamic> metadata;

  const RetrievalResult({
    required this.content,
    required this.score,
    required this.metadata,
  });
}
