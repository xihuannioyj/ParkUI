import 'package:flutter/material.dart';

/// 组件类型枚举（用于圆角查询）
///
/// 仅用于快捷查询组件推荐圆角值，不与组件实际类型耦合。
enum ParkRadiusComponent {
  /// 常规按钮
  button,

  /// 圆角/胶囊按钮
  buttonRound,

  /// 输入框
  input,

  /// 卡片
  card,

  /// 对话框
  dialog,

  /// 选择器
  select,

  /// 标签
  tag,

  /// 徽标
  badge,
}

/// Park UI 圆角令牌
///
/// 提供从小到大的圆角预设值，覆盖按钮、卡片、输入框、弹窗等场景。
@immutable
class ParkRadius {
  /// 4px — 微圆角（Tag、Badge 等小元素）
  final double xs;

  /// 8px — 小圆角（按钮、输入框默认）
  final double sm;

  /// 12px — 中圆角（卡片、面板）
  final double md;

  /// 16px — 大圆角（大卡片、底部弹窗）
  final double lg;

  /// 20px — 超大圆角（对话框、模态框）
  final double xl;

  /// 9999 — 全圆角（胶囊按钮、头像）
  final double full;

  const ParkRadius({
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 20.0,
    this.full = 9999.0,
  });

  /// 默认圆角令牌
  factory ParkRadius.defaults() {
    return const ParkRadius();
  }

  // ========================================================================
  // 便捷方法：生成 BorderRadius
  // ========================================================================

  /// 微圆角
  BorderRadius get brXs => BorderRadius.circular(xs);

  /// 小圆角
  BorderRadius get brSm => BorderRadius.circular(sm);

  /// 中圆角
  BorderRadius get brMd => BorderRadius.circular(md);

  /// 大圆角
  BorderRadius get brLg => BorderRadius.circular(lg);

  /// 超大圆角
  BorderRadius get brXl => BorderRadius.circular(xl);

  /// 全圆角（胶囊形）
  BorderRadius get brFull => BorderRadius.circular(full);

  // ========================================================================
  // 组件圆角映射
  // ========================================================================

  /// 获取指定组件的推荐圆角值（px）。
  double componentRadius(ParkRadiusComponent component) {
    switch (component) {
      case ParkRadiusComponent.button:
      case ParkRadiusComponent.input:
      case ParkRadiusComponent.select:
        return sm; // 8px
      case ParkRadiusComponent.buttonRound:
        return full; // 9999px
      case ParkRadiusComponent.card:
        return md; // 12px
      case ParkRadiusComponent.dialog:
        return lg; // 16px
      case ParkRadiusComponent.tag:
      case ParkRadiusComponent.badge:
        return xs; // 4px
    }
  }

  /// 获取指定组件的推荐 [BorderRadius]。
  BorderRadius componentBr(ParkRadiusComponent component) =>
      BorderRadius.circular(componentRadius(component));

  ParkRadius copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? full,
  }) {
    return ParkRadius(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkRadius &&
          runtimeType == other.runtimeType &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl &&
          full == other.full;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl, full);
}
