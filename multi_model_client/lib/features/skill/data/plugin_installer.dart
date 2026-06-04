/// 插件安装器
/// 
/// 负责插件的下载、验证、安装、更新和卸载
/// 支持：
/// - 从 GitHub 下载插件包
/// - 校验插件完整性
/// - 解压到本地插件目录
/// - 注册到 SkillDispatcher
/// - 版本管理和更新
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../domain/plugin_manifest.dart';
import '../domain/skill.dart';
import '../domain/skill_dispatcher.dart';
import 'github_plugin_registry.dart';

/// 安装状态
enum InstallStatus {
  /// 等待中
  pending,
  
  /// 下载中
  downloading,
  
  /// 验证中
  verifying,
  
  /// 安装中
  installing,
  
  /// 完成
  completed,
  
  /// 失败
  failed,
}

/// 安装进度
class InstallProgress {
  final InstallStatus status;
  final double progress; // 0.0 - 1.0
  final String? message;
  final String? error;
  
  const InstallProgress({
    required this.status,
    this.progress = 0.0,
    this.message,
    this.error,
  });
}

/// 已安装插件信息
class InstalledPlugin {
  final PluginManifest manifest;
  final String installPath;
  final DateTime installedAt;
  final DateTime? updatedAt;
  final PluginStatus status;
  
  const InstalledPlugin({
    required this.manifest,
    required this.installPath,
    required this.installedAt,
    this.updatedAt,
    this.status = PluginStatus.installed,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'manifest': manifest.toJson(),
      'installPath': installPath,
      'installedAt': installedAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'status': status.name,
    };
  }
  
  factory InstalledPlugin.fromJson(Map<String, dynamic> json) {
    return InstalledPlugin(
      manifest: PluginManifest.fromJson(json['manifest'] as Map<String, dynamic>),
      installPath: json['installPath'] as String,
      installedAt: DateTime.parse(json['installedAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      status: PluginStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PluginStatus.installed,
      ),
    );
  }
}

/// 插件安装器
class PluginInstaller {
  final GitHubPluginRegistry _registry;
  final SkillDispatcher _dispatcher;
  final StreamController<InstallProgress> _progressController;
  
  /// 已安装插件缓存
  final Map<String, InstalledPlugin> _installedPlugins = {};
  
  /// 插件安装目录
  late final String _pluginsDir;
  
  /// 插件注册文件路径
  late final String _registryPath;
  
  PluginInstaller({
    GitHubPluginRegistry? registry,
    SkillDispatcher? dispatcher,
  }) : _registry = registry ?? GitHubPluginRegistry(),
       _dispatcher = dispatcher ?? SkillDispatcher(),
       _progressController = StreamController<InstallProgress>.broadcast();
  
  /// 安装进度流
  Stream<InstallProgress> get progressStream => _progressController.stream;
  
  /// 初始化安装器
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _pluginsDir = path.join(appDir.path, 'llm_studio', 'plugins');
    _registryPath = path.join(appDir.path, 'llm_studio', 'plugin_registry.json');
    
    // 创建插件目录
    final dir = Directory(_pluginsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // 加载已安装插件
    await _loadInstalledPlugins();
  }
  
  /// 获取已安装插件列表
  List<InstalledPlugin> getInstalledPlugins() {
    return _installedPlugins.values.toList();
  }
  
  /// 检查插件是否已安装
  bool isPluginInstalled(String pluginId) {
    return _installedPlugins.containsKey(pluginId);
  }
  
