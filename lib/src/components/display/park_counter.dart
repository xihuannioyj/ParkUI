import 'dart:async';

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 倒计时尺寸
enum ParkCounterSize {
  small,
  medium,
  large,
}

/// Park 倒计时主题风格
enum ParkCounterTheme {
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
/// final controller = ParkCounterController(remaining: Duration(minutes: 5));
/// ParkCounter(remaining: Duration(minutes: 5), controller: controller);
/// controller.start();
/// ```
class ParkCounterController extends ChangeNotifier {
  Duration _remaining;
  Timer? _timer;
  bool _isRunning = false;

  /// 初始剩余时间
  final Duration initialRemaining;

  ParkCounterController({required Duration remaining})
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
/// ParkCounter(
///   remaining: Duration(hours: 1, minutes: 30),
///   onFinish: () => print('时间到！'),
///   size: ParkCounterSize.medium,
///   theme: ParkCounterTheme.round,
/// )
/// ```
class ParkCounter extends StatefulWidget {
  /// 剩余时间
  final Duration remaining;

  /// 倒计时结束回调
  final VoidCallback? onFinish;

  /// 尺寸
  final ParkCounterSize size;

  /// 主题风格
  final ParkCounterTheme theme;

  /// 外部控制器（可选）
  final ParkCounterController? controller;

  /// Custom number format callback. Receives integer value and returns display string.
  final String Function(int value)? formatter;

  /// When true, shows shimmer animation instead of numbers.
  final bool loading;

  const ParkCounter({
    super.key,
    required this.remaining,
    this.onFinish,
    this.size = ParkCounterSize.medium,
    this.theme = ParkCounterTheme.defaultStyle,
    this.controller,
    this.formatter,
    this.loading = false,
  });

  @override
  State<ParkCounter> createState() => _ParkCounterState();
}

class _ParkCounterState extends State<ParkCounter>
    with SingleTickerProviderStateMixin {
  late ParkCounterController _controller;
  bool _ownsController = false;
  Duration _displayRemaining = Duration.zero;
  AnimationController? _shimmerController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ParkCounterController(remaining: widget.remaining);
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
  void didUpdateWidget(ParkCounter oldWidget) {
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

    final hours = _displayRemaining.inHours;
    final minutes = _displayRemaining.inMinutes % 60;
    final seconds = _displayRemaining.inSeconds % 60;

    final sizeConfig = _resolveSize(park);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 时
        if (hours > 0 || _displayRemaining.inHours > 0) ...[
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
    );
  }

  String _pad(int value) {
    if (widget.formatter != null) return widget.formatter!(value);
    return value.toString().padLeft(2, '0');
  }

  Widget _buildDigitBox(
    String text,
    _CounterSizeConfig config,
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
    _CounterSizeConfig config,
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
    _CounterSizeConfig config,
    ParkThemeData park,
  ) {
    switch (widget.theme) {
      case ParkCounterTheme.defaultStyle:
        return BorderRadius.circular(park.radius.sm);
      case ParkCounterTheme.round:
        return park.radius.brFull;
      case ParkCounterTheme.square:
        return BorderRadius.zero;
    }
  }

  _CounterSizeConfig _resolveSize(ParkThemeData park) {
    switch (widget.size) {
      case ParkCounterSize.small:
        return _CounterSizeConfig(
          boxWidth: 28,
          boxHeight: 28,
          fontSize: park.typography.sizeBodySmall,
          colonSpacing: park.spacing.xs,
        );
      case ParkCounterSize.medium:
        return _CounterSizeConfig(
          boxWidth: 36,
          boxHeight: 36,
          fontSize: park.typography.sizeBody,
          colonSpacing: park.spacing.sm,
        );
      case ParkCounterSize.large:
        return _CounterSizeConfig(
          boxWidth: 48,
          boxHeight: 48,
          fontSize: park.typography.sizeH2,
          colonSpacing: park.spacing.md,
        );
    }
  }
}

class _CounterSizeConfig {
  final double boxWidth;
  final double boxHeight;
  final double fontSize;
  final double colonSpacing;

  const _CounterSizeConfig({
    required this.boxWidth,
    required this.boxHeight,
    required this.fontSize,
    required this.colonSpacing,
  });
}
