import 'package:flutter/material.dart';

import 'park_theme_data.dart';
import 'tokens/park_blur.dart';
import 'tokens/park_gradient.dart';
import 'tokens/park_gradients.dart';
import 'tokens/park_radius.dart';
import 'tokens/park_shadows.dart';

/// Park UI 主题预设。
///
/// 每个预设只描述"风格 DNA"：表面材质、圆角性格、阴影性格、模糊强度、
/// 渐变偏好与是否倾向深色。真正的品牌主色由 [ParkColors] 提供，
/// 二者正交组合（7 预设 × N 品牌色 × 2 明暗）。
///
/// 设计来源：本枚举下沉自 App 层原有的 `ThemeStyleId`（5 值），
/// 在此基础上**新增 aurora（极光）与 candy（糖果）** 两种风格，
/// 用于兑现"不只有单一呆板主题色"的产品诉求。App 层的
/// `ThemeStylePreset` 保留 id / 中文名 / 描述作为壳，主题构建委托至此，
/// 从而全仓库只有**一套**预设定义。
enum ParkThemePreset {
  /// Stripe 经典：白底淡阴影 + 细边框，干净专业。
  ///
  /// 🔴 这是默认预设，与 [ParkThemeData.light] / [ParkThemeData.dark]
  /// **逐字段严格等价**，由 `test/theme/stripe_baseline_test.dart` 锁定。
  stripe,

  /// 扁平化：无阴影纯色块，高对比扁平。
  flat,

  /// 灵动毛玻璃：半透明 + 背景模糊 + 浅描边。
  glass,

  /// 新拟态：同色面 + 双柔光阴影，似从底面浮起。
  neo,

  /// 赛博霓虹：深色面 + 品牌色辉光描边。
  neon,

  /// 极光渐变（新增）：玻璃材质 + 多色极光背景渐变，模糊最强。
  aurora,

  /// 糖果撞色（新增）：扁平材质 + 高饱和暖色倾向 + 超大圆角 + 无阴影。
  candy;

  /// 该预设对应的表面材质风格。
  ParkSurfaceStyle get surfaceStyle => switch (this) {
    ParkThemePreset.stripe => ParkSurfaceStyle.stripe,
    ParkThemePreset.flat => ParkSurfaceStyle.flat,
    ParkThemePreset.glass => ParkSurfaceStyle.glass,
    ParkThemePreset.neo => ParkSurfaceStyle.neo,
    ParkThemePreset.neon => ParkSurfaceStyle.neon,
    // 极光复用玻璃材质：极光的"通透感"来自模糊 + 多色背景。
    ParkThemePreset.aurora => ParkSurfaceStyle.glass,
    // 糖果复用扁平材质：撞色靠色块本身，不依赖阴影。
    ParkThemePreset.candy => ParkSurfaceStyle.flat,
  };

  /// 该预设的圆角性格（圆角越大越"软"）。
  ParkRadius get radius => switch (this) {
    // 🔴 stripe 必须与 ParkRadius.defaults() 完全一致，不做任何偏移。
    ParkThemePreset.stripe => ParkRadius.defaults(),
    ParkThemePreset.flat =>
      ParkRadius.defaults().copyWith(sm: 10, md: 14, lg: 18, xl: 24),
    ParkThemePreset.glass =>
      ParkRadius.defaults().copyWith(sm: 12, md: 18, lg: 22, xl: 28),
    ParkThemePreset.neo =>
      ParkRadius.defaults().copyWith(sm: 14, md: 20, lg: 26, xl: 32),
    ParkThemePreset.neon =>
      ParkRadius.defaults().copyWith(sm: 10, md: 14, lg: 18, xl: 22),
    ParkThemePreset.aurora =>
      ParkRadius.defaults().copyWith(sm: 14, md: 22, lg: 28, xl: 34),
    ParkThemePreset.candy =>
      ParkRadius.defaults().copyWith(sm: 16, md: 24, lg: 30, xl: 36),
  };

  /// 该预设的阴影性格。
  ParkShadows shadowsFor(Brightness brightness) => switch (this) {
    ParkThemePreset.stripe ||
    ParkThemePreset.glass ||
    ParkThemePreset.aurora => brightness == Brightness.dark
        ? ParkShadows.dark()
        : ParkShadows.defaults(),
    ParkThemePreset.flat ||
    ParkThemePreset.neo ||
    ParkThemePreset.candy => ParkShadows.flat(),
    ParkThemePreset.neon => ParkShadows.neon(),
  };

  /// 该预设的模糊性格。
  ///
  /// stripe / flat / neo / candy 不使用模糊，故与默认值一致。
  ParkBlur get blur => switch (this) {
    ParkThemePreset.glass => const ParkBlur(
      sm: 6.0,
      md: 12.0,
      lg: 24.0,
      xl: 36.0,
    ),
    ParkThemePreset.aurora => const ParkBlur(
      sm: 8.0,
      md: 16.0,
      lg: 32.0,
      xl: 48.0,
    ),
    _ => ParkBlur.defaults(),
  };

