import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';

/// ParkDialog — 对话框组件，支持 alert / confirm / info / success / warning / error 等静态调用。
class ParkDialog extends StatefulWidget {
  final String title;
  final String? content;
  final String confirmText;
  final String? cancelText;
  final bool barrierDismissible;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  // --- New params ---
  /// When true, dialog is vertically centered in viewport.
  final bool centered;

  /// When true, shows a close (X) button in top-right corner.
  final bool closable;

  /// When true, the confirm/OK button shows loading state.
  final bool confirmLoading;

  /// When true, pressing Escape closes the dialog.
  final bool keyboard;

  /// Custom dialog width. Null uses built-in constraints.
  final double? width;

  /// Completely custom footer replacing default buttons.
  final Widget? footer;

  /// When true, tapping the mask/overlay closes the dialog.
  final bool maskClosable;

  /// Arbitrary Widget as dialog body (forms, lists, images).
  /// When provided, replaces [content] string.
  final Widget? contentWidget;

  /// Rich title with icons or styled text.
  /// When provided, replaces [title] string rendering.
  final Widget? titleWidget;

  /// When true, dialog takes up the full screen.
  final bool fullscreen;

  /// Callback fired after dialog close animation completes.
  final VoidCallback? afterClose;

  /// When true, dialog content is destroyed when closed (unmounted).
  final bool destroyOnClose;

  /// Custom close icon widget (replaces default X icon when [closable] is true).
  final Widget? closeIcon;

  /// Whether to show the mask/overlay background. When false, no mask is rendered.
  final bool mask;

  /// Custom action buttons rendered as a horizontal row at the bottom.
  ///
  /// When provided, this replaces the default confirm/cancel buttons and any [footer].
  /// Each widget is typically a button (e.g. TextButton, ElevatedButton) that the
  /// caller wires with its own onPressed callback. Mimics Flutter's AlertDialog.actions.
  final List<Widget>? actions;

  const ParkDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmText = '确定',
    this.cancelText,
    this.barrierDismissible = true,
    this.onConfirm,
    this.onCancel,
    this.centered = false,
    this.closable = false,
    this.confirmLoading = false,
    this.keyboard = true,
    this.width,
    this.footer,
    this.maskClosable = true,
    this.contentWidget,
    this.titleWidget,
    this.fullscreen = false,
    this.afterClose,
    this.destroyOnClose = false,
    this.closeIcon,
    this.mask = true,
    this.actions,
  });

  /// 弹出 alert 对话框（仅一个确认按钮）
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
  }) {
    return _show(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      barrierDismissible: barrierDismissible,
      onConfirm: onConfirm,
      centered: centered,
      closable: closable,
      confirmLoading: confirmLoading,
      keyboard: keyboard,
      width: width,
      footer: footer,
      maskClosable: maskClosable,
      contentWidget: contentWidget,
      titleWidget: titleWidget,
      fullscreen: fullscreen,
    );
  }

  /// 弹出 confirm 对话框（确认 + 取消两个按钮）
  static Future<void> confirm(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    String cancelText = '取消',
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
  }) {
    return _show(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      barrierDismissible: barrierDismissible,
      onConfirm: onConfirm,
      onCancel: onCancel,
      centered: centered,
      closable: closable,
      confirmLoading: confirmLoading,
      keyboard: keyboard,
      width: width,
      footer: footer,
      maskClosable: maskClosable,
      contentWidget: contentWidget,
      titleWidget: titleWidget,
      fullscreen: fullscreen,
    );
  }

  /// 弹出 info 对话框（信息提示，带图标，仅一个确认按钮）
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '我知道了',
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    IconData? icon,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _show(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      barrierDismissible: barrierDismissible,
      onConfirm: onConfirm,
      statusIcon: icon != null
          ? Icon(icon, color: park.colors.info, size: 24)
          : Icon(Icons.info_outline, color: park.colors.info, size: 24),
      centered: centered,
      closable: closable,
      confirmLoading: confirmLoading,
      keyboard: keyboard,
      width: width,
      footer: footer,
      maskClosable: maskClosable,
      contentWidget: contentWidget,
      titleWidget: titleWidget,
      fullscreen: fullscreen,
    );
  }

  /// 弹出 success 对话框（成功提示，带图标）
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    IconData? icon,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _show(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      barrierDismissible: barrierDismissible,
      onConfirm: onConfirm,
      statusIcon: icon != null
          ? Icon(icon, color: park.colors.success, size: 24)
          : Icon(Icons.check_circle_outline,
              color: park.colors.success, size: 24),
      centered: centered,
      closable: closable,
      confirmLoading: confirmLoading,
      keyboard: keyboard,
      width: width,
      footer: footer,
      maskClosable: maskClosable,
      contentWidget: contentWidget,
      titleWidget: titleWidget,
      fullscreen: fullscreen,
    );
  }

  /// 弹出 warning 对话框（警告提示，带图标）
  static Future<void> warning(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    IconData? icon,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _show(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      barrierDismissible: barrierDismissible,
      onConfirm: onConfirm,
      statusIcon: icon != null
          ? Icon(icon, color: park.colors.warning, size: 24)
          : Icon(Icons.warning_amber_outlined,
              color: park.colors.warning, size: 24),
      centered: centered,
      closable: closable,
      confirmLoading: confirmLoading,
      keyboard: keyboard,
      width: width,
      footer: footer,
      maskClosable: maskClosable,
      contentWidget: contentWidget,
      titleWidget: titleWidget,
      fullscreen: fullscreen,
    );
  }

  /// 弹出 error 对话框（错误提示，带图标）
  static Future<void> error(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    IconData? icon,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _show(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      barrierDismissible: barrierDismissible,
      onConfirm: onConfirm,
      statusIcon: icon != null
          ? Icon(icon, color: park.colors.error, size: 24)
          : Icon(Icons.error_outline, color: park.colors.error, size: 24),
      centered: centered,
      closable: closable,
      confirmLoading: confirmLoading,
      keyboard: keyboard,
      width: width,
      footer: footer,
      maskClosable: maskClosable,
      contentWidget: contentWidget,
      titleWidget: titleWidget,
      fullscreen: fullscreen,
    );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '确定',
    String? cancelText,
    bool barrierDismissible = true,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? statusIcon,
    bool centered = false,
    bool closable = false,
    bool confirmLoading = false,
    bool keyboard = true,
    double? width,
    Widget? footer,
    bool maskClosable = true,
    Widget? contentWidget,
    Widget? titleWidget,
    bool fullscreen = false,
    List<Widget>? actions,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    bool dismissed = false;
    final completer = Completer<void>();

    void dismiss() {
      if (dismissed) return;
      dismissed = true;
      entry.remove();
      if (!completer.isCompleted) completer.complete();
    }

    entry = OverlayEntry(builder: (_) {
      return _ParkDialogOverlay(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        barrierDismissible: barrierDismissible,
        onConfirm: () {
          onConfirm?.call();
          dismiss();
        },
        onCancel: () {
          onCancel?.call();
          dismiss();
        },
        onDismiss: dismiss,
        statusIcon: statusIcon,
        centered: centered,
        closable: closable,
        confirmLoading: confirmLoading,
        keyboard: keyboard,
        width: width,
        footer: footer,
        maskClosable: maskClosable,
        contentWidget: contentWidget,
        titleWidget: titleWidget,
        fullscreen: fullscreen,
        actions: actions,
      );
    });

    overlay.insert(entry);
    return completer.future;
  }

  @override
  State<ParkDialog> createState() => _ParkDialogState();
}

