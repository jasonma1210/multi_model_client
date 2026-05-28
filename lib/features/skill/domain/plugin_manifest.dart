/// 插件清单规范定义
/// 
/// 定义 LLM Studio 插件的标准格式，兼容 GitHub 插件库
/// 
/// 插件清单文件（plugin.json）示例：
/// ```json
/// {
///   "id": "com.example.web-scraper",
///   "name": "Web Scraper",
///   "version": "1.0.0",
///   "author": "Example Author",
///   "description": "A web scraping skill for extracting data from websites",
///   "repository": "https://github.com/example/web-scraper-plugin",
///   "entryPoint": "lib/main.dart",
///   "minAppVersion": "1.0.0",
///   "license": "MIT",
///   "icon": "assets/icon.png",
///   "category": "web",
///   "tags": ["scraping", "web", "data"],
///   "permissions": ["network", "file_read"],
///   "parameters": [
///     {
///       "name": "url",
///       "description": "Target URL to scrape",
///       "type": "string",
///       "required": true
///     }
///   ],
///   "dependencies": [],
///   "config": {
///     "timeout": 30000,
///     "maxRetries": 3
///   }
/// }
/// ```
library;

import 'dart:convert';
import 'skill.dart';

/// 插件权限类型
enum PluginPermission {
  /// 网络访问权限
  network,
  
  /// 文件读取权限
  fileRead,
  
  /// 文件写入权限
  fileWrite,
  
  /// 数据库访问权限
  database,
  
  /// 剪贴板访问权限
  clipboard,
  
  /// 通知权限
  notification,
  
  /// 系统命令执行权限
  systemCommand,
  
  /// 相机/麦克风权限
  media,
}

/// 插件状态
enum PluginStatus {
  /// 已安装
  installed,
  
  /// 已禁用
  disabled,
  
  /// 安装中
  installing,
  
  /// 更新中
  updating,
  
  /// 错误状态
  error,
  
  /// 待审核（安全沙箱检测中）
  pendingReview,
}

/// 插件清单定义
class PluginManifest {
  /// 插件唯一标识符（反向域名格式，如 com.example.plugin-name）
  final String id;
  
  /// 插件显示名称
  final String name;
  
  /// 插件版本号（语义化版本）
  final String version;
  
  /// 插件作者
  final String author;
  
  /// 插件描述
  final String description;
  
  /// GitHub 仓库地址
  final String? repository;
  
  /// 入口文件路径
  final String entryPoint;
  
  /// 最低应用版本要求
  final String? minAppVersion;
  
  /// 开源许可证
  final String? license;
  
  /// 插件图标路径
  final String? icon;
  
  /// 插件分类
  final String? category;
  
  /// 标签列表
  final List<String>? tags;
  
  /// 所需权限列表
  final List<PluginPermission> permissions;
  
  /// 技能参数定义
  final List<SkillParameter> parameters;
  
  /// 依赖的其他插件 ID
  final List<String> dependencies;
  
  /// 插件配置项
  final Map<String, dynamic>? config;
  
  /// 技能类型（工具类/专家类）
  final SkillType skillType;
  
  /// 专家提示词（仅专家类技能需要）
  final String? expertPrompt;
  
  /// 专家 Emoji 图标
  final String? emoji;
  
  /// 所属领域
  final String? domain;
  
