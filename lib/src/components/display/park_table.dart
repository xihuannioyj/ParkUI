import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import 'park_empty.dart';

/// Park 表格列对齐方式
enum ParkTableColumnAlign {
  left,
  center,
  right,
}

/// Park 表格尺寸
enum ParkTableSize { small, medium, large }

/// Park 行选择类型
enum ParkRowSelectionType { checkbox, radio }

/// Park 列固定位置
enum ParkColumnFixed { left, right, none }

/// Park 表格列定义
class ParkTableColumn {
  /// 列键名（对应 data Map 中的 key）
  final String key;

  /// 列标题
  final String title;

  /// 列宽（null 则自动分配）
  final double? width;

  /// 对齐方式
  final ParkTableColumnAlign align;

  /// 是否可排序
  final bool sortable;

  /// 自定义单元格渲染器（优先级高于默认文本渲染）
  final Widget Function(dynamic row, int rowIndex)? render;

  /// 列固定位置（左固定、右固定、不固定）
  final ParkColumnFixed fixed;

  /// 是否截断文本并显示省略号
  final bool ellipsis;

  /// 是否在文本溢出时显示 tooltip
  final bool tooltip;

  const ParkTableColumn({
    required this.key,
    required this.title,
    this.width,
    this.align = ParkTableColumnAlign.left,
    this.sortable = false,
    this.render,
    this.fixed = ParkColumnFixed.none,
    this.ellipsis = true,
    this.tooltip = false,
  });
}

/// Park 行选择配置
///
/// 用于表格的行选择功能，支持 checkbox（多选）和 radio（单选）模式。
class ParkRowSelection {
  /// 选择类型：多选或单选
  final ParkRowSelectionType type;

  /// 当前已选中的行 key 列表
  final List<String> selectedRowKeys;

  /// 选择变更回调
  final void Function(List<String> selectedKeys, List<dynamic> selectedRows)? onChanged;

  /// 判断某行 checkbox 是否禁用
  final bool Function(String key)? getCheckboxDisabled;

  const ParkRowSelection({
    this.type = ParkRowSelectionType.checkbox,
    this.selectedRowKeys = const [],
    this.onChanged,
    this.getCheckboxDisabled,
  });
}

/// Park 表格分页配置
///
/// 用于表格底部分页栏，控制当前页、每页条数和总数。
class ParkTablePagination {
  /// 当前页码（从 1 开始）
  final int current;

  /// 每页条数
  final int pageSize;

  /// 数据总条数
  final int total;

  /// 页码变更回调
  final void Function(int page, int pageSize)? onPageChanged;

  const ParkTablePagination({
    this.current = 1,
    this.pageSize = 10,
    this.total = 0,
    this.onPageChanged,
  });
}

// ParkTablePagination is now the standalone pagination widget in navigation/.
// Use ParkTablePagination for ParkTable's pagination parameter.

/// Park 数据表格组件
///
/// 支持排序、边框、斑马纹、空状态与加载态，
/// 水平方向可滚动以适配窄屏。
///
/// ```dart
/// ParkTable(
///   columns: [
///     ParkTableColumn(key: 'name', title: '姓名', sortable: true),
///     ParkTableColumn(key: 'age', title: '年龄', width: 80, align: ParkTableColumnAlign.center),
///   ],
///   data: [
///     {'name': '张三', 'age': '28'},
///     {'name': '李四', 'age': '32'},
///   ],
///   stripe: true,
///   sticky: true,
///   size: ParkTableSize.medium,
/// )
/// ```
class ParkTable extends StatefulWidget {
  /// 列定义
  final List<ParkTableColumn> columns;

  /// 数据列表
  final List<Map<String, dynamic>> data;

  /// 是否显示边框
  final bool bordered;

  /// 是否启用斑马纹
  final bool striped;

  /// 空数据提示文本
  final String emptyText;

  /// 是否处于加载状态（显示加载遮罩）
  final bool loading;

