abstract class IDialogueEngine {
  Future<void> sendMessage(String sessionId, String content);
  /// [knowledgeContext] RAG 检索结果，以结构化 system 消息注入，不污染用户消息原文
  Stream<DialogueResponse> streamResponse(
    String sessionId,
    String content, {
    bool enableWebSearch = false,
    String? knowledgeContext,
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

  const DialogueResponse({
    required this.content,
    this.isComplete = false,
    this.toolCall,
    this.tokenCount,
    this.tokensPerSecond,
  });
  
  /// 创建副本，可覆盖部分字段
  DialogueResponse copyWith({
    String? content,
    bool? isComplete,
    Map<String, dynamic>? toolCall,
    int? tokenCount,
    double? tokensPerSecond,
  }) {
    return DialogueResponse(
      content: content ?? this.content,
      isComplete: isComplete ?? this.isComplete,
      toolCall: toolCall ?? this.toolCall,
      tokenCount: tokenCount ?? this.tokenCount,
      tokensPerSecond: tokensPerSecond ?? this.tokensPerSecond,
    );
  }
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
