import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_spacing.dart';

/// 数字输入框组件
///
/// 基于 Flutter TextField 扩展，支持 +/- 按钮、步进、范围限制。
///
/// ```dart
/// ParkInputNumber(
///   value: 10,
///   min: 0,
///   max: 100,
///   step: 5,
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkInputNumber extends StatefulWidget {
  final double? value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final double step;
  final int? precision;
  final String? label;
  final bool disabled;
  final bool readOnly;

  const ParkInputNumber({
    super.key,
    this.value,
    this.onChanged,
    this.min = double.negativeInfinity,
    this.max = double.infinity,
    this.step = 1,
    this.precision,
    this.label,
    this.disabled = false,
    this.readOnly = false,
  });

  @override
  State<ParkInputNumber> createState() => _ParkInputNumberState();
}

class _ParkInputNumberState extends State<ParkInputNumber> {
  late TextEditingController _controller;
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = _clamp(widget.value ?? 0);
    _controller = TextEditingController(text: _format(_current));
  }

  @override
  void didUpdateWidget(ParkInputNumber old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && widget.value != null) {
      _current = _clamp(widget.value!);
      _controller.text = _format(_current);
    }
  }

  double _clamp(double v) => v.clamp(widget.min, widget.max);
  String _format(double v) {
    if (widget.precision != null) return v.toStringAsFixed(widget.precision!);
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  void _setValue(double v) {
    final clamped = _clamp(v);
    if (clamped == _current) return;
    setState(() {
      _current = clamped;
      _controller.text = _format(clamped);
    });
    widget.onChanged?.call(clamped);
  }

  void _increment() => _setValue(_current + widget.step);
  void _decrement() => _setValue(_current - widget.step);

  bool get _atMin => _current <= widget.min;
  bool get _atMax => _current >= widget.max;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final spacing = ParkSpacing.defaults();

    final btnStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size(36, 36)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      backgroundColor: WidgetStateProperty.all(park.colors.surface),
      side: WidgetStateProperty.all(BorderSide(color: park.colors.border)),
    );

    final input = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(Icons.remove, _decrement, _atMin, btnStyle, park),
        SizedBox(width: spacing.xs),
        SizedBox(
          width: 72,
          child: TextField(
            controller: _controller,
            enabled: !widget.disabled,
            readOnly: widget.readOnly,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 14, color: park.colors.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: park.colors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: park.colors.border)),
            ),
            onSubmitted: (t) {
              final v = double.tryParse(t);
              if (v != null) _setValue(v);
              else _controller.text = _format(_current);
            },
          ),
        ),
        SizedBox(width: spacing.xs),
        _buildButton(Icons.add, _increment, _atMax, btnStyle, park),
      ],
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label!, style: TextStyle(fontSize: 13, color: park.colors.textSecondary)),
          SizedBox(height: spacing.xs),
          input,
        ],
      );
    }
    return input;
  }

  Widget _buildButton(IconData icon, VoidCallback onTap, bool disabled, ButtonStyle style, ParkThemeData park) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: park.colors.surface,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Icon(icon, size: 16, color: disabled ? park.colors.textDisabled : park.colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
