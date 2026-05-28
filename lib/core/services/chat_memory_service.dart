/// 聊天记忆服务 - LLM Studio 无限上下文核心模块
///
/// 功能：
/// - 三层上下文结构（System Prompt + Summary + Active Messages）
/// - LLM 智能摘要压缩
/// - Token 数量估算与自动压缩触发
/// - 压缩记忆持久化
///
/// @author Jianma
/// @version 2.0.0
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../storage/database.dart';
import '../storage/database_connection.dart';

/// 聊天记忆（三层结构）
///
/// - systemPrompt: 核心指令，永不压缩
/// - currentSummary: 压缩归档，随每次触发压缩而更新
/// - activeMessages: 活跃消息池，保持即时语境
class ChatMemory {
  /// 会话 ID
  final String sessionId;

  /// 系统提示词（永不压缩）
  final String systemPrompt;

  /// 当前总结（压缩归档）
  final String currentSummary;

  /// 活跃消息池
  final List<ChatMemoryMessage> activeMessages;

  /// 最大上下文 Token 数
  final int maxContextTokens;

  /// 压缩触发阈值比例（默认 90%）
  final double compressionThreshold;

  /// 摘要保留比例（保留最近 30% 原始消息）
  final double keepRatio;

  const ChatMemory({
    required this.sessionId,
    this.systemPrompt = '',
    this.currentSummary = '',
    this.activeMessages = const [],
    this.maxContextTokens = 32768,
    this.compressionThreshold = 0.90,
    this.keepRatio = 0.30,
  });

  /// 估算当前活跃消息的 Token 数
  int get estimatedActiveTokens {
    return activeMessages.fold<int>(
      0,
      (sum, msg) => sum + ChatMemoryService.estimateTokens(msg.content),
    );
  }

  /// 估算总结的 Token 数
  int get estimatedSummaryTokens {
    return ChatMemoryService.estimateTokens(currentSummary);
  }

  /// 估算系统提示词的 Token 数
  int get estimatedSystemPromptTokens {
    return ChatMemoryService.estimateTokens(systemPrompt);
  }

  /// 估算总 Token 数
  int get totalEstimatedTokens {
    return estimatedSystemPromptTokens + estimatedSummaryTokens + estimatedActiveTokens;
  }

  /// 当前使用率
  double get usageRatio {
    return totalEstimatedTokens / maxContextTokens;
  }

  /// 是否需要压缩
  bool get needsCompression {
    return usageRatio > compressionThreshold;
  }

  /// 获取格式化后的上下文使用情况
  String get usageInfo {
    return '${(usageRatio * 100).toStringAsFixed(1)}% '
        '($totalEstimatedTokens/$maxContextTokens tokens)';
  }

  ChatMemory copyWith({
    String? sessionId,
    String? systemPrompt,
    String? currentSummary,
    List<ChatMemoryMessage>? activeMessages,
    int? maxContextTokens,
    double? compressionThreshold,
    double? keepRatio,
  }) {
    return ChatMemory(
      sessionId: sessionId ?? this.sessionId,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      currentSummary: currentSummary ?? this.currentSummary,
      activeMessages: activeMessages ?? this.activeMessages,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
      compressionThreshold: compressionThreshold ?? this.compressionThreshold,
      keepRatio: keepRatio ?? this.keepRatio,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'systemPrompt': systemPrompt,
    'currentSummary': currentSummary,
    'activeMessages': activeMessages.map((m) => m.toJson()).toList(),
    'maxContextTokens': maxContextTokens,
    'compressionThreshold': compressionThreshold,
    'keepRatio': keepRatio,
  };

  factory ChatMemory.fromJson(Map<String, dynamic> json) {
    return ChatMemory(
      sessionId: json['sessionId'] as String,
      systemPrompt: json['systemPrompt'] as String? ?? '',
      currentSummary: json['currentSummary'] as String? ?? '',
      activeMessages: (json['activeMessages'] as List<dynamic>?)
          ?.map((m) => ChatMemoryMessage.fromJson(m as Map<String, dynamic>))
          .toList() ?? [],
      maxContextTokens: json['maxContextTokens'] as int? ?? 32768,
      compressionThreshold: (json['compressionThreshold'] as num?)?.toDouble() ?? 0.90,
      keepRatio: (json['keepRatio'] as num?)?.toDouble() ?? 0.30,
    );
  }
}

/// 聊天记忆中的单条消息
class ChatMemoryMessage {
  final String id;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final DateTime timestamp;
  final bool isImportant;
  final List<String>? imageUrls;

