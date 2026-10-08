import 'package:flutter/material.dart';
import 'park_colors.dart';
import 'park_gradient.dart';

/// Park UI 扩展强调色。
///
/// 这两个色值不属于 [ParkColors] 的品牌 / 功能 / 中性三族，是为「极光」等
/// 预设专门引入的**设计系统扩展色**。集中定义在此处而非散落在组件里，
/// 是为了让"所有颜色走令牌"的红线依然成立，且便于后续统一调整。
abstract final class ParkAccentColors {
  /// 极光青（aurora preset 第一段）。
  static const Color auroraTeal = Color(0xFF4ECDC4);

  /// 极光粉（aurora preset 第三段）。
  static const Color auroraPink = Color(0xFFFF6B9D);
}

/// Park UI 渐变令牌组。
///
/// 提供一组**语义化**的渐变，全部由 [ParkColors] 派生（不硬编码品牌色），
/// 供渐变文字、玻璃高光、霓虹描边、页面背景等场景直接消费。
///
/// 与 [ParkColors] 平级，通过 `ParkThemeData.gradients` 暴露；
/// 预设（如 aurora / candy）可以覆盖本组令牌。
@immutable
class ParkGradients {
  /// 创建渐变令牌组。
  const ParkGradients({
    required this.brand,
    required this.accent,
    required this.neonGlow,
    required this.aurora,
    required this.glassSheen,
    required this.sweep,
  });

  /// 由 [colors] 派生出整套语义渐变（推荐入口）。
  factory ParkGradients.fromColors(ParkColors colors) {
    return ParkGradients(
      brand: ParkGradient.linear(
        colors: <Color>[colors.brand, colors.brandAt(7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: ParkGradient.linear(
        colors: <Color>[colors.info, colors.brand],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      neonGlow: ParkGradient.linear(
        colors: <Color>[
          colors.brand.withValues(alpha: 0.85),
          colors.brand.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      aurora: const ParkGradient.linear(
        colors: <Color>[
          ParkAccentColors.auroraTeal,
          Color(0xFF9B5DE5),
          ParkAccentColors.auroraPink,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glassSheen: ParkGradient.linear(
        // textOnBrand 在明暗两套色板中均为白色，语义上即"反色面上的高光"。
        colors: <Color>[
          colors.textOnBrand.withValues(alpha: 0.28),
          colors.textOnBrand.withValues(alpha: 0.04),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      sweep: ParkGradient.sweep(
        colors: <Color>[colors.brand, colors.brandLight, colors.brand],
      ),
    );
  }

  /// 品牌线性渐变（主色 → 主色 7 阶）。
  final ParkGradient brand;

  /// 功能强调渐变（信息色 → 品牌色）。
  final ParkGradient accent;

  /// 霓虹辉光渐变（品牌色 → 透明）。
  final ParkGradient neonGlow;

  /// 极光三色渐变（青 → 紫 → 粉）。
  final ParkGradient aurora;

  /// 玻璃高光渐变（反色面 28% → 4%）。
  final ParkGradient glassSheen;

  /// 环形流动渐变（品牌色 → 浅色 → 品牌色）。
  final ParkGradient sweep;

  /// 逐项插值。
  static ParkGradients lerp(ParkGradients a, ParkGradients b, double t) {
    return ParkGradients(
      brand: ParkGradient.lerp(a.brand, b.brand, t),
      accent: ParkGradient.lerp(a.accent, b.accent, t),
      neonGlow: ParkGradient.lerp(a.neonGlow, b.neonGlow, t),
      aurora: ParkGradient.lerp(a.aurora, b.aurora, t),
      glassSheen: ParkGradient.lerp(a.glassSheen, b.glassSheen, t),
      sweep: ParkGradient.lerp(a.sweep, b.sweep, t),
    );
  }

  /// 复制并覆盖部分字段。
  ParkGradients copyWith({
    ParkGradient? brand,
    ParkGradient? accent,
    ParkGradient? neonGlow,
    ParkGradient? aurora,
    ParkGradient? glassSheen,
    ParkGradient? sweep,
  }) {
    return ParkGradients(
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      neonGlow: neonGlow ?? this.neonGlow,
      aurora: aurora ?? this.aurora,
      glassSheen: glassSheen ?? this.glassSheen,
      sweep: sweep ?? this.sweep,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkGradients &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          accent == other.accent &&
          neonGlow == other.neonGlow &&
          aurora == other.aurora &&
          glassSheen == other.glassSheen &&
          sweep == other.sweep;

  @override
  int get hashCode => Object.hash(brand, accent, neonGlow, aurora, glassSheen, sweep);
}
