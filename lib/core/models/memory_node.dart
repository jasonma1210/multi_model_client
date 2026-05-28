/// 记忆节点模型 - LLM Studio 永久记忆系统
/// 
/// 功能：
/// - 记忆抽象层级（Lv1-Lv5）
/// - 重要性评分算法
/// - 关键词提取与检索
/// - 跨会话记忆融合
/// 
/// @author Jianma
/// @version 1.0.0
library;

import 'package:drift/drift.dart';

import '../storage/database.dart';

/// 记忆抽象层级
enum AbstractionLevel {
  /// Lv1: 7天内 - 完整对话摘要
  level1Recent(1, '完整', 7),
  
  /// Lv2: 7-30天 - 关键事实
  level2Facts(2, '事实', 30),
  
  /// Lv3: 30-90天 - 实体 + 关系
  level3Entities(3, '实体', 90),
  
  /// Lv4: 90-180天 - 高权重关键词
  level4Keywords(4, '关键词', 180),
  
  /// Lv5: >180天 - 仅核心概念
  level5Core(5, '核心', 365);

  final int level;
  final String label;
  final int maxDays;

  const AbstractionLevel(this.level, this.label, this.maxDays);

  /// 根据天数获取抽象层级
  static AbstractionLevel fromDays(int days) {
    if (days <= 7) return AbstractionLevel.level1Recent;
    if (days <= 30) return AbstractionLevel.level2Facts;
    if (days <= 90) return AbstractionLevel.level3Entities;
    if (days <= 180) return AbstractionLevel.level4Keywords;
    return AbstractionLevel.level5Core;
  }
}

/// 记忆节点 - 扩展现有 Memory 模型
class MemoryNode {
  /// 基础记忆 ID
  final String id;
  
  /// 所属会话 ID（null 为全局记忆）
  final String? sessionId;
  
  /// 记忆类型
  final String type;
  
  /// 记忆内容
  final String content;
  
  /// 实体标签（JSON 格式）
  final String? entityTags;
  
  /// 权重（0-1）
  final double weight;
  
  /// 是否全局记忆
  final bool isGlobal;
  
  /// 是否已归档
  final bool isArchived;
  
  /// 向量嵌入（JSON 格式）
  final String? embedding;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 最后访问时间
  final DateTime? lastAccessedAt;
  
  // ====== 新增字段 ======
  
  /// 抽象层级（Lv1-Lv5）
  final AbstractionLevel abstractionLevel;
  
  /// 重要性评分（0-1）
  final double importance;
  
  /// 检索关键词列表
  final List<String> keywords;
  
  /// 压缩后的内容摘要
  final String? compressedContent;
  
  /// 原始内容（压缩前）
  final String? originalContent;
  
  /// 记忆来源（session/knowledge/rag/manual）
  final String source;
  
  /// 访问次数
  final int accessCount;
  
  /// 关联的记忆节点 ID（用于记忆融合）
  final List<String> relatedNodeIds;

  MemoryNode({
    required this.id,
    this.sessionId,
    required this.type,
    required this.content,
    this.entityTags,
    required this.weight,
    required this.isGlobal,
    required this.isArchived,
    this.embedding,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
    // 新增字段
    AbstractionLevel? abstractionLevel,
    double? importance,
    List<String>? keywords,
    this.compressedContent,
    this.originalContent,
    this.source = 'manual',
    this.accessCount = 0,
    List<String>? relatedNodeIds,
  })  : abstractionLevel = abstractionLevel ?? _calculateAbstractionLevel(createdAt),
        importance = importance ?? _calculateImportance(
          createdAt: createdAt,
          lastAccessedAt: lastAccessedAt,
          contentLength: content.length,
          weight: weight,
          isGlobal: isGlobal,
        ),
        keywords = keywords ?? _extractKeywords(content),
        relatedNodeIds = relatedNodeIds ?? [];

  /// 从现有 Memory 创建 MemoryNode
  factory MemoryNode.fromMemory(dynamic memory, {
    String source = 'manual',
    int accessCount = 0,
    List<String>? relatedNodeIds,
  }) {
    return MemoryNode(
      id: memory.id,
      sessionId: memory.sessionId,
      type: memory.type,
      content: memory.content,
      entityTags: memory.entityTags,
      weight: memory.weight,
      isGlobal: memory.isGlobal,
      isArchived: memory.isArchived,
      embedding: memory.embedding,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
      lastAccessedAt: memory.lastAccessedAt,
      source: source,
      accessCount: accessCount,
      relatedNodeIds: relatedNodeIds,
    );
  }

  /// 计算抽象层级
  static AbstractionLevel _calculateAbstractionLevel(DateTime createdAt) {
    final days = DateTime.now().difference(createdAt).inDays;
    return AbstractionLevel.fromDays(days);
  }

