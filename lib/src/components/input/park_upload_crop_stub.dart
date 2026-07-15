// Park Upload 图片裁剪 + 文件分片读取 — Web 平台桩实现。
//
// 分片读取和图片裁剪功能仅原生平台可用，Web 端调用时抛出异常。
import 'dart:typed_data';

/// Web 端不支持图片裁剪处理。
Future<Uint8List> processCroppedImage(
  String filePath,
  double cropLeft,
  double cropTop,
  double cropWidth,
  double cropHeight,
  int? maxWidth,
  int? maxHeight,
) async {
  throw UnsupportedError('Image cropping is not supported on web platform.');
}

/// Web 端不支持文件分片读取。
Future<List<int>> readFileChunk(
    String filePath, int start, int end) async {
  throw UnsupportedError(
      'Chunked file reading is not supported on web platform.');
}

/// Web 端不支持文件字节读取。
Future<Uint8List> readFileBytes(String filePath) async {
  throw UnsupportedError(
      'File byte reading is not supported on web platform.');
}

/// Web 端不支持读取图片尺寸。
Future<List<int>> readImageDimensions(String filePath) async {
  throw UnsupportedError(
      'Image dimension reading is not supported on web platform.');
}
