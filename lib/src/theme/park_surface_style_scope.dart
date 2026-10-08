import 'package:flutter/material.dart';

import 'park_surface_tokens.dart';
import 'park_theme_data.dart';

/// 局部表面风格覆盖层。
///
/// 全局风格由 [ParkThemeData.surfaceStyle] 给出，但真实需求里必然存在
/// "这一张卡片要玻璃、整页是 stripe"的情况。本 [InheritedWidget] 让子树可以
/// 局部覆盖风格，无需把 `surfaceStyle` 一路透传到每个组件。
///
/// 材质解析优先级（高 → 低）：
/// 1. 组件私有参数；
/// 2. [ParkSurfaceStyleScope.tokenOverride] / [ParkSurfaceStyleScope.style]；
/// 3. [ParkThemeData.surfaceStyle]（全局）；
/// 4. [ParkSurfaceStyle.stripe]（兜底，与现状一致）。
///
/// 用法：
/// ```dart
/// ParkSurfaceStyleScope(
///   style: ParkSurfaceStyle.glass,
///   child: ParkCard(child: Text('这一块是玻璃')),
/// )
/// ```
class ParkSurfaceStyleScope extends InheritedWidget {
  /// 覆盖子树的表面风格；null 表示不覆盖（沿用全局）。
  final ParkSurfaceStyle? style;

  /// 直接覆盖表面令牌（优先级高于 [style]），用于需要精确控制的场景。
  final ParkSurfaceTokens? tokenOverride;

  /// 创建局部表面风格覆盖层。
  const ParkSurfaceStyleScope({
    super.key,
    this.style,
    this.tokenOverride,
    required super.child,
  });

  /// 当前作用域声明的风格；无作用域时返回 null。
  ///
  /// 用 [maybeOf] 而非 `of` 是为了让调用方区分"未覆盖"与"覆盖为 stripe"。
  static ParkSurfaceStyle? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ParkSurfaceStyleScope>()
        ?.style;
  }

  /// 当前作用域所属的 [ParkThemeData]；主题缺失时返回 null。
  ///
  /// 用 [Theme.of] 的 `extension` 而非 [ParkTheme.of]，以便调用方自行决定
  /// 缺失时的兜底策略。
  static ParkThemeData? themeOf(BuildContext context) {
    return Theme.of(context).extension<ParkThemeData>();
  }

  /// 当前生效的风格。
  ///
  /// 优先取作用域声明的 [style]；否则回退到 [ParkThemeData.surfaceStyle]；
  /// 主题缺失时兜底为 [ParkSurfaceStyle.stripe]（与现有默认行为一致）。
  static ParkSurfaceStyle of(BuildContext context) {
    return maybeOf(context) ??
        themeOf(context)?.surfaceStyle ??
        ParkSurfaceStyle.stripe;
  }

  /// 当前生效的表面令牌。
  ///
  /// 若作用域提供了 [tokenOverride] 则直接返回；否则按 [of] 解析出的风格
  /// 从主题基础令牌派生。主题缺失时使用 [ParkThemeData.light] 作为兜底。
  static ParkSurfaceTokens tokensOf(
    BuildContext context, {
    bool bordered = true,
    bool hovered = false,
    ParkSurfaceBorderTone borderTone = ParkSurfaceBorderTone.outline,
    bool transparent = false,
    double elevation = 0.0,
  }) {
    final ParkSurfaceStyleScope? scope = context
        .dependOnInheritedWidgetOfExactType<ParkSurfaceStyleScope>();
    if (scope?.tokenOverride != null) return scope!.tokenOverride!;

    final ParkThemeData park = themeOf(context) ?? ParkThemeData.light();
    return ParkSurfaceTokens.resolve(
      style: scope?.style ?? park.surfaceStyle,
      colors: park.colors,
      radius: park.radius,
      blur: park.blur,
      bordered: bordered,
      hovered: hovered,
      borderTone: borderTone,
      transparent: transparent,
      elevation: elevation,
    );
  }

  @override
  bool updateShouldNotify(ParkSurfaceStyleScope oldWidget) {
    return style != oldWidget.style || tokenOverride != oldWidget.tokenOverride;
  }
}