  /// 计算重要性评分（0-1）
  static double _calculateImportance({
    required DateTime createdAt,
    DateTime? lastAccessedAt,
    required int contentLength,
    required double weight,
    required bool isGlobal,
  }) {
    double score = 0.0;

    // 1. 访问频率因子（最高 0.3）
    if (lastAccessedAt != null) {
      final daysSinceAccess = DateTime.now().difference(lastAccessedAt).inDays;
      final accessFrequency = 1.0 / (daysSinceAccess + 1);
      score += (accessFrequency * 0.3).clamp(0.0, 0.3);
    } else {
      final daysSinceCreate = DateTime.now().difference(createdAt).inDays;
      final ageFactor = 1.0 / (daysSinceCreate + 1);
      score += (ageFactor * 0.15).clamp(0.0, 0.15);
    }

    // 2. 内容长度因子（最高 0.3）
    if (contentLength > 10 && contentLength < 500) {
      score += 0.3;
    } else if (contentLength >= 500 && contentLength < 2000) {
      score += 0.2;
    } else if (contentLength >= 2000) {
      score += 0.1;
    } else {
      score += 0.1;
    }

    // 3. 权重因子（最高 0.2）
    score += (weight * 0.2).clamp(0.0, 0.2);

    // 4. 是否全局记忆（最高 0.2）
    if (isGlobal) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// 提取关键词
  static List<String> _extractKeywords(String content) {
    final keywords = <String>[];
    
    // 提取中文关键词（2-4 个连续字符）
    final cnRegex = RegExp(r'[\u4e00-\u9fa5]{2,4}');
    final cnMatches = cnRegex.allMatches(content);
    final cnCounts = <String, int>{};
    for (final match in cnMatches) {
      final word = match.group(0)!;
      cnCounts[word] = (cnCounts[word] ?? 0) + 1;
    }
    // 取频率最高的 5 个
    final sortedCn = cnCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    keywords.addAll(sortedCn.take(5).map((e) => e.key));

    // 提取英文关键词
    final enRegex = RegExp(r'\b[A-Za-z]{3,}\b');
    final enMatches = enRegex.allMatches(content);
    final enCounts = <String, int>{};
    for (final match in enMatches) {
      final word = match.group(0)!.toLowerCase();
      // 过滤停用词
      if (!_isStopWord(word)) {
        enCounts[word] = (enCounts[word] ?? 0) + 1;
      }
    }
    final sortedEn = enCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    keywords.addAll(sortedEn.take(5).map((e) => e.key));

    return keywords.take(10).toList();
  }

  /// 是否为停用词
  static bool _isStopWord(String word) {
    const stopWords = {
      'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can',
      'had', 'her', 'was', 'one', 'our', 'out', 'has', 'have', 'been',
      'would', 'could', 'there', 'their', 'what', 'about', 'which',
      'when', 'make', 'like', 'time', 'just', 'know', 'take', 'into',
      'year', 'your', 'some', 'them', 'than', 'then', 'look', 'only',
      'come', 'its', 'over', 'think', 'also', 'back', 'after', 'use',
      'two', 'how', 'first', 'new', 'want', 'because', 'any',
      'these', 'give', 'day', 'most', 'say', 'should', 'may', 'must',
    };
    return stopWords.contains(word.toLowerCase());
  }

  /// 转换为压缩版本
  MemoryNode compress(AbstractionLevel targetLevel) {
    if (abstractionLevel.level <= targetLevel.level) {
      return this; // 无需压缩
    }

    final compressed = _generateCompressedContent(targetLevel);
    return MemoryNode(
      id: id,
      sessionId: sessionId,
      type: type,
      content: compressed, // 更新为压缩内容
      entityTags: entityTags,
      weight: weight,
      isGlobal: isGlobal,
      isArchived: isArchived,
      embedding: embedding,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastAccessedAt: lastAccessedAt,
      abstractionLevel: targetLevel,
      importance: importance * 0.8, // 压缩后重要性略降
      keywords: keywords.take(5).toList(), // 保留核心关键词
      compressedContent: compressed,
      originalContent: content, // 保存原始内容
      source: source,
      accessCount: accessCount,
      relatedNodeIds: relatedNodeIds,
    );
  }

  /// 生成压缩内容
  String _generateCompressedContent(AbstractionLevel level) {
    switch (level) {
      case AbstractionLevel.level1Recent:
        return content;
        
      case AbstractionLevel.level2Facts:
        // 提取关键事实（保留前 50%）
        if (content.length <= 200) return content;
        return '${content.substring(0, content.length ~/ 2)}...\n[关键事实已提取]';
        
      case AbstractionLevel.level3Entities:
        // 提取实体和关系（保留前 30%）
        if (content.length <= 100) return content;
        return '${content.substring(0, (content.length * 0.3).toInt())}...\n[实体关系已提取]';
        
      case AbstractionLevel.level4Keywords:
        // 提取关键词（保留前 15%）
        if (content.length <= 50) return content;
        return '${content.substring(0, (content.length * 0.15).toInt())}...\n[关键词已提取]';
        
      case AbstractionLevel.level5Core:
        // 仅保留核心概念（保留前 10%）
        if (content.length <= 30) return content;
        return '${content.substring(0, (content.length * 0.1).toInt())}...\n[核心概念已提取]';
    }
  }

  /// 转换为 Drift Companion（用于更新数据库）
  MemoriesCompanion toCompanion() {
    return MemoriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      content: Value(content),
      entityTags: Value(entityTags),
      weight: Value(weight),
      isGlobal: Value(isGlobal),
      isArchived: Value(isArchived),
      embedding: Value(embedding),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  /// 复制并修改
  MemoryNode copyWith({
    String? id,
    String? sessionId,
    String? type,
    String? content,
    String? entityTags,
    double? weight,
    bool? isGlobal,
    bool? isArchived,
    String? embedding,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAccessedAt,
    AbstractionLevel? abstractionLevel,
    double? importance,
    List<String>? keywords,
    String? compressedContent,
    String? originalContent,
    String? source,
    int? accessCount,
    List<String>? relatedNodeIds,
  }) {
    return MemoryNode(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      content: content ?? this.content,
      entityTags: entityTags ?? this.entityTags,
      weight: weight ?? this.weight,
      isGlobal: isGlobal ?? this.isGlobal,
      isArchived: isArchived ?? this.isArchived,
      embedding: embedding ?? this.embedding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      abstractionLevel: abstractionLevel ?? this.abstractionLevel,
      importance: importance ?? this.importance,
      keywords: keywords ?? this.keywords,
      compressedContent: compressedContent ?? this.compressedContent,
      originalContent: originalContent ?? this.originalContent,
      source: source ?? this.source,
      accessCount: accessCount ?? this.accessCount,
      relatedNodeIds: relatedNodeIds ?? this.relatedNodeIds,
    );
  }

  /// 转为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'type': type,
      'content': content,
      'entityTags': entityTags,
      'weight': weight,
      'isGlobal': isGlobal,
      'isArchived': isArchived,
      'embedding': embedding,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt?.toIso8601String(),
      'abstractionLevel': abstractionLevel.level,
      'importance': importance,
      'keywords': keywords,
      'compressedContent': compressedContent,
      'originalContent': originalContent,
      'source': source,
      'accessCount': accessCount,
      'relatedNodeIds': relatedNodeIds,
    };
  }

