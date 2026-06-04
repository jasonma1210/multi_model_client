# MJ Nexus 设计系统迁移指南

本指南帮助将现有代码迁移到新的统一设计系统。

---

## 1. 色彩系统统一

### 问题
现有两套冲突的色彩系统：
- `app_theme.dart`（得物风）：纯中性黑主色，无彩色强调色
- `app_colors.dart`（科技蓝风）：科技蓝强调色，完整状态色系统

### 解决方案

#### 步骤 1：更新 app_colors.dart
将 `app_colors.dart` 更新为统一的设计令牌系统：

```dart
/// MJ Nexus 统一色彩系统
/// 基于 Linear 设计系统，融合得物风克制感和科技蓝强调色
class AppColors {
  AppColors._();

  // =====================================================
  // 深色主题（Dark Theme）
  // =====================================================

  /// 页面背景，最深色
  static const Color darkBackground = Color(0xFF0F1117);
  
  /// 卡片、面板背景
  static const Color darkSurface = Color(0xFF161822);
  
  /// 卡片内容区
  static const Color darkCard = Color(0xFF1C1E2A);
  
  /// 边框、分隔线
  static const Color darkBorder = Color(0xFF2A2D3A);
  
  /// Hover 状态背景
  static const Color darkHover = Color(0xFF222536);
  
  /// Active 状态背景
  static const Color darkActive = Color(0xFF2A2D3A);

  // 文字颜色（深色主题）

  /// 主要文字，标题
  static const Color darkTextPrimary = Color(0xFFE8EAF0);
  
  /// 次要文字，描述
  static const Color darkTextSecondary = Color(0xFF8B8FA3);
  
  /// 暗示文字，占位符
  static const Color darkTextMuted = Color(0xFF555570);
  
  /// 反色文字（用于浅色按钮上）
  static const Color darkTextInverse = Color(0xFF0F1117);

  // =====================================================
  // 浅色主题（Light Theme）
  // =====================================================

  /// 页面背景
  static const Color lightBackground = Color(0xFFF8F9FA);
  
  /// 卡片、面板背景
  static const Color lightSurface = Color(0xFFFFFFFF);
  
  /// 卡片内容区
  static const Color lightCard = Color(0xFFFFFFFF);
  
  /// 边框、分隔线
  static const Color lightBorder = Color(0xFFE5E7EB);
  
  /// Hover 状态背景
  static const Color lightHover = Color(0xFFF3F4F6);
  
  /// Active 状态背景
  static const Color lightActive = Color(0xFFE5E7EB);

  // 文字颜色（浅色主题）

  /// 主要文字，标题
  static const Color lightTextPrimary = Color(0xFF111827);
  
  /// 次要文字，描述
  static const Color lightTextSecondary = Color(0xFF6B7280);
  
  /// 暗示文字，占位符
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  
  /// 反色文字（用于深色按钮上）
  static const Color lightTextInverse = Color(0xFFFFFFFF);

  // =====================================================
  // 强调色（Accent Colors）
  // =====================================================

  /// 主强调色，科技蓝
  static const Color accentPrimary = Color(0xFF3B82F6);
  
  /// 强调色 Hover 状态
  static const Color accentHover = Color(0xFF2563EB);
  
  /// 强调色浅色背景
  static const Color accentLight = Color(0x1A3B82F6);
  
  /// 次强调色，靛蓝
  static const Color accentSecondary = Color(0xFF6366F1);

  // =====================================================
  // 状态色（Semantic Colors）
  // =====================================================

  /// 成功状态
  static const Color success = Color(0xFF22C55E);
  
  /// 成功背景
  static const Color successLight = Color(0x1A22C55E);
  
  /// 警告状态
  static const Color warning = Color(0xFFF59E0B);
  
  /// 警告背景
  static const Color warningLight = Color(0x1AF59E0B);
  
  /// 错误状态
  static const Color error = Color(0xFFEF4444);
  
  /// 错误背景
  static const Color errorLight = Color(0x1AEF4444);
  
  /// 信息状态
  static const Color info = Color(0xFF3B82F6);
  
  /// 信息背景
  static const Color infoLight = Color(0x1A3B82F6);

  // =====================================================
  // 渐变色（Gradients）
  // =====================================================

  /// 主渐变，科技蓝到靛蓝
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
  );

  /// 表面微渐变
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C1E2A), Color(0xFF161822)],
  );

  /// 强调渐变，紫粉
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
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
```

