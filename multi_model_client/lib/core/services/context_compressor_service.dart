/// 上下文压缩服务 - LLM Studio 会话管理模块
/// 
/// 功能：
/// - 会话上下文压缩（滑动窗口/摘要/混合策略）
/// - Token 数量控制
/// - 消息摘要生成
/// - 自动触发压缩
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:math';

/// 上下文压缩策略
enum CompressionStrategy {
  /// 滑动窗口 - 只保留最近 N 条消息
  slidingWindow,

  /// 摘要压缩 - 将旧消息压缩成摘要
  summary,

  /// 混合策略 - 摘要 + 最近消息
  hybrid,
}

/// 压缩后的消息结构
class CompressedMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isSummary;
  final int? originalMessageCount;

  CompressedMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isSummary = false,
    this.originalMessageCount,
  });
}

/// 会话上下文压缩服务
///
/// 自动管理长对话的上下文窗口，防止超出模型的 token 限制
class ContextCompressorService {
  // 配置
  final int maxMessages; // 最大保留消息数
  final int maxTokens; // 最大 token 数（估算）
  final CompressionStrategy strategy;
  final double summaryRatio; // 摘要压缩时保留的消息比例

  ContextCompressorService({
    this.maxMessages = 50,
    this.maxTokens = 8000,
    this.strategy = CompressionStrategy.hybrid,
    this.summaryRatio = 0.3,
  });

  /// 检查是否需要压缩
  bool needsCompression(List<dynamic> messages) {
    // 检查消息数量
    if (messages.length > maxMessages) {
      return true;
    }

    // 估算 token 数（简单估算：平均每 token 约 4 字符）
    final totalChars = messages.fold<int>(
      0,
      (sum, msg) => sum + ((msg.content?.length ?? 0) as int),
    );
    final estimatedTokens = totalChars ~/ 4;

    return estimatedTokens > maxTokens;
  }

  /// 执行上下文压缩
  ///
  /// 返回压缩后的消息列表，保留重要信息同时减少上下文长度
  List<CompressedMessage> compress(List<dynamic> messages) {
    if (messages.isEmpty) return [];

    // 过滤掉 tool 角色消息（通常不需要保留在压缩上下文中）
    final filteredMessages = messages
        .where((m) => m.role != 'tool')
        .toList();

    if (filteredMessages.length <= maxMessages) {
      // 不需要压缩，直接转换
      return filteredMessages
          .map((m) => CompressedMessage(
                id: m.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                role: m.role,
                content: m.content ?? '',
                timestamp: m.createdAt ?? DateTime.now(),
              ))
          .toList();
    }

    // 根据策略进行压缩
    switch (strategy) {
      case CompressionStrategy.slidingWindow:
        return _slidingWindowCompress(filteredMessages);
      case CompressionStrategy.summary:
        return _summaryCompress(filteredMessages);
      case CompressionStrategy.hybrid:
        return _hybridCompress(filteredMessages);
    }
  }

  /// 滑动窗口压缩 - 保留最近 N 条消息
  List<CompressedMessage> _slidingWindowCompress(List<dynamic> messages) {
    final recentMessages = messages.length > maxMessages
        ? messages.sublist(messages.length - maxMessages)
        : messages;

    return recentMessages
        .map((m) => CompressedMessage(
              id: m.id ?? '',
              role: m.role,
              content: m.content ?? '',
              timestamp: m.createdAt ?? DateTime.now(),
            ))
        .toList();
  }

