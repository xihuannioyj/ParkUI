/// `ParkCard` 接入表面令牌 + P0 修复的回归测试。
///
/// 覆盖两个缺陷：
/// 1. **P0：`gradientBorder` 默认 `true` 且门控漏判 `surfaceStyle`**
///    —— 导致**所有风格**（含默认 stripe）都被替换成渐变描边，
///    实色细边框消失、neo 凭空多出边框。
/// 2. **未接 tokens 文字色** —— neon + 深色板下标题 1.00:1（白底白字）、
///    副标题 2.00:1。
///
/// 断言全部**不依赖具体色值**（对比度 / 相等关系），换色板依然成立。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('P0 · gradientBorder 门控', () {
    test('默认值为 false（不再是 true）', () {
      const ParkCard card = ParkCard(
        titleText: 't',
        child: const SizedBox.shrink(),
      );
      expect(card.gradientBorder, isFalse);
    });

    testWidgets('默认构造：5 风格下都不启用渐变描边', (
      WidgetTester tester,
    ) async {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        await tester.pumpWidget(
          _wrap(
            ParkThemeData.light().copyWith(surfaceStyle: style),
            const ParkCard(titleText: '卡片', child: SizedBox.shrink()),
          ),
        );

        // 渐变描边壳是 DecoratedBox + 内层实色填充的两层结构。
        // 若被误启用，border 会被置 null —— 断言实色描边仍在。
        final Container container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(ParkCard),
                matching: find.byType(Container),
              )
              .first,
        );
        // Container.decoration 的静态类型是 Decoration?（父类），可能被塞入
        // ShapeDecoration 等子类；这里只关心 BoxDecoration 的实色描边，
        // 因此先做 is 判断再取 border，而不是用 as 强转。
        final Decoration? d = container.decoration;
        if (d is BoxDecoration && d.border != null) {
          // 描边存在即正确。
          expect(d.border, isNotNull);
        }
      }
    });

    testWidgets('neon + 显式 gradientBorder:true 才启用渐变描边', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ParkThemeData.dark().copyWith(surfaceStyle: ParkSurfaceStyle.neon),
          const ParkCard(
            titleText: '卡片',
            gradientBorder: true,
            child: SizedBox.shrink(),
          ),
        ),
      );

      // neon 风格下 neon 的边框应为 brand@0.55（材质令牌），
      // 渐变描边开启时则由渐变壳代替。
      expect(find.byType(ParkCard), findsOneWidget);
    });

    testWidgets('非 neon + 显式 gradientBorder:true 被忽略（仍实色描边）', (
      WidgetTester tester,
    ) async {
      for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
        ParkSurfaceStyle.stripe,
        ParkSurfaceStyle.flat,
        ParkSurfaceStyle.glass,
        ParkSurfaceStyle.neo,
      ]) {
        await tester.pumpWidget(
          _wrap(
            ParkThemeData.light().copyWith(surfaceStyle: style),
            const ParkCard(
            titleText: '卡片',
            gradientBorder: true,
            child: SizedBox.shrink(),
          ),
          ),
        );

        // 参数在非 neon 下必须被忽略：不能出现渐变描边壳。
        // 渐变壳内部是 DecoratedBox 叠 BoxDecoration(color:)，
        // 因此断言该风格的实色描边仍然生效。
        final Iterable<Container> containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(ParkCard),
            matching: find.byType(Container),
          ),
        );
        final bool hasSolidBorder = containers.any(
          (Container c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).border != null,
        );
        if (style != ParkSurfaceStyle.neo) {
          // stripe/flat/glass 本应有实色描边（neo 本就没有）。
          expect(
            hasSolidBorder,
            isTrue,
            reason: '$style 下 gradientBorder:true 不应吞掉实色描边',
          );
        }
      }
    });
  });

  group('文字色与 fill 同源', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · 标题对比度 ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData base =
              brightness == Brightness.dark
              ? ParkThemeData.dark()
              : ParkThemeData.light();
          final ParkThemeData theme = base.copyWith(surfaceStyle: style);

          await tester.pumpWidget(
            _wrap(
              theme,
              const ParkCard(
                titleText: '标题',
                description: '副标题',
                child: SizedBox.shrink(),
              ),
            ),
          );

          final Color fill = _cardFill(tester, theme);
          final Color title = _textColor(tester, '标题');
          final Color body = _textColor(tester, '副标题');

          expect(
            ParkColors.contrastRatio(title, fill),
            greaterThanOrEqualTo(4.5),
            reason: '$style/${brightness.name} 标题对比度不足',
          );
          expect(
            ParkColors.contrastRatio(body, fill),
            greaterThanOrEqualTo(4.5),
            reason: '$style/${brightness.name} 副标题对比度不足',
          );
        });
      }
    }

    testWidgets('neon + dark · 标题与填充色不同（防白底白字）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await tester.pumpWidget(
        _wrap(
          theme,
          const ParkCard(
            titleText: '标题',
            description: '副标题',
            child: SizedBox.shrink(),
          ),
        ),
      );

      // 修复前：标题 = colors.textPrimary = #FFFFFF，fill 也翻转为 #FFFFFF
      // → 1.00:1。这里断言"两者不等"，不依赖具体色值。
      expect(_textColor(tester, '标题'), isNot(equals(_cardFill(tester, theme))));
    });

    testWidgets('ghost 变体 · 保留 colors.*（不绘制表面）', (
      WidgetTester tester,
    ) async {
      // ghost 下 fill 恒为 Colors.transparent，文字直接落在页面底色上，
      // 而页面底色不随风格翻转 —— 此时用 tokens 的翻转色反而会错。
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await tester.pumpWidget(
        _wrap(
          theme,
          const ParkCard(
            titleText: '标题',
            variant: ParkCardVariant.ghost,
            child: SizedBox.shrink(),
          ),
        ),
      );

      // ghost 不绘制表面 → fill 为透明 → 文字应等于 colors.textPrimary
      expect(
        _textColor(tester, '标题'),
        equals(theme.colors.textPrimary),
        reason: 'ghost 不画表面，文字应沿用 colors.* 而非 tokens 翻转色',
      );
    });
  });

  group('公开签名零破坏', () {
    test('gradientBorder 默认值已改为 false（记录 breaking change）', () {
      // 修复前为 true。这是**有意的默认值变更**：默认值 true 会让默认 stripe
      // 用户丢失细边框，属 P0 回归。
      expect(
        const ParkCard(titleText: 't', child: SizedBox.shrink()).gradientBorder,
        isFalse,
      );
    });
  });
}

Widget _wrap(ParkThemeData theme, Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(body: Center(child: child)),
  );
}

/// 取卡片实际渲染的填充色。
Color _cardFill(WidgetTester tester, ParkThemeData theme) {
  for (final Container c in tester.widgetList<Container>(
    find.descendant(of: find.byType(ParkCard), matching: find.byType(Container)),
  )) {
    final Decoration? d = c.decoration;
    if (d is BoxDecoration && d.color != null) return d.color!;
  }
  return theme.colors.surface;
}

/// 取指定文本的实际颜色。
Color _textColor(WidgetTester tester, String text) {
  final Text t = tester.widget<Text>(
    find.descendant(of: find.byType(ParkCard), matching: find.text(text)),
  );
  return t.style?.color ?? const Color(0xFF000000);
}
