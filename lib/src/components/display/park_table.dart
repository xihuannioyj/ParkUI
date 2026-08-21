import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';
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

/// Park 虚拟滚动配置
///
/// 控制表格虚拟滚动行为。当启用时，仅渲染可见行 + 缓冲区，
/// 适用于大数据量（100+ 行）场景。
class ParkVirtualScrollConfig {
  /// 是否启用虚拟滚动
  final bool enabled;

  /// 缓冲区行数（可见区域上下额外渲染的行数）
  final int overscan;

  /// 估算行高（像素），用于计算可见范围
  final double estimatedRowHeight;

  const ParkVirtualScrollConfig({
    this.enabled = true,
    this.overscan = 5,
    this.estimatedRowHeight = 54.0,
  });
}

/// Park 表格筛选项值
///
/// 定义单个筛选项的文本和值，对齐 Ant Design filters 数组格式。
class ParkTableFilterValue {
  /// 筛选项显示文本
  final String text;

  /// 筛选项值（用于 onFilter 比较）
  final dynamic value;

  const ParkTableFilterValue({required this.text, required this.value});
}

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

  /// 是否可拖拽调整列宽
  final bool resizable;

  /// 最小列宽（拖拽时不会小于此值，null 时使用 50）
  final double? minWidth;

  /// 最大列宽（拖拽时不会大于此值，null 时不限制）
  final double? maxWidth;

  /// 自定义筛选面板（为 null 时使用内置文本搜索筛选）
  final Widget Function(BuildContext context, ParkTableFilterPanelProps props)?
      filterDropdown;

  /// 自定义筛选图标（为 null 时使用内置漏斗图标）
  final Widget? filterIcon;

  /// 筛选项列表（对齐 Ant Design filters 格式）
  final List<ParkTableFilterValue>? filters;

  /// 筛选逻辑（接收列值和行数据，返回是否保留该行）
  final bool Function(dynamic value, dynamic record)? onFilter;

  /// 当前筛选值（受控模式，为 null 时使用内部状态）
  final List<dynamic>? filteredValue;

  /// 筛选变更回调
  final ValueChanged<List<dynamic>?>? onFilterChange;

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
    this.resizable = false,
    this.minWidth,
    this.maxWidth,
    this.filterDropdown,
    this.filterIcon,
    this.filters,
    this.onFilter,
    this.filteredValue,
    this.onFilterChange,
  });

  /// 是否有筛选配置
  bool get hasFilter =>
      filters != null || filterDropdown != null || onFilter != null;
}

/// 筛选面板属性（传递给自定义 filterDropdown）
class ParkTableFilterPanelProps {
  /// 确认筛选回调
  final VoidCallback confirm;

  /// 重置筛选回调
  final VoidCallback reset;

  /// 当前筛选值
  final List<dynamic> selectedValues;

  /// 设置筛选值
  final ValueChanged<List<dynamic>> setSelectedValues;

