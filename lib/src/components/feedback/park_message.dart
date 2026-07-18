import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 消息弹出位置
enum ParkMessagePosition { top, bottom }

/// ParkMessageConfig — global configuration for ParkMessage behaviour.
class ParkMessageConfig {
  /// Maximum number of messages visible at the same time.
  /// When exceeded the oldest message is dismissed.
  final int maxCount;

  const ParkMessageConfig({this.maxCount = 1});
}

/// ParkMessage — 全局消息提示，从顶部/底部滑入，自动消失。
class ParkMessage extends StatefulWidget {
  final String title;
  final String? content;
  final Duration duration;
  final bool closable;
  final ParkMessagePosition position;
  final Widget? icon;
  final Color? accentColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  // --- New params ---
  /// Callback when message is tapped (alias / additional to [onTap]).
  final VoidCallback? onClick;

  /// Callback when message is dismissed (after animation completes).
  final VoidCallback? onClose;

  /// When true, hovering over the message pauses its auto-dismiss timer.
  final bool pauseOnHover;

  const ParkMessage({
    super.key,
    required this.title,
    this.content,
    this.duration = const Duration(seconds: 3),
    this.closable = false,
    this.position = ParkMessagePosition.top,
    this.icon,
    this.accentColor,
    this.backgroundColor,
    this.onTap,
    this.onClick,
    this.onClose,
    this.pauseOnHover = false,
  });

  // ---- Global state ----
  static ParkMessageConfig _config = const ParkMessageConfig();

  /// Active messages keyed by their user-supplied key (or auto-generated id).
  static final Map<String, _ParkMessageOverlayController> _activeMessages = {};
  static int _autoId = 0;

  /// Legacy single-controller reference.
  static _ParkMessageOverlayController? _currentController;

  /// Pending controller for same-frame replacement.
  /// When two messages are shown in the same frame, the first is still
  /// pending (postFrameCallback hasn't fired yet). Track it so the second
  /// can dismiss it.
  static _ParkMessageOverlayController? _pendingController;

  /// Update global message configuration.
  static void config({int? maxCount}) {
    _config = ParkMessageConfig(
      maxCount: maxCount ?? _config.maxCount,
    );
  }

  /// Reset configuration to defaults (useful in tests).
  static void resetConfig() {
    _config = const ParkMessageConfig();
  }

