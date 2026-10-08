/// `ParkTabBar` 接入表面派生层的测试。
///
/// ## 本组件两条专属不变量
///
/// 1. 🔴 **B 组红线：选中态颜色恒为 `colors.brand`**。本组件的"选中指示"
///    就是选中项颜色本身（没有独立高亮条 / 滑块），所以指示器材质同样
///    恒为 brand —— 最保守的选择。
/// 2. **悬浮式（[ParkTabBarType.floating]）是独立分支**：它同时决定
///    「圆角 / 阴影 / 分割线」三件事，必须整条处理，否则会出现
///    "圆角了但仍贴底"的撕裂态。
///
/// ## 关于选中态对比度阈值
///
/// `colors.brand`(#635BFF) 在深色表面上是 3.36:1，低于 AA 正文 4.5。
/// 这是**改造前就存在**的事实，本轮不改变，故按 UI 组件边界口径断言 ≥ 3.0。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

const String _kFirstLabel = '首页';
const String _kSecondLabel = '发现';

/// 渲染一个底部标签栏。
Future<void> pumpTabBar(
  WidgetTester tester, {
  required ParkThemeData theme,
  ParkTabBarType type = ParkTabBarType.fixed,
  bool bordered = true,
  double elevation = 8,
  int currentIndex = 0,
  ParkSurfaceStyle? scopeStyle,
}) async {
  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(
      body: ParkTabBar(
        type: type,
        bordered: bordered,
        elevation: elevation,
        currentIndex: currentIndex,
        onTap: (_) {},
        items: const <ParkTabBarItem>[
          ParkTabBarItem(icon: Icons.home, label: _kFirstLabel),
          ParkTabBarItem(icon: Icons.search, label: _kSecondLabel),
        ],
      ),
    ),
  );

  if (scopeStyle != null) {
    app = ParkSurfaceStyleScope(style: scopeStyle, child: app);
  }

  await tester.pumpWidget(app);
}

/// 取标签栏**容器**的 decoration（真正受本次改动影响的元素）。
///
/// 走真实渲染路径：ParkTabBar 的自身 Container 在树序上先于 item 内的
/// 角标 Container，因此取第一个带 BoxDecoration 的即为栏容器。
BoxDecoration tabBarDecoration(WidgetTester tester) {
  for (final Container c in tester.widgetList<Container>(
    find.descendant(
      of: find.byType(ParkTabBar),
      matching: find.byType(Container),
    ),
  )) {
    final Decoration? d = c.decoration;
    if (d is BoxDecoration) return d;
  }
  throw StateError('未找到标签栏容器 decoration');
}

/// 取某个标签文字的实际渲染色。
Color labelColorOf(WidgetTester tester, String label) {
  return tester.widget<Text>(find.text(label)).style!.color!;
}

/// 把可能半透明的填充合成到不透明页面背景上。
///
/// 🔴 `ParkColors.contrastRatio` 只读 r/g/b、**忽略 alpha**。
Color effectiveFill(BoxDecoration d, ParkThemeData theme) {
  return Color.alphaBlend(d.color!, theme.colors.background);
}