class _ParkDialogState extends State<ParkDialog> {
  @override
  Widget build(BuildContext context) {
    return _ParkDialogOverlay(
      title: widget.title,
      content: widget.content,
      confirmText: widget.confirmText,
      cancelText: widget.cancelText,
      barrierDismissible: widget.barrierDismissible,
      onConfirm: widget.onConfirm,
      onCancel: widget.onCancel,
      onDismiss: () {},
      centered: widget.centered,
      closable: widget.closable,
      confirmLoading: widget.confirmLoading,
      keyboard: widget.keyboard,
      width: widget.width,
      footer: widget.footer,
      maskClosable: widget.maskClosable,
      contentWidget: widget.contentWidget,
      titleWidget: widget.titleWidget,
      fullscreen: widget.fullscreen,
      actions: widget.actions,
    );
  }
}

class _ParkDialogOverlay extends StatefulWidget {
  final String title;
  final String? content;
  final String confirmText;
  final String? cancelText;
  final bool barrierDismissible;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback onDismiss;
  final Widget? statusIcon;
  final bool centered;
  final bool closable;
  final bool confirmLoading;
  final bool keyboard;
  final double? width;
  final Widget? footer;
  final bool maskClosable;
  final Widget? contentWidget;
  final Widget? titleWidget;
  final bool fullscreen;
  final List<Widget>? actions;

  const _ParkDialogOverlay({
    required this.title,
    this.content,
    required this.confirmText,
    this.cancelText,
    required this.barrierDismissible,
    this.onConfirm,
    this.onCancel,
    required this.onDismiss,
    this.statusIcon,
    this.centered = false,
    this.closable = false,
    this.confirmLoading = false,
    this.keyboard = true,
    this.width,
    this.footer,
    this.maskClosable = true,
    this.contentWidget,
    this.titleWidget,
    this.fullscreen = false,
    this.actions,
  });

  @override
  State<_ParkDialogOverlay> createState() => _ParkDialogOverlayState();
}

