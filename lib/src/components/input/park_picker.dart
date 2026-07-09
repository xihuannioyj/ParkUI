import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// 选择器选项
class ParkPickerItem {
  /// 显示文字
  final String label;

  /// 选项值
  final String value;

  /// 是否禁用。
  final bool disabled;

  const ParkPickerItem({
    required this.label,
    required this.value,
    this.disabled = false,
  });
}

/// 自定义选项构建器回调
typedef ParkPickerItemBuilder = Widget Function(
  ParkPickerItem item,
  bool isSelected,
);

/// Park 滚轮选择器
///
/// 底部弹出模态面板，使用 [CupertinoPicker] 滚轮交互，
/// 顶部带取消 / 确认操作栏。支持多列并排选择。
///
/// ```dart
/// final result = await ParkPicker.show(
///   context: context,
///   title: '选择城市',
///   items: [
///     ParkPickerItem(label: '北京', value: 'beijing'),
///     ParkPickerItem(label: '上海', value: 'shanghai'),
///   ],
///   value: 'beijing',
/// );
///
/// // 多列选择
/// final results = await ParkPicker.showMultiColumn(
///   context: context,
///   title: '选择时间',
///   columns: [
///     [ParkPickerItem(label: '09', value: '09'), ParkPickerItem(label: '10', value: '10')],
///     [ParkPickerItem(label: '00', value: '00'), ParkPickerItem(label: '30', value: '30')],
///   ],
/// );
/// ```
class ParkPicker extends StatefulWidget {
  /// 面板标题
  final String? title;

  /// 选项列表
  final List<ParkPickerItem> items;

  /// 当前选中值
  final String? value;

  /// 确认回调，返回选中的 value
  final ValueChanged<String>? onConfirm;

  /// 是否启用搜索。
  final bool searchable;

  /// 搜索框占位文案。
  final String searchHintText;

  /// 是否为多列模式。
  ///
  /// 为 true 时使用 [columns] 数据展示多个并排滚轮。
  final bool multiColumn;

  /// 多列模式下的列数据。
  ///
  /// 仅当 [multiColumn] 为 true 时有效。
  final List<List<ParkPickerItem>>? columns;

  /// 多列模式下的确认回调，返回每列选中值的列表。
  final ValueChanged<List<String>>? onMultiConfirm;

  /// 多列模式下的当前选中值列表。
  final List<String>? values;

  /// 确认按钮文字。
  ///
  /// 为 null 时使用内置默认文案 "确认"。
  final String? confirmText;

  /// 取消按钮文字。
  ///
  /// 为 null 时使用内置默认文案 "取消"。
  final String? cancelText;

  /// 自定义选项渲染器。
  ///
  /// 为 null 时使用默认文本渲染。
  final ParkPickerItemBuilder? itemBuilder;

  /// 绑定键（点号分隔的路径，如 `'pickerValue'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  const ParkPicker({
    super.key,
    this.title,
    required this.items,
    this.value,
    this.onConfirm,
    this.searchable = false,
    this.searchHintText = '搜索选项',
    this.multiColumn = false,
    this.columns,
    this.onMultiConfirm,
    this.values,
    this.confirmText,
    this.cancelText,
    this.itemBuilder,
    this.bindKey,
    this.bindingService,
  });

  /// 弹出选择器面板
  ///
  /// 返回用户确认选中的 value，取消时返回 null。
  static Future<String?> show(
    BuildContext context, {
    String? title,
    required List<ParkPickerItem> items,
    String? value,
    ValueChanged<String>? onConfirm,
    bool searchable = false,
    String searchHintText = '搜索选项',
    String? confirmText,
    String? cancelText,
    ParkPickerItemBuilder? itemBuilder,
    String? bindKey,
    ParkBindingService? bindingService,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ParkPickerSheet(
          title: title,
          items: items,
          value: value,
          onConfirm: onConfirm,
          searchable: searchable,
          searchHintText: searchHintText,
          confirmText: confirmText,
          cancelText: cancelText,
          itemBuilder: itemBuilder,
          bindKey: bindKey,
          bindingService: bindingService,
        );
      },
    );
  }

  /// 弹出多列选择器面板
  ///
  /// 返回用户确认选中的各列 value 列表，取消时返回 null。
  static Future<List<String>?> showMultiColumn(
    BuildContext context, {
    String? title,
    required List<List<ParkPickerItem>> columns,
    List<String>? values,
    ValueChanged<List<String>>? onConfirm,
    String? confirmText,
    String? cancelText,
    ParkPickerItemBuilder? itemBuilder,
    String? bindKey,
    ParkBindingService? bindingService,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ParkPickerSheet(
          title: title,
          items: const [],
          multiColumn: true,
          columns: columns,
          values: values,
          onMultiConfirm: onConfirm,
          confirmText: confirmText,
          cancelText: cancelText,
          itemBuilder: itemBuilder,
          searchable: false,
          searchHintText: '',
          bindKey: bindKey,
          bindingService: bindingService,
        );
      },
    );
  }

  @override
  State<ParkPicker> createState() => _ParkPickerState();
}

