import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Progress bar type.
enum ParkProgressType { line, dashboard }

/// Progress status controlling color and end-of-bar status icon.
enum ParkProgressStatus { normal, success, error, active }

/// A progress indicator component supporting linear and dashboard (circular ring)
/// styles, with optional step segmentation.
///
/// Accepts a [value] from 0.0 to 1.0, optional label, and brand-colored fill.
class ParkProgress extends StatelessWidget {
  /// Progress value between 0.0 and 1.0.
  final double value;

  /// Linear bar or dashboard ring.
  final ParkProgressType type;

  /// Fill color. Defaults to brand color.
  final Color? color;

  /// Track (background) color. Defaults to disabled background.
  final Color? trackColor;

  /// Thickness of the bar or ring stroke.
  final double strokeWidth;

  /// Label control:
  /// - `null` → no label
  /// - `true` → shows percentage
  /// - `String` → custom label text
  final Object? label;

  /// Diameter of the dashboard ring variant.
  final double size;

  /// When non-null, renders the progress as N discrete step blocks (antd
  /// Progress `steps` style). Each completed step uses `park.colors.brand`;
  /// incomplete steps use `park.colors.divider`.
  final int? steps;

  /// Width of each step block when [steps] is set.
  final double stepWidth;

  /// Progress status controlling color and end-of-bar icon.
  final ParkProgressStatus status;

  /// Custom text format callback. Receives the raw 0.0–1.0 progress value and
  /// returns a display string. Default produces `'${(percent * 100).toInt()}%'`.
  final String Function(double percent)? formatLabel;

  /// Background track color (alias for [trackColor], takes priority when both set).
  final Color? trailColor;

  /// Gradient fill for the progress bar (line variant only). Overrides [color] when set.
  final Gradient? gradient;

  /// Configurable line cap for the progress stroke.
  final StrokeCap strokeLinecap;

  /// When true, shows a shimmer/striped animation on the filled portion.
  final bool active;

  /// Creates a ParkProgress.
  const ParkProgress({
    super.key,
    this.value = 0.0,
    this.type = ParkProgressType.line,
    this.color,
    this.trackColor,
    this.strokeWidth = 6,
    this.label,
    this.size = 80,
    this.steps,
    this.stepWidth = 8,
    this.status = ParkProgressStatus.normal,
    this.formatLabel,
    this.trailColor,
    this.gradient,
    this.strokeLinecap = StrokeCap.round,
    this.active = false,
  });

  double get _clampedValue => value.clamp(0.0, 1.0);

  String _resolveLabel() {
    if (label == null) return '';
    if (formatLabel != null) return formatLabel!(_clampedValue);
    if (label is bool && label == true) {
      return '${(_clampedValue * 100).round()}%';
    }
    if (label is String) return label as String;
    return '';
  }

  Color _resolveStatusColor(ParkThemeData park) {
    switch (status) {
      case ParkProgressStatus.normal:
        return color ?? park.colors.brand;
      case ParkProgressStatus.success:
        return park.colors.success;
      case ParkProgressStatus.error:
        return park.colors.error;
      case ParkProgressStatus.active:
        return color ?? park.colors.brand;
    }
  }

