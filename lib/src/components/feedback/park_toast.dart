import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';

/// Toast 弹出位置
enum ParkToastPosition { top, center, bottom }

/// ParkToastConfig — global configuration for ParkToast behaviour.
class ParkToastConfig {
  /// Maximum number of toasts visible at the same time.
  /// When exceeded the oldest toast is dismissed.
  final int maxCount;

  const ParkToastConfig({this.maxCount = 1});
}

/// ParkToast — 轻量提示组件，自动消失。
class ParkToast extends StatelessWidget {
  final String message;
  final Widget? icon;
  final Color? bgColor;
  final ParkToastPosition position;

  /// Callback fired after toast close animation completes.
  final VoidCallback? afterClose;

  /// When true, toast overlay is destroyed when hidden (saves memory).
  final bool destroyOnHide;

  const ParkToast({
    super.key,
    required this.message,
    this.icon,
    this.bgColor,
    this.position = ParkToastPosition.center,
    this.afterClose,
    this.destroyOnHide = false,
  });

  // ---- Global state ----
  static ParkToastConfig _config = const ParkToastConfig();

  /// Active toasts keyed by their user-supplied key (or auto-generated id).
  static final Map<String, _ParkToastOverlayController> _activeToasts = {};
  static int _autoId = 0;

  /// Legacy single-controller reference — kept so that old code that relied
  /// on "showing a new toast dismisses the previous one" still works when
  /// maxCount == 1 and no explicit key is given.
  static _ParkToastOverlayController? _currentController;

  /// Update global toast configuration.
  static void config({int? maxCount}) {
    _config = ParkToastConfig(
      maxCount: maxCount ?? _config.maxCount,
    );
  }

  /// Reset configuration to defaults (useful in tests).
  static void resetConfig() {
    _config = const ParkToastConfig();
  }

