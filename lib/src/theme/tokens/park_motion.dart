import 'package:flutter/material.dart';

/// Park 动效设计令牌
///
/// 定义统一的动画时长与缓动曲线，
/// 确保所有组件的过渡动效风格一致。
///
/// 用法：
/// ```dart
/// AnimatedContainer(
///   duration: ParkMotion.standard,
///   curve: ParkMotion.defaultEasing,
///   ...
/// )
/// ```
@immutable
class ParkMotion {
  const ParkMotion._();

  /// 快速过渡（150ms）— hover、focus、pressed 等即时反馈。
  static const Duration quick = Duration(milliseconds: 150);

  /// 标准过渡（250ms）— 面板展开、弹窗出入、页面切换。
  static const Duration standard = Duration(milliseconds: 250);

  /// 慢速过渡（400ms）— 复杂动画、多元素编排。
  static const Duration slow = Duration(milliseconds: 400);

  /// 默认缓动曲线 — Stripe 风格快入慢出（easeOutCubic）。
  static const Curve defaultEasing = Curves.easeOutCubic;

  /// 进入缓动曲线 — 元素出现时使用（快入慢出）。
  static const Curve enterEasing = Curves.easeOut;

  /// 退出缓动曲线 — 元素消失时使用（慢入快出）。
  static const Curve exitEasing = Curves.easeIn;
}