  const PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    this.repository,
    required this.entryPoint,
    this.minAppVersion,
    this.license,
    this.icon,
    this.category,
    this.tags,
    this.permissions = const [],
    this.parameters = const [],
    this.dependencies = const [],
    this.config,
    this.skillType = SkillType.custom,
    this.expertPrompt,
    this.emoji,
    this.domain,
  });
  
  /// 从 JSON 解析
  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    return PluginManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      author: json['author'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      repository: json['repository'] as String?,
      entryPoint: json['entryPoint'] as String? ?? 'lib/main.dart',
      minAppVersion: json['minAppVersion'] as String?,
      license: json['license'] as String?,
      icon: json['icon'] as String?,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => PluginPermission.values.firstWhere(
                (p) => p.name == e,
                orElse: () => PluginPermission.network,
              ))
          .toList() ?? [],
      parameters: (json['parameters'] as List<dynamic>?)
          ?.map((e) => SkillParameter.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      dependencies: (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      config: json['config'] as Map<String, dynamic>?,
      skillType: _parseSkillType(json['skillType'] as String?),
      expertPrompt: json['expertPrompt'] as String?,
      emoji: json['emoji'] as String?,
      domain: json['domain'] as String?,
    );
  }
  
  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'author': author,
      'description': description,
      if (repository != null) 'repository': repository,
      'entryPoint': entryPoint,
      if (minAppVersion != null) 'minAppVersion': minAppVersion,
      if (license != null) 'license': license,
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      'permissions': permissions.map((e) => e.name).toList(),
      'parameters': parameters.map((e) => e.toJson()).toList(),
      'dependencies': dependencies,
      if (config != null) 'config': config,
      'skillType': skillType.name,
      if (expertPrompt != null) 'expertPrompt': expertPrompt,
      if (emoji != null) 'emoji': emoji,
      if (domain != null) 'domain': domain,
    };
  }
  
  /// 从 JSON 字符串解析
  factory PluginManifest.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return PluginManifest.fromJson(json);
  }
  
  /// 转换为 JSON 字符串
  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  /// 创建副本
  PluginManifest copyWith({
    String? id,
    String? name,
    String? version,
    String? author,
    String? description,
    String? repository,
    String? entryPoint,
    String? minAppVersion,
    String? license,
    String? icon,
    String? category,
    List<String>? tags,
    List<PluginPermission>? permissions,
    List<SkillParameter>? parameters,
    List<String>? dependencies,
    Map<String, dynamic>? config,
    SkillType? skillType,
    String? expertPrompt,
    String? emoji,
    String? domain,
  }) {
    return PluginManifest(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      author: author ?? this.author,
      description: description ?? this.description,
      repository: repository ?? this.repository,
      entryPoint: entryPoint ?? this.entryPoint,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      license: license ?? this.license,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      permissions: permissions ?? this.permissions,
      parameters: parameters ?? this.parameters,
      dependencies: dependencies ?? this.dependencies,
      config: config ?? this.config,
      skillType: skillType ?? this.skillType,
      expertPrompt: expertPrompt ?? this.expertPrompt,
      emoji: emoji ?? this.emoji,
      domain: domain ?? this.domain,
    );
  }
  
  /// 检查是否需要指定权限
  bool requiresPermission(PluginPermission permission) {
    return permissions.contains(permission);
  }
  
  /// 获取所有权限的描述
  List<String> get permissionDescriptions {
    return permissions.map((p) {
      switch (p) {
        case PluginPermission.network:
          return '网络访问';
        case PluginPermission.fileRead:
          return '文件读取';
        case PluginPermission.fileWrite:
          return '文件写入';
        case PluginPermission.database:
          return '数据库访问';
        case PluginPermission.clipboard:
          return '剪贴板访问';
        case PluginPermission.notification:
          return '通知权限';
        case PluginPermission.systemCommand:
          return '系统命令执行';
        case PluginPermission.media:
          return '相机/麦克风';
      }
    }).toList();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PluginManifest && other.id == id && other.version == version;
  }
  
  @override
  int get hashCode => id.hashCode ^ version.hashCode;
  
  @override
  String toString() {
    return 'PluginManifest(id: $id, name: $name, version: $version)';
  }
  
  /// 解析技能类型
  static SkillType _parseSkillType(String? type) {
    if (type == null) return SkillType.custom;
    return SkillType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => SkillType.custom,
    );
  }
}

/// 插件验证结果
class PluginValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const PluginValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  
  factory PluginValidationResult.valid({List<String> warnings = const []}) {
    return PluginValidationResult(isValid: true, warnings: warnings);
  }
  
  factory PluginValidationResult.invalid(List<String> errors, {List<String> warnings = const []}) {
    return PluginValidationResult(isValid: false, errors: errors, warnings: warnings);
  }
}

/// 插件清单验证器
class PluginManifestValidator {
  /// 验证插件清单
  static PluginValidationResult validate(PluginManifest manifest) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // ID 格式验证
    if (!RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$').hasMatch(manifest.id)) {
      errors.add('插件 ID 格式无效，应使用反向域名格式（如 com.example.plugin）');
    }
    
    // 版本号验证（语义化版本）
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(manifest.version)) {
      errors.add('版本号格式无效，应使用语义化版本（如 1.0.0）');
    }
    
    // 入口文件验证
    if (manifest.entryPoint.isEmpty) {
      errors.add('入口文件路径不能为空');
    }
    
    // 权限检查
    if (manifest.permissions.contains(PluginPermission.systemCommand)) {
      warnings.add('该插件请求系统命令执行权限，请确保来源可信');
    }
    
    // 依赖检查
    for (final dep in manifest.dependencies) {
      if (dep.isEmpty) {
        warnings.add('存在空的依赖项');
      }
    }
    
    // 参数验证
    for (final param in manifest.parameters) {
      if (param.name.isEmpty) {
        errors.add('参数名称不能为空');
      }
    }
    
    if (errors.isNotEmpty) {
      return PluginValidationResult.invalid(errors, warnings: warnings);
    }
    
    return PluginValidationResult.valid(warnings: warnings);
  }
}