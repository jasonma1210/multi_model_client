import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// MCP 服务器预设模板
/// 提供常用 MCP 服务器的配置模板
class McpServerTemplates {

  /// 获取所有可用的服务器模板
  static List<McpServerTemplate> getAllTemplates() {
    return [
      ...filesystemTemplates,
      ...databaseTemplates,
      ...communicationTemplates,
      ...productivityTemplates,
      ...developerToolsTemplates,
    ];
  }

  /// 按类别获取模板
  static List<McpServerTemplate> getTemplatesByCategory(String category) {
    return getAllTemplates().where((t) => t.category == category).toList();
  }

  /// 文件系统模板
  static final filesystemTemplates = [
    McpServerTemplate(
      id: 'filesystem-readonly',
      name: '文件系统（只读）',
      description: '以只读模式访问指定目录的文件',
      category: 'filesystem',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-filesystem', '{working_dir}'],
      env: {},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-filesystem',
    ),
    McpServerTemplate(
      id: 'filesystem-readwrite',
      name: '文件系统（读写）',
      description: '读写访问指定目录的文件',
      category: 'filesystem',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-filesystem', '{working_dir}'],
      env: {},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-filesystem',
    ),
  ];

  /// 数据库模板
  static final databaseTemplates = [
    McpServerTemplate(
      id: 'postgres',
      name: 'PostgreSQL',
      description: '连接 PostgreSQL 数据库进行查询和操作',
      category: 'database',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-postgres'],
      env: {'POSTGRES_CONNECTION_STRING': ''},
      requiredEnvVars: ['POSTGRES_CONNECTION_STRING'],
      documentation: 'https://github.com/modelcontextprotocol/server-postgres',
    ),
    McpServerTemplate(
      id: 'sqlite',
      name: 'SQLite',
      description: '连接 SQLite 数据库进行查询和操作',
      category: 'database',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-sqlite'],
      env: {'SQLITE_DB_PATH': ''},
      requiredEnvVars: ['SQLITE_DB_PATH'],
      documentation: 'https://github.com/modelcontextprotocol/server-sqlite',
    ),
    McpServerTemplate(
      id: 'mysql',
      name: 'MySQL',
      description: '连接 MySQL 数据库进行查询和操作',
      category: 'database',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-mysql'],
      env: {'MYSQL_CONNECTION_STRING': ''},
      requiredEnvVars: ['MYSQL_CONNECTION_STRING'],
      documentation: 'https://github.com/modelcontextprotocol/server-mysql',
    ),
  ];

  /// 通讯工具模板
  static final communicationTemplates = [
    McpServerTemplate(
      id: 'slack',
      name: 'Slack',
      description: '发送消息到 Slack 频道',
      category: 'communication',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-slack'],
      env: {'SLACK_TOKEN': ''},
      requiredEnvVars: ['SLACK_TOKEN'],
      documentation: 'https://github.com/modelcontextprotocol/server-slack',
    ),
    McpServerTemplate(
      id: 'discord',
      name: 'Discord',
      description: '发送消息到 Discord 频道',
      category: 'communication',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-discord'],
      env: {'DISCORD_BOT_TOKEN': ''},
      requiredEnvVars: ['DISCORD_BOT_TOKEN'],
      documentation: 'https://github.com/modelcontextprotocol/server-discord',
    ),
    McpServerTemplate(
      id: 'sentry',
      name: 'Sentry',
      description: '集成 Sentry 错误追踪',
      category: 'communication',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-sentry'],
      env: {'SENTRY_AUTH_TOKEN': '', 'SENTRY_ORG': ''},
      requiredEnvVars: ['SENTRY_AUTH_TOKEN', 'SENTRY_ORG'],
      documentation: 'https://github.com/modelcontextprotocol/server-sentry',
    ),
  ];

  /// 生产力工具模板
  static final productivityTemplates = [
    McpServerTemplate(
      id: 'github',
      name: 'GitHub',
      description: '管理 GitHub 仓库、Issue、PR 等',
      category: 'productivity',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-github'],
      env: {'GITHUB_PERSONAL_ACCESS_TOKEN': ''},
      requiredEnvVars: ['GITHUB_PERSONAL_ACCESS_TOKEN'],
      documentation: 'https://github.com/modelcontextprotocol/server-github',
    ),
    McpServerTemplate(
      id: 'gitlab',
      name: 'GitLab',
      description: '管理 GitLab 仓库、Issue、MR 等',
      category: 'productivity',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-gitlab'],
      env: {'GITLAB_TOKEN': '', 'GITLAB_URL': 'https://gitlab.com'},
      requiredEnvVars: ['GITLAB_TOKEN'],
      documentation: 'https://github.com/modelcontextprotocol/server-gitlab',
    ),
    McpServerTemplate(
      id: 'gdrive',
      name: 'Google Drive',
      description: '访问和管理 Google Drive 文件',
      category: 'productivity',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-gdrive'],
      env: {'GOOGLE_OAUTH_CLIENT_ID': '', 'GOOGLE_OAUTH_CLIENT_SECRET': ''},
      requiredEnvVars: ['GOOGLE_OAUTH_CLIENT_ID'],
      documentation: 'https://github.com/modelcontextprotocol/server-gdrive',
    ),
    McpServerTemplate(
      id: 'notion',
      name: 'Notion',
      description: '访问和管理 Notion 页面和数据库',
      category: 'productivity',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-notion'],
      env: {'NOTION_API_KEY': ''},
      requiredEnvVars: ['NOTION_API_KEY'],
      documentation: 'https://github.com/modelcontextprotocol/server-notion',
    ),
    McpServerTemplate(
      id: 'linear',
      name: 'Linear',
      description: '管理 Linear 项目和 Issue',
      category: 'productivity',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-linear'],
      env: {'LINEAR_API_KEY': ''},
      requiredEnvVars: ['LINEAR_API_KEY'],
      documentation: 'https://github.com/modelcontextprotocol/server-linear',
    ),
  ];

