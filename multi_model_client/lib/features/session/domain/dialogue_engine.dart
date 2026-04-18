/// 对话引擎 - LLM Studio 核心对话处理模块
/// 
/// 负责：
/// - 模型推理调用（本地/远程）
/// - 上下文管理（自动压缩）
/// - 网络搜索（Tavily/DuckDuckGo/Wikipedia）
/// - MCP 工具调用
/// - 记忆引擎集成
/// - RAG 知识库检索
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import '../../../core/interfaces/dialogue_interface.dart';
import '../../../core/engines/model_inference_engine.dart';
import '../../../core/services/mcp_service_manager.dart';
import '../../../core/services/context_compressor_service.dart';
import '../domain/session_manager.dart';
import '../data/repositories/message_repository.dart';
import '../../../core/storage/database.dart' hide Message;
// dialogue_interface imported above
import '../../memory/domain/memory_engine.dart';
import '../../rag/domain/rag_engine.dart';

/// 搜索模式
enum WebSearchMode {
  tavily,      // Tavily API (需要 Key，国内推荐)
  duckduckgo,  // DuckDuckGo (免费，海外)
  wikipedia,   // Wikipedia (免费)
}

class DialogueEngine implements IDialogueEngine {
  final ModelInferenceEngine _modelEngine;
  final SessionManager _sessionManager;
  final MessageRepository _messageRepository;
  final MemoryEngine _memoryEngine;
  final RAGEngine _ragEngine;
  final MCPToolCallNotifier _mcpNotifier;
  
  /// 上下文压缩服务
  late final ContextCompressorService _compressor;
  
  /// 压缩状态通知器
  final StreamController<CompressionEvent>? _compressionController =
      StreamController<CompressionEvent>.broadcast();
  
  /// 压缩事件流（供 UI 订阅）
  Stream<CompressionEvent> get compressionStream =>
      _compressionController?.stream ?? const Stream.empty();

  DialogueEngine({
    required ModelInferenceEngine modelEngine,
    required SessionManager sessionManager,
    required MessageRepository messageRepository,
    required MemoryEngine memoryEngine,
    required RAGEngine ragEngine,
    MCPToolCallNotifier? mcpNotifier,
    ContextCompressorService? compressor,
  })  : _modelEngine = modelEngine,
        _sessionManager = sessionManager,
        _messageRepository = messageRepository,
        _memoryEngine = memoryEngine,
        _ragEngine = ragEngine,
        _mcpNotifier = mcpNotifier ?? MCPToolCallNotifier(),
        _compressor = compressor ?? ContextCompressorService(
          maxMessages: 50,
          maxTokens: 8000,
          strategy: CompressionStrategy.hybrid,
        );

  /// MCP 工具调用通知器
  void notifyMcpToolCall(MCPToolCall call) {
    _mcpNotifier.notify(call);
  }

  @override
  Future<void> sendMessage(String sessionId, String content) async {
    // Save user message
    await _messageRepository.createMessage(
      sessionId: sessionId,
      role: 'user',
      content: content,
    );

    // Get session info
    final session = await _sessionManager.getSession(sessionId);

    String response;
    try {
      // 构建结构化消息数组
      final messages = await _buildStructuredMessages(sessionId);

      // 调用结构化聊天 API
      response = await _modelEngine.generateChat(session.modelId, messages);
    } catch (e) {
      debugPrint('Model generation failed: $e');
      response = '''抱歉，我暂时无法连接到AI模型。可能的原因：

1. 本地模型未加载 - 请在"模型加载页"点击"加载模型"（需要 Ollama 服务运行中）
2. 远程模型配置有误 - 请检查 API Key 和 Base URL
3. Ollama 未启动 - 请确保 Ollama 服务正在运行

错误详情：$e

您可以尝试：
• 启动 Ollama 并加载一个本地模型
• 配置远程模型 API（OpenAI/Anthropic）''';
    }

    // Save assistant message
    await _messageRepository.createMessage(
      sessionId: sessionId,
      role: 'assistant',
      content: response,
    );
  }

