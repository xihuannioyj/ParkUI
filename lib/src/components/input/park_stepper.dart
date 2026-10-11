import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

/// 步进器尺寸枚举
enum ParkStepperSize { small, medium, large }

/// 步进器主题枚举
enum ParkStepperTheme { filled, outline }

/// Park UI 步进器（数量选择器）
///
/// 基于 [FormField<int>] 封装，提供 [−] [value] [+] 样式的数值调节控件，
/// 支持最小/最大值限制、步长、禁用等。
///
/// ```dart
/// ParkStepper(
///   value: 1,
///   min: 0,
///   max: 99,
///   step: 1,
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkStepper extends FormField<int> implements ParkBindableWidget {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkStepper({
    super.key,
    this.bindKey,
    this.bindingService,
    int value = 0,
    this.min,
    this.max,
    this.step = 1,
    this.onChanged,
    this.disabled = false,
    this.inputMode = false,
    this.size = ParkStepperSize.medium,
    this.longPressIncrement = true,
    this.formatter,
    this.theme = ParkStepperTheme.filled,
    this.readOnly = false,
    this.precision,
    this.prefix,
    this.suffix,
    this.placeholder,
    this.onOverLimit,
    this.inputReadOnly = false,
    this.stringMode = false,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
  })  : // P1-2：step<=0 时步进无意义（同值回调风暴/方向反转），构造期拦截。
        assert(step > 0, 'step must be greater than 0'),
        assert(min == null || max == null || min <= max,
            'min must be <= max'),
        super(
          initialValue: value,
          builder: (FormFieldState<int> field) {
            final state = field as _ParkStepperState;
            final park =
                Theme.of(state.context).extension<ParkThemeData>() ??
                    ParkThemeData.light();
            return _ParkStepperBuilder(state: state, park: park);
          },
        );

  final int? min;
  final int? max;
  final int step;
  final ValueChanged<int>? onChanged;
  final bool disabled;

  /// 是否显示可编辑的文本框替代纯文字显示。
  final bool inputMode;

  /// 步进器尺寸。
  final ParkStepperSize size;

  /// 长按 +/- 按钮是否持续递增/递减。
  final bool longPressIncrement;

  /// 自定义显示格式化回调。
  final String Function(int value)? formatter;

  /// 按钮样式主题。
  final ParkStepperTheme theme;

  /// 是否只读。外观正常但 +/- 按钮不可交互。
  final bool readOnly;

  /// 小数位数精度。为 null 时使用整数模式。
  final int? precision;

  /// 输入框前的前置 Widget。
  final Widget? prefix;

  /// 输入框后的后缀 Widget。
  final Widget? suffix;

  /// 输入模式下的占位文字。
  final String? placeholder;

  /// 超出 min/max 限制时的回调
  final VoidCallback? onOverLimit;

  /// 输入框是否只读（仅 inputMode 下有效，禁止手动输入）
  final bool inputReadOnly;

  /// 字符串模式（使用字符串存储大数值，避免 int 溢出）
  final bool stringMode;

  @override
  FormFieldState<int> createState() => _ParkStepperState();
}

