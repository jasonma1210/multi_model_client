// ignore_for_file: unnecessary_underscores
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/dialogue_engine.dart';

// ============================================================
// 消息解析工具
// ============================================================

/// 解析消息内容，提取 reasoning 区块和正文
/// 支持三种格式：
/// 1. `<think>...</think>` 或 `<thinking>...</thinking>`（主流格式）
/// 2. `<|channel>...</channel|>`（Qwen3 等模型的格式，开始/结束标签不同）
/// 3. `<|channel|>...<|channel|>`（旧版兼容格式）
class MessageParser {
  // Qwen3 格式：<|channel> 开始，<channel|> 结束
  static final _qwen3OpenRegex = RegExp(r'<\|channel>', caseSensitive: false);
  static final _qwen3CloseRegex = RegExp(r'<channel\|>', caseSensitive: false);

  // 旧版 Qwen 格式（开始结束标签相同）
  static final _qwenLegacyRegex = RegExp(r'<\|channel\|>([\s\S]*?)<\|channel\|>', caseSensitive: false);

  // 传统 think 格式
  static final _thinkRegex = RegExp(
    r'<think(?:ing)?>([\s\S]*?)</think(?:ing)?>',
    caseSensitive: false,
  );

  /// 解析完整消息，提取 reasoning 内容和主体正文
  static ParsedMessage parse(String content) {
    final thinkingBuffer = StringBuffer();
    var mainContent = content;

    // 1. 优先匹配 Qwen3 格式 <|channel>...</channel|>
    final qwen3Open = _qwen3OpenRegex.firstMatch(mainContent);
    final qwen3Close = _qwen3CloseRegex.firstMatch(mainContent);
    if (qwen3Open != null && qwen3Close != null && qwen3Close.start > qwen3Open.end) {
      final reasoning = mainContent.substring(qwen3Open.end, qwen3Close.start).trim();
      thinkingBuffer.write(reasoning);
      mainContent = (mainContent.substring(0, qwen3Open.start) +
          mainContent.substring(qwen3Close.end)).trim();
    }

    // 2. 匹配旧版 Qwen 格式 <|channel|>...<|channel|>
    if (thinkingBuffer.isEmpty) {
      for (final m in _qwenLegacyRegex.allMatches(mainContent)) {
        if (thinkingBuffer.isNotEmpty) thinkingBuffer.write('\n\n');
        thinkingBuffer.write(m.group(1)?.trim() ?? '');
        mainContent = mainContent.replaceFirst(RegExp(RegExp.escape(m.group(0)!)), '');
      }
      mainContent = mainContent.trim();
    }

    // 3. 匹配传统 think 格式 <think>...</think>
    if (thinkingBuffer.isEmpty) {
      for (final m in _thinkRegex.allMatches(mainContent)) {
        if (thinkingBuffer.isNotEmpty) thinkingBuffer.write('\n\n');
        thinkingBuffer.write(m.group(1)?.trim() ?? '');
        mainContent = mainContent.replaceFirst(RegExp(RegExp.escape(m.group(0)!)), '');
      }
      mainContent = mainContent.trim();
    }

    final thinking = thinkingBuffer.toString().trim();
    return ParsedMessage(
      thinkingContent: thinking.isEmpty ? null : thinking,
      mainContent: mainContent,
    );
  }

  /// 从流式内容实时提取（增量解析）
  static StreamingParsedMessage parseStreaming(String buffer) {
    // 优先检测 Qwen3 格式 <|channel>
    final q3Open = _qwen3OpenRegex.firstMatch(buffer);
    if (q3Open != null) {
      final q3Close = _qwen3CloseRegex.firstMatch(buffer);
      if (q3Close == null || q3Close.start < q3Open.end) {
        // 还在 reasoning 中
        return StreamingParsedMessage(
          thinkingContent: buffer.substring(q3Open.end).trim(),
          mainContent: '',
          isThinking: true,
        );
      }
      // reasoning 完成
      return StreamingParsedMessage(
        thinkingContent: buffer.substring(q3Open.end, q3Close.start).trim(),
        mainContent: buffer.substring(q3Close.end).trim(),
        isThinking: false,
      );
    }

    // 传统 think 格式
    final thinkOpen = RegExp(r'<think(?:ing)?>', caseSensitive: false);
    final thinkClose = RegExp(r'</think(?:ing)?>', caseSensitive: false);
    final openMatch = thinkOpen.firstMatch(buffer);
    if (openMatch != null) {
      final closeMatch = thinkClose.firstMatch(buffer);
      if (closeMatch == null || closeMatch.start < openMatch.end) {
        return StreamingParsedMessage(
          thinkingContent: buffer.substring(openMatch.end).trim(),
          mainContent: '',
          isThinking: true,
        );
      }
      return StreamingParsedMessage(
        thinkingContent: buffer.substring(openMatch.end, closeMatch.start).trim(),
        mainContent: buffer.substring(closeMatch.end).trim(),
        isThinking: false,
      );
    }

    return StreamingParsedMessage(
      thinkingContent: null,
      mainContent: buffer,
      isThinking: false,
    );
  }
}

