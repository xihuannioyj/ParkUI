import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';

/// 全局 Toast 的表面材质派生结果（与 [ParkMessageSurface] 同构）。
///
/// Toast 是**中性胶囊**：填充固定走 [inverseSurface]、文字固定走
/// `textOnBrand`，不消费材质 `fill` / 文字色。这里只把**阴影**收敛到材质令牌，
/// 使 glass / neo 风格下有正确的浮层阴影，而 stripe / flat 下 [ParkSurfaceTokens.shadows]
/// 为 null → 回落到浮层原值（零回归）。
@immutable
class ParkToastSurface {
  /// 容器填充色（固定 inverseSurface，见 [resolveParkToastSurface]）。
  final Color fill;

  /// 圆角（固定胶囊 brFull，不消费 [ParkSurfaceTokens.radius]）。
  final BorderRadius radius;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 是否需要背景模糊采样（glass 风格）；Toast 强制不透明，仅记录令牌值。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  const ParkToastSurface({
    required this.fill,
    required this.radius,
    required this.shadows,
    required this.useBlur,
    required this.blurSigma,
  });
}

/// Toast 改造前的浮层阴影 floor（与 [ParkMessageSurface] 同理，浮层原值兜底）。
List<BoxShadow> _toastShadowFloor(ParkThemeData park) => park.shadows.sm;

