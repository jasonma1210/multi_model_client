// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/llama_cpp_update_service.dart';
import '../../../../core/engines/local_ffi_engine.dart';
import 'package:mj_nexus/generated/app_localizations.dart';

// 备份服务 Provider
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = '0.1.0-beta';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (_) {
      // Use default version if package_info fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true, // 允许返回导航
      onPopInvokedWithResult: (didPop, result) {
        // 不需要额外处理，右滑返回行为与返回按钮一致
        // 如果 Navigator.canPop() = true，会正常返回上一页
        // 如果 Navigator.canPop() = false，go_router 会自动处理
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: Text(
            l10n.settings,
            style: theme.textTheme.headlineMedium,
          ),
        ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // Appearance Section
          _SettingsSection(
            title: l10n.appearance,
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: l10n.theme,
                subtitle: _getThemeName(themeMode, l10n),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, ref, l10n),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: getLanguageName(locale),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context, ref, l10n),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Models Section
          _SettingsSection(
            title: l10n.models,
            children: [
              _SettingsTile(
                icon: Icons.smart_toy_outlined,
                title: l10n.modelManagement,
                subtitle: l10n.configureModels,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/models'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // AI Features Section
          _SettingsSection(
            title: l10n.aiFeatures,
            children: [
              _SettingsTile(
                icon: Icons.psychology_outlined,
                title: l10n.memorySettings,
                subtitle: l10n.configureMemory,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/memory'),
              ),
              _SettingsTile(
                icon: Icons.library_books_outlined,
                title: l10n.knowledgeBase,
                subtitle: l10n.manageKnowledgeBases,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/knowledge'),
              ),
              _SettingsTile(
                icon: Icons.record_voice_over_outlined,
                title: l10n.voiceSettings,
                subtitle: l10n.textToSpeechConfig,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/voice'),
              ),
              _SettingsTile(
                icon: Icons.extension_outlined,
                title: l10n.pluginManagement,
                subtitle: l10n.pluginManagementDesc,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/plugins'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Skills Section
          _SettingsSection(
            title: l10n.skills,
            children: [
              _SettingsTile(
                icon: Icons.extension_outlined,
                title: l10n.skillCenter,
                subtitle: l10n.skillCenterDesc,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/skills'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Data Section
          _SettingsSection(
            title: l10n.dataStorage,
            children: [
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: l10n.storage,
                subtitle: l10n.manageDataCache,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showStorageInfo(context, l10n),
              ),
              _SettingsTile(
                icon: Icons.folder_outlined,
                title: l10n.storagePathConfig,
                subtitle: l10n.storagePathConfigDesc,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/storage'),
              ),
              _SettingsTile(
                icon: Icons.backup_outlined,
                title: l10n.backupExport,
                subtitle: l10n.exportBackupData,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showBackupOptions(context, l10n),
              ),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: l10n.logManagement,
                subtitle: l10n.logManagementDesc,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/settings/logs'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Help & Guide Section
          _SettingsSection(
            title: l10n.helpGuide,
            children: [
              _SettingsTile(
                icon: Icons.menu_book_outlined,
                title: l10n.userManual,
                subtitle: l10n.userManualDesc,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/manual'),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // About Section
          _SettingsSection(
            title: l10n.about,
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.version,
                subtitle: _appVersion,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingS,
                    vertical: AppTheme.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    l10n.latest,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.code_outlined,
                title: l10n.openSourceLicenses,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: l10n.appTitle,
                    applicationVersion: _appVersion,
                    applicationIcon: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/mj_nexus_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // 如果图片加载失败，显示默认图标
                          return Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: const Icon(
                              Icons.hub_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.warning_amber_outlined,
                title: '免责声明',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Text('免责声明'),
                        ],
                      ),
                      content: const SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '本应用仅供学习和研究使用。',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 12),
                            Text('1. AI 生成内容不代表本应用立场，本应用不对其准确性、完整性或适用性做任何保证。'),
                            SizedBox(height: 8),
                            Text('2. 用户在使用 AI 功能时，应自行判断内容的可信度，并承担使用风险。'),
                            SizedBox(height: 8),
                            Text('3. 本应用不收集用户对话数据，所有数据仅存储在本地设备。'),
                            SizedBox(height: 8),
                            Text('4. 请遵守当地法律法规，合理使用 AI 技术。'),
                            SizedBox(height: 12),
                            Text(
                              '使用本应用即表示您同意上述条款。',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('我已阅读'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
      ),
    );
  }

  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: l10n.light,
              icon: Icons.light_mode,
              isSelected: ref.read(themeProvider) == ThemeMode.light,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: l10n.dark,
              icon: Icons.dark_mode,
              isSelected: ref.read(themeProvider) == ThemeMode.dark,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: l10n.system,
              icon: Icons.settings_suggest,
              isSelected: ref.read(themeProvider) == ThemeMode.system,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              title: 'English',
              subtitle: 'English',
              isSelected: ref.read(localeProvider).languageCode == 'en',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en', 'US'));
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              title: '中文',
              subtitle: 'Chinese',
              isSelected: ref.read(localeProvider).languageCode == 'zh',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('zh', 'CN'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: AppTheme.spacingS),
            Text(l10n.comingSoon),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showStorageInfo(BuildContext context, AppLocalizations l10n) async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = await getTemporaryDirectory();

    int dbSize = 0;
    int cacheSize = 0;
    int modelsSize = 0;

    // Calculate database size
    final dbFile = File('${appDir.path}/app_database.sqlite');
    if (await dbFile.exists()) {
      dbSize = await dbFile.length();
    }

    // Calculate cache size
    if (await cacheDir.exists()) {
      cacheSize = await _calculateDirectorySize(cacheDir);
    }

    // Calculate models size
    final modelsDir = Directory('${appDir.path}/models');
    if (await modelsDir.exists()) {
      modelsSize = await _calculateDirectorySize(modelsDir);
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.storageInfo),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StorageItem(
              icon: Icons.storage,
              label: l10n.database,
              size: dbSize,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _StorageItem(
              icon: Icons.cached,
              label: l10n.cache,
              size: cacheSize,
            ),
            const SizedBox(height: AppTheme.spacingS),
            _StorageItem(
              icon: Icons.smart_toy,
              label: l10n.models,
              size: modelsSize,
            ),
            const Divider(height: AppTheme.spacingL),
            _StorageItem(
              icon: Icons.folder,
              label: l10n.total,
              size: dbSize + cacheSize + modelsSize,
              isTotal: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);

              try {
                if (await cacheDir.exists()) {
                  await cacheDir.delete(recursive: true);
                  await cacheDir.create();
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.cacheCleared),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(milliseconds: 1500),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.clearCacheFailed}: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(milliseconds: 1500),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.clearCache),
          ),
        ],
      ),
    );
  }

  Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('[settings_page] Error: $e');
    }
    return size;
  }

  void _showBackupOptions(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusL),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.upload_file,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(l10n.exportDatabase),
                subtitle: Text(l10n.exportAllData),
                onTap: () {
                  Navigator.pop(context);
                  _exportDatabase(context, l10n);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(l10n.importDatabase),
                subtitle: Text(l10n.importFromBackup),
                onTap: () {
                  Navigator.pop(context);
                  _importDatabase(context, l10n);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Icon(
                    Icons.share,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(l10n.exportSessions),
                subtitle: Text(l10n.exportSpecificSessions),
                onTap: () {
                  Navigator.pop(context);
                  _exportSessions(context, l10n);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportDatabase(BuildContext context, AppLocalizations l10n) async {
    try {
      final backupService = ref.read(backupServiceProvider);
      
      // 显示加载中
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('正在导出数据...'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 30),
          ),
        );
      }

      final filePath = await backupService.exportAllData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // 询问是否分享
        final shouldShare = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('导出成功'),
            content: Text('数据已保存到:\n$filePath'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('关闭'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('分享'),
              ),
            ],
          ),
        );

        if (shouldShare == true) {
          await backupService.shareBackup(filePath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void _importDatabase(BuildContext context, AppLocalizations l10n) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: '选择备份文件',
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      // 选择导入模式
      final importMode = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('导入模式'),
          content: const Text('请选择数据合并方式:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'merge'),
              child: const Text('合并（推荐）'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(ctx, 'replace'),
              child: const Text('覆盖（危险）'),
            ),
          ],
        ),
      );

      if (importMode == null) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('正在导入数据...'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 30),
          ),
        );
      }

      final backupService = ref.read(backupServiceProvider);
      await backupService.importData(filePath, merge: importMode == 'merge');

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入成功！'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void _exportSessions(BuildContext context, AppLocalizations l10n) {
    // 导出单个会话功能已在会话详情页实现
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请在会话详情页点击导出按钮'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  /// 显示 Ollama 配置对话框
  void _showOllamaSettingsDialog(BuildContext context) {
    final settingsService = ref.read(settingsServiceProvider);
    final baseUrlController = TextEditingController(
      text: settingsService.getOllamaBaseUrl(),
    );
    final defaultModelController = TextEditingController(
      text: settingsService.getOllamaDefaultModel(),
    );
    final apiKeyController = TextEditingController(
      text: settingsService.getOllamaApiKey(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_outlined, size: 24),
            SizedBox(width: 10),
            Text('Ollama 配置'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: baseUrlController,
              decoration: const InputDecoration(
                labelText: '服务地址',
                hintText: 'http://localhost:11434',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: defaultModelController,
              decoration: const InputDecoration(
                labelText: '默认模型',
                hintText: 'llama3.2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key（可选）',
                hintText: '如需认证请输入',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加 Ollama 远程模型时将使用此配置',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              await settingsService.setOllamaBaseUrl(baseUrlController.text);
              await settingsService.setOllamaDefaultModel(defaultModelController.text);
              await settingsService.setOllamaApiKey(apiKeyController.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ollama 配置已保存'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(milliseconds: 1500),
                  ),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 检查 llama.cpp 更新
  Future<void> _checkLlamaCppUpdate(BuildContext context, AppLocalizations l10n) async {
    // 显示检查中的对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('正在检查 llama.cpp 更新...'),
          ],
        ),
      ),
    );

    try {
      // 检查更新
      final remoteVersion = await LlamaCppUpdateService.instance.checkForUpdate();
      final localVersion = await LlamaCppUpdateService.instance.getLocalVersion();

      if (!context.mounted) return;
      Navigator.pop(context); // 关闭加载对话框

      if (remoteVersion == null) {
        _showUpdateDialog(context, '检查更新失败', '无法获取最新版本信息，请检查网络连接。', null);
        return;
      }

      // 判断是否需要更新
      final needsUpdate = LlamaCppUpdateService.instance.shouldUpdate(
        localVersion,
        remoteVersion,
        threshold: 50,
      );

      if (!needsUpdate) {
        _showUpdateDialog(
          context,
          '已是最新版本',
          '当前版本: ${localVersion ?? "未知"}\n最新版本: ${remoteVersion.tagName}',
          null,
        );
        return;
      }

      // 显示更新对话框
      _showUpdateDialog(
        context,
        '发现新版本',
        '当前版本: ${localVersion ?? "未知"}\n最新版本: ${remoteVersion.tagName}\n\n是否下载并更新？',
        remoteVersion,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showUpdateDialog(context, '检查更新失败', '错误: $e', null);
    }
  }

  /// 显示更新对话框
  void _showUpdateDialog(
    BuildContext context,
    String title,
    String content,
    LlamaCppVersion? remoteVersion,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
          if (remoteVersion != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _downloadAndApplyUpdate(context, remoteVersion);
              },
              child: const Text('下载更新'),
            ),
        ],
      ),
    );
  }

  /// 下载并应用更新
  Future<void> _downloadAndApplyUpdate(
    BuildContext context,
    LlamaCppVersion remoteVersion,
  ) async {
    // 显示下载进度对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('正在更新 llama.cpp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return StreamBuilder<UpdateProgress>(
                  stream: _updateProgressController.stream,
                  builder: (context, snapshot) {
                    final progress = snapshot.data ?? UpdateProgress.idle();
                    return Column(
                      children: [
                        Text(progress.message),
                        if (progress.status == UpdateStatus.downloading) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: progress.progress),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 取消下载逻辑可以在这里添加
              Navigator.pop(ctx);
            },
            child: const Text('取消'),
          ),
        ],
      ),
    );

    // 执行下载
    final updateService = LlamaCppUpdateService.instance;
    final result = await updateService.downloadAndExtract(
      remoteVersion,
      onProgress: (progress) {
        _updateProgressController.add(progress);
      },
    );

    if (!context.mounted) return;

    if (result != null) {
      // ====== 热更新：同步库文件并重新加载引擎 ======
      _updateProgressController.add(UpdateProgress(
        status: UpdateStatus.extracting,
        message: '正在同步库文件...',
      ));

      final hotUpdateResult = await LlamaCppUpdateService.instance.hotUpdate(
        onProgress: (progress) {
          _updateProgressController.add(progress);
        },
      );

      if (!context.mounted) return;
      Navigator.pop(context); // 关闭下载对话框

      if (hotUpdateResult.success) {
        // 如果有模型已加载，尝试热重载
        final engine = LocalFFIEngine.instance;
        if (engine.isInitialized && engine.currentModelPath != null) {
          try {
            await engine.reloadAfterHotUpdate();
            if (!context.mounted) return;
            _showHotUpdateSuccessDialog(context, remoteVersion.tagName, hotUpdateResult.syncedCount);
          } catch (e) {
            // 热重载失败，但库文件已更新，下次加载模型时会使用新库
            debugPrint('热重载模型失败: $e');
            if (!context.mounted) return;
            _showHotUpdateSuccessDialog(context, remoteVersion.tagName, hotUpdateResult.syncedCount, needsReload: true);
          }
        } else {
          // 没有已加载的模型
          _showHotUpdateSuccessDialog(context, remoteVersion.tagName, hotUpdateResult.syncedCount);
        }
      } else {
        _showUpdateFailedDialog(context, hotUpdateResult.error ?? '未知错误');
      }
    } else {
      if (!context.mounted) return;
      Navigator.pop(context); // 关闭下载对话框
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('更新失败，请重试'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 显示热更新成功对话框
  void _showHotUpdateSuccessDialog(BuildContext context, String version, int syncedCount, {bool needsReload = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('✅ 更新完成'),
        content: Text(
          needsReload
              ? 'llama.cpp 库文件已更新到 $version\n\n已同步 $syncedCount 个库文件\n\n请重新选择一个模型以使用新引擎'
              : 'llama.cpp 已更新到 $version\n\n已同步 $syncedCount 个库文件\n\n引擎已自动重新加载，无需重启应用！',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  /// 显示更新失败对话框
  void _showUpdateFailedDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('❌ 更新失败'),
        content: Text('错误: $error\n\n请手动同步库文件后重试。'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 更新进度控制器
  final StreamController<UpdateProgress> _updateProgressController =
      StreamController<UpdateProgress>.broadcast();
}

// Helper Widgets

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacingS,
            bottom: AppTheme.spacingS,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.language,
        color: isSelected ? theme.colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
    );
  }
}

class _StorageItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int size;
  final bool isTotal;

  const _StorageItem({
    required this.icon,
    required this.label,
    required this.size,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isTotal ? theme.colorScheme.primary : null,
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          _formatBytes(size),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
