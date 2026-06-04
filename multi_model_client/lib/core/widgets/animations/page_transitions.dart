/// 页面切换过渡动画
///
/// 提供：
/// - [fadeThroughPageRoute]：淡入淡出（适合模态/详情页）
/// - [slideUpPageRoute]：从底部滑入（适合底部弹窗/全屏页面）
/// - [sharedAxisPageRoute]：共享轴过渡（适合同级页面间切换）
/// - [pageRouteBuilder]：通用工厂方法
///
/// 使用方式：
/// ```dart
/// Navigator.push(
///   context,
///   fadeThroughPageRoute(builder: (_) => DetailPage()),
/// );
/// ```
library;

import 'package:flutter/material.dart';

import 'app_animations.dart';

/// 通用 PageRoute 工厂
PageRoute<T> pageRouteBuilder<T>({
  required WidgetBuilder builder,
  Duration duration = AppAnimations.durationSlow,
  Duration reverseDuration = AppAnimations.durationNormal,
  RouteTransitionsBuilder? transitionsBuilder,
  bool fullscreenDialog = false,
  bool opaque = true,
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: transitionsBuilder ??
        (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
    fullscreenDialog: fullscreenDialog,
    opaque: opaque,
  );
}

/// 淡入淡出过渡
PageRoute<T> fadeThroughPageRoute<T>({
  required WidgetBuilder builder,
  Duration duration = AppAnimations.durationSlow,
  RouteTransitionsBuilder? transitionsBuilder,
  bool fullscreenDialog = false,
}) {
  return pageRouteBuilder<T>(
    builder: builder,
    duration: duration,
    fullscreenDialog: fullscreenDialog,
    transitionsBuilder:
        transitionsBuilder ??
        (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: AppAnimations.easeOut),
            child: child,
          );
        },
  );
}

/// 从底部滑入（适合底部弹窗/全屏页面）
PageRoute<T> slideUpPageRoute<T>({
  required WidgetBuilder builder,
  Duration duration = AppAnimations.durationSlow,
  RouteTransitionsBuilder? transitionsBuilder,
  bool fullscreenDialog = false,
}) {
  return pageRouteBuilder<T>(
    builder: builder,
    duration: duration,
    fullscreenDialog: fullscreenDialog,
    transitionsBuilder:
        transitionsBuilder ??
        (context, animation, secondaryAnimation, child) {
          final tween = Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          );
          return SlideTransition(
            position: tween.chain(
              CurveTween(curve: AppAnimations.easeOut),
            ).animate(animation),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: AppAnimations.easeOut),
              child: child,
            ),
          );
        },
  );
}

/// 共享轴过渡（水平）：退出页面左滑 + 进入页面右滑
///
/// Material Design 3 风格的"shared axis"过渡简化版。
PageRoute<T> sharedAxisPageRoute<T>({
  required WidgetBuilder builder,
  Duration duration = AppAnimations.durationSlow,
  bool horizontal = true,
}) {
  return pageRouteBuilder<T>(
    builder: builder,
    duration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final inTween = Tween<Offset>(
        begin: horizontal ? const Offset(0.15, 0) : const Offset(0, 0.15),
        end: Offset.zero,
      );
      final outTween = Tween<Offset>(
        begin: Offset.zero,
        end: horizontal ? const Offset(-0.15, 0) : const Offset(0, -0.15),
      );
      return SlideTransition(
        position: inTween
            .chain(CurveTween(curve: AppAnimations.easeOut))
            .animate(animation),
        child: SlideTransition(
          position: outTween
              .chain(CurveTween(curve: AppAnimations.easeOut))
              .animate(secondaryAnimation),
          child: FadeTransition(opacity: animation, child: child),
        ),
      );
    },
  );
}

// ============================================================
// 模态框专用动画
// ============================================================

/// 缩放+淡入过渡（适合对话框）
///
/// 对话框从 95% 缩放 + 淡入出现，配合遮罩层的淡入效果。
PageRoute<T> scaleFadePageRoute<T>({
  required WidgetBuilder builder,
  Duration duration = const Duration(milliseconds: 250),
}) {
  return pageRouteBuilder<T>(
    builder: builder,
    duration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scaleTween = Tween<double>(begin: 0.95, end: 1.0)
          .chain(CurveTween(curve: AppAnimations.easeOut));
      return ScaleTransition(
        scale: scaleTween.animate(animation),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppAnimations.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// 从右侧滑入（适合详情页/子页面）
PageRoute<T> slideFromRightPageRoute<T>({
  required WidgetBuilder builder,
  Duration duration = AppAnimations.durationSlow,
}) {
  return pageRouteBuilder<T>(
    builder: builder,
    duration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final inTween = Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: AppAnimations.easeOut));
      return SlideTransition(
        position: inTween.animate(animation),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppAnimations.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// 模态框过渡动画构建器（用于 showDialog 的 transitionBuilder）
///
/// 用法：
/// ```dart
/// showDialog(
///   context: context,
///   builder: (ctx) => MyDialog(),
///   // 或者用 showGeneralDialog 获得更多控制
/// );
/// ```
Widget modalTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final scaleTween = Tween<double>(begin: 0.95, end: 1.0)
      .chain(CurveTween(curve: AppAnimations.easeOut));
  return ScaleTransition(
    scale: scaleTween.animate(animation),
    child: FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AppAnimations.easeOut),
      child: child,
    ),
  );
}

/// 底部弹窗过渡动画构建器（用于 showModalBottomSheet 的 transitionBuilder）
Widget bottomSheetTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final slideTween = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).chain(CurveTween(curve: AppAnimations.easeOut));
  return SlideTransition(
    position: slideTween.animate(animation),
    child: FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: AppAnimations.easeOut),
      child: child,
    ),
  );
}

/// 显示增强动画的对话框
///
/// 替代 showDialog，自动应用缩放+淡入动画。
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: modalTransitionBuilder,
  );
}

/// 显示增强动画的底部弹窗
///
/// 替代 showModalBottomSheet，自动应用滑入+淡入动画。
Future<T?> showAnimatedBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    builder: builder,
  );
}
