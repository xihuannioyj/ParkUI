import 'package:flutter/material.dart';
import 'tokens/park_colors.dart';
import 'tokens/park_typography.dart';
import 'tokens/park_spacing.dart';
import 'tokens/park_radius.dart';
import 'tokens/park_shadows.dart';

/// 表面风格：决定卡片/容器等表面材质如何渲染（阴影、边框、玻璃、霓虹等）。
///
/// 该枚举由 [ParkThemeData.surfaceStyle] 携带，组件据此切换渲染策略，
/// 使得同一套组件库可以呈现完全不同的视觉语言。
enum ParkSurfaceStyle {
  /// Stripe 经典：白底面 + 淡阴影 + 细边框，干净专业。
  stripe,

  /// 扁平化：无阴影、纯色块、几乎无边框，强调色块与留白。
  flat,

  /// 毛玻璃：半透明 + 背景模糊 + 浅描边，柔和通透。
  glass,

  /// 新拟态：与背景同色 + 双柔光阴影 + 无边框，似从底面浮起。
  neo,

  /// 暗夜霓虹：深色面 + 品牌色辉光 + 发光描边，科技感。
  neon,
}

/// Park UI 主题数据容器
///
/// 将所有设计令牌打包为一个 [ThemeExtension]，通过 Flutter 的
/// [ThemeData.extensions] 机制注入到 widget tree 中。
///
/// 用法：
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [ParkThemeData.light()],
///   ),
/// )
/// ```
///
/// 控件内消费：
/// ```dart
/// final park = Theme.of(context).extension<ParkThemeData>();
/// final color = park?.colors.brand ?? const Color(0xFF1677FF);
/// ```
@immutable
class ParkThemeData extends ThemeExtension<ParkThemeData> {
  /// 色彩令牌
  final ParkColors colors;

  /// 字体令牌
  final ParkTypography typography;

  /// 间距令牌
  final ParkSpacing spacing;

  /// 圆角令牌
  final ParkRadius radius;

  /// 阴影令牌
  final ParkShadows shadows;

  /// 表面风格（决定卡片/容器材质渲染策略：stripe / flat / glass / neo / neon）。
  final ParkSurfaceStyle surfaceStyle;

  const ParkThemeData({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radius,
    required this.shadows,
    this.surfaceStyle = ParkSurfaceStyle.stripe,
  });

  /// 亮色主题
  factory ParkThemeData.light() {
    return ParkThemeData(
      colors: ParkColors.light(),
      typography: ParkTypography.defaults(),
      spacing: ParkSpacing.defaults(),
      radius: ParkRadius.defaults(),
      shadows: ParkShadows.defaults(),
    );
  }

  /// 暗色主题
  factory ParkThemeData.dark() {
    return ParkThemeData(
      colors: ParkColors.dark(),
      typography: ParkTypography.defaults(),
      spacing: ParkSpacing.defaults(),
      radius: ParkRadius.defaults(),
      shadows: ParkShadows.dark(),
    );
  }

  @override
  ParkThemeData copyWith({
    ParkColors? colors,
    ParkTypography? typography,
    ParkSpacing? spacing,
    ParkRadius? radius,
    ParkShadows? shadows,
    ParkSurfaceStyle? surfaceStyle,
  }) {
    return ParkThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      surfaceStyle: surfaceStyle ?? this.surfaceStyle,
    );
  }

  @override
  ParkThemeData lerp(ThemeExtension<ParkThemeData>? other, double t) {
    if (other is! ParkThemeData) return this;

    // 对于 Color 做线性插值，其他令牌类型直接切换
    return ParkThemeData(
      colors: _lerpColors(colors, other.colors, t),
      typography: t < 0.5 ? typography : other.typography,
      spacing: t < 0.5 ? spacing : other.spacing,
      radius: _lerpRadius(radius, other.radius, t),
      shadows: t < 0.5 ? shadows : other.shadows,
      surfaceStyle: t < 0.5 ? surfaceStyle : other.surfaceStyle,
    );
  }

  static ParkColors _lerpColors(ParkColors a, ParkColors b, double t) {
    return ParkColors(
      brand: Color.lerp(a.brand, b.brand, t)!,
      brandLight: Color.lerp(a.brandLight, b.brandLight, t)!,
      brandDark: Color.lerp(a.brandDark, b.brandDark, t)!,
      brandPalette: List.generate(
        10,
        (i) => Color.lerp(a.brandPalette[i], b.brandPalette[i], t)!,
      ),
      success: Color.lerp(a.success, b.success, t)!,
      successLight: Color.lerp(a.successLight, b.successLight, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      warningLight: Color.lerp(a.warningLight, b.warningLight, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      errorLight: Color.lerp(a.errorLight, b.errorLight, t)!,
      info: Color.lerp(a.info, b.info, t)!,
      infoLight: Color.lerp(a.infoLight, b.infoLight, t)!,
      textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
      textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
      textPlaceholder: Color.lerp(a.textPlaceholder, b.textPlaceholder, t)!,
      textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
      textOnBrand: Color.lerp(a.textOnBrand, b.textOnBrand, t)!,
      border: Color.lerp(a.border, b.border, t)!,
      borderLight: Color.lerp(a.borderLight, b.borderLight, t)!,
      divider: Color.lerp(a.divider, b.divider, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      disabledBg: Color.lerp(a.disabledBg, b.disabledBg, t)!,
    );
  }

  static ParkRadius _lerpRadius(ParkRadius a, ParkRadius b, double t) {
    return ParkRadius(
      xs: a.xs + (b.xs - a.xs) * t,
      sm: a.sm + (b.sm - a.sm) * t,
      md: a.md + (b.md - a.md) * t,
      lg: a.lg + (b.lg - a.lg) * t,
      xl: a.xl + (b.xl - a.xl) * t,
      full: 9999.0,
    );
  }
}
