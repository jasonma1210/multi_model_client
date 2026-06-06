// ignore_for_file: use_build_context_synchronously
/// 名灵回响 - 创建名灵页面
///
/// 用户输入昵称/领域/描述 → 配置搜索 API Key → 选择模型 → 开始异步蒸馏
/// 蒸馏进度通过 Stream 实时显示
///
/// @author JianMa
/// @version 2.0.0
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/model_provider.dart';
import '../../domain/name_blacklist_service.dart';
import '../../domain/spirit_distillation_service.dart';
import '../../data/spirit_repository.dart';
import '../../domain/spirit_skill.dart';
import '../../../skill/domain/skill_dispatcher.dart';

/// 领域选项
const List<MapEntry<String, String>> _domainOptions = [
  MapEntry('演员', '🎭'),
  MapEntry('歌手', '🎤'),
  MapEntry('导演', '🎬'),
  MapEntry('作家', '✍️'),
  MapEntry('企业家', '💼'),
  MapEntry('科学家', '🔬'),
  MapEntry('教育家', '📚'),
  MapEntry('运动员', '⚽'),
  MapEntry('艺术家', '🎨'),
  MapEntry('主持人', '🎙️'),
  MapEntry('博主', '📱'),
  MapEntry('设计师', '🎯'),
  MapEntry('医生', '🏥'),
  MapEntry('律师', '⚖️'),
  MapEntry('音乐家', '🎵'),
  MapEntry('其他', '👤'),
];

class SpiritCreatePage extends ConsumerStatefulWidget {
  const SpiritCreatePage({super.key});

  @override
  ConsumerState<SpiritCreatePage> createState() => _SpiritCreatePageState();
}

