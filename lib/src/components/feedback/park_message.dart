import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../l10n/park_localizations.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_surface.dart';

/// 消息弹出位置
enum ParkMessagePosition { top, bottom }

/// 消息尺寸
enum ParkMessageSize {
  /// 小尺寸（紧凑内边距、小字号、小图标）
  small,

  /// 默认尺寸
  medium,

  /// 大尺寸（宽松内边距、大字号、大图标）
  large,
}

/// ParkMessageConfig — global configuration for ParkMessage behaviour.
class ParkMessageConfig {
  /// Maximum number of messages visible at the same time.
  /// When exceeded the oldest message is dismissed.
  final int maxCount;

  const ParkMessageConfig({this.maxCount = 1});
}

/// 全局消息提示的表面材质派生结果（与 [ParkPopconfirmSurface] 同构）。
///
/// 把容器填充、圆角、阴影与文字色收敛到**一个**派生结果里，避免"容器改了、
/// 文字没改"的半迁移状态。
@immutable
class ParkMessageSurface {
  /// 容器填充色（语义色背景，见 [resolveParkMessageSurface]）。
  final Color fill;

  /// 圆角（保留组件原值 `ParkRadius.brMd`，不消费 [ParkSurfaceTokens.radius]）。
  final BorderRadius radius;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 是否需要背景模糊采样（glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  /// 标题文字色 —— **必须**来自表面令牌。
  final Color titleColor;

  /// 正文文字色 —— **必须**来自表面令牌。
  final Color bodyColor;

  const ParkMessageSurface({
    required this.fill,
    required this.radius,
    required this.shadows,
    required this.useBlur,
    required this.blurSigma,
    required this.titleColor,
    required this.bodyColor,
  });
}

/// 消息框改造前的浮层阴影（浮层兜底 floor）。
///
/// 原 overlay 路径用的是 [ParkThemeData.shadows] 的 md 档；按浮层规范第 1 条，
/// stripe / flat 风格下 [ParkSurfaceTokens.shadows] 为 null，必须回落到此原值，
/// 否则消息会凭空丢失阴影（非零回归）。
List<BoxShadow> _messageShadowFloor(ParkThemeData park) => park.shadows.md;

