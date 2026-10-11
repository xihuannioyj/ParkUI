import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';
import 'park_date_preset.dart';

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
  static ParkDateRangeShortcut today(ParkLocalizations l10n) =>
      ParkDateRangeShortcut(
        label: l10n.shortcutToday,
        offset: Duration.zero,
      );

  /// 最近 7 天
  static ParkDateRangeShortcut last7Days(ParkLocalizations l10n) =>
      ParkDateRangeShortcut(
        label: l10n.shortcutLast7Days,
        offset: Duration(days: -6),
      );

  /// 最近 30 天
  static ParkDateRangeShortcut last30Days(ParkLocalizations l10n) =>
      ParkDateRangeShortcut(
        label: l10n.shortcutLast30Days,
        offset: Duration(days: -29),
      );

  /// 本月
  static ParkDateRangeShortcut thisMonth(ParkLocalizations l10n) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final diff = firstDay.difference(now);
    return ParkDateRangeShortcut(
      label: l10n.shortcutThisMonth,
      offset: Duration(days: diff.inDays),
    );
  }

  /// 最近 90 天
  static ParkDateRangeShortcut last90Days(ParkLocalizations l10n) =>
      ParkDateRangeShortcut(
        label: l10n.shortcutLast90Days,
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

  /// 预设快捷项列表（使用 [ParkDatePreset] 构建，支持回调闭包）
  final List<ParkDatePreset>? presets;

  /// 标签文字（内联模式）
  final String? label;

  /// 起始日期占位文字
  final String? startHintText;

  /// 结束日期占位文字
  final String? endHintText;

  /// 重置按钮文字
  final String? resetText;

  /// 是否显示重置按钮
  final bool showReset;

  /// 绑定键
  final String? bindKey;

  /// 绑定服务
  final ParkBindingService? bindingService;

  /// 自定义底部 footer 组件，渲染在日期选择面板底部确认按钮下方。
  /// 为 null 时无变化。
  final Widget? renderExtraFooter;

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
    this.shortcuts = const [],
    this.label,
    this.startHintText,
    this.endHintText,
    this.resetText,
    this.showReset = true,
    this.bindKey,
    this.bindingService,
    this.presets,
    this.renderExtraFooter,
  });

  /// 默认快捷预设（4 项：今天 / 近7天 / 近30天 / 本月至今）。
  /// 需要运行时传入 [ParkLocalizations] 以获取本地化标签。
  static List<ParkDateRangeShortcut> defaultShortcuts(ParkLocalizations l10n) => [
        ParkDateRangeShortcut.today(l10n),
        ParkDateRangeShortcut.last7Days(l10n),
        ParkDateRangeShortcut.last30Days(l10n),
        ParkDateRangeShortcut.thisMonth(l10n),
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
    List<ParkDateRangeShortcut>? shortcuts,
    List<ParkDatePreset>? presets,
    Widget? renderExtraFooter,
  }) {
    final l10n = ParkLocalizations.of(context);
    final resolvedShortcuts = shortcuts ?? ParkDateRangePicker.defaultShortcuts(l10n);
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
        shortcuts: resolvedShortcuts,
        presets: presets,
        renderExtraFooter: renderExtraFooter,
      ),
    );
  }

  @override
  State<ParkDateRangePicker> createState() => _ParkDateRangePickerState();
}

