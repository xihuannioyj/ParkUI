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
    this.showArrow = true,
    this.arrowPadding,
    this.open,
    this.onOpenChange,
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
  final bool showArrow;

  /// Arrow offset relative to its default centered position.
  ///
  /// When non-null, the arrow is shifted by this amount:
  /// - For [ParkTooltipPlacement.top]/[ParkTooltipPlacement.bottom]:
  ///   [EdgeInsets.left]/[EdgeInsets.right] moves the arrow horizontally.
  /// - For [ParkTooltipPlacement.left]/[ParkTooltipPlacement.right]:
  ///   [EdgeInsets.top]/[EdgeInsets.bottom] moves the arrow vertically.
  /// - [EdgeInsets] values for the opposite axis are ignored.
  final EdgeInsets? arrowPadding;

  /// Controlled open state.
  ///
  /// * `true` — forces the tooltip to show.
  /// * `false` — forces the tooltip to hide.
  /// * `null` (default) — uses default hover/tap behavior.
  ///
  /// When non-null, pointer events (hover/tap) are ignored in favor of
  /// this value, making the tooltip fully controlled by the parent.
  final bool? open;

  /// Called when the tooltip wants to change visibility.
  ///
  /// The parent widget can use this to control [open].
  final ValueChanged<bool>? onOpenChange;

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
  final GlobalKey _triggerKey = GlobalKey();
  final GlobalKey _bubbleKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  Timer? _hideTimer;
  Timer? _autoHideTimer;
  bool _internalVisible = false;
  Size _bubbleSize = Size.zero;
  bool _bubbleMeasured = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  /// Whether the tooltip should currently be shown.
  bool get _isVisible => widget.open ?? _internalVisible;

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

    // If controlled open is true from the start, show immediately.
    if (widget.open == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    }
  }

  @override
  void didUpdateWidget(covariant ParkTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != null && widget.open != oldWidget.open) {
      if (widget.open!) {
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

    if (widget.open == null) {
      setState(() => _internalVisible = true);
    }
    widget.onOpenChange?.call(true);

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
      if (widget.open == null) {
        setState(() => _internalVisible = false);
      }
      widget.onOpenChange?.call(false);
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
    _bubbleMeasured = false;
    _bubbleSize = Size.zero;
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    // First frame renders the bubble invisibly so its size can be measured.
    // The bubble key is attached in the FIRST frame so the callback can
    // read its size immediately after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry == null) return;
      final box = _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _bubbleSize = box.size;
      }
      _bubbleMeasured = true;
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _removeOverlay() {
    final entry = _overlayEntry;
    _overlayEntry = null;
    if (entry != null && entry.mounted) entry.remove();
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

    // Resolve the trigger geometry first: both the placement that actually
    // fits on screen and the arrow offset depend on it.
    final RenderBox? triggerRenderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final Size screenSize = MediaQuery.of(context).size;
    final Offset triggerPosition =
        triggerRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size triggerSize = triggerRenderBox?.size ?? Size.zero;
    final double g = widget.gap;
    final bool measured = _bubbleMeasured && _bubbleSize != Size.zero;

    // Flip to the opposite side when the preferred side has no room for the
    // bubble, so a tooltip anchored to a control near a screen edge (e.g. an
    // app-bar button) is not clamped on top of the control it describes.
    final ParkTooltipPlacement placement = triggerRenderBox == null || !measured
        ? widget.placement
        : _resolvePlacement(
            triggerPosition: triggerPosition,
            triggerSize: triggerSize,
            bubbleSize: _bubbleSize,
            screenSize: screenSize,
            gap: g,
          );
    final _TooltipLayout? layout = triggerRenderBox == null || !measured
        ? null
        : _resolveLayout(
            placement: placement,
            triggerPosition: triggerPosition,
            triggerSize: triggerSize,
            bubbleSize: _bubbleSize,
            screenSize: screenSize,
            gap: g,
          );

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

    // The bubble with maxWidth constraint.
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
    if (widget.showArrow) {
      bubble = _TooltipWithArrow(
        placement: placement,
        color: bgColor,
        arrowPadding: widget.arrowPadding,
        arrowOffset: layout?.arrowOffset ?? Offset.zero,
        child: bubble,
      );
    }

    // Animation wrapper.
    Widget animated = FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: _scaleAlignment(placement),
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

    if (triggerRenderBox == null) {
      // Fallback: render at center if trigger not found (e.g., in tests).
      return Center(
        child: Semantics(
          label: widget.message,
          container: true,
          liveRegion: true,
          child: animated,
        ),
      );
    }

    // First frame: render bubble invisibly at the trigger position to
    // measure its real size. The key must be attached HERE (first frame)
    // so the post-frame callback can read its size.
    if (layout == null) {
      return Positioned(
        left: triggerPosition.dx.clamp(0.0, screenSize.width),
        top: triggerPosition.dy.clamp(0.0, screenSize.height),
        child: Opacity(
          opacity: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: Semantics(
              label: widget.message,
              container: true,
              liveRegion: true,
              child: KeyedSubtree(key: _bubbleKey, child: animated),
            ),
          ),
        ),
      );
    }

    // Second frame: the bubble has been measured, so place it where
    // [_resolveLayout] decided (placement possibly flipped to stay on screen).
    return Positioned(
      left: layout.left,
      top: layout.top,
      child: Semantics(
        label: widget.message,
        container: true,
        liveRegion: true,
        child: animated,
      ),
    );
  }

  /// Returns the placement to actually use: [ParkTooltipPlacement] requested by
  /// the caller, flipped to the opposite side of the trigger when the requested
  /// side has no room for the bubble and the opposite side does fit.
  ///
  /// Without this, a tooltip with the default top placement anchored to an
  /// app-bar button is clamped against the top of the screen and ends up drawn
  /// over the button instead of next to it.
  ParkTooltipPlacement _resolvePlacement({
    required Offset triggerPosition,
    required Size triggerSize,
    required Size bubbleSize,
    required Size screenSize,
    required double gap,
  }) {
    final ParkTooltipPlacement preferred = widget.placement;

    final double spaceAbove = triggerPosition.dy - gap;
    final double spaceBelow =
        screenSize.height - (triggerPosition.dy + triggerSize.height) - gap;
    final double spaceLeft = triggerPosition.dx - gap;
    final double spaceRight =
        screenSize.width - (triggerPosition.dx + triggerSize.width) - gap;

    final bool fitsAbove = spaceAbove >= bubbleSize.height;
    final bool fitsBelow = spaceBelow >= bubbleSize.height;
    final bool fitsLeft = spaceLeft >= bubbleSize.width;
    final bool fitsRight = spaceRight >= bubbleSize.width;

    switch (preferred) {
      case ParkTooltipPlacement.top:
        return !fitsAbove && fitsBelow
            ? ParkTooltipPlacement.bottom
            : preferred;
      case ParkTooltipPlacement.topLeft:
        return !fitsAbove && fitsBelow
            ? ParkTooltipPlacement.bottomLeft
            : preferred;
      case ParkTooltipPlacement.topRight:
        return !fitsAbove && fitsBelow
            ? ParkTooltipPlacement.bottomRight
            : preferred;
      case ParkTooltipPlacement.bottom:
        return !fitsBelow && fitsAbove
            ? ParkTooltipPlacement.top
            : preferred;
      case ParkTooltipPlacement.bottomLeft:
        return !fitsBelow && fitsAbove
            ? ParkTooltipPlacement.topLeft
            : preferred;
      case ParkTooltipPlacement.bottomRight:
        return !fitsBelow && fitsAbove
            ? ParkTooltipPlacement.topRight
            : preferred;
      case ParkTooltipPlacement.left:
        return !fitsLeft && fitsRight
            ? ParkTooltipPlacement.right
            : preferred;
      case ParkTooltipPlacement.right:
        return !fitsRight && fitsLeft
            ? ParkTooltipPlacement.left
            : preferred;
    }
  }

  /// Computes the on-screen position of the bubble for [placement], clamped to
  /// the screen, plus the arrow offset needed to keep the arrow pointing at the
  /// trigger after clamping.
  _TooltipLayout _resolveLayout({
    required ParkTooltipPlacement placement,
    required Offset triggerPosition,
    required Size triggerSize,
    required Size bubbleSize,
    required Size screenSize,
    required double gap,
  }) {
    final double g = gap;
    double left;
    double top;

    switch (placement) {
      case ParkTooltipPlacement.top:
        left = triggerPosition.dx + triggerSize.width / 2 - bubbleSize.width / 2;
        top = triggerPosition.dy - bubbleSize.height - g;
        break;
      case ParkTooltipPlacement.topLeft:
        left = triggerPosition.dx;
        top = triggerPosition.dy - bubbleSize.height - g;
        break;
      case ParkTooltipPlacement.topRight:
        left = triggerPosition.dx + triggerSize.width - bubbleSize.width;
        top = triggerPosition.dy - bubbleSize.height - g;
        break;
      case ParkTooltipPlacement.bottom:
        left = triggerPosition.dx + triggerSize.width / 2 - bubbleSize.width / 2;
        top = triggerPosition.dy + triggerSize.height + g;
        break;
      case ParkTooltipPlacement.bottomLeft:
        left = triggerPosition.dx;
        top = triggerPosition.dy + triggerSize.height + g;
        break;
      case ParkTooltipPlacement.bottomRight:
        left = triggerPosition.dx + triggerSize.width - bubbleSize.width;
        top = triggerPosition.dy + triggerSize.height + g;
        break;
      case ParkTooltipPlacement.left:
        left = triggerPosition.dx - bubbleSize.width - g;
        top = triggerPosition.dy + triggerSize.height / 2 - bubbleSize.height / 2;
        break;
      case ParkTooltipPlacement.right:
        left = triggerPosition.dx + triggerSize.width + g;
        top = triggerPosition.dy + triggerSize.height / 2 - bubbleSize.height / 2;
        break;
    }

    // Clamp to screen bounds.
    left = left.clamp(
      0.0,
      (screenSize.width - bubbleSize.width).clamp(0.0, double.infinity),
    );
    top = top.clamp(
      0.0,
      (screenSize.height - bubbleSize.height).clamp(0.0, double.infinity),
    );

    return _TooltipLayout(
      left: left,
      top: top,
      arrowOffset: _resolveArrowOffset(
        placement: placement,
        triggerPosition: triggerPosition,
        triggerSize: triggerSize,
        bubbleSize: bubbleSize,
        left: left,
        top: top,
      ),
    );
  }

  /// Shifts the arrow along the bubble edge so it keeps pointing at the centre
  /// of the trigger once the bubble has been clamped into the screen.
  ///
  /// The shift is clamped so the triangle always stays inside the bubble.
  /// Corner placements ([ParkTooltipPlacement.topLeft] and friends) align a
  /// bubble edge with the trigger edge on purpose, so their arrow stays centred.
  Offset _resolveArrowOffset({
    required ParkTooltipPlacement placement,
    required Offset triggerPosition,
    required Size triggerSize,
    required Size bubbleSize,
    required double left,
    required double top,
  }) {
    const double edgeInset = 4.0;

    switch (placement) {
      case ParkTooltipPlacement.top:
      case ParkTooltipPlacement.bottom:
        final double maxShift =
            bubbleSize.width / 2 - edgeInset - _TooltipWithArrow._arrowSize;
        if (maxShift <= 0) return Offset.zero;
        final double triggerCenterX =
            triggerPosition.dx + triggerSize.width / 2;
        final double bubbleCenterX = left + bubbleSize.width / 2;
        return Offset(
          (triggerCenterX - bubbleCenterX).clamp(-maxShift, maxShift),
          0,
        );
      case ParkTooltipPlacement.left:
      case ParkTooltipPlacement.right:
        final double maxShift =
            bubbleSize.height / 2 - edgeInset - _TooltipWithArrow._arrowSize;
        if (maxShift <= 0) return Offset.zero;
        final double triggerCenterY =
            triggerPosition.dy + triggerSize.height / 2;
        final double bubbleCenterY = top + bubbleSize.height / 2;
        return Offset(
          0,
          (triggerCenterY - bubbleCenterY).clamp(-maxShift, maxShift),
        );
      case ParkTooltipPlacement.topLeft:
      case ParkTooltipPlacement.topRight:
      case ParkTooltipPlacement.bottomLeft:
      case ParkTooltipPlacement.bottomRight:
        return Offset.zero;
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
    Widget child = KeyedSubtree(
      key: _triggerKey,
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
// Resolved on-screen geometry
// ---------------------------------------------------------------------------

/// Where the tooltip bubble ended up on screen, plus the arrow shift needed to
/// keep the arrow pointing at the trigger.
class _TooltipLayout {
  const _TooltipLayout({
    required this.left,
    required this.top,
    required this.arrowOffset,
  });

  /// Bubble offset from the top-left of the screen.
  final double left;
  final double top;

  /// Offset applied to the arrow along the bubble edge, relative to the edge
  /// centre. [Offset.zero] means the arrow stays centred on that edge.
  final Offset arrowOffset;
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
    this.arrowPadding,
    this.arrowOffset = Offset.zero,
  });

  final ParkTooltipPlacement placement;
  final Color color;
  final Widget child;
  final EdgeInsets? arrowPadding;

  /// Extra shift of the arrow along the bubble edge, so it can keep pointing
  /// at the trigger after the bubble was clamped into the screen.
  final Offset arrowOffset;

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
          arrowPadding: arrowPadding,
          arrowOffset: arrowOffset,
        ),
        child: Padding(
          padding: _effectivePadding(arrowEdge),
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

  EdgeInsets _effectivePadding(_ArrowEdge edge) {
    final base = _basePadding(edge);
    if (arrowPadding == null) return base;

    // Apply only the relevant axis from arrowPadding.
    switch (edge) {
      case _ArrowEdge.top:
        return EdgeInsets.only(
          top: base.top,
          left: arrowPadding!.left,
          right: arrowPadding!.right,
        );
      case _ArrowEdge.bottom:
        return EdgeInsets.only(
          bottom: base.bottom,
          left: arrowPadding!.left,
          right: arrowPadding!.right,
        );
      case _ArrowEdge.left:
        return EdgeInsets.only(
          left: base.left,
          top: arrowPadding!.top,
          bottom: arrowPadding!.bottom,
        );
      case _ArrowEdge.right:
        return EdgeInsets.only(
          right: base.right,
          top: arrowPadding!.top,
          bottom: arrowPadding!.bottom,
        );
    }
  }

  EdgeInsets _basePadding(_ArrowEdge edge) {
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
    this.arrowPadding,
    this.arrowOffset = Offset.zero,
  });

  final Color color;
  final _ArrowEdge edge;
  final double arrowSize;
  final EdgeInsets? arrowPadding;

  /// Extra shift along the bubble edge, used to keep the arrow pointing at the
  /// trigger when the bubble was clamped into the screen.
  final Offset arrowOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Arrow center offset from arrowPadding and the resolved arrow shift.
    final dx =
        arrowOffset.dx + (arrowPadding?.left ?? 0) - (arrowPadding?.right ?? 0);
    final dy =
        arrowOffset.dy + (arrowPadding?.top ?? 0) - (arrowPadding?.bottom ?? 0);

    switch (edge) {
      case _ArrowEdge.bottom:
        // Triangle pointing down, centered horizontally + dx offset.
        path
          ..moveTo(size.width / 2 - arrowSize + dx, size.height - arrowSize)
          ..lineTo(size.width / 2 + dx, size.height)
          ..lineTo(size.width / 2 + arrowSize + dx, size.height - arrowSize)
          ..close();
        break;
      case _ArrowEdge.top:
        // Triangle pointing up, centered horizontally + dx offset.
        path
          ..moveTo(size.width / 2 - arrowSize + dx, arrowSize)
          ..lineTo(size.width / 2 + dx, 0)
          ..lineTo(size.width / 2 + arrowSize + dx, arrowSize)
          ..close();
        break;
      case _ArrowEdge.left:
        // Triangle pointing left, centered vertically + dy offset.
        path
          ..moveTo(arrowSize, size.height / 2 - arrowSize + dy)
          ..lineTo(0, size.height / 2 + dy)
          ..lineTo(arrowSize, size.height / 2 + arrowSize + dy)
          ..close();
        break;
      case _ArrowEdge.right:
        // Triangle pointing right, centered vertically + dy offset.
        path
          ..moveTo(size.width - arrowSize, size.height / 2 - arrowSize + dy)
          ..lineTo(size.width, size.height / 2 + dy)
          ..lineTo(size.width - arrowSize, size.height / 2 + arrowSize + dy)
          ..close();
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.edge != edge ||
      oldDelegate.arrowPadding != arrowPadding ||
      oldDelegate.arrowOffset != arrowOffset;
}
