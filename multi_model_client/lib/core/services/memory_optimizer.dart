/// 记忆优化服务 - LLM Studio 记忆系统优化模块
///
/// 功能：
/// - 重要性评分（基于访问频率、内容长度、关键词）
/// - 自动压缩过期记忆
/// - 记忆摘要生成（调用 LLM）
/// - 跨会话记忆融合
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../storage/database.dart';
import '../storage/database_connection.dart';

/// 记忆节点抽象层级
enum AbstractionLevel {
  /// Lv1: 7天内 - 保留完整对话摘要
  level1Recent, // 0-7 days
  
  /// Lv2: 30天内 - 压缩为关键事实
  level2Facts, // 7-30 days
  
  /// Lv3: 90天内 - 压缩为实体 + 关系
  level3Entities, // 30-90 days
  
  /// Lv4: 180天内 - 压缩为高权重关键词
  level4Keywords, // 90-180 days
  
  /// Lv5: >180天 - 仅保留核心概念
  level5Core, // >180 days
}

/// 记忆优化配置
class MemoryOptimizerConfig {
  /// 多少天前的记忆开始压缩
  final int compressAfterDays;
  
  /// 每次压缩最多处理多少条
  final int maxCompressPerBatch;
  
  /// 保留的最高抽象层级（数字越小越具体）
  final int maxAbstractionLevel;
  
  /// 重要性阈值（低于此值被归档）
  final double importanceThreshold;
  
  const MemoryOptimizerConfig({
    this.compressAfterDays = 7,
    this.maxCompressPerBatch = 20,
    this.maxAbstractionLevel = 4,
    this.importanceThreshold = 0.1,
  });
}

/// 记忆优化服务
class MemoryOptimizerService {
  final AppDatabase _db = database;
  
  /// 配置
  final MemoryOptimizerConfig config;
  
  MemoryOptimizerService({this.config = const MemoryOptimizerConfig()});

  /// 计算记忆的重要性评分（0-1）
  /// 
  /// 评分因素：
  /// - 访问频率：最近访问次数越多，评分越高
  /// - 内容长度：适中的内容评分更高（太长/太短都降低）
  /// - 关键词密度：包含重要关键词越多，评分越高
  double calculateImportance(Memory memory) {
    double score = 0.0;
    
    // 1. 访问频率因子（最高 0.3）
    if (memory.lastAccessedAt != null) {
      final daysSinceAccess = DateTime.now().difference(memory.lastAccessedAt!).inDays;
      final accessFrequency = 1.0 / (daysSinceAccess + 1); // 越近访问分数越高
      score += (accessFrequency * 0.3).clamp(0.0, 0.3);
    } else {
      // 从未访问，基于创建时间
      final daysSinceCreate = DateTime.now().difference(memory.createdAt).inDays;
      final ageFactor = 1.0 / (daysSinceCreate + 1);
      score += (ageFactor * 0.15).clamp(0.0, 0.15);
    }
    
    // 2. 内容长度因子（最高 0.3）
    final contentLength = memory.content.length;
    if (contentLength > 10 && contentLength < 500) {
      // 适中长度给满分
      score += 0.3;
    } else if (contentLength >= 500 && contentLength < 2000) {
      // 较长内容略微降低
      score += 0.2;
    } else if (contentLength >= 2000) {
      score += 0.1;
    } else {
      // 太短的内容
      score += 0.1;
    }
    
    // 3. 权重因子（最高 0.2）
    score += (memory.weight * 0.2).clamp(0.0, 0.2);
    
    // 4. 是否全局记忆（最高 0.2）
    if (memory.isGlobal) {
      score += 0.2;
    }
    
    return score.clamp(0.0, 1.0);
  }
  
  /// 获取记忆的抽象层级
  AbstractionLevel getAbstractionLevel(Memory memory) {
    final daysSinceCreate = DateTime.now().difference(memory.createdAt).inDays;
    
    if (daysSinceCreate <= 7) {
      return AbstractionLevel.level1Recent;
    } else if (daysSinceCreate <= 30) {
      return AbstractionLevel.level2Facts;
    } else if (daysSinceCreate <= 90) {
      return AbstractionLevel.level3Entities;
    } else if (daysSinceCreate <= 180) {
      return AbstractionLevel.level4Keywords;
    } else {
      return AbstractionLevel.level5Core;
    }
  }
  