class ParsedMessage {
  final String? thinkingContent;
  final String mainContent;

  const ParsedMessage({
    required this.thinkingContent,
    required this.mainContent,
  });
}

class StreamingParsedMessage {
  final String? thinkingContent;
  final String mainContent;
  final bool isThinking;

  const StreamingParsedMessage({
    required this.thinkingContent,
    required this.mainContent,
    required this.isThinking,
  });
}

/// 网络搜索引用信息
class WebSearchResult {
  final String title;
  final String url;
  final String? favicon; // 网站图标 URL
  final String? snippet;

  const WebSearchResult({
    required this.title,
    required this.url,
    this.favicon,
    this.snippet,
  });
}

/// 网络搜索摘要（用于气泡顶部显示）
class WebSearchSummary {
  final int keywordCount;
  final int referenceCount;
  final List<WebSearchResult> results;
  final List<String> keywords;

  const WebSearchSummary({
    required this.keywordCount,
    required this.referenceCount,
    required this.results,
    required this.keywords,
  });
}

// ============================================================
// Reasoning 折叠组件（截图样式：深色圆角卡片，默认折叠）
// ============================================================

/// Reasoning 折叠区块（参考截图：深色背景、脑图标、"Reasoning" 文字、展开箭头）
class ThinkingSection extends StatefulWidget {
  final String content;
  final bool isStreaming; // 是否还在流式思考中

  const ThinkingSection({
    super.key,
    required this.content,
    this.isStreaming = false,
  });

  @override
  State<ThinkingSection> createState() => _ThinkingSectionState();
}

