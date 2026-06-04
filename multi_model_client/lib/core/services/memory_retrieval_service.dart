/// 记忆检索服务 - LLM Studio 永久记忆系统
/// 
/// 功能：
/// - 层级降级检索（先高层级，再低层级）
/// - 关键词匹配检索
/// - 向量语义检索
/// - 动态组装上下文
/// 
/// @author Jianma
/// @version 1.0.0
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/memory_node.dart';
import '../storage/database.dart';
import '../storage/database_connection.dart';
import 'embedding_service.dart';

/// 检索配置
class MemoryRetrievalConfig {
  /// 每次检索返回的最大数量
  final int maxResults;
  
  /// 是否启用向量检索
  final bool enableVectorSearch;
  
  /// 是否启用关键词检索
  final bool enableKeywordSearch;
  
  /// 最小相关性分数
  final double minRelevanceScore;
  
  /// 检索层级上限（从 Lv1 开始）
  final int maxAbstractionLevel;

  const MemoryRetrievalConfig({
    this.maxResults = 10,
    this.enableVectorSearch = true,
    this.enableKeywordSearch = true,
    this.minRelevanceScore = 0.3,
    this.maxAbstractionLevel = 3,
  });
}

/// 检索结果
class MemoryRetrievalResult {
  final List<MemoryNode> nodes;
  final int totalFound;
  final Map<AbstractionLevel, int> levelDistribution;
  final String? query;

  MemoryRetrievalResult({
    required this.nodes,
    required this.totalFound,
    required this.levelDistribution,
    this.query,
  });

  /// 转换为上下文字符串
  String toContextString({int maxLength = 2000}) {
    if (nodes.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('## 相关记忆');
    buffer.writeln();
    
    for (final node in nodes) {
      buffer.writeln('### ${node.abstractionLevel.label} - ${node.createdAt.toString().substring(0, 10)}');
      buffer.writeln(node.content);
      buffer.writeln();
    }
    
    var result = buffer.toString();
    if (result.length > maxLength) {
      result = '${result.substring(0, maxLength)}\n\n[...记忆内容被截断...]';
    }
    
    return result;
  }
}

/// 记忆检索服务
class MemoryRetrievalService {
  final AppDatabase _db = database;
  final EmbeddingService _embeddingService = EmbeddingService();
  
  /// 配置
  final MemoryRetrievalConfig config;

  MemoryRetrievalService({this.config = const MemoryRetrievalConfig()});

  /// 检索记忆（层级降级策略）
  Future<MemoryRetrievalResult> retrieve({
    required String query,
    String? sessionId,
    bool globalOnly = false,
  }) async {
    final levelCounts = <AbstractionLevel, int>{};
    
    // 1. 获取所有未归档的记忆
    final allMemories = await _db.getAllMemories();
    final candidates = allMemories.where((m) {
      if (m.isArchived) return false;
      if (!globalOnly && sessionId != null && m.sessionId != sessionId && !m.isGlobal) return false;
      if (globalOnly && !m.isGlobal) return false;
      return true;
    }).toList();
    
    // 2. 转换为 MemoryNode 并计算相关性
    final scoredNodes = <({MemoryNode node, double score})>[];
    
    for (final memory in candidates) {
      final node = MemoryNode.fromMemory(memory);
      
      // 计算相关性分数
      double score = 0.0;
      
      // 关键词匹配
      if (config.enableKeywordSearch) {
        score += _calculateKeywordScore(query, node.keywords);
      }
      
      // 向量相似度
      if (config.enableVectorSearch && node.embedding != null) {
        score += await _calculateVectorScore(query, node.embedding!);
      }
      
      // 内容直接匹配
      score += _calculateContentScore(query, node.content);
      
      // 重要性加权
      score *= (0.5 + node.importance * 0.5);
      
      // 抽象层级加权（高层级更重要）
      final levelWeight = 1.0 - (node.abstractionLevel.level - 1) * 0.15;
      score *= levelWeight;
      
      if (score >= config.minRelevanceScore) {
        scoredNodes.add((node: node, score: score));
      }
    }
    
    // 3. 按分数排序并选择
    scoredNodes.sort((a, b) => b.score.compareTo(a.score));
    
    // 4. 层级降级：优先选择高层级，如果数量不足再补充低层级
    final selectedNodes = _selectWithLevelFallback(
      scoredNodes.take(config.maxResults * 2).toList(),
      config.maxResults,
    );
    
    // 5. 统计层级分布
    for (final node in selectedNodes) {
      levelCounts[node.abstractionLevel] = (levelCounts[node.abstractionLevel] ?? 0) + 1;
    }
    
    return MemoryRetrievalResult(
      nodes: selectedNodes,
      totalFound: scoredNodes.length,
      levelDistribution: levelCounts,
      query: query,
    );
  }