  /// 该预设的渐变偏好；null 表示沿用 [ParkGradients.fromColors] 的默认派生。
  ///
  /// 仅 aurora / candy 覆盖，其余预设返回 null 以保证 stripe 零回归。
  ParkGradients? gradientsFor(ParkThemeData base) => switch (this) {
    ParkThemePreset.aurora => base.gradients.copyWith(
      aurora: base.gradients.aurora,
      brand: base.gradients.aurora,
      sweep: base.gradients.aurora.copyWith(type: ParkGradientType.sweep),
    ),
    ParkThemePreset.candy => base.gradients.copyWith(
      brand: ParkGradient.linear(
        colors: <Color>[base.colors.warning, base.colors.error],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: ParkGradient.linear(
        colors: <Color>[base.colors.success, base.colors.warning],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _ => null,
  };

  /// 是否倾向深色底（霓虹与极光在浅色底上无意义）。
  ///
  /// 注意是"倾向"而非"强制"：App 层可在用户显式选择浅色时忽略此倾向，
  /// 这样既不破坏用户预期，也让组件库单独使用时有一个合理默认。
  bool get prefersDark => switch (this) {
    ParkThemePreset.neon || ParkThemePreset.aurora => true,
    _ => false,
  };

  /// 展示名称（中文）。
  String get label => switch (this) {
    ParkThemePreset.stripe => 'Stripe 经典',
    ParkThemePreset.flat => '扁平化',
    ParkThemePreset.glass => '毛玻璃',
    ParkThemePreset.neo => '新拟态',
    ParkThemePreset.neon => '暗夜霓虹',
    ParkThemePreset.aurora => '极光渐变',
    ParkThemePreset.candy => '糖果撞色',
  };

  /// 简短描述。
  String get description => switch (this) {
    ParkThemePreset.stripe => '白底淡阴影 + 细边框，干净专业',
    ParkThemePreset.flat => '无阴影纯色块，高对比扁平',
    ParkThemePreset.glass => '半透明 + 背景模糊 + 浅描边',
    ParkThemePreset.neo => '同色面 + 双柔光阴影，似浮起',
    ParkThemePreset.neon => '深色面 + 品牌色辉光描边',
    ParkThemePreset.aurora => '极光三色渐变 + 最强模糊，梦幻通透',
    ParkThemePreset.candy => '撞色色块 + 超大圆角，活泼明快',
  };

  /// 页面背景装饰（渐变背景）。
  ///
  /// 仅 glass / aurora / neon 返回非 null —— 这三种风格需要渐变背景来让
  /// 玻璃的模糊与霓虹的辉光更出彩；其余风格返回 null，使用普通的
  /// `colors.background` 作为 scaffold 背景。
  ///
  /// 全部颜色来自 [ParkGradients] / [ParkColors]，无硬编码色值。
  BoxDecoration? backgroundDecoration(ParkThemeData base) {
    final ParkGradients g = base.gradients;
    return switch (this) {
      ParkThemePreset.glass => BoxDecoration(gradient: g.accent.asFlutter),
      ParkThemePreset.aurora => BoxDecoration(gradient: g.aurora.asFlutter),
      ParkThemePreset.neon => BoxDecoration(
        gradient: ParkGradient.radial(
          colors: <Color>[
            base.colors.brand.withValues(alpha: 0.28),
            base.colors.background,
          ],
          center: const Alignment(-0.2, -0.6),
          radius: 1.4,
        ).asFlutter,
      ),
      _ => null,
    };
  }

  /// 由预设派生 [ParkThemeData]。
  ///
  /// [brightness] 决定基础色板；[base] 可选，用于在已有主题上叠加预设
  /// （例如保留 App 层选定的品牌色）。
  ParkThemeData build({
    Brightness brightness = Brightness.light,
    ParkThemeData? base,
  }) {
    final ParkThemeData seed =
        base ??
        (brightness == Brightness.dark
            ? ParkThemeData.dark()
            : ParkThemeData.light());

    final ParkThemeData themed = seed.copyWith(
      surfaceStyle: surfaceStyle,
      radius: radius,
      shadows: shadowsFor(brightness),
      blur: blur,
    );

    final ParkGradients? gradients = gradientsFor(themed);
    return gradients == null ? themed : themed.copyWith(gradients: gradients);
  }
}

/// 全部可选预设，按推荐展示顺序排列。默认 [ParkThemePreset.stripe]。
const List<ParkThemePreset> parkThemePresets = <ParkThemePreset>[
  ParkThemePreset.stripe,
  ParkThemePreset.flat,
  ParkThemePreset.glass,
  ParkThemePreset.neo,
  ParkThemePreset.neon,
  ParkThemePreset.aurora,
  ParkThemePreset.candy,
];

/// 按名称查找预设；找不到回退到 [ParkThemePreset.stripe]。
ParkThemePreset findParkThemePreset(String name) {
  return ParkThemePreset.values.firstWhere(
    (ParkThemePreset p) => p.name == name,
    orElse: () => ParkThemePreset.stripe,
  );
}
