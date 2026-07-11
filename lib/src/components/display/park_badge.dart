import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Badge size presets.
enum ParkBadgeSize { small, medium }

/// Badge status — renders a colored status dot (no count).
enum ParkBadgeStatus { success, processing, defaultStatus, warning, error }

/// Ribbon placement on the child widget.
enum ParkRibbonPlacement { topRight, topLeft }

/// A numeric or dot badge positioned at the top-right of its [child].
///
/// Shows a red dot when [dot] is true, otherwise shows [count]
/// (capped at [maxCount] with a "+" suffix).
/// Supports status dots, offset positioning, ribbon banners, and tooltips.
/// When [child] is null, renders in standalone mode as a status dot with optional text.
class ParkBadge extends StatelessWidget {
  /// Creates a ParkBadge.
  const ParkBadge({
    super.key,
    this.count,
    this.dot = false,
    this.maxCount = 99,
    this.color,
    this.textColor,
    this.size = ParkBadgeSize.medium,
    this.child,
    this.status,
    this.offset,
    this.ribbon = false,
    this.ribbonText,
    this.ribbonPlacement = ParkRibbonPlacement.topRight,
    this.title,
    this.showZero = false,
    this.standaloneText,
    this.countWidget,
    this.overflowCount,
  });

  /// The number to display. Null hides the number (use with [dot]).
  final int? count;

  /// When true, shows a small dot instead of a number.
  final bool dot;

  /// Maximum count before showing "maxCount+".
  final int maxCount;

  /// Background color of the badge. Defaults to red.
  final Color? color;

  /// Text color inside the badge. Defaults to white.
  final Color? textColor;

  /// Size preset.
  final ParkBadgeSize size;

  /// The widget the badge is anchored to. Null for standalone mode.
  final Widget? child;

  /// Status mode — renders a colored status dot (no count).
  /// When set, [dot] and [count] are ignored.
  final ParkBadgeStatus? status;

  /// Adjusts badge position (dx, dy) from default top-right corner.
  final Offset? offset;

  /// When true, renders as a ribbon banner in the corner of the child.
  final bool ribbon;

  /// Text displayed on the ribbon banner.
  final String? ribbonText;

  /// Controls which corner the ribbon is placed in.
  final ParkRibbonPlacement ribbonPlacement;

  /// Tooltip text shown on hover.
  final String? title;

  /// When true, displays badge even when [count] is 0.
  final bool showZero;

  /// Text label shown next to the status dot in standalone mode (no child).
  final String? standaloneText;

  /// Custom widget to display instead of the count number.
  final Widget? countWidget;

  /// Overflow count threshold (alias for [maxCount]).
  /// When set, takes priority over [maxCount].
  final int? overflowCount;

  double get _dotSize => size == ParkBadgeSize.small ? 6 : 8;

  double get _fontSize => size == ParkBadgeSize.small ? 10 : 12;

  double get _minWidth => size == ParkBadgeSize.small ? 16 : 20;

  double get _height => size == ParkBadgeSize.small ? 16 : 20;

  double get _padding => size == ParkBadgeSize.small ? 4 : 6;

