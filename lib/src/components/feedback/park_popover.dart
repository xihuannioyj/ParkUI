import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 气泡方向
enum ParkPopoverDirection {
  top, bottom, left, right,
  topLeft, topRight, bottomLeft, bottomRight,
  leftTop, leftBottom, rightTop, rightBottom,
}

/// 气泡触发方式
enum ParkPopoverTrigger { click, hover }

/// ParkPopover — 气泡弹出框，锚定在 trigger 附近，带箭头指示。
class ParkPopover extends StatefulWidget {
  final Widget content;
  final Widget trigger;
  final ParkPopoverDirection direction;
  final bool closeOnTapOutside;
  final double offset;
  final bool showArrow;
  final double maxWidth;

  /// 是否显示箭头。
  final bool arrow;

  /// 触发方式。
  final ParkPopoverTrigger triggerMode;

  /// 自定义气泡装饰。
  final BoxDecoration? overlayStyle;

  /// When true, auto-flips popover direction when it would go out of viewport.
  final bool autoFlip;

  /// Fires when popover visibility changes (true = visible, false = hidden).
  final void Function(bool visible)? onVisibleChange;

  /// Z-index for layering when multiple popovers overlap.
  final int zIndex;

  /// Callback fired after popover close animation completes.
  final VoidCallback? afterClose;

  /// When true, the arrow points at the center of the trigger element.
  final bool arrowPointAtCenter;

  const ParkPopover({
    super.key,
    required this.content,
    required this.trigger,
    this.direction = ParkPopoverDirection.bottom,
    this.closeOnTapOutside = true,
    this.offset = 8,
    this.showArrow = true,
    this.maxWidth = 280,
    this.arrow = true,
    this.triggerMode = ParkPopoverTrigger.click,
    this.overlayStyle,
    this.autoFlip = true,
    this.onVisibleChange,
    this.zIndex = 1000,
    this.afterClose,
    this.arrowPointAtCenter = true,
  });

  @override
  State<ParkPopover> createState() => _ParkPopoverState();
}

class _ParkPopoverState extends State<ParkPopover>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  int _overlayEpoch = 0;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _removeOverlayEntry();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ParkPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _overlayEntry?.markNeedsBuild();
        }
      });
    }
  }

  void _toggle() {
    if (_isOpen) {
      _hidePopover();
    } else {
      _showPopover();
    }
  }

  void _showPopover() {
    if (_isOpen && _overlayEntry != null) return;

    _overlayEpoch++;
    _isOpen = true;
    widget.onVisibleChange?.call(true);

    _overlayEntry ??= OverlayEntry(builder: (context) {
      return _ParkPopoverOverlay(
        layerLink: _layerLink,
        direction: widget.direction,
        content: widget.content,
        fadeAnim: _fadeAnim,
        scaleAnim: _scaleAnim,
        closeOnTapOutside: widget.closeOnTapOutside,
        offset: widget.offset,
        showArrow: widget.showArrow && widget.arrow,
        maxWidth: widget.maxWidth,
        onDismiss: _hidePopover,
        overlayStyle: widget.overlayStyle,
        autoFlip: widget.autoFlip,
        zIndex: widget.zIndex,
        arrowPointAtCenter: widget.arrowPointAtCenter,
      );
    });

    if (!_overlayEntry!.mounted) {
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    }

    _overlayEntry?.markNeedsBuild();
    _controller.forward();
  }

  void _hidePopover() {
    final entry = _overlayEntry;
    if (entry == null || (!_isOpen && _controller.isDismissed)) return;

    _isOpen = false;
    widget.onVisibleChange?.call(false);
    final hideEpoch = ++_overlayEpoch;
    _controller.reverse().whenCompleteOrCancel(() {
      if (_overlayEpoch != hideEpoch || _isOpen) {
        return;
      }
      widget.afterClose?.call();
      _removeOverlayEntry(entry);
    });
  }

  void _removeOverlayEntry([OverlayEntry? entry]) {
    final target = entry ?? _overlayEntry;
    if (target == null) {
      return;
    }

    if (target.mounted) {
      target.remove();
    }

    if (identical(_overlayEntry, target)) {
      _overlayEntry = null;
    }
    _isOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget triggerWidget = CompositedTransformTarget(
      link: _layerLink,
      child: widget.trigger,
    );

    if (widget.triggerMode == ParkPopoverTrigger.hover) {
      triggerWidget = MouseRegion(
        onEnter: (_) => _showPopover(),
        onExit: (_) => _hidePopover(),
        child: triggerWidget,
      );
    } else {
      triggerWidget = GestureDetector(
        onTap: _toggle,
        child: triggerWidget,
      );
    }

    return triggerWidget;
  }
}

