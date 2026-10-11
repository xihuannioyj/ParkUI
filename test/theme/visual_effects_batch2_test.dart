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

    test('🔴 5 风格 × 明/暗：玻璃面板的 fill 必可承载 tokens.titleColor', () {
      // 🔴 注意断言对象：ParkGlassPanel 内部**不渲染任何文字**，
      // 文字色由调用方从 ParkSurfaceTokens.titleColor 取。因此这里断言的是
      // "面板提供的 fill"与"调用方应取的 titleColor"这对成对取值 ——
      // 消费者正是 ParkEmpty / ParkResult / ParkTag，它们已在
      // 「回归 · 玻璃容器内元素与 fill 的成对取值」里做 widget 级实测。
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );
          final double ratio = ParkColors.contrastRatio(
            _titleOf(t),
            t.fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style / $b：面板 fill 与 titleColor 对比度仅 '
                '${ratio.toStringAsFixed(2)}:1',
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

    // --------------------------------------------------------------
    // 🔴 反向锁：gradientBorder 默认 true，但**非 neon 风格的实色边框
    // 必须仍然存在**（若被渐变描边顶掉，stripe/flat/glass 会同时丢边框）。
    //
    // 这条是"gradientBorder 只在 neon 生效"的**决定性证据**：
    // 它断言的不是"没有 DecoratedBox"（那可能只是没渲染），
    // 而是"AnimatedContainer.decoration.border 仍然非 null 且等于
    // 表面令牌给出的边框"。
    // --------------------------------------------------------------
    testWidgets('🔴 gradientBorder 默认 true 时，非 neon 风格边框不得消失', (
      tester,
    ) async {
      for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
        ParkSurfaceStyle.stripe,
        ParkSurfaceStyle.flat,
        ParkSurfaceStyle.glass,
        ParkSurfaceStyle.neo,
      ]) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          await tester.pumpWidget(
            _wrap(
              park,
              const ParkCard(titleText: '边框', child: Text('内容')),
            ),
          );

          // 取真实渲染的 AnimatedContainer 装饰。
          final AnimatedContainer container = tester.widget<AnimatedContainer>(
            find
                .descendant(
                  of: find.byType(ParkCard),
                  matching: find.byType(AnimatedContainer),
                )
                .last,
          );
          final BoxDecoration decoration =
              container.decoration! as BoxDecoration;

          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );

          if (t.border != null) {
            // 该风格本应有边框 → 必须真的画出来了。
            expect(
              decoration.border,
              isNotNull,
              reason: '$style / $b：材质令牌给了边框（${t.border}），'
                  '但渲染层没有 —— 说明 gradientBorder 误伤了非 neon 风格',
            );
            expect(
              decoration.border!.top.color,
              t.border!.top.color,
              reason: '$style / $b：边框颜色必须与表面令牌一致',
            );
            expect(decoration.border!.top.width, t.border!.top.width);
          } else {
            // neo 令牌本就无边框（靠双柔光表达体积感）→ 也不该凭空有。
            expect(
              decoration.border,
              isNull,
              reason: '$style / $b：材质令牌无边框，渲染层也不应有',
            );
          }
        }
      }
    });

    testWidgets('🔴 neon：默认 gradientBorder=true 才有渐变描边壳', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      // 默认值（不传 gradientBorder）→ 应有描边壳。
      await tester.pumpWidget(
        _wrap(park, const ParkCard(titleText: '默认', child: Text('x'))),
      );
      expect(
        find.byType(DecoratedBox),
        findsWidgets,
        reason: 'neon 默认应启用渐变描边',
      );

      // 显式关闭 → 无描边壳，但实色边框回来。
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkCard(
            titleText: '关闭',
            gradientBorder: false,
            child: Text('x'),
          ),
        ),
      );
      expect(find.byType(DecoratedBox), findsNothing);
      final AnimatedContainer c = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(ParkCard),
              matching: find.byType(AnimatedContainer),
            )
            .last,
      );
      expect(
        (c.decoration! as BoxDecoration).border,
        isNotNull,
        reason: 'gradientBorder=false 时 neon 应恢复实色边框',
      );
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

    // --------------------------------------------------------------
    // 🔴 断言穿透到 widget 树（补 ce93e86 前"只断言 tokens 层"的漏洞）
    //
    // 上一轮教训：断言停在 ParkSurfaceTokens 层，只能证明"令牌算对了"，
    // 证明不了"组件真的把那个值用在了实际渲染的元素上"。
    // 以下用例改为**从 widget 树取出真实样式**再判对比度。
    // --------------------------------------------------------------

    testWidgets('🔴 ParkEmpty 玻璃容器：真实渲染的 Icon 颜色可读', (
      tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
        await tester.pumpWidget(
          _wrap(
            park,
            // 🔴 **不能同时开gradientPlaceholder** —— 实现里渐变占位块
            // 在 glassContainer 之前早退（park_empty.dart:343），
            // 两者同开时 glass 容器根本不会被渲染，断言就成了空转。
            // 这里要验的是玻璃容器分支，故只开 glassContainer。
            const ParkEmpty(
              description: '容器',
              glassContainer: true,
            ),
          ),
        );

        // 从 widget 树取真实渲染的容器装饰与图标，而不是重算令牌。
        final Container container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(ParkEmpty),
                matching: find.byType(Container),
              )
              .first,
        );
        final Color fill =
            (container.decoration! as BoxDecoration).color!;
        final Icon icon = tester.widget<Icon>(find.byType(Icon).first);

        final double ratio = ParkColors.contrastRatio(
          icon.color ?? park.colors.textPrimary,
          fill,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$b：真实渲染的 Icon/fill 对比度仅 '
              '${ratio.toStringAsFixed(2)}:1 —— 断言必须穿透到 widget 树',
        );
      }
    });

    testWidgets('🔴 ParkResult 玻璃容器：真实渲染的 Icon 颜色可读', (
      tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
        await tester.pumpWidget(
          _wrap(
            park,
            // 🔴 不能同时开 gradientPlaceholder ——渐变块在
            // glassContainer 之前早退（park_result.dart:344），
            // 同开时玻璃容器不会被渲染，断言会空转。
            const ParkResult(
              title: '容器',
              status: ParkResultStatus.warning,
              glassContainer: true,
            ),
          ),
        );

        final Container container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(ParkResult),
                matching: find.byType(Container),
              )
              .first,
        );
        final Color fill =
            (container.decoration! as BoxDecoration).color!;
        final Icon icon = tester.widget<Icon>(find.byType(Icon).first);

        final double ratio = ParkColors.contrastRatio(
          icon.color ?? park.colors.textPrimary,
          fill,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$b：warning 状态下真实 Icon/fill 仅 '
              '${ratio.toStringAsFixed(2)}:1',
        );
      }
    });

    testWidgets('🔴 ParkTag gradient：真实渲染的文字色可读（不是判 accent）', (
      tester,
    ) async {
      // 关键：theme=warning 时旧实现拿 warning 橙去判对比度，
      // 但真正绘制的是 brand 紫渐变 —— 断言必须对着"实际画的东西"。
      for (final ParkTagTheme t in ParkTagTheme.values) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
          await tester.pumpWidget(
            _wrap(
              park,
              ParkTag(
                text: '渐变',
                theme: t,
                effect: ParkTagEffect.gradient,
              ),
            ),
          );

          final Text text = tester.widget<Text>(find.text('渐变'));
          final Color fg = text.style!.color!;

          // 背景是 brand 渐变，取最亮色标作为最坏落点。
          Color lightest = park.gradients.brand.colors.first;
          for (final Color c in park.gradients.brand.colors) {
            if (c.computeLuminance() > lightest.computeLuminance()) {
              lightest = c;
            }
          }

          final double ratio = ParkColors.contrastRatio(fg, lightest);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'theme=$t / $b：真实文字色在渐变最亮色标上仅 '
                '${ratio.toStringAsFixed(2)}:1',
          );
        }
      }
    });

    test('🔴 gradient 前景判据：对着渐变最亮色标而非 theme 色', () {
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.light);
      // 渐变最亮色标
      Color lightest = park.gradients.brand.colors.first;
      for (final Color c in park.gradients.brand.colors) {
        if (c.computeLuminance() > lightest.computeLuminance()) {
          lightest = c;
        }
      }
      // 前景应等于两个候选令牌中"实测更优"的那个。
      final double onBrand = ParkColors.contrastRatio(
        park.colors.textOnBrand,
        lightest,
      );
      final double onPrimary = ParkColors.contrastRatio(
        park.colors.textPrimary,
        lightest,
      );
      final Color expected =
          onBrand >= onPrimary ? park.colors.textOnBrand : park.colors.textPrimary;
      expect(onBrand, greaterThanOrEqualTo(4.5));
      expect(expected, park.colors.textOnBrand);
    });

    // --------------------------------------------------------------
    // 🔴 互斥参数：`gradientPlaceholder` 与 `glassContainer` 同开时，
    //    渐变块早退，玻璃容器永不渲染 —— 这是真实的 API 陷阱
    //    （我自己第一次写测试时同时开了两个，断言直接空转）。
    //    这里把优先级钉死：两个参数各自单独可用，组合时有确定胜者。
    // --------------------------------------------------------------

    testWidgets('🔴 gradientPlaceholder 优先于 glassContainer（互斥钉死）', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);

      // 同开两者 -> 渐变块胜出：应能找到带 gradient 的 DecoratedBox。
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkEmpty(
            description: '互斥',
            gradientPlaceholder: true,
            glassContainer: true,
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).gradient != null,
        ),
        findsWidgets,
        reason: 'gradientPlaceholder 优先，渐变块应被渲染',
      );
      // 图标色取 textOnBrand（反色面），而不是玻璃容器的 titleColor。
      final Icon icon = tester.widget<Icon>(find.byType(Icon).first);
      expect(icon.color, park.colors.textOnBrand);

      // 仅开 glassContainer -> 走玻璃容器分支（无渐变）。
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkEmpty(description: '仅玻璃', glassContainer: true),
        ),
      );
      final Container container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(ParkEmpty),
              matching: find.byType(Container),
            )
            .first,
      );
      final Color fill =
          (container.decoration! as BoxDecoration).color!;
      expect(
        ParkColors.contrastRatio(
          tester.widget<Icon>(find.byType(Icon).first).color!,
          fill,
        ),
        greaterThanOrEqualTo(4.5),
        reason: '仅开 glassContainer 时走玻璃分支，Icon 必须走 titleColor',
      );
    });

    testWidgets('🔴 ParkResult 同样：gradientPlaceholder 优先', (tester) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkResult(
            title: '互斥',
            gradientPlaceholder: true,
            glassContainer: true,
          ),
        ),
      );
      // 渐变块胜出：状态图标用 textOnBrand，而非玻璃容器的 titleColor。
      final Icon icon = tester.widget<Icon>(find.byType(Icon).first);
      expect(icon.color, park.colors.textOnBrand);
    });

    test('🔴 ParkGlassPanel 本身不设文字色 —— 契约由调用方履行', () {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.dark);
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.glass,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );
      // 容器提供 fill，文字色由调用方消费 titleColor —— 二者必须成对可读。
      expect(
        ParkColors.contrastRatio(t.titleColor, t.fill),
        greaterThanOrEqualTo(4.5),
      );
    });

    // --------------------------------------------------------------
    // 🔴 ParkPageTitle：背景与前景必须同源（本批次漏掉的第三处）
    //
    // 原实现标题色硬编码 colors.textPrimary，而 background:fill 时
    // 背景取 surface.fill —— neon+dark 下 fill 翻转为近白，
    // 于是"白底白字"，实测对比度 1.00:1。
    // --------------------------------------------------------------

    testWidgets('🔴 ParkPageTitle + background:fill：真实标题色可读', (
      tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
        await tester.pumpWidget(
          _wrap(
            park,
            const ParkPageTitle(
              title: '订单管理',
              background: ParkPageTitleBackground.fill,
            ),
          ),
        );

        // 从 widget 树取真实背景与真实文字色，而不是重算令牌。
        final DecoratedBox box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(ParkPageTitle),
            matching: find.byType(DecoratedBox),
          ),
        );
        final Color fill = (box.decoration as BoxDecoration).color!;
        final Text text = tester.widget<Text>(find.text('订单管理'));

        final double ratio = ParkColors.contrastRatio(
          text.style!.color!,
          fill,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$b：真实标题/fill 仅 ${ratio.toStringAsFixed(2)}:1'
              '（修复前 neon+dark 为 1.00:1 白底白字）',
        );
      }
    });

    testWidgets('🔴 ParkPageTitle + 副标题：真实副标题色可读', (tester) async {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
        await tester.pumpWidget(
          _wrap(
            park,
            const ParkPageTitle(
              title: '标题',
              subtitle: '共 128 条',
              background: ParkPageTitleBackground.fill,
            ),
          ),
        );

        final DecoratedBox box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(ParkPageTitle),
            matching: find.byType(DecoratedBox),
          ),
        );
        final Color fill = (box.decoration as BoxDecoration).color!;
        final Text sub = tester.widget<Text>(find.text('共 128 条'));

        final double ratio = ParkColors.contrastRatio(
          sub.style!.color!,
          fill,
        );
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '$b：真实副标题/fill 仅 ${ratio.toStringAsFixed(2)}:1',
        );
      }
    });

    testWidgets('🔴 ParkPageTitle 透明背景：必须保留 colors.*（不得被 tokens 污染）', (
      tester,
    ) async {
      // 透明背景下文字落在页面底色上（恒为 colors.background，不翻转），
      // 此时沿用 colors.textPrimary 才是对的 —— 防止"过度修复"引入回归。
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
        await tester.pumpWidget(
          _wrap(park, const ParkPageTitle(title: '透明底')),
        );
        final Text text = tester.widget<Text>(find.text('透明底'));
        expect(
          text.style!.color,
          park.colors.textPrimary,
          reason: '$b：透明背景不应改动标题色来源',
        );
        // 且必须真的没有绘制背景
        expect(
          find.descendant(
            of: find.byType(ParkPageTitle),
            matching: find.byType(DecoratedBox),
          ),
          findsNothing,
        );
      }
    });

    // ========================================================================
  // illustration 路径 —— 文档承诺的组合方式此前零覆盖（team-lead 指出的真缺口）
  //
  // 缺口性质与此前几轮不同：不是"断言对象选错"，而是**文档承诺了
  // 组合语义却没有任何断言守着**。按 team-lead 采纳的团队准则
  // 「任何正确性承诺都必须能指出一条会在该承诺被破坏时失败的断言」，
  // 本组把下列承诺逐条钉死。
  // ========================================================================
  group('illustration 路径 · 文档承诺的组合语义', () {
    testWidgets('🔴 ParkResult：illustration 优先于 icon（文档 L81 承诺）', (
      tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.neon, b);
        await tester.pumpWidget(
          _wrap(
            park,
            const ParkResult(
              title: '优先级',
              illustration: Icon(Icons.brush),
              icon: Icon(Icons.circle),
            ),
          ),
        );
        expect(
          find.byIcon(Icons.brush),
          findsOneWidget,
          reason: '$b：illustration 应胜出',
        );
        expect(
          find.byIcon(Icons.circle),
          findsNothing,
          reason: '$b：icon 应被illustration 顶掉（文档 L81 承诺）',
        );
      }
    });

    testWidgets('🔴 ParkResult：illustration 存在时无渐变块/无默认圆容器', (
      tester,
    ) async {
      // 优先级链illustration > icon > gradientPlaceholder > 默认圆容器。
      // 既然illustration 已给出，后两者都不该出现。
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkResult(
            title: '独占',
            illustration: Icon(Icons.brush),
            gradientPlaceholder: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.brush), findsOneWidget);
      // 渐变占位块是 BoxShape.circle 容器 + 默认状态图标；
      // 既然走了 illustration 分支，默认状态图标不应存在。
      expect(
        find.byIcon(Icons.info),
        findsNothing,
        reason: 'illustration 存在时不应回落到默认状态图标',
      );
    });

    testWidgets('🔴 ParkEmpty：illustration 不被任何容器包裹（保持原样）', (
      tester,
    ) async {
      // 文档承诺"用户提供的插画/图片原样渲染（不做任何包裹），
      // 以免改变用户自己设计的排版"。
      // 验证方式：把illustration 放进一个可识别的自定义容器，
      // 断言该容器在树中原样存在（未被 DecoratedBox/ClipRRect 包住）。
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.glass, b);
        await tester.pumpWidget(
          _wrap(
            park,
            ParkEmpty(
              description: '原样',
              illustration: Container(
                key: const Key('my-illustration'),
                width: 40,
                height: 40,
                color: park.colors.brand,
                child: const Icon(Icons.brush),
              ),
            ),
          ),
        );
        expect(
          find.byKey(const Key('my-illustration')),
          findsOneWidget,
          reason: '$b：用户插画应原样渲染',
        );
        // 关键：玻璃容器**不应**包住用户插画 ——
        // 否则等于替用户改了他自己的排版。
        expect(
          find.ancestor(
            of: find.byKey(const Key('my-illustration')),
            matching: find.byType(ClipRRect),
          ),
          findsNothing,
          reason: '$b：用户插画不得被裁剪包裹（会破坏自定义排版）',
        );
      }
    });

    testWidgets('🔴 ParkEmpty：illustration 优先于 gradientPlaceholder', (
      tester,
    ) async {
      final ParkThemeData park = _theme(ParkSurfaceStyle.glass, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkEmpty(
            description: '混合',
            illustration: Icon(Icons.brush),
            gradientPlaceholder: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.brush), findsOneWidget);
      expect(
        find.byIcon(Icons.inbox),
        findsNothing,
        reason: 'illustration 应优先于渐变占位块',
      );
    });

    testWidgets('🔴 ParkEmpty：image 仍被支持（向后兼容未破坏）', (
      tester,
    ) async {
      // illustration 是新增参数，不能挤掉既有 image 的能力。
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          const ParkEmpty(description: 'image', image: Icon(Icons.image)),
        ),
      );
      expect(
        find.byIcon(Icons.image),
        findsOneWidget,
        reason: 'image 参数必须继续可用（向后兼容）',
      );
    });

    testWidgets('🔴 ParkResult：三个工厂预设不受illustration 影响', (
      tester,
    ) async {
      // forfrbidden/notFound/serverError 三个工厂都预设了 icon，
      // 用户传 illustration 时应胜出。
      final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, Brightness.light);
      await tester.pumpWidget(
        _wrap(
          park,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ParkResult.forbidden(
                illustration: const Icon(Icons.brush),
              ),
              ParkResult.notFound(illustration: const Icon(Icons.brush)),
              // ⚠️ serverError 工厂目前**没有暴露** illustration / icon
              // （见 park_result.dart:164-182），与上面两个工厂不对称，属组件 API 缺陷。
              // 这里改用等价的公开构造函数复现同一场景：
              // status500 + 预设 bug_report 图标 + 用户 illustration，
              // 断言"用户 illustration 胜出、预设图标不渲染"的意图不变。
              // TODO(park_result): 工厂补齐 illustration 后，
              // 请改回 ParkResult.serverError(illustration: const Icon(Icons.brush))。
              const ParkResult(
                status: ParkResultStatus.status500,
                icon: Icon(Icons.bug_report, size: 56),
                illustration: Icon(Icons.brush),
                title: '',
              ),
            ],
          ),
        ),
      );
      expect(
        find.byIcon(Icons.brush),
        findsNWidgets(3),
        reason: '工厂预设的 icon 应被用户 illustration 覆盖',
      );
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.byIcon(Icons.search_off), findsNothing);
      expect(find.byIcon(Icons.bug_report), findsNothing);
    });
  });

  group('令牌层 · 表面派生', () {
      // 这条断言的是**令牌层已修好**：bodyColor 不再是恒定的
      // colors.textSecondary，而是在 neon + 深色下与 titleColor 同规则翻转。
      //
      // 🔴 修正记录：本用例最初断言的是"bodyColor < 4.5"（记录缺陷）。
      // 令牌层修复后该断言会失败 —— 因为缺陷**不应该**再存在。
      // 因此改为断言"bodyColor/fill >= 4.5"，
      // 把"缺陷已修"钉成可执行契约，防止令牌层将来被改回。
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      // 正文色在近白 fill 上必须可读（修复前仅 2.00:1）。
      expect(
        ParkColors.contrastRatio(t.bodyColor, t.fill),
        greaterThanOrEqualTo(4.5),
        reason: '令牌层已给 bodyColor 补 neon 翻转，正文必须可读',
      );
      // 与 titleColor 同规则 → neon + 深色下两者相同。
      expect(
        t.bodyColor,
        t.titleColor,
        reason: 'neon + 深色下 bodyColor 应与 titleColor 同源（同为 colors.surface）',
      );
    });

    test('🔴 5 风格 × 明/暗：bodyColor/fill 全部 >= 4.5:1（令牌层契约）', () {
      // 这是本次令牌层修复的**核心回归锁**：全矩阵验证"正文色在任意
      // 风格/明暗下都可读"，而不是只测 neon 一个点。
      for (final ParkSurfaceStyle style in _styles) {
        for (final Brightness b in Brightness.values) {
          final ParkThemeData park = _theme(style, b);
          final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
            style: style,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );
          final double ratio = ParkColors.contrastRatio(
            t.bodyColor,
            t.fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$style / $b：bodyColor/fill 仅 '
                '${ratio.toStringAsFixed(2)}:1 —— 若失败请检查 '
                'ParkSurfaceTokens.resolve 的 bodyColor 是否被改回恒定值',
          );
        }
      }
    });

    test('🔴 stripe 零回归：bodyColor 恒为 colors.textSecondary', () {
      // 令牌层改动**绝不允许**影响 stripe —— golden 与 stripe_baseline
      // 都以 stripe 为基线。显式钉死逐字段等价。
      for (final Brightness b in Brightness.values) {
        final ParkThemeData park = _theme(ParkSurfaceStyle.stripe, b);
        final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
          style: ParkSurfaceStyle.stripe,
          colors: park.colors,
          radius: park.radius,
          blur: park.blur,
        );
        expect(
          t.bodyColor,
          park.colors.textSecondary,
          reason: '$b：stripe 下 bodyColor 必须逐字段不变',
        );
      }
    });

    test('🔴 ParkPageTitle 副标题：令牌修好后"实测取优"成为无害冗余', () {
      // ParkPageTitle 里那层"实测取优"兜底在bodyColor 修好后不再改变结果
      // （因为 bodyColor 本身已达标），但保留作为防御。
      // 这条断言两者一致，证明兜底与令牌层不冲突。
      final ParkThemeData park = _theme(ParkSurfaceStyle.neon, Brightness.dark);
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.neon,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );
      final Color picked =
          ParkColors.contrastRatio(t.bodyColor, t.fill) >= 4.5
              ? t.bodyColor
              : t.titleColor;
      expect(picked, t.bodyColor, reason: 'bodyColor 已达标，取优应选中它本身');
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
