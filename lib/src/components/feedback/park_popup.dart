import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 弹出位置
enum ParkPopupPosition { center, bottom, top }

/// 弹出动画类型
enum ParkPopupAnimation { fade, slide, scale, none }

/// ParkPopup — 弹出面板组件，支持中心/底部/顶部位置与动画过渡。
class ParkPopup extends StatefulWidget {
  final bool visible;
  final Widget child;
  final ParkPopupPosition position;
  final VoidCallback? onDismiss;
  final bool barrier;
  final bool dismissOnBarrierTap;

  /// 当 true 时显示半透明遮罩。
  final bool mask;

  /// 当 true 时点击遮罩关闭弹窗。
  final bool maskClosable;

  /// 弹出动画类型。
  final ParkPopupAnimation animation;

  /// 自定义圆角。
  final double? borderRadius;

  /// When true, child widget is destroyed when popup closes (disposed).
  final bool destroyOnClose;

  /// When true, wraps content in SafeArea. When false, no SafeArea wrapping.
  final bool safeArea;

  /// Close guard: called before closing. Return false to prevent close.
  final Future<bool> Function()? beforeClose;

  /// Z-index for layering when multiple popups overlap.
  final int zIndex;

  /// Callback fired after popup close animation completes.
  final VoidCallback? afterClose;

  /// Whether to show an arrow indicator pointing at the trigger.
  final bool arrow;

  const ParkPopup({
    super.key,
    required this.visible,
    required this.child,
    this.position = ParkPopupPosition.center,
    this.onDismiss,
    this.barrier = true,
    this.dismissOnBarrierTap = true,
    this.mask = true,
    this.maskClosable = true,
    this.animation = ParkPopupAnimation.fade,
    this.borderRadius,
    this.destroyOnClose = false,
    this.safeArea = true,
    this.beforeClose,
    this.zIndex = 1000,
    this.afterClose,
    this.arrow = false,
  });

  @override
  State<ParkPopup> createState() => _ParkPopupState();
}

class _ParkPopupState extends State<ParkPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _dismissTriggeredByBarrier = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _configureSlideAnimation();

    if (widget.visible) {
      _controller.forward();
    }
  }

  void _configureSlideAnimation() {
    _slideAnim = Tween<Offset>(
      begin: _slideBegin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  Offset get _slideBegin {
    switch (widget.position) {
      case ParkPopupPosition.center:
        return const Offset(0, 0.05);
      case ParkPopupPosition.bottom:
        return const Offset(0, 1);
      case ParkPopupPosition.top:
        return const Offset(0, -1);
    }
  }

  Alignment get _alignment {
    switch (widget.position) {
      case ParkPopupPosition.center:
        return Alignment.center;
      case ParkPopupPosition.bottom:
        return Alignment.bottomCenter;
      case ParkPopupPosition.top:
        return Alignment.topCenter;
    }
  }

  @override
  void didUpdateWidget(covariant ParkPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _configureSlideAnimation();
    }

    if (widget.visible && !oldWidget.visible) {
      _dismissTriggeredByBarrier = false;
      _controller.forward();
    } else if (!widget.visible && oldWidget.visible) {
      // Check beforeClose guard
      if (widget.beforeClose != null) {
        widget.beforeClose!().then((canClose) {
          if (!canClose) {
            // Prevent close by re-opening
            _controller.forward();
            return;
          }
          _performClose();
        });
      } else {
        _performClose();
      }
    }
  }

  void _performClose() {
    final notifyDismiss = !_dismissTriggeredByBarrier;
    _dismissTriggeredByBarrier = false;
    _controller.reverse().whenCompleteOrCancel(() {
      if (notifyDismiss) {
        widget.onDismiss?.call();
      }
    });
  }

  void _handleBarrierTap() async {
    if (!widget.dismissOnBarrierTap && !widget.maskClosable) {
      return;
    }

    if (widget.beforeClose != null) {
      final canClose = await widget.beforeClose!();
      if (!canClose) return;
    }

    _dismissTriggeredByBarrier = true;
    widget.onDismiss?.call();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.visible) {
        _dismissTriggeredByBarrier = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    if (!_controller.isAnimating && !widget.visible && _controller.isDismissed) {
      if (widget.destroyOnClose) return const SizedBox.shrink();
      // When not destroyOnClose, keep child alive but invisible
      return Offstage(child: widget.child);
    }

    return Stack(
      children: [
        // Barrier
        if (widget.barrier && widget.mask)
          FadeTransition(
            opacity: _fadeAnim,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleBarrierTap,
              child: Container(
                color: park.colors.overlay.withValues(alpha: 0.4),
              ),
            ),
          ),

        // Content
        _buildAnimatedContent(park),
      ],
    );
  }

  Widget _buildAnimatedContent(ParkThemeData park) {
    final Widget content = widget.borderRadius != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius!),
            child: widget.child,
          )
        : widget.child;

    Widget _wrapSafeArea(Widget child) {
      return widget.safeArea
          ? SafeArea(child: Align(alignment: _alignment, child: child))
          : Align(alignment: _alignment, child: child);
    }

    switch (widget.animation) {
      case ParkPopupAnimation.fade:
        return FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: _wrapSafeArea(content),
          ),
        );
      case ParkPopupAnimation.slide:
        return SlideTransition(
          position: _slideAnim,
          child: _wrapSafeArea(content),
        );
      case ParkPopupAnimation.scale:
        return FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _fadeAnim,
            child: _wrapSafeArea(content),
          ),
        );
      case ParkPopupAnimation.none:
        return _wrapSafeArea(content);
    }
  }
}
