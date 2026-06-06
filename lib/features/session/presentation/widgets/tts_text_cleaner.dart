// TTS 文本清洗工具
// 从 session_detail_page.dart 拆分

/// 清洗 TTS 文本，移除 reasoning/thinking 内容
///
/// 移除以下格式：
/// - `<|channel|>thought...<|channel|>` (Qwen 系列)
/// - `<|channel|>` 单独出现
/// - `Thinking Process:` 开头段落
/// - `<thinking>...</thinking>` 标签
/// - `<|...|>` 其他 XML 格式标签
class TTSTextCleaner {
  /// 清洗 [text]，移除推理/思考内容
  ///
  /// 返回清洗后的文本
  static String cleanReasoning(String text) {
    if (text.isEmpty) return text;

    String cleaned = text;

    // 移除 <|channel|>thought...<|channel|> 格式（Qwen 系列）
    final thoughtPattern = RegExp(r'<\|channel\|>thought[\s\S]*?<\|channel\|>');
    cleaned = cleaned.replaceAll(thoughtPattern, '');

    // 移除 <|channel|> 单独出现的情况
    cleaned = cleaned.replaceAll(RegExp(r'<\|channel\|>'), '');

    // 移除 Thinking Process: 开头的整段
    cleaned = cleaned.replaceAll(RegExp(r'Thinking Process:[\s\S]*?(?=\n\n|\n[A-Z]|$)'), '');

    // 移除 <thinking>...</thinking> 标签
    cleaned = cleaned.replaceAll(RegExp(r'<thinking>[\s\S]*?</thinking>'), '');

    // 移除其他 XML 格式标签 <|...|>
    cleaned = cleaned.replaceAll(RegExp(r'<\|[^|]+\|>'), '');

    // 清理多余空行
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return cleaned.trim();
  }
}
