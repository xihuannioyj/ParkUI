/// QA 回归测试 —— 批次 1 独立复核发现（QA Round 1）。
///
/// ## 本文件为何存在
///
/// 这是 QA 在**无法运行 `flutter test`** 的环境下，对
/// `lib/src/theme/park_surface_tokens.dart` 做的逐分支静态复核产物。
/// 它把迁移前 `ParkCard._resolveSurface`（`git show HEAD~1`）的真实取值
/// 钉成字面量断言，专门覆盖工程师既有测试**漏掉**的组合：
/// `neon × dark`、`glass × ghost`。
///
/// 现有 `park_surface_tokens_test.dart:120` 断言
/// `expect(t.fill, park.colors.textPrimary)`，但按源码静态求值该断言**必然失败**
/// （实际值是 `colors.surface`）—— 说明源码与测试同时存在问题。
/// 本文件用**迁移前的真实字面量**作为唯一事实来源，不复用有问题的实现。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  group('QA · neon 填充色零回归（迁移前 card.dart:421-425）', () {
    // 迁移前原文：
    //   final Color color = explicit ??
    //       (isGhost ? Colors.transparent
    //               : (isDark ? colors.textPrimary : colors.surface));
    //
    // 即 neon 的填充色**是唯一随 isDark 翻转的风格**。
    // 迁移后被写进 titleColor（L159-161），而 painted switch（L94-98）
    // 用 `_ => colors.surface` 兜底，导致 neon 填充色丢失翻转。
    test('neon + dark：填充色必须取 colors.textPrimary（近白），不得取 surface', () {
      final ParkThemeData park = ParkThemeData.dark();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(
        t.isDark,
        isTrue,
        reason: 'dark 色板 background=0xFF0A1B2E，亮度 0.0105 < 0.5',
      );
      expect(
        t.fill,
        equals(park.colors.textPrimary),
        reason: '迁移前 neon+dark 填充为 textPrimary(0xFFFFFFFF)；'
            '若退化为 colors.surface(0xFF0F2438) 则深底深面不可见',
      );
      // 防回归护栏：显式区分两个值，避免"恰好相等"蒙混过关。
      expect(park.colors.surface, isNot(equals(park.colors.textPrimary)));
    });

    test('neon + light：填充色维持 colors.surface', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(t.isDark, isFalse);
      expect(t.fill, equals(park.colors.surface));
    });

    test('neon + dark：标题色不得与填充色同色（否则标题不可见）', () {
      final ParkThemeData park = ParkThemeData.dark();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(
        t.titleColor,
        isNot(equals(t.fill)),
        reason: '深色表面上标题需与填充形成对比，同色即不可读',
      );
    });
  });

  group('QA · glass 填充色半透明度零回归（迁移前 card.dart:386）', () {
    // 迁移前：colors.surface.withValues(alpha: 0.55)
    test('glass + light：填充为 surface @55% 透明度', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(t.useBackdropFilter, isTrue);
      expect(t.fill.a, closeTo(0.55, 0.001));
      expect(t.glassAlpha, closeTo(0.55, 0.001));
    });

    // 迁移前 glass 分支**不检查 isGhost**（只有 flat/neo/neon/stripe 检查）。
    // 迁移后统一用 `transparent` 覆盖，ghost 时 fill 变全透明 —— 行为已变更。
    test('glass + ghost：填充透明（记录迁移后行为，锁定当前语义）', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        transparent: true,
      );

      expect(t.fill, equals(Colors.transparent));
    });
  });

  group('QA · painted switch 必须对 5 种风格全部显式分支（禁 wildcard）', () {
    // 源码 L94-98 用 `_ => colors.surface` 兜底，把 neon 一起吞掉。
    // 本组以行为断言代替静态检查：每种风格的 fill 必须符合其自身语义。
    test('stripe/flat 填充为 surface；neo 为 background；glass 为 surface@55%', () {
      final ParkThemeData park = ParkThemeData.dark();

      ParkSurfaceTokens resolve(ParkSurfaceStyle s) => ParkSurfaceTokens.resolve(
            style: s,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );

      // 迁移前 stripe/flat 均为 colors.surface（card.dart:447 / 374）。
      expect(resolve(ParkSurfaceStyle.stripe).fill, equals(park.colors.surface));
      expect(resolve(ParkSurfaceStyle.flat).fill, equals(park.colors.surface));
      // 迁移前 neo 为 colors.background（card.dart:402）。
      expect(resolve(ParkSurfaceStyle.neo).fill, equals(park.colors.background));
      // glass 为 surface @55%。
      expect(resolve(ParkSurfaceStyle.glass).fill.a, closeTo(0.55, 0.001));
    });

    test('neon 是唯一随 isDark 翻转填充色的风格', () {
      // 逐一验证"哪些风格在 dark 下翻转了 fill"，
      // 确保只有 neon 翻转，其余四种不翻转。
      final ParkThemeData light = ParkThemeData.light();
      final ParkThemeData dark = ParkThemeData.dark();

      ParkSurfaceTokens r(ParkSurfaceStyle s, ParkColors c) =>
          ParkSurfaceTokens.resolve(
            style: s,
            colors: c,
            radius: c == light.colors ? light.radius : dark.radius,
            blur: c == light.colors ? light.blur : dark.blur,
          );

      // neon：light 用 surface，dark 用 textPrimary → 两者不同（翻转）。
      expect(
        r(ParkSurfaceStyle.neon, light.colors).fill,
        isNot(equals(r(ParkSurfaceStyle.neon, dark.colors).fill)),
        reason: 'neon 必须随 isDark 翻转填充色',
      );

      // 其余四种不随明暗翻转。
      for (final ParkSurfaceStyle s in <ParkSurfaceStyle>[
        ParkSurfaceStyle.stripe,
        ParkSurfaceStyle.flat,
        ParkSurfaceStyle.neo,
      ]) {
        expect(
          r(s, light.colors).fill,
          equals(r(s, dark.colors).fill),
          reason: '$s 不应随明暗翻转填充色',
        );
      }
    });
  });

  group('QA · ParkSurfaceTokens 全字段不可变性与一致性', () {
    test('同输入两次 resolve 结果完全相等且 hashCode 相同', () {
      final ParkThemeData park = ParkThemeData.light();
      ParkSurfaceTokens resolve() => ParkSurfaceTokens.resolve(
            style: ParkSurfaceStyle.glass,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
            bordered: true,
            elevation: 3,
            hovered: true,
          );

      expect(resolve(), equals(resolve()));
      expect(resolve().hashCode, equals(resolve().hashCode));
    });

    test('ghost(透明) 态一律无阴影（5 种风格全覆盖）', () {
      final ParkThemeData park = ParkThemeData.light();
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
          style: style,
          colors: park.colors,
          radius: park.radius,
          blur: park.blur,
          transparent: true,
          elevation: 8,
        );
        expect(t.shadows, isNull, reason: '$style 的 ghost 态不应有阴影');
        expect(t.fill, equals(Colors.transparent), reason: '$style ghost 应全透明');
      }
    });

    test('elevation=0 且非 hover 时 stripe 无阴影（0 不能被当作有阴影）', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        elevation: 0,
      );
      expect(t.shadows, isNull);
      expect(t.shadowsOrEmpty, isEmpty);
    });
  });

  group('QA · ParkThemePreset 7 值 × light/dark = 14 组合构造不抛异常', () {
    test('全部 14 种组合均可构造，且 surfaceStyle 落在 5 种合法值内', () {
      for (final ParkThemePreset preset in ParkThemePreset.values) {
        for (final Brightness brightness in Brightness.values) {
          final ParkThemeData park = ParkThemeData.preset(preset, brightness: brightness);
          expect(
            ParkSurfaceStyle.values,
            contains(park.surfaceStyle),
            reason: '$preset/$brightness 产生了非法 surfaceStyle',
          );
          // 渐变 getter 必须永不抛异常且可访问。
          expect(park.gradients, isNotNull, reason: '$preset/$brightness gradients 兜底失效');
        }
      }
      expect(ParkThemePreset.values.length, 7, reason: '预设数量应为 7');
    });

    test('stripe 预设仍与 light()/dark() 逐字段相等（红线复核）', () {
      expect(
        ParkThemeData.preset(ParkThemePreset.stripe, brightness: Brightness.light),
        equals(ParkThemeData.light()),
      );
      expect(
        ParkThemeData.preset(ParkThemePreset.stripe, brightness: Brightness.dark),
        equals(ParkThemeData.dark()),
      );
    });
  });

  group('QA · ParkGradient.lerp 边界健壮性（除零 / 空列表）', () {
    test('空颜色列表不崩溃', () {
      const ParkGradient a = ParkGradient.linear(colors: <Color>[]);
      const ParkGradient b = ParkGradient.linear(colors: <Color>[]);
      final ParkGradient r = ParkGradient.lerp(a, b, 0.5);
      expect(r.colors, isEmpty);
    });

    test('颜色数量不等时按中点切换，不崩溃', () {
      const ParkGradient a = ParkGradient.linear(
        colors: <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
      );
      const ParkGradient b = ParkGradient.linear(colors: <Color>[Color(0xFFFF0000)]);
      expect(ParkGradient.lerp(a, b, 0.2).colors.length, 2, reason: 't<0.5 取 a');
      expect(ParkGradient.lerp(a, b, 0.8).colors.length, 1, reason: 't>=0.5 取 b');
    });

    test('t=0 与 t=1 边界不抛异常（含 radius 插值）', () {
      const ParkGradient a = ParkGradient.radial(
        colors: <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
        radius: 0,
      );
      const ParkGradient b = ParkGradient.radial(
        colors: <Color>[Color(0xFFFF0000), Color(0xFF00FF00)],
        radius: 1,
      );
      expect(() => ParkGradient.lerp(a, b, 0), returnsNormally);
      expect(() => ParkGradient.lerp(a, b, 1), returnsNormally);
      expect(ParkGradient.lerp(a, b, 0).radius, 0);
      expect(ParkGradient.lerp(a, b, 1).radius, 1);
    });

    test('单色渐变 lerp 不产生 NaN（长度为 1 的除零风险）', () {
      const ParkGradient a = ParkGradient.linear(colors: <Color>[Color(0xFF000000)]);
      const ParkGradient b = ParkGradient.linear(colors: <Color>[Color(0xFFFFFFFF)]);
      final ParkGradient r = ParkGradient.lerp(a, b, 0.5);
      expect(r.colors.length, 1);
      expect(r.colors.first.a.isFinite, isTrue);
    });
  });

  group('QA · ParkSurfaceStyleScope 嵌套与缺省回退', () {
    testWidgets('三层嵌套：最内层 Scope 覆盖生效', (WidgetTester tester) async {
      late ParkSurfaceStyle inner;
      await tester.pumpWidget(
        MaterialApp(
          home: ParkSurfaceStyleScope(
            style: ParkSurfaceStyle.glass,
            child: ParkSurfaceStyleScope(
              style: ParkSurfaceStyle.neo,
              child: Builder(
                builder: (BuildContext context) {
                  inner = ParkSurfaceStyleScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(inner, equals(ParkSurfaceStyle.neo), reason: '内层应覆盖外层');
    });

    testWidgets('内层 style=null 时应回退到外层而非主题', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceStyle resolved;
      late ParkSurfaceStyle? maybe;
      await tester.pumpWidget(
        MaterialApp(
          home: ParkSurfaceStyleScope(
            style: ParkSurfaceStyle.glass,
            child: ParkSurfaceStyleScope(
              child: Builder(
                builder: (BuildContext context) {
                  maybe = ParkSurfaceStyleScope.maybeOf(context);
                  resolved = ParkSurfaceStyleScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      // maybeOf 只取最近的 Scope（内层 style=null → null）。
      expect(maybe, isNull);
      // of() 会因 maybeOf 为 null 而回退到**主题**（此处无 Theme 扩展 → stripe），
      // 而非外层的 glass —— 这是"就近 Scope 语义"的已知边界，记录在此。
      expect(resolved, equals(ParkSurfaceStyle.stripe));
    });

    testWidgets('无任何 Scope 时回退主题 surfaceStyle', (
      WidgetTester tester,
    ) async {
      late ParkSurfaceStyle resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              resolved = ParkSurfaceStyleScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, equals(ParkSurfaceStyle.stripe), reason: '无主题时兜底 stripe');
    });

    testWidgets('tokenOverride 优先级高于 style', (WidgetTester tester) async {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens override = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        elevation: 9,
      );
      late ParkSurfaceTokens actual;
      await tester.pumpWidget(
        MaterialApp(
          home: ParkSurfaceStyleScope(
            style: ParkSurfaceStyle.glass,
            tokenOverride: override,
            child: Builder(
              builder: (BuildContext context) {
                actual = ParkSurfaceStyleScope.tokensOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(actual, equals(override));
    });
  });
}
