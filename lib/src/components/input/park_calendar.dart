import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';
import '../../l10n/park_localizations.dart';

/// ParkCalendar 模式（旧 API，内部使用）。
///
/// 新代码请使用 [ParkCalendarSelectionMode]。
@Deprecated('Use ParkCalendarSelectionMode instead')
enum ParkCalendarMode {
  /// 单日选择
  single,

  /// 范围选择
  range,

  /// 多选
  multiple,
}

/// ParkCalendar 选择模式。
///
/// 提供选择模式定义：
/// - [single]：单日选择（默认）
/// - [range]：范围选择
enum ParkCalendarSelectionMode {
  /// 单日选择
  single,

  /// 范围选择
  range,
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

  /// 选择模式（旧 API）
  final ParkCalendarMode mode;

  /// 选择模式（新 API）。
  /// 当为 [ParkCalendarSelectionMode.range] 时，使用 [rangeStart]/[rangeEnd]/[onRangeChange]。
  /// 默认 [ParkCalendarSelectionMode.single] 时行为与旧 API 完全一致。
  final ParkCalendarSelectionMode selectionMode;

  /// 范围选择开始日期（新 API，配合 [selectionMode] = range 使用）
  final DateTime? rangeStart;

  /// 范围选择结束日期（新 API，配合 [selectionMode] = range 使用）
  final DateTime? rangeEnd;

  /// 范围变化回调（新 API）。
  /// 返回当前选中的开始/结束日期。
  final void Function(DateTime? start, DateTime? end)? onRangeChange;

  /// 最早可选日期
  final DateTime? minDate;

  /// 最晚可选日期
  final DateTime? maxDate;

  /// 是否显示今日高亮
  final bool showToday;

  /// 禁用的日期列表
  final List<DateTime>? disabledDates;

  /// 自定义日期单元格渲染器（旧 API）。
  /// 当提供时替换默认的日期单元格 Widget。
  final Widget Function(DateTime date, bool isSelected, bool isToday, bool isDisabled)? cellBuilder;

