import 'package:flutter/material.dart';

/// 日期选择器预设快捷项
///
/// 提供一组常用日期范围的快速选择。
/// 通过 [onSelect] 回调在点击时设置对应的日期值。
///
/// ```dart
/// // DatePicker 中使用
/// ParkDatePicker(
///   presets: [
///     ParkDatePreset.today((date) => print(date)),
///     ParkDatePreset.thisMonth((date) => print(date)),
///   ],
/// )
///
/// // DateRangePicker 中使用
/// ParkDateRangePicker(
///   presets: [
///     ParkDatePreset.last7Days((start, end) => print('$start ~ $end')),
///     ParkDatePreset.last30Days((start, end) => print('$start ~ $end')),
///     ParkDatePreset.thisMonth((start, end) => print('$start ~ $end')),
///     ParkDatePreset.thisQuarter((start, end) => print('$start ~ $end')),
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
  factory ParkDatePreset.today(ValueChanged<DateTime> onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return ParkDatePreset(
      label: '今天',
      date: today,
      onSelect: () => onApply(today),
    );
  }

  /// 本月第一天（用于 DatePicker）
  factory ParkDatePreset.thisMonth(ValueChanged<DateTime> onApply) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    return ParkDatePreset(
      label: '本月',
      date: firstDay,
      onSelect: () => onApply(firstDay),
    );
  }

  // ===========================================================================
  // DateRangePicker 内置便捷构造
  // ===========================================================================

  /// 近 7 天（用于 DateRangePicker）
  factory ParkDatePreset.last7Days(
      void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    return ParkDatePreset(
      label: '近7天',
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }

  /// 近 30 天（用于 DateRangePicker）
  factory ParkDatePreset.last30Days(
      void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 29));
    return ParkDatePreset(
      label: '近30天',
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }

  /// 本月至今（用于 DateRangePicker）
  factory ParkDatePreset.thisMonthRange(
      void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(now.year, now.month, 1);
    return ParkDatePreset(
      label: '本月',
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }

  /// 本季度（用于 DateRangePicker）
  factory ParkDatePreset.thisQuarter(
      void Function(DateTime start, DateTime end) onApply) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    final start = DateTime(now.year, quarterStartMonth, 1);
    return ParkDatePreset(
      label: '本季',
      startDate: start,
      endDate: today,
      onSelect: () => onApply(start, today),
    );
  }
}
