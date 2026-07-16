import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';

/// 日期选择器预设快捷项
///
/// 提供一组常用日期范围的快速选择。
/// 通过 [onSelect] 回调在点击时设置对应的日期值。
///
/// ```dart
/// // DatePicker 中使用
/// ParkDatePicker(
///   presets: [
///     ParkDatePreset.today(l10n, (date) => print(date)),
///     ParkDatePreset.thisMonth(l10n, (date) => print(date)),
///   ],
/// )
///
/// // DateRangePicker 中使用
/// ParkDateRangePicker(
///   presets: [
///     ParkDatePreset.last7Days(l10n, (start, end) => print('$start ~ $end')),
///     ParkDatePreset.last30Days(l10n, (start, end) => print('$start ~ $end')),
///     ParkDatePreset.thisMonth(l10n, (start, end) => print('$start ~ $end')),
///     ParkDatePreset.thisQuarter(l10n, (start, end) => print('$start ~ $end')),
///   ],
/// )
/// ```
class ParkDatePreset {
  /// 显示文字
  final String label;

  /// 预设选中回调（闭包内设置对应的开始/结束日期）
  final VoidCallback onSelect;

  /// 预设代表的日期值（DatePicker 使用，用于关闭面板时回传）
  final DateTime? date;

  /// 预设代表的起始日期（DateRangePicker 使用）
  final DateTime? startDate;

  /// 预设代表的结束日期（DateRangePicker 使用）
  final DateTime? endDate;

  const ParkDatePreset({
    required this.label,
    required this.onSelect,
    this.date,
    this.startDate,
    this.endDate,
  });

  // ===========================================================================
  // DatePicker 内置便捷构造
  // ===========================================================================

  /// 今天（用于 DatePicker）
  factory ParkDatePreset.today(ParkLocalizations l10n, ValueChanged<DateTime> onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return ParkDatePreset(
      label: l10n.shortcutToday,
      date: today,
      onSelect: () => onApply(today),
    );
  }

  /// 昨天（用于 DatePicker）
  factory ParkDatePreset.yesterday(ParkLocalizations l10n, ValueChanged<DateTime> onApply) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    return ParkDatePreset(
      label: l10n.shortcutYesterday,
      date: yesterday,
      onSelect: () => onApply(yesterday),
    );
  }

  /// 本月第一天（用于 DatePicker）
  factory ParkDatePreset.thisMonth(ParkLocalizations l10n, ValueChanged<DateTime> onApply) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    return ParkDatePreset(
      label: l10n.shortcutThisMonth,
      date: firstDay,
      onSelect: () => onApply(firstDay),
    );
  }

  // ===========================================================================
  // DateRangePicker 内置便捷构造
  // ===========================================================================

  /// 近 7 天（用于 DateRangePicker）
  factory ParkDatePreset.last7Days(
      ParkLocalizations l10n, void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    return ParkDatePreset(
      label: l10n.shortcutLast7Days,
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }

  /// 近 30 天（用于 DateRangePicker）
  factory ParkDatePreset.last30Days(
      ParkLocalizations l10n, void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 29));
    return ParkDatePreset(
      label: l10n.shortcutLast30Days,
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }

  /// 本月至今（用于 DateRangePicker）
  factory ParkDatePreset.thisMonthRange(
      ParkLocalizations l10n, void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(now.year, now.month, 1);
    return ParkDatePreset(
      label: l10n.shortcutThisMonth,
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }

  /// 本季度（用于 DateRangePicker）
  factory ParkDatePreset.thisQuarter(
      ParkLocalizations l10n, void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    final start = DateTime(now.year, quarterStartMonth, 1);
    return ParkDatePreset(
      label: l10n.shortcutThisQuarter,
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }
}
