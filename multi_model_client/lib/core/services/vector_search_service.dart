/// 向量检索服务 - LLM Studio 语义搜索模块
/// 
/// 功能：
/// - 向量存储与管理
/// - 语义相似度检索
/// - 记忆向量持久化
/// - Embedding 集成
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:drift/drift.dart';
import '../storage/database.dart';
import '../storage/database_connection.dart';
import './embedding_service.dart';

/// 向量检索服务
/// 提供向量存储和相似度检索功能
class VectorSearchService {
  final AppDatabase _db;
  final EmbeddingService _embeddingService;

  VectorSearchService(this._db, this._embeddingService);

  /// 存储记忆向量
  Future<void> storeMemoryVector(String memoryId, String content) async {
    final vector = await _embeddingService.generateEmbedding(content);
    final vectorJson = _embeddingService.vectorToJson(vector);

    // 更新记忆记录，添加向量
    await (_db.update(_db.memories)
          ..where((m) => m.id.equals(memoryId)))
        .write(MemoriesCompanion(
      // 假设我们在Memories表中有vector字段
      // 如果没有，需要先修改数据库表结构
      // 这里用entityTags字段临时存储
      entityTags: Value(vectorJson),
    ));
  }

  /// 存储文档块向量
  Future<void> storeDocumentChunkVector(String chunkId, String content) async {
    final vector = await _embeddingService.generateEmbedding(content);
    final vectorJson = _embeddingService.vectorToJson(vector);

    // 更新文档块记录
    await (_db.update(_db.documentChunks)
          ..where((dc) => dc.id.equals(chunkId)))
        .write(DocumentChunksCompanion(
      vector: Value(vectorJson),
    ));
  }

  /// 语义检索记忆
  Future<List<Memory>> searchMemories(
    String query, {
    String? sessionId,
    int limit = 10,
    double threshold = 0.5,
  }) async {
    // 生成查询向量
    final queryVector = await _embeddingService.generateEmbedding(query);

    // 获取所有记忆
    List<Memory> memories;
    if (sessionId != null) {
      memories = await (_db.select(_db.memories)
            ..where((m) => m.sessionId.equals(sessionId)))
          .get();
    } else {
      memories = await _db.getAllMemories();
    }

    // 计算相似度
    final scoredMemories = <MapEntry<Memory, double>>[];
    for (final memory in memories) {
      if (memory.entityTags == null) continue;

      try {
        final memoryVector = _embeddingService.jsonToVector(memory.entityTags!);
        final similarity = _embeddingService.cosineSimilarity(
          queryVector,
          memoryVector,
        );

        if (similarity >= threshold) {
          scoredMemories.add(MapEntry(memory, similarity));
        }
      } catch (e) {
        // 跳过无效的向量数据
        continue;
      }
    }

    // 按相似度排序
    scoredMemories.sort((a, b) => b.value.compareTo(a.value));

    // 返回top-k结果
    return scoredMemories.take(limit).map((e) => e.key).toList();
  }

  /// 语义检索文档块
  Future<List<DocumentChunk>> searchDocumentChunks(
    String knowledgeBaseId,
    String query, {
    int limit = 10,
    double threshold = 0.5,
  }) async {
    // 生成查询向量
    final queryVector = await _embeddingService.generateEmbedding(query);

    // 获取知识库的所有文档块
    final chunks = await _db.getKnowledgeBaseChunks(knowledgeBaseId);

    // 计算相似度
    final scoredChunks = <MapEntry<DocumentChunk, double>>[];
    for (final chunk in chunks) {
      if (chunk.vector == null) continue;

      try {
        final chunkVector = _embeddingService.jsonToVector(chunk.vector!);
        final similarity = _embeddingService.cosineSimilarity(
          queryVector,
          chunkVector,
        );

        if (similarity >= threshold) {
          scoredChunks.add(MapEntry(chunk, similarity));
        }
      } catch (e) {
        // 跳过无效的向量数据
        continue;
      }
    }

    // 按相似度排序
    scoredChunks.sort((a, b) => b.value.compareTo(a.value));

    // 返回top-k结果
    return scoredChunks.take(limit).map((e) => e.key).toList();
  }

  /// 批量生成知识库向量
  Future<void> generateKnowledgeBaseVectors(String knowledgeBaseId) async {
    final chunks = await _db.getKnowledgeBaseChunks(knowledgeBaseId);

    for (final chunk in chunks) {
      await storeDocumentChunkVector(chunk.id, chunk.content);
    }
  }

  /// 批量生成记忆向量
  Future<void> generateMemoryVectors({String? sessionId}) async {
    List<Memory> memories;
    if (sessionId != null) {
      memories = await (_db.select(_db.memories)
            ..where((m) => m.sessionId.equals(sessionId)))
          .get();
    } else {
      memories = await _db.getAllMemories();
    }

    for (final memory in memories) {
      await storeMemoryVector(memory.id, memory.content);
    }
  }
}
