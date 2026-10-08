/// `ParkNavBar` 接入表面派生层的测试。
///
/// ## 覆盖矩阵
///
/// - `transparent × bordered` 全 4 组合 × {stripe, neon} × 明/暗
///   —— 这是本组件**最典型**的陷阱：一个条件同时短路「填充 / 阴影 / 分割线 /
///   模糊」四个属性，漏掉任何一个都会出现"透明但带阴影"的撕裂态。
/// - 5 风格 × 明/暗：标题色与容器 fill 的对比度 ≥ 4.5:1
/// - 透明分支专项：标题必须与**页面背景**可读（背后没有表面）
/// - stripe / flat 零回归：填充色、分割线色、elevation=0 无阴影
/// - elevation > 0：stripe 回落原值，neon 由风格接管
///
/// ## 为什么"透明栏"不能用 tokens.titleColor
///
/// neon + 深色底下 `tokens.titleColor` 是 `colors.surface`（深 navy），
/// 而透明栏背后是页面内容 `colors.background`（同为深 navy）——深压深，
/// 标题直接消失。所以透明是**独立分支**，可读基准换成页面背景。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

const String _kTitle = '页面标题';
const String _kSubTitle = '副标题';

/// 渲染一个导航栏。
Future<void> pumpNavBar(
  WidgetTester tester, {
  required ParkThemeData theme,
  bool transparent = false,
  bool bordered = true,
  double elevation = 0,
  bool withSubTitle = false,
  ParkSurfaceStyle? scopeStyle,
}) async {
  final Widget navBar = withSubTitle
      ? ParkNavBar(
          title: const Text('主标题'),
          subTitle: _kSubTitle,
          transparent: transparent,
          bordered: bordered,
          elevation: elevation,
        )
      : ParkNavBar.text(
          title: _kTitle,
          transparent: transparent,
          bordered: bordered,
          elevation: elevation,
        );

  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(body: navBar),
  );

  if (scopeStyle != null) {
    app = ParkSurfaceStyleScope(style: scopeStyle, child: app);
  }

  await tester.pumpWidget(app);
}

/// 取导航栏**容器**的 decoration（真正受本次改动影响的元素）。
BoxDecoration navBarDecoration(WidgetTester tester) {
  for (final Container c in tester.widgetList<Container>(
    find.descendant(
      of: find.byType(ParkNavBar),
      matching: find.byType(Container),
    ),
  )) {
    final Decoration? d = c.decoration;
    if (d is BoxDecoration) return d;
  }
  throw StateError('未找到导航栏容器 decoration');
}

/// 标题文字的实际渲染色。
Color titleColorOf(WidgetTester tester) {
  return tester.widget<Text>(find.text(_kTitle)).style!.color!;
}

/// 副标题文字的实际渲染色。
Color subTitleColorOf(WidgetTester tester) {
  return tester.widget<Text>(find.text(_kSubTitle)).style!.color!;
}

/// 把可能半透明的填充合成到不透明页面背景上。
///
/// 🔴 `ParkColors.contrastRatio` 只读 r/g/b、**忽略 alpha**。glass 的 fill 是
/// `surface@0.55`，直接拿它算对比度在数学上无效。
Color effectiveFill(BoxDecoration d, ParkThemeData theme) {
  return Color.alphaBlend(d.color!, theme.colors.background);
}

