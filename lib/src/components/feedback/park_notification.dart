import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 通知提醒框组件
///
/// 从屏幕右上角弹出的全局通知提醒，支持自动关闭和手动关闭。
/// 功能类似 Ant Design NG 的 [NzNotificationService]。
///
/// ```dart
/// // 显示成功通知
/// ParkNotification.show(context,
///   type: ParkNotificationType.success,
///   title: '操作成功',
///   description: '数据已成功保存',
/// );
///
/// // 显示错误通知
/// ParkNotification.show(context,
///   type: ParkNotificationType.error,
///   title: '保存失败',
///   description: '网络异常，请稍后重试',
///   duration: Duration(seconds: 5),
/// );
/// ```
class ParkNotification {
  static OverlayEntry? _currentEntry;

  /// 显示全局通知。
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    ParkNotificationType type = ParkNotificationType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onClose,
    Widget? icon,
    bool closable = true,
  }) {
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotificationOverlay(
        title: title,
        description: description,
        type: type,
        duration: duration,
        onClose: () {
          entry.remove();
          _currentEntry = null;
          onClose?.call();
        },
        closable: closable,
        icon: icon,
        park: park,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// 隐藏当前通知。
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// 通知类型
enum ParkNotificationType { success, error, warning, info }

class _NotificationOverlay extends StatefulWidget {
  final String title;
  final String? description;
  final ParkNotificationType type;
  final Duration duration;
  final VoidCallback onClose;
  final bool closable;
  final Widget? icon;
  final ParkThemeData park;

  const _NotificationOverlay({
    required this.title,
    this.description,
    required this.type,
    required this.duration,
    required this.onClose,
    this.closable = true,
    this.icon,
    required this.park,
  });

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    if (widget.duration > Duration.zero) {
      Timer(widget.duration, () {
        if (mounted) _dismiss();
      });
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (Color? bg, Color? borderColor, Color iconColor, IconData defaultIcon) =
        _getTypeColors(widget.park);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.park.colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor ?? widget.park.colors.border, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.icon ?? Icon(defaultIcon, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: widget.park.colors.textPrimary)),
                        if (widget.description != null) ...[
                          const SizedBox(height: 4),
                          Text(widget.description!, style: TextStyle(fontSize: 13, color: widget.park.colors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  if (widget.closable)
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(Icons.close, size: 16, color: widget.park.colors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color?, Color?, Color, IconData) _getTypeColors(ParkThemeData park) {
    switch (widget.type) {
      case ParkNotificationType.success:
        return (null, park.colors.success, park.colors.success, Icons.check_circle_outline);
      case ParkNotificationType.error:
        return (null, park.colors.error, park.colors.error, Icons.error_outline);
      case ParkNotificationType.warning:
        return (null, park.colors.warning, park.colors.warning, Icons.warning_amber_outlined);
      case ParkNotificationType.info:
        return (null, park.colors.info, park.colors.info, Icons.info_outline);
    }
  }
}
