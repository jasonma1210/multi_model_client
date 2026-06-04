import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark); // Default to dark mode

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// ============================================================
// 响应式布局工具
// ============================================================

/// 多平台屏幕尺寸枚举
enum ScreenLayout {
  /// 手机竖屏 < 600px
  mobile,
  /// 平板 600-1024px
  tablet,
  /// 桌面 > 1024px
  desktop,
}

/// 响应式工具类
class ResponsiveLayout {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;

  static ScreenLayout of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) return ScreenLayout.mobile;
    if (width < _tabletBreakpoint) return ScreenLayout.tablet;
    return ScreenLayout.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenLayout.mobile;
  static bool isTablet(BuildContext context) =>
      of(context) == ScreenLayout.tablet;
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenLayout.desktop;

  /// 会话消息列表的水平内边距（根据屏幕尺寸调整）
  static double chatHorizontalPadding(BuildContext context) {
    switch (of(context)) {
      case ScreenLayout.mobile:
        return 16.0;
      case ScreenLayout.tablet:
        return 48.0;
      case ScreenLayout.desktop:
        return 80.0;
    }
  }

  /// 消息气泡的最大宽度比例
  static double messageBubbleMaxWidth(BuildContext context) {
    switch (of(context)) {
      case ScreenLayout.mobile:
        return 0.78;
      case ScreenLayout.tablet:
        return 0.65;
      case ScreenLayout.desktop:
        return 0.60;
    }
  }

  /// 侧边栏宽度（桌面端显示侧边栏）
  static double sidebarWidth(BuildContext context) {
    switch (of(context)) {
      case ScreenLayout.mobile:
        return 0;
      case ScreenLayout.tablet:
        return 240;
      case ScreenLayout.desktop:
        return 280;
    }
  }

  /// 输入框最大宽度（桌面端居中约束）
  static double? inputAreaMaxWidth(BuildContext context) {
    switch (of(context)) {
      case ScreenLayout.mobile:
      case ScreenLayout.tablet:
        return null; // 全宽
      case ScreenLayout.desktop:
        return 900; // 居中约束
    }
  }
}

/// MJ Nexus Design System — 克制科技风多平台适配版
///
/// 设计理念：
/// - 保留得物风的克制与中性基调
/// - 融入科技蓝强调色，增强 AI 客户端定位
/// - 遵循 Material Design 3 规范
/// - 深色/浅色双主题，统一视觉语言
class AppTheme {
  // =====================================================
  // 设计令牌 - 强调色系统（科技蓝）
  // =====================================================

  /// 主强调色：科技蓝
  static const Color accentPrimary = Color(0xFF3B82F6);
  /// 次强调色：靛蓝
  static const Color accentSecondary = Color(0xFF6366F1);
  /// 强调色 Hover 状态
  static const Color accentHover = Color(0xFF2563EB);
  /// 强调色极浅变体（背景用，10% 透明度）
  static const Color accentSubtle = Color(0x1A3B82F6);

  // =====================================================
  // 设计令牌 - 中性色基底
  // =====================================================

  /// 主色：深沉中性 - 非纯黑，微带暖感
  static const Color _primaryColor = Color(0xFF1A1A1A);
  /// 次要色：中灰
  static const Color _accentColor = Color(0xFF6B6B6B);
  static const Color _successColor = Color(0xFF22C55E);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _errorColor = Color(0xFFEF4444);

  // =====================================================
  // 深色主题调色板
  // =====================================================

  static const Color _darkBg = Color(0xFF0F1117);        // 最深背景（微带蓝调）
  static const Color _darkSurface = Color(0xFF161822);   // 卡片/表面
  static const Color _darkCard = Color(0xFF1C1E2A);      // 卡片内容区
  static const Color _darkBorder = Color(0xFF2A2D3A);    // 极细边框
  static const Color _darkHover = Color(0xFF222536);     // Hover 状态
  static const Color _darkActive = Color(0xFF2A3048);    // Active/Selected 状态

  // 文字颜色
  static const Color _darkTextPrimary = Color(0xFFE8EAF0);    // 主要文字
  static const Color _darkTextSecondary = Color(0xFF8B8FA3);  // 次要文字
  static const Color _darkTextMuted = Color(0xFF555770);      // 暗示文字

