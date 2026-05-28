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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../../core/interfaces/dialogue_interface.dart';
import '../../../core/services/performance_monitor.dart';
import '../../../core/engines/model_inference_engine.dart';
import '../../../core/services/mcp_service_manager.dart';
import '../../../core/services/context_compressor_service.dart';
import '../../../core/services/memory_palace_service.dart';
import '../../../core/services/tts_prompt_template.dart';
import '../domain/session_manager.dart';
import '../data/repositories/message_repository.dart';
import '../../memory/domain/memory_engine.dart';
import '../../rag/domain/rag_engine.dart';
import '../../skill/domain/skill.dart';
import '../../skill/domain/skill_dispatcher.dart';

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
  final MCPToolCallNotifier _mcpNotifier;
  
  /// 上下文压缩服务
  late final ContextCompressorService _compressor;
  
  /// 记忆宫殿服务
  late final MemoryPalaceService _memoryPalace;
  
  /// 压缩状态通知器
  final StreamController<CompressionEvent> _compressionController =
      StreamController<CompressionEvent>.broadcast();
  
  /// 压缩事件流（供 UI 订阅）
  Stream<CompressionEvent> get compressionStream =>
      _compressionController.stream;

  /// LLM 摘要回调（用于智能压缩）
  final Future<String> Function(List<Map<String, String>> messages)? _llmSummaryCallback;

  DialogueEngine({
    required ModelInferenceEngine modelEngine,
    required SessionManager sessionManager,
    required MessageRepository messageRepository,
    MemoryEngine? memoryEngine,
    RAGEngine? ragEngine,
    MCPToolCallNotifier? mcpNotifier,
    ContextCompressorService? compressor,
    MemoryPalaceService? memoryPalace,
    Future<String> Function(List<Map<String, String>> messages)? llmSummaryCallback,
  })  : _modelEngine = modelEngine,
        _sessionManager = sessionManager,
        _messageRepository = messageRepository,
        _mcpNotifier = mcpNotifier ?? MCPToolCallNotifier(),
        _llmSummaryCallback = llmSummaryCallback,
        _compressor = compressor ?? ContextCompressorService(
          maxMessages: 50,
          maxTokens: 8000,
          strategy: CompressionStrategy.hybrid,
        ),
        _memoryPalace = memoryPalace ?? MemoryPalaceService() {
    // 如果提供了 LLM 摘要回调，配置到压缩服务
    if (llmSummaryCallback != null) {
      _compressor.setLlmSummaryCallback(llmSummaryCallback);
    }
  }

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
    String? locationContext,
  }) async* {
    // 性能监控开始
    final perf = PerformanceMonitor();
    final stopwatch = perf.startTimer('dialogue_stream_response');

    try {
    // ✅ 第一步：保存用户消息到数据库
    // 保存的是干净的用户文字（去掉多模态图片标记），避免 UI 显示乱码
    // 图片数据仅在本次推理中使用，不持久化到历史
    debugPrint('[DialogueEngine] streamResponse 开始: sessionId=$sessionId');
    final displayContent = _stripImageMarker(content);
    await _messageRepository.createMessage(
      sessionId: sessionId,
      role: 'user',
      content: displayContent,
    );
    debugPrint('[DialogueEngine] ✅ 步骤1: 用户消息已保存');
    // 立即刷新，让用户消息先显示出来
    await _sessionManager.refreshCurrentSession();
    debugPrint('[DialogueEngine] ✅ 步骤1.5: 会话已刷新');

    // 获取会话信息
    final session = await _sessionManager.getSession(sessionId);
    debugPrint('[DialogueEngine] ✅ 步骤2: 会话已获取, modelId=${session.modelId}');

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

    // ★★★ 动态更新上下文压缩阈值（90% of model context size）★★★
    // 每次流式推理前确保阈值是最新的（模型切换等情况）
    try {
      final ctxSize = await _modelEngine.getContextSize(session.modelId);
      _compressor.updateContextSize(ctxSize); // 内部自动计算 90%
      debugPrint('[DialogueEngine] 上下文压缩阈值: ${(ctxSize * 0.9).round()} (90% of $ctxSize)');
    } catch (e) {
      debugPrint('[DialogueEngine] 获取上下文大小失败: $e，使用默认值');
    }

    // ✅ 第二步：如果启用网络搜索，先搜索再注入上下文
    String enrichedContent = content;
    WebSearchResponseData? webSearchData;
    if (enableWebSearch) {
      final searchResults = await _performWebSearch(content);
      if (searchResults.isNotEmpty) {
        final resultsText = searchResults
            .map((r) => '- ${r['title']}: ${r['snippet']} (来源: ${r['url']})')
            .join("\n");
        enrichedContent = '请结合以下网络搜索结果回答用户的问题：\n\n$resultsText\n\n用户问题: $content';
        // 构建搜索数据供 UI 展示
        final keywords = _extractKeywordsFromContent(content);
        webSearchData = WebSearchResponseData(
          keywords: keywords,
          results: searchResults
              .map((r) => {
                    'title': (r['title'] ?? '') as String,
                    'url': (r['url'] ?? '') as String,
                  })
              .toList(),
        );
      }
    }

    // ✅ 第三步：构建结构化消息
    // 如果有知识库上下文（RAG），将其以临时 system 消息注入消息列表
    // 不修改用户消息原文，符合标准 RAG 流程
    debugPrint('[DialogueEngine] ✅ 步骤3: 开始构建结构化消息');
    var messages = await _buildStructuredMessagesWithContent(
      sessionId,
      enrichedContent,
      ragContext: knowledgeContext,
      locationContext: locationContext,
    );
    debugPrint('[DialogueEngine] ✅ 步骤3: 结构化消息构建完成, 消息数=${messages.length}');

    // ✅ 第三步半：安全截断 - 确保消息总 token 在上下文预算内
    try {
      final ctxSize = await _modelEngine.getContextSize(session.modelId);
      final tokenBudget = (ctxSize * 0.85).round(); // 使用 85% 预算（给输出留空间）
      final estimatedTokens = ContextCompressorService.estimateTotalTokens(
        messages.map((m) => _MessageAdapter(m.role, m.content)).toList(),
      );
      debugPrint('[DialogueEngine] 📊 预截断检查: 估算${estimatedTokens}tokens, 预算${tokenBudget}tokens');
      
      if (estimatedTokens > tokenBudget) {
        debugPrint('[DialogueEngine] ⚠️ 消息超出预算，执行安全截断...');
        final truncated = ContextCompressorService.truncateToFit(
          messages.map((m) => _MessageAdapter(m.role, m.content)).toList(),
          tokenBudget,
        );
        // 将截断结果转回 ChatMessage
        messages = truncated.map((m) => ChatMessage(role: m.role, content: m.content)).toList();
        debugPrint('[DialogueEngine] ✅ 安全截断完成: ${messages.length} 条消息');
      }
    } catch (e) {
      debugPrint('[DialogueEngine] ⚠️ 安全截断检查失败（非致命）: $e');
    }

    // ✅ 第四步：流式推理（带自动重试机制）
    final responseBuffer = StringBuffer();
    bool hasError = false;
    
    // 速度追踪
    // 注意：这里统计的是字符数，不是真正的 token 数
    // 真正的 token 数需要模型返回，但 llama.cpp 不直接返回
    // 估算：中文约 1-1.5 字符 = 1 token，英文约 3-4 字符 = 1 token
    // 使用 1.5 作为估算比率（中文为主，更符合实际）
    const double charToTokenRatio = 1.5;
    int charCount = 0;
    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      debugPrint('[DialogueEngine] ✅ 步骤4: 开始流式推理, modelId=${session.modelId}');
      await for (final token in _modelEngine.generateChatStream(session.modelId, messages)) {
        responseBuffer.write(token);
        charCount += token.length; // 统计实际字符数
        
        // 计算实时速度（字符数 / 比率 = 估算的 token 数）
        final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        double? currentTPS;
        if (elapsedSeconds > 0) {
          currentTPS = (charCount / charToTokenRatio) / elapsedSeconds;
        }
        
        yield DialogueResponse(
          content: token, 
          isComplete: false,
          tokenCount: (charCount / charToTokenRatio).round(),
          tokensPerSecond: currentTPS,
          webSearchData: webSearchData,
        );
      }
      stopwatch.stop();
      
      // 计算估算的 token 数用于性能监控
      final estimatedTokens = (charCount / charToTokenRatio).round();
      // 记录到性能监控
      _modelEngine.recordGenerationTime(session.modelId, stopwatch.elapsedMilliseconds, estimatedTokens);
    } catch (e) {
      // ★★★ 错误恢复：检测 "prompt too long" 并自动截断重试 ★★★
      final errStr = e.toString().toLowerCase();
      final isPromptTooLong = errStr.contains('tokenization failed') ||
          errStr.contains('prompt too long') ||
          errStr.contains('too long') ||
          errStr.contains('token') && errStr.contains('limit');
      
      if (isPromptTooLong) {
        debugPrint('[DialogueEngine] 🔄 检测到 prompt 超长错误，尝试激进截断重试...');
        try {
          // 清空之前的响应
          responseBuffer.clear();
          charCount = 0;
          
          // 激进截断：只保留 system 消息 + 最近 6 条消息
          final ctxSize = await _modelEngine.getContextSize(session.modelId);
          final aggressiveBudget = (ctxSize * 0.5).round(); // 使用 50% 预算
          
          final truncated = ContextCompressorService.truncateToFit(
            messages.map((m) => _MessageAdapter(m.role, m.content)).toList(),
            aggressiveBudget,
          );
          messages = truncated.map((m) => ChatMessage(role: m.role, content: m.content)).toList();
          
          debugPrint('[DialogueEngine] 🔄 激进截断后: ${messages.length} 条消息, 重新推理...');
          
          await for (final token in _modelEngine.generateChatStream(session.modelId, messages)) {
            responseBuffer.write(token);
            charCount += token.length;
            
            final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
            double? currentTPS;
            if (elapsedSeconds > 0) {
              currentTPS = (charCount / charToTokenRatio) / elapsedSeconds;
            }
            
            yield DialogueResponse(
              content: token, 
              isComplete: false,
              tokenCount: (charCount / charToTokenRatio).round(),
              tokensPerSecond: currentTPS,
              webSearchData: webSearchData,
            );
          }
          stopwatch.stop();
          debugPrint('[DialogueEngine] ✅ 激进截断重试成功');
          return; // 成功，跳过后续 rethrow
        } catch (retryError) {
          debugPrint('[DialogueEngine] ❌ 激进截断重试也失败: $retryError');
          hasError = true;
          rethrow;
        }
      }
      
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
    final totalChars = charCount;
    final totalTokens = (totalChars / charToTokenRatio).round();
    final avgTPS = stopwatch.elapsedMilliseconds > 0 
        ? totalTokens / (stopwatch.elapsedMilliseconds / 1000.0) 
        : null;
    yield DialogueResponse(
      content: responseBuffer.toString(),
      isComplete: true,
      tokenCount: totalTokens,
      tokensPerSecond: avgTPS,
      webSearchData: webSearchData,
    );

    // ✅ 第七步：后台检查并执行 MCP 工具调用（不影响主流程）
    if (session.enabledMcpServerIds?.isNotEmpty ?? false) {
      _checkAndExecuteMcpTools(
        sessionId: sessionId,
        text: responseBuffer.toString(),
        messages: messages,
      );
    }

    // ★★★ 第八步：对话完成后检查上下文压缩 ★★★
    // 用户期望：对话完成后，如果上下文超过90%，则真正压缩历史消息到数据库
    await _performPostConversationCompression(sessionId, session.modelId);

    // 性能监控结束
    perf.endTimer('dialogue_stream_response', stopwatch);
    debugPrint('[Performance] 对话响应耗时: ${stopwatch.elapsedMilliseconds}ms, 字符数: $totalChars, 估算Token: $totalTokens, TPS: $avgTPS');
    } catch (e) {
      // 性能监控错误记录
      perf.endTimer('dialogue_stream_response', stopwatch, tags: {'error': 'true'});
      rethrow;
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

    // ✅ Skills 插件系统：注入专家技能的系统提示词
    if (session.enabledSkill != null && session.enabledSkill!.isNotEmpty) {
      final skillDispatcher = SkillDispatcher();
      final skill = skillDispatcher.getSkill(session.enabledSkill!);
      if (skill != null && skill.type == SkillType.expert && skill.expertPrompt != null) {
        messages.add(ChatMessage.system(skill.expertPrompt!));
        debugPrint('[DialogueEngine] 已注入专家技能: ${skill.name}');
      }
    }

    // ✅ TTS 控制指令：当启用语音播报时，注入 TTS 控制指令提示词
    if (session.enableVoiceOutput) {
      messages.add(ChatMessage.system(TTSPromptTemplate.simplifiedPrompt));
      debugPrint('[DialogueEngine] 已注入 TTS 控制指令提示词');
    }

    // ✅ 检查是否需要压缩上下文
    List<dynamic> historyMessages;
    if (_compressor.needsCompression(dbMessages)) {
      // 执行上下文压缩
      final compressedMessages = _compressor.compress(dbMessages);
      
      // 通知 UI 压缩事件
      _compressionController.add(CompressionEvent(
        originalCount: dbMessages.length,
        compressedCount: compressedMessages.length,
        strategy: _compressor.strategy,
      ));
      
      debugPrint('[DialogueEngine] 上下文压缩: ${dbMessages.length} → ${compressedMessages.length} 条消息');
      
      historyMessages = compressedMessages.map((m) => CompressedMessageAdapter(m)).toList();
    } else {
      historyMessages = dbMessages;
    }

    // ✅ 查询模型是否支持多模态：支持则保留历史图片，否则剥离（节省 token）
    final supportsVision = await _modelEngine.supportsMultimodal(session.modelId);

    // 历史消息（过滤 tool 和 system 角色）
    // 注意：system 消息已经在开头添加，历史消息中的 system 消息需要跳过
    // llama.cpp 要求所有 system 消息必须在最前面，否则会报错 "System message must be at the beginning"
    for (final msg in historyMessages) {
      if (msg.role == 'tool' || msg.role == 'system') continue; // 跳过工具和系统消息
      if (msg.role == 'user') {
        // 多模态模型保留图片以获得上下文，纯文本模型剥离以节省 token
        messages.add(_parseUserMessage(msg.content, stripOnly: !supportsVision));
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
  /// [locationContext] 位置信息上下文，以临时 system 消息形式注入，
  ///                   位于 RAG 上下文之后、历史对话之前。
  Future<List<ChatMessage>> _buildStructuredMessagesWithContent(
    String sessionId,
    String currentContent, {
    String? ragContext,
    String? locationContext,
  }) async {
    debugPrint('[DialogueEngine] _buildStructuredMessagesWithContent 开始: sessionId=$sessionId');
    final dbMessages = await _messageRepository.getSessionMessages(sessionId);
    final session = await _sessionManager.getSession(sessionId);
    debugPrint('[DialogueEngine] _buildStructuredMessagesWithContent: 会话已获取, systemPrompt=${session.systemPrompt != null ? "有" : "无"}, enabledSkill=${session.enabledSkill}');

    final messages = <ChatMessage>[];

    // 系统提示词（单独作为第一条 system 消息）
    if (session.systemPrompt != null && session.systemPrompt!.isNotEmpty) {
      messages.add(ChatMessage.system(session.systemPrompt!));
    }

    // ✅ Skills 插件系统：注入专家技能的系统提示词
    if (session.enabledSkill != null && session.enabledSkill!.isNotEmpty) {
      final skillDispatcher = SkillDispatcher();
      final skill = skillDispatcher.getSkill(session.enabledSkill!);
      if (skill != null && skill.type == SkillType.expert && skill.expertPrompt != null) {
        messages.add(ChatMessage.system(skill.expertPrompt!));
        debugPrint('[DialogueEngine] 已注入专家技能: ${skill.name}');
      }
    }

    // ✅ TTS 控制指令：当启用语音播报时，注入 TTS 控制指令提示词
    if (session.enableVoiceOutput) {
      messages.add(ChatMessage.system(TTSPromptTemplate.simplifiedPrompt));
      debugPrint('[DialogueEngine] 已注入 TTS 控制指令提示词');
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

    // ✅ 位置上下文：以独立 system 消息注入
    // 位于 RAG 上下文之后、历史对话之前，AI 会将其作为用户当前位置信息
    if (locationContext != null && locationContext.isNotEmpty) {
      final locationSystemPrompt = '你是一个智能助手。用户当前所在位置信息如下，'
          '请根据用户的位置信息回答相关问题。如果问题与位置无关，请忽略位置信息直接回答。\n\n'
          '$locationContext\n'
          '请根据用户的位置提供更准确、更贴心的回答。';
      messages.add(ChatMessage.system(locationSystemPrompt));
      debugPrint('[DialogueEngine] 位置上下文已注入为 system 消息');
    }

    // ✅ 记忆宫殿上下文：检索相关记忆并注入
    // 位于位置上下文之后、历史对话之前
    try {
      final memoryContext = await _memoryPalace.generateMemoryContext(
        query: currentContent,
        sessionId: sessionId,
        maxLength: 1500,
      );
      if (memoryContext.isNotEmpty) {
        final memorySystemPrompt = '你是一个智能助手。以下是用户的记忆背景信息，'
            '请结合这些记忆来提供更个性化、更连贯的回答。\n\n'
            '$memoryContext\n'
            '请根据用户的记忆背景提供更贴心的回答。';
        messages.add(ChatMessage.system(memorySystemPrompt));
        debugPrint('[DialogueEngine] 记忆上下文已注入为 system 消息');
      }
    } catch (e) {
      debugPrint('[DialogueEngine] 记忆上下文检索失败: $e');
    }

    // ✅ 检查是否需要压缩上下文
    List<dynamic> historyMessages;
    if (_compressor.needsCompression(dbMessages)) {
      // 执行上下文压缩
      final compressedMessages = _compressor.compress(dbMessages);
      
      // 通知 UI 压缩事件
      _compressionController.add(CompressionEvent(
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

    // ✅ 查询模型是否支持多模态：支持则保留历史图片，否则剥离（节省 token）
    final supportsVision = await _modelEngine.supportsMultimodal(session.modelId);

    // 历史消息（过滤 tool 和 system 角色）
    // 注意：system 消息已经在开头添加，历史消息中的 system 消息需要跳过
    // llama.cpp 要求所有 system 消息必须在最前面，否则会报错 "System message must be at the beginning"
    for (int i = 0; i < historyMessages.length; i++) {
      final msg = historyMessages[i];
      if (msg.role == 'tool' || msg.role == 'system') continue;
      
      // ✅ 跳过最后一条用户消息（因为我们要用 currentContent 替代它）
      if (i == lastUserMessageIndex) continue;
      
      if (msg.role == 'user') {
        // 多模态模型保留图片以获得上下文，纯文本模型剥离以节省 token
        messages.add(_parseUserMessage(msg.content, stripOnly: !supportsVision));
      } else if (msg.role == 'assistant') {
        messages.add(ChatMessage.assistant(msg.content));
      }
    }

    // 添加当前用户消息（解析多模态图片标记，如有图片则构建带图片的 ChatMessage）
    messages.add(_parseUserMessage(currentContent));

    return messages;
  }
  
  /// 从消息内容中去掉多模态图片标记，只保留用户文字部分（用于数据库存储/UI 显示）
  String _stripImageMarker(String content) {
    const marker = '[多模态图片数据:';
    final idx = content.indexOf(marker);
    if (idx < 0) return content;
    final text = content.substring(0, idx).trimRight();
    return text.isEmpty ? '[图片]' : text;
  }

  /// 解析用户消息：如含 `[多模态图片数据:...]` 标记，提取图片并构建多模态 ChatMessage；
  /// 否则直接构建纯文本 ChatMessage。
  ///
  /// 图片标记格式（由 session_detail_page 注入）：
  ///   $userText\n\n[多模态图片数据:[{"name":"...","mimeType":"...","data":"base64..."},...]
  ///
  /// [stripOnly] 为 true 时只剥离图片标记（用于历史消息，避免重复传图片消耗 token）
  ChatMessage _parseUserMessage(String content, {bool stripOnly = false}) {
    const marker = '[多模态图片数据:';
    final markerIndex = content.indexOf(marker);
    if (markerIndex < 0) {
      return ChatMessage.user(content);
    }

    // 拆分：用户文字 + JSON 数组
    final userText = content.substring(0, markerIndex).trimRight();
    final jsonStart = markerIndex + marker.length;
    final jsonStr = content.substring(jsonStart);

    if (stripOnly) {
      // 历史消息：只保留文字部分，不重发图片（避免 token 浪费）
      final text = userText.isEmpty ? '[包含图片的消息]' : userText;
      return ChatMessage.user(text);
    }

    // 用 '}' 定位 JSON 数组结束（比找 ']' 更可靠，因为 base64 数据可能含 ']'）
    final lastBrace = jsonStr.lastIndexOf('}');
    if (lastBrace < 0) {
      debugPrint('[DialogueEngine] 多模态 JSON 找不到结束符 \'}\'，降级为纯文本');
      return ChatMessage.user(userText.isEmpty ? content : userText);
    }

    // 截取到 '}' 并补全 ']' 得到完整 JSON 数组
    final cleanJson = '${jsonStr.substring(0, lastBrace + 1)}]';
    try {
      final rawList = jsonDecode(cleanJson) as List<dynamic>;
      final images = rawList.map((item) {
        final m = item as Map<String, dynamic>;
        return ChatImageData(
          base64Data: m['data'] as String,
          mimeType: m['mimeType'] as String? ?? 'image/jpeg',
        );
      }).toList();

      debugPrint('[DialogueEngine] 解析到 ${images.length} 张图片，构建多模态消息');
      return ChatMessage.user(userText, images: images);
    } catch (e) {
      final preview = cleanJson.length > 100 ? '${cleanJson.substring(0, 100)}...' : cleanJson;
      debugPrint('[DialogueEngine] 多模态 JSON 解析出错: $e，cleanJson: "$preview"');
      return ChatMessage.user(userText.isEmpty ? content : userText);
    }
  }

  /// 压缩事件类
  void disposeCompression() {
    _compressionController.close();
  }

  /// ★★★ 对话完成后执行上下文压缩 ★★★
  ///
  /// 用户期望的逻辑：
  /// 1. 对话完成后（AI 回复完毕后）检查上下文使用率
  /// 2. 如果超过 90%，则真正压缩历史消息
  /// 3. 清空历史消息，保留压缩结果作为对话依据
  Future<void> _performPostConversationCompression(
    String sessionId,
    String modelId,
  ) async {
    try {
      // 获取会话的所有消息
      final dbMessages = await _messageRepository.getSessionMessages(sessionId);
      
      // 至少需要有一定数量的消息才考虑压缩
      if (dbMessages.length < 10) return;
      
      // 检查是否需要压缩（基于 90% 阈值）
      if (!_compressor.needsCompression(dbMessages)) return;
      
      // 获取上下文大小用于计算使用率
      final ctxSize = await _modelEngine.getContextSize(modelId);
      final estimatedTokens = ContextCompressorService.estimateTotalTokens(dbMessages);
      final usageRatio = estimatedTokens / ctxSize;
      
      debugPrint('[DialogueEngine] 对话完成，开始检查上下文压缩: '
          '消息数=${dbMessages.length}, 估算Tokens=$estimatedTokens, '
          '上下文=$ctxSize, 使用率=${(usageRatio * 100).toStringAsFixed(1)}%');
      
      // 如果使用率未达到 90%，跳过压缩
      if (usageRatio < 0.90) {
        debugPrint('[DialogueEngine] 上下文使用率未达 90%，跳过压缩');
        return;
      }
      
      debugPrint('[DialogueEngine] 上下文使用率超过 90%，执行压缩...');
      
      // 执行上下文压缩（优先使用 LLM 摘要）
      List<CompressedMessage> compressedMessages;
      if (_llmSummaryCallback != null && dbMessages.length > 50) {
        // 使用 LLM 智能摘要
        debugPrint('[DialogueEngine] 使用 LLM 摘要压缩...');
        compressedMessages = await _compressor.compressWithLlmSummary(dbMessages);
      } else {
        // 使用规则压缩
        compressedMessages = _compressor.compress(dbMessages);
      }
      
      // ★★★ 关键：清空历史消息，写入压缩结果到数据库 ★★★
      // 这是用户期望的核心逻辑：清空旧消息，保留压缩后的摘要
      await _replaceMessagesWithCompression(sessionId, compressedMessages, dbMessages.length);
      
      // 通知 UI 压缩事件
      _compressionController.add(CompressionEvent(
        originalCount: dbMessages.length,
        compressedCount: compressedMessages.length,
        strategy: _compressor.strategy,
      ));
      
      debugPrint('[DialogueEngine] ✅ 上下文压缩完成: ${dbMessages.length} → ${compressedMessages.length} 条消息');
    } catch (e) {
      debugPrint('[DialogueEngine] 上下文压缩失败: $e');
      // 压缩失败不影响对话，默默继续
    }
  }

  /// ★★★ 将压缩后的消息写入数据库，清空旧消息 ★★★
  ///
  /// 激进压缩策略：
  /// 1. 先把所有历史消息存到 MemPalace（确保不丢失）
  /// 2. 清空会话历史
  /// 3. 写入压缩摘要
  /// 4. 会话隔离：每个会话的记忆独立
  Future<void> _replaceMessagesWithCompression(
    String sessionId,
    List<CompressedMessage> compressedMessages,
    int originalCount,
  ) async {
    try {
      // ★★★ 第一步：把历史消息存到 MemPalace（确保不丢失）★★★
      await _archiveToMemoryPalace(sessionId, compressedMessages, originalCount);
      
      // ★★★ 第二步：清空该会话的所有历史消息 ★★★
      await _messageRepository.deleteSessionMessages(sessionId);
      
      // ★★★ 第三步：写入压缩后的消息 ★★★
      for (final msg in compressedMessages) {
        // 如果是摘要消息，用特殊标记包裹
        String content = msg.content;
        if (msg.isSummary) {
          content = '[📝 对话摘要]\n$content';
        }
        
        await _messageRepository.createMessage(
          sessionId: sessionId,
          role: msg.role,
          content: content,
        );
      }
      
      // ★★★ 第四步：添加压缩说明消息 ★★★
      await _messageRepository.createMessage(
        sessionId: sessionId,
        role: 'system',
        content: '[🗜️ 上下文压缩] 已将 $originalCount 条历史消息压缩为 ${compressedMessages.length} 条。\n'
            '✅ 原始对话已归档到记忆宫殿，可通过"回忆"功能检索。\n'
            '当前会话继续，上下文空间已释放。',
      );
      
      // ★★★ 第五步：刷新会话，确保 UI 显示最新数据 ★★★
      await _sessionManager.refreshCurrentSession();
    } catch (e) {
      debugPrint('[DialogueEngine] 写入压缩消息失败: $e');
      rethrow;
    }
  }

  /// ★★★ 将历史消息归档到记忆宫殿 ★★★
  ///
  /// 会话隔离：每条记忆都绑定 sessionId
  /// 检索时只检索当前会话的相关记忆
  Future<void> _archiveToMemoryPalace(
    String sessionId,
    List<CompressedMessage> compressedMessages,
    int originalCount,
  ) async {
    try {
      debugPrint('[DialogueEngine] 开始归档历史消息到记忆宫殿，sessionId=$sessionId');
      
      // 1. 归档完整对话摘要（作为一条记忆）
      final summaryBuffer = StringBuffer();
      summaryBuffer.writeln('## 会话对话归档');
      summaryBuffer.writeln('会话ID: $sessionId');
      summaryBuffer.writeln('原始消息数: $originalCount');
      summaryBuffer.writeln('压缩时间: ${DateTime.now().toString().substring(0, 19)}');
      summaryBuffer.writeln('');
      
      // 按角色分组统计
      int userCount = 0;
      int assistantCount = 0;
      int systemCount = 0;
      for (final msg in compressedMessages) {
        if (msg.role == 'user') userCount++;
        if (msg.role == 'assistant') assistantCount++;
        if (msg.role == 'system') systemCount++;
      }
      summaryBuffer.writeln('统计: 用户消息 $userCount 条，助手回复 $assistantCount 条，系统消息 $systemCount 条');
      summaryBuffer.writeln('');
      
      // 提取对话主题（前几条用户消息）
      final userMessages = compressedMessages.where((m) => m.role == 'user').take(3).toList();
      if (userMessages.isNotEmpty) {
        summaryBuffer.writeln('### 对话主题');
        for (int i = 0; i < userMessages.length; i++) {
          final content = userMessages[i].content;
          final preview = content.length > 100 ? '${content.substring(0, 100)}...' : content;
          summaryBuffer.writeln('${i + 1}. $preview');
        }
        summaryBuffer.writeln('');
      }
      
      // 添加压缩摘要内容
      final summaryMessages = compressedMessages.where((m) => m.isSummary).toList();
      if (summaryMessages.isNotEmpty) {
        summaryBuffer.writeln('### 压缩摘要');
        for (final msg in summaryMessages) {
          summaryBuffer.writeln(msg.content);
        }
      }
      
      // 存储到记忆宫殿（会话隔离）
      await _memoryPalace.addMemory(
        content: summaryBuffer.toString(),
        sessionId: sessionId,  // ★ 会话隔离关键
        type: 'long_term',
        isGlobal: false,  // 不是全局记忆，只属于当前会话
      );
      
      // 2. 归档重要消息（系统提示、首条用户消息等）
      for (final msg in compressedMessages) {
        if (msg.isImportant && msg.importantType != null) {
          await _memoryPalace.addMemory(
            content: '[${msg.importantType!.name}] ${msg.content}',
            sessionId: sessionId,
            type: 'long_term',
            isGlobal: false,
          );
        }
      }
      
      debugPrint('[DialogueEngine] ✅ 归档完成：$originalCount 条消息已存入记忆宫殿');
    } catch (e) {
      debugPrint('[DialogueEngine] 归档到记忆宫殿失败: $e');
      // 归档失败不影响压缩流程，继续执行
    }
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

  /// 从用户提问中提取简短关键词（用于 UI 展示搜索标签）
  List<String> _extractKeywordsFromContent(String content) {
    // 简单策略：将句子拆分为不超过 4 组关键词短语
    final cleaned = content.trim();
    if (cleaned.length <= 20) return [cleaned];

    // 按标点拆分
    final parts = cleaned
        .split(RegExp(r'[，。？！,?!、\n]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.isEmpty) return [cleaned.substring(0, cleaned.length.clamp(0, 30))];

    // 取前 4 个短语，每个限制最多 20 字
    return parts
        .take(4)
        .map((s) => s.length > 20 ? s.substring(0, 20) : s)
        .toList();
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

      if (results.isNotEmpty) {
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
      } catch (_) {
        // ignore: non-critical error
      }
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
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('brave_api_key') ?? '';
    if (apiKey.isEmpty) {
      throw UnimplementedError('Brave API Key not configured. Set brave_api_key in Settings.');
    }
    try {
      final url = Uri.parse('https://api.search.brave.com/res/v1/web/search')
          .replace(queryParameters: {'q': query, 'count': '5'});
      final response = await http.get(url, headers: {
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip',
        'X-Subscription-Token': apiKey,
      }).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['web']?['results'] as List<dynamic>? ?? [];
        return results.map((r) => {
          'title': r['title'] ?? '',
          'url': r['url'] ?? '',
          'snippet': r['description'] ?? '',
          'source': 'brave',
        }).toList();
      }
      throw Exception('Brave API error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Brave search failed: $e');
    }
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
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('serpapi_key') ?? '';
    if (apiKey.isEmpty) {
      throw UnimplementedError('SerpAPI Key not configured. Set serpapi_key in Settings.');
    }
    try {
      final url = Uri.parse('https://serpapi.com/search').replace(queryParameters: {
        'q': query,
        'api_key': apiKey,
        'engine': 'google',
        'num': '5',
      });
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['organic_results'] as List<dynamic>? ?? [];
        return results.map((r) => {
          'title': r['title'] ?? '',
          'url': r['link'] ?? '',
          'snippet': r['snippet'] ?? '',
          'source': 'serpapi',
        }).toList();
      }
      throw Exception('SerpAPI error: ${response.statusCode}');
    } catch (e) {
      throw Exception('SerpAPI search failed: $e');
    }
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

  /// 获取当前上下文使用信息（已用 token、总 token、使用率）
  /// UI 层调用此方法获取上下文占比，用于显示进度条
  ({int used, int max, double ratio}) getContextUsage() {
    return _modelEngine.getContextUsage();
  }

  /// 刷新上下文使用率估算
  /// 在消息变化后（非推理场景，如手动删除消息）调用
  void refreshContextUsage() {
    _modelEngine.refreshContextUsage();
  }

  /// 基于当前会话消息列表更新上下文使用率
  /// 传入从数据库加载的完整历史消息（List<Message>）
  void updateContextUsageFromMessages(List<dynamic> messages) {
    _modelEngine.updateContextUsageFromMessages(messages);
  }

  /// 手动触发上下文压缩（UI 调用）
  /// 用于用户点击进度条时主动压缩上下文
  Future<void> autoCompressContext(String sessionId) async {
    try {
      final session = await _sessionManager.getSession(sessionId);
      await _performPostConversationCompression(sessionId, session.modelId);
      _modelEngine.refreshContextUsage();
    } catch (e) {
      debugPrint('[DialogueEngine] 手动上下文压缩失败: $e');
    }
  }
}

/// MCP 工具调用通知器
class MCPToolCallNotifier {
  final List<void Function(MCPToolCall)> _listeners = [];

  bool get hasListeners => _listeners.isNotEmpty;

  void addListener(void Function(MCPToolCall) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(MCPToolCall) listener) {
    _listeners.remove(listener);
  }

  void notify(MCPToolCall call) {
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

/// 消息适配器 - 轻量级，用于 truncateToFit 接口
class _MessageAdapter {
  final String role;
  final String content;
  _MessageAdapter(this.role, this.content);
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
