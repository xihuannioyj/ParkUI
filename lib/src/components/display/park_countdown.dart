import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 倒计时/计时器组件
///
/// 支持倒计时（指定目标时间或时长）和正计时（从 0 开始计时）两种模式。
/// 纯 [Timer] 驱动，零三方依赖。
///
/// ```dart
/// // 倒计时 10 秒
/// ParkCountdown(
///   duration: Duration(seconds: 10),
///   onFinish: () => print('倒计时结束'),
/// )
///
/// // 正计时
/// ParkCountdown(
///   stopwatch: true,
///   autoStart: true,
/// )
///
/// // 指定目标时间
/// ParkCountdown(
///   target: DateTime.now().add(Duration(hours: 1)),
///   format: 'HH:mm:ss',
/// )
/// ```
class ParkCountdown extends StatefulWidget {
  /// 倒计时总时长（与 [target] 二选一）。
  final Duration? duration;

  /// 目标时间（与 [duration] 二选一）。
  final DateTime? target;

  /// 是否为正计时模式（从 0 开始计时）。
  final bool stopwatch;

  /// 是否自动开始计时（默认 true）。
  final bool autoStart;

  /// 时间格式化模板。
  ///
  /// 支持：DD(天) HH(时) mm(分) ss(秒) SSS(毫秒)。
  /// 默认：`'HH:mm:ss'`（小于 1 小时显示 `'mm:ss'`）。
  final String? format;

  /// 文本样式。
  final TextStyle? style;

  /// 数字文本样式（覆盖 [style] 中的数字部分）。
  final TextStyle? digitStyle;

  /// 分隔符文本样式（覆盖 [style] 中的 `:` 部分）。
  final TextStyle? separatorStyle;

  /// 每秒回调（返回当前剩余/已过时间）。
  final void Function(Duration elapsed)? onTick;

  /// 倒计时结束回调。
  final VoidCallback? onFinish;

  /// 计时状态变化回调。
  final void Function(CountdownStatus status)? onStatusChanged;

  /// 对齐方式。
  final TextAlign textAlign;

  /// 创建 [ParkCountdown]。
  const ParkCountdown({
    super.key,
    this.duration,
    this.target,
    this.stopwatch = false,
    this.autoStart = true,
    this.format,
    this.style,
    this.digitStyle,
    this.separatorStyle,
    this.onTick,
    this.onFinish,
    this.onStatusChanged,
    this.textAlign = TextAlign.center,
  });

  @override
  State<ParkCountdown> createState() => _ParkCountdownState();
}

/// 计时器状态枚举。
enum CountdownStatus {
  /// 未开始
  idle,

  /// 运行中
  running,

  /// 已暂停
  paused,

  /// 已结束
  finished,
}

class _ParkCountdownState extends State<ParkCountdown> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Duration _total = Duration.zero;
  CountdownStatus _status = CountdownStatus.idle;

  @override
  void initState() {
    super.initState();
    _initDuration();
    if (widget.autoStart) {
      start();
    }
  }

  void _initDuration() {
    if (widget.target != null) {
      _total = widget.target!.difference(DateTime.now());
      if (_total.isNegative) _total = Duration.zero;
    } else if (widget.duration != null) {
      _total = widget.duration!;
    } else if (!widget.stopwatch) {
      _total = Duration.zero;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 开始计时。
  void start() {
    if (_status == CountdownStatus.running) return;
    _timer?.cancel();

    if (widget.target != null || (!widget.stopwatch && widget.duration != null)) {
      // 倒计时模式
      if (_elapsed == Duration.zero) {
        _initDuration();
      }
      final startTime = DateTime.now();
      _status = CountdownStatus.running;
      _notifyStatus();

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final remaining = _total - DateTime.now().difference(startTime) + _elapsed;
        if (remaining.isNegative || remaining == Duration.zero) {
          setState(() {
            _elapsed = Duration.zero;
            _status = CountdownStatus.finished;
          });
          _notifyStatus();
          widget.onFinish?.call();
          timer.cancel();
        } else {
          setState(() {
            _elapsed = remaining;
          });
          widget.onTick?.call(remaining);
        }
      });
    } else {
      // 正计时模式
      final startTime = DateTime.now();
      _status = CountdownStatus.running;
      _notifyStatus();

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _elapsed = DateTime.now().difference(startTime);
        });
        widget.onTick?.call(_elapsed);
      });
    }
  }

  /// 暂停计时。
  void pause() {
    if (_status != CountdownStatus.running) return;
    _timer?.cancel();
    setState(() {
      _status = CountdownStatus.paused;
    });
    _notifyStatus();
  }

  /// 恢复计时。
  void resume() {
    if (_status != CountdownStatus.paused) return;
    _status = CountdownStatus.idle;
    start();
  }

  /// 重置计时器。
  void reset() {
    _timer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _status = CountdownStatus.idle;
    });
    _notifyStatus();
    if (widget.autoStart) start();
  }

  void _notifyStatus() {
    widget.onStatusChanged?.call(_status);
  }

  /// 当前状态。
  CountdownStatus get status => _status;

  /// 格式化时间为指定模板。
  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final days = duration.inDays;

    final fmt = widget.format ?? (hours > 0 ? 'HH:mm:ss' : 'mm:ss');

    return fmt
        .replaceAll('DD', days.toString().padLeft(2, '0'))
        .replaceAll('HH', hours.toString().padLeft(2, '0'))
        .replaceAll('mm', minutes.toString().padLeft(2, '0'))
        .replaceAll('ss', seconds.toString().padLeft(2, '0'));
  }

  /// 将格式化后的时间拆分为数字与分隔符组件。
  List<InlineSpan> _buildSpans(String formatted, TextStyle? baseStyle) {
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    final digits = RegExp(r'\d');
    final digitStyle = widget.digitStyle ?? baseStyle;
    final sepStyle = widget.separatorStyle ?? baseStyle?.copyWith(
      color: baseStyle.color?.withAlpha(128),
    );

    for (var i = 0; i < formatted.length; i++) {
      final char = formatted[i];
      if (digits.hasMatch(char)) {
        buffer.write(char);
      } else {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer.toString(), style: digitStyle));
          buffer.clear();
        }
        spans.add(TextSpan(text: char, style: sepStyle));
      }
    }
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString(), style: digitStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final defaultStyle = widget.style ?? TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: park.colors.textPrimary,
      fontFamily: 'Inter',
    );

    final formatted = _formatTime(_elapsed);
    final spans = _buildSpans(formatted, defaultStyle);

    return Semantics(
      label: '倒计时: $formatted',
      value: formatted,
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: widget.textAlign,
      ),
    );
  }
}
