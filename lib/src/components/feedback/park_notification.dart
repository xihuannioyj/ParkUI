import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 通知提醒框组件
///
/// 从屏幕右上角弹出的全局通知提醒，支持自动关闭和手动关闭。
/// 支持多实例队列模式，最多同时显示 [_maxCount] 个通知。
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
  static final Map<String, _NotificationController> _activeNotifications = {};
  static int _autoId = 0;

  /// Maximum number of notifications visible at the same time.
  static const int _maxCount = 5;

  /// 通知框宽度（设计常量，置于根级便于统一调整）。
  static const double _kNotificationWidth = 360.0;

  /// 每个通知占据的垂直空间（用于堆叠偏移计算）。
  static const double _kNotificationSlot = 100.0;

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
    // Enforce maxCount: dismiss oldest notifications when limit reached.
    while (_activeNotifications.length >= _maxCount) {
      final oldestKey = _activeNotifications.keys.first;
      _activeNotifications[oldestKey]?.dismiss();
      _activeNotifications.remove(oldestKey);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context, rootOverlay: true);
      final park =
          Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

      late final OverlayEntry entry;
      bool removed = false;
      final String effectiveKey = '_auto_${_autoId++}';
      final GlobalKey<_NotificationOverlayState> overlayStateKey =
          GlobalKey<_NotificationOverlayState>();
      late final _NotificationController controller;

      final double topOffset =
          _activeNotifications.length * _kNotificationSlot;

      void remove() {
        if (removed) return;
        removed = true;
        _activeNotifications.remove(effectiveKey);
        onClose?.call();
        entry.remove();
      }

      controller = _NotificationController(
        dismiss: () {
          final _NotificationOverlayState? state =
              overlayStateKey.currentState;
          if (state == null) {
            remove();
            return;
          }
          state.close();
        },
      );
      _activeNotifications[effectiveKey] = controller;

      entry = OverlayEntry(
        builder: (_) => _NotificationOverlay(
          key: overlayStateKey,
          title: title,
          description: description,
          type: type,
          duration: duration,
          onClose: remove,
          closable: closable,
          icon: icon,
          park: park,
          topOffset: topOffset,
        ),
      );

      overlay.insert(entry);
    });
  }

  /// 隐藏所有通知（通过退出动画）。
  static void hide() {
    for (final controller in _activeNotifications.values.toList()) {
      controller.dismiss();
    }
  }
}

/// 通知类型
enum ParkNotificationType { success, error, warning, info }

class _NotificationController {
  final VoidCallback dismiss;

  _NotificationController({required this.dismiss});
}

class _NotificationOverlay extends StatefulWidget {
  final String title;
  final String? description;
  final ParkNotificationType type;
  final Duration duration;
  final VoidCallback onClose;
  final bool closable;
  final Widget? icon;
  final ParkThemeData park;
  final double topOffset;

  const _NotificationOverlay({
    super.key,
    required this.title,
    this.description,
    required this.type,
    required this.duration,
    required this.onClose,
    this.closable = true,
    this.icon,
    required this.park,
    this.topOffset = 0.0,
  });

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.park.motion.standard,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.park.motion.enterEasing,
    ));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    if (widget.duration > Duration.zero) {
      _timer = Timer(widget.duration, () {
        if (mounted) close();
      });
    }
  }

  /// Public close method: cancel timer, run exit animation, then notify.
  void close() {
    _timer?.cancel();
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onClose();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  (Color, IconData) _getTypeStyle(ParkThemeData park) {
    switch (widget.type) {
      case ParkNotificationType.success:
        return (park.colors.success, Icons.check_circle_outline);
      case ParkNotificationType.error:
        return (park.colors.error, Icons.error_outline);
      case ParkNotificationType.warning:
        return (park.colors.warning, Icons.warning_amber_outlined);
      case ParkNotificationType.info:
        return (park.colors.info, Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (Color accent, IconData defaultIcon) = _getTypeStyle(widget.park);
    final ParkThemeData park = widget.park;

    return Positioned(
      top: MediaQuery.of(context).padding.top +
          park.spacing.base +
          widget.topOffset,
      right: park.spacing.base,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Semantics(
            liveRegion: true,
            label: widget.title,
            hint: widget.description,
            child: Container(
              width: ParkNotification._kNotificationWidth,
              padding: EdgeInsets.all(park.spacing.base),
              decoration: BoxDecoration(
                color: park.colors.surface,
                borderRadius: park.radius.brMd,
                border: Border.all(color: accent, width: 1),
                boxShadow: park.shadows.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.icon ??
                      Icon(defaultIcon,
                          size: park.spacing.lg, color: accent),
                  SizedBox(width: park.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: park.typography.sizeBodySmall,
                            fontWeight: park.typography.weightBold,
                            color: park.colors.textPrimary,
                            // Overlay 无 Material → fallback style 黄色下划线，
                            // 必须显式清除。
                            decoration: TextDecoration.none,
                          ),
                        ),
                        if (widget.description != null) ...[
                          SizedBox(height: park.spacing.xs),
                          Text(
                            widget.description!,
                            style: TextStyle(
                              fontSize: park.typography.sizeCaption,
                              color: park.colors.textSecondary,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.closable)
                    Semantics(
                      button: true,
                      label: ParkLocalizations.of(context).closeText,
                      child: GestureDetector(
                        onTap: close,
                        child: Icon(
                          Icons.close,
                          size: park.spacing.base,
                          color: park.colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
