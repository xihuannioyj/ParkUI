import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/tokens/park_colors.dart';
import 'package:park_ui/src/theme/tokens/park_shadows.dart';

/// 暗色模式令牌测试（B275 主题维度）
///
/// 覆盖三个方面：
/// 1. dark 变体完整性：所有颜色令牌均存在且为合理的暗色变体；
/// 2. WCAG AA 对比度：dark 文字令牌对 surface 满足 ≥4.5:1；
/// 3. shadows 层数一致性：light / dark 三级阴影层数一致，避免 lerp 跳变。
void main() {
  // ---------------------------------------------------------------------------
  // 1. dark 变体完整性
  // ---------------------------------------------------------------------------
  group('ParkColors.dark 变体完整性', () {
    final dark = ParkColors.dark();
    final light = ParkColors.light();

    test('所有颜色令牌均非空', () {
      expect(dark.brand, isA<Color>());
      expect(dark.brandLight, isA<Color>());
      expect(dark.brandDark, isA<Color>());
      expect(dark.success, isA<Color>());
      expect(dark.successLight, isA<Color>());
      expect(dark.successDark, isA<Color>());
      expect(dark.warning, isA<Color>());
      expect(dark.warningLight, isA<Color>());
      expect(dark.warningDark, isA<Color>());
      expect(dark.error, isA<Color>());
      expect(dark.errorLight, isA<Color>());
      expect(dark.errorDark, isA<Color>());
      expect(dark.info, isA<Color>());
      expect(dark.infoLight, isA<Color>());
      expect(dark.infoDark, isA<Color>());
      expect(dark.textPrimary, isA<Color>());
      expect(dark.textSecondary, isA<Color>());
      expect(dark.textPlaceholder, isA<Color>());
      expect(dark.textDisabled, isA<Color>());
      expect(dark.textOnBrand, isA<Color>());
      expect(dark.border, isA<Color>());
      expect(dark.borderLight, isA<Color>());
      expect(dark.divider, isA<Color>());
      expect(dark.background, isA<Color>());
      expect(dark.surface, isA<Color>());
      expect(dark.overlay, isA<Color>());
      expect(dark.disabledBg, isA<Color>());
    });

    test('brandPalette 提供完整 10 阶色板', () {
      expect(dark.brandPalette.length, 10);
      for (final c in dark.brandPalette) {
        expect(c, isA<Color>());
      }
    });

    test('dark 背景/表面为深色（亮度低于 light）', () {
      expect(dark.surface.computeLuminance(),
          lessThan(light.surface.computeLuminance()));
      expect(dark.background.computeLuminance(),
          lessThan(light.background.computeLuminance()));
    });

    test('dark 主文字为浅色，与 light 形成反转', () {
      expect(dark.textPrimary.computeLuminance(),
          greaterThan(light.textPrimary.computeLuminance()));
    });

    test('dark 与 light 的表面色不同', () {
      expect(dark.surface, isNot(equals(light.surface)));
      expect(dark.background, isNot(equals(light.background)));
    });

    test('light() 默认值保持不变（回归守护）', () {
      // 铁律：不得修改 ParkThemeData.light() 的任何默认值。
      expect(light.textPlaceholder, const Color(0xFF6C7E90));
      expect(light.textDisabled, const Color(0xFF607080));
      expect(light.textSecondary, const Color(0xFF425466));
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.background, const Color(0xFFF6F9FC));
      expect(light.brand, const Color(0xFF635BFF));
    });
  });

  // ---------------------------------------------------------------------------
  // 2. WCAG AA 对比度（dark 文字令牌 vs surface）
  // ---------------------------------------------------------------------------
  group('ParkColors.dark WCAG AA 对比度', () {
    final dark = ParkColors.dark();
    final surface = dark.surface;

    test('textPrimary 对 surface ≥ 4.5:1', () {
      expect(ParkColors.contrastRatio(dark.textPrimary, surface),
          greaterThanOrEqualTo(4.5));
    });

    test('textSecondary 对 surface ≥ 4.5:1', () {
      expect(ParkColors.contrastRatio(dark.textSecondary, surface),
          greaterThanOrEqualTo(4.5));
    });

    test('textPlaceholder 对 surface ≥ 4.5:1', () {
      expect(ParkColors.contrastRatio(dark.textPlaceholder, surface),
          greaterThanOrEqualTo(4.5));
    });

    test('textDisabled 对 surface ≥ 4.5:1', () {
      expect(ParkColors.contrastRatio(dark.textDisabled, surface),
          greaterThanOrEqualTo(4.5));
    });

    test('文字令牌对 background 同样 ≥ 4.5:1', () {
      final bg = dark.background;
      expect(ParkColors.contrastRatio(dark.textSecondary, bg),
          greaterThanOrEqualTo(4.5));
      expect(ParkColors.contrastRatio(dark.textPlaceholder, bg),
          greaterThanOrEqualTo(4.5));
      expect(ParkColors.contrastRatio(dark.textDisabled, bg),
          greaterThanOrEqualTo(4.5));
    });
  });

  // ---------------------------------------------------------------------------
  // 3. shadows 层数一致性（light / dark）
  // ---------------------------------------------------------------------------
  group('ParkShadows light/dark 层数一致性', () {
    final light = ParkShadows.defaults();
    final dark = ParkShadows.dark();

    test('sm 层数一致（修复历史 light 2 层 vs dark 1 层跳变）', () {
      expect(light.sm.length, greaterThan(0));
      expect(dark.sm.length, equals(light.sm.length));
    });

    test('md 层数一致', () {
      expect(light.md.length, greaterThan(0));
      expect(dark.md.length, equals(light.md.length));
    });

    test('lg 层数一致', () {
      expect(light.lg.length, greaterThan(0));
      expect(dark.lg.length, equals(light.lg.length));
    });

    test('lerp 在 t=0.5 平滑插值（层数一致时不整体跳变）', () {
      final mid = ParkShadows.lerp(light, dark, 0.5);
      // 层数一致时应逐层插值，长度保持不变。
      expect(mid.sm.length, equals(light.sm.length));
      expect(mid.md.length, equals(light.md.length));
      expect(mid.lg.length, equals(light.lg.length));
      // 插值结果应介于两端之间（blurRadius 取中点）。
      for (int i = 0; i < light.sm.length; i++) {
        final expected = (light.sm[i].blurRadius + dark.sm[i].blurRadius) / 2;
        expect(mid.sm[i].blurRadius, closeTo(expected, 0.001));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 4. 主题级 dark 集成
  // ---------------------------------------------------------------------------
  group('ParkThemeData.dark 集成', () {
    test('dark() 携带 dark 颜色与 dark 阴影', () {
      final theme = ParkThemeData.dark();
      expect(theme.colors, equals(ParkColors.dark()));
      expect(theme.shadows, equals(ParkShadows.dark()));
    });

    test('light→dark lerp 在 t=0.5 时阴影层数稳定', () {
      final a = ParkThemeData.light();
      final b = ParkThemeData.dark();
      final mid = a.lerp(b, 0.5);
      expect(mid.shadows.sm.length, equals(a.shadows.sm.length));
      expect(mid.shadows.md.length, equals(a.shadows.md.length));
      expect(mid.shadows.lg.length, equals(a.shadows.lg.length));
    });
  });
}
