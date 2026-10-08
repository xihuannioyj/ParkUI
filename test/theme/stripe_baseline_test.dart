/// Stripe 基线快照测试 —— 批次 1 的**硬前置**。
///
/// ## 为什么必须先写这个测试
///
/// 引入"表面令牌派生层"（`ParkSurfaceTokens`）有极高的回归风险：
/// 它会成为全项目唯一的材质翻译点，一旦 stripe 分支的数值与迁移前
/// `ParkCard._resolveSurface` 有任何偏差，**所有 200+ 组件的外观都会变**，
/// 而用户默认看到的正是 stripe —— 破坏它等于破坏产品第一印象。
///
/// 因此本文件在**改动派生逻辑之前**就已建立，把"当前 stripe 观感"钉死为
/// 逐字段字面量断言。注意断言用的是**硬编码字面量**而不是"两个实现相等"，
/// 因为后者会在两边同时漂移时静默通过。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import '../golden/golden_test_helper.dart';

/// 迁移前 `ParkCard._resolveSurface` 的 stripe 分支原始输出（浅色）。
///
/// 这些字面量直接抄自**删除前**的源码，是"基线"的唯一事实来源。
/// 任何一项变化都意味着 stripe 观感被破坏。
const Color _kStripeLightFill = Color(0xFFFFFFFF); // colors.surface
const Color _kStripeLightBorder = Color(0xFFE3E8EE); // colors.border
const Color _kStripeLightTitle = Color(0xFF0A2540); // colors.textPrimary
const Color _kStripeLightBody = Color(0xFF425466); // colors.textSecondary

