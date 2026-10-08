/// `ParkBottomNav` 接入表面派生层的测试。
///
/// ## 三条本组件专属的不变量
///
/// 1. 🔴 **B 组红线：选中态颜色恒为 `colors.brand`**，5 风格 × 明暗下都不变。
///    这是"导航栏在任何主题下都可辨识"的底线。
/// 2. **未选中态必须与容器 fill 可读**（≥ 4.5:1）。
///    neon + 深色下容器 fill 翻转为近白，若未选中色沿用
///    `colors.textSecondary`（暗色板 `#ADB8C9`）只有 **2.00:1**。
/// 3. **未选中态零漂移**：stripe / flat / glass / neo 下它**字面等于**
///    `colors.textSecondary`，只有 neon + 深色那一格会变。
///
/// ## 关于选中态对比度阈值
///
/// `colors.brand`(#635BFF) 在深色表面上是 **3.36:1**，低于 AA 正文 4.5。
/// 这是**改造前就存在**的事实（底色同为 `colors.surface`），本轮不改变，
/// 因此这里按"UI 组件边界"口径断言 ≥ 3.0，而不是硬套 4.5 制造假失败。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 渲染一个底部导航栏。
Future<void> pumpBottomNav(
  WidgetTester tester, {
  required ParkThemeData theme,
  int currentIndex = 0,
  double elevation = 0,
  ParkBottomNavType type = ParkBottomNavType.fixed,
  Color? selectedItemColor,
  Color? unselectedItemColor,
  ParkSurfaceStyle? scopeStyle,
}) async {
  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(
      body: ParkBottomNav(
        currentIndex: currentIndex,
        onTap: (_) {},
        elevation: elevation,
        type: type,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        items: const <ParkBottomNavItem>[
          ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
          ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
          ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    ),
  );

  if (scopeStyle != null) {
    app = ParkSurfaceStyleScope(style: scopeStyle, child: app);
  }

  await tester.pumpWidget(app);
}

/// 取底栏**容器**的 decoration（真正受本次改动影响的元素）。
BoxDecoration bottomNavDecoration(WidgetTester tester) {
  for (final Container c in tester.widgetList<Container>(
    find.descendant(
      of: find.byType(ParkBottomNav),
      matching: find.byType(Container),
    ),
  )) {
    final Decoration? d = c.decoration;
    if (d is BoxDecoration) return d;
  }
  throw StateError('未找到底栏容器 decoration');
}

/// 取原生 BottomNavigationBar 实际收到的选中色 / 未选中色。
BottomNavigationBar bottomNavBar(WidgetTester tester) {
  return tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
}

/// 把可能半透明的填充合成到不透明页面背景上。
///
/// 🔴 `ParkColors.contrastRatio` 只读 r/g/b、**忽略 alpha**，glass 的 fill 是
/// `surface@0.55`，直接拿它算对比度在数学上无效。
Color effectiveFill(BoxDecoration d, ParkThemeData theme) {
  return Color.alphaBlend(d.color!, theme.colors.background);
}

void main() {
  // ==========================================================================
  // 1. 🔴 B 组红线：选中态颜色恒为 brand，绝不随 surfaceStyle 变化
  // ==========================================================================
  group('ParkBottomNav · B 组红线：选中态恒为 brand', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · selectedItemColor == brand', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpBottomNav(tester, theme: theme);

          expect(
            bottomNavBar(tester).selectedItemColor,
            equals(theme.colors.brand),
            reason: '选中态必须恒为 brand，不能随表面风格漂移',
          );
        });
      }
    }

    testWidgets('选中态颜色在 5 风格间完全一致（逐对比）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData light = ParkThemeData.light();
      Color? baseline;
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        await pumpBottomNav(
          tester,
          theme: light.copyWith(surfaceStyle: style),
        );
        final Color? selected = bottomNavBar(tester).selectedItemColor;
        baseline ??= selected;
        expect(selected, equals(baseline), reason: '$style 下选中色漂移了');
      }
      expect(baseline, equals(light.colors.brand));
    });

    for (final ParkBottomNavType type in ParkBottomNavType.values) {
      testWidgets('$type · 选中色仍为 brand 且与 fill ≥ 3.0:1', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.dark().copyWith(
          surfaceStyle: ParkSurfaceStyle.neon,
        );
        await pumpBottomNav(tester, theme: theme, type: type);

        final Color fill = effectiveFill(bottomNavDecoration(tester), theme);
        final double ratio = ParkColors.contrastRatio(
          bottomNavBar(tester).selectedItemColor!,
          fill,
        );
        expect(bottomNavBar(tester).selectedItemColor, equals(theme.colors.brand));
        expect(
          ratio,
          greaterThanOrEqualTo(3.0),
          reason:
              '$type 选中色对比度仅 ${ratio.toStringAsFixed(2)}:1'
              '（brand 在深色面上是 3.36:1，改造前即如此，按 UI 边界 3.0 判定）',
        );
      });
    }
  });

  // ==========================================================================
  // 2. 未选中态必须与容器 fill 可读
  // ==========================================================================
  group('ParkBottomNav · 未选中态可读性（5 风格 × 明暗）', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · 未选中色 vs fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpBottomNav(tester, theme: theme);

          final Color fill = effectiveFill(bottomNavDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            bottomNavBar(tester).unselectedItemColor!,
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                '$style/${brightness.name} 未选中色仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }

    testWidgets('neon + dark · 未选中色不再是 textSecondary（2.00:1 反证）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpBottomNav(tester, theme: theme);

      final Color fill = effectiveFill(bottomNavDecoration(tester), theme);
      // 反证：沿用 colors.textSecondary 会撞成 2.00:1。
      expect(
        ParkColors.contrastRatio(theme.colors.textSecondary, fill),
        lessThan(4.5),
        reason: '这正是"未选中态不能死守 textSecondary"的证据',
      );
      // 实际取值必须可读。
      expect(
        ParkColors.contrastRatio(
          bottomNavBar(tester).unselectedItemColor!,
          fill,
        ),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('零漂移：stripe/flat/glass/neo 下未选中色字面等于 textSecondary', (
      WidgetTester tester,
    ) async {
      for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
        ParkSurfaceStyle.stripe,
        ParkSurfaceStyle.flat,
        ParkSurfaceStyle.glass,
        ParkSurfaceStyle.neo,
      ]) {
        for (final Brightness brightness in Brightness.values) {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);
          await pumpBottomNav(tester, theme: theme);

          expect(
            bottomNavBar(tester).unselectedItemColor,
            equals(theme.colors.textSecondary),
            reason: '$style/${brightness.name} 未选中态发生了不必要的漂移',
          );
        }
      }
    });
  });

  // ==========================================================================
  // 3. 零回归：stripe / flat
  // ==========================================================================
  group('ParkBottomNav · stripe/flat 零回归', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.flat,
    ]) {
      testWidgets('$style · 填充色等于 colors.surface（与改造前一致）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpBottomNav(tester, theme: theme);

        expect(bottomNavDecoration(tester).color, equals(theme.colors.surface));
      });

      testWidgets('$style · elevation=0 时无阴影（底栏有显式旋钮）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpBottomNav(tester, theme: theme, elevation: 0);

        expect(
          bottomNavDecoration(tester).boxShadow,
          isNull,
          reason: 'elevation=0 即"不要阴影"，不得凭空投影',
        );
      });

      testWidgets('$style · elevation=4 时阴影回落到组件原值', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpBottomNav(tester, theme: theme, elevation: 4);

        // 抄改造前的**字面量**：textPrimary 8% / blur 20 / offset (0,-5)。
        expect(
          bottomNavDecoration(tester).boxShadow,
          equals(<BoxShadow>[
            BoxShadow(
              color: theme.colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ]),
        );
      });
    }

    testWidgets('neon · elevation=4 时阴影由风格接管（不是组件原值）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpBottomNav(tester, theme: theme, elevation: 4);

      final List<BoxShadow>? shadows = bottomNavDecoration(tester).boxShadow;
      expect(shadows, isNotNull);
      expect(
        shadows,
        isNot(
          equals(<BoxShadow>[
            BoxShadow(
              color: theme.colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ]),
        ),
      );
    });

    testWidgets('所有风格 · 无描边（组件无 bordered 语义）', (
      WidgetTester tester,
    ) async {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        await pumpBottomNav(
          tester,
          theme: ParkThemeData.light().copyWith(surfaceStyle: style),
        );
        expect(
          bottomNavDecoration(tester).border,
          isNull,
          reason: '$style 底栏不应凭空出现描边',
        );
      }
    });
  });

  // ==========================================================================
  // 4. 玻璃风格 / Scope 覆盖
  // ==========================================================================
  group('ParkBottomNav · 玻璃与 Scope', () {
    testWidgets('glass 渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpBottomNav(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe 不渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpBottomNav(tester, theme: ParkThemeData.light());
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('全局 stripe + 局部 glass → 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpBottomNav(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('全局 glass + 局部 stripe → 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpBottomNav(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        scopeStyle: ParkSurfaceStyle.stripe,
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 5. 用户逃生舱：selectedItemColor / unselectedItemColor 部分覆盖
  // ==========================================================================
  group('ParkBottomNav · 用户颜色覆盖', () {
    testWidgets('只覆盖 selected 时，unselected 仍走派生结果', (
      WidgetTester tester,
    ) async {
      const Color customSelected = Color(0xFF00C853);
      final ParkThemeData theme = ParkThemeData.light();
      await pumpBottomNav(tester, theme: theme, selectedItemColor: customSelected);

      expect(bottomNavBar(tester).selectedItemColor, equals(customSelected));
      expect(
        bottomNavBar(tester).unselectedItemColor,
        equals(theme.colors.textSecondary),
        reason: '未覆盖的一侧仍应走表面令牌派生结果',
      );
    });

    testWidgets('只覆盖 unselected 时，selected 仍为 brand（红线不失效）', (
      WidgetTester tester,
    ) async {
      const Color customUnselected = Color(0xFF111111);
      final ParkThemeData theme = ParkThemeData.light();
      await pumpBottomNav(
        tester,
        theme: theme,
        unselectedItemColor: customUnselected,
      );

      expect(bottomNavBar(tester).unselectedItemColor, equals(customUnselected));
      expect(bottomNavBar(tester).selectedItemColor, equals(theme.colors.brand));
    });
  });

  // ==========================================================================
  // 6. 派生函数直测
  // ==========================================================================
  group('ParkBottomNav · resolveParkBottomNavSurface', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · selected 恒 brand', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          late ParkBottomNavSurface resolved;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                extensions: <ThemeExtension<ParkThemeData>>[theme],
              ),
              home: Builder(
                builder: (BuildContext ctx) {
                  resolved = resolveParkBottomNavSurface(
                    park: theme,
                    context: ctx,
                  );
                  return const SizedBox.shrink();
                },
              ),
            ),
          );

          expect(resolved.selectedColor, equals(theme.colors.brand));
          final Color fill = Color.alphaBlend(
            resolved.fill,
            theme.colors.background,
          );
          expect(
            ParkColors.contrastRatio(resolved.unselectedColor, fill),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    }
  });

  // ==========================================================================
  // 7. 公开签名零破坏
  // ==========================================================================
  group('ParkBottomNav · 公开默认值不变', () {
    test('所有公开参数默认值锁定', () {
      final ParkBottomNav nav = ParkBottomNav(
        currentIndex: 0,
        onTap: (_) {},
        items: const <ParkBottomNavItem>[
          ParkBottomNavItem(icon: Icon(Icons.home), label: 'a'),
          ParkBottomNavItem(icon: Icon(Icons.search), label: 'b'),
        ],
      );
      expect(nav.size, equals(ParkBottomNavSize.medium));
      expect(nav.type, equals(ParkBottomNavType.fixed));
      expect(nav.elevation, 0.0);
      expect(nav.backgroundColor, isNull);
      expect(nav.selectedItemColor, isNull);
      expect(nav.unselectedItemColor, isNull);
      expect(nav.selectedFontSize, isNull);
      expect(nav.unselectedFontSize, isNull);
      expect(nav.iconSize, isNull);
    });
  });
}
