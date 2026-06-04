/// TTS 风格控制指令解析器
///
/// 支持从 AI 回复中解析和分离 TTS 控制指令，实现精准的语音合成控制。
///
/// 支持的指令格式：
/// - [tts:style=开心 语速快]文本[/tts] - 风格标签控制
/// - [tts:emotion=兴奋][笑]文本[/tts] - 情绪标签控制
/// - [tts:导演模式]角色：...\n场景：...\n指导：...\n[/tts]文本 - 导演模式控制
/// - [tts:natural=自然语言描述]文本[/tts] - 自然语言控制
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/foundation.dart';

/// TTS 控制指令类型
enum TTSControlType {
  /// 风格标签控制（放在 role: assistant 的 content 中）
  style,

  /// 情绪标签控制（放在 role: assistant 的 content 中）
  emotion,

  /// 导演模式控制（放在 role: user 的 content 中）
  director,

  /// 自然语言控制（放在 role: user 的 content 中）
  natural,
}

/// TTS 控制指令数据
class TTSControlData {
  /// 控制指令类型
  final TTSControlType type;

  /// 控制指令内容（风格、情绪、导演描述等）
  final String controlContent;

  /// 实际显示的文本内容
  final String displayContent;

  /// 原始完整文本
  final String originalContent;

  const TTSControlData({
    required this.type,
    required this.controlContent,
    required this.displayContent,
    required this.originalContent,
  });

  /// 是否包含控制指令
  bool get hasControl => controlContent.isNotEmpty;

  /// 获取用于 TTS 的文本（包含控制标签）
  String get ttsContent {
    switch (type) {
      case TTSControlType.style:
      case TTSControlType.emotion:
        // 音频标签控制：控制标签放在 assistant content 中
        return '$controlContent$displayContent';
      case TTSControlType.director:
      case TTSControlType.natural:
        // 自然语言控制：控制内容放在 user content 中，返回纯文本
        return displayContent;
    }
  }

  /// 获取用于显示的文本（不包含控制指令）
  String get visibleContent => displayContent;

  @override
  String toString() {
    return 'TTSControlData(type: $type, control: $controlContent, display: $displayContent)';
  }
}

/// TTS 风格控制指令解析器
class TTSStyleParser {
  static const String _tag = 'TTSStyleParser';

  // 指令匹配正则
  static final RegExp _styleRegex = RegExp(
    r'\[tts:(style|emotion|natural)=([^\]]+)\](.*?)\[/tts\]',
    dotAll: true,
  );

  static final RegExp _directorRegex = RegExp(
    r'\[tts:director\](.*?)\[/tts\](.*)',
    dotAll: true,
  );

  /// 孤立起始标签正则（用于自愈：检测 `[tts:xxx]` 开头但找不到 `[/tts]` 的情况）
  ///
  /// 常见触发场景：
  /// 1. 流式接收中，TTS 引擎在中途开始合成，闭合标签尚未到达
  /// 2. LLM 输出被 `max_tokens` 截断
  /// 3. 模型忘记写闭合标签 `[/tts]`
  static final RegExp _orphanOpenStyleRegex = RegExp(
    r'\[tts:(style|emotion|natural)=([^\]]+)\]',
  );
  static final RegExp _orphanOpenDirectorRegex = RegExp(
    r'\[tts:director\]',
  );

