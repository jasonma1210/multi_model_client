/// 微交互动画组件库
///
/// - [Pulse]：脉冲（Loading、提示强调）
/// - [HoverScale]：Hover 时缩放高亮（仅支持指针设备的平台：桌面/Web）
/// - [RotatingIcon]：持续旋转（适合录音中、加载中）
/// - [RotatingIconOnce]：点击后旋转一圈
/// - [Shake]：抖动（错误/警告反馈）
library;

import 'package:flutter/material.dart';

import 'app_animations.dart';

/// 脉冲动画（透明度 + 缩放）
class Pulse extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxOpacity;

  const Pulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.minScale = 0.95,
    this.maxOpacity = 0.6,
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = AppAnimations.enabled.value ? _controller.value : 0.0;
        return Opacity(
          opacity: 1.0 - (1.0 - widget.maxOpacity) * t,
          child: Transform.scale(
            scale: widget.minScale + (1.0 - widget.minScale) * t,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Hover 缩放（仅支持指针设备的平台：桌面/Web）
class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const HoverScale({
    super.key,
    required this.child,
    this.scale = 1.05,
    this.duration = AppAnimations.durationMedium,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    // 触屏平台：HoverScale 退化为 InkWell
    final isPointerSupported =
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.fuchsia;

    if (!isPointerSupported) {
      if (widget.onTap == null) return widget.child;
      return Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: ValueListenableBuilder<bool>(
        valueListenable: AppAnimations.enabled,
        builder: (context, enabled, _) {
          if (!enabled) return widget.child;
          return AnimatedScale(
            scale: _hovering ? widget.scale : 1.0,
            duration: widget.duration,
            curve: AppAnimations.easeOut,
            child: widget.onTap == null
                ? widget.child
                : GestureDetector(
                    onTap: widget.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: widget.child,
                  ),
          );
        },
      ),
    );
  }
}

/// 持续旋转（适合"加载中"、"录音中"）
class RotatingIcon extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool clockwise;

  const RotatingIcon({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.clockwise = true,
  });

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
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
    return ValueListenableBuilder<bool>(
      valueListenable: AppAnimations.enabled,
      builder: (context, enabled, _) {
        if (!enabled) return widget.child;
        return RotationTransition(
          turns: _controller,
          child: widget.child,
        );
      },
    );
  }
}

/// 点击后旋转一圈
class RotatingIconOnce extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const RotatingIconOnce({
    super.key,
    required this.child,
    this.duration = AppAnimations.durationSlow,
  });

  @override
  State<RotatingIconOnce> createState() => _RotatingIconOnceState();
}

class _RotatingIconOnceState extends State<RotatingIconOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.forward(from: 0),
      behavior: HitTestBehavior.opaque,
      child: ValueListenableBuilder<bool>(
        valueListenable: AppAnimations.enabled,
        builder: (context, enabled, _) {
          if (!enabled) return widget.child;
          return RotationTransition(turns: _controller, child: widget.child);
        },
      ),
    );
  }
}

/// 抖动（错误/警告反馈）
class Shake extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final bool trigger;

  const Shake({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.offset = 8.0,
    this.trigger = false,
  });

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppAnimations.enabled,
      builder: (context, enabled, _) {
        if (!enabled) return widget.child;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final dx = _shakeOffset(_controller.value, widget.offset);
            return Transform.translate(
              offset: Offset(dx, 0),
              child: child,
            );
          },
          child: widget.child,
        );
      },
    );
  }

  /// 衰减正弦波：t=0 → 0；t=1 → 0；中间衰减
  double _shakeOffset(double t, double amplitude) {
    if (t == 0 || t == 1) return 0;
    return amplitude *
        (1 - t) *
        (t * 24).remainder(2) *
        ((t * 24) % 2 < 1 ? 1 : -1);
  }
}