  Color _statusColor(ParkThemeData park) {
    switch (status) {
      case ParkBadgeStatus.success:
        return park.colors.success;
      case ParkBadgeStatus.processing:
        return park.colors.brand;
      case ParkBadgeStatus.defaultStatus:
        return park.colors.textSecondary;
      case ParkBadgeStatus.warning:
        return park.colors.warning;
      case ParkBadgeStatus.error:
        return park.colors.error;
      case null:
        return color ?? park.colors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // Ribbon mode
    if (ribbon && child != null) {
      return _buildRibbon(park);
    }

    // Status dot mode
    if (status != null) {
      if (child == null) {
        return _buildStandaloneStatusDot(park);
      }
      return _buildStatusDot(park);
    }

    // Standard badge mode
    final showDot = dot;
    final showCount = !dot && count != null && (count! > 0 || (count == 0 && showZero));

    if (!showDot && !showCount && countWidget == null) {
      return child ?? const SizedBox.shrink();
    }

    // Standalone mode: no child, just the indicator + optional text
    if (child == null) {
      return _buildStandaloneIndicator(park, showDot);
    }

    Widget indicator;
    if (countWidget != null) {
      indicator = countWidget!;
    } else if (showDot) {
      indicator = Container(
        width: _dotSize,
        height: _dotSize,
        decoration: BoxDecoration(
          color: color ?? park.colors.error,
          shape: BoxShape.circle,
          border: Border.all(
            color: park.colors.surface,
            width: 1.5,
          ),
        ),
      );
    } else {
      final label = count! > maxCount ? '$maxCount+' : '$count';
      indicator = Container(
        constraints: BoxConstraints(minWidth: _minWidth),
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: _padding),
        decoration: BoxDecoration(
          color: color ?? park.colors.error,
          borderRadius: BorderRadius.circular(_height / 2),
          border: Border.all(
            color: park.colors.surface,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: park.typography.weightBold,
            color: textColor ?? park.colors.textOnBrand,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final dx = offset?.dx ?? 0;
    final dy = offset?.dy ?? 0;

    Widget result = Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          top: -4 + dy,
          right: -4 + dx,
          child: indicator,
        ),
      ],
    );

    return _wrapTooltip(result);
  }

  /// Standalone mode: status dot with optional text label, no child.
  Widget _buildStandaloneStatusDot(ParkThemeData park) {
    final statusColor = _statusColor(park);
    final dotSize = _dotSize + 2;

    Widget dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: park.colors.surface,
          width: 1.5,
        ),
      ),
    );

    if (status == ParkBadgeStatus.processing) {
      dot = _ProcessingDot(
        color: statusColor,
        size: dotSize,
        borderColor: park.colors.surface,
      );
    }

    if (standaloneText != null) {
      return _wrapTooltip(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          SizedBox(width: park.spacing.xs),
          Text(
            standaloneText!,
            style: TextStyle(
              fontSize: park.typography.sizeBodySmall,
              color: park.colors.textPrimary,
            ),
          ),
        ],
      ));
    }

    return _wrapTooltip(dot);
  }

  /// Standalone mode: numeric or dot indicator with optional text, no child.
  Widget _buildStandaloneIndicator(ParkThemeData park, bool showDot) {
    Widget indicator;

    if (countWidget != null) {
      indicator = countWidget!;
    } else if (showDot) {
      indicator = Container(
        width: _dotSize,
        height: _dotSize,
        decoration: BoxDecoration(
          color: color ?? park.colors.error,
          shape: BoxShape.circle,
          border: Border.all(
            color: park.colors.surface,
            width: 1.5,
          ),
        ),
      );
    } else {
      final label = count != null
          ? (count! > maxCount ? '$maxCount+' : '$count')
          : '';
      indicator = Container(
        constraints: BoxConstraints(minWidth: _minWidth),
        height: _height,
        padding: EdgeInsets.symmetric(horizontal: _padding),
        decoration: BoxDecoration(
          color: color ?? park.colors.error,
          borderRadius: BorderRadius.circular(_height / 2),
          border: Border.all(
            color: park.colors.surface,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: park.typography.weightBold,
            color: textColor ?? park.colors.textOnBrand,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (standaloneText != null) {
      return _wrapTooltip(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(width: park.spacing.xs),
          Text(
            standaloneText!,
            style: TextStyle(
              fontSize: park.typography.sizeBodySmall,
              color: park.colors.textPrimary,
            ),
          ),
        ],
      ));
    }

    return _wrapTooltip(indicator);
  }

  Widget _buildStatusDot(ParkThemeData park) {
    final statusColor = _statusColor(park);
    final dotSize = _dotSize + 2; // slightly larger than regular dot

    Widget statusIndicator = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: park.colors.surface,
          width: 1.5,
        ),
      ),
    );

    // Add pulse animation for processing status
    if (status == ParkBadgeStatus.processing) {
      statusIndicator = _ProcessingDot(
        color: statusColor,
        size: dotSize,
        borderColor: park.colors.surface,
      );
    }

    final dx = offset?.dx ?? 0;
    final dy = offset?.dy ?? 0;

    Widget result = Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          top: -4 + dy,
          right: -4 + dx,
          child: statusIndicator,
        ),
      ],
    );

    return _wrapTooltip(result);
  }

  Widget _buildRibbon(ParkThemeData park) {
    final isRight = ribbonPlacement == ParkRibbonPlacement.topRight;

    final ribbonWidget = Container(
      width: 80,
      padding: EdgeInsets.symmetric(vertical: park.spacing.xs),
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        ribbonText ?? '',
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: park.typography.weightBold,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    Widget result = ClipRect(
      child: Stack(
        children: [
          child!,
          Positioned(
            top: 8,
            right: isRight ? -28 : null,
            left: isRight ? null : -28,
            child: Transform.rotate(
              angle: isRight ? 0.7854 : -0.7854, // pi/4 or -pi/4
              child: ribbonWidget,
            ),
          ),
        ],
      ),
    );

    return _wrapTooltip(result);
  }

  Widget _wrapTooltip(Widget widget) {
    if (title != null) {
      return Tooltip(
        message: title!,
        child: widget,
      );
    }
    return widget;
  }
}

/// Animated processing dot with a subtle pulse effect.
class _ProcessingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Color borderColor;

  const _ProcessingDot({
    required this.color,
    required this.size,
    required this.borderColor,
  });

  @override
  State<_ProcessingDot> createState() => _ProcessingDotState();
}

class _ProcessingDotState extends State<_ProcessingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.repeat();
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
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _opacityAnimation.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Solid dot
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.borderColor,
                  width: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
