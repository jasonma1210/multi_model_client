/// 插件市场页面
/// 
/// 提供插件浏览、搜索、安装、更新、卸载功能
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/plugin_manifest.dart';
import '../../data/github_plugin_registry.dart';
import '../../data/plugin_installer.dart';

/// 插件市场页面
class PluginMarketPage extends ConsumerStatefulWidget {
  const PluginMarketPage({super.key});

  @override
  ConsumerState<PluginMarketPage> createState() => _PluginMarketPageState();
}

class _PluginMarketPageState extends ConsumerState<PluginMarketPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final GitHubPluginRegistry _registry = GitHubPluginRegistry();
  final PluginInstaller _installer = PluginInstaller();
  
  List<PluginManifest> _searchResults = [];
  List<PluginManifest> _featuredPlugins = [];
  List<InstalledPlugin> _installedPlugins = [];
  
  bool _isSearching = false;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeInstaller();
    _loadFeaturedPlugins();
    _loadInstalledPlugins();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeInstaller() async {
    await _installer.initialize();
  }
  
  Future<void> _loadFeaturedPlugins() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final plugins = await _registry.getFeaturedPlugins();
      setState(() {
        _featuredPlugins = plugins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载推荐插件失败: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadInstalledPlugins() async {
    final plugins = _installer.getInstalledPlugins();
    setState(() {
      _installedPlugins = plugins;
    });
  }
  
  Future<void> _searchPlugins(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _error = null;
    });
    
    try {
      final result = await _registry.searchPlugins(query: query);
      setState(() {
        _searchResults = result.plugins;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _error = '搜索失败: $e';
        _isSearching = false;
      });
    }
  }
  
  Future<void> _installPlugin(PluginManifest plugin) async {
    if (plugin.repository == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('插件无仓库地址，无法安装')),
      );
      return;
    }
    
    // 显示安装进度对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _InstallProgressDialog(
        installer: _installer,
        repoFullName: _extractRepoFullName(plugin.repository!),
      ),
    );
    
    await _loadInstalledPlugins();
  }
  
  Future<void> _uninstallPlugin(String pluginId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('卸载插件'),
        content: const Text('确定要卸载此插件吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('卸载'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await _installer.uninstallPlugin(pluginId);
        await _loadInstalledPlugins();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('插件已卸载')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('卸载失败: $e')),
          );
        }
      }
    }
  }
  
  String _extractRepoFullName(String repoUrl) {
    final uri = Uri.parse(repoUrl);
    final segments = uri.pathSegments;
    if (segments.length >= 2) {
      return '${segments[0]}/${segments[1]}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件市场'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '推荐', icon: Icon(Icons.star)),
            Tab(text: '搜索', icon: Icon(Icons.search)),
            Tab(text: '已安装', icon: Icon(Icons.extension)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeaturedTab(),
          _buildSearchTab(),
          _buildInstalledTab(),
        ],
      ),
    );
  }
  
  Widget _buildFeaturedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeaturedPlugins,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    
    if (_featuredPlugins.isEmpty) {
      return const Center(
        child: Text('暂无推荐插件'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _featuredPlugins.length,
      itemBuilder: (context, index) {
        final plugin = _featuredPlugins[index];
        return _PluginCard(
          plugin: plugin,
          isInstalled: _installer.isPluginInstalled(plugin.id),
          onInstall: () => _installPlugin(plugin),
          onTap: () => _showPluginDetails(plugin),
        );
      },
    );
  }
  
  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索插件...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults.clear();
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: _searchPlugins,
          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text('输入关键词搜索插件'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final plugin = _searchResults[index];
                        return _PluginCard(
                          plugin: plugin,
                          isInstalled: _installer.isPluginInstalled(plugin.id),
                          onInstall: () => _installPlugin(plugin),
                          onTap: () => _showPluginDetails(plugin),
                        );
                      },
                    ),
        ),
      ],
    );
  }
  
  Widget _buildInstalledTab() {
    if (_installedPlugins.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无已安装的插件'),
            SizedBox(height: 8),
            Text(
              '前往"推荐"或"搜索"标签页安装插件',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _installedPlugins.length,
      itemBuilder: (context, index) {
        final installed = _installedPlugins[index];
        return _InstalledPluginCard(
          installed: installed,
          onUninstall: () => _uninstallPlugin(installed.manifest.id),
          onToggle: (enabled) {
            if (enabled) {
              _installer.enablePlugin(installed.manifest.id);
            } else {
              _installer.disablePlugin(installed.manifest.id);
            }
            _loadInstalledPlugins();
          },
        );
      },
    );
  }
  
  void _showPluginDetails(PluginManifest plugin) {
    showDialog(
      context: context,
      builder: (context) => _PluginDetailsDialog(
        plugin: plugin,
        isInstalled: _installer.isPluginInstalled(plugin.id),
        onInstall: () {
          Navigator.pop(context);
          _installPlugin(plugin);
        },
      ),
    );
  }
}