void main() {
  // ==========================================================================
  // 1. 🔴 transparent × bordered 全 4 组合（独立分支，防撕裂态）
  // ==========================================================================
  group('ParkNavBar · transparent × bordered 全 4 组合', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.neon,
    ]) {
      for (final Brightness brightness in Brightness.values) {
        final String base = '$style / ${brightness.name}';

        testWidgets('$base · transparent=true 同时清零填充/阴影/分割线', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          // bordered=true 也要被 transparent 短路 —— 这正是"一个条件控制
          // 多个属性"必须整条处理的原因。
          await pumpNavBar(tester, theme: theme, transparent: true, bordered: true);

          final BoxDecoration d = navBarDecoration(tester);
          expect(d.color, equals(Colors.transparent));
          expect(
            d.boxShadow,
            isNull,
            reason: '$base 透明栏带阴影 = 视觉很脏的撕裂态',
          );
          expect(
            d.border,
            isNull,
            reason: '$base 透明栏不应有分割线',
          );
        });

        testWidgets('$base · transparent=false + bordered=true 有分割线', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpNavBar(
            tester,
            theme: theme,
            transparent: false,
            bordered: true,
          );

          final BoxDecoration d = navBarDecoration(tester);
          expect(d.border, isNotNull);
          // 分割线是"可分辨"而非"高对比"：它本就刻意很淡。
          // 断言口径 = 合成到 fill 之后不能与 fill 同色（否则等于没画）。
          final Color fill = effectiveFill(d, theme);
          final Color composited = Color.alphaBlend(
            (d.border! as Border).bottom.color,
            fill,
          );
          expect(
            ParkColors.contrastRatio(composited, fill),
            greaterThan(1.02),
            reason: '$base 分割线压在 fill 上不可分辨',
          );
        });

        testWidgets('$base · transparent=false + bordered=false 无分割线', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpNavBar(
            tester,
            theme: theme,
            transparent: false,
            bordered: false,
          );

          expect(navBarDecoration(tester).border, isNull);
        });

        testWidgets('$base · transparent=true 标题仍与页面背景可读', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpNavBar(tester, theme: theme, transparent: true);

          // 透明栏背后是页面内容，可读基准是 colors.background 而非 fill。
          final double ratio = ParkColors.contrastRatio(
            titleColorOf(tester),
            theme.colors.background,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$base 透明栏标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }
  });

  // ==========================================================================
  // 2. 5 风格 × 明/暗：标题 / 副标题与容器 fill 的对比度
  // ==========================================================================
  group('ParkNavBar · 5 风格 × 明/暗 · 文字可读性', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        final String label = '$style / ${brightness.name}';

        testWidgets('$label · 标题与容器 fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpNavBar(tester, theme: theme);

          final Color fill = effectiveFill(navBarDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            titleColorOf(tester),
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label 标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });

        testWidgets('$label · 副标题与容器 fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpNavBar(tester, theme: theme, withSubTitle: true);

          final Color fill = effectiveFill(navBarDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            subTitleColorOf(tester),
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label 副标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }

    // neon 是唯一有 isDark 分支的风格，只测 stripe 等于测不出来。
    testWidgets('neon + dark · 标题色不等于 fill（防白底白字）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpNavBar(tester, theme: theme);

      expect(
        titleColorOf(tester),
        isNot(equals(navBarDecoration(tester).color!)),
      );
    });
  });

  // ==========================================================================
  // 3. 零回归：stripe / flat
  // ==========================================================================
  group('ParkNavBar · stripe/flat 零回归', () {
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
        await pumpNavBar(tester, theme: theme);

        expect(navBarDecoration(tester).color, equals(theme.colors.surface));
      });

      testWidgets('$style · 分割线沿用 colors.divider（观感零回归）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpNavBar(tester, theme: theme, bordered: true);

        final Border border = navBarDecoration(tester).border! as Border;
        // 亮色板下 colors.divider 在白色 fill 上仍可分辨，因此应沿用原色。
        expect(border.bottom.color, equals(theme.colors.divider));
        expect(border.bottom.width, equals(0.5));
        expect(border.top, equals(BorderSide.none));
      });

      testWidgets('$style · elevation=0 时无阴影（导航栏有显式旋钮）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpNavBar(tester, theme: theme, elevation: 0);

        expect(
          navBarDecoration(tester).boxShadow,
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
        await pumpNavBar(tester, theme: theme, elevation: 4);

        // 抄改造前的**字面量**：overlay 8% / blur=elevation / offset=(0, e/2)。
        expect(
          navBarDecoration(tester).boxShadow,
          equals(<BoxShadow>[
            BoxShadow(
              color: theme.colors.overlay.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]),
        );
      });
    }

    // 新增能力：风格接管阴影。
    testWidgets('neon · elevation=4 时阴影由风格接管（不是组件原值）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpNavBar(tester, theme: theme, elevation: 4);

      final List<BoxShadow>? shadows = navBarDecoration(tester).boxShadow;
      expect(shadows, isNotNull);
      expect(
        shadows,
        isNot(
          equals(<BoxShadow>[
            BoxShadow(
              color: theme.colors.overlay.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]),
        ),
        reason: 'neon 的阴影应与浮层兜底值不同，即风格确实接管了',
      );
    });
  });

  // ==========================================================================
  // 4. 玻璃风格
  // ==========================================================================
  group('ParkNavBar · 玻璃风格', () {
    testWidgets('glass 渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpNavBar(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe 不渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpNavBar(tester, theme: ParkThemeData.light());

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('transparent + glass 不渲染 BackdropFilter（整条短路）', (
      WidgetTester tester,
    ) async {
      await pumpNavBar(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        transparent: true,
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 5. 局部 Scope 覆盖
  // ==========================================================================
  group('ParkNavBar · ParkSurfaceStyleScope 局部覆盖', () {
    testWidgets('全局 stripe + 局部 glass → 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpNavBar(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('全局 glass + 局部 stripe → 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpNavBar(
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
  group('ParkNavBar · resolveParkNavBarSurface', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · titleColor/bodyColor 可读', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          late ParkNavBarSurface resolved;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                extensions: <ThemeExtension<ParkThemeData>>[theme],
              ),
              home: Builder(
                builder: (BuildContext ctx) {
                  resolved = resolveParkNavBarSurface(park: theme, context: ctx);
                  return const SizedBox.shrink();
                },
              ),
            ),
          );

          final Color fill = Color.alphaBlend(
            resolved.fill,
            theme.colors.background,
          );
          expect(ParkColors.contrastRatio(resolved.titleColor, fill),
              greaterThanOrEqualTo(4.5));
          expect(ParkColors.contrastRatio(resolved.bodyColor, fill),
              greaterThanOrEqualTo(4.5));
        });
      }
    }

    testWidgets('transparent 分支：填充透明且无阴影无分割线无模糊', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      late ParkNavBarSurface resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
          home: Builder(
            builder: (BuildContext ctx) {
              resolved = resolveParkNavBarSurface(
                park: theme,
                context: ctx,
                transparent: true,
                bordered: true,
                elevation: 8,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.fill, equals(Colors.transparent));
      expect(resolved.shadows, isNull);
      expect(resolved.dividerColor, isNull);
      expect(resolved.useBlur, isFalse);
      // 透明分支的可读基准是页面背景，不是 fill。
      expect(
        ParkColors.contrastRatio(
          resolved.titleColor,
          theme.colors.background,
        ),
        greaterThanOrEqualTo(4.5),
      );
      // 反证：若误用 tokens.titleColor（neon+深色下是深 navy），
      // 压在深色页面上会不可读。
      expect(
        ParkColors.contrastRatio(
          ParkSurfaceTokens.resolve(
            style: ParkSurfaceStyle.neon,
            colors: theme.colors,
            radius: theme.radius,
            blur: theme.blur,
          ).titleColor,
          theme.colors.background,
        ),
        lessThan(4.5),
        reason: '这正是"透明栏不能沿用 tokens.titleColor"的证据',
      );
    });
  });

  // ==========================================================================
  // 7. 公开签名零破坏
  // ==========================================================================
  group('ParkNavBar · 公开默认值不变', () {
    test('所有公开参数默认值锁定', () {
      const ParkNavBar bar = ParkNavBar();
      expect(bar.transparent, isFalse);
      expect(bar.height, 56.0);
      expect(bar.safeAreaTop, isTrue);
      expect(bar.bordered, isTrue);
      expect(bar.elevation, 0.0);
      expect(bar.centerTitle, isFalse);
      expect(bar.leftArrow, isFalse);
      expect(bar.backgroundColor, isNull);
      expect(bar.titleColor, isNull);
    });
  });
}
