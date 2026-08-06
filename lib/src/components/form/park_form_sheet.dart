import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 表单弹层：底部 Sheet 包裹任意表单内容 + 确认/取消按钮。
///
/// 适用于"弹层包裹带校验 Form + bloc 绑定 + 自定义 actions"模式，
/// 提供统一的高层组合组件入口。
///
/// ```dart
/// final result = await ParkFormSheet.show(
///   context: context,
///   title: '编辑信息',
///   builder: (ctx) => ParkForm(
///     showDefaultActions: false,
///     children: [ /* ... */ ],
///   ),
///   onConfirm: () async {
///     // 校验 + 提交逻辑
///     return true; // true 关闭弹层，false 保持打开
///   },
/// );
/// ```
class ParkFormSheet {
  ParkFormSheet._();

  /// 打开表单弹层。
  ///
  /// [builder] 构建表单内容（通常是 ParkForm 或自定义表单）。
  /// [onConfirm] 点击确认时回调，返回 true 关闭弹层，返回 false 保持打开。
  /// [extraActions] 额外操作按钮，显示在取消和确认按钮之间。
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
    String? confirmText,
    String? cancelText,
    Future<bool> Function()? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool isScrollControlled = true,
    double? maxHeight,
    List<Widget>? extraActions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: barrierDismissible,
      enableDrag: barrierDismissible,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _ParkFormSheetContent<T>(
          title: title,
          builder: builder,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          maxHeight: maxHeight,
          extraActions: extraActions,
        );
      },
    );
  }
}

/// 内部：表单弹层内容组件。
class _ParkFormSheetContent<T> extends StatefulWidget {
  final String title;
  final WidgetBuilder builder;
  final String? confirmText;
  final String? cancelText;
  final Future<bool> Function()? onConfirm;
  final VoidCallback? onCancel;
  final double? maxHeight;
  final List<Widget>? extraActions;

  const _ParkFormSheetContent({
    required this.title,
    required this.builder,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.maxHeight,
    this.extraActions,
  });

  @override
  State<_ParkFormSheetContent<T>> createState() =>
      _ParkFormSheetContentState<T>();
}

class _ParkFormSheetContentState<T> extends State<_ParkFormSheetContent<T>> {
  bool _confirming = false;

  Future<void> _handleConfirm() async {
    if (_confirming) return;

    final onConfirm = widget.onConfirm;
    if (onConfirm == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _confirming = true);
    try {
      final shouldClose = await onConfirm();
      if (!mounted) return;
      if (shouldClose) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _confirming = false);
      }
    }
  }

  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;
    final radius = park.radius;
    final l10n = ParkLocalizations.of(context);

    final effectiveConfirmText = widget.confirmText ?? l10n.confirmText;
    final effectiveCancelText = widget.cancelText ?? l10n.cancelText;

    Widget content = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(radius.lg)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: spacing.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title bar: title + close button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.base,
                vertical: spacing.md,
              ),
              child: Row(
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: typo.sizeH3,
                        fontWeight: typo.weightMedium,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),

                  // Close button
                  Semantics(
                    label: l10n.closeText,
                    button: true,
                    child: GestureDetector(
                      onTap: _handleCancel,
                      child: Padding(
                        padding: EdgeInsets.all(spacing.xs),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, color: colors.divider),

            // Form content area
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(spacing.base),
                child: widget.builder(context),
              ),
            ),

            // Bottom button area
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.base,
                spacing.md,
                spacing.base,
                spacing.base,
              ),
              child: Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: _ParkFormSheetButton(
                      label: effectiveCancelText,
                      backgroundColor: colors.surface,
                      foregroundColor: colors.textPrimary,
                      borderColor: colors.border,
                      borderRadius: radius.md,
                      loading: false,
                      onPressed: _handleCancel,
                    ),
                  ),

                  // Extra actions
                  if (widget.extraActions != null)
                    ...widget.extraActions!.map(
                      (action) => Padding(
                        padding: EdgeInsets.only(left: spacing.sm),
                        child: action,
                      ),
                    ),

                  SizedBox(width: spacing.sm),

                  // Confirm button
                  Expanded(
                    child: _ParkFormSheetButton(
                      label: effectiveConfirmText,
                      backgroundColor: colors.brand,
                      foregroundColor: colors.textOnBrand,
                      borderColor: null,
                      borderRadius: radius.md,
                      loading: _confirming,
                      onPressed: _handleConfirm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Apply maxHeight constraint
    if (widget.maxHeight != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight!),
        child: content,
      );
    }

    return content;
  }
}

/// 内部：表单弹层按钮。
class _ParkFormSheetButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool loading;
  final VoidCallback onPressed;

  const _ParkFormSheetButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.borderRadius,
    this.loading = false,
    required this.onPressed,
  });

  @override
  State<_ParkFormSheetButton> createState() => _ParkFormSheetButtonState();
}

class _ParkFormSheetButtonState extends State<_ParkFormSheetButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final typo = park.typography;
    final bool canPress = !widget.loading;
    final scale = _isPressed ? 0.97 : 1.0;
    final opacity = canPress ? (_isPressed ? 0.85 : 1.0) : 0.5;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 150),
        child: Semantics(
          button: true,
          enabled: canPress,
          label: widget.label,
          child: GestureDetector(
            onTapDown:
                canPress ? (_) => setState(() => _isPressed = true) : null,
            onTapUp:
                canPress ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel:
                canPress ? () => setState(() => _isPressed = false) : null,
            onTap: canPress ? widget.onPressed : null,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: widget.borderColor != null
                    ? Border.all(color: widget.borderColor!, width: 1.0)
                    : null,
              ),
              alignment: Alignment.center,
              child: widget.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          widget.foregroundColor,
                        ),
                      ),
                    )
                  : Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.foregroundColor,
                        fontSize: typo.sizeBody,
                        fontWeight: typo.weightMedium,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
