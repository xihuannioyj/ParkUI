import 'package:flutter/material.dart';
import '../components/base/park_icon_size.dart';

/// Park 图标主题数据。
///
/// 全局控制图标的默认颜色、尺寸覆盖等。
/// 通过 [ParkThemeData.iconTheme] 注入。
@immutable
class ParkIconThemeData {
  /// 全局默认图标颜色。
  /// [ParkIcon] 的 color 为 null 时，先查此值；此值也为 null 时使用 [ParkColors.brand]。
  final Color? defaultColor;

  /// [ParkCell] 等组合组件中左图标默认颜色。
  /// null 时使用 [ParkThemeData.colors.brand]。
  final Color? cellIconColor;

  /// [ParkCell] 等组合组件中左图标尺寸（像素）。
  /// null 时使用组件默认图标尺寸（20px）。
  final double? cellIconSize;

  /// 覆盖内置 small 尺寸（默认 16px）。
  final double? smallSize;

  /// 覆盖内置 medium 尺寸（默认 20px）。
  final double? mediumSize;

  /// 覆盖内置 large 尺寸（默认 24px）。
  final double? largeSize;

  /// 覆盖内置 xlarge 尺寸（默认 32px）。
  final double? xlargeSize;

  const ParkIconThemeData({
    this.defaultColor,
    this.cellIconColor,
    this.cellIconSize,
    this.smallSize,
    this.mediumSize,
    this.largeSize,
    this.xlargeSize,
  });

  /// 按 [ParkIconSize] 获取覆盖后的像素值，无覆盖返回 null。
  double? sizeOverrideFor(ParkIconSize size) {
    switch (size) {
      case ParkIconSize.small:
        return smallSize;
      case ParkIconSize.medium:
        return mediumSize;
      case ParkIconSize.large:
        return largeSize;
      case ParkIconSize.xlarge:
        return xlargeSize;
    }
  }

  ParkIconThemeData merge(ParkIconThemeData? other) {
    if (other == null) return this;
    return ParkIconThemeData(
      defaultColor: other.defaultColor ?? defaultColor,
      cellIconColor: other.cellIconColor ?? cellIconColor,
      cellIconSize: other.cellIconSize ?? cellIconSize,
      smallSize: other.smallSize ?? smallSize,
      mediumSize: other.mediumSize ?? mediumSize,
      largeSize: other.largeSize ?? largeSize,
      xlargeSize: other.xlargeSize ?? xlargeSize,
    );
  }

  ParkIconThemeData copyWith({
    Color? defaultColor,
    Color? cellIconColor,
    double? cellIconSize,
    double? smallSize,
    double? mediumSize,
    double? largeSize,
    double? xlargeSize,
  }) {
    return ParkIconThemeData(
      defaultColor: defaultColor ?? this.defaultColor,
      cellIconColor: cellIconColor ?? this.cellIconColor,
      cellIconSize: cellIconSize ?? this.cellIconSize,
      smallSize: smallSize ?? this.smallSize,
      mediumSize: mediumSize ?? this.mediumSize,
      largeSize: largeSize ?? this.largeSize,
      xlargeSize: xlargeSize ?? this.xlargeSize,
    );
  }
}
