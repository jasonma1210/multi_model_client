/// 工具调度器 - LLM Studio 技能调度模块
/// 
/// 功能：
/// - 工具注册与管理
/// - 工具调用调度
/// - 参数验证与转换
/// - 执行结果处理
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'dart:async';

/// 工具调度器
/// 统一管理和调度各种工具
class ToolScheduler {
  final Map<String, Tool> _registeredTools = {};

  /// 注册工具
  void registerTool(Tool tool) {
    _registeredTools[tool.name] = tool;
  }

  /// 注销工具
  void unregisterTool(String name) {
    _registeredTools.remove(name);
  }

  /// 获取所有工具
  List<Tool> getAllTools() {
    return _registeredTools.values.toList();
  }

  /// 获取工具
  Tool? getTool(String name) {
    return _registeredTools[name];
  }

  /// 执行工具
  Future<ToolResult> executeTool(
    String name,
    Map<String, dynamic> parameters,
  ) async {
    final tool = _registeredTools[name];
    if (tool == null) {
      throw ToolNotFoundException('Tool not found: $name');
    }

    // 验证参数
    final validationError = _validateParameters(tool, parameters);
    if (validationError != null) {
      return ToolResult(
        success: false,
        error: validationError,
      );
    }

    // 执行工具
    try {
      final result = await tool.execute(parameters);
      return ToolResult(
        success: true,
        result: result,
      );
    } catch (e) {
      return ToolResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 验证参数
  String? _validateParameters(Tool tool, Map<String, dynamic> parameters) {
    for (final param in tool.parameters) {
      if (param.required && !parameters.containsKey(param.name)) {
        return 'Required parameter missing: ${param.name}';
      }

      if (parameters.containsKey(param.name)) {
        final value = parameters[param.name];
        if (!_validateType(value, param.type)) {
          return 'Invalid type for parameter ${param.name}: expected ${param.type}';
        }
      }
    }
    return null;
  }

  /// 验证类型
  bool _validateType(dynamic value, String type) {
    switch (type) {
      case 'string':
        return value is String;
      case 'number':
        return value is num;
      case 'boolean':
        return value is bool;
      case 'array':
        return value is List;
      case 'object':
        return value is Map;
      default:
        return true;
    }
  }
}

/// 工具定义
class Tool {
  final String name;
  final String description;
  final List<ToolParameter> parameters;
  final Future<dynamic> Function(Map<String, dynamic>) execute;

  Tool({
    required this.name,
    required this.description,
    required this.parameters,
    required this.execute,
  });

  /// 转换为OpenAI Function格式
  Map<String, dynamic> toOpenAIFormat() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': {
          'type': 'object',
          'properties': {
            for (final param in parameters)
              param.name: {
                'type': param.type,
                'description': param.description,
              }
          },
          'required': parameters.where((p) => p.required).map((p) => p.name).toList(),
        },
      },
    };
  }

  /// 转换为Anthropic Tool格式
  Map<String, dynamic> toAnthropicFormat() {
    return {
      'name': name,
      'description': description,
      'input_schema': {
        'type': 'object',
        'properties': {
          for (final param in parameters)
            param.name: {
              'type': param.type,
              'description': param.description,
            }
        },
        'required': parameters.where((p) => p.required).map((p) => p.name).toList(),
      },
    };
  }
}

/// 工具参数定义
class ToolParameter {
  final String name;
  final String type;
  final String description;
  final bool required;

  ToolParameter({
    required this.name,
    required this.type,
    required this.description,
    this.required = false,
  });
}

/// 工具执行结果
class ToolResult {
  final bool success;
  final dynamic result;
  final String? error;

  ToolResult({
    required this.success,
    this.result,
    this.error,
  });
}

/// 工具未找到异常
class ToolNotFoundException implements Exception {
  final String message;

  ToolNotFoundException(this.message);

  @override
  String toString() => 'ToolNotFoundException: $message';
}

/// 内置工具集合
class BuiltinTools {
  /// 计算器工具
  static Tool calculator() {
    return Tool(
      name: 'calculator',
      description: 'Perform arithmetic calculations',
      parameters: [
        ToolParameter(
          name: 'expression',
          type: 'string',
          description: 'Mathematical expression to evaluate',
          required: true,
        ),
      ],
      execute: (params) async {
        // TODO: 实现安全的数学表达式求值
        return {'result': 0};
      },
    );
  }

  /// 单位转换工具
  static Tool unitConverter() {
    return Tool(
      name: 'unit_converter',
      description: 'Convert between different units',
      parameters: [
        ToolParameter(
          name: 'value',
          type: 'number',
          description: 'Value to convert',
          required: true,
        ),
        ToolParameter(
          name: 'from_unit',
          type: 'string',
          description: 'Source unit',
          required: true,
        ),
        ToolParameter(
          name: 'to_unit',
          type: 'string',
          description: 'Target unit',
          required: true,
        ),
      ],
      execute: (params) async {
        // TODO: 实现单位转换
        return {'result': 0};
      },
    );
  }

  /// 天气查询工具
  static Tool weather() {
    return Tool(
      name: 'get_weather',
      description: 'Get weather information for a location',
      parameters: [
        ToolParameter(
          name: 'location',
          type: 'string',
          description: 'City name or coordinates',
          required: true,
        ),
      ],
      execute: (params) async {
        // TODO: 集成天气API
        return {'temperature': '20°C', 'condition': 'Sunny'};
      },
    );
  }

  /// 日历工具
  static Tool calendar() {
    return Tool(
      name: 'calendar',
      description: 'Manage calendar events',
      parameters: [
        ToolParameter(
          name: 'action',
          type: 'string',
          description: 'Action to perform (create, query, delete)',
          required: true,
        ),
        ToolParameter(
          name: 'event_details',
          type: 'object',
          description: 'Event details',
          required: false,
        ),
      ],
      execute: (params) async {
        // TODO: 实现日历操作
        return {'success': true};
      },
    );
  }

  /// 注册所有内置工具
  static void registerAll(ToolScheduler scheduler) {
    scheduler.registerTool(calculator());
    scheduler.registerTool(unitConverter());
    scheduler.registerTool(weather());
    scheduler.registerTool(calendar());
  }
}
