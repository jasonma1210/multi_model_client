abstract class IDialogueEngine {
  Future<void> sendMessage(String sessionId, String content);
  /// [knowledgeContext] RAG 检索结果，以结构化 system 消息注入，不污染用户消息原文
  /// [locationContext] 位置信息上下文，用于需要位置相关回答的问题
  Stream<DialogueResponse> streamResponse(
    String sessionId,
    String content, {
    bool enableWebSearch = false,
    String? knowledgeContext,
    String? locationContext,
  });
  Future<void> cancelGeneration(String sessionId);
  Future<void> clearContext(String sessionId);
}

class DialogueResponse {
  final String content;
  final bool isComplete;
  final Map<String, dynamic>? toolCall;
  final int? tokenCount;
  /// 当前实时速度（tokens/s），流式输出时实时更新
  final double? tokensPerSecond;
  /// 网络搜索结果（如果本次开启了网络搜索）
  final WebSearchResponseData? webSearchData;

  // ★★★ 上下文使用率追踪 ★★★
  /// 当前上下文使用率（0.0 ~ 1.0），由 LocalFFIEngine 实时计算
  final double? contextUsage;
  /// 上下文压缩通知（当触发压缩时不为 null）
  final ContextCompressionInfo? compressionInfo;

  const DialogueResponse({
    required this.content,
    this.isComplete = false,
    this.toolCall,
    this.tokenCount,
    this.tokensPerSecond,
    this.webSearchData,
    this.contextUsage,
    this.compressionInfo,
  });
  
  /// 创建副本，可覆盖部分字段
  DialogueResponse copyWith({
    String? content,
    bool? isComplete,
    Map<String, dynamic>? toolCall,
    int? tokenCount,
    double? tokensPerSecond,
    WebSearchResponseData? webSearchData,
    double? contextUsage,
    ContextCompressionInfo? compressionInfo,
  }) {
    return DialogueResponse(
      content: content ?? this.content,
      isComplete: isComplete ?? this.isComplete,
      toolCall: toolCall ?? this.toolCall,
      tokenCount: tokenCount ?? this.tokenCount,
      tokensPerSecond: tokensPerSecond ?? this.tokensPerSecond,
      webSearchData: webSearchData ?? this.webSearchData,
      contextUsage: contextUsage ?? this.contextUsage,
      compressionInfo: compressionInfo ?? this.compressionInfo,
    );
  }
}

/// 上下文压缩信息，当压缩发生时包含详情
class ContextCompressionInfo {
  /// 压缩前消息数
  final int messagesBefore;
  /// 压缩后消息数
  final int messagesAfter;
  /// 压缩原因
  final String reason;
  /// 压缩时刻的上下文使用率
  final double usageBefore;

  const ContextCompressionInfo({
    required this.messagesBefore,
    required this.messagesAfter,
    required this.reason,
    required this.usageBefore,
  });
}

/// 网络搜索响应数据，用于 UI 展示引用卡片
class WebSearchResponseData {
  /// 搜索关键词列表
  final List<String> keywords;
  /// 搜索结果列表（title + url）
  final List<Map<String, String>> results;

  const WebSearchResponseData({
    required this.keywords,
    required this.results,
  });
}

class DialogueContext {
  final List<Message> messages;
  final String? systemPrompt;
  final List<MemoryItem>? relevantMemories;
  final List<KnowledgeItem>? relevantKnowledge;

  const DialogueContext({
    required this.messages,
    this.systemPrompt,
    this.relevantMemories,
    this.relevantKnowledge,
  });
}

class Message {
  final String role;
  final String content;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.role,
    required this.content,
    this.metadata,
  });
}

class MemoryItem {
  final String content;
  final double relevance;

  const MemoryItem({
    required this.content,
    required this.relevance,
  });
}

class KnowledgeItem {
  final String content;
  final String source;
  final double relevance;

  const KnowledgeItem({
    required this.content,
    required this.source,
    required this.relevance,
  });
}
