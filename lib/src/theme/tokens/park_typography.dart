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

  // ========================================================================
  // 字体族
  // ========================================================================

  /// 默认字体族（null 使用系统默认）
  final String? fontFamily;

  const ParkTypography({
    this.sizeDisplay = 34.0,
    this.sizeH1 = 28.0,
    this.sizeH2 = 22.0,
    this.sizeH3 = 18.0,
    this.sizeBody = 16.0,
    this.sizeBodySmall = 14.0,
    this.sizeCaption = 13.0,
    this.sizeOverline = 11.0,
    this.lineHeightTitle = 1.25,
    this.lineHeightBody = 1.5,
    this.weightBold = FontWeight.w600,
    this.weightRegular = FontWeight.w400,
    this.weightMedium = FontWeight.w500,
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
        letterSpacing: 0.5,
      );

  ParkTypography copyWith({
    double? sizeDisplay,
    double? sizeH1,
    double? sizeH2,
    double? sizeH3,
    double? sizeBody,
    double? sizeBodySmall,
    double? sizeCaption,
    double? sizeOverline,
    double? lineHeightTitle,
    double? lineHeightBody,
    FontWeight? weightBold,
    FontWeight? weightRegular,
    FontWeight? weightMedium,
    String? fontFamily,
  }) {
    return ParkTypography(
      sizeDisplay: sizeDisplay ?? this.sizeDisplay,
      sizeH1: sizeH1 ?? this.sizeH1,
      sizeH2: sizeH2 ?? this.sizeH2,
      sizeH3: sizeH3 ?? this.sizeH3,
      sizeBody: sizeBody ?? this.sizeBody,
      sizeBodySmall: sizeBodySmall ?? this.sizeBodySmall,
      sizeCaption: sizeCaption ?? this.sizeCaption,
      sizeOverline: sizeOverline ?? this.sizeOverline,
      lineHeightTitle: lineHeightTitle ?? this.lineHeightTitle,
      lineHeightBody: lineHeightBody ?? this.lineHeightBody,
      weightBold: weightBold ?? this.weightBold,
      weightRegular: weightRegular ?? this.weightRegular,
      weightMedium: weightMedium ?? this.weightMedium,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
