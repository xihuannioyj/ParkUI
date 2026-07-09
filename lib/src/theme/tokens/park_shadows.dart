import 'package:flutter/material.dart';

/// Park UI 阴影令牌
///
/// 提供三级阴影预设：小（sm）、中（md）、大（lg），
/// 对应不同的视觉层级（卡片、弹窗、浮动层）。
@immutable
class ParkShadows {
  /// 小阴影 — 卡片、按钮等贴近表面的元素
  final List<BoxShadow> sm;

  /// 中阴影 — 下拉菜单、浮动面板等
  final List<BoxShadow> md;

  /// 大阴影 — 对话框、模态框等高层级元素
  final List<BoxShadow> lg;

  const ParkShadows._({
    required this.sm,
    required this.md,
    required this.lg,
  });

  /// 默认阴影令牌（navy 色调柔和阴影，Stripe 风格）
  factory ParkShadows.defaults() {
    return const ParkShadows._(
      sm: [
        BoxShadow(
          color: Color(0x120A2540), // navy 7%
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
        BoxShadow(
          color: Color(0x0A0A2540), // navy 4%
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      md: [
        BoxShadow(
          color: Color(0x140A2540), // navy 8%
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color(0x0A0A2540), // navy 4%
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
      lg: [
        BoxShadow(
          color: Color(0x1C0A2540), // navy 11%
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: Color(0x120A2540), // navy 7%
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  /// 暗色模式阴影（更深的阴影色）
  factory ParkShadows.dark() {
    return const ParkShadows._(
      sm: [
        BoxShadow(
          color: Color(0x40000000), // 25% black
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
      md: [
        BoxShadow(
          color: Color(0x52000000), // 32% black
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color(0x33000000), // 20% black
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
      lg: [
        BoxShadow(
          color: Color(0x66000000), // 40% black
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: Color(0x40000000), // 25% black
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ],
    );
  }

  /// 扁平风格阴影（完全无阴影）。
  factory ParkShadows.flat() {
    return const ParkShadows._(
      sm: <BoxShadow>[],
      md: <BoxShadow>[],
      lg: <BoxShadow>[],
    );
  }

  /// 霓虹风格阴影（深色弥散辉光，品牌色辉光由卡片层叠加）。
  factory ParkShadows.neon() {
    return const ParkShadows._(
      sm: <BoxShadow>[
        BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4)),
      ],
      md: <BoxShadow>[
        BoxShadow(color: Color(0x52000000), blurRadius: 20, offset: Offset(0, 8)),
      ],
      lg: <BoxShadow>[
        BoxShadow(color: Color(0x66000000), blurRadius: 36, offset: Offset(0, 14)),
      ],
    );
  }

  ParkShadows copyWith({
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
  }) {
    return ParkShadows._(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
    );
  }
}