  /// 自愈预处理：剥除所有孤立的 `[tts:xxx]` 起始标签（保留正文）
  ///
  /// 当输入文本中含有 `[tts:style=xxx]正文` 形式但缺少 `[/tts]` 闭合时，
  /// 直接返回 `正文`，避免 TTS 引擎把 `[tts:style=xxx]` 当普通文本朗读。
  ///
  /// 处理策略：
  /// - 完整的 `[tts:xxx]...[/tts]` 对保持不变（由 `_styleRegex` 处理）
  /// - 孤立的 `[tts:xxx]` 起始标签 → 剥除标签，保留正文
  static String _healOrphanOpenTags(String text) {
    var result = text;

    // 1) 先找到所有完整闭合对，标记其起始标签位置为"已配对"
    final pairedRanges = <int>{};
    for (final m in _styleRegex.allMatches(text)) {
      // 完整 style/emotion/natural 对的起点：在 match.start 之前定位 `[tts:`
      final openIdx = text.indexOf('[tts:', m.start);
      if (openIdx >= 0) {
        pairedRanges.add(openIdx);
      }
    }
    for (final m in _directorRegex.allMatches(text)) {
      // 完整 director 对的起点：直接在 m.start
      pairedRanges.add(m.start);
    }

    // 2) 自愈：从后向前扫描所有 style/emotion/natural 孤立起始标签，剥除它们
    final orphanMatches = _orphanOpenStyleRegex.allMatches(result).toList()
      ..sort((a, b) => b.start.compareTo(a.start));
    for (final m in orphanMatches) {
      if (pairedRanges.contains(m.start)) continue; // 已是完整对的起点，跳过
      result = result.replaceRange(m.start, m.end, '');
    }

    // 3) 自愈：处理导演模式孤立标签（同样按已配对集合判断）
    final directorOrphans = _orphanOpenDirectorRegex.allMatches(result).toList()
      ..sort((a, b) => b.start.compareTo(a.start));
    for (final m in directorOrphans) {
      if (pairedRanges.contains(m.start)) continue;
      result = result.replaceRange(m.start, m.end, '');
    }

    return result;
  }

  /// 从文本中解析所有 TTS 控制指令
  ///
  /// 返回 [List<TTSControlData>]，包含所有解析到的控制指令段。
  /// 适用于包含多个 TTS 标签的文本。
  static List<TTSControlData> parseAll(String text) {
    // ★ 自愈预处理：剥除孤立的 [tts:xxx] 起始标签（流式截断/模型忘闭合场景）
    final healedText = _healOrphanOpenTags(text);

    final results = <TTSControlData>[];
    final matches = _styleRegex.allMatches(healedText).toList();

    if (matches.isEmpty) {
      results.add(TTSControlData(
        type: TTSControlType.style,
        controlContent: '',
        displayContent: healedText,
        originalContent: healedText,
      ));
      return results;
    }

    for (final match in matches) {
      final controlTypeStr = match.group(1) ?? '';
      final controlValue = match.group(2)?.trim() ?? '';
      final displayContent = match.group(3)?.trim() ?? '';

      TTSControlType type;
      String controlContent;

      switch (controlTypeStr) {
        case 'style':
          type = TTSControlType.style;
          controlContent = '($controlValue)';
          break;
        case 'emotion':
          type = TTSControlType.emotion;
          controlContent = '($controlValue)';
          break;
        case 'natural':
          type = TTSControlType.natural;
          controlContent = controlValue;
          break;
        default:
          type = TTSControlType.style;
          controlContent = '($controlValue)';
      }

      if (displayContent.isNotEmpty) {
        results.add(TTSControlData(
          type: type,
          controlContent: controlContent,
          displayContent: displayContent,
          originalContent: match.group(0) ?? '',
        ));
      }
    }

    return results;
  }

