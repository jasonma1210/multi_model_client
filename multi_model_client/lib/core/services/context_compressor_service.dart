/// 上下文压缩服务 - LLM Studio 会话管理模块
/// 
/// 功能：
/// - 会话上下文压缩（滑动窗口/摘要/混合策略）
/// - LLM 摘要压缩（调用模型生成智能摘要）
/// - 重要信息保留算法（系统提示/首条/高权重消息）
/// - Token 数量控制
/// - 自定义压缩触发条件
/// 
/// @author JianMa
/// @version 2.0.0
library;

import 'dart:math';
import 'package:flutter/foundation.dart';

/// 上下文压缩策略
enum CompressionStrategy {
  /// 滑动窗口 - 只保留最近 N 条消息
  slidingWindow,

  /// 简单摘要 - 提取关键信息（基于规则）
  simpleSummary,

  /// LLM 摘要 - 调用模型生成智能摘要
  llmSummary,

  /// 混合策略 - 摘要 + 最近消息
  hybrid,
}

/// 重要消息类型（用于保留算法）
enum ImportantMessageType {
  system,      // 系统提示
  firstUser,   // 首条用户消息（设定上下文）
  highWeight,  // 高权重消息（用户标记）
  toolResult,  // 工具执行结果
}

/// 重要消息标记
class ImportantMessage {
  final String messageId;
  final ImportantMessageType type;
  final double weight;

  ImportantMessage({
    required this.messageId,
    required this.type,
    this.weight = 1.0,
  });
}

/// 压缩触发条件配置
class CompressionTriggerConfig {
  /// 消息数量阈值
  final int messageCountThreshold;

  /// Token 数量阈值
  final int tokenThreshold;

  /// 压缩比率（超过此比率才触发）
  final double usageRatioThreshold;

  /// 是否启用 LLM 摘要（当消息超过此数量时）
  final int llmSummaryThreshold;

  const CompressionTriggerConfig({
    this.messageCountThreshold = 50,
    this.tokenThreshold = 8000,
    this.usageRatioThreshold = 0.75,
    this.llmSummaryThreshold = 100,
  });
}

/// 压缩后的消息结构
class CompressedMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isSummary;
  final int? originalMessageCount;
  final bool isImportant;
  final ImportantMessageType? importantType;

  CompressedMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isSummary = false,
    this.originalMessageCount,
    this.isImportant = false,
    this.importantType,
  });

  CompressedMessage copyWith({
    String? id,
    String? role,
    String? content,
    DateTime? timestamp,
    bool? isSummary,
    int? originalMessageCount,
    bool? isImportant,
    ImportantMessageType? importantType,
  }) {
    return CompressedMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSummary: isSummary ?? this.isSummary,
      originalMessageCount: originalMessageCount ?? this.originalMessageCount,
      isImportant: isImportant ?? this.isImportant,
      importantType: importantType ?? this.importantType,
    );
  }
}

/// LLM 摘要生成器回调
typedef LlmSummaryCallback = Future<String> Function(List<Map<String, String>> messages);

/// 会话上下文压缩服务
///
/// 自动管理长对话的上下文窗口，防止超出模型的 token 限制
/// 支持多种压缩策略，包括 LLM 智能摘要
class ContextCompressorService {
  // 配置
  final int maxMessages; // 最大保留消息数
  final int maxTokens; // 最大 token 数（估算）
  final CompressionStrategy strategy;
  final double summaryRatio; // 摘要压缩时保留的消息比例
  final CompressionTriggerConfig triggerConfig;
  
  // LLM 摘要回调（可选）
  LlmSummaryCallback? _llmSummaryCallback;

  ContextCompressorService({
    this.maxMessages = 50,
    this.maxTokens = 8000,
    this.strategy = CompressionStrategy.hybrid,
    this.summaryRatio = 0.3,
    CompressionTriggerConfig? triggerConfig,
    LlmSummaryCallback? llmSummaryCallback,
  })  : triggerConfig = triggerConfig ?? const CompressionTriggerConfig(),
        _llmSummaryCallback = llmSummaryCallback;

  /// 设置 LLM 摘要生成回调
  void setLlmSummaryCallback(LlmSummaryCallback callback) {
    _llmSummaryCallback = callback;
  }