  const ParkTableFilterPanelProps({
    required this.confirm,
    required this.reset,
    required this.selectedValues,
    required this.setSelectedValues,
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

/// Park 树形数据配置
///
/// 用于表格展示树形结构数据，对齐 Ant Design 5 的 tree data 功能。
/// 当数据行包含子节点时，会在该行前显示展开/收起图标，展开后显示子行并带缩进。
class ParkTableTreeConfig {
  /// 树形数据子节点字段名（默认 'children'）
  final String childrenFieldName;

  /// 默认展开所有节点
  final bool defaultExpandAll;

  /// 受控展开的节点 key 列表（为 null 时使用内部状态）
  final List<dynamic>? expandedRowKeys;

  /// 展开/收起回调
  final void Function(List<dynamic> expandedKeys, dynamic record)? onExpand;

  /// 缩进像素（默认 16）
  final double indentSize;

  /// 自定义展开图标（为 null 时使用内置箭头图标）
  final Widget? expandIcon;

  const ParkTableTreeConfig({
    this.childrenFieldName = 'children',
    this.defaultExpandAll = false,
    this.expandedRowKeys,
    this.onExpand,
    this.indentSize = 16.0,
    this.expandIcon,
  });
}

/// 树形数据扁平化后的行信息
class _FlatTreeRow {
  /// 原始数据行
  final Map<String, dynamic> data;

  /// 树深度（0 为根节点）
  final int depth;

  /// 行唯一标识 key
  final String key;

  /// 是否有子节点
  final bool hasChildren;

  /// 在原始数据中的索引（用于兼容行选择等功能）
  final int originalIndex;

  const _FlatTreeRow({
    required this.data,
    required this.depth,
    required this.key,
    required this.hasChildren,
    required this.originalIndex,
  });
}

// ParkTablePagination is now the standalone pagination widget in navigation/.
// Use ParkTablePagination for ParkTable's pagination parameter.

/// Park 数据表格组件
///
/// 支持排序、边框、斑马纹、空状态与加载态，
/// 水平方向可滚动以适配窄屏。
///
/// **性能说明（R3-20）：** 当启用 [sticky]（固定表头）或 [expandable]（可展开行）
/// 模式时，虚拟滚动会退化为全量渲染，因为这两种模式需要完整布局所有行才能正确
/// 计算 sticky 偏移量或展开区域。对于大数据量（>100 行）且不需要 sticky/expandable
/// 的场景，建议使用纯 [ListView.builder] 方案以获得最佳性能。
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
  final String? emptyText;

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

  /// 行唯一标识字段名（对应 data Map 中的 key），null 时使用行索引
  final String? rowKey;

  /// 每行事件回调（返回该行自定义事件 Map，如 onTap/onDoubleTap 等）。
  ///
  /// 回调值已按真实类型声明为 [VoidCallback]，调用处无需强转。
  final Map<String, VoidCallback>? Function(dynamic row, int index)? onRow;

  /// 表格滚动配置（如 {x: 1200, y: 400} 表示固定表头，横向可滚动）
  final Map<String, double>? scroll;

  /// 是否在排序列显示 tooltip 提示
  final bool showSorterTooltip;

  /// 综合变更回调（分页、排序、筛选等变化时触发）
  @Deprecated('Use onChanged instead')
  final void Function(Map<String, dynamic> changeInfo)? onChange;

  /// 综合变更回调（分页、排序、筛选等变化时触发）
  final void Function(Map<String, dynamic> changeInfo)? onChanged;

  /// 内部使用的有效回调：优先使用 onChanged，回退到 onChange。
  void Function(Map<String, dynamic> changeInfo)? get _effectiveOnChanged =>
      onChanged ?? onChange;

  /// 展开行内容构建器（替代签名，与 expandedRowBuilder 功能相同）
  final Widget Function(Map<String, dynamic> row, int index)? expandedRowRender;

  /// 列宽变化回调（拖拽调整列宽时触发，key 为列 key，value 为当前宽度）
  final void Function(Map<String, double> widths)? onColumnWidthChanged;

  /// 虚拟滚动配置（null 或 enabled=false 时禁用虚拟滚动）
  ///
  /// 当启用虚拟滚动时，仅渲染可见行 + 缓冲区，适用于大数据量场景。
  /// 分页模式下虚拟滚动自动禁用（分页已限制渲染行数）。
  /// 展开行模式下虚拟滚动自动禁用（展开行高度不固定）。
  final ParkVirtualScrollConfig? virtualScroll;

  /// 树形数据配置（null 时不启用树形数据模式）
  ///
  /// 启用后，数据行中的子节点（由 [ParkTableTreeConfig.childrenFieldName] 指定字段）
  /// 会以树形结构展示，支持展开/收起、多级嵌套和缩进。
  /// 树形数据模式下分页自动禁用。
  final ParkTableTreeConfig? treeConfig;

  const ParkTable({
    super.key,
    required this.columns,
    required this.data,
    this.bordered = false,
    this.striped = false,
    this.emptyText = null,
    this.loading = false,
    this.expandable = false,
    this.expandedRowBuilder,
    this.onSort,
    this.sticky = false,
    this.rowSelection,
    this.pagination,
    this.empty,
    this.size = ParkTableSize.medium,
    this.rowKey,
    this.onRow,
    this.scroll,
    this.showSorterTooltip = true,
    // ignore: deprecated_member_use_from_same_package
    this.onChange,
    this.onChanged,
    this.expandedRowRender,
    this.onColumnWidthChanged,
    this.virtualScroll,
    this.treeConfig,
  });

  @override
  State<ParkTable> createState() => _ParkTableState();
}

class _ParkTableState extends State<ParkTable> {
  String? _sortKey;
  bool _sortAscending = true;
  final Set<int> _expandedRows = {};

  /// 运行时列宽缓存（拖拽调整后更新），key 为列 key。
  Map<String, double> _columnWidths = {};

  /// Pre-computed sorted data cache (rebuilt once per build cycle).
  List<Map<String, dynamic>>? _cachedSortedData;

  /// Pre-computed row key cache: index → key (O(1) lookup).
  Map<int, String>? _rowKeyCache;

  /// 内部筛选状态（非受控模式时使用），key 为列 key。
  final Map<String, List<dynamic>> _internalFilterState = {};

  /// 树形数据展开的 key 集合（非受控模式时使用）
  final Set<String> _expandedTreeKeys = {};

  /// 树形数据扁平化缓存
  List<_FlatTreeRow>? _flatTreeRowsCache;

  /// 虚拟滚动控制器
  ScrollController? _virtualScrollController;

  /// 是否启用虚拟滚动（综合判断）
  bool get _isVirtualScrollEnabled {
    // 分页模式下不需要虚拟滚动
    if (widget.pagination != null) return false;
    // 展开行模式下不需要虚拟滚动（高度不固定）
    if (_hasExpandedRow) return false;
    // 树形数据模式下不需要虚拟滚动（需要特殊渲染缩进和展开图标）
    if (_isTreeMode) return false;
    // 检查配置
    final config = widget.virtualScroll;
    if (config == null) return false;
    return config.enabled;
  }

  /// 是否启用树形数据模式
  bool get _isTreeMode => widget.treeConfig != null;

  bool get _isStriped => widget.striped;

  /// 默认列宽（当列未指定 width 且未被拖拽调整时使用）。
  static const double _defaultColumnWidth = 120.0;

  /// 拖拽最小列宽限制。
  static const double _minResizableWidth = 50.0;

  /// 获取指定列的当前宽度。
  double _getColumnWidth(ParkTableColumn col) {
    return _columnWidths[col.key] ?? col.width ?? _defaultColumnWidth;
  }

  /// 初始化列宽缓存（从列定义中读取初始值）。
  void _initColumnWidths() {
    final widths = <String, double>{};
    for (final col in widget.columns) {
      if (col.width != null) {
        widths[col.key] = col.width!;
      }
    }
    _columnWidths = widths;
  }

  /// 拖拽调整列宽回调。
  void _onColumnResize(ParkTableColumn col, double delta) {
    final currentWidth = _getColumnWidth(col);
    final minW = col.minWidth ?? _minResizableWidth;
    double newWidth = currentWidth + delta;
    if (newWidth < minW) newWidth = minW;
    if (col.maxWidth != null && newWidth > col.maxWidth!) {
      newWidth = col.maxWidth!;
    }
    setState(() {
      _columnWidths[col.key] = newWidth;
    });
    widget.onColumnWidthChanged?.call(Map<String, double>.from(_columnWidths));
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedRows.contains(index)) {
        _expandedRows.remove(index);
      } else {
        _expandedRows.add(index);
      }
    });
  }

  /// 切换树形节点的展开/收起状态
  void _toggleTreeExpand(String key, Map<String, dynamic> record) {
    final config = widget.treeConfig!;
    setState(() {
      if (_expandedTreeKeys.contains(key)) {
        _expandedTreeKeys.remove(key);
      } else {
        _expandedTreeKeys.add(key);
      }
      _flatTreeRowsCache = null; // Invalidate flat cache
    });
    // 回调
    if (config.onExpand != null) {
      config.onExpand!(_expandedTreeKeys.toList(), record);
    }
  }

  /// 初始化树形数据默认展开状态（defaultExpandAll）
  void _initTreeExpandedKeys(List<Map<String, dynamic>> data) {
    if (!_isTreeMode) return;
    final config = widget.treeConfig!;
    if (config.defaultExpandAll) {
      _collectAllKeys(data, config.childrenFieldName);
    }
  }

  /// 递归收集所有有子节点的 key
  void _collectAllKeys(List<Map<String, dynamic>> data, String childrenField) {
    for (final row in data) {
      final children = row[childrenField];
      if (children is List && children.isNotEmpty) {
        final key = _getTreeRowKey(row);
        _expandedTreeKeys.add(key);
        _collectAllKeys(
          children.cast<Map<String, dynamic>>(),
          childrenField,
        );
      }
    }
  }

  /// 获取树形数据行的 key
  String _getTreeRowKey(Map<String, dynamic> row) {
    if (widget.rowKey != null) {
      return row[widget.rowKey]?.toString() ?? row.hashCode.toString();
    }
    return row.hashCode.toString();
  }

  /// 将树形数据扁平化为行列表
  List<_FlatTreeRow> _flattenTreeData(List<Map<String, dynamic>> data) {
    if (_flatTreeRowsCache != null) return _flatTreeRowsCache!;
    if (!_isTreeMode) {
      // 非树形模式，直接返回扁平结构（depth=0）
      _flatTreeRowsCache = List<_FlatTreeRow>.generate(
        data.length,
        (i) => _FlatTreeRow(
          data: data[i],
          depth: 0,
          key: _getRowKey(i),
          hasChildren: false,
          originalIndex: i,
        ),
      );
      return _flatTreeRowsCache!;
    }

    final config = widget.treeConfig!;
    final result = <_FlatTreeRow>[];
    final expandedKeys = config.expandedRowKeys != null
        ? config.expandedRowKeys!.map((e) => e.toString()).toSet()
        : _expandedTreeKeys;

    void flatten(List<Map<String, dynamic>> rows, int depth, int startIndex) {
      int index = startIndex;
      for (final row in rows) {
        final children = row[config.childrenFieldName];
        final bool hasChildren = children is List && children.isNotEmpty;
        final key = _getTreeRowKey(row);

        result.add(_FlatTreeRow(
          data: row,
          depth: depth,
          key: key,
          hasChildren: hasChildren,
          originalIndex: index,
        ));

        // 如果已展开且有子节点，递归展开子节点
        if (hasChildren && expandedKeys.contains(key)) {
          flatten(children.cast<Map<String, dynamic>>(), depth + 1, index);
        }
        index++;
      }
    }

    flatten(data, 0, 0);
    _flatTreeRowsCache = result;
    return result;
  }

  void _onSort(String key, int columnIndex) {
    setState(() {
      if (_sortKey == key) {
        _sortAscending = !_sortAscending;
      } else {
        _sortKey = key;
        _sortAscending = true;
      }
      _cachedSortedData = null; // Invalidate cache on sort change
    });
    widget.onSort?.call(columnIndex, _sortAscending);
    widget._effectiveOnChanged?.call({
      'type': 'sort',
      'columnKey': key,
      'columnIndex': columnIndex,
      'ascending': _sortAscending,
    });
  }

  /// Whether any expanded row builder is available.
  bool get _hasExpandedRow {
    return widget.expandable &&
        (widget.expandedRowBuilder != null || widget.expandedRowRender != null);
  }

  /// Build expanded row content using expandedRowBuilder (preferred) or
  /// expandedRowRender (fallback).
  Widget _buildExpandedRowContent(Map<String, dynamic> row, int index) {
    if (widget.expandedRowBuilder != null) {
      return widget.expandedRowBuilder!(context, row, index);
    }
    return widget.expandedRowRender!(row, index);
  }

  /// 将单元格值解析为 [num]，支持 num 与可解析的数字字符串。
  ///
  /// 无法解析时返回 null。
  static num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Ensures the sorted/filtered data and row key caches are up-to-date.
  /// Called at the start of build() and lazily when _getRowKey is accessed.
  void _ensureRowKeyCache() {
    if (_cachedSortedData != null) return;
    List<Map<String, dynamic>> result;
    if (_sortKey == null) {
      result = widget.data;
    } else {
      final sorted = List<Map<String, dynamic>>.from(widget.data);
      sorted.sort((a, b) {
        final num? aNum = _toNum(a[_sortKey]);
        final num? bNum = _toNum(b[_sortKey]);
        if (aNum != null && bNum != null) {
          return _sortAscending ? aNum.compareTo(bNum) : bNum.compareTo(aNum);
        }
        final aVal = a[_sortKey]?.toString() ?? '';
        final bVal = b[_sortKey]?.toString() ?? '';
        return _sortAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
      result = sorted;
    }
    // Apply filters
    result = _applyFilters(result);
    _cachedSortedData = result;
    _rowKeyCache = {};
    final data = _cachedSortedData!;
    for (var i = 0; i < data.length; i++) {
      if (widget.rowKey != null) {
        _rowKeyCache![i] = data[i][widget.rowKey]?.toString() ?? '$i';
      } else {
        _rowKeyCache![i] = '$i';
      }
    }
  }

  /// 对数据应用所有列的筛选条件。
  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> data) {
    for (final col in widget.columns) {
      if (!col.hasFilter) continue;
      final filterValues = col.filteredValue ?? _internalFilterState[col.key];
      if (filterValues == null || filterValues.isEmpty) continue;
      if (col.onFilter == null) continue;
      data = data.where((row) {
        return filterValues
            .any((v) => col.onFilter!(v, row));
      }).toList();
    }
    return data;
  }

  /// 获取列的当前筛选值（受控优先，否则内部状态）
  List<dynamic>? _getColumnFilterValues(ParkTableColumn col) {
    return col.filteredValue ?? _internalFilterState[col.key];
  }

  /// 设置列的筛选值
  void _setColumnFilter(ParkTableColumn col, List<dynamic>? values) {
    setState(() {
      if (values == null || values.isEmpty) {
        _internalFilterState.remove(col.key);
      } else {
        _internalFilterState[col.key] = values;
      }
      _cachedSortedData = null;
      _rowKeyCache = null;
    });
    col.onFilterChange?.call(values);
    widget._effectiveOnChanged?.call({
      'type': 'filter',
      'columnKey': col.key,
      'filteredValue': values,
    });
  }

  /// O(1) row key lookup from pre-computed cache.
  String _getRowKey(int dataIndex) {
    _ensureRowKeyCache();
    return _rowKeyCache![dataIndex] ?? '$dataIndex';
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
    final data = _cachedSortedData!;

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
    widget._effectiveOnChanged?.call({
      'type': 'selection',
      'selectedRowKeys': newKeys,
      'selectedRows': selectedRows,
    });
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
  void initState() {
    super.initState();
    _initColumnWidths();
    _initTreeExpandedKeys(widget.data);
    _initVirtualScrollController();
  }

  void _initVirtualScrollController() {
    if (_isVirtualScrollEnabled && _virtualScrollController == null) {
      _virtualScrollController = ScrollController();
    }
  }

  @override
  void dispose() {
    _virtualScrollController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ParkTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data ||
        widget.rowKey != oldWidget.rowKey ||
        widget.columns != oldWidget.columns) {
      _cachedSortedData = null;
      _rowKeyCache = null;
      _columnWidths.clear();
      _expandedRows.clear();
      _flatTreeRowsCache = null;
    }
    if (widget.treeConfig != oldWidget.treeConfig) {
      _expandedTreeKeys.clear();
      _flatTreeRowsCache = null;
      _initTreeExpandedKeys(widget.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    // Rebuild sorted data + row key caches once per build cycle (B78).
    _ensureRowKeyCache();

    // Empty state
    if (widget.data.isEmpty && !widget.loading) {
      return widget.empty ?? ParkEmpty(description: widget.emptyText ?? ParkLocalizations.of(context).noData);
    }

    final data = _cachedSortedData!;
    final headerBg = park.colors.surface;

    final bool hasFixed =
        _leftFixedColumns.isNotEmpty || _rightFixedColumns.isNotEmpty;
    final Widget tableView = hasFixed
        ? _buildFixedTable(data, headerBg, park)
        : _buildPlainTable(data, headerBg, park);

    Widget result = tableView;

    // Loading overlay
    if (widget.loading) {
      result = Stack(
        children: [
          result,
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

    // 树形数据模式下禁用分页
    if (widget.pagination != null && !_isTreeMode) {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          result,
          _buildPaginationBar(widget.pagination!, park),
        ],
      );
    }

    return result;
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
          if (_hasExpandedRow)
            const SizedBox(width: 40),
          ...widget.columns.asMap().entries.map((entry) {
            final colIndex = entry.key;
            final col = entry.value;
            return SizedBox(
              width: _getColumnWidth(col),
              child: _buildHeaderCell(col, park, colIndex),
            );
          }),
        ],
      ),
    );

    // sticky 模式：吸顶由 _buildStickyTable 的「有界高度 Column + 数据区垂直滚动」实现，
    // 表头本身无需嵌套 SliverPersistentHeader（shrinkWrap 视口 + pinned 会产生非法
    // SliverGeometry 导致布局崩溃），这里仅返回内容。
    return ClipRect(child: headerContent);
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
            widget._effectiveOnChanged?.call({
              'type': 'selection',
              'selectedRowKeys': <String>[],
              'selectedRows': <dynamic>[],
            });
          } else {
            final selectedRows = data
                .asMap()
                .entries
                .where((e) => enabledKeys.contains(_getRowKey(e.key)))
                .map((e) => e.value)
                .toList();
            sel.onChanged?.call(enabledKeys, selectedRows);
            widget._effectiveOnChanged?.call({
              'type': 'selection',
              'selectedRowKeys': enabledKeys,
              'selectedRows': selectedRows,
            });
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

    // Column 模式（expandable / tree）的 rows 是 stretch Column，
    // 必须给定固定宽度，否则水平 SingleChildScrollView 传入无限宽约束导致布局崩溃。
    final bool needsFixedWidth = _hasExpandedRow || _isTreeMode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: needsFixedWidth
          ? SizedBox(width: _totalRowWidth(), child: rows)
          : rows,
    );
  }

  double _totalRowWidth() {
    double w = 0;
    if (widget.rowSelection != null) w += 48;
    if (_hasExpandedRow) w += 40;
    for (final col in widget.columns) {
      w += _getColumnWidth(col);
    }
    return w;
  }

  Widget _buildDataRows(List<Map<String, dynamic>> data, ParkThemeData park) {
    final useExpandable =
        _hasExpandedRow;

    if (widget.sticky || useExpandable || _isTreeMode) {
      // Column-based rendering for sticky, expandable, and tree modes
      final children = <Widget>[];

      // 树形模式使用扁平化数据
      final List<_FlatTreeRow> flatRows = _isTreeMode
          ? _flattenTreeData(data)
          : List<_FlatTreeRow>.generate(
              data.length,
              (i) => _FlatTreeRow(
                data: data[i],
                depth: 0,
                key: _getRowKey(i),
                hasChildren: false,
                originalIndex: i,
              ),
            );

      for (var i = 0; i < flatRows.length; i++) {
        final flatRow = flatRows[i];
        final row = flatRow.data;
        final rowIndex = flatRow.originalIndex;
        final isStriped = _isStriped && i.isOdd;
        final isSelected = _isRowSelected(rowIndex);

        Color? rowColor;
        if (isSelected) {
          rowColor = park.colors.brand.withValues(alpha: 0.04);
        } else if (isStriped) {
          rowColor = park.colors.background;
        }

        Widget rowWidget = GestureDetector(
          onTap: useExpandable ? () => _toggleExpand(rowIndex) : null,
          child: Container(
            color: rowColor,
            child: Row(
              children: [
                if (widget.rowSelection != null)
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: _buildRowSelectionWidget(rowIndex, park),
                    ),
                  ),
                if (useExpandable)
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: AnimatedRotation(
                        turns: _expandedRows.contains(rowIndex) ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: park.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ...widget.columns.asMap().entries.map((entry) {
                  final colIndex = entry.key;
                  final col = entry.value;
                  return SizedBox(
                    width: _getColumnWidth(col),
                    child: _buildDataCell(col, row, park,
                        rowIndex: rowIndex,
                        treeDepth: _isTreeMode && colIndex == 0 ? flatRow.depth : 0,
                        treeHasChildren: _isTreeMode && colIndex == 0 ? flatRow.hasChildren : false,
                        treeRowKey: _isTreeMode ? flatRow.key : null,
                        treeRecord: _isTreeMode ? row : null),
                  );
                }),
              ],
            ),
          ),
        );

        // Wrap with onRow event handlers if provided
        if (widget.onRow != null) {
          final rowEvents = widget.onRow!(row, rowIndex);
          if (rowEvents != null) {
            rowWidget = GestureDetector(
              onTap: rowEvents['onTap'],
              onDoubleTap: rowEvents['onDoubleTap'],
              onLongPress: rowEvents['onLongPress'],
              child: rowWidget,
            );
          }
        }

        children.add(rowWidget);

        if (useExpandable && _expandedRows.contains(rowIndex)) {
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
            child: _buildExpandedRowContent(row, rowIndex),
          ));
        }

        children.add(Divider(height: 1, color: park.colors.divider));
      }

      // sticky / expandable / tree 场景行集合：普通 Column 排布，
      // 吸顶由 _buildStickyTable 统一处理（不再嵌套 shrinkWrap CustomScrollView）。
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
            ParkLocalizations.of(context).totalInfo(pg.total),
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
            onPressed: () {
              pg.onPageChanged?.call(currentPage - 1, pg.pageSize);
              widget._effectiveOnChanged?.call({
                'type': 'pagination',
                'page': currentPage - 1,
                'pageSize': pg.pageSize,
              });
            },
            park: park,
          ),
          ..._buildPageNumbers(currentPage, totalPages, pg, park),
          _pageButton(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages,
            onPressed: () {
              pg.onPageChanged?.call(currentPage + 1, pg.pageSize);
              widget._effectiveOnChanged?.call({
                'type': 'pagination',
                'page': currentPage + 1,
                'pageSize': pg.pageSize,
              });
            },
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
    return Semantics(
      button: true,
      selected: isCurrent,
      label: '$page',
      child: GestureDetector(
      onTap: isCurrent ? null : () {
        pg.onPageChanged?.call(page, pg.pageSize);
        widget._effectiveOnChanged?.call({
          'type': 'pagination',
          'page': page,
          'pageSize': pg.pageSize,
        });
      },
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
      ),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
    required ParkThemeData park,
  }) {
    final l10n = ParkLocalizations.of(context);
    final label = icon == Icons.chevron_left ? l10n.previousStep : l10n.nextStep;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
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
      if (col.width != null || _columnWidths.containsKey(col.key)) {
        widths[index] = FixedColumnWidth(_getColumnWidth(col));
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
      behavior: HitTestBehavior.opaque,
      onTap: col.sortable ? () => _onSort(col.key, columnIndex) : null,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: widget.showSorterTooltip && col.sortable
                  ? Tooltip(
                      message: ParkLocalizations.of(context).clickToSort,
                      child: Text(
                        col.title,
                        style: TextStyle(
                          color: park.colors.textPrimary,
                          fontSize: park.typography.sizeBodySmall,
                          fontWeight: park.typography.weightBold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : Text(
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
            if (col.hasFilter) ...[
              SizedBox(width: park.spacing.xs),
              _buildFilterIcon(col, park),
            ],
            if (col.resizable) _buildResizeHandle(col, park),
          ],
        ),
      ),
    );
  }

  /// 构建筛选图标（点击弹出筛选面板）
  Widget _buildFilterIcon(ParkTableColumn col, ParkThemeData park) {
    final isActive =
        (_getColumnFilterValues(col)?.isNotEmpty ?? false);
    final filterIcon = col.filterIcon ??
        Icon(
          Icons.filter_list,
          size: 14,
          color: isActive ? park.colors.brand : park.colors.textSecondary,
        );

    return GestureDetector(
      onTap: () => _showFilterPopup(col, park),
      behavior: HitTestBehavior.opaque,
      child: filterIcon,
    );
  }

  /// 显示筛选弹出面板
  void _showFilterPopup(ParkTableColumn col, ParkThemeData park) {
    final currentValues =
        List<dynamic>.from(_getColumnFilterValues(col) ?? <dynamic>[]);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _FilterDialog(
          column: col,
          park: park,
          initialValues: currentValues,
          onConfirm: (values) {
            _setColumnFilter(col, values.isEmpty ? null : values);
            Navigator.of(dialogContext).pop();
          },
          onReset: () {
            _setColumnFilter(col, null);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  /// 构建列宽拖拽手柄。
  Widget _buildResizeHandle(ParkTableColumn col, ParkThemeData park) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          _onColumnResize(col, details.delta.dx);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: park.colors.border,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
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
    int treeDepth = 0,
    bool treeHasChildren = false,
    String? treeRowKey,
    Map<String, dynamic>? treeRecord,
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
      Widget content = col.render!(row, rowIndex);
      // 树形模式第一列添加缩进和展开图标
      if (treeDepth > 0 || treeHasChildren) {
        content = _buildTreeCellContent(content, treeDepth, treeHasChildren,
            treeRowKey, treeRecord, park, alignGeometry);
      }
      return Padding(
        padding: padding,
        child: Align(
          alignment: alignGeometry,
          child: content,
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

    Widget cellContent = Align(
      alignment: alignGeometry,
      child: textWidget,
    );

    // 树形模式第一列添加缩进和展开图标
    if (treeDepth > 0 || treeHasChildren) {
      cellContent = _buildTreeCellContent(cellContent, treeDepth,
          treeHasChildren, treeRowKey, treeRecord, park, alignGeometry);
    }

    return Padding(
      padding: padding,
      child: cellContent,
    );
  }

  /// 构建树形单元格内容（缩进 + 展开图标 + 原始内容）
  Widget _buildTreeCellContent(
    Widget content,
    int depth,
    bool hasChildren,
    String? rowKey,
    Map<String, dynamic>? record,
    ParkThemeData park,
    AlignmentGeometry align,
  ) {
    final config = widget.treeConfig!;
    final indentWidth = config.indentSize * depth;

    // 展开/收起图标
    Widget? expandIcon;
    if (hasChildren && rowKey != null && record != null) {
      final isExpanded = config.expandedRowKeys != null
          ? config.expandedRowKeys!.map((e) => e.toString()).contains(rowKey)
          : _expandedTreeKeys.contains(rowKey);

      expandIcon = GestureDetector(
        onTap: () => _toggleTreeExpand(rowKey, record),
        child: config.expandIcon ??
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_right,
                size: 16,
                color: park.colors.textSecondary,
              ),
            ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 缩进
        SizedBox(width: indentWidth),
        // 展开图标占位（有子节点时显示图标，否则留空保持对齐）
        if (hasChildren)
          SizedBox(
            width: 20,
            height: 20,
            child: Center(child: expandIcon),
          )
        else
          const SizedBox(width: 20),
        // 原始内容
        Flexible(child: content),
      ],
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

  // ========================================================================
  // 固定列（Fixed Columns）
  // ========================================================================

  /// 左侧固定列（始终可见，不随横向滚动移动）。
  List<ParkTableColumn> get _leftFixedColumns => widget.columns
      .where((ParkTableColumn c) => c.fixed == ParkColumnFixed.left)
      .toList();

  /// 中间可滚动列（fixed == none）。
  List<ParkTableColumn> get _midColumns => widget.columns
      .where((ParkTableColumn c) => c.fixed == ParkColumnFixed.none)
      .toList();

  /// 右侧固定列（始终可见，右侧锚定）。
  List<ParkTableColumn> get _rightFixedColumns => widget.columns
      .where((ParkTableColumn c) => c.fixed == ParkColumnFixed.right)
      .toList();

  /// 无固定列时的传统整体渲染（保持 sticky / expandable 等原有行为）。
  Widget _buildPlainTable(
    List<Map<String, dynamic>> data,
    Color headerBg,
    ParkThemeData park,
  ) {
    // 虚拟化路径：显式设置了 scroll 视口时，行使用 ListView.builder 惰性构建，
    // 避免万行全量 build；表头固定、横向滚动与 Scrollbar 均保留（B26）。
    // 虚拟化路径：显式设置了 scroll 视口或启用了 virtualScroll 时，
    // 行使用 ListView.builder 惰性构建，避免万行全量 build。
    if (!widget.sticky &&
        !(_hasExpandedRow) &&
        !_isTreeMode &&
        (widget.scroll != null || _isVirtualScrollEnabled)) {
      return _buildVirtualTable(data, headerBg, park);
    }

    // 非 sticky 且 非 expandable 且 非 tree mode → 用同一个 Table widget 统一渲染表头和数据行，
    // 确保 columnWidths 对表头和数据行一致，避免 header 用 SizedBox(fixed)
    // 而 body 用 FlexColumnWidth 导致的列宽不匹配。
    if (!widget.sticky &&
        !(_hasExpandedRow) &&
        !_isTreeMode) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Table(
                columnWidths: _buildColumnWidths(),
                border: widget.bordered
                    ? TableBorder.all(color: park.colors.border, width: 1)
                    : TableBorder(
                        horizontalInside: BorderSide(
                            color: park.colors.divider, width: 0.5),
                        bottom:
                            BorderSide(color: park.colors.divider, width: 0.5),
                      ),
                children: <TableRow>[
                  // 表头行（第一行）
                  TableRow(
                    decoration: BoxDecoration(color: headerBg),
                    children: <Widget>[
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
                      ...widget.columns.asMap().entries.map((MapEntry<int,
                              ParkTableColumn> entry) =>
                          _buildHeaderCell(entry.value, park, entry.key)),
                    ],
                  ),
                  // 数据行
                  ...data.asMap().entries.map((MapEntry<int,
                          Map<String, dynamic>> entry) {
                    final int rowIndex = entry.key;
                    final Map<String, dynamic> row = entry.value;
                    final bool isStriped = _isStriped && rowIndex.isOdd;
                    final bool isSelected = _isRowSelected(rowIndex);

                    Color? rowBg;
                    if (isSelected) {
                      rowBg = park.colors.brand.withValues(alpha: 0.04);
                    } else if (isStriped) {
                      rowBg = park.colors.background;
                    }

                    return TableRow(
                      decoration: BoxDecoration(color: rowBg),
                      children: <Widget>[
                        if (widget.rowSelection != null)
                          SizedBox(
                            width: 48,
                            child: Center(
                              child:
                                  _buildRowSelectionWidget(rowIndex, park),
                            ),
                          ),
                        ...widget.columns.map((ParkTableColumn col) =>
                            _buildDataCell(col, row, park,
                                rowIndex: rowIndex)),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );
    }

    // sticky：吸顶表头（有界高度时表头固定、数据区独立垂直滚动；无界高度时退化为普通排布）
    if (widget.sticky) {
      return _buildStickyTable(data, headerBg, park);
    }

    // expandable / tree 场景：保留原有的分离式 header + body 布局
    // （它们都用 SizedBox(width: col.width ?? 120)，宽度计算一致）
    final Widget header = _buildTableHeader(data, headerBg, park);
    final Widget body = _buildTableBody(data, park);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[header, body],
    );
  }

  /// sticky 吸顶表头布局。
  ///
  /// 有界高度（如外层 SizedBox/Expanded 提供固定高度）时：表头固定，数据区独立垂直滚动，
  /// 表头与数据区共享同一横向滚动容器保证列对齐；无界高度时退化为普通排布避免崩溃。
  Widget _buildStickyTable(
    List<Map<String, dynamic>> data,
    Color headerBg,
    ParkThemeData park,
  ) {
    final Widget header = _buildTableHeader(data, headerBg, park);
    final Widget body = _buildDataRows(data, park);
    final double totalWidth = _totalRowWidth();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedHeight) {
          // 无界高度：整表按内容排布，横向可滚动
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[header, body],
              ),
            ),
          );
        }
        // 有界高度：表头吸顶，数据区垂直滚动
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: totalWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                header,
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 含固定列时的三段式布局：左固定层 + 中间横向滚动 + 右固定层。
  Widget _buildFixedTable(
    List<Map<String, dynamic>> data,
    Color headerBg,
    ParkThemeData park,
  ) {
    final List<ParkTableColumn> left = _leftFixedColumns;
    final List<ParkTableColumn> mid = _midColumns;
    final List<ParkTableColumn> right = _rightFixedColumns;
    final bool hasSelection = widget.rowSelection != null;
    final Color surface = park.colors.surface;

    Widget buildPane(
      List<ParkTableColumn> cols, {
      required bool includeSelectionLeading,
      required bool scrollable,
    }) {
      final Widget headerPane =
          _buildHeaderPane(cols, park, includeSelectionLeading: includeSelectionLeading);
      final Widget bodyPane =
          _buildBodyPane(cols, data, park, includeSelectionLeading: includeSelectionLeading);
      Widget pane = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[headerPane, bodyPane],
      );
      if (scrollable) {
        pane = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: pane,
        );
      }
      return pane;
    }

    final List<Widget> children = <Widget>[];

    final bool hasLeftPane = left.isNotEmpty || hasSelection;
    if (hasLeftPane) {
      children.add(
        _FixedLayer(
          backgroundColor: surface,
          shadowOnRight: left.isNotEmpty,
          child: buildPane(
            left,
            includeSelectionLeading: hasSelection,
            scrollable: false,
          ),
        ),
      );
    }

    children.add(
      Expanded(
        child: buildPane(mid, includeSelectionLeading: false, scrollable: true),
      ),
    );

    if (right.isNotEmpty) {
      children.add(
        _FixedLayer(
          backgroundColor: surface,
          shadowOnLeft: true,
          child: buildPane(
            right,
            includeSelectionLeading: false,
            scrollable: false,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// 虚拟滚动表格：表头固定 + 横向滚动 + 行按视口惰性构建（ListView.builder）。
  ///
  /// 在 [widget.scroll] 提供视口高度或 [widget.virtualScroll] 启用时启用，
  /// 用于大数据量场景避免全量 build。
  Widget _buildVirtualTable(
    List<Map<String, dynamic>> data,
    Color headerBg,
    ParkThemeData park,
  ) {
    final double totalWidth = _totalRowWidth();
    final double viewportHeight = widget.scroll?['y'] ?? 400.0;
    final double rowHeight =
        widget.virtualScroll?.estimatedRowHeight ?? 54.0;
    final Widget header = _buildTableHeader(data, headerBg, park);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              header,
              SizedBox(
                height: viewportHeight,
                child: Scrollbar(
                  controller: _virtualScrollController,
                  child: ListView.builder(
                    controller: _virtualScrollController,
                    itemCount: data.length,
                    // 使用固定行高以启用虚拟滚动的精确偏移计算
                    itemExtent: rowHeight,
                    itemBuilder: (BuildContext context, int index) =>
                        _buildVirtualRow(data[index], index, park),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建虚拟滚动中的单行（含选择列、各列单元格与 onRow 事件）。
  Widget _buildVirtualRow(
    Map<String, dynamic> row,
    int index,
    ParkThemeData park,
  ) {
    final bool isStriped = _isStriped && index.isOdd;
    final bool isSelected = _isRowSelected(index);

    Color? rowColor;
    if (isSelected) {
      rowColor = park.colors.brand.withValues(alpha: 0.04);
    } else if (isStriped) {
      rowColor = park.colors.background;
    }

    Widget rowWidget = Container(
      color: rowColor,
      child: Row(
        children: <Widget>[
          if (widget.rowSelection != null)
            SizedBox(
              width: 48,
              child: Center(child: _buildRowSelectionWidget(index, park)),
            ),
          ...widget.columns.map(
            (ParkTableColumn col) => SizedBox(
              width: _getColumnWidth(col),
              child: _buildDataCell(col, row, park, rowIndex: index),
            ),
          ),
        ],
      ),
    );

    final Map<String, VoidCallback>? rowEvents = widget.onRow?.call(row, index);
    if (rowEvents != null) {
      rowWidget = GestureDetector(
        onTap: rowEvents['onTap'],
        onDoubleTap: rowEvents['onDoubleTap'],
        onLongPress: rowEvents['onLongPress'],
        child: rowWidget,
      );
    }

    return rowWidget;
  }

  /// 构建指定列集合的表头行（复用 [_buildHeaderCell]）。
  Widget _buildHeaderPane(
    List<ParkTableColumn> cols,
    ParkThemeData park, {
    required bool includeSelectionLeading,
  }) {
    final List<Widget> headerChildren = <Widget>[];

    if (includeSelectionLeading && widget.rowSelection != null) {
      headerChildren.add(
        SizedBox(
          width: 48,
          child: Center(
            child: widget.rowSelection!.type ==
                    ParkRowSelectionType.checkbox
                ? _buildSelectAllCheckbox(_cachedSortedData!, park)
                : const SizedBox.shrink(),
          ),
        ),
      );
    }

    if (_hasExpandedRow) {
      headerChildren.add(const SizedBox(width: 40));
    }

    for (int i = 0; i < cols.length; i++) {
      final ParkTableColumn col = cols[i];
      headerChildren.add(
        SizedBox(
          width: _getColumnWidth(col),
          child: _buildHeaderCell(
            col,
            park,
            widget.columns.indexOf(col),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: park.colors.surface),
      child: Row(children: headerChildren),
    );
  }

  /// 构建指定列集合的数据行（复用 [_buildDataCell]）。
  Widget _buildBodyPane(
    List<ParkTableColumn> cols,
    List<Map<String, dynamic>> data,
    ParkThemeData park, {
    required bool includeSelectionLeading,
  }) {
    final List<Widget> rows = <Widget>[];

    // 树形模式使用扁平化数据
    final List<_FlatTreeRow> flatRows = _isTreeMode
        ? _flattenTreeData(data)
        : List<_FlatTreeRow>.generate(
            data.length,
            (i) => _FlatTreeRow(
              data: data[i],
              depth: 0,
              key: _getRowKey(i),
              hasChildren: false,
              originalIndex: i,
            ),
          );

    for (int i = 0; i < flatRows.length; i++) {
      final flatRow = flatRows[i];
      final Map<String, dynamic> row = flatRow.data;
      final int rowIndex = flatRow.originalIndex;
      final bool isStriped = _isStriped && i.isOdd;
      final bool isSelected = _isRowSelected(rowIndex);

      Color? rowColor;
      if (isSelected) {
        rowColor = park.colors.brand.withValues(alpha: 0.04);
      } else if (isStriped) {
        rowColor = park.colors.background;
      }

      final List<Widget> cells = <Widget>[];

      if (includeSelectionLeading && widget.rowSelection != null) {
        cells.add(
          SizedBox(
            width: 48,
            child: Center(child: _buildRowSelectionWidget(rowIndex, park)),
          ),
        );
      }

      if (_hasExpandedRow) {
        cells.add(const SizedBox(width: 40));
      }

      for (final ParkTableColumn col in cols) {
        final int colIndex = widget.columns.indexOf(col);
        cells.add(
          SizedBox(
            width: _getColumnWidth(col),
            child: _buildDataCell(col, row, park,
                rowIndex: rowIndex,
                treeDepth: _isTreeMode && colIndex == 0 ? flatRow.depth : 0,
                treeHasChildren:
                    _isTreeMode && colIndex == 0 ? flatRow.hasChildren : false,
                treeRowKey: _isTreeMode ? flatRow.key : null,
                treeRecord: _isTreeMode ? row : null),
          ),
        );
      }

      rows.add(
        Container(color: rowColor, child: Row(children: cells)),
      );
      rows.add(Divider(height: 1, color: park.colors.divider));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

/// 固定列容器：提供背景填充与阴影，使其在横向滚动的内容之上可见。
class _FixedLayer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final bool shadowOnLeft;
  final bool shadowOnRight;

  const _FixedLayer({
    required this.child,
    required this.backgroundColor,
    this.shadowOnLeft = false,
    this.shadowOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final List<BoxShadow> shadows = <BoxShadow>[];
    if (shadowOnRight) {
      shadows.add(BoxShadow(
        color: park.colors.textPrimary.withValues(alpha: 0.12),
        blurRadius: 6,
        offset: const Offset(2, 0),
      ));
    }
    if (shadowOnLeft) {
      shadows.add(BoxShadow(
        color: park.colors.textPrimary.withValues(alpha: 0.12),
        blurRadius: 6,
        offset: const Offset(-2, 0),
      ));
    }
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

/// 筛选弹出对话框
///
/// 支持两种模式：
/// 1. 勾选模式：当列定义了 [ParkTableColumn.filters] 时，显示复选框列表
/// 2. 搜索模式：当列未定义 filters 时，显示文本搜索输入框
class _FilterDialog extends StatefulWidget {
  final ParkTableColumn column;
  final ParkThemeData park;
  final List<dynamic> initialValues;
  final ValueChanged<List<dynamic>> onConfirm;
  final VoidCallback onReset;

  const _FilterDialog({
    required this.column,
    required this.park,
    required this.initialValues,
    required this.onConfirm,
    required this.onReset,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late List<dynamic> _selectedValues;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selectedValues = List<dynamic>.from(widget.initialValues);
    _searchController = TextEditingController(
      text: _selectedValues.isNotEmpty ? _selectedValues.first.toString() : '',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = widget.park;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
        child: Padding(
          padding: EdgeInsets.all(park.spacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.column.title,
                style: TextStyle(
                  fontWeight: park.typography.weightBold,
                  fontSize: park.typography.sizeBody,
                  color: park.colors.textPrimary,
                ),
              ),
              SizedBox(height: park.spacing.sm),
              if (widget.column.filters != null)
                _buildCheckboxList(park)
              else
                _buildSearchInput(park),
              SizedBox(height: park.spacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _selectedValues = []);
                      widget.onReset();
                    },
                    child: Text(
                      ParkLocalizations.of(context).resetText,
                      style: TextStyle(color: park.colors.textSecondary),
                    ),
                  ),
                  SizedBox(width: park.spacing.sm),
                  FilledButton(
                    onPressed: () {
                      if (widget.column.filters != null) {
                        widget.onConfirm(_selectedValues);
                      } else {
                        final text = _searchController.text.trim();
                        widget.onConfirm(text.isEmpty ? [] : [text]);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: park.colors.brand,
                      foregroundColor: park.colors.textOnBrand,
                      minimumSize: const Size(64, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(ParkLocalizations.of(context).confirmText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxList(ParkThemeData park) {
    return Flexible(
      child: SizedBox(
        height: 240,
        child: ListView(
          shrinkWrap: true,
          children: widget.column.filters!.map((filter) {
            final isSelected = _selectedValues.contains(filter.value);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedValues.add(filter.value);
                  } else {
                    _selectedValues.remove(filter.value);
                  }
                });
              },
              title: Text(
                filter.text,
                style: TextStyle(
                  fontSize: park.typography.sizeBodySmall,
                  color: park.colors.textPrimary,
                ),
              ),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: park.colors.brand,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchInput(ParkThemeData park) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: ParkLocalizations.of(context).searchPlaceholder,
        hintStyle: TextStyle(color: park.colors.textDisabled),
        prefixIcon: Icon(Icons.search, size: 18, color: park.colors.textSecondary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: park.radius.brSm,
          borderSide: BorderSide(color: park.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: park.radius.brSm,
          borderSide: BorderSide(color: park.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: park.radius.brSm,
          borderSide: BorderSide(color: park.colors.brand, width: 1.5),
        ),
      ),
      style: TextStyle(
        fontSize: park.typography.sizeBodySmall,
        color: park.colors.textPrimary,
      ),
    );
  }
}
