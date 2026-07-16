import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../binding/park_binding_form_field_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../l10n/park_localizations.dart';

/// Park UI 滑块
///
/// 基于 [FormField<double>] 封装，支持连续/离散滑动、数值显示、
/// 刻度标记与吸附、tooltip 气泡、自定义激活色、双滑块范围选择等功能。
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
///
/// // 范围选择模式
/// ParkSlider(
///   range: true,
///   rangeStart: 20,
///   rangeEnd: 80,
///   min: 0,
///   max: 100,
///   showValue: true,
///   onRangeChanged: (start, end) => print('$start - $end'),
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

  /// 刻度标记位置列表（与 min/max 同量纲的绝对值）。
  ///
  /// 提供此参数时，滑块自动吸附到最近的刻度值，并在轨道上渲染刻度线与标签。
  /// 值必须在 [min, max] 范围内。
  ///
  /// ```dart
  /// ParkSlider(
  ///   min: 0, max: 100,
  ///   marks: [0, 25, 50, 75, 100],
  /// )
  /// ```
  final List<double>? marks;

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

  /// 根据 marks 计算出的有效 divisions（marks.length - 1），
  /// 优先于 [effectiveDivisions]。
  int? get marksDivisions {
    if (marks != null && marks!.length > 1) return marks!.length - 1;
    return null;
  }

  @override
  FormFieldState<double> createState() => _ParkSliderState();
}

class _ParkSliderState extends FormFieldState<double>
    with BindableFormFieldMixin<double> {
  double _rangeStart = 0;
  double _rangeEnd = 100;

  @override
  void initState() {
    super.initState();
    final w = widget as ParkSlider;
    if (w.range) {
      _rangeStart = (w.rangeStart ?? w.min).clamp(w.min, w.max);
      _rangeEnd = (w.rangeEnd ?? w.max).clamp(w.min, w.max);
    }
  }

  @override
  void didUpdateWidget(covariant FormField<double> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSlider = oldWidget as ParkSlider;
    final newSlider = widget as ParkSlider;
    if (newSlider.range) {
      final newStart = (newSlider.rangeStart ?? newSlider.min)
          .clamp(newSlider.min, newSlider.max);
      final newEnd = (newSlider.rangeEnd ?? newSlider.max)
          .clamp(newSlider.min, newSlider.max);
      if (newStart != _rangeStart || newEnd != _rangeEnd) {
        setState(() {
          _rangeStart = newStart;
          _rangeEnd = newEnd;
        });
      }
    }
    // Sync single value if changed externally
    final newInitial = newSlider.initialValue;
    final oldInitial = oldSlider.initialValue;
    if (newInitial != null && newInitial != oldInitial && newInitial != value) {
      setValue(newInitial.clamp(newSlider.min, newSlider.max));
    }
  }

  @override
  void didChange(double? value) {
    super.didChange(value);
    (widget as ParkSlider).onChanged?.call(value ?? 0);
  }

  /// 将值吸附到最近的刻度标记。
  double _snapToMark(double value, List<double> marks) {
    if (marks.isEmpty) return value;
    int nearest = 0;
    double minDist = double.infinity;
    for (int i = 0; i < marks.length; i++) {
      final dist = (value - marks[i]).abs();
      if (dist < minDist) {
        minDist = dist;
        nearest = i;
      }
    }
    return marks[nearest];
  }

  /// 处理 onChanged，包含吸附逻辑。
  void _handleChanged(double value) {
    final widget = this.widget as ParkSlider;
    double newValue = value;
    if (widget.marks != null && widget.marks!.isNotEmpty) {
      newValue = _snapToMark(value, widget.marks!);
    }
    didChange(newValue);
  }

  /// 处理 onChangeEnd，包含吸附逻辑。
  void _handleChangeEnd(double value) {
    final widget = this.widget as ParkSlider;
    double snapped = value;
    if (widget.marks != null && widget.marks!.isNotEmpty) {
      snapped = _snapToMark(value, widget.marks!);
    }
    widget.onChangeEnd?.call(snapped);
  }

  /// 处理范围滑块 onChange，包含吸附逻辑。
  void _handleRangeChanged(RangeValues values) {
    final w = widget as ParkSlider;
    double newStart = values.start;
    double newEnd = values.end;

    if (w.marks != null && w.marks!.isNotEmpty) {
      final snappedStart = _snapToMark(values.start, w.marks!);
      final snappedEnd = _snapToMark(values.end, w.marks!);
      // 确保 start <= end，根据拖动方向处理边界情况
      if (snappedStart <= snappedEnd) {
        newStart = snappedStart;
        newEnd = snappedEnd;
      } else {
        // 两拇指交叉时，以被拖动的那一个为准
        if (values.start != _rangeStart) {
          // 正在拖动 start 拇指 — start 撞上 end，锁定 end
          newStart = newEnd;
        } else {
          // 正在拖动 end 拇指 — end 撞上 start，锁定 start
          newEnd = newStart;
        }
      }
    }

    setState(() {
      _rangeStart = newStart;
      _rangeEnd = newEnd;
    });

    w.onRangeChanged?.call(newStart, newEnd);
    // 向后兼容：单值回调使用 start 值
    w.onChanged?.call(newStart);
  }

  /// 处理范围滑块 onChangeEnd，包含吸附逻辑。
  void _handleRangeChangeEnd(RangeValues values) {
    final w = widget as ParkSlider;
    double snappedStart = values.start;
    double snappedEnd = values.end;

    if (w.marks != null && w.marks!.isNotEmpty) {
      snappedStart = _snapToMark(values.start, w.marks!);
      snappedEnd = _snapToMark(values.end, w.marks!);
      if (snappedStart > snappedEnd) {
        if (values.start != _rangeStart) {
          snappedStart = snappedEnd;
        } else {
          snappedEnd = snappedStart;
        }
      }
    }

    w.onChangeEnd?.call(snappedStart);
  }
}

