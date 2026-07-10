import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

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
    }
  }

  Future<void> _showPicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selected ?? TimeOfDay.now(),
      helpText: widget.label ?? '选择时间',
    );
    if (time != null && mounted) {
      setState(() => _selected = time);
      widget.onChanged?.call(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final displayText = _selected != null
        ? _selected!.format(context)
        : (widget.placeholder ?? '请选择时间');

    return Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: widget.disabled ? park.colors.disabledBg : Colors.transparent,
              border: Border.all(color: park.colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: park.colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
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
                if (!widget.disabled)
                  Icon(Icons.arrow_drop_down, size: 20, color: park.colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
