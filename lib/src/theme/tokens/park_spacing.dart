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

  /// 垂直 xxl 间距
  Widget get vXxl => SizedBox(height: xxl);

  /// 垂直 page 间距
  Widget get vPage => SizedBox(height: page);

  /// 垂直 xxs 间距
  Widget get vXxs => SizedBox(height: xxs);

  /// 水平 xxl 间距
  Widget get hXxl => SizedBox(width: xxl);

  /// 水平 page 间距
  Widget get hPage => SizedBox(width: page);

  /// 水平 xxs 间距
  Widget get hXxs => SizedBox(width: xxs);

  // ========================================================================
  // 场景速查 getter（基于 HANDOFF §3.3）
  // ========================================================================

  /// 按钮水平内边距 (medium 尺寸) = base + sm = 24px
  double get buttonHorizontalPaddingMd => base + sm;

  /// 按钮垂直内边距 (medium 尺寸) = sm = 8px
  double get buttonVerticalPaddingMd => sm;

  /// 输入框与标签间距 = sm = 8px
  double get inputLabelGap => sm;

  /// 表单字段间距 = xl = 24px
  double get formFieldGap => xl;

  /// 卡片内边距 = base = 16px
  double get cardPadding => base;

  /// 卡片间距 = xl = 24px
  double get cardGap => xl;

  /// Section 间距 = xxl = 32px
  double get sectionGap => xxl;

  /// 弹窗内边距 = xl = 24px
  double get dialogPadding => xl;

  /// 逐间距值平滑插值。
  static ParkSpacing lerp(ParkSpacing a, ParkSpacing b, double t) {
    return ParkSpacing(
      xxs: a.xxs + (b.xxs - a.xxs) * t,
      xs: a.xs + (b.xs - a.xs) * t,
      sm: a.sm + (b.sm - a.sm) * t,
      md: a.md + (b.md - a.md) * t,
      base: a.base + (b.base - a.base) * t,
      lg: a.lg + (b.lg - a.lg) * t,
      xl: a.xl + (b.xl - a.xl) * t,
      xxl: a.xxl + (b.xxl - a.xxl) * t,
      page: a.page + (b.page - a.page) * t,
    );
  }

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkSpacing &&
          runtimeType == other.runtimeType &&
          xxs == other.xxs &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          base == other.base &&
          lg == other.lg &&
          xl == other.xl &&
          xxl == other.xxl &&
          page == other.page;

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, base, lg, xl, xxl, page);
}
