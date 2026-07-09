import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 遮罩层组件。
///
/// 提供全屏遮罩能力，支持静态方法调用（[ParkOverlay.show]）
/// 和声明式嵌入两种方式。
///
/// 静态调用：
/// ```dart
/// ParkOverlay.show(context, child: MyWidget());
/// ```
///
/// 声明式使用：
/// ```dart
/// ParkOverlay(
///   visible: true,
///   onTap: () => setState(() => visible = false),
///   child: Center(child: Text('加载中...')),
/// )
/// ```
class ParkOverlay extends StatefulWidget {
  /// 遮罩内容。
  final Widget child;

  /// 是否可见（声明式模式）。
  final bool visible;

  /// 点击遮罩回调。
  final VoidCallback? onTap;

  /// 遮罩背景色。
  final Color? barrierColor;

  /// 是否响应点击穿透。
  final bool blocking;

  /// 动画时长。
  final Duration duration;

  /// 创建遮罩层组件（声明式）。
  const ParkOverlay({
    super.key,
    required this.child,
    this.visible = false,
    this.onTap,
    this.barrierColor,
    this.blocking = true,
    this.duration = const Duration(milliseconds: 200),
    this.color,
    this.blur,
    this.lockScroll = true,
    this.afterClose,
    this.custom = false,
    this.transitionName = 'fade',
  });

  /// 自定义遮罩颜色。
  final Color? color;

  /// 背景模糊 sigma 值。
  final double? blur;

  /// When true (default), prevents background scrolling while overlay is visible.
  final bool lockScroll;

  /// Callback fired after overlay close animation completes.
  final VoidCallback? afterClose;

  /// When true, renders without default mask styling (fully custom).
  final bool custom;

  /// Name of the transition animation to use.
  final String transitionName;

  /// 静态方法：弹出全屏遮罩层。
  ///
  /// 返回 [ParkOverlayHandle] 用于手动关闭。
  /// 也可通过 [autoClose] 参数设置自动关闭时间。
  ///
  /// [context] 构建上下文。
  /// [child] 遮罩内容。
  /// [barrierColor] 遮罩背景色。
  /// [blocking] 是否阻止背景点击。
  /// [autoClose] 自动关闭时间（null 则不自动关闭）。
  /// [onTap] 点击遮罩回调。
  static ParkOverlayHandle show(
    BuildContext context, {
    required Widget child,
    Color? barrierColor,
    bool blocking = true,
    Duration? autoClose,
    VoidCallback? onTap,
    Color? color,
    double? blur,
    bool lockScroll = true,
  }) {
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    final Completer<void> completer = Completer<void>();
    bool dismissed = false;

    void dismiss() {
      if (dismissed) return;
      dismissed = true;
      if (entry.mounted) {
        entry.remove();
      }
      if (!completer.isCompleted) completer.complete();
    }

    entry = OverlayEntry(
      builder: (BuildContext ctx) {
        return _ParkOverlayPopup(
          barrierColor: color ?? barrierColor,
          blocking: blocking,
          onTap: () {
            onTap?.call();
            dismiss();
          },
          onDismiss: dismiss,
          blur: blur,
          lockScroll: lockScroll,
          child: child,
        );
      },
    );

    overlay.insert(entry);

    if (autoClose != null) {
      Future<void>.delayed(autoClose, dismiss);
    }

    return ParkOverlayHandle._(dismiss, completer.future);
  }

  @override
  State<ParkOverlay> createState() => _ParkOverlayState();
}

class _ParkOverlayState extends State<ParkOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.visible ? 1.0 : 0.0,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant ParkOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
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
    if (!widget.visible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final Color barrier =
        widget.color ?? widget.barrierColor ?? park.colors.overlay.withValues(alpha: 0.5);

    Widget result = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        Widget overlay = Container(
          color: barrier.withValues(alpha: _fadeAnim.value),
          child: widget.child,
        );

        if (widget.blur != null && widget.blur! > 0) {
          overlay = Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur!,
                  sigmaY: widget.blur!,
                ),
                child: overlay,
              ),
            ],
          );
        }

        return IgnorePointer(
          ignoring: !_controller.isCompleted && !widget.visible,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: GestureDetector(
              onTap: widget.blocking ? widget.onTap : null,
              child: overlay,
            ),
          ),
        );
      },
    );

    if (widget.lockScroll) {
      return ScrollConfiguration(
        behavior: const _NoScrollBehavior(),
        child: result,
      );
    }
    return result;
  }
}

/// 遮罩层弹出句柄。
///
/// 通过 [ParkOverlay.show] 返回，用于手动关闭遮罩层。
class ParkOverlayHandle {
  /// 关闭回调。
  final VoidCallback _dismiss;

  /// 关闭完成 Future。
  final Future<void> _future;

  /// 创建句柄。
  ParkOverlayHandle._(this._dismiss, this._future);

  /// 关闭遮罩层。
  void close() => _dismiss();

  /// 等待遮罩层关闭。
  Future<void> get closed => _future;
}

/// 内部弹出遮罩组件（用于静态方法）。
class _ParkOverlayPopup extends StatefulWidget {
  final Widget child;
  final Color? barrierColor;
  final bool blocking;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;
  final double? blur;
  final bool lockScroll;

  const _ParkOverlayPopup({
    required this.child,
    this.barrierColor,
    this.blocking = true,
    this.onTap,
    required this.onDismiss,
    this.blur,
    this.lockScroll = true,
  });

  @override
  State<_ParkOverlayPopup> createState() => _ParkOverlayPopupState();
}

class _ParkOverlayPopupState extends State<_ParkOverlayPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final Color barrier =
        widget.barrierColor ?? park.colors.overlay.withValues(alpha: 0.5);

    Widget result = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        Widget barrierWidget = GestureDetector(
          onTap: widget.blocking ? widget.onTap : null,
          child: Container(
            color: barrier.withValues(alpha: _fadeAnim.value),
          ),
        );

        if (widget.blur != null && widget.blur! > 0) {
          barrierWidget = BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blur!,
              sigmaY: widget.blur!,
            ),
            child: barrierWidget,
          );
        }

        return Stack(
          children: <Widget>[
            barrierWidget,
            // 内容。
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (widget.lockScroll) {
      return ScrollConfiguration(
        behavior: const _NoScrollBehavior(),
        child: result,
      );
    }
    return result;
  }
}

/// ScrollBehavior that prevents overscroll glow and bouncing.
class _NoScrollBehavior extends ScrollBehavior {
  const _NoScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const NeverScrollableScrollPhysics();
  }
}