  /// 自定义日期单元格渲染器（新 API）。
  /// 提供 (date, isSelected, isInRange, isRangeStart, isRangeEnd) 五个参数，
  /// 返回的 Widget 替代默认日期数字文本。
  /// 与 [cellBuilder] 同时设置时，[cellRender] 优先。
  final Widget Function(
    DateTime date,
    bool isSelected,
    bool isInRange,
    bool isRangeStart,
    bool isRangeEnd,
  )? cellRender;

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
    this.selectionMode = ParkCalendarSelectionMode.single,
    this.rangeStart,
    this.rangeEnd,
    this.onRangeChange,
    this.minDate,
    this.maxDate,
    this.showToday = true,
    this.disabledDates,
    this.cellBuilder,
    this.cellRender,
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

/// 用于绘制虚线边框的自定义画笔
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  _DashedBorderPainter({
    required this.color,
    // ignore: unused_element_parameter
    this.strokeWidth = 1.0,
    // ignore: unused_element_parameter
    this.dashWidth = 3.0,
    // ignore: unused_element_parameter
    this.dashGap = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final segmentPath = metric.extractPath(distance, end);
        canvas.drawPath(segmentPath, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashGap != dashGap;
}

class _ParkCalendarState extends State<ParkCalendar>
    with BindableWidgetMixin<dynamic, ParkCalendar> {
  late DateTime _displayMonth;
  DateTimeRange? _tempRange;
  late List<DateTime> _tempMultiple;
  DateTime? _hoveredDate;

  /// 是否使用新 API 的 range 模式
  bool get _isNewRangeMode =>
      widget.selectionMode == ParkCalendarSelectionMode.range;

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
    if (widget.value != oldWidget.value && widget.value != null) {
      setState(() {
        _displayMonth = DateTime(widget.value!.year, widget.value!.month);
      });
    }
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
    if (_isNewRangeMode) {
      return (widget.rangeStart != null &&
              _isSameDay(date, widget.rangeStart!)) ||
          (widget.rangeEnd != null && _isSameDay(date, widget.rangeEnd!));
    }
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
    if (_isNewRangeMode) {
      final start = widget.rangeStart;
      final end = widget.rangeEnd;
      if (start == null || end == null) return false;
      final d = _stripTime(date);
      final s = _stripTime(start);
      final e = _stripTime(end);
      return d.isAfter(s) && d.isBefore(e);
    }
    if (widget.mode != ParkCalendarMode.range || _tempRange == null) {
      return false;
    }
    final start = _stripTime(_tempRange!.start);
    final end = _stripTime(_tempRange!.end);
    final d = _stripTime(date);
    return d.isAfter(start) && d.isBefore(end);
  }

  bool _isRangeStart(DateTime date) {
    if (!_isNewRangeMode || widget.rangeStart == null) return false;
    return _isSameDay(date, widget.rangeStart!);
  }

  bool _isRangeEnd(DateTime date) {
    if (!_isNewRangeMode || widget.rangeEnd == null) return false;
    return _isSameDay(date, widget.rangeEnd!);
  }

  /// 当前日期是否在范围内部但没有选中开始/结束
  bool _isRangeMiddle(DateTime date) {
    return _isInRange(date) && !_isRangeStart(date) && !_isRangeEnd(date);
  }

  /// 日期是否处于选择中的 hover 状态（新 range 模式下，
  /// 已选开始日期、尚未选结束日期时，hover 的中间日期）
  bool _isHoveringInRange(DateTime date) {
    if (!_isNewRangeMode || _hoveredDate == null) return false;
    final start = widget.rangeStart;
    final end = widget.rangeEnd;
    // 只在已选开始、未选结束、hover 有效时显示
    if (start == null || end != null) return false;
    final s = _stripTime(start);
    final h = _stripTime(_hoveredDate!);
    final d = _stripTime(date);
    final minDay = s.isBefore(h) ? s : h;
    final maxDay = s.isAfter(h) ? s : h;
    return d.isAfter(minDay) && d.isBefore(maxDay) && !_isDisabled(date);
  }

  void _onDateTap(DateTime date) {
    if (_isDisabled(date)) return;

    // 新 API range 模式
    if (_isNewRangeMode) {
      final start = widget.rangeStart;
      final end = widget.rangeEnd;
      if (start == null || end != null) {
        // 开始新选择：设置 rangeStart，清空 rangeEnd
        widget.onRangeChange?.call(date, null);
      } else {
        // 完成范围选择：设置 rangeEnd，确保 start < end
        final range = date.isBefore(start)
            ? DateTimeRange(start: date, end: start)
            : DateTimeRange(start: start, end: date);
        widget.onRangeChange?.call(range.start, range.end);
      }
      return;
    }

    // 旧 API 逻辑
    switch (widget.mode) {
      case ParkCalendarMode.single:
        widget.onChanged?.call(date);
        boundValue = date;
      case ParkCalendarMode.range:
        if (_tempRange == null ||
            (_tempRange!.start == _tempRange!.end &&
                !_isSameDay(date, _tempRange!.start))) {
          // Start new range
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
          Future<void>.delayed(ParkMotion.defaults.slow, () {
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

  void _onHoverDate(DateTime? date) {
    if (_isNewRangeMode && widget.rangeStart != null && widget.rangeEnd == null) {
      setState(() => _hoveredDate = date);
    } else if (_hoveredDate != null) {
      setState(() => _hoveredDate = null);
    }
  }

  /// 构建日期单元格的语义标签
  String _dateSemanticsLabel(DateTime date, bool isDisabled) {
    if (isDisabled) return 'disabled';
    final l10n = ParkLocalizations.of(context);
    final dateStr = l10n.dateSemanticFormat(date.year, date.month, date.day);
    if (_isNewRangeMode) {
      if (_isRangeStart(date)) return '${l10n.rangeStartSemantic} $dateStr';
      if (_isRangeEnd(date)) return '${l10n.rangeEndSemantic} $dateStr';
      if (_isInRange(date)) return '${l10n.rangeMiddleSemantic} $dateStr';
    }
    return dateStr;
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
    final l10n = ParkLocalizations.of(context);
    final allWeekLabels = [
      l10n.weekdaySun,
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
    ];
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
              child: Semantics(
                label: ParkLocalizations.of(context).previousStep,
                child: Icon(
                  Icons.chevron_left,
                  color: colors.textSecondary,
                  size: 24,
                ),
              ),
            ),
            Text(
              ParkLocalizations.of(context).formatYearMonth(year, month),
              style: TextStyle(
                fontSize: typo.sizeBody,
                fontWeight: typo.weightMedium,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: _nextMonth,
              child: Semantics(
                label: ParkLocalizations.of(context).nextStep,
                child: Icon(
                  Icons.chevron_right,
                  color: colors.textSecondary,
                  size: 24,
                ),
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
              final isInRange = _isInRange(date);
              final isRangeStart = _isRangeStart(date);
              final isRangeEnd = _isRangeEnd(date);
              final isRangeMiddle = _isRangeMiddle(date);
              final isHoveringInRange = _isHoveringInRange(date);

              // Use cellRender if provided (new API)
              if (widget.cellRender != null) {
                return GestureDetector(
                  onTap: isDisabled ? null : () => _onDateTap(date),
                  behavior: HitTestBehavior.opaque,
                  child: MouseRegion(
                    onEnter: (_) => _onHoverDate(date),
                    onExit: (_) => _onHoverDate(null),
                    child: Semantics(
                      label: _dateSemanticsLabel(date, isDisabled),
                      selected: isSelected,
                      enabled: !isDisabled,
                      child: widget.cellRender!(
                        date,
                        isSelected,
                        isInRange,
                        isRangeStart,
                        isRangeEnd,
                      ),
                    ),
                  ),
                );
              }

              // Use custom cellBuilder if provided (old API)
              if (widget.cellBuilder != null) {
                return GestureDetector(
                  onTap: isDisabled ? null : () => _onDateTap(date),
                  behavior: HitTestBehavior.opaque,
                  child: Semantics(
                    label: _dateSemanticsLabel(date, isDisabled),
                    selected: isSelected,
                    enabled: !isDisabled,
                    child: widget.cellBuilder!(date, isSelected, isToday, isDisabled),
                  ),
                );
              }

              // 默认渲染
              final isRangeMode = _isNewRangeMode && widget.rangeStart != null;

              // 选择中 hover 态的虚线边框（只在新 range 模式开始后、结束前展示）
              final showDashedBorder = isRangeMode &&
                  !isDisabled &&
                  ((isRangeMiddle && isHoveringInRange) ||
                      (isRangeStart && widget.rangeEnd == null && _hoveredDate != null));

              // 选择中 hover 态的中间日期背景
              final showHoverBackground = isRangeMode &&
                  !isDisabled &&
                  !isRangeStart &&
                  !isRangeEnd &&
                  isHoveringInRange;

              Color bgColor;
              Color textColor;

              if (isDisabled) {
                bgColor = Colors.transparent;
                textColor = colors.textDisabled;
              } else if (isRangeStart || isRangeEnd) {
                bgColor = colors.brand;
                textColor = colors.textOnBrand;
              } else if (isRangeMiddle) {
                bgColor = colors.brand.withValues(alpha: 0.1);
                textColor = colors.brand;
              } else if (isSelected) {
                bgColor = colors.brand;
                textColor = colors.textOnBrand;
              } else if (isInRange) {
                bgColor = colors.brand.withValues(alpha: 0.1);
                textColor = colors.brand;
              } else if (showHoverBackground) {
                bgColor = colors.brandLight;
                textColor = colors.brand;
              } else {
                bgColor = Colors.transparent;
                textColor = colors.textPrimary;
              }

              // 开始/结束日期的圆形装饰
              Widget cellContent;
              if (isRangeStart || isRangeEnd) {
                // 品牌色实心圆
                cellContent = Container(
                  decoration: ShapeDecoration(
                    color: colors.brand,
                    shape: const CircleBorder(),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: typo.sizeBodySmall,
                      color: colors.textOnBrand,
                      fontWeight: typo.weightBold,
                    ),
                  ),
                );
              } else {
                cellContent = Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: radius.brSm,
                    border: isToday && !isSelected && !isRangeStart && !isRangeEnd
                        ? Border.all(color: colors.brand, width: 1)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: typo.sizeBodySmall,
                      color: textColor,
                      fontWeight: isSelected || isRangeStart || isRangeEnd
                          ? typo.weightBold
                          : typo.weightRegular,
                    ),
                  ),
                );
              }

              // 虚线边框包裹
              if (showDashedBorder) {
                cellContent = ClipRRect(
                  borderRadius: radius.brSm,
                  child: Stack(
                    children: [
                      cellContent,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _DashedBorderPainter(
                              color: colors.brand,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GestureDetector(
                onTap: isDisabled ? null : () => _onDateTap(date),
                behavior: HitTestBehavior.opaque,
                child: MouseRegion(
                  onEnter: (_) => _onHoverDate(date),
                  onExit: (_) => _onHoverDate(null),
                  child: Semantics(
                    label: _dateSemanticsLabel(date, isDisabled),
                    selected: isSelected,
                    enabled: !isDisabled,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: cellContent,
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