  /// ★★★ 动态更新上下文大小阈值 ★★★
  ///
  /// 当模型加载后，动态更新压缩触发阈值。
  /// [maxContextSize] 为模型的最大上下文 token 数。
  /// 触发阈值设为 90%：即上下文使用超过 90% 时触发压缩。
  void updateContextSize(int maxContextSize) {
    _effectiveMaxTokens = (maxContextSize * 0.9).round();
    debugPrint('[ContextCompressor] 上下文阈值更新: maxContextSize=$maxContextSize, '
        'threshold=$_effectiveMaxTokens (90%)');
  }

  /// 当前生效的最大 token 阈值（可能被 updateContextSize 覆盖）
  int get effectiveThreshold => _effectiveMaxTokens;

  int _effectiveMaxTokens = 8000; // 默认值

  /// 检查是否需要压缩（基于触发条件）
  bool needsCompression(List<dynamic> messages) {
    // 检查消息数量
    if (messages.length > triggerConfig.messageCountThreshold) {
      return true;
    }

    // 估算 token 数（使用动态阈值 _effectiveMaxTokens）
    final estimatedTokens = estimateTotalTokens(messages);
    if (estimatedTokens > _effectiveMaxTokens) {
      return true;
    }

    // 检查使用比率（触发阈值 90%）
    final usageRatio = estimatedTokens / _effectiveMaxTokens;
    if (usageRatio > triggerConfig.usageRatioThreshold) {
      return true;
    }

    return false;
  }

  /// 执行上下文压缩
  ///
  /// 返回压缩后的消息列表，保留重要信息同时减少上下文长度
  List<CompressedMessage> compress(List<dynamic> messages) {
    if (messages.isEmpty) return [];

    // 识别重要消息
    final importantMessages = _identifyImportantMessages(messages);
    
    // 过滤掉 tool 角色消息（通常不需要保留在压缩上下文中）
    final filteredMessages = messages
        .where((m) => m.role != 'tool')
        .toList();

    if (filteredMessages.length <= maxMessages) {
      // 不需要压缩，直接转换但标记重要消息
      return _convertToCompressedMessages(filteredMessages, importantMessages);
    }

    // 根据策略进行压缩
    switch (strategy) {
      case CompressionStrategy.slidingWindow:
        return _slidingWindowCompress(filteredMessages, importantMessages);
      case CompressionStrategy.simpleSummary:
        return _simpleSummaryCompress(filteredMessages, importantMessages);
      case CompressionStrategy.llmSummary:
        return _llmSummaryCompress(filteredMessages, importantMessages);
      case CompressionStrategy.hybrid:
        return _hybridCompress(filteredMessages, importantMessages);
    }
  }

  /// 识别重要消息
  List<ImportantMessage> _identifyImportantMessages(List<dynamic> messages) {
    final important = <ImportantMessage>[];

    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      
      // 系统提示始终重要
      if (msg.role == 'system') {
        important.add(ImportantMessage(
          messageId: msg.id ?? 'system_$i',
          type: ImportantMessageType.system,
          weight: 1.0,
        ));
      }
      
      // 首条用户消息重要
      if (msg.role == 'user' && i == messages.indexWhere((m) => m.role == 'user')) {
        important.add(ImportantMessage(
          messageId: msg.id ?? 'first_user_$i',
          type: ImportantMessageType.firstUser,
          weight: 0.9,
        ));
      }

      // 检查高权重标记（如果有）—— 防御性访问，兼容 drift Message 等无此字段的类型
      bool isImportant = false;
      double? weight;
      try {
        isImportant = (msg as dynamic).isImportant == true;
        weight = (msg as dynamic).weight as double?;
      } catch (_) {
        // Message 类型没有 isImportant / weight 字段，使用默认值
      }
      if (isImportant || weight != null && weight > 0.8) {
        important.add(ImportantMessage(
          messageId: msg.id ?? 'high_weight_$i',
          type: ImportantMessageType.highWeight,
          weight: weight ?? 0.8,
        ));
      }
    }

