import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
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
class ParkWatermark extends StatefulWidget {
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
  State<ParkWatermark> createState() => _ParkWatermarkState();
}

class _ParkWatermarkState extends State<ParkWatermark> {
  /// GlobalKey for the RepaintBoundary wrapping the image widget.
  final GlobalKey _imageKey = GlobalKey();

  /// Captured ui.Image for tiling on canvas.
  ui.Image? _capturedImage;

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      WidgetsBinding.instance.addPostFrameCallback(_captureImage);
    }
  }

  @override
  void didUpdateWidget(ParkWatermark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != null && widget.image != oldWidget.image) {
      WidgetsBinding.instance.addPostFrameCallback(_captureImage);
    }
  }

  /// Capture the image widget as a ui.Image via RenderRepaintBoundary.
  void _captureImage(_) {
    if (!mounted) return;
    final renderObject = _imageKey.currentContext?.findRenderObject();
    if (renderObject is RenderRepaintBoundary) {
      final dpr = MediaQuery.of(context).devicePixelRatio;
      renderObject.toImage(pixelRatio: dpr).then((img) {
        if (mounted) {
          setState(() => _capturedImage = img);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final fgColor = widget.color ?? park.colors.textPrimary.withAlpha(26);

    return Semantics(
      label: widget.text ?? '水印',
      container: true,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: _buildOverlay(fgColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the watermark overlay based on whether text or image is provided.
  Widget _buildOverlay(Color fgColor) {
    // Image watermark mode
    if (widget.image != null) {
      return Stack(
        children: [
          // Hidden render of the image widget for capture via RepaintBoundary.
          Opacity(
            opacity: 0,
            child: RepaintBoundary(
              key: _imageKey,
              child: widget.image,
            ),
          ),
          // Tiled image watermark on canvas (once captured).
          if (_capturedImage != null)
            CustomPaint(
              painter: _ImageWatermarkPainter(
                image: _capturedImage!,
                rotate: widget.rotate,
                gapX: widget.gapX,
                gapY: widget.gapY,
              ),
              size: Size.infinite,
            ),
        ],
      );
    }

    // Text watermark mode (existing implementation)
    return CustomPaint(
      painter: _WatermarkPainter(
        text: widget.text,
        color: fgColor,
        fontSize: widget.fontSize,
        rotate: widget.rotate,
        gapX: widget.gapX,
        gapY: widget.gapY,
      ),
      size: Size.infinite,
    );
  }
}

/// Paints tiled text watermark on the canvas.
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

/// Paints tiled image watermark on the canvas using [canvas.drawImageRect].
///
/// The [image] is a [ui.Image] captured from the watermark's image widget
/// via [RenderRepaintBoundary.toImage]. It is tiled across the canvas with
/// rotation and spacing applied.
class _ImageWatermarkPainter extends CustomPainter {
  final ui.Image image;
  final double rotate;
  final double gapX;
  final double gapY;

  _ImageWatermarkPainter({
    required this.image,
    required this.rotate,
    required this.gapX,
    required this.gapY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radians = rotate * math.pi / 180;
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();

    if (imgW == 0 || imgH == 0) return;

    // Calculate the bounding box of the rotated image to ensure full coverage.
    final cosA = math.cos(radians).abs();
    final sinA = math.sin(radians).abs();
    final rotatedW = imgW * cosA + imgH * sinA;
    final rotatedH = imgW * sinA + imgH * cosA;

    final stepX = rotatedW + gapX;
    final stepY = rotatedH + gapY;

    final srcRect = Rect.fromLTWH(0, 0, imgW, imgH);

    // Tile across the canvas with extra margin for rotation overflow.
    for (double y = -rotatedH; y < size.height + stepY; y += stepY) {
      for (double x = -rotatedW; x < size.width + stepX; x += stepX) {
        canvas.save();
        canvas.translate(x + stepX / 2, y + stepY / 2);
        canvas.rotate(radians);
        final dstRect = Rect.fromLTWH(-imgW / 2, -imgH / 2, imgW, imgH);
        canvas.drawImageRect(image, srcRect, dstRect, Paint());
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ImageWatermarkPainter old) =>
      image != old.image || rotate != old.rotate || gapX != old.gapX || gapY != old.gapY;
}
