import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/tokens/park_sizing.dart';
import 'package:park_ui/src/theme/tokens/park_radius.dart';
import 'package:park_ui/src/theme/tokens/park_spacing.dart';
import 'package:park_ui/src/theme/tokens/park_typography.dart';
import 'package:park_ui/src/theme/tokens/park_colors.dart';
import 'package:park_ui/src/theme/tokens/park_motion.dart';
import 'package:park_ui/src/theme/tokens/park_shadows.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

// =============================================================================
// ParkSizing 测试
// =============================================================================
void main() {
  group('ParkSizing', () {
    test('默认值正确', () {
      final sizing = ParkSizing.defaults();
      expect(sizing.buttonHeightSm, 28.0);
      expect(sizing.buttonHeightMd, 36.0);
      expect(sizing.buttonHeightLg, 44.0);
      expect(sizing.inputHeightSm, 32.0);
      expect(sizing.inputHeightMd, 48.0);
      expect(sizing.inputHeightLg, 56.0);
      expect(sizing.buttonHorizontalPaddingMd, 24.0);
      expect(sizing.buttonVerticalPaddingMd, 8.0);
      expect(sizing.minTouchTarget, 44.0);
    });

    test('defaults() 工厂返回默认值', () {
      final sizing = ParkSizing.defaults();
      const defaultSizing = ParkSizing();
      expect(sizing, equals(defaultSizing));
    });

    test('copyWith 能正确修改字段', () {
      const original = ParkSizing();
      final modified = original.copyWith(
        buttonHeightSm: 30.0,
        inputHeightMd: 50.0,
        minTouchTarget: 48.0,
      );
      expect(modified.buttonHeightSm, 30.0);
      expect(modified.inputHeightMd, 50.0);
      expect(modified.minTouchTarget, 48.0);
      // 未修改的字段保持不变
      expect(modified.buttonHeightMd, 36.0);
      expect(modified.inputHeightLg, 56.0);
    });

    test('== 和 hashCode: 相同值的对象相等', () {
      const a = ParkSizing();
      const b = ParkSizing();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同的对象不相等', () {
      const a = ParkSizing();
      final b = a.copyWith(buttonHeightSm: 30.0);
      expect(a, isNot(equals(b)));
    });

    test('const 构造可用', () {
      const sizing = ParkSizing();
      expect(sizing, isA<ParkSizing>());
    });
  });

// =============================================================================
// ParkRadius 测试
// =============================================================================
  group('ParkRadius', () {
    late ParkRadius radius;

    setUp(() {
      radius = ParkRadius.defaults();
    });

    test('默认值正确', () {
      expect(radius.xs, 4.0);
      expect(radius.sm, 8.0);
      expect(radius.md, 12.0);
      expect(radius.lg, 16.0);
      expect(radius.xl, 20.0);
      expect(radius.full, 9999.0);
    });

    group('componentRadius 组件圆角映射', () {
      test('button → sm(8px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.button),
          radius.sm,
        );
        expect(radius.componentRadius(ParkRadiusComponent.button), 8.0);
      });

      test('input → sm(8px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.input),
          radius.sm,
        );
        expect(radius.componentRadius(ParkRadiusComponent.input), 8.0);
      });

      test('select → sm(8px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.select),
          radius.sm,
        );
        expect(radius.componentRadius(ParkRadiusComponent.select), 8.0);
      });

      test('buttonRound → full(9999px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.buttonRound),
          radius.full,
        );
        expect(
          radius.componentRadius(ParkRadiusComponent.buttonRound),
          9999.0,
        );
      });

      test('card → md(12px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.card),
          radius.md,
        );
        expect(radius.componentRadius(ParkRadiusComponent.card), 12.0);
      });

      test('dialog → lg(16px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.dialog),
          radius.lg,
        );
        expect(radius.componentRadius(ParkRadiusComponent.dialog), 16.0);
      });

      test('tag → xs(4px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.tag),
          radius.xs,
        );
        expect(radius.componentRadius(ParkRadiusComponent.tag), 4.0);
      });

      test('badge → xs(4px)', () {
        expect(
          radius.componentRadius(ParkRadiusComponent.badge),
          radius.xs,
        );
        expect(radius.componentRadius(ParkRadiusComponent.badge), 4.0);
      });
    });

    group('componentBr', () {
      test('返回正确的 BorderRadius', () {
        expect(
          radius.componentBr(ParkRadiusComponent.button),
          BorderRadius.circular(radius.sm),
        );
        expect(
          radius.componentBr(ParkRadiusComponent.buttonRound),
          BorderRadius.circular(radius.full),
        );
      });
    });

    test('== 和 hashCode: 相同值的对象相等', () {
      const a = ParkRadius();
      const b = ParkRadius();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同的对象不相等', () {
      const a = ParkRadius();
      const b = ParkRadius(xs: 8.0);
      expect(a, isNot(equals(b)));
    });
  });

