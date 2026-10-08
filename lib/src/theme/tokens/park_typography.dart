import 'package:flutter/material.dart';

/// Park UI 字体令牌
///
/// 提供完整的字体排版体系，包含字号、行高、字重的预设组合。
/// 默认使用系统字体栈，不强制加载自定义字体文件。
@immutable
class ParkTypography {
  // ========================================================================
  // 字号 - 独立值
  // ========================================================================

  /// 超大标题
  final double sizeDisplay;

  /// 页面大标题
  ///
  /// 🔴 取值 **30.0**，刻意避开 28：28 已被 [sizeH1] 占用，若两值相同则
  /// `pageTitle` 与 `h1` 在视觉上无法区分，"语义分层"就失去意义。
  /// 34（display）→ 30（pageTitle）→ 28（h1）构成三级递减的标题梯度。
  final double sizePageTitle;

  /// 区块标题
  ///
  /// 取值 20.0，落在 [sizeH2]（22）与 [sizeH3]（18）之间，
  /// 为"卡片区块 / 分组标题"提供比 h3 更强的存在感又不越级到 h2。
  final double sizeSectionTitle;

  /// 一级标题
  final double sizeH1;

  /// 二级标题
  final double sizeH2;

  /// 三级标题
  final double sizeH3;

  /// 正文（默认）
  final double sizeBody;

  /// 小号正文
  final double sizeBodySmall;

  /// 辅助文字
  final double sizeCaption;

  /// 超小文字（标签、角标等）
  final double sizeOverline;

  // ========================================================================
  // 字符间距
  // ========================================================================

  /// Overline 字母间距（默认 0.5）
  final double letterSpacingOverline;

  // ========================================================================
  // 行高比例（行高 = 字号 × lineHeight）
  // ========================================================================

  /// 标题行高比例（紧凑）
  final double lineHeightTitle;

  /// 正文行高比例（宽松）
  final double lineHeightBody;

  // ========================================================================
  // 字重
  // ========================================================================

  /// 标题字重
  final FontWeight weightBold;

  /// 正文字重
  final FontWeight weightRegular;

  /// 中等字重（按钮、标签等）
  final FontWeight weightMedium;

  /// 轻字重（辅助文字、大字号装饰等）
  final FontWeight weightLight;

  // ========================================================================
  // 字体族
  // ========================================================================

  /// 默认字体族（null 使用系统默认）
  final String? fontFamily;

  const ParkTypography({
    this.sizeDisplay = 34.0,
    this.sizePageTitle = 30.0,
    this.sizeSectionTitle = 20.0,
    this.sizeH1 = 28.0,
    this.sizeH2 = 22.0,
    this.sizeH3 = 18.0,
    this.sizeBody = 16.0,
    this.sizeBodySmall = 14.0,
    this.sizeCaption = 13.0,
    this.sizeOverline = 11.0,
    this.letterSpacingOverline = 0.5,
    this.lineHeightTitle = 1.25,
    this.lineHeightBody = 1.5,
    this.weightBold = FontWeight.w600,
    this.weightRegular = FontWeight.w400,
    this.weightMedium = FontWeight.w500,
    this.weightLight = FontWeight.w300,
    this.fontFamily = 'Inter',
  });

  /// 默认字体令牌（中文优化）
  factory ParkTypography.defaults() {
    return const ParkTypography();
  }

  // ========================================================================
  // 便捷方法：生成预设 TextStyle
  // ========================================================================

  /// 超大标题样式
  TextStyle get display => TextStyle(
    fontSize: sizeDisplay,
    height: lineHeightTitle,
    fontWeight: weightBold,
    fontFamily: fontFamily,
  );

  /// 页面大标题样式
  ///
  /// 适用于页面顶部的主标题（比 [h1] 大、比 [display] 小）。
  TextStyle get pageTitle => TextStyle(
    fontSize: sizePageTitle,
    height: lineHeightTitle,
    fontWeight: weightBold,
    fontFamily: fontFamily,
  );

  /// 区块标题样式
  ///
  /// 适用于卡片区块 / 分组标题（比 [h3] 强、比 [h2] 弱）。
  TextStyle get sectionTitle => TextStyle(
    fontSize: sizeSectionTitle,
    height: lineHeightTitle,
    fontWeight: weightMedium,
    fontFamily: fontFamily,
  );

  /// 一级标题样式
  TextStyle get h1 => TextStyle(
    fontSize: sizeH1,
    height: lineHeightTitle,
    fontWeight: weightBold,
    fontFamily: fontFamily,
  );

  /// 二级标题样式
  TextStyle get h2 => TextStyle(
    fontSize: sizeH2,
    height: lineHeightTitle,
    fontWeight: weightBold,
    fontFamily: fontFamily,
  );

  /// 三级标题样式
  TextStyle get h3 => TextStyle(
    fontSize: sizeH3,
    height: lineHeightTitle,
    fontWeight: weightMedium,
    fontFamily: fontFamily,
  );

  /// 正文样式
  TextStyle get body => TextStyle(
    fontSize: sizeBody,
    height: lineHeightBody,
    fontWeight: weightRegular,
    fontFamily: fontFamily,
  );

  /// 小号正文样式
  TextStyle get bodySmall => TextStyle(
    fontSize: sizeBodySmall,
    height: lineHeightBody,
    fontWeight: weightRegular,
    fontFamily: fontFamily,
  );

  /// 辅助文字样式
  TextStyle get caption => TextStyle(
    fontSize: sizeCaption,
    height: lineHeightBody,
    fontWeight: weightRegular,
    fontFamily: fontFamily,
  );