    return important;
  }

  /// 转换为压缩消息并标记重要消息
  List<CompressedMessage> _convertToCompressedMessages(
    List<dynamic> messages,
    List<ImportantMessage> importantMessages,
  ) {
    final importantIds = importantMessages.map((i) => i.messageId).toSet();
    final importantMap = {for (var i in importantMessages) i.messageId: i};

    return messages.map((m) {
      final id = m.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final important = importantMap[id];
      
      return CompressedMessage(
        id: id,
        role: m.role,
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: importantIds.contains(id),
        importantType: important?.type,
      );
    }).toList();
  }

  /// 滑动窗口压缩 - 保留最近 N 条消息
  List<CompressedMessage> _slidingWindowCompress(
    List<dynamic> messages,
    List<ImportantMessage> importantMessages,
  ) {
    // 优先保留重要消息
    final result = <CompressedMessage>[];
    final importantIds = importantMessages.map((i) => i.messageId).toSet();
    final importantMap = {for (var i in importantMessages) i.messageId: i};

    // 添加重要消息（无论是否在窗口内）
    for (final msg in messages) {
      final id = msg.id ?? '';
      if (importantIds.contains(id)) {
        final important = importantMap[id];
        result.add(CompressedMessage(
          id: id,
          role: msg.role,
          content: msg.content ?? '',
          timestamp: msg.createdAt ?? DateTime.now(),
          isImportant: true,
          importantType: important?.type,
        ));
      }
    }

    // 添加最近的消息
    final recentMessages = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;

    for (final msg in recentMessages) {
      final id = msg.id ?? '';
      if (!importantIds.contains(id)) {
        final important = importantMap[id];
        result.add(CompressedMessage(
          id: id,
          role: msg.role,
          content: msg.content ?? '',
          timestamp: msg.createdAt ?? DateTime.now(),
          isImportant: importantIds.contains(id),
          importantType: important?.type,
        ));
      }
    }

    // 按时间排序
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return result;
  }

  /// 简单摘要压缩 - 基于规则提取关键信息
  List<CompressedMessage> _simpleSummaryCompress(
    List<dynamic> messages,
    List<ImportantMessage> importantMessages,
  ) {
    final result = <CompressedMessage>[];
    final importantMap = {for (var i in importantMessages) i.messageId: i};

    // 1. 保留系统提示（最重要）
    final systemMessages = messages.where((m) => m.role == 'system').toList();
    for (final m in systemMessages) {
      result.add(CompressedMessage(
        id: m.id ?? '',
        role: 'system',
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: true,
        importantType: ImportantMessageType.system,
      ));
    }

    // 2. 保留首条用户消息（设定上下文）
    final userMessages = messages.where((m) => m.role == 'user').toList();
    if (userMessages.isNotEmpty) {
      final firstUser = userMessages.first;
      result.add(CompressedMessage(
        id: firstUser.id ?? '',
        role: 'user',
        content: '[对话开始] ${firstUser.content ?? ''}',
        timestamp: firstUser.createdAt ?? DateTime.now(),
        isSummary: true,
        isImportant: true,
        importantType: ImportantMessageType.firstUser,
        originalMessageCount: userMessages.length,
      ));
    }

    // 3. 生成中间消息的摘要
    final middleMessages = messages.length > maxMessages * 1.5
        ? messages.sublist(userMessages.isNotEmpty ? 1 : 0, messages.length - maxMessages)
        : <dynamic>[];
    
    if (middleMessages.isNotEmpty) {
      final summary = _generateRuleBasedSummary(middleMessages);
      result.add(CompressedMessage(
        id: 'middle_summary',
        role: 'system',
        content: summary,
        timestamp: DateTime.now(),
        isSummary: true,
        originalMessageCount: middleMessages.length,
      ));
    }

    // 4. 保留最近的消息
    final keepCount = (maxMessages * summaryRatio).round();
    final startIndex = max(0, messages.length - keepCount);
    final recentMessages = messages.sublist(startIndex);

    if (startIndex > 0) {
      result.add(CompressedMessage(
        id: 'window_separator',
        role: 'system',
        content: '[... 省略早期对话，共 $startIndex 条消息 ...]',
        timestamp: DateTime.now(),
        isSummary: true,
      ));
    }

    for (final m in recentMessages) {
      final important = importantMap[m.id ?? ''];
      result.add(CompressedMessage(
        id: m.id ?? '',
        role: m.role,
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: important != null,
        importantType: important?.type,
      ));
    }

    return result;
  }

  /// LLM 摘要压缩 - 调用模型生成智能摘要
  Future<List<CompressedMessage>> compressWithLlmSummary(
    List<dynamic> messages,
  ) async {
    final result = <CompressedMessage>[];
    final importantMessages = _identifyImportantMessages(messages);
    final importantMap = {for (var i in importantMessages) i.messageId: i};

    // 1. 保留系统提示
    final systemMessages = messages.where((m) => m.role == 'system').toList();
    for (final m in systemMessages) {
      result.add(CompressedMessage(
        id: m.id ?? '',
        role: 'system',
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: true,
        importantType: ImportantMessageType.system,
      ));
    }

    // 2. 保留首条用户消息
    final userMessages = messages.where((m) => m.role == 'user').toList();
    if (userMessages.isNotEmpty) {
      result.add(CompressedMessage(
        id: userMessages.first.id ?? '',
        role: 'user',
        content: '[对话开始] ${userMessages.first.content ?? ''}',
        timestamp: userMessages.first.createdAt ?? DateTime.now(),
        isImportant: true,
        importantType: ImportantMessageType.firstUser,
      ));
    }

    // 3. 调用 LLM 生成摘要
    if (_llmSummaryCallback != null && messages.length > triggerConfig.llmSummaryThreshold) {
      try {
        // 准备要摘要的消息
        final messagesToSummarize = messages.length > maxMessages * 2
            ? messages.sublist(1, messages.length - maxMessages)
            : messages.sublist(1, messages.length);
        
        final messageMaps = messagesToSummarize.map((m) => <String, String>{
          'role': m.role,
          'content': m.content ?? '',
        }).toList();

        // 调用 LLM 生成摘要
        final llmSummary = await _llmSummaryCallback!(messageMaps);
        
        result.add(CompressedMessage(
          id: 'llm_summary_${DateTime.now().millisecondsSinceEpoch}',
          role: 'system',
          content: '[LLM 智能摘要]\n$llmSummary',
          timestamp: DateTime.now(),
          isSummary: true,
          originalMessageCount: messagesToSummarize.length,
        ));
      } catch (e) {
        debugPrint('[ContextCompressor] LLM 摘要生成失败: $e');
        // 回退到简单摘要
        final fallbackSummary = _generateRuleBasedSummary(
          messages.sublist(1, min(messages.length, maxMessages * 2)),
        );
        result.add(CompressedMessage(
          id: 'fallback_summary',
          role: 'system',
          content: fallbackSummary,
          timestamp: DateTime.now(),
          isSummary: true,
        ));
      }
    } else {
      // 没有 LLM 回调，使用简单摘要
      final middleMessages = messages.length > maxMessages
          ? messages.sublist(1, messages.length - maxMessages)
          : <dynamic>[];
      
      if (middleMessages.isNotEmpty) {
        final summary = _generateRuleBasedSummary(middleMessages);
        result.add(CompressedMessage(
          id: 'rule_summary',
          role: 'system',
          content: summary,
          timestamp: DateTime.now(),
          isSummary: true,
          originalMessageCount: middleMessages.length,
        ));
      }
    }

    // 4. 保留最近的消息
    final keepCount = maxMessages;
    final startIndex = max(0, messages.length - keepCount);
    
    if (startIndex > 0) {
      result.add(CompressedMessage(
        id: 'window_separator',
        role: 'system',
        content: '[... 省略早期对话 ...]',
        timestamp: DateTime.now(),
        isSummary: true,
      ));
    }

    final recentMessages = messages.sublist(startIndex);
    for (final m in recentMessages) {
      final important = importantMap[m.id ?? ''];
      result.add(CompressedMessage(
        id: m.id ?? '',
        role: m.role,
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: important != null,
        importantType: important?.type,
      ));
    }

    return result;
  }

  /// LLM 摘要压缩（同步包装）
  List<CompressedMessage> _llmSummaryCompress(
    List<dynamic> messages,
    List<ImportantMessage> importantMessages,
  ) {
    // 同步调用会返回简单摘要，异步版本由 compressWithLlmSummary 提供
    if (_llmSummaryCallback != null && messages.length > triggerConfig.llmSummaryThreshold) {
      // 返回一个标记，让调用方知道需要异步处理
      final result = _simpleSummaryCompress(messages, importantMessages);
      result.insert(0, CompressedMessage(
        id: 'llm_pending',
        role: 'system',
        content: '[提示：可调用 LLM 摘要提升压缩质量]',
        timestamp: DateTime.now(),
        isSummary: true,
      ));
      return result;
    }
    return _simpleSummaryCompress(messages, importantMessages);
  }

  /// 混合压缩策略 - 保留重要消息 + 摘要 + 最近消息
  List<CompressedMessage> _hybridCompress(
    List<dynamic> messages,
    List<ImportantMessage> importantMessages,
  ) {
    final result = <CompressedMessage>[];
    final importantMap = {for (var i in importantMessages) i.messageId: i};

    // 1. 保留系统提示词（最重要）
    final systemMessages = messages.where((m) => m.role == 'system').toList();
    for (final m in systemMessages) {
      result.add(CompressedMessage(
        id: m.id ?? '',
        role: 'system',
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: true,
        importantType: ImportantMessageType.system,
      ));
    }

    // 2. 保留首条用户消息
    final userMessages = messages.where((m) => m.role == 'user').toList();
    if (userMessages.isNotEmpty) {
      result.add(CompressedMessage(
        id: userMessages.first.id ?? '',
        role: 'user',
        content: '[对话开始] ${userMessages.first.content ?? ''}',
        timestamp: userMessages.first.createdAt ?? DateTime.now(),
        isImportant: true,
        importantType: ImportantMessageType.firstUser,
      ));
    }

    // 3. 根据消息长度选择压缩方式
    if (messages.length > triggerConfig.llmSummaryThreshold && _llmSummaryCallback != null) {
      // 消息非常多，使用简单摘要（异步版本需要单独调用）
      final summary = _generateRuleBasedSummary(
        messages.sublist(1, min(messages.length, maxMessages * 2)),
      );
      result.add(CompressedMessage(
        id: 'hybrid_summary',
        role: 'system',
        content: summary,
        timestamp: DateTime.now(),
        isSummary: true,
        originalMessageCount: messages.length,
      ));
    } else if (messages.length > maxMessages * 1.5) {
      // 中等长度，生成简单摘要
      final summary = _generateRuleBasedSummary(
        messages.sublist(1, min(messages.length, maxMessages * 2)),
      );
      result.add(CompressedMessage(
        id: 'context_summary',
        role: 'system',
        content: summary,
        timestamp: DateTime.now(),
        isSummary: true,
        originalMessageCount: messages.length,
      ));
    }

    // 4. 保留最近的 maxMessages 条消息
    final keepCount = maxMessages;
    final startIndex = max(0, messages.length - keepCount);

    // 添加分隔标记
    if (startIndex > 0) {
      result.add(CompressedMessage(
        id: 'window_separator',
        role: 'system',
        content: '[... 省略早期对话 ...]',
        timestamp: DateTime.now(),
        isSummary: true,
      ));
    }

    final recentMessages = messages.sublist(startIndex);
    for (final m in recentMessages) {
      final important = importantMap[m.id ?? ''];
      result.add(CompressedMessage(
        id: m.id ?? '',
        role: m.role,
        content: m.content ?? '',
        timestamp: m.createdAt ?? DateTime.now(),
        isImportant: important != null,
        importantType: important?.type,
      ));
    }

    return result;
  }

  /// 基于规则的摘要生成
  String _generateRuleBasedSummary(List<dynamic> messages) {
    final userMessages = messages.where((m) => m.role == 'user').toList();
    final assistantMessages = messages.where((m) => m.role == 'assistant').toList();

    final summary = StringBuffer();
    summary.writeln('[对话历史摘要 - 共 ${userMessages.length} 轮对话]');
    summary.writeln();

    // 提取前几条用户消息作为主题
    if (userMessages.isNotEmpty) {
      summary.writeln('对话主题：');
      for (var i = 0; i < min(3, userMessages.length); i++) {
        final content = userMessages[i].content ?? '';
        final truncated = content.length > 80
            ? '${content.substring(0, 80)}...'
            : content;
        summary.writeln('• $truncated');
      }
      summary.writeln();
    }

    // 提取关键实体（简单提取）
    final allContent = messages.map((m) => m.content ?? '').join(' ');
    final keyEntities = _extractKeyEntities(allContent);
    if (keyEntities.isNotEmpty) {
      summary.writeln('关键实体：${keyEntities.join(", ")}');
      summary.writeln();
    }

    // 统计信息
    summary.writeln('统计：');
    summary.writeln('- 用户消息：${userMessages.length} 条');
    summary.writeln('- 助手回复：${assistantMessages.length} 条');
    summary.writeln('- 时间跨度：${_formatTime(messages.first.createdAt)} → ${_formatTime(messages.last.createdAt)}');

    return summary.toString();
  }

  /// 提取关键实体（简单实现）
  List<String> _extractKeyEntities(String content) {
    // 简单提取：查找可能的人名、地名、术语（以大写字母开头的词）
    final regex = RegExp(r'(?<=[^\u4e00-\u9fa5])([A-Z][a-zA-Z]{2,})(?=[^\u4e00-\u9fa5]|$)');
    final matches = regex.allMatches(content).map((m) => m.group(1)!).toSet();
    
    // 也提取中文关键词（长度 >= 2 的连续中文字符）
    final cnRegex = RegExp(r'[\u4e00-\u9fa5]{2,}');
    final cnMatches = cnRegex.allMatches(content).map((m) => m.group(0)!).toSet();
    
    // 合并并返回前 5 个
    final all = {...matches, ...cnMatches};
    return all.take(5).toList();
  }

  /// 格式化时间
  String _formatTime(DateTime? time) {
    if (time == null) return '未知';
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 估算 token 数（保守估算，含 20% 安全余量）
  ///
  /// 注意：实际 tokenizer 可能与估算有差异，保守估算避免超限崩溃
  static int estimateTokens(String text) {
    // 中文字符约 1-2 token，英文约 4 字符 1 token
    // 加 20% 安全余量避免实际 token 超出估算
    final chineseChars = RegExp(r'[\u4e00-\u9fff]').allMatches(text).length;
    final otherChars = text.length - chineseChars;
    final estimated = (chineseChars * 1.5 + otherChars / 4);
    return (estimated * 1.2).round(); // 20% 安全余量
  }

  /// 估算消息列表的总 token 数
  static int estimateTotalTokens(List<dynamic> messages) {
    return messages.fold<int>(
      0,
      (sum, msg) => sum + estimateTokens(msg.content ?? ''),
    );
  }

  /// ★★★ 强制截断消息列表以适配 token 预算 ★★★
  ///
  /// 当压缩后仍然超出上下文限制时，调用此方法进行硬截断。
  /// 策略：
  /// 1. 始终保留 system 消息
  /// 2. 保留当前用户消息（列表最后一条 user 消息）
  /// 3. 从最旧的非 system 消息开始删除，直到满足预算
  static List<dynamic> truncateToFit(
    List<dynamic> messages,
    int tokenBudget,
  ) {
    final totalTokens = estimateTotalTokens(messages);
    if (totalTokens <= tokenBudget) return messages;

    debugPrint('[ContextCompressor] ⚠️ 需要强制截断: 当前${totalTokens}tokens, 预算${tokenBudget}tokens');

    // 分离 system 消息和非 system 消息
    final systemMessages = messages.where((m) => m.role == 'system').toList();
    final nonSystemMessages = messages.where((m) => m.role != 'system').toList();
    final systemTokens = estimateTotalTokens(systemMessages);

    if (systemTokens >= tokenBudget) {
      // system 消息本身就超预算了，只保留 system 消息（无解）
      debugPrint('[ContextCompressor] ❌ system 消息已超预算 (${systemTokens}tokens)');
      return systemMessages;
    }

    final remainingBudget = tokenBudget - systemTokens;

    // 找到最后一条 user 消息（当前用户输入），必须保留
    int lastUserIndex = -1;
    for (int i = nonSystemMessages.length - 1; i >= 0; i--) {
      if (nonSystemMessages[i].role == 'user') {
        lastUserIndex = i;
        break;
      }
    }

    // 保留最近的消息，从最旧的开始删除
    final keptMessages = <dynamic>[];
    int usedTokens = 0;

    // 先预留最后一条 user 消息的 token
    int reservedTokens = 0;
    if (lastUserIndex >= 0) {
      reservedTokens = estimateTokens(nonSystemMessages[lastUserIndex].content ?? '');
    }

    // 从最新到最旧遍历，贪心保留
    for (int i = nonSystemMessages.length - 1; i >= 0; i--) {
      final msg = nonSystemMessages[i];
      final msgTokens = estimateTokens(msg.content ?? '');
      
      // 最后一条 user 消息必须保留
      if (i == lastUserIndex) {
        if (usedTokens + msgTokens <= remainingBudget) {
          keptMessages.insert(0, msg);
          usedTokens += msgTokens;
        }
        continue;
      }

      if (usedTokens + msgTokens + reservedTokens <= remainingBudget) {
        keptMessages.insert(0, msg);
        usedTokens += msgTokens;
      } else {
        // 超出预算，停止添加
        debugPrint('[ContextCompressor] 🔧 截断: 丢弃 ${i + 1} 条旧消息');
        break;
      }
    }

    // 添加截断说明
    final droppedCount = nonSystemMessages.length - keptMessages.length;
    if (droppedCount > 0) {
      final truncationNotice = _createTruncationNotice(droppedCount);
      keptMessages.insert(0, truncationNotice);
    }

    final result = [...systemMessages, ...keptMessages];
      debugPrint('[ContextCompressor] ✅ 截断完成: ${messages.length} → ${result.length} 条消息, '
        '${estimateTotalTokens(result)}tokens (预算$tokenBudget)');
    return result;
  }

  /// 创建截断说明消息
  static dynamic _createTruncationNotice(int droppedCount) {
    // 返回一个简单对象，兼容 compress 方法的动态类型
    return _TruncationNotice(
      role: 'system',
      content: '[📋 上下文截断] 为适配模型上下文限制，已省略 $droppedCount 条较早的消息。',
    );
  }

  /// 获取压缩建议
  static CompressionRecommendation getRecommendation(List<dynamic> messages, int contextWindow) {
    final totalTokens = estimateTotalTokens(messages);
    final usagePercent = (totalTokens / contextWindow * 100).round();

    if (usagePercent < 50) {
      return CompressionRecommendation(
        needsCompression: false,
        urgency: CompressionUrgency.none,
        message: '上下文使用良好，无需压缩',
        suggestion: null,
      );
    } else if (usagePercent < 75) {
      return CompressionRecommendation(
        needsCompression: true,
        urgency: CompressionUrgency.low,
        message: '上下文即将达到上限',
        suggestion: '建议在下一轮对话后启用压缩',
      );
    } else if (usagePercent < 90) {
      return CompressionRecommendation(
        needsCompression: true,
        urgency: CompressionUrgency.medium,
        message: '上下文使用率较高',
        suggestion: '建议现在启用压缩以保留对话连续性',
      );
    } else {
      return CompressionRecommendation(
        needsCompression: true,
        urgency: CompressionUrgency.high,
        message: '上下文即将溢出！',
        suggestion: '请立即压缩，否则新消息将被截断',
      );
    }
  }

  /// 创建支持 LLM 摘要的服务实例
  static ContextCompressorService createWithLlm({
    required LlmSummaryCallback llmSummaryCallback,
    int maxMessages = 50,
    int maxTokens = 8000,
    CompressionStrategy strategy = CompressionStrategy.hybrid,
  }) {
    return ContextCompressorService(
      maxMessages: maxMessages,
      maxTokens: maxTokens,
      strategy: strategy,
      llmSummaryCallback: llmSummaryCallback,
      triggerConfig: const CompressionTriggerConfig(
        llmSummaryThreshold: 80,
      ),
    );
  }
}

/// 压缩建议
class CompressionRecommendation {
  final bool needsCompression;
  final CompressionUrgency urgency;
  final String message;
  final String? suggestion;

  CompressionRecommendation({
    required this.needsCompression,
    required this.urgency,
    required this.message,
    this.suggestion,
  });
}

/// 压缩紧急程度
enum CompressionUrgency {
  none,
  low,
  medium,
  high,
}

/// 截断通知消息（轻量级，仅用于 truncateToFit）
class _TruncationNotice {
  final String role;
  final String content;
  _TruncationNotice({required this.role, required this.content});
}