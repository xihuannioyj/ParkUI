import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';

/// 日期范围筛选快捷预设
class ParkDateRangeShortcut {
  /// 显示文字
  final String label;

  /// 起始日期位移（负数 = 过去）
  final Duration offset;

  /// 终点是否对齐到今天
  final bool endToday;

  const ParkDateRangeShortcut({
    required this.label,
    required this.offset,
    this.endToday = true,
  });

  /// 今天
  static const today = ParkDateRangeShortcut(
    label: '今天',
    offset: Duration.zero,
  );

  /// 最近 7 天
  static const last7Days = ParkDateRangeShortcut(
    label: '近 7 天',
    offset: Duration(days: -6),
  );

  /// 最近 30 天
  static const last30Days = ParkDateRangeShortcut(
    label: '近 30 天',
    offset: Duration(days: -29),
  );

  /// 本月
  static ParkDateRangeShortcut get thisMonth {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final diff = firstDay.difference(now);
    return ParkDateRangeShortcut(
      label: '本月',
      offset: Duration(days: diff.inDays),
    );
  }

  /// 最近 90 天
  static const last90Days = ParkDateRangeShortcut(
    label: '近 90 天',
    offset: Duration(days: -89),
  );
}

/// 日期范围选择器结果
class ParkDateRange {
  /// 起始日期
  final DateTime start;

  /// 结束日期
  final DateTime end;

  const ParkDateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkDateRange &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() =>
      'ParkDateRange(start: $start, end: $end)';
}

/// ParkDateRangePicker — 日期范围筛选组件
///
/// 提供开始/结束日期选择、快捷预设、重置功能。
/// 可内嵌于 [ParkDropdownSheet] 的 child 模式中使用，
/// 也可独立使用静态方法 [show] 弹出。
///
/// ```dart
/// // 静态弹出
/// final result = await ParkDateRangePicker.show(
///   context: context,
///   startTime: startDate,
///   endTime: endDate,
/// );
///
/// // 嵌入自定义面板
/// ParkDateRangePicker(
///   startTime: start,
///   endTime: end,
///   onChanged: (range) => print('${range.start} ~ ${range.end}'),
/// );
/// ```
class ParkDateRangePicker extends StatefulWidget {
  /// 起始日期
  final DateTime? startTime;

  /// 结束日期
  final DateTime? endTime;

  /// 日期范围变更回调
  final ValueChanged<ParkDateRange?>? onChanged;

  /// 确认回调
  final ValueChanged<ParkDateRange>? onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 可选最早日期
  final DateTime? firstDate;

  /// 可选最晚日期
  final DateTime? lastDate;

  /// 是否显示快捷预设
  final bool showShortcuts;

  /// 快捷预设列表
  final List<ParkDateRangeShortcut> shortcuts;

  /// 标签文字（内联模式）
  final String? label;

  /// 起始日期占位文字
  final String startHintText;

  /// 结束日期占位文字
  final String endHintText;

  /// 重置按钮文字
  final String resetText;

  /// 是否显示重置按钮
  final bool showReset;

  /// 绑定键
  final String? bindKey;

  /// 绑定服务
  final ParkBindingService? bindingService;

  const ParkDateRangePicker({
    super.key,
    this.startTime,
    this.endTime,
    this.onChanged,
    this.onConfirm,
    this.onCancel,
    this.firstDate,
    this.lastDate,
    this.showShortcuts = true,
    this.shortcuts = ParkDateRangePicker.defaultShortcuts,
    this.label,
    this.startHintText = '开始日期',
    this.endHintText = '结束日期',
    this.resetText = '重置',
    this.showReset = true,
    this.bindKey,
    this.bindingService,
  });

  /// 默认快捷预设（4 项：今天 / 近7天 / 近30天 / 本月至今）。
  static const List<ParkDateRangeShortcut> defaultShortcuts = [
    ParkDateRangeShortcut(label: '今天', offset: Duration.zero),
    ParkDateRangeShortcut(label: '近 7 天', offset: Duration(days: -6)),
    ParkDateRangeShortcut(label: '近 30 天', offset: Duration(days: -29)),
    ParkDateRangeShortcut(label: '本月至今', offset: Duration.zero),
  ];

