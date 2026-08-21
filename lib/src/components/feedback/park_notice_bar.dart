import 'dart:async';

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 通知栏变体
enum ParkNoticeBarVariant { info, success, warning, error }

/// 通知栏尺寸
enum ParkNoticeBarSize {
  /// 小尺寸（紧凑内边距、小字号）
  small,

  /// 默认尺寸
  medium,

  /// 大尺寸（宽松内边距、大字号）
  large,
}

/// 通知栏模式
enum ParkNoticeBarMode {
  /// 可关闭模式（显示关闭按钮）
  closable,

  /// 链接模式（显示箭头图标，可点击跳转）
  link,

  /// 操作模式（显示自定义操作按钮）
  action,
}

/// ParkNoticeBar — 通知栏组件，支持跑马灯滚动、关闭、多色变体。
class ParkNoticeBar extends StatefulWidget {
  final String text;
  final Widget? icon;
  /// 当 true 时显示关闭按钮。
  final bool closable;
  final VoidCallback? onClose;
  final bool scrollable;
  final ParkNoticeBarVariant variant;

  /// 当 true 且 scrollable 为 false 时，允许文本换行显示。
  final bool wrap;

  /// 右侧额外操作组件。
  final Widget? extra;

  /// Marquee scroll speed in pixels per second. Null uses default behavior.
  final double? speed;

  /// Prefix slot rendered before the icon.
  final Widget? prefixWidget;

  /// Notice bar mode (closable/link/action). When set, overrides [closable].
  final ParkNoticeBarMode? mode;

  /// Notice bar size (small/medium/large).
  final ParkNoticeBarSize size;

  const ParkNoticeBar({
    super.key,
    required this.text,
    this.icon,
    this.closable = false,
    this.onClose,
    this.scrollable = false,
    this.variant = ParkNoticeBarVariant.info,
    this.wrap = false,
    this.extra,
    this.speed,
    this.prefixWidget,
    this.mode,
    this.size = ParkNoticeBarSize.medium,
  });

  @override
  State<ParkNoticeBar> createState() => _ParkNoticeBarState();
}

