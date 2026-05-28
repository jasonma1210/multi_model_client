// ignore_for_file: unnecessary_underscores, use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/database_connection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/app_localizations.dart';

// 记忆设置 Provider
final memorySettingsProvider =
    StateNotifierProvider<MemorySettingsNotifier, MemorySettings>((ref) {
      return MemorySettingsNotifier();
    });

class MemorySettings {
  final int maxMemories;
  final double similarityThreshold;

  const MemorySettings({
    this.maxMemories = 100,
    this.similarityThreshold = 0.7,
  });

  MemorySettings copyWith({int? maxMemories, double? similarityThreshold}) {
    return MemorySettings(
      maxMemories: maxMemories ?? this.maxMemories,
      similarityThreshold: similarityThreshold ?? this.similarityThreshold,
    );
  }
}

class MemorySettingsNotifier extends StateNotifier<MemorySettings> {
  MemorySettingsNotifier() : super(const MemorySettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = MemorySettings(
      maxMemories: prefs.getInt('max_memories') ?? 100,
      similarityThreshold: prefs.getDouble('similarity_threshold') ?? 0.7,
    );
  }

  Future<void> setMaxMemories(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('max_memories', value);
    state = state.copyWith(maxMemories: value);
  }

  Future<void> setSimilarityThreshold(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('similarity_threshold', value);
    state = state.copyWith(similarityThreshold: value);
  }

  /// 清除所有记忆和聊天记录
  Future<void> clearAllMemoriesAndMessages() async {
    final db = database;
    await db.deleteAllMemories();
    await db.deleteAllMessages();
  }
}

/// 记忆统计信息 Provider
final memoryStatsProvider = FutureProvider<MemoryStats>((ref) async {
  final db = database;
  final memoryCount = await db.getMemoryCount();
  final messageCount = await db.getMessageCount();

  // 计算数据库文件大小
  int dbSize = 0;
  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocDir.path}/multi_model_client.db';
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      dbSize = await dbFile.length();
    }
  } catch (_) {
    // ignore: non-critical error
  }

  return MemoryStats(
    memoryCount: memoryCount,
    messageCount: messageCount,
    storageBytes: dbSize,
  );
});

class MemoryStats {
  final int memoryCount;
  final int messageCount;
  final int storageBytes;

  MemoryStats({
    required this.memoryCount,
    required this.messageCount,
    required this.storageBytes,
  });

  String get storageFormatted {
    if (storageBytes < 1024) {
      return '$storageBytes B';
    } else if (storageBytes < 1024 * 1024) {
      return '${(storageBytes / 1024).toStringAsFixed(1)} KB';
    } else if (storageBytes < 1024 * 1024 * 1024) {
      return '${(storageBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(storageBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}

class MemorySettingsPage extends ConsumerStatefulWidget {
  const MemorySettingsPage({super.key});

  @override
  ConsumerState<MemorySettingsPage> createState() => _MemorySettingsPageState();
}

class _MemorySettingsPageState extends ConsumerState<MemorySettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(memorySettingsProvider);
    final statsAsync = ref.watch(memoryStatsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          title: Text(l10n.memorySettings),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          children: [
            // 存储设置
            _SettingsSection(
              title: '存储设置',
              children: [
                ListTile(
                  title: const Text('最大记忆数量'),
                  subtitle: Text('当前: ${settings.maxMemories} 条'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMaxMemoriesDialog(
                    context,
                    ref,
                    settings.maxMemories,
                  ),
                ),
                ListTile(
                  title: const Text('相似度阈值'),
                  subtitle: Text(
                    '当前: ${(settings.similarityThreshold * 100).toInt()}%',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showSimilarityThresholdDialog(
                    context,
                    ref,
                    settings.similarityThreshold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

            // 数据管理
            _SettingsSection(
              title: '数据管理',
              children: [
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    '清除所有记忆',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: const Text('删除所有会话的聊天内容和记忆数据，不可恢复'),
                  onTap: () => _showClearMemoryDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingM),

            // 统计信息
            _SettingsSection(
              title: '统计信息',
              children: [
                ListTile(
                  title: const Text('总会话消息数'),
                  subtitle: const Text('用户提问 + AI 回复'),
                  trailing: statsAsync.when(
                    data: (stats) => Text('${stats.messageCount} 条'),
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text('-'),
                  ),
                ),
                ListTile(
                  title: const Text('当前记忆数量'),
                  trailing: statsAsync.when(
                    data: (stats) => Text('${stats.memoryCount} 条'),
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text('-'),
                  ),
                ),
                ListTile(
                  title: const Text('占用存储空间'),
                  trailing: statsAsync.when(
                    data: (stats) => Text(stats.storageFormatted),
                    loading: () => const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Text('-'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  void _showMaxMemoriesDialog(
    BuildContext context,
    WidgetRef ref,
    int currentValue,
  ) {
    int selectedValue = currentValue;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('最大记忆数量'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('设置所有会话的最大记忆数量: $selectedValue 条'),
              const SizedBox(height: 16),
              Slider(
                value: selectedValue.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                label: '$selectedValue',
                onChanged: (value) {
                  setState(() => selectedValue = value.toInt());
                },
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('10'), Text('500')],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(memorySettingsProvider.notifier)
                  .setMaxMemories(selectedValue);
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSimilarityThresholdDialog(
    BuildContext context,
    WidgetRef ref,
    double currentValue,
  ) {
    double selectedValue = currentValue;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('相似度阈值'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('低于此相似度的记忆将被过滤: ${(selectedValue * 100).toInt()}%'),
              const SizedBox(height: 16),
              Slider(
                value: selectedValue,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${(selectedValue * 100).toInt()}%',
                onChanged: (value) {
                  setState(() => selectedValue = value);
                },
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('10%'), Text('100%')],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(memorySettingsProvider.notifier)
                  .setSimilarityThreshold(selectedValue);
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearMemoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ClearMemoryDialog(
        onConfirm: () async {
          await ref
              .read(memorySettingsProvider.notifier)
              .clearAllMemoriesAndMessages();
          // 刷新统计信息
          ref.invalidate(memoryStatsProvider);
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('已清除所有记忆和聊天记录')));
          }
        },
      ),
    );
  }
}

/// 清除记忆确认对话框（带5秒等待）
class _ClearMemoryDialog extends StatefulWidget {
  final Future<void> Function() onConfirm;

  const _ClearMemoryDialog({required this.onConfirm});

  @override
  State<_ClearMemoryDialog> createState() => _ClearMemoryDialogState();
}

class _ClearMemoryDialogState extends State<_ClearMemoryDialog> {
  int _countdown = 5;
  Timer? _timer;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('清除失败: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canConfirm = _countdown == 0 && !_isDeleting;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          const Text('危险操作'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('此操作将删除：', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('• 所有会话的聊天记录'),
          Text('• 所有记忆数据'),
          SizedBox(height: 16),
          Text(
            '⚠️ 此操作不可恢复！',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: canConfirm
                ? theme.colorScheme.error
                : theme.colorScheme.error.withValues(alpha: 0.5),
          ),
          onPressed: canConfirm ? _handleConfirm : null,
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_countdown > 0 ? '确认清除 ($_countdown)' : '确认清除'),
        ),
      ],
    );
  }
}

// 设置区块组件
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

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
          child: Column(children: children),
        ),
      ],
    );
  }
}