  /// 以静态方法弹出日期范围选择面板
  ///
  /// 返回用户确认的 [ParkDateRange]，取消时返回 null。
  static Future<ParkDateRange?> show(
    BuildContext context, {
    DateTime? startTime,
    DateTime? endTime,
    DateTime? firstDate,
    DateTime? lastDate,
    bool showShortcuts = true,
    List<ParkDateRangeShortcut> shortcuts = ParkDateRangePicker.defaultShortcuts,
  }) {
    return showModalBottomSheet<ParkDateRange>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DateRangePickerSheet(
        startTime: startTime,
        endTime: endTime,
        firstDate: firstDate,
        lastDate: lastDate,
        showShortcuts: showShortcuts,
        shortcuts: shortcuts,
      ),
    );
  }

  @override
  State<ParkDateRangePicker> createState() => _ParkDateRangePickerState();
}

class _ParkDateRangePickerState extends State<ParkDateRangePicker>
    with BindableWidgetMixin<ParkDateRange?, ParkDateRangePicker> {
  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
  }

  void _open() {
    ParkDateRangePicker.show(
      context,
      startTime: widget.startTime,
      endTime: widget.endTime,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      showShortcuts: widget.showShortcuts,
      shortcuts: widget.shortcuts,
    ).then((result) {
      if (result != null) {
        widget.onChanged?.call(result);
        widget.onConfirm?.call(result);
        boundValue = result;
      } else {
        widget.onCancel?.call();
      }
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final startText = _formatDate(widget.startTime);
    final endText = _formatDate(widget.endTime);
    final hasValue = startText.isNotEmpty && endText.isNotEmpty;
    final displayText = hasValue ? '$startText ~ $endText' : '';

    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: park.colors.background,
          borderRadius: park.radius.brMd,
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range_rounded,
              size: 18,
              color: park.colors.textPlaceholder,
            ),
            SizedBox(width: park.spacing.sm),
            Expanded(
              child: Text(
                widget.label != null ? '${widget.label}：$displayText' : displayText,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeBody,
                  color: hasValue
                      ? park.colors.textPrimary
                      : park.colors.textPlaceholder,
                ),
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: () {
                  widget.onChanged?.call(null);
                  boundValue = null;
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: park.colors.textPlaceholder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 日期范围选择面板（内部组件）
// ============================================================================

class _DateRangePickerSheet extends StatefulWidget {
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showShortcuts;
  final List<ParkDateRangeShortcut> shortcuts;

  const _DateRangePickerSheet({
    this.startTime,
    this.endTime,
    this.firstDate,
    this.lastDate,
    this.showShortcuts = true,
    this.shortcuts = ParkDateRangePicker.defaultShortcuts,
  });

  @override
  State<_DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<_DateRangePickerSheet> {
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startTime;
    _endDate = widget.endTime;
  }

  void _handleShortcut(ParkDateRangeShortcut shortcut) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = shortcut.offset.isNegative
        ? today.add(shortcut.offset)
        : shortcut.offset == Duration.zero
            ? today
            : today.add(shortcut.offset);
    setState(() {
      _startDate = start;
      _endDate = today;
    });
  }

  void _pickDate({required bool isStart}) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final initial = isStart ? _startDate : _endDate;

    showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        DateTime temp = initial ?? DateTime.now();
        return Container(
          decoration: BoxDecoration(
            color: park.colors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(park.radius.lg)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Padding(
                  padding: EdgeInsets.only(top: park.spacing.sm),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: park.colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: park.spacing.base,
                    vertical: park.spacing.sm,
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          ParkLocalizations.of(context).cancelText,
                          style: TextStyle(color: park.colors.textSecondary),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isStart ? '选择开始日期' : '选择结束日期',
                        style: park.typography.body.copyWith(
                          fontWeight: park.typography.weightBold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, temp),
                        child: Text(
                          ParkLocalizations.of(context).confirmText,
                          style: TextStyle(color: park.colors.brand),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: temp,
                    minimumDate: widget.firstDate,
                    maximumDate: widget.lastDate,
                    minimumYear: 2018,
                    maximumYear: 2030,
                    onDateTimeChanged: (dt) => temp = dt,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((result) {
      if (result != null && mounted) {
        setState(() {
          if (isStart) {
            _startDate = result;
          } else {
            _endDate = result;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;
    final radius = park.radius;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
        boxShadow: park.shadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 拖拽手柄 ──
            Padding(
              padding: EdgeInsets.only(top: spacing.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── 标题栏 ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.sm,
                spacing.xs,
                spacing.sm,
                spacing.xs,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '时间筛选',
                    style: typo.body.copyWith(
                      fontSize: typo.sizeBody,
                      fontWeight: typo.weightBold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_startDate != null && _endDate != null) {
                        Navigator.pop(
                          context,
                          ParkDateRange(
                            start: _startDate!,
                            end: _endDate!,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: (_startDate != null && _endDate != null)
                            ? colors.brand
                            : colors.textPlaceholder,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 快捷预设 ──
            if (widget.showShortcuts && widget.shortcuts.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.base),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.shortcuts.length,
                    separatorBuilder: (_, _a) =>
                        SizedBox(width: spacing.sm),
                    itemBuilder: (context, index) {
                      final s = widget.shortcuts[index];
                      return _ShortcutChip(
                        label: s.label,
                        selected: _isShortcutActive(s),
                        onTap: () => _handleShortcut(s),
                      );
                    },
                  ),
                ),
              ),

            SizedBox(height: spacing.sm),

            // ── 日期选择区域 ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.base),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: radius.brMd,
                ),
                child: Column(
                  children: [
                    _DateField(
                      label: '开始时间',
                      date: _startDate,
                      hintText: '请选择开始日期',
                      onTap: () => _pickDate(isStart: true),
                      park: park,
                    ),
                    Divider(
                      height: 1,
                      indent: 12,
                      endIndent: 12,
                      color: colors.border.withValues(alpha: 0.6),
                    ),
                    _DateField(
                      label: '结束时间',
                      date: _endDate,
                      hintText: '请选择结束日期',
                      onTap: () => _pickDate(isStart: false),
                      park: park,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: spacing.base),

            // ── 重置按钮 ──
            if (widget.showShortcuts)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  0,
                  spacing.base,
                  spacing.base,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: radius.brMd,
                      ),
                    ),
                    child: Text(
                      '重置筛选',
                      style: typo.body.copyWith(
                        fontSize: typo.sizeBody,
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: spacing.sm),
          ],
        ),
      ),
    );
  }

  bool _isShortcutActive(ParkDateRangeShortcut shortcut) {
    if (_startDate == null || _endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expectedStart = shortcut.offset.isNegative
        ? today.add(shortcut.offset)
        : shortcut.offset == Duration.zero
            ? today
            : today.add(shortcut.offset);
    return _startDate == expectedStart && _endDate == today;
  }
}

/// 快捷预设 Chip
class _ShortcutChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ShortcutChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: park.motion.quick,
        curve: park.motion.defaultEasing,
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? park.colors.brand.withValues(alpha: 0.1)
              : park.colors.background,
          borderRadius: park.radius.brFull,
          border: Border.all(
            color: selected
                ? park.colors.brand.withValues(alpha: 0.3)
                : park.colors.border,
          ),
        ),
        child: Text(
          label,
          style: park.typography.body.copyWith(
            fontSize: park.typography.sizeBodySmall,
            fontWeight: selected ? park.typography.weightBold : null,
            color: selected ? park.colors.brand : park.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// 日期选择行（开始/结束）
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String hintText;
  final VoidCallback onTap;
  final ParkThemeData park;

  const _DateField({
    required this.label,
    required this.date,
    required this.hintText,
    required this.onTap,
    required this.park,
  });

  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        child: Row(
          children: [
            Text(
              '$label：',
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                fontWeight: park.typography.weightMedium,
                color: park.colors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              hasValue ? _fmt(date) : hintText,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                color: hasValue
                    ? park.colors.textPrimary
                    : park.colors.textPlaceholder,
              ),
            ),
            SizedBox(width: park.spacing.sm),
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: park.colors.textPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}