  /// 从文本中解析 TTS 控制指令
  ///
  /// 返回 [TTSControlData]，包含分离后的控制指令和显示文本。
  ///
  /// 示例：
  /// ```dart
  /// final data = TTSStyleParser.parse(
  ///   '[tts:style=开心 语速快]今天天气真好！[/tts]'
  /// );
  /// print(data.controlContent); // '(开心 语速快)'
  /// print(data.displayContent); // '今天天气真好！'
  /// ```
  static TTSControlData parse(String text) {
    debugPrint('[$_tag] 解析文本: $text');

    // ★ 自愈预处理：剥除孤立的 [tts:xxx] 起始标签（流式截断/模型忘闭合场景）
    final healedText = _healOrphanOpenTags(text);

    // 尝试匹配导演模式
    final directorMatch = _directorRegex.firstMatch(healedText);
    if (directorMatch != null) {
      final directorContent = directorMatch.group(1)?.trim() ?? '';
      final displayContent = directorMatch.group(2)?.trim() ?? '';
      debugPrint('[$_tag] 匹配到导演模式: $directorContent');
      return TTSControlData(
        type: TTSControlType.director,
        controlContent: directorContent,
        displayContent: displayContent,
        originalContent: healedText,
      );
    }

    // 尝试匹配风格/情绪/自然语言控制
    final styleMatch = _styleRegex.firstMatch(healedText);
    if (styleMatch != null) {
      final controlTypeStr = styleMatch.group(1) ?? '';
      final controlValue = styleMatch.group(2)?.trim() ?? '';
      final displayContent = styleMatch.group(3)?.trim() ?? '';

      TTSControlType type;
      String controlContent;

      switch (controlTypeStr) {
        case 'style':
          type = TTSControlType.style;
          controlContent = '($controlValue)';
          break;
        case 'emotion':
          type = TTSControlType.emotion;
          controlContent = '($controlValue)';
          break;
        case 'natural':
          type = TTSControlType.natural;
          controlContent = controlValue;
          break;
        default:
          type = TTSControlType.style;
          controlContent = '($controlValue)';
      }

      debugPrint('[$_tag] 匹配到$controlTypeStr控制: $controlContent');
      return TTSControlData(
        type: type,
        controlContent: controlContent,
        displayContent: displayContent,
        originalContent: healedText,
      );
    }

    // 没有匹配到控制指令，返回纯文本
    debugPrint('[$_tag] 未匹配到控制指令，返回纯文本');
    return TTSControlData(
      type: TTSControlType.style,
      controlContent: '',
      displayContent: healedText,
      originalContent: healedText,
    );
  }

  /// 从文本中提取纯显示内容（移除所有 TTS 控制指令）
  ///
  /// 用于在 UI 中显示给用户，不包含任何控制标签。
  static String extractDisplayContent(String text) {
    final data = parse(text);
    return data.visibleContent;
  }

  /// 从文本中提取 TTS 控制指令内容
  ///
  /// 用于传递给 TTS 引擎。
  static String extractControlContent(String text) {
    final data = parse(text);
    return data.controlContent;
  }

  /// 检查文本是否包含 TTS 控制指令
  static bool hasControlDirective(String text) {
    return _styleRegex.hasMatch(text) || _directorRegex.hasMatch(text);
  }

  // ============================================================================
  // ★ 音频标签（audio tag）支持 — MiMo v2.5 文档第 138-145 行
  // ============================================================================
  //
  // 音频标签是 MiMo 引擎支持的"细粒度"控制标签，**保留**在 `assistant` 文本中，
  // 由 MiMo 引擎自身解释并产生对应音效（哭、笑、喘、颤抖、气声等）。
  //
  // 与 `[tts:style=xxx]` 风格标签的区别：
  // - 风格标签：放在文本**开头**，控制整段的整体风格
  // - 音频标签：放在文本**任意位置**，对单个字/词/句子做局部控制
  //
  // ★ MVP 阶段只做"识别保留"，不做语义校验。后续 V1.0 加白名单过滤。

  /// 音频标签正则（识别 MiMo 文档列出的 26 种细粒度标签）
  static final RegExp _audioTagRegex = RegExp(
    r'\[('
    // 语速与节奏
    r'吸气|深呼吸|叹气|长叹一口气|喘息|屏息'
    // 情绪状态
    r'|紧张|害怕|激动|疲惫|委屈|撒娇|心虚|震惊|不耐烦'
    // 语音特征
    r'|颤抖|声音颤抖|变调|破音|鼻音|气声|沙哑'
    // 哭笑表达
    r'|笑|轻笑|大笑|冷笑|抽泣|呜咽|哽咽|嚎啕大哭'
    r')\]',
  );

