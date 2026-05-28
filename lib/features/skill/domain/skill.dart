/// 技能类型
enum SkillType {
  native, // 内置技能（工具类）
  expert, // 专家技能（角色扮演类）
  mcp, // MCP工具包装（兼容保留）
  custom, // 自定义技能
}

/// 技能参数类型
enum SkillParameterType {
  string,
  number,
  boolean,
  array,
  object,
}

/// 技能参数定义
class SkillParameter {
  final String name;
  final String description;
  final SkillParameterType type;
  final bool required;
  final dynamic defaultValue;
  final List<dynamic>? enumValues;

  const SkillParameter({
    required this.name,
    required this.description,
    required this.type,
    this.required = true,
    this.defaultValue,
    this.enumValues,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'required': required,
      if (defaultValue != null) 'default': defaultValue,
      if (enumValues != null) 'enum': enumValues,
    };
  }

  factory SkillParameter.fromJson(Map<String, dynamic> json) {
    return SkillParameter(
      name: json['name'] as String,
      description: json['description'] as String,
      type: SkillParameterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SkillParameterType.string,
      ),
      required: json['required'] as bool? ?? true,
      defaultValue: json['default'],
      enumValues: (json['enum'] as List<dynamic>?)?.toList(),
    );
  }
}

/// 技能结果
class SkillResult {
  final bool success;
  final dynamic data;
  final String? error;
  final Map<String, dynamic>? metadata;

  const SkillResult({
    required this.success,
    this.data,
    this.error,
    this.metadata,
  });

  factory SkillResult.success(dynamic data, {Map<String, dynamic>? metadata}) {
    return SkillResult(
      success: true,
      data: data,
      metadata: metadata,
    );
  }

  factory SkillResult.error(String error, {Map<String, dynamic>? metadata}) {
    return SkillResult(
      success: false,
      error: error,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// 技能定义
abstract class Skill {
  final String id;
  final String name;
  final String description;
  final SkillType type;
  final List<SkillParameter> parameters;
  final String? icon;
  final String? category;
  final List<String>? tags;
  final bool isBuiltin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// 专家技能专用字段
  final String? expertPrompt; // 专家系统提示词
  final String? emoji; // 专家 emoji 图标
  final String? domain; // 所属领域

  const Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.parameters = const [],
    this.icon,
    this.category,
    this.tags,
    this.isBuiltin = false,
    this.createdAt,
    this.updatedAt,
    this.expertPrompt,
    this.emoji,
    this.domain,
  });

  /// 执行技能
  Future<SkillResult> execute(Map<String, dynamic> params);

  /// 获取执行提示词
  String getExecutePrompt() {
    // 如果是专家类型，返回专家提示词
    if (type == SkillType.expert && expertPrompt != null) {
      return expertPrompt!;
    }

    final buffer = StringBuffer();
    buffer.writeln('## $name');
    buffer.writeln();
    buffer.writeln(description);
    if (parameters.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### 参数');
      for (final param in parameters) {
        buffer.write('- **${param.name}**');
        buffer.write(' (${param.type.name})');
        if (param.required) buffer.write(' (必需)');
        buffer.writeln(': ${param.description}');
        if (param.defaultValue != null) {
          buffer.writeln('  - 默认值: ${param.defaultValue}');
        }
        if (param.enumValues != null) {
          buffer.writeln('  - 可选值: ${param.enumValues!.join(', ')}');
        }
      }
    }
    return buffer.toString();
  }

  /// 验证参数
  Map<String, dynamic> validateParams(Map<String, dynamic> params) {
    final result = <String, dynamic>{};
    final errors = <String>[];

    for (final param in parameters) {
      final value = params[param.name];

      if (value == null) {
        if (param.required && param.defaultValue == null) {
          errors.add('缺少必需参数: ${param.name}');
        } else if (param.defaultValue != null) {
          result[param.name] = param.defaultValue;
        }
        continue;
      }

      // 类型检查
      if (!_isValidType(value, param.type)) {
        errors.add('参数 ${param.name} 类型错误，期望 ${param.type.name}');
        continue;
      }

      // 枚举值检查
      if (param.enumValues != null && !param.enumValues!.contains(value)) {
        errors.add(
            '参数 ${param.name} 值无效，可选值: ${param.enumValues!.join(', ')}');
        continue;
      }

      result[param.name] = value;
    }

    if (errors.isNotEmpty) {
      throw SkillValidationException(errors.join('; '));
    }

    return result;
  }

  bool _isValidType(dynamic value, SkillParameterType type) {
    switch (type) {
      case SkillParameterType.string:
        return value is String;
      case SkillParameterType.number:
        return value is num;
      case SkillParameterType.boolean:
        return value is bool;
      case SkillParameterType.array:
        return value is List;
      case SkillParameterType.object:
        return value is Map;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      'isBuiltin': isBuiltin,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (expertPrompt != null) 'expertPrompt': expertPrompt,
      if (emoji != null) 'emoji': emoji,
      if (domain != null) 'domain': domain,
    };
  }
}

/// 技能验证异常
class SkillValidationException implements Exception {
  final String message;

  SkillValidationException(this.message);

  @override
  String toString() => 'SkillValidationException: $message';
}

/// 技能未找到异常
class SkillNotFoundException implements Exception {
  final String skillId;

  SkillNotFoundException(this.skillId);

  @override
  String toString() => 'SkillNotFoundException: Skill "$skillId" not found';
}
