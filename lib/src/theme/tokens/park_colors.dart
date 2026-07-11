import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Park UI 色彩令牌（Stripe 风格）
///
/// 提供完整的设计色彩体系，包含品牌色、功能色、中性色三大类。
/// 每个令牌都是不可变的 final 值，通过 [ParkColors.light] 和 [ParkColors.dark]
/// 工厂构造获取预设色板。
///
/// 设计原则（对齐 Stripe 设计语言）：
/// - 品牌色：Stripe 标志性 blurple（#635BFF），提供 10 阶色板
/// - 功能色：成功(绿)、警告(橙)、错误(红)、信息(blurple)
/// - 中性色：navy(#0A2540) 文字、slate 次级文字、浅灰占位、淡边框与灰蓝背景
@immutable
class ParkColors {
  // ========================================================================
  // 品牌色
  // ========================================================================

  /// 品牌主色
  final Color brand;

  /// 品牌色浅（用于 hover、light 背景等）
  final Color brandLight;

  /// 品牌色深（用于 active、pressed 等）
  final Color brandDark;

  /// 品牌色 10 阶色板（index 0-9，从浅到深）
  final List<Color> brandPalette;

  // ========================================================================
  // 功能色
  // ========================================================================

  /// 成功色（成功状态、正面反馈）
  final Color success;

  /// 成功色浅
  final Color successLight;

  /// 警告色（注意、提示）
  final Color warning;

  /// 警告色浅
  final Color warningLight;

  /// 错误色（错误状态、危险操作）
  final Color error;

  /// 错误色浅
  final Color errorLight;

  /// 信息色（普通提示、辅助信息）
  final Color info;

  /// 信息色浅
  final Color infoLight;

  // ========================================================================
  // 中性色 - 文字
  // ========================================================================

  /// 主要文字色
  final Color textPrimary;

  /// 次要文字色
  final Color textSecondary;

  /// 占位文字色
  final Color textPlaceholder;

  /// 禁用文字色
  final Color textDisabled;

  /// 反色文字（用于深色背景上的白色文字）
  final Color textOnBrand;

  // ========================================================================
  // 中性色 - 边框 & 分割线
  // ========================================================================

  /// 边框色
  final Color border;

  /// 边框色浅（用于 hover 等轻量交互）
  final Color borderLight;

  /// 分割线色
  final Color divider;

  // ========================================================================
  // 中性色 - 背景
  // ========================================================================

  /// 页面背景色
  final Color background;

  /// 卡片/容器表面色
  final Color surface;

  /// 遮罩色（Dialog、Popup 背后的半透明层）
  final Color overlay;

  /// 禁用背景色
  final Color disabledBg;

  const ParkColors({
    required this.brand,
    required this.brandLight,
    required this.brandDark,
    required this.brandPalette,
    required this.success,
    required this.successLight,
    required this.warning,
    required this.warningLight,
    required this.error,
    required this.errorLight,
    required this.info,
    required this.infoLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.textDisabled,
    required this.textOnBrand,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.background,
    required this.surface,
    required this.overlay,
    required this.disabledBg,
  });

  /// 亮色模式默认色板（Stripe）
  factory ParkColors.light() {
    return const ParkColors(
      // 品牌色 — Stripe blurple
      brand: Color(0xFF635BFF),
      brandLight: Color(0xFFF5F3FF), // 极浅紫（hover / 浅色按钮底）
      brandDark: Color(0xFF4B45C6), // 按下态
      brandPalette: [
        Color(0xFFF5F3FF), // 1 - 最浅
        Color(0xFFEDE9FE), // 2
        Color(0xFFDDD6FE), // 3
        Color(0xFFC4B5FD), // 4
        Color(0xFFA78BFA), // 5
        Color(0xFF635BFF), // 6 - 主色
        Color(0xFF5B54E8), // 7
        Color(0xFF5147CC), // 8
        Color(0xFF4238A8), // 9
        Color(0xFF312A7A), // 10 - 最深
      ],

      // 功能色
      success: Color(0xFF1BB978),
      successLight: Color(0xFFD9F7EA),
      warning: Color(0xFFFFB400),
      warningLight: Color(0xFFFFE9B8),
      error: Color(0xFFDF1B41),
      errorLight: Color(0xFFFCE0E4),
      info: Color(0xFF635BFF),
      infoLight: Color(0xFFF5F3FF),

      // 文字
      textPrimary: Color(0xFF0A2540), // Stripe navy
      textSecondary: Color(0xFF425466), // Stripe slate
      textPlaceholder: Color(0xFF8898AA), // Stripe 浅灰
      textDisabled: Color(0xFF8792A2),
      textOnBrand: Color(0xFFFFFFFF),

      // 边框 & 分割线
      border: Color(0xFFE3E8EE),
      borderLight: Color(0xFFEDF0F5),
      divider: Color(0x140A2540), // navy 7.8%

      // 背景
      background: Color(0xFFF6F9FC), // Stripe 浅灰蓝背景
      surface: Color(0xFFFFFFFF),
      overlay: Color(0x730A2540), // navy 45%
      disabledBg: Color(0xFFEDF0F5),
    );
  }