  /// 显示普通 Toast
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    ParkToastPosition position = ParkToastPosition.center,
    Color? bgColor,
    String? key,
    VoidCallback? onClick,
    bool pauseOnHover = false,
    Widget? contentWidget,
    VoidCallback? onClose,
  }) {
    _showToast(
      context,
      message: message,
      duration: duration,
      position: position,
      bgColor: bgColor,
      toastKey: key,
      onClick: onClick,
      pauseOnHover: pauseOnHover,
      contentWidget: contentWidget,
      onClose: onClose,
    );
  }

  /// 成功 Toast
  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    ParkToastPosition position = ParkToastPosition.center,
    String? key,
    VoidCallback? onClick,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _showToast(context,
        message: message,
        icon: Icon(Icons.check_circle_rounded,
            color: park.colors.success, size: 20),
        duration: duration,
        position: position,
        toastKey: key,
        onClick: onClick,
        pauseOnHover: pauseOnHover);
  }

  /// 错误 Toast
  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    ParkToastPosition position = ParkToastPosition.center,
    String? key,
    VoidCallback? onClick,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _showToast(context,
        message: message,
        icon:
            Icon(Icons.error_rounded, color: park.colors.error, size: 20),
        duration: duration,
        position: position,
        toastKey: key,
        onClick: onClick,
        pauseOnHover: pauseOnHover);
  }

  /// 警告 Toast
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    ParkToastPosition position = ParkToastPosition.center,
    String? key,
    VoidCallback? onClick,
    bool pauseOnHover = false,
    VoidCallback? onClose,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _showToast(context,
        message: message,
        icon: Icon(Icons.warning_rounded,
            color: park.colors.warning, size: 20),
        duration: duration,
        position: position,
        toastKey: key,
        onClick: onClick,
        pauseOnHover: pauseOnHover,
        onClose: onClose);
  }

  /// 加载中 Toast — shows a loading spinner with message.
  /// Returns a dismiss function to manually close it.
  static VoidCallback loading(
    BuildContext context,
    String message, {
    ParkToastPosition position = ParkToastPosition.center,
    String? key,
  }) {
    final effectiveKey = key ?? '_loading_auto';
    _showToast(
      context,
      message: message,
      duration: const Duration(hours: 1),
      position: position,
      toastKey: effectiveKey,
      isloading: true,
    );
    return () {
      _activeToasts[effectiveKey]?.dismiss();
      _activeToasts.remove(effectiveKey);
    };
  }

  static void _showToast(
    BuildContext context, {
    required String message,
    Widget? icon,
    Duration duration = const Duration(seconds: 2),
    ParkToastPosition position = ParkToastPosition.center,
    Color? bgColor,
    String? toastKey,
    VoidCallback? onClick,
    bool pauseOnHover = false,
    Widget? contentWidget,
    VoidCallback? onClose,
    bool isloading = false,
  }) {
    // If a toast with the same key exists, dismiss it first (update pattern).
    if (toastKey != null && _activeToasts.containsKey(toastKey)) {
      _activeToasts[toastKey]?.dismiss();
      _activeToasts.remove(toastKey);
    }

    // Enforce maxCount: dismiss oldest toasts when limit reached.
    while (_activeToasts.length >= _config.maxCount) {
      final oldestKey = _activeToasts.keys.first;
      _activeToasts[oldestKey]?.dismiss();
      _activeToasts.remove(oldestKey);
    }

    // Legacy: when maxCount == 1 and no key, dismiss previous single toast.
    if (_config.maxCount <= 1 && toastKey == null) {
      _currentController?.dismiss();
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    bool removed = false;
    late final _ParkToastOverlayController controller;

    final effectiveKey = toastKey ?? '_auto_${_autoId++}';

    void remove() {
      if (removed) return;
      removed = true;
      _activeToasts.remove(effectiveKey);
      if (identical(_currentController, controller)) {
        _currentController = null;
      }
      entry.remove();
      onClose?.call();
    }

    controller = _ParkToastOverlayController(dismiss: remove);
    _activeToasts[effectiveKey] = controller;

    // Keep legacy reference for backward compat.
    if (_config.maxCount <= 1 && toastKey == null) {
      _currentController = controller;
    }

    entry = OverlayEntry(builder: (_) {
      return _ParkToastOverlay(
        message: message,
        icon: icon,
        bgColor: bgColor,
        position: position,
        duration: duration,
        onDismiss: remove,
        onClick: onClick,
        pauseOnHover: pauseOnHover,
        contentWidget: contentWidget,
        isloading: isloading,
      );
    });

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _buildPill(park);
  }

  Widget _buildPill(ParkThemeData park) {
    final bg = bgColor ?? park.colors.overlay;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: park.spacing.base,
        vertical: park.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: park.radius.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: park.spacing.xs)],
          Flexible(
            child: Text(
              message,
              style: park.typography.body.copyWith(
                fontSize: park.typography.sizeBody,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkToastOverlayController {
  final VoidCallback dismiss;

  _ParkToastOverlayController({required this.dismiss});
}

class _ParkToastOverlay extends StatefulWidget {
  final String message;
  final Widget? icon;
  final Color? bgColor;
  final ParkToastPosition position;
  final Duration duration;
  final VoidCallback onDismiss;
  final VoidCallback? onClick;
  final bool pauseOnHover;
  final Widget? contentWidget;
  final bool isloading;

  const _ParkToastOverlay({
    required this.message,
    this.icon,
    this.bgColor,
    required this.position,
    required this.duration,
    required this.onDismiss,
    this.onClick,
    this.pauseOnHover = false,
    this.contentWidget,
    this.isloading = false,
  });

  @override
  State<_ParkToastOverlay> createState() => _ParkToastOverlayState();
}

class _ParkToastOverlayState extends State<_ParkToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  bool _isClosing = false;
  Timer? _dismissTimer;
  bool _isHovered = false;
  Duration _remainingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ParkMotion.defaults.standard,
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: ParkMotion.defaults.enterEasing);
    _controller.forward();

    _remainingDuration = widget.duration > const Duration(milliseconds: 300)
        ? widget.duration - const Duration(milliseconds: 300)
        : Duration.zero;

    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    final startTime = DateTime.now();
    _dismissTimer = Timer(_remainingDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
    // Store start time for pause calculation
    _timerStartTime = startTime;
  }

  DateTime? _timerStartTime;

  void _pauseTimer() {
    if (_dismissTimer != null && _timerStartTime != null) {
      _dismissTimer!.cancel();
      final elapsed = DateTime.now().difference(_timerStartTime!);
      _remainingDuration = _remainingDuration - elapsed;
      if (_remainingDuration < Duration.zero) {
        _remainingDuration = Duration.zero;
      }
    }
  }

  void _resumeTimer() {
    _startDismissTimer();
  }

  Future<void> _dismiss() async {
    if (_isClosing) return;
    _isClosing = true;
    _dismissTimer?.cancel();
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  AlignmentGeometry _alignment() {
    switch (widget.position) {
      case ParkToastPosition.top:
        return Alignment.topCenter;
      case ParkToastPosition.center:
        return Alignment.center;
      case ParkToastPosition.bottom:
        return Alignment.bottomCenter;
    }
  }

  EdgeInsets _padding(ParkThemeData park) {
    switch (widget.position) {
      case ParkToastPosition.top:
        return EdgeInsets.only(top: park.spacing.lg * 3);
      case ParkToastPosition.center:
        return EdgeInsets.zero;
      case ParkToastPosition.bottom:
        return EdgeInsets.only(bottom: park.spacing.lg * 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final bg = widget.bgColor ?? park.colors.overlay;

    Widget toastWidget = FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        alignment: _alignment(),
        padding: _padding(park),
        child: GestureDetector(
          onTap: widget.onClick,
          child: MouseRegion(
            onEnter: (_) {
              if (widget.pauseOnHover && !_isHovered) {
                _isHovered = true;
                _pauseTimer();
              }
            },
            onExit: (_) {
              if (widget.pauseOnHover && _isHovered) {
                _isHovered = false;
                _resumeTimer();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.base,
                vertical: park.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: park.radius.brFull,
              ),
              child: widget.contentWidget != null
                  ? widget.contentWidget!
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isloading) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: park.spacing.xs),
                        ],
                        if (widget.icon != null) ...[
                          widget.icon!,
                          SizedBox(width: park.spacing.xs),
                        ],
                        Flexible(
                          child: Text(
                            widget.message,
                            style: park.typography.body.copyWith(
                              fontSize: park.typography.sizeBody,
                              color: Colors.white,
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

    // When there's an onClick, we need pointer events; otherwise use IgnorePointer
    if (widget.onClick == null && !widget.pauseOnHover && !widget.isloading) {
      return IgnorePointer(child: toastWidget);
    }
    return toastWidget;
  }
}
