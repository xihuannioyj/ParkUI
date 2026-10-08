import 'package:flutter/material.dart';
import 'tokens/park_colors.dart';
import 'tokens/park_typography.dart';
import 'tokens/park_spacing.dart';
import 'tokens/park_radius.dart';
import 'tokens/park_shadows.dart';
import 'tokens/park_motion.dart';
import 'tokens/park_sizing.dart';
import 'tokens/park_elevation.dart';
import 'tokens/park_blur.dart';
import 'tokens/park_gradients.dart';
import 'park_icon_theme_data.dart';
import 'park_theme_preset.dart';

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

  /// 图标主题。
  final ParkIconThemeData iconTheme;

  /// 动画令牌。
  final ParkMotion motion;

  /// 尺寸令牌。
  final ParkSizing sizing;

  /// 海拔令牌。
  final ParkElevation elevation;

  /// 模糊令牌。
  final ParkBlur blur;

  /// 渐变令牌组。
  ///
  /// 与 [colors] 平级：渐变不是"风格派生物"，而是独立令牌组，
  /// 预设（aurora / candy）可以覆盖它，因此**需要**进 [ParkThemeData]
  /// 并参与 `copyWith` / `lerp` / `==` / `hashCode`
  /// （漏改 `==` 会导致主题切换时误判"没变"而不重建）。
  ///
  /// 注意这与"表面令牌不进主题"并不矛盾：[ParkSurfaceTokens] 是
  /// `surfaceStyle` 的派生物（会随风格整体跳变，不适合插值），
  /// 而 [ParkGradients] 与 [surfaceStyle] 正交、生命周期同 [colors]。
  ///
  /// 留空时由 [colors] 自动派生（见 [resolvedGradients]），因此既有调用方
  /// （如 App 层的 `ThemeStylePreset.buildParkTheme`）无需改动。
  final ParkGradients? _gradients;

  /// 实际生效的渐变令牌组。
  ///
  /// 未显式指定时从 [colors] 派生，保证品牌色变化时渐变自动跟随，
  /// 且不需要每个构造点都记得传这一项。
  ParkGradients get gradients => _gradients ?? ParkGradients.fromColors(colors);

  const ParkThemeData({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radius,
    required this.shadows,
    ParkGradients? gradients,
    this.surfaceStyle = ParkSurfaceStyle.stripe,
    this.iconTheme = const ParkIconThemeData(),
    this.motion = const ParkMotion(),
    this.sizing = const ParkSizing(),
    this.elevation = const ParkElevation(),
    this.blur = const ParkBlur(),
  }) : _gradients = gradients;

  /// 亮色主题
  factory ParkThemeData.light() {
    return ParkThemeData(
      colors: ParkColors.light(),
      typography: ParkTypography.defaults(),
      spacing: ParkSpacing.defaults(),
      radius: ParkRadius.defaults(),
      shadows: ParkShadows.defaults(),
      iconTheme: const ParkIconThemeData(),
      motion: const ParkMotion(),
      sizing: ParkSizing.defaults(),
      elevation: ParkElevation.defaults(),
      blur: ParkBlur.defaults(),
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
      iconTheme: const ParkIconThemeData(),
      motion: const ParkMotion(),
      sizing: ParkSizing.defaults(),
      elevation: ParkElevation.defaults(),
      blur: ParkBlur.defaults(),
    );
  }

  /// 由预设派生主题。
  ///
  /// ```dart
  /// // 一行切主题
  /// MaterialApp(
  ///   theme: ThemeData(
  ///     extensions: <ThemeExtension<ParkThemeData>>[
  ///       ParkThemeData.preset(ParkThemePreset.aurora),
  ///     ],
  ///   ),
  /// )
  /// ```
  ///
  /// 🔴 [ParkThemePreset.stripe] 的输出与 [ParkThemeData.light] /
  /// [ParkThemeData.dark] **逐字段严格相等**（由
  /// `test/theme/stripe_baseline_test.dart` 锁定），因此 stripe 观感零回归。
  ///
  /// 传入 [base] 可在已有主题上叠加预设（例如保留 App 层选定的品牌色）。
  factory ParkThemeData.preset(
    ParkThemePreset preset, {
    Brightness brightness = Brightness.light,
    ParkThemeData? base,
  }) {
    return preset.build(brightness: brightness, base: base);
  }

  @override
  ParkThemeData copyWith({
    ParkColors? colors,
    ParkTypography? typography,
    ParkSpacing? spacing,
    ParkRadius? radius,
    ParkShadows? shadows,
    ParkGradients? gradients,
    ParkSurfaceStyle? surfaceStyle,
    ParkIconThemeData? iconTheme,
    ParkMotion? motion,
    ParkSizing? sizing,
    ParkElevation? elevation,
    ParkBlur? blur,
  }) {
    return ParkThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      gradients: gradients ?? _gradients,
      surfaceStyle: surfaceStyle ?? this.surfaceStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      motion: motion ?? this.motion,
      sizing: sizing ?? this.sizing,
      elevation: elevation ?? this.elevation,
      blur: blur ?? this.blur,
    );
  }

  @override
  ParkThemeData lerp(ThemeExtension<ParkThemeData>? other, double t) {
    if (other is! ParkThemeData) return this;

    return ParkThemeData(
      colors: _lerpColors(colors, other.colors, t),
      typography: ParkTypography.lerp(typography, other.typography, t),
      spacing: ParkSpacing.lerp(spacing, other.spacing, t),
      radius: _lerpRadius(radius, other.radius, t),
      shadows: ParkShadows.lerp(shadows, other.shadows, t),
      // Gradients ARE interpolable (unlike surface tokens): each color stop is
      // Color.lerp-ed and stops are interpolated by ParkGradient.lerp. So they
      // belong in the theme and take part in the transition animation.
      gradients: ParkGradients.lerp(gradients, other.gradients, t),
      // surfaceStyle is a discrete enum (ParkSurfaceStyle) and cannot be
      // smoothly interpolated. It switches at the midpoint (t < 0.5 → a, else b).
      //
      // This hard jump is INTENTIONAL and safe, because the surface material
      // is NOT baked into this theme: `ParkSurfaceTokens` is derived on read
      // via `ParkSurfaceTokens.resolve(park.surfaceStyle, ...)`. So when the
      // enum flips at t = 0.5, the whole derived surface flips with it —
      // there is never a "glass colors + stripe enum" torn intermediate state.
      // A jump is strictly better than a tear here.
      surfaceStyle: t < 0.5 ? surfaceStyle : other.surfaceStyle,
      iconTheme: ParkIconThemeData.lerp(iconTheme, other.iconTheme, t),
      motion: ParkMotion.lerp(motion, other.motion, t),
      sizing: ParkSizing.lerp(sizing, other.sizing, t),
      elevation: ParkElevation.lerp(elevation, other.elevation, t),
      blur: ParkBlur.lerp(blur, other.blur, t),
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
      successDark: Color.lerp(a.successDark, b.successDark, t)!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      warningLight: Color.lerp(a.warningLight, b.warningLight, t)!,
      warningDark: Color.lerp(a.warningDark, b.warningDark, t)!,
      error: Color.lerp(a.error, b.error, t)!,
      errorLight: Color.lerp(a.errorLight, b.errorLight, t)!,
      errorDark: Color.lerp(a.errorDark, b.errorDark, t)!,
      info: Color.lerp(a.info, b.info, t)!,
      infoLight: Color.lerp(a.infoLight, b.infoLight, t)!,
      infoDark: Color.lerp(a.infoDark, b.infoDark, t)!,
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
      // These two were previously MISSING here, which meant a lerped theme
      // silently reset them to the const defaults instead of interpolating —
      // so the inverse-surface pill (Toast, etc.) jumped during theme
      // transitions. Fixed here together with ParkColors.copyWith/==/hashCode.
      inverseSurface: Color.lerp(a.inverseSurface, b.inverseSurface, t)!,
      onInverseSurface: Color.lerp(a.onInverseSurface, b.onInverseSurface, t)!,
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
      full: a.full + (b.full - a.full) * t,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkThemeData &&
        other.colors == colors &&
        other.spacing == spacing &&
        other.radius == radius &&
        other.typography == typography &&
        other.shadows == shadows &&
        other.gradients == gradients &&
        other.surfaceStyle == surfaceStyle &&
        other.iconTheme == iconTheme &&
        other.motion == motion &&
        other.sizing == sizing &&
        other.elevation == elevation &&
        other.blur == blur;
  }

  @override
  int get hashCode => Object.hash(
        colors,
        spacing,
        radius,
        typography,
        shadows,
        gradients,
        surfaceStyle,
        iconTheme,
        motion,
        sizing,
        elevation,
        blur,
      );
}
