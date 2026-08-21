import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_spacing.dart';
import '../../binding/park_binding_service.dart';
import '../../binding/park_binding_mixin.dart';
import '../../l10n/park_localizations.dart';

/// 数字输入框组件
///
/// 基于 Flutter TextField 扩展，支持 +/- 按钮、步进、范围限制。
///
/// 支持 [bindKey] 双向绑定：置于 [ParkForm] 内且表单已注入
/// 绑定服务时，仅凭 [bindKey] 即可与模型字段联动（B22 / 开发文档.md §5.x）。
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

  /// 绑定键（点号分隔的路径，如 `'user.age'`）。
  /// 设此参数后组件进入双向绑定模式，值变化自动同步到 [ParkBindingService]。
  /// 不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。传入后组件通过 [bindKey] 自动双向绑定。
  /// 如果组件位于 [ParkForm] / [ParkDynamicForm] 内且表单已注入绑定服务，
  /// 此参数可省略（自动从 [ParkBindingFormScope] 获取）。
  final ParkBindingService? bindingService;

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
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkInputNumber> createState() => _ParkInputNumberState();
}

class _ParkInputNumberState extends State<ParkInputNumber>
    with BindableWidgetMixin<double, ParkInputNumber> {
  late TextEditingController _controller;
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = _clamp(widget.value ?? 0);
    _controller = TextEditingController(text: _format(_current));
    // 若 initState 阶段已建立绑定（显式 bindingService），用绑定值覆盖初始值。
    _syncFromBindableIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 表单作用域内通过 ParkBindingFormScope 解析绑定服务后同步初始值。
    _syncFromBindableIfNeeded();
  }

  @override
  void didUpdateWidget(ParkInputNumber old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && widget.value != null) {
      _current = _clamp(widget.value!);
      _controller.text = _format(_current);
    }
  }

  /// 若已绑定，用绑定模型的当前值同步内部状态与控制器文本。
  void _syncFromBindableIfNeeded() {
    final double? v = boundValue;
    if (v != null) {
      _current = _clamp(v);
      _controller.text = _format(_current);
    }
  }

  @override
  void onBindableChanged() {
    // 绑定模型外部变化（如表单重置）时刷新文本框显示值。
    final double? v = boundValue;
    if (v != null) {
      _current = _clamp(v);
      _controller.text = _format(_current);
    }
    super.onBindableChanged();
  }

  double _clamp(double v) => v.clamp(widget.min, widget.max);
  String _format(double v) {
    if (widget.precision != null) return v.toStringAsFixed(widget.precision!);
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  /// 按步进/精度小数位规整，消除二进制浮点累积误差
  /// （0.1 步进连加三次得到 0.30000000000000004 → 0.3，P1-5）。
  double _roundToStep(double v) {
    final int stepDecimals = _decimalPlaces(widget.step);
    final int p = widget.precision ?? stepDecimals;
    if (p <= 0) return v;
    final double factor = math.pow(10, p).toDouble();
    return (v * factor).roundToDouble() / factor;
  }

  int _decimalPlaces(double value) {
    final String s = value.toString();
    final int idx = s.indexOf('.');
    if (idx < 0) return 0;
    return s.length - idx - 1;
  }

  void _setValue(double v) {
    final double rounded = _roundToStep(v);
    final double clamped = _clamp(rounded);
    if (clamped == _current) return;
    setState(() {
      _current = clamped;
      _controller.text = _format(clamped);
    });
    widget.onChanged?.call(clamped);
    // 同步到绑定模型（B22）。
    boundValue = clamped;
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
      minimumSize: WidgetStateProperty.all(Size(park.sizing.buttonHeightMd, park.sizing.buttonHeightMd)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: park.radius.brSm)),
      backgroundColor: WidgetStateProperty.all(park.colors.surface),
      side: WidgetStateProperty.all(BorderSide(color: park.colors.border)),
    );

    final input = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: ParkLocalizations.of(context).decreaseValue,
          button: true,
          child: _buildButton(Icons.remove, _decrement, _atMin, btnStyle, park),
        ),
        SizedBox(width: spacing.xs),
        Semantics(
          textField: true,
          child: SizedBox(
            width: park.sizing.buttonHeightMd * 2,
            child: TextField(
              controller: _controller,
              enabled: !widget.disabled,
              readOnly: widget.readOnly,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: park.typography.sizeBodySmall, color: park.colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: park.spacing.sm),
                border: OutlineInputBorder(borderRadius: park.radius.brSm, borderSide: BorderSide(color: park.colors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: park.radius.brSm, borderSide: BorderSide(color: park.colors.border)),
              ),
              onSubmitted: (t) {
                final v = double.tryParse(t);
                if (v != null) _setValue(v);
                else _controller.text = _format(_current);
              },
            ),
          ),
        ),
        SizedBox(width: spacing.xs),
        Semantics(
          label: ParkLocalizations.of(context).increaseValue,
          button: true,
          child: _buildButton(Icons.add, _increment, _atMax, btnStyle, park),
        ),
      ],
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(widget.label!, style: TextStyle(fontSize: park.typography.sizeCaption, color: park.colors.textSecondary)),
          ),
          SizedBox(height: spacing.xs),
          input,
        ],
      );
    }
    return input;
  }

  Widget _buildButton(IconData icon, VoidCallback onTap, bool disabled, ButtonStyle style, ParkThemeData park) {
    return SizedBox(
      width: park.sizing.buttonHeightMd,
      height: park.sizing.buttonHeightMd,
      child: Material(
        color: park.colors.surface,
        borderRadius: park.radius.brSm,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: park.radius.brSm,
          child: Center(
            child: Icon(icon, size: 16, color: disabled ? park.colors.textDisabled : park.colors.textPrimary),
          ),
        ),
      ),
    );
  }
}
