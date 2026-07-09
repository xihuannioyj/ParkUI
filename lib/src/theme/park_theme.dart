import 'package:flutter/material.dart';
import 'park_theme_data.dart';
import 'tokens/park_colors.dart';
import 'tokens/park_typography.dart';
import 'tokens/park_spacing.dart';
import 'tokens/park_radius.dart';
import 'tokens/park_shadows.dart';

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
/// ```
class ParkTheme {
  ParkTheme._();

  /// 从 context 获取 ParkThemeData，未注入时返回 light 默认值
  static ParkThemeData of(BuildContext context) {
    return Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
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
}

/// BuildContext 扩展：便捷访问 Park 主题
extension ParkThemeContextExtension on BuildContext {
  /// 获取 ParkThemeData
  ParkThemeData get parkTheme => ParkTheme.of(this);

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
}
