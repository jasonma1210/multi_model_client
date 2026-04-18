import 'dart:convert';

/// 提示词模板变量替换引擎
class PromptEngine {
  /// 替换模板变量
  /// [template] 模板内容，支持 {{variable}} 格式的变量
  /// [variables] 变量映射表
  /// 返回替换后的字符串
  String renderTemplate(String template, Map<String, String> variables) {
    String result = template;
    for (var entry in variables.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    return result;
  }

  /// 获取内置变量
  /// 这些变量会在模板渲染时自动注入
  Map<String, String> getBuiltInVariables({
    String? userName,
    String? sessionId,
  }) {
    final now = DateTime.now();
    return {
      'current_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'current_time': now.toString(),
      'user_name': userName ?? 'User',
      'session_id': sessionId ?? '',
    };
  }

  /// 从模板内容中提取所有变量名
  Set<String> extractVariables(String template) {
    final regex = RegExp(r'\{\{(\w+)\}\}');
    final matches = regex.allMatches(template);
    return matches.map((m) => m.group(1)!).toSet();
  }

  /// 验证变量是否完整
  /// 返回缺失的变量名列表
  List<String> validateVariables(String template, Map<String, String> providedVariables) {
    final requiredVariables = extractVariables(template);
    final providedKeys = providedVariables.keys.toSet();
    final missing = requiredVariables.difference(providedKeys).toList();
    return missing;
  }

  /// 渲染模板并注入内置变量
  String renderTemplateWithBuiltIns(
    String template, {
    Map<String, String>? customVariables,
    String? userName,
    String? sessionId,
  }) {
    final variables = {
      ...getBuiltInVariables(userName: userName, sessionId: sessionId),
      ...?customVariables,
    };
    return renderTemplate(template, variables);
  }

  /// 预览模板渲染效果（使用占位符）
  String previewTemplate(String template) {
    final variables = extractVariables(template);
    final previewValues = <String, String>{};
    for (var v in variables) {
      previewValues[v] = '[$v]';
    }
    return renderTemplate(template, previewValues);
  }
}

/// 预设提示词模板分类
class PromptCategory {
  static const String general = 'general';
  static const String translation = 'translation';
  static const String coding = 'coding';
  static const String summary = 'summary';
  static const String qa = 'qa';
  static const String writing = 'writing';
  static const String custom = 'custom';

  static const List<String> all = [
    general,
    translation,
    coding,
    summary,
    qa,
    writing,
    custom,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case general:
        return '通用';
      case translation:
        return '翻译';
      case coding:
        return '代码';
      case summary:
        return '总结';
      case qa:
        return '问答';
      case writing:
        return '写作';
      case custom:
        return '自定义';
      default:
        return category;
    }
  }
}

