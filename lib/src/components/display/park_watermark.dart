import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 水印组件
///
/// 在内容区域叠加半透明文字/图片水印，用于版权保护和敏感信息标识。
///
/// ```dart
/// ParkWatermark(
///   text: '机密文件',
///   child: contentWidget,
/// )
/// ```
class ParkWatermark extends StatelessWidget {
  /// 水印文字（与 [image] 二选一）。
  final String? text;

  /// 水印图片（与 [text] 二选一）。
  final Widget? image;

  /// 水印颜色（文字模式，默认 #0A2540 0.1）。
  final Color? color;

  /// 水印字号（文字模式，默认 14）。
  final double fontSize;

  /// 旋转角度（默认 -25 度）。
  final double rotate;

  /// 水印间距（横向，默认 120）。
  final double gapX;

  /// 水印间距（纵向，默认 100）。
  final double gapY;

  /// 被水印包裹的内容。
  final Widget child;

  const ParkWatermark({
    super.key,
    this.text,
    this.image,
    this.color,
    this.fontSize = 14,
    this.rotate = -25,
    this.gapX = 120,
    this.gapY = 100,
    required this.child,
  }) : assert(text != null || image != null, 'text 或 image 至少提供一个');

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final fgColor = color ?? park.colors.textPrimary.withAlpha(26);

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WatermarkPainter(
                text: text,
                color: fgColor,
                fontSize: fontSize,
                rotate: rotate,
                gapX: gapX,
                gapY: gapY,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String? text;
  final Color color;
  final double fontSize;
  final double rotate;
  final double gapX;
  final double gapY;

  _WatermarkPainter({
    required this.text,
    required this.color,
    required this.fontSize,
    required this.rotate,
    required this.gapX,
    required this.gapY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text == null || text!.isEmpty) return;
    final paint = Paint()..color = color;
    final radians = rotate * math.pi / 180;

    canvas.save();
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();

    final halfW = textPainter.width / 2;
    final halfH = textPainter.height / 2;

    for (double y = -halfH; y < size.height + gapY; y += gapY) {
      for (double x = -halfW; x < size.width + gapX; x += gapX) {
        canvas.save();
        canvas.translate(x + gapX / 2, y + gapY / 2);
        canvas.rotate(radians);
        textPainter.paint(canvas, Offset(-halfW, -halfH));
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) =>
      text != old.text || color != old.color || fontSize != old.fontSize || rotate != old.rotate;
}
