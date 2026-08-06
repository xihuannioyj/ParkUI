import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import 'park_picker.dart';

/// 可内嵌裸滚轮选择器（非模态，直接嵌入页面布局）。
///
/// 支持多列联动、外部确认头部、实时区间校验。
/// 与 [ParkPicker] 不同，本组件不弹出模态面板，而是直接嵌入页面布局中。
///
/// ```dart
/// ParkInlinePicker(
///   columns: [
///     [ParkPickerItem(label: '08', value: '08'), ParkPickerItem(label: '09', value: '09')],
///     [ParkPickerItem(label: '00', value: '00'), ParkPickerItem(label: '30', value: '30')],
///     [ParkPickerItem(label: '00', value: '00'), ParkPickerItem(label: '15', value: '15')],
///   ],
///   values: ['09', '00', '00'],
///   onChanged: (values) => print('选中: $values'),
///   onValidate: (values) {
///     // 实时区间校验
///     if (values[0] == '08' && values[1] == '00') return '开始时间不能早于 08:00';
///     return null;
///   },
///   header: Row(
///     mainAxisAlignment: MainAxisAlignment.end,
///     children: [TextButton(onPressed: () {}, child: Text('确认'))],
///   ),
/// )
/// ```
class ParkInlinePicker extends StatefulWidget {
  const ParkInlinePicker({
    super.key,
    required this.columns,
    this.values,
    this.onChanged,
    this.onValidate,
    this.header,
    this.maxHeight = 280.0,
    this.itemHeight = 40.0,
    this.visibleItemCount = 5,
    this.bindKey,
    this.bindingService,
  });

  /// 多列数据源
  final List<List<ParkPickerItem>> columns;

  /// 当前选中值（每列一个）
  final List<String>? values;

  /// 选中变化回调（实时触发）
  final ValueChanged<List<String>>? onChanged;

  /// 实时区间校验回调，返回错误信息则显示提示，返回 null 则通过
  final String? Function(List<String> values)? onValidate;

  /// 外部确认头部 slot（共享确认按钮等）
  final Widget? header;

  /// 最大高度限制（高度自适应但不超过此值）
  final double maxHeight;

  /// 每项高度
  final double itemHeight;

  /// 可见项数
  final int visibleItemCount;

  /// 绑定键（点号分隔的路径，如 `'timeRange'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  @override
  State<ParkInlinePicker> createState() => _ParkInlinePickerState();
}

class _ParkInlinePickerState extends State<ParkInlinePicker>
    with BindableWidgetMixin<List<String>, ParkInlinePicker> {
  late List<FixedExtentScrollController> _controllers;
  late List<int> _selectedIndexes;
  String? _validationError;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _selectedIndexes = List<int>.generate(
      widget.columns.length,
      (col) => _findColumnIndex(col, widget.values),
    );
    _controllers = List<FixedExtentScrollController>.generate(
      widget.columns.length,
      (col) => FixedExtentScrollController(
        initialItem: _selectedIndexes[col],
      ),
    );
    // 初始校验
    _validationError = widget.onValidate?.call(_currentValues());
  }

  @override
  void didUpdateWidget(covariant ParkInlinePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部 values 变化时同步内部状态
    if (widget.values != oldWidget.values && widget.values != null) {
      final newIndexes = List<int>.generate(
        widget.columns.length,
        (col) => _findColumnIndex(col, widget.values),
      );
      bool changed = false;
      for (int i = 0; i < newIndexes.length; i++) {
        if (i >= _selectedIndexes.length || newIndexes[i] != _selectedIndexes[i]) {
          changed = true;
          break;
        }
      }
      if (changed) {
        setState(() {
          _selectedIndexes = newIndexes;
          for (int i = 0; i < _controllers.length && i < newIndexes.length; i++) {
            if (_controllers[i].hasClients) {
              _controllers[i].jumpToItem(newIndexes[i]);
            }
          }
        });
        _validationError = widget.onValidate?.call(_currentValues());
      }
    }
  }

  int _findColumnIndex(int col, List<String>? values) {
    if (values == null || col >= values.length) return 0;
    if (col >= widget.columns.length) return 0;
    final idx =
        widget.columns[col].indexWhere((item) => item.value == values[col]);
    return idx >= 0 ? idx : 0;
  }

  List<String> _currentValues() {
    final result = <String>[];
    for (int i = 0; i < widget.columns.length; i++) {
      if (i < _selectedIndexes.length &&
          _selectedIndexes[i] < widget.columns[i].length) {
        result.add(widget.columns[i][_selectedIndexes[i]].value);
      } else if (widget.columns[i].isNotEmpty) {
        result.add(widget.columns[i][0].value);
      }
    }
    return result;
  }

  void _onColumnChanged(int colIdx, int index) {
    setState(() {
      _selectedIndexes[colIdx] = index;
    });
    final values = _currentValues();
    widget.onChanged?.call(values);
    boundValue = values;
    // 实时校验
    setState(() {
      _validationError = widget.onValidate?.call(values);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
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
    final spacing = park.spacing;

    final double pickerHeight = widget.itemHeight * widget.visibleItemCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 外部确认头部 slot
        if (widget.header != null) widget.header!,

        // 滚轮区域
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: SizedBox(
            height: pickerHeight,
            child: widget.columns.isEmpty
                ? Center(
                    child: Text(
                      '暂无数据',
                      style: TextStyle(
                        fontSize: typo.sizeBodySmall,
                        color: colors.textPlaceholder,
                      ),
                    ),
                  )
                : Row(
                    children: List.generate(widget.columns.length, (colIdx) {
                      return Expanded(
                        child: CupertinoPicker(
                          scrollController: colIdx < _controllers.length
                              ? _controllers[colIdx]
                              : FixedExtentScrollController(),
                          itemExtent: widget.itemHeight,
                          onSelectedItemChanged: (index) =>
                              _onColumnChanged(colIdx, index),
                          selectionOverlay:
                              CupertinoPickerDefaultSelectionOverlay(
                            background: colors.surface,
                          ),
                          children: widget.columns[colIdx].map((item) {
                            return Center(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: typo.sizeBody,
                                  color: item.disabled
                                      ? colors.textDisabled
                                      : colors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),
          ),
        ),

        // 校验错误提示
        if (_validationError != null)
          Padding(
            padding: EdgeInsets.only(
              top: spacing.xs,
              left: spacing.base,
              right: spacing.base,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _validationError!,
                style: TextStyle(
                  fontSize: typo.sizeBodySmall,
                  color: colors.error,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
