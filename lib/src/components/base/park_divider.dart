import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 分割线方向
enum ParkDividerAxis {
  /// 水平分割线
  horizontal,

  /// 垂直分割线
  vertical,
}

/// Park 分割线文字对齐方式
enum ParkDividerTextAlign {
  /// 靠左
  left,

  /// 居中
  center,

  /// 靠右
  right,
}

/// Park 分割线
///
/// 支持水平/垂直方向、自定义颜色/粗细/间距，以及带文字的水平分割线。
/// 可选虚线渲染。
///
/// ```dart
/// ParkDivider()
/// ParkDivider(color: Colors.red, thickness: 2)
/// ParkDivider(dashed: true)
/// ParkDivider.withText('或者')
/// ParkDivider.withText('或者', textAlign: ParkDividerTextAlign.left)
/// ParkDivider.withText('设置', icon: Icons.settings)
/// ParkDivider(axis: ParkDividerAxis.vertical, height: 24)
/// ```
class ParkDivider extends StatelessWidget {
  /// 分割线方向
  final ParkDividerAxis axis;

  /// 分割线颜色
  final Color? color;

  /// 分割线粗细（像素）
  final double thickness;

  /// 水平方向的缩进（左）
  final double indent;

  /// 水平方向的缩进（右）
  final double endIndent;

  /// 垂直方向时的高度
  final double? verticalHeight;

  /// 是否渲染为虚线。
  ///
  /// 为 true 时使用 [CustomPaint] 绘制虚线。
  final bool dashed;

  /// 虚线段长度（仅 [dashed] 为 true 时有效）
  final double dashWidth;

  /// 虚线间隔（仅 [dashed] 为 true 时有效）
  final double dashGap;

  /// 是否渲染为点线（圆点样式，区别于 [dashed] 的短线段）
  final bool dotted;

  /// 是否以正文样式渲染分割线文字（不使用小号次要文字样式）
  final bool plain;

  const ParkDivider({
    super.key,
    this.axis = ParkDividerAxis.horizontal,
    this.color,
    this.thickness = 0.5,
    this.indent = 0,
    this.endIndent = 0,
    this.verticalHeight,
    this.dashed = false,
    this.dashWidth = 4.0,
    this.dashGap = 3.0,
    this.dotted = false,
    this.plain = false,
  });

  /// 带文字的分割线（仅水平方向有效）
  static Widget withText(
    String text, {
    Key? key,
    Color? color,
    Color? textColor,
    double thickness = 0.5,
    double indent = 16,
    double endIndent = 16,
    TextStyle? textStyle,
    ParkDividerTextAlign textAlign = ParkDividerTextAlign.center,
    IconData? icon,
    bool dashed = false,
    double dashWidth = 4.0,
    double dashGap = 3.0,
    bool dotted = false,
    bool plain = false,
  }) {
    return _ParkDividerWithText(
      key: key,
      text: text,
      color: color,
      textColor: textColor,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      textStyle: textStyle,
      textAlign: textAlign,
      icon: icon,
      dashed: dashed,
      dashWidth: dashWidth,
      dashGap: dashGap,
      dotted: dotted,
      plain: plain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final dividerColor = color ?? park.colors.divider;

    Widget result;

    if (axis == ParkDividerAxis.vertical) {
      if (dotted) {
        result = SizedBox(
          width: thickness,
          height: verticalHeight ?? 16,
          child: CustomPaint(
            painter: _DottedLinePainter(
              color: dividerColor,
              strokeWidth: thickness,
              dotSpacing: dashGap + dashWidth,
              axis: Axis.vertical,
            ),
          ),
        );
      } else if (dashed) {
        result = SizedBox(
          width: thickness,
          height: verticalHeight ?? 16,
          child: CustomPaint(
            painter: _DashedLinePainter(
              color: dividerColor,
              strokeWidth: thickness,
              dashWidth: dashWidth,
              dashGap: dashGap,
              axis: Axis.vertical,
            ),
          ),
        );
      } else {
        result = Container(
          width: thickness,
          height: verticalHeight ?? 16,
          color: dividerColor,
        );
      }
    } else if (dotted) {
      result = Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: SizedBox(
          height: thickness,
          child: CustomPaint(
            painter: _DottedLinePainter(
              color: dividerColor,
              strokeWidth: thickness,
              dotSpacing: dashGap + dashWidth,
              axis: Axis.horizontal,
            ),
          ),
        ),
      );
    } else if (dashed) {
      result = Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: SizedBox(
          height: thickness,
          child: CustomPaint(
            painter: _DashedLinePainter(
              color: dividerColor,
              strokeWidth: thickness,
              dashWidth: dashWidth,
              dashGap: dashGap,
              axis: Axis.horizontal,
            ),
          ),
        ),
      );
    } else {
      result = Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: Container(
          height: thickness,
          color: dividerColor,
        ),
      );
    }

    return Semantics(
      child: result,
    );
  }
}

