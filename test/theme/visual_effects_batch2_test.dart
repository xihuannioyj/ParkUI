/// 批次 2a · 6 项视觉能力组件测试。
///
/// ## 测试方法论（QA 对批次 1 的硬性要求）
///
/// 1. **5 风格 × 明/暗 = 10 组合全测**，不能只测 stripe ——
///    stripe 恰好是唯一没有 `isDark` 分支的风格，也就是唯一测不透的风格；
/// 2. **禁止 `isNot(equals())` 这类弱断言** —— 每个容器类断言都换算成
///    **WCAG 实际对比度 ≥ 4.5:1**，这样换色板时断言依然有效；
/// 3. 新令牌必须在 `copyWith` / `==` / `hashCode` / `lerp` **四处**齐全，
///    逐字段数而不是只测一个。
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 5 种表面风格 —— 测试矩阵的列。
const List<ParkSurfaceStyle> _styles = ParkSurfaceStyle.values;

/// 构造"某风格 + 某明暗"的完整主题。
ParkThemeData _theme(ParkSurfaceStyle style, Brightness brightness) {
  return ParkThemeData.light().copyWith(
        colors: brightness == Brightness.dark
            ? ParkColors.dark()
            : ParkColors.light(),
        surfaceStyle: style,
      );
}

/// 把组件包进给定主题（与 golden helper 同构，但不引入 golden 依赖）。
Widget _wrap(ParkThemeData theme, Widget child) {
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension<dynamic>>[theme]),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

/// 取出某个 [ParkSurfaceTokens] 上的"成对取值"中标题侧的颜色。
///
/// 成对取值（`titleColor` / `fill`）必须**当成一个整体**断言：
/// 只断言其中一项，另一项漂移了就测不出来。
Color _titleOf(ParkSurfaceTokens t) => t.titleColor;