  /// 是否启用可展开行
  final bool expandable;

  /// 展开行内容构建器
  final Widget Function(BuildContext context, Map<String, dynamic> row, int index)? expandedRowBuilder;

  /// 排序回调 (columnIndex, ascending)
  final void Function(int columnIndex, bool ascending)? onSort;

  /// 表头是否吸顶
  final bool sticky;

  /// 行选择配置（null 表示不启用选择列）
  final ParkRowSelection? rowSelection;

  /// 分页配置（null 表示不分页）
  final ParkTablePagination? pagination;

  /// 自定义空状态 Widget（为 null 时使用内置 ParkEmpty）
  final Widget? empty;

  /// 表格尺寸（控制单元格内边距）
  final ParkTableSize size;

  /// 是否启用斑马纹（与 [striped] 等效）
  final bool stripe;

  /// 行唯一标识字段名（对应 data Map 中的 key），null 时使用行索引
  final String? rowKey;

  /// 每行事件回调（返回该行自定义事件 Map，如 onTap/onDoubleTap 等）
  final Map<String, Function>? Function(dynamic row, int index)? onRow;

  /// 表格滚动配置（如 {x: 1200, y: 400} 表示固定表头，横向可滚动）
  final Map<String, double>? scroll;

  /// 是否在排序列显示 tooltip 提示
  final bool showSorterTooltip;

  /// 综合变更回调（分页、排序、筛选等变化时触发）
  final void Function(Map<String, dynamic> changeInfo)? onChange;

  /// 展开行内容构建器（替代签名，与 expandedRowBuilder 功能相同）
  final Widget Function(Map<String, dynamic> row, int index)? expandedRowRender;

  const ParkTable({
    super.key,
    required this.columns,
    required this.data,
    this.bordered = false,
    this.striped = false,
    this.emptyText = '暂无数据',
    this.loading = false,
    this.expandable = false,
    this.expandedRowBuilder,
    this.onSort,
    this.sticky = false,
    this.rowSelection,
    this.pagination,
    this.empty,
    this.size = ParkTableSize.medium,
    this.stripe = false,
    this.rowKey,
    this.onRow,
    this.scroll,
    this.showSorterTooltip = true,
    this.onChange,
    this.expandedRowRender,
  });

  @override
  State<ParkTable> createState() => _ParkTableState();
}

class _ParkTableState extends State<ParkTable> {
  String? _sortKey;
  bool _sortAscending = true;
  final Set<int> _expandedRows = {};

