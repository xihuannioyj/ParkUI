import 'package:flutter/material.dart';

/// 间距组件 — 统一控制子元素之间的间距。
///
/// 替代手动在 children 之间添加 [SizedBox] 或 [Padding]。
/// 支持水平、垂直和自动换行三种模式。
///
/// ```dart
/// // 水平 16px 间距
/// ParkSpace(
///   size: 16,
///   children: [Text('A'), Text('B'), Text('C')],
/// )
///
/// // 垂直 8px 间距
/// ParkSpace(
///   direction: Axis.vertical,
///   size: 8,
///   children: [Text('A'), Text('B')],
/// )
///
/// // 自动换行
/// ParkSpace(
///   wrap: true,
///   size: 12,
///   children: [chip1, chip2, chip3, chip4],
/// )
/// ```
class ParkSpace extends StatelessWidget {
  /// 子元素列表。
  final List<Widget> children;

  /// 间距大小（默认 8px）。
  final double size;

  /// 排列方向（默认水平）。
  final Axis direction;

  /// 是否自动换行（仅水平方向有效）。
  final bool wrap;

  /// 主轴对齐方式。
  final MainAxisAlignment mainAxisAlignment;

  /// 交叉轴对齐方式。
  final CrossAxisAlignment crossAxisAlignment;

  /// 创建 [ParkSpace]。
  const ParkSpace({
    super.key,
    required this.children,
    this.size = 8,
    this.direction = Axis.horizontal,
    this.wrap = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// 水平 4px 间距。
  factory ParkSpace.xs({required List<Widget> children, Axis dir = Axis.horizontal, bool wrap = false}) =>
      ParkSpace(children: children, size: 4, direction: dir, wrap: wrap);

  /// 水平 8px 间距。
  factory ParkSpace.sm({required List<Widget> children, Axis dir = Axis.horizontal, bool wrap = false}) =>
      ParkSpace(children: children, size: 8, direction: dir, wrap: wrap);

  /// 水平 16px 间距。
  factory ParkSpace.md({required List<Widget> children, Axis dir = Axis.horizontal, bool wrap = false}) =>
      ParkSpace(children: children, size: 16, direction: dir, wrap: wrap);

  /// 水平 24px 间距。
  factory ParkSpace.lg({required List<Widget> children, Axis dir = Axis.horizontal, bool wrap = false}) =>
      ParkSpace(children: children, size: 24, direction: dir, wrap: wrap);

  /// 水平 32px 间距。
  factory ParkSpace.xl({required List<Widget> children, Axis dir = Axis.horizontal, bool wrap = false}) =>
      ParkSpace(children: children, size: 32, direction: dir, wrap: wrap);

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _insertSpacers(children),
      );
    }

    if (wrap) {
      return Wrap(
        spacing: size,
        runSpacing: size,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _insertSpacers(children),
    );
  }

  List<Widget> _insertSpacers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(
          width: direction == Axis.horizontal ? size : 0,
          height: direction == Axis.vertical ? size : 0,
        ));
      }
    }
    return result;
  }
}