  /// 从文本中提取所有音频标签（保留位置信息）
  ///
  /// 返回按文本顺序排列的音频标签列表，例如：
  /// ```
  /// 输入: "你好[笑]世界[哭]啊"
  /// 输出: [(笑, 2), (哭, 7)]
  /// ```
  static List<({String tag, int position})> extractAudioTags(String text) {
    return _audioTagRegex.allMatches(text).map((m) {
      return (tag: m.group(1)!, position: m.start);
    }).toList();
  }

  /// 检查文本是否包含音频标签
  static bool hasAudioTag(String text) {
    return _audioTagRegex.hasMatch(text);
  }

  /// 统计音频标签数量
  static int countAudioTags(String text) {
    return _audioTagRegex.allMatches(text).length;
  }

  /// 音频标签白名单（来自 MiMo v2.5 文档第 138-145 行）
  ///
  /// 共 26 种细粒度控制标签，按功能分 4 类：
  /// - 语速与节奏（7）
  /// - 情绪状态（9）
  /// - 语音特征（8）
  /// - 哭笑表达（10）
  static const Set<String> audioTagWhitelist = {
    // 语速与节奏
    '吸气', '深呼吸', '叹气', '长叹一口气', '喘息', '屏息',
    // 情绪状态
    '紧张', '害怕', '激动', '疲惫', '委屈', '撒娇', '心虚', '震惊', '不耐烦',
    // 语音特征
    '颤抖', '声音颤抖', '变调', '破音', '鼻音', '气声', '沙哑',
    // 哭笑表达
    '笑', '轻笑', '大笑', '冷笑', '抽泣', '呜咽', '哽咽', '嚎啕大哭',
  };

  /// 检测结果：白名单外的标签
  ///
  /// 返回所有未在白名单中但符合 `[xxx]` 形式的内容标签
  /// 例如：`[神秘]`、`[未知]` 等
  static List<String> findUnknownAudioTags(String text) {
    // 匹配任意 `[xxx]` 形式（xxx 不含 ]）
    final genericRegex = RegExp(r'\[([^\]]+)\]');
    final unknown = <String>[];
    for (final m in genericRegex.allMatches(text)) {
      final content = m.group(1) ?? '';
      // 跳过 tts: 风格标签 和 /xxx 闭合标签（包括 /tts、/神秘 等）
      if (content.startsWith('tts:') || content.startsWith('/')) continue;
      if (!audioTagWhitelist.contains(content)) {
        unknown.add(content);
      }
    }
    return unknown;
  }

  /// 校验并清理文本中的音频标签
  ///
  /// [strict] true：白名单外的标签**直接删除**；false：保留原样（仅警告）
  ///
  /// 返回清理后的文本 + 是否含有警告信息
  static ({String text, List<String> warnings}) sanitizeAudioTags(
    String text, {
    bool strict = false,
  }) {
    final unknown = findUnknownAudioTags(text);
    if (unknown.isEmpty) {
      return (text: text, warnings: const []);
    }
    if (!strict) {
      return (text: text, warnings: unknown);
    }
    // 严格模式：删除白名单外的标签
    var cleaned = text;
    for (final tag in unknown.toSet()) {
      cleaned = cleaned.replaceAll('[$tag]', '');
      cleaned = cleaned.replaceAll('[/$tag]', '');
    }
    return (text: cleaned, warnings: unknown);
  }

  // ============================================================================
  // ★ 冲突检测 — V1.1（实际方法位于顶层，见文件下方）
  // ============================================================================
  //
  // 检测不同 TTS 控制指令之间的潜在冲突：
  // 1. style + natural 并存（同一段）：可能让模型困惑
  // 2. style + director 并存：style 放 assistant、director 放 user，可能冲突
  // 3. 多个 natural 标签连续：可能造成风格叠加混乱
  // 4. audio tag 数量过多（>10 个/段）：可能让模型过度关注音效而忽略文字

