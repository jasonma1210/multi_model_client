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

/// Cherry Studio inspired design system — 得物「性冷淡」多平台适配版
class AppTheme {
  // =====================================================
  // 设计令牌 - 得物风「性冷淡」中性调色板
  // =====================================================

  /// 主强调色：深沉中性 - 非纯黑，微带暖感
  static const Color _primaryColor = Color(0xFF1A1A1A);
  /// 次要强调色：中灰
  static const Color _accentColor = Color(0xFF6B6B6B);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _errorColor = Color(0xFFEF4444);

  // =====================================================
  // 深色主题调色板 - 得物深色风
  // =====================================================

  static const Color _darkBg = Color(0xFF111111);        // 最深背景（近纯黑）
  static const Color _darkSurface = Color(0xFF181818);   // 卡片/表面
  static const Color _darkCard = Color(0xFF1E1E1E);      // 卡片内容区
  static const Color _darkBorder = Color(0xFF2A2A2A);    // 极细边框
  static const Color _darkHover = Color(0xFF252525);     // Hover 状态

  // 文字颜色
  static const Color _darkTextPrimary = Color(0xFFE8E8E8);    // 主要文字
  static const Color _darkTextSecondary = Color(0xFF999999);  // 次要文字
  static const Color _darkTextMuted = Color(0xFF555555);      // 暗示文字

  // =====================================================
  // 浅色主题调色板 - 得物浅色风
  // =====================================================

  static const Color _lightBg = Color(0xFFF7F7F7);       // 背景（冷白）
  static const Color _lightSurface = Color(0xFFFFFFFF);  // 表面
  static const Color _lightCard = Color(0xFFFFFFFF);     // 卡片
  static const Color _lightBorder = Color(0xFFEAEAEA);   // 边框

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

  // 圆角系统 - 得物风适中圆角，不过分圆润
  static const double radiusS = 6.0;
  static const double radiusM = 10.0;
  static const double radiusL = 14.0;
  static const double radiusXL = 18.0;
  static const double radiusXXL = 24.0;

  // 阴影 - 极轻，得物风几乎无阴影
  static List<BoxShadow> shadowS = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowL = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // =====================================================
  // 浅色主题
  // =====================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor,
        surface: _lightSurface,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        onError: Colors.white,
        // 得物风：surfaceContainerHighest 用极浅的灰
        surfaceContainerHighest: Color(0xFFF2F2F2),
        surfaceContainerHigh: Color(0xFFF7F7F7),
        outlineVariant: Color(0xFFEAEAEA),
        onSurfaceVariant: Color(0xFF6B6B6B),
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: const BorderSide(color: _lightBorder, width: 1),
        ),
        margin: const EdgeInsets.all(spacingS),
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
          borderSide: const BorderSide(color: Color(0xFF333333), width: 1.5),
        ),
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFFBBBBBB),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
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
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _lightBorder, width: 1.5),
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
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightBorder,
        thickness: 1,
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
        color: Color(0xFF555555),
        size: 20,
      ),
      textTheme: _buildTextTheme(
        primary: const Color(0xFF1A1A1A),
        secondary: const Color(0xFF6B6B6B),
        muted: const Color(0xFFAAAAAA),
      ),
    );
  }

  // =====================================================
  // 深色主题 - 得物深色「冷淡」风
  // =====================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFE8E8E8),    // 深色模式主色：浅灰白（而非蓝色）
        secondary: Color(0xFF888888),
        surface: _darkSurface,
        error: _errorColor,
        onPrimary: Color(0xFF111111),
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFF222222),
        surfaceContainerHigh: Color(0xFF1C1C1C),
        outlineVariant: Color(0xFF2A2A2A),
        onSurfaceVariant: Color(0xFF888888),
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
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
          side: const BorderSide(color: _darkBorder, width: 1),
        ),
        margin: const EdgeInsets.all(spacingS),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: Color(0xFF555555), width: 1.5),
        ),
        filled: true,
        fillColor: _darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        hintStyle: const TextStyle(
          color: _darkTextMuted,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8E8E8),
          foregroundColor: const Color(0xFF111111),
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkTextPrimary,
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
          side: const BorderSide(color: _darkBorder, width: 1.5),
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
        backgroundColor: const Color(0xFFE8E8E8),
        foregroundColor: const Color(0xFF111111),
        elevation: 0,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 1,
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
      iconTheme: const IconThemeData(
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

  /// Model avatar — 得物风：方形圆角，单色背景，简洁字母
  static Widget buildModelAvatar({
    required String modelId,
    double size = 48,
  }) {
    final hash = modelId.hashCode;
    // 得物风调色板：中性色为主，偶尔有低饱和度点缀
    final bgColors = [
      const Color(0xFF2A2A2A),
      const Color(0xFF1E2A2A),
      const Color(0xFF2A1E2A),
      const Color(0xFF2A2A1E),
      const Color(0xFF1E1E2A),
    ];
    final textColors = [
      const Color(0xFFAAAAAA),
      const Color(0xFF7EC8A8),
      const Color(0xFFB89FD4),
      const Color(0xFFD4C87A),
      const Color(0xFF8AB4D4),
    ];
    final idx = hash.abs() % bgColors.length;

    final initials = modelId
        .split(RegExp(r'[-_/]'))
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColors[idx],
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: textColors[idx].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? 'AI' : initials,
          style: TextStyle(
            color: textColors[idx],
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
      ),
    );
  }

  /// Nav item（侧边栏）
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
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? _darkHover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(radiusM),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? _darkTextPrimary
                    : _darkTextSecondary,
              ),
              const SizedBox(width: spacingM),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? _darkTextPrimary
                      : _darkTextSecondary,
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
        border: Border.all(color: _darkBorder),
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
                color: _darkBorder,
                borderRadius: BorderRadius.circular(radiusS),
              ),
              child: Text(
                language,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _darkTextSecondary,
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
}
