/// 智能上下文管理器 - 上下文记忆功能重构
/// 
/// 采用主流 LLM 工具的上下文处理方案：
/// - 5层分层架构（系统提示/长期记忆/会话摘要/最近消息/当前上下文）
/// - 重要性加权排序
/// - 异步记忆检索与缓存
/// - 批量数据库操作
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engines/model_inference_engine.dart' show ChatMessage;
import 'context_compressor_service.dart';

/// 上下文层类型
enum ContextLayerType {
  system,         // 系统提示（固定，永不压缩）
  longTermMemory, // 长期记忆（记忆宫殿，重要性加权）
  sessionSummary, // 会话摘要（定期更新）
  recentMessages, // 最近消息（滑动窗口）
  currentContext, // 当前上下文（实时）
}

/// 上下文层
class ContextLayer {
  final ContextLayerType type;
  final List<ChatMessage> messages;
  final int tokenCount;
  final double priority;  // 0.0 - 1.0，越高越重要

  ContextLayer({
    required this.type,
    required this.messages,
    required this.tokenCount,
    required this.priority,
  });
}

/// 智能上下文管理器
class SmartContextManager {
  static final SmartContextManager _instance = SmartContextManager._();
  static SmartContextManager get instance => _instance;

  SmartContextManager._();

  /// 记忆检索缓存
  final _memoryCache = <String, _CachedMemory>{};
  static const _cacheTimeout = Duration(minutes: 5);

  /// 会话摘要缓存
  final _summaryCache = <String, String>{};

  /// 获取智能压缩的上下文
  Future<List<ChatMessage>> getOptimizedContext({
    required String sessionId,
    required List<ChatMessage> allMessages,
    required int tokenBudget,
    required String? systemPrompt,
    String? currentQuery,
  }) async {
    debugPrint('[SmartContextManager] 开始优化上下文: 预算=$tokenBudget tokens');
    
    final stopwatch = Stopwatch()..start();
    
    // 1. 分层组织消息
    final layers = _organizeIntoLayers(
      allMessages: allMessages,
      systemPrompt: systemPrompt,
      tokenBudget: tokenBudget,
    );
    
    // 2. 计算各层 token 使用
    int usedTokens = 0;
    final optimizedMessages = <ChatMessage>[];
    
    // 3. 按优先级添加各层
    for (final layer in layers) {
      if (usedTokens + layer.tokenCount <= tokenBudget) {
        optimizedMessages.addAll(layer.messages);
        usedTokens += layer.tokenCount;
        debugPrint('[SmartContextManager] 添加 ${layer.type.name}: '
            '${layer.messages.length}条消息, ${layer.tokenCount}tokens');
      } else {
        // 尝试部分添加
        final remainingBudget = tokenBudget - usedTokens;
        final partialMessages = _partialAdd(layer.messages, remainingBudget);
        optimizedMessages.addAll(partialMessages);
        debugPrint('[SmartContextManager] 部分添加 ${layer.type.name}: '
            '${partialMessages.length}条消息');
        break;
      }
    }
    
    stopwatch.stop();
    debugPrint('[SmartContextManager] 上下文优化完成: '
        '${optimizedMessages.length}条消息, '
        '耗时${stopwatch.elapsedMilliseconds}ms');
    
    return optimizedMessages;
  }

  /// 将消息组织成5层结构
  List<ContextLayer> _organizeIntoLayers({
    required List<ChatMessage> allMessages,
    required String? systemPrompt,
    required int tokenBudget,
  }) {
    final layers = <ContextLayer>[];
    
    // Layer 1: 系统提示（最高优先级）
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      final systemTokens = ContextCompressorService.estimateTokens(systemPrompt);
      layers.add(ContextLayer(
        type: ContextLayerType.system,
        messages: [ChatMessage(role: 'system', content: systemPrompt)],
        tokenCount: systemTokens,
        priority: 1.0,
      ));
    }
    
    // Layer 2: 长期记忆（高优先级）
    // 这里简化处理，实际应该从记忆宫殿检索
    final importantMessages = _extractImportantMessages(allMessages);
    if (importantMessages.isNotEmpty) {
      final memoryTokens = importantMessages.fold<int>(
        0,
        (sum, msg) => sum + ContextCompressorService.estimateTokens(msg.content),
      );
      layers.add(ContextLayer(
        type: ContextLayerType.longTermMemory,
        messages: importantMessages,
        tokenCount: memoryTokens,
        priority: 0.9,
      ));
    }
    
    // Layer 3: 会话摘要（中高优先级）
    final summary = _generateSessionSummary(allMessages);
    if (summary.isNotEmpty) {
      final summaryTokens = ContextCompressorService.estimateTokens(summary);
      layers.add(ContextLayer(
        type: ContextLayerType.sessionSummary,
        messages: [ChatMessage(role: 'system', content: '会话摘要: $summary')],
        tokenCount: summaryTokens,
        priority: 0.7,
      ));
    }
    
    // Layer 4: 最近消息（中优先级，滑动窗口）
    final recentMessages = _getRecentMessages(allMessages, count: 20);
    if (recentMessages.isNotEmpty) {
      final recentTokens = recentMessages.fold<int>(
        0,
        (sum, msg) => sum + ContextCompressorService.estimateTokens(msg.content),
      );
      layers.add(ContextLayer(
        type: ContextLayerType.recentMessages,
        messages: recentMessages,
        tokenCount: recentTokens,
        priority: 0.6,
      ));
    }
    
