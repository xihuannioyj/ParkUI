import 'package:flutter/material.dart';

/// 弹性布局方向
enum ParkFlexDirection {
  /// 水平从左到右
  row,

  /// 水平从右到左
  rowReverse,

  /// 垂直从上到下
  column,

  /// 垂直从下到上
  columnReverse,
}

/// Park 弹性布局组件
///
/// 对标 Ant Design Flex，提供 Row / Column / Wrap 的一致性封装。
/// - 根据 [direction] 选择 Row / Column
/// - [gap] 通过 [SizedBox] 在子组件之间插入间距
/// - [wrap] 为 true 时使用 [Wrap] 替代 Row / Column
/// - [flexValues] 不为 null 时将每个 child 包裹在 [Expanded] 中
///
/// ```dart
/// ParkFlex(
///   direction: ParkFlexDirection.row,
///   gap: 16,
///   children: [Widget1(), Widget2(), Widget3()],
/// )
///
/// ParkFlex(
///   direction: ParkFlexDirection.column,
///   gap: 8,
///   children: [Widget1(), Widget2()],
/// )
///
/// ParkFlex(
///   wrap: true,
///   gap: 12,
///   children: [chip1, chip2, chip3, chip4],
/// )
///
/// ParkFlex(
///   flexValues: [1, 2, 1],
///   children: [Widget1(), Widget2(), Widget3()],
/// )
/// ```
class ParkFlex extends StatelessWidget {
  /// 布局方向
  final ParkFlexDirection direction;

  /// 主轴对齐方式
  final MainAxisAlignment justify;

  /// 交叉轴对齐方式
  final CrossAxisAlignment align;

  /// 是否换行（为 true 时使用 Wrap 替代 Row/Column）
  final bool wrap;

  /// 子组件之间的间距
  final double gap;

  /// 子组件列表
  final List<Widget> children;

  /// 每个子组件的 flex 值（长度须与 children 一致）
  ///
  /// 不为 null 时，每个 child 会被包裹在 Expanded(flex: value) 中。
  /// 注意：当 [wrap] 为 true 时，flexValues 无效（Wrap 不支持 Expanded）。
  final List<int>? flexValues;

  /// 换行时的行间距（仅 [wrap] 为 true 时有效）
  final double? runGap;

  const ParkFlex({
    super.key,
    this.direction = ParkFlexDirection.row,
    this.justify = MainAxisAlignment.start,
    this.align = CrossAxisAlignment.center,
    this.wrap = false,
    this.gap = 0,
    this.children = const [],
    this.flexValues,
    this.runGap,
  });

  /// 便捷构造：水平布局
  const ParkFlex.row({
    Key? key,
    MainAxisAlignment justify = MainAxisAlignment.start,
    CrossAxisAlignment align = CrossAxisAlignment.center,
    double gap = 0,
    List<Widget> children = const [],
    List<int>? flexValues,
  }) : this(
          key: key,
          direction: ParkFlexDirection.row,
          justify: justify,
          align: align,
          gap: gap,
          children: children,
          flexValues: flexValues,
        );

  /// 便捷构造：垂直布局
  const ParkFlex.column({
    Key? key,
    MainAxisAlignment justify = MainAxisAlignment.start,
    CrossAxisAlignment align = CrossAxisAlignment.center,
    double gap = 0,
    List<Widget> children = const [],
    List<int>? flexValues,
  }) : this(
          key: key,
          direction: ParkFlexDirection.column,
          justify: justify,
          align: align,
          gap: gap,
          children: children,
          flexValues: flexValues,
        );

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    // wrap 模式：使用 Wrap
    if (wrap) {
      return Wrap(
        direction: _isHorizontal ? Axis.horizontal : Axis.vertical,
        spacing: gap,
        runSpacing: runGap ?? gap,
        alignment: _wrapAlignment,
        crossAxisAlignment: _wrapCrossAlignment,
        children: children,
      );
    }

    // 非 wrap 模式：使用 Row 或 Column
    final items = _buildChildren();

    if (_isHorizontal) {
      return Row(
        mainAxisAlignment: justify,
        crossAxisAlignment: align,
        textDirection: _horizontalTextDirection,
        children: items,
      );
    } else {
      return Column(
        mainAxisAlignment: justify,
        crossAxisAlignment: align,
        verticalDirection: _verticalDirection,
        children: items,
      );
    }
  }

  bool get _isHorizontal =>
      direction == ParkFlexDirection.row ||
      direction == ParkFlexDirection.rowReverse;

  TextDirection? get _horizontalTextDirection {
    switch (direction) {
      case ParkFlexDirection.row:
        return TextDirection.ltr;
      case ParkFlexDirection.rowReverse:
        return TextDirection.rtl;
      case ParkFlexDirection.column:
      case ParkFlexDirection.columnReverse:
        return null;
    }
  }

  VerticalDirection get _verticalDirection {
    switch (direction) {
      case ParkFlexDirection.columnReverse:
        return VerticalDirection.up;
      case ParkFlexDirection.row:
      case ParkFlexDirection.rowReverse:
      case ParkFlexDirection.column:
        return VerticalDirection.down;
    }
  }

  /// 构建子组件列表（插入 gap 间距 + flex 包裹）
  List<Widget> _buildChildren() {
    final result = <Widget>[];
    final hasFlex = flexValues != null && flexValues!.length == children.length;

    for (var i = 0; i < children.length; i++) {
      Widget child = children[i];

      // 如果有 flexValues，包裹 Expanded
      if (hasFlex) {
        child = Expanded(flex: flexValues![i], child: child);
      }

      result.add(child);

      // 在子组件之间插入间距
      if (i < children.length - 1 && gap > 0) {
        result.add(
          _isHorizontal
              ? SizedBox(width: gap)
              : SizedBox(height: gap),
        );
      }
    }

    return result;
  }

  // Wrap alignment 映射
  WrapAlignment get _wrapAlignment {
    switch (justify) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  WrapCrossAlignment get _wrapCrossAlignment {
    switch (align) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        return WrapCrossAlignment.center;
    }
  }
}