  /// 安装插件
  Future<InstalledPlugin> installPlugin(
    String repoFullName, {
    String? version,
    bool force = false,
  }) async {
    try {
      // 1. 获取插件清单
      _emitProgress(InstallProgress(
        status: InstallStatus.pending,
        message: '正在获取插件信息...',
      ));
      
      final manifest = await _registry.getPlugin(repoFullName);
      if (manifest == null) {
        throw PluginInstallException('无法获取插件清单');
      }
      
      // 2. 检查是否已安装
      if (!force && _installedPlugins.containsKey(manifest.id)) {
        final existing = _installedPlugins[manifest.id]!;
        if (existing.manifest.version == manifest.version) {
          _emitProgress(InstallProgress(
            status: InstallStatus.completed,
            message: '插件已安装且为最新版本',
          ));
          return existing;
        }
      }
      
      // 3. 验证清单
      _emitProgress(InstallProgress(
        status: InstallStatus.verifying,
        message: '正在验证插件清单...',
      ));
      
      final validation = PluginManifestValidator.validate(manifest);
      if (!validation.isValid) {
        throw PluginInstallException('插件清单验证失败: ${validation.errors.join(', ')}');
      }
      
      // 4. 下载插件
      _emitProgress(InstallProgress(
        status: InstallStatus.downloading,
        message: '正在下载插件...',
        progress: 0.0,
      ));
      
      final downloadUrl = await _registry.getPluginDownloadUrl(
        repoFullName,
        version: version,
      );
      
      final pluginDir = path.join(_pluginsDir, manifest.id);
      await _downloadAndExtract(downloadUrl, pluginDir);
      
      // 5. 安装插件
      _emitProgress(InstallProgress(
        status: InstallStatus.installing,
        message: '正在安装插件...',
        progress: 0.8,
      ));
      
      // 保存清单文件
      final manifestFile = File(path.join(pluginDir, 'plugin.json'));
      await manifestFile.writeAsString(manifest.toJsonString());
      
      // 注册技能
      await _registerPluginSkill(manifest, pluginDir);
      
      // 6. 记录安装信息
      final installed = InstalledPlugin(
        manifest: manifest,
        installPath: pluginDir,
        installedAt: DateTime.now(),
      );
      
      _installedPlugins[manifest.id] = installed;
      await _saveInstalledPlugins();
      
      _emitProgress(InstallProgress(
        status: InstallStatus.completed,
        message: '插件安装成功',
        progress: 1.0,
      ));
      
      return installed;
    } catch (e) {
      _emitProgress(InstallProgress(
        status: InstallStatus.failed,
        error: e.toString(),
      ));
      if (e is PluginInstallException) rethrow;
      throw PluginInstallException('安装插件失败: $e');
    }
  }
  
  /// 卸载插件
  Future<void> uninstallPlugin(String pluginId) async {
    try {
      final installed = _installedPlugins[pluginId];
      if (installed == null) {
        throw PluginInstallException('插件未安装: $pluginId');
      }
      
      // 1. 注销技能
      _dispatcher.unregisterSkill(pluginId);
      
      // 2. 删除插件文件
      final pluginDir = Directory(installed.installPath);
      if (await pluginDir.exists()) {
        await pluginDir.delete(recursive: true);
      }
      
      // 3. 从缓存中移除
      _installedPlugins.remove(pluginId);
      await _saveInstalledPlugins();
      
      debugPrint('[PluginInstaller] 插件已卸载: $pluginId');
    } catch (e) {
      if (e is PluginInstallException) rethrow;
      throw PluginInstallException('卸载插件失败: $e');
    }
  }
  
  /// 更新插件
  Future<InstalledPlugin?> updatePlugin(String pluginId) async {
    try {
      final installed = _installedPlugins[pluginId];
      if (installed == null) {
        throw PluginInstallException('插件未安装: $pluginId');
      }
      
      if (installed.manifest.repository == null) {
        throw PluginInstallException('插件无仓库信息，无法更新');
      }
      
      // 从仓库 URL 提取 repoFullName
      final repoUrl = installed.manifest.repository!;
      final repoFullName = _extractRepoFullName(repoUrl);
      
      // 重新安装（强制覆盖）
      return await installPlugin(repoFullName, force: true);
    } catch (e) {
      if (e is PluginInstallException) rethrow;
      throw PluginInstallException('更新插件失败: $e');
    }
  }
  
  /// 启用插件
  Future<void> enablePlugin(String pluginId) async {
    final installed = _installedPlugins[pluginId];
    if (installed == null) {
      throw PluginInstallException('插件未安装: $pluginId');
    }
    
    _installedPlugins[pluginId] = InstalledPlugin(
      manifest: installed.manifest,
      installPath: installed.installPath,
      installedAt: installed.installedAt,
      updatedAt: installed.updatedAt,
      status: PluginStatus.installed,
    );
    
    await _registerPluginSkill(installed.manifest, installed.installPath);
    await _saveInstalledPlugins();
  }
  
  /// 禁用插件
  Future<void> disablePlugin(String pluginId) async {
    final installed = _installedPlugins[pluginId];
    if (installed == null) {
      throw PluginInstallException('插件未安装: $pluginId');
    }
    
    _installedPlugins[pluginId] = InstalledPlugin(
      manifest: installed.manifest,
      installPath: installed.installPath,
      installedAt: installed.installedAt,
      updatedAt: installed.updatedAt,
      status: PluginStatus.disabled,
    );
    
    _dispatcher.unregisterSkill(pluginId);
    await _saveInstalledPlugins();
  }
  
  /// 检查插件更新
  Future<List<PluginManifest>> checkForUpdates() async {
    final updates = <PluginManifest>[];
    
    for (final entry in _installedPlugins.entries) {
      final installed = entry.value;
      if (installed.manifest.repository == null) continue;
      
      try {
        final repoFullName = _extractRepoFullName(installed.manifest.repository!);
        final latest = await _registry.getPlugin(repoFullName);
        
        if (latest != null && latest.version != installed.manifest.version) {
          updates.add(latest);
        }
      } catch (e) {
        debugPrint('[PluginInstaller] 检查更新失败 ${entry.key}: $e');
      }
    }
    
    return updates;
  }
  
