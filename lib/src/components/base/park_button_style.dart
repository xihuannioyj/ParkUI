import 'package:flutter/material.dart';

/// Park 按钮变体
enum ParkButtonVariant {
  /// 主要按钮 — 实心填充品牌色
  primary,

  /// 默认按钮 — 白底 + 边框
  secondary,

  /// 文字按钮 — 无边框无背景
  text,

  /// 链接按钮 — 无边框，品牌色文字，带下划线
  link,

  /// 幽灵按钮 — 透明底 + 边框
  ghost,

  /// 危险按钮 — 实心填充错误色
  danger,

  /// 填充按钮 — 微妙背景色，无边框（比 secondary 更低调）
  filled,

  /// 浅色按钮 — 品牌色调浅底，无边框
  light,
}

/// Park 按钮尺寸
enum ParkButtonSize {
  /// 小号 — 28px 高，适合紧凑场景
  small,

  /// 中号 — 36px 高，默认尺寸
  medium,

  /// 大号 — 44px 高，适合主要操作
  large,
}

/// Park 按钮形状
enum ParkButtonShape {
  /// 矩形（带圆角）
  rectangle,

  /// 圆角胶囊
  round,

  /// 圆形（仅用于 icon-only 按钮）
  circle,
}

/// Park 按钮样式配置
///
/// 集中管理按钮的所有外观属性，便于统一调整和复用。
@immutable
class ParkButtonStyle {
  /// 背景色
  final Color? backgroundColor;

  /// 前景色（文字 + 图标）
  final Color? foregroundColor;

  /// 边框色
  final Color? borderColor;

  /// 边框宽度
  final double? borderWidth;

  /// 圆角半径
  final double? borderRadius;

  /// 字号
  final double? fontSize;

  /// 字重
  final FontWeight? fontWeight;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 最小宽度
  final double? minWidth;

  /// 高度
  final double? height;

  /// 禁用时透明度
  final double disabledOpacity;

  /// 阴影
  final List<BoxShadow>? elevation;

  const ParkButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.minWidth,
    this.height,
    this.disabledOpacity = 0.4,
    this.elevation,
  });

  ParkButtonStyle copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    double? fontSize,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
    double? minWidth,
    double? height,
    double? disabledOpacity,
    List<BoxShadow>? elevation,
  }) {
    return ParkButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      padding: padding ?? this.padding,
      minWidth: minWidth ?? this.minWidth,
      height: height ?? this.height,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      elevation: elevation ?? this.elevation,
    );
  }
}

/// Park 按钮 HTML 类型（主要用于 Web 表单语义）
enum ParkButtonHtmlType {
  /// 普通按钮
  button,

  /// 提交按钮
  submit,

  /// 重置按钮
  reset,
}