// =============================================================================
// ParkSpacing 测试
// =============================================================================
  group('ParkSpacing', () {
    late ParkSpacing spacing;

    setUp(() {
      spacing = ParkSpacing.defaults();
    });

    test('场景速查 getter 值正确', () {
      expect(spacing.buttonHorizontalPaddingMd, 24.0); // base(16) + sm(8)
      expect(spacing.buttonVerticalPaddingMd, 8.0); // sm
      expect(spacing.inputLabelGap, 8.0); // sm
      expect(spacing.formFieldGap, 24.0); // xl
      expect(spacing.cardPadding, 16.0); // base
      expect(spacing.cardGap, 24.0); // xl
      expect(spacing.sectionGap, 32.0); // xxl
      expect(spacing.dialogPadding, 24.0); // xl
    });

    test('SizedBox getter 可用且值正确', () {
      // 新增的 getter
      expect(spacing.hXxl, isA<SizedBox>());
      expect((spacing.hXxl as SizedBox).width, 32.0);
      expect(spacing.hPage, isA<SizedBox>());
      expect((spacing.hPage as SizedBox).width, 48.0);
      expect(spacing.hXxs, isA<SizedBox>());
      expect((spacing.hXxs as SizedBox).width, 2.0);
      expect(spacing.vXxl, isA<SizedBox>());
      expect((spacing.vXxl as SizedBox).height, 32.0);
      expect(spacing.vPage, isA<SizedBox>());
      expect((spacing.vPage as SizedBox).height, 48.0);
      expect(spacing.vXxs, isA<SizedBox>());
      expect((spacing.vXxs as SizedBox).height, 2.0);

      // 已有的 getter 仍然可用
      expect(spacing.hXs, isA<SizedBox>());
      expect(spacing.hSm, isA<SizedBox>());
      expect(spacing.hBase, isA<SizedBox>());
      expect(spacing.hMd, isA<SizedBox>());
      expect(spacing.hLg, isA<SizedBox>());
      expect(spacing.vXs, isA<SizedBox>());
      expect(spacing.vSm, isA<SizedBox>());
      expect(spacing.vBase, isA<SizedBox>());
      expect(spacing.vMd, isA<SizedBox>());
      expect(spacing.vLg, isA<SizedBox>());
    });

    test('== 和 hashCode: 相同值的对象相等', () {
      const a = ParkSpacing();
      const b = ParkSpacing();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同的对象不相等', () {
      const a = ParkSpacing();
      const b = ParkSpacing(xxs: 4.0);
      expect(a, isNot(equals(b)));
    });
  });

// =============================================================================
// ParkTypography 测试
// =============================================================================
  group('ParkTypography', () {
    test('letterSpacingOverline 默认值 0.5', () {
      const typography = ParkTypography();
      expect(typography.letterSpacingOverline, 0.5);
    });

    test('weightLight 默认值 FontWeight.w300', () {
      const typography = ParkTypography();
      expect(typography.weightLight, FontWeight.w300);
    });

    test('overline getter 使用 letterSpacingOverline', () {
      const typography = ParkTypography();
      final overlineStyle = typography.overline;
      expect(overlineStyle.letterSpacing, typography.letterSpacingOverline);
      expect(overlineStyle.letterSpacing, 0.5);
    });

    test('copyWith 能修改 letterSpacingOverline', () {
      const original = ParkTypography();
      final modified = original.copyWith(letterSpacingOverline: 1.0);
      expect(modified.letterSpacingOverline, 1.0);
      // 未修改字段保持默认
      expect(modified.weightLight, FontWeight.w300);
    });

    test('copyWith 能修改 weightLight', () {
      const original = ParkTypography();
      final modified = original.copyWith(weightLight: FontWeight.w200);
      expect(modified.weightLight, FontWeight.w200);
    });

    test('== 和 hashCode: 相同值的对象相等', () {
      const a = ParkTypography();
      const b = ParkTypography();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同的对象不相等', () {
      const a = ParkTypography();
      final b = a.copyWith(letterSpacingOverline: 1.0);
      expect(a, isNot(equals(b)));
    });
  });