class _ParkStepperState extends FormFieldState<int>
    with BindableFormFieldMixin<int> {
  void decrement() {
    final widget = this.widget as ParkStepper;
    if (widget.disabled || widget.readOnly) return;
    final current = value ?? 0;
    final newValue = current - widget.step;
    if (widget.min != null && newValue < widget.min!) {
      widget.onOverLimit?.call();
      return;
    }
    didChange(newValue);
    widget.onChanged?.call(newValue);
  }

  void increment() {
    final widget = this.widget as ParkStepper;
    if (widget.disabled || widget.readOnly) return;
    final current = value ?? 0;
    final newValue = current + widget.step;
    if (widget.max != null && newValue > widget.max!) {
      widget.onOverLimit?.call();
      return;
    }
    didChange(newValue);
    widget.onChanged?.call(newValue);
  }

  @override
  void didUpdateWidget(covariant FormField<int> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // FormField 只在首次创建时读取 initialValue，父级改变 value 时必须自行同步，
    // 否则受控用法（重置 / 外部联动）不会更新显示（含文本框内容）。
    if (widget.initialValue != oldWidget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

class _ParkStepperBuilder extends StatefulWidget {
  const _ParkStepperBuilder({required this.state, required this.park});

  final _ParkStepperState state;
  final ParkThemeData park;

  @override
  State<_ParkStepperBuilder> createState() => _ParkStepperBuilderState();
}

class _ParkStepperBuilderState extends State<_ParkStepperBuilder> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final current = widget.state.value ?? 0;
    final widget_ = widget.state.widget as ParkStepper;
    final initialText = widget_.formatter?.call(current)
        ?? _formatDisplay(current, widget_.precision, stringMode: widget_.stringMode);
    _textController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ParkStepperBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget.state.value ?? 0;
    final widget_ = widget.state.widget as ParkStepper;
    final displayText = widget_.formatter?.call(current) ?? _formatDisplay(current, widget_.precision, stringMode: widget_.stringMode);
    if (_textController.text != displayText) {
      _textController.text = displayText;
    }
  }

  void _onSubmitted(String text) {
    final widget_ = widget.state.widget as ParkStepper;
    // In stringMode, display shows formatted values like "3.00"; parse as double first.
    int? parsed = int.tryParse(text);
    if (parsed == null && widget_.stringMode) {
      parsed = double.tryParse(text)?.toInt();
    }
    if (parsed != null) {
      int clamped = parsed;
      if (widget_.min != null) clamped = clamped < widget_.min! ? widget_.min! : clamped;
      if (widget_.max != null) clamped = clamped > widget_.max! ? widget_.max! : clamped;
      widget.state.didChange(clamped);
      widget_.onChanged?.call(clamped);
      _textController.text = widget_.formatter?.call(clamped) ?? _formatDisplay(clamped, widget_.precision, stringMode: widget_.stringMode);
    } else {
      // revert to current value
      final current = widget.state.value ?? 0;
      _textController.text = widget_.formatter?.call(current) ?? _formatDisplay(current, widget_.precision, stringMode: widget_.stringMode);
    }
  }

  String _formatDisplay(int value, int? precision, {bool stringMode = false}) {
    if (stringMode) {
      final effectivePrecision = (precision != null && precision > 0) ? precision : 2;
      return value.toDouble().toStringAsFixed(effectivePrecision);
    }
    if (precision == null || precision <= 0) return '$value';
    return value.toDouble().toStringAsFixed(precision);
  }

  double _buttonSize() {
    final sz = (widget.state.widget as ParkStepper).size;
    switch (sz) {
      case ParkStepperSize.small:
        return 28;
      case ParkStepperSize.medium:
        return 36;
      case ParkStepperSize.large:
        return 44;
    }
  }

  double _iconSize() {
    final sz = (widget.state.widget as ParkStepper).size;
    switch (sz) {
      case ParkStepperSize.small:
        return 12;
      case ParkStepperSize.medium:
        return 16;
      case ParkStepperSize.large:
        return 20;
    }
  }

  double _fontSize() {
    final sz = (widget.state.widget as ParkStepper).size;
    final park = widget.park;
    switch (sz) {
      case ParkStepperSize.small:
        return park.typography.sizeBodySmall;
      case ParkStepperSize.medium:
        return park.typography.sizeBody;
      case ParkStepperSize.large:
        return park.typography.sizeH3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final widget_ = widget.state.widget as ParkStepper;
    final current = widget.state.value ?? 0;
    final isDisabled = widget_.disabled;
    final atMin = widget_.min != null && current <= widget_.min!;
    final atMax = widget_.max != null && current >= widget_.max!;
    final btnSize = _buttonSize();
    final iconSz = _iconSize();
    final fontSize = _fontSize();
    final displayText = widget_.formatter?.call(current) ?? _formatDisplay(current, widget_.precision, stringMode: widget_.stringMode);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget_.prefix != null) ...[
          widget_.prefix!,
          SizedBox(width: widget.park.spacing.xs),
        ],
        _StepperButton(
          icon: CupertinoIcons.minus,
          onTap: atMin || isDisabled || widget_.readOnly ? null : widget.state.decrement,
          park: widget.park,
          buttonSize: btnSize,
          iconSize: iconSz,
          longPressEnabled: widget_.longPressIncrement && !widget_.readOnly,
          onLongPressTick: widget.state.decrement,
          theme: widget_.theme,
        ),
        if (widget_.inputMode)
          Container(
            constraints: BoxConstraints(minWidth: btnSize * 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: widget.park.spacing.sm,
              vertical: widget.park.spacing.xs,
            ),
            child: TextField(
              controller: _textController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              enabled: !isDisabled,
              readOnly: widget_.inputReadOnly,
              style: widget.park.typography.body.copyWith(
                color: isDisabled
                    ? widget.park.colors.textDisabled
                    : widget.park.colors.textPrimary,
                fontWeight: widget.park.typography.weightMedium,
                fontSize: fontSize,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                  widget_.stringMode ? r'^-?\d*\.?\d*' : r'^-?\d*',
                )),
              ],
              onSubmitted: _onSubmitted,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget_.placeholder,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          )
        else
          Container(
            constraints: BoxConstraints(minWidth: btnSize * 1.2),
            padding: EdgeInsets.symmetric(
              horizontal: widget.park.spacing.sm,
              vertical: widget.park.spacing.xs,
            ),
            alignment: Alignment.center,
            child: Text(
              displayText,
              style: widget.park.typography.body.copyWith(
                color: isDisabled
                    ? widget.park.colors.textDisabled
                    : widget.park.colors.textPrimary,
                fontWeight: widget.park.typography.weightMedium,
                fontSize: fontSize,
              ),
            ),
          ),
        _StepperButton(
          icon: CupertinoIcons.plus,
          onTap: atMax || isDisabled || widget_.readOnly ? null : widget.state.increment,
          park: widget.park,
          buttonSize: btnSize,
          iconSize: iconSz,
          longPressEnabled: widget_.longPressIncrement && !widget_.readOnly,
          onLongPressTick: widget.state.increment,
          theme: widget_.theme,
        ),
        if (widget_.suffix != null) ...[
          SizedBox(width: widget.park.spacing.xs),
          widget_.suffix!,
        ],
      ],
    );
  }
}