class _ParkPickerState extends State<ParkPicker> {
  @override
  Widget build(BuildContext context) {
    return _ParkPickerSheet(
      title: widget.title,
      items: widget.items,
      value: widget.value,
      onConfirm: widget.onConfirm,
      searchable: widget.searchable,
      searchHintText: widget.searchHintText,
      multiColumn: widget.multiColumn,
      columns: widget.columns,
      values: widget.values,
      onMultiConfirm: widget.onMultiConfirm,
      confirmText: widget.confirmText,
      cancelText: widget.cancelText,
      itemBuilder: widget.itemBuilder,
      bindKey: widget.bindKey,
      bindingService: widget.bindingService,
    );
  }
}

/// 内部：底部弹出面板
class _ParkPickerSheet extends StatefulWidget {
  final String? title;
  final List<ParkPickerItem> items;
  final String? value;
  final ValueChanged<String>? onConfirm;
  final bool searchable;
  final String searchHintText;
  final bool multiColumn;
  final List<List<ParkPickerItem>>? columns;
  final List<String>? values;
  final ValueChanged<List<String>>? onMultiConfirm;
  final String? confirmText;
  final String? cancelText;
  final ParkPickerItemBuilder? itemBuilder;
  final String? bindKey;
  final ParkBindingService? bindingService;

  const _ParkPickerSheet({
    this.title,
    required this.items,
    this.value,
    this.onConfirm,
    required this.searchable,
    required this.searchHintText,
    this.multiColumn = false,
    this.columns,
    this.values,
    this.onMultiConfirm,
    this.confirmText,
    this.cancelText,
    this.itemBuilder,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<_ParkPickerSheet> createState() => _ParkPickerSheetState();
}

class _ParkPickerSheetState extends State<_ParkPickerSheet>
    with BindableWidgetMixin<String, _ParkPickerSheet> {
  late FixedExtentScrollController _scrollController;
  late List<FixedExtentScrollController> _multiScrollControllers;
  late int _selectedIndex;
  late List<int> _multiSelectedIndexes;
  String _keyword = '';

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    if (widget.multiColumn && widget.columns != null) {
      _multiSelectedIndexes = List<int>.generate(
        widget.columns!.length,
        (col) => _findColumnIndex(col, widget.values),
      );
      _multiScrollControllers = List<FixedExtentScrollController>.generate(
        widget.columns!.length,
        (col) => FixedExtentScrollController(
          initialItem: _multiSelectedIndexes[col],
        ),
      );
      _scrollController = FixedExtentScrollController(initialItem: 0);
      _selectedIndex = 0;
    } else {
      _selectedIndex = _findIndex(widget.value);
      _scrollController = FixedExtentScrollController(
        initialItem: _selectedIndex,
      );
      _multiScrollControllers = [];
      _multiSelectedIndexes = [];
    }
  }

  int _findIndex(String? value) {
    if (value == null) return 0;
    final idx = widget.items.indexWhere((item) => item.value == value);
    return idx >= 0 ? idx : 0;
  }

  int _findColumnIndex(int col, List<String>? values) {
    if (values == null || col >= values.length) return 0;
    final cols = widget.columns!;
    if (col >= cols.length) return 0;
    final idx = cols[col].indexWhere((item) => item.value == values[col]);
    return idx >= 0 ? idx : 0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final c in _multiScrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final double pickerHeight = widget.title == null ? 200 : 180;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部操作栏
            _buildHeader(park),

            // 分割线
            Divider(height: 1, color: colors.divider),

            if (!widget.multiColumn && widget.searchable)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  spacing.sm,
                  spacing.base,
                  spacing.xs,
                ),
                child: TextField(
                  onChanged: (String value) {
                    setState(() {
                      _keyword = value;
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: widget.searchHintText,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.md),
                    ),
                  ),
                ),
              ),

            // 滚轮选择器
            Flexible(
              child: SizedBox(
                height: pickerHeight,
                child: widget.multiColumn
                    ? _buildMultiColumnPicker(park)
                    : _buildSingleColumnPicker(park, typo, colors),
              ),
            ),

