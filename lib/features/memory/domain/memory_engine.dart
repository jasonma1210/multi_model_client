import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/interfaces/memory_interface.dart';
import '../../../core/interfaces/dialogue_interface.dart' as dialogue show Message;
import '../../../core/storage/database_connection.dart';
import '../../../core/storage/database.dart' hide Message;
import '../../../core/engines/model_inference_engine.dart';
import '../../../core/services/embedding_service.dart';

class MemoryEngine implements IMemoryEngine {
  final AppDatabase _db = database;
  final ModelInferenceEngine? _modelEngine;
  final EmbeddingService _embeddingService;
  static const String _tag = 'MemoryEngine';

  // 是否启用语义搜索（需要有效的 embedding 服务）
  bool _semanticSearchEnabled = false;

  MemoryEngine({
    ModelInferenceEngine? modelEngine,
    EmbeddingService? embeddingService,
  })  : _modelEngine = modelEngine,
        _embeddingService = embeddingService ?? EmbeddingService() {
    // 尝试启用语义搜索
    _initSemanticSearch();
  }

  Future<void> _initSemanticSearch() async {
    // 检查是否可以使用远程 embedding API
    // 在生产环境中，这里应该从配置中读取 API key
    _semanticSearchEnabled = true; // 启用，使用伪向量或远程API
  }

  @override
  Future<void> extractMemory(String sessionId, List<dialogue.Message> messages) async {
    // Build prompt for memory extraction
    final conversationText = messages
        .map((m) => '${m.role}: ${m.content}')
        .join('\n');

    // Use LLM to extract memories
    // In production, this would use a smaller, fine-tuned model
    final extractionPrompt = '''
Analyze the following conversation and extract important memories:

$conversationText

Extract:
1. Entities (people, places, things)
2. Facts (important information)
3. Preferences (user preferences)

Format as JSON:
{
  "entities": [...],
  "facts": [...],
  "preferences": [...]
}
''';

    // Try to use LLM for extraction if available
    if (_modelEngine != null) {
      try {
        final response = await _modelEngine.generate(
          'memory-extraction-model',
          extractionPrompt,
          maxTokens: 500,
        );

        // Parse LLM response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
        if (jsonMatch != null) {
          final json = jsonDecode(jsonMatch.group(0)!);

          // Store extracted memories
          if (json['entities'] != null) {
            for (final entity in json['entities']) {
              await _storeMemory(sessionId, 'Entity: $entity', MemoryType.instant);
            }
          }

          if (json['facts'] != null) {
            for (final fact in json['facts']) {
              await _storeMemory(sessionId, 'Fact: $fact', MemoryType.longTerm);
            }
          }

          if (json['preferences'] != null) {
            for (final pref in json['preferences']) {
              await _storeMemory(sessionId, 'Preference: $pref', MemoryType.longTerm);
            }
          }
        }
      } catch (e) {
        debugPrint('[$_tag] LLM 记忆提取失败: $e');
        // Fall back to simple extraction
        await _simpleExtraction(sessionId, messages);
      }
    } else {
      // No LLM available, use simple extraction
      await _simpleExtraction(sessionId, messages);
    }
  }

  Future<void> _simpleExtraction(String sessionId, List<dialogue.Message> messages) async {
    // Store memories from user messages
    for (final message in messages) {
      if (message.role == 'user' && message.content.length > 20) {
        await _storeMemory(sessionId, message.content, MemoryType.working);
      }
    }
  }

