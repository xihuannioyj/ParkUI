/// 表面令牌派生层（`ParkSurfaceTokens`）与局部覆盖（`ParkSurfaceStyleScope`）
/// 的行为测试。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('ParkSurfaceTokens · 5 种风格全覆盖且无 fallthrough', () {
    test('每个 surfaceStyle 都产出可用的表面令牌', () {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        final ParkThemeData park = ParkThemeData.light();
        final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
          style: style,
          colors: park.colors,
          radius: park.radius,
          blur: park.blur,
          bordered: true,
        );

        expect(t.style, equals(style), reason: '$style 的 style 回写错误');
        expect(t.radius, isNotNull, reason: '$style 必须有圆角');
        expect(t.useBackdropFilter, isA<bool>(), reason: '$style 必须显式声明');
        expect(t.isGlass, equals(style == ParkSurfaceStyle.glass));
      }
    });

    test('5 种风格两两不同（证明映射表不是把所有分支写成同一个结果）', () {
      final ParkThemeData park = ParkThemeData.light();
      final Set<String> signatures = <String>{
        for (final ParkSurfaceStyle style in ParkSurfaceStyle.values)
          _signature(
            ParkSurfaceTokens.resolve(
              style: style,
              colors: park.colors,
              radius: park.radius,
              blur: park.blur,
              bordered: true,
            ),
          ),
      };

      // glass / neo / neon / flat / stripe 五者材质规则互不相同，
      // 若签名去重后少于 5，说明有分支被写成了相同结果。
      expect(
        signatures.length,
        equals(ParkSurfaceStyle.values.length),
        reason: '存在两种风格派生结果完全相同：$signatures',
      );
    });

    test('glass：半透明填充 + 启用 BackdropFilter + 模糊走 ParkBlur.lg', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
      );

      expect(t.fill, park.colors.surface.withValues(alpha: 0.55));
      expect(t.useBackdropFilter, isTrue);
      expect(t.glassAlpha, 0.55);
      expect(t.glassBlur, park.blur.lg, reason: '模糊必须走令牌而非硬编码');
      expect(
        t.border,
        Border.all(
          color: park.colors.textOnBrand.withValues(alpha: 0.40),
          width: 1,
        ),
      );
    });

    test('flat：无阴影 + 边框用 borderLight', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.flat,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
      );

      expect(t.fill, park.colors.surface);
      expect(t.shadows, isNull);
      expect(t.useBackdropFilter, isFalse);
      expect(t.border, Border.all(color: park.colors.borderLight, width: 1));
    });

    test('neo：双柔光阴影（-5,-5 与 +5,+5）+ 无边框', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neo,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
      );

      expect(t.fill, park.colors.background, reason: 'neo 与背景同色');
      expect(t.border, isNull, reason: 'neo 不画边框');
      expect(t.shadows!.length, 2);
      expect(t.shadows![0].offset, const Offset(-5, -5));
      expect(t.shadows![1].offset, const Offset(5, 5));
    });

    test('neon：品牌色辉光阴影 + 发光描边', () {
      final ParkThemeData park = ParkThemeData.dark();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
      );

      expect(t.isDark, isTrue);
      expect(t.fill, park.colors.textPrimary, reason: '深色底下表面取亮色');
      expect(
        t.border,
        Border.all(
          color: park.colors.brand.withValues(alpha: 0.55),
          width: 1,
        ),
      );
      expect(t.shadows!.single.color, park.colors.brand.withValues(alpha: 0.45));
      expect(t.shadows!.single.blurRadius, 20);
    });

    test('neon + light：填充维持 surface（不翻转）', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(t.isDark, isFalse);
      expect(t.fill, park.colors.surface);
    });

    test('neon 是唯一随 isDark 翻转填充色的风格（防 wildcard 兜底吞掉 neon）', () {
      // 回归锁定：曾因 `painted` switch 写了 `_ => colors.surface`，
      // neon 掉进兜底分支，导致深色模式下卡片与背景几乎同色。
      final ParkColors light = ParkColors.light();
      final ParkColors dark = ParkColors.dark();

      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        final Color lightFill = _fill(style, light);
        final Color darkFill = _fill(style, dark);

        if (style == ParkSurfaceStyle.neon) {
          // neon：浅色取 surface，深色取 textPrimary —— 必须翻转。
          expect(lightFill, equals(light.surface));
          expect(darkFill, equals(dark.textPrimary));
          expect(
            lightFill,
            isNot(equals(darkFill)),
            reason: 'neon 必须随 isDark 翻转填充色',
          );
        } else {
          // 其余风格：填充色与 isDark 无关，light/dark 各自等于其色板的
          // 语义值（glass 带 55% alpha，neo 取 background）。
          expect(
            lightFill,
            equals(_expectedPainted(style, light)),
            reason: '$style 在浅色板下的填充色不应受 isDark 影响',
          );
          expect(
            darkFill,
            equals(_expectedPainted(style, dark)),
            reason: '$style 在深色板下的填充色不应受 isDark 影响',
          );
        }
      }
    });

    test('neon + dark：填充色与背景可分辨（不与背景同色）', () {
      final ParkThemeData park = ParkThemeData.dark();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(
        t.fill,
        isNot(equals(park.colors.background)),
        reason: 'neon 卡片不得与页面背景同色，否则深色模式下不可分辨',
      );
      expect(t.fill, isNot(equals(park.colors.surface)));
    });

    test('任意风格 + 深色板：标题色与填充色对比度 >= 4.5:1（AA）', () {
      // 防止"填充色改了但标题色没跟着改"导致文字不可见。
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        for (final bool transparent in <bool>[false, true]) {
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: ParkColors.dark(),
            radius: ParkRadius.defaults(),
            blur: ParkBlur.defaults(),
            transparent: transparent,
          );
          if (transparent) continue; // ghost 态不绘制表面，文字由上层负责

          final double ratio = ParkColors.contrastRatio(t.titleColor, t.fill);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style 在深色板下标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        }
      }
    });

    test('glass + ghost：填充透明（有意统一 ghost 语义，记录行为变更）', () {
      // 迁移前 glass 分支不检查 isGhost，ghost + glass 仍画 55% 半透明填充。
      // 迁移后 ghost 对 5 种风格一致生效，属有意修正，此处锁定当前语义。
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        transparent: true,
      );

      expect(t.fill, Colors.transparent);
      expect(t.shadows, isNull);
    });

    test('每种风格的填充色都与其自身语义一致（逐风格显式断言）', () {
      final ParkThemeData dark = ParkThemeData.dark();
      ParkSurfaceTokens r(ParkSurfaceStyle s) => ParkSurfaceTokens.resolve(
        style: s,
        colors: dark.colors,
        radius: dark.radius,
        blur: dark.blur,
      );

      expect(r(ParkSurfaceStyle.stripe).fill, equals(dark.colors.surface));
      expect(r(ParkSurfaceStyle.flat).fill, equals(dark.colors.surface));
      expect(r(ParkSurfaceStyle.neo).fill, equals(dark.colors.background));
      expect(
        r(ParkSurfaceStyle.glass).fill,
        equals(dark.colors.surface.withValues(alpha: 0.55)),
      );
      expect(r(ParkSurfaceStyle.neon).fill, equals(dark.colors.textPrimary));
    });

    test('所有风格都不污染 ParkColors.brand（品牌语义色保持不透明）', () {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        final ParkThemeData park = ParkThemeData.light();
        ParkSurfaceTokens.resolve(
          style: style,
          colors: park.colors,
          radius: park.radius,
          blur: park.blur,
        );
        expect(
          park.colors.brand.a,
          equals(1.0),
          reason: '$style 风格不得让 colors.brand 变半透明',
        );
        expect(park.colors.brand, equals(const Color(0xFF635BFF)));
      }
    });
  });

  group('ParkSurfaceStyleScope · 局部覆盖', () {
    testWidgets('无 Scope 时回退到全局 surfaceStyle', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceStyle resolved;
      await tester.pumpWidget(
        _probe(
          theme: ParkThemeData.light().copyWith(
            surfaceStyle: ParkSurfaceStyle.neo,
          ),
          onResolve: (ParkSurfaceStyle s) => resolved = s,
        ),
      );

      expect(resolved, equals(ParkSurfaceStyle.neo));
    });

    testWidgets('Scope 可局部覆盖风格（整页 stripe + 单卡 glass）', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceStyle resolved;
      await tester.pumpWidget(
        _probe(
          theme: ParkThemeData.light(),
          scopeStyle: ParkSurfaceStyle.glass,
          onResolve: (ParkSurfaceStyle s) => resolved = s,
        ),
      );

      expect(resolved, equals(ParkSurfaceStyle.glass));
    });

    testWidgets('嵌套时内层覆盖生效、出栈后恢复外层', (
      WidgetTester tester,
    ) async {
      final List<ParkSurfaceStyle> seen = <ParkSurfaceStyle>[];

      await tester.pumpWidget(
        _wrap(
          ParkThemeData.light(),
          ParkSurfaceStyleScope(
            style: ParkSurfaceStyle.glass,
            child: Builder(
              builder: (BuildContext context) {
                seen.add(ParkSurfaceStyleScope.of(context));
                return ParkSurfaceStyleScope(
                  style: ParkSurfaceStyle.neon,
                  child: Builder(
                    builder: (BuildContext inner) {
                      seen.add(ParkSurfaceStyleScope.of(inner));
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(seen, equals(<ParkSurfaceStyle>[
        ParkSurfaceStyle.glass,
        ParkSurfaceStyle.neon,
      ]));
    });

    testWidgets('maybeOf 在无 Scope 时返回 null，of 回退到 stripe', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceStyle? maybe;
      late ParkSurfaceStyle fallback;
      await tester.pumpWidget(
        _probe(
          theme: ParkThemeData.light().copyWith(
            surfaceStyle: ParkSurfaceStyle.neon,
          ),
          onResolve: (ParkSurfaceStyle s) => fallback = s,
          onMaybe: (ParkSurfaceStyle? s) => maybe = s,
        ),
      );

      expect(maybe, isNull, reason: '无 Scope 时不得伪造覆盖');
      expect(fallback, equals(ParkSurfaceStyle.neon));
    });

    testWidgets('tokenOverride 优先于 style', (WidgetTester tester) async {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens override = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      ).copyWith(fill: const Color(0xFF123456));

      late ParkSurfaceTokens resolved;
      await tester.pumpWidget(
        _tokensProbe(
          theme: park,
          scopeStyle: ParkSurfaceStyle.glass,
          tokenOverride: override,
          onResolve: (ParkSurfaceTokens t) => resolved = t,
        ),
      );

      expect(resolved.fill, equals(const Color(0xFF123456)));
      expect(resolved.style, equals(ParkSurfaceStyle.stripe));
    });

    test('updateShouldNotify 只在 style/token 变化时为 true', () {
      const ParkSurfaceStyleScope a = ParkSurfaceStyleScope(
        style: ParkSurfaceStyle.glass,
        child: SizedBox.shrink(),
      );
      const ParkSurfaceStyleScope b = ParkSurfaceStyleScope(
        style: ParkSurfaceStyle.glass,
        child: SizedBox.shrink(),
      );
      const ParkSurfaceStyleScope c = ParkSurfaceStyleScope(
        style: ParkSurfaceStyle.neon,
        child: SizedBox.shrink(),
      );

      expect(a.updateShouldNotify(b), isFalse);
      expect(a.updateShouldNotify(c), isTrue);
    });

    testWidgets('tokensOf 在无 Scope 时按全局风格派生', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceTokens resolved;
      final ParkThemeData park = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.glass,
      );

      await tester.pumpWidget(
        _wrap(
          park,
          Builder(
            builder: (BuildContext context) {
              resolved = ParkSurfaceStyleScope.tokensOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.style, equals(ParkSurfaceStyle.glass));
      expect(resolved.useBackdropFilter, isTrue);
      expect(
        resolved.fill,
        equals(park.colors.surface.withValues(alpha: 0.55)),
      );
    });

    testWidgets('ParkTheme.surfaceTokensOf 与 context 扩展结果一致', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceTokens viaStatic;
      late ParkSurfaceTokens viaExtension;
      final ParkThemeData park = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await tester.pumpWidget(
        _wrap(
          park,
          Builder(
            builder: (BuildContext context) {
              viaStatic = ParkTheme.surfaceTokensOf(context);
              viaExtension = context.parkSurfaceTokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(viaStatic, equals(viaExtension));
      expect(viaStatic.style, equals(ParkSurfaceStyle.neon));
    });
  });

  group('ParkSurfaceTokens 值语义', () {
    test('同输入产出相等实例（hashCode 亦相同）', () {
      final ParkThemeData park = ParkThemeData.light();
      ParkSurfaceTokens make() => ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
      );

      expect(make(), equals(make()));
      expect(make().hashCode, equals(make().hashCode));
    });

    test('copyWith 覆盖单字段不影响其余字段', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens base = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
      );
      final ParkSurfaceTokens next = base.copyWith(
        fill: const Color(0xFFABCDEF),
      );

      expect(next.fill, equals(const Color(0xFFABCDEF)));
      expect(next.style, equals(base.style));
      expect(next.radius, equals(base.radius));
      expect(next.titleColor, equals(base.titleColor));
    });

    test('shadowsOrEmpty 永不返回 null', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.flat,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(t.shadows, isNull);
      expect(t.shadowsOrEmpty, isEmpty);
    });
  });
}

/// 稳定的材质签名，用于比较两种风格的派生结果是否真的不同。
String _signature(ParkSurfaceTokens t) {
  return '${t.style}|${t.fill}|${t.border}|${t.glassBlur}'
      '|${t.glassAlpha}|${t.useBackdropFilter}|${t.shadows}';
}

/// 派生指定风格在指定色板下的填充色（ghost 关闭）。
Color _fill(ParkSurfaceStyle style, ParkColors colors) {
  return ParkSurfaceTokens.resolve(
    style: style,
    colors: colors,
    radius: ParkRadius.defaults(),
    blur: ParkBlur.defaults(),
  ).fill;
}

/// 各风格在**非 neon** 时应得的填充色（与 isDark 无关）。
///
/// 单独列出以表达"这 4 种风格的填充色不随 isDark 翻转"这一不变量。
Color _expectedPainted(ParkSurfaceStyle style, ParkColors colors) {
  return switch (style) {
    ParkSurfaceStyle.stripe => colors.surface,
    ParkSurfaceStyle.flat => colors.surface,
    ParkSurfaceStyle.glass => colors.surface.withValues(alpha: 0.55),
    ParkSurfaceStyle.neo => colors.background,
    // neon 由 isDark 决定，调用方不应走到这里。
    ParkSurfaceStyle.neon =>
      throw StateError('neon 的填充色依赖 isDark，不适用 _expectedPainted'),
  };
}

Widget _probe({
  required ParkThemeData theme,
  ParkSurfaceStyle? scopeStyle,
  required ValueChanged<ParkSurfaceStyle> onResolve,
  ValueChanged<ParkSurfaceStyle?>? onMaybe,
}) {
  Widget child = Builder(
    builder: (BuildContext context) {
      onResolve(ParkSurfaceStyleScope.of(context));
      onMaybe?.call(ParkSurfaceStyleScope.maybeOf(context));
      return const SizedBox.shrink();
    },
  );
  if (scopeStyle != null) {
    child = ParkSurfaceStyleScope(style: scopeStyle, child: child);
  }
  return _wrap(theme, child);
}

Widget _tokensProbe({
  required ParkThemeData theme,
  ParkSurfaceStyle? scopeStyle,
  ParkSurfaceTokens? tokenOverride,
  required ValueChanged<ParkSurfaceTokens> onResolve,
}) {
  return _wrap(
    theme,
    ParkSurfaceStyleScope(
      style: scopeStyle,
      tokenOverride: tokenOverride,
      child: Builder(
        builder: (BuildContext context) {
          onResolve(ParkSurfaceStyleScope.tokensOf(context));
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

Widget _wrap(ParkThemeData theme, Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(body: child),
  );
}
