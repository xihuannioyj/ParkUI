import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';

/// Park UI 滑块
///
/// 基于 [FormField<double>] 封装，支持连续/离散滑动、数值显示、
/// 自定义激活色等功能。
///
/// ```dart
/// ParkSlider(
///   value: 50,
///   min: 0,
///   max: 100,
///   divisions: 10,
///   showValue: true,
///   onChanged: (v) => print(v),
/// )
/// ```
class ParkSlider extends FormField<double> {
  /// 绑定键（点号分隔的路径，如 user.name）。不设时组件行为不变（零侵入）。
  final String? bindKey;

  /// 绑定服务实例。不设时尝试从 [ParkBindingFormScope] 获取。
  final ParkBindingService? bindingService;

  ParkSlider({
    super.key,
    this.bindKey,
    this.bindingService,
    double value = 0,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.activeColor,
    this.showValue = false,
    this.range = false,
    this.rangeStart,
    this.rangeEnd,
    this.onRangeChanged,
    this.marks,
    this.showTooltip = true,
    this.vertical = false,
    this.step,
    this.tooltipBuilder,
    this.disabled = false,
    this.readOnly = false,
    this.reverse = false,
    this.dots = false,
    this.onChangeStart,
    this.inactiveColor,
    this.thumbIcon,
    this.included = true,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
  }) : super(
          initialValue: value.clamp(min, max),
          builder: (FormFieldState<double> field) {
            final state = field as _ParkSliderState;
            final park =
                Theme.of(state.context).extension<ParkThemeData>() ??
                    ParkThemeData.light();
            return _ParkSliderBuilder(state: state, park: park);
          },
        );

  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color? activeColor;
  final bool showValue;

  /// 是否启用范围选择模式（双滑块）
  final bool range;

  /// 范围选择起始值
  final double? rangeStart;

  /// 范围选择结束值
  final double? rangeEnd;

  /// 范围变更回调
  final void Function(double start, double end)? onRangeChanged;

  /// 刻度标记，key 为数值，value 为显示文字
  final Map<double, String>? marks;

  /// 是否在拖动时显示拇指上方的 tooltip。
  final bool showTooltip;

  /// 是否垂直方向渲染滑块。
  final bool vertical;

  /// 步长。若提供且 divisions 为 null，则自动计算 divisions。
  final double? step;

  /// 自定义 tooltip 文字格式化回调。
  final String Function(double value)? tooltipBuilder;

  /// 是否禁用滑块。默认 false。
  final bool disabled;

  /// 是否只读。外观正常但不可交互。
  final bool readOnly;

  /// 是否反转方向（从右到左）。
  final bool reverse;

  /// 是否在步进刻度处显示圆点。
  final bool dots;

  /// 拖动开始回调
  final ValueChanged<double>? onChangeStart;

  /// 非激活轨道颜色（默认使用 borderLight）
  final Color? inactiveColor;

  /// 拇指上的自定义图标 Widget
  final Widget? thumbIcon;

  /// 是否高亮已包含的轨道段（marks 之间的区间）。默认 true。
  final bool included;

  /// 根据 step 计算出的有效 divisions。
  int? get effectiveDivisions {
    if (divisions != null) return divisions;
    if (step != null && step! > 0) {
      final range = max - min;
      final d = (range / step!).round();
      return d > 0 ? d : null;
    }
    return null;
  }

  @override
  FormFieldState<double> createState() => _ParkSliderState();
}

class _ParkSliderState extends FormFieldState<double>
    with BindableFormFieldMixin<double> {
  @override
  void didChange(double? value) {
    super.didChange(value);
    (widget as ParkSlider).onChanged?.call(value ?? 0);
  }
}

class _ParkSliderBuilder extends StatelessWidget {
  const _ParkSliderBuilder({required this.state, required this.park});

  final _ParkSliderState state;
  final ParkThemeData park;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as ParkSlider;
    final activeColor = widget.activeColor ?? park.colors.brand;
    final effDivisions = widget.effectiveDivisions;

    if (widget.range) {
      return _buildRangeSlider(context, widget, activeColor, effDivisions);
    }

    final currentValue = state.value ?? widget.min;
    final isInteractive = !widget.disabled && !widget.readOnly;

