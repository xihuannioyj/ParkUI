import 'package:flutter/material.dart';

/// Park 动画令牌。
@immutable
class ParkMotion {
  /// 标准时长（毫秒）。
  final int standardMs;

  /// 快速时长（毫秒）。
  final int quickMs;

  /// 慢速时长（毫秒）。
  final int slowMs;

  /// 编组动画 / 入场序列的间隔延迟（毫秒）。
  final int staggerMs;

  /// 进入曲线的入点缓动。
  final Curve enterEasing;

  /// 默认曲线的出点缓动。
  final Curve defaultEasing;

  /// 退出曲线的出点缓动。
  final Curve exitEasing;

  // Computed getters
  Duration get standard => Duration(milliseconds: standardMs);
  Duration get quick => Duration(milliseconds: quickMs);
  Duration get slow => Duration(milliseconds: slowMs);

  /// 编组动画 / 入场序列的间隔延迟。
  Duration get stagger => Duration(milliseconds: staggerMs);

  const ParkMotion({
    this.standardMs = 250,
    this.quickMs = 150,
    this.slowMs = 400,
    this.staggerMs = 50,
    this.enterEasing = Curves.easeOut,
    this.defaultEasing = Curves.easeOutCubic,
    this.exitEasing = Curves.easeIn,
  });

  static const defaults = ParkMotion();

  /// 逐属性平滑插值。
  ///
  /// 时长字段（standardMs / quickMs / slowMs / staggerMs）做线性插值；
  /// 缓动曲线（Curve）无法连续插值，在 t < 0.5 时使用 a，否则使用 b。
  static ParkMotion lerp(ParkMotion a, ParkMotion b, double t) {
    return ParkMotion(
      standardMs: (a.standardMs + (b.standardMs - a.standardMs) * t).round(),
      quickMs: (a.quickMs + (b.quickMs - a.quickMs) * t).round(),
      slowMs: (a.slowMs + (b.slowMs - a.slowMs) * t).round(),
      staggerMs: (a.staggerMs + (b.staggerMs - a.staggerMs) * t).round(),
      enterEasing: t < 0.5 ? a.enterEasing : b.enterEasing,
      defaultEasing: t < 0.5 ? a.defaultEasing : b.defaultEasing,
      exitEasing: t < 0.5 ? a.exitEasing : b.exitEasing,
    );
  }

  ParkMotion copyWith({
    int? standardMs,
    int? quickMs,
    int? slowMs,
    int? staggerMs,
    Curve? enterEasing,
    Curve? defaultEasing,
    Curve? exitEasing,
  }) {
    return ParkMotion(
      standardMs: standardMs ?? this.standardMs,
      quickMs: quickMs ?? this.quickMs,
      slowMs: slowMs ?? this.slowMs,
      staggerMs: staggerMs ?? this.staggerMs,
      enterEasing: enterEasing ?? this.enterEasing,
      defaultEasing: defaultEasing ?? this.defaultEasing,
      exitEasing: exitEasing ?? this.exitEasing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkMotion &&
          runtimeType == other.runtimeType &&
          standardMs == other.standardMs &&
          quickMs == other.quickMs &&
          slowMs == other.slowMs &&
          staggerMs == other.staggerMs &&
          enterEasing == other.enterEasing &&
          defaultEasing == other.defaultEasing &&
          exitEasing == other.exitEasing;

  @override
  int get hashCode => Object.hash(
        standardMs,
        quickMs,
        slowMs,
        staggerMs,
        enterEasing,
        defaultEasing,
        exitEasing,
      );
}
