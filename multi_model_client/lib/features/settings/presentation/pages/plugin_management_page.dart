/// 插件管理页面 - LLM Studio 多模态插件管理
///
/// 功能：
/// - 显示所有可用插件及其下载状态
/// - 手动下载/删除插件
/// - 显示下载进度
/// - 与语音设置的 ASR/TTS 模型整合
///
/// @author Jianma
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/plugin_download_service.dart';

/// 插件管理页面
class PluginManagementPage extends ConsumerStatefulWidget {
  const PluginManagementPage({super.key});

  @override
  ConsumerState<PluginManagementPage> createState() =>
      _PluginManagementPageState();
}

class _PluginManagementPageState extends ConsumerState<PluginManagementPage> {
  final PluginDownloadService _pluginService = PluginDownloadService.instance;
  List<PluginStatus> _pluginStatuses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPluginStatuses();
  }

  Future<void> _loadPluginStatuses() async {
    setState(() => _isLoading = true);
    try {
      final statuses = await _pluginService.getAllPluginStatus();
      setState(() {
        _pluginStatuses = statuses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载插件状态失败: $e')));
      }
    }
  }

  Future<void> _downloadPlugin(String pluginId) async {
    try {
      final status = await _pluginService.downloadPlugin(
        pluginId,
        onProgress: (status, progress, downloaded, total) {
          if (mounted) {
            setState(() {
              final index = _pluginStatuses.indexWhere(
                (s) => s.pluginId == pluginId,
              );
              if (index >= 0) {
                _pluginStatuses[index] = PluginStatus(
                  pluginId: pluginId,
                  status: PluginDownloadStatus.downloading,
                  progress: progress,
                  downloadedBytes: downloaded,
                  totalBytes: total,
                );
              }
            });
          }
        },
      );

      await _loadPluginStatuses();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('插件下载完成: ${status.pluginId}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('插件下载失败: $e')));
      }
    }
  }

  Future<void> _deletePlugin(String pluginId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除插件'),
        content: const Text('确定要删除此插件吗？删除后需要重新下载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _pluginService.deletePlugin(pluginId);
      await _loadPluginStatuses();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('插件已删除')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 右滑返回上一页，与返回按钮行为一致
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/settings'),
          ),
          title: const Text('插件管理'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPluginStatuses,
              tooltip: '刷新',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 说明文字
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '多模态插件说明',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.check_circle_outline,
                          '内置插件：OCR（iOS Vision / Android ML Kit）、视频音频提取（系统 API）',
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.cloud_download_outlined,
                          '按需下载：首次使用相关功能时自动提示下载',
                          theme,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.link,
                          '语音设置整合：ASR/TTS 模型与语音设置页面共享',
                          theme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 插件列表
                  ..._buildPluginSections(theme),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPluginSections(ThemeData theme) {
    final plugins = _pluginService.getAvailablePlugins();
    final widgets = <Widget>[];

    // 按类型分组 - 只显示插件（OCR和音频提取），ASR/TTS在语音设置中管理
    final ocrPlugins = plugins.where((p) => p.type == PluginType.ocr).toList();
    final audioExtractorPlugins = plugins
        .where((p) => p.type == PluginType.audioExtractor)
        .toList();
    // ASR/TTS 模型不在这里显示，只在语音设置中管理
    // final asrPlugins = plugins.where((p) => p.type == PluginType.asrModel).toList();
    // final ttsPlugins = plugins.where((p) => p.type == PluginType.ttsModel).toList();

    // OCR 插件
    if (ocrPlugins.isNotEmpty) {
      widgets.add(
        _buildPluginSection('文字识别 (OCR)', Icons.text_fields, ocrPlugins, theme),
      );
    }

    // 音频提取插件
    if (audioExtractorPlugins.isNotEmpty) {
      widgets.add(
        _buildPluginSection(
          '视频音频提取',
          Icons.video_library_outlined,
          audioExtractorPlugins,
          theme,
        ),
      );
    }

    // 提示用户去语音设置管理ASR/TTS
    widgets.add(_buildVoiceSettingsHint(theme));

    return widgets;
  }

  Widget _buildVoiceSettingsHint(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '语音模型管理',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ASR 语音识别模型和 TTS 语音合成模型在「语音设置」中管理，请前往设置 → 语音设置 进行配置。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => context.go('/settings/voice'),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('前往语音设置'),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginSection(
    String title,
    IconData icon,
    List<PluginInfo> plugins,
    ThemeData theme, {
    String? relatedSetting,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (relatedSetting != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '设置中可管理',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // 插件列表
        ...plugins.map((plugin) => _buildPluginCard(plugin, theme)),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPluginCard(PluginInfo plugin, ThemeData theme) {
    final status = _pluginStatuses.firstWhere(
      (s) => s.pluginId == plugin.id,
      orElse: () => PluginStatus(
        pluginId: plugin.id,
        status: PluginDownloadStatus.notDownloaded,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 插件名称和状态
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plugin.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (plugin.isBuiltIn) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '内置',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plugin.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status, theme),
              ],
            ),

            // 下载进度条
            if (status.status == PluginDownloadStatus.downloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: status.progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 4),
              Text(
                '${(status.progress * 100).toInt()}% - ${_formatBytes(status.downloadedBytes)} / ${_formatBytes(status.totalBytes)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // 操作按钮
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (plugin.isBuiltIn)
                  Text(
                    '系统内置，无需下载',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else if (status.status == PluginDownloadStatus.downloaded)
                  TextButton.icon(
                    onPressed: () => _deletePlugin(plugin.id),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  )
                else if (status.status == PluginDownloadStatus.notDownloaded)
                  FilledButton.icon(
                    onPressed: () => _downloadPlugin(plugin.id),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text('下载 (${_formatBytes(plugin.fileSize)})'),
                  )
                else if (status.status == PluginDownloadStatus.downloading)
                  TextButton.icon(
                    onPressed: () => _pluginService.cancelDownload(plugin.id),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('取消'),
                  )
                else if (status.status == PluginDownloadStatus.error)
                  FilledButton.icon(
                    onPressed: () => _downloadPlugin(plugin.id),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('重试'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PluginStatus status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status.status) {
      case PluginDownloadStatus.downloaded:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        text = '已下载';
        icon = Icons.check_circle;
        break;
      case PluginDownloadStatus.downloading:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        text = '下载中';
        icon = Icons.downloading;
        break;
      case PluginDownloadStatus.error:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        text = '错误';
        icon = Icons.error;
        break;
      case PluginDownloadStatus.notDownloaded:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        text = '未下载';
        icon = Icons.cloud_download_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
