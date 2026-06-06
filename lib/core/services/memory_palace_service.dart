/// 记忆宫殿服务 - LLM Studio 永久记忆系统
/// 
/// 功能：
/// - 记忆宫殿管理（房间/位置）
/// - 节点抽象化调度
/// - 跨会话记忆融合
/// - 自动记忆组织
/// 
/// @author Jianma
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../models/memory_node.dart';
import '../storage/database.dart';
import '../storage/database_connection.dart';
import 'memory_retrieval_service.dart';
import 'memory_compress_engine.dart';

/// 记忆宫殿房间
class MemoryPalaceRoom {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final int capacity;
  final List<MemoryPalaceLocation> locations;

  MemoryPalaceRoom({
    required this.id,
    required this.name,
    this.description,
    this.icon = '🏠',
    this.capacity = 100,
    this.locations = const [],
  });
}

/// 记忆宫殿位置
class MemoryPalacePosition {
  final String roomId;
  final String positionId;
  final String label;
  final double x;
  final double y;

  MemoryPalacePosition({
    required this.roomId,
    required this.positionId,
    required this.label,
    required this.x,
    required this.y,
  });
}

/// 记忆宫殿配置
class MemoryPalaceConfig {
  /// 自动压缩间隔（小时）
  final int compressIntervalHours;
  
  /// 自动归档阈值（重要性低于此值归档）
  final double archiveThreshold;
  
  /// 最大活跃记忆数
  final int maxActiveMemories;
  
  /// 是否启用跨会话融合
  final bool enableCrossSessionFusion;

  const MemoryPalaceConfig({
    this.compressIntervalHours = 24,
    this.archiveThreshold = 0.05,
    this.maxActiveMemories = 1000,
    this.enableCrossSessionFusion = true,
  });
}

/// 记忆宫殿服务
/// 
/// 参考古希腊记忆宫殿法，将记忆存储在虚拟的"房间"中
/// 支持自动组织、跨会话融合、智能检索
class MemoryPalaceService {
  final AppDatabase _db = database;
  final MemoryRetrievalService _retrievalService = MemoryRetrievalService();
  final MemoryCompressEngine _compressEngine = MemoryCompressEngine();
  
  /// 配置
  final MemoryPalaceConfig config;
  
  /// 房间定义
  final Map<String, MemoryPalaceRoom> _rooms = {};
  
  /// 最后压缩时间
  DateTime? _lastCompressTime;

  MemoryPalaceService({this.config = const MemoryPalaceConfig()}) {
    _initRooms();
  }

  /// 初始化默认房间
  void _initRooms() {
    _rooms['recent'] = MemoryPalaceRoom(
      id: 'recent',
      name: '最近记忆',
      description: '最近 7 天的对话记忆',
      icon: '🕐',
      capacity: 100,
    );
    
    _rooms['facts'] = MemoryPalaceRoom(
      id: 'facts',
      name: '关键事实',
      description: '7-30 天的重要事实',
      icon: '📌',
      capacity: 200,
    );
    
    _rooms['entities'] = MemoryPalaceRoom(
      id: 'entities',
      name: '实体关系',
      description: '30-90 天的实体和关系',
      icon: '🔗',
      capacity: 300,
    );
    
    _rooms['keywords'] = MemoryPalaceRoom(
      id: 'keywords',
      name: '关键词库',
      description: '90-180 天的高权重关键词',
      icon: '🔑',
      capacity: 500,
    );
    
    _rooms['core'] = MemoryPalaceRoom(
      id: 'core',
      name: '核心概念',
      description: '180 天以上的核心概念',
      icon: '💎',
      capacity: 1000,
    );
    
    _rooms['global'] = MemoryPalaceRoom(
      id: 'global',
      name: '全局记忆',
      description: '跨会话的重要记忆',
      icon: '🌐',
      capacity: 500,
    );
  }

  /// 获取所有房间
  List<MemoryPalaceRoom> getRooms() {
    return _rooms.values.toList();
  }