#### 步骤 2：更新 app_theme.dart
更新 `app_theme.dart` 中的颜色引用，使用新的统一色彩系统：

```dart
// 在 AppTheme 类中更新颜色引用
class AppTheme {
  // 使用新的统一色彩系统
  static const Color _primaryColor = AppColors.accentPrimary;
  static const Color _accentColor = AppColors.accentSecondary;
  static const Color _successColor = AppColors.success;
  static const Color _errorColor = AppColors.error;

  // 深色主题调色板
  static const Color _darkBg = AppColors.darkBackground;
  static const Color _darkSurface = AppColors.darkSurface;
  static const Color _darkCard = AppColors.darkCard;
  static const Color _darkBorder = AppColors.darkBorder;
  static const Color _darkHover = AppColors.darkHover;

  // 文字颜色
  static const Color _darkTextPrimary = AppColors.darkTextPrimary;
  static const Color _darkTextSecondary = AppColors.darkTextSecondary;
  static const Color _darkTextMuted = AppColors.darkTextMuted;

  // 浅色主题调色板
  static const Color _lightBg = AppColors.lightBackground;
  static const Color _lightSurface = AppColors.lightSurface;
  static const Color _lightCard = AppColors.lightCard;
  static const Color _lightBorder = AppColors.lightBorder;
  
  // ... 其他代码保持不变
}
```

#### 步骤 3：更新组件中的颜色引用
将现有组件中的硬编码颜色替换为设计令牌：

```dart
// 之前
Container(
  color: Color(0xFF111111),
  child: Text(
    'Hello',
    style: TextStyle(color: Color(0xFFE8E8E8)),
  ),
)

// 之后
Container(
  color: AppColors.darkBackground,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.darkTextPrimary),
  ),
)
```

---

## 2. 组件样式升级

### 2.1 卡片样式升级

```dart
// 创建统一的卡片组件
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool showBorder;
  final bool showShadow;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.showBorder = true,
    this.showShadow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: showBorder
              ? Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1,
                )
              : null,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
```

### 2.2 按钮样式升级

```dart
// 主要按钮
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

// 次要按钮
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2.3 输入框样式升级

```dart
// 统一输入框
class AppTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.accentPrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.error,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 3. 动画系统增强

### 3.1 模态框动画

```dart
// 自定义模态框动画
class AppModalRoute<T> extends PopupRoute<T> {
  final Widget child;
  final Duration duration;

  AppModalRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Duration get transitionDuration => duration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => 'Modal';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      ),
    );
  }
}

// 使用示例
showAppModal(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Modal Title'),
    content: Text('Modal Content'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      PrimaryButton(
        text: 'Confirm',
        onPressed: () => Navigator.pop(context),
      ),
    ],
  ),
);
```

### 3.2 骨架屏组件

```dart
// 骨架屏加载效果
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
                isDark ? AppColors.darkCard : AppColors.lightCard,
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
          ),
        );
      },
    );
  }
}

// 使用示例
SkeletonLoader(
  width: 200,
  height: 20,
  borderRadius: BorderRadius.circular(4),
)
```

### 3.3 Toast 动画

```dart
// 自定义 Toast 组件
class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

enum ToastType { info, success, warning, error }

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_animation),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColor(isDark),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: _getIconColor(),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(
                      Icons.close,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.successLight;
      case ToastType.warning:
        return AppColors.warningLight;
      case ToastType.error:
        return AppColors.errorLight;
      case ToastType.info:
        return isDark ? AppColors.darkCard : AppColors.lightCard;
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.accentPrimary;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.warning:
        return Icons.warning_outlined;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.accentPrimary;
    }
  }
}

// 使用示例
AppToast.show(
  context,
  message: '操作成功',
  type: ToastType.success,
);
```

---

## 4. 排版系统优化

### 4.1 更新 TextTheme