  // =====================================================
  // 浅色主题调色板
  // =====================================================

  static const Color _lightBg = Color(0xFFF8F9FA);       // 背景（微带蓝调冷白）
  static const Color _lightSurface = Color(0xFFFFFFFF);  // 表面
  static const Color _lightCard = Color(0xFFFFFFFF);     // 卡片
  static const Color _lightBorder = Color(0xFFE5E7EB);   // 边框
  static const Color _lightHover = Color(0xFFF3F4F6);    // Hover 状态

  // =====================================================
  // 设计间距系统 - 4pt 基准
  // =====================================================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;
  static const double spacingXXXL = 48.0;

  // =====================================================
  // 圆角系统
  // =====================================================

  static const double radiusS = 6.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // =====================================================
  // 阴影系统 - 分层阴影
  // =====================================================

  /// 轻微阴影（卡片默认）
  static List<BoxShadow> shadowS = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 中等阴影（悬浮卡片、下拉菜单）
  static List<BoxShadow> shadowM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  /// 重阴影（模态框、弹窗）
  static List<BoxShadow> shadowL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 超重阴影（全屏覆盖层）
  static List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  /// 强调色发光阴影（FAB、主按钮）
  static List<BoxShadow> shadowAccent = [
    BoxShadow(
      color: accentPrimary.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // =====================================================
  // 渐变系统
  // =====================================================

  /// 主渐变（科技蓝到靛蓝）
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
  );

  /// 表面渐变（深色主题微层次）
  static const LinearGradient gradientSurfaceDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C1E2A), Color(0xFF161822)],
  );

  /// 强调渐变（紫粉）
  static const LinearGradient gradientAccent = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  // =====================================================
  // 浅色主题
  // =====================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: accentPrimary,
        secondary: _accentColor,
        surface: _lightSurface,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFFF0F2F5),
        surfaceContainerHigh: Color(0xFFF5F6F8),
        surfaceContainerLow: Color(0xFFFAFBFC),
        outlineVariant: _lightBorder,
        onSurfaceVariant: Color(0xFF6B7280),
      ),
      scaffoldBackgroundColor: _lightBg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _lightSurface,
        foregroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: _lightBorder, width: 0.5),
        ),
        margin: const EdgeInsets.all(spacingS),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        titleTextStyle: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: Color(0xFFD1D5DB),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: accentPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFB0B5BF),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: _lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightBorder,
        thickness: 0.5,
        space: spacingL,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingXS,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF6B7280),
        size: 20,
      ),
      textTheme: _buildTextTheme(
        primary: const Color(0xFF1A1A1A),
        secondary: const Color(0xFF6B7280),
        muted: const Color(0xFF9CA3AF),
      ),
    );
  }

  // =====================================================
  // 深色主题 - 克制科技风
  // =====================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentPrimary,
        secondary: Color(0xFF8B8FA3),
        surface: _darkSurface,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
        onError: Colors.white,
        surfaceContainerHighest: _darkCard,
        surfaceContainerHigh: Color(0xFF1A1E2A),
        surfaceContainerLow: Color(0xFF121520),
        outlineVariant: _darkBorder,
        onSurfaceVariant: _darkTextSecondary,
      ),
      scaffoldBackgroundColor: _darkBg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _darkBg,
        foregroundColor: _darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: BorderSide(color: _darkBorder.withValues(alpha: 0.5), width: 0.5),
        ),
        margin: const EdgeInsets.all(spacingS),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          side: BorderSide(color: _darkBorder.withValues(alpha: 0.3), width: 0.5),
        ),
        titleTextStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _darkCard,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: _darkTextMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkCard,
        contentTextStyle: const TextStyle(
          color: _darkTextPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: BorderSide(color: _darkBorder.withValues(alpha: 0.5), width: 0.5),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: _darkBorder.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: _darkBorder.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: accentPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        hintStyle: TextStyle(
          color: _darkTextMuted,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkTextPrimary,
          side: BorderSide(color: _darkBorder.withValues(alpha: 0.8), width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingXL,
            vertical: spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _darkBorder.withValues(alpha: 0.5),
        thickness: 0.5,
        space: spacingL,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingXS,
        ),
        iconColor: _darkTextSecondary,
        textColor: _darkTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: _darkTextSecondary,
        size: 20,
      ),
      textTheme: _buildTextTheme(
        primary: _darkTextPrimary,
        secondary: _darkTextSecondary,
        muted: _darkTextMuted,
      ),
    );
  }

  /// 构建统一的文字主题（浅/深色共用，颜色参数化）
  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color muted,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: primary,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: primary,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primary,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: primary,
        height: 1.6,
        letterSpacing: 0.1,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: primary,
        height: 1.6,
        letterSpacing: 0.1,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: primary,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: muted,
        letterSpacing: 0.3,
      ),
    );
  }

  // =====================================================
  // HELPER WIDGETS
  // =====================================================

  /// Model avatar — 方形圆角，渐变背景，简洁字母
  static Widget buildModelAvatar({
    required String modelId,
    double size = 48,
  }) {
    final hash = modelId.hashCode;
    final gradients = [
      [const Color(0xFF3B82F6), const Color(0xFF6366F1)], // 蓝-靛
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // 紫-粉
      [const Color(0xFF22C55E), const Color(0xFF14B8A6)], // 绿-青
      [const Color(0xFFF59E0B), const Color(0xFFF97316)], // 黄-橙
      [const Color(0xFF06B6D4), const Color(0xFF3B82F6)], // 天蓝-蓝
      [const Color(0xFFEF4444), const Color(0xFFF43F5E)], // 红-玫红
    ];
    final idx = hash.abs() % gradients.length;

    final initials = modelId
        .split(RegExp(r'[-_/]'))
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients[idx],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? 'AI' : initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size / 2.8,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Status indicator
  static Widget buildStatusIndicator({
    required bool isActive,
    double size = 8,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive ? _successColor : _darkTextMuted,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [BoxShadow(color: _successColor.withValues(alpha: 0.4), blurRadius: 4)]
            : null,
      ),
    );
  }

  /// Nav item（侧边栏）— 支持主题自适应
  static Widget buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radiusM),
        hoverColor: _darkHover,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          decoration: BoxDecoration(
            color: isSelected ? _darkActive : Colors.transparent,
            borderRadius: BorderRadius.circular(radiusM),
            border: isSelected
                ? Border.all(color: accentPrimary.withValues(alpha: 0.15), width: 0.5)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? accentPrimary : _darkTextSecondary,
              ),
              const SizedBox(width: spacingM),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? _darkTextPrimary : _darkTextSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Code block
  static Widget buildCodeBlock({
    required String code,
    String? language,
  }) {
    return Container(
      padding: const EdgeInsets.all(spacingM),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(radiusM),
        border: Border.all(color: _darkBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          if (language != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: spacingS,
                vertical: spacingXS,
              ),
              decoration: BoxDecoration(
                color: accentPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(radiusS),
              ),
              child: Text(
                language,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: spacingM),
          ],
          Expanded(
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: _darkTextPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 装饰工具方法
  // =====================================================

  /// 设置页面图标容器（带强调色背景）
  static BoxDecoration settingsIconDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: accentPrimary.withValues(alpha: isDark ? 0.15 : 0.1),
      borderRadius: BorderRadius.circular(radiusS),
    );
  }

  /// 玻璃态卡片装饰（深色主题）
  static BoxDecoration glassCardDecoration({
    required bool isDark,
    double blur = 10,
  }) {
    return BoxDecoration(
      color: (isDark ? _darkCard : _lightCard).withValues(alpha: isDark ? 0.7 : 0.9),
      borderRadius: BorderRadius.circular(radiusL),
      border: Border.all(
        color: (isDark ? _darkBorder : _lightBorder).withValues(alpha: 0.3),
        width: 0.5,
      ),
    );
  }

  /// 获取当前主题下的强调色
  static Color accent(BuildContext context) => accentPrimary;

  /// 获取当前主题下的表面色
  static Color surfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkSurface
        : _lightSurface;
  }

  /// 获取当前主题下的卡片色
  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkCard
        : _lightCard;
  }

  /// 获取当前主题下的边框色
  static Color borderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBorder
        : _lightBorder;
  }

  /// 获取当前主题下的 Hover 色
  static Color hoverColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkHover
        : _lightHover;
  }
}
