import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/park_theme_data.dart';

/// 二维码组件
///
/// 基于 [qr_flutter] 进行真实 QR 编码（含 Reed-Solomon 纠错、数据掩码、
/// 格式与版本信息），可被标准扫码器正常识别。
/// 支持纠错等级、前景/背景色自定义，以及叠加 Logo。
///
/// > 注：本项目接受首个三方依赖 `qr_flutter`，组件库定位由「零依赖」调整为「最小依赖」。
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

  /// 叠加的 Logo widget（可选）。
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
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final Color bg = backgroundColor ?? park.colors.surface;
    final Color fg = foregroundColor ?? park.colors.textPrimary;

    // qr_flutter 要求 data 非空，空内容时回退为纯色占位。
    if (data.trim().isEmpty) {
      return Semantics(
        label: 'QR Code',
        child: SizedBox(
          width: size,
          height: size,
          child: Container(color: bg),
        ),
      );
    }

    return Semantics(
      label: 'QR Code',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            QrImageView(
              data: data,
              version: QrVersions.auto,
              size: size,
              padding: EdgeInsets.zero,
              foregroundColor: fg,
              backgroundColor: bg,
              errorCorrectionLevel: _toQrErrorLevel(errorCorrectionLevel),
              gapless: true,
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

  /// 将 [ParkQRErrorCorrectionLevel] 映射为 qr_flutter 的整型纠错等级。
  static int _toQrErrorLevel(ParkQRErrorCorrectionLevel level) {
    switch (level) {
      case ParkQRErrorCorrectionLevel.low:
        return QrErrorCorrectLevel.L;
      case ParkQRErrorCorrectionLevel.medium:
        return QrErrorCorrectLevel.M;
      case ParkQRErrorCorrectionLevel.quartile:
        return QrErrorCorrectLevel.Q;
      case ParkQRErrorCorrectionLevel.high:
        return QrErrorCorrectLevel.H;
    }
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
