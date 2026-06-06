/// 按压反馈组件库
///
/// 提供统一的"按下-回弹"反馈效果：
/// - [Pressable] 通用按压容器（任何子元素都可获得按压缩放 + 透明度反馈）
/// - [PressableScale] 仅缩放，不改变颜色（用于已有 InkWell 的场景）
///
/// 设计要点：
/// - 缩放反馈（0.96）使用 Curves.easeOutBack，提供"按下去、回弹上来"的物理感
/// - 同时叠加透明度（按下时 0.85）强化"被按下"的视觉确认
/// - 完全可通过 [AppAnimations.enabled] 关闭（无障碍/减少动效模式）
library;

import 'package:flutter/material.dart';

import 'app_animations.dart';

/// 通用按压反馈容器
///
/// 将任意 [child] 包裹后获得：
/// - 按下：缩放至 96% + 透明度 0.85
/// - 抬起：恢复原状（带回弹）
///
/// ```dart
/// Pressable(
///   onTap: () => doSomething(),
///   child: MyButton(),
/// )
/// ```
class Pressable extends StatefulWidget {
  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 自定义按压缩放值，默认 [AppAnimations.pressScale]
  final double scale;

  /// 按下时透明度（0.0~1.0）
  final double pressedOpacity;

  /// 是否启用反馈（外部已处理点击时可关闭以避免双重反馈）
  final bool enabled;

  /// 自定义边框圆角（用于 [Material] 涟漪的范围）
  final BorderRadius? borderRadius;

  /// 子组件
  final Widget child;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = AppAnimations.pressScale,
    this.pressedOpacity = 0.85,
    this.enabled = true,
    this.borderRadius,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  @override
  Widget build(BuildContext context) {
    // 无回调或无动画：直接渲染子组件
    if (!_interactive) {
      return widget.child;
    }

    return ValueListenableBuilder<bool>(
      valueListenable: AppAnimations.enabled,
      builder: (context, animationsEnabled, _) {
        // 关闭动效时使用最低成本反馈（仅 InkWell）
        if (!animationsEnabled) {
          return _buildInkWell();
        }

        return GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _pressed ? widget.scale : 1.0,
            duration: AppAnimations.durationMedium,
            curve: AppAnimations.bounceOut,
            child: AnimatedOpacity(
              opacity: _pressed ? widget.pressedOpacity : 1.0,
              duration: AppAnimations.durationFast,
              curve: AppAnimations.easeOut,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInkWell() {
    return Material(
      color: Colors.transparent,
      borderRadius: widget.borderRadius,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        borderRadius: widget.borderRadius,
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool value) {
    if (!mounted) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
}
