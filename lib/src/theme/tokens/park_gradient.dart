import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 渐变类型。
enum ParkGradientType {
  /// 线性渐变（[LinearGradient]）。
  linear,

  /// 径向渐变（[RadialGradient]）。
  radial,

  /// 扫描渐变（[SweepGradient]）。
  sweep,
}

/// Park UI 渐变值令牌。
///
/// Flutter 自带的 `Gradient` 家族无法参与 `ThemeExtension.lerp`（Flutter 未为
/// [Gradient] 提供 `lerp`），因此无法直接放进主题并在主题过渡动画中插值。
/// 本类是对 Flutter 渐变的**不可变值包装**，补齐了 `copyWith` / `lerp` /
/// `==` / `hashCode` 四件套，使其可以安全地作为令牌参与主题派生与插值。
///
/// 设计约束：
/// - 所有颜色必须来自 [ParkColors] 或其他令牌，**禁止硬编码色值**；
/// - [stops] 为 null 时由 Flutter 均分，避免为等间距色标写死数字；
/// - [begin] / [end] / [center] / [tileMode] 无法连续插值，在 `lerp` 中按
///   `t < 0.5` 取 a、否则取 b（与仓库内其他令牌的离散字段处理一致）。
@immutable
class ParkGradient {
  /// 创建渐变令牌。
  const ParkGradient({
    required this.type,
    required this.colors,
    this.stops,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.center = Alignment.center,
    this.radius = 0.5,
    this.tileMode = TileMode.clamp,
  });

  /// 线性渐变。
  const ParkGradient.linear({
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) : this(
         type: ParkGradientType.linear,
         colors: colors,
         stops: stops,
         begin: begin,
         end: end,
       );

  /// 径向渐变。
  const ParkGradient.radial({
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) : this(
         type: ParkGradientType.radial,
         colors: colors,
         stops: stops,
         center: center,
         radius: radius,
       );

  /// 扫描渐变（整圈 0° → 360°）。
  ///
  /// [SweepGradient] 要求至少两个颜色色标才能形成完整环。
  const ParkGradient.sweep({
    required List<Color> colors,
    List<double>? stops,
    AlignmentGeometry center = Alignment.center,
  }) : this(
         type: ParkGradientType.sweep,
         colors: colors,
         stops: stops,
         center: center,
       );

  /// 渐变类型。
  final ParkGradientType type;

  /// 渐变色标（建议 2-3 色；[ParkGradientType.sweep] 建议首尾同色）。
  final List<Color> colors;

  /// 色标位置（与 [colors] 等长）；null 表示均分。
  final List<double>? stops;

  /// 线性渐变起点。
  final AlignmentGeometry begin;

  /// 线性渐变终点。
  final AlignmentGeometry end;

  /// 径向 / 扫描渐变中心。
  final AlignmentGeometry center;

  /// 径向渐变半径。
  final double radius;

  /// 超出边界时的平铺模式。
  final TileMode tileMode;

  // ========================================================================
  // 派生：转换为 Flutter 原生渐变
  // ========================================================================

  /// 转换为 [LinearGradient]。
  ///
  /// 当 [type] 不是 [ParkGradientType.linear] 时，[begin] / [end] 仍会被使用，
  /// 调用方需自行保证语义正确。
  LinearGradient get asLinear => LinearGradient(
    begin: begin,
    end: end,
    colors: colors,
    stops: stops,
    tileMode: tileMode,
  );

  /// 转换为 [RadialGradient]。
  RadialGradient get asRadial => RadialGradient(
    center: center,
    radius: radius,
    colors: colors,
    stops: stops,
    tileMode: tileMode,
  );

  /// 转换为 [SweepGradient]。
  SweepGradient get asSweep => SweepGradient(
    center: center,
    startAngle: 0.0,
    endAngle: math.pi * 2,
    colors: colors,
    stops: stops,
    tileMode: tileMode,
  );

  /// 按 [type] 分派到对应的 Flutter 渐变。
  Gradient get asFlutter => switch (type) {
    ParkGradientType.linear => asLinear,
    ParkGradientType.radial => asRadial,
    ParkGradientType.sweep => asSweep,
  };

  /// 为给定区域创建着色器（供 [ShaderMask] 等使用）。
  Shader createShader(Rect rect) => asFlutter.createShader(rect);

  // ========================================================================
  // 值语义
  // ========================================================================

  /// 复制并覆盖部分字段。
  ParkGradient copyWith({
    ParkGradientType? type,
    List<Color>? colors,
    List<double>? stops,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    AlignmentGeometry? center,
    double? radius,
    TileMode? tileMode,
  }) {
    return ParkGradient(
      type: type ?? this.type,
      colors: colors ?? this.colors,
      stops: stops ?? this.stops,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      tileMode: tileMode ?? this.tileMode,
    );
  }

  /// 逐属性平滑插值。
  ///
  /// - [colors] 逐项 [Color.lerp]；长度不等时 `t < 0.5` 取 a，否则取 b；
  /// - [stops] 与颜色同步插值，长度不等时同样按中点切换；
  /// - [radius] 线性插值；
  /// - 离散字段（[type] / [begin] / [end] / [center] / [tileMode]）在
  ///   `t < 0.5` 取 a，否则取 b。
  static ParkGradient lerp(ParkGradient a, ParkGradient b, double t) {
    if (identical(a, b)) return a;

    final List<Color> colors = a.colors.length == b.colors.length
        ? List<Color>.generate(
            a.colors.length,
            (int i) => Color.lerp(a.colors[i], b.colors[i], t)!,
          )
        : (t < 0.5 ? a.colors : b.colors);

    final List<double>? stops = _lerpStops(a.stops, b.stops, t);

    return ParkGradient(
      type: t < 0.5 ? a.type : b.type,
      colors: colors,
      stops: stops,
      begin: t < 0.5 ? a.begin : b.begin,
      end: t < 0.5 ? a.end : b.end,
      center: t < 0.5 ? a.center : b.center,
      radius: a.radius + (b.radius - a.radius) * t,
      tileMode: t < 0.5 ? a.tileMode : b.tileMode,
    );
  }

  /// 插值色标位置；任一侧为 null 或长度不一致时按中点切换。
  static List<double>? _lerpStops(List<double>? a, List<double>? b, double t) {
    if (a == null || b == null || a.length != b.length) {
      return t < 0.5 ? a : b;
    }
    return List<double>.generate(
      a.length,
      (int i) => a[i] + (b[i] - a[i]) * t,
      growable: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkGradient &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          _colorListEquals(colors, other.colors) &&
          _doubleListEquals(stops, other.stops) &&
          begin == other.begin &&
          end == other.end &&
          center == other.center &&
          radius == other.radius &&
          tileMode == other.tileMode;

  @override
  int get hashCode => Object.hash(
    type,
    Object.hashAll(colors),
    stops == null ? -1 : Object.hashAll(stops!),
    begin,
    end,
    center,
    radius,
    tileMode,
  );

  /// 比较两个颜色列表元素逐一相等。
  static bool _colorListEquals(List<Color> a, List<Color> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// 比较两个 double 列表元素逐一相等。
  static bool _doubleListEquals(List<double>? a, List<double>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
