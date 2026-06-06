/// 元素出现/消失动画组件库
///
/// 提供 4 种入场动画 + 1 种通用包装：
/// - [FadeIn]：纯淡入
/// - [FadeInSlide]：淡入 + 滑入（带方向）
/// - [FadeInScale]：淡入 + 缩放
/// - [AnimatedAppear]：根据 `show` 状态自动播放出现/消失
///
/// 所有动画均：
/// - 遵循 [AppAnimations] 的统一时长/曲线
/// - 默认按 [ListItemStaggered] 模式支持列表错峰入场
/// - 支持全局开关（[AppAnimations.enabled]）
library;

import 'package:flutter/material.dart';

import 'app_animations.dart';

/// 淡入动画
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.durationNormal,
  });

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _opacity = CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
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
        return FadeTransition(opacity: _opacity, child: widget.child);
      },
    );
  }
}

/// 淡入 + 滑入方向
enum SlideDirection { up, down, left, right }

/// 淡入 + 滑入
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final SlideDirection direction;
  final double distance;

  const FadeInSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.durationNormal,
    this.direction = SlideDirection.up,
    this.distance = AppAnimations.slideDistance,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _opacity = CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut);

    final begin = switch (widget.direction) {
      SlideDirection.up => Offset(0, widget.distance),
      SlideDirection.down => Offset(0, -widget.distance),
      SlideDirection.left => Offset(widget.distance, 0),
      SlideDirection.right => Offset(-widget.distance, 0),
    };
    _offset = Tween<Offset>(begin: begin, end: Offset.zero)
        .chain(CurveTween(curve: AppAnimations.easeOut))
        .animate(_controller);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
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
        return SlideTransition(
          position: _offset,
          child: FadeTransition(opacity: _opacity, child: widget.child),
        );
      },
    );
  }
}

/// 淡入 + 缩放
class FadeInScale extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginScale;

  const FadeInScale({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.durationNormal,
    this.beginScale = 0.92,
  });

  @override
  State<FadeInScale> createState() => _FadeInScaleState();
}

class _FadeInScaleState extends State<FadeInScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _opacity = CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut);
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0)
        .chain(CurveTween(curve: AppAnimations.bounceOut))
        .animate(_controller);
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
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
        return FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(scale: _scale, child: widget.child),
        );
      },
    );
  }
}

/// 根据 `show` 状态播放出现/消失动画
///
/// 用法：
/// ```dart
/// AnimatedAppear(
///   show: isVisible,
///   child: MyWidget(),
/// )
/// ```
class AnimatedAppear extends StatefulWidget {
  final bool show;
  final Widget child;
  final Duration duration;
  final SlideDirection slideDirection;
  final double slideDistance;

  const AnimatedAppear({
    super.key,
    required this.show,
    required this.child,
    this.duration = AppAnimations.durationNormal,
    this.slideDirection = SlideDirection.up,
    this.slideDistance = AppAnimations.slideDistance,
  });

  @override
  State<AnimatedAppear> createState() => _AnimatedAppearState();
}

class _AnimatedAppearState extends State<AnimatedAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      value: widget.show ? 1.0 : 0.0,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut);
    final begin = switch (widget.slideDirection) {
      SlideDirection.up => Offset(0, widget.slideDistance),
      SlideDirection.down => Offset(0, -widget.slideDistance),
      SlideDirection.left => Offset(widget.slideDistance, 0),
      SlideDirection.right => Offset(-widget.slideDistance, 0),
    };
    _offset = Tween<Offset>(begin: begin, end: Offset.zero)
        .chain(CurveTween(curve: AppAnimations.easeOut))
        .animate(_controller);
    if (widget.show) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedAppear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.show != widget.show) {
      if (widget.show) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
        if (!enabled) {
          return widget.show ? widget.child : const SizedBox.shrink();
        }
        return SlideTransition(
          position: _offset,
          child: FadeTransition(opacity: _opacity, child: widget.child),
        );
      },
    );
  }
}

/// 列表项错峰入场
///
/// 用法：
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, i) => StaggeredListItem(
///     index: i,
///     child: MyItem(items[i]),
///   ),
/// )
/// ```
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration itemDelay;
  final Duration duration;
  final SlideDirection direction;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = Duration.zero,
    this.itemDelay = const Duration(milliseconds: 40),
    this.duration = AppAnimations.durationNormal,
    this.direction = SlideDirection.up,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      delay: baseDelay + itemDelay * index,
      duration: duration,
      direction: direction,
      child: child,
    );
  }
}
