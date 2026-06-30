/// v0.44.0: Function Calling template patterns and helpers
///
/// Supports FC output formats of mainstream local models:
/// - Qwen: [TOOL_CALL]{json}
/// - Hermes: [hermes]{json}[/hermes]
/// - Llama 3.1: <|python_tag|>{json}<|eom_id|>
/// - Mistral: [TOOL_CALLS]{json}
library;

import 'dart:convert';

/// FC template type
enum FcFormat {
  qwen,
  hermes,
  llama31,
  mistral,
  auto,
}

/// FC template regex patterns (precompiled for performance)
class FcTemplatePatterns {
  static final RegExp _qwen = RegExp(r'\[TOOL_CALL\]\s*(\{.*?\})\s*', dotAll: true);
  static final RegExp _hermes = RegExp(r'\[hermes\]\s*(\{.*?\})\s*\[/hermes\]', dotAll: true);
  static final RegExp _llama31 = RegExp(r'<\|python_tag\|>\s*(\{.*?\})\s*(?:<\|eom_id\|>|$)', dotAll: true);
  static final RegExp _mistral = RegExp(r'\[TOOL_CALLS\]\s*(\{.*?\})', dotAll: true);
  static final RegExp _generic = RegExp(r'\{[^{}]*"name"\s*:\s*"[^"]*"[^{}]*"arguments"\s*:\s*\{[^{}]*\}[^{}]*\}', dotAll: true);

  static RegExp? patternFor(FcFormat format) {
    switch (format) {
      case FcFormat.qwen: return _qwen;
      case FcFormat.hermes: return _hermes;
      case FcFormat.llama31: return _llama31;
      case FcFormat.mistral: return _mistral;
      case FcFormat.auto: return null;
    }
  }

  static RegExp get generic => _generic;

  static List<RegExp> get allPatterns => [_qwen, _hermes, _llama31, _mistral];
}

/// FC prompt templates (tell model how to output tool calls)
class FcPromptTemplates {
  static String getTemplate(FcFormat format) {
    switch (format) {
      case FcFormat.qwen:
        return 'When you need to call a tool, use this format:\n[TOOL_CALL]{"name": "tool_name", "arguments": {"key": "value"}}\nNote: call only one tool at a time, tool name must match the available tools list exactly.';
      case FcFormat.hermes:
        return 'When you need to call a tool, use this format:\n[hermes]{"name": "tool_name", "arguments": {"key": "value"}}[/hermes]\nNote: call only one tool at a time, tool name must match the available tools list exactly.';
      case FcFormat.llama31:
        return 'When you need to call a tool, use this format:\n<|python_tag|>{"name": "tool_name", "arguments": {"key": "value"}}<|eom_id|>\nNote: call only one tool at a time, tool name must match the available tools list exactly.';
      case FcFormat.mistral:
        return 'When you need to call a tool, use this format:\n[TOOL_CALLS]{"name": "tool_name", "arguments": {"key": "value"}}\nNote: call only one tool at a time, tool name must match the available tools list exactly.';
      case FcFormat.auto:
        return 'When you need to call a tool, use this format:\n[TOOL_CALL]{"name": "tool_name", "arguments": {"key": "value"}}\nNote: call only one tool at a time, tool name must match the available tools list exactly.';
    }
  }

  static FcFormat inferFormat(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('qwen')) return FcFormat.qwen;
    if (id.contains('hermes') || id.contains('nous')) return FcFormat.hermes;
    if (id.contains('llama-3') || id.contains('llama3') || id.contains('llama-4') || id.contains('llama4')) return FcFormat.llama31;
    if (id.contains('mistral') || id.contains('mixtral')) return FcFormat.mistral;
    return FcFormat.auto;
  }
}

/// FC output parser
class FcOutputParser {
  static Map<String, dynamic>? parseToolCall(String output, FcFormat format) {
    String? jsonStr;

    if (format == FcFormat.qwen || format == FcFormat.auto) {
      final match = FcTemplatePatterns.allPatterns[0].firstMatch(output);
      if (match != null && match.groupCount >= 1) jsonStr = match.group(1);
    }
    if (jsonStr == null && (format == FcFormat.hermes || format == FcFormat.auto)) {
      final match = FcTemplatePatterns.allPatterns[1].firstMatch(output);
      if (match != null && match.groupCount >= 1) jsonStr = match.group(1);
    }
    if (jsonStr == null && (format == FcFormat.llama31 || format == FcFormat.auto)) {
      final match = FcTemplatePatterns.allPatterns[2].firstMatch(output);
      if (match != null && match.groupCount >= 1) jsonStr = match.group(1);
    }
    if (jsonStr == null && (format == FcFormat.mistral || format == FcFormat.auto)) {
      final match = FcTemplatePatterns.allPatterns[3].firstMatch(output);
      if (match != null && match.groupCount >= 1) jsonStr = match.group(1);
    }
    if (jsonStr == null) {
      final match = FcTemplatePatterns.generic.firstMatch(output);
      if (match != null) jsonStr = match.group(0);
    }

    if (jsonStr == null) return null;

    try {
      final decoded = _decodeJson(jsonStr);
      if (decoded == null) return null;
      final name = decoded['name'] as String?;
      if (name == null) return null;
      final arguments = decoded['arguments'] ?? decoded['parameters'] ?? {};
      final id = decoded['id'] as String? ?? 'tool_${DateTime.now().millisecondsSinceEpoch}';
      return {
        'id': id,
        'name': name,
        'arguments': arguments is Map ? Map<String, dynamic>.from(arguments) : {},
      };
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _decodeJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map<String, dynamic>) return first;
      }
    } catch (_) {
      try {
        final fixed = jsonStr
            .replaceAll("'", '"')
            .replaceAll(RegExp(r',\s*}'), '}')
            .replaceAll(RegExp(r',\s*\]'), ']');
        final decoded = jsonDecode(fixed);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
