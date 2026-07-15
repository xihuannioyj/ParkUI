import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 加载指示器类型
enum ParkLoadingType { circular, dots }

/// 加载指示器尺寸
enum ParkLoadingSize { small, medium, large }

/// ParkLoading — 加载指示组件，可作为 Widget 使用或通过静态方法全屏展示。
class ParkLoading extends StatefulWidget {
  final ParkLoadingType type;
  final double size;
  final Color? color;
  final String? text;

  /// 加载指示器尺寸预设。
  final ParkLoadingSize loadingSize;

  /// 当 true 时在 spinner 后面显示半透明遮罩。
  final bool mask;

  /// Content to show underneath. When provided with [loading] = true,
  /// shows overlay over child; when [loading] = false, just shows child.
  final Widget? child;

  /// When true and [child] is provided, shows loading overlay over child.
  /// When false, just shows child directly.
  final bool loading;

  /// Delay before showing the loading indicator (avoids flash for quick loads).
  final Duration? delay;

  /// Custom loading indicator widget replacing the default spinner.
  final Widget? indicator;

  const ParkLoading({
    super.key,
    this.type = ParkLoadingType.circular,
    this.size = 36,
    this.color,
    this.text,
    this.loadingSize = ParkLoadingSize.medium,
    this.mask = false,
    this.child,
    this.loading = true,
    this.delay,
    this.indicator,
  });

  static _ParkLoadingOverlayController? _currentController;

  /// 全屏显示 loading 遮罩
  static void show(
    BuildContext context, {
    String? message,
    ParkLoadingType type = ParkLoadingType.circular,
    Color? color,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentController?.dismiss();

      final overlay = Overlay.of(context, rootOverlay: true);
      late OverlayEntry entry;
      bool removed = false;
      final GlobalKey<_ParkLoadingOverlayState> key =
          GlobalKey<_ParkLoadingOverlayState>();
      late final _ParkLoadingOverlayController controller;

      void removeEntry() {
        if (removed) return;
        removed = true;
        if (identical(_currentController, controller)) {
          _currentController = null;
        }
        entry.remove();
      }

      controller = _ParkLoadingOverlayController(
        dismiss: () async {
          final _ParkLoadingOverlayState? state = key.currentState;
          if (state == null) {
            removeEntry();
            return;
          }
          await state.dismiss();
        },
      );
      _currentController = controller;

      entry = OverlayEntry(
        builder: (_) => _ParkLoadingOverlay(
          key: key,
          message: message,
          type: type,
          color: color,
          onRemoved: removeEntry,
        ),
      );

      overlay.insert(entry);
    });
  }

  /// 隐藏全屏 loading
  static void hide(BuildContext context) {
    _currentController?.dismiss();
  }

  /// 关闭全屏 loading（等同于 [hide]）。
  static void dismiss() {
    _currentController?.dismiss();
  }

  @override
  State<ParkLoading> createState() => _ParkLoadingState();
}

class _ParkLoadingOverlayController {
  final Future<void> Function() dismiss;
  _ParkLoadingOverlayController({required this.dismiss});
}

class _ParkLoadingState extends State<ParkLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _showIndicator = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Handle delay: don't show indicator until after delay
    if (widget.delay != null && widget.child != null) {
      _showIndicator = false;
      Future<void>.delayed(widget.delay!, () {
        if (mounted) {
          setState(() => _showIndicator = true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ParkLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading != oldWidget.loading && widget.delay != null) {
      if (widget.loading) {
        _showIndicator = false;
        Future<void>.delayed(widget.delay!, () {
          if (mounted) {
            setState(() => _showIndicator = true);
          }
        });
      } else {
        _showIndicator = false;
      }
    }
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
    final indicatorColor = widget.color ?? park.colors.brand;

    // Wrapping mode: when child is provided
    if (widget.child != null) {
      if (!widget.loading) {
        return widget.child!;
      }

      // Show child with loading overlay
      if (!_showIndicator && widget.delay != null) {
        return widget.child!;
      }

      return Stack(
        children: [
          widget.child!,
          Positioned.fill(
            child: Semantics(
              label: ParkLocalizations.of(context).loading,
              liveRegion: true,
              child: Container(
                color: park.colors.overlay.withValues(alpha: 0.3),
                child: Center(
                  child: widget.indicator ?? _buildDefaultIndicator(park, indicatorColor),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Standalone mode (original behavior)
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.indicator ??
            (widget.type == ParkLoadingType.circular
                ? SizedBox(
                    width: _effectiveSize(indicatorColor),
                    height: _effectiveSize(indicatorColor),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                    ),
                  )
                : _ParkDotsIndicator(
                    size: _effectiveSize(indicatorColor) * 0.3,
                    color: indicatorColor,
                    controller: _controller,
                  )),
        if (widget.text != null) ...[
          SizedBox(height: park.spacing.sm),
          Text(
            widget.text!,
            style: park.typography.body.copyWith(
              fontSize: park.typography.sizeBodySmall,
              color: park.colors.textSecondary,
            ),
          ),
        ],
      ],
    );

    content = Semantics(
      label: widget.text ?? ParkLocalizations.of(context).loading,
      liveRegion: true,
      child: content,
    );

    if (widget.mask) {
      content = Container(
        color: park.colors.overlay.withValues(alpha: 0.3),
        child: Center(child: content),
      );
    }

    return content;
  }

  double _effectiveSize(Color indicatorColor) {
    switch (widget.loadingSize) {
      case ParkLoadingSize.small:
        return widget.size == 36 ? 24.0 : widget.size;
      case ParkLoadingSize.medium:
        return widget.size;
      case ParkLoadingSize.large:
        return widget.size == 36 ? 48.0 : widget.size;
    }
  }

  Widget _buildDefaultIndicator(ParkThemeData park, Color indicatorColor) {
    final effectiveSize = _effectiveSize(indicatorColor);
    if (widget.type == ParkLoadingType.circular) {
      return SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        ),
      );
    }
    return _ParkDotsIndicator(
      size: effectiveSize * 0.3,
      color: indicatorColor,
      controller: _controller,
    );
  }
}

class _ParkDotsIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final AnimationController controller;

  const _ParkDotsIndicator({
    required this.size,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final t = (controller.value + index * 0.2) % 1.0;
            final scale = 0.6 + 0.4 * _bounceCurve(t);
            return Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                margin: EdgeInsets.symmetric(horizontal: size * 0.3),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  double _bounceCurve(double t) {
    // Use dart:math sin for full double-precision accuracy
    return (1 + math.sin(t * math.pi * 2)) / 2;
  }
}

class _ParkLoadingOverlay extends StatefulWidget {
  final String? message;
  final ParkLoadingType type;
  final Color? color;
  final VoidCallback onRemoved;

  const _ParkLoadingOverlay({
    super.key,
    this.message,
    required this.type,
    this.color,
    required this.onRemoved,
  });

  @override
  State<_ParkLoadingOverlay> createState() => _ParkLoadingOverlayState();
}

class _ParkLoadingOverlayState extends State<_ParkLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  Future<void> dismiss() async {
    if (_isClosing) return;
    _isClosing = true;
    await _fadeController.reverse();
    if (!mounted) return;
    widget.onRemoved();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: park.colors.overlay.withValues(alpha: 0.4),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(park.spacing.lg),
            decoration: BoxDecoration(
              color: park.colors.surface,
              borderRadius: park.radius.brLg,
              boxShadow: park.shadows.md,
            ),
            child: ParkLoading(
              type: widget.type,
              color: widget.color,
              text: widget.message,
            ),
          ),
        ),
      ),
    );
  }
}
