// ParkGrid - 网格布局组件
//
// 支持等分和自适应两种模式，可配置列数、间距、分割线等。
// 纯自定义实现，不依赖 Flutter Material/Cupertino 组件。

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 网格模式
enum ParkGridMode {
  /// 等分模式：每行固定列数，每个格子等宽
  equal,

  /// 自适应模式：根据 flex 属性动态分配宽度
  auto,
}

/// 网格项垂直对齐方式
enum ParkGridAlign {
  /// 顶部对齐
  start,

  /// 居中对齐
  center,

  /// 底部对齐
  end,

  /// 拉伸填充
  stretch,
}

/// 网格项
class ParkGridItem {
  /// 唯一标识
  final String? key;

  /// 标题文本
  final String? label;

  /// 自定义内容构建器（优先级高于 label）
  final WidgetBuilder? builder;

  /// 图标
  final IconData? icon;

  /// 角标文本
  final String? badge;

  /// 是否禁用
  final bool disabled;

  /// 自适应模式下的弹性系数
  final int flex;

  const ParkGridItem({
    this.key,
    this.label,
    this.builder,
    this.icon,
    this.badge,
    this.disabled = false,
    this.flex = 1,
  });
}

/// ParkGrid 网格布局组件
///
/// 支持等分（equal）和自适应（auto）两种布局模式。
/// 每行显示 [columnCount] 个格子（auto 模式下按 flex 分配宽度）。
class ParkGrid extends StatelessWidget {
  /// 列数
  final int columnCount;

  /// 网格项列表
  final List<ParkGridItem> items;

  /// 布局模式
  final ParkGridMode mode;

  /// 点击回调
  final ValueChanged<int>? onTap;

  /// 行间距
  final double? rowSpacing;

  /// 列间距
  final double? columnSpacing;

  /// 统一间距（同时设置行和列）
  final double? spacing;

  /// 是否显示边框
  final bool bordered;

  /// 是否显示分割线
  final bool divider;

  /// 每个格子的高度
  final double? itemHeight;

  /// 背景色
  final Color? backgroundColor;

  /// Vertical alignment of grid items within each cell.
  final ParkGridAlign align;

  const ParkGrid({
    super.key,
    required this.columnCount,
    required this.items,
    this.mode = ParkGridMode.equal,
    this.onTap,
    this.rowSpacing,
    this.columnSpacing,
    this.spacing,
    this.bordered = false,
    this.divider = false,
    this.itemHeight,
    this.backgroundColor,
    this.align = ParkGridAlign.start,
    // 注意：不做构造期 assert，columnCount<=0 由 build 内运行时兜底为 1 列
    // （release 下 assert 被裁剪会导致行为不一致）。
  });

  double get _rowSpacing => rowSpacing ?? spacing ?? 0.0;
  double get _columnSpacing => columnSpacing ?? spacing ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final parkTheme = Theme.of(context).extension<ParkThemeData>();
    final bgColor = backgroundColor ??
        parkTheme?.colors.surface ??
        Theme.of(context).colorScheme.surface;

