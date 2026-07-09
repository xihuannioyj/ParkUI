import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';

/// ParkCalendar 模式
enum ParkCalendarMode {
  /// 单日选择
  single,

  /// 范围选择
  range,

  /// 多选
  multiple,
}

/// ParkCalendar — 日历组件
///
/// 支持单日、范围、多选三种模式，可设置最小/最大日期范围，
/// 支持禁用特定日期。
///
/// ```dart
/// ParkCalendar(
///   mode: ParkCalendarMode.single,
///   value: DateTime.now(),
///   onChanged: (date) => print(date),
/// )
/// ```
class ParkCalendar extends StatefulWidget {
  /// 当前选中日期（single 模式）
  final DateTime? value;

  /// 当前选中范围（range 模式）
  final DateTimeRange? rangeValue;

  /// 当前多选日期（multiple 模式）
  final List<DateTime>? multipleValues;

  /// 单日选择变更回调
  final ValueChanged<DateTime>? onChanged;

  /// 范围选择变更回调
  final ValueChanged<DateTimeRange>? onRangeChanged;

  /// 多选变更回调
  final ValueChanged<List<DateTime>>? onMultipleChanged;

  /// 选择模式
  final ParkCalendarMode mode;

  /// 最早可选日期
  final DateTime? minDate;

  /// 最晚可选日期
  final DateTime? maxDate;

  /// 是否显示今日高亮
  final bool showToday;

  /// 禁用的日期列表
  final List<DateTime>? disabledDates;

  /// 自定义日期单元格渲染器。
  /// 当提供时替换默认的日期单元格 Widget。
  final Widget Function(DateTime date, bool isSelected, bool isToday, bool isDisabled)? cellBuilder;

  /// 动态禁用日期回调，返回 true 的日期不可选。
  /// 与静态 [disabledDates] 列表叠加生效。
  final bool Function(DateTime)? disabledDate;

  /// 每周的第一天：0=周日, 1=周一, ..., 6=周六。默认 1（周一）。
  final int firstDayOfWeek;

  /// 自定义月份导航头部。
  /// 当提供时替换默认的年月标题和前后箭头。
  final Widget Function(DateTime currentMonth, VoidCallback onPrev, VoidCallback onNext)? headerBuilder;

  /// 面板月份变更回调（用户翻页时触发）。
  final ValueChanged<DateTime>? onPanelChange;

  /// 绑定键（点号分隔的路径，如 `'selectedDate'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  const ParkCalendar({
    super.key,
    this.value,
    this.rangeValue,
    this.multipleValues,
    this.onChanged,
    this.onRangeChanged,
    this.onMultipleChanged,
    this.mode = ParkCalendarMode.single,
    this.minDate,
    this.maxDate,
    this.showToday = true,
    this.disabledDates,
    this.cellBuilder,
    this.disabledDate,
    this.firstDayOfWeek = 1,
    this.headerBuilder,
    this.onPanelChange,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkCalendar> createState() => _ParkCalendarState();
}