            // 底部间距
            SizedBox(height: spacing.base),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleColumnPicker(
    ParkThemeData park,
    dynamic typo,
    dynamic colors,
  ) {
    final List<ParkPickerItem> visibleItems = _keyword.trim().isEmpty
        ? widget.items
        : widget.items
              .where(
                (ParkPickerItem item) =>
                    item.label.toLowerCase().contains(
                      _keyword.trim().toLowerCase(),
                    ) ||
                    item.value.toLowerCase().contains(
                      _keyword.trim().toLowerCase(),
                    ),
              )
              .toList();

    if (_selectedIndex >= visibleItems.length) {
      _selectedIndex = visibleItems.isEmpty ? 0 : visibleItems.length - 1;
    }

    if (visibleItems.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textPlaceholder,
          ),
        ),
      );
    }

    return CupertinoPicker(
      scrollController: _scrollController,
      itemExtent: 40,
      onSelectedItemChanged: (index) {
        _selectedIndex = index;
      },
      children: visibleItems.map((item) {
        final isSelected =
            visibleItems.indexOf(item) == _selectedIndex;
        if (widget.itemBuilder != null) {
          return widget.itemBuilder!(item, isSelected);
        }
        return Center(
          child: Text(
            item.disabled ? '${item.label}（禁用）' : item.label,
            style: TextStyle(
              fontSize: park.typography.sizeBody,
              color: item.disabled
                  ? park.colors.textDisabled
                  : park.colors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiColumnPicker(ParkThemeData park) {
    final cols = widget.columns ?? [];
    if (cols.isEmpty) {
      return Center(
        child: Text(
          '暂无数据',
          style: TextStyle(
            fontSize: park.typography.sizeBodySmall,
            color: park.colors.textPlaceholder,
          ),
        ),
      );
    }

    return Row(
      children: List.generate(cols.length, (colIdx) {
        return Expanded(
          child: CupertinoPicker(
            scrollController: _multiScrollControllers[colIdx],
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              _multiSelectedIndexes[colIdx] = index;
            },
            children: cols[colIdx].map((item) {
              final isSelected =
                  cols[colIdx].indexOf(item) == _multiSelectedIndexes[colIdx];
              if (widget.itemBuilder != null) {
                return widget.itemBuilder!(item, isSelected);
              }
              return Center(
                child: Text(
                  item.disabled ? '${item.label}（禁用）' : item.label,
                  style: TextStyle(
                    fontSize: park.typography.sizeBody,
                    color: item.disabled
                        ? park.colors.textDisabled
                        : park.colors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    final cancelLabel = widget.cancelText ?? '取消';
    final confirmLabel = widget.confirmText ?? '确认';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.base,
        vertical: spacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              cancelLabel,
              style: TextStyle(
                fontSize: typo.sizeBody,
                color: colors.textSecondary,
              ),
            ),
          ),

          // 标题
          if (widget.title != null)
            Text(
              widget.title!,
              style: TextStyle(
                fontSize: typo.sizeH3,
                fontWeight: typo.weightMedium,
                color: colors.textPrimary,
              ),
            )
          else
            const SizedBox.shrink(),

          // 确认按钮
          GestureDetector(
            onTap: () {
              if (widget.multiColumn) {
                _handleMultiColumnConfirm();
              } else {
                _handleSingleColumnConfirm();
              }
            },
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontSize: typo.sizeBody,
                color: colors.brand,
                fontWeight: typo.weightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSingleColumnConfirm() {
    final List<ParkPickerItem> visibleItems = _keyword.trim().isEmpty
        ? widget.items
        : widget.items
              .where(
                (ParkPickerItem item) =>
                    item.label.toLowerCase().contains(
                      _keyword.trim().toLowerCase(),
                    ) ||
                    item.value.toLowerCase().contains(
                      _keyword.trim().toLowerCase(),
                    ),
              )
              .toList();
    if (visibleItems.isEmpty) return;
    final selected = visibleItems[_selectedIndex];
    if (selected.disabled) return;
    widget.onConfirm?.call(selected.value);
    boundValue = selected.value;
    Navigator.of(context).pop(selected.value);
  }

  void _handleMultiColumnConfirm() {
    final cols = widget.columns ?? [];
    if (cols.isEmpty) return;
    final result = <String>[];
    for (int i = 0; i < cols.length; i++) {
      if (i < _multiSelectedIndexes.length &&
          _multiSelectedIndexes[i] < cols[i].length) {
        result.add(cols[i][_multiSelectedIndexes[i]].value);
      } else if (cols[i].isNotEmpty) {
        result.add(cols[i][0].value);
      }
    }
    widget.onMultiConfirm?.call(result);
    Navigator.of(context).pop(result);
  }
}