    // 将 items 按 columnCount 分组
    // 边界防御：columnCount<=0 时（release 下 assert 被裁剪）会导致死循环或负索引，
    // 这里运行时兜底为 1 列。
    final int cols = columnCount > 0 ? columnCount : 1;
    final rows = <List<ParkGridItem>>[];
    for (var i = 0; i < items.length; i += cols) {
      final end = (i + cols > items.length) ? items.length : i + cols;
      rows.add(items.sublist(i, end));
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: bordered
            ? Border.all(
                color: parkTheme?.colors.border ??
                    Theme.of(context).dividerColor,
                width: 0.5,
              )
            : null,
        borderRadius: bordered
            ? parkTheme?.radius.brMd ?? BorderRadius.circular(8)
            : null,
      ),
      clipBehavior: bordered ? Clip.antiAlias : Clip.none,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var rowIdx = 0; rowIdx < rows.length; rowIdx++) ...[
            if (rowIdx > 0 && (_rowSpacing > 0 || divider))
              if (divider)
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: parkTheme?.colors.divider ?? Theme.of(context).dividerColor,
                )
              else
                SizedBox(height: _rowSpacing),
            _buildRow(context, rows[rowIdx], rowIdx),
          ],
        ],
      ),
    );
  }

  CrossAxisAlignment get _crossAxisAlignment {
    switch (align) {
      case ParkGridAlign.start:
        return CrossAxisAlignment.start;
      case ParkGridAlign.center:
        return CrossAxisAlignment.center;
      case ParkGridAlign.end:
        return CrossAxisAlignment.end;
      case ParkGridAlign.stretch:
        return CrossAxisAlignment.stretch;
    }
  }

  Widget _buildRow(BuildContext context, List<ParkGridItem> rowItems, int rowIdx) {
    if (mode == ParkGridMode.equal) {
      return Row(
        crossAxisAlignment: _crossAxisAlignment,
        children: [
          for (var i = 0; i < rowItems.length; i++) ...[
            if (i > 0 && _columnSpacing > 0)
              SizedBox(width: _columnSpacing),
            Expanded(
              child: _buildCell(context, rowIdx * columnCount + i, rowItems[i]),
            ),
          ],
          // 填充空位
          for (var i = rowItems.length; i < columnCount; i++) ...[
            if (i > 0 && _columnSpacing > 0)
              SizedBox(width: _columnSpacing),
            const Expanded(child: SizedBox.shrink()),
          ],
        ],
      );
    } else {
      // auto 模式：按 flex 分配宽度
      return Row(
        crossAxisAlignment: _crossAxisAlignment,
        children: [
          for (var i = 0; i < rowItems.length; i++) ...[
            if (i > 0 && _columnSpacing > 0)
              SizedBox(width: _columnSpacing),
            Expanded(
              flex: rowItems[i].flex,
              child: _buildCell(context, rowIdx * columnCount + i, rowItems[i]),
            ),
          ],
        ],
      );
    }
  }

  Widget _buildCell(BuildContext context, int index, ParkGridItem item) {
    Widget child;
    if (item.builder != null) {
      child = item.builder!(context);
    } else {
      child = _buildDefaultContent(context, item);
    }

    final cell = Container(
      height: itemHeight ?? 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: child,
    );

    if (item.disabled) {
      return Opacity(
        opacity: 0.4,
        child: cell,
      );
    }

    final bool isInteractive = onTap != null && !item.disabled;
    final Widget cellWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap != null ? () => onTap!(index) : null,
      child: cell,
    );

    if (isInteractive) {
      return Semantics(
        button: true,
        label: item.label,
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  Widget _buildDefaultContent(BuildContext context, ParkGridItem item) {
    final parkTheme = Theme.of(context).extension<ParkThemeData>();

    if (item.icon != null) {
      return _buildIconWithBadge(context, item);
    }

    if (item.label != null) {
      return Text(
        item.label!,
        style: TextStyle(
          fontSize: parkTheme?.typography.sizeBodySmall ??
              ParkThemeData.light().typography.sizeBodySmall,
          color: parkTheme?.colors.textPrimary ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildIconWithBadge(BuildContext context, ParkGridItem item) {
    final parkTheme = Theme.of(context).extension<ParkThemeData>();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: item.label,
              child: Icon(
                item.icon,
                size: 24,
                color: parkTheme?.colors.textPrimary ?? Theme.of(context).iconTheme.color,
              ),
            ),
            if (item.label != null) ...[
              const SizedBox(height: 4),
              Text(
                item.label!,
                style: TextStyle(
                  fontSize: 12,
                  color: parkTheme?.colors.textSecondary ??
                      Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        if (item.badge != null)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: parkTheme?.colors.error ?? Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                item.badge!,
                style: TextStyle(
                  fontSize: 10,
                  color: parkTheme?.colors.textOnBrand ?? Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