  Future<void> _storeMemory(String sessionId, String content, MemoryType type) async {
    // 生成嵌入向量
    List<double> embedding;
    try {
      embedding = await _embeddingService.generateEmbedding(content);
    } catch (e) {
      debugPrint('[$_tag] 生成嵌入向量失败: $e');
      embedding = _embeddingService.generatePseudoEmbedding(content);
    }

    await _db.insertMemory(MemoriesCompanion(
      sessionId: Value(sessionId),
      type: Value(type.name),
      content: Value(content),
      weight: const Value(1.0),
      isGlobal: const Value(false),
      embedding: Value(jsonEncode(embedding)),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<List<MemoryItem>> retrieveMemories(String sessionId, String query) async {
    // Get session-specific memories
    final sessionMemories = await _db.getSessionMemories(sessionId);

    // Get global memories
    final globalMemories = await _db.getGlobalMemories();

    // Combine memories
    final allMemories = [...sessionMemories, ...globalMemories];

    // Use semantic search if enabled
    List<Memory> rankedMemories;
    if (_semanticSearchEnabled) {
      rankedMemories = await _semanticSearch(allMemories, query);
    } else {
      // Fall back to keyword matching
      rankedMemories = _keywordSearch(allMemories, query);
    }

    // Convert to MemoryItem
    return rankedMemories.take(10).map((memory) {
      return MemoryItem(
        id: memory.id,
        sessionId: memory.sessionId,
        content: memory.content,
        type: MemoryType.values.firstWhere((t) => t.name == memory.type),
        weight: memory.weight,
        isGlobal: memory.isGlobal,
        createdAt: memory.createdAt,
        lastAccessedAt: memory.lastAccessedAt,
      );
    }).toList();
  }

  Future<List<Memory>> _semanticSearch(List<Memory> memories, String query) async {
    try {
      // 生成查询的嵌入向量
      final queryEmbedding = await _embeddingService.generateEmbedding(query);

      // 对每个记忆计算相似度
      final scoredMemories = <MapEntry<Memory, double>>[];

      for (final memory in memories) {
        double score = 0.0;

        if (memory.embedding != null && memory.embedding!.isNotEmpty) {
          // 使用预存储的嵌入向量计算相似度
          try {
            final memoryEmbedding = _embeddingService.jsonToVector(memory.embedding!);
            score = _embeddingService.cosineSimilarity(queryEmbedding, memoryEmbedding);
          } catch (e) {
            // 如果解析失败，回退到关键词匹配
            debugPrint('[$_tag] 解析记忆嵌入失败 ${memory.id}: $e');
          }
        }

        // 如果没有嵌入向量或计算失败，使用关键词匹配作为后备
        if (score == 0.0) {
          score = _keywordMatchScore(memory.content, query);
        }

        scoredMemories.add(MapEntry(memory, score));
      }

      // 按相似度排序
      scoredMemories.sort((a, b) => b.value.compareTo(a.value));

      return scoredMemories.map((entry) => entry.key).toList();
    } catch (e) {
      debugPrint('[$_tag] 语义搜索失败: $e');
      return _keywordSearch(memories, query);
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

  List<Memory> _keywordSearch(List<Memory> memories, String query) {
    final queryWords = query.toLowerCase().split(' ');
    final scoredMemories = memories.map((memory) {
      final memoryWords = memory.content.toLowerCase().split(' ');
      final score = queryWords.where((word) => memoryWords.contains(word)).length;
      return MapEntry(memory, score.toDouble());
    }).toList();

    // Sort by score
    scoredMemories.sort((a, b) => b.value.compareTo(a.value));

    return scoredMemories.map((entry) => entry.key).toList();
  }

  @override
  Future<void> updateMemoryWeight(String memoryId, double weight) async {
    await _db.updateMemory(MemoriesCompanion(
      id: Value(memoryId),
      weight: Value(weight),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> archiveMemory(String memoryId) async {
    await _db.updateMemory(MemoriesCompanion(
      id: Value(memoryId),
      type: Value(MemoryType.archived.name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteMemory(String memoryId) async {
    await _db.deleteMemory(memoryId);
  }

  @override
  Future<void> manualAddMemory(String sessionId, String content, {bool isGlobal = false}) async {
    // 生成嵌入向量
    List<double> embedding;
    try {
      embedding = await _embeddingService.generateEmbedding(content);
    } catch (e) {
      debugPrint('[$_tag] 生成嵌入向量失败: $e');
      embedding = _embeddingService.generatePseudoEmbedding(content);
    }

    await _db.insertMemory(MemoriesCompanion(
      sessionId: Value(isGlobal ? null : sessionId),
      type: Value(MemoryType.longTerm.name),
      content: Value(content),
      weight: const Value(1.0),
      isGlobal: Value(isGlobal),
      embedding: Value(jsonEncode(embedding)),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Promote working memory to long-term
  Future<void> promoteToLongTerm(String memoryId) async {
    await _db.updateMemory(MemoriesCompanion(
      id: Value(memoryId),
      type: Value(MemoryType.longTerm.name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Decay old memories
  Future<void> decayMemories({double threshold = 0.1}) async {
    final allMemories = await _db.getAllMemories();

    for (final memory in allMemories) {
      // Calculate decay based on time since last access
      final daysSinceAccess = memory.lastAccessedAt != null
          ? DateTime.now().difference(memory.lastAccessedAt!).inDays
          : DateTime.now().difference(memory.createdAt).inDays;

      final decayFactor = 1.0 - (daysSinceAccess * 0.01);
      final newWeight = memory.weight * decayFactor;

      if (newWeight < threshold) {
        await archiveMemory(memory.id);
      } else {
        await updateMemoryWeight(memory.id, newWeight);
      }
    }
  }
}

// Riverpod Provider
final memoryEngineProvider = Provider<MemoryEngine>((ref) {
  return MemoryEngine(
    modelEngine: globalModelEngine,
  );
});