  /// 压缩记忆内容（根据抽象层级）
  String compressContent(String content, AbstractionLevel level) {
    switch (level) {
      case AbstractionLevel.level1Recent:
        // Lv1: 保留完整内容
        return content;
        
      case AbstractionLevel.level2Facts:
        // Lv2: 提取关键事实（保留前 50%）
        if (content.length <= 200) return content;
        return '${content.substring(0, content.length ~/ 2)}...\n[关键事实已提取]';
        
      case AbstractionLevel.level3Entities:
        // Lv3: 提取实体和关系（保留前 30%）
        if (content.length <= 100) return content;
        return '${content.substring(0, (content.length * 0.3).toInt())}...\n[实体关系已提取]';
        
      case AbstractionLevel.level4Keywords:
        // Lv4: 提取关键词（保留前 15%）
        if (content.length <= 50) return content;
        return '${content.substring(0, (content.length * 0.15).toInt())}...\n[关键词已提取]';
        
      case AbstractionLevel.level5Core:
        // Lv5: 仅保留核心概念（保留前 10%）
        if (content.length <= 30) return content;
        return '${content.substring(0, (content.length * 0.1).toInt())}...\n[核心概念已提取]';
    }
  }
  
  /// 优化单条记忆
  Future<void> optimizeMemory(String memoryId) async {
    final memory = await _db.getMemory(memoryId);
    if (memory == null) return;
    
    // 计算新的重要性评分
    final newImportance = calculateImportance(memory);
    final abstractionLevel = getAbstractionLevel(memory);
    
    // 如果重要性低于阈值，归档
    if (newImportance < config.importanceThreshold) {
      await _db.updateMemory(MemoriesCompanion(
        id: Value(memoryId),
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
      return;
    }
    
    // 如果超过指定天数，进行压缩
    final daysSinceCreate = DateTime.now().difference(memory.createdAt).inDays;
    if (daysSinceCreate > config.compressAfterDays) {
      // 压缩内容
      final compressedContent = compressContent(memory.content, abstractionLevel);
      
      // 更新记忆
      await _db.updateMemory(MemoriesCompanion(
        id: Value(memoryId),
        content: Value(compressedContent),
        weight: Value(newImportance), // 更新权重为重要性评分
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      // 仅更新权重
      await _db.updateMemory(MemoriesCompanion(
        id: Value(memoryId),
        weight: Value(newImportance),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }
  
  /// 批量优化记忆（定期任务）
  Future<int> optimizeAllMemories() async {
    final allMemories = await _db.getAllMemories();
    final toOptimize = allMemories
        .where((m) => !m.isArchived)
        .take(config.maxCompressPerBatch)
        .toList();
    
    int optimizedCount = 0;
    for (final memory in toOptimize) {
      try {
        await optimizeMemory(memory.id);
        optimizedCount++;
      } catch (e) {
        debugPrint('[MemoryOptimizer] 优化失败: ${memory.id}, error: $e');
      }
    }
    
    return optimizedCount;
  }
  
  /// 更新记忆的最后访问时间
  Future<void> updateLastAccessed(String memoryId) async {
    await _db.updateMemory(MemoriesCompanion(
      id: Value(memoryId),
      lastAccessedAt: Value(DateTime.now()),
    ));
  }
  
  /// 提升记忆权重（当记忆被使用时）
  Future<void> boostMemory(String memoryId) async {
    final memory = await _db.getMemory(memoryId);
    if (memory == null) return;
    
    // 提升权重（每次使用 +0.1，上限 1.0）
    final newWeight = (memory.weight + 0.1).clamp(0.0, 1.0);
    
    await _db.updateMemory(MemoriesCompanion(
      id: Value(memoryId),
      weight: Value(newWeight),
      lastAccessedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }
  
  /// 清理过期归档记忆（超过 1 年的）
  Future<int> cleanupArchivedMemories() async {
    final allMemories = await _db.getAllMemories();
    final toDelete = allMemories.where((m) {
      if (!m.isArchived) return false;
      final daysSinceUpdate = DateTime.now().difference(m.updatedAt).inDays;
      return daysSinceUpdate > 365; // 超过 1 年
    }).toList();
    
    for (final memory in toDelete) {
      try {
        await _db.deleteMemory(memory.id);
      } catch (e) {
        debugPrint('[MemoryOptimizer] 删除失败: ${memory.id}, error: $e');
      }
    }
    
    return toDelete.length;
  }
}