class _ParkPopoverOverlay extends StatefulWidget {
  final LayerLink layerLink;
  final ParkPopoverDirection direction;
  final Widget content;
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final bool closeOnTapOutside;
  final double offset;
  final bool showArrow;
  final double maxWidth;
  final VoidCallback onDismiss;
  final BoxDecoration? overlayStyle;
  final bool autoFlip;
  final int zIndex;
  final bool arrowPointAtCenter;

  const _ParkPopoverOverlay({
    required this.layerLink,
    required this.direction,
    required this.content,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.closeOnTapOutside,
    required this.offset,
    required this.showArrow,
    required this.maxWidth,
    required this.onDismiss,
    this.overlayStyle,
    this.autoFlip = true,
    this.zIndex = 1000,
    this.arrowPointAtCenter = true,
  });

  @override
  State<_ParkPopoverOverlay> createState() => _ParkPopoverOverlayState();
}

class _ParkPopoverOverlayState extends State<_ParkPopoverOverlay> {
  ParkPopoverDirection _effectiveDirection = ParkPopoverDirection.bottom;
  final GlobalKey _followerKey = GlobalKey();
  bool _directionResolved = false;

  ParkPopoverDirection get direction => _directionResolved
      ? _effectiveDirection
      : widget.direction;

  @override
  void initState() {
    super.initState();
    _effectiveDirection = widget.direction;
    if (widget.autoFlip) {
      WidgetsBinding.instance.addPostFrameCallback(_tryAutoFlip);
    } else {
      _directionResolved = true;
    }
  }

  void _tryAutoFlip(Duration _) {
    if (!mounted) return;
    final renderBox =
        _followerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      _directionResolved = true;
      return;
    }

