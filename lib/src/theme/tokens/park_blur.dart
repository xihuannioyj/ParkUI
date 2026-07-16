import 'package:flutter/material.dart';

/// Park UI 模糊令牌
///
/// 定义 4 级背景模糊半径（sm / md / lg / xl），用于毛玻璃效果
/// （BackdropFilter / ImageFilter.blur）等场景。
///
/// 典型用途：
/// - sm (4px): 轻量毛玻璃（tooltip、badge）
/// - md (8px): 中等模糊（下拉菜单、浮动面板）
/// - lg (16px): 强模糊（对话框遮罩、侧边栏）
/// - xl (24px): 极强模糊（全屏遮罩、模态背景）
@immutable
class ParkBlur {
  /// 4px — 轻量毛玻璃（tooltip、badge）
  final double sm;

  /// 8px — 中等模糊（下拉菜单、浮动面板）
  final double md;

  /// 16px — 强模糊（对话框遮罩、侧边栏）
  final double lg;

  /// 24px — 极强模糊（全屏遮罩、模态背景）
  final double xl;

  const ParkBlur({
    this.sm = 4.0,
    this.md = 8.0,
    this.lg = 16.0,
    this.xl = 24.0,
  });

  /// 默认模糊令牌
  factory ParkBlur.defaults() {
    return const ParkBlur();
  }

  /// 逐模糊半径平滑插值。
  static ParkBlur lerp(ParkBlur a, ParkBlur b, double t) {
    return ParkBlur(
      sm: a.sm + (b.sm - a.sm) * t,
      md: a.md + (b.md - a.md) * t,
      lg: a.lg + (b.lg - a.lg) * t,
      xl: a.xl + (b.xl - a.xl) * t,
    );
  }

  ParkBlur copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return ParkBlur(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkBlur &&
          runtimeType == other.runtimeType &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl;

  @override
  int get hashCode => Object.hash(sm, md, lg, xl);
}
