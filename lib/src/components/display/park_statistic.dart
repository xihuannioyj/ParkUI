import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 统计数值组件（借鉴 Ant Design React `Statistic`）。
///
/// 以醒目大字展示一个数值，支持：
/// - 从 0 动画增长到目标值（[AnimationController] + [Curve]）；
/// - 小数精度（[precision]）与千分位分组（[groupSeparator]）；
/// - 前缀（[prefix]）/ 后缀（[suffix]）装饰；
/// - 标题（[title]，由构造函数参数暴露，组件内不硬编码文案）；
/// - 数值样式 [valueStyle] 走 `park.typography` 设计令牌；
/// - 语义化：[Semantics] 包裹，便于无障碍读取。
///
/// 零三方依赖，纯 Flutter 原生重写。
///
/// ```dart
/// ParkStatistic(
///   title: '活跃用户',
///   value: 112893,
///   prefix: Icon(Icons.people),
///   suffix: Text('人'),
/// )
/// ```
class ParkStatistic extends StatefulWidget {
  /// 目标数值（int / double 均可）。
  final num value;

  /// 标题文案（展示在数值上方）。由构造函数参数暴露，组件内不硬编码。
  final String? title;

  /// 前缀装饰（如图标、货币符号）。
  final Widget? prefix;

  /// 后缀装饰（如单位「人」「%」）。
  final Widget? suffix;

  /// 小数精度（固定小数位数）。为 null 时按数值实际精度展示。
  final int? precision;

  /// 千分位分组符，默认 ','。传空字符串可关闭分组。
  final String? groupSeparator;

  /// 小数点符号，默认 '.'。
  final String decimalSeparator;

  /// 数值文本样式。为 null 时取 `park.typography.h2` 令牌样式。
  final TextStyle? valueStyle;

  /// 标题文本样式。为 null 时取 `park.typography.caption` 令牌样式。
  final TextStyle? titleStyle;

  /// 是否启用从 0 到 value 的动画增长。默认 true。
  final bool animate;

  /// 动画时长。默认 800ms。
  final Duration duration;

  /// 动画曲线。默认 [Curves.easeOutCubic]。
  final Curve curve;

  /// 文本对齐方式。默认 [TextAlign.start]。
  final TextAlign textAlign;

  /// 主区域（标题 + 数值）的对齐，默认 [MainAxisAlignment.start]。
  final CrossAxisAlignment crossAxisAlignment;

  const ParkStatistic({
    super.key,
    required this.value,
    this.title,
    this.prefix,
    this.suffix,
    this.precision,
    this.groupSeparator = ',',
    this.decimalSeparator = '.',
    this.valueStyle,
    this.titleStyle,
    this.animate = true,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    this.textAlign = TextAlign.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  State<ParkStatistic> createState() => _ParkStatisticState();
}

class _ParkStatisticState extends State<ParkStatistic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _target;

  @override
  void initState() {
    super.initState();
    _target = widget.value.toDouble();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = _buildTween();
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  Animation<double> _buildTween() {
    return Tween<double>(begin: 0, end: _target).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void didUpdateWidget(covariant ParkStatistic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.curve != widget.curve) {
      _target = widget.value.toDouble();
      _animation = _buildTween();
    }
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller
          ..reset()
          ..forward();
      } else {
        _controller.value = 1;
      }
    } else if (oldWidget.value != widget.value && widget.animate) {
      // 目标值变化后重新从 0 增长（对齐「数值从 0 动画增长」）。
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 将数值格式化为带分组符与精度的字符串。
  String _formatNumber(double value) {
    final bool isNegative = value < 0;
    final double abs = value.abs();

    final String intStr;
    final String decStr;
    if (widget.precision != null) {
      // 边界防御：precision<0 时 toStringAsFixed 抛 RangeError。
      final int p = widget.precision! < 0 ? 0 : widget.precision!;
      final String fixed = abs.toStringAsFixed(p);
      final List<String> parts = fixed.split('.');
      intStr = parts[0];
      decStr = parts.length > 1 ? parts[1] : '';
    } else if (abs == abs.truncateToDouble()) {
      intStr = abs.truncate().toString();
      decStr = '';
    } else {
      final String s = abs.toString();
      // 小数值（如 1e-7）会显示科学计数法 "1e-7"：转固定精度并去尾零。
      if (s.contains('e') || s.contains('E')) {
        final List<String> parts = abs.toStringAsFixed(10).split('.');
        intStr = parts[0];
        decStr = _trimTrailingZeros(parts.length > 1 ? parts[1] : '');
      } else {
        final List<String> parts = s.split('.');
        intStr = parts[0];
        decStr = parts.length > 1 ? parts[1] : '';
      }
    }

    final String grouped = _groupDigits(intStr, widget.groupSeparator ?? ',');
    final String decimal =
        decStr.isEmpty ? '' : '${widget.decimalSeparator}$decStr';
    return '${isNegative ? '-' : ''}$grouped$decimal';
  }

  /// 去除小数尾零（如 "1000000000" → "1"）。
  String _trimTrailingZeros(String s) {
    var end = s.length;
    while (end > 0 && s[end - 1] == '0') end--;
    return s.substring(0, end);
  }

  /// 从右往左每 3 位插入分组符。
  String _groupDigits(String digits, String sep) {
    if (sep.isEmpty) return digits;
    final StringBuffer buf = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) buf.write(sep);
      buf.write(digits[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final TextStyle baseValueStyle =
        widget.valueStyle ?? park.typography.h2;
    final TextStyle baseTitleStyle = widget.titleStyle ??
        park.typography.caption.copyWith(color: park.colors.textSecondary);

    final Widget valueText = AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        final String text = _formatNumber(_animation.value);
        return Text(
          text,
          textAlign: widget.textAlign,
          style: baseValueStyle,
        );
      },
    );

    final List<Widget> rowChildren = <Widget>[
      if (widget.prefix != null) ...<Widget>[
        widget.prefix!,
        SizedBox(width: park.spacing.xs),
      ],
      Expanded(child: valueText),
      if (widget.suffix != null) ...<Widget>[
        SizedBox(width: park.spacing.xs),
        widget.suffix!,
      ],
    ];

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: <Widget>[
        if (widget.title != null && widget.title!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: park.spacing.xs),
            child: Text(
              widget.title!,
              style: baseTitleStyle,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: rowChildren,
        ),
      ],
    );

    // 无障碍：暴露标题与最终数值。
    return Semantics(
      container: true,
      label: widget.title,
      value: _formatNumber(_target),
      child: content,
    );
  }
}