  @override
  Stream<DialogueResponse> streamResponse(
    String sessionId,
    String content, {
    bool enableWebSearch = false,
    String? knowledgeContext,
  }) async* {
    // ✅ 第一步：保存用户消息到数据库（保存原始用户输入，不含知识库内容）
    // 保持用户消息干净，知识库上下文仅在推理时注入，不持久化到历史
    await _messageRepository.createMessage(
      sessionId: sessionId,
      role: 'user',
      content: content,
    );
    // 立即刷新，让用户消息先显示出来
    await _sessionManager.refreshCurrentSession();

    // 获取会话信息
    final session = await _sessionManager.getSession(sessionId);

    // ✅ 如果是本地模型且未就绪，自动触发加载（不打断用户，静默加载）
    if (!_modelEngine.isModelReady(session.modelId)) {
      debugPrint('[DialogueEngine] 模型 ${session.modelId} 未加载，尝试自动加载...');
      try {
        await _modelEngine.loadModel(session.modelId);
        debugPrint('[DialogueEngine] 模型 ${session.modelId} 自动加载成功');
      } catch (e) {
        debugPrint('[DialogueEngine] 模型自动加载失败: $e');
        rethrow; // 加载失败时抛出，让前端显示明确错误
      }
    }

    // ✅ 第二步：如果启用网络搜索，先搜索再注入上下文
    String enrichedContent = content;
    if (enableWebSearch) {
      final searchResults = await _performWebSearch(content);
      if (searchResults.isNotEmpty) {
        final resultsText = searchResults
            .map((r) => '- ${r['title']}: ${r['snippet']} (来源: ${r['url']})')
            .join("\n");
        enrichedContent = '请结合以下网络搜索结果回答用户的问题：\n\n' + resultsText + '\n\n用户问题: $content';
      }
    }

    // ✅ 第三步：构建结构化消息
    // 如果有知识库上下文（RAG），将其以临时 system 消息注入消息列表
    // 不修改用户消息原文，符合标准 RAG 流程
    final messages = await _buildStructuredMessagesWithContent(
      sessionId,
      enrichedContent,
      ragContext: knowledgeContext,
    );

    // ✅ 第四步：流式推理
    final responseBuffer = StringBuffer();
    bool hasError = false;
    
    // 速度追踪
    int tokenCount = 0;
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      await for (final token in _modelEngine.generateChatStream(session.modelId, messages)) {
        responseBuffer.write(token);
        tokenCount++;
        
        // 计算实时速度
        final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        double? currentTPS;
        if (elapsedSeconds > 0) {
          currentTPS = tokenCount / elapsedSeconds;
        }
        
        yield DialogueResponse(
          content: token, 
          isComplete: false,
          tokenCount: tokenCount,
          tokensPerSecond: currentTPS,
        );
      }
      stopwatch.stop();
      
      // 记录到性能监控
      _modelEngine.recordGenerationTime(session.modelId, stopwatch.elapsedMilliseconds, tokenCount);
    } catch (e) {
      debugPrint('Stream generation failed: $e');
      hasError = true;
      // 重新抛出，让 session_detail_page 的 catch 处理（显示 SnackBar 提示）
      rethrow;
    } finally {
      // ✅ 第五步：无论成功还是失败，只要有内容就保存助手回复
      final fullResponse = responseBuffer.toString();
      if (fullResponse.isNotEmpty && !hasError) {
        await _messageRepository.createMessage(
          sessionId: sessionId,
          role: 'assistant',
          content: fullResponse,
        );
        // ✅ 关键：刷新消息列表，让助手回复显示出来（不触发 isLoading，不会闪屏）
        await _sessionManager.refreshCurrentSession();
      }
    }

    // ✅ 第六步：告知前端生成完毕（只在成功时到达这里）
    final totalTokens = tokenCount;
    final avgTPS = stopwatch.elapsedMilliseconds > 0 
        ? totalTokens / (stopwatch.elapsedMilliseconds / 1000.0) 
        : null;
    yield DialogueResponse(
      content: responseBuffer.toString(),
      isComplete: true,
      tokenCount: totalTokens,
      tokensPerSecond: avgTPS,
    );

