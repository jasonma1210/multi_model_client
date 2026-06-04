/// 骨架屏加载组件库
///
/// 提供优雅的内容占位加载效果：
/// - [Shimmer] 基础微光动画容器
/// - [SkeletonLine] 单行文字骨架
/// - [SkeletonCircle] 圆形骨架（头像等）
/// - [SkeletonCard] 卡片骨架
/// - [SkeletonListTile] 列表项骨架
/// - [SessionListSkeleton] 会话列表骨架屏
/// - [SettingsSkeleton] 设置页骨架屏
///
/// 设计要点：
/// - 使用线性渐变模拟微光效果
/// - 自动适配深色/浅色主题
/// - 遵循 [AppAnimations] 全局开关
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_animations.dart';

/// 微光动画容器
///
/// 将任意 [child] 包裹后获得微光闪烁效果。
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark ? const Color(0xFF1C1E2A) : const Color(0xFFE5E7EB));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF2A2D3A) : const Color(0xFFF3F4F6));

    return ValueListenableBuilder<bool>(
      valueListenable: AppAnimations.enabled,
      builder: (context, enabled, _) {
        if (!enabled) return widget.child;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: const Alignment(-1.0, -0.3),
                  end: const Alignment(1.0, 0.3),
                  colors: [base, highlight, base],
                  stops: [
                    _controller.value - 0.3,
                    _controller.value,
                    _controller.value + 0.3,
                  ].map((s) => s.clamp(0.0, 1.0)).toList(),
                ).createShader(bounds);
              },
              child: child,
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 单行文字骨架
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E2A) : const Color(0xFFE5E7EB),
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// 圆形骨架（头像等）
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E2A) : const Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// 方形圆角骨架（图标等）
class SkeletonRounded extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonRounded({
    super.key,
    this.width = 40,
    this.height = 40,
    this.radius = AppTheme.radiusM,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E2A) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// 卡片骨架
class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets margin;

  const SkeletonCard({
    super.key,
    this.height = 120,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingL,
      vertical: AppTheme.spacingS,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer(
      child: Container(
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E2A) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
      ),
    );
  }
}

/// 列表项骨架（带头像 + 两行文字）
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        children: [
          const SkeletonCircle(size: 40),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 14,
                ),
                const SizedBox(height: AppTheme.spacingS),
                const SkeletonLine(width: 120, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 会话列表骨架屏
class SessionListSkeleton extends StatelessWidget {
  final int itemCount;

  const SessionListSkeleton({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonListTile(),
    );
  }
}

/// 设置页骨架屏
class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      children: [
        // Section header
        const SkeletonLine(width: 80, height: 12),
        const SizedBox(height: AppTheme.spacingS),
        // Cards
        for (int i = 0; i < 3; i++) ...[
          Shimmer(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1C1E2A)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Row(
                children: [
                  const SkeletonRounded(width: 36, height: 36, radius: 8),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLine(
                          width: 100 + i * 20.0,
                          height: 14,
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        const SkeletonLine(width: 160, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppTheme.spacingXL),
        // Another section
        const SkeletonLine(width: 60, height: 12),
        const SizedBox(height: AppTheme.spacingS),
        for (int i = 0; i < 2; i++) ...[
          Shimmer(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1C1E2A)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Row(
                children: [
                  const SkeletonRounded(width: 36, height: 36, radius: 8),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLine(width: 80 + i * 30.0, height: 14),
                        const SizedBox(height: AppTheme.spacingXS),
                        const SkeletonLine(width: 140, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