  /// 层级降级选择
  List<MemoryNode> _selectWithLevelFallback(
    List<({MemoryNode node, double score})> scoredNodes,
    int maxCount,
  ) {
    final result = <MemoryNode>[];
    
    // 按抽象层级分组
    final byLevel = <AbstractionLevel, List<({MemoryNode node, double score})>>{};
    for (final item in scoredNodes) {
      final level = item.node.abstractionLevel;
      byLevel[level] = [...(byLevel[level] ?? []), item];
    }
    
    // 从高层级开始选择
    for (var level = AbstractionLevel.level1Recent; 
         level.level <= config.maxAbstractionLevel && result.length < maxCount;
         level = AbstractionLevel.values[level.level]) {
      
      final levelNodes = byLevel[level] ?? [];
      final remaining = maxCount - result.length;
      
      // 选择该层级的记忆
      final selected = levelNodes.take(remaining).toList();
      result.addAll(selected.map((n) => n.node));
    }
    
    return result.take(maxCount).toList();
  }

  /// 计算关键词匹配分数
  double _calculateKeywordScore(String query, List<String> keywords) {
    if (keywords.isEmpty) return 0.0;
    
    final queryLower = query.toLowerCase();
    final queryWords = queryLower.split(RegExp(r'[\s,，。、]+')).where((w) => w.isNotEmpty).toSet();
    
    int matchCount = 0;
    for (final keyword in keywords) {
      final keywordLower = keyword.toLowerCase();
      for (final word in queryWords) {
        if (keywordLower.contains(word) || word.contains(keywordLower)) {
          matchCount++;
          break;
        }
      }
    }
    
    return (matchCount / keywords.length * 0.3).clamp(0.0, 0.3);
  }

  /// 计算向量相似度分数
  Future<double> _calculateVectorScore(String query, String embeddingJson) async {
    try {
      // 生成查询的 embedding
      final queryEmbedding = await _embeddingService.generateEmbedding(query);
      
      // 解析存储的 embedding
      final storedEmbedding = jsonDecode(embeddingJson);
      if (storedEmbedding is! List) return 0.0;
      
      // 计算余弦相似度
      final score = _cosineSimilarity(
        queryEmbedding,
        storedEmbedding.map((e) => (e as num).toDouble()).toList(),
      );
      
      return (score * 0.5).clamp(0.0, 0.5); // 向量匹配最高 0.5 分
    } catch (e) {
      debugPrint('[MemoryRetrieval] 向量计算失败: $e');
      return 0.0;
    }
  }

  /// 余弦相似度
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    
    for (var i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0 || normB == 0) return 0.0;
    
    return dotProduct / (normA * normB);
  }

  /// 计算内容直接匹配分数
  double _calculateContentScore(String query, String content) {
    final contentLower = content.toLowerCase();
    final queryLower = query.toLowerCase();
    
    // 完全包含
    if (contentLower.contains(queryLower)) {
      return 0.4;
    }
    
    // 词匹配
    final queryWords = queryLower.split(RegExp(r'[\s,，。、]+')).where((w) => w.length >= 2).toSet();
    if (queryWords.isEmpty) return 0.0;
    
    int matchCount = 0;
    for (final word in queryWords) {
      if (contentLower.contains(word)) {
        matchCount++;
      }
    }
    
    return (matchCount / queryWords.length * 0.2).clamp(0.0, 0.2);
  }

  /// 检索特定层级的记忆
  Future<List<MemoryNode>> retrieveByLevel(AbstractionLevel level) async {
    final allMemories = await _db.getAllMemories();
    final result = <MemoryNode>[];
    
    for (final memory in allMemories) {
      if (memory.isArchived) continue;
      
      final node = MemoryNode.fromMemory(memory);
      if (node.abstractionLevel == level) {
        result.add(node);
      }
    }
    
    // 按重要性排序
    result.sort((a, b) => b.importance.compareTo(a.importance));
    return result.take(config.maxResults).toList();
  }

  /// 获取记忆统计
  Future<MemoryRetrievalStats> getStats() async {
    final allMemories = await _db.getAllMemories();
    
    int total = 0;
    int archived = 0;
    final levelCounts = <AbstractionLevel, int>{};
    final typeCounts = <String, int>{};
    
    for (final memory in allMemories) {
      total++;
      if (memory.isArchived) {
        archived++;
        continue;
      }
      
      final node = MemoryNode.fromMemory(memory);
      levelCounts[node.abstractionLevel] = (levelCounts[node.abstractionLevel] ?? 0) + 1;
      typeCounts[memory.type] = (typeCounts[memory.type] ?? 0) + 1;
    }
    
    return MemoryRetrievalStats(
      totalCount: total,
      activeCount: total - archived,
      archivedCount: archived,
      levelCounts: levelCounts,
      typeCounts: typeCounts,
    );
  }
}

/// 记忆检索统计
class MemoryRetrievalStats {
  final int totalCount;
  final int activeCount;
  final int archivedCount;
  final Map<AbstractionLevel, int> levelCounts;
  final Map<String, int> typeCounts;

  MemoryRetrievalStats({
    required this.totalCount,
    required this.activeCount,
    required this.archivedCount,
    required this.levelCounts,
    required this.typeCounts,
  });
}