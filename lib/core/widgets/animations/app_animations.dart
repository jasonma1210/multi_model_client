/// 统一动画规范
///
/// 全 App 共用的动画时长、缓动曲线常量。
/// 集中管理避免散落 magic number，便于统一调整观感。
///
/// 设计目标：
/// - **快**：交互反馈类动画 ≤ 200ms，避免用户感觉迟钝
/// - **柔**：优先使用 Curves.easeOutCubic / easeInOutCubic，避免线性动画的机械感
/// - **可访问**：通过 [AppAnimations.enabled] 全局开关尊重系统"减少动效"设置
library;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// 应用级动画常量
class AppAnimations {
  AppAnimations._();

  // ─── 基础时长 ───────────────────────────────────────────

  /// 极快（按下涟漪、图标切换），约 80ms
  static const Duration durationFast = Duration(milliseconds: 80);

  /// 快速（按钮按压反馈、颜色过渡），约 150ms
  static const Duration durationMedium = Duration(milliseconds: 150);

  /// 标准（卡片淡入、列表项入场），约 250ms
  static const Duration durationNormal = Duration(milliseconds: 250);

  /// 慢（页面切换、Hero 过渡），约 320ms
  static const Duration durationSlow = Duration(milliseconds: 320);

  /// 极慢（首次启动、引导），约 500ms
  static const Duration durationXSlow = Duration(milliseconds: 500);

  // ─── 缓动曲线 ───────────────────────────────────────────

  /// 通用 ease-out，元素进入动画首选
  static const Curve easeOut = Curves.easeOutCubic;

  /// 通用 ease-in，元素退出动画首选
  static const Curve easeIn = Curves.easeInCubic;

  /// 通用 ease-in-out，元素变换首选
  static const Curve easeInOut = Curves.easeInOutCubic;

  /// 回弹曲线，用于按压回弹
  static const Curve bounceOut = Curves.easeOutBack;

  /// 弹性曲线，用于弹窗/Toast 出现
  static const Curve elasticOut = Curves.elasticOut;

  // ─── 距离/幅度 ──────────────────────────────────────────

  /// 元素淡入滑入时的水平/垂直位移距离
  static const double slideDistance = 16.0;

  /// 按压时的缩放幅度（0.96 = 缩小 4%）
  static const double pressScale = 0.96;

  // ─── 可访问性 ───────────────────────────────────────────

  /// 是否启用动画（系统级"减少动效"开关）
  ///
  /// 监听 [WidgetsBindingObserver.didChangeAppLifecycleState] /
  /// [AccessibilityFeatures.disableAnimations] 时由调用方刷新本值。
  static final ValueNotifier<bool> enabled =
      ValueNotifier<bool>(_readReduceMotionFromSystem());

  static bool _readReduceMotionFromSystem() {
    // SchedulerBinding 在 main() 完成后才可用；构造函数可能先于 runApp 执行，
    // 因此仅在可用时探测，失败则默认开启。
    try {
      final binding = SchedulerBinding.instance;
      return binding.platformDispatcher.accessibilityFeatures.disableAnimations;
    } catch (_) {
      return true;
    }
  }

  /// 调试用：手动覆盖动画开关
  @visibleForTesting
  static void debugSetEnabled(bool value) {
    enabled.value = value;
  }
}
