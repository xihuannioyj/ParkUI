import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Tooltip placement relative to the trigger child.
enum ParkTooltipPlacement {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// How the tooltip is triggered.
enum ParkTooltipTrigger {
  /// Shown on mouse hover (desktop). Hides when cursor leaves.
  hover,

  /// Shown on tap (mobile). Toggles on each tap.
  tap,
}

/// A standalone, highly-customizable tooltip that uses [OverlayEntry] and
/// [LayerLink] for precise positioning.
///
/// Unlike Flutter's built-in [Tooltip], ParkTooltip supports 8 placement
/// positions, controlled visibility, arrow toggling, delay/duration, and
/// full color customization.
///
/// ```dart
/// ParkTooltip(
///   message: 'Delete this item',
///   placement: ParkTooltipPlacement.top,
///   child: Icon(Icons.delete),
/// )
/// ```
class ParkTooltip extends StatefulWidget {
  /// Creates a ParkTooltip.
  const ParkTooltip({
    super.key,
    required this.child,
    this.message,
    this.richMessage,
    this.placement = ParkTooltipPlacement.top,
    this.trigger = ParkTooltipTrigger.hover,
    this.arrow = true,
    this.visible,
    this.onVisibleChange,
    this.delay = const Duration(milliseconds: 100),
    this.duration,
    this.color,
    this.textColor,
    this.maxWidth = 250.0,
    this.padding,
    this.borderRadius,
    this.gap = 4.0,
    this.mouseEnterDelay = Duration.zero,
    this.mouseLeaveDelay = const Duration(milliseconds: 100),
    this.destroyTooltipOnHide = false,
  });

  /// The widget that triggers the tooltip.
  final Widget child;

  /// Simple text content. Mutually exclusive with [richMessage].
  final String? message;

  /// Rich widget content. Mutually exclusive with [message].
  /// When both are null, the tooltip will not appear.
  final Widget? richMessage;

  /// Where the tooltip appears relative to [child].
  final ParkTooltipPlacement placement;

  /// How the tooltip is shown/hidden.
  final ParkTooltipTrigger trigger;

  /// Whether to render the small triangle arrow pointing at the child.
  final bool arrow;

  /// Controlled visibility. When non-null, the tooltip ignores pointer
  /// events and uses this value exclusively.
  final bool? visible;

  /// Called when the tooltip wants to change visibility.
  /// The parent widget can use this to control [visible].
  final ValueChanged<bool>? onVisibleChange;

  /// Delay before the tooltip appears (hover trigger only).
  final Duration delay;

  /// Auto-hide after this duration. Null means no auto-hide.
  final Duration? duration;

  /// Tooltip background color. Defaults to dark (`0xE6000000`).
  final Color? color;

  /// Tooltip text color. Defaults to white.
  final Color? textColor;

  /// Maximum width of the tooltip bubble.
  final double maxWidth;

  /// Inner padding of the tooltip bubble.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the tooltip bubble.
  final BorderRadius? borderRadius;

  /// Gap between the child edge and the tooltip bubble.
  final double gap;

  /// Delay before the tooltip appears on mouse enter (hover trigger).
  final Duration mouseEnterDelay;

  /// Delay before the tooltip hides on mouse leave (hover trigger).
  final Duration mouseLeaveDelay;

  /// Whether to destroy the tooltip overlay when hidden (saves memory).
  final bool destroyTooltipOnHide;

  @override
  State<ParkTooltip> createState() => _ParkTooltipState();
}

class _ParkTooltipState extends State<ParkTooltip>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _autoHideTimer;
  bool _internalVisible = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  /// Whether the tooltip should currently be shown.
  bool get _isVisible => widget.visible ?? _internalVisible;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    // If controlled visible is true from the start, show immediately.
    if (widget.visible == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(covariant ParkTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != null && widget.visible != oldWidget.visible) {
      if (widget.visible!) {
        _show();
      } else {
        _hide();
      }
    }
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _autoHideTimer?.cancel();
    _removeOverlay();
    _animController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Show / Hide logic
  // -----------------------------------------------------------------------

  void _requestShow() {
    _hideTimer?.cancel();
    _showTimer?.cancel();
    _showTimer = Timer(widget.delay, _show);
  }

  void _requestHide() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    // Small delay to allow re-entry (e.g. cursor moving from child to tooltip).
    _hideTimer = Timer(const Duration(milliseconds: 80), _hide);
  }

  void _show() {
    if (_isVisible && _overlayEntry != null) return;
    if (widget.message == null && widget.richMessage == null) return;

    if (widget.visible == null) {
      setState(() => _internalVisible = true);
    }
    widget.onVisibleChange?.call(true);

    _ensureOverlay();
    _animController.forward();

    _autoHideTimer?.cancel();
    if (widget.duration != null) {
      _autoHideTimer = Timer(widget.duration!, _hide);
    }
  }