// =============================================================================
// ParkColors 测试
// =============================================================================
  group('ParkColors', () {
    test('contrastRatio: 白色在黑色上 ≈ 21.0', () {
      const white = Color(0xFFFFFFFF);
      const black = Color(0xFF000000);
      final ratio = ParkColors.contrastRatio(white, black);
      expect(ratio, closeTo(21.0, 0.01));
    });

    test('contrastRatio: brand(#635BFF) 在白色上 ≈ 4.7', () {
      const brand = Color(0xFF635BFF);
      const white = Color(0xFFFFFFFF);
      final ratio = ParkColors.contrastRatio(brand, white);
      // 实际 WCAG 2.1 计算结果约为 4.70:1，
      // HANDOFF 文档中标注的 5.4:1 为设计估算值，此处以实际计算为准。
      expect(ratio, closeTo(4.7, 0.1));
    });

    test('textOnColor: 深色背景上返回白色', () {
      final colors = ParkColors.light();
      const black = Color(0xFF000000);
      expect(colors.textOnColor(black), const Color(0xFFFFFFFF));
    });

    test('textOnColor: 浅色背景上返回 textPrimary', () {
      final colors = ParkColors.light();
      const white = Color(0xFFFFFFFF);
      expect(colors.textOnColor(white), const Color(0xFF0A2540));
    });

    test('== 和 hashCode: 相同值相等', () {
      final a = ParkColors.light();
      final b = ParkColors.light();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同值不相等', () {
      final a = ParkColors.light();
      final b = ParkColors.dark();
      expect(a, isNot(equals(b)));
    });
  });

// =============================================================================
// ParkMotion 测试
// =============================================================================
  group('ParkMotion', () {
    test('staggerMs 默认值 50', () {
      const motion = ParkMotion();
      expect(motion.staggerMs, 50);
    });

    test('stagger getter 返回正确 Duration', () {
      const motion = ParkMotion();
      expect(motion.stagger, const Duration(milliseconds: 50));
    });

    test('copyWith 能修改 staggerMs', () {
      const original = ParkMotion();
      final modified = original.copyWith(staggerMs: 100);
      expect(modified.staggerMs, 100);
      expect(modified.stagger, const Duration(milliseconds: 100));
      // 未修改字段保持不变
      expect(modified.standardMs, 250);
    });

    test('== 和 hashCode: 相同值的对象相等', () {
      const a = ParkMotion();
      const b = ParkMotion();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同的对象不相等', () {
      const a = ParkMotion();
      final b = a.copyWith(staggerMs: 100);
      expect(a, isNot(equals(b)));
    });
  });

// =============================================================================
// ParkShadows 测试
// =============================================================================
  group('ParkShadows', () {
    test('== 和 hashCode: 相同值相等', () {
      final a = ParkShadows.defaults();
      final b = ParkShadows.defaults();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== 和 hashCode: 不同值不相等', () {
      final a = ParkShadows.defaults();
      final b = ParkShadows.flat();
      expect(a, isNot(equals(b)));
    });
  });

// =============================================================================
// ParkThemeData 测试
// =============================================================================
  group('ParkThemeData', () {
    test('light() 包含 sizing 且为默认值', () {
      final theme = ParkThemeData.light();
      expect(theme.sizing, isA<ParkSizing>());
      expect(theme.sizing, equals(ParkSizing.defaults()));
    });

    test('dark() 包含 sizing 且为默认值', () {
      final theme = ParkThemeData.dark();
      expect(theme.sizing, isA<ParkSizing>());
      expect(theme.sizing, equals(ParkSizing.defaults()));
    });

    test('copyWith 支持修改 sizing', () {
      final theme = ParkThemeData.light();
      final customSizing = ParkSizing.defaults().copyWith(buttonHeightSm: 32.0);
      final modified = theme.copyWith(sizing: customSizing);
      expect(modified.sizing.buttonHeightSm, 32.0);
    });

    test('lerp 支持 sizing', () {
      final lightTheme = ParkThemeData.light();
      final darkTheme = ParkThemeData.dark();
      // t=0 时返回 light
      final lerped0 = lightTheme.lerp(darkTheme, 0.0);
      expect(lerped0?.sizing, equals(ParkSizing.defaults()));
      // t=1 时返回 dark
      final lerped1 = lightTheme.lerp(darkTheme, 1.0);
      expect(lerped1?.sizing, equals(ParkSizing.defaults()));
    });
  });
}