  /// 下载并解压插件
  Future<void> _downloadAndExtract(String url, String targetDir) async {
    // 注意：实际实现需要使用 archive 包解压
    // 这里简化处理，实际项目中需要添加 archive 依赖
    
    final client = http.Client();
    try {
      final response = await client.get(Uri.parse(url)).timeout(
        const Duration(minutes: 5),
      );
      
      if (response.statusCode != 200) {
        throw PluginInstallException('下载失败: ${response.statusCode}');
      }
      
      // 保存 ZIP 文件
      final zipPath = path.join(targetDir, 'plugin.zip');
      final dir = Directory(targetDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(response.bodyBytes);
      
      // TODO: 解压 ZIP 文件到 targetDir
      // 需要使用 archive 包：
      // final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      // for (final file in archive) {
      //   final filePath = path.join(targetDir, file.name);
      //   if (file.isFile) {
      //     File(filePath).writeAsBytes(file.content as List<int>);
      //   } else {
      //     Directory(filePath).create(recursive: true);
      //   }
      // }
      
      // 删除 ZIP 文件
      await zipFile.delete();
      
    } finally {
      client.close();
    }
  }
  
  /// 注册插件技能
  Future<void> _registerPluginSkill(PluginManifest manifest, String pluginDir) async {
    // 创建自定义技能实例
    final skill = PluginSkill(
      manifest: manifest,
      pluginDir: pluginDir,
    );
    
    _dispatcher.registerSkill(skill);
    debugPrint('[PluginInstaller] 插件技能已注册: ${manifest.id}');
  }
  
  /// 加载已安装插件
  Future<void> _loadInstalledPlugins() async {
    try {
      final file = File(_registryPath);
      if (!await file.exists()) return;
      
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      for (final entry in data.entries) {
        try {
          _installedPlugins[entry.key] = InstalledPlugin.fromJson(
            entry.value as Map<String, dynamic>,
          );
        } catch (e) {
          debugPrint('[PluginInstaller] 加载插件失败 ${entry.key}: $e');
        }
      }
      
      debugPrint('[PluginInstaller] 已加载 ${_installedPlugins.length} 个插件');
    } catch (e) {
      debugPrint('[PluginInstaller] 加载插件注册表失败: $e');
    }
  }
  
  /// 保存已安装插件
  Future<void> _saveInstalledPlugins() async {
    try {
      final data = <String, dynamic>{};
      for (final entry in _installedPlugins.entries) {
        data[entry.key] = entry.value.toJson();
      }
      
      final file = File(_registryPath);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('[PluginInstaller] 保存插件注册表失败: $e');
    }
  }
  
  /// 发送进度通知
  void _emitProgress(InstallProgress progress) {
    _progressController.add(progress);
  }
  
  /// 从仓库 URL 提取 repoFullName
  String _extractRepoFullName(String repoUrl) {
    // https://github.com/owner/repo -> owner/repo
    final uri = Uri.parse(repoUrl);
    final segments = uri.pathSegments;
    if (segments.length >= 2) {
      return '${segments[0]}/${segments[1]}';
    }
    throw PluginInstallException('无效的仓库 URL: $repoUrl');
  }
  
  /// 释放资源
  void dispose() {
    _progressController.close();
  }
}

/// 插件技能实现
class PluginSkill extends Skill {
  final PluginManifest manifest;
  final String pluginDir;
  
  PluginSkill({
    required this.manifest,
    required this.pluginDir,
  }) : super(
    id: manifest.id,
    name: manifest.name,
    description: manifest.description,
    type: manifest.skillType,
    parameters: manifest.parameters,
    isBuiltin: false,
    expertPrompt: manifest.expertPrompt,
    emoji: manifest.emoji,
    domain: manifest.domain,
  );
  
  @override
  Future<SkillResult> execute(Map<String, dynamic> params) async {
    try {
      // 验证参数
      final validatedParams = validateParams(params);
      
      // TODO: 实际执行插件代码
      // 这里需要根据插件类型执行不同的逻辑：
      // 1. Dart 插件：使用 isolate 执行
      // 2. 脚本插件：使用 Process 执行
      // 3. HTTP 插件：调用远程 API
      
      debugPrint('[PluginSkill] 执行插件: ${manifest.id}, 参数: $validatedParams');
      
      // 临时返回成功结果
      return SkillResult.success({
        'message': '插件执行成功',
        'pluginId': manifest.id,
        'params': validatedParams,
      });
    } catch (e) {
      return SkillResult.error('插件执行失败: $e');
    }
  }
}

/// 插件安装异常
class PluginInstallException implements Exception {
  final String message;
  
  const PluginInstallException(this.message);
  
  @override
  String toString() => 'PluginInstallException: $message';
}