  /// 从多段 TTS 控制数据中提取全局角色锚定描述
  ///
  /// 分析所有段落的控制标签，提取统一的角色基础特质，
  /// 作为每段 API 请求的共享 user 消息，确保语调人格一致。
  ///
  /// [segments] 所有 TTS 段落
  /// [sceneContext] 可选的场景上下文描述
  static String extractGlobalAnchor(
    List<TTSControlData> segments, {
    String? sceneContext,
  }) {
    if (segments.isEmpty) return '';

    // 收集所有自然语言控制描述
    final allControls = <String>[];
    for (final seg in segments) {
      if (seg.hasControl && seg.controlContent.isNotEmpty) {
        allControls.add(seg.controlContent);
      }
    }

    if (allControls.isEmpty) return '';

    // 提取第一个段落的控制作为角色基调（通常第一个标签设定整体风格）
    final baseTone = allControls.first;

    // 构建全局锚定描述
    final anchor = StringBuffer();
    anchor.write('保持统一的声音特质和人格：$baseTone');
    if (sceneContext != null && sceneContext.isNotEmpty) {
      anchor.write('。场景设定：$sceneContext');
    }
    anchor.write('。后续每句话的情感变化是在此基础上的细微调整，保持同一人的自然过渡。');

    return anchor.toString();
  }

  /// 构建风格标签控制的 TTS 请求格式
  ///
  /// 根据小米 MIMO API 格式，将控制指令转换为正确的 messages 格式。
  ///
  /// [globalAnchor] 全局角色锚定描述，作为第一个 user 消息注入，
  /// 让 TTS 模型在所有段落中保持一致的角色人格和语调基调。
  static Map<String, dynamic> buildMiMoRequest({
    required String text,
    required String voice,
    String format = 'wav',
    String model = 'mimo-v2.5-tts',
    String? globalAnchor,
  }) {
    final data = parse(text);

    final messages = <Map<String, String>>[];

    // 全局角色锚定：作为第一条 user 消息，建立统一的语调基调
    if (globalAnchor != null && globalAnchor.isNotEmpty) {
      messages.add({
        'role': 'user',
        'content': globalAnchor,
      });
    }

    // 自然语言控制和导演模式：控制内容放在 user 消息中
    if (data.type == TTSControlType.natural ||
        data.type == TTSControlType.director) {
      if (data.controlContent.isNotEmpty) {
        messages.add({
          'role': 'user',
          'content': data.controlContent,
        });
      }
    }

    // 风格标签控制和情绪标签控制：控制标签放在 assistant 消息中
    // 自然语言控制和导演模式：assistant 消息只包含纯文本
    messages.add({
      'role': 'assistant',
      'content': data.ttsContent,
    });

    return {
      'model': model,
      'messages': messages,
      'audio': {
        'format': format,
        'voice': voice,
      },
      'n': 1,
    };
  }

  /// 构建风格标签控制的 TTS 请求格式（用于克隆音色）
  ///
  /// 克隆音色模式下，voice 字段是 DataURL 格式。
  ///
  /// [globalAnchor] 全局角色锚定描述，作为第一个 user 消息注入，
  /// 让 TTS 模型在所有段落中保持一致的角色人格和语调基调。
  static Map<String, dynamic> buildMiMoCloneRequest({
    required String text,
    required String voiceDataUrl,
    String format = 'wav',
    String model = 'mimo-v2.5-tts-voiceclone',
    String? globalAnchor,
  }) {
    final data = parse(text);

    final messages = <Map<String, String>>[];

    // 全局角色锚定：作为第一条 user 消息，建立统一的语调基调
    if (globalAnchor != null && globalAnchor.isNotEmpty) {
      messages.add({
        'role': 'user',
        'content': globalAnchor,
      });
    }

    // 自然语言控制和导演模式：控制内容放在 user 消息中
    if (data.type == TTSControlType.natural ||
        data.type == TTSControlType.director) {
      if (data.controlContent.isNotEmpty) {
        messages.add({
          'role': 'user',
          'content': data.controlContent,
        });
      }
    }

    // 风格标签控制和情绪标签控制：控制标签放在 assistant 消息中
    messages.add({
      'role': 'assistant',
      'content': data.ttsContent,
    });

    return {
      'model': model,
      'messages': messages,
      'audio': {
        'format': format,
        'voice': voiceDataUrl,
      },
      'n': 1,
    };
  }