    // Layer 5: 当前上下文（较低优先级）
    final currentMessages = _getCurrentContext(allMessages);
    if (currentMessages.isNotEmpty) {
      final currentTokens = currentMessages.fold<int>(
        0,
        (sum, msg) => sum + ContextCompressorService.estimateTokens(msg.content),
      );
      layers.add(ContextLayer(
        type: ContextLayerType.currentContext,
        messages: currentMessages,
        tokenCount: currentTokens,
        priority: 0.5,
      ));
    }
    
    // 按优先级排序（高优先级在前）
    layers.sort((a, b) => b.priority.compareTo(a.priority));
    
    return layers;
  }

  /// 提取重要消息
  List<ChatMessage> _extractImportantMessages(List<ChatMessage> messages) {
    return messages.where((msg) {
      // 系统消息
      if (msg.role == 'system') return true;
      // 工具结果
      if (msg.role == 'tool') return true;
      // 标记为重要的消息
      // if (msg.isImportant) return true;
      return false;
    }).toList();
  }

  /// 生成会话摘要
  String _generateSessionSummary(List<ChatMessage> messages) {
    if (messages.length < 10) return '';
    
    // 简单摘要：提取关键信息
    final userMessages = messages.where((m) => m.role == 'user').toList();
    final assistantMessages = messages.where((m) => m.role == 'assistant').toList();
    
    if (userMessages.isEmpty) return '';
    
    // 提取用户主要话题
    final topics = <String>[];
    for (var i = 0; i < userMessages.length && i < 5; i++) {
      final content = userMessages[i].content;
      if (content.length > 50) {
        topics.add(content.substring(0, 50));
      } else {
        topics.add(content);
      }
    }
    
    return '用户主要话题: ${topics.join(", ")}';
  }

  /// 获取最近消息（滑动窗口）
  List<ChatMessage> _getRecentMessages(List<ChatMessage> messages, {int count = 20}) {
    if (messages.length <= count) {
      return List.from(messages);
    }
    return messages.sublist(messages.length - count);
  }

  /// 获取当前上下文（最近的对话轮次）
  List<ChatMessage> _getCurrentContext(List<ChatMessage> messages) {
    // 获取最后一轮对话（用户问题 + AI回答）
    if (messages.isEmpty) return [];
    
    final lastMessages = <ChatMessage>[];
    for (var i = messages.length - 1; i >= 0 && lastMessages.length < 4; i--) {
      lastMessages.insert(0, messages[i]);
      // 如果遇到用户消息且已经有AI回答，停止
      if (messages[i].role == 'user' && lastMessages.length > 1) {
        break;
      }
    }
    
    return lastMessages;
  }

  /// 部分添加消息（在预算内尽可能添加）
  List<ChatMessage> _partialAdd(List<ChatMessage> messages, int tokenBudget) {
    final result = <ChatMessage>[];
    int usedTokens = 0;
    
    for (final msg in messages) {
      final msgTokens = ContextCompressorService.estimateTokens(msg.content);
      if (usedTokens + msgTokens <= tokenBudget) {
        result.add(msg);
        usedTokens += msgTokens;
      } else {
        break;
      }
    }
    
    return result;
  }

  /// 异步检索记忆（带缓存）
  Future<List<ChatMessage>> retrieveMemory({
    required String query,
    required String sessionId,
  }) async {
    // 检查缓存
    final cached = _memoryCache[sessionId];
    if (cached != null && !cached.isExpired) {
      return cached.messages;
    }
    
    // 并行检索
    final results = await Future.wait([
      _searchByKeywords(query),
      _searchByRecency(sessionId),
    ]);
    
    // 合并结果
    final merged = <ChatMessage>[];
    for (final result in results) {
      merged.addAll(result);
    }
    
    // 缓存结果
    _memoryCache[sessionId] = _CachedMemory(
      messages: merged,
      timestamp: DateTime.now(),
    );
    
    return merged;
  }

  /// 按关键词搜索
  Future<List<ChatMessage>> _searchByKeywords(String query) async {
    // 简化实现，实际应该使用向量搜索
    return [];
  }

  /// 按时间近度搜索
  Future<List<ChatMessage>> _searchByRecency(String sessionId) async {
    // 简化实现，实际应该查询数据库
    return [];
  }

  /// 清除缓存
  void clearCache({String? sessionId}) {
    if (sessionId != null) {
      _memoryCache.remove(sessionId);
      _summaryCache.remove(sessionId);
    } else {
      _memoryCache.clear();
      _summaryCache.clear();
    }
  }
}

/// 缓存的记忆
class _CachedMemory {
  final List<ChatMessage> messages;
  final DateTime timestamp;

  _CachedMemory({required this.messages, required this.timestamp});

  bool get isExpired {
    return DateTime.now().difference(timestamp) > const Duration(minutes: 5);
  }
}

/// Riverpod Provider
final smartContextManagerProvider = Provider<SmartContextManager>((ref) {
  return SmartContextManager.instance;
});
