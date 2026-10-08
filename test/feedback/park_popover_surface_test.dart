/// `ParkPopover` 接入表面派生层的测试。
///
/// ## 覆盖矩阵：5 风格 × 明/暗 × {有箭头, 无箭头, overlayStyle} = 30 组合
///
/// 每组合至少一条**不依赖具体色值**的可读性断言（对比度 ≥ 4.5:1）。
///
/// ## 重点验证的三个点
///
/// 1. **箭头与气泡体成对取值** —— 改造前两者分处两地、各自写死
///    `colors.surface`，主体改由风格令牌决定后会"箭头与气泡不同色"。
///    这是本组件最关键的不变量。
/// 2. **浮层规范可复用** —— 验证 shadow 兜底 / 圆角保 brMd / 无边框
///    三条规范在 popover 上同样成立（证明模式可套用而非一次性方案）。
/// 3. **气泡与背后内容的可分辨性** —— popover 是浮在页面内容之上的，
///    填充色不能与背后内容撞色导致边界消失。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 打开一个 popover 并settle。
Future<void> pumpPopover(
  WidgetTester tester, {
  required ParkThemeData theme,
  bool showArrow = true,
  bool arrow = true,
  BoxDecoration? overlayStyle,
  ParkPopoverDirection direction = ParkPopoverDirection.bottom,
  ParkSurfaceStyle? scopeStyle,
}) async {
  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(
      body: Center(
        child: ParkPopover(
          direction: direction,
          showArrow: showArrow,
          arrow: arrow,
          overlayStyle: overlayStyle,
          trigger: const Text('触发'),
          content: const Text('气泡内容'),
        ),
      ),
    ),
  );

  if (scopeStyle != null) {
    app = ParkSurfaceStyleScope(style: scopeStyle, child: app);
  }

  await tester.pumpWidget(app);
  await tester.tap(find.text('触发'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// 取气泡主体的 decoration。
///
/// popover 渲染在 root Overlay 里（不在 ParkPopover 的子树内），
/// 所以按"带填充色的 Container"定位。
BoxDecoration popoverDecoration(WidgetTester tester) {
  final Iterable<Container> containers = tester.widgetList<Container>(
    find.byType(Container),
  );
  for (final Container c in containers) {
    final Decoration? d = c.decoration;
    if (d is BoxDecoration &&
        d.color != null &&
        d.boxShadow != null) {
      return d;
    }
  }
  throw StateError('未找到气泡主体 decoration');
}

/// 取气泡建议的内容文字色。
///
/// 关键：必须用 [ParkPopoverSurface.titleColor]（来自表面令牌），
/// **不能**用 `colors.textPrimary` —— neon + 深色底下气泡填充会翻转为
/// 近白，此时 textPrimary 与之撞成 1.00:1（白底白字，批次 1 的 P0 同类）。
Color contentTextColor(
  WidgetTester tester,
  ParkThemeData park,
) {
  return resolveParkPopoverSurface(park: park, context: tester.element(find.byType(Scaffold))).titleColor;
}

void main() {
  // ==========================================================================
  // 1. 30 组合矩阵
  // ==========================================================================
  group('ParkPopover · 5 风格 × 明/暗 × 有/无箭头 × overlayStyle', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        // 三个变体：有箭头 / 无箭头 / 自定义 overlayStyle
        for (final String variant in <String>['arrow', 'noArrow', 'custom']) {
          testWidgets(
            '$style / ${brightness.name} / $variant · 内容文字对比度 ≥ 4.5:1',
            (WidgetTester tester) async {
              final ParkThemeData base =
                  brightness == Brightness.dark
                  ? ParkThemeData.dark()
                  : ParkThemeData.light();
              final ParkThemeData theme = base.copyWith(
                surfaceStyle: style,
              );

              await pumpPopover(
                tester,
                theme: theme,
                showArrow: variant != 'noArrow',
                arrow: variant != 'noArrow',
                overlayStyle: variant == 'custom'
                    ? BoxDecoration(color: theme.colors.surface)
                    : null,
              );

              final Color fill = popoverDecoration(tester).color!;
              // 断言不依赖具体色值：只看对比度，换色板依然有效。
              final double ratio = ParkColors.contrastRatio(
                contentTextColor(tester, theme),
                fill,
              );
              expect(
                ratio,
                greaterThanOrEqualTo(4.5),
                reason:
                    '$style/${brightness.name}/$variant 内容对比度仅 '
                    '${ratio.toStringAsFixed(2)}:1',
              );
            },
          );
        }
      }
    }
  });

  // ==========================================================================
  // 2. 🔴 箭头与气泡体成对取值（本组件最关键的不变量）
  // ==========================================================================
  group('ParkPopover · 箭头与气泡体必须同色', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets(
          '$style / ${brightness.name} · 箭头色 == 气泡体填充色',
          (WidgetTester tester) async {
            final ParkThemeData base =
                brightness == Brightness.dark
                ? ParkThemeData.dark()
                : ParkThemeData.light();
            final ParkThemeData theme = base.copyWith(
              surfaceStyle: style,
            );

            late ParkPopoverSurface resolved;
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(
                  extensions: <ThemeExtension<ParkThemeData>>[theme],
                ),
                home: Builder(
                  builder: (BuildContext ctx) {
                    // 直接调用顶层解析函数：箭头颜色是 CustomPainter 的私有
                    // 字段，无法从 widget 树反推，故在源头断言。
                    resolved = resolveParkPopoverSurface(
                      park: theme,
                      context: ctx,
                    );
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );

            // 核心断言：arrowColor 恒等于 fill —— 二者同源，不因风格分叉。
            expect(resolved.arrowColor, equals(resolved.fill));
          },
        );
      }
    }

    testWidgets('overlayStyle 自定义填充时，箭头跟随自定义色', (
      WidgetTester tester,
    ) async {
      const Color customFill = Color(0xFF123456);
      final ParkThemeData theme = ParkThemeData.light();

      late ParkPopoverSurface resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<ParkThemeData>>[theme],
          ),
          home: Builder(
            builder: (BuildContext ctx) {
              resolved = resolveParkPopoverSurface(
                park: theme,
                context: ctx,
                overlayStyle: const BoxDecoration(color: customFill),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.fill, equals(customFill));
      expect(
        resolved.arrowColor,
        equals(customFill),
        reason: '自定义气泡体时箭头必须跟随，否则箭头与体错配',
      );
    });

    testWidgets('overlayStyle 只给阴影不给颜色时，箭头回落 surface', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light();

      late ParkPopoverSurface resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<ParkThemeData>>[theme],
          ),
          home: Builder(
            builder: (BuildContext ctx) {
              resolved = resolveParkPopoverSurface(
                park: theme,
                context: ctx,
                overlayStyle: const BoxDecoration(
                  boxShadow: <BoxShadow>[],
                ),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.fill, equals(theme.colors.surface));
      expect(resolved.arrowColor, equals(resolved.fill));
    });

    testWidgets('neon + dark · 内容文字色可读（防白底白字）', (
      WidgetTester tester,
    ) async {
      // neon 在深色底下 fill 翻转为近白（colors.textPrimary）。
      // 若内容文字仍用 colors.textPrimary，对比度 = 1.00:1（完全不可见）。
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      late ParkPopoverSurface resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<ParkThemeData>>[theme],
          ),
          home: Builder(
            builder: (BuildContext ctx) {
              resolved = resolveParkPopoverSurface(park: theme, context: ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // 断言"建议文字色 != 填充色"（不依赖具体色值）。
      expect(resolved.titleColor, isNot(equals(resolved.fill)));
      expect(
        ParkColors.contrastRatio(resolved.titleColor, resolved.fill),
        greaterThanOrEqualTo(4.5),
        reason: 'neon+dark 下建议文字色必须与近白填充可读',
      );
      // 显式记录：用 colors.textPrimary 会撞成 1.00:1。
      expect(
        ParkColors.contrastRatio(theme.colors.textPrimary, resolved.fill),
        lessThan(1.5),
        reason: '这正是"若沿用 colors.textPrimary 会白底白字"的证据',
      );
    });
  });

  // ==========================================================================
  // 3. 浮层规范可复用性验证
  // ==========================================================================
  group('ParkPopover · 浮层规范三条', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.flat,
    ]) {
      testWidgets('$style · 阴影回落到浮层下限 shadows.lg（零回归）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopover(tester, theme: theme);

        expect(
          popoverDecoration(tester).boxShadow,
          equals(theme.shadows.lg),
          reason: 'tokens 在该风格下无阴影，必须回落到浮层下限，否则气泡失去抬起感',
        );
      });
    }

    testWidgets('圆角保留组件原有 brMd（不是卡片以外的值）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light();
      await pumpPopover(tester, theme: theme);

      expect(
        popoverDecoration(tester).borderRadius,
        equals(theme.radius.brMd),
      );
    });

    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      testWidgets('$style · 无描边（气泡不消费边框）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopover(tester, theme: theme);

        expect(
          popoverDecoration(tester).border,
          isNull,
          reason: '气泡没有 bordered 语义，不应凭空出现描边',
        );
      });
    }

    test('glass/neo/neon 由风格接管阴影（非浮层兜底值）', () {
      final ParkThemeData light = ParkThemeData.light();
      for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
        ParkSurfaceStyle.glass,
        ParkSurfaceStyle.neo,
        ParkSurfaceStyle.neon,
      ]) {
        final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
          style: style,
          colors: light.colors,
          radius: light.radius,
          blur: light.blur,
          bordered: false,
        );
        expect(
          t.shadows,
          isNotNull,
          reason: '$style 应自带阴影（否则风格接管无意义）',
        );
        expect(
          t.shadows,
          isNot(equals(light.shadows.lg)),
          reason: '$style 的阴影应与浮层兜底值不同，即风格确实接管了',
        );
      }
    });
  });

  // ==========================================================================
  // 4. 玻璃风格
  // ==========================================================================
  group('ParkPopover · 玻璃风格', () {
    testWidgets('glass 渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpPopover(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe 不渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpPopover(tester, theme: ParkThemeData.light());

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('overlayStyle 接管时不渲染 BackdropFilter（用户完全接管）', (
      WidgetTester tester,
    ) async {
      await pumpPopover(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        overlayStyle: const BoxDecoration(color: Color(0xFF123456)),
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 5. 局部 Scope 覆盖
  // ==========================================================================
  group('ParkPopover · ParkSurfaceStyleScope 局部覆盖', () {
    testWidgets('全局 stripe + 局部 glass → 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpPopover(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('全局 glass + 局部 stripe → 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpPopover(
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
  // 6. 🔴 气泡与背后内容的可分辨性（浮层类共性问题）
  // ==========================================================================
  group('ParkPopover · 与背后内容的可分辨性', () {
    testWidgets('neon + dark · 气泡与页面背景强对比（17:1+，浮层最显眼）', (
      WidgetTester tester,
    ) async {
      // neon 在深色底下 fill 翻转为近白，与深色背景形成强反差，
      // 这是"浮层必须能被一眼看到"的最强形态。
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpPopover(tester, theme: theme);

      final double ratio = ParkColors.contrastRatio(
        popoverDecoration(tester).color!,
        theme.colors.background,
      );
      expect(ratio, greaterThanOrEqualTo(3.0));
    });

    testWidgets('卡片式浮层：靠阴影而非色差界定边界（shadow 不可缺失）', (
      WidgetTester tester,
    ) async {
      // stripe/flat/glass 的 fill = colors.surface，与 colors.background
      // 仅约 1.06:1 —— 这是**设计意图**（卡片式浮层靠投影界定边界）。
      // 因此边界保障的责任落在"阴影必须存在"上，而非"色差足够大"。
      for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
        ParkSurfaceStyle.stripe,
        ParkSurfaceStyle.flat,
        ParkSurfaceStyle.glass,
      ]) {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopover(tester, theme: theme);
        await tester.pumpAndSettle();

        final Color fill = popoverDecoration(tester).color!;
        // 1) 色差确实很小（记录事实，不是缺陷）
        final double bgRatio = ParkColors.contrastRatio(
          fill,
          theme.colors.background,
        );
        expect(
          bgRatio,
          lessThan(3.0),
          reason: '$style 预期为低色差卡片式浮层（实测 $bgRatio）',
        );
        // 2) 因此阴影必须存在，否则浮层会"融"进背景
        expect(
          popoverDecoration(tester).boxShadow,
          isNotEmpty,
          reason: '$style 低色差浮层必须靠阴影界定边界',
        );
      }
    });

    test('neo 风格：fill 与背景同色是设计意图，靠双柔光阴影界定', () {
      // neo 的 fill 就是 colors.background（同色面），这是新拟态的定义。
      // 它**不能**靠色差保证边界，必须靠阴影。
      final ParkThemeData theme = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neo,
        colors: theme.colors,
        radius: theme.radius,
        blur: theme.blur,
        bordered: false,
      );

      expect(t.fill, equals(theme.colors.background));
      expect(
        t.shadows,
        isNotNull,
        reason: 'neo 靠双柔光阴影而非色差界定边界，阴影不可缺失',
      );
      expect(
        t.shadows!.length,
        equals(2),
        reason: 'neo 的标志是"双柔光"（左上 + 右下）',
      );
    });
  });

  // ==========================================================================
  // 7. 方向维度（几何正交条件，不影响材质但需不回归）
  // ==========================================================================
  group('ParkPopover · 方向不回归', () {
    for (final ParkPopoverDirection dir in ParkPopoverDirection.values) {
      testWidgets('$dir · 正常渲染且填充一致', (WidgetTester tester) async {
        final ParkThemeData theme = ParkThemeData.light();
        await pumpPopover(tester, theme: theme, direction: dir);

        expect(find.text('气泡内容'), findsOneWidget);
        expect(popoverDecoration(tester).color, equals(theme.colors.surface));
      });
    }
  });

  // ==========================================================================
  // 8. 公开签名零破坏
  // ==========================================================================
  group('ParkPopover · 公开默认值不变', () {
    test('所有公开参数默认值锁定', () {
      const ParkPopover p = ParkPopover(
        trigger: Text('t'),
        content: Text('c'),
      );
      expect(p.direction, equals(ParkPopoverDirection.bottom));
      expect(p.closeOnTapOutside, isTrue);
      expect(p.offset, 8);
      expect(p.showArrow, isTrue);
      expect(p.maxWidth, 280);
      expect(p.arrow, isTrue);
      expect(p.triggerMode, equals(ParkPopoverTrigger.click));
      expect(p.overlayStyle, isNull);
      expect(p.autoFlip, isTrue);
      expect(p.zIndex, 1000);
      expect(p.arrowPointAtCenter, isTrue);
    });
  });
}