/// 解析全局消息提示的表面材质（浮层规范在 ParkMessage 上的实现）。
///
/// 五条浮层规范：
/// 1. 阴影 `tokens.shadows ?? floor`（[_messageShadowFloor]）——
///    风格接管优先，浮层原值兜底；
/// 2. 圆角保留组件原值 `BorderRadius.circular(park.radius.brMd)`，
///    **不**消费 [ParkSurfaceTokens.radius]；
/// 3. 无边框（消息原本无边框语义，故 [bordered] 传 false）；
/// 4. 文字色取派生的 `titleColor / bodyColor`（消息用语义文字对
///    `colors.textPrimary / textSecondary`，而非表面令牌 —— 见下方实现注释）；
/// 5. 无全屏 / 特殊形态分支。
///
/// ## 关于填充色：消息是**语义色**表面（info=蓝 / success=绿 / warning=橙 /
/// error=红），类型身份由左侧 [accentColor] 描边条承载，因此**容器填充保留
/// 语义色**而非 [ParkSurfaceTokens.fill]。这样做有两个好处：
/// - stripe / flat 下观感与改造前完全一致（零回归）；
/// - 玻璃风格只对背后内容做 [BackdropFilter] 模糊，不把语义色变半透明，
///   避免削弱信息可读性（消息是瞬时强提示，可读性优先）。
/// 文字色使用**语义文字对** `colors.textPrimary / textSecondary`（见下方
/// 实现注释）：消息填充恒为语义浅色，与语义文字对天然配对，5 风格 × 2 明暗中
/// 对比度均 ≥ 4.5:1；不需要表面令牌的 neon 翻转逻辑。
///
/// 抽成顶层函数（[visibleForTesting]）以便单测直接断言"文字色与填充对比度"。
@visibleForTesting
ParkMessageSurface resolveParkMessageSurface({
  required ParkThemeData park,
  required BuildContext context,
  required Color backgroundColor,
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  return ParkMessageSurface(
    fill: backgroundColor,
    radius: park.radius.brMd,
    shadows: ParkSurfaceTokens.overlayShadows(
      tokens: tokens,
      floor: _messageShadowFloor(park),
    ),
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
    // 🔴 标题 / 正文使用**语义文字对** `colors.textPrimary / textSecondary`，
    // 而非表面令牌：消息填充恒为语义浅色（infoLight 等），在 5 风格 × 2 明暗中
    // 始终是"可读的着色背景"，与 textPrimary / textSecondary 配对即可保证对比度。
    // 若改用 surface 令牌（neon + 深色下 token 文字翻转为 colors.surface 深 navy），
    // 而填充仍是近黑的 infoLight 深色，会反成"深字深底"不可读。
    titleColor: park.colors.textPrimary,
    bodyColor: park.colors.textSecondary,
  );
}

/// 玻璃风格包装：在 [ParkSurfaceBlurDepth] 允许（嵌套层级 `< 1`）时对子树
/// 叠加 [BackdropFilter] 采样背后内容；否则原样返回。
///
/// 外层 [ClipRRect]（调用方）负责把模糊结果裁成圆角，这里只负责"是否模糊"。
/// 判定必须是 `< 1` 而非 `<= 1`，与 [ParkSurface.canBlur] 的语义一致，
/// 避免在同一 backdrop 上重复采样。
Widget _parkMessageGlassWrap({
  required ParkMessageSurface surface,
  required BuildContext context,
  required Widget child,
}) {
  if (surface.useBlur &&
      ParkSurfaceBlurDepth.of(context) < 1 &&
      surface.blurSigma > 0) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: surface.blurSigma,
        sigmaY: surface.blurSigma,
      ),
      child: child,
    );
  }
  return child;
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

  /// 消息尺寸（small/medium/large），控制内边距、字号与图标大小。
  final ParkMessageSize size;

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
    this.size = ParkMessageSize.medium,
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
    // 边界防御：maxCount <= 0 时空 Map 淘汰循环取 keys.first 抛 StateError。
    final int rawMax = maxCount ?? _config.maxCount;
    _config = ParkMessageConfig(
      maxCount: rawMax < 1 ? 1 : rawMax,
    );
  }

  /// Reset configuration to defaults (useful in tests).
  static void resetConfig() {
    _config = const ParkMessageConfig();
  }

  /// 按尺寸返回类型图标大小（info/success/warning/error）。
  static double _iconSizeFor(ParkMessageSize size) => switch (size) {
        ParkMessageSize.small => 16.0,
        ParkMessageSize.medium => 20.0,
        ParkMessageSize.large => 24.0,
      };

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
    ParkMessageSize size = ParkMessageSize.medium,
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
      icon: Icon(Icons.info_outline, color: park.colors.info, size: _iconSizeFor(size)),
      accentColor: park.colors.info,
      backgroundColor: park.colors.infoLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
      size: size,
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
    ParkMessageSize size = ParkMessageSize.medium,
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
        size: _iconSizeFor(size),
      ),
      accentColor: park.colors.success,
      backgroundColor: park.colors.successLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
      size: size,
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
    ParkMessageSize size = ParkMessageSize.medium,
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
        size: _iconSizeFor(size),
      ),
      accentColor: park.colors.warning,
      backgroundColor: park.colors.warningLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
      size: size,
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
    ParkMessageSize size = ParkMessageSize.medium,
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
      icon: Icon(Icons.error_outline, color: park.colors.error, size: _iconSizeFor(size)),
      accentColor: park.colors.error,
      backgroundColor: park.colors.errorLight,
      messageKey: key,
      onClick: onClick,
      onClose: onClose,
      pauseOnHover: pauseOnHover,
      size: size,
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
    ParkMessageSize size = ParkMessageSize.medium,
  }) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final double loadingSize = switch (size) {
      ParkMessageSize.small => 14.0,
      ParkMessageSize.medium => 18.0,
      ParkMessageSize.large => 22.0,
    };
    _show(
      context,
      title: title,
      content: content,
      duration: duration,
      closable: closable,
      position: position,
      onTap: onTap,
      icon: SizedBox(
        width: loadingSize,
        height: loadingSize,
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
      size: size,
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
    ParkMessageSize size = ParkMessageSize.medium,
  }) {
    // If a message with the same key exists, dismiss it first (update pattern).
    if (messageKey != null && _activeMessages.containsKey(messageKey)) {
      _activeMessages[messageKey]?.dismiss();
      _activeMessages.remove(messageKey);
    }

    // Enforce maxCount: dismiss oldest messages when limit reached.
    // 边界防御：即使 maxCount 被外部构造为 0，也绝不从空 Map 取 first。
    while (_activeMessages.isNotEmpty &&
        _activeMessages.length >= _config.maxCount) {
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
            size: size,
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
    final ParkMessageSurface surface = resolveParkMessageSurface(
      park: park,
      context: context,
      backgroundColor: widget.backgroundColor ?? park.colors.infoLight,
    );

    // size 令牌：小/中/大 三档内边距、字号与图标大小
    final EdgeInsets padding = switch (widget.size) {
      ParkMessageSize.small => EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.xs,
        ),
      ParkMessageSize.medium => EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.md,
        ),
      ParkMessageSize.large => EdgeInsets.symmetric(
          horizontal: park.spacing.lg,
          vertical: park.spacing.lg,
        ),
    };
    final double titleFontSize = switch (widget.size) {
      ParkMessageSize.small => park.typography.sizeCaption,
      ParkMessageSize.medium => park.typography.sizeBody,
      ParkMessageSize.large => park.typography.sizeBody,
    };
    final double contentFontSize = switch (widget.size) {
      ParkMessageSize.small => park.typography.sizeCaption,
      ParkMessageSize.medium => park.typography.sizeBodySmall,
      ParkMessageSize.large => park.typography.sizeBody,
    };
    final double closeIconSize = switch (widget.size) {
      ParkMessageSize.small => 14.0,
      ParkMessageSize.medium => 18.0,
      ParkMessageSize.large => 20.0,
    };

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
          padding: padding,
          decoration: BoxDecoration(
            color: surface.fill,
            borderRadius: surface.radius,
            boxShadow: surface.shadows,
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
                        fontSize: titleFontSize,
                        fontWeight: park.typography.weightMedium,
                        color: surface.titleColor,
                        // Overlay 无 Material → fallback style 黄色下划线，
                        // 必须显式清除（ParkMessage.show 走 overlay 路径）。
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (widget.content != null) ...[
                      SizedBox(height: park.spacing.xs),
                      Text(
                        widget.content!,
                        style: park.typography.body.copyWith(
                          fontSize: contentFontSize,
                          color: surface.bodyColor,
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
                  label: l10n.closeText,
                  child: Icon(Icons.close, size: closeIconSize, color: surface.bodyColor),
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

  /// 消息尺寸（small/medium/large）。
  final ParkMessageSize size;

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
    this.size = ParkMessageSize.medium,
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
    // 浮层表面材质：填充保留语义色（见 [resolveParkMessageSurface]），
    // 阴影 / 文字色走 surface 令牌；glass 风格由 [_parkMessageGlassWrap] 叠加模糊。
    final ParkMessageSurface surface = resolveParkMessageSurface(
      park: park,
      context: context,
      backgroundColor: widget.backgroundColor ?? park.colors.infoLight,
    );

    final alignment = widget.position == ParkMessagePosition.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;

    // size 令牌：小/中/大 三档内边距、字号与图标大小
    final EdgeInsets padding = switch (widget.size) {
      ParkMessageSize.small => EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.xs,
        ),
      ParkMessageSize.medium => EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.md,
        ),
      ParkMessageSize.large => EdgeInsets.symmetric(
          horizontal: park.spacing.lg,
          vertical: park.spacing.lg,
        ),
    };
    final double titleFontSize = switch (widget.size) {
      ParkMessageSize.small => park.typography.sizeCaption,
      ParkMessageSize.medium => park.typography.sizeBody,
      ParkMessageSize.large => park.typography.sizeBody,
    };
    final double contentFontSize = switch (widget.size) {
      ParkMessageSize.small => park.typography.sizeCaption,
      ParkMessageSize.medium => park.typography.sizeBodySmall,
      ParkMessageSize.large => park.typography.sizeBody,
    };
    final double closeIconSize = switch (widget.size) {
      ParkMessageSize.small => 14.0,
      ParkMessageSize.medium => 18.0,
      ParkMessageSize.large => 20.0,
    };

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
                  borderRadius: surface.radius,
                  child: _parkMessageGlassWrap(
                    surface: surface,
                    context: context,
                    child: Stack(
                      children: [
                        Container(
                          padding: padding,
                          decoration: BoxDecoration(
                            color: surface.fill,
                            borderRadius: surface.radius,
                            boxShadow: surface.shadows,
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
                                        fontSize: titleFontSize,
                                        fontWeight: park.typography.weightMedium,
                                        color: surface.titleColor,
                                      ),
                                    ),
                                    if (widget.content != null) ...[
                                      SizedBox(height: park.spacing.xs),
                                      Text(
                                        widget.content!,
                                        style: park.typography.body.copyWith(
                                          fontSize: contentFontSize,
                                          color: surface.bodyColor,
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
                                      size: closeIconSize,
                                      color: surface.bodyColor,
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
      ),
    );
    return messageWidget;
  }
}