  /// 超小文字样式
  TextStyle get overline => TextStyle(
    fontSize: sizeOverline,
    height: lineHeightTitle,
    fontWeight: weightMedium,
    fontFamily: fontFamily,
    letterSpacing: letterSpacingOverline,
  );

  /// 逐属性平滑插值。
  ///
  /// 数值字段（字号、行高、字距）做线性插值；
  /// 字重（FontWeight）通过 [FontWeight.lerp] 平滑过渡；
  /// 字体族（String）无法连续插值，在 t < 0.5 时使用 a。
  static ParkTypography lerp(ParkTypography a, ParkTypography b, double t) {
    return ParkTypography(
      sizeDisplay: a.sizeDisplay + (b.sizeDisplay - a.sizeDisplay) * t,
      sizePageTitle:
          a.sizePageTitle + (b.sizePageTitle - a.sizePageTitle) * t,
      sizeSectionTitle:
          a.sizeSectionTitle + (b.sizeSectionTitle - a.sizeSectionTitle) * t,
      sizeH1: a.sizeH1 + (b.sizeH1 - a.sizeH1) * t,
      sizeH2: a.sizeH2 + (b.sizeH2 - a.sizeH2) * t,
      sizeH3: a.sizeH3 + (b.sizeH3 - a.sizeH3) * t,
      sizeBody: a.sizeBody + (b.sizeBody - a.sizeBody) * t,
      sizeBodySmall: a.sizeBodySmall + (b.sizeBodySmall - a.sizeBodySmall) * t,
      sizeCaption: a.sizeCaption + (b.sizeCaption - a.sizeCaption) * t,
      sizeOverline: a.sizeOverline + (b.sizeOverline - a.sizeOverline) * t,
      letterSpacingOverline:
          a.letterSpacingOverline +
          (b.letterSpacingOverline - a.letterSpacingOverline) * t,
      lineHeightTitle:
          a.lineHeightTitle + (b.lineHeightTitle - a.lineHeightTitle) * t,
      lineHeightBody:
          a.lineHeightBody + (b.lineHeightBody - a.lineHeightBody) * t,
      weightBold: FontWeight.lerp(a.weightBold, b.weightBold, t) ?? a.weightBold,
      weightRegular: FontWeight.lerp(a.weightRegular, b.weightRegular, t) ?? a.weightRegular,
      weightMedium: FontWeight.lerp(a.weightMedium, b.weightMedium, t) ?? a.weightMedium,
      weightLight: FontWeight.lerp(a.weightLight, b.weightLight, t) ?? a.weightLight,
      fontFamily: t < 0.5 ? a.fontFamily : b.fontFamily,
    );
  }

  ParkTypography copyWith({
    double? sizeDisplay,
    double? sizePageTitle,
    double? sizeSectionTitle,
    double? sizeH1,
    double? sizeH2,
    double? sizeH3,
    double? sizeBody,
    double? sizeBodySmall,
    double? sizeCaption,
    double? sizeOverline,
    double? letterSpacingOverline,
    double? lineHeightTitle,
    double? lineHeightBody,
    FontWeight? weightBold,
    FontWeight? weightRegular,
    FontWeight? weightMedium,
    FontWeight? weightLight,
    String? fontFamily,
  }) {
    return ParkTypography(
      sizeDisplay: sizeDisplay ?? this.sizeDisplay,
      sizePageTitle: sizePageTitle ?? this.sizePageTitle,
      sizeSectionTitle: sizeSectionTitle ?? this.sizeSectionTitle,
      sizeH1: sizeH1 ?? this.sizeH1,
      sizeH2: sizeH2 ?? this.sizeH2,
      sizeH3: sizeH3 ?? this.sizeH3,
      sizeBody: sizeBody ?? this.sizeBody,
      sizeBodySmall: sizeBodySmall ?? this.sizeBodySmall,
      sizeCaption: sizeCaption ?? this.sizeCaption,
      sizeOverline: sizeOverline ?? this.sizeOverline,
      letterSpacingOverline:
          letterSpacingOverline ?? this.letterSpacingOverline,
      lineHeightTitle: lineHeightTitle ?? this.lineHeightTitle,
      lineHeightBody: lineHeightBody ?? this.lineHeightBody,
      weightBold: weightBold ?? this.weightBold,
      weightRegular: weightRegular ?? this.weightRegular,
      weightMedium: weightMedium ?? this.weightMedium,
      weightLight: weightLight ?? this.weightLight,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkTypography &&
          runtimeType == other.runtimeType &&
          sizeDisplay == other.sizeDisplay &&
          sizePageTitle == other.sizePageTitle &&
          sizeSectionTitle == other.sizeSectionTitle &&
          sizeH1 == other.sizeH1 &&
          sizeH2 == other.sizeH2 &&
          sizeH3 == other.sizeH3 &&
          sizeBody == other.sizeBody &&
          sizeBodySmall == other.sizeBodySmall &&
          sizeCaption == other.sizeCaption &&
          sizeOverline == other.sizeOverline &&
          letterSpacingOverline == other.letterSpacingOverline &&
          lineHeightTitle == other.lineHeightTitle &&
          lineHeightBody == other.lineHeightBody &&
          weightBold == other.weightBold &&
          weightRegular == other.weightRegular &&
          weightMedium == other.weightMedium &&
          weightLight == other.weightLight &&
          fontFamily == other.fontFamily;

  @override
  int get hashCode => Object.hash(
    sizeDisplay,
    sizePageTitle,
    sizeSectionTitle,
    sizeH1,
    sizeH2,
    sizeH3,
    sizeBody,
    sizeBodySmall,
    sizeCaption,
    sizeOverline,
    letterSpacingOverline,
    lineHeightTitle,
    lineHeightBody,
    weightBold,
    weightRegular,
    weightMedium,
    weightLight,
    fontFamily,
  );
}