    Widget sliderWidget = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: widget.disabled
            ? activeColor.withValues(alpha: 0.4)
            : activeColor,
        inactiveTrackColor: widget.inactiveColor ?? park.colors.borderLight,
        thumbColor: widget.disabled
            ? activeColor.withValues(alpha: 0.4)
            : activeColor,
        overlayColor: activeColor.withValues(alpha: 0.12),
        valueIndicatorColor: activeColor,
        showValueIndicator:
            widget.showTooltip ? ShowValueIndicator.onDrag : ShowValueIndicator.never,
        valueIndicatorTextStyle: TextStyle(
          color: park.colors.textOnBrand,
          fontSize: park.typography.sizeBodySmall,
        ),
        trackHeight: 4,
        thumbShape: _ParkSliderThumb(
          color: widget.disabled ? activeColor.withValues(alpha: 0.4) : activeColor,
          park: park,
        ),
        valueIndicatorShape: widget.showTooltip
            ? const PaddleSliderValueIndicatorShape()
            : const _HiddenValueIndicatorShape(),
      ),
      child: Slider(
        value: currentValue,
        min: widget.min,
        max: widget.max,
        divisions: effDivisions,
        label: widget.showTooltip
            ? (widget.tooltipBuilder?.call(currentValue) ??
                currentValue.toStringAsFixed(0))
            : null,
        onChanged: isInteractive
            ? (v) {
                state.didChange(v);
              }
            : null,
        onChangeStart: isInteractive ? widget.onChangeStart : null,
        onChangeEnd: isInteractive ? widget.onChangeEnd : null,
      ),
    );

    if (widget.reverse) {
      sliderWidget = Directionality(
        textDirection: TextDirection.rtl,
        child: sliderWidget,
      );
    }

    if (widget.vertical) {
      sliderWidget = RotatedBox(
        quarterTurns: 3,
        child: sliderWidget,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '数值',
                style: park.typography.bodySmall.copyWith(
                  color: park.colors.textSecondary,
                ),
              ),
              Text(
                _formatValue(currentValue, effDivisions),
                style: park.typography.bodySmall.copyWith(
                  color: park.colors.textPrimary,
                  fontWeight: park.typography.weightMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: park.spacing.xs),
        ],
        sliderWidget,
        // Dots at step marks
        if (widget.dots && effDivisions != null && effDivisions > 0)
          Padding(
            padding: EdgeInsets.only(top: park.spacing.xs),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dots = <Widget>[];
                for (int i = 0; i <= effDivisions; i++) {
                  final ratio = i / effDivisions;
                  final stepValue = widget.min + ratio * (widget.max - widget.min);
                  final isActive = stepValue <= currentValue;
                  dots.add(
                    Positioned(
                      left: ratio * constraints.maxWidth - 3,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? activeColor : park.colors.borderLight,
                        ),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 6,
                  child: Stack(children: dots),
                );
              },
            ),
          ),
        if (widget.marks != null && widget.marks!.isNotEmpty)
          _buildMarks(widget.marks!, widget.min, widget.max, activeColor),
      ],
    );
  }

  String _formatValue(double value, int? divisions) {
    if (divisions != null) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildMarks(
    Map<double, String> marks,
    double minVal,
    double maxVal,
    Color activeColor,
  ) {
    final totalRange = maxVal - minVal;
    if (totalRange <= 0) return const SizedBox.shrink();

    final entries = marks.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Padding(
      padding: EdgeInsets.only(top: park.spacing.xs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: 24,
            child: Stack(
              children: entries.map((entry) {
                final ratio = ((entry.key - minVal) / totalRange)
                    .clamp(0.0, 1.0);
                return Positioned(
                  left: ratio * constraints.maxWidth - 20,
                  child: SizedBox(
                    width: 40,
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.center,
                      style: park.typography.caption.copyWith(
                        color: park.colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeSlider(
    BuildContext context,
    ParkSlider widget,
    Color activeColor,
    int? effDivisions,
  ) {
    final startVal = widget.rangeStart ?? widget.min;
    final endVal = widget.rangeEnd ?? widget.max;

    Widget sliderWidget = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: park.colors.borderLight,
        thumbColor: activeColor,
        overlayColor: activeColor.withValues(alpha: 0.12),
        rangeThumbShape: const RoundRangeSliderThumbShape(),
        trackHeight: 4,
      ),
      child: RangeSlider(
        values: RangeValues(
          startVal.clamp(widget.min, widget.max),
          endVal.clamp(widget.min, widget.max),
        ),
        min: widget.min,
        max: widget.max,
        divisions: effDivisions,
        onChanged: (values) {
          widget.onRangeChanged?.call(values.start, values.end);
        },
      ),
    );

    if (widget.vertical) {
      sliderWidget = RotatedBox(
        quarterTurns: 3,
        child: sliderWidget,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(startVal, effDivisions),
                style: park.typography.bodySmall.copyWith(
                  color: park.colors.textPrimary,
                  fontWeight: park.typography.weightMedium,
                ),
              ),
              Text(
                _formatValue(endVal, effDivisions),
                style: park.typography.bodySmall.copyWith(
                  color: park.colors.textPrimary,
                  fontWeight: park.typography.weightMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: park.spacing.xs),
        ],
        sliderWidget,
        if (widget.marks != null && widget.marks!.isNotEmpty)
          _buildMarks(widget.marks!, widget.min, widget.max, activeColor),
      ],
    );
  }
}

/// 自定义圆形拇指，带阴影效果
class _ParkSliderThumb extends SliderComponentShape {
  const _ParkSliderThumb({
    required this.color,
    required this.park,
  });

  final Color color;
  final ParkThemeData park;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(20, 20);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer shadow
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: 10)),
      const Color(0x1A000000),
      4.0,
      false,
    );

    // White circle background
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Colored border ring
    canvas.drawCircle(
      center,
      9,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner colored dot
    canvas.drawCircle(
      center,
      4,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }
}

/// 隐藏的 value indicator shape，用于 showTooltip=false 时不渲染指示器。
class _HiddenValueIndicatorShape extends SliderComponentShape {
  const _HiddenValueIndicatorShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    // no-op: hide indicator
  }
}