class _SpiritCreatePageState extends ConsumerState<SpiritCreatePage> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tavilyApiKeyController = TextEditingController();
  String _selectedDomain = '演员';
  String _selectedModelId = '';
  bool _isDistilling = false;
  String? _progressMessage;
  double? _progressValue;
  String? _errorMessage;

  /// Tavily API Key 是否已配置（从蒸馏服务读取）
  bool _isTavilyConfigured = false;
  bool _showTavilyConfig = false;

  final NameBlacklistService _blacklistService = NameBlacklistService();

  @override
  void initState() {
    super.initState();
    _checkTavilyConfig();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _tavilyApiKeyController.dispose();
    super.dispose();
  }

  /// 检查 Tavily API Key 是否已配置
  Future<void> _checkTavilyConfig() async {
    final service = ref.read(spiritDistillationServiceProvider);
    final configured = await service.isTavilyConfigured();
    if (mounted) {
      setState(() {
        _isTavilyConfigured = configured;
        _showTavilyConfig = !configured;
      });
      // 如果已配置，填充到控制器
      if (configured) {
        final key = await service.getTavilyApiKey();
        if (key != null) {
          _tavilyApiKeyController.text = key;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建名灵'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isDistilling ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题说明
            _buildHeader(theme),
            const SizedBox(height: 24),

            // 昵称输入
            _buildNicknameField(theme, isDark),
            const SizedBox(height: 16),

            // 领域选择
            _buildDomainSelector(theme, isDark),
            const SizedBox(height: 16),

            // 描述输入
            _buildDescriptionField(theme),
            const SizedBox(height: 16),

            // Tavily API Key 配置
            _buildTavilyConfigSection(theme, isDark),
            const SizedBox(height: 16),

            // 模型选择
            _buildModelSelector(theme, isDark),
            const SizedBox(height: 24),

            // 蒸馏进度
            if (_isDistilling) _buildProgressCard(theme),
            if (_errorMessage != null && !_isDistilling)
              _buildErrorCard(theme),

            // 开始蒸馏按钮
            if (!_isDistilling) _buildStartButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('👻', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              '名灵回响',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '通过大模型+网络搜索，蒸馏出公众人物的思想风格，创建可交互的数字分身。所有真名将被昵称替代。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNicknameField(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('昵称', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          enabled: !_isDistilling,
          decoration: InputDecoration(
            hintText: '输入人物昵称（如：大幂幂）',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: isDark
                ? theme.colorScheme.surfaceContainerHighest
                : theme.colorScheme.surfaceContainerLow,
          ),
          onChanged: (value) {
            _checkBlacklist(value);
          },
        ),
      ],
    );
  }

  /// 检查黑名单并提示
  Future<void> _checkBlacklist(String input) async {
    if (input.trim().isEmpty) return;
    final (isValid, message) = await _blacklistService.validateName(input.trim());
    if (!isValid && message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (isValid && message != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检测到真名，已自动替换为昵称: $message'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildDomainSelector(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('领域', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _domainOptions.map((entry) {
            final isSelected = _selectedDomain == entry.key;
            return ChoiceChip(
              label: Text('${entry.value} ${entry.key}'),
              selected: isSelected,
              onSelected: _isDistilling
                  ? null
                  : (selected) {
                      if (selected) {
                        setState(() => _selectedDomain = entry.key);
                      }
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('描述（可选）', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          enabled: !_isDistilling,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '描述你希望这个名灵具备的特点...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  /// Tavily API Key 配置区域
  Widget _buildTavilyConfigSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行 + 展开/收起
        InkWell(
          onTap: () => setState(() => _showTavilyConfig = !_showTavilyConfig),
          child: Row(
            children: [
              Icon(
                _isTavilyConfigured
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                size: 18,
                color: _isTavilyConfigured
                    ? Colors.green
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                '搜索服务 (Tavily)',
                style: theme.textTheme.titleSmall,
              ),
              const Spacer(),
              // 配置状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _isTavilyConfigured
                      ? Colors.green.withValues(alpha: 0.1)
                      : theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isTavilyConfigured ? '已配置' : '未配置',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _isTavilyConfigured
                        ? Colors.green
                        : theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                _showTavilyConfig
                    ? Icons.expand_less
                    : Icons.expand_more,
                size: 20,
              ),
            ],
          ),
        ),

        // 展开的配置区域
        if (_showTavilyConfig) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isTavilyConfigured
                    ? Colors.green.withValues(alpha: 0.3)
                    : theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 说明文字
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Tavily 是免费的 AI 搜索 API，蒸馏需要网络搜索支持。首次使用需配置 API Key。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    // 打开 Tavily 注册页面
                    // 使用 launchUrl 或其他方式
                  },
                  child: Text(
                    '免费注册: https://tavily.com',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // API Key 输入
                TextField(
                  controller: _tavilyApiKeyController,
                  enabled: !_isDistilling,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '输入 Tavily API Key',
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      tooltip: '保存',
                      onPressed: _isDistilling ? null : _saveTavilyApiKey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? theme.colorScheme.surfaceContainerHigh
                        : theme.colorScheme.surface,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _saveTavilyApiKey(),
                ),
                const SizedBox(height: 8),

                // 降级提示
                Text(
                  '未配置时将降级使用 DuckDuckGo（搜索结果有限）',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 保存 Tavily API Key
  Future<void> _saveTavilyApiKey() async {
    final apiKey = _tavilyApiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 Tavily API Key')),
      );
      return;
    }

    final service = ref.read(spiritDistillationServiceProvider);
    await service.setTavilyApiKey(apiKey);

    setState(() {
      _isTavilyConfigured = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tavily API Key 已保存'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildModelSelector(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('蒸馏模型', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildModelDropdown(theme, isDark),
        const SizedBox(height: 4),
        Text(
          '选择用于蒸馏的 AI 模型，推荐使用推理能力较强的模型',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 模型下拉选择（分组显示本地模型和远程 API 模型）
  Widget _buildModelDropdown(ThemeData theme, bool isDark) {
    final modelState = ref.watch(modelProvider);

    // 分组：本地模型 + 远程模型
    final localModels = modelState.localModels;
    final remoteModels = modelState.remoteModels;

    // 如果没有任何模型，显示提示
    if (localModels.isEmpty && remoteModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '暂无可用模型，请先在设置中添加模型',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 默认选择第一个可用模型
    if (_selectedModelId.isEmpty) {
      // 优先选择远程模型（推理能力更强），其次本地已加载模型
      if (remoteModels.isNotEmpty) {
        _selectedModelId = remoteModels.first.id;
      } else if (localModels.isNotEmpty) {
        // 优先选择已加载的本地模型
        final loaded = localModels.where((m) => m.isLoaded).toList();
        _selectedModelId = loaded.isNotEmpty ? loaded.first.id : localModels.first.id;
      }
    }

    // 构建 DropdownMenuItem 列表（分组）
    final items = <DropdownMenuItem<String>>[];

    // 本地模型分组
    if (localModels.isNotEmpty) {
      for (final model in localModels) {
        items.add(DropdownMenuItem(
          value: model.id,
          child: Row(
            children: [
              Icon(
                Icons.computer_rounded,
                size: 16,
                color: model.isLoaded ? Colors.green : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  model.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: model.isLoaded ? null : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (model.isLoaded)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '已加载',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ));
      }
    }

    // 远程模型分组
    if (remoteModels.isNotEmpty) {
      for (final model in remoteModels) {
        items.add(DropdownMenuItem(
          value: model.id,
          child: Row(
            children: [
              Icon(
                Icons.cloud_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  model.displayName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 显示协议类型
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  model.remoteConfig?.protocol.name.toUpperCase() ?? 'API',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedModelId.isNotEmpty && items.any((i) => i.value == _selectedModelId)
            ? _selectedModelId
            : null,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        hint: const Text('选择蒸馏模型'),
        items: items,
        onChanged: _isDistilling
            ? null
            : (value) {
                if (value != null) {
                  setState(() => _selectedModelId = value);
                }
              },
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _progressMessage ?? '正在处理...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (_progressValue != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: _progressValue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(ThemeData theme) {
    final canStart = _nameController.text.trim().isNotEmpty && _selectedModelId.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: canStart ? _startDistillation : null,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('开始蒸馏'),
      ),
    );
  }

  /// 开始蒸馏
  Future<void> _startDistillation() async {
    final nickname = _nameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入昵称')),
      );
      return;
    }

    if (_selectedModelId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择蒸馏模型')),
      );
      return;
    }

    // 黑名单验证
    final (isValid, message) = await _blacklistService.validateName(nickname);
    if (!isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? '名称不合规')),
        );
      }
      return;
    }

    String effectiveNickname = nickname;
    String? realName;
    if (message != null) {
      realName = nickname;
      effectiveNickname = message;
    }

    // 如果 Tavily 未配置，提示用户
    if (!_isTavilyConfigured) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('搜索服务未配置'),
          content: const Text(
            'Tavily API Key 未配置，将使用 DuckDuckGo 降级搜索（结果有限）。\n\n'
            '建议配置 Tavily API Key 以获得更好的搜索结果。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
                // 展开配置区域
                setState(() => _showTavilyConfig = true);
              },
              child: const Text('去配置'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('继续蒸馏'),
            ),
          ],
        ),
      );

      if (shouldContinue != true) return;
    }

    setState(() {
      _isDistilling = true;
      _errorMessage = null;
      _progressMessage = '正在初始化...';
      _progressValue = null;
    });

    try {
      final distillService = ref.read(spiritDistillationServiceProvider);
      final repo = ref.read(spiritRepositoryProvider);

      // 订阅进度
      final progressSub = distillService.progressStream.listen((progress) {
        if (!mounted) return;
        setState(() {
          _progressMessage = progress.message;
          _progressValue = progress.progress;
        });
      });

      // 执行蒸馏
      final persona = await distillService.distill(
        nickname: effectiveNickname,
        realName: realName,
        domain: _selectedDomain,
        modelId: _selectedModelId,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
      );

      progressSub.cancel();

      // 保存到仓库
      await repo.addPersona(persona);

      // 如果蒸馏成功，注册为技能
      if (persona.isReady) {
        final dispatcher = SkillDispatcher();
        final skillManager = SpiritSkillManager();
        skillManager.registerSpiritSkill(persona, dispatcher);
      }

      if (mounted) {
        setState(() {
          _isDistilling = false;
        });

        // 显示结果
        if (persona.isReady) {
          // 显示蒸馏完成弹窗，3秒自动关闭
          ScaffoldMessenger.of(context).clearSnackBars();
          final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${persona.nickname} 蒸馏完成！'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: '查看',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  context.push('/spirit/detail/${persona.id}');
                },
              ),
            ),
          );
          // 3秒后自动返回画廊页
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.pop(persona.id);
            }
          });
        } else {
          setState(() {
            _errorMessage = persona.errorMessage ?? '蒸馏失败，请重试';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDistilling = false;
          _errorMessage = '蒸馏异常: $e';
        });
      }
    }
  }
}
