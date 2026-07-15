import 'package:flutter/material.dart';

/// Park UI 尺寸令牌
///
/// 提供组件级尺寸预设，涵盖按钮、输入框等常用控件的高度与内边距。
/// 所有值遵循 HANDOFF 组件规范中的尺寸定义，可在运行时按需调整。
@immutable
class ParkSizing {
  // ========================================================================
  // 按钮高度
  // ========================================================================

  /// 小号按钮高度 — 28px
  final double buttonHeightSm;

  /// 中号按钮高度 — 36px
  final double buttonHeightMd;

  /// 大号按钮高度 — 44px
  final double buttonHeightLg;

  // ========================================================================
  // 输入框高度
  // ========================================================================

  /// 小号输入框高度 — 32px
  final double inputHeightSm;

  /// 中号输入框高度 — 48px
  final double inputHeightMd;

  /// 大号输入框高度 — 56px
  final double inputHeightLg;

  // ========================================================================
  // 按钮内边距
  // ========================================================================

  /// 中号按钮水平内边距 — 24px
  final double buttonHorizontalPaddingMd;

  /// 中号按钮垂直内边距 — 8px
  final double buttonVerticalPaddingMd;

  // ========================================================================
  // 可访问性
  // ========================================================================

  /// 最小触摸目标 — 44px（WCAG 2.5.5 / Apple HIG / Material）
  final double minTouchTarget;

  const ParkSizing({
    this.buttonHeightSm = 28.0,
    this.buttonHeightMd = 36.0,
    this.buttonHeightLg = 44.0,
    this.inputHeightSm = 32.0,
    this.inputHeightMd = 48.0,
    this.inputHeightLg = 56.0,
    this.buttonHorizontalPaddingMd = 24.0,
    this.buttonVerticalPaddingMd = 8.0,
    this.minTouchTarget = 44.0,
  });

  /// 默认尺寸令牌
  factory ParkSizing.defaults() => const ParkSizing();

  /// 逐尺寸值平滑插值。
  static ParkSizing lerp(ParkSizing a, ParkSizing b, double t) {
    return ParkSizing(
      buttonHeightSm: a.buttonHeightSm + (b.buttonHeightSm - a.buttonHeightSm) * t,
      buttonHeightMd: a.buttonHeightMd + (b.buttonHeightMd - a.buttonHeightMd) * t,
      buttonHeightLg: a.buttonHeightLg + (b.buttonHeightLg - a.buttonHeightLg) * t,
      inputHeightSm: a.inputHeightSm + (b.inputHeightSm - a.inputHeightSm) * t,
      inputHeightMd: a.inputHeightMd + (b.inputHeightMd - a.inputHeightMd) * t,
      inputHeightLg: a.inputHeightLg + (b.inputHeightLg - a.inputHeightLg) * t,
      buttonHorizontalPaddingMd:
          a.buttonHorizontalPaddingMd + (b.buttonHorizontalPaddingMd - a.buttonHorizontalPaddingMd) * t,
      buttonVerticalPaddingMd:
          a.buttonVerticalPaddingMd + (b.buttonVerticalPaddingMd - a.buttonVerticalPaddingMd) * t,
      minTouchTarget: a.minTouchTarget + (b.minTouchTarget - a.minTouchTarget) * t,
    );
  }

  ParkSizing copyWith({
    double? buttonHeightSm,
    double? buttonHeightMd,
    double? buttonHeightLg,
    double? inputHeightSm,
    double? inputHeightMd,
    double? inputHeightLg,
    double? buttonHorizontalPaddingMd,
    double? buttonVerticalPaddingMd,
    double? minTouchTarget,
  }) {
    return ParkSizing(
      buttonHeightSm: buttonHeightSm ?? this.buttonHeightSm,
      buttonHeightMd: buttonHeightMd ?? this.buttonHeightMd,
      buttonHeightLg: buttonHeightLg ?? this.buttonHeightLg,
      inputHeightSm: inputHeightSm ?? this.inputHeightSm,
      inputHeightMd: inputHeightMd ?? this.inputHeightMd,
      inputHeightLg: inputHeightLg ?? this.inputHeightLg,
      buttonHorizontalPaddingMd:
          buttonHorizontalPaddingMd ?? this.buttonHorizontalPaddingMd,
      buttonVerticalPaddingMd:
          buttonVerticalPaddingMd ?? this.buttonVerticalPaddingMd,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkSizing &&
          runtimeType == other.runtimeType &&
          buttonHeightSm == other.buttonHeightSm &&
          buttonHeightMd == other.buttonHeightMd &&
          buttonHeightLg == other.buttonHeightLg &&
          inputHeightSm == other.inputHeightSm &&
          inputHeightMd == other.inputHeightMd &&
          inputHeightLg == other.inputHeightLg &&
          buttonHorizontalPaddingMd == other.buttonHorizontalPaddingMd &&
          buttonVerticalPaddingMd == other.buttonVerticalPaddingMd &&
          minTouchTarget == other.minTouchTarget;

  @override
  int get hashCode => Object.hash(
        buttonHeightSm,
        buttonHeightMd,
        buttonHeightLg,
        inputHeightSm,
        inputHeightMd,
        inputHeightLg,
        buttonHorizontalPaddingMd,
        buttonVerticalPaddingMd,
        minTouchTarget,
      );
}
