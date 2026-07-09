import 'package:flutter/material.dart';

/// Park UI 间距令牌
///
/// 基于 4px 基准的间距体系，覆盖从微调到页面级留白的所有场景。
/// 所有值都是 4 的倍数，确保像素对齐。
@immutable
class ParkSpacing {
  /// 2px — 极小间距（图标与文字之间等）
  final double xxs;

  /// 4px — 超小间距
  final double xs;

  /// 8px — 小号间距（紧凑元素之间）
  final double sm;

  /// 12px — 中小间距
  final double md;

  /// 16px — 默认间距（最常用）
  final double base;

  /// 20px — 中大间距
  final double lg;

  /// 24px — 大号间距
  final double xl;

  /// 32px — 超大间距（区块之间）
  final double xxl;

  /// 48px — 页面级留白
  final double page;

  const ParkSpacing({
    this.xxs = 2.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 12.0,
    this.base = 16.0,
    this.lg = 20.0,
    this.xl = 24.0,
    this.xxl = 32.0,
    this.page = 48.0,
  });

  /// 默认间距令牌
  factory ParkSpacing.defaults() {
    return const ParkSpacing();
  }

  // ========================================================================
  // 便捷方法：生成 SizedBox
  // ========================================================================

  /// 水平间距 SizedBox
  Widget hGap(double size) => SizedBox(width: size);

  /// 垂直间距 SizedBox
  Widget vGap(double size) => SizedBox(height: size);

  /// 水平 xs 间距
  Widget get hXs => SizedBox(width: xs);

  /// 水平 sm 间距
  Widget get hSm => SizedBox(width: sm);

  /// 水平 base 间距
  Widget get hBase => SizedBox(width: base);

  /// 水平 md 间距
  Widget get hMd => SizedBox(width: md);

  /// 水平 lg 间距
  Widget get hLg => SizedBox(width: lg);

  /// 垂直 xs 间距
  Widget get vXs => SizedBox(height: xs);

  /// 垂直 sm 间距
  Widget get vSm => SizedBox(height: sm);

  /// 垂直 base 间距
  Widget get vBase => SizedBox(height: base);

  /// 垂直 md 间距
  Widget get vMd => SizedBox(height: md);

  /// 垂直 lg 间距
  Widget get vLg => SizedBox(height: lg);

  /// 垂直 xl 间距
  Widget get vXl => SizedBox(height: xl);

  ParkSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? base,
    double? lg,
    double? xl,
    double? xxl,
    double? page,
  }) {
    return ParkSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      base: base ?? this.base,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      page: page ?? this.page,
    );
  }
}
