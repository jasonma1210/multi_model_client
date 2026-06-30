/// 思考预算配置卡片
///
/// v0.42.0 新增：嵌入到模型配置页中，控制模型的思考深度。
/// 设计遵循 Material Design 3 规范，使用 SegmentedButton + Slider。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/thinking_config.dart';
import '../../providers/thinking_budget_provider.dart';

/// 思考预算配置卡片
class ThinkingBudgetCard extends ConsumerWidget {
  /// 模型配置 ID
  final String modelConfigId;

  /// 模型显示名
  final String modelDisplayName;

  const ThinkingBudgetCard({
    required this.modelConfigId,
    required this.modelDisplayName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thinkingBudgetProvider(modelConfigId));
    final controller = ref.read(thinkingBudgetProvider(modelConfigId).notifier);
    final capability = ref.watch(thinkingCapabilityProvider(modelConfigId));

    // 不支持思考的模型不显示此卡片
    if (!capability.supportsThinking) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: colors.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '思考预算',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '控制模型推理深度',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _ModelBadge(modelName: modelDisplayName),
              ],
            ),

            const SizedBox(height: 16),

            // 模式选择
            SegmentedButton<ThinkingMode>(
              segments: [
                ButtonSegment(
                  value: ThinkingMode.disabled,
                  label: const Text('关闭'),
                  icon: const Icon(Icons.block, size: 18),
                ),
                ButtonSegment(
                  value: ThinkingMode.adaptive,
                  label: const Text('自适应'),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                ),
                ButtonSegment(
                  value: ThinkingMode.enabled,
                  label: const Text('自定义'),
                  icon: const Icon(Icons.tune, size: 18),
                ),
              ],
              selected: {state.config.mode},
              onSelectionChanged: state.isLoading
                  ? null
                  : (selection) {
                      controller.updateMode(selection.first);
                    },
            ),

            const SizedBox(height: 8),

            // 模式说明
            Text(
              state.config.mode.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),

            // 预算滑块（仅 enabled 模式）
            if (state.config.mode == ThinkingMode.enabled) ...[
              const SizedBox(height: 16),
              _BudgetSlider(
                value: (state.config.budgetTokens ?? 10000).toDouble(),
                min: capability.minBudget.toDouble(),
                max: capability.maxBudget.toDouble(),
                onChanged: state.isLoading
                    ? null
                    : (v) => controller.updateBudget(v.toInt()),
              ),
            ],

            const SizedBox(height: 8),

            // 显示开关
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示思考过程'),
              subtitle: const Text('在回复中展示模型的推理步骤'),
              value: state.config.showThinkingProcess,
              onChanged: state.isLoading
                  ? null
                  : (v) => controller.toggleShowProcess(v),
            ),

            // 错误提示
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colors.onErrorContainer, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 加载指示
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}

/// 模型名徽标
class _ModelBadge extends StatelessWidget {
  final String modelName;
  const _ModelBadge({required this.modelName});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        modelName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// 预算滑块
class _BudgetSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const _BudgetSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final divisions = ((max - min) / 1000).round().clamp(5, 100);
    final costEstimate = _estimateCost(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Token 预算',
              style: theme.textTheme.bodyMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${(value / 1000).toStringAsFixed(1)}K',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: '${(value / 1000).toStringAsFixed(0)}K',
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(min / 1000).toStringAsFixed(0)}K',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            Text(
              '单次预估: \$${costEstimate.toStringAsFixed(4)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(max / 1000).toStringAsFixed(0)}K',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _estimateCost(double tokens) {
    // 简化的成本估算（基于 Claude 4.5 Sonnet 定价）
    return tokens / 1000 * 0.015;
  }
}