class _ThinkingSectionState extends State<ThinkingSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // 流式 reasoning 中自动展开，完成后延迟收起
    if (widget.isStreaming) {
      _expanded = true;
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ThinkingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 从流式→完成，自动收起
    if (oldWidget.isStreaming && !widget.isStreaming && _expanded) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _collapse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _collapse() {
    setState(() {
      _expanded = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 截图样式：深色背景卡片（亮色模式用深灰，暗色模式用更深的灰）
    final cardBg = isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFF2C2C2E);
    final cardBorder = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFF3A3A3C);
    final headerTextColor = const Color(0xFFAAAAAA);
    final contentTextColor = isDark
        ? const Color(0xFF999999)
        : const Color(0xFFAAAAAA);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 标题行（点击展开/收起）──
            GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    // 大脑图标
                    Icon(
                      Icons.psychology_rounded,
                      size: 16,
                      color: headerTextColor,
                    ),
                    const SizedBox(width: 8),
                    // "Reasoning" 文字（或流式动画）
                    if (widget.isStreaming)
                      _StreamingReasoningLabel(color: headerTextColor)
                    else
                      Text(
                        'Reasoning',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: headerTextColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    const Spacer(),
                    // 展开/收起箭头（截图右侧的 ⌃ 双箭头图标）
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 260),
                      child: Icon(
                        Icons.unfold_more_rounded,
                        size: 17,
                        color: headerTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 展开内容 ──
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 分隔线
                  Container(
                    height: 0.5,
                    color: cardBorder,
                  ),
                  // 内容文字
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: SelectableText(
                      widget.content,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.65,
                        color: contentTextColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 流式 Reasoning 中的动态标签（带脉冲点）
class _StreamingReasoningLabel extends StatefulWidget {
  final Color color;

  const _StreamingReasoningLabel({required this.color});

  @override
  State<_StreamingReasoningLabel> createState() =>
      _StreamingReasoningLabelState();
}

class _StreamingReasoningLabelState extends State<_StreamingReasoningLabel> {
  int _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount % 3) + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Reasoning${'.' * _dotCount}',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: widget.color,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ============================================================
// 网络搜索引用组件
// ============================================================

/// 网络搜索引用折叠区块（参考截图中的搜索卡片样式）
class WebSearchSection extends StatefulWidget {
  final WebSearchSummary summary;

  const WebSearchSection({super.key, required this.summary});

  @override
  State<WebSearchSection> createState() => _WebSearchSectionState();
}

class _WebSearchSectionState extends State<WebSearchSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF8F8F8);
    final borderColor = isDark
        ? const Color(0xFF2E2E2E)
        : const Color(0xFFEEEEEE);
    final headerTextColor = isDark
        ? const Color(0xFF999999)
        : const Color(0xFF888888);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 14,
                    color: headerTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '搜索 ${widget.summary.keywordCount} 个关键词，参考 ${widget.summary.referenceCount} 篇资料',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: headerTextColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: headerTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 展开的搜索关键词和结果
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 1, thickness: 1, color: borderColor),
                // 关键词标签
                if (widget.summary.keywords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.summary.keywords.map((kw) {
                        return _SearchKeywordChip(keyword: kw, theme: theme);
                      }).toList(),
                    ),
                  ),
                // 搜索结果列表
                if (widget.summary.results.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: _SearchResultsGrid(
                      results: widget.summary.results,
                      theme: theme,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchKeywordChip extends StatelessWidget {
  final String keyword;
  final ThemeData theme;

  const _SearchKeywordChip({required this.keyword, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF363636)
              : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_rounded,
            size: 11,
            color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
          ),
          const SizedBox(width: 4),
          Text(
            keyword,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark
                  ? const Color(0xFFBBBBBB)
                  : const Color(0xFF555555),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  final List<WebSearchResult> results;
  final ThemeData theme;

  const _SearchResultsGrid({required this.results, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    // 显示前 6 个
    final displayResults = results.take(6).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: displayResults.map((r) {
        return _SearchResultChip(result: r, isDark: isDark);
      }).toList(),
    );
  }
}

class _SearchResultChip extends StatelessWidget {
  final WebSearchResult result;
  final bool isDark;

  const _SearchResultChip({
    required this.result,
    required this.isDark,
  });

  /// 从 URL 提取域名显示
  String get _domain {
    try {
      final uri = Uri.parse(result.url);
      return uri.host.replaceAll('www.', '');
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF363636) : const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 网站图标
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF444444) : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(
              Icons.language_rounded,
              size: 10,
              color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 6),
          // 标题（截断）
          Flexible(
            child: Text(
              result.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? const Color(0xFFCCCCCC)
                    : const Color(0xFF444444),
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 消息气泡主体
// ============================================================

/// 完整的消息气泡（支持 thinking + 搜索引用 + Markdown 内容）
class MessageBubble extends StatelessWidget {
  final dynamic message;
  final String modelId;
  final int? tokenCount;
  final double? tokensPerSecond;
  final WebSearchSummary? webSearchSummary;
  /// 点击播放语音的回调（仅 AI 消息气泡显示）
  final VoidCallback? onPlayVoice;

  const MessageBubble({
    super.key,
    required this.message,
    required this.modelId,
    this.tokenCount,
    this.tokensPerSecond,
    this.webSearchSummary,
    this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == 'user';

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAssistantAvatar(theme),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (isUser)
                  _UserBubble(content: message.content, theme: theme)
                else
                  _AssistantBubble(
                    message: message,
                    modelId: modelId,
                    tokenCount: tokenCount,
                    tokensPerSecond: tokensPerSecond,
                    webSearchSummary: webSearchSummary,
                    onPlayVoice: onPlayVoice,
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            _buildUserAvatar(theme),
          ],
        ],
      ),
    ));
  }

  Widget _buildAssistantAvatar(ThemeData theme) {
    return AppTheme.buildModelAvatar(modelId: modelId, size: 34);
  }

  Widget _buildUserAvatar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2D2D2D)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.person_outline_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

/// 用户消息气泡
class _UserBubble extends StatelessWidget {
  final String content;
  final ThemeData theme;

  const _UserBubble({required this.content, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已复制'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          // 得物风：用中性深色而非蓝色
          color: isDark
              ? const Color(0xFF2D2D2D)
              : const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isDark ? const Color(0xFFE8E8E8) : Colors.white,
            fontSize: 15,
            height: 1.55,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

/// AI 助手消息气泡
class _AssistantBubble extends StatefulWidget {
  final dynamic message;
  final String modelId;
  final int? tokenCount;
  final double? tokensPerSecond;
  final WebSearchSummary? webSearchSummary;
  final VoidCallback? onPlayVoice;

  const _AssistantBubble({
    required this.message,
    required this.modelId,
    this.tokenCount,
    this.tokensPerSecond,
    this.webSearchSummary,
    this.onPlayVoice,
  });

  @override
  State<_AssistantBubble> createState() => _AssistantBubbleState();
}

class _AssistantBubbleState extends State<_AssistantBubble> {
  String? _translatedText;
  bool _isTranslating = false;

  // v0.44.0: MessageParser 结果缓存（LRU，容量 50）
  // key: '${messageId}_${content.hashCode}'
  // value: ParsedMessage
  // 避免每次 build 重复正则扫描相同消息
  static final Map<String, ParsedMessage> _parseCache = {};
  static const int _maxCacheSize = 50;

  /// v0.44.0: 查询或填充解析缓存（LRU）
  ParsedMessage _parseWithCache(String cacheKey, String content) {
    final cached = _parseCache[cacheKey];
    if (cached != null) {
      // LRU: 移到末尾（最近使用）
      _parseCache.remove(cacheKey);
      _parseCache[cacheKey] = cached;
      return cached;
    }
    final parsed = MessageParser.parse(content);
    _parseCache[cacheKey] = parsed;
    // LRU 淘汰最久未用
    if (_parseCache.length > _maxCacheSize) {
      _parseCache.remove(_parseCache.keys.first);
    }
    return parsed;
  }

  /// 检测文本是否主要为英文
  bool _isMainlyEnglish(String text) {
    final cleaned = text.replaceAll(RegExp(r'[\s\d\p{P}]', unicode: true), '');
    if (cleaned.isEmpty) return false;
    final englishChars = RegExp(r'[a-zA-Z]').allMatches(cleaned).length;
    final chineseChars = RegExp(r'[\u4e00-\u9fff]').allMatches(cleaned).length;
    return englishChars > chineseChars * 2 && englishChars > 10;
  }

  /// 使用 LLM 翻译英文到中文
  Future<void> _translate() async {
    if (_isTranslating) return;
    setState(() => _isTranslating = true);

    try {
      final content = (widget.message.content as String? ?? '');
      // 清理 TTS 标签和 Markdown 格式
      final plainText = content
          .replaceAll(RegExp(r'\[tts[^\]]*\]'), '')
          .replaceAll(RegExp(r'\[/tts\]'), '')
          .replaceAll(RegExp(r'```[\s\S]*?```'), '')
          .replaceAll(RegExp(r'`[^`]*`'), '')
          .replaceAll(RegExp(r'[*#_~>]'), '')
          .trim();

      // 通过 ProviderScope 获取 DialogueEngine 进行翻译
      final container = ProviderScope.containerOf(context);
      final engine = container.read(dialogueEngineProvider);
      final result = await engine.translateText(plainText, targetLang: '中文');

      if (mounted) {
        setState(() {
          _translatedText = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translatedText = '翻译失败: $e';
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = widget.message.content as String? ?? '';
    // v0.44.0: 优先查缓存，避免重复正则扫描
    final cacheKey = '${widget.message.id}_${content.hashCode}';
    final parsed = _parseWithCache(cacheKey, content);
    final showTranslate = _isMainlyEnglish(parsed.mainContent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 思考区块（有 thinking 内容时显示）
        if (parsed.thinkingContent != null &&
            parsed.thinkingContent!.isNotEmpty)
          ThinkingSection(
            content: parsed.thinkingContent!,
            isStreaming: false,
          ),

        // 搜索引用区块
        if (widget.webSearchSummary != null)
          WebSearchSection(summary: widget.webSearchSummary!),

        // 正文内容（仅当有正文时显示，避免思考内容为空时也渲染空框）
        if (parsed.mainContent.isNotEmpty)
          _MarkdownContent(
            content: parsed.mainContent,
            theme: theme,
          ),

        // ★ 翻译区域（检测到英文时显示）
        if (showTranslate) ...[
          const SizedBox(height: 4),
          if (_translatedText != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF1A2A1A)
                    : const Color(0xFFF0F7F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.translate, size: 12, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '中文翻译',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _translatedText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            )
          else if (_isTranslating)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text('翻译中...', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                ],
              ),
            )
          else
            InkWell(
              onTap: _translate,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      '翻译',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],

        // 底部：统计 + 播放语音 + 复制
        const SizedBox(height: 6),
        _BubbleFooter(
          content: content,
          tokenCount: widget.tokenCount,
          tokensPerSecond: widget.tokensPerSecond,
          theme: theme,
          onPlayVoice: widget.onPlayVoice,
        ),
      ],
    );
  }
}

/// Markdown 正文渲染
class _MarkdownContent extends StatelessWidget {
  final String content;
  final ThemeData theme;

  const _MarkdownContent({required this.content, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF1A1A1A);
    final codeBlockBg = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF5F5F5);
    final codeBg = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF0F0F0);

    return SelectionArea(
      child: MarkdownBody(
        data: _cleanContent(content),
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
            letterSpacing: -0.3,
          ),
          h2: TextStyle(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.4,
            letterSpacing: -0.2,
          ),
          h3: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          h4: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          p: TextStyle(
            color: textColor,
            fontSize: 15,
            height: 1.65,
            letterSpacing: 0.1,
          ),
          listBullet: TextStyle(color: textColor, fontSize: 15),
          listIndent: 20,
          code: TextStyle(
            color: isDark
                ? const Color(0xFFE06C75)
                : const Color(0xFFD63384),
            backgroundColor: codeBg,
            fontSize: 13,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: codeBlockBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2E2E2E)
                  : const Color(0xFFE5E5E5),
              width: 1,
            ),
          ),
          codeblockPadding: const EdgeInsets.all(14),
          blockquote: TextStyle(
            color: isDark
                ? const Color(0xFF999999)
                : const Color(0xFF777777),
            fontSize: 14,
            fontStyle: FontStyle.italic,
            height: 1.6,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDark
                    ? const Color(0xFF444444)
                    : const Color(0xFFCCCCCC),
                width: 3,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.only(left: 14),
          a: TextStyle(
            color: isDark
                ? const Color(0xFF7EB7F5)
                : const Color(0xFF0066CC),
            decoration: TextDecoration.underline,
            decorationColor: isDark
                ? const Color(0xFF7EB7F5).withValues(alpha: 0.4)
                : const Color(0xFF0066CC).withValues(alpha: 0.4),
          ),
          strong: const TextStyle(fontWeight: FontWeight.w700),
          em: const TextStyle(fontStyle: FontStyle.italic),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFFE5E5E5),
                width: 1,
              ),
            ),
          ),
          tableHead: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tableBody: TextStyle(
            color: textColor,
            fontSize: 13,
          ),
          tableBorder: TableBorder.all(
            color: isDark
                ? const Color(0xFF2E2E2E)
                : const Color(0xFFE5E5E5),
            width: 1,
          ),
          tableCellsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          tableColumnWidth: const FlexColumnWidth(),
        ),
      ),
    );
  }

  String _cleanContent(String content) {
    String c = content;
    c = c.replaceAllMapped(
      RegExp(r'(?<!\$)\$(?!\$)'),
      (m) => '',
    );
    c = c.replaceAll(RegExp(r'\*{3,}'), '---');
    c = c.replaceAll(RegExp(r'\\+\s*$', multiLine: true), '');
    return c;
  }
}