  IconData? _resolveStatusIcon() {
    if (status == ParkProgressStatus.normal || status == ParkProgressStatus.active) {
      return null;
    }
    if (_clampedValue >= 1.0) {
      if (status == ParkProgressStatus.success) return Icons.check_circle;
      if (status == ParkProgressStatus.error) return Icons.error;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final fillColor = _resolveStatusColor(park);
    final bg = trailColor ?? trackColor ?? park.colors.disabledBg;
    final showLabel = label != null && label != false;
    final labelText = _resolveLabel();
    final statusIcon = _resolveStatusIcon();

    final progressPercent = (_clampedValue * 100).round();
    final semanticLabel = 'Progress: $progressPercent%';

    Widget result;
    if (steps != null) {
      result = _buildSteps(park, fillColor, bg);
    } else if (type == ParkProgressType.dashboard) {
      result = _buildDashboard(park, fillColor, bg, showLabel, labelText);
    } else {
      result = _buildLine(park, fillColor, bg, showLabel, labelText, statusIcon);
    }

    return Semantics(
      label: type == ParkProgressType.dashboard ? '$progressPercent%' : semanticLabel,
      value: steps != null ? progressPercent.toString() : null,
      child: result,
    );
  }

  Widget _buildLine(
    ParkThemeData park,
    Color fillColor,
    Color bg,
    bool showLabel,
    String labelText,
    IconData? statusIcon,
  ) {
    final bar = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _clampedValue),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(strokeWidth / 2),
          child: SizedBox(
            height: strokeWidth,
            child: Stack(
              children: [
                // Track
                Container(color: bg),
                // Fill
                FractionallySizedBox(
                  widthFactor: animatedValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: gradient == null ? fillColor : null,
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(strokeWidth / 2),
                    ),
                    // Active shimmer/striped overlay
                    child: active
                        ? _ActiveStripeOverlay(
                            color: fillColor,
                            strokeWidth: strokeWidth,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!showLabel && statusIcon == null) return bar;

    return Row(
      children: [
        Expanded(child: bar),
        SizedBox(width: park.spacing.sm),
        if (statusIcon != null) ...[
          Icon(
            statusIcon,
            size: 16,
            color: fillColor,
          ),
          if (showLabel) SizedBox(width: park.spacing.xs),
        ],
        if (showLabel)
          SizedBox(
            width: 40,
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: park.typography.sizeBodySmall,
                color: park.colors.textSecondary,
                fontWeight: park.typography.weightMedium,
              ),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }

  Widget _buildDashboard(
    ParkThemeData park,
    Color fillColor,
    Color bg,
    bool showLabel,
    String labelText,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _clampedValue),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, animatedValue, _) {
          return CustomPaint(
            size: Size(size, size),
            painter: _CircleProgressPainter(
              value: animatedValue,
              fillColor: fillColor,
              trackColor: bg,
              strokeWidth: strokeWidth,
              strokeLinecap: strokeLinecap,
            ),
            child: showLabel
                ? Center(
                    child: Text(
                      labelText,
                      style: TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: park.typography.weightBold,
                        color: park.colors.textPrimary,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildSteps(
    ParkThemeData park,
    Color fillColor,
    Color bg,
  ) {
    final totalSteps = (steps ?? 5).clamp(1, 20);
    final filledSteps = (_clampedValue * totalSteps).round().clamp(0, totalSteps);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Gap between steps
          return SizedBox(width: stepWidth * 0.5);
        }
        final stepIndex = index ~/ 2;
        final isFilled = stepIndex < filledSteps;
        return Container(
          width: stepWidth,
          height: strokeWidth * 1.5,
          decoration: BoxDecoration(
            color: isFilled ? park.colors.brand : park.colors.divider,
            borderRadius: BorderRadius.circular(strokeWidth * 0.3),
          ),
        );
      }),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  _CircleProgressPainter({
    required this.value,
    required this.fillColor,
    required this.trackColor,
    required this.strokeWidth,
    this.strokeLinecap = StrokeCap.round,
  });

  final double value;
  final Color fillColor;
  final Color trackColor;
  final double strokeWidth;
  final StrokeCap strokeLinecap;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeLinecap;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill arc
    if (value > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = strokeLinecap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * value,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeLinecap != strokeLinecap;
  }
}

/// Animated striped overlay for the active progress state.
class _ActiveStripeOverlay extends StatefulWidget {
  final Color color;
  final double strokeWidth;

  const _ActiveStripeOverlay({
    required this.color,
    required this.strokeWidth,
  });

  @override
  State<_ActiveStripeOverlay> createState() => _ActiveStripeOverlayState();
}

class _ActiveStripeOverlayState extends State<_ActiveStripeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _StripePainter(
            color: widget.color.withValues(alpha: 0.25),
            offset: _controller.value,
            stripeWidth: widget.strokeWidth * 1.5,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({
    required this.color,
    required this.offset,
    required this.stripeWidth,
  });

  final Color color;
  final double offset;
  final double stripeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // 边界防御：stripeWidth<=0 时 step<=0，x+=step 永不前进 → paint 死循环卡死 UI。
    final double effectiveStripeWidth = stripeWidth > 0 ? stripeWidth : 8.0;
    final step = effectiveStripeWidth * 2;
    final shift = offset * step;

    for (double x = -size.height + shift - step; x < size.width + step; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + effectiveStripeWidth, 0)
        ..lineTo(x + effectiveStripeWidth, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.color != color;
  }
}