```dart
// 在 app_theme.dart 中更新 TextTheme
static TextTheme _buildTextTheme({
  required Color primary,
  required Color secondary,
  required Color muted,
}) {
  return TextTheme(
    // Display 标题
    displayLarge: TextStyle(
      fontFamily: 'Inter Display',
      fontSize: 30,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: primary,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Inter Display',
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: primary,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Inter Display',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: primary,
      height: 1.3,
    ),
    
    // Headline 标题
    headlineLarge: TextStyle(
      fontFamily: 'Inter Display',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: primary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Inter Display',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: primary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Inter Display',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: primary,
    ),
    
    // Title 标题
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primary,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: secondary,
      letterSpacing: 0.1,
    ),
    
    // Body 正文
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: primary,
      height: 1.6,
      letterSpacing: 0.1,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: primary,
      height: 1.6,
      letterSpacing: 0.1,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: secondary,
      height: 1.5,
    ),
    
    // Label 标签
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: primary,
      letterSpacing: 0.2,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: muted,
      letterSpacing: 0.3,
    ),
  );
}
```

---

## 5. 间距和圆角系统

### 5.1 统一间距系统

```dart
// 在 app_theme.dart 中更新间距系统
class AppTheme {
  // 间距系统 - 4pt 基准
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;
  static const double spacingXXXL = 48.0;

  // 圆角系统
  static const double radiusXS = 4.0;
  static const double radiusS = 6.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 9999.0;
  
  // ... 其他代码
}
```

---

## 6. 迁移检查清单

### 6.1 色彩系统迁移
- [ ] 更新 `app_colors.dart` 为统一色彩系统
- [ ] 更新 `app_theme.dart` 中的颜色引用
- [ ] 替换所有硬编码颜色值
- [ ] 测试深色/浅色主题切换

### 6.2 组件样式迁移
- [ ] 创建统一的卡片组件
- [ ] 创建统一的按钮组件
- [ ] 创建统一的输入框组件
- [ ] 更新现有页面使用新组件

### 6.3 动画系统迁移
- [ ] 添加模态框动画
- [ ] 添加骨架屏组件
- [ ] 添加 Toast 动画
- [ ] 测试动画性能

### 6.4 排版系统迁移
- [ ] 更新 TextTheme
- [ ] 添加 Inter Display 字体
- [ ] 测试不同字号下的可读性

### 6.5 间距和圆角迁移
- [ ] 统一间距系统
- [ ] 统一圆角系统
- [ ] 测试响应式布局

---

## 7. 常见问题

### Q1: 如何处理渐变色？
A: 渐变色应谨慎使用，仅用于强调元素（如按钮、卡片边框）。避免大面积使用渐变。

### Q2: 如何确保无障碍性？
A: 所有文字颜色必须满足WCAG AA对比度标准（4.5:1）。使用设计令牌中的颜色，不要自定义。

### Q3: 如何处理动画性能？
A: 使用 `AnimatedBuilder` 和 `RepaintBoundary` 优化动画性能。避免在动画中重建整个组件树。

### Q4: 如何测试响应式布局？
A: 使用 `ResponsiveLayout` 工具类测试不同屏幕尺寸。确保在所有断点下都有良好的用户体验。

---

## 附录：设计令牌快速参考

### 颜色
```dart
// 背景色
AppColors.darkBackground  // #0F1117
AppColors.lightBackground // #F8F9FA

// 表面色
AppColors.darkSurface  // #161822
AppColors.lightSurface // #FFFFFF

// 强调色
AppColors.accentPrimary   // #3B82F6
AppColors.accentSecondary // #6366F1

// 文字色
AppColors.darkTextPrimary   // #E8EAF0
AppColors.lightTextPrimary  // #111827
```

### 间距
```dart
AppTheme.spacingXS  // 4px
AppTheme.spacingS   // 8px
AppTheme.spacingM   // 12px
AppTheme.spacingL   // 16px
AppTheme.spacingXL  // 24px
AppTheme.spacingXXL // 32px
```

### 圆角
```dart
AppTheme.radiusXS  // 4px
AppTheme.radiusS   // 6px
AppTheme.radiusM   // 8px
AppTheme.radiusL   // 12px
AppTheme.radiusXL  // 16px
```