  /// 开发者工具模板
  static final developerToolsTemplates = [
    McpServerTemplate(
      id: 'git',
      name: 'Git',
      description: '执行 Git 操作（提交、推送、分支管理等）',
      category: 'developer',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-git'],
      env: {},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-git',
    ),
    McpServerTemplate(
      id: 'docker',
      name: 'Docker',
      description: '管理 Docker 容器和镜像',
      category: 'developer',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-docker'],
      env: {'DOCKER_HOST': ''},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-docker',
    ),
    McpServerTemplate(
      id: 'puppeteer',
      name: 'Puppeteer',
      description: '浏览器自动化和网页抓取',
      category: 'developer',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-puppeteer'],
      env: {},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-puppeteer',
    ),
    McpServerTemplate(
      id: 'search',
      name: 'DuckDuckGo 搜索',
      description: '使用 DuckDuckGo 进行网络搜索',
      category: 'developer',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-duckduckgo'],
      env: {},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-duckduckgo',
    ),
    McpServerTemplate(
      id: 'brave-search',
      name: 'Brave 搜索',
      description: '使用 Brave Search 进行网络搜索',
      category: 'developer',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-brave-search'],
      env: {'BRAVE_API_KEY': ''},
      requiredEnvVars: ['BRAVE_API_KEY'],
      documentation: 'https://github.com/modelcontextprotocol/server-brave-search',
    ),
    McpServerTemplate(
      id: 'fetch',
      name: 'Fetch',
      description: '获取网页内容',
      category: 'developer',
      type: 'stdio',
      command: 'npx',
      args: ['-y', '@modelcontextprotocol/server-fetch'],
      env: {},
      requiredEnvVars: [],
      documentation: 'https://github.com/modelcontextprotocol/server-fetch',
    ),
  ];

  /// 从模板创建服务器配置
  static Map<String, dynamic> createConfigFromTemplate(
    McpServerTemplate template, {
    String? workingDirectory,
    Map<String, String>? customEnv,
  }) {
    // 替换工作目录占位符
    final args = template.args.map((arg) {
      if (arg.contains('{working_dir}')) {
        return arg.replaceAll('{working_dir}', workingDirectory ?? '/tmp');
      }
      return arg;
    }).toList();

    // 合并环境变量
    final env = <String, String>{...template.env};
    if (customEnv != null) {
      env.addAll(customEnv);
    }

    return {
      'serverId': '${template.id}_${DateTime.now().millisecondsSinceEpoch}',
      'name': template.name,
      'type': template.type,
      'command': template.command,
      'args': jsonEncode(args),
      'env': jsonEncode(env),
      'isEnabled': false,
      'isAutoStart': false,
    };
  }
}

/// MCP 服务器模板
class McpServerTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String type;
  final String command;
  final List<String> args;
  final Map<String, String> env;
  final List<String> requiredEnvVars;
  final String documentation;

  const McpServerTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.type,
    required this.command,
    required this.args,
    required this.env,
    required this.requiredEnvVars,
    required this.documentation,
  });

  /// 获取分类显示名称
  String get categoryDisplayName {
    switch (category) {
      case 'filesystem':
        return '文件系统';
      case 'database':
        return '数据库';
      case 'communication':
        return '通讯工具';
      case 'productivity':
        return '生产力工具';
      case 'developer':
        return '开发者工具';
      default:
        return category;
    }
  }

  /// 获取分类图标
  String get categoryIcon {
    switch (category) {
      case 'filesystem':
        return '📁';
      case 'database':
        return '🗄️';
      case 'communication':
        return '💬';
      case 'productivity':
        return '📊';
      case 'developer':
        return '🛠️';
      default:
        return '🔧';
    }
  }
}

/// MCP 服务器分类
enum McpServerCategory {
  filesystem('文件系统', '📁'),
  database('数据库', '🗄️'),
  communication('通讯工具', '💬'),
  productivity('生产力工具', '📊'),
  developer('开发者工具', '🛠️');

  final String displayName;
  final String icon;

  const McpServerCategory(this.displayName, this.icon);
}

// Riverpod Providers

// MCP 服务器模板列表 Provider
final mcpServerTemplatesProvider = Provider<List<McpServerTemplate>>((ref) {
  return McpServerTemplates.getAllTemplates();
});

// 按类别筛选的模板 Provider
final mcpServerTemplatesByCategoryProvider = Provider.family<List<McpServerTemplate>, String>((ref, category) {
  return McpServerTemplates.getTemplatesByCategory(category);
});

// 所有类别 Provider
final mcpServerCategoriesProvider = Provider<List<McpServerCategory>>((ref) {
  return McpServerCategory.values;
});