// 工具按钮、菜单项和操作按钮等基础控件
// 从 session_detail_page.dart 拆分

import 'package:flutter/material.dart';

import '../../../../core/widgets/animations/animations.dart';

/// 工具按钮（图标）
class ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const ToolButton({
    super.key,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedSwitcher(
            duration: AppAnimations.durationFast,
            switchInCurve: AppAnimations.easeOut,
            switchOutCurve: AppAnimations.easeIn,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              icon,
              key: ValueKey('$icon-$isActive'),
              size: 22,
              color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// 操作按钮（发送/停止）
class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color? iconColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = color != theme.colorScheme.surfaceContainerHighest;

    return Tooltip(
      message: isEnabled ? '发送' : '正在生成',
      child: Pressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: AnimatedSwitcher(
            duration: AppAnimations.durationMedium,
            switchInCurve: AppAnimations.bounceOut,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              icon,
              key: ValueKey(icon.codePoint),
              size: 20,
              color: iconColor ?? Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// 工具菜单项（底部弹出面板中的每行）
class ToolMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const ToolMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // 图标框
            AnimatedContainer(
              duration: AppAnimations.durationMedium,
              curve: AppAnimations.easeOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            // 标题 + 副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: AppAnimations.durationMedium,
                    curve: AppAnimations.easeOut,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isActive ? theme.colorScheme.primary : null,
                    ),
                    child: Text(label),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 激活指示点（淡入出现）
            AnimatedOpacity(
              duration: AppAnimations.durationMedium,
              opacity: isActive ? 1.0 : 0.0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
