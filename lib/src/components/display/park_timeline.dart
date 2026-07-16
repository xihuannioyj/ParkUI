import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// Timeline content positioning mode.
enum ParkTimelineMode {
  /// All content on the left side of the line.
  left,

  /// All content on the right side of the line.
  right,

  /// Content alternates sides (left/right/left...).
  /// On wide screens (>= 600px), content is truly alternated.
  /// On narrow screens, falls back to [right] mode.
  alternate,
}

/// Timeline label placement.
enum ParkTimelineLabelPlacement {
  /// Label is placed beside the dot on the same side.
  sameSide,

  /// Label is placed opposite to the content.
  opposite,
}

/// Data model for a single timeline entry.
///
/// Each item renders a dot on the vertical line and a content card beside it.
@immutable
class ParkTimelineItem {
  /// Creates a timeline item.
  const ParkTimelineItem({
    required this.title,
    this.description,
    this.time,
    this.icon,
    this.color,
    this.dotWidget,
  });

  /// Primary text displayed for this entry.
  final String title;

  /// Optional secondary text below the title.
  final String? description;

  /// Optional timestamp label (rendered in caption style).
  final String? time;

  /// Optional icon rendered inside the dot indicator.
  /// When provided, the dot becomes a filled circle containing this icon.
  final IconData? icon;

  /// Custom color for this item's dot indicator.
  /// Defaults to [ParkColors.brand] when null.
  final Color? color;

  /// Fully custom widget replacing the default dot indicator.
  /// When provided, [icon] and [color] are ignored.
  final Widget? dotWidget;
}

/// A vertical timeline that connects a sequence of events with a line and
/// dot indicators.
///
/// Supports left/right/alternate content positioning, sequential fade-in
/// animation, a pending (loading) indicator at the end, reverse ordering,
/// and custom dot widgets per item.
///
/// ```dart
/// ParkTimeline(
///   items: [
///     ParkTimelineItem(title: 'Order placed', time: '10:00'),
///     ParkTimelineItem(title: 'Shipped', time: '14:30', color: Colors.green),
///   ],
///   mode: ParkTimelineMode.alternate,
///   pending: true,
/// )
/// ```
class ParkTimeline extends StatefulWidget {
  /// Creates a ParkTimeline.
  const ParkTimeline({
    super.key,
    required this.items,
    this.mode = ParkTimelineMode.left,
    this.pending = false,
    this.pendingLabel,
    this.reverse = false,
    this.dotSize = 12.0,
    this.lineWidth = 2.0,
    this.itemSpacing = 24.0,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationDelay = const Duration(milliseconds: 80),
    this.labelPlacement = ParkTimelineLabelPlacement.sameSide,
    this.pendingDot,
  });

  /// The timeline entries to display.
  final List<ParkTimelineItem> items;

  /// How content is positioned relative to the vertical line.
  final ParkTimelineMode mode;

  /// When true, shows a loading indicator at the last item's position.
  final bool pending;

  /// Text shown next to the pending indicator when [pending] is true.
  /// When null, uses [ParkLocalizations.loading].
  final String? pendingLabel;

  /// When true, the first item in [items] is rendered at the bottom.
  final bool reverse;

  /// Diameter of the default dot indicator in logical pixels.
  final double dotSize;

  /// Width of the vertical connecting line.
  final double lineWidth;

  /// Vertical gap between consecutive items.
  final double itemSpacing;

  /// Duration of each item's fade-in animation.
  final Duration animationDuration;

  /// Delay between successive item animations.
  final Duration animationDelay;

  /// Controls where the time label is placed relative to the dot.
  final ParkTimelineLabelPlacement labelPlacement;

  /// Custom widget for the pending (loading) dot indicator.
  final Widget? pendingDot;

  @override
  State<ParkTimeline> createState() => _ParkTimelineState();
}

