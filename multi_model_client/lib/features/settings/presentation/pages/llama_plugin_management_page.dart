/// llama.cpp 插件管理页面
///
/// 职责：
/// 1. 显示当前安装的 llama.cpp 版本
/// 2. 检查最新版本
/// 3. 下载并安装新版本
/// 4. 显示下载进度
///
/// 特点：
/// - 类似 LM Studio 的插件管理
/// - 国内/海外镜像切换
/// - 实时下载进度显示
///
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/llama_plugin_service.dart';
import '../../../../core/services/mirror_service.dart';

class LlamaPluginManagementPage extends StatefulWidget {
  const LlamaPluginManagementPage({super.key});

  @override
  State<LlamaPluginManagementPage> createState() => _LlamaPluginManagementPageState();
}

class _LlamaPluginManagementPageState extends State<LlamaPluginManagementPage> {
  LlamaPluginInfo? _current;
  LlamaPluginInfo? _latest;
  bool _isChecking = false;
  bool _isDownloading = false;
  String? _error;
  MirrorType _selectedMirror = MirrorType.auto;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
  }

  Future<void> _loadCurrentVersion() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    try {
      final current = await LlamaPluginService.instance.getCurrentVersion();
      setState(() {
        _current = current;
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isChecking = false;
      });
    }
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    try {
      final latest = await LlamaPluginService.instance.checkLatest();
      setState(() {
        _latest = latest;
        _isChecking = false;
        if (latest != null && _current != null) {
          final hasUpdate = latest.buildNumber > _current!.buildNumber;
          if (hasUpdate) {
            _showUpdateBadge();
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isChecking = false;
      });
    }
  }

  void _showUpdateBadge() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('发现新版本，点击下载按钮更新'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _downloadAndInstall() async {
    if (_latest == null) {
      await _checkForUpdate();
      if (_latest == null) return;
    }
    if (_current != null && _latest!.buildNumber <= _current!.buildNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已经是最新版本')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      final mirrorUrl = _selectedMirror == MirrorType.china
          ? 'https://hf-mirror.com'
          : (_selectedMirror == MirrorType.global
              ? 'https://huggingface.co'
              : null);

      await LlamaPluginService.instance.downloadAndInstall(
        target: _latest!,
        mirrorUrl: mirrorUrl,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            // 触发 UI 重建
          });
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('更新已下载，下次启动生效'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadCurrentVersion();
        _latest = null;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('llama.cpp 插件管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isChecking ? null : _checkForUpdate,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isChecking && _current == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('错误: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCurrentVersion,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    final current = _current;
    final latest = _latest;
    final hasUpdate = latest != null && current != null && latest.buildNumber > current.buildNumber;
    final downloadProgress = latest != null
        ? LlamaPluginService.instance.getDownloadProgress(latest.version)
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── 当前版本卡片 ──
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.memory, size: 24),
                    const SizedBox(width: 8),
                    const Text('当前版本', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (hasUpdate)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('UPDATE', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildVersionInfo(current),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── 镜像选择 ──
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('下载源', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                SegmentedButton<MirrorType>(
                  segments: const [
                    ButtonSegment(value: MirrorType.auto, label: Text('自动')),
                    ButtonSegment(value: MirrorType.china, label: Text('国内镜像')),
                    ButtonSegment(value: MirrorType.global, label: Text('海外源')),
                  ],
                  selected: {_selectedMirror},
                  onSelectionChanged: (s) => setState(() => _selectedMirror = s.first),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── 最新版本信息 ──
        if (latest != null) ...[
          Card(
            color: hasUpdate ? Colors.red.shade50 : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('最新版本', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      if (hasUpdate)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildVersionInfo(latest),
                  if (latest.releaseDate != null) ...[
                    const SizedBox(height: 8),
                    Text('发布日期: ${_formatDate(latest.releaseDate!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── 下载进度 ──
        if (downloadProgress != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('下载 ${downloadProgress.version}: ${downloadProgress.status}'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: downloadProgress.progress),
                  const SizedBox(height: 8),
                  Text('${(downloadProgress.progress * 100).toStringAsFixed(1)}% '
                      '(${(downloadProgress.downloadedBytes / 1024 / 1024).toStringAsFixed(1)}MB / '
                      '${(downloadProgress.totalBytes / 1024 / 1024).toStringAsFixed(1)}MB)'),
                  if (downloadProgress.error != null) ...[
                    const SizedBox(height: 8),
                    Text('错误: ${downloadProgress.error}', style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── 操作按钮 ──
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isChecking ? null : _checkForUpdate,
                icon: const Icon(Icons.refresh),
                label: const Text('检查更新'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isDownloading || !hasUpdate ? null : _downloadAndInstall,
                icon: _isDownloading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download),
                label: Text(hasUpdate ? '下载更新' : '已是最新'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasUpdate ? Colors.red : null,
                  foregroundColor: hasUpdate ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersionInfo(LlamaPluginInfo? info) {
    if (info == null) return const Text('-');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('版本号: '),
            Text(info.version, style: const TextStyle(fontFamily: 'monospace')),
          ],
        ),
        if (info.commit != null)
          Row(
            children: [
              const Text('Commit: '),
              Text(info.commit!, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ],
          ),
        if (info.fileSize != null)
          Row(
            children: [
              const Text('大小: '),
              Text('${(info.fileSize! / 1024 / 1024).toStringAsFixed(1)} MB'),
            ],
          ),
        if (info.notes != null && info.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('更新说明:', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              info.notes!.length > 500
                  ? '${info.notes!.substring(0, 500)}...'
                  : info.notes!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
