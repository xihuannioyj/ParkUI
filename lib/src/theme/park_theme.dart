import 'package:flutter/material.dart';
import 'park_config_provider.dart';
import 'park_theme_data.dart';
import 'tokens/park_colors.dart';
import 'tokens/park_typography.dart';
import 'tokens/park_spacing.dart';
import 'tokens/park_radius.dart';
import 'tokens/park_shadows.dart';
import 'tokens/park_elevation.dart';
import 'tokens/park_blur.dart';

/// Park UI 主题快捷访问工具
///
/// 提供静态方法从 [BuildContext] 中提取 Park 设计令牌。
/// 所有方法都有 fallback 默认值，即使未注入 [ParkThemeData] 也能正常工作。
///
/// 用法：
/// ```dart
/// // 方式一：通过 ParkTheme 静态方法
/// final color = ParkTheme.colorsOf(context).brand;
/// final radius = ParkTheme.radiusOf(context).sm;
///
/// // 方式二：通过 context 扩展（需要 import park_ui.dart）
/// final park = context.parkTheme;
///
/// // 方式三：快捷主题常量
/// MaterialApp(
///   theme: parkThemeDataLight,  // 浅色
///   darkTheme: parkThemeDataDark,  // 深色
/// )
/// /// 
class ParkTheme {
  ParkTheme._();

  /// 从 context 获取 ParkThemeData。
  ///
  /// 优先通过 [ParkConfigProvider] 获取（单一数据源）。
  /// 若 [ParkConfigProvider] 不在 widget tree 中，回退到
  /// [ThemeData.extensions] 路径；若仍未找到，在 debug 模式下触发 assert
  /// 并返回 light 默认值。
  static ParkThemeData of(BuildContext context) {
    // 1. 优先从 ParkConfigProvider 获取（单一数据源）
    final provider = ParkConfigProvider.maybeOf(context);
    if (provider != null) return provider;

    // 2. 回退：从 ThemeData.extensions 获取
    final ext = Theme.of(context).extension<ParkThemeData>();
    assert(
      ext != null,
      'ParkThemeData not found. Wrap your app with ParkConfigProvider '
      'or add ParkThemeData to ThemeData.extensions.',
    );
    return ext ?? ParkThemeData.light();
  }

  /// 获取色彩令牌
  static ParkColors colorsOf(BuildContext context) {
    return of(context).colors;
  }

  /// 获取字体令牌
  static ParkTypography typographyOf(BuildContext context) {
    return of(context).typography;
  }

  /// 获取间距令牌
  static ParkSpacing spacingOf(BuildContext context) {
    return of(context).spacing;
  }

  /// 获取圆角令牌
  static ParkRadius radiusOf(BuildContext context) {
    return of(context).radius;
  }

  /// 获取阴影令牌
  static ParkShadows shadowsOf(BuildContext context) {
    return of(context).shadows;
  }

  /// 获取海拔令牌
  static ParkElevation elevationOf(BuildContext context) {
    return of(context).elevation;
  }

  /// 获取模糊令牌
  static ParkBlur blurOf(BuildContext context) {
    return of(context).blur;
  }
}

/// BuildContext 扩展：便捷访问 Park 主题令牌
///
/// parkTheme 的便捷访问由 [ParkConfigProviderContextExtension] 提供
/// （单一数据源），此扩展仅保留各令牌子类的快捷方法。
extension ParkThemeContextExtension on BuildContext {
  /// 获取色彩令牌
  ParkColors get parkColors => ParkTheme.colorsOf(this);

  /// 获取字体令牌
  ParkTypography get parkTypography => ParkTheme.typographyOf(this);

  /// 获取间距令牌
  ParkSpacing get parkSpacing => ParkTheme.spacingOf(this);

  /// 获取圆角令牌
  ParkRadius get parkRadius => ParkTheme.radiusOf(this);

  /// 获取阴影令牌
  ParkShadows get parkShadows => ParkTheme.shadowsOf(this);

  /// 获取海拔令牌
  ParkElevation get parkElevation => ParkTheme.elevationOf(this);

  /// 获取模糊令牌
  ParkBlur get parkBlur => ParkTheme.blurOf(this);
}

/// 快捷主题常量：浅色。
final ThemeData parkThemeDataLight = ThemeData(
  useMaterial3: true,
  extensions: <ThemeExtension<ParkThemeData>>[ParkThemeData.light()],
);

/// 快捷主题常量：深色。
final ThemeData parkThemeDataDark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  extensions: <ThemeExtension<ParkThemeData>>[ParkThemeData.dark()],
);
