/// 记忆压缩引擎 - LLM Studio 永久记忆系统
/// 
/// 功能：
/// - 定期扫描旧记忆（>7天）
/// - LLM 压缩为摘要节点
/// - 更新抽象层级
/// - 关键词提取与检索
/// 
/// @author Jianma
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../models/memory_node.dart';
import '../storage/database.dart';
import '../storage/database_connection.dart';

/// 记忆压缩配置
class MemoryCompressConfig {
  /// 多少天前的记忆开始压缩
  final int compressAfterDays;
  
  /// 每次压缩最多处理多少条
  final int maxCompressPerBatch;
  
  /// 保留的最高抽象层级
  final int maxAbstractionLevel;
  
  /// 重要性阈值（低于此值被归档）
  final double importanceThreshold;
  
  /// 是否使用 LLM 压缩（否则用规则压缩）
  final bool useLlmCompression;
  
  /// LLM 压缩回调
  final Future<String> Function(String content)? llmCompressCallback;

  const MemoryCompressConfig({
    this.compressAfterDays = 7,
    this.maxCompressPerBatch = 20,
    this.maxAbstractionLevel = 4,
    this.importanceThreshold = 0.1,
    this.useLlmCompression = false,
    this.llmCompressCallback,
  });
}

/// 压缩任务结果
class CompressTaskResult {
  final String memoryId;
  final bool success;
  final AbstractionLevel oldLevel;
  final AbstractionLevel newLevel;
  final String? error;

  CompressTaskResult({
    required this.memoryId,
    required this.success,
    required this.oldLevel,
    required this.newLevel,
    this.error,
  });
}

/// 记忆压缩引擎
class MemoryCompressEngine {
  final AppDatabase _db = database;
  
  /// 配置
  final MemoryCompressConfig config;
  
  /// 是否正在运行
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  MemoryCompressEngine({this.config = const MemoryCompressConfig()});

  /// 扫描并压缩符合条件的记忆
  Future<List<CompressTaskResult>> scanAndCompress() async {
    if (_isRunning) {
      debugPrint('[MemoryCompressEngine] 压缩任务正在运行中，跳过');
      return [];
    }
    
    _isRunning = true;
    final results = <CompressTaskResult>[];
    
    try {
      // 获取所有未归档的记忆
      final allMemories = await _db.getAllMemories();
      final toCompress = <dynamic>[];
      
      for (final memory in allMemories) {
        if (memory.isArchived) continue;
        
        final daysSinceCreate = DateTime.now().difference(memory.createdAt).inDays;
        
        // 检查是否需要压缩
        if (daysSinceCreate > config.compressAfterDays) {
          // 计算当前抽象层级
          final currentLevel = AbstractionLevel.fromDays(daysSinceCreate);
          
          // 如果超过配置的层级，需要压缩
          if (currentLevel.level > config.maxAbstractionLevel) {
            toCompress.add(memory);
          }
        }
      }
      
      // 限制每批处理数量
      final batch = toCompress.take(config.maxCompressPerBatch).toList();
      
      debugPrint('[MemoryCompressEngine] 开始压缩 ${batch.length} 条记忆');
      
      for (final memory in batch) {
        final result = await _compressMemory(memory);
        results.add(result);
      }
      
      debugPrint('[MemoryCompressEngine] 压缩完成，成功 ${results.where((r) => r.success).length} 条');
      
    } catch (e) {
      debugPrint('[MemoryCompressEngine] 压缩任务异常: $e');
    } finally {
      _isRunning = false;
    }
    
    return results;
  }

  /// 压缩单条记忆
  Future<CompressTaskResult> _compressMemory(dynamic memory) async {
    try {
      // 创建 MemoryNode
      final node = MemoryNode.fromMemory(memory);
      
      final oldLevel = node.abstractionLevel;
      
      // 计算目标层级
      final daysSinceCreate = DateTime.now().difference(memory.createdAt).inDays;
      final targetLevel = AbstractionLevel.fromDays(daysSinceCreate);
      
      // 如果目标层级不超过当前层级，无需压缩
      if (targetLevel.level <= oldLevel.level) {
        return CompressTaskResult(
          memoryId: memory.id,
          success: true,
          oldLevel: oldLevel,
          newLevel: oldLevel,
        );
      }
      
      String compressedContent;
      
      // 根据配置选择压缩方式
      if (config.useLlmCompression && config.llmCompressCallback != null) {
        // 使用 LLM 压缩
        compressedContent = await config.llmCompressCallback!(memory.content);
      } else {
        // 使用规则压缩
        compressedContent = _ruleBasedCompress(memory.content, targetLevel);
      }
      
      // 更新记忆
      await _db.updateMemory(MemoriesCompanion(
        id: Value(memory.id),
        content: Value(compressedContent),
        weight: Value(node.importance * 0.8), // 更新权重
        updatedAt: Value(DateTime.now()),
      ));
      
      return CompressTaskResult(
        memoryId: memory.id,
        success: true,
        oldLevel: oldLevel,
        newLevel: targetLevel,
      );
      
    } catch (e) {
      debugPrint('[MemoryCompressEngine] 压缩记忆失败: ${memory.id}, error: $e');
      return CompressTaskResult(
        memoryId: memory.id,
        success: false,
        oldLevel: AbstractionLevel.level1Recent,
        newLevel: AbstractionLevel.level1Recent,
        error: e.toString(),
      );
    }
  }