/// 插件卡片组件
class _PluginCard extends StatelessWidget {
  final PluginManifest plugin;
  final bool isInstalled;
  final VoidCallback onInstall;
  final VoidCallback onTap;

  const _PluginCard({
    required this.plugin,
    required this.isInstalled,
    required this.onInstall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(plugin.category),
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plugin.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'v${plugin.version} · ${plugin.author}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isInstalled)
                    const Chip(
                      label: Text('已安装'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                    )
                  else
                    ElevatedButton(
                      onPressed: onInstall,
                      child: const Text('安装'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plugin.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (plugin.tags != null && plugin.tags!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: plugin.tags!.take(5).map((tag) {
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'web':
        return Icons.web;
      case 'data':
        return Icons.data_usage;
      case 'ai':
        return Icons.smart_toy;
      case 'media':
        return Icons.perm_media;
      case 'utility':
        return Icons.build;
      default:
        return Icons.extension;
    }
  }
}

/// 已安装插件卡片组件
class _InstalledPluginCard extends StatelessWidget {
  final InstalledPlugin installed;
  final VoidCallback onUninstall;
  final ValueChanged<bool> onToggle;

  const _InstalledPluginCard({
    required this.installed,
    required this.onUninstall,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = installed.status == PluginStatus.installed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.extension,
                  size: 32,
                  color: isEnabled ? Theme.of(context).primaryColor : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        installed.manifest.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? null : Colors.grey,
                        ),
                      ),
                      Text(
                        'v${installed.manifest.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onUninstall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              installed.manifest.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '安装时间: ${installed.installedAt.toString().substring(0, 19)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

/// 插件详情对话框
class _PluginDetailsDialog extends StatelessWidget {
  final PluginManifest plugin;
  final bool isInstalled;
  final VoidCallback onInstall;

  const _PluginDetailsDialog({
    required this.plugin,
    required this.isInstalled,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(plugin.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('版本: ${plugin.version}'),
            Text('作者: ${plugin.author}'),
            if (plugin.license != null) Text('许可证: ${plugin.license}'),
            const SizedBox(height: 16),
            Text(plugin.description),
            if (plugin.permissions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('所需权限:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...plugin.permissionDescriptions.map((p) => Text('• $p')),
            ],
            if (plugin.repository != null) ...[
              const SizedBox(height: 16),
              Text('仓库: ${plugin.repository}'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        if (!isInstalled)
          ElevatedButton(
            onPressed: onInstall,
            child: const Text('安装'),
          ),
      ],
    );
  }
}

/// 安装进度对话框
class _InstallProgressDialog extends StatefulWidget {
  final PluginInstaller installer;
  final String repoFullName;

  const _InstallProgressDialog({
    required this.installer,
    required this.repoFullName,
  });

  @override
  State<_InstallProgressDialog> createState() => _InstallProgressDialogState();
}

class _InstallProgressDialogState extends State<_InstallProgressDialog> {
  String _status = '准备安装...';
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startInstall();
  }

  Future<void> _startInstall() async {
    try {
      final subscription = widget.installer.progressStream.listen((progress) {
        if (mounted) {
          setState(() {
            _status = progress.message ?? '安装中...';
            _progress = progress.progress;
            _error = progress.error;
          });
        }
      });

      await widget.installer.installPlugin(widget.repoFullName);
      
      subscription.cancel();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('插件安装成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('安装插件'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ] else ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress),
          ],
        ],
      ),
      actions: [
        if (_error != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
      ],
    );
  }
}