/// 解析全局 Toast 的表面材质（浮层规范在 ParkToast 上的实现）。
///
/// 五条浮层规范：
/// 1. 阴影 `tokens.shadows ?? floor`（[_toastShadowFloor]）——
///    stripe / flat 下 [ParkSurfaceTokens.shadows] 为 null，回落到此原值；
/// 2. 圆角保留组件原值 `brFull`（胶囊），不消费 [ParkSurfaceTokens.radius]；
/// 3. 无边框（Toast 无边框语义，故 [bordered] 传 false）；
/// 4. Toast 填充 / 文字色固定（inverseSurface / textOnBrand），不来自材质，
///    因此无"文字色取自 tokens"条目；
/// 5. 无全屏形态分支。
@visibleForTesting
ParkToastSurface resolveParkToastSurface({
  required ParkThemeData park,
  required BuildContext context,
  required Color backgroundColor,
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );
  return ParkToastSurface(
    // Toast 强制 100% 不透明（见 _buildPill 注释），玻璃模糊不可见，
    // 因此 fill 保留 inverseSurface，useBlur 仅记录令牌值、容器不包裹
    // BackdropFilter。
    fill: backgroundColor,
    radius: park.radius.brFull,
    shadows: ParkSurfaceTokens.overlayShadows(
      tokens: tokens,
      floor: _toastShadowFloor(park),
    ),
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
  );
}

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
  ///
  /// 保留向后兼容：当前无实际效果——overlay 由框架自动管理销毁。
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
    // 边界防御：maxCount <= 0 时 _activeToasts 为空也会进入淘汰循环，
    // 对空 Map 取 keys.first 抛 StateError。
    final int safeMaxCount = (maxCount ?? _config.maxCount) < 1
        ? 1
        : (maxCount ?? _config.maxCount);
    _config = ParkToastConfig(maxCount: safeMaxCount);
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
    _showToast(
      context,
      message: message,
      icon: Icon(
        Icons.check_circle_rounded,
        color: park.colors.success,
        size: 20,
      ),
      duration: duration,
      position: position,
      toastKey: key,
      onClick: onClick,
      pauseOnHover: pauseOnHover,
    );
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
    _showToast(
      context,
      message: message,
      icon: Icon(Icons.error_rounded, color: park.colors.error, size: 20),
      duration: duration,
      position: position,
      toastKey: key,
      onClick: onClick,
      pauseOnHover: pauseOnHover,
    );
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
    _showToast(
      context,
      message: message,
      icon: Icon(Icons.warning_rounded, color: park.colors.warning, size: 20),
      duration: duration,
      position: position,
      toastKey: key,
      onClick: onClick,
      pauseOnHover: pauseOnHover,
      onClose: onClose,
    );
  }

  /// 加载中 Toast — shows a loading spinner with message.
  /// Returns a dismiss function to manually close it.
  static VoidCallback loading(
    BuildContext context,
    String message, {
    ParkToastPosition position = ParkToastPosition.center,
    String? key,
  }) {
    // 每次 loading 使用唯一 key：共享 '_loading_auto' 会导致后开的 loading
    // 顶掉先开的，且先开调用方返回的 dismiss 会误关后开的 loading。
    final effectiveKey = key ?? '_loading_auto_${_autoId++}';
    _showToast(
      context,
      message: message,
      // B83a: Duration is irrelevant for loading toasts (no auto-dismiss timer
      // is started when isLoading=true), but a non-null value is required by
      // the parameter contract.
      duration: Duration.zero,
      position: position,
      toastKey: effectiveKey,
      isLoading: true,
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
    bool isLoading = false,
  }) {
    final bool effectiveLoading = isLoading;
    // If a toast with the same key exists, dismiss it first (update pattern).
    if (toastKey != null && _activeToasts.containsKey(toastKey)) {
      _activeToasts[toastKey]?.dismiss();
      _activeToasts.remove(toastKey);
    }

    // Enforce maxCount: dismiss oldest toasts when limit reached.
    // 边界防御：即使 maxCount 被外部构造为 0，也绝不从空 Map 取 first。
    while (_activeToasts.isNotEmpty &&
        _activeToasts.length >= _config.maxCount) {
      final oldestKey = _activeToasts.keys.first;
      _activeToasts[oldestKey]?.dismiss();
      _activeToasts.remove(oldestKey);
    }

    // Legacy: when maxCount == 1 and no key, dismiss previous single toast.
    if (_config.maxCount <= 1 && toastKey == null) {
      _currentController?.dismiss();
    }

    final OverlayState? overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (overlay == null) {
      debugPrint(
        'ParkToast: Overlay not found, skip toast => message: $message',
      );
      onClose?.call();
      return;
    }
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

    entry = OverlayEntry(
      builder: (_) {
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
          isLoading: effectiveLoading,
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return _buildPill(park, context);
  }

  Widget _buildPill(ParkThemeData park, BuildContext context) {
    // 默认背景必须 100% 不透明（如 ParkLoading 气泡用 surface 的解法）：
    // 任何残留透明度都会透出底下页面内容（如顶部装饰条），视觉上出现异常色线。
    // 主题统一：走 inverseSurface 令牌（亮色模式深色胶囊、暗色模式浅色胶囊）。
    final bg = bgColor ?? park.colors.inverseSurface;
    final ParkToastSurface surface =
        resolveParkToastSurface(park: park, context: context, backgroundColor: bg);
    // 用 LayoutBuilder 拿真实布局约束计算宽度，避免依赖 MediaQuery.sizeOf：
    // ScreenUtil 等库会替换 MediaQuery.size 为设计稿假尺寸，导致宽度基准错误。
    final pill = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double baseWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final double maxWidth = baseWidth * 0.82;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: park.spacing.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.base,
                vertical: park.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: surface.fill,
                borderRadius: surface.radius,
                boxShadow: surface.shadows,
              ),
              clipBehavior: Clip.antiAlias,
              child: _ParkToastBody(
                message: message,
                icon: icon,
                park: park,
              ),
            ),
          ),
        );
      },
    );

    // 非居中位置时应用对齐
    if (position != ParkToastPosition.center) {
      return Align(
        alignment: position == ParkToastPosition.top
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: pill,
      );
    }
    return pill;
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
  final bool isLoading;

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
    this.isLoading = false,
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
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: ParkMotion.defaults.enterEasing,
    );
    _controller.forward();

    _remainingDuration = widget.duration > const Duration(milliseconds: 300)
        ? widget.duration - const Duration(milliseconds: 300)
        : Duration.zero;

    // B83a: Loading toasts should persist until manually dismissed — skip timer.
    if (!widget.isLoading) {
      _startDismissTimer();
    }
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
    final timer = _dismissTimer;
    final startTime = _timerStartTime;
    if (timer != null && startTime != null) {
      timer.cancel();
      final elapsed = DateTime.now().difference(startTime);
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
        return EdgeInsets.only(top: park.spacing.lg * 2);
      case ParkToastPosition.center:
        return EdgeInsets.zero;
      case ParkToastPosition.bottom:
        return EdgeInsets.only(bottom: park.spacing.lg * 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    // 默认背景必须 100% 不透明（禁用半透明 colors.overlay，零透出）。
    // 主题统一：走 inverseSurface 令牌。
    final bg = widget.bgColor ?? park.colors.inverseSurface;
    final ParkToastSurface surface =
        resolveParkToastSurface(park: park, context: context, backgroundColor: bg);

    Widget toastWidget = SafeArea(
      child: Semantics(
        liveRegion: true,
        child: FadeTransition(
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 用真实布局约束（ScreenUtil 无法伪造约束）计算 82% 宽度，
                    // 避免 MediaQuery.sizeOf 被替换为设计稿假尺寸。
                    final double baseWidth = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : MediaQuery.sizeOf(context).width;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: park.spacing.lg,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: baseWidth * 0.82,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: park.spacing.base,
                            vertical: park.spacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: surface.fill,
                            borderRadius: surface.radius,
                            boxShadow: surface.shadows,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: widget.contentWidget != null
                              ? widget.contentWidget!
                              : _ParkToastBody(
                                  message: widget.message,
                                  icon: widget.icon,
                                  park: park,
                                  isLoading: widget.isLoading,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // When there's an onClick, we need pointer events; otherwise use IgnorePointer
    if (widget.onClick == null && !widget.pauseOnHover && !widget.isLoading) {
      return IgnorePointer(child: toastWidget);
    }
    return toastWidget;
  }
}

class _ParkToastBody extends StatelessWidget {
  final String message;
  final Widget? icon;
  final ParkThemeData park;
  final bool isLoading;

  const _ParkToastBody({
    required this.message,
    required this.park,
    this.icon,
    this.isLoading = false,
  });

  double _leadingReservedWidth() {
    double width = 0;
    if (isLoading) {
      width += 16;
    }
    if (icon != null) {
      width += 20;
    }
    return width;
  }

  Widget _buildMessageText() {
    return Text(
      message,
      maxLines: 4,
      softWrap: true,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: park.typography.body.copyWith(
        fontSize: park.typography.sizeBody,
        color: park.colors.textOnBrand,
        // Overlay 环境无 Material → DefaultTextStyle 回退到 fallback style
        // （黄色下划线），Text(inherit: true) 会继承该装饰。必须显式清除，
        // 否则 toast 文本下方出现黄色线条。
        decoration: TextDecoration.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width * 0.82;
        final double textMaxWidth = math.max(
          0,
          availableWidth - _leadingReservedWidth(),
        );

        if (!isLoading && icon == null) {
          return _buildMessageText();
        }

        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: park.spacing.xs,
          runSpacing: park.spacing.xs * 0.5,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    park.colors.textOnBrand,
                  ),
                ),
              ),
            if (icon != null) icon!,
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: textMaxWidth),
              child: _buildMessageText(),
            ),
          ],
        );
      },
    );
  }
}
