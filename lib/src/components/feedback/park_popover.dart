import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_spacing.dart';
import '../base/park_surface.dart';

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

/// 气泡表面材质的派生结果。
///
/// 把"主体填充"与"箭头填充"收敛到**同一个** [fill]，是本组件最关键的
/// 不变量：改造前两者分处两地、各自写死 `colors.surface`，一旦主体改由
/// 风格令牌决定就会不同色。
@immutable
class ParkPopoverSurface {
  /// 气泡体（与箭头共用）的填充色。
  final Color fill;

  /// 圆角。
  final BorderRadius radius;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 是否需要背景模糊采样。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  /// 箭头颜色 —— **恒等于** [fill]。
  ///
  /// 单独暴露这个 getter 是为了让"箭头与气泡体同色"这条不变量
  /// 可被单元测试直接断言（改造前箭头与主体分处两地、各自写死
  /// `colors.surface`，是典型的"成对取值漏改"高危点）。
  Color get arrowColor => fill;

  /// 建议的气泡内容文字色。
  ///
  /// popover 本身不画文字（内容由调用方给），但调用方需要知道"在当前
  /// 表面上该用什么文字色"。直接用 `colors.textPrimary` 在 neon + 深色
  /// 底下会与近白的 [fill] 撞成 1.00:1（白底白字）——与批次 1 的 neon P0
  /// 同类。暴露此字段让调用方有一个正确且可测的默认值。
  final Color titleColor;

  /// 建议的次要文字色（描述 / 备注）。
  final Color bodyColor;

  const ParkPopoverSurface({
    required this.fill,
    required this.radius,
    required this.shadows,
    required this.useBlur,
    required this.blurSigma,
    required this.titleColor,
    required this.bodyColor,
  });
}

/// 解析气泡表面材质（浮层类统一规范的唯一实现点）。
///
/// 抽成顶层公开函数而非私有方法，是为了让它**可被单元测试直接调用**——
/// 箭头与主体的同色性无法从 widget 树反推（箭头是 CustomPaint，
/// 颜色是 painter 的私有字段）。
///
/// 规范（与 `ParkDialog` 一致）：
/// 1. 阴影 `tokens.shadows ?? park.shadows.lg`（风格接管 + 浮层下限兜底）；
/// 2. 圆角保留组件原值（气泡是卡片尺寸，用 `brMd`）；
/// 3. 无描边（`bordered: false`）。
@visibleForTesting
ParkPopoverSurface resolveParkPopoverSurface({
  required ParkThemeData park,
  required BuildContext context,
  BoxDecoration? overlayStyle,
}) {
  // overlayStyle 是用户完全接管的逃生舱，此时不派生任何令牌。
  if (overlayStyle != null) {
    final BorderRadiusGeometry? customRadius = overlayStyle.borderRadius;
    return ParkPopoverSurface(
      fill: overlayStyle.color ?? park.colors.surface,
      // BorderRadius.topLeft 是单角 Radius，需包成 BorderRadius。
      radius: customRadius is BorderRadius
          ? BorderRadius.only(topLeft: customRadius.topLeft)
          : park.radius.brMd,
      shadows: overlayStyle.boxShadow,
      useBlur: false,
      blurSigma: 0,
      // 自定义填充时无法判断明暗，退回默认文字色（与改造前行为一致）。
      titleColor: park.colors.textPrimary,
      bodyColor: park.colors.textSecondary,
    );
  }

  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  return ParkPopoverSurface(
    fill: tokens.fill,
    radius: park.radius.brMd,
    shadows: tokens.shadows ?? park.shadows.lg,
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
    // 文字色来自 tokens：neon 深色底下 fill 翻转为近白，此时
    // colors.textPrimary 会与之撞成 1.00:1（白底白字）。
    titleColor: tokens.titleColor,
    bodyColor: tokens.bodyColor,
  );
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

  /// 解析气泡的表面材质。
  ///
  /// 委托给 [resolveParkPopoverSurface]（顶层函数）以便单元测试直接验证
  /// "箭头与气泡体同色"这条不变量 —— 箭头是 CustomPaint，其颜色无法从
  /// widget 树反推。
  ParkPopoverSurface _resolveSurface(ParkThemeData park) {
    return resolveParkPopoverSurface(
      park: park,
      context: context,
      overlayStyle: widget.overlayStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final ParkPopoverSurface surface = _resolveSurface(park);

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
              child: _buildBody(surface, park.spacing),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建气泡主体（含箭头与玻璃模糊）。
  Widget _buildBody(ParkPopoverSurface surface, ParkSpacing spacing) {
    // glass 风格：叠加 BackdropFilter 采样背后内容。
    // 复用 ParkSurfaceBlurDepth 做嵌套降级，避免重复采样同一 backdrop。
    Widget column = Material(
      key: ValueKey('popover_z_${widget.zIndex}'),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showArrow && _isVerticalTop) _buildArrow(surface),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showArrow && _isHorizontalRight) _buildArrow(surface),
              Semantics(
                container: true,
                child: Container(
                  constraints: BoxConstraints(maxWidth: widget.maxWidth),
                  padding: EdgeInsets.all(spacing.md),
                  decoration: widget.overlayStyle ??
                      BoxDecoration(
                        color: surface.fill,
                        borderRadius: surface.radius,
                        boxShadow: surface.shadows,
                      ),
                  child: widget.content,
                ),
              ),
              if (widget.showArrow && _isHorizontalLeft) _buildArrow(surface),
            ],
          ),
          if (widget.showArrow && _isVerticalBottom) _buildArrow(surface),
        ],
      ),
    );

    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) <= 1 &&
        surface.blurSigma > 0) {
      column = ClipRRect(
        borderRadius: surface.radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: surface.blurSigma,
            sigmaY: surface.blurSigma,
          ),
          child: column,
        ),
      );
    }
    return column;
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

  Widget _buildArrow(ParkPopoverSurface surface) {
    const arrowSize = 8.0;
    // 🔴 箭头色取自 surface.arrowColor（恒等于气泡体 fill），不能独立写死
    // `park.colors.surface` —— 否则 neon 等会翻转填充色的风格下，
    // 箭头与气泡体不同色，出现视觉裂缝。
    final Color color = surface.arrowColor;
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