class _StepperButton extends StatefulWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.park,
    this.buttonSize = 36,
    this.iconSize = 16,
    this.longPressEnabled = true,
    this.onLongPressTick,
    this.theme = ParkStepperTheme.filled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final ParkThemeData park;
  final double buttonSize;
  final double iconSize;
  final bool longPressEnabled;
  final VoidCallback? onLongPressTick;
  final ParkStepperTheme theme;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  Timer? _repeatTimer;

  void _startRepeat() {
    if (!widget.longPressEnabled || widget.onTap == null) return;
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      // P1-1：到边界后父组件把 onTap 置 null（按钮禁用），
      // 此时停止重复，否则 onOverLimit 以 ~8Hz 无限重放。
      if (widget.onTap == null) {
        _stopRepeat();
        return;
      }
      widget.onLongPressTick?.call();
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stopRepeat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final park = widget.park;

    Color bgColor;
    Color borderColor;
    Color iconColor;

    if (!isEnabled) {
      bgColor = park.colors.disabledBg;
      borderColor = park.colors.borderLight;
      iconColor = park.colors.textDisabled;
    } else if (widget.theme == ParkStepperTheme.filled) {
      bgColor = park.colors.surface;
      borderColor = park.colors.border;
      iconColor = park.colors.brand;
    } else {
      // outline theme
      bgColor = Colors.transparent;
      borderColor = park.colors.brand;
      iconColor = park.colors.brand;
    }

    final label = widget.icon == CupertinoIcons.minus ? 'decrement' : 'increment';

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: widget.longPressEnabled && isEnabled
          ? (_) => _startRepeat()
          : null,
      onLongPressEnd: widget.longPressEnabled && isEnabled
          ? (_) => _stopRepeat()
          : null,
      onLongPressCancel: widget.longPressEnabled && isEnabled
          ? _stopRepeat
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.buttonSize,
        height: widget.buttonSize,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: park.radius.brSm,
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Icon(
          widget.icon,
          size: widget.iconSize,
          color: iconColor,
        ),
      ),
    ),
    );
  }
}