class _ParkNoticeBarState extends State<ParkNoticeBar>
    with SingleTickerProviderStateMixin {
  bool _closed = false;
  bool _isClosing = false;
  bool _userInteracting = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final ScrollController _scrollController;

  /// 跑马灯停顿定时器（可取消）。
  Timer? _marqueeTimer;
  /// 跑马灯代数令牌：dispose/停止后使所有在途回调失效。
  int _marqueeGeneration = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _scrollController = ScrollController();

    if (widget.scrollable) {
      _scheduleMarqueeStart();
    }
  }

  @override
  void didUpdateWidget(covariant ParkNoticeBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.scrollable) {
      _stopMarquee(resetPosition: true);
      return;
    }

    if (!oldWidget.scrollable || oldWidget.text != widget.text) {
      _stopMarquee(resetPosition: true);
      _scheduleMarqueeStart();
    }
  }

  void _scheduleMarqueeStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _startMarquee());
  }

  void _startMarquee() {
    if (!mounted ||
        _closed ||
        _userInteracting ||
        !widget.scrollable ||
        !_scrollController.hasClients) {
      return;
    }

    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;

    final durationMs = widget.speed != null
        ? (maxExtent / widget.speed! * 1000).toInt()
        : (maxExtent * 30).toInt();

    _animateMarquee(Duration(milliseconds: durationMs));
  }

  /// Animate the scroll to the end, then loop back to the start.
  void _animateMarquee(Duration duration) {
    if (!mounted || _closed || _userInteracting) return;
    if (!_scrollController.hasClients) return;

    final int generation = ++_marqueeGeneration;
    _scrollController
        .animateTo(
      _scrollController.position.maxScrollExtent,
      duration: duration,
      curve: Curves.linear,
    )
        .then((_) {
      if (!mounted || _closed || _userInteracting) return;
      if (generation != _marqueeGeneration) return;
      // Pause briefly before restarting.
      // 用可取消 Timer 替代 Future.delayed：dispose 后不残留 pending Timer，
      // 代数令牌让在途回调全部失效。
      _marqueeTimer?.cancel();
      _marqueeTimer = Timer(const Duration(milliseconds: 400), () {
        if (!mounted || _closed || _userInteracting) return;
        if (generation != _marqueeGeneration) return;
        if (!_scrollController.hasClients) return;
        _scrollController.jumpTo(0);
        _animateMarquee(duration);
      });
    });
  }

  void _stopMarquee({bool resetPosition = false}) {
    _marqueeGeneration++;
    _marqueeTimer?.cancel();
    _marqueeTimer = null;
    if (resetPosition && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _handleInteractionStart() {
    _userInteracting = true;
    _stopMarquee();
  }

  void _handleInteractionEnd() {
    if (!_userInteracting) return;
    _userInteracting = false;
    _scheduleMarqueeStart();
  }

  void _close() {
    if (_isClosing || _closed) return;
    _isClosing = true;
    _stopMarquee();
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _closed = true);
      widget.onClose?.call();
    });
  }

  @override
  void dispose() {
    _stopMarquee();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _bgColor(ParkThemeData park) {
    switch (widget.variant) {
      case ParkNoticeBarVariant.info:
        return park.colors.infoLight;
      case ParkNoticeBarVariant.success:
        return park.colors.successLight;
      case ParkNoticeBarVariant.warning:
        return park.colors.warningLight;
      case ParkNoticeBarVariant.error:
        return park.colors.errorLight;
    }
  }

  Color _textColor(ParkThemeData park) {
    switch (widget.variant) {
      case ParkNoticeBarVariant.info:
        return park.colors.info;
      case ParkNoticeBarVariant.success:
        return park.colors.success;
      case ParkNoticeBarVariant.warning:
        return park.colors.warning;
      case ParkNoticeBarVariant.error:
        return park.colors.error;
    }
  }

  Widget _defaultIcon(ParkThemeData park) {
    IconData iconData;
    switch (widget.variant) {
      case ParkNoticeBarVariant.info:
        iconData = Icons.info_outline;
        break;
      case ParkNoticeBarVariant.success:
        iconData = Icons.check_circle_outline;
        break;
      case ParkNoticeBarVariant.warning:
        iconData = Icons.warning_amber_outlined;
        break;
      case ParkNoticeBarVariant.error:
        iconData = Icons.error_outline;
        break;
    }
    final double iconSize = switch (widget.size) {
      ParkNoticeBarSize.small => 16.0,
      ParkNoticeBarSize.medium => 18.0,
      ParkNoticeBarSize.large => 20.0,
    };
    return Icon(iconData, size: iconSize, color: _textColor(park));
  }

  @override
  Widget build(BuildContext context) {
    if (_closed) return const SizedBox.shrink();

    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final bg = _bgColor(park);
    final fg = _textColor(park);

    // size 令牌：小/中/大 三档内边距与字号
    final EdgeInsets padding = switch (widget.size) {
      ParkNoticeBarSize.small => EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.xs,
        ),
      ParkNoticeBarSize.medium => EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
      ParkNoticeBarSize.large => EdgeInsets.symmetric(
          horizontal: park.spacing.lg,
          vertical: park.spacing.md,
        ),
    };
    final double fontSize = switch (widget.size) {
      ParkNoticeBarSize.small => park.typography.sizeCaption,
      ParkNoticeBarSize.medium => park.typography.sizeBodySmall,
      ParkNoticeBarSize.large => park.typography.sizeBody,
    };

    return Semantics(
      liveRegion: true,
      label: widget.text,
      child: FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: park.radius.brSm,
        ),
        child: Row(
          children: [
            if (widget.prefixWidget != null) ...[
              widget.prefixWidget!,
              SizedBox(width: park.spacing.sm),
            ],
            widget.icon ?? _defaultIcon(park),
            SizedBox(width: park.spacing.sm),
            Expanded(
              child: widget.scrollable
                  ? Listener(
                      onPointerDown: (_) => _handleInteractionStart(),
                      onPointerUp: (_) => _handleInteractionEnd(),
                      onPointerCancel: (_) => _handleInteractionEnd(),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          widget.text,
                          style: park.typography.body.copyWith(
                            fontSize: fontSize,
                            color: fg,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    )
                  : Text(
                      widget.text,
                      style: park.typography.body.copyWith(
                        fontSize: fontSize,
                        color: fg,
                      ),
                      maxLines: widget.wrap ? null : 2,
                      overflow: widget.wrap ? null : TextOverflow.ellipsis,
                    ),
            ),
            if (widget.closable) ...[
              SizedBox(width: park.spacing.sm),
              Semantics(
                button: true,
                label: ParkLocalizations.of(context).closeText,
                child: GestureDetector(
                  onTap: _close,
                  child: Icon(Icons.close, size: 16, color: fg),
                ),
              ),
            ],
            if (widget.extra != null) ...[
              SizedBox(width: park.spacing.sm),
              widget.extra!,
            ],
          ],
        ),
      ),
    ),
  );
  }
}