  const ChatMemoryMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isImportant = false,
    this.imageUrls,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'isImportant': isImportant,
    'imageUrls': imageUrls,
  };

  factory ChatMemoryMessage.fromJson(Map<String, dynamic> json) {
    return ChatMemoryMessage(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isImportant: json['isImportant'] as bool? ?? false,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

/// LLM 摘要回调类型
typedef LlmSummaryCallback = Future<String> Function({
  required String existingSummary,
  required List<Map<String, String>> messagesToCompress,
  required String systemPrompt,
});

/// 聊天记忆服务
class ChatMemoryService {
  final AppDatabase _db = database;

  /// LLM 摘要回调
  LlmSummaryCallback? _llmSummaryCallback;

  /// 会话记忆缓存（内存）
  final Map<String, ChatMemory> _memoryCache = {};

  /// 压缩统计
  int _totalCompressions = 0;
  int _totalCompressedMessages = 0;

  ChatMemoryService();

  /// 设置 LLM 摘要回调
  void setLlmSummaryCallback(LlmSummaryCallback callback) {
    _llmSummaryCallback = callback;
  }

  /// ★★★ Token 估算 ★★★
  ///
  /// 使用简单的字符估算方法：
  /// - 中文字符 ≈ 1.5 token
  /// - 英文字符 ≈ 4 字符/token
  /// - 数字/标点 ≈ 2 字符/token
  static int estimateTokens(String text) {
    if (text.isEmpty) return 0;

    // 中文字符
    final chineseChars = RegExp(r'[\u4e00-\u9fff]').allMatches(text).length;
    // 英文字母
    final englishChars = RegExp(r'[a-zA-Z]').allMatches(text).length;
    // 数字和标点
    final otherChars = text.length - chineseChars - englishChars;

    // 估算公式
    return ((chineseChars * 1.5) + (englishChars / 4.0) + (otherChars / 2.0)).round();
  }

  /// ★★★ 获取会话记忆 ★★★
  ///
  /// 如果缓存中没有，从数据库加载
  Future<ChatMemory> getMemory(String sessionId) async {
    // 先检查缓存
    if (_memoryCache.containsKey(sessionId)) {
      return _memoryCache[sessionId]!;
    }

    // 从数据库加载
    final memory = await _loadFromDatabase(sessionId);
    _memoryCache[sessionId] = memory;
    return memory;
  }

  /// ★★★ 保存会话记忆 ★★★
  Future<void> saveMemory(ChatMemory memory) async {
    // 更新缓存
    _memoryCache[memory.sessionId] = memory;

    // 持久化到数据库
    await _saveToDatabase(memory);
  }

  /// ★★★ 更新系统提示词 ★★★
  Future<void> updateSystemPrompt(String sessionId, String systemPrompt) async {
    final memory = await getMemory(sessionId);
    final updated = memory.copyWith(systemPrompt: systemPrompt);
    await saveMemory(updated);
  }

  /// ★★★ 添加活跃消息 ★★★
  Future<void> addMessage(String sessionId, String role, String content) async {
    final memory = await getMemory(sessionId);
    final newMessage = ChatMemoryMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );
    final updatedMessages = [...memory.activeMessages, newMessage];
    final updated = memory.copyWith(activeMessages: updatedMessages);
    await saveMemory(updated);
  }

  /// ★★★ 检查并执行压缩 ★★★
  ///
  /// 返回是否执行了压缩
  Future<bool> checkAndCompress(String sessionId) async {
    final memory = await getMemory(sessionId);

    // 如果不需要压缩，直接返回
    if (!memory.needsCompression) {
      return false;
    }

    // 执行压缩
    await compress(sessionId);
    return true;
  }

  /// ★★★ 执行上下文压缩 ★★★
  ///
  /// 核心压缩逻辑：
  /// 1. 提取需要压缩的旧消息（最旧的 70%）
  /// 2. 调用 LLM 生成新总结
  /// 3. 保留最近的 30% 原始消息
  /// 4. 更新记忆
  Future<void> compress(String sessionId) async {
    final memory = await getMemory(sessionId);

    if (memory.activeMessages.isEmpty) {
      debugPrint('[ChatMemoryService] 无活跃消息，跳过压缩');
      return;
    }

    // 计算保留点（保留最近 30%）
    final keepCount = (memory.activeMessages.length * memory.keepRatio).ceil();
    final keepStartIndex = memory.activeMessages.length - keepCount;

    // 分离保留消息和压缩消息
    final keepMessages = memory.activeMessages.sublist(keepStartIndex);
    final compressMessages = memory.activeMessages.sublist(0, keepStartIndex);

    if (compressMessages.isEmpty) {
      debugPrint('[ChatMemoryService] 无需压缩的消息，跳过');
      return;
    }

    // 构建待压缩消息的 Map 列表
    final messagesToCompress = compressMessages.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();

    // 生成新总结
    String newSummary;
    if (_llmSummaryCallback != null) {
      // 使用 LLM 生成智能摘要
      try {
        newSummary = await _llmSummaryCallback!(
          existingSummary: memory.currentSummary,
          messagesToCompress: messagesToCompress,
          systemPrompt: memory.systemPrompt,
        );
        debugPrint('[ChatMemoryService] ✅ LLM 摘要生成成功，长度: ${newSummary.length}');
      } catch (e) {
        debugPrint('[ChatMemoryService] ❌ LLM 摘要生成失败: $e，使用规则摘要');
        newSummary = _generateRuleBasedSummary(messagesToCompress, memory.currentSummary);
      }
    } else {
      // 使用规则摘要
      newSummary = _generateRuleBasedSummary(messagesToCompress, memory.currentSummary);
      debugPrint('[ChatMemoryService] ⚠️ 未配置 LLM 回调，使用规则摘要');
    }

    // 更新记忆
    final mergedSummary = _mergeSummary(memory.currentSummary, newSummary);
    final updated = memory.copyWith(
      currentSummary: mergedSummary,
      activeMessages: keepMessages,
    );

    await saveMemory(updated);

    // 更新统计
    _totalCompressions++;
    _totalCompressedMessages += compressMessages.length;

    debugPrint('[ChatMemoryService] ✅ 压缩完成: '
        '${compressMessages.length} 条消息 → 摘要, '
        '保留 ${keepMessages.length} 条活跃消息');
  }

  /// ★★★ 生成结构化消息用于推理 ★★★
  ///
  /// 返回的消息数组结构：
  /// - system: System Prompt + 总结
  /// - history: 活跃消息池
  List<Map<String, dynamic>> buildMessagesForInference(ChatMemory memory) {
    final messages = <Map<String, dynamic>>[];

    // 构建 system prompt（包含总结）
    String systemContent = memory.systemPrompt;
    if (memory.currentSummary.isNotEmpty) {
      systemContent += '\n\n[对话历史摘要]\n${memory.currentSummary}';
    }
    messages.add({'role': 'system', 'content': systemContent});

    // 添加活跃消息
    // 注意：包含图片的多模态消息不计入上下文（回答完后即丢弃）
    for (final msg in memory.activeMessages) {
      // 如果消息包含图片，标记为多模态，不加入推理上下文
      if (msg.imageUrls != null && msg.imageUrls!.isNotEmpty) {
        debugPrint('[ChatMemory] 跳过含图片的消息（多模态不计入上下文）: ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
        continue;
      }
      messages.add({
        'role': msg.role,
        'content': msg.content,
        if (msg.imageUrls != null) 'imageUrls': msg.imageUrls,
      });
    }

    return messages;
  }

  /// ★★★ 合并新旧总结 ★★★
  ///
  /// 如果已有总结，追加新总结；否则直接使用新总结
  String _mergeSummary(String existingSummary, String newSummary) {
    if (existingSummary.isEmpty) {
      return newSummary;
    }

    // 简单合并策略：保留旧总结 + 新总结
    return '$existingSummary\n\n---\n\n$newSummary';
  }

  /// ★★★ 基于规则的摘要生成 ★★★
  String _generateRuleBasedSummary(
    List<Map<String, String>> messages,
    String existingSummary,
  ) {
    final buffer = StringBuffer();

    // 统计信息
    final userMessages = messages.where((m) => m['role'] == 'user').toList();
    final assistantMessages = messages.where((m) => m['role'] == 'assistant').toList();

    buffer.writeln('[对话摘要 - ${userMessages.length} 轮对话]');

    // 提取主题
    if (userMessages.isNotEmpty) {
      buffer.writeln('## 对话主题');
      for (int i = 0; i < userMessages.length && i < 3; i++) {
        final content = userMessages[i]['content'] ?? '';
        final preview = content.length > 80 ? '${content.substring(0, 80)}...' : content;
        buffer.writeln('• $preview');
      }
    }

    // 提取关键信息
    final allContent = messages.map((m) => m['content'] ?? '').join(' ');
    final keyEntities = _extractKeyEntities(allContent);
    if (keyEntities.isNotEmpty) {
      buffer.writeln('## 关键信息');
      buffer.writeln(keyEntities.join(', '));
    }

    // 统计
    buffer.writeln('## 统计');
    buffer.writeln('用户消息: ${userMessages.length} 条');
    buffer.writeln('助手回复: ${assistantMessages.length} 条');

    return buffer.toString();
  }

  /// ★★★ 提取关键实体 ★★★
  List<String> _extractKeyEntities(String content) {
    final entities = <String>[];

    // 提取中文关键词（2字以上）
    final cnRegex = RegExp(r'[\u4e00-\u9fa5]{2,}');
    final cnMatches = cnRegex.allMatches(content).toSet();
    entities.addAll(cnMatches.map((m) => m.group(0)!));

    // 提取英文关键词
    final enRegex = RegExp(r'(?<=[^\u4e00-\u9fa5])([A-Z][a-z]+[A-Z][a-z]+)(?=[^\u4e00-\u9fa5])');
    final enMatches = enRegex.allMatches(content).toSet();
    entities.addAll(enMatches.map((m) => m.group(1)!));

    // 去重并返回前 5 个
    return entities.toSet().take(5).toList();
  }

  /// ★★★ 从数据库加载 ★★★
  Future<ChatMemory> _loadFromDatabase(String sessionId) async {
    try {
      // 尝试从 session_summary 表加载
      final summaries = await _db.getSessionSummaries();
      final summary = summaries.where((s) => s.sessionId == sessionId).firstOrNull;

      if (summary != null) {
        // 反序列化 activeMessages
        List<ChatMemoryMessage> activeMessages = [];
        if (summary.activeMessagesJson != null && summary.activeMessagesJson!.isNotEmpty) {
          try {
            final jsonList = jsonDecode(summary.activeMessagesJson!) as List<dynamic>;
            activeMessages = jsonList
                .map((m) => ChatMemoryMessage.fromJson(m as Map<String, dynamic>))
                .toList();
          } catch (e) {
            debugPrint('[ChatMemoryService] 解析活跃消息失败: $e');
          }
        }

        return ChatMemory(
          sessionId: sessionId,
          systemPrompt: summary.systemPrompt ?? '',
          currentSummary: summary.summary,
          activeMessages: activeMessages,
          maxContextTokens: summary.maxContextTokens,
        );
      }
    } catch (e) {
      debugPrint('[ChatMemoryService] 从数据库加载失败: $e');
    }

    // 返回空记忆
    return ChatMemory(sessionId: sessionId);
  }

  /// ★★★ 保存到数据库 ★★★
  Future<void> _saveToDatabase(ChatMemory memory) async {
    try {
      // 序列化 activeMessages
      final activeMessagesJson = jsonEncode(
        memory.activeMessages.map((m) => m.toJson()).toList(),
      );

      // 检查是否存在
      final summaries = await _db.getSessionSummaries();
      final existing = summaries.where((s) => s.sessionId == memory.sessionId).firstOrNull;

      if (existing != null) {
        // 更新
        await _db.updateSessionSummary(
          sessionId: memory.sessionId,
          summary: memory.currentSummary,
          systemPrompt: memory.systemPrompt,
          activeMessagesJson: activeMessagesJson,
          maxContextTokens: memory.maxContextTokens,
        );
      } else {
        // 插入
        await _db.insertSessionSummary(
          sessionId: memory.sessionId,
          summary: memory.currentSummary,
          systemPrompt: memory.systemPrompt,
          activeMessagesJson: activeMessagesJson,
          maxContextTokens: memory.maxContextTokens,
        );
      }

      debugPrint('[ChatMemoryService] ✅ 记忆已持久化到数据库');
    } catch (e) {
      debugPrint('[ChatMemoryService] ❌ 保存到数据库失败: $e');
    }
  }

  /// ★★★ 清空会话记忆 ★★★
  Future<void> clearMemory(String sessionId) async {
    _memoryCache.remove(sessionId);
    await _db.deleteSessionSummary(sessionId);
    debugPrint('[ChatMemoryService] ✅ 会话记忆已清空: $sessionId');
  }

  /// 获取压缩统计
  Map<String, int> get compressionStats => {
    'totalCompressions': _totalCompressions,
    'totalCompressedMessages': _totalCompressedMessages,
  };
}
