import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/interfaces/rag_interface.dart';
import '../../../core/storage/database_connection.dart';
import '../../../core/storage/database.dart';
import '../../../core/engines/model_inference_engine.dart';
import '../../../core/services/embedding_service.dart';

class RAGEngine implements IRAGEngine {
  final AppDatabase _db = database;
  final ModelInferenceEngine? _modelEngine;
  final EmbeddingService _embeddingService;
  final _uuid = const Uuid();

  // 是否启用语义搜索
  bool _semanticSearchEnabled = true;

  RAGEngine({
    ModelInferenceEngine? modelEngine,
    EmbeddingService? embeddingService,
  })  : _modelEngine = modelEngine,
        _embeddingService = embeddingService ?? EmbeddingService();

  @override
  Future<void> createKnowledgeBase(String name, {String? sessionId}) async {
    await _db.insertKnowledgeBase(KnowledgeBasesCompanion(
      name: Value(name),
      sessionId: Value(sessionId),
      isGlobal: Value(sessionId == null),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteKnowledgeBase(String kbId) async {
    // Delete all chunks first
    await _db.deleteKnowledgeBaseChunks(kbId);

    // Delete knowledge base
    await _db.deleteKnowledgeBase(kbId);
  }

  @override
  Future<void> addDocument(String kbId, DocumentConfig config) async {
    // Check if file exists
    final file = File(config.path);
    if (!await file.exists()) {
      throw FileNotFoundException(config.path);
    }

    // Generate a unique document ID
    final documentId = _uuid.v4();

    // Process document
    await processDocument(kbId, config.path, documentId: documentId);
  }

  @override
  Future<void> removeDocument(String kbId, String documentId) async {
    // Query all chunks that belong to this document
    // We need to track document ID in metadata
    final chunks = await _db.getKnowledgeBaseChunks(kbId);

    // Delete chunks that belong to this document
    for (final chunk in chunks) {
      if (chunk.metadata != null) {
        try {
          final metadata = jsonDecode(chunk.metadata!) as Map<String, dynamic>;
          if (metadata['documentId'] == documentId) {
            await (_db.delete(_db.documentChunks)
                  ..where((dc) => dc.id.equals(chunk.id)))
                .go();
          }
        } catch (e) {
          // Skip chunks with invalid metadata
        }
      }
    }
  }

  @override
  Future<List<RetrievalResult>> retrieve(String kbId, String query, {int topK = 5}) async {
    // Get all chunks from knowledge base
    final chunks = await _db.getKnowledgeBaseChunks(kbId);

    // Use semantic search if enabled
    List<DocumentChunk> rankedChunks;
    if (_semanticSearchEnabled) {
      rankedChunks = await _semanticSearch(chunks, query);
    } else {
      // Fall back to keyword matching
      rankedChunks = _keywordSearch(chunks, query);
    }

    // Return top K results
    return rankedChunks.take(topK).map((chunk) {
      final metadataJson = chunk.metadata ?? '{}';
      return RetrievalResult(
        content: chunk.content,
        score: 1.0, // TODO: Add actual relevance scores
        metadata: jsonDecode(metadataJson) as Map<String, dynamic>,
      );
    }).toList();
  }

  Future<List<DocumentChunk>> _semanticSearch(List<DocumentChunk> chunks, String query) async {
    try {
      // 生成查询的嵌入向量
      final queryEmbedding = await _embeddingService.generateEmbedding(query);

      // 对每个 chunk 计算相似度
      final scoredChunks = <MapEntry<DocumentChunk, double>>[];

      for (final chunk in chunks) {
        double score = 0.0;

        if (chunk.vector != null && chunk.vector!.isNotEmpty) {
          // 使用预存储的嵌入向量计算相似度
          try {
            final chunkEmbedding = _embeddingService.jsonToVector(chunk.vector!);
            score = _embeddingService.cosineSimilarity(queryEmbedding, chunkEmbedding);
          } catch (e) {
            print('Failed to parse vector for chunk ${chunk.id}: $e');
          }
        }

        // 如果没有嵌入向量或计算失败，使用关键词匹配作为后备
        if (score == 0.0) {
          score = _keywordMatchScore(chunk.content, query);
        }

        scoredChunks.add(MapEntry(chunk, score));
      }

      // 按相似度排序
      scoredChunks.sort((a, b) => b.value.compareTo(a.value));

      return scoredChunks.map((entry) => entry.key).toList();
    } catch (e) {
      print('Semantic search failed: $e');
      return _keywordSearch(chunks, query);
    }
  }

  // 计算关键词匹配分数
  double _keywordMatchScore(String content, String query) {
    final contentLower = content.toLowerCase();
    final queryLower = query.toLowerCase();
    final queryWords = queryLower.split(RegExp(r'\s+'));

    int matchCount = 0;
    for (final word in queryWords) {
      if (word.length > 2 && contentLower.contains(word)) {
        matchCount++;
      }
    }

    return matchCount / queryWords.length;
  }

  List<DocumentChunk> _keywordSearch(List<DocumentChunk> chunks, String query) {
    final queryWords = query.toLowerCase().split(' ');
    final scoredChunks = chunks.map((chunk) {
      final chunkWords = chunk.content.toLowerCase().split(' ');
      final score = queryWords.where((word) => chunkWords.contains(word)).length.toDouble();
      return MapEntry(chunk, score);
    }).toList();

    // Sort by score
    scoredChunks.sort((a, b) => b.value.compareTo(a.value));

    return scoredChunks.map((entry) => entry.key).toList();
  }

  @override
  Future<void> processDocument(String kbId, String documentPath, {String? documentId}) async {
    final file = File(documentPath);
    final content = await file.readAsString();

    // Use provided documentId or generate one
    final docId = documentId ?? _uuid.v4();

    // Chunk the document
    final chunks = _chunkText(content, chunkSize: 500, overlap: 50);

    // Store chunks with document metadata and embeddings
    for (final chunk in chunks) {
      // 生成嵌入向量
      List<double> embedding;
      try {
        embedding = await _embeddingService.generateEmbedding(chunk);
      } catch (e) {
        print('Failed to generate embedding for chunk: $e');
        embedding = _embeddingService.generatePseudoEmbedding(chunk);
      }

      final metadata = jsonEncode({
        'documentId': docId,
        'source': documentPath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _db.insertDocumentChunk(DocumentChunksCompanion(
        knowledgeBaseId: Value(kbId),
        content: Value(chunk),
        vector: Value(_embeddingService.vectorToJson(embedding)),
        metadata: Value(metadata),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  // Chunk text into smaller pieces
  List<String> _chunkText(String text, {required int chunkSize, required int overlap}) {
    final chunks = <String>[];
    final words = text.split(' ');

    int start = 0;
    while (start < words.length) {
      final end = (start + chunkSize).clamp(0, words.length);
      final chunk = words.sublist(start, end).join(' ');
      chunks.add(chunk);

      start += chunkSize - overlap;
    }

    return chunks;
  }

  // Process with embeddings (placeholder for vector search)
  Future<void> generateEmbeddings(String kbId) async {
    final chunks = await _db.getKnowledgeBaseChunks(kbId);

    if (_modelEngine == null) {
      print('No model engine available for embedding generation');
      return;
    }

    for (final chunk in chunks) {
      try {
        // TODO: Use a proper embedding model (e.g., sentence-transformers)
        // For now, we skip embedding generation as the inference engine
        // is designed for text generation, not embeddings

        // In production, you would:
        // 1. Call an embedding API (OpenAI, Cohere, etc.) or
        // 2. Use a local embedding model (sentence-transformers, etc.)
        // 3. Store the embedding vector in the database

        print('Embedding generation not yet implemented for chunk ${chunk.id}');
      } catch (e) {
        print('Failed to generate embedding for chunk ${chunk.id}: $e');
      }
    }
  }

  // Helper method to calculate cosine similarity (for future use with embeddings)
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // Get knowledge base info
  Future<KnowledgeBase?> getKnowledgeBase(String kbId) async {
    return await _db.getKnowledgeBase(kbId);
  }

  // List all knowledge bases
  Future<List<KnowledgeBase>> listKnowledgeBases({String? sessionId}) async {
    final allKbs = await _db.getAllKnowledgeBases();

    if (sessionId != null) {
      return allKbs.where((kb) => kb.sessionId == sessionId || kb.isGlobal).toList();
    }

    return allKbs;
  }
}

class FileNotFoundException implements Exception {
  final String path;
  FileNotFoundException(this.path);

  @override
  String toString() => 'FileNotFoundException: $path';
}

// Riverpod Provider
final ragEngineProvider = Provider<RAGEngine>((ref) {
  return RAGEngine(
    modelEngine: globalModelEngine,
  );
});