  void _hide() {
    _autoHideTimer?.cancel();
    _animController.reverse().then((_) {
      if (!mounted) return;
      if (widget.visible == null) {
        setState(() => _internalVisible = false);
      }
      widget.onVisibleChange?.call(false);
      _removeOverlay();
    });
  }

  void _toggleVisibility() {
    if (_isVisible) {
      _hide();
    } else {
      _show();
    }
  }

  // -----------------------------------------------------------------------
  // Overlay management
  // -----------------------------------------------------------------------

  void _ensureOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // -----------------------------------------------------------------------
  // Overlay content
  // -----------------------------------------------------------------------

  Widget _buildOverlay(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final bgColor = widget.color ?? park.colors.overlay;
    final fgColor = widget.textColor ?? Colors.white;
    final effectivePadding =
        widget.padding ?? EdgeInsets.symmetric(
          horizontal: park.spacing.md,
          vertical: park.spacing.sm,
        );
    final effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(park.radius.sm);

    // Build the tooltip content widget.
    Widget tooltipContent;
    if (widget.richMessage != null) {
      tooltipContent = widget.richMessage!;
    } else {
      tooltipContent = Text(
        widget.message!,
        style: TextStyle(
          fontSize: park.typography.sizeCaption,
          color: fgColor,
          decoration: TextDecoration.none,
          fontWeight: park.typography.weightRegular,
        ),
      );
    }

    // The bubble.
    Widget bubble = Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveRadius,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: park.typography.sizeCaption,
          color: fgColor,
          decoration: TextDecoration.none,
        ),
        child: tooltipContent,
      ),
    );

    // Wrap with arrow if enabled.
    if (widget.arrow) {
      bubble = _TooltipWithArrow(
        placement: widget.placement,
        color: bgColor,
        child: bubble,
      );
    }

    // Animation wrapper.
    Widget animated = FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: _scaleAlignment(widget.placement),
        child: bubble,
      ),
    );

    // Allow hover on the tooltip itself (for hover trigger) to keep it visible.
    if (widget.trigger == ParkTooltipTrigger.hover) {
      animated = MouseRegion(
        onEnter: (_) {
          _hideTimer?.cancel();
          _autoHideTimer?.cancel();
        },
        onExit: (_) => _requestHide(),
        child: animated,
      );
    }

    // Position with CompositedTransformFollower.
    final followerOffset = _followerOffset(widget.placement);
    final followerAnchor = _followerAnchor(widget.placement);
    final targetAnchor = _targetAnchor(widget.placement);

    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: followerOffset,
      targetAnchor: targetAnchor,
      followerAnchor: followerAnchor,
      child: animated,
    );
  }

  // -----------------------------------------------------------------------
  // Placement geometry helpers
  // -----------------------------------------------------------------------

  /// Offset applied to the follower based on placement + gap.
  Offset _followerOffset(ParkTooltipPlacement p) {
    final g = widget.gap;
    switch (p) {
      case ParkTooltipPlacement.top:
        return Offset(0, -g);
      case ParkTooltipPlacement.topLeft:
        return Offset(0, -g);
      case ParkTooltipPlacement.topRight:
        return Offset(0, -g);
      case ParkTooltipPlacement.bottom:
        return Offset(0, g);
      case ParkTooltipPlacement.bottomLeft:
        return Offset(0, g);
      case ParkTooltipPlacement.bottomRight:
        return Offset(0, g);
      case ParkTooltipPlacement.left:
        return Offset(-g, 0);
      case ParkTooltipPlacement.right:
        return Offset(g, 0);
    }
  }

  Alignment _followerAnchor(ParkTooltipPlacement p) {
    switch (p) {
      case ParkTooltipPlacement.top:
        return Alignment.bottomCenter;
      case ParkTooltipPlacement.topLeft:
        return Alignment.bottomLeft;
      case ParkTooltipPlacement.topRight:
        return Alignment.bottomRight;
      case ParkTooltipPlacement.bottom:
        return Alignment.topCenter;
      case ParkTooltipPlacement.bottomLeft:
        return Alignment.topLeft;
      case ParkTooltipPlacement.bottomRight:
        return Alignment.topRight;
      case ParkTooltipPlacement.left:
        return Alignment.centerRight;
      case ParkTooltipPlacement.right:
        return Alignment.centerLeft;
    }
  }

  Alignment _targetAnchor(ParkTooltipPlacement p) {
    switch (p) {
      case ParkTooltipPlacement.top:
        return Alignment.topCenter;
      case ParkTooltipPlacement.topLeft:
        return Alignment.topLeft;
      case ParkTooltipPlacement.topRight:
        return Alignment.topRight;
      case ParkTooltipPlacement.bottom:
        return Alignment.bottomCenter;
      case ParkTooltipPlacement.bottomLeft:
        return Alignment.bottomLeft;
      case ParkTooltipPlacement.bottomRight:
        return Alignment.bottomRight;
      case ParkTooltipPlacement.left:
        return Alignment.centerLeft;
      case ParkTooltipPlacement.right:
        return Alignment.centerRight;
    }
  }

  Alignment _scaleAlignment(ParkTooltipPlacement p) {
    switch (p) {
      case ParkTooltipPlacement.top:
      case ParkTooltipPlacement.topLeft:
      case ParkTooltipPlacement.topRight:
        return Alignment.bottomCenter;
      case ParkTooltipPlacement.bottom:
      case ParkTooltipPlacement.bottomLeft:
      case ParkTooltipPlacement.bottomRight:
        return Alignment.topCenter;
      case ParkTooltipPlacement.left:
        return Alignment.centerRight;
      case ParkTooltipPlacement.right:
        return Alignment.centerLeft;
    }
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Widget child = CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );

    if (widget.trigger == ParkTooltipTrigger.hover) {
      // Use MouseRegion for desktop hover.
      child = MouseRegion(
        onEnter: (_) => _requestShow(),
        onExit: (_) => _requestHide(),
        child: child,
      );
    } else {
      // Tap trigger.
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleVisibility,
        child: child,
      );
    }

    return child;
  }
}