  /// 从 JSON 创建
  factory MemoryNode.fromJson(Map<String, dynamic> json) {
    return MemoryNode(
      id: json['id'],
      sessionId: json['sessionId'],
      type: json['type'],
      content: json['content'],
      entityTags: json['entityTags'],
      weight: (json['weight'] as num).toDouble(),
      isGlobal: json['isGlobal'],
      isArchived: json['isArchived'],
      embedding: json['embedding'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastAccessedAt: json['lastAccessedAt'] != null 
          ? DateTime.parse(json['lastAccessedAt']) 
          : null,
      abstractionLevel: AbstractionLevel.values.firstWhere(
        (e) => e.level == json['abstractionLevel'],
        orElse: () => AbstractionLevel.level1Recent,
      ),
      importance: (json['importance'] as num).toDouble(),
      keywords: List<String>.from(json['keywords'] ?? []),
      compressedContent: json['compressedContent'],
      originalContent: json['originalContent'],
      source: json['source'] ?? 'manual',
      accessCount: json['accessCount'] ?? 0,
      relatedNodeIds: List<String>.from(json['relatedNodeIds'] ?? []),
    );
  }

  @override
  String toString() {
    return 'MemoryNode(id: $id, level: ${abstractionLevel.label}, importance: ${importance.toStringAsFixed(2)})';
  }
}

/// 记忆节点搜索结果
class MemoryNodeSearchResult {
  final MemoryNode node;
  final double relevanceScore;
  final List<String> matchedKeywords;

  MemoryNodeSearchResult({
    required this.node,
    required this.relevanceScore,
    required this.matchedKeywords,
  });
}

/// 记忆宫殿位置
class MemoryPalaceLocation {
  final String roomId;
  final String position;
  final double x;
  final double y;

  MemoryPalaceLocation({
    required this.roomId,
    required this.position,
    required this.x,
    required this.y,
  });
}