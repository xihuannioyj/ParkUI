import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';
import '../../binding/park_binding_service.dart';
import '../../binding/park_binding_form_scope.dart';
import '../../binding/park_bindable.dart';

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

  /// 绑定键（点号分隔的路径）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  /// 创建 [ParkTimePicker]。
  const ParkTimePicker({
    super.key,
    this.value,
    this.placeholder,
    this.onChanged,
    this.showSeconds = false,
    this.disabled = false,
    this.label,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkTimePicker> createState() => _ParkTimePickerState();
}

class _ParkTimePickerState extends State<ParkTimePicker> {
  late TimeOfDay? _selected;
  int _second = 0;
  ParkBindable<TimeOfDay>? _bindable;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
    _tryLinkBinding();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryLinkBinding();
  }

  void _tryLinkBinding() {
    final String? key = widget.bindKey;
    if (key == null || _bindable != null) return;
    final ParkBindingService? service = widget.bindingService ??
        ParkBindingFormScope.of(context)?.service;
    if (service == null) return;

    _bindable = service.bind<TimeOfDay>(key);
    _selected = _bindable!.value;
    _bindable!.addListener(_onBindableChanged);
  }

  /// model → UI 方向同步。
  void _onBindableChanged() {
    if (!mounted || _bindable == null) return;
    final TimeOfDay? value = _bindable!.value;
    if (value != _selected) {
      setState(() => _selected = value);
    }
  }

  /// UI → model 方向同步。
  void _syncToBindable(TimeOfDay? value) {
    final ParkBindable<TimeOfDay>? bindable = _bindable;
    if (bindable != null && bindable.value != value) {
      // ignore: avoid_dynamic_calls
      (bindable as dynamic).value = value;
    }
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
    if (widget.bindKey != oldWidget.bindKey ||
        widget.bindingService != oldWidget.bindingService) {
      _bindable?.removeListener(_onBindableChanged);
      _bindable = null;
      _tryLinkBinding();
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
        _syncToBindable(time);
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
              // 固定宽高阻断 AlertDialog 的 intrinsic 测量下探到
              // CupertinoTimerPicker 内部的 LayoutBuilder（否则报
              // "LayoutBuilder does not support returning intrinsic dimensions"）。
              content: SizedBox(
                width: 320,
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
      _syncToBindable(time);
      widget.onChanged?.call(time);
    }
  }

  @override
  void dispose() {
    _bindable?.removeListener(_onBindableChanged);
    super.dispose();
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
                          fontSize: park.typography.sizeBodySmall,
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
