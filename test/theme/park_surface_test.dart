/// `ParkSurface` 装饰器测试。
///
/// 重点验证两件事：
/// 1. 它只是 `ParkSurfaceStyleScope` + `BackdropFilter` 的组合，能把风格
///    正确传递给子树；
/// 2. 玻璃嵌套时内层**不再**渲染 `BackdropFilter`（避免同一区域被重复采样，
///    成本呈平方级增长）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  Widget wrap(Widget child, {ParkThemeData? theme}) {
    final ParkThemeData park = theme ?? ParkThemeData.light();
    return MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[park]),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('ParkSurface · 基本渲染', () {
    testWidgets('stripe 风格下不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(child: Text('内容')),
        ),
      );

      expect(find.byType(ParkSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('内容'), findsOneWidget);
    });

    testWidgets('glass 风格下渲染一层 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(
            style: ParkSurfaceStyle.glass,
            child: Text('玻璃'),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('intensity=0 时仍保留填充但不模糊（降级不塌陷）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(
            style: ParkSurfaceStyle.glass,
            intensity: 0,
            child: Text('无模糊玻璃'),
          ),
        ),
      );

      // 模糊关闭，但容器仍在 → 视觉不塌陷
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(AnimatedContainer), findsWidgets);
      expect(find.text('无模糊玻璃'), findsOneWidget);
    });

    testWidgets('向子树传递风格：子树读到的是 glass 而非全局 stripe', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceStyle seen;
      await tester.pumpWidget(
        wrap(
          ParkSurface(
            style: ParkSurfaceStyle.glass,
            child: Builder(
              builder: (BuildContext context) {
                seen = ParkSurfaceStyleScope.of(context);
                return const Text('子');
              },
            ),
          ),
        ),
      );

      expect(seen, equals(ParkSurfaceStyle.glass));
    });

    testWidgets('未指定 style 时沿用全局风格', (WidgetTester tester) async {
      late ParkSurfaceStyle seen;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (BuildContext context) {
              seen = ParkSurfaceStyleScope.of(context);
              return const SizedBox.shrink();
            },
          ),
          theme: ParkThemeData.light().copyWith(
            surfaceStyle: ParkSurfaceStyle.neon,
          ),
        ),
      );

      expect(seen, equals(ParkSurfaceStyle.neon));
    });

    testWidgets('intensity 断言非法值', (WidgetTester tester) async {
      // 断言在构造期触发，因此不能用 const。
      await tester.pumpWidget(
        wrap(
          ParkSurface(intensity: 2.0, child: const Text('x')),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group('ParkSurface · 玻璃嵌套降级', () {
    testWidgets('嵌套 3 层玻璃时只有最外层渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(
            style: ParkSurfaceStyle.glass,
            child: ParkSurface(
              style: ParkSurfaceStyle.glass,
              child: ParkSurface(
                style: ParkSurfaceStyle.glass,
                child: Text('三层'),
              ),
            ),
          ),
        ),
      );

      // 🔴 回归锁定：曾用 `depth <= 1`，导致第 2 层也采样，3 层嵌套渲染出
      // 2 层 BackdropFilter。`ParkSurfaceBlurDepth` 记录的是**祖先已采样层数**，
      // 故判定必须是 `depth < 1`。
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('嵌套 2 层玻璃时同样只有最外层采样', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(
            style: ParkSurfaceStyle.glass,
            child: ParkSurface(
              style: ParkSurfaceStyle.glass,
              child: Text('两层'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('嵌套 4 层玻璃仍只有 1 层采样（深度增加不改变判定）', (
      WidgetTester tester,
    ) async {
      Widget nest(int n) => n == 0
          ? const Text('四层')
          : ParkSurface(
              style: ParkSurfaceStyle.glass,
              child: nest(n - 1),
            );

      await tester.pumpWidget(wrap(nest(3)));

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('canBlur 与 build 的判定一致（不会出现两套规则）', (
      WidgetTester tester,
    ) async {
      // ParkGlassPanel.canRenderBlur / ParkTag / ParkDialog / ParkPopover
      // 都用 `depth < 1`；这里锁定 ParkSurface.canBlur 同为该语义。
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (BuildContext outer) {
              expect(
                ParkSurface.canBlur(outer),
                isTrue,
                reason: '最外层应允许模糊',
              );
              return ParkSurface(
                style: ParkSurfaceStyle.glass,
                child: Builder(
                  builder: (BuildContext inner) {
                    expect(
                      ParkSurface.canBlur(inner),
                      isFalse,
                      reason: '内层应被拒绝（祖先已采样）',
                    );
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ),
      );
    });

    testWidgets('非玻璃嵌套不受影响（各自独立渲染）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(
            child: ParkSurface(child: Text('双层')),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(ParkSurface), findsNWidgets(2));
    });

    testWidgets('外层非玻璃 + 内层玻璃时，内层仍可模糊（深度从 0 起算）', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ParkSurface(
            child: ParkSurface(
              style: ParkSurfaceStyle.glass,
              child: Text('内层玻璃'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('ParkSurfaceBlurDepth 默认深度为 0', (
      WidgetTester tester,
    ) async {
      late int depth;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (BuildContext context) {
              depth = ParkSurfaceBlurDepth.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(depth, equals(0));
    });
  });
}