  /// 摘要压缩 - 保留首尾消息 + 摘要中间部分
  List<CompressedMessage> _summaryCompress(List<dynamic> messages) {
    final result = <CompressedMessage>[];

    // 保留系统提示（如果有）
    final systemMessages = messages.where((m) => m.role == 'system').toList();
    result.addAll(systemMessages.map((m) => CompressedMessage(
          id: m.id ?? '',
          role: 'system',
          content: m.content ?? '',
          timestamp: m.createdAt ?? DateTime.now(),
        )));

    // 保留用户的第一条消息（设定上下文）
    final userMessages = messages.where((m) => m.role == 'user').toList();
    if (userMessages.isNotEmpty) {
      result.add(CompressedMessage(
        id: userMessages.first.id ?? '',
        role: 'user',
        content: '[对话开始] ${userMessages.first.content ?? ''}',
        timestamp: userMessages.first.createdAt ?? DateTime.now(),
        isSummary: true,
        originalMessageCount: userMessages.length,
      ));
    }

    // 保留最后 N 条消息
    final keepCount = (maxMessages * summaryRatio).round();
    final recentMessages = messages.length > keepCount
        ? messages.sublist(messages.length - keepCount)
        : messages;

    // 添加分隔标记
    if (messages.length > maxMessages) {
      result.add(CompressedMessage(
        id: 'summary_separator',
        role: 'system',
        content: '[... 以上为对话摘要，已省略 ${messages.length - keepCount - systemMessages.length - (userMessages.isNotEmpty ? 1 : 0)} 条中间消息 ...]',
        timestamp: DateTime.now(),
        isSummary: true,
      ));
    }

    result.addAll(recentMessages.map((m) => CompressedMessage(
          id: m.id ?? '',
          role: m.role,
          content: m.content ?? '',
          timestamp: m.createdAt ?? DateTime.now(),
        )));

    return result;
  }

  /// 混合压缩策略 - 保留系统提示 + 摘要 + 最近消息
  List<CompressedMessage> _hybridCompress(List<dynamic> messages) {
    final result = <CompressedMessage>[];

    // 1. 保留系统提示词（最重要）
    final systemMessages = messages.where((m) => m.role == 'system').toList();
    result.addAll(systemMessages.map((m) => CompressedMessage(
          id: m.id ?? '',
          role: 'system',
          content: m.content ?? '',
          timestamp: m.createdAt ?? DateTime.now(),
        )));

    // 2. 如果对话很长，添加摘要
    if (messages.length > maxMessages * 1.5) {
      final summary = _generateSimpleSummary(messages);
      result.add(CompressedMessage(
        id: 'context_summary',
        role: 'system',
        content: summary,
        timestamp: DateTime.now(),
        isSummary: true,
        originalMessageCount: messages.length,
      ));
    }

    // 3. 保留最近的 maxMessages 条消息
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
    result.addAll(recentMessages.map((m) => CompressedMessage(
          id: m.id ?? '',
          role: m.role,
          content: m.content ?? '',
          timestamp: m.createdAt ?? DateTime.now(),
        )));

    return result;
  }

  /// 生成简单的对话摘要
  String _generateSimpleSummary(List<dynamic> messages) {
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
        final truncated = content.length > 100
            ? '${content.substring(0, 100)}...'
            : content;
        summary.writeln('- ${i + 1}. $truncated');
      }
      summary.writeln();
    }

    // 统计信息
    summary.writeln('统计：');
    summary.writeln('- 用户消息：${userMessages.length} 条');
    summary.writeln('- 助手回复：${assistantMessages.length} 条');
    summary.writeln('- 时间跨度：从 ${_formatTime(messages.first.createdAt)} 到 ${_formatTime(messages.last.createdAt)}');

    return summary.toString();
  }

  /// 格式化时间
  String _formatTime(DateTime? time) {
    if (time == null) return '未知';
    return '${time.month}/${time.day} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 估算 token 数
  static int estimateTokens(String text) {
    // 中文字符约 1-2 token，英文约 4 字符 1 token
    // 简单估算
    final chineseChars = RegExp(r'[\u4e00-\u9fff]').allMatches(text).length;
    final otherChars = text.length - chineseChars;
    return (chineseChars * 1.5 + otherChars / 4).round();
  }

  /// 估算消息列表的总 token 数
  static int estimateTotalTokens(List<dynamic> messages) {
    return messages.fold<int>(
      0,
      (sum, msg) => sum + estimateTokens(msg.content ?? ''),
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