  /// info 消息
  static void info(
    BuildContext context,
    String title, {
    String? content,
    Duration duration = const Duration(seconds: 3),
    bool closable = false,
    ParkMessagePosition position = ParkMessagePosition.top,
    VoidCallback? onTap,
    String? key,
    VoidCallback? onClick,
    VoidCallback? onClose,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _show(
      context,
      title: title,
      content: content,
      duration: duration,
      closable: closable,
      position: position,
      onTap: onTap,
      icon: Icon(Icons.info_outline, color: park.colors.info, size: 20),
      accentColor: park.colors.info,
      backgroundColor: park.colors.infoLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
    );
  }

  /// success 消息
  static void success(
    BuildContext context,
    String title, {
    String? content,
    Duration duration = const Duration(seconds: 3),
    bool closable = false,
    ParkMessagePosition position = ParkMessagePosition.top,
    VoidCallback? onTap,
    String? key,
    VoidCallback? onClick,
    VoidCallback? onClose,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _show(
      context,
      title: title,
      content: content,
      duration: duration,
      closable: closable,
      position: position,
      onTap: onTap,
      icon: Icon(
        Icons.check_circle_outline,
        color: park.colors.success,
        size: 20,
      ),
      accentColor: park.colors.success,
      backgroundColor: park.colors.successLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
    );
  }

  /// warning 消息
  static void warning(
    BuildContext context,
    String title, {
    String? content,
    Duration duration = const Duration(seconds: 3),
    bool closable = false,
    ParkMessagePosition position = ParkMessagePosition.top,
    VoidCallback? onTap,
    String? key,
    VoidCallback? onClick,
    VoidCallback? onClose,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _show(
      context,
      title: title,
      content: content,
      duration: duration,
      closable: closable,
      position: position,
      onTap: onTap,
      icon: Icon(
        Icons.warning_amber_outlined,
        color: park.colors.warning,
        size: 20,
      ),
      accentColor: park.colors.warning,
      backgroundColor: park.colors.warningLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
    );
  }

  /// error 消息
  static void error(
    BuildContext context,
    String title, {
    String? content,
    Duration duration = const Duration(seconds: 3),
    bool closable = false,
    ParkMessagePosition position = ParkMessagePosition.top,
    VoidCallback? onTap,
    String? key,
    VoidCallback? onClick,
    VoidCallback? onClose,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _show(
      context,
      title: title,
      content: content,
      duration: duration,
      closable: closable,
      position: position,
      onTap: onTap,
      icon: Icon(Icons.error_outline, color: park.colors.error, size: 20),
      accentColor: park.colors.error,
      backgroundColor: park.colors.errorLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
    );
  }

  /// loading 消息 — shows a spinning indicator.
  static void loading(
    BuildContext context,
    String title, {
    String? content,
    Duration duration = const Duration(seconds: 3),
    bool closable = false,
    ParkMessagePosition position = ParkMessagePosition.top,
    VoidCallback? onTap,
    String? key,
    VoidCallback? onClick,
    VoidCallback? onClose,
    bool pauseOnHover = false,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    _show(
      context,
      title: title,
      content: content,
      duration: duration,
      closable: closable,
      position: position,
      onTap: onTap,
      icon: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor:
              AlwaysStoppedAnimation<Color>(park.colors.textSecondary),
        ),
      ),
      accentColor: park.colors.info,
      backgroundColor: park.colors.infoLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
    );
  }

  static void _show(
    BuildContext context, {
    required String title,
    String? content,
    Duration duration = const Duration(seconds: 3),
    bool closable = false,
    ParkMessagePosition position = ParkMessagePosition.top,
    VoidCallback? onTap,
    Widget? icon,
    Color? accentColor,
    Color? backgroundColor,
    String? messageKey,
    VoidCallback? onClick,
    VoidCallback? onClose,
    bool pauseOnHover = false,
  }) {
    // If a message with the same key exists, dismiss it first (update pattern).
    if (messageKey != null && _activeMessages.containsKey(messageKey)) {
      _activeMessages[messageKey]?.dismiss();
      _activeMessages.remove(messageKey);
    }

    // Enforce maxCount: dismiss oldest messages when limit reached.
    while (_activeMessages.length >= _config.maxCount) {
      final oldestKey = _activeMessages.keys.first;
      _activeMessages[oldestKey]?.dismiss();
      _activeMessages.remove(oldestKey);
    }

    // Legacy: when maxCount == 1 and no key, dismiss previous single message.
    if (_config.maxCount <= 1 && messageKey == null) {
      _currentController?.dismiss();
      // Also dismiss a pending message from the same frame (not yet inserted).
      _pendingController?.dismiss();
    }

    // Create controller synchronously so it can be tracked for same-frame replacement.
    final effectiveKey = messageKey ?? '_auto_${_autoId++}';
    bool removed = false;
    OverlayEntry? entry;
    final GlobalKey<_ParkMessageOverlayState> overlayStateKey =
        GlobalKey<_ParkMessageOverlayState>();
    late final _ParkMessageOverlayController controller;

    void remove() {
      if (removed) return;
      removed = true;
      _activeMessages.remove(effectiveKey);
      if (identical(_currentController, controller)) {
        _currentController = null;
      }
      if (identical(_pendingController, controller)) {
        _pendingController = null;
      }
      onClose?.call();
      entry?.remove();
    }

    controller = _ParkMessageOverlayController(
      dismiss: () {
        final _ParkMessageOverlayState? state = overlayStateKey.currentState;
        if (state == null) {
          remove();
          return;
        }
        state.close();
      },
    );
    _activeMessages[effectiveKey] = controller;

    // Legacy reference.
    if (_config.maxCount <= 1 && messageKey == null) {
      _currentController = controller;
    }
    // Track as pending until overlay is actually inserted.
    _pendingController = controller;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.of(context, rootOverlay: true);

      if (removed) return; // Already dismissed before frame fired.

      entry = OverlayEntry(
        builder: (_) {
          return _ParkMessageOverlay(
            key: overlayStateKey,
            title: title,
            content: content,
            duration: duration,
            closable: closable,
            position: position,
            onTap: onTap,
            icon: icon,
            accentColor: accentColor,
            backgroundColor: backgroundColor,
            onDismiss: remove,
            onClick: onClick,
            pauseOnHover: pauseOnHover,
          );
        },
      );

      overlay.insert(entry!);
      // Overlay is now inserted; clear pending reference.
      if (identical(_pendingController, controller)) {
        _pendingController = null;
      }
    });
  }

  @override
  State<ParkMessage> createState() => _ParkMessageState();
}

class _ParkMessageOverlayController {
  final VoidCallback dismiss;

  _ParkMessageOverlayController({required this.dismiss});
}

class _ParkMessageState extends State<ParkMessage> {
  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _buildBar(park);
  }

