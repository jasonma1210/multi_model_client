# MJ Nexus 设计系统文档

基于 Linear 设计系统的 Flutter 实现，融合得物风克制感和科技蓝强调色。

---

## 1. Visual Theme

**Philosophy**: 精密、系统化、注重层次感的现代AI客户端设计
**Direction**: modern-minimal, tech-utility, restrained-elegance
**Personality**: confident, precise, approachable, tech-forward
**Reference**: Linear (开发者工具), Vercel (极简美学), Material Design 3 (组件规范)

---

## 2. Color Palette

### 色彩系统融合策略
- **背景色**: 采用得物风深邃感，增加微蓝调
- **表面色**: 保持得物风层次感，增加微渐变
- **强调色**: 保留科技蓝，降低饱和度，增加高级感
- **文字色**: 保持得物风层次，优化可读性

### 深色主题（Dark Theme）

| Token | HEX | OKLCh | Usage |
|-------|-----|-------|-------|
| --color-bg | #0F1117 | oklch(12% 0.02 260) | 页面背景，最深色 |
| --color-surface | #161822 | oklch(16% 0.02 260) | 卡片、面板背景 |
| --color-card | #1C1E2A | oklch(20% 0.02 260) | 卡片内容区 |
| --color-border | #2A2D3A | oklch(25% 0.02 260) | 边框、分隔线 |
| --color-hover | #222536 | oklch(22% 0.02 260) | Hover 状态背景 |
| --color-active | #2A2D3A | oklch(25% 0.02 260) | Active 状态背景 |

### 文字颜色（深色主题）

| Token | HEX | OKLCh | Usage |
|-------|-----|-------|-------|
| --color-text-primary | #E8EAF0 | oklch(92% 0.01 260) | 主要文字，标题 |
| --color-text-secondary | #8B8FA3 | oklch(60% 0.02 260) | 次要文字，描述 |
| --color-text-muted | #555770 | oklch(40% 0.02 260) | 暗示文字，占位符 |
| --color-text-inverse | #0F1117 | oklch(12% 0.02 260) | 反色文字（用于浅色按钮上） |

### 强调色（Accent Colors）

| Token | HEX | OKLCh | Usage |
|-------|-----|-------|-------|
| --color-accent | #3B82F6 | oklch(60% 0.20 250) | 主强调色，CTA按钮 |
| --color-accent-hover | #2563EB | oklch(50% 0.22 250) | 强调色Hover状态 |
| --color-accent-light | rgba(59,130,246,0.1) | oklch(60% 0.20 250 / 0.1) | 强调色浅色背景 |
| --color-accent-secondary | #6366F1 | oklch(55% 0.22 280) | 次强调色，靛蓝 |

### 状态色（Semantic Colors）

| Token | HEX | OKLCh | Usage |
|-------|-----|-------|-------|
| --color-success | #22C55E | oklch(70% 0.20 145) | 成功状态 |
| --color-success-light | rgba(34,197,94,0.1) | oklch(70% 0.20 145 / 0.1) | 成功背景 |
| --color-warning | #F59E0B | oklch(75% 0.18 85) | 警告状态 |
| --color-warning-light | rgba(245,158,11,0.1) | oklch(75% 0.18 85 / 0.1) | 警告背景 |
| --color-error | #EF4444 | oklch(60% 0.25 25) | 错误状态 |
| --color-error-light | rgba(239,68,68,0.1) | oklch(60% 0.25 25 / 0.1) | 错误背景 |
| --color-info | #3B82F6 | oklch(60% 0.20 250) | 信息状态 |
| --color-info-light | rgba(59,130,246,0.1) | oklch(60% 0.20 250 / 0.1) | 信息背景 |

### 渐变色（Gradients）