  bool get _isStriped => widget.striped || widget.stripe;

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedRows.contains(index)) {
        _expandedRows.remove(index);
      } else {
        _expandedRows.add(index);
      }
    });
  }

  void _onSort(String key, int columnIndex) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
    });
    widget.onSort?.call(columnIndex, _sortAscending);
  }

  List<Map<String, dynamic>> get _sortedData {
    if (_sortKey == null) return widget.data;

    final sorted = List<Map<String, dynamic>>.from(widget.data);
    sorted.sort((a, b) {
      final aVal = a[_sortKey]?.toString() ?? '';
      final bVal = b[_sortKey]?.toString() ?? '';
      return _sortAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });
    return sorted;
  }

  String _getRowKey(int dataIndex) {
    if (widget.rowKey != null) {
      final data = _sortedData;
      if (dataIndex < data.length) {
        return data[dataIndex][widget.rowKey]?.toString() ?? '$dataIndex';
      }
    }
    return '$dataIndex';
  }

  bool _isRowSelected(int dataIndex) {
    if (widget.rowSelection == null) return false;
    return widget.rowSelection!.selectedRowKeys.contains(_getRowKey(dataIndex));
  }

  bool _isRowSelectionDisabled(int dataIndex) {
    if (widget.rowSelection?.getCheckboxDisabled == null) return false;
    return widget.rowSelection!.getCheckboxDisabled!(_getRowKey(dataIndex));
  }

  void _toggleRowSelection(int dataIndex) {
    final sel = widget.rowSelection!;
    final key = _getRowKey(dataIndex);
    final data = _sortedData;

    List<String> newKeys;
    if (sel.type == ParkRowSelectionType.radio) {
      newKeys = [key];
    } else {
      newKeys = List<String>.from(sel.selectedRowKeys);
      if (newKeys.contains(key)) {
        newKeys.remove(key);
      } else {
        newKeys.add(key);
      }
    }

    final selectedRows = data
        .asMap()
        .entries
        .where((e) => newKeys.contains(_getRowKey(e.key)))
        .map((e) => e.value)
        .toList();

    sel.onChanged?.call(newKeys, selectedRows);
  }

  EdgeInsets _cellPadding() {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    switch (widget.size) {
      case ParkTableSize.small:
        return EdgeInsets.symmetric(
            horizontal: park.spacing.sm, vertical: park.spacing.xs);
      case ParkTableSize.medium:
        return EdgeInsets.symmetric(
            horizontal: park.spacing.md, vertical: park.spacing.md);
      case ParkTableSize.large:
        return EdgeInsets.symmetric(
            horizontal: park.spacing.base, vertical: park.spacing.base);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    // Empty state
    if (widget.data.isEmpty && !widget.loading) {
      return widget.empty ??
          ParkEmpty(description: widget.emptyText);
    }

    final data = _sortedData;
    final headerBg = park.colors.surface;

    Widget header = _buildTableHeader(data, headerBg, park);
    Widget body = _buildTableBody(data, park);

    // Loading overlay
    if (widget.loading) {
      body = Stack(
        children: [
          body,
          Positioned.fill(
            child: Container(
              color: park.colors.surface.withValues(alpha: 0.6),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(park.colors.brand),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget table = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        body,
        if (widget.pagination != null)
          _buildPaginationBar(widget.pagination!, park),
      ],
    );

    return table;
  }

  // ========================================================================
  // Header
  // ========================================================================

  Widget _buildTableHeader(
      List<Map<String, dynamic>> data, Color headerBg, ParkThemeData park) {
    Widget headerContent = Container(
      decoration: BoxDecoration(color: headerBg),
      child: Row(
        children: [
          if (widget.rowSelection != null)
            SizedBox(
              width: 48,
              child: Center(
                child: widget.rowSelection!.type ==
                        ParkRowSelectionType.checkbox
                    ? _buildSelectAllCheckbox(data, park)
                    : const SizedBox.shrink(),
              ),
            ),
          if (widget.expandable && widget.expandedRowBuilder != null)
            const SizedBox(width: 40),
          ...widget.columns.asMap().entries.map((entry) {
            final colIndex = entry.key;
            final col = entry.value;
            return SizedBox(
              width: col.width ?? 120,
              child: _buildHeaderCell(col, park, colIndex),
            );
          }),
        ],
      ),
    );

    if (widget.sticky) {
      return ClipRect(
        child: CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _ParkStickyHeaderDelegate(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: headerContent,
                ),
                height: _headerHeight(park),
              ),
            ),
          ],
        ),
      );
    }

    return headerContent;
  }

  double _headerHeight(ParkThemeData park) {
    final padding = _cellPadding();
    return padding.vertical + 22; // ~20px text + vertical padding
  }

  Widget _buildSelectAllCheckbox(
      List<Map<String, dynamic>> data, ParkThemeData park) {
    final sel = widget.rowSelection!;
    final allKeys =
        List.generate(data.length, (i) => _getRowKey(i));
    final enabledKeys = allKeys
        .where((k) =>
            sel.getCheckboxDisabled?.call(k) != true)
        .toList();
    final allSelected = enabledKeys.isNotEmpty &&
        enabledKeys.every((k) => sel.selectedRowKeys.contains(k));
    final someSelected =
        enabledKeys.any((k) => sel.selectedRowKeys.contains(k));

    return SizedBox(
      width: 18,
      height: 18,
      child: Checkbox(
        value: allSelected,
        tristate: someSelected && !allSelected,
        onChanged: (_) {
          if (allSelected) {
            sel.onChanged?.call([], []);
          } else {
            final selectedRows = data
                .asMap()
                .entries
                .where((e) => enabledKeys.contains(_getRowKey(e.key)))
                .map((e) => e.value)
                .toList();
            sel.onChanged?.call(enabledKeys, selectedRows);
          }
        },
        activeColor: park.colors.brand,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ========================================================================
  // Body
  // ========================================================================

  Widget _buildTableBody(List<Map<String, dynamic>> data, ParkThemeData park) {
    Widget rows = _buildDataRows(data, park);

    if (widget.sticky) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _totalRowWidth(),
          child: rows,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: rows,
    );
  }

  double _totalRowWidth() {
    double w = 0;
    if (widget.rowSelection != null) w += 48;
    if (widget.expandable && widget.expandedRowBuilder != null) w += 40;
    for (final col in widget.columns) {
      w += col.width ?? 120;
    }
    return w;
  }

  Widget _buildDataRows(List<Map<String, dynamic>> data, ParkThemeData park) {
    final useExpandable =
        widget.expandable && widget.expandedRowBuilder != null;

    if (widget.sticky || useExpandable) {
      // Column-based rendering for sticky and expandable modes
      final children = <Widget>[];
      for (var i = 0; i < data.length; i++) {
        final row = data[i];
        final isStriped = _isStriped && i.isOdd;
        final isSelected = _isRowSelected(i);

        Color? rowColor;
        if (isSelected) {
          rowColor = park.colors.brand.withValues(alpha: 0.04);
        } else if (isStriped) {
          rowColor = park.colors.background;
        }

        Widget rowWidget = GestureDetector(
          onTap: useExpandable ? () => _toggleExpand(i) : null,
          child: Container(
            color: rowColor,
            child: Row(
              children: [
                if (widget.rowSelection != null)
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: _buildRowSelectionWidget(i, park),
                    ),
                  ),
                if (useExpandable)
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: AnimatedRotation(
                        turns: _expandedRows.contains(i) ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: park.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ...widget.columns.map((col) {
                  return SizedBox(
                    width: col.width ?? 120,
                    child: _buildDataCell(col, row, park, rowIndex: i),
                  );
                }),
              ],
            ),
          ),
        );

        // Wrap with onRow event handlers if provided
        if (widget.onRow != null) {
          final rowEvents = widget.onRow!(row, i);
          if (rowEvents != null) {
            rowWidget = GestureDetector(
              onTap: rowEvents['onTap'] as VoidCallback?,
              onDoubleTap: rowEvents['onDoubleTap'] as VoidCallback?,
              onLongPress: rowEvents['onLongPress'] as VoidCallback?,
              child: rowWidget,
            );
          }
        }

        children.add(rowWidget);

        if (useExpandable && _expandedRows.contains(i)) {
          children.add(Container(
            width: double.infinity,
            padding: EdgeInsets.all(park.spacing.base),
            decoration: BoxDecoration(
              color: park.colors.background,
              border: Border(
                left: BorderSide(
                  color: park.colors.brand.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
            ),
            child: widget.expandedRowBuilder!(context, row, i),
          ));
        }

        children.add(Divider(height: 1, color: park.colors.divider));
      }

      if (widget.sticky) {
        return CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => children[index],
                childCount: children.length,
                addAutomaticKeepAlives: true,
              ),
            ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    // Normal Table rendering (non-sticky, non-expandable)
    return Table(
      columnWidths: _buildColumnWidths(),
      border: widget.bordered
          ? TableBorder.all(color: park.colors.border, width: 1)
          : TableBorder(
              horizontalInside:
                  BorderSide(color: park.colors.divider, width: 0.5),
              bottom:
                  BorderSide(color: park.colors.divider, width: 0.5),
            ),
      children: [
        // Data rows
        ...data.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final row = entry.value;
          final isStriped = _isStriped && rowIndex.isOdd;
          final isSelected = _isRowSelected(rowIndex);

          Color? rowBg;
          if (isSelected) {
            rowBg = park.colors.brand.withValues(alpha: 0.04);
          } else if (isStriped) {
            rowBg = park.colors.background;
          }

          return TableRow(
            decoration: BoxDecoration(color: rowBg),
            children: [
              if (widget.rowSelection != null)
                SizedBox(
                  width: 48,
                  child: Center(
                    child: _buildRowSelectionWidget(rowIndex, park),
                  ),
                ),
              ...widget.columns.map((col) {
                return _buildDataCell(col, row, park, rowIndex: rowIndex);
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRowSelectionWidget(int dataIndex, ParkThemeData park) {
    final sel = widget.rowSelection!;
    final isSelected = _isRowSelected(dataIndex);
    final isDisabled = _isRowSelectionDisabled(dataIndex);

    if (sel.type == ParkRowSelectionType.radio) {
      final radioColor = isDisabled
          ? park.colors.textDisabled
          : isSelected
              ? park.colors.brand
              : park.colors.border;
      return GestureDetector(
        onTap: isDisabled ? null : () => _toggleRowSelection(dataIndex),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: radioColor, width: 2),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: park.colors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      );
    }

    return SizedBox(
      width: 18,
      height: 18,
      child: Checkbox(
        value: isSelected,
        onChanged: isDisabled ? null : (_) => _toggleRowSelection(dataIndex),
        activeColor: park.colors.brand,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ========================================================================
  // Pagination
  // ========================================================================

  Widget _buildPaginationBar(ParkTablePagination pg, ParkThemeData park) {
    final totalPages = pg.pageSize > 0
        ? (pg.total / pg.pageSize).ceil().clamp(1, 999999)
        : 1;
    final currentPage = pg.current.clamp(1, totalPages);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: park.spacing.base,
        vertical: park.spacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: park.colors.divider, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '共 ${pg.total} 条',
            style: TextStyle(
              fontSize: park.typography.sizeBodySmall,
              color: park.colors.textSecondary,
              fontWeight: park.typography.weightRegular,
            ),
          ),
          SizedBox(width: park.spacing.base),
          _pageButton(
            icon: Icons.chevron_left,
            enabled: currentPage > 1,
            onPressed: () =>
                pg.onPageChanged?.call(currentPage - 1, pg.pageSize),
            park: park,
          ),
          ..._buildPageNumbers(currentPage, totalPages, pg, park),
          _pageButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages,
            onPressed: () =>
                pg.onPageChanged?.call(currentPage + 1, pg.pageSize),
            park: park,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(
      int current, int total, ParkTablePagination pg, ParkThemeData park) {
    if (total <= 7) {
      return List.generate(total, (i) {
        final page = i + 1;
        return _pageNumberButton(page, page == current, pg, park);
      });
    }

    final pages = <int?>[];
    pages.add(1);

    if (current > 3) pages.add(null); // ellipsis

    final start = (current - 1).clamp(2, total - 1);
    final end = (current + 1).clamp(2, total - 1);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }

    if (current < total - 2) pages.add(null); // ellipsis

    pages.add(total);

    // Deduplicate
    final seen = <int>{};
    final unique = <Widget>[];
    for (final p in pages) {
      if (p == null) {
        unique.add(SizedBox(
          width: 32,
          child: Center(
            child: Text('...',
                style: TextStyle(
                    color: park.colors.textSecondary,
                    fontSize: park.typography.sizeBodySmall,
                    fontWeight: park.typography.weightRegular)),
          ),
        ));
      } else if (seen.add(p)) {
        unique.add(_pageNumberButton(p, p == current, pg, park));
      }
    }
    return unique;
  }

  Widget _pageNumberButton(
      int page, bool isCurrent, ParkTablePagination pg, ParkThemeData park) {
    return GestureDetector(
      onTap: isCurrent ? null : () => pg.onPageChanged?.call(page, pg.pageSize),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCurrent ? park.colors.brand : Colors.transparent,
          borderRadius: park.radius.brSm,
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: isCurrent ? park.colors.textOnBrand : park.colors.textPrimary,
            fontWeight: isCurrent
                ? park.typography.weightBold
                : park.typography.weightRegular,
          ),
        ),
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    required ParkThemeData park,
  }) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: park.radius.brSm,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? park.colors.textPrimary
              : park.colors.textDisabled,
        ),
      ),
    );
  }

  // ========================================================================
  // Column widths / header / data cells
  // ========================================================================

  Map<int, TableColumnWidth> _buildColumnWidths() {
    final widths = <int, TableColumnWidth>{};
    var index = 0;

    if (widget.rowSelection != null) {
      widths[index++] = const FixedColumnWidth(48);
    }

    for (var i = 0; i < widget.columns.length; i++) {
      final col = widget.columns[i];
      if (col.width != null) {
        widths[index] = FixedColumnWidth(col.width!);
      } else {
        widths[index] = const FlexColumnWidth();
      }
      index++;
    }
    return widths;
  }

  Widget _buildHeaderCell(
      ParkTableColumn col, ParkThemeData park, int columnIndex) {
    final alignment = _columnAlignToAlignment(col.align);
    final padding = _cellPadding();

    return GestureDetector(
      onTap: col.sortable ? () => _onSort(col.key, columnIndex) : null,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                col.title,
                style: TextStyle(
                  color: park.colors.textPrimary,
                  fontSize: park.typography.sizeBodySmall,
                  fontWeight: park.typography.weightBold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (col.sortable) ...[
              SizedBox(width: park.spacing.xs),
              _buildSortIcon(park, col.key),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortIcon(ParkThemeData park, String key) {
    final isActive = _sortKey == key;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.arrow_drop_up,
          size: 14,
          color: isActive && _sortAscending
              ? park.colors.brand
              : park.colors.textSecondary.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 0),
        Icon(
          Icons.arrow_drop_down,
          size: 14,
          color: isActive && !_sortAscending
              ? park.colors.brand
              : park.colors.textSecondary.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDataCell(
    ParkTableColumn col,
    Map<String, dynamic> row,
    ParkThemeData park, {
    int rowIndex = 0,
  }) {
    final alignGeometry = switch (col.align) {
      ParkTableColumnAlign.left => Alignment.centerLeft,
      ParkTableColumnAlign.center => Alignment.center,
      ParkTableColumnAlign.right => Alignment.centerRight,
    };
    final value = row[col.key]?.toString() ?? '';
    final padding = _cellPadding();

    // Custom render callback takes priority
    if (col.render != null) {
      return Padding(
        padding: padding,
        child: Align(
          alignment: alignGeometry,
          child: col.render!(row, rowIndex),
        ),
      );
    }

    Widget textWidget = Text(
      value,
      style: TextStyle(
        color: park.colors.textPrimary,
        fontSize: park.typography.sizeBody,
        fontWeight: park.typography.weightRegular,
      ),
      overflow: col.ellipsis ? TextOverflow.ellipsis : null,
      maxLines: col.ellipsis ? 2 : null,
    );

    if (col.tooltip) {
      textWidget = Tooltip(
        message: value,
        child: textWidget,
      );
    }

    return Padding(
      padding: padding,
      child: Align(
        alignment: alignGeometry,
        child: textWidget,
      ),
    );
  }

  static MainAxisAlignment _columnAlignToAlignment(
    ParkTableColumnAlign align,
  ) {
    switch (align) {
      case ParkTableColumnAlign.left:
        return MainAxisAlignment.start;
      case ParkTableColumnAlign.center:
        return MainAxisAlignment.center;
      case ParkTableColumnAlign.right:
        return MainAxisAlignment.end;
    }
  }
}

/// 吸顶表头委托
class _ParkStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _ParkStickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _ParkStickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || height != oldDelegate.height;
  }
}
