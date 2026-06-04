# Phase 1：Skills 插件系统 + GitHub 集成 实现说明

## 实现概述

Phase 1 已完成核心功能开发，包括：

1. **插件清单规范** - 定义了标准的插件格式和验证逻辑
2. **GitHub 插件仓库服务** - 支持从 GitHub 搜索和获取插件
3. **插件安装器** - 支持插件的下载、验证、安装、更新和卸载
4. **插件沙箱执行器** - 提供隔离的执行环境和权限控制
5. **SkillDispatcher 增强** - 支持插件管理和事件通知
6. **数据库扩展** - 新增 PluginRegistry 表
7. **插件市场 UI** - 提供插件浏览、搜索、安装界面

## 文件结构

```
lib/features/skill/
├── domain/
│   ├── plugin_manifest.dart      # 插件清单规范定义
│   ├── plugin_sandbox.dart       # 插件沙箱执行器
│   └── skill_dispatcher.dart     # 增强的技能调度器
├── data/
│   ├── github_plugin_registry.dart  # GitHub 插件仓库服务
│   └── plugin_installer.dart        # 插件安装器
└── presentation/
    └── pages/
        └── plugin_market_page.dart   # 插件市场页面
```

## 使用步骤

### 1. 生成数据库代码

由于新增了 PluginRegistry 表，需要运行 build_runner 生成代码：

```bash
cd multi_model_client
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 使用插件市场

在应用中导航到插件市场页面：

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const PluginMarketPage()),
);
```

### 3. 搜索和安装插件

1. 在"推荐"标签页浏览官方推荐插件
2. 在"搜索"标签页搜索 GitHub 上的插件
3. 点击"安装"按钮安装插件
4. 在"已安装"标签页管理已安装的插件

### 4. 使用插件技能

安装的插件会自动注册为技能，可以通过以下方式使用：

```dart
final dispatcher = SkillDispatcher();
final result = await dispatcher.dispatch('com.example.plugin-id', {
  'param1': 'value1',
  'param2': 'value2',
});
```

## 插件开发规范

### plugin.json 示例

```json
{
  "id": "com.example.web-scraper",
  "name": "Web Scraper",
  "version": "1.0.0",
  "author": "Example Author",
  "description": "A web scraping skill for extracting data from websites",
  "repository": "https://github.com/example/web-scraper-plugin",
  "entryPoint": "lib/main.dart",
  "minAppVersion": "1.0.0",
  "license": "MIT",
  "icon": "assets/icon.png",
  "category": "web",
  "tags": ["scraping", "web", "data"],
  "permissions": ["network", "file_read"],
  "parameters": [
    {
      "name": "url",
      "description": "Target URL to scrape",
      "type": "string",
      "required": true
    }
  ],
  "dependencies": [],
  "config": {
    "timeout": 30000,
    "maxRetries": 3
  }
}
```

### 权限类型

- `network` - 网络访问
- `file_read` - 文件读取
- `file_write` - 文件写入
- `database` - 数据库访问
- `clipboard` - 剪贴板访问
- `notification` - 通知权限
- `system_command` - 系统命令执行
- `media` - 相机/麦克风

### 技能类型

- `native` - 内置工具技能
- `expert` - 专家角色技能
- `mcp` - MCP 工具包装
- `custom` - 自定义技能

## 安全机制

### 沙箱执行

插件在沙箱中执行，具有以下限制：

1. **权限控制** - 根据 plugin.json 中声明的权限进行访问控制
2. **资源限制** - 限制执行时间和内存使用
3. **域名白名单** - 网络请求只能访问声明的域名
4. **文件路径白名单** - 文件访问只能访问声明的路径
5. **安全审计日志** - 记录所有安全相关操作

### 权限检查

```dart
final sandbox = PluginSandbox(config: SandboxConfig.fromManifest(manifest));

// 检查文件访问权限
if (sandbox.permissionChecker.checkFileAccess('/path/to/file')) {
  // 允许访问
}

// 检查网络访问权限
if (sandbox.permissionChecker.checkNetworkAccess('https://example.com')) {
  // 允许访问
}
```

## API 参考

### PluginManifest

插件清单定义类，包含插件的所有元数据。

### GitHubPluginRegistry

GitHub 插件仓库服务，提供以下方法：

- `searchPlugins()` - 搜索插件
- `getFeaturedPlugins()` - 获取推荐插件
- `getPlugin()` - 获取指定插件
- `getPluginVersions()` - 获取插件版本列表

### PluginInstaller

插件安装器，提供以下方法：

- `installPlugin()` - 安装插件
- `uninstallPlugin()` - 卸载插件
- `updatePlugin()` - 更新插件
- `enablePlugin()` / `disablePlugin()` - 启用/禁用插件
- `checkForUpdates()` - 检查更新

### SkillDispatcher

技能调度器，提供以下方法：

- `registerSkill()` - 注册技能
- `unregisterSkill()` - 注销技能
- `dispatch()` - 调度执行技能
- `enableSkill()` / `disableSkill()` - 启用/禁用技能
- `getPluginSkills()` - 获取所有插件技能
- `getBuiltinSkills()` - 获取所有内置技能

## 后续计划

Phase 1 完成后，将继续开发：

- **Phase 2：多会话隔离机制** - 确保不同会话间上下文和资源的独立
- **Phase 3：任务流编排引擎** - 构建复杂任务流编排能力

## 注意事项

1. **网络依赖** - 搜索和下载插件需要网络连接
2. **GitHub API 限制** - 未认证请求有速率限制，建议配置 GitHub Token
3. **插件安全** - 只安装来自可信来源的插件
4. **存储空间** - 插件会占用本地存储空间
5. **版本兼容性** - 检查插件的最低应用版本要求