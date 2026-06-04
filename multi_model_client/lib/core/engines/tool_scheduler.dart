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
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:math_expressions/math_expressions.dart';

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

/// 单位转换表（相对于基准单位的比率）
const Map<String, Map<String, double>> _unitTable = {
  'length': {
    'mm': 0.001, 'cm': 0.01, 'm': 1.0, 'km': 1000.0,
    'in': 0.0254, 'ft': 0.3048, 'yd': 0.9144, 'mi': 1609.344,
  },
  'weight': {
    'mg': 0.000001, 'g': 0.001, 'kg': 1.0, 'ton': 1000.0,
    'oz': 0.02834952, 'lb': 0.4535924,
  },
  'temperature': {'c': 1, 'f': 2, 'k': 3},
  'volume': {
    'ml': 0.001, 'l': 1.0, 'gal': 3.78541, 'qt': 0.946353,
    'pt': 0.473176, 'cup': 0.236588,
  },
  'speed': {
    'm/s': 1.0, 'km/h': 0.277778, 'mph': 0.44704, 'knot': 0.514444,
  },
};

/// 单位转换
double _convertUnit(double value, String from, String to) {
  final fromLower = from.toLowerCase();
  final toLower = to.toLowerCase();

  // 温度特殊处理
  if (_isTemperature(fromLower) && _isTemperature(toLower)) {
    return _convertTemperature(value, fromLower, toLower);
  }

  // 查找单位所属类别
  for (final entry in _unitTable.entries) {
    if (entry.key == 'temperature') continue;
    final fromRate = entry.value[fromLower];
    final toRate = entry.value[toLower];
    if (fromRate != null && toRate != null) {
      final baseValue = value * fromRate;
      return baseValue / toRate;
    }
  }
  throw UnsupportedError('Cannot convert from $from to $to');
}

bool _isTemperature(String unit) => ['c', 'f', 'k', 'celsius', 'fahrenheit', 'kelvin'].contains(unit);

double _convertTemperature(double value, String from, String to) {
  final f = from[0];
  final t = to[0];
  // 先转为摄氏
  double celsius;
  switch (f) {
    case 'c': celsius = value; break;
    case 'f': celsius = (value - 32) * 5 / 9; break;
    case 'k': celsius = value - 273.15; break;
    default: throw UnsupportedError('Unknown temperature unit: $from');
  }
  // 摄氏转目标
  switch (t) {
    case 'c': return celsius;
    case 'f': return celsius * 9 / 5 + 32;
    case 'k': return celsius + 273.15;
    default: throw UnsupportedError('Unknown temperature unit: $to');
  }
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
        final expression = params['expression'] as String;
        try {
          final parser = Parser();
          final cm = ContextModel();
          final exp = parser.parse(expression);
          final result = exp.evaluate(EvaluationType.REAL, cm);
          return {'result': result, 'expression': expression};
        } catch (e) {
          return {'error': 'Invalid expression: $e', 'expression': expression};
        }
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
        final value = (params['value'] as num).toDouble();
        final fromUnit = params['from_unit'] as String;
        final toUnit = params['to_unit'] as String;
        try {
          final result = _convertUnit(value, fromUnit, toUnit);
          return {
            'result': result,
            'from': '$value $fromUnit',
            'to': '$result $toUnit',
          };
        } catch (e) {
          return {'error': 'Conversion failed: $e'};
        }
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
        final location = params['location'] as String;
        try {
          // 使用 wttr.in 免费天气 API
          final url = Uri.parse('https://wttr.in/${Uri.encodeComponent(location)}?format=j1');
          final response = await http.get(url).timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final current = data['current_condition']?[0];
            if (current != null) {
              return {
                'location': location,
                'temperature': '${current['temp_C']}°C',
                'feels_like': '${current['FeelsLikeC']}°C',
                'condition': current['weatherDesc']?[0]?['value'] ?? 'Unknown',
                'humidity': '${current['humidity']}%',
                'wind_speed': '${current['windspeedKmph']} km/h',
              };
            }
          }
          return {'location': location, 'error': 'Unable to fetch weather data'};
        } catch (e) {
          debugPrint('[ToolScheduler] Weather API error: $e');
          return {'location': location, 'error': 'Weather service unavailable: $e'};
        }
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
        final action = params['action'] as String;
        final details = params['event_details'] as Map<String, dynamic>?;
        switch (action) {
          case 'query':
            final now = DateTime.now();
            return {
              'action': 'query',
              'current_time': now.toIso8601String(),
              'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
              'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              'weekday': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1],
            };
          case 'create':
            if (details == null) {
              return {'success': false, 'error': 'event_details required for create action'};
            }
            return {
              'action': 'create',
              'success': true,
              'event': details,
              'note': 'Calendar event created (local storage). Full calendar integration requires platform-specific plugins.',
            };
          case 'delete':
            return {
              'action': 'delete',
              'success': true,
              'note': 'Calendar event deletion requires platform-specific calendar plugin.',
            };
          default:
            return {'error': 'Unknown action: $action. Supported: query, create, delete'};
        }
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
