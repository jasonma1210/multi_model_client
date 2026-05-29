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

  /// 从文本中解析所有 TTS 控制指令
  ///
  /// 返回 [List<TTSControlData>]，包含所有解析到的控制指令段。
  /// 适用于包含多个 TTS 标签的文本。
  static List<TTSControlData> parseAll(String text) {
    final results = <TTSControlData>[];
    final matches = _styleRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      results.add(TTSControlData(
        type: TTSControlType.style,
        controlContent: '',
        displayContent: text,
        originalContent: text,
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

    // 尝试匹配导演模式
    final directorMatch = _directorRegex.firstMatch(text);
    if (directorMatch != null) {
      final directorContent = directorMatch.group(1)?.trim() ?? '';
      final displayContent = directorMatch.group(2)?.trim() ?? '';
      debugPrint('[$_tag] 匹配到导演模式: $directorContent');
      return TTSControlData(
        type: TTSControlType.director,
        controlContent: directorContent,
        displayContent: displayContent,
        originalContent: text,
      );
    }

    // 尝试匹配风格/情绪/自然语言控制
    final styleMatch = _styleRegex.firstMatch(text);
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
        originalContent: text,
      );
    }

    // 没有匹配到控制指令，返回纯文本
    debugPrint('[$_tag] 未匹配到控制指令，返回纯文本');
    return TTSControlData(
      type: TTSControlType.style,
      controlContent: '',
      displayContent: text,
      originalContent: text,
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
    };
  }
}