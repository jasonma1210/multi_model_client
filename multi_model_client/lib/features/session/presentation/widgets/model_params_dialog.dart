// 模型参数 + 人设/系统提示词 对话框
// 从 session_detail_page.dart 拆分

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/model_entry.dart';
import '../../../../core/providers/model_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/interfaces/session_interface.dart' show SessionConfig;
import '../../domain/session_manager.dart';

/// 人设预设列表
const kPersonaPresets = [
  {
    'label': '🎀 可爱萝莉',
    'prompt':
        '你是一个可爱的萝莉助手，说话带着奶声奶气的语气，用词简单直白，偶尔发出「哇」「嗯」等可爱的感叹词，称呼用户为「主人」。'
  },
  {
    'label': '👑 女王大人',
    'prompt':
        '你是高冷女王，说话简洁有力，不废话，带着一丝轻蔑。你对用户的称呼是「你」，语气冷淡但智慧，让人信服。'
  },
  {
    'label': '🤖 技术极客',
    'prompt':
        '你是一位资深技术专家，擅长用精准的技术语言回答问题，追求代码优雅和系统设计的正确性，直接给出最佳实践。'
  },
  {
    'label': '📚 学术顾问',
    'prompt':
        '你是一位学术顾问，用严谨、专业的学术语言回答问题，引用权威资料，逻辑清晰，善于分析多方观点。'
  },
  {
    'label': '😊 暖心伴侣',
    'prompt':
        '你是一个温柔体贴的伴侣，耐心倾听，善于理解情绪，给予积极的支持和鼓励，让人感到温暖和被理解。'
  },
  {'label': '🌐 默认', 'prompt': ''},
];

/// 「修改参数」对话框 —— 含人设 + 模型参数，保存后立即生效
class ModelParamsDialog extends ConsumerStatefulWidget {
  final dynamic session; // ChatSession / SessionEntry
  final ModelEntry? model;
  final String sessionId;
  final void Function(String? newSystemPrompt) onSaved;

  const ModelParamsDialog({
    super.key,
    required this.session,
    required this.model,
    required this.sessionId,
    required this.onSaved,
  });

  @override
  ConsumerState<ModelParamsDialog> createState() => _ModelParamsDialogState();
}