/// 气泡底部操作栏
class _BubbleFooter extends StatelessWidget {
  final String content;
  final int? tokenCount;
  final double? tokensPerSecond;
  final ThemeData theme;
  final VoidCallback? onPlayVoice;

  const _BubbleFooter({
    required this.content,
    required this.theme,
    this.tokenCount,
    this.tokensPerSecond,
    this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.35);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 统计信息
        if (tokenCount != null || tokensPerSecond != null) ...[
          _StatsBadge(
            tokenCount: tokenCount,
            tokensPerSecond: tokensPerSecond,
            theme: theme,
          ),
          const SizedBox(width: 10),
        ],
        // ★ 播放语音按钮
        if (onPlayVoice != null) ...[
          GestureDetector(
            onTap: onPlayVoice,
            child: Icon(Icons.volume_up_outlined, size: 14, color: iconColor),
          ),
          const SizedBox(width: 10),
        ],
        // 复制按钮
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('已复制'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Icon(Icons.copy_outlined, size: 14, color: iconColor),
        ),
      ],
    );
  }
}

class _StatsBadge extends StatelessWidget {
  final int? tokenCount;
  final double? tokensPerSecond;
  final ThemeData theme;

  const _StatsBadge({
    required this.theme,
    this.tokenCount,
    this.tokensPerSecond,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final parts = <String>[];
    if (tokenCount != null) parts.add('$tokenCount tokens');
    if (tokensPerSecond != null) {
      parts.add('${tokensPerSecond!.toStringAsFixed(1)} tok/s');
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF252525)
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        parts.join(' · '),
        style: TextStyle(
          fontSize: 10.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ============================================================
// 流式消息气泡（生成中使用）
// ============================================================

/// 流式生成中的消息气泡，支持实时 thinking 展示
class StreamingMessageBubble extends StatelessWidget {
  final String streamingText;
  final String modelId;
  final int? tokenCount;
  final double? tokensPerSecond;
  final WebSearchSummary? webSearchSummary;

  const StreamingMessageBubble({
    super.key,
    required this.streamingText,
    required this.modelId,
    this.tokenCount,
    this.tokensPerSecond,
    this.webSearchSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final parsed = streamingText.isEmpty
        ? const StreamingParsedMessage(
            thinkingContent: null,
            mainContent: '',
            isThinking: false,
          )
        : MessageParser.parseStreaming(streamingText);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTheme.buildModelAvatar(modelId: modelId, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 思考区块（实时）
                if (parsed.thinkingContent != null &&
                    parsed.thinkingContent!.isNotEmpty)
                  ThinkingSection(
                    content: parsed.thinkingContent!,
                    isStreaming: parsed.isThinking,
                  ),

                // 搜索引用区块
                if (webSearchSummary != null)
                  WebSearchSection(summary: webSearchSummary!),

                // 正文内容或打字指示器
                if (parsed.mainContent.isNotEmpty)
                  _StreamingMainContent(
                    content: parsed.mainContent,
                    theme: theme,
                  )
                else if (streamingText.isEmpty || parsed.isThinking)
                  _TypingIndicator(theme: theme),

                // 实时速度
                if (tokenCount != null || tokensPerSecond != null) ...[
                  const SizedBox(height: 8),
                  _StreamingStats(
                    tokenCount: tokenCount,
                    tokensPerSecond: tokensPerSecond,
                    theme: theme,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamingMainContent extends StatelessWidget {
  final String content;
  final ThemeData theme;

  const _StreamingMainContent({required this.content, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1A1A1A),
          fontSize: 15,
          height: 1.65,
          letterSpacing: 0.1,
        ),
        code: TextStyle(
          color: isDark
              ? const Color(0xFFE06C75)
              : const Color(0xFFD63384),
          backgroundColor: isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFF0F0F0),
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// 打字指示器（三个跳动的圆点）
class _TypingIndicator extends StatefulWidget {
  final ThemeData theme;

  const _TypingIndicator({required this.theme});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.theme.colorScheme.onSurface.withValues(alpha: 0.4);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final t = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _StreamingStats extends StatelessWidget {
  final int? tokenCount;
  final double? tokensPerSecond;
  final ThemeData theme;

  const _StreamingStats({
    required this.theme,
    this.tokenCount,
    this.tokensPerSecond,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (tokenCount != null) parts.add('$tokenCount tokens');
    if (tokensPerSecond != null) {
      parts.add('${tokensPerSecond!.toStringAsFixed(1)} tok/s');
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 11,
          height: 11,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation(
              theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          parts.join(' · '),
          style: TextStyle(
            fontSize: 10.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