/// 预设提示词模板数据
class PresetPromptTemplates {
  static List<Map<String, dynamic>> get all => [
        // 翻译助手
        {
          'id': 'preset_translation_zh_en',
          'name': '中译英助手',
          'category': PromptCategory.translation,
          'content': '请将以下中文文本翻译成英文，保持原意和风格：\n\n{{content}}\n\n请只输出翻译结果，不要添加解释。',
          'variables': jsonEncode(['content']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_translation_en_zh',
          'name': '英译中助手',
          'category': PromptCategory.translation,
          'content': 'Please translate the following English text into Chinese, maintaining the original meaning and style:\n\n{{content}}\n\nPlease only output the translation, without adding explanations.',
          'variables': jsonEncode(['content']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_translation_multi',
          'name': '多语言翻译',
          'category': PromptCategory.translation,
          'content': 'You are a professional translator. Please translate the following text to {{target_language}}.\n\nOriginal text:\n{{content}}\n\nTranslation guidelines:\n- Maintain the original tone and style\n- Use appropriate terminology for the target language\n- Preserve any cultural nuances where possible\n\nOutput only the translation.',
          'variables': jsonEncode(['target_language', 'content']),
          'isBuiltin': true,
        },

        // 代码助手
        {
          'id': 'preset_coding_code_review',
          'name': '代码审查助手',
          'category': PromptCategory.coding,
          'content': "You are an expert code reviewer. Please review the following {{language}} code:\n\n'''{{language}}\n{{code}}\n'''\n\nProvide feedback on:\n1. Code quality and best practices\n2. Potential bugs or security issues\n3. Performance improvements\n4. Readability and maintainability\n\nBe specific and constructive in your feedback.",
          'variables': jsonEncode(['language', 'code']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_coding_explain',
          'name': '代码解释助手',
          'category': PromptCategory.coding,
          'content': "Please explain the following {{language}} code in detail:\n\n'''{{language}}\n{{code}}\n'''\n\nExplain:\n- What the code does\n- How it works\n- Key concepts used\n- Any important patterns or techniques",
          'variables': jsonEncode(['language', 'code']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_coding_debug',
          'name': '代码调试助手',
          'category': PromptCategory.coding,
          'content': "Help me debug the following {{language}} code:\n\nError message:\n{{error_message}}\n\nCode:\n'''{{language}}\n{{code}}\n'''\n\nPlease:\n1. Identify the root cause of the error\n2. Explain why it is happening\n3. Provide a fix with explanation",
          'variables': jsonEncode(['language', 'error_message', 'code']),
          'isBuiltin': true,
        },

        // 总结助手
        {
          'id': 'preset_summary_brief',
          'name': '简洁总结',
          'category': PromptCategory.summary,
          'content': '请用一段话简洁地总结以下内容的要点：\n\n{{content}}\n\n总结要求：\n- 控制在 {{max_length}} 字以内\n- 突出最重要的信息\n- 使用清晰的语言表达',
          'variables': jsonEncode(['content', 'max_length']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_summary_detailed',
          'name': '详细总结',
          'category': PromptCategory.summary,
          'content': '请对以下内容进行详细总结：\n\n{{content}}\n\n总结要求：\n- 涵盖所有重要观点\n- 按照逻辑顺序组织\n- 包含关键细节和数据（如有）\n- 适当分段，便于阅读',
          'variables': jsonEncode(['content']),
          'isBuiltin': true,
        },

        // 问答助手
        {
          'id': 'preset_qa_context',
          'name': '基于上下文问答',
          'category': PromptCategory.qa,
          'content': 'Based on the following context, please answer the question.\n\nContext:\n{{context}}\n\nQuestion: {{question}}\n\nPlease:\n1. Answer based ONLY on the provided context\n2. If the answer cannot be found in the context, say so\n3. Be precise and cite relevant parts of the context if helpful',
          'variables': jsonEncode(['context', 'question']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_qa_explain',
          'name': '概念解释助手',
          'category': PromptCategory.qa,
          'content': '请解释以下概念/术语：\n\n{{concept}}\n\n请提供：\n- 简洁的定义\n- 常见应用场景\n- 相关的重要知识点\n- 如果适用，提供简单的例子',
          'variables': jsonEncode(['concept']),
          'isBuiltin': true,
        },

        // 写作助手
        {
          'id': 'preset_writing_article',
          'name': '文章写作助手',
          'category': PromptCategory.writing,
          'content': 'Please help me write an article about:\n\nTopic: {{topic}}\n\nStyle: {{style}}\n\nApproximate length: {{length}}\n\nRequirements:\n- Engaging introduction\n- Well-structured body with clear points\n- Compelling conclusion\n- Match the requested style and length',
          'variables': jsonEncode(['topic', 'style', 'length']),
          'isBuiltin': true,
        },
        {
          'id': 'preset_writing_email',
          'name': '邮件写作助手',
          'category': PromptCategory.writing,
          'content': 'Help me write a professional email with the following details:\n\nRecipient: {{recipient}}\nSubject: {{subject}}\nPurpose: {{purpose}}\nTone: {{tone}}\n\nPlease write a clear, professional email that effectively communicates the intended message.',
          'variables': jsonEncode(['recipient', 'subject', 'purpose', 'tone']),
          'isBuiltin': true,
        },

        // 通用助手
        {
          'id': 'preset_general_assistant',
          'name': '通用助手',
          'category': PromptCategory.general,
          'content': 'You are a helpful AI assistant. {{task}}\n\nPlease provide a clear, accurate, and helpful response. If you are unsure about something, say so rather than guessing.',
          'variables': jsonEncode(['task']),
          'isBuiltin': true,
        },
      ];
}
