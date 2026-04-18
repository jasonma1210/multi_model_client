import 'package:flutter/material.dart';
import '../../../../core/models/model_hardware_requirement.dart';
import '../../../../core/services/quant_level_matcher.dart';

/// 量化级别选择器组件
class QuantLevelSelector extends StatefulWidget {
  final ModelHardwareRequirement modelRequirement;
  final QuantMatchResult matchResult;
  final String? selectedLevel;
  final Function(String) onLevelSelected;

  const QuantLevelSelector({
    super.key,
    required this.modelRequirement,
    required this.matchResult,
    this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  State<QuantLevelSelector> createState() => _QuantLevelSelectorState();
}

class _QuantLevelSelectorState extends State<QuantLevelSelector> {
  String? _hoveredLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          '选择量化级别',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),

        // 推荐理由
        if (widget.matchResult.reason != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.matchResult.reason!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 可用量化级别
        ...widget.matchResult.validLevels.entries.map((entry) {
          final level = entry.key;
          final memMB = entry.value;
          final isRecommended = level == widget.matchResult.recommendLevel;
          final isSelected = level == widget.selectedLevel;

          return _buildQuantLevelTile(
            level: level,
            memMB: memMB,
            isEnabled: true,
            isRecommended: isRecommended,
            isSelected: isSelected,
          );
        }),

        // 分隔线
        if (widget.matchResult.invalidLevels.isNotEmpty) ...[
          const Divider(height: 32),
          Text(
            '不兼容的量化级别',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
        ],

        // 禁用量化级别
        ...widget.matchResult.invalidLevels.entries.map((entry) {
          final level = entry.key;
          final memMB = entry.value;

          return _buildQuantLevelTile(
            level: level,
            memMB: memMB,
            isEnabled: false,
            isRecommended: false,
            isSelected: false,
          );
        }),
      ],
    );
  }

  Widget _buildQuantLevelTile({
    required String level,
    required int memMB,
    required bool isEnabled,
    required bool isRecommended,
    required bool isSelected,
  }) {
    final memGB = memMB / 1024;
    final description = widget.matchResult.getLevelDescription(level);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredLevel = level),
      onExit: (_) => setState(() => _hoveredLevel = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : _hoveredLevel == level && isEnabled
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : isRecommended && isEnabled
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : isEnabled
                        ? Theme.of(context).dividerColor
                        : Theme.of(context).disabledColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: RadioListTile<String>(
          value: level,
          groupValue: widget.selectedLevel,
          onChanged: isEnabled ? (value) => widget.onLevelSelected(value!) : null,
          title: Row(
            children: [
              Text(
                level,
                style: TextStyle(
                  fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                  color: isEnabled ? null : Theme.of(context).disabledColor,
                ),
              ),
              if (isRecommended) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '推荐',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: isEnabled
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.memory_outlined,
                    size: 14,
                    color: isEnabled ? Colors.blue : Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '内存需求: ${memGB.toStringAsFixed(1)} GB',
                    style: TextStyle(
                      fontSize: 12,
                      color: isEnabled ? Colors.blue : Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.storage_outlined,
                    size: 14,
                    color: isEnabled ? Colors.orange : Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '存储: ${memGB.toStringAsFixed(1)} GB',
                    style: TextStyle(
                      fontSize: 12,
                      color: isEnabled ? Colors.orange : Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
              if (!isEnabled) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '设备内存不足，需要 ${(memMB / 1024).toStringAsFixed(1)} GB',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          dense: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      ),
    );
  }
}

/// 量化级别信息卡片
class QuantLevelInfoCard extends StatelessWidget {
  final String level;
  final int memMB;
  final bool isRecommended;
  final bool isSelected;

  const QuantLevelInfoCard({
    super.key,
    required this.level,
    required this.memMB,
    this.isRecommended = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final memGB = memMB / 1024;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  level,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isRecommended) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '推荐',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.memory_outlined, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text('内存: ${memGB.toStringAsFixed(1)} GB'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