  /// 构建音色设计（voicedesign）模型的 TTS 请求
  ///
  /// `mimo-v2.5-tts-voicedesign` 是 MiMo v2.5 提供的"通过文本描述自动生成音色"模型。
  /// 文档第 39 行明确：`user` 角色的消息为**必填参数**，用于描述想要的音色。
  /// 文档第 50 行：`optimize_text_preview` 参数可让模型自动润色输入文本。
  ///
  /// [voicePrompt] 音色描述（必填），如 "young female ASMR, soft whisper"
  /// [autoOptimizeText] 是否启用 `optimize_text_preview`（默认 true）
  /// [globalAnchor] 全局角色锚定描述（可选）
  static Map<String, dynamic> buildMiMoDesignRequest({
    required String text,
    required String voicePrompt,
    String format = 'wav',
    String model = 'mimo-v2.5-tts-voicedesign',
    bool autoOptimizeText = true,
    String? globalAnchor,
  }) {
    if (voicePrompt.trim().isEmpty) {
      throw ArgumentError('voicedesign 模型要求 voicePrompt 必填');
    }

    final data = parse(text);

    final messages = <Map<String, String>>[];

    // 1) 全局角色锚定：作为第一条 user 消息
    if (globalAnchor != null && globalAnchor.isNotEmpty) {
      messages.add({
        'role': 'user',
        'content': globalAnchor,
      });
    }

    // 2) ★ voicedesign 必填：音色描述作为 user 消息
    messages.add({
      'role': 'user',
      'content': voicePrompt,
    });

    // 3) 自然语言控制/导演模式：放在 user 消息中
    if (data.type == TTSControlType.natural ||
        data.type == TTSControlType.director) {
      if (data.controlContent.isNotEmpty) {
        messages.add({
          'role': 'user',
          'content': data.controlContent,
        });
      }
    }

    // 4) 待合成文本作为 assistant 消息
    messages.add({
      'role': 'assistant',
      'content': data.ttsContent,
    });

    return {
      'model': model,
      'messages': messages,
      'audio': {
        'format': format,
        // voicedesign 不传 voice（音色由 user 消息描述生成）
        'optimize_text_preview': autoOptimizeText,
      },
      'n': 1,
    };
  }
}

// =============================================================================
// ★ 顶层冲突检测（V1.1）— Dart 不允许 class 内部声明 enum/typedef
// =============================================================================

/// 冲突项类型
enum ConflictType {
  styleAndNaturalOverlap,    // style + natural 标签在同一段
  styleAndDirectorOverlap,   // style/emotion + director 在同一文本
  naturalMultiple,           // 多个 natural 标签连续
  audioTagOverload,          // audio tag 数量过多
  unknownAudioTag,           // 白名单外的标签
}

/// 冲突项（type, message, position 三元组）
typedef TTSConflict = ({ConflictType type, String message, int? position});

/// 冲突类型中文名
String conflictTypeName(ConflictType t) {
  switch (t) {
    case ConflictType.styleAndNaturalOverlap:
      return 'style 与 natural 同时存在';
    case ConflictType.styleAndDirectorOverlap:
      return '风格标签与导演模式同时存在';
    case ConflictType.naturalMultiple:
      return '多个 natural 标签连续';
    case ConflictType.audioTagOverload:
      return '音频标签过多';
    case ConflictType.unknownAudioTag:
      return '白名单外音频标签';
  }
}

