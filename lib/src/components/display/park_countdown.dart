import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 倒计时尺寸
enum ParkCountdownSize {
  small,
  medium,
  large,
}

/// Park 倒计时主题风格
enum ParkCountdownTheme {
  /// 默认：带圆角的数字方块
  defaultStyle,

  /// 圆形数字方块
  round,

  /// 直角方块
  square,
}

/// Park 倒计时控制器
///
/// 提供 [start]、[pause]、[reset] 方法控制倒计时。
///
/// ```dart
/// final controller = ParkCountdownController(remaining: Duration(minutes: 5));
/// ParkCountdown(remaining: Duration(minutes: 5), controller: controller);
/// controller.start();
/// ```
class ParkCountdownController extends ChangeNotifier {
  Duration _remaining;
  Timer? _timer;
  bool _isRunning = false;

  /// 初始剩余时间
  final Duration initialRemaining;

  ParkCountdownController({required Duration remaining})
      : initialRemaining = remaining,
        _remaining = remaining;

  /// 当前剩余时间
  Duration get remaining => _remaining;

  /// 是否正在运行
  bool get isRunning => _isRunning;

  /// 开始倒计时
  void start(VoidCallback? onFinish) {
    if (_isRunning || _remaining <= Duration.zero) return;
    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remaining -= const Duration(seconds: 1);
      notifyListeners();

      if (_remaining <= Duration.zero) {
        _remaining = Duration.zero;
        _isRunning = false;
        _timer?.cancel();
        _timer = null;
        onFinish?.call();
        notifyListeners();
      }
    });
  }

  /// 暂停倒计时
  void pause() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  /// 重置倒计时到初始时间
  void reset() {
    pause();
    _remaining = initialRemaining;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Park 倒计时组件
///
/// 显示倒计时数字方块与冒号分隔符，支持多种尺寸和主题风格。
///
/// ```dart
/// ParkCountdown(
///   remaining: Duration(hours: 1, minutes: 30),
///   onFinish: () => print('时间到！'),
///   size: ParkCountdownSize.medium,
///   theme: ParkCountdownTheme.round,
/// )
/// ```
class ParkCountdown extends StatefulWidget {
  /// 剩余时间
  final Duration remaining;

  /// 倒计时结束回调
  final VoidCallback? onFinish;

  /// 尺寸
  final ParkCountdownSize size;

  /// 主题风格
  final ParkCountdownTheme theme;

  /// 外部控制器（可选）
  final ParkCountdownController? controller;

  /// Custom number format callback. Receives integer value and returns display string.
  final String Function(int value)? formatter;

  /// When true, shows shimmer animation instead of numbers.
  final bool loading;

  const ParkCountdown({
    super.key,
    required this.remaining,
    this.onFinish,
    this.size = ParkCountdownSize.medium,
    this.theme = ParkCountdownTheme.defaultStyle,
    this.controller,
    this.formatter,
    this.loading = false,
  });

  @override
  State<ParkCountdown> createState() => _ParkCountdownState();
}

class _ParkCountdownState extends State<ParkCountdown>
    with SingleTickerProviderStateMixin {
  late ParkCountdownController _controller;
  bool _ownsController = false;
  Duration _displayRemaining = Duration.zero;
  AnimationController? _shimmerController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ParkCountdownController(remaining: widget.remaining);
      _ownsController = true;
      _controller.start(widget.onFinish);
    }
    _controller.addListener(_onControllerUpdate);
    _displayRemaining = _controller.remaining;
    _initShimmer();
  }

  void _initShimmer() {
    if (widget.loading) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (_ownsController) {
      _controller.dispose();
    }
    _shimmerController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ParkCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading != oldWidget.loading) {
      if (widget.loading && _shimmerController == null) {
        _initShimmer();
      } else if (!widget.loading && _shimmerController != null) {
        _shimmerController?.stop();
        _shimmerController?.dispose();
        _shimmerController = null;
      }
    }
    if (oldWidget.controller != widget.controller) {
      // 外部控制器被替换：迁移监听（外部 → 内部 的切换也安全处理）。
      _controller.removeListener(_onControllerUpdate);
      if (_ownsController || widget.controller == null) {
        _controller.pause();
        _controller.dispose();
        _ownsController = true;
        _controller = ParkCountdownController(remaining: widget.remaining);
      } else {
        _controller = widget.controller!;
      }
      _controller.addListener(_onControllerUpdate);
      _controller.start(widget.onFinish);
    } else if (oldWidget.remaining != widget.remaining && _ownsController) {
      // 内部控制器 + remaining 变化：重建控制器使新值生效
      // （原实现把此分支嵌套在 controller 变化判断里，恒不可达 → 死代码）。
      _controller.removeListener(_onControllerUpdate);
      _controller.pause();
      _controller.dispose();
      _controller = ParkCountdownController(remaining: widget.remaining);
      _controller.addListener(_onControllerUpdate);
      _controller.start(widget.onFinish);
    }
    if (oldWidget.remaining != widget.remaining) {
      _displayRemaining = _controller.remaining;
    }
  }

  void _onControllerUpdate() {
    setState(() {
      _displayRemaining = _controller.remaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    // 边界防御：负初始值在 Dart 取模下会显示错误值（如 00:00:59），钳制到零。
    final Duration display = _displayRemaining.isNegative
        ? Duration.zero
        : _displayRemaining;
    final hours = display.inHours;
    final minutes = display.inMinutes % 60;
    final seconds = display.inSeconds % 60;

    final sizeConfig = _resolveSize(park);

    return Semantics(
      liveRegion: true,
      label: '${_pad(hours)}:${_pad(minutes)}:${_pad(seconds)}',
      child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 时
        if (hours > 0 || display.inHours > 0) ...[
          _buildDigitBox(
            _pad(hours),
            sizeConfig,
            park,
          ),
          _buildColon(sizeConfig, park),
        ],
        // 分
        _buildDigitBox(
          _pad(minutes),
          sizeConfig,
          park,
        ),
        _buildColon(sizeConfig, park),
        // 秒
        _buildDigitBox(
          _pad(seconds),
          sizeConfig,
          park,
        ),
      ],
    ),
    );
  }

  String _pad(int value) {
    if (widget.formatter != null) return widget.formatter!(value);
    return value.toString().padLeft(2, '0');
  }

  Widget _buildDigitBox(
    String text,
    _CountdownSizeConfig config,
    ParkThemeData park,
  ) {
    final br = _resolveBorderRadius(config, park);

    if (widget.loading && _shimmerController != null) {
      return AnimatedBuilder(
        animation: _shimmerController!,
        builder: (context, child) {
          return Container(
            width: config.boxWidth,
            height: config.boxHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: br,
              boxShadow: park.shadows.sm,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  park.colors.disabledBg,
                  park.colors.border.withValues(alpha: 0.3),
                  park.colors.disabledBg,
                ],
                stops: [
                  (_shimmerController!.value - 0.3).clamp(0.0, 1.0),
                  _shimmerController!.value.clamp(0.0, 1.0),
                  (_shimmerController!.value + 0.3).clamp(0.0, 1.0),
                ],
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: config.boxWidth,
      height: config.boxHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: park.colors.brand,
        borderRadius: br,
        boxShadow: park.shadows.sm,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyle(
            color: park.colors.textOnBrand,
            fontSize: config.fontSize,
            fontWeight: park.typography.weightBold,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildColon(
    _CountdownSizeConfig config,
    ParkThemeData park,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: config.colonSpacing),
      child: Text(
        ':',
        style: TextStyle(
          color: park.colors.textPrimary,
          fontSize: config.fontSize,
          fontWeight: park.typography.weightBold,
          height: 1.0,
        ),
      ),
    );
  }

  BorderRadius _resolveBorderRadius(
    _CountdownSizeConfig config,
    ParkThemeData park,
  ) {
    switch (widget.theme) {
      case ParkCountdownTheme.defaultStyle:
        return BorderRadius.circular(park.radius.sm);
      case ParkCountdownTheme.round:
        return park.radius.brFull;
      case ParkCountdownTheme.square:
        return BorderRadius.zero;
    }
  }

  _CountdownSizeConfig _resolveSize(ParkThemeData park) {
    switch (widget.size) {
      case ParkCountdownSize.small:
        return _CountdownSizeConfig(
          boxWidth: 28,
          boxHeight: 28,
          fontSize: park.typography.sizeBodySmall,
          colonSpacing: park.spacing.xs,
        );
      case ParkCountdownSize.medium:
        return _CountdownSizeConfig(
          boxWidth: 36,
          boxHeight: 36,
          fontSize: park.typography.sizeBody,
          colonSpacing: park.spacing.sm,
        );
      case ParkCountdownSize.large:
        return _CountdownSizeConfig(
          boxWidth: 48,
          boxHeight: 48,
          fontSize: park.typography.sizeH2,
          colonSpacing: park.spacing.md,
        );
    }
  }
}

class _CountdownSizeConfig {
  final double boxWidth;
  final double boxHeight;
  final double fontSize;
  final double colonSpacing;

  const _CountdownSizeConfig({
    required this.boxWidth,
    required this.boxHeight,
    required this.fontSize,
    required this.colonSpacing,
  });
}
