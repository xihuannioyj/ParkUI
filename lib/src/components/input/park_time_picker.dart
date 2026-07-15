import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// 时间选择器组件
///
/// 独立的时间选择，支持 HH:mm / HH:mm:ss 格式。
/// 从 [ParkDatePicker] 拆出的纯时间场景组件。
///
/// ```dart
/// ParkTimePicker(
///   value: TimeOfDay(hour: 9, minute: 30),
///   onChanged: (time) => print('$time'),
///   showSeconds: true,
/// )
/// ```
class ParkTimePicker extends StatefulWidget {
  /// 当前选中时间。
  final TimeOfDay? value;

  /// 占位文字（默认 '请选择时间'）。
  final String? placeholder;

  /// 时间变化回调。
  final ValueChanged<TimeOfDay>? onChanged;

  /// 是否显示秒（默认 false）。
  final bool showSeconds;

  /// 是否禁用（默认 false）。
  final bool disabled;

  /// 标签文字。
  final String? label;

  /// 创建 [ParkTimePicker]。
  const ParkTimePicker({
    super.key,
    this.value,
    this.placeholder,
    this.onChanged,
    this.showSeconds = false,
    this.disabled = false,
    this.label,
  });

  @override
  State<ParkTimePicker> createState() => _ParkTimePickerState();
}

class _ParkTimePickerState extends State<ParkTimePicker> {
  late TimeOfDay? _selected;
  int _second = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  void didUpdateWidget(ParkTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selected = widget.value;
      // Reset seconds when value changes from outside (TimeOfDay has no seconds).
      if (!widget.showSeconds) {
        _second = 0;
      }
    }
  }

  /// Build display text.
  ///
  /// When [showSeconds] is true, renders a custom HH:mm:ss (or H:mm:ss AM/PM)
  /// format that includes the seconds value. Otherwise delegates to
  /// [TimeOfDay.format] for the default locale-aware display.
  String _formatDisplayText() {
    if (_selected == null) {
      return widget.placeholder ?? ParkLocalizations.of(context).selectTimeText;
    }
    if (!widget.showSeconds) {
      return _selected!.format(context);
    }
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final h = _selected!.hour;
    final m = _selected!.minute;
    final s = _second;
    if (use24h) {
      return '${h.toString().padLeft(2, '0')}'
          ':${m.toString().padLeft(2, '0')}'
          ':${s.toString().padLeft(2, '0')}';
    } else {
      final period = h < 12 ? 'AM' : 'PM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '${h12.toString().padLeft(2, '0')}'
          ':${m.toString().padLeft(2, '0')}'
          ':${s.toString().padLeft(2, '0')} $period';
    }
  }

  /// Open the time picker dialog.
  ///
  /// When [showSeconds] is true a custom [CupertinoTimerPicker]-based dialog
  /// is used so that the seconds column is available. Otherwise the standard
  /// Material [showTimePicker] is used (unchanged behaviour).
  Future<void> _showPicker() async {
    if (widget.showSeconds) {
      await _showCustomPicker();
    } else {
      final time = await showTimePicker(
        context: context,
        initialTime: _selected ?? TimeOfDay.now(),
        helpText: widget.label ?? ParkLocalizations.of(context).chooseTimeText,
      );
      if (time != null && mounted) {
        setState(() => _selected = time);
        widget.onChanged?.call(time);
      }
    }
  }

  /// Custom picker dialog using [CupertinoTimerPicker] in hms mode.
  ///
  /// Shows hour, minute and second columns in a scrollable picker.
  /// Returns a [Duration] which is then decomposed into [TimeOfDay] (hour +
  /// minute) and a separate [_second] value for display.
  Future<void> _showCustomPicker() async {
    final initial = _selected ?? TimeOfDay.now();
    final initialDuration = Duration(
      hours: initial.hour,
      minutes: initial.minute,
      seconds: _second,
    );

    Duration picked = initialDuration;

    final duration = await showDialog<Duration>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(widget.label ?? ParkLocalizations.of(context).chooseTimeText),
              content: SizedBox(
                height: 200,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: initialDuration,
                  onTimerDurationChanged: (d) {
                    setDialogState(() => picked = d);
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(ParkLocalizations.of(context).cancelText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(picked),
                  child: Text(ParkLocalizations.of(context).confirmText),
                ),
              ],
            );
          },
        );
      },
    );

    if (duration != null && mounted) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      final time = TimeOfDay(hour: hours, minute: minutes);
      setState(() {
        _selected = time;
        _second = seconds;
      });
      widget.onChanged?.call(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final displayText = _formatDisplayText();

    return Semantics(
      label: widget.label ?? ParkLocalizations.of(context).chooseTimeText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 13,
                  color: park.colors.textSecondary,
                ),
              ),
            ),
          GestureDetector(
            onTap: widget.disabled ? null : _showPicker,
            child: Container(
              padding: EdgeInsets.all(park.spacing.md),
              decoration: BoxDecoration(
                color: widget.disabled
                    ? park.colors.disabledBg
                    : Colors.transparent,
                border: Border.all(color: park.colors.border),
                borderRadius: park.radius.brSm,
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: park.colors.textSecondary),
                  park.spacing.hSm,
                  Expanded(
                    child: Semantics(
                      label: ParkLocalizations.of(context).currentSelectionText,
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 14,
                          color: _selected != null
                              ? park.colors.textPrimary
                              : park.colors.textPlaceholder,
                        ),
                      ),
                    ),
                  ),
                  if (!widget.disabled)
                    Icon(Icons.arrow_drop_down,
                        size: 20, color: park.colors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