  /// 暗色模式默认色板（Stripe dark — 深 navy 底）
  factory ParkColors.dark() {
    return const ParkColors(
      // 品牌色 — 保留 blurple
      brand: Color(0xFF635BFF),
      brandLight: Color(0xFF1A1733), // 暗色下的浅紫底（hover / 浅色按钮）
      brandDark: Color(0xFF4B45C6),
      brandPalette: [
        Color(0xFF2E2A5E), // 1 - 最深
        Color(0xFF37307A), // 2
        Color(0xFF4238A8), // 3
        Color(0xFF5147CC), // 4
        Color(0xFF635BFF), // 5 - 主色
        Color(0xFF7A73FF), // 6
        Color(0xFF8A84FF), // 7
        Color(0xFFA8A3FF), // 8
        Color(0xFFC4BFFE), // 9
        Color(0xFFE0DDFF), // 10 - 最浅
      ],

      // 功能色（暗色模式更明亮）
      success: Color(0xFF34D399),
      successLight: Color(0xFF0E2A22),
      warning: Color(0xFFFFC453),
      warningLight: Color(0xFF2A2310),
      error: Color(0xFFF25767),
      errorLight: Color(0xFF2C0E13),
      info: Color(0xFF635BFF),
      infoLight: Color(0xFF1A1733),

      // 文字（暗色模式）
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFADB8C9), // 浅 slate
      textPlaceholder: Color(0xFF7A8AA0),
      textDisabled: Color(0xFF5E6B7E),
      textOnBrand: Color(0xFFFFFFFF),

      // 边框 & 分割线（暗色模式）
      border: Color(0x1FFFFFFF), // 白 12%
      borderLight: Color(0x14FFFFFF), // 白 8%
      divider: Color(0x1AFFFFFF), // 白 10%

      // 背景（暗色模式 — 深 navy）
      background: Color(0xFF0A1B2E),
      surface: Color(0xFF0F2438),
      overlay: Color(0x99000000), // 黑 60%
      disabledBg: Color(0xFF16283C),
    );
  }

  /// 按 key 索引品牌色阶（1-10，对应 index 0-9）
  Color brandAt(int level) {
    assert(level >= 1 && level <= 10, 'brandPalette level must be 1-10');
    return brandPalette[level - 1];
  }

  ParkColors copyWith({
    Color? brand,
    Color? brandLight,
    Color? brandDark,
    List<Color>? brandPalette,
    Color? success,
    Color? successLight,
    Color? warning,
    Color? warningLight,
    Color? error,
    Color? errorLight,
    Color? info,
    Color? infoLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textPlaceholder,
    Color? textDisabled,
    Color? textOnBrand,
    Color? border,
    Color? borderLight,
    Color? divider,
    Color? background,
    Color? surface,
    Color? overlay,
    Color? disabledBg,
  }) {
    return ParkColors(
      brand: brand ?? this.brand,
      brandLight: brandLight ?? this.brandLight,
      brandDark: brandDark ?? this.brandDark,
      brandPalette: brandPalette ?? this.brandPalette,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      warning: warning ?? this.warning,
      warningLight: warningLight ?? this.warningLight,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
      info: info ?? this.info,
      infoLight: infoLight ?? this.infoLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      divider: divider ?? this.divider,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      overlay: overlay ?? this.overlay,
      disabledBg: disabledBg ?? this.disabledBg,
    );
  }

  // ========================================================================
  // 无障碍辅助方法（WCAG 2.1）
  // ========================================================================

  /// 计算两个颜色之间的相对亮度对比度 (WCAG 2.1)。
  ///
  /// 返回值 >= 4.5 表示满足 AA 级普通文字标准，
  /// >= 3.0 表示满足 AA 级大文字标准。
  static double contrastRatio(Color foreground, Color background) {
    final double l1 = _relativeLuminance(foreground);
    final double l2 = _relativeLuminance(background);
    final double lighter = l1 > l2 ? l1 : l2;
    final double darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// 根据背景色自动选择白色或深色文字（确保 WCAG AA 4.5:1）。
  ///
  /// 当白色文字在给定背景上的对比度 >= 4.5 时返回纯白，
  /// 否则返回 [textPrimary]（#0A2540，Stripe navy）。
  Color textOnColor(Color background) {
    return contrastRatio(const Color(0xFFFFFFFF), background) >= 4.5
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0A2540);
  }

  /// 计算颜色的相对亮度（WCAG 2.1 定义）。
  static double _relativeLuminance(Color color) {
    final double r = _linearize(color.r);
    final double g = _linearize(color.g);
    final double b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// 对 sRGB 通道值做线性化转换（gamma 展开）。
  static double _linearize(double channel) {
    if (channel <= 0.03928) return channel / 12.92;
    return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkColors &&
          runtimeType == other.runtimeType &&
          brand == other.brand &&
          brandLight == other.brandLight &&
          brandDark == other.brandDark &&
          _listEquals(brandPalette, other.brandPalette) &&
          success == other.success &&
          successLight == other.successLight &&
          warning == other.warning &&
          warningLight == other.warningLight &&
          error == other.error &&
          errorLight == other.errorLight &&
          info == other.info &&
          infoLight == other.infoLight &&
          textPrimary == other.textPrimary &&
          textSecondary == other.textSecondary &&
          textPlaceholder == other.textPlaceholder &&
          textDisabled == other.textDisabled &&
          textOnBrand == other.textOnBrand &&
          border == other.border &&
          borderLight == other.borderLight &&
          divider == other.divider &&
          background == other.background &&
          surface == other.surface &&
          overlay == other.overlay &&
          disabledBg == other.disabledBg;

  @override
  int get hashCode => Object.hashAll([
        brand,
        brandLight,
        brandDark,
        ...brandPalette,
        success,
        successLight,
        warning,
        warningLight,
        error,
        errorLight,
        info,
        infoLight,
        textPrimary,
        textSecondary,
        textPlaceholder,
        textDisabled,
        textOnBrand,
        border,
        borderLight,
        divider,
        background,
        surface,
        overlay,
        disabledBg,
      ]);

  /// 比较两个 Color 列表的元素逐一相等。
  static bool _listEquals(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