class _ParkCalendarState extends State<ParkCalendar>
    with BindableWidgetMixin<dynamic, ParkCalendar> {
  late DateTime _displayMonth;
  DateTimeRange? _tempRange;
  late List<DateTime> _tempMultiple;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _displayMonth = widget.value ?? DateTime.now();
    _tempRange = widget.rangeValue;
    _tempMultiple = widget.multipleValues != null
        ? List<DateTime>.from(widget.multipleValues!)
        : [];
    // 从 bindable 读取初始值
    final initialValue = boundValue;
    if (initialValue != null) {
      if (widget.mode == ParkCalendarMode.single && initialValue is DateTime) {
        _displayMonth = initialValue;
      } else if (widget.mode == ParkCalendarMode.range &&
          initialValue is DateTimeRange) {
        _tempRange = initialValue;
      } else if (widget.mode == ParkCalendarMode.multiple &&
          initialValue is List) {
        _tempMultiple = List<DateTime>.from(initialValue);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ParkCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rangeValue != oldWidget.rangeValue) {
      _tempRange = widget.rangeValue;
    }
    if (widget.multipleValues != oldWidget.multipleValues) {
      _tempMultiple = widget.multipleValues != null
          ? List<DateTime>.from(widget.multipleValues!)
          : [];
    }
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month - 1,
        1,
      );
    });
    widget.onPanelChange?.call(_displayMonth);
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(
        _displayMonth.year,
        _displayMonth.month + 1,
        1,
      );
    });
    widget.onPanelChange?.call(_displayMonth);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  bool _isDisabled(DateTime date) {
    if (widget.minDate != null &&
        date.isBefore(_stripTime(widget.minDate!))) {
      return true;
    }
    if (widget.maxDate != null &&
        date.isAfter(_stripTime(widget.maxDate!))) {
      return true;
    }
    if (widget.disabledDates != null) {
      if (widget.disabledDates!.any((d) => _isSameDay(d, date))) {
        return true;
      }
    }
    if (widget.disabledDate != null && widget.disabledDate!(date)) {
      return true;
    }
    return false;
  }

  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSelected(DateTime date) {
    switch (widget.mode) {
      case ParkCalendarMode.single:
        return widget.value != null && _isSameDay(date, widget.value!);
      case ParkCalendarMode.range:
        if (_tempRange == null) return false;
        return _isSameDay(date, _tempRange!.start) ||
            _isSameDay(date, _tempRange!.end);
      case ParkCalendarMode.multiple:
        return _tempMultiple.any((d) => _isSameDay(d, date));
    }
  }

  bool _isInRange(DateTime date) {
    if (widget.mode != ParkCalendarMode.range || _tempRange == null) {
      return false;
    }
    final start = _stripTime(_tempRange!.start);
    final end = _stripTime(_tempRange!.end);
    final d = _stripTime(date);
    return d.isAfter(start) && d.isBefore(end);
  }

  void _onDateTap(DateTime date) {
    if (_isDisabled(date)) return;

    switch (widget.mode) {
      case ParkCalendarMode.single:
        widget.onChanged?.call(date);
        boundValue = date;
      case ParkCalendarMode.range:
        if (_tempRange == null ||
            (_tempRange!.start == _tempRange!.end &&
                !_isSameDay(date, _tempRange!.start))) {
          // Start new range: if tapping same date, set as both start and end
          _tempRange = DateTimeRange(start: date, end: date);
          widget.onRangeChanged?.call(_tempRange!);
          boundValue = _tempRange;
        } else if (_isSameDay(date, _tempRange!.start)) {
          // Tapped start again, reset
          _tempRange = DateTimeRange(start: date, end: date);
          widget.onRangeChanged?.call(_tempRange!);
          boundValue = _tempRange;
        } else {
          // Complete range
          final start = _tempRange!.start;
          final range = date.isBefore(start)
              ? DateTimeRange(start: date, end: start)
              : DateTimeRange(start: start, end: date);
          _tempRange = range;
          widget.onRangeChanged?.call(range);
          boundValue = range;
          // Reset for next selection
          Future<void>.delayed(ParkMotion.slow, () {
            if (mounted) {
              setState(() => _tempRange = null);
            }
          });
        }
        setState(() {});
      case ParkCalendarMode.multiple:
        final existing = _tempMultiple.indexWhere((d) => _isSameDay(d, date));
        if (existing >= 0) {
          _tempMultiple.removeAt(existing);
        } else {
          _tempMultiple.add(date);
        }
        widget.onMultipleChanged?.call(List<DateTime>.from(_tempMultiple));
        boundValue = List<DateTime>.from(_tempMultiple);
        setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;

    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Compute weekday labels and grid offset based on firstDayOfWeek
    // firstDayOfWeek: 0=Sun, 1=Mon, ..., 6=Sat
    // DateTime.weekday: 1=Mon ... 7=Sun
    // Convert to 0=Sun convention: dayOfWeek = weekday % 7
    const allWeekLabels = ['日', '一', '二', '三', '四', '五', '六'];
    final weekLabels = List<String>.generate(
      7,
      (i) => allWeekLabels[(widget.firstDayOfWeek + i) % 7],
    );

    final firstDayOfWeek0 = firstDay.weekday % 7; // 0=Sun
    final startWeekday =
        (firstDayOfWeek0 - widget.firstDayOfWeek + 7) % 7;

    // Header
    Widget header;
    if (widget.headerBuilder != null) {
      header = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.sm,
        ),
        child: widget.headerBuilder!(_displayMonth, _prevMonth, _nextMonth),
      );
    } else {
      header = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: _prevMonth,
              child: Icon(
                Icons.chevron_left,
                color: colors.textSecondary,
                size: 24,
              ),
            ),
            Text(
              '$year年${month.toString().padLeft(2, '0')}月',
              style: TextStyle(
                fontSize: typo.sizeBody,
                fontWeight: typo.weightMedium,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: _nextMonth,
              child: Icon(
                Icons.chevron_right,
                color: colors.textSecondary,
                size: 24,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: month navigation
        header,

        // Weekday labels
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
          child: Row(
            children: weekLabels
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: typo.sizeCaption,
                          color: colors.textSecondary,
                          fontWeight: typo.weightMedium,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        SizedBox(height: spacing.xs),

        // Days grid
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.xs),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return const SizedBox.shrink();
              }

              final day = index - startWeekday + 1;
              final date = DateTime(year, month, day);
              final isDisabled = _isDisabled(date);
              final isSelected = _isSelected(date);
              final isToday = widget.showToday && _isToday(date);

              // Use custom cellBuilder if provided
              if (widget.cellBuilder != null) {
                return GestureDetector(
                  onTap: isDisabled ? null : () => _onDateTap(date),
                  behavior: HitTestBehavior.opaque,
                  child: widget.cellBuilder!(date, isSelected, isToday, isDisabled),
                );
              }

              final isInRange = _isInRange(date);

              Color bgColor;
              Color textColor;

              if (isDisabled) {
                bgColor = Colors.transparent;
                textColor = colors.textDisabled;
              } else if (isSelected) {
                bgColor = colors.brand;
                textColor = colors.textOnBrand;
              } else if (isInRange) {
                bgColor = colors.brand.withValues(alpha: 0.1);
                textColor = colors.brand;
              } else {
                bgColor = Colors.transparent;
                textColor = colors.textPrimary;
              }

              return GestureDetector(
                onTap: isDisabled ? null : () => _onDateTap(date),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: radius.brSm,
                    border: isToday && !isSelected
                        ? Border.all(color: colors.brand, width: 1)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: typo.sizeBodySmall,
                      color: textColor,
                      fontWeight: isSelected
                          ? typo.weightBold
                          : typo.weightRegular,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