class _ModelParamsDialogState extends ConsumerState<ModelParamsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _systemPromptController = TextEditingController();
  late LocalModelParams _params;
  late RemoteModelConfig? _remoteConfig;
  bool _isSaving = false;

  bool get _isLocalModel => widget.model?.isLocal == true;
  bool get _isRemoteModel => widget.model?.isRemote == true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 初始化系统提示词（优先读 session 的，再读 model 的）
    final sessionPrompt = widget.session?.systemPrompt as String?;
    final modelPrompt = widget.model?.localParams?.systemPrompt;
    _systemPromptController.text = sessionPrompt ?? modelPrompt ?? '';
    // 初始化本地模型参数
    _params = widget.model?.localParams ?? const LocalModelParams();
    // 初始化远程模型参数
    _remoteConfig = widget.model?.remoteConfig;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      insetPadding: isWide
          ? EdgeInsets.symmetric(
              horizontal: (screenWidth - 560) / 2,
              vertical: 40,
            )
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 标题栏 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Icon(
                      Icons.tune_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '修改参数',
                          style: theme.textTheme.titleMedium,
                        ),
                        if (widget.model != null)
                          Text(
                            widget.model!.displayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Tab 栏 ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TabBar(
                controller: _tabController,
                labelStyle: theme.textTheme.labelLarge,
                unselectedLabelStyle: theme.textTheme.labelLarge,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                tabs: const [
                  Tab(text: '人设 & 提示词'),
                  Tab(text: '推理参数'),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── 内容区 ──
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSystemPromptTab(theme),
                  _buildParamsTab(theme),
                ],
              ),
            ),

            // ── 底部按钮 ──
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveAll,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check, size: 16),
                    label: const Text('保存并生效'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 人设 & 系统提示词 Tab ──
  Widget _buildSystemPromptTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 说明文字
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '设置当前会话专属的系统提示词（人设），让 AI 扮演特定角色。\n例如：「你是萝莉音调的可爱助手」「你是女王大人，说话冷漠有气场」',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 快速人设预设
          Text(
            '快速选择',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kPersonaPresets.map((preset) {
              return ActionChip(
                label: Text(preset['label']!),
                onPressed: () {
                  _systemPromptController.text = preset['prompt']!;
                },
                padding: const EdgeInsets.symmetric(horizontal: 4),
                labelStyle: theme.textTheme.labelSmall,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 系统提示词输入框
          Text(
            '自定义提示词',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _systemPromptController,
            maxLines: 7,
            decoration: InputDecoration(
              hintText: '输入系统提示词，例如：你是一位专业的技术作家，善于用通俗语言解释复杂概念...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_systemPromptController.text.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _systemPromptController.clear()),
                  icon: const Icon(Icons.clear, size: 14),
                  label: const Text('清除'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 推理参数 Tab ──
  Widget _buildParamsTab(ThemeData theme) {
    if (_isLocalModel) {
      return _buildLocalParamsContent(theme);
    } else if (_isRemoteModel) {
      return _buildRemoteParamsContent(theme);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '当前会话未绑定模型，无法配置参数',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalParamsContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 温度
          ParamRow(
            label: '温度',
            tooltip: '控制输出随机性。越低越确定（0=完全确定），越高越发散（建议创意 0.8，代码 0.2）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _params.temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 200,
                    onChanged: (v) => setState(
                        () => _params = _params.copyWith(temperature: v)),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    _params.temperature.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Top P
          ParamRow(
            label: 'Top P',
            tooltip: '核采样：从累积概率达到 P 的词中选择（0.9 = 高质量，0.5 = 保守）',
            child: Row(
              children: [
                Switch(
                  value: _params.topPEnabled,
                  onChanged: (v) => setState(
                      () => _params = _params.copyWith(topPEnabled: v)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _params.topP,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    onChanged: _params.topPEnabled
                        ? (v) => setState(
                            () => _params = _params.copyWith(topP: v))
                        : null,
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    _params.topP.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Top K
          ParamRow(
            label: 'Top K',
            tooltip: '只从概率最高的 K 个词中采样。值越小越保守，值越大越发散',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _params.topK.toDouble(),
                    min: 1,
                    max: 200,
                    divisions: 199,
                    onChanged: (v) => setState(
                        () => _params = _params.copyWith(topK: v.round())),
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${_params.topK}',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 重复惩罚
          ParamRow(
            label: '重复惩罚',
            tooltip: '防止重复内容。1.0 = 无惩罚，1.2 表示重复词概率降低 20%',
            child: Row(
              children: [
                Switch(
                  value: _params.repeatPenaltyEnabled,
                  onChanged: (v) => setState(() =>
                      _params = _params.copyWith(repeatPenaltyEnabled: v)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _params.repeatPenalty,
                    min: 1.0,
                    max: 2.0,
                    divisions: 100,
                    onChanged: _params.repeatPenaltyEnabled
                        ? (v) => setState(
                            () => _params = _params.copyWith(repeatPenalty: v))
                        : null,
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    _params.repeatPenalty.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ★ 纯 CPU 测试模式开关（骁龙 8 Elite 排查 Vulkan 问题用）
          ParamRow(
            label: '纯 CPU 测试',
            tooltip: '强制 gpuLayers=0，纯 CPU 推理。\n'
                '用于排查 Vulkan GPU 加速问题：\n'
                '1. 开启此开关 → 测试纯 CPU 速度\n'
                '2. 如果纯 CPU 更快 → Vulkan 有问题\n'
                '3. 如果纯 CPU 更慢 → Vulkan 正常，问题在别处',
            child: Switch(
              value: _params.gpuLayers == 0,
              onChanged: (v) => setState(() => _params = _params.copyWith(
                gpuLayers: v ? 0 : 99,
                cpuThreads: v ? 2 : _params.cpuThreads, // 纯 CPU 模式用 2 线程绑定超大核
              )),
            ),
          ),
          const SizedBox(height: 4),

          // GPU 层数
          ParamRow(
            label: 'GPU 层数',
            tooltip: '卸载到 GPU 的模型层数。99 = 全部卸载（最快），0 = 纯 CPU（最慢）\n'
                '★ 骁龙 8 Elite 提示：如果开启 Vulkan 后反而更慢，\n'
                '   请先用「纯 CPU 测试」开关对比速度',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _params.gpuLayers.toDouble(),
                    min: 0,
                    max: 99,
                    divisions: 99,
                    onChanged: (v) => setState(
                        () => _params = _params.copyWith(gpuLayers: v.round())),
                  ),
                ),
                SizedBox(
                  width: 38,
                  child: Text(
                    '${_params.gpuLayers}',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // CPU 线程
          ParamRow(
            label: 'CPU 线程',
            tooltip: '推理使用的 CPU 线程数，建议等于 CPU 核心数',
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: _params.cpuThreads > 1
                      ? () => setState(() => _params = _params.copyWith(
                          cpuThreads: _params.cpuThreads - 1))
                      : null,
                ),
                Text('${_params.cpuThreads}', style: theme.textTheme.bodyMedium),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _params.cpuThreads < 64
                      ? () => setState(() => _params = _params.copyWith(
                          cpuThreads: _params.cpuThreads + 1))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 快速模式（思考模式）
          ParamRow(
            label: '思考模式',
            tooltip:
                '启用后，模型将输出思考过程（Chain-of-Thought），适合数学、逻辑推理等复杂问题。关闭则为快速模式，直接给出答案',
            child: Row(
              children: [
                Expanded(
                  child: Switch(
                    value: _params.enableReasoning,
                    onChanged: (v) => setState(() =>
                        _params = _params.copyWith(enableReasoning: v)),
                  ),
                ),
                Text(
                  _params.enableReasoning ? '开启' : '关闭（快速模式）',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _params.enableReasoning ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // 最大 Token 数
          ParamRow(
            label: '限制响应长度',
            tooltip: '开启后限制单次回复最大 token 数',
            child: Row(
              children: [
                Switch(
                  value: _params.limitResponseLength,
                  onChanged: (v) => setState(() =>
                      _params = _params.copyWith(limitResponseLength: v)),
                ),
                if (_params.limitResponseLength) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: '${_params.maxTokens ?? 2048}',
                      ),
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        isDense: true,
                        border: OutlineInputBorder(),
                        suffixText: 'tok',
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0) {
                          setState(() => _params = _params.copyWith(maxTokens: n));
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteParamsContent(ThemeData theme) {
    final config = _remoteConfig;
    if (config == null) {
      return const Center(child: Text('暂无远程模型配置'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 温度
          ParamRow(
            label: '温度',
            tooltip: '控制输出随机性（0=确定，2=最发散）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 200,
                    onChanged: (v) => setState(
                        () => _remoteConfig = config.copyWith(temperature: v)),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    config.temperature.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Top P
          ParamRow(
            label: 'Top P',
            tooltip: '核采样阈值（0.9 = 高质量）',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.topP,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    onChanged: (v) => setState(
                        () => _remoteConfig = config.copyWith(topP: v)),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    config.topP.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Max Tokens
          ParamRow(
            label: '最大输出',
            tooltip: '单次回复最大 token 数',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.maxTokens.toDouble().clamp(256, 8192),
                    min: 256,
                    max: 8192,
                    divisions: 63,
                    onChanged: (v) => setState(
                        () => _remoteConfig = config.copyWith(maxTokens: v.round())),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${config.maxTokens}',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Stream
          ParamRow(
            label: '流式输出',
            tooltip: '开启后实时逐字输出，关闭后等待完整响应',
            child: Switch(
              value: config.streamEnabled,
              onChanged: (v) => setState(
                  () => _remoteConfig = config.copyWith(streamEnabled: v)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 保存 ──
  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      // 1. 保存系统提示词到 Session（当前会话专属）
      final sessionManager = ref.read(sessionManagerProvider);
      final sessionState = ref.read(sessionStateProvider);
      await sessionManager.updateSessionConfig(
        widget.sessionId,
        SessionConfig(
          name: sessionState.activeSession?.name ?? '',
          modelId: sessionState.activeSession?.modelId ?? '',
          systemPrompt: _systemPromptController.text.trim().isEmpty
              ? null
              : _systemPromptController.text.trim(),
        ),
      );

      // 2. 保存推理参数到 ModelEntry（持久化）
      if (widget.model != null) {
        final modelNotifier = ref.read(modelProvider.notifier);
        if (_isLocalModel) {
          await modelNotifier.updateLocalParams(
            widget.model!.id,
            _params.copyWith(
              systemPrompt: _systemPromptController.text.trim().isEmpty
                  ? null
                  : _systemPromptController.text.trim(),
            ),
          );
        } else if (_isRemoteModel && _remoteConfig != null) {
          await modelNotifier.updateRemoteConfig(widget.model!.id, _remoteConfig!);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved(_systemPromptController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

/// 单行参数布局
class ParamRow extends StatelessWidget {
  final String label;
  final String tooltip;
  final Widget child;

  const ParamRow({
    super.key,
    required this.label,
    required this.tooltip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip,
                  preferBelow: true,
                  child: Icon(
                    Icons.help_outline,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