// ---------------------------------------------------------------------------
// Arrow wrapper
// ---------------------------------------------------------------------------

/// Wraps the tooltip bubble with a small triangle arrow that points toward
/// the trigger child. The arrow direction is derived from the placement.
class _TooltipWithArrow extends StatelessWidget {
  const _TooltipWithArrow({
    required this.placement,
    required this.color,
    required this.child,
  });

  final ParkTooltipPlacement placement;
  final Color color;
  final Widget child;

  static const double _arrowSize = 6.0;

  @override
  Widget build(BuildContext context) {
    final arrowEdge = _arrowEdge(placement);

    return ClipRect(
      child: CustomPaint(
        painter: _ArrowPainter(
          color: color,
          edge: arrowEdge,
          arrowSize: _arrowSize,
        ),
        child: Padding(
          padding: _arrowPadding(arrowEdge),
          child: child,
        ),
      ),
    );
  }

  /// Which edge of the tooltip the arrow is on.
  static _ArrowEdge _arrowEdge(ParkTooltipPlacement p) {
    switch (p) {
      case ParkTooltipPlacement.top:
      case ParkTooltipPlacement.topLeft:
      case ParkTooltipPlacement.topRight:
        return _ArrowEdge.bottom;
      case ParkTooltipPlacement.bottom:
      case ParkTooltipPlacement.bottomLeft:
      case ParkTooltipPlacement.bottomRight:
        return _ArrowEdge.top;
      case ParkTooltipPlacement.left:
        return _ArrowEdge.right;
      case ParkTooltipPlacement.right:
        return _ArrowEdge.left;
    }
  }

  EdgeInsets _arrowPadding(_ArrowEdge edge) {
    switch (edge) {
      case _ArrowEdge.top:
        return const EdgeInsets.only(top: _arrowSize);
      case _ArrowEdge.bottom:
        return const EdgeInsets.only(bottom: _arrowSize);
      case _ArrowEdge.left:
        return const EdgeInsets.only(left: _arrowSize);
      case _ArrowEdge.right:
        return const EdgeInsets.only(right: _arrowSize);
    }
  }
}

enum _ArrowEdge { top, bottom, left, right }

/// Paints a small triangle on the specified edge of the tooltip bubble.
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.color,
    required this.edge,
    required this.arrowSize,
  });

  final Color color;
  final _ArrowEdge edge;
  final double arrowSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (edge) {
      case _ArrowEdge.bottom:
        // Triangle pointing down, centered horizontally.
        path
          ..moveTo(size.width / 2 - arrowSize, size.height - arrowSize)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(size.width / 2 + arrowSize, size.height - arrowSize)
          ..close();
        break;
      case _ArrowEdge.top:
        // Triangle pointing up, centered horizontally.
        path
          ..moveTo(size.width / 2 - arrowSize, arrowSize)
          ..lineTo(size.width / 2, 0)
          ..lineTo(size.width / 2 + arrowSize, arrowSize)
          ..close();
        break;
      case _ArrowEdge.left:
        // Triangle pointing left, centered vertically.
        path
          ..moveTo(arrowSize, size.height / 2 - arrowSize)
          ..lineTo(0, size.height / 2)
          ..lineTo(arrowSize, size.height / 2 + arrowSize)
          ..close();
        break;
      case _ArrowEdge.right:
        // Triangle pointing right, centered vertically.
        path
          ..moveTo(size.width - arrowSize, size.height / 2 - arrowSize)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width - arrowSize, size.height / 2 + arrowSize)
          ..close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.edge != edge;
}
