import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_button.dart';
import '../base/park_button_style.dart';

/// 气泡确认框组件
///
/// 在目标元素附近弹出确认对话框，用于需要用户二次确认的操作。
/// 基于 [ParkPopover] 和 [ParkButton] 组合实现。
///
/// ```dart
/// ParkPopconfirm(
///   title: '确认删除？',
///   description: '删除后将无法恢复，请确认操作。',
///   onConfirm: () => print('已确认'),
///   child: ParkButton(text: '删除'),
/// )
/// ```
class ParkPopconfirm extends StatefulWidget {
  /// 确认框标题。
  final String? title;

  /// 确认框描述文字。
  final String? description;

  /// 自定义标题 widget（优先于 [title]）。
  final Widget? titleWidget;

  /// 自定义描述 widget（优先于 [description]）。
  final Widget? descriptionWidget;

  /// 确认按钮文字（默认 '确定'）。
  final String confirmText;

  /// 取消按钮文字（默认 '取消'）。
  final String cancelText;

  /// 确认回调。
  final VoidCallback? onConfirm;

  /// 取消回调。
  final VoidCallback? onCancel;

  /// 确认后是否自动关闭（默认 true）。
  final bool autoCloseAfterConfirm;

  /// 提示图标（默认 null）。
  final IconData? icon;

  /// 触发元素。
  final Widget child;

  /// 是否为危险操作（确认按钮变红色）（默认 false）。
  final bool danger;

  /// 确认按钮 loading 状态。
  final bool confirmLoading;

  /// 创建 [ParkPopconfirm]。
  const ParkPopconfirm({
    super.key,
    this.title,
    this.description,
    this.titleWidget,
    this.descriptionWidget,
    this.confirmText = '',
    this.cancelText = '',
    this.onConfirm,
    this.onCancel,
    this.autoCloseAfterConfirm = true,
    this.icon,
    required this.child,
    this.danger = false,
    this.confirmLoading = false,
  });

  @override
  State<ParkPopconfirm> createState() => _ParkPopconfirmState();
}

class _ParkPopconfirmState extends State<ParkPopconfirm> {
  final _triggerKey = GlobalKey();
  final _bubbleKey = GlobalKey();
  bool _isVisible = false;
  OverlayEntry? _overlayEntry;
  double _bubbleTop = 0;
  double _bubbleLeft = 0;

  void _showPopconfirm() {
    if (_isVisible) return;
    _isVisible = true;

    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context);
    final childPosition = renderBox.localToGlobal(Offset.zero);
    final childSize = renderBox.size;
    final viewport = MediaQuery.of(context).size;

    // Default position: below the trigger, aligned left
    _bubbleTop = childPosition.dy + childSize.height + 8;
    _bubbleLeft = childPosition.dx;

    _overlayEntry = OverlayEntry(
      builder: (_) => _buildPopover(childPosition, childSize),
    );

    overlay.insert(_overlayEntry!);

    // Adjust position after first layout to prevent viewport overflow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) {
        _adjustBubbleBounds(childPosition, childSize, viewport);
      }
    });
  }

  /// Checks whether the bubble overflows the viewport and adjusts position.
  ///
  /// Uses [_bubbleKey] to measure the actual rendered size of the bubble,
  /// then flips vertically or clamps horizontally as needed.
  void _adjustBubbleBounds(
      Offset childPosition, Size childSize, Size viewport) {
    final bubbleBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (bubbleBox == null || !bubbleBox.hasSize) return;

    final bubbleSize = bubbleBox.size;
    bool needsRebuild = false;

    // Vertical: flip above trigger if overflowing bottom
    final defaultTop = childPosition.dy + childSize.height + 8;
    if (defaultTop + bubbleSize.height > viewport.height) {
      final flippedTop = childPosition.dy - 8 - bubbleSize.height;
      _bubbleTop = flippedTop >= 0 ? flippedTop : 4.0;
      needsRebuild = true;
    }

    // Horizontal: clamp to prevent right overflow
    if (_bubbleLeft + bubbleSize.width > viewport.width) {
      _bubbleLeft = viewport.width - bubbleSize.width - 8;
      needsRebuild = true;
    }
    // Prevent left overflow
    if (_bubbleLeft < 0) {
      _bubbleLeft = 4.0;
      needsRebuild = true;
    }

    if (needsRebuild) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _hidePopconfirm() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  void _handleConfirm() {
    if (widget.autoCloseAfterConfirm) _hidePopconfirm();
    widget.onConfirm?.call();
  }

  void _handleCancel() {
    _hidePopconfirm();
    widget.onCancel?.call();
  }

  Widget _buildPopover(Offset childPosition, Size childSize) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    final confirmLabel =
        widget.confirmText.isNotEmpty ? widget.confirmText : l10n.confirmText;
    final cancelLabel =
        widget.cancelText.isNotEmpty ? widget.cancelText : l10n.cancelText;

    return Stack(
      children: [
        // 遮罩层
        Positioned.fill(
          child: GestureDetector(
            onTap: _handleCancel,
            child: Container(color: Colors.transparent),
          ),
        ),
        // 气泡
        Positioned(
          top: _bubbleTop,
          left: _bubbleLeft,
          child: Material(
            key: _bubbleKey,
            color: Colors.transparent,
            child: Semantics(
              label: widget.title ?? '',
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: EdgeInsets.all(park.spacing.base),
                decoration: BoxDecoration(
                  color: park.colors.surface,
                  borderRadius: BorderRadius.circular(park.radius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: park.colors.overlay.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题区域
                    if (widget.titleWidget != null || widget.title != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: park.spacing.sm),
                        child: widget.titleWidget ??
                            Row(
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon,
                                      size: 18,
                                      color: widget.danger
                                          ? park.colors.error
                                          : park.colors.brand),
                                  park.spacing.hSm,
                                ],
                                Expanded(
                                  child: Text(
                                    widget.title!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: park.colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    // 描述区域
                    if (widget.descriptionWidget != null ||
                        widget.description != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: park.spacing.base),
                        child: widget.descriptionWidget ??
                            Text(
                              widget.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: park.colors.textSecondary,
                              ),
                            ),
                      ),
                    // 按钮区域
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Semantics(
                          label: cancelLabel,
                          button: true,
                          child: ParkButton(
                            child: Text(cancelLabel),
                            variant: ParkButtonVariant.secondary,
                            size: ParkButtonSize.small,
                            onPressed: _handleCancel,
                          ),
                        ),
                        SizedBox(width: park.spacing.sm),
                        Semantics(
                          label: confirmLabel,
                          button: true,
                          child: ParkButton(
                            child: Text(confirmLabel),
                            variant: widget.danger
                                ? ParkButtonVariant.danger
                                : ParkButtonVariant.primary,
                            size: ParkButtonSize.small,
                            loading: widget.confirmLoading,
                            onPressed: _handleConfirm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry!.remove();
    }
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _triggerKey,
      onTap: _showPopconfirm,
      child: widget.child,
    );
  }
}
