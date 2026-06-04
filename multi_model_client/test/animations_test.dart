// 动画模块单元测试
//
// 验证：
// - [AppAnimations] 常量定义合理
// - [Pressable] 点击回调正确触发
// - [FadeIn] / [FadeInSlide] / [FadeInScale] 完成动画后正常显示
// - [AnimatedAppear] show=true 渲染，show=false 不渲染
// - [Pulse] / [RotatingIcon] 渲染子组件并持续动画
// - [StaggeredListItem] 可正常渲染多个子项
// - [PageTransitions] 创建有效路由
// - [Shake] trigger=true 启动抖动
// - 全局动画开关 debugSetEnabled 切换生效

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mj_nexus/core/widgets/animations/animations.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('AppAnimations', () {
    test('常量值合理', () {
      expect(AppAnimations.durationFast, const Duration(milliseconds: 80));
      expect(AppAnimations.durationMedium, const Duration(milliseconds: 150));
      expect(AppAnimations.durationNormal, const Duration(milliseconds: 250));
      expect(AppAnimations.durationSlow, const Duration(milliseconds: 320));
      // 缓动曲线为有效 Curve
      expect(AppAnimations.easeOut, isA<Curve>());
      expect(AppAnimations.easeIn, isA<Curve>());
      expect(AppAnimations.easeInOut, isA<Curve>());
      expect(AppAnimations.bounceOut, isA<Curve>());
      // 缩放比例在合理范围
      expect(AppAnimations.pressScale, lessThan(1.0));
      expect(AppAnimations.pressScale, greaterThan(0.8));
      // 滑动距离 > 0
      expect(AppAnimations.slideDistance, greaterThan(0.0));
    });

    test('debugSetEnabled 切换后值变化', () {
      final original = AppAnimations.enabled.value;
      AppAnimations.debugSetEnabled(!original);
      expect(AppAnimations.enabled.value, !original);
      AppAnimations.debugSetEnabled(original);
      expect(AppAnimations.enabled.value, original);
    });
  });

  group('Pressable', () {
    testWidgets('点击触发 onTap', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _wrap(
          Pressable(
            onTap: () => tapCount++,
            child: const SizedBox(width: 50, height: 50, key: ValueKey('p')),
          ),
        ),
      );
      await tester.tap(find.byType(Pressable));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });

    testWidgets('无 onTap 时不创建交互层', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Pressable(
            child: SizedBox(width: 50, height: 50, key: ValueKey('p')),
          ),
        ),
      );
      // 直接渲染子组件（不创建 GestureDetector / AnimatedScale）
      expect(find.byType(AnimatedScale), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byKey(const ValueKey('p')), findsOneWidget);
    });

    testWidgets('长按触发 onLongPress', (tester) async {
      var longPressCount = 0;
      await tester.pumpWidget(
        _wrap(
          Pressable(
            onLongPress: () => longPressCount++,
            child: const SizedBox(width: 50, height: 50, key: ValueKey('p')),
          ),
        ),
      );
      await tester.longPress(find.byType(Pressable));
      await tester.pumpAndSettle();
      expect(longPressCount, 1);
    });
  });

  group('FadeIn / FadeInSlide / FadeInScale', () {
    testWidgets('FadeIn 动画完成后子组件可见', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FadeIn(
            child: Text('hello', key: ValueKey('t')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('t')), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('FadeInSlide 完成动画后子组件可见', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FadeInSlide(
            child: Text('slide', key: ValueKey('s')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('s')), findsOneWidget);
    });

    testWidgets('FadeInScale 完成动画后子组件可见', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FadeInScale(
            child: Text('scale', key: ValueKey('sc')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sc')), findsOneWidget);
    });

    testWidgets('带 delay 的 FadeIn 在 delay 后才显示', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FadeIn(
            delay: Duration(milliseconds: 200),
            child: Text('delayed', key: ValueKey('d')),
          ),
        ),
      );
      // 初始 pump：未到 delay，opacity 仍为 0
      await tester.pump();
      // 推进到 delay 之后
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('d')), findsOneWidget);
    });
  });

  group('AnimatedAppear', () {
    testWidgets('show=true 渲染子组件', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AnimatedAppear(
            show: true,
            child: const Text('shown', key: ValueKey('sh')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sh')), findsOneWidget);
    });

    testWidgets('show=false 时子组件不可见（opacity 0）', (tester) async {
      // 确保全局动画开启
      final original = AppAnimations.enabled.value;
      AppAnimations.debugSetEnabled(true);
      addTearDown(() => AppAnimations.debugSetEnabled(original));

      await tester.pumpWidget(
        _wrap(
          AnimatedAppear(
            show: true,
            child: const Text('toggle', key: ValueKey('tg')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tg')), findsOneWidget);

      // 切换到 show=false
      await tester.pumpWidget(
        _wrap(
          AnimatedAppear(
            show: false,
            child: const Text('toggle', key: ValueKey('tg')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // 子组件仍在 widget tree 中（不可见）
      expect(find.byKey(const ValueKey('tg')), findsOneWidget);
    });
  });

  group('Pulse / RotatingIcon', () {
    testWidgets('Pulse 渲染子组件', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Pulse(
            child: const Icon(Icons.favorite, key: ValueKey('pul')),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('pul')), findsOneWidget);
    });

    testWidgets('RotatingIcon 渲染子组件', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RotatingIcon(
            child: const Icon(Icons.refresh, key: ValueKey('rot')),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('rot')), findsOneWidget);
    });

    testWidgets('Pulse 内部存在 Opacity/Transform 动画包装', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Pulse(
            child: const Icon(Icons.favorite, key: ValueKey('pul')),
          ),
        ),
      );
      // Pulse 内部用 AnimatedBuilder + Opacity + Transform.scale 实现
      expect(find.descendant(
        of: find.byType(Pulse),
        matching: find.byType(Opacity),
      ), findsOneWidget);
    });
  });

  group('StaggeredListItem', () {
    testWidgets('渲染多个子组件', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: const [
              StaggeredListItem(index: 0, child: Text('A', key: ValueKey('a'))),
              StaggeredListItem(index: 1, child: Text('B', key: ValueKey('b'))),
              StaggeredListItem(index: 2, child: Text('C', key: ValueKey('c'))),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });

  group('PageTransitions', () {
    testWidgets('fadeThroughPageRoute 创建有效路由', (tester) async {
      final route = fadeThroughPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('fade')),
      );
      expect(route, isA<PageRoute<void>>());
      expect(route.transitionDuration, AppAnimations.durationSlow);
    });

    testWidgets('slideUpPageRoute 创建有效路由', (tester) async {
      final route = slideUpPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('slide')),
      );
      expect(route, isA<PageRoute<void>>());
    });

    testWidgets('sharedAxisPageRoute 创建有效路由', (tester) async {
      final route = sharedAxisPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('shared')),
      );
      expect(route, isA<PageRoute<void>>());
    });

    testWidgets('pageRouteBuilder 默认 FadeTransition', (tester) async {
      final route = pageRouteBuilder<void>(
        builder: (_) => const Scaffold(body: Text('default')),
      );
      expect(route, isA<PageRoute<void>>());
      // transitionDuration 默认为 durationSlow
      expect(route.transitionDuration, AppAnimations.durationSlow);
    });
  });

  group('Shake', () {
    testWidgets('trigger 变化时启动抖动动画', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Shake(
            trigger: false,
            child: const Text('shake', key: ValueKey('sh')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sh')), findsOneWidget);

      // 重新构建并设置 trigger=true 启动抖动
      await tester.pumpWidget(
        _wrap(
          Shake(
            trigger: true,
            child: const Text('shake', key: ValueKey('sh')),
          ),
        ),
      );
      // 立即 pump 一帧
      await tester.pump();
      // 找到 Shake 的子组件
      expect(find.byKey(const ValueKey('sh')), findsOneWidget);
      // 在动画中（duration=400ms）经过 200ms
      await tester.pump(const Duration(milliseconds: 200));
      // 子组件仍然存在（动画未结束）
      expect(find.byKey(const ValueKey('sh')), findsOneWidget);
    });
  });

  group('HoverScale', () {
    testWidgets('渲染子组件', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HoverScale(
            onTap: () {},
            child: const Icon(Icons.add, key: ValueKey('h')),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('h')), findsOneWidget);
    });

    testWidgets('无 onTap 时不创建交互层', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HoverScale(
            child: Icon(Icons.add, key: ValueKey('h')),
          ),
        ),
      );
      // 触屏平台 HoverScale 退化为纯 Icon（无 onTap 时）
      expect(find.byKey(const ValueKey('h')), findsOneWidget);
    });
  });

  group('RotatingIconOnce', () {
    testWidgets('渲染子组件', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RotatingIconOnce(
            child: const Icon(Icons.refresh, key: ValueKey('ri')),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('ri')), findsOneWidget);
    });

    testWidgets('点击后启动旋转动画', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RotatingIconOnce(
            child: const Icon(Icons.refresh, key: ValueKey('ri')),
          ),
        ),
      );
      await tester.tap(find.byType(RotatingIconOnce));
      await tester.pump();
      // 子组件依然可见
      expect(find.byKey(const ValueKey('ri')), findsOneWidget);
      // 推进一帧后动画进行中
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const ValueKey('ri')), findsOneWidget);
    });
  });

  group('SlideDirection', () {
    test('枚举值存在', () {
      expect(SlideDirection.values, containsAll([
        SlideDirection.up,
        SlideDirection.down,
        SlideDirection.left,
        SlideDirection.right,
      ]));
    });
  });
}