void main() {
  // ==========================================================================
  // 1. 🔴 B 组红线：选中态恒为 brand
  // ==========================================================================
  group('ParkTabBar · B 组红线：选中态恒为 brand', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · 选中标签色 == brand', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpTabBar(tester, theme: theme);

          expect(
            labelColorOf(tester, _kFirstLabel),
            equals(theme.colors.brand),
            reason: '选中态必须恒为 brand，不能随表面风格漂移',
          );
        });
      }
    }

    testWidgets('选中色在 5 风格间完全一致（逐对比）', (WidgetTester tester) async {
      final ParkThemeData light = ParkThemeData.light();
      Color? baseline;
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        await pumpTabBar(tester, theme: light.copyWith(surfaceStyle: style));
        final Color selected = labelColorOf(tester, _kFirstLabel);
        baseline ??= selected;
        expect(selected, equals(baseline), reason: '$style 下选中色漂移了');
      }
      expect(baseline, equals(light.colors.brand));
    });
  });

  // ==========================================================================
  // 2. 选中 / 未选中项的可读性
  // ==========================================================================
  group('ParkTabBar · 标签可读性（5 风格 × 明暗）', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        final String label = '$style / ${brightness.name}';

        testWidgets('$label · 未选中标签 vs fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpTabBar(tester, theme: theme);

          final Color fill = effectiveFill(tabBarDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            labelColorOf(tester, _kSecondLabel),
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label 未选中标签仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });

        testWidgets('$label · 选中标签 vs fill ≥ 3.0:1（brand 边界）', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpTabBar(tester, theme: theme);

          final Color fill = effectiveFill(tabBarDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            labelColorOf(tester, _kFirstLabel),
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(3.0),
            reason:
                '$label 选中标签 ${ratio.toStringAsFixed(2)}:1'
                '（brand 在深色面上是 3.36:1，改造前即如此，按 UI 边界 3.0 判定）',
          );
        });
      }
    }

    testWidgets('neon + dark · 未选中标签不再是 textSecondary（2.00:1 反证）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpTabBar(tester, theme: theme);

      final Color fill = effectiveFill(tabBarDecoration(tester), theme);
      expect(
        ParkColors.contrastRatio(theme.colors.textSecondary, fill),
        lessThan(4.5),
        reason: '这正是"未选中态不能死守 textSecondary"的证据',
      );
      expect(
        ParkColors.contrastRatio(labelColorOf(tester, _kSecondLabel), fill),
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
          await pumpTabBar(tester, theme: theme);

          expect(
            labelColorOf(tester, _kSecondLabel),
            equals(theme.colors.textSecondary),
            reason: '$style/${brightness.name} 未选中态发生了不必要的漂移',
          );
        }
      }
    });
  });

  // ==========================================================================
  // 3. 🔴 悬浮式作为独立分支
  // ==========================================================================
  group('ParkTabBar · floating 独立分支', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.flat,
    ]) {
      testWidgets('$style · floating 圆角 brLg + 阴影 md + 无分割线', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpTabBar(
          tester,
          theme: theme,
          type: ParkTabBarType.floating,
          elevation: 8,
        );

        final BoxDecoration d = tabBarDecoration(tester);
        expect(d.borderRadius, equals(theme.radius.brLg));
        // 悬浮式的兜底是 shadows.md —— 与改造前逐字段一致（零回归）。
        expect(d.boxShadow, equals(theme.shadows.md));
        expect(
          d.border,
          isNull,
          reason: '悬浮式不画分割线（圆角已界定边界）',
        );
      });
    }

    testWidgets('neon · floating 阴影由风格接管（不是 shadows.md）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpTabBar(tester, theme: theme, type: ParkTabBarType.floating);

      final List<BoxShadow>? shadows = tabBarDecoration(tester).boxShadow;
      expect(shadows, isNotNull);
      expect(shadows, isNot(equals(theme.shadows.md)));
    });

    testWidgets('圆角恒为组件原值，不消费 tokens.radius（brMd）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpTabBar(tester, theme: theme, type: ParkTabBarType.floating);

      expect(tabBarDecoration(tester).borderRadius, equals(theme.radius.brLg));
      expect(theme.radius.brLg, isNot(equals(theme.radius.brMd)));

      // 贴底式恒为 zero。
      await pumpTabBar(tester, theme: theme, type: ParkTabBarType.fixed);
      expect(tabBarDecoration(tester).borderRadius, equals(BorderRadius.zero));
    });
  });

  // ==========================================================================
  // 4. 零回归：stripe / flat 贴底式
  // ==========================================================================
  group('ParkTabBar · stripe/flat 贴底式零回归', () {
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
        await pumpTabBar(tester, theme: theme);

        expect(tabBarDecoration(tester).color, equals(theme.colors.surface));
      });

      testWidgets('$style · elevation=8 时阴影回落到组件原值', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpTabBar(tester, theme: theme, elevation: 8);

        // 抄改造前的**字面量**：textPrimary 8% / blur=elevation /
        // offset=(0, -elevation*0.25) = (0, -2)。
        expect(
          tabBarDecoration(tester).boxShadow,
          equals(<BoxShadow>[
            BoxShadow(
              color: theme.colors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ]),
        );
      });

      testWidgets('$style · 分割线沿用 colors.divider（观感零回归）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpTabBar(tester, theme: theme, bordered: true);

        final Border border = tabBarDecoration(tester).border! as Border;
        expect(border.top.color, equals(theme.colors.divider));
        expect(border.top.width, equals(0.5));
        expect(border.bottom, equals(BorderSide.none));
      });
    }

    testWidgets('bordered=false 时无分割线', (WidgetTester tester) async {
      await pumpTabBar(
        tester,
        theme: ParkThemeData.light(),
        bordered: false,
      );
      expect(tabBarDecoration(tester).border, isNull);
    });

    testWidgets('elevation=0 时无阴影（组件有显式旋钮）', (
      WidgetTester tester,
    ) async {
      await pumpTabBar(tester, theme: ParkThemeData.light(), elevation: 0);
      expect(tabBarDecoration(tester).boxShadow, isNull);
    });

    testWidgets('neon + dark · 分割线与 fill 可分辨（不消失）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpTabBar(tester, theme: theme, bordered: true);

      final BoxDecoration d = tabBarDecoration(tester);
      final Color fill = effectiveFill(d, theme);
      final Color composited = Color.alphaBlend(
        (d.border! as Border).top.color,
        fill,
      );
      // 分割线刻意很淡，断言口径是"不能与 fill 同色"而非 4.5。
      expect(
        ParkColors.contrastRatio(composited, fill),
        greaterThan(1.02),
        reason: 'neon+dark 下暗色板 divider 是"白 10%"，压在近白 fill 上会消失',
      );
    });
  });

  // ==========================================================================
  // 5. 玻璃风格 / Scope 覆盖
  // ==========================================================================
  group('ParkTabBar · 玻璃与 Scope', () {
    testWidgets('glass 渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpTabBar(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe 不渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpTabBar(tester, theme: ParkThemeData.light());
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('全局 stripe + 局部 glass → 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpTabBar(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('全局 glass + 局部 stripe → 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpTabBar(
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
  // 6. 派生函数直测
  // ==========================================================================
  group('ParkTabBar · resolveParkTabBarSurface', () {
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

          late ParkTabBarSurface resolved;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                extensions: <ThemeExtension<ParkThemeData>>[theme],
              ),
              home: Builder(
                builder: (BuildContext ctx) {
                  resolved = resolveParkTabBarSurface(
                    park: theme,
                    context: ctx,
                    type: ParkTabBarType.fixed,
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
  group('ParkTabBar · 公开默认值不变', () {
    test('所有公开参数默认值锁定', () {
      const ParkTabBar bar = ParkTabBar(
        items: <ParkTabBarItem>[
          ParkTabBarItem(icon: Icons.home, label: 'a'),
        ],
      );
      expect(bar.type, equals(ParkTabBarType.fixed));
      expect(bar.useSafeArea, isTrue);
      expect(bar.fixed, isTrue);
      expect(bar.elevation, 8.0);
      expect(bar.bordered, isTrue);
      expect(bar.shape, equals(ParkTabBarShape.normal));
      expect(bar.size, equals(ParkTabBarSize.medium));
      expect(bar.initialIndex, 0);
      expect(bar.currentIndex, isNull);
      expect(bar.centerAction, isNull);
    });
  });
}
