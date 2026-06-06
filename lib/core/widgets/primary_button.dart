import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 主要按钮组件
///
/// 基于 DESIGN.md 规范，提供统一的主要按钮样式：
/// - 科技蓝背景色
/// - 支持加载状态
/// - 支持图标
/// - 涟漪+按压缩放动画
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isLoading ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: width,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.accentPrimary.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            elevation: 0,
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingM + 2,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: AppTheme.spacingS),
                    ],
                    Text(text),
                  ],
                ),
        ),
      ),
    );
  }
}