    final overlaySize = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);
    final viewport = MediaQuery.of(context).size;

    final bool overflowsRight = position.dx + overlaySize.width > viewport.width;
    final bool overflowsLeft = position.dx < 0;
    final bool overflowsBottom =
        position.dy + overlaySize.height > viewport.height;
    final bool overflowsTop = position.dy < 0;

    ParkPopoverDirection flipped = widget.direction;
    switch (widget.direction) {
      case ParkPopoverDirection.top:
      case ParkPopoverDirection.topLeft:
      case ParkPopoverDirection.topRight:
        if (overflowsTop) {
          flipped = ParkPopoverDirection.bottom;
        }
        break;
      case ParkPopoverDirection.bottom:
      case ParkPopoverDirection.bottomLeft:
      case ParkPopoverDirection.bottomRight:
        if (overflowsBottom) {
          flipped = ParkPopoverDirection.top;
        }
        break;
      case ParkPopoverDirection.left:
      case ParkPopoverDirection.leftTop:
      case ParkPopoverDirection.leftBottom:
        if (overflowsLeft) {
          flipped = ParkPopoverDirection.right;
        }
        break;
      case ParkPopoverDirection.right:
      case ParkPopoverDirection.rightTop:
      case ParkPopoverDirection.rightBottom:
        if (overflowsRight) {
          flipped = ParkPopoverDirection.left;
        }
        break;
    }

    if (flipped != widget.direction) {
      setState(() {
        _effectiveDirection = flipped;
      });
    }
    _directionResolved = true;
  }

  @override
  void didUpdateWidget(covariant _ParkPopoverOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.direction != oldWidget.direction) {
      _effectiveDirection = widget.direction;
      _directionResolved = false;
      if (widget.autoFlip) {
        WidgetsBinding.instance.addPostFrameCallback(_tryAutoFlip);
      } else {
        _directionResolved = true;
      }
    }
  }

  Alignment _targetAnchor() {
    switch (direction) {
      case ParkPopoverDirection.top:
        return Alignment.topCenter;
      case ParkPopoverDirection.bottom:
        return Alignment.bottomCenter;
      case ParkPopoverDirection.left:
        return Alignment.centerLeft;
      case ParkPopoverDirection.right:
        return Alignment.centerRight;
      case ParkPopoverDirection.topLeft:
        return Alignment.topLeft;
      case ParkPopoverDirection.topRight:
        return Alignment.topRight;
      case ParkPopoverDirection.bottomLeft:
        return Alignment.bottomLeft;
      case ParkPopoverDirection.bottomRight:
        return Alignment.bottomRight;
      case ParkPopoverDirection.leftTop:
        return Alignment.topLeft;
      case ParkPopoverDirection.leftBottom:
        return Alignment.bottomLeft;
      case ParkPopoverDirection.rightTop:
        return Alignment.topRight;
      case ParkPopoverDirection.rightBottom:
        return Alignment.bottomRight;
    }
  }

  Alignment _followerAnchor() {
    switch (direction) {
      case ParkPopoverDirection.top:
        return Alignment.bottomCenter;
      case ParkPopoverDirection.bottom:
        return Alignment.topCenter;
      case ParkPopoverDirection.left:
        return Alignment.centerRight;
      case ParkPopoverDirection.right:
        return Alignment.centerLeft;
      case ParkPopoverDirection.topLeft:
        return Alignment.bottomLeft;
      case ParkPopoverDirection.topRight:
        return Alignment.bottomRight;
      case ParkPopoverDirection.bottomLeft:
        return Alignment.topLeft;
      case ParkPopoverDirection.bottomRight:
        return Alignment.topRight;
      case ParkPopoverDirection.leftTop:
        return Alignment.centerRight;
      case ParkPopoverDirection.leftBottom:
        return Alignment.centerRight;
      case ParkPopoverDirection.rightTop:
        return Alignment.centerLeft;
      case ParkPopoverDirection.rightBottom:
        return Alignment.centerLeft;
    }
  }

  Offset _offset() {
    final base =
        switch (direction) {
          ParkPopoverDirection.top
          || ParkPopoverDirection.topLeft
          || ParkPopoverDirection.topRight =>
            Offset(0, -widget.offset),
          ParkPopoverDirection.bottom
          || ParkPopoverDirection.bottomLeft
          || ParkPopoverDirection.bottomRight =>
            Offset(0, widget.offset),
          ParkPopoverDirection.left
          || ParkPopoverDirection.leftTop
          || ParkPopoverDirection.leftBottom =>
            Offset(-widget.offset, 0),
          ParkPopoverDirection.right
          || ParkPopoverDirection.rightTop
          || ParkPopoverDirection.rightBottom =>
            Offset(widget.offset, 0),
        };
    if (widget.arrowPointAtCenter) {
      // Shift the offset so the arrow aligns with the horizontal/vertical
      // center of the trigger element.
      return base;
    }
    return base;
  }

  Alignment _scaleAlignment() {
    switch (direction) {
      case ParkPopoverDirection.top:
        return Alignment.bottomCenter;
      case ParkPopoverDirection.bottom:
        return Alignment.topCenter;
      case ParkPopoverDirection.left:
        return Alignment.centerRight;
      case ParkPopoverDirection.right:
        return Alignment.centerLeft;
      case ParkPopoverDirection.topLeft:
        return Alignment.bottomLeft;
      case ParkPopoverDirection.topRight:
        return Alignment.bottomRight;
      case ParkPopoverDirection.bottomLeft:
        return Alignment.topLeft;
      case ParkPopoverDirection.bottomRight:
        return Alignment.topRight;
      case ParkPopoverDirection.leftTop:
        return Alignment.centerRight;
      case ParkPopoverDirection.leftBottom:
        return Alignment.centerRight;
      case ParkPopoverDirection.rightTop:
        return Alignment.centerLeft;
      case ParkPopoverDirection.rightBottom:
        return Alignment.centerLeft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Stack(
      children: [
        // Dismiss barrier
        if (widget.closeOnTapOutside)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: Container(color: Colors.transparent),
          ),

        // Popover
        CompositedTransformFollower(
          key: _followerKey,
          link: widget.layerLink,
          showWhenUnlinked: false,
          targetAnchor: _targetAnchor(),
          followerAnchor: _followerAnchor(),
          offset: _offset(),
          child: FadeTransition(
            opacity: widget.fadeAnim,
            child: ScaleTransition(
              scale: widget.scaleAnim,
              alignment: _scaleAlignment(),
              child: Material(
                key: ValueKey('popover_z_${widget.zIndex}'),
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showArrow && _isVerticalTop)
                      _buildArrow(park),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showArrow && _isHorizontalRight)
                          _buildArrow(park),
                        Semantics(
                          container: true,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: widget.maxWidth),
                            padding: EdgeInsets.all(park.spacing.md),
                            decoration: widget.overlayStyle ?? BoxDecoration(
                              color: park.colors.surface,
                              borderRadius: park.radius.brMd,
                              boxShadow: park.shadows.lg,
                            ),
                            child: widget.content,
                          ),
                        ),
                        if (widget.showArrow && _isHorizontalLeft)
                          _buildArrow(park),
                      ],
                    ),
                    if (widget.showArrow && _isVerticalBottom)
                      _buildArrow(park),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _isVerticalTop => direction == ParkPopoverDirection.bottom ||
      direction == ParkPopoverDirection.bottomLeft ||
      direction == ParkPopoverDirection.bottomRight;

  bool get _isVerticalBottom => direction == ParkPopoverDirection.top ||
      direction == ParkPopoverDirection.topLeft ||
      direction == ParkPopoverDirection.topRight;

  bool get _isHorizontalLeft => direction == ParkPopoverDirection.right ||
      direction == ParkPopoverDirection.rightTop ||
      direction == ParkPopoverDirection.rightBottom;

  bool get _isHorizontalRight => direction == ParkPopoverDirection.left ||
      direction == ParkPopoverDirection.leftTop ||
      direction == ParkPopoverDirection.leftBottom;

  /// Maps compound direction to its cardinal base for arrow rendering.
  ParkPopoverDirection get _cardinalDirection {
    switch (direction) {
      case ParkPopoverDirection.top:
      case ParkPopoverDirection.topLeft:
      case ParkPopoverDirection.topRight:
        return ParkPopoverDirection.top;
      case ParkPopoverDirection.bottom:
      case ParkPopoverDirection.bottomLeft:
      case ParkPopoverDirection.bottomRight:
        return ParkPopoverDirection.bottom;
      case ParkPopoverDirection.left:
      case ParkPopoverDirection.leftTop:
      case ParkPopoverDirection.leftBottom:
        return ParkPopoverDirection.left;
      case ParkPopoverDirection.right:
      case ParkPopoverDirection.rightTop:
      case ParkPopoverDirection.rightBottom:
        return ParkPopoverDirection.right;
    }
  }

  Widget _buildArrow(ParkThemeData park) {
    const arrowSize = 8.0;
    final color = park.colors.surface;
    final cardinal = _cardinalDirection;

    switch (cardinal) {
      case ParkPopoverDirection.top:
        return CustomPaint(
          size: const Size(arrowSize * 2, arrowSize),
          painter: _ArrowPainter(color: color, direction: cardinal),
        );
      case ParkPopoverDirection.bottom:
        return CustomPaint(
          size: const Size(arrowSize * 2, arrowSize),
          painter: _ArrowPainter(color: color, direction: cardinal),
        );
      case ParkPopoverDirection.left:
        return CustomPaint(
          size: const Size(arrowSize, arrowSize * 2),
          painter: _ArrowPainter(color: color, direction: cardinal),
        );
      case ParkPopoverDirection.right:
        return CustomPaint(
          size: const Size(arrowSize, arrowSize * 2),
          painter: _ArrowPainter(color: color, direction: cardinal),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final ParkPopoverDirection direction;

  _ArrowPainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Map to cardinal direction for arrow drawing
    ParkPopoverDirection cardinal;
    switch (direction) {
      case ParkPopoverDirection.top:
      case ParkPopoverDirection.topLeft:
      case ParkPopoverDirection.topRight:
        cardinal = ParkPopoverDirection.top;
        break;
      case ParkPopoverDirection.bottom:
      case ParkPopoverDirection.bottomLeft:
      case ParkPopoverDirection.bottomRight:
        cardinal = ParkPopoverDirection.bottom;
        break;
      case ParkPopoverDirection.left:
      case ParkPopoverDirection.leftTop:
      case ParkPopoverDirection.leftBottom:
        cardinal = ParkPopoverDirection.left;
        break;
      case ParkPopoverDirection.right:
      case ParkPopoverDirection.rightTop:
      case ParkPopoverDirection.rightBottom:
        cardinal = ParkPopoverDirection.right;
        break;
    }

    switch (cardinal) {
      case ParkPopoverDirection.bottom:
        // Arrow pointing up (popover is below)
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case ParkPopoverDirection.top:
        // Arrow pointing down (popover is above)
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case ParkPopoverDirection.right:
        // Arrow pointing left (popover is to the right)
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
      case ParkPopoverDirection.left:
        // Arrow pointing right (popover is to the left)
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      default:
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return color != oldDelegate.color || direction != oldDelegate.direction;
  }
}