    // ✅ 第七步：后台检查并执行 MCP 工具调用（不影响主流程）
    if (session.enabledMcpServerIds?.isNotEmpty ?? false) {
      _checkAndExecuteMcpTools(
        sessionId: sessionId,
        text: responseBuffer.toString(),
        messages: messages,
      );
    }
  }

  @override
  Future<void> cancelGeneration(String sessionId) async {
    final session = await _sessionManager.getSession(sessionId);
    _modelEngine.cancelGeneration(session.modelId);
  }

  @override
  Future<void> clearContext(String sessionId) async {
    await _messageRepository.deleteSessionMessages(sessionId);
  }

  /// 构建结构化消息数组（支持 system/user/assistant 角色）
  ///
  /// 返回的消息数组结构：
  /// - 如果有 systemPrompt → 第一条为 ChatMessage.system
  /// - 历史消息 → 按 role 映射为 ChatMessage.system/user/assistant
  /// - 自动启用上下文压缩（如果消息过长）
  /// 注意：调用此方法前用户消息已保存到数据库，无需再次添加
  Future<List<ChatMessage>> _buildStructuredMessages(
    String sessionId,
  ) async {
    final dbMessages = await _messageRepository.getSessionMessages(sessionId);
    final session = await _sessionManager.getSession(sessionId);

    final messages = <ChatMessage>[];

    // 系统提示词（单独作为第一条 system 消息）
    if (session.systemPrompt != null && session.systemPrompt!.isNotEmpty) {
      messages.add(ChatMessage.system(session.systemPrompt!));
    }

    // ✅ 检查是否需要压缩上下文
    List<dynamic> historyMessages;
    if (_compressor.needsCompression(dbMessages)) {
      // 执行上下文压缩
      final compressedMessages = _compressor.compress(dbMessages);
      
      // 通知 UI 压缩事件
      _compressionController?.add(CompressionEvent(
        originalCount: dbMessages.length,
        compressedCount: compressedMessages.length,
        strategy: _compressor.strategy,
      ));
      
      debugPrint('[DialogueEngine] 上下文压缩: ${dbMessages.length} → ${compressedMessages.length} 条消息');
      
      historyMessages = compressedMessages.map((m) => CompressedMessageAdapter(m)).toList();
    } else {
      historyMessages = dbMessages;
    }

    // 历史消息（过滤 tool 角色）
    for (final msg in historyMessages) {
      if (msg.role == 'tool') continue; // 跳过工具消息
      if (msg.role == 'system') {
        messages.add(ChatMessage.system(msg.content));
      } else if (msg.role == 'user') {
        messages.add(ChatMessage.user(msg.content));
      } else if (msg.role == 'assistant') {
        messages.add(ChatMessage.assistant(msg.content));
      }
    }

    return messages;
  }

  // Add system message
  Future<void> addSystemMessage(String sessionId, String content) async {
    await _messageRepository.createMessage(
      sessionId: sessionId,
      role: 'system',
      content: content,
    );
  }

  // Add tool result
  Future<void> addToolResult(String sessionId, String toolCallId, String result) async {
    await _messageRepository.createMessage(
      sessionId: sessionId,
      role: 'tool',
      content: result,
      toolCallInfo: toolCallId,
    );
  }

  /// 使用指定内容构建结构化消息（用于搜索增强等场景）
  ///
  /// [ragContext] RAG 检索结果，以临时 system 消息形式注入，
  ///             位于会话 systemPrompt 之后、历史对话之前。
  ///             注意：此内容不保存到数据库，仅在当次推理中有效。
  Future<List<ChatMessage>> _buildStructuredMessagesWithContent(
    String sessionId,
    String currentContent, {
    String? ragContext,
  }) async {
    final dbMessages = await _messageRepository.getSessionMessages(sessionId);
    final session = await _sessionManager.getSession(sessionId);

    final messages = <ChatMessage>[];

    // 系统提示词（单独作为第一条 system 消息）
    if (session.systemPrompt != null && session.systemPrompt!.isNotEmpty) {
      messages.add(ChatMessage.system(session.systemPrompt!));
    }

    // ✅ RAG 知识库上下文：以独立 system 消息注入（标准 RAG 做法）
    // 位于 systemPrompt 之后、历史对话之前，AI 会将其作为"参考资料"
    // 不污染用户消息原文，不持久化到数据库历史
    if (ragContext != null && ragContext.isNotEmpty) {
      final ragSystemPrompt = '你是一个知识问答助手。以下是从知识库中检索到的与用户问题相关的参考资料，'
          '请优先基于这些资料回答用户的问题。如果参考资料与问题无关，请忽略参考资料直接回答。'
          '请不要在回答中提及"参考资料"或"知识库"等词语，直接给出自然流畅的回答。\n\n'
          '=== 知识库参考资料 ===\n'
          '$ragContext\n'
          '=== 参考资料结束 ===';
      messages.add(ChatMessage.system(ragSystemPrompt));
      debugPrint('[DialogueEngine] RAG 上下文已注入为 system 消息，长度: ${ragSystemPrompt.length}');
    }

    // ✅ 检查是否需要压缩上下文
    List<dynamic> historyMessages;
    if (_compressor.needsCompression(dbMessages)) {
      // 执行上下文压缩
      final compressedMessages = _compressor.compress(dbMessages);
      
      // 通知 UI 压缩事件
      _compressionController?.add(CompressionEvent(
        originalCount: dbMessages.length,
        compressedCount: compressedMessages.length,
        strategy: _compressor.strategy,
      ));
      
      debugPrint('[DialogueEngine] 上下文压缩: ${dbMessages.length} → ${compressedMessages.length} 条消息');
      
      historyMessages = compressedMessages.map((m) => CompressedMessageAdapter(m)).toList();
    } else {
      historyMessages = dbMessages;
    }

    // ✅ 找到最后一条用户消息的索引（用于跳过它）
    int lastUserMessageIndex = -1;
    for (int i = historyMessages.length - 1; i >= 0; i--) {
      if (historyMessages[i].role == 'user') {
        lastUserMessageIndex = i;
        break;
      }
    }

    // 历史消息（过滤 tool 角色）
    for (int i = 0; i < historyMessages.length; i++) {
      final msg = historyMessages[i];
      if (msg.role == 'tool') continue;
      
      // ✅ 跳过最后一条用户消息（因为我们要用 currentContent 替代它）
      if (i == lastUserMessageIndex) continue;
      
      if (msg.role == 'system') {
        messages.add(ChatMessage.system(msg.content));
      } else if (msg.role == 'user') {
        messages.add(ChatMessage.user(msg.content));
      } else if (msg.role == 'assistant') {
        messages.add(ChatMessage.assistant(msg.content));
      }
    }

    // 添加当前用户消息（原始用户输入，干净无污染）
    messages.add(ChatMessage.user(currentContent));

    return messages;
  }
  
  /// 压缩事件类
  void disposeCompression() {
    _compressionController?.close();
  }

  /// 搜索模式显示名称
  static String getSearchModeName(WebSearchMode mode) {
    switch (mode) {
      case WebSearchMode.tavily:
        return 'Tavily';
      case WebSearchMode.duckduckgo:
        return 'DuckDuckGo';
      case WebSearchMode.wikipedia:
        return 'Wikipedia';
    }
  }

  /// 当前搜索模式
  WebSearchMode _currentSearchMode = WebSearchMode.tavily;

  /// Tavily API Key (可配置)
  String? _tavilyApiKey;

  /// 设置搜索模式
  void setWebSearchMode(WebSearchMode mode) {
    _currentSearchMode = mode;
  }

  /// 设置 Tavily API Key
  void setTavilyApiKey(String? apiKey) {
    _tavilyApiKey = apiKey;
  }

  /// 执行网络搜索（根据用户选择的模式）
  Future<List<Map<String, dynamic>>> _performWebSearch(String query) async {
    List<Map<String, dynamic>>? results;

    try {
      switch (_currentSearchMode) {
        case WebSearchMode.tavily:
          results = await _searchTavily(query);
          break;
        case WebSearchMode.duckduckgo:
          results = await _searchDuckDuckGo(query);
          break;
        case WebSearchMode.wikipedia:
          results = await _searchWikipedia(query);
          break;
      }

      if (results != null && results.isNotEmpty) {
        debugPrint('Web search succeeded with ${results.length} results');
        return results;
      }
    } catch (e) {
      debugPrint('Search failed: $e');
    }

    // 如果当前模式失败，尝试降级
    if (_currentSearchMode == WebSearchMode.tavily) {
      try {
        final ddgResults = await _searchDuckDuckGo(query);
        if (ddgResults.isNotEmpty) return ddgResults;
      } catch (_) {}
    }

    // 所有源都失败，返回提示
    debugPrint('All search sources failed for query: $query');
    return [
      {
        'title': '网络搜索暂时不可用',
        'snippet': '请检查网络连接或 API Key 配置。',
        'url': '',
        'source': 'System',
      }
    ];
  }

  /// Tavily API (国内推荐，需要免费 API Key)
  /// 注册地址: https://tavily.com
  Future<List<Map<String, dynamic>>> _searchTavily(String query) async {
    final apiKey = _tavilyApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Tavily API Key 未配置。请在设置中配置 Tavily API Key。');
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://api.tavily.com/search',
        data: {
          'query': query,
          'api_key': apiKey,
          'search_depth': 'basic',
          'max_results': 5,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];

        return results.map((r) => {
          'title': r['title'] ?? '',
          'snippet': r['content'] ?? '',
          'url': r['url'] ?? '',
          'source': 'Tavily',
        }).toList().cast<Map<String, dynamic>>();
      } else {
        throw Exception('Tavily API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Tavily search failed: $e');
    }
  }

  /// Brave Search API (推荐，免费额度)
  Future<List<Map<String, dynamic>>> _searchBraveAPI(String query) async {
    // TODO: 用户可以配置 Brave API Key
    // Brave API: https://api.search.brave.com/res/v1/web/search
    // 免费额度: 2000次/月
    throw UnimplementedError('Brave API Key not configured');
  }

  /// DuckDuckGo Instant Answer API
  Future<List<Map<String, dynamic>>> _searchDuckDuckGo(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://api.duckduckgo.com/?q=$encodedQuery&format=json&no_html=1&skip_disambig=1&t=hh&ia=web';

      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'LLM-Studio/1.0',
          },
        ).timeout(const Duration(seconds: 15)); // 增加超时到15秒

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final results = <Map<String, dynamic>>[];

          // 提取摘要
          final abstract = data['Abstract'] as String?;
          final abstractUrl = data['AbstractURL'] as String?;
          final abstractSource = data['AbstractSource'] as String?;

          if (abstract != null && abstract.isNotEmpty) {
            results.add({
              'title': query,
              'snippet': abstract,
              'url': abstractUrl ?? '',
              'source': abstractSource ?? 'DuckDuckGo',
            });
          }

          // 提取相关主题
          final related = data['RelatedTopics'] as List<dynamic>?;
          if (related != null) {
            for (var i = 0; i < related.length && results.length < 5; i++) {
              final topic = related[i] as Map<String, dynamic>;
              final text = topic['Text'] as String?;
              final firstUrl = topic['FirstURL'] as String?;

              if (text != null && text.isNotEmpty) {
                results.add({
                  'title': text.split(' - ').first,
                  'snippet': text,
                  'url': firstUrl ?? '',
                  'source': 'DuckDuckGo',
                });
              }
            }
          }

          // 提取答案
          final answer = data['Answer'] as String?;
          if (answer != null && answer.isNotEmpty) {
            results.insert(0, {
              'title': 'Answer',
              'snippet': answer,
              'url': '',
              'source': 'DuckDuckGo',
            });
          }

          return results;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('DuckDuckGo search failed: $e');
      rethrow;
    }
    return [];
  }

  /// Wikipedia API (免费，无需Key)
  Future<List<Map<String, dynamic>>> _searchWikipedia(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$encodedQuery&format=json&utf8=1&origin=*';

      final client = http.Client();
      try {
        final response = await client.get(
          Uri.parse(url),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final query = data['query'] as Map<String, dynamic>?;
          final search = query?['search'] as List<dynamic>?;

          if (search != null && search.isNotEmpty) {
            return search.take(5).map((item) {
              final m = item as Map<String, dynamic>;
              final title = m['title'] as String? ?? '';
              final snippet = (m['snippet'] as String? ?? '')
                  .replaceAll(RegExp(r'<[^>]*>'), ''); // 移除HTML标签
              return {
                'title': title,
                'snippet': snippet,
                'url': 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(title)}',
                'source': 'Wikipedia',
              };
            }).toList();
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Wikipedia search failed: $e');
      rethrow;
    }
    return [];
  }

  /// SerpAPI (需要API Key)
  Future<List<Map<String, dynamic>>> _searchSerpAPI(String query) async {
    // TODO: 实现 SerpAPI 支持
    throw UnimplementedError('SerpAPI not configured');
  }

  /// 检查并执行 MCP 工具调用
  Future<void> _checkAndExecuteMcpTools({
    required String sessionId,
    required String text,
    required List<ChatMessage> messages,
  }) async {
    if (!_mcpNotifier.hasListeners) return;
    
    try {
      final mcpManager = mcpServiceManager;
      final availableTools = await mcpManager.getAvailableTools(sessionId);
      
      if (availableTools.isEmpty) return;
      
      // 构建工具描述用于提示模型
      final toolDescriptions = <String>[];
      for (final entry in availableTools.entries) {
        for (final tool in entry.value) {
          final argsSchema = tool.inputSchema?.toString() ?? '{}';
          toolDescriptions.add('${tool.name}: ${tool.description ?? ""}');
        }
      }
      
      debugPrint('[DialogueEngine] 检测到 ${availableTools.length} 个 MCP 服务器可用');
      
      // 尝试解析工具调用
      final results = await mcpManager.parseAndExecuteTools(
        sessionId: sessionId,
        text: text,
      );
      
      // 通知 UI 显示工具调用结果
      for (final result in results) {
        _mcpNotifier.notify(result);
        
        // 如果有结果，将结果添加到消息上下文
        if (result.result != null) {
          final resultText = result.result!.content
              .map((c) => c.text ?? c.data ?? '')
              .join('\n');
          
          // 添加工具结果到消息历史
          await _messageRepository.createMessage(
            sessionId: sessionId,
            role: 'tool',
            content: '[${result.toolName}] 结果: $resultText',
            toolCallInfo: '${result.serverId}:${result.toolName}',
          );
        }
      }
    } catch (e) {
      debugPrint('[DialogueEngine] MCP 工具调用失败: $e');
    }
  }
}