| Token | Gradient | Usage |
|-------|----------|-------|
| --gradient-primary | linear-gradient(135deg, #3B82F6, #6366F1) | 主渐变，科技蓝到靛蓝 |
| --gradient-surface | linear-gradient(180deg, #1C1E2A, #161822) | 表面微渐变 |
| --gradient-accent | linear-gradient(135deg, #8B5CF6, #EC4899) | 强调渐变，紫粉 |

### 浅色主题（Light Theme）

| Token | HEX | OKLCh | Usage |
|-------|-----|-------|-------|
| --color-bg | #F8F9FA | oklch(97% 0.005 80) | 页面背景 |
| --color-surface | #FFFFFF | oklch(100% 0 0) | 卡片、面板背景 |
| --color-card | #FFFFFF | oklch(100% 0 0) | 卡片内容区 |
| --color-border | #E5E7EB | oklch(90% 0.005 80) | 边框、分隔线 |
| --color-hover | #F3F4F6 | oklch(95% 0.005 80) | Hover 状态背景 |
| --color-active | #E5E7EB | oklch(90% 0.005 80) | Active 状态背景 |

### 文字颜色（浅色主题）

| Token | HEX | OKLCh | Usage |
|-------|-----|-------|-------|
| --color-text-primary | #111827 | oklch(15% 0.01 260) | 主要文字，标题 |
| --color-text-secondary | #6B7280 | oklch(50% 0.01 260) | 次要文字，描述 |
| --color-text-muted | #9CA3AF | oklch(65% 0.01 260) | 暗示文字，占位符 |
| --color-text-inverse | #FFFFFF | oklch(100% 0 0) | 反色文字（用于深色按钮上） |

---

## 3. Typography

### 字体栈（Font Stacks）

```dart
// 主要字体栈
const fontFamilyPrimary = 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';

// 等宽字体栈（用于代码块和AI输出）
const fontFamilyMono = '"JetBrains Mono", "Fira Code", "Cascadia Code", monospace';

// 显示字体（用于大标题）
const fontFamilyDisplay = '"Inter Display", "Inter", sans-serif';
```

### 字号层级（Type Scale）

| Level | Size | Weight | Line-height | Letter-spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| Display | 30px | 700 | 1.2 | -0.8px | Hero 标题 |
| H1 | 26px | 700 | 1.2 | -0.6px | 页面标题 |
| H2 | 22px | 700 | 1.3 | -0.4px | 区域标题 |
| H3 | 20px | 600 | 1.3 | -0.3px | 子区域标题 |
| H4 | 18px | 600 | 1.4 | -0.2px | 卡片标题 |
| H5 | 16px | 600 | 1.4 | -0.1px | 列表标题 |
| H6 | 15px | 600 | 1.4 | 0px | 小标题 |
| Body | 14px | 400 | 1.6 | 0.1px | 正文 |
| Body Large | 16px | 400 | 1.6 | 0.1px | 大正文 |
| Caption | 12px | 400 | 1.5 | 0.2px | 说明文字 |
| Small | 10px | 500 | 1.4 | 0.3px | 标签、徽章 |
| Code | 13px | 400 | 1.5 | 0.5px | 代码块 |

---

## 4. Component Styles

### 按钮（Buttons）

```dart
// 填充按钮（主要操作）
class FilledButtonStyle {
  static const backgroundColor = Color(0xFF3B82F6); // accent
  static const foregroundColor = Color(0xFFFFFFFF); // white
  static const hoverBackgroundColor = Color(0xFF2563EB); // accent-hover
  static const padding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const borderRadius = BorderRadius.all(Radius.circular(8));
  static const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
}

// 轮廓按钮（次要操作）
class OutlinedButtonStyle {
  static const foregroundColor = Color(0xFFE8EAF0); // text-primary
  static const borderColor = Color(0xFF2A2D3A); // border
  static const hoverBackgroundColor = Color(0xFF222536); // hover
  static const padding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const borderRadius = BorderRadius.all(Radius.circular(8));
  static const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
}

// 文本按钮（三级操作）
class TextButtonStyle {
  static const foregroundColor = Color(0xFFE8EAF0); // text-primary
  static const hoverBackgroundColor = Color(0xFF222536); // hover
  static const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const borderRadius = BorderRadius.all(Radius.circular(6));
  static const textStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
}
```

### 卡片（Cards）

```dart
class CardStyle {
  static const backgroundColor = Color(0xFF1C1E2A); // card
  static const borderColor = Color(0xFF2A2D3A); // border
  static const borderWidth = 1.0;
  static const borderRadius = BorderRadius.all(Radius.circular(12));
  static const padding = EdgeInsets.all(16);
  static const margin = EdgeInsets.all(8);
  
  // 悬停状态
  static const hoverBorderColor = Color(0xFF3B82F6); // accent
  static const hoverBoxShadow = [
    BoxShadow(
      color: Color(0x1A3B82F6), // accent-light
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
```

### 输入框（Inputs）

```dart
class InputStyle {
  static const backgroundColor = Color(0xFF161822); // surface
  static const borderColor = Color(0xFF2A2D3A); // border
  static const focusedBorderColor = Color(0xFF3B82F6); // accent
  static const errorBorderColor = Color(0xFFEF4444); // error
  static const borderRadius = BorderRadius.all(Radius.circular(8));
  static const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const textStyle = TextStyle(fontSize: 14, color: Color(0xFFE8EAF0));
  static const hintStyle = TextStyle(fontSize: 14, color: Color(0xFF555770));
}
```

### 对话框（Dialogs）

```dart
class DialogStyle {
  static const backgroundColor = Color(0xFF1C1E2A); // card
  static const borderColor = Color(0xFF2A2D3A); // border
  static const borderRadius = BorderRadius.all(Radius.circular(16));
  static const padding = EdgeInsets.all(24);
  static const titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE8EAF0));
  static const contentStyle = TextStyle(fontSize: 14, color: Color(0xFF8B8FA3), height: 1.6);
  
  // 玻璃态效果（可选）
  static const glassEffect = BoxDecoration(
    color: Color(0x801C1E2A), // 半透明
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: Color(0x402A2D3A))),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  );
}
```

### 导航栏（Navigation Bar）

```dart
class NavigationBarStyle {
  static const backgroundColor = Color(0xFF161822); // surface
  static const indicatorColor = Color(0xFF3B82F6); // accent
  static const selectedIconColor = Color(0xFFE8EAF0); // text-primary
  static const unselectedIconColor = Color(0xFF8B8FA3); // text-secondary
  static const selectedTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE8EAF0));
  static const unselectedTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8B8FA3));
  static const height = 64.0;
  static const indicatorBorderRadius = BorderRadius.all(Radius.circular(8));
}
```

---

## 5. Layout

### 间距系统（Spacing Scale）

| Token | Value | Usage |
|-------|-------|-------|
| --space-xs | 4px | 内联元素间距 |
| --space-sm | 8px | 紧凑间距 |
| --space-md | 12px | 默认间距 |
| --space-lg | 16px | 区域内边距 |
| --space-xl | 24px | 区域分隔 |
| --space-2xl | 32px | 大区域分隔 |
| --space-3xl | 48px | 页面边距 |

### 圆角系统（Border Radius）

| Token | Value | Usage |
|-------|-------|-------|
| --radius-xs | 4px | 小元素，标签 |
| --radius-sm | 6px | 按钮，输入框 |
| --radius-md | 8px | 卡片，对话框 |
| --radius-lg | 12px | 大卡片，模态框 |
| --radius-xl | 16px | 特殊容器 |
| --radius-full | 9999px | 圆形，药丸形 |

### 响应式断点（Breakpoints）

| Name | Width | Columns | Gutter |
|------|-------|---------|--------|
| Mobile | < 600px | 4 | 16px |
| Tablet | 600-1024px | 8 | 24px |
| Desktop | > 1024px | 12 | 32px |

---

## 6. Depth & Elevation

### 阴影系统（Shadow Scale）

| Token | Value | Usage |
|-------|-------|-------|
| --shadow-xs | 0 1px 2px rgba(0,0,0,0.05) | 微阴影 |
| --shadow-sm | 0 2px 4px rgba(0,0,0,0.1) | 卡片阴影 |
| --shadow-md | 0 4px 8px rgba(0,0,0,0.12) | 悬浮元素 |
| --shadow-lg | 0 8px 16px rgba(0,0,0,0.14) | 对话框 |
| --shadow-xl | 0 16px 32px rgba(0,0,0,0.16) | 模态框 |

### Z-index 层级

| Level | Value | Usage |
|-------|-------|-------|
| Base | 0 | 默认层级 |
| Dropdown | 100 | 下拉菜单 |
| Sticky | 200 | 固定元素 |
| Modal | 300 | 模态框 |
| Toast | 400 | 通知提示 |
| Tooltip | 500 | 工具提示 |

---

## 7. Cautions

### 禁止的模式（Never Do）
- 不要使用纯黑色（#000000）作为背景或文字颜色
- 不要使用过于鲜艳的强调色，保持科技感的克制
- 不要过度使用渐变，仅用于强调元素
- 不要使用过于复杂的阴影效果
- 不要忽略深色/浅色主题的对比度要求

### 推荐的替代方案（Prefer）
- 使用带有微蓝调的深色背景（#0F1117）
- 使用降低饱和度的科技蓝作为强调色
- 使用微渐变增加层次感，而非大面积渐变
- 使用轻阴影和边框组合创造深度
- 确保所有文字颜色满足WCAG AA对比度标准

---

## 8. Responsive Behavior

### 移动端适配策略
- 单列布局，垂直堆叠
- 增大点击区域（最小44px）
- 简化导航，使用底部导航栏
- 减少信息密度，增加留白

### 平板适配策略
- 两栏布局，侧边栏可折叠
- 中等信息密度
- 支持横竖屏切换

### 桌面适配策略
- 三栏布局，完整侧边栏
- 高信息密度，紧凑间距
- 支持键盘快捷键和鼠标悬停状态

---

## 9. Agent Prompt Guide

### AI 生成关键指令

1. **色彩使用**
   - 始终使用设计令牌中的颜色变量，不要硬编码颜色值
   - 深色主题使用深色背景（#0F1117），浅色主题使用浅色背景（#F8F9FA）
   - 强调色仅用于CTA按钮和重要交互元素

2. **排版规范**
   - 标题使用Inter Display字体，正文使用Inter字体
   - 代码块使用JetBrains Mono等宽字体
   - 保持行高和字间距的规范性

3. **组件样式**
   - 按钮使用圆角8px，输入框使用圆角8px
   - 卡片使用圆角12px，对话框使用圆角16px
   - 保持一致的间距系统（4px基准）

4. **动画效果**
   - 使用80ms/150ms/250ms的动画时长
   - 使用ease-out缓动曲线
   - 支持可访问性动画开关

5. **Material Design 3 适配**
   - 使用MD3的色彩系统，但自定义种子颜色
   - 采用MD3的组件样式，但保持克制
   - 利用MD3的动态色彩，但限制在科技蓝范围内

### Flutter 代码片段

```dart
// 快速应用设计令牌
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF3B82F6), // accent
    brightness: Brightness.dark,
    background: Color(0xFF0F1117),
    surface: Color(0xFF161822),
    // ... 其他颜色
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontFamily: 'Inter Display', fontSize: 30, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.normal),
    // ... 其他文本样式
  ),
)
```

---

## 附录：设计令牌 CSS 变量

```css
:root {
  /* 深色主题 */
  --color-bg: #0F1117;
  --color-surface: #161822;
  --color-card: #1C1E2A;
  --color-border: #2A2D3A;
  --color-accent: #3B82F6;
  --color-accent-hover: #2563EB;
  --color-text-primary: #E8EAF0;
  --color-text-secondary: #8B8FA3;
  --color-text-muted: #555770;
  
  /* 间距 */
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 12px;
  --space-lg: 16px;
  --space-xl: 24px;
  --space-2xl: 32px;
  --space-3xl: 48px;
  
  /* 圆角 */
  --radius-xs: 4px;
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-full: 9999px;
  
  /* 阴影 */
  --shadow-xs: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
  --shadow-md: 0 4px 8px rgba(0,0,0,0.12);
  --shadow-lg: 0 8px 16px rgba(0,0,0,0.14);
  --shadow-xl: 0 16px 32px rgba(0,0,0,0.16);
}
```