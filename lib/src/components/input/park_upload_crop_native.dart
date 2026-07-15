// Park Upload 图片裁剪 + 文件分片读取 — 原生平台实现。
//
// 使用 dart:io 的 File 读取文件字节，使用 dart:ui 进行图片裁剪。
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

/// 处理裁剪后的图片，返回 PNG 编码的字节数据。
///
/// [filePath] 原始图片路径。
/// [cropLeft] / [cropTop] / [cropWidth] / [cropHeight]
///   归一化裁剪区域（0.0 ~ 1.0），相对于原始图片尺寸。
/// [maxWidth] / [maxHeight] 输出最大尺寸（像素），为 null 时不限制。
Future<Uint8List> processCroppedImage(
  String filePath,
  double cropLeft,
  double cropTop,
  double cropWidth,
  double cropHeight,
  int? maxWidth,
  int? maxHeight,
) async {
  final File file = File(filePath);
  final Uint8List bytes = await file.readAsBytes();
  final Codec codec = await instantiateImageCodec(bytes);
  final FrameInfo frameInfo = await codec.getNextFrame();
  final Image image = frameInfo.image;

  final int origW = image.width;
  final int origH = image.height;

  // 计算裁剪区域（像素）
  final double pxLeft = cropLeft * origW;
  final double pxTop = cropTop * origH;
  final double pxWidth = cropWidth * origW;
  final double pxHeight = cropHeight * origH;

  // 计算输出尺寸
  int outW = pxWidth.round();
  int outH = pxHeight.round();

  if (maxWidth != null && outW > maxWidth) {
    outW = maxWidth;
    outH = (outW * pxHeight / pxWidth).round();
  }
  if (maxHeight != null && outH > maxHeight) {
    outH = maxHeight;
    outW = (outH * pxWidth / pxHeight).round();
  }

  outW = outW.clamp(1, 99999);
  outH = outH.clamp(1, 99999);

  // 使用 Canvas 绘制裁剪并缩放
  final PictureRecorder recorder = PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(pxLeft, pxTop, pxWidth, pxHeight),
    Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
    Paint(),
  );
  final Picture picture = recorder.endRecording();
  final Image resultImage = await picture.toImage(outW, outH);
  final ByteData? byteData =
      await resultImage.toByteData(format: ImageByteFormat.png);

  image.dispose();
  resultImage.dispose();

  return byteData?.buffer.asUint8List() ?? Uint8List(0);
}

/// 读取图片的原始尺寸（宽、高），用于裁剪对话框初始化。
Future<List<int>> readImageDimensions(String filePath) async {
  final File file = File(filePath);
  final Uint8List bytes = await file.readAsBytes();
  final Codec codec = await instantiateImageCodec(bytes);
  final FrameInfo frameInfo = await codec.getNextFrame();
  final Image image = frameInfo.image;
  final List<int> dims = <int>[image.width, image.height];
  image.dispose();
  return dims;
}

/// 读取文件的指定字节范围（分片上传用）。
///
/// [filePath] 文件路径。
/// [start] 起始字节偏移（包含）。
/// [end] 结束字节偏移（不包含）。
Future<List<int>> readFileChunk(
    String filePath, int start, int end) async {
  final File file = File(filePath);
  final RandomAccessFile raf = await file.open();
  try {
    await raf.setPosition(start);
    final int length = (end - start).clamp(0, await file.length() - start);
    return raf.readSync(length);
  } finally {
    raf.close();
  }
}

/// 读取整个文件内容为字节列表（图片裁剪用）。
Future<Uint8List> readFileBytes(String filePath) async {
  final File file = File(filePath);
  return file.readAsBytes();
}
