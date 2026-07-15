import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
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

  /// Show a standard modal popup with title bar (cancel + title + confirm)
  /// and scrollable content body.
  ///
  /// Convenience method for the common "form modal" pattern.
  /// Returns the popup result (true if confirmed, false/null if cancelled).
  static Future<bool?> showModal({
    required BuildContext context,
    required String title,
    required Widget child,
    String confirmText = '',
    String cancelText = '',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool confirmEnabled = true,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ParkPopupModal(
          title: title,
          child: child,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          confirmEnabled: confirmEnabled,
        );
      },
    );
  }

  /// 通用底部弹窗（函数式调用，带返回值）。
  ///
  /// 封装 [showModalBottomSheet]，返回 [Future]<[T]?>。
  /// 适用于选择列表、详情面板、操作菜单等需要函数式 + 返回值的场景。
  ///
  /// ```dart
  /// // 选择列表（带返回值）
  /// final String? value = await ParkPopup.showBottomSheet<String>(
  ///   context: context,
  ///   builder: (ctx) => Column(
  ///     mainAxisSize: MainAxisSize.min,
  ///     children: [
  ///       ListTile(title: Text('选项 A'), onTap: () => Navigator.pop(ctx, 'A')),
  ///       ListTile(title: Text('选项 B'), onTap: () => Navigator.pop(ctx, 'B')),
  ///     ],
  ///   ),
  /// );
  ///
  /// // 详情面板
  /// ParkPopup.showBottomSheet(
  ///   context: context,
  ///   isScrollControlled: true,
  ///   builder: (ctx) => SafeArea(
  ///     child: MyDetailPanel(),
  ///   ),
  /// );
  /// ```
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    double? borderRadius,
    Color? backgroundColor,
    bool useSafeArea = true,
    bool showDragHandle = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Colors.transparent,
      shape: borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
            )
          : null,
      builder: (_) {
        // 底部弹窗容器
        return ClipRRect(
          borderRadius: borderRadius != null
              ? BorderRadius.vertical(top: Radius.circular(borderRadius))
              : BorderRadius.vertical(top: Radius.circular(16)),
          child: _ParkBottomSheetContent<T>(
            builder: builder,
            useSafeArea: useSafeArea,
            showDragHandle: showDragHandle,
          ),
        );
      },
    );
  }
}

class _ParkPopupState extends State<ParkPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _dismissTriggeredByBarrier = false;

  /// B83b: Guard flag to prevent beforeClose reentry race condition.
  bool _isCheckingBeforeClose = false;

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
      _isCheckingBeforeClose = false;
      _controller.forward();
    } else if (!widget.visible && oldWidget.visible) {
      // B83b: Check beforeClose guard with reentry protection.
      if (widget.beforeClose != null && !_isCheckingBeforeClose) {
        _isCheckingBeforeClose = true;
        widget.beforeClose!().then((canClose) {
          _isCheckingBeforeClose = false;
          if (!canClose) {
            // Prevent close by re-opening
            _controller.forward();
            return;
          }
          _performClose();
        });
      } else if (widget.beforeClose == null) {
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
    if (!widget.dismissOnBarrierTap || !widget.maskClosable) {
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

/// Internal modal scaffold widget used by [ParkPopup.showModal].
class _ParkPopupModal extends StatelessWidget {
  final String title;
  final Widget child;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool confirmEnabled;

  const _ParkPopupModal({
    required this.title,
    required this.child,
    required this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final l10n = ParkLocalizations.of(context);
    final cancelLabel = cancelText.isNotEmpty ? cancelText : l10n.cancelText;
    final confirmLabel = confirmText.isNotEmpty ? confirmText : l10n.confirmText;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(park.radius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: EdgeInsets.only(top: park.spacing.sm),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.sm,
                vertical: park.spacing.xs,
              ),
              child: Row(
                children: [
                  Semantics(
                    label: cancelLabel,
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        onCancel?.call();
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: park.spacing.base,
                          vertical: park.spacing.sm,
                        ),
                        child: Text(
                          cancelLabel,
                          style: TextStyle(
                            fontSize: park.typography.sizeBody,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: park.typography.sizeBody,
                      fontWeight: park.typography.weightBold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: confirmLabel,
                    button: true,
                    enabled: confirmEnabled,
                    child: GestureDetector(
                      onTap: confirmEnabled
                          ? () {
                              onConfirm?.call();
                              Navigator.pop(context, true);
                            }
                          : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: park.spacing.base,
                          vertical: park.spacing.sm,
                        ),
                        child: Text(
                          confirmLabel,
                          style: TextStyle(
                            fontSize: park.typography.sizeBody,
                            fontWeight: park.typography.weightBold,
                            color: confirmEnabled ? colors.brand : colors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable content body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  park.spacing.base, 0,
                  park.spacing.base, park.spacing.base,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal bottom sheet content widget used by [ParkPopup.showBottomSheet].
class _ParkBottomSheetContent<T> extends StatelessWidget {
  final WidgetBuilder builder;
  final bool useSafeArea;
  final bool showDragHandle;

  const _ParkBottomSheetContent({
    required this.builder,
    this.useSafeArea = true,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    Widget content = builder(context);
    if (showDragHandle) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: park.colors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(child: content),
        ],
      );
    }
    if (useSafeArea) {
      content = SafeArea(
        top: false,
        child: content,
      );
    }
    return content;
  }
}