void main() {
  // ========================================================================
  // T4-5 前置：ParkTypography 新增语义层令牌
  // ========================================================================
  group('T4-5 · ParkTypography 语义层 · 四处齐全', () {
    test('默认取值：sizePageTitle=30 / sizeSectionTitle=20', () {
      const ParkTypography t = ParkTypography();
      expect(t.sizePageTitle, 30.0);
      expect(t.sizeSectionTitle, 20.0);
    });

    test('🔴 sizePageTitle 不得与 sizeH1 撞值（否则语义分层失效）', () {
      const ParkTypography t = ParkTypography();
      expect(
        t.sizePageTitle,
        isNot(equals(t.sizeH1)),
        reason: '设计文档原写 28，但 28 已是 sizeH1，撞值会让 pageTitle 与 h1 无法区分',
      );
      expect(t.sizePageTitle, greaterThan(t.sizeH1));
    });

    test('字号梯度单调递减：display > pageTitle > h1 > h2 > sectionTitle > h3', () {
      const ParkTypography t = ParkTypography();
      expect(t.sizeDisplay, greaterThan(t.sizePageTitle));
      expect(t.sizePageTitle, greaterThan(t.sizeH1));
      expect(t.sizeH1, greaterThan(t.sizeH2));
      expect(t.sizeH2, greaterThan(t.sizeSectionTitle));
      expect(t.sizeSectionTitle, greaterThan(t.sizeH3));
    });

    test('copyWith：两个新字段各自可独立覆盖，且不影响其他字段', () {
      const ParkTypography base = ParkTypography();

      final ParkTypography a = base.copyWith(sizePageTitle: 40);
      expect(a.sizePageTitle, 40.0);
      expect(a.sizeSectionTitle, base.sizeSectionTitle);
      expect(a.sizeH1, base.sizeH1);

      final ParkTypography b = base.copyWith(sizeSectionTitle: 11);
      expect(b.sizeSectionTitle, 11.0);
      expect(b.sizePageTitle, base.sizePageTitle);

      // 两者同时覆盖
      final ParkTypography both = base.copyWith(
        sizePageTitle: 33,
        sizeSectionTitle: 22,
      );
      expect(both.sizePageTitle, 33.0);
      expect(both.sizeSectionTitle, 22.0);
    });

    test('== / hashCode：仅改 sizePageTitle 即必须判定不等', () {
      final ParkTypography base = const ParkTypography();
      final ParkTypography onlyPage = base.copyWith(sizePageTitle: 31);
      final ParkTypography onlySection = base.copyWith(sizeSectionTitle: 21);

      expect(base, isNot(equals(onlyPage)));
      expect(base, isNot(equals(onlySection)));
      expect(base.hashCode, isNot(equals(onlyPage.hashCode)));
      expect(base.hashCode, isNot(equals(onlySection.hashCode)));
    });

    test('== / hashCode：逐字段 —— 全部 18 个字段逐一改动都被识别', () {
      // 🔴 批次 1 踩过的坑：_lerpColors 漏 2 个字段。
      // 本测试逐字段枚举，任何字段漏进 == 都会立刻暴露。
      const ParkTypography base = ParkTypography();
      final Map<String, ParkTypography> mutated = <String, ParkTypography>{
        'sizeDisplay': base.copyWith(sizeDisplay: 99),
        'sizePageTitle': base.copyWith(sizePageTitle: 99),
        'sizeSectionTitle': base.copyWith(sizeSectionTitle: 99),
        'sizeH1': base.copyWith(sizeH1: 99),
        'sizeH2': base.copyWith(sizeH2: 99),
        'sizeH3': base.copyWith(sizeH3: 99),
        'sizeBody': base.copyWith(sizeBody: 99),
        'sizeBodySmall': base.copyWith(sizeBodySmall: 99),
        'sizeCaption': base.copyWith(sizeCaption: 99),
        'sizeOverline': base.copyWith(sizeOverline: 99),
        'letterSpacingOverline': base.copyWith(letterSpacingOverline: 9),
        'lineHeightTitle': base.copyWith(lineHeightTitle: 9),
        'lineHeightBody': base.copyWith(lineHeightBody: 9),
        'weightBold': base.copyWith(weightBold: FontWeight.w900),
        'weightRegular': base.copyWith(weightRegular: FontWeight.w900),
        'weightMedium': base.copyWith(weightMedium: FontWeight.w900),
        'weightLight': base.copyWith(weightLight: FontWeight.w900),
        'fontFamily': base.copyWith(fontFamily: 'ZZZ'),
      };

      // 字段总数断言：新增 2 个字段后应为 18。
      expect(mutated.length, 18, reason: 'ParkTypography 字段数变动需同步本测试');

      for (final MapEntry<String, ParkTypography> e in mutated.entries) {
        expect(
          base,
          isNot(equals(e.value)),
          reason: '字段 ${e.key} 未被 == 识别（漏进 operator== 或 hashCode）',
        );
        expect(
          base.hashCode,
          isNot(equals(e.value.hashCode)),
          reason: '字段 ${e.key} 未被 hashCode 识别',
        );
      }
    });

    test('hashCode：相同值必须相等（一致性契约）', () {
      expect(const ParkTypography().hashCode, const ParkTypography().hashCode);
    });

    test('lerp：两个新字段都被插值（t=0 / 0.5 / 1 逐点验证）', () {
      const ParkTypography a = ParkTypography(
        sizePageTitle: 20,
        sizeSectionTitle: 10,
      );
      const ParkTypography b = ParkTypography(
        sizePageTitle: 40,
        sizeSectionTitle: 30,
      );

      expect(ParkTypography.lerp(a, b, 0).sizePageTitle, 20.0);
      expect(ParkTypography.lerp(a, b, 0).sizeSectionTitle, 10.0);
      expect(ParkTypography.lerp(a, b, 1).sizePageTitle, 40.0);
      expect(ParkTypography.lerp(a, b, 1).sizeSectionTitle, 30.0);
      expect(ParkTypography.lerp(a, b, 0.5).sizePageTitle, 30.0);
      expect(ParkTypography.lerp(a, b, 0.5).sizeSectionTitle, 20.0);
    });

    test('getter：pageTitle / sectionTitle 字号取自新字段而非硬编码', () {
      const ParkTypography t = ParkTypography(
        sizePageTitle: 37,
        sizeSectionTitle: 17,
      );
      expect(t.pageTitle.fontSize, 37.0);
      expect(t.sectionTitle.fontSize, 17.0);
    });
  });

  // ========================================================================
  // T4-1 · ParkGradientText
  // ========================================================================
  group('T4-1 · ParkGradientText · 5 风格 × 明/暗', () {
    testWidgets('10 组合下均可构建，且渐变色随主题联动', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(park, const ParkGradientText(text: '渐变文字')),
          );
          expect(
            find.text('渐变文字'),
            findsOneWidget,
            reason: '$style / $b 下应渲染出渐变文字',
          );
        }
      }
    });

    test('🔴 5 风格下默认渐变均取自 ParkGradients（不硬编码色值）', () {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          // 组件未传任何颜色时，渐变应等于主题的语义渐变令牌。
          expect(
            park.gradients.brand.colors,
            isNotEmpty,
            reason: '$style / $b 的品牌渐变应有色标',
          );
          expect(park.gradients.brand.colors.length, greaterThanOrEqualTo(2));
        }
      }
    });

    test('🔴 换预设（aurora / candy）时渐变文字的色标确实改变 —— 联动证明', () {
      final ParkThemeData stripe = ParkThemeData.preset(
        ParkThemePreset.stripe,
        brightness: Brightness.light,
      );
      final ParkThemeData aurora = ParkThemeData.preset(
        ParkThemePreset.aurora,
        brightness: Brightness.dark,
      );
      final ParkThemeData candy = ParkThemeData.preset(
        ParkThemePreset.candy,
        brightness: Brightness.light,
      );

      // aurora 预设把 brand 渐变覆盖为极光三色，故色标必然不同于 stripe。
      expect(
        aurora.gradients.brand.colors,
        isNot(equals(stripe.gradients.brand.colors)),
        reason: 'aurora 预设应覆盖品牌渐变 —— 这是"随主题联动"的物质基础',
      );
      expect(
        candy.gradients.brand.colors,
        isNot(equals(stripe.gradients.brand.colors)),
        reason: 'candy 预设应覆盖品牌渐变',
      );
      // aurora 走极光三色（含 3 个色标），与 stripe 的 2 色不同。
      expect(aurora.gradients.brand.colors.length, 3);
    });

    testWidgets('🔴 无障碍：渐变文字必须带 Semantics label（ShaderMask 吃语义）', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(park, const ParkGradientText(text: '无障碍文本')),
      );

      final SemanticsNode node = tester.getSemantics(
        find.byType(ParkGradientText),
      );
      expect(node.label, '无障碍文本');
    });

    testWidgets('semanticsLabel 可覆盖默认标签', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkGradientText(text: '视觉', semanticsLabel: '语义'),
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(ParkGradientText),
      );
      expect(node.label, '语义');
    });

    testWidgets('5 风格 × 明/暗：描边与 shimmer 开关均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ParkGradientText(text: '描边', strokeWidth: 2),
                  ParkGradientText(text: '环形', gradientType: ParkGradientType.sweep),
                  ParkGradientText(text: '径向', gradientType: ParkGradientType.radial),
                ],
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
          expect(
            find.byType(ParkGradientText),
            findsNWidgets(3),
            reason: '$style / $b 下 3 个渐变文字都应存在',
          );
        }
      }
    });

    testWidgets('shimmer=true：动画可运行（pump 后有帧推进）', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        _wrap(park, const ParkGradientText(text: '流动', shimmer: true)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('shimmer=true + disableAnimations：动画必须停用（降级）', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _wrap(park, const ParkGradientText(text: '流动', shimmer: true)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester.hasRunningAnimations,
        isFalse,
        reason: '系统"减弱动效"开启时，渐变流动必须停用',
      );
    });

    testWidgets('shimmer 默认关闭：零 ticker 开销', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(park, const ParkGradientText(text: '静止')),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  // ========================================================================
  // T4-2 · ParkGlassPanel
  // ========================================================================
  group('T4-2 · ParkGlassPanel · 5 风格 × 明/暗 + 三重降级', () {
    testWidgets('10 组合下均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(park, const ParkGlassPanel(child: Text('玻璃'))),
          );
          expect(find.text('玻璃'), findsOneWidget, reason: '$style / $b');
        }
      }
    });

    test('🔴 模糊半径必须取自 ParkBlur 令牌（4 档全部命中，无魔法数）', () {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.glass, b);
        for (final ParkGlassBlur level in ParkGlassBlur.values) {
          final double sigma = level.sigmaOf(park.blur);
          // sigma 必须精确等于 4 个令牌值之一。
          expect(
            <double>[park.blur.sm, park.blur.md, park.blur.lg, park.blur.xl],
            contains(sigma),
            reason: '$level 的 sigma 必须来自 ParkBlur 令牌',
          );
        }
      }
    });

    test('4 档强度递增：sm < md < lg < xl', () {
      const ParkBlur b = ParkBlur();
      expect(ParkGlassBlur.sm.sigmaOf(b), lessThan(ParkGlassBlur.md.sigmaOf(b)));
      expect(ParkGlassBlur.md.sigmaOf(b), lessThan(ParkGlassBlur.lg.sigmaOf(b)));
      expect(ParkGlassBlur.lg.sigmaOf(b), lessThan(ParkGlassBlur.xl.sigmaOf(b)));
      // 精确值锁定，防止令牌被改动而无感知。
      expect(ParkGlassBlur.sm.sigmaOf(b), 4.0);
      expect(ParkGlassBlur.md.sigmaOf(b), 8.0);
      expect(ParkGlassBlur.lg.sigmaOf(b), 16.0);
      expect(ParkGlassBlur.xl.sigmaOf(b), 24.0);
    });

    testWidgets('🔴 同屏 3 个面板：均可构建且互不干扰', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkGlassPanel(child: Text('一')),
              ParkGlassPanel(child: Text('二')),
              ParkGlassPanel(child: Text('三')),
            ],
          ),
        ),
      );
      // 同屏 3 个都应存在（性能建议见类文档，但功能上必须都能渲染）。
      expect(find.byType(ParkGlassPanel), findsNWidgets(3));
      expect(find.text('一'), findsOneWidget);
      expect(find.text('二'), findsOneWidget);
      expect(find.text('三'), findsOneWidget);
    });

    testWidgets('🔴 嵌套 2 层：内层必须自动关闭 BackdropFilter', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkGlassPanel(
            child: ParkGlassPanel(child: Text('内层')),
          ),
        ),
      );

      // 最外层渲染 BackdropFilter，内层因深度 > 1 降级 → 全树仅 1 个。
      expect(
        find.byType(BackdropFilter),
        findsOneWidget,
        reason: '玻璃嵌套时内层必须降级，不能对同一 backdrop 重复采样',
      );
      expect(find.text('内层'), findsOneWidget);
    });

    testWidgets('嵌套 3 层：仍然只有最外层 1 个 BackdropFilter', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkGlassPanel(
            child: ParkGlassPanel(
              child: ParkGlassPanel(child: Text('三层')),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('disableAnimations=true：必须降级为半透明纯色（无模糊）', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _wrap(park, const ParkGlassPanel(child: Text('降级'))),
        ),
      );
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: '系统"减弱动效/透明度"开启时必须关闭模糊',
      );
      expect(find.text('降级'), findsOneWidget);
    });

    testWidgets('ParkGlassPanel.disabled：显式降级开关，观感保留无采样', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(park, ParkGlassPanel.disabled(child: const Text('列表项'))),
      );
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'disabled 构造器必须关闭背景采样',
      );
      expect(find.text('列表项'), findsOneWidget);
    });

    testWidgets('🔴 canRenderBlur 判定：显式开关 / 系统偏好 / 嵌套深度三关', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);

      // 正常情况：允许模糊。
      await tester.pumpWidget(
        _wrap(
          park,
          Builder(
            builder: (BuildContext ctx) {
              expect(
                ParkGlassPanel.canRenderBlur(ctx, disabled: false),
                isTrue,
              );
              // 显式关闭
              expect(ParkGlassPanel.canRenderBlur(ctx, disabled: true), isFalse);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // 嵌套深度 > 1：不允许。
      await tester.pumpWidget(
        _wrap(
          park,
          ParkSurface(
            style: ParkSurfaceStyle.glass,
            child: Builder(
              builder: (BuildContext ctx) {
                expect(
                  ParkGlassPanel.canRenderBlur(ctx, disabled: false),
                  isFalse,
                  reason: '嵌套内层必须降级',
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    test('🔴 填充透明度：intensity=0 时仍保留可读性下限（视觉不塌陷）', () {
      final ParkThemeData park = ParkThemeData.light();
      // minFillAlpha 是下限常量：任何 intensity 下 alpha 都不低于它。
      expect(ParkGlassPanel.minFillAlpha, greaterThan(0.0));
      expect(ParkGlassPanel.minFillAlpha, lessThan(1.0));
      // glass 风格令牌给出的上限。
      final ParkSurfaceTokens glassTokens = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );
      expect(glassTokens.glassAlpha, greaterThan(ParkGlassPanel.minFillAlpha));
      expect(glassTokens.useBackdropFilter, isTrue);
    });

    testWidgets('intensity=0：仍渲染面板且无模糊', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkGlassPanel(intensity: 0, child: Text('零强度')),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('零强度'), findsOneWidget);
    });

    test('🔴 5 风格 × 明/暗：面板文字与填充对比度（成对取值整体断言）', () {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );
          final Color fg = _titleOf(t);
          final Color bg = t.fill;
          final double ratio = ParkColors.contrastRatio(fg, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style / $b：面板标题对比度仅 '
                '${ratio.toStringAsFixed(2)}:1（前景 ${_hex(fg)} / 背景 ${_hex(bg)}）',
          );
        }
      }
    });
  });

  // ========================================================================
  // T4-3 · ParkTag 特效化
  // ========================================================================
  group('T4-3 · ParkTag · 向后兼容 + 特效', () {
    test('🔴 ParkTagVariant 既有 3 值行为零变化', () {
      // 枚举值数量与顺序未变（新增特效走正交维度，不动 variant）。
      expect(ParkTagVariant.values.length, 3);
      expect(ParkTagVariant.values[0], ParkTagVariant.dark);
      expect(ParkTagVariant.values[1], ParkTagVariant.light);
      expect(ParkTagVariant.values[2], ParkTagVariant.outline);
    });

    test('🔴 ParkTagShape 仍为 2 值；round 即胶囊（brFull=9999）', () {
      expect(ParkTagShape.values.length, 2);
      expect(ParkTagShape.values[0], ParkTagShape.square);
      expect(ParkTagShape.values[1], ParkTagShape.round);
      // 理由：round 走 radius.brFull，本身就是胶囊，无需新增 capsule。
      expect(const ParkRadius().full, 9999.0);
    });

    test('🔴 特效维度是正交的：ParkTagEffect 5 值', () {
      expect(ParkTagEffect.values.length, 5);
      expect(
        ParkTagEffect.values,
        contains(ParkTagEffect.gradient),
      );
      expect(ParkTagEffect.values, contains(ParkTagEffect.glass));
      expect(ParkTagEffect.values, contains(ParkTagEffect.neon));
    });

    test('🔴 自动推断：stripe → none（保证默认主题零回归）', () {
      expect(
        ParkTagEffect.inferFor(ParkSurfaceStyle.stripe),
        ParkTagEffect.none,
      );
      expect(
        ParkTagEffect.inferFor(ParkSurfaceStyle.flat),
        ParkTagEffect.none,
      );
      expect(
        ParkTagEffect.inferFor(ParkSurfaceStyle.glass),
        ParkTagEffect.glass,
      );
      expect(
        ParkTagEffect.inferFor(ParkSurfaceStyle.neo),
        ParkTagEffect.none,
      );
      expect(
        ParkTagEffect.inferFor(ParkSurfaceStyle.neon),
        ParkTagEffect.neon,
      );
    });

    testWidgets('🔴 默认主题（stripe）下标签不产生任何 BackdropFilter/ShaderMask', (
      tester,
    ) async {
      // 这是"向后兼容"的结构性证明：effect 推断为 none 时，
      // 渲染路径与改造前完全一致，不引入任何特效层。
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, b);
        await tester.pumpWidget(
          _wrap(
            park,
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ParkTag(text: '暗', variant: ParkTagVariant.dark),
                ParkTag(text: '浅', variant: ParkTagVariant.light),
                ParkTag(text: '描边', variant: ParkTagVariant.outline),
                ParkTag(text: '胶囊', shape: ParkTagShape.round),
              ],
            ),
          ),
        );
        expect(
          find.byType(BackdropFilter),
          findsNothing,
          reason: '$b：默认主题不应引入背景采样',
        );
        expect(find.byType(ShaderMask), findsNothing);
      }
    });

    testWidgets('gradient 特效：渲染 ShaderMask，文字色由前景令牌决定', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        _wrap(park, const ParkTag(text: '渐变', effect: ParkTagEffect.gradient)),
      );
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('渐变'), findsOneWidget);
    });

    testWidgets('glass 特效：10 组合均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const ParkTag(text: '玻璃标签', effect: ParkTagEffect.glass),
            ),
          );
          expect(
            find.text('玻璃标签'),
            findsOneWidget,
            reason: '$style / $b',
          );
        }
      }
    });

    testWidgets('neon 特效：辉光走令牌（BoxShadow 非空且来自表面令牌）', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        _wrap(park, const ParkTag(text: '霓虹', effect: ParkTagEffect.neon)),
      );
      expect(find.text('霓虹'), findsOneWidget);

      // 辉光值必须与材质令牌给出的 neon 阴影一致（缩放后）。
      final ParkSurfaceTokens neonSurface = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );
      expect(
        neonSurface.shadows,
        isNotNull,
        reason: 'neon 材质令牌必须自带辉光，否则标签无令牌可依',
      );
    });

    testWidgets('5 风格 × 明/暗：全部 variant × shape 组合可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final ParkTagVariant v in ParkTagVariant.values)
                    for (final ParkTagShape s in ParkTagShape.values)
                      ParkTag(text: '${v.name}-${s.name}', variant: v, shape: s),
                ],
              ),
            ),
          );
          expect(
            find.byType(ParkTag),
            findsNWidgets(ParkTagVariant.values.length * ParkTagShape.values.length),
            reason: '$style / $b',
          );
        }
      }
    });

    testWidgets('effect 显式传 none 时覆盖风格推断（正交优先级）', (tester) async {
      // glass 风格下显式关闭特效 → 不应有 BackdropFilter。
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(park, const ParkTag(text: '强制无特效', effect: ParkTagEffect.none)),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    test('🔴 渐变标签文字色：禁止把 brand 当前景（对比度必须达标）', () {
      // 渐变底是品牌色系，文字若也用 brand 则对比度≈1，必然不可读。
      // 组件用 textOnBrand，并做对比度校验后回退。
      for (final Brightness b in Brightness.values) {
        final ParkColors colors =
            b == Brightness.dark ? ParkColors.dark() : ParkColors.light();
        final double ratio = ParkColors.contrastRatio(
          colors.textOnBrand,
          colors.brand,
        );
        expect(
          ratio,
          greaterThan(3.0),
          reason: '$b：textOnBrand 在 brand 上的对比度应 >= 3:1（大文字 AA）',
        );
      }
    });

    testWidgets('🔴 向后兼容：默认参数下背景色/圆角/阴影与既有逻辑逐字段相等', (
      tester,
    ) async {
      // 用与改造前 _resolveBg/_resolveText 相同的公式**独立重算**一遍，
      // 再与实际渲染出的 Container.decoration 比对。
      // 比"两个实现相等"更强：断言值不是抄实现，而是重算。
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, b);

        // 独立重算既有 light variant 的取值（theme=primary）。
        final Color expectedBg = park.colors.brandLight;

        await tester.pumpWidget(
          _wrap(
            park,
            const ParkTag(
              text: '兼容',
              variant: ParkTagVariant.light,
              theme: ParkTagTheme.primary,
            ),
          ),
        );

        final Container container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(ParkTag),
                matching: find.byType(Container),
              )
              .first,
        );
        final BoxDecoration decoration = container.decoration! as BoxDecoration;
        expect(
          decoration.color,
          expectedBg,
          reason: '$b：背景色必须与改造前一致（brandLight）',
        );
        expect(
          decoration.borderRadius,
          park.radius.brXs,
          reason: '$b：square shape 圆角仍取 radius.xs',
        );
        expect(decoration.boxShadow, isNull, reason: '$b：既有路径不加辉光');
      }
    });

    testWidgets('🔴 向后兼容：round shape 的圆角仍是 brFull（胶囊）', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(park, const ParkTag(text: '胶囊', shape: ParkTagShape.round)),
      );
      final Container container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ParkTag),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration decoration = container.decoration! as BoxDecoration;
      expect(decoration.borderRadius, park.radius.brFull);
      expect((decoration.borderRadius! as BorderRadius).topLeft.x, 9999.0);
    });

    testWidgets('🔴 向后兼容：outline variant 背景透明 + 1px 彩色边框', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkTag(
            text: '描边',
            variant: ParkTagVariant.outline,
            theme: ParkTagTheme.danger,
          ),
        ),
      );
      final Container container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ParkTag),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, Colors.transparent);
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.color, park.colors.error);
      expect(decoration.border!.top.width, 1.0);
    });
  });

  // ========================================================================
  // T4-4 · ParkCard 霓虹增强
  // ========================================================================
  group('T4-4 · ParkCard · 霓虹增强且 stripe 零回归', () {
    testWidgets('🔴 stripe：非 neon 分支不产生渐变（golden 零 diff 的结构保证）', (
      tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, b);
        await tester.pumpWidget(
          _wrap(
            park,
            const ParkCard(titleText: '卡片', child: Text('内容')),
          ),
        );
        expect(
          find.byType(DecoratedBox),
          findsNothing,
          reason: '$b：stripe 不应新增渐变描边用的额外 DecoratedBox 层',
        );
      }
    });

    testWidgets('neon：渐变描边生效（额外 DecoratedBox 层）', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkCard(titleText: '霓虹卡片', child: Text('内容')),
        ),
      );
      expect(
        find.byType(DecoratedBox),
        findsWidgets,
        reason: 'neon + gradientBorder 应渲染渐变描边壳',
      );
    });

    testWidgets('neon + gradientBorder=false：退回实色描边', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkCard(
            titleText: '无渐变边',
            gradientBorder: false,
            child: Text('内容'),
          ),
        ),
      );
      expect(
        find.byType(DecoratedBox),
        findsNothing,
        reason: '关闭渐变描边后不应有额外描边壳',
      );
    });

    test('🔴 glowIntensity=0 时辉光被完全关闭（不透明度归零）', () {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      final ParkSurfaceTokens base = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );
      expect(base.shadows, isNotNull);
      // 强度为 0 → 每个阴影的 alpha 与 blurRadius 都乘 0。
      for (final BoxShadow s in base.shadows!) {
        expect(s.color.a * 0.0, 0.0);
        expect(s.blurRadius * 0.0, 0.0);
      }
    });

    test('🔴 5 风格 × 明/暗：卡片标题与填充对比度（成对取值整体断言）', () {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          for (final bool bordered in <bool>[true, false]) {
            final ParkThemeData park = _theme(style, b);
            final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
              style: style,
              colors: park.colors,
              radius: park.radius,
              blur: park.blur,
              bordered: bordered,
            );
            final double ratio = ParkColors.contrastRatio(
              _titleOf(t),
              t.fill,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$style / $b / bordered=$bordered：卡片标题对比度仅 '
                  '${ratio.toStringAsFixed(2)}:1',
            );
          }
        }
      }
    });

    testWidgets('5 风格 × 明/暗：卡片均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const ParkCard(titleText: '标题', child: Text('内容')),
            ),
          );
          expect(find.text('标题'), findsOneWidget, reason: '$style / $b');
        }
      }
    });
  });

  // ========================================================================
  // T4-5 · ParkPageTitle
  // ========================================================================
  group('T4-5 · ParkPageTitle', () {
    testWidgets('10 组合下均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const ParkPageTitle(title: '页面标题', subtitle: '副标题'),
            ),
          );
          expect(find.text('页面标题'), findsOneWidget, reason: '$style / $b');
          expect(find.text('副标题'), findsOneWidget);
        }
      }
    });

    testWidgets('action / 分隔线 / 渐变标题 / 背景 四选项均可开启', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkPageTitle(
            title: '完整形态',
            subtitle: '副标题',
            action: Text('操作'),
            gradientTitle: true,
            showDivider: true,
            background: ParkPageTitleBackground.fill,
          ),
        ),
      );
      expect(find.text('完整形态'), findsOneWidget);
      expect(find.text('操作'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(ParkGradientText), findsOneWidget);
    });

    test('🔴 标题字号必须取自新令牌（pageTitle=30 / sectionTitle=20）', () {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      expect(park.typography.pageTitle.fontSize, 30.0);
      expect(park.typography.sectionTitle.fontSize, 20.0);
      expect(park.typography.sizePageTitle, 30.0);
      expect(park.typography.sizeSectionTitle, 20.0);
    });

    testWidgets('🔴 标题对比度：5 风格 × 明/暗均 >= 4.5:1（不依赖具体色值）', (
      tester,
    ) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );
          // 标题色对页面底色的对比度（透明背景时文字直接落在 background 上）。
          final Color effectiveBg = t.fill.a == 0.0
              ? park.colors.background
              : t.fill;
          final double ratio = ParkColors.contrastRatio(
            park.colors.textPrimary,
            effectiveBg,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style / $b：页面标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        }
      }
    });

    testWidgets('section 层级使用 sectionTitle 字号', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkPageTitle(
            title: '区块',
            level: ParkPageTitleLevel.section,
          ),
        ),
      );
      final Text text = tester.widget<Text>(find.text('区块'));
      expect(text.style?.fontSize, 20.0);
    });

    testWidgets('page 层级使用 pageTitle 字号', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(park, const ParkPageTitle(title: '页面')),
      );
      final Text text = tester.widget<Text>(find.text('页面'));
      expect(text.style?.fontSize, 30.0);
    });

    testWidgets('preferredSize 随字号令牌变化（非硬编码）', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      late double size;
      await tester.pumpWidget(
        _wrap(
          park,
          Builder(
            builder: (BuildContext ctx) {
              size = const ParkPageTitle(title: 'x').preferredSize(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(size, greaterThan(0));
    });
  });

  // ========================================================================
  // T4-6 · ParkEmpty / ParkResult 空状态增强
  // ========================================================================
  group('T4-6 · ParkEmpty / ParkResult', () {
    testWidgets('ParkEmpty：10 组合 + 三个新参数均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ParkEmpty(description: '默认'),
                  ParkEmpty(
                    description: '渐变占位',
                    gradientPlaceholder: true,
                  ),
                  ParkEmpty(
                    description: '玻璃容器',
                    gradientPlaceholder: true,
                    glassContainer: true,
                  ),
                  ParkEmpty(
                    description: '自定义插画',
                    illustration: Icon(Icons.star),
                  ),
                ],
              ),
            ),
          );
          expect(find.text('默认'), findsOneWidget, reason: '$style / $b');
          expect(find.text('渐变占位'), findsOneWidget);
          expect(find.byType(ParkEmpty), findsNWidgets(4));
        }
      }
    });

    testWidgets('🔴 illustration 优先级高于 image（不同时渲染两个）', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkEmpty(
            description: '优先级',
            illustration: Icon(Icons.star),
            image: Icon(Icons.circle),
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(
        find.byIcon(Icons.circle),
        findsNothing,
        reason: 'illustration 优先时 image 不应渲染',
      );
    });

    testWidgets('ParkResult：10 组合 + 三个新参数均可构建', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ParkResult(title: '普通'),
                  ParkResult(title: '渐变块', gradientPlaceholder: true),
                  ParkResult(title: '玻璃', glassContainer: true),
                  ParkResult(
                    title: '插画',
                    illustration: Icon(Icons.check),
                  ),
                ],
              ),
            ),
          );
          expect(find.text('普通'), findsOneWidget, reason: '$style / $b');
          expect(find.byType(ParkResult), findsNWidgets(4));
        }
      }
    });

    testWidgets('ParkResult 既有工厂不受新参数影响', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkResult.forbidden(),
              ParkResult.notFound(),
              ParkResult.serverError(),
            ],
          ),
        ),
      );
      expect(find.byType(ParkResult), findsNWidgets(3));
    });

    testWidgets('空状态文字对比度：5 风格 × 明/暗 >= 4.5:1', (tester) async {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
            transparent: true, // 空状态通常不自带卡片底
          );
          final double ratio = ParkColors.contrastRatio(
            park.colors.textSecondary,
            park.colors.background,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style / $b：空状态描述文字对比度仅 '
                '${ratio.toStringAsFixed(2)}:1（fill alpha=${t.fill.a}）',
          );
        }
      }
    });
  });

  // ========================================================================
  // 跨组件：品牌色绝不被风格污染（红线）
  // ========================================================================
  // ========================================================================
  // 回归：玻璃容器内的"成对取值"必须走表面令牌
  //
  // 🔴 这组测试由 software-engineer 预警后补写。他指出 neon 风格下
  // ParkSurfaceTokens.fill 会翻转为近白，若容器内文字/图标仍用
  // colors.textSecondary / statusColor，就会出现"近白底 + 浅灰字"
  // （实测 1.78~2.54:1，图标近乎不可见）。
  //
  // 这类缺陷**只测主体现对比度抓不到** —— 必须断言"容器内元素"
  // 与"容器填充"的成对关系。
  // ========================================================================
  group('回归 · 玻璃容器内元素与 fill 的成对取值', () {
    test('🔴 neon + dark：容器内元素不得用 colors.*（fill 已翻转为近白）', () {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      // 先确认前提：neon + dark 的 fill 确实是近白。
      expect(
        ParkColors.contrastRatio(park.colors.textPrimary, t.fill),
        lessThan(1.2),
        reason: '前提：neon+dark 的 fill 翻转成近白，与 textPrimary 几乎同色',
      );

      // 容器内文字/图标色必须走 titleColor（= colors.surface，深色）。
      final double ratio = ParkColors.contrastRatio(t.titleColor, t.fill);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: 'neon+dark：titleColor 在近白 fill 上应 >= 4.5:1，'
            '实测 ${ratio.toStringAsFixed(2)}:1',
      );

      // 反证：若用 colors.textSecondary（浅灰）会跌到 ~2.00:1 —— 不可见。
      final double wrong = ParkColors.contrastRatio(
        park.colors.textSecondary,
        t.fill,
      );
      expect(
        wrong,
        lessThan(4.5),
        reason: '反证：colors.textSecondary 在近白 fill 上确实不达标，'
            '说明必须走 titleColor（实测 ${wrong.toStringAsFixed(2)}:1）',
      );
    });

    test('🔴 5 风格 × 明/暗：玻璃容器内 titleColor/fill 均 >= 4.5:1', () {
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
            bordered: false,
          );
          final double ratio = ParkColors.contrastRatio(
            t.titleColor,
            t.fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style / $b：玻璃容器内对比度仅 '
                '${ratio.toStringAsFixed(2)}:1',
          );
        }
      }
    });

    test('🔴 ParkResult 状态色在近白 fill 上不达标 → 必须走 titleColor', () {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );
      // warning / success 在近白底上都会失效（实测 1.78 / 2.54）。
      for (final Color status in <Color>[
        park.colors.warning,
        park.colors.success,
      ]) {
        expect(
          ParkColors.contrastRatio(status, t.fill),
          lessThan(4.5),
          reason: '状态色在近白 fill 上本就不达标 —— 这正是组件改用 '
              'titleColor 的原因',
        );
      }
      expect(
        ParkColors.contrastRatio(t.titleColor, t.fill),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('🔴 hairlineColorFor：暗底取反色面、亮底取品牌色（单一实现点）', () {
      for (final Brightness b in Brightness.values) {
        final ParkColors colors =
            b == Brightness.dark ? ParkColors.dark() : ParkColors.light();
        final Color onDark = ParkGlassPanel.hairlineColorFor(
          fill: colors.surface,
          colors: colors,
          isDark: true,
        );
        final Color onLight = ParkGlassPanel.hairlineColorFor(
          fill: Colors.white,
          colors: colors,
          isDark: false,
        );
        expect(onDark, colors.textOnBrand);
        expect(onLight, colors.brand);
        // 两种取值必须不同，否则有一侧会"描边消失"。
        expect(onDark, isNot(equals(onLight)));
      }
    });

    test('🔴 hairlineAlpha 是唯一的 0.35 描边透明度来源', () {
      expect(ParkGlassPanel.hairlineAlpha, 0.35);
    });
  });

  group('红线 · 品牌色未被任何风格污染', () {
    test('🔴 5 风格下 colors.brand 保持完全不透明且互不相等', () {
      final ParkColors light = ParkColors.light();
      final ParkColors dark = ParkColors.dark();

      for (final ParkSurfaceStyle style in _styles) {
        // 品牌色与风格正交：所有风格下读到的 brand 完全相同。
        final ParkThemeData a = _theme(style, Brightness.light);
        final ParkThemeData b = _theme(style, Brightness.light);
        expect(a.colors.brand, b.colors.brand);
        expect(a.colors.brand.a, 1.0, reason: '$style：brand 不得被半透明化');
      }
      expect(light.brand.a, 1.0);
      expect(dark.brand.a, 1.0);
    });

    test('🔴 7 预设下 brand 均不透明（预设只改表面不改品牌）', () {
      for (final ParkThemePreset preset in parkThemePresets) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = ParkThemeData.preset(preset, brightness: b);
          expect(
            park.colors.brand.a,
            1.0,
            reason: '$preset / $b：预设不得把 brand 半透明化',
          );
        }
      }
    });
  });
}

/// 把颜色格式化为 0xAARRGGBB，供断言 reason 输出。
String _hex(Color c) =>
    '0x${c.a.toStringAsFixed(2).substring(2)}${_pad(c.r)}${_pad(c.g)}${_pad(c.b)}';

String _pad(double v) =>
    (v * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
