import 'package:flutter/material.dart';
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
    this.confirmText = '确定',
    this.cancelText = '取消',
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
  final _overlayKey = GlobalKey();
  bool _isVisible = false;
  OverlayEntry? _overlayEntry;

  void _showPopconfirm() {
    if (_isVisible) return;
    _isVisible = true;

    final renderBox = _overlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final overlay = Overlay.of(context);
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => _buildPopover(position, size),
    );

    overlay.insert(_overlayEntry!);
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

  Widget _buildPopover(Offset position, Size childSize) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

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
          top: position.dy + childSize.height + 8,
          left: position.dx,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: park.colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
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
                      padding: const EdgeInsets.only(bottom: 8),
                      child: widget.titleWidget ??
                          Row(
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon,
                                    size: 18,
                                    color: widget.danger
                                        ? park.colors.error
                                        : park.colors.brand),
                                const SizedBox(width: 8),
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
                  if (widget.descriptionWidget != null || widget.description != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
                      ParkButton(
                        child: Text(widget.cancelText),
                        variant: ParkButtonVariant.secondary,
                        size: ParkButtonSize.small,
                        onPressed: _handleCancel,
                      ),
                      const SizedBox(width: 8),
                      ParkButton(
                        child: Text(widget.confirmText),
                        variant: widget.danger
                            ? ParkButtonVariant.danger
                            : ParkButtonVariant.primary,
                        size: ParkButtonSize.small,
                        loading: widget.confirmLoading,
                        onPressed: _handleConfirm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _overlayKey,
      onTap: _showPopconfirm,
      child: widget.child,
    );
  }
}