  Widget _buildBar(ParkThemeData park) {
    final l10n = ParkLocalizations.of(context);
    final bg = widget.backgroundColor ?? park.colors.infoLight;
    return Semantics(
      liveRegion: true,
      label: widget.title,
      hint: widget.content,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onTap?.call();
          widget.onClick?.call();
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: park.spacing.base,
            vertical: park.spacing.md,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: park.radius.brMd,
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                SizedBox(width: park.spacing.sm),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: park.typography.body.copyWith(
                        fontSize: park.typography.sizeBody,
                        fontWeight: park.typography.weightMedium,
                        color: park.colors.textPrimary,
                      ),
                    ),
                    if (widget.content != null) ...[
                      SizedBox(height: park.spacing.xs),
                      Text(
                        widget.content!,
                        style: park.typography.body.copyWith(
                          fontSize: park.typography.sizeBodySmall,
                          color: park.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.closable)
                Semantics(
                  button: true,
                  label: l10n.closeText,
                  child: Icon(Icons.close, size: 18, color: park.colors.textSecondary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParkMessageOverlay extends StatefulWidget {
  final String title;
  final String? content;
  final Duration duration;
  final bool closable;
  final ParkMessagePosition position;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? accentColor;
  final Color? backgroundColor;
  final VoidCallback onDismiss;
  final VoidCallback? onClick;
  final bool pauseOnHover;

  const _ParkMessageOverlay({
    super.key,
    required this.title,
    this.content,
    required this.duration,
    required this.closable,
    required this.position,
    this.onTap,
    this.icon,
    this.accentColor,
    this.backgroundColor,
    required this.onDismiss,
    this.onClick,
    this.pauseOnHover = false,
  });

  @override
  State<_ParkMessageOverlay> createState() => _ParkMessageOverlayState();
}

class _ParkMessageOverlayState extends State<_ParkMessageOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  bool _isClosing = false;
  Timer? _dismissTimer;
  bool _isHovered = false;
  Duration _remainingDuration = Duration.zero;
  DateTime? _timerStartTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final begin = widget.position == ParkMessagePosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);
    _slideAnim = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    if (!widget.closable) {
      _remainingDuration = widget.duration;
      _startDismissTimer();
    }
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    _timerStartTime = DateTime.now();
    _dismissTimer = Timer(_remainingDuration, () {
      if (mounted) {
        close();
      }
    });
  }

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

  void close() {
    if (_isClosing) return;
    _isClosing = true;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (!mounted) return;
      widget.onDismiss();
    });
  }

  void _handleTap() {
    widget.onTap?.call();
    widget.onClick?.call();
    if (widget.onTap != null || widget.onClick != null) {
      close();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final bg = widget.backgroundColor ?? park.colors.infoLight;

    final alignment = widget.position == ParkMessagePosition.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;

    final safeArea = widget.position == ParkMessagePosition.top
        ? EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + park.spacing.sm)
        : EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + park.spacing.sm,
          );

    Widget messageWidget = Semantics(
      liveRegion: true,
      label: widget.title,
      hint: widget.content,
      child: SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: park.spacing.base)
                .add(safeArea),
            child: MouseRegion(
              onEnter: (_) {
                if (widget.pauseOnHover && !_isHovered && !widget.closable) {
                  _isHovered = true;
                  _pauseTimer();
                }
              },
              onExit: (_) {
                if (widget.pauseOnHover && _isHovered && !widget.closable) {
                  _isHovered = false;
                  _resumeTimer();
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap:
                    (widget.onTap == null && widget.onClick == null)
                        ? null
                        : _handleTap,
                child: ClipRRect(
                  borderRadius: park.radius.brMd,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: park.spacing.base,
                          vertical: park.spacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: park.radius.brMd,
                          boxShadow: park.shadows.md,
                        ),
                        child: Row(
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              SizedBox(width: park.spacing.sm),
                            ],
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: park.typography.body.copyWith(
                                      fontSize: park.typography.sizeBody,
                                      fontWeight: park.typography.weightMedium,
                                      color: park.colors.textPrimary,
                                    ),
                                  ),
                                  if (widget.content != null) ...[
                                    SizedBox(height: park.spacing.xs),
                                    Text(
                                      widget.content!,
                                      style: park.typography.body.copyWith(
                                        fontSize: park.typography.sizeBodySmall,
                                        color: park.colors.textSecondary,
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
                                    size: 18,
                                    color: park.colors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.accentColor != null)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 3,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(park.radius.sm),
                                bottomLeft: Radius.circular(park.radius.sm),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
    return messageWidget;
  }
}
