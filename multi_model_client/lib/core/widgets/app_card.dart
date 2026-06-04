import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// 统一卡片组件
///
/// 基于 DESIGN.md 规范，提供统一的卡片样式：
/// - 可配置边框、阴影、悬停效果
/// - 支持点击交互
/// - 自动适配深色/浅色主题
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showBorder;
  final bool showShadow;
  final bool showHover;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.showBorder = true,
    this.showShadow = false,
    this.showHover = false,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          margin: margin ?? const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: showBorder
                ? Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.5)
                        : AppColors.lightBorder.withValues(alpha: 0.5),
                    width: 0.5,
                  )
                : null,
            boxShadow: showShadow
                ? (isDark ? AppTheme.shadowM : AppTheme.shadowS)
                : null,
          ),
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingL),
          child: child,
        ),
      ),
    );
  }
}
