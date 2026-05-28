import 'package:flutter/material.dart';

/// 全局 SnackBar 辅助方法
class SnackBarHelper {
  /// 显示 SnackBar（默认 1.5 秒后自动关闭）
  static void show(BuildContext context, String message, {
    Color? backgroundColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示成功 SnackBar（绿色）
  static void showSuccess(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.green);
  }

  /// 显示错误 SnackBar（红色）
  static void showError(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.red);
  }

  /// 显示警告 SnackBar（橙色）
  static void showWarning(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.orange);
  }
}