class _ParkDialogOverlayState extends State<_ParkDialogOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  bool _isClosing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ParkMotion.standard,
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: ParkMotion.enterEasing);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    // Request focus for keyboard handling
    if (widget.keyboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  Future<void> _dismiss(VoidCallback? callback) async {
    if (_isClosing) return;
    _isClosing = true;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismiss();
    callback?.call();
  }

  Future<void> _handleBarrierTap() {
    if (!widget.maskClosable && !widget.barrierDismissible) {
      return Future<void>.value();
    }
    return _dismiss(widget.onCancel);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.keyboard) return KeyEventResult.ignored;
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _dismiss(widget.onCancel);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    Widget dialogContent = Material(
      color: Colors.transparent,
      child: Container(
        constraints: widget.fullscreen
            ? const BoxConstraints.expand()
            : (widget.width != null
                ? BoxConstraints(maxWidth: widget.width!, minWidth: widget.width!)
                : const BoxConstraints(maxWidth: 340, minWidth: 260)),
        padding: EdgeInsets.all(park.spacing.lg),
        decoration: BoxDecoration(
          color: park.colors.surface,
          borderRadius: widget.fullscreen ? BorderRadius.zero : park.radius.brLg,
          boxShadow: widget.fullscreen ? null : park.shadows.lg,
        ),
        child: Column(
          mainAxisSize: widget.fullscreen ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with optional close button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.statusIcon != null) ...[
                  widget.statusIcon!,
                  SizedBox(width: park.spacing.sm),
                ],
                Expanded(
                  child: widget.titleWidget ?? Text(
                    widget.title,
                    style: park.typography.body.copyWith(
                      fontSize: park.typography.sizeH3,
                      fontWeight: park.typography.weightBold,
                      color: park.colors.textPrimary,
                    ),
                  ),
                ),
                if (widget.closable)
                  GestureDetector(
                    onTap: () => _dismiss(widget.onCancel),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: park.colors.textSecondary,
                    ),
                  ),
              ],
            ),
            if (widget.contentWidget != null) ...[
              SizedBox(height: park.spacing.sm),
              widget.fullscreen
                  ? Expanded(child: widget.contentWidget!)
                  : widget.contentWidget!,
            ] else if (widget.content != null) ...[
              SizedBox(height: park.spacing.sm),
              Text(
                widget.content!,
                style: park.typography.body.copyWith(
                  fontSize: park.typography.sizeBody,
                  color: park.colors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: park.spacing.lg),
            // Footer: actions > footer > default buttons
            if (widget.actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (int i = 0; i < widget.actions!.length; i++) ...[
                    if (i > 0) SizedBox(width: park.spacing.sm),
                    widget.actions![i],
                  ],
                ],
              )
            else if (widget.footer != null)
              widget.footer!
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.cancelText != null) ...[
                    _ParkDialogButton(
                      label: widget.cancelText!,
                      isPrimary: false,
                      park: park,
                      onPressed: () => _dismiss(widget.onCancel),
                    ),
                    SizedBox(width: park.spacing.sm),
                  ],
                  _ParkDialogButton(
                    label: widget.confirmText,
                    isPrimary: true,
                    park: park,
                    loading: widget.confirmLoading,
                    onPressed: widget.confirmLoading
                        ? null
                        : () => _dismiss(widget.onConfirm),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: Stack(
            children: [
              // Barrier
              GestureDetector(
                onTap: _handleBarrierTap,
                child: Container(
                  color: park.colors.overlay
                      .withValues(alpha: _fadeAnim.value * 0.5),
                ),
              ),
              // Dialog
              widget.fullscreen
                  ? _buildAnimatedDialog(dialogContent)
                  : (widget.centered
                      ? Center(child: _buildAnimatedDialog(dialogContent))
                      : Align(
                          alignment: const Alignment(0, -0.3),
                          child: _buildAnimatedDialog(dialogContent),
                        )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDialog(Widget content) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: content,
      ),
    );
  }
}

class _ParkDialogButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final ParkThemeData park;
  final VoidCallback? onPressed;
  final bool loading;

  const _ParkDialogButton({
    required this.label,
    required this.isPrimary,
    required this.park,
    this.onPressed,
    this.loading = false,
  });

  @override
  State<_ParkDialogButton> createState() => _ParkDialogButtonState();
}

class _ParkDialogButtonState extends State<_ParkDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.loading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: disabled ? null : () => setState(() => _isPressed = false),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: ParkMotion.quick,
        curve: ParkMotion.defaultEasing,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.park.spacing.base,
            vertical: widget.park.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: disabled
                ? widget.park.colors.disabledBg
                : (widget.isPrimary
                    ? widget.park.colors.brand
                    : widget.park.colors.disabledBg),
            borderRadius: widget.park.radius.brSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.loading) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isPrimary
                          ? widget.park.colors.textOnBrand
                          : widget.park.colors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: widget.park.spacing.xs),
              ],
              Text(
                widget.label,
                style: widget.park.typography.body.copyWith(
                  fontSize: widget.park.typography.sizeBody,
                  fontWeight: widget.park.typography.weightMedium,
                  color: disabled
                      ? widget.park.colors.textSecondary
                      : (widget.isPrimary
                          ? widget.park.colors.textOnBrand
                          : widget.park.colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