class _ParkTimelineState extends State<ParkTimeline>
    with SingleTickerProviderStateMixin {
  /// Single controller driving the staggered reveal animation.
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(vsync: this);
    _revealController.addListener(_onRevealTick);
    _startRevealAnimation();
  }

  @override
  void didUpdateWidget(covariant ParkTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-run animation when the item list changes.
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.reverse != widget.reverse) {
      _startRevealAnimation();
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _startRevealAnimation() {
    final totalItems = widget.items.length + (widget.pending ? 1 : 0);
    if (totalItems <= 0) return;

    // Total duration = delay between items * (count - 1) + each item's fade duration.
    final totalDuration = widget.animationDuration +
        widget.animationDelay * (totalItems - 1);
    _revealController.duration = totalDuration;
    _revealController.reset();
    _revealController.forward();
  }

  void _onRevealTick() {
    if (mounted) setState(() {});
  }

  /// Whether the item at [index] should be visible given the current
  /// animation progress.
  bool _isRevealed(int index) {
    final totalItems = widget.items.length + (widget.pending ? 1 : 0);
    if (totalItems <= 0) return false;
    final totalDuration = widget.animationDuration +
        widget.animationDelay * (totalItems - 1);
    if (totalDuration.inMilliseconds == 0) return true;

    // Each item starts its fade-in at (index * animationDelay) into the timeline.
    final itemStartMs = (widget.animationDelay * index).inMilliseconds;
    final fraction = itemStartMs / totalDuration.inMilliseconds;
    return _revealController.value >= fraction;
  }

  /// Returns the effective mode for the given viewport width.
  ParkTimelineMode _effectiveMode(double width) {
    if (widget.mode == ParkTimelineMode.alternate) {
      // Fall back to right-aligned on narrow viewports.
      return width >= 600 ? ParkTimelineMode.alternate : ParkTimelineMode.right;
    }
    return widget.mode;
  }

  /// Whether the content for item at [index] should be placed on the left
  /// side of the line.
  bool _isLeftSide(int index, ParkTimelineMode mode) {
    switch (mode) {
      case ParkTimelineMode.left:
        return true;
      case ParkTimelineMode.right:
        return false;
      case ParkTimelineMode.alternate:
        return index.isEven;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // Build the ordered item list (apply reverse).
    final orderedItems =
        widget.reverse ? widget.items.reversed.toList() : widget.items;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mode = _effectiveMode(constraints.maxWidth);
        final isAlternate = mode == ParkTimelineMode.alternate;
        final isLeftOnly = mode == ParkTimelineMode.left;

        return Semantics(
          label: 'Timeline',
          child: Column(
            crossAxisAlignment: isLeftOnly
                ? CrossAxisAlignment.end
                : isAlternate
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < orderedItems.length; i++) ...[
                if (i > 0) SizedBox(height: widget.itemSpacing),
                _buildItem(
                  context,
                  park,
                  orderedItems[i],
                  i,
                  orderedItems.length,
                  mode,
                ),
              ],
              if (widget.pending) ...[
                if (orderedItems.isNotEmpty)
                  SizedBox(height: widget.itemSpacing),
                _buildPendingItem(
                  context,
                  park,
                  orderedItems.length,
                  mode,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Builds a single timeline entry (dot + content card).
  Widget _buildItem(
    BuildContext context,
    ParkThemeData park,
    ParkTimelineItem item,
    int index,
    int totalCount,
    ParkTimelineMode mode,
  ) {
    final isLeft = _isLeftSide(index, mode);
    final isAlternate = mode == ParkTimelineMode.alternate;
    final isRevealed = _isRevealed(index);
    final dotColor = item.color ?? park.colors.brand;

    final dot = _buildDot(park, item, dotColor);

    final content = _buildContent(park, item);

    // Build the line segments above and below the dot.
    final isFirst = index == 0;
    final isLast = index == totalCount - 1 && !widget.pending;

    return _AnimatedReveal(
      visible: isRevealed,
      duration: widget.animationDuration,
      child: _TimelineRow(
        dotSize: widget.dotSize,
        lineWidth: widget.lineWidth,
        lineColor: park.colors.border,
        dot: dot,
        content: content,
        isLeft: isLeft,
        isAlternate: isAlternate,
        showLineAbove: !isFirst,
        showLineBelow: !isLast,
        lineAboveHeight: widget.itemSpacing,
        lineBelowHeight: widget.itemSpacing,
      ),
    );
  }

  /// Builds the pending (loading) indicator at the end of the timeline.
  Widget _buildPendingItem(
    BuildContext context,
    ParkThemeData park,
    int index,
    ParkTimelineMode mode,
  ) {
    final l10n = ParkLocalizations.of(context);
    final isLeft = _isLeftSide(index, mode);
    final isAlternate = mode == ParkTimelineMode.alternate;
    final isRevealed = _isRevealed(index);

    final pendingDot = widget.pendingDot ??
        SizedBox(
          width: widget.dotSize + 8,
          height: widget.dotSize + 8,
          child: CustomPaint(
            painter: _DashedCirclePainter(
              color: park.colors.textDisabled,
              strokeWidth: 2.0,
              dashWidth: 3.0,
              dashGap: 2.0,
            ),
          ),
        );

    final label = widget.pendingLabel ?? l10n.loading;

    final pendingContent = Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 0 : park.spacing.md,
        right: isLeft ? park.spacing.md : 0,
      ),
      child: Semantics(
        label: label,
        child: Text(
          label,
          style: TextStyle(
            fontSize: park.typography.sizeCaption,
            color: park.colors.textDisabled,
          ),
        ),
      ),
    );

    return _AnimatedReveal(
      visible: isRevealed,
      duration: widget.animationDuration,
      child: _BlinkingPending(
        child: _TimelineRow(
          dotSize: widget.dotSize,
          lineWidth: widget.lineWidth,
          lineColor: park.colors.border,
          dot: pendingDot,
          content: pendingContent,
          isLeft: isLeft,
          isAlternate: isAlternate,
          showLineAbove: true,
          showLineBelow: false,
          lineAboveHeight: widget.itemSpacing,
          lineBelowHeight: 0,
        ),
      ),
    );
  }

  /// Builds the dot indicator for a timeline item.
  Widget _buildDot(
    ParkThemeData park,
    ParkTimelineItem item,
    Color dotColor,
  ) {
    // Custom dot widget takes highest priority.
    if (item.dotWidget != null) {
      return item.dotWidget!;
    }

    // Icon dot: filled circle with icon inside.
    if (item.icon != null) {
      final iconSize = widget.dotSize + 8;
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dotColor.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          item.icon,
          size: iconSize * 0.55,
          color: Colors.white,
        ),
      );
    }

    // Default: simple circle dot with ring.
    return Container(
      width: widget.dotSize,
      height: widget.dotSize,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: dotColor.withValues(alpha: 0.25),
          width: 3,
        ),
      ),
    );
  }

  /// Builds the content card for a timeline item.
  Widget _buildContent(ParkThemeData park, ParkTimelineItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        label: '${item.title}${item.description != null ? ', ${item.description}' : ''}${item.time != null ? ', ${item.time}' : ''}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontSize: park.typography.sizeBody,
                fontWeight: park.typography.weightMedium,
                color: park.colors.textPrimary,
              ),
            ),
            if (item.description != null) ...[
              SizedBox(height: park.spacing.xs),
              Text(
                item.description!,
                style: TextStyle(
                  fontSize: park.typography.sizeCaption,
                  color: park.colors.textSecondary,
                ),
              ),
            ],
            if (item.time != null) ...[
              SizedBox(height: park.spacing.xs),
              Text(
                item.time!,
                style: TextStyle(
                  fontSize: park.typography.sizeCaption,
                  color: park.colors.textPlaceholder,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/// A row that renders the dot column (with optional line segments above/below)
/// and the content column, handling left/right/alternate positioning.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.dotSize,
    required this.lineWidth,
    required this.lineColor,
    required this.dot,
    required this.content,
    required this.isLeft,
    required this.isAlternate,
    required this.showLineAbove,
    required this.showLineBelow,
    required this.lineAboveHeight,
    required this.lineBelowHeight,
  });

  final double dotSize;
  final double lineWidth;
  final Color lineColor;
  final Widget dot;
  final Widget content;
  final bool isLeft;
  final bool isAlternate;
  final bool showLineAbove;
  final bool showLineBelow;
  final double lineAboveHeight;
  final double lineBelowHeight;

  @override
  Widget build(BuildContext context) {
    // The "rail" is the vertical column containing line-dot-line.
    final railWidth = dotSize + 12; // dot + horizontal padding

    Widget rail = SizedBox(
      width: railWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Line above the dot
          if (showLineAbove)
            SizedBox(
              width: lineWidth,
              height: lineAboveHeight / 2,
              child: ColoredBox(color: lineColor),
            )
          else
            SizedBox(height: lineAboveHeight / 2),
          // Dot
          Center(child: dot),
          // Line below the dot
          if (showLineBelow)
            SizedBox(
              width: lineWidth,
              height: lineBelowHeight / 2,
              child: ColoredBox(color: lineColor),
            )
          else
            SizedBox(height: lineBelowHeight / 2),
        ],
      ),
    );

    // In alternate mode, both sides need equal width allocation.
    if (isAlternate) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left content area (or spacer)
          Expanded(
            child: isLeft
                ? Align(
                    alignment: Alignment.topRight,
                    child: content,
                  )
                : const SizedBox.shrink(),
          ),
          // Rail in center
          rail,
          // Right content area (or spacer)
          Expanded(
            child: isLeft
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.topLeft,
                    child: content,
                  ),
          ),
        ],
      );
    }

    // Non-alternate: rail + content side by side.
    if (isLeft) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: content,
            ),
          ),
          rail,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rail,
        Expanded(child: content),
      ],
    );
  }
}

/// Simple fade + slide-up animation for revealing timeline items.
class _AnimatedReveal extends StatelessWidget {
  const _AnimatedReveal({
    required this.visible,
    required this.duration,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, -0.15),
        duration: duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

/// Blinking animation (fade in/out) for the pending indicator.
class _BlinkingPending extends StatefulWidget {
  const _BlinkingPending({required this.child});

  final Widget child;

  @override
  State<_BlinkingPending> createState() => _BlinkingPendingState();
}

class _BlinkingPendingState extends State<_BlinkingPending>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(CurveTween(curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Paints a dashed circle outline used for the pending dot indicator.
class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final circumference = 2 * math.pi * radius;

    final totalDash = dashWidth + dashGap;
    final dashCount = (circumference / totalDash).floor();

    if (dashCount == 0) return;

    final adjustedTotal = circumference / dashCount;
    final adjustedDashWidth = adjustedTotal * (dashWidth / totalDash);
    final adjustedGap = adjustedTotal * (dashGap / totalDash);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (adjustedDashWidth + adjustedGap)) / radius;
      final sweepAngle = adjustedDashWidth / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