/// 内部：虚线绘制画笔
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final Axis axis;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // 边界防御：dashWidth + dashGap <= 0 时 while 循环永不前进会卡死 UI，
    // 退化为实线。
    final double step = dashWidth + dashGap;
    if (step <= 0) {
      if (axis == Axis.horizontal) {
        canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
      } else {
        canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
      }
      return;
    }

    if (axis == Axis.horizontal) {
      final y = size.height / 2;
      double startX = 0;
      while (startX < size.width) {
        final endX = (startX + dashWidth).clamp(0.0, size.width);
        canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
        startX += step;
      }
    } else {
      final x = size.width / 2;
      double startY = 0;
      while (startY < size.height) {
        final endY = (startY + dashWidth).clamp(0.0, size.height);
        canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
        startY += step;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.axis != axis;
  }
}

/// 内部：点线绘制画笔（圆点样式）
class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dotSpacing;
  final Axis axis;

  _DottedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dotSpacing,
    required this.axis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotRadius = strokeWidth * 1.0;
    final spacing = dotSpacing > 0 ? dotSpacing : 6.0;

    if (axis == Axis.horizontal) {
      final y = size.height / 2;
      double x = 0;
      while (x < size.width) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
        x += spacing;
      }
    } else {
      final x = size.width / 2;
      double y = 0;
      while (y < size.height) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
        y += spacing;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dotSpacing != dotSpacing ||
        oldDelegate.axis != axis;
  }
}

/// 内部用：带文字的水平分割线
class _ParkDividerWithText extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final double thickness;
  final double indent;
  final double endIndent;
  final TextStyle? textStyle;
  final ParkDividerTextAlign textAlign;
  final IconData? icon;
  final bool dashed;
  final double dashWidth;
  final double dashGap;
  final bool dotted;
  final bool plain;

  const _ParkDividerWithText({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.thickness = 0.5,
    this.indent = 16,
    this.endIndent = 16,
    this.textStyle,
    this.textAlign = ParkDividerTextAlign.center,
    this.icon,
    this.dashed = false,
    this.dashWidth = 4.0,
    this.dashGap = 3.0,
    this.dotted = false,
    this.plain = false,
  });

  Widget _buildLine(Color dividerColor) {
    if (dotted) {
      return Expanded(
        child: SizedBox(
          height: thickness,
          child: CustomPaint(
            painter: _DottedLinePainter(
              color: dividerColor,
              strokeWidth: thickness,
              dotSpacing: dashGap + dashWidth,
              axis: Axis.horizontal,
            ),
          ),
        ),
      );
    }
    if (dashed) {
      return Expanded(
        child: SizedBox(
          height: thickness,
          child: CustomPaint(
            painter: _DashedLinePainter(
              color: dividerColor,
              strokeWidth: thickness,
              dashWidth: dashWidth,
              dashGap: dashGap,
              axis: Axis.horizontal,
            ),
          ),
        ),
      );
    }
    return Expanded(
      child: Container(height: thickness, color: dividerColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final dividerColor = color ?? park.colors.divider;
    final fgColor = textColor ?? park.colors.textSecondary;

    final textWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: park.spacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fgColor),
            SizedBox(width: park.spacing.xs),
          ],
          Text(
            text,
            style: textStyle ??
                TextStyle(
                  color: fgColor,
                  fontSize: plain
                      ? park.typography.sizeBody
                      : park.typography.sizeCaption,
                ),
          ),
        ],
      ),
    );

    return Semantics(
      child: Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: Row(
          children: [
            switch (textAlign) {
              ParkDividerTextAlign.left => SizedBox(width: park.spacing.xl),
              ParkDividerTextAlign.center => _buildLine(dividerColor),
              ParkDividerTextAlign.right => const Spacer(),
            },
            textWidget,
            switch (textAlign) {
              ParkDividerTextAlign.left => const Spacer(),
              ParkDividerTextAlign.center => _buildLine(dividerColor),
              ParkDividerTextAlign.right => SizedBox(width: park.spacing.xl),
            },
          ],
        ),
      ),
    );
  }
}