  /// 获取指定房间
  MemoryPalaceRoom? getRoom(String roomId) {
    return _rooms[roomId];
  }

  /// 添加记忆到宫殿
  Future<void> addMemory({
    required String content,
    String? sessionId,
    String type = 'long_term',
    bool isGlobal = false,
    String? roomId,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    
    // 确定房间
    final targetRoom = roomId ?? _determineRoom(isGlobal);
    
    // 创建记忆
    await _db.createMemory(MemoriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      type: Value(type),
      content: Value(content),
      weight: const Value(1.0),
      isGlobal: Value(isGlobal),
      isArchived: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    
    debugPrint('[MemoryPalace] 添加记忆到 $targetRoom: ${content.substring(0, 20)}...');
  }

  /// 确定记忆应放入的房间
  String _determineRoom(bool isGlobal) {
    if (isGlobal) return 'global';
    return 'recent';
  }

  /// 检索记忆（跨房间）
  Future<List<MemoryNode>> searchMemories({
    required String query,
    String? sessionId,
    bool globalOnly = false,
    int maxResults = 10,
  }) async {
    final result = await _retrievalService.retrieve(
      query: query,
      sessionId: sessionId,
      globalOnly: globalOnly,
    );
    
    return result.nodes.take(maxResults).toList();
  }

  /// 获取指定房间的记忆
  Future<List<MemoryNode>> getRoomMemories(String roomId) async {
    final level = _roomIdToLevel(roomId);
    if (level == null) return [];
    
    return await _retrievalService.retrieveByLevel(level);
  }

  /// 房间 ID 转换为抽象层级
  AbstractionLevel? _roomIdToLevel(String roomId) {
    switch (roomId) {
      case 'recent':
        return AbstractionLevel.level1Recent;
      case 'facts':
        return AbstractionLevel.level2Facts;
      case 'entities':
        return AbstractionLevel.level3Entities;
      case 'keywords':
        return AbstractionLevel.level4Keywords;
      case 'core':
        return AbstractionLevel.level5Core;
      default:
        return null;
    }
  }

  /// 执行定期压缩任务
  Future<CompressTaskResult> runPeriodicCompress() async {
    final now = DateTime.now();
    
    // 检查是否需要压缩
    if (_lastCompressTime != null) {
      final hoursSinceLastCompress = now.difference(_lastCompressTime!).inHours;
      if (hoursSinceLastCompress < config.compressIntervalHours) {
        debugPrint('[MemoryPalace] 距离上次压缩不足 ${config.compressIntervalHours} 小时，跳过');
        return CompressTaskResult(
          memoryId: '',
          success: true,
          oldLevel: AbstractionLevel.level1Recent,
          newLevel: AbstractionLevel.level1Recent,
        );
      }
    }
    
    // 执行压缩
    debugPrint('[MemoryPalace] 开始定期压缩任务');
    await _compressEngine.scanAndCompress();
    
    // 归档低重要性记忆
    final archived = await _compressEngine.archiveLowImportanceMemories();
    debugPrint('[MemoryPalace] 归档了 $archived 条低重要性记忆');
    
    _lastCompressTime = now;
    
    return CompressTaskResult(
      memoryId: 'periodic_compress',
      success: true,
      oldLevel: AbstractionLevel.level1Recent,
      newLevel: AbstractionLevel.level1Recent,
    );
  }

  /// 跨会话记忆融合
  Future<int> fuseCrossSessionMemories() async {
    if (!config.enableCrossSessionFusion) return 0;
    
    debugPrint('[MemoryPalace] 开始跨会话记忆融合');
    
    // 获取所有全局记忆
    final allMemories = await _db.getAllMemories();
    final globalMemories = allMemories.where((m) => m.isGlobal && !m.isArchived).toList();
    
    if (globalMemories.length < 2) {
      debugPrint('[MemoryPalace] 全局记忆不足，跳过融合');
      return 0;
    }
    
    // 查找相似记忆并融合
    int fusedCount = 0;
    final processed = <String>{};
    
    for (final memory in globalMemories) {
      if (processed.contains(memory.id)) continue;
      
      // 查找相似记忆
      final similar = await _findSimilarMemories(memory, globalMemories);
      
      if (similar.isNotEmpty) {
        // 融合相似记忆
        await _fuseMemories(memory, similar);
        processed.add(memory.id);
        for (final s in similar) {
          processed.add(s.id);
        }
        fusedCount += similar.length;
      }
    }
    
    debugPrint('[MemoryPalace] 融合完成，共处理 $fusedCount 条记忆');
    return fusedCount;
  }

  /// 查找相似记忆
  Future<List<dynamic>> _findSimilarMemories(dynamic target, List<dynamic> candidates) async {
    final similar = <dynamic>[];
    final targetKeywords = _extractSimpleKeywords(target.content);
    
    for (final candidate in candidates) {
      if (candidate.id == target.id) continue;
      
      final candidateKeywords = _extractSimpleKeywords(candidate.content);
      
      // 计算关键词重叠
      final overlap = targetKeywords
          .where((k) => candidateKeywords.contains(k))
          .length;
      
      if (overlap >= 2) {
        similar.add(candidate);
      }
    }
    
    return similar.take(5).toList();
  }

  /// 简单关键词提取
  List<String> _extractSimpleKeywords(String content) {
    final cnRegex = RegExp(r'[\u4e00-\u9fa5]{2,}');
    final cnMatches = cnRegex.allMatches(content);
    final cnCounts = <String, int>{};
    for (final match in cnMatches) {
      final word = match.group(0)!;
      cnCounts[word] = (cnCounts[word] ?? 0) + 1;
    }
    
    return cnCounts.entries
        .where((e) => e.value >= 2)
        .take(10)
        .map((e) => e.key)
        .toList();
  }

  /// 融合记忆
  Future<void> _fuseMemories(dynamic primary, List<dynamic> secondary) async {
    // 合并内容
    final combinedContent = StringBuffer();
    combinedContent.writeln(primary.content);
    combinedContent.writeln('\n--- 融合内容 ---\n');
    
    for (final s in secondary) {
      combinedContent.writeln(s.content);
      combinedContent.writeln('\n---\n');
    }
    
    // 更新主记忆
    await _db.updateMemory(MemoriesCompanion(
      id: Value(primary.id),
      content: Value(combinedContent.toString()),
      weight: Value((primary.weight + 0.1).clamp(0.0, 1.0)),
      updatedAt: Value(DateTime.now()),
    ));
    
    // 标记次要记忆为归档
    for (final s in secondary) {
      await _db.updateMemory(MemoriesCompanion(
        id: Value(s.id),
        isArchived: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  /// 获取宫殿统计
  Future<MemoryPalaceStats> getStats() async {
    final retrievalStats = await _retrievalService.getStats();
    await _compressEngine.getStats();  // 触发统计更新
    
    return MemoryPalaceStats(
      totalMemories: retrievalStats.totalCount,
      activeMemories: retrievalStats.activeCount,
      archivedMemories: retrievalStats.archivedCount,
      levelDistribution: retrievalStats.levelCounts,
      roomCounts: await _getRoomCounts(retrievalStats),
      lastCompressTime: _lastCompressTime,
    );
  }

  /// 获取房间记忆数量
  Future<Map<String, int>> _getRoomCounts(MemoryRetrievalStats stats) async {
    final counts = <String, int>{};
    
    for (final entry in stats.levelCounts.entries) {
      final roomId = _levelToRoomId(entry.key);
      counts[roomId] = entry.value;
    }
    
    // 全局记忆单独统计
    final allMemories = await _db.getAllMemories();
    counts['global'] = allMemories.where((m) => m.isGlobal && !m.isArchived).length;
    
    return counts;
  }

  /// 抽象层级转换为房间 ID
  String _levelToRoomId(AbstractionLevel level) {
    switch (level) {
      case AbstractionLevel.level1Recent:
        return 'recent';
      case AbstractionLevel.level2Facts:
        return 'facts';
      case AbstractionLevel.level3Entities:
        return 'entities';
      case AbstractionLevel.level4Keywords:
        return 'keywords';
      case AbstractionLevel.level5Core:
        return 'core';
    }
  }

  /// 生成记忆上下文（用于对话）
  Future<String> generateMemoryContext({
    required String query,
    String? sessionId,
    int maxLength = 2000,
  }) async {
    final memories = await searchMemories(
      query: query,
      sessionId: sessionId,
      maxResults: 5,
    );
    
    if (memories.isEmpty) {
      return '';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('## 相关记忆');
    
    for (final memory in memories) {
      buffer.writeln('\n### ${memory.abstractionLevel.label}');
      buffer.writeln(memory.content);
    }
    
    var result = buffer.toString();
    if (result.length > maxLength) {
      result = '${result.substring(0, maxLength)}\n\n[...更多记忆...]';
    }
    
    return result;
  }

  /// 清理过期数据
  Future<int> cleanup() async {
    debugPrint('[MemoryPalace] 开始清理任务');
    
    // 清理归档记忆
    final deleted = await _compressEngine.cleanupArchivedMemories();
    
    // 清理超过最大数量的旧记忆
    final allMemories = await _db.getAllMemories();
    final activeMemories = allMemories.where((m) => !m.isArchived).toList();
    
    int extraDeleted = 0;
    if (activeMemories.length > config.maxActiveMemories) {
      // 按重要性排序，删除最低的
      activeMemories.sort((a, b) => a.weight.compareTo(b.weight));
      
      final toDelete = activeMemories.take(
        activeMemories.length - config.maxActiveMemories,
      );
      
      for (final memory in toDelete) {
        try {
          await _db.updateMemory(MemoriesCompanion(
            id: Value(memory.id),
            isArchived: const Value(true),
            updatedAt: Value(DateTime.now()),
          ));
          extraDeleted++;
        } catch (e) {
          debugPrint('[MemoryPalace] 清理失败: ${memory.id}');
        }
      }
    }
    
    debugPrint('[MemoryPalace] 清理完成，删除 $deleted 条归档记忆，$extraDeleted 条超额记忆');
    return deleted + extraDeleted;
  }

  /// 清理所有"共享/全局"记忆
  ///
  /// 【修复 V72】随会话隔离策略，旧的 isGlobal=true 记忆属于脏数据。
  ///   调用此方法可一次性删除所有全局记忆，不影响会话级记忆。
  ///
  /// 返回被删除的记忆数量。
  Future<int> clearGlobalMemories() async {
    final deleted = await _db.deleteAllGlobalMemories();
    debugPrint('[MemoryPalace] 已清理 $deleted 条共享/全局记忆');
    return deleted;
  }
}

/// 记忆宫殿统计
class MemoryPalaceStats {
  final int totalMemories;
  final int activeMemories;
  final int archivedMemories;
  final Map<AbstractionLevel, int> levelDistribution;
  final Map<String, int> roomCounts;
  final DateTime? lastCompressTime;

  MemoryPalaceStats({
    required this.totalMemories,
    required this.activeMemories,
    required this.archivedMemories,
    required this.levelDistribution,
    required this.roomCounts,
    this.lastCompressTime,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('记忆宫殿统计:');
    buffer.writeln('- 总计: $totalMemories');
    buffer.writeln('- 活跃: $activeMemories');
    buffer.writeln('- 已归档: $archivedMemories');
    buffer.writeln('- 房间分布:');
    for (final entry in roomCounts.entries) {
      buffer.writeln('  • $entry.key: ${entry.value}');
    }
    if (lastCompressTime != null) {
      buffer.writeln('- 最后压缩: $lastCompressTime');
    }
    return buffer.toString();
  }
}