class _ParkSliderBuilder extends StatelessWidget {
  const _ParkSliderBuilder({required this.state, required this.park});

  final _ParkSliderState state;
  final ParkThemeData park;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as ParkSlider;
    final l10n = ParkLocalizations.of(context);
    final activeColor = widget.activeColor ?? park.colors.brand;
    final effDivisions =
        widget.marksDivisions ?? widget.effectiveDivisions;

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
            ? (v) => state._handleChanged(v)
            : null,
        onChangeStart: isInteractive ? widget.onChangeStart : null,
        onChangeEnd: isInteractive
            ? (v) => state._handleChangeEnd(v)
            : null,
      ),
    );

    // 当有 marks 时，在轨道上叠加刻度线
    if (widget.marks != null && widget.marks!.isNotEmpty) {
      sliderWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          sliderWidget,
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalRange = widget.max - widget.min;
                  if (totalRange <= 0) return const SizedBox.shrink();

                  // Flutter Slider 默认左右各有 24px 的 thumb 内边距
                  const thumbPad = 24.0;
                  final trackWidth =
                      (constraints.maxWidth - thumbPad * 2).clamp(0.0, double.infinity);

                  // 轨道垂直居中位置（trackHeight=4，所以中心在 Slider 高度中间附近）
                  const trackCenterY = 14.0;

                  return Stack(
                    children: widget.marks!.map((markVal) {
                      final ratio =
                          ((markVal - widget.min) / totalRange).clamp(0.0, 1.0);
                      final left = thumbPad + ratio * trackWidth - 1.0;

                      final isActive = widget.included && markVal <= currentValue;

                      return Positioned(
                        left: left,
                        top: trackCenterY - 6.0,
                        child: Container(
                          width: 2,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isActive
                                ? activeColor
                                : (widget.inactiveColor ?? park.colors.borderLight),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

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

    return Semantics(
      slider: true,
      value: _formatValue(currentValue, effDivisions),
      enabled: isInteractive,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        if (widget.showValue) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sliderValueLabel,
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
          _buildMarks(
            widget.marks!,
            widget.min,
            widget.max,
            activeColor,
            currentValue,
          ),
      ],
      ),
    );
  }

  String _formatValue(double value, int? divisions) {
    if (divisions != null) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildMarks(
    List<double> marks,
    double minVal,
    double maxVal,
    Color activeColor,
    double currentValue, {
    double? rangeEndValue,
  }) {
    final totalRange = maxVal - minVal;
    if (totalRange <= 0) return const SizedBox.shrink();

    final sortedMarks = List<double>.from(marks)..sort();

    return Padding(
      padding: EdgeInsets.only(top: park.spacing.xs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const thumbPad = 24.0;
          final trackWidth =
              (constraints.maxWidth - thumbPad * 2).clamp(0.0, double.infinity);

          return SizedBox(
            height: 20,
            child: Stack(
              children: sortedMarks.map((markVal) {
                final ratio =
                    ((markVal - minVal) / totalRange).clamp(0.0, 1.0);
                final left = thumbPad + ratio * trackWidth - 20;

                final sliderWidget = state.widget as ParkSlider;
                final isActive = sliderWidget.included && (rangeEndValue != null
                    ? (markVal >= currentValue && markVal <= rangeEndValue)
                    : (markVal <= currentValue));

                return Positioned(
                  left: left,
                  child: SizedBox(
                    width: 40,
                    child: Text(
                      markVal == markVal.roundToDouble()
                          ? markVal.toStringAsFixed(0)
                          : markVal.toStringAsFixed(1),
                      textAlign: TextAlign.center,
                      style: park.typography.caption.copyWith(
                        color: isActive
                            ? activeColor
                            : park.colors.textSecondary,
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
    final startVal = state._rangeStart.clamp(widget.min, widget.max);
    final endVal = state._rangeEnd.clamp(widget.min, widget.max);
    final isInteractive = !widget.disabled && !widget.readOnly;

    final rangeValues = RangeValues(startVal, endVal);

    Widget sliderWidget = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: widget.disabled
            ? activeColor.withValues(alpha: 0.4)
            : activeColor,
        inactiveTrackColor: widget.inactiveColor ?? park.colors.borderLight,
        overlayColor: activeColor.withValues(alpha: 0.12),
        trackHeight: 4,
        rangeThumbShape: _ParkRangeSliderThumb(
          color: widget.disabled
              ? activeColor.withValues(alpha: 0.4)
              : activeColor,
          park: park,
        ),
        rangeValueIndicatorShape: widget.showTooltip
            ? const PaddleRangeSliderValueIndicatorShape()
            : const _HiddenRangeValueIndicatorShape(),
        valueIndicatorColor: activeColor,
        valueIndicatorTextStyle: TextStyle(
          color: park.colors.textOnBrand,
          fontSize: park.typography.sizeBodySmall,
        ),
        showValueIndicator:
            widget.showTooltip ? ShowValueIndicator.onDrag : ShowValueIndicator.never,
      ),
      child: RangeSlider(
        values: rangeValues,
        min: widget.min,
        max: widget.max,
        divisions: effDivisions,
        labels: widget.showTooltip
            ? RangeLabels(
                widget.tooltipBuilder?.call(startVal) ??
                    startVal.toStringAsFixed(effDivisions != null ? 0 : 1),
                widget.tooltipBuilder?.call(endVal) ??
                    endVal.toStringAsFixed(effDivisions != null ? 0 : 1),
              )
            : null,
        onChanged: isInteractive
            ? (values) => state._handleRangeChanged(values)
            : null,
        onChangeStart: isInteractive
            ? (values) => widget.onChangeStart?.call(values.start)
            : null,
        onChangeEnd: isInteractive
            ? (values) => state._handleRangeChangeEnd(values)
            : null,
      ),
    );

    // 当有 marks 时，在轨道上叠加刻度线（范围模式）
    if (widget.marks != null && widget.marks!.isNotEmpty) {
      sliderWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          sliderWidget,
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalRange = widget.max - widget.min;
                  if (totalRange <= 0) return const SizedBox.shrink();

                  const thumbPad = 24.0;
                  final trackWidth =
                      (constraints.maxWidth - thumbPad * 2).clamp(0.0, double.infinity);
                  const trackCenterY = 14.0;

                  return Stack(
                    children: widget.marks!.map((markVal) {
                      final ratio =
                          ((markVal - widget.min) / totalRange).clamp(0.0, 1.0);
                      final left = thumbPad + ratio * trackWidth - 1.0;

                      // 范围模式：在 [startVal, endVal] 区间内的 mark 为激活色
                      final isActive = widget.included &&
                          markVal >= startVal && markVal <= endVal;

                      return Positioned(
                        left: left,
                        top: trackCenterY - 6.0,
                        child: Container(
                          width: 2,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isActive
                                ? activeColor
                                : (widget.inactiveColor ?? park.colors.borderLight),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

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

    return Semantics(
      slider: true,
      value:
          '${_formatValue(startVal, effDivisions)} - ${_formatValue(endVal, effDivisions)}',
      enabled: isInteractive,
      child: Column(
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
          // Dots at step marks（范围模式）
          if (widget.dots && effDivisions != null && effDivisions > 0)
            Padding(
              padding: EdgeInsets.only(top: park.spacing.xs),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final dots = <Widget>[];
                  for (int i = 0; i <= effDivisions; i++) {
                    final ratio = i / effDivisions;
                    final stepValue =
                        widget.min + ratio * (widget.max - widget.min);
                    final isActive =
                        stepValue >= startVal && stepValue <= endVal;
                    dots.add(
                      Positioned(
                        left: ratio * constraints.maxWidth - 3,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive
                                ? activeColor
                                : park.colors.borderLight,
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
            _buildMarks(
              widget.marks!,
              widget.min,
              widget.max,
              activeColor,
              startVal,
              rangeEndValue: endVal,
            ),
        ],
      ),
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
      park.colors.textPrimary.withValues(alpha: 0.1),
      4.0,
      false,
    );

    // White circle background
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = park.colors.surface
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

/// 范围滑块自定义圆形拇指，视觉风格与 [_ParkSliderThumb] 一致。
class _ParkRangeSliderThumb extends RangeSliderThumbShape {
  const _ParkRangeSliderThumb({
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
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final canvas = context.canvas;

    // Outer shadow — 与单滑块一致
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: 10)),
      park.colors.textPrimary.withValues(alpha: 0.1),
      4.0,
      false,
    );

    // White circle background
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = park.colors.surface
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

/// 隐藏的范围滑块 value indicator shape。
class _HiddenRangeValueIndicatorShape extends RangeSliderValueIndicatorShape {
  const _HiddenRangeValueIndicatorShape();

  @override
  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete, {
    required TextPainter labelPainter,
    required double textScaleFactor,
  }) {
    return Size.zero;
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isOnTop = false,
    required TextPainter labelPainter,
    double textScaleFactor = 1.0,
    Size sizeWithOverflow = Size.zero,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    TextDirection textDirection = TextDirection.ltr,
    Thumb thumb = Thumb.start,
    double value = 0,
  }) {
    // no-op: hide indicator
  }
}