  /// 基于规则的压缩
  String _ruleBasedCompress(String content, AbstractionLevel level) {
    switch (level) {
      case AbstractionLevel.level1Recent:
        return content;
        
      case AbstractionLevel.level2Facts:
        // 提取关键事实：保留前 50%
        if (content.length <= 200) return content;
        final half = content.length ~/ 2;
        return '${content.substring(0, half)}\n\n[以上为关键事实摘要]';
        
      case AbstractionLevel.level3Entities:
        // 提取实体：保留前 30%
        if (content.length <= 100) return content;
        final third = (content.length * 0.3).toInt();
        return '${content.substring(0, third)}\n\n[以上为实体关系摘要]';
        
      case AbstractionLevel.level4Keywords:
        // 提取关键词：保留前 15%
        if (content.length <= 50) return content;
        final quarter = (content.length * 0.15).toInt();
        return '${content.substring(0, quarter)}\n\n[以上为关键词摘要]';
        
      case AbstractionLevel.level5Core:
        // 核心概念：保留前 10%
        if (content.length <= 30) return content;
        final tenth = (content.length * 0.1).toInt();
        return '${content.substring(0, tenth)}\n\n[以上为核心概念]';
    }
  }

  /// 使用 LLM 生成智能摘要
  Future<String> generateLlmSummary(String content, {
    String? systemPrompt,
  }) async {
    if (config.llmCompressCallback == null) {
      throw Exception('未配置 LLM 压缩回调');
    }
    
    final prompt = systemPrompt ?? '''请将以下记忆内容压缩为简洁的摘要，保留关键信息和核心概念：

$content

请生成 50-100 字的摘要：''';
    
    return await config.llmCompressCallback!(prompt);
  }

  /// 归档低重要性记忆
  Future<int> archiveLowImportanceMemories() async {
    final allMemories = await _db.getAllMemories();
    final toArchive = <dynamic>[];
    
    for (final memory in allMemories) {
      if (memory.isArchived) continue;
      
      // 计算重要性
      final node = MemoryNode.fromMemory(memory);
      if (node.importance < config.importanceThreshold) {
        toArchive.add(memory);
      }
    }
    
    int archivedCount = 0;
    for (final memory in toArchive) {
      try {
        await _db.updateMemory(MemoriesCompanion(
          id: Value(memory.id),
          isArchived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
        archivedCount++;
      } catch (e) {
        debugPrint('[MemoryCompressEngine] 归档失败: ${memory.id}, error: $e');
      }
    }
    
    return archivedCount;
  }

  /// 清理过期归档记忆（超过 1 年的）
  Future<int> cleanupArchivedMemories({int daysThreshold = 365}) async {
    final allMemories = await _db.getAllMemories();
    final toDelete = <dynamic>[];
    
    for (final memory in allMemories) {
      if (!memory.isArchived) continue;
      
      final daysSinceUpdate = DateTime.now().difference(memory.updatedAt).inDays;
      if (daysSinceUpdate > daysThreshold) {
        toDelete.add(memory);
      }
    }
    
    int deletedCount = 0;
    for (final memory in toDelete) {
      try {
        await _db.deleteMemory(memory.id);
        deletedCount++;
      } catch (e) {
        debugPrint('[MemoryCompressEngine] 删除失败: ${memory.id}, error: $e');
      }
    }
    
    return deletedCount;
  }

  /// 获取压缩统计信息
  Future<MemoryCompressStats> getStats() async {
    final allMemories = await _db.getAllMemories();
    
    int totalCount = 0;
    int archivedCount = 0;
    final levelCounts = <AbstractionLevel, int>{};
    
    for (final memory in allMemories) {
      totalCount++;
      if (memory.isArchived) {
        archivedCount++;
        continue;
      }
      
      final level = AbstractionLevel.fromDays(
        DateTime.now().difference(memory.createdAt).inDays,
      );
      levelCounts[level] = (levelCounts[level] ?? 0) + 1;
    }
    
    return MemoryCompressStats(
      totalCount: totalCount,
      activeCount: totalCount - archivedCount,
      archivedCount: archivedCount,
      levelCounts: levelCounts,
    );
  }
}

/// 记忆压缩统计
class MemoryCompressStats {
  final int totalCount;
  final int activeCount;
  final int archivedCount;
  final Map<AbstractionLevel, int> levelCounts;

  MemoryCompressStats({
    required this.totalCount,
    required this.activeCount,
    required this.archivedCount,
    required this.levelCounts,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('记忆统计:');
    buffer.writeln('- 总计: $totalCount');
    buffer.writeln('- 活跃: $activeCount');
    buffer.writeln('- 已归档: $archivedCount');
    buffer.writeln('- 层级分布:');
    for (final entry in levelCounts.entries) {
      buffer.writeln('  • Lv${entry.key.level} ${entry.key.label}: ${entry.value}');
    }
    return buffer.toString();
  }
}