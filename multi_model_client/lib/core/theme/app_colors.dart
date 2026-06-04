/// MJ Nexus 色彩系统 - 与 AppTheme 统一的设计令牌
///
/// 设计理念：
/// - 与 AppTheme 保持色彩一致性
/// - 提供便捷的上下文感知色彩访问方法
/// - 渐变色增强视觉层次
///
/// @author JianMa
/// @version 2.0.0 — 与 AppTheme 统一
library;

import 'package:flutter/material.dart';

import 'app_theme.dart';

/// 应用色彩系统（与 AppTheme 统一）
class AppColors {
  AppColors._();

  // =====================================================
  // 深色主题 — 与 AppTheme 保持一致
  // =====================================================

  /// 深邃背景色（微带蓝调）
  static const Color darkBackground = Color(0xFF0F1117);
  
  /// 表面色（卡片、面板）
  static const Color darkSurface = Color(0xFF161822);
  
  /// 卡片色
  static const Color darkCard = Color(0xFF1C1E2A);
  
  /// 边框色
  static const Color darkBorder = Color(0xFF2A2D3A);
  
  /// Hover 状态色
  static const Color darkHover = Color(0xFF222536);
  
  /// 主文字色
  static const Color darkTextPrimary = Color(0xFFE8EAF0);
  
  /// 次文字色
  static const Color darkTextSecondary = Color(0xFF8B8FA3);
  
  /// 暗示文字色
  static const Color darkTextMuted = Color(0xFF555770);

  // =====================================================
  // 浅色主题 — 与 AppTheme 保持一致
  // =====================================================

  /// 背景色（微带蓝调冷白）
  static const Color lightBackground = Color(0xFFF8F9FA);
  
  /// 表面色
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  /// 卡片色
  static const Color lightCard = Color(0xFFFFFFFF);
  
  /// 边框色
  static const Color lightBorder = Color(0xFFE5E7EB);
  
  /// 主文字色
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  
  /// 次文字色
  static const Color lightTextSecondary = Color(0xFF6B7280);
  
  /// 暗示文字色
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  
  /// Hover 状态色
  static const Color lightHover = Color(0xFFF3F4F6);

  // =====================================================
  // 强调色（与 AppTheme.accentPrimary 统一）
  // =====================================================

  /// 主强调色（科技蓝）
  static const Color accentPrimary = AppTheme.accentPrimary;
  
  /// 次强调色（靛蓝）
  static const Color accentSecondary = AppTheme.accentSecondary;
  
  /// 强调色 Hover 状态
  static const Color accentHover = AppTheme.accentHover;
  
  /// 强调色浅色变体（背景用）
  static const Color accentLight = AppTheme.accentSubtle;

  // =====================================================
  // 状态色
  // =====================================================

  /// 成功色
  static const Color success = Color(0xFF22C55E);
  
  /// 成功色浅色变体
  static const Color successLight = Color(0x1A22C55E);
  
  /// 警告色
  static const Color warning = Color(0xFFF59E0B);
  
  /// 警告色浅色变体
  static const Color warningLight = Color(0x1AF59E0B);
  
  /// 错误色
  static const Color error = Color(0xFFEF4444);
  
  /// 错误色浅色变体
  static const Color errorLight = Color(0x1AEF4444);
  
  /// 信息色
  static const Color info = Color(0xFF3B82F6);
  
  /// 信息色浅色变体
  static const Color infoLight = Color(0x1A3B82F6);

  // =====================================================
  // 渐变色（与 AppTheme 统一）
  // =====================================================

  /// 主渐变（科技蓝到靛蓝）
  static const LinearGradient primaryGradient = AppTheme.gradientPrimary;

  /// 表面渐变（深色主题微层次）
  static const LinearGradient surfaceGradient = AppTheme.gradientSurfaceDark;

  /// 强调渐变（紫粉）
  static const LinearGradient accentGradient = AppTheme.gradientAccent;

  /// 成功渐变
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF10B981)],
  );

  /// 警告渐变
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
  );

  /// 错误渐变
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // =====================================================
  // 模型头像渐变色（12种）
  // =====================================================

  static const List<LinearGradient> modelAvatarGradients = [
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), // 靛蓝-紫
    LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)]), // 蓝-浅蓝
    LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF4ADE80)]), // 绿-浅绿
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]), // 黄-浅黄
    LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF87171)]), // 红-浅红
    LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF472B6)]), // 粉-浅粉
    LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF2DD4BF)]), // 青-浅青
    LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)]), // 紫-浅紫
    LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)]), // 橙-浅橙
    LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)]), // 天蓝-浅天蓝
    LinearGradient(colors: [Color(0xFF84CC16), Color(0xFFA3E635)]), // 青绿-浅青绿
    LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]), // 玫红-浅玫红
  ];

  // =====================================================
  // 工具方法
  // =====================================================

  /// 根据主题模式获取背景色
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  /// 根据主题模式获取表面色
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }

  /// 根据主题模式获取卡片色
  static Color getCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }

  /// 根据主题模式获取边框色
  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }

  /// 根据主题模式获取主文字色
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  /// 根据主题模式获取次文字色
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// 根据模型名称获取渐变色
  static LinearGradient getModelGradient(String modelName) {
    final index = modelName.hashCode.abs() % modelAvatarGradients.length;
    return modelAvatarGradients[index];
  }
}
