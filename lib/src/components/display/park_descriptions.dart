import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 描述列表的尺寸枚举。
///
/// 控制内边距和字体大小。
enum ParkDescriptionsSize {
  /// 紧凑模式 — 更小的内边距和字体。
  small,

  /// 默认尺寸。
  defaultSize,

  /// 宽松模式 — 更大的内边距和字体。
  large,
}

/// 描述列表的布局方向枚举。
enum ParkDescriptionsLayout {
  /// 水平布局：label 在左，value 在右。
  horizontal,

  /// 垂直布局：label 在上，value 在下。
  vertical,
}

/// 描述列表单项。
///
/// 用于 [ParkDescriptions] 中展示一组 label-value 对。
/// [value] 与 [valueWidget] 二选一，[valueWidget] 优先级更高。
class ParkDescriptionItem {
  /// 标签文本。
  final String label;

  /// 值文本（与 [valueWidget] 二选一）。
  final String? value;

  /// 自定义值 Widget（优先于 [value]）。
  final Widget? valueWidget;

  /// 跨列数，默认 1。span=2 表示横跨两列。
  final int span;

  /// 创建一个描述列表单项。
  const ParkDescriptionItem({
    required this.label,
    this.value,
    this.valueWidget,
    this.span = 1,
  });
}

/// 描述列表组件。
///
/// 用于只读详情页数据展示，对标 Ant Design `Descriptions` / TDesign `Descriptions`。
/// 支持 [bordered] 表格风格与简洁分隔线风格两种模式，
/// 可配置列数、标题、label 宽度、空值占位符与标题栏右侧操作。
///
/// ```dart
/// ParkDescriptions(
///   title: '订单详情',
///   column: 2,
///   bordered: true,
///   items: [
///     ParkDescriptionItem(label: '订单号', value: 'DD20260701001'),
///     ParkDescriptionItem(label: '状态', value: '已支付'),
///     ParkDescriptionItem(label: '收货地址', value: '北京市朝阳区', span: 2),
///   ],
/// )
/// ```
class ParkDescriptions extends StatelessWidget {
  /// 标题（可选）。
  final String? title;

  /// 列数（1/2/3，默认 1）。
  final int column;

  /// 是否显示边框（true=单元格边框 + label 灰底，false=简洁分隔线风格）。
  final bool bordered;

  /// 数据项列表。
  final List<ParkDescriptionItem> items;

  /// label 固定宽度（null=使用默认宽度 100）。仅 [layout] 为 [ParkDescriptionsLayout.horizontal] 时有效。
  final double? labelWidth;

  /// 空值占位符（默认 '—'）。
  final String emptyText;

  /// 标题栏右侧操作 Widget（如编辑按钮）。
  final Widget? action;

  /// 尺寸。控制内边距和字体大小。
  final ParkDescriptionsSize size;

  /// 布局方向。
  final ParkDescriptionsLayout layout;

  /// 创建一个描述列表组件。
  const ParkDescriptions({
    super.key,
    this.title,
    this.column = 1,
    this.bordered = false,
    required this.items,
    this.labelWidth,
    this.emptyText = '—',
    this.action,
    this.size = ParkDescriptionsSize.defaultSize,
    this.layout = ParkDescriptionsLayout.horizontal,
  });

  /// label 默认宽度（当 labelWidth 为 null 时使用）。
  static const double _defaultLabelWidth = 100.0;

  /// 依据尺寸返回水平内边距。
  static double _hPad(ParkDescriptionsSize s) {
    switch (s) {
      case ParkDescriptionsSize.small:
        return 8.0;
      case ParkDescriptionsSize.defaultSize:
        return 12.0;
      case ParkDescriptionsSize.large:
        return 16.0;
    }
  }

  /// 依据尺寸返回垂直内边距。
  static double _vPad(ParkDescriptionsSize s) {
    switch (s) {
      case ParkDescriptionsSize.small:
        return 5.0;
      case ParkDescriptionsSize.defaultSize:
        return 10.0;
      case ParkDescriptionsSize.large:
        return 14.0;
    }
  }

  /// 依据尺寸返回 label 字体大小。
  static double _labelFontSize(ParkDescriptionsSize s) {
    switch (s) {
      case ParkDescriptionsSize.small:
        return 12.0;
      case ParkDescriptionsSize.defaultSize:
        return 13.0;
      case ParkDescriptionsSize.large:
        return 14.0;
    }
  }