void main() {
  group('Stripe 基线 · 派生层与迁移前逐字段相等', () {
    test('stripe + light：填充/边框/圆角与迁移前完全一致', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(t.style, ParkSurfaceStyle.stripe);
      expect(t.fill, _kStripeLightFill);
      expect(t.border, isNull, reason: 'bordered 默认 true，但需显式传入才画边框');
      expect(t.shadows, isNull, reason: 'elevation=0 且未 hover 时无阴影');
      expect(t.radius, park.radius.brMd);
      expect(t.titleColor, _kStripeLightTitle);
      expect(t.bodyColor, _kStripeLightBody);
      expect(t.glassBlur, 0.0);
      expect(t.glassAlpha, 1.0);
      expect(t.useBackdropFilter, isFalse);
      expect(t.isDark, isFalse);
    });

    test('stripe + dark：深色色板下派生结果同样稳定', () {
      final ParkThemeData park = ParkThemeData.dark();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
      );

      expect(t.fill, park.colors.surface);
      expect(t.isDark, isTrue);
      expect(t.titleColor, park.colors.textPrimary);
      expect(t.bodyColor, park.colors.textSecondary);
      expect(t.shadows, isNull);
      expect(t.useBackdropFilter, isFalse);
    });

    test('stripe + bordered + outlined：边框为 colors.border 1px', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
        borderTone: ParkSurfaceBorderTone.outline,
      );

      expect(t.border, Border.all(color: _kStripeLightBorder, width: 1));
    });

    test('stripe + outlined + hover：边框高亮为 brand @30%', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
        borderTone: ParkSurfaceBorderTone.outline,
        hovered: true,
      );

      expect(
        t.border,
        Border.all(
          color: park.colors.brand.withValues(alpha: 0.3),
          width: 1,
        ),
      );
    });

    test('stripe + inner：边框为 disabledBg 1px（与迁移前一致）', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
        borderTone: ParkSurfaceBorderTone.inner,
      );

      expect(
        t.border,
        Border.all(color: park.colors.disabledBg, width: 1),
      );
    });

    test('stripe + preview：无边框', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
        borderTone: ParkSurfaceBorderTone.none,
      );

      expect(t.border, isNull);
    });

    test('stripe + bordered=false：无边框（与迁移前 !widget.bordered 一致）', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: false,
        borderTone: ParkSurfaceBorderTone.outline,
      );

      expect(t.border, isNull);
    });

    test('stripe + ghost(transparent)：填充透明且无阴影', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        transparent: true,
        elevation: 4,
      );

      expect(t.fill, Colors.transparent);
      expect(t.shadows, isNull, reason: 'ghost 态不绘制阴影');
    });

    test('stripe + elevation：阴影为 textPrimary@8%，blur=e*4，offset=(0,e*2)', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        elevation: 3,
      );

      expect(t.shadows, <BoxShadow>[
        BoxShadow(
          color: _kStripeLightTitle.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ]);
    });

    test('stripe + elevation + hover：阴影高度额外 +2（与迁移前一致）', () {
      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens t = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        elevation: 3,
        hovered: true,
      );

      // baseElevation 3 + hover 2 = 5 → blur 20, offset (0,10)
      expect(t.shadows, <BoxShadow>[
        BoxShadow(
          color: _kStripeLightTitle.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ]);
    });
  });

  group('Stripe 基线 · preset(stripe) 与 light()/dark() 逐字段相等', () {
    test('preset(stripe, light) == light()，且 hashCode 相同', () {
      final ParkThemeData a = ParkThemeData.light();
      final ParkThemeData b = ParkThemeData.preset(
        ParkThemePreset.stripe,
        brightness: Brightness.light,
      );

      expect(b, equals(a));
      expect(b.hashCode, equals(a.hashCode));
    });

    test('preset(stripe, dark) == dark()，且 hashCode 相同', () {
      final ParkThemeData a = ParkThemeData.dark();
      final ParkThemeData b = ParkThemeData.preset(
        ParkThemePreset.stripe,
        brightness: Brightness.dark,
      );

      expect(b, equals(a));
      expect(b.hashCode, equals(a.hashCode));
    });

    test('preset(stripe) 逐个令牌字段与 light() 严格相等', () {
      final ParkThemeData a = ParkThemeData.light();
      final ParkThemeData b = ParkThemeData.preset(ParkThemePreset.stripe);

      expect(b.colors, equals(a.colors));
      expect(b.typography, equals(a.typography));
      expect(b.spacing, equals(a.spacing));
      expect(b.radius, equals(a.radius));
      expect(b.shadows, equals(a.shadows));
      expect(b.gradients, equals(a.gradients));
      expect(b.surfaceStyle, equals(a.surfaceStyle));
      expect(b.iconTheme, equals(a.iconTheme));
      expect(b.motion, equals(a.motion));
      expect(b.sizing, equals(a.sizing));
      expect(b.elevation, equals(a.elevation));
      expect(b.blur, equals(a.blur));
    });

    test('light().copyWith(surfaceStyle: stripe) 与自身恒等', () {
      final ParkThemeData a = ParkThemeData.light();
      expect(a.copyWith(surfaceStyle: ParkSurfaceStyle.stripe), equals(a));
    });

    test('light() 默认 surfaceStyle 就是 stripe（默认值未被改动）', () {
      expect(
        ParkThemeData.light().surfaceStyle,
        equals(ParkSurfaceStyle.stripe),
      );
      expect(ParkThemeData.dark().surfaceStyle, equals(ParkSurfaceStyle.stripe));
    });

    test('copyWith 不传 gradients 时保持原有派生结果（不破坏既有调用方）', () {
      final ParkThemeData a = ParkThemeData.light();
      final ParkThemeData b = a.copyWith(surfaceStyle: ParkSurfaceStyle.glass);

      // 未显式传 gradients 时由 colors 派生，故 glass 只改风格不改渐变。
      expect(b.gradients, equals(a.gradients));
      expect(b.surfaceStyle, equals(ParkSurfaceStyle.glass));
    });
  });

  group('Stripe 基线 · ParkCard 实际渲染零回归', () {
    testWidgets('ParkCard 默认主题下填充色等于 stripe 派生令牌', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        goldenWrapColumn(<Widget>[
          const ParkCard(
            titleText: 'Outlined Card',
            variant: ParkCardVariant.outlined,
            child: Text('Card content'),
          ),
        ]),
      );

      final ParkThemeData park = ParkThemeData.light();
      final ParkSurfaceTokens expected = ParkSurfaceTokens.resolve(
        style: ParkSurfaceStyle.stripe,
        colors: park.colors,
        radius: park.radius,
        blur: park.blur,
        bordered: true,
        borderTone: ParkSurfaceBorderTone.outline,
      );

      // 卡片最外层装饰盒的填充色必须与派生层一致 —— 证明 ParkCard 确实
      // 在消费 ParkSurfaceTokens，而不是残留着自己的 switch 分支。
      final AnimatedContainer container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final BoxDecoration decoration =
          container.decoration as BoxDecoration;

      expect(decoration.color, equals(expected.fill));
      expect(decoration.border, equals(expected.border));
      expect(decoration.boxShadow, equals(expected.shadows));
    });

    testWidgets('ParkCard 在 glass 主题下确实切换为玻璃材质', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        goldenWrapColumn(
          <Widget>[
            const ParkCard(
              titleText: 'Glass Card',
              variant: ParkCardVariant.outlined,
              child: Text('Card content'),
            ),
          ],
          theme: ParkThemeData.light().copyWith(
            surfaceStyle: ParkSurfaceStyle.glass,
          ),
        ),
      );

      // glass 风格必须出现 BackdropFilter（迁移前由 useGlass 分支产生）。
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('ParkCard 在 stripe 主题下不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        goldenWrapColumn(<Widget>[
          const ParkCard(
            titleText: 'Stripe Card',
            variant: ParkCardVariant.outlined,
            child: Text('Card content'),
          ),
        ]),
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