/// MCP 工具调用通知器
class MCPToolCallNotifier {
  final List<void Function(MCPToolCall)> _listeners = [];
  MCPToolCall? _lastCall;

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(void Function(MCPToolCall) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(MCPToolCall) listener) {
    _listeners.remove(listener);
  }

  void notify(MCPToolCall call) {
    _lastCall = call;
    for (final listener in _listeners) {
      try {
        listener(call);
      } catch (e) {
        debugPrint('[MCPToolCallNotifier] 通知失败: $e');
      }
    }
  }
}
// ════════════════════════════════════════════════════════════════════════════
//  Riverpod Provider - 使用全局单例
// ════════════════════════════════════════════════════════════════════════════

final dialogueEngineProvider = Provider<DialogueEngine>((ref) {
  return DialogueEngine(
    modelEngine: globalModelEngine,  // 使用全局单例
    sessionManager: ref.watch(sessionManagerProvider),
    messageRepository: MessageRepository(),
    memoryEngine: MemoryEngine(),
    ragEngine: RAGEngine(),
  );
});

/// 压缩事件 - 用于通知 UI 上下文已被压缩
class CompressionEvent {
  final int originalCount;
  final int compressedCount;
  final CompressionStrategy strategy;
  
  CompressionEvent({
    required this.originalCount,
    required this.compressedCount,
    required this.strategy,
  });
  
  String get message {
    final reduced = originalCount - compressedCount;
    final percent = (reduced / originalCount * 100).round();
    return '上下文已压缩: $originalCount → $compressedCount 条 ($percent% 精简)';
  }
}

/// 动态消息接口 - 兼容压缩和原始消息
abstract class DynamicMessage {
  String get id;
  String get role;
  String get content;
  DateTime get createdAt;
  String? get toolCallInfo;
  String? get modelId;
}

/// 压缩消息适配器 - 将 CompressedMessage 适配为 DynamicMessage
class CompressedMessageAdapter implements DynamicMessage {
  final CompressedMessage _original;
  
  CompressedMessageAdapter(this._original);
  
  @override
  String get id => _original.id;
  @override
  String get role => _original.role;
  @override
  String get content => _original.content;
  @override
  DateTime get createdAt => _original.timestamp;
  @override
  String? get toolCallInfo => null;
  @override
  String? get modelId => null;
}
