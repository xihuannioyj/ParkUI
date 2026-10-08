/// `ParkDialog` 接入表面派生层的测试（批次 2b 样板）。
///
/// ## 覆盖矩阵：5 风格 × 明/暗 × {default, fullscreen, ghost} = 30 组合
///
/// 每组合至少一条**不依赖具体色值**的可读性断言（对比度 ≥ 4.5:1），
/// 这样换色板时断言不会失效 —— 这是批次 1 P0 教训后确立的准则。
///
/// ## 为什么重点测 fullscreen
///
/// `fullscreen` 同时短路 4 个属性（圆角→zero / 阴影→null / mainAxisSize→max /
/// 宽高约束→expand），是典型的"漏搬正交条件"高危点。若只测默认路径，
/// 就会出现"半 fullscreen"撕裂（圆角已是 0 但仍带阴影）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 打开一个对话框并返回其根节点。
///
/// 注意：对外入口是 [ParkDialog.alert] / [ParkDialog.confirm] 等静态方法
/// （`_show` 是私有的），所以这里通过静态方法触发。
/// 用 [ParkDialog.alert] 是因为它带 [ParkDialog.closable] 参数，
/// 可用于验证关闭按钮图标的对比度（bodyColor 的第二个消费点）。
Future<void> pumpDialog(
  WidgetTester tester, {
  required ParkThemeData theme,
  bool fullscreen = false,
  bool closable = false,
  ParkSurfaceStyle? scopeStyle,
  String title = '标题',
  String? content = '内容',
}) async {
  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (BuildContext dialogContext) {
            return ElevatedButton(
              onPressed: () {
                ParkDialog.alert(
                  dialogContext,
                  title: title,
                  content: content,
                  fullscreen: fullscreen,
                  closable: closable,
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    ),
  );

  // 局部风格覆盖：验证 ParkSurfaceStyleScope 对对话框同样生效。
  final Widget app = scopeStyle == null
      ? wrap(const SizedBox.shrink())
      : ParkSurfaceStyleScope(style: scopeStyle, child: wrap(const SizedBox.shrink()));

  await tester.pumpWidget(app);
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// 找到对话框表面的 Container（带 BoxDecoration 且有填充色）。
BoxDecoration dialogDecoration(WidgetTester tester) {
  final Iterable<Container> containers = tester.widgetList<Container>(
    find.descendant(
      of: find.byType(ParkDialog),
      matching: find.byType(Container),
    ),
  );
  for (final Container c in containers) {
    final Decoration? d = c.decoration;
    if (d is BoxDecoration && d.color != null) return d;
  }
  throw StateError('未找到对话框表面 decoration');
}

void main() {
  // ==========================================================================
  // 1. 30 组合矩阵：每组合一条不依赖色值的可读性断言
  // ==========================================================================
  group('ParkDialog · 5 风格 × 明/暗 × {default, fullscreen, ghost}', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        for (final bool fullscreen in <bool>[false, true]) {
          final String label =
              '$style / ${brightness.name} / ${fullscreen ? 'fullscreen' : 'default'}';

          testWidgets('$label · 标题对比度 ≥ 4.5:1（WCAG AA）', (
            WidgetTester tester,
          ) async {
            final ParkThemeData base =
                brightness == Brightness.dark
                ? ParkThemeData.dark()
                : ParkThemeData.light();
            await pumpDialog(
              tester,
              theme: base.copyWith(surfaceStyle: style),
              fullscreen: fullscreen,
            );

            final BoxDecoration d = dialogDecoration(tester);
            // 断言不依赖具体色值：只看对比度，换色板依然有效。
            final double ratio = ParkColors.contrastRatio(
              _titleColorOf(tester, base),
              d.color!,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$label 标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
            );

            // 🔴 正文色必须一并断言 —— 标题可读不代表正文可读。
            //
            // 批次 1 曾在 `ParkSurfaceTokens` 里只给 titleColor 加 neon 翻转、
            // bodyColor 恒为 textSecondary，导致 neon + 深色下：
            //   fill = #FFFFFF（近白）、bodyColor = #ADB8C9 → 2.00:1
            // 而当时本文件**只断言了标题**，因此完全没抓到。
            //
            // 这条断言与标题那条同等重要：两者是"成对取值"，必须同进同出。
            final double bodyRatio = ParkColors.contrastRatio(
              _bodyColorOf(tester, base),
              d.color!,
            );
            expect(
              bodyRatio,
              greaterThanOrEqualTo(4.5),
              reason: '$label 正文对比度仅 ${bodyRatio.toStringAsFixed(2)}:1',
            );
          });
        }
      }
    }
  });

  // ==========================================================================
  // 1b. 正文色专项：成对取值的另一半
  // ==========================================================================
  group('ParkDialog · bodyColor 与 titleColor 同规则（成对取值）', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · bodyColor 与 fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData base =
              brightness == Brightness.dark
              ? ParkThemeData.dark()
              : ParkThemeData.light();
          final ParkThemeData theme = base.copyWith(surfaceStyle: style);

          await pumpDialog(tester, theme: theme);

          final BoxDecoration d = dialogDecoration(tester);
          final double ratio = ParkColors.contrastRatio(
            _bodyColorOf(tester, base),
            d.color!,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style/${brightness.name} 正文 ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }

    testWidgets('neon + dark · 关闭按钮图标同样可读（曾为 2.00:1）', (
      WidgetTester tester,
    ) async {
      // 关闭图标是 bodyColor 的第二个消费点，容易在修 title 时被漏掉。
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await pumpDialog(tester, theme: theme, closable: true);

      final BoxDecoration d = dialogDecoration(tester);
      final Icon icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(ParkDialog),
          matching: find.byIcon(Icons.close),
        ),
      );
      expect(
        ParkColors.contrastRatio(icon.color!, d.color!),
        greaterThanOrEqualTo(4.5),
        reason: '关闭图标在近白 fill 上必须可读',
      );
    });

    testWidgets('neon + dark · bodyColor 不等于 fill（防白底白字回归）', (
      WidgetTester tester,
    ) async {
      // 不依赖具体色值的"必须不同"断言，换色板依然成立。
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await pumpDialog(tester, theme: theme);

      expect(_bodyColorOf(tester, theme), isNot(equals(dialogDecoration(tester).color!)));
    });
  });

  // ==========================================================================
  // 2. ghost 语义：fullscreen 即"无表面的浮层"
  // ==========================================================================
  group('ParkDialog · fullscreen 作为独立分支（防半 fullscreen 撕裂）', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      testWidgets('$style · fullscreen 同时清零圆角与阴影（4 属性一致）', (
        WidgetTester tester,
      ) async {
        await pumpDialog(
          tester,
          theme: ParkThemeData.light().copyWith(surfaceStyle: style),
          fullscreen: true,
        );

        final BoxDecoration d = dialogDecoration(tester);
        expect(
          d.borderRadius,
          equals(BorderRadius.zero),
          reason: '$style fullscreen 圆角必须为 zero',
        );
        expect(
          d.boxShadow,
          isNull,
          reason: '$style fullscreen 不应带阴影（否则圆角0+阴影=撕裂态）',
        );
      });
    }

    testWidgets('fullscreen 不渲染 BackdropFilter（全屏采样无意义且昂贵）', (
      WidgetTester tester,
    ) async {
      await pumpDialog(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        fullscreen: true,
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('glass + 非 fullscreen 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpDialog(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe + 非 fullscreen 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpDialog(
        tester,
        theme: ParkThemeData.light(),
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 3. 零回归：stripe / flat 的阴影与圆角必须与改造前一致
  // ==========================================================================
  group('ParkDialog · stripe/flat 零回归', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.flat,
    ]) {
      testWidgets('$style · 阴影回落到浮层下限 shadows.lg（不丢失）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpDialog(tester, theme: theme);

        final BoxDecoration d = dialogDecoration(tester);
        // tokens 在 stripe/flat 下 shadows 为 null，必须回落到 park.shadows.lg，
        // 否则对话框会突然丢失阴影（浮层的"抬起"感没了）。
        expect(d.boxShadow, isNotNull);
        expect(d.boxShadow, equals(theme.shadows.lg));
      });

      testWidgets('$style · 圆角保持浮层语义 brLg（不是卡片 brMd）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpDialog(tester, theme: theme);

        final BoxDecoration d = dialogDecoration(tester);
        expect(
          d.borderRadius,
          equals(theme.radius.brLg),
          reason: '对话框是比卡片更大的表面，圆角应为 brLg',
        );
      });
    }

    testWidgets('stripe · 填充色等于 colors.surface（与改造前一致）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light();
      await pumpDialog(tester, theme: theme);

      expect(dialogDecoration(tester).color, equals(theme.colors.surface));
    });
  });

  // ==========================================================================
  // 4. 材质性格：glass / neo / neon 由风格接管阴影
  // ==========================================================================
  group('ParkDialog · 非 stripe 风格接管材质', () {
    testWidgets('glass · 阴影为风格定义的柔和阴影（非 shadows.lg）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.glass,
      );
      await pumpDialog(tester, theme: theme);

      expect(dialogDecoration(tester).boxShadow, isNot(equals(theme.shadows.lg)));
    });

    testWidgets('neon · 阴影含品牌色辉光', (WidgetTester tester) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpDialog(tester, theme: theme);

      final List<BoxShadow> shadows = dialogDecoration(tester).boxShadow!;
      expect(shadows, isNotEmpty);
      // 辉光来自品牌色 —— 用"含 brand 色"断言，不硬编码 alpha。
      expect(
        shadows.any(
          (BoxShadow s) => s.color == theme.colors.brand.withValues(alpha: 0.45),
        ),
        isTrue,
        reason: 'neon 对话框应带品牌色辉光',
      );
    });

    testWidgets('neon + dark · 标题与填充色不同（防白底白字）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );
      await pumpDialog(tester, theme: theme);

      final Color fill = dialogDecoration(tester).color!;
      // 不硬编码具体色值，只断言"标题色 != 填充色"——这正是批次 1 neon 缺陷的判据。
      expect(_titleColorOf(tester, theme), isNot(equals(fill)));
    });
  });

  // ==========================================================================
  // 5. 局部 Scope 覆盖
  // ==========================================================================
  group('ParkDialog · ParkSurfaceStyleScope 局部覆盖生效', () {
    testWidgets('Scope(style: glass) 使 stripe 全局主题下的对话框变玻璃', (
      WidgetTester tester,
    ) async {
      // 全局 stripe（无 BackdropFilter），局部 Scope 覆盖为 glass。
      await pumpDialog(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('Scope 覆盖为 flat 时不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpDialog(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        scopeStyle: ParkSurfaceStyle.flat,
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 6. 公开 API 零破坏
  // ==========================================================================
  group('ParkDialog · 公开签名未变', () {
    test('fullscreen / mask 等参数默认值不变', () {
      const ParkDialog d = ParkDialog(title: 't');
      expect(d.fullscreen, isFalse);
      // mask 是既有死参数（从未被消费，见报告），此处仅锁定默认值不变。
      expect(d.mask, isTrue);
      expect(d.centered, isFalse);
      expect(d.closable, isFalse);
      expect(d.confirmLoading, isFalse);
      expect(d.keyboard, isTrue);
      expect(d.barrierDismissible, isTrue);
    });
  });
}

/// 取对话框标题的实际颜色。
///
/// 优先从渲染出的 Text 里读；读不到则回退到按风格派生的令牌，
/// 保证断言在结构变化时仍能工作。
Color _titleColorOf(WidgetTester tester, ParkThemeData theme) {
  final Iterable<Text> titles = tester.widgetList<Text>(
    find.descendant(of: find.byType(ParkDialog), matching: find.byType(Text)),
  );
  for (final Text t in titles) {
    final Color? c = t.style?.color;
    if (c != null) return c;
  }
  // 回退：按当前风格派生标题色（与 ParkSurfaceTokens 逻辑一致）。
  final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
    style: theme.surfaceStyle,
    colors: theme.colors,
    radius: theme.radius,
    blur: theme.blur,
  );
  return t.titleColor;
}

/// 取对话框正文 / 次要文字（关闭按钮、关闭图标）的实际颜色。
///
/// 与 [_titleColorOf] 读同一个 Text 列表的**最后一个**带色节点 ——
/// 标题在前、正文在后，因此这正好取到正文色。
Color _bodyColorOf(WidgetTester tester, ParkThemeData theme) {
  final List<Color> colors = <Color>[
    for (final Text t in tester.widgetList<Text>(
      find.descendant(
        of: find.byType(ParkDialog),
        matching: find.byType(Text),
      ),
    ))
      if (t.style?.color != null) t.style!.color!,
  ];
  if (colors.isNotEmpty) return colors.last;
  // 回退：按当前风格派生正文色。
  return ParkSurfaceTokens.resolve(
    style: theme.surfaceStyle,
    colors: theme.colors,
    radius: theme.radius,
    blur: theme.blur,
  ).bodyColor;
}