class _ParkDateRangePickerState extends State<ParkDateRangePicker>
    with BindableWidgetMixin<ParkDateRange?, ParkDateRangePicker> {
  DateTime? _localStartDate;
  DateTime? _localEndDate;

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _localStartDate = widget.startTime;
    _localEndDate = widget.endTime;
  }

  @override
  void didUpdateWidget(ParkDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime) {
      _localStartDate = widget.startTime;
    }
    if (widget.endTime != oldWidget.endTime) {
      _localEndDate = widget.endTime;
    }
  }

  void _open() {
    final l10n = ParkLocalizations.of(context);
    final resolvedShortcuts = widget.shortcuts.isNotEmpty
        ? widget.shortcuts
        : ParkDateRangePicker.defaultShortcuts(l10n);
    ParkDateRangePicker.show(
      context,
      startTime: _localStartDate,
      endTime: _localEndDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      showShortcuts: widget.showShortcuts,
      shortcuts: resolvedShortcuts,
      presets: widget.presets,
      renderExtraFooter: widget.renderExtraFooter,
    ).then((result) {
      if (result != null) {
        setState(() {
          _localStartDate = result.start;
          _localEndDate = result.end;
        });
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

    final startText = _formatDate(_localStartDate);
    final endText = _formatDate(_localEndDate);
    final hasValue = startText.isNotEmpty && endText.isNotEmpty;
    final displayText = hasValue ? '$startText ~ $endText' : '';

    return Semantics(
      button: true,
      label: widget.label ?? (displayText.isEmpty ? '' : displayText),
      child: GestureDetector(
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
              Semantics(
                button: true,
                label: ParkLocalizations.of(context).clearText,
                child: GestureDetector(
                onTap: () {
                  setState(() {
                    _localStartDate = null;
                    _localEndDate = null;
                  });
                  widget.onChanged?.call(null);
                  boundValue = null;
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: park.colors.textPlaceholder,
                ),
              ),
              ),
          ],
        ),
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
  final List<ParkDatePreset>? presets;
  final Widget? renderExtraFooter;

  const _DateRangePickerSheet({
    this.startTime,
    this.endTime,
    this.firstDate,
    this.lastDate,
    this.showShortcuts = true,
    this.shortcuts = const [],
    this.presets,
    this.renderExtraFooter,
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

  void _handlePreset(ParkDatePreset preset) {
    preset.onSelect();
    if (preset.startDate != null && preset.endDate != null) {
      setState(() {
        _startDate = preset.startDate;
        _endDate = preset.endDate;
      });
    }
  }

  void _pickDate({required bool isStart}) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final initial = isStart ? _startDate : _endDate;

    showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // 边界防御：initial 超出 [firstDate, lastDate] 时 CupertinoDatePicker
        // debug 断言失败，先钳制到允许范围。
        DateTime temp = initial ?? DateTime.now();
        if (widget.firstDate != null && temp.isBefore(widget.firstDate!)) {
          temp = widget.firstDate!;
        }
        if (widget.lastDate != null && temp.isAfter(widget.lastDate!)) {
          temp = widget.lastDate!;
        }
        // P1-9：结束日期不允许早于开始日期、开始日期不允许晚于结束日期——
        // 双向钳制初始值与可选范围（CupertinoDatePicker 的 min/max 可为 null）。
        final DateTime? effectiveMin;
        final DateTime? effectiveMax;
        if (!isStart && _startDate != null) {
          temp = temp.isBefore(_startDate!) ? _startDate! : temp;
          effectiveMin = (widget.firstDate != null &&
                  widget.firstDate!.isAfter(_startDate!))
              ? widget.firstDate
              : _startDate;
          effectiveMax = widget.lastDate;
        } else if (isStart && _endDate != null) {
          temp = temp.isAfter(_endDate!) ? _endDate! : temp;
          effectiveMax = (widget.lastDate != null &&
                  widget.lastDate!.isBefore(_endDate!))
              ? widget.lastDate
              : _endDate;
          effectiveMin = widget.firstDate;
        } else {
          effectiveMin = widget.firstDate;
          effectiveMax = widget.lastDate;
        }
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
                      Semantics(
                        button: true,
                        label: l10n.cancelText,
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            l10n.cancelText,
                            style: TextStyle(color: park.colors.textSecondary),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isStart ? l10n.selectStartDate : l10n.selectEndDate,
                        style: park.typography.body.copyWith(
                          fontWeight: park.typography.weightBold,
                        ),
                      ),
                      const Spacer(),
                      Semantics(
                        button: true,
                        label: l10n.confirmText,
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx, temp),
                          child: Text(
                            l10n.confirmText,
                            style: TextStyle(color: park.colors.brand),
                          ),
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
                    minimumDate: effectiveMin,
                    maximumDate: effectiveMax,
                    minimumYear: (widget.firstDate?.year) ??
                        (DateTime.now().year - 100),
                    maximumYear: (widget.lastDate?.year) ??
                        (DateTime.now().year + 100),
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
            // 防御：若外部逻辑绕过钳制导致 start > end，交换保证区间合法。
            if (_endDate != null && result.isAfter(_endDate!)) {
              _endDate = result;
            }
          } else {
            _endDate = result;
            if (_startDate != null && result.isBefore(_startDate!)) {
              _startDate = result;
            }
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
    final l10n = ParkLocalizations.of(context);
    final bool canConfirm = _startDate != null && _endDate != null;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius.lg)),
        boxShadow: park.shadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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

            // ── 标题栏：左右等宽插槽，保证标题严格居中 ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.base,
                spacing.sm,
                spacing.base,
                spacing.sm,
              ),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildHeaderAction(
                          label: l10n.cancelText,
                          color: colors.textSecondary,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          l10n.timeFilter,
                          style: typo.body.copyWith(
                            fontSize: typo.sizeBody,
                            fontWeight: typo.weightBold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildHeaderAction(
                          label: l10n.confirmText,
                          color: canConfirm
                              ? colors.brand
                              : colors.textPlaceholder,
                          bold: true,
                          onTap: canConfirm
                              ? () => Navigator.pop(
                                    context,
                                    ParkDateRange(
                                      start: _startDate!,
                                      end: _endDate!,
                                    ),
                                  )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 快捷预设：胶囊自动换行（不再横向滚动，窄屏也不截断） ──
            if (widget.showShortcuts && widget.shortcuts.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.base),
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: 0,
                  children: [
                    for (final s in widget.shortcuts)
                      _ShortcutChip(
                        label: s.label,
                        selected: _isShortcutActive(s),
                        onTap: () => _handleShortcut(s),
                      ),
                  ],
                ),
              ),

            // ── Preset 快捷项 ──
            if (widget.presets != null && widget.presets!.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.base,
                  spacing.sm,
                  spacing.base,
                  0,
                ),
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: 0,
                  children: [
                    for (final p in widget.presets!)
                      _ShortcutChip(
                        label: p.label,
                        selected: p.startDate != null &&
                            p.endDate != null &&
                            _startDate == p.startDate &&
                            _endDate == p.endDate,
                        onTap: () => _handlePreset(p),
                      ),
                  ],
                ),
              ),

            SizedBox(height: spacing.sm),

            // ── 起止日期：并排两块字段，与页面上的筛选项形成同一套语言 ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.base),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _DateField(
                      label: l10n.startTime,
                      date: _startDate,
                      hintText: l10n.selectStartDate,
                      onTap: () => _pickDate(isStart: true),
                      park: park,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: _DateField(
                      label: l10n.endTime,
                      date: _endDate,
                      hintText: l10n.selectEndDate,
                      onTap: () => _pickDate(isStart: false),
                      park: park,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: spacing.md),

            // ── 重置：降级为文字操作，主操作只留「确定」 ──
            if (widget.showShortcuts)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  label: Text(l10n.resetFilter),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    minimumSize: const Size(0, 44),
                    textStyle: typo.body.copyWith(
                      fontSize: typo.sizeBodySmall,
                    ),
                  ),
                ),
              ),

            SizedBox(height: spacing.sm),

            // ── 自定义 Footer ──
            if (widget.renderExtraFooter != null) ...[
              SizedBox(height: spacing.sm),
              widget.renderExtraFooter!,
              SizedBox(height: spacing.sm),
            ],
          ],
        ),
        ),
      ),
    );
  }

  /// 标题栏文字操作。
  ///
  /// 固定 44 高度以满足最小触控目标；左右插槽等宽，保证标题严格居中。
  Widget _buildHeaderAction({
    required String label,
    required Color color,
    bool bold = false,
    VoidCallback? onTap,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: park.typography.body.copyWith(
          fontSize: park.typography.sizeBody,
          fontWeight: bold
              ? park.typography.weightBold
              : park.typography.weightRegular,
        ),
      ),
      child: Text(label),
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
    final colors = park.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // 纵向 padding 把触控高度撑到 44，视觉胶囊靠内容+padding 自适应宽度与 36 高度
        // （不能给 Container 设 alignment：在 Wrap 的有界约束下会被拉成整行宽）。
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: park.spacing.xs),
          child: AnimatedContainer(
            duration: park.motion.quick,
            curve: park.motion.defaultEasing,
            padding: EdgeInsets.symmetric(
              horizontal: park.spacing.md,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: selected ? colors.brand : colors.background,
              borderRadius: park.radius.brFull,
              border: Border.all(
                color: selected ? colors.brand : colors.border,
              ),
              boxShadow: selected ? park.shadows.sm : null,
            ),
            child: Text(
              label,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBodySmall,
                fontWeight: selected
                    ? park.typography.weightBold
                    : park.typography.weightRegular,
                color: selected ? colors.textOnBrand : colors.textSecondary,
              ),
            ),
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
    final colors = park.colors;
    return Semantics(
      button: true,
      label: '$label${hasValue ? _fmt(date) : hintText}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: park.spacing.md,
            vertical: park.spacing.md,
          ),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: park.radius.brMd,
            border: Border.all(
              color: hasValue
                  ? colors.brand.withValues(alpha: 0.35)
                  : colors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: park.typography.body.copyWith(
                        fontSize: park.typography.sizeCaption,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: hasValue ? colors.brand : colors.textPlaceholder,
                  ),
                ],
              ),
              SizedBox(height: park.spacing.xs),
              Text(
                hasValue ? _fmt(date) : hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeBody,
                  fontWeight: hasValue
                      ? park.typography.weightMedium
                      : park.typography.weightRegular,
                  color:
                      hasValue ? colors.textPrimary : colors.textPlaceholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
