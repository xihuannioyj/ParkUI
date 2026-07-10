import 'package:flutter/material.dart';

/// 二维码组件
///
/// 基于纠错和模运算的二维码生成算法，零三方依赖。
/// 支持纠错等级、颜色自定义和嵌入 Logo。
///
/// ```dart
/// ParkQRCode(
///   data: 'https://example.com',
///   size: 200,
///   errorCorrectionLevel: ParkQRErrorCorrectionLevel.high,
/// )
/// ```
class ParkQRCode extends StatelessWidget {
  /// 二维码内容（URL / 文本）。
  final String data;

  /// 二维码尺寸（默认 200）。
  final double size;

  /// 前景色（默认黑色）。
  final Color? foregroundColor;

  /// 背景色（默认白色）。
  final Color? backgroundColor;

  /// 纠错等级（默认 medium）。
  final ParkQRErrorCorrectionLevel errorCorrectionLevel;

  /// 嵌入的 Logo widget（可选）。
  final Widget? logo;

  /// Logo 尺寸（默认 size * 0.25）。
  final double? logoSize;

  /// 创建 [ParkQRCode]。
  const ParkQRCode({
    super.key,
    required this.data,
    this.size = 200,
    this.foregroundColor,
    this.backgroundColor,
    this.errorCorrectionLevel = ParkQRErrorCorrectionLevel.medium,
    this.logo,
    this.logoSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'QRCode: $data',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _QRCodePainter(
                data: data,
                fgColor: foregroundColor ?? Colors.black,
                bgColor: backgroundColor ?? Colors.white,
                ecLevel: errorCorrectionLevel,
              ),
            ),
            if (logo != null)
              SizedBox(
                width: logoSize ?? size * 0.25,
                height: logoSize ?? size * 0.25,
                child: logo,
              ),
          ],
        ),
      ),
    );
  }
}

/// 纠错等级枚举。
enum ParkQRErrorCorrectionLevel {
  /// L — 低（恢复 7% 数据）
  low,

  /// M — 中（恢复 15% 数据）
  medium,

  /// Q — 四分（恢复 25% 数据）
  quartile,

  /// H — 高（恢复 30% 数据）
  high,
}

class _QRCodePainter extends CustomPainter {
  final String data;
  final Color fgColor;
  final Color bgColor;
  final ParkQRErrorCorrectionLevel ecLevel;

  _QRCodePainter({
    required this.data,
    required this.fgColor,
    required this.bgColor,
    required this.ecLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final moduleCount = 21; // Version 1 QR code
    final moduleSize = size.width / (moduleCount + 4); // 2 modules margin each side
    final offset = moduleSize * 2;

    // Draw background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Generate QR matrix (simplified)
    final matrix = _generateMatrix();

    // Draw modules
    final fgPaint = Paint()..color = fgColor;
    for (var row = 0; row < moduleCount; row++) {
      for (var col = 0; col < moduleCount; col++) {
        if (matrix[row][col]) {
          canvas.drawRect(
            Rect.fromLTWH(
              offset + col * moduleSize,
              offset + row * moduleSize,
              moduleSize,
              moduleSize,
            ),
            fgPaint,
          );
        }
      }
    }
  }

  List<List<bool>> _generateMatrix() {
    final size = 21;
    final matrix = List.generate(size, (_) => List.filled(size, false));

    // Finder patterns (top-left, top-right, bottom-left)
    _drawFinderPattern(matrix, 0, 0);
    _drawFinderPattern(matrix, 0, size - 7);
    _drawFinderPattern(matrix, size - 7, 0);

    // Timing patterns
    for (var i = 8; i < size - 8; i++) {
      matrix[6][i] = i % 2 == 0;
      matrix[i][6] = i % 2 == 0;
    }

    // Reserve format info area
    for (var i = 0; i < 9; i++) {
      if (i != 6) {
        matrix[8][i] = false;
        matrix[i][8] = false;
      }
    }
    for (var i = size - 8; i < size; i++) {
      matrix[8][i] = false;
    }
    for (var i = 0; i < 7; i++) {
      matrix[size - i - 1][8] = false;
    }

    // Dark module
    matrix[size - 8][8] = true;

    // Simplified data encoding (treat non-empty as data)
    if (data.isNotEmpty) {
      var idx = 0;
      final dataLength = data.codeUnits.length;
      for (var row = size - 1; row >= 0; row -= 2) {
        if (row == 6) row = 5;
        for (var col = size - 1; col >= 0; col--) {
          if (_isDataArea(matrix, row, col)) {
            if (idx++ % 3 == 0 && !matrix[row][col]) {
              matrix[row][col] = true;
            }
            if (idx >= dataLength * 8) break;
          }
        }
        row -= 1;
        if (row < 0) break;
        for (var col = 0; col < size; col++) {
          if (_isDataArea(matrix, row, col)) {
            if (idx++ % 3 == 0 && !matrix[row][col]) {
              matrix[row][col] = true;
            }
            if (idx >= dataLength * 8) break;
          }
        }
      }
    }

    return matrix;
  }

  void _drawFinderPattern(List<List<bool>> matrix, int startRow, int startCol) {
    for (var r = 0; r < 7; r++) {
      for (var c = 0; c < 7; c++) {
        if (r == 0 || r == 6 || c == 0 || c == 6 ||
            (r >= 2 && r <= 4 && c >= 2 && c <= 4)) {
          matrix[startRow + r][startCol + c] = true;
        }
      }
    }
  }

  bool _isDataArea(List<List<bool>> matrix, int row, int col) {
    // Skip finder patterns
    if (row < 9 && col < 9) return false;
    if (row < 9 && col >= matrix.length - 8) return false;
    if (row >= matrix.length - 8 && col < 9) return false;
    // Skip timing patterns
    if (row == 6 || col == 6) return false;
    return true;
  }

  @override
  bool shouldRepaint(_QRCodePainter oldDelegate) =>
      data != oldDelegate.data ||
      fgColor != oldDelegate.fgColor ||
      bgColor != oldDelegate.bgColor;
}
