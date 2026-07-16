import 'package:flutter/material.dart';

/// Park UI 海拔令牌
///
/// 定义 5 级海拔值（xs / sm / md / lg / xl），对标 Material Design elevation。
/// 海拔值表示组件在 Z 轴上的视觉高度层级，数值越大阴影越深、层级越高。
///
/// 典型用途：
/// - xs (1): 贴面元素（chip、tag）
/// - sm (2): 按钮、卡片
/// - md (4): 浮动面板、下拉菜单
/// - lg (8): 浮动操作按钮、侧边栏
/// - xl (12): 对话框、模态框
@immutable
class ParkElevation {
  /// 1dp — 贴面元素（chip、tag）
  final double xs;

  /// 2dp — 按钮、卡片
  final double sm;

  /// 4dp — 浮动面板、下拉菜单
  final double md;

  /// 8dp — 浮动操作按钮、侧边栏
  final double lg;

  /// 12dp — 对话框、模态框
  final double xl;

  const ParkElevation({
    this.xs = 1.0,
    this.sm = 2.0,
    this.md = 4.0,
    this.lg = 8.0,
    this.xl = 12.0,
  });

  /// 默认海拔令牌
  factory ParkElevation.defaults() {
    return const ParkElevation();
  }

  /// 逐海拔值平滑插值。
  static ParkElevation lerp(ParkElevation a, ParkElevation b, double t) {
    return ParkElevation(
      xs: a.xs + (b.xs - a.xs) * t,
      sm: a.sm + (b.sm - a.sm) * t,
      md: a.md + (b.md - a.md) * t,
      lg: a.lg + (b.lg - a.lg) * t,
      xl: a.xl + (b.xl - a.xl) * t,
    );
  }

  ParkElevation copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return ParkElevation(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkElevation &&
          runtimeType == other.runtimeType &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl);
}