/// 检测文本中的所有冲突（顶层函数）
///
/// 返回冲突项列表，每项包含类型、位置、详细说明
List<TTSConflict> detectTTSConflicts(String text) {
  final conflicts = <TTSConflict>[];

  // 1) style + natural 重叠
  // ★ 注：内部用到的正则与检测函数都属于 TTSStyleParser 类
  final styleMatches = <RegExpMatch>[];
  for (final m in RegExp(r'\[tts:(style|emotion|natural)=([^\]]+)\](.*?)\[/tts\]',
          dotAll: true)
      .allMatches(text)) {
    styleMatches.add(m);
  }
  final naturalCount = styleMatches.where((m) => m.group(1) == 'natural').length;
  final otherStyleCount = styleMatches.length - naturalCount;
  if (naturalCount > 0 && otherStyleCount > 0) {
    conflicts.add((
      type: ConflictType.styleAndNaturalOverlap,
      message: '检测到 $naturalCount 个 natural 与 $otherStyleCount 个 style/emotion 同时存在，'
          'MiMo 引擎对 natural 最敏感，可能出现风格混乱',
      position: null,
    ));
  }

  // 2) style + director 重叠
  final hasStyle = styleMatches.isNotEmpty;
  final hasDirector = RegExp(r'\[tts:director\](.*?)\[/tts\]', dotAll: true)
      .hasMatch(text);
  if (hasStyle && hasDirector) {
    conflicts.add((
      type: ConflictType.styleAndDirectorOverlap,
      message: '检测到风格标签与导演模式同时存在，导演描述会作为 user 消息覆盖风格指令',
      position: null,
    ));
  }

  // 3) 多个 natural
  if (naturalCount > 1) {
    conflicts.add((
      type: ConflictType.naturalMultiple,
      message: '检测到 $naturalCount 个 natural 标签，引擎会拼接处理，建议合并为 1 个',
      position: null,
    ));
  }

  // 4) audio tag 过多（只统计不在 [tts:...] / [/tts] 内的标签）
  int audioCount = 0;
  final audioTagRegex = RegExp(
      r'\[(笑|哭|轻笑|大笑|冷笑|抽泣|呜咽|哽咽|嚎啕大哭|吸气|深呼吸|叹气|长叹一口气|喘息|屏息|紧张|害怕|激动|疲惫|委屈|撒娇|心虚|震惊|不耐烦|颤抖|声音颤抖|变调|破音|鼻音|气声|沙哑)\]');
  // 先标记 [tts:...] / [/tts] 段为已占用区间
  final occupied = <(int, int)>[];
  for (final m in RegExp(r'\[/?tts:[^\]]*\]').allMatches(text)) {
    occupied.add((m.start, m.end));
  }
  for (final m in audioTagRegex.allMatches(text)) {
    final inside = occupied.any((r) => m.start >= r.$1 && m.end <= r.$2);
    if (!inside) audioCount++;
  }
  if (audioCount > 10) {
    conflicts.add((
      type: ConflictType.audioTagOverload,
      message: '检测到 $audioCount 个音频标签（>10），可能让模型过度关注音效',
      position: null,
    ));
  }

  // 5) 白名单外标签
  final unknown = TTSStyleParser.findUnknownAudioTags(text);
  if (unknown.isNotEmpty) {
    conflicts.add((
      type: ConflictType.unknownAudioTag,
      message: '检测到 ${unknown.length} 个白名单外标签：${unknown.take(5).join('、')}'
          '${unknown.length > 5 ? '…' : ''}',
      position: null,
    ));
  }

  return conflicts;
}

/// 生成冲突的简短摘要（用于 UI 显示）
String summarizeTTSConflicts(List<TTSConflict> conflicts) {
  if (conflicts.isEmpty) return '✓ 无冲突';
  return '⚠️ ${conflicts.length} 个冲突：\n'
      '${conflicts.map((c) => '• ${conflictTypeName(c.type)}').join('\n')}';
}