  /// 依据尺寸返回 value 字体大小。
  static double _valueFontSize(ParkDescriptionsSize s) {
    switch (s) {
      case ParkDescriptionsSize.small:
        return 12.0;
      case ParkDescriptionsSize.defaultSize:
        return 13.0;
      case ParkDescriptionsSize.large:
        return 14.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final cols = column.clamp(1, 3);

    // 将 items 按列数和 span 分组为行
    final rows = _groupIntoRows(items, cols);

    return Semantics(
      container: true,
      label: title,
      child: Container(
        decoration: BoxDecoration(
          color: park.colors.surface,
          borderRadius: BorderRadius.circular(park.radius.sm),
          border: Border.all(color: park.colors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) _buildTitleBar(park),
            if (bordered)
              _buildBorderedRows(rows, park, cols)
            else
              _buildBorderlessRows(rows, park),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 行分组逻辑
  // ===========================================================================

  /// 将 [items] 按 [cols] 列数和每项的 span 分组为行。
  List<List<_RowItem>> _groupIntoRows(
      List<ParkDescriptionItem> items, int cols) {
    final rows = <List<_RowItem>>[];
    var currentRow = <_RowItem>[];
    var usedSpan = 0;

    for (final item in items) {
      final span = item.span.clamp(1, cols);

      // 当前行放不下时，先关闭当前行
      if (usedSpan + span > cols && currentRow.isNotEmpty) {
        rows.add(currentRow);
        currentRow = <_RowItem>[];
        usedSpan = 0;
      }

      currentRow.add(_RowItem(item: item, span: span));
      usedSpan += span;

      // 当前行已满
      if (usedSpan >= cols) {
        rows.add(currentRow);
        currentRow = <_RowItem>[];
        usedSpan = 0;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }

  // ===========================================================================
  // 标题栏
  // ===========================================================================

  /// 构建标题栏。
  Widget _buildTitleBar(ParkThemeData park) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(size),
        vertical: _vPad(size),
      ),
      decoration: BoxDecoration(
        color: park.colors.background,
        border: Border(
          bottom: BorderSide(color: park.colors.border, width: 0.5),
        ),
      ),
      child: Semantics(
        header: true,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: park.typography.sizeBody,
                  fontWeight: park.typography.weightMedium,
                  color: park.colors.textPrimary,
                  fontFamily: park.typography.fontFamily,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // bordered=true 模式（表格风格）
  // ===========================================================================

  /// 构建表格风格的多行。
  Widget _buildBorderedRows(
      List<List<_RowItem>> rows, ParkThemeData park, int cols) {
    if (layout == ParkDescriptionsLayout.vertical) {
      return _buildBorderedVerticalRows(rows, park, cols);
    }
    return _buildBorderedHorizontalRows(rows, park, cols);
  }

  /// 构建表格风格（水平布局）的多行。
  Widget _buildBorderedHorizontalRows(
      List<List<_RowItem>> rows, ParkThemeData park, int cols) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++)
          _buildBorderedHorizontalRow(rows[i], park, cols,
              isLastRow: i == rows.length - 1),
      ],
    );
  }

  /// 构建表格风格（垂直布局）的多行。
  ///
  /// 每组数据行渲染为两行：label 行（灰底）+ value 行。
  Widget _buildBorderedVerticalRows(
      List<List<_RowItem>> rows, ParkThemeData park, int cols) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          // label 行
          _buildBorderedVerticalLabelRow(rows[i], park, cols,
              isLastDataRow: i == rows.length - 1),
          // value 行
          _buildBorderedVerticalValueRow(rows[i], park, cols,
              isLastDataRow: i == rows.length - 1),
        ],
      ],
    );
  }

  /// 构建表格风格（水平布局）的单行。
  Widget _buildBorderedHorizontalRow(
      List<_RowItem> rowItems, ParkThemeData park, int cols,
      {required bool isLastRow}) {
    final cells = <Widget>[];
    final usedSpan = rowItems.fold(0, (sum, ri) => sum + ri.span);

    for (var i = 0; i < rowItems.length; i++) {
      final rowItem = rowItems[i];
      final isLastInRow = i == rowItems.length - 1 && usedSpan >= cols;

      // label 单元格
      cells.add(
        _buildBorderedLabelCell(
          rowItem.item,
          park,
          isLastInRow: false,
          isLastRow: isLastRow,
        ),
      );

      // value 单元格
      cells.add(
        _buildBorderedValueCell(
          rowItem.item,
          park,
          span: rowItem.span,
          isLastInRow: isLastInRow,
          isLastRow: isLastRow,
        ),
      );
    }

    // 填充剩余空列（保持网格完整）
    final remainingSpan = cols - usedSpan;
    if (remainingSpan > 0) {
      cells.add(
        _buildBorderedEmptyLabelCell(
          park,
          isLastRow: isLastRow,
        ),
      );
      cells.add(
        Expanded(
          flex: remainingSpan,
          child: _buildBorderedEmptyValueCell(
            park,
            isLastInRow: true,
            isLastRow: isLastRow,
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    );
  }

  /// 构建表格风格（垂直布局）的 label 行。
  Widget _buildBorderedVerticalLabelRow(
      List<_RowItem> rowItems, ParkThemeData park, int cols,
      {required bool isLastDataRow}) {
    final cells = <Widget>[];
    final usedSpan = rowItems.fold(0, (sum, ri) => sum + ri.span);

    for (var i = 0; i < rowItems.length; i++) {
      final rowItem = rowItems[i];
      final isLastInRow = i == rowItems.length - 1 && usedSpan >= cols;

      cells.add(
        Expanded(
          flex: rowItem.span,
          child: _buildBorderedVerticalLabelCell(
            rowItem.item,
            park,
            isLastInRow: isLastInRow,
            isLastRow: isLastDataRow,
          ),
        ),
      );
    }

    // 填充剩余空列
    final remainingSpan = cols - usedSpan;
    if (remainingSpan > 0) {
      cells.add(
        Expanded(
          flex: remainingSpan,
          child: _buildBorderedEmptyLabelCell(
            park,
            isLastRow: isLastDataRow,
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    );
  }

  /// 构建表格风格（垂直布局）的 value 行。
  Widget _buildBorderedVerticalValueRow(
      List<_RowItem> rowItems, ParkThemeData park, int cols,
      {required bool isLastDataRow}) {
    final cells = <Widget>[];
    final usedSpan = rowItems.fold(0, (sum, ri) => sum + ri.span);

    for (var i = 0; i < rowItems.length; i++) {
      final rowItem = rowItems[i];
      final isLastInRow = i == rowItems.length - 1 && usedSpan >= cols;

      cells.add(
        Expanded(
          flex: rowItem.span,
          child: _buildBorderedVerticalValueCell(
            rowItem.item,
            park,
            isLastInRow: isLastInRow,
            isLastRow: isLastDataRow,
          ),
        ),
      );
    }

    // 填充剩余空列
    final remainingSpan = cols - usedSpan;
    if (remainingSpan > 0) {
      cells.add(
        Expanded(
          flex: remainingSpan,
          child: _buildBorderedEmptyValueCell(
            park,
            isLastInRow: true,
            isLastRow: isLastDataRow,
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells,
      ),
    );
  }

  /// 构建表格风格的 label 单元格。
  Widget _buildBorderedLabelCell(
      ParkDescriptionItem item, ParkThemeData park,
      {required bool isLastInRow, required bool isLastRow}) {
    final width = labelWidth ?? _defaultLabelWidth;
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(size),
        vertical: _vPad(size),
      ),
      decoration: BoxDecoration(
        color: park.colors.background,
        border: Border(
          right: BorderSide(color: park.colors.border, width: 0.5),
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: '${item.label}',
        child: Text(
          item.label,
          style: TextStyle(
            fontSize: _labelFontSize(size),
            fontWeight: park.typography.weightRegular,
            color: park.colors.textSecondary,
            fontFamily: park.typography.fontFamily,
          ),
        ),
      ),
    );
  }

  /// 构建表格风格的 value 单元格。
  Widget _buildBorderedValueCell(
      ParkDescriptionItem item, ParkThemeData park,
      {required int span, required bool isLastInRow, required bool isLastRow}) {
    return Expanded(
      flex: span,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _hPad(size),
          vertical: _vPad(size),
        ),
        decoration: BoxDecoration(
          border: Border(
            right: isLastInRow
                ? BorderSide.none
                : BorderSide(color: park.colors.border, width: 0.5),
            bottom: isLastRow
                ? BorderSide.none
                : BorderSide(color: park.colors.border, width: 0.5),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: _buildValueWidget(item, park),
      ),
    );
  }

  /// 构建表格风格（垂直布局）的 label 单元格。
  Widget _buildBorderedVerticalLabelCell(
      ParkDescriptionItem item, ParkThemeData park,
      {required bool isLastInRow, required bool isLastRow}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(size),
        vertical: _vPad(size),
      ),
      decoration: BoxDecoration(
        color: park.colors.background,
        border: Border(
          right: isLastInRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
          bottom: BorderSide(color: park.colors.border, width: 0.5),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: '${item.label}',
        child: Text(
          item.label,
          style: TextStyle(
            fontSize: _labelFontSize(size),
            fontWeight: park.typography.weightRegular,
            color: park.colors.textSecondary,
            fontFamily: park.typography.fontFamily,
          ),
        ),
      ),
    );
  }

  /// 构建表格风格（垂直布局）的 value 单元格。
  Widget _buildBorderedVerticalValueCell(
      ParkDescriptionItem item, ParkThemeData park,
      {required bool isLastInRow, required bool isLastRow}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(size),
        vertical: _vPad(size),
      ),
      decoration: BoxDecoration(
        border: Border(
          right: isLastInRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: _buildValueWidget(item, park),
    );
  }

  /// 构建表格风格的空白 label 单元格（用于填充不完整行）。
  Widget _buildBorderedEmptyLabelCell(ParkThemeData park,
      {required bool isLastRow}) {
    final width = labelWidth ?? _defaultLabelWidth;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: park.colors.background,
        border: Border(
          right: BorderSide(color: park.colors.border, width: 0.5),
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
        ),
      ),
    );
  }

  /// 构建表格风格的空白 value 单元格（用于填充不完整行）。
  Widget _buildBorderedEmptyValueCell(ParkThemeData park,
      {required bool isLastInRow, required bool isLastRow}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: isLastInRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(color: park.colors.border, width: 0.5),
        ),
      ),
    );
  }

  // ===========================================================================
  // bordered=false 模式（分隔线风格）
  // ===========================================================================

  /// 构建分隔线风格的多行。
  Widget _buildBorderlessRows(List<List<_RowItem>> rows, ParkThemeData park) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Container(
              height: 0.5,
              color: park.colors.divider,
            ),
          _buildBorderlessRow(rows[i], park),
        ],
      ],
    );
  }

  /// 构建分隔线风格的单行。
  Widget _buildBorderlessRow(List<_RowItem> rowItems, ParkThemeData park) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(size),
        vertical: _vPad(size),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rowItems.length; i++) ...[
            if (i > 0) SizedBox(width: park.spacing.lg),
            Expanded(
              flex: rowItems[i].span,
              child: (layout == ParkDescriptionsLayout.vertical)
                  ? _buildBorderlessVerticalItem(rowItems[i].item, park)
                  : _buildBorderlessPair(rowItems[i].item, park),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建分隔线风格的 label:value 对（水平布局）。
  Widget _buildBorderlessPair(ParkDescriptionItem item, ParkThemeData park) {
    final width = labelWidth ?? _defaultLabelWidth;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Semantics(
            label: '${item.label}',
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: _labelFontSize(size),
                fontWeight: park.typography.weightRegular,
                color: park.colors.textSecondary,
                fontFamily: park.typography.fontFamily,
              ),
            ),
          ),
        ),
        SizedBox(width: park.spacing.sm),
        Expanded(
          child: _buildValueWidget(item, park),
        ),
      ],
    );
  }

  /// 构建分隔线风格的垂直项（label 在上，value 在下）。
  Widget _buildBorderlessVerticalItem(
      ParkDescriptionItem item, ParkThemeData park) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${item.label}',
          child: Text(
            item.label,
            style: TextStyle(
              fontSize: _labelFontSize(size),
              fontWeight: park.typography.weightRegular,
              color: park.colors.textSecondary,
              fontFamily: park.typography.fontFamily,
            ),
          ),
        ),
        SizedBox(height: park.spacing.xxs),
        _buildValueWidget(item, park),
      ],
    );
  }

  // ===========================================================================
  // 值渲染
  // ===========================================================================

  /// 构建值 Widget，处理空值占位与自定义 Widget。
  Widget _buildValueWidget(ParkDescriptionItem item, ParkThemeData park) {
    // valueWidget 优先级最高
    if (item.valueWidget != null) {
      return item.valueWidget!;
    }

    final value = item.value;
    final isEmpty = value == null || value.isEmpty;

    if (isEmpty) {
      return Semantics(
        label: '空',
        child: Text(
          emptyText,
          style: TextStyle(
            fontSize: _valueFontSize(size),
            fontWeight: park.typography.weightRegular,
            color: park.colors.textPlaceholder,
            fontFamily: park.typography.fontFamily,
          ),
        ),
      );
    }

    return Text(
      value,
      style: TextStyle(
        fontSize: _valueFontSize(size),
        fontWeight: park.typography.weightRegular,
        color: park.colors.textPrimary,
        fontFamily: park.typography.fontFamily,
      ),
    );
  }
}

/// 内部行项：包装 [ParkDescriptionItem] 与 clamp 后的实际 span。
class _RowItem {
  final ParkDescriptionItem item;
  final int span;

  const _RowItem({required this.item, required this.span});
}
