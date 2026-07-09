// Park 平台图片操作抽象接口。
//
// 设计为"接口在包内、实现由 app 注入"的解耦模式：
// - 抽象类与默认 stub 实现均位于 park_ui 包内，确保 park_ui 不依赖 dart:io /
//   image_picker / image_cropper / mobile_scanner 等平台包；
// - app 在启动时通过 [setInstance] 注入原生 / Web 实现；未注入时回退到 stub
//   （"暂不支持"占位 / 返回 null），保证 park_ui 可独立编译与单元测试。
import 'package:flutter/material.dart';

/// 图片操作结果。
///
/// [bytes] 图片字节数据（用于 Image.memory 展示）。
/// [path] 本地文件路径（仅原生平台有值，用于表单值存储）。
class ParkImagePickResult {
  /// 图片字节数据。
  final List<int>? bytes;

  /// 本地文件路径。
  final String? path;

  /// 创建图片操作结果。
  const ParkImagePickResult({this.bytes, this.path});

  /// 空结果（用户取消或平台不支持）。
  static const ParkImagePickResult empty = ParkImagePickResult();
}

/// 扫码器句柄 — 允许扫码器内部关闭外部 Overlay。
abstract class ParkScannerOverlayHandle {
  /// 关闭扫码浮层。
  void close();
}

/// 平台图片服务抽象。
///
/// 封装所有依赖 dart:io 或原生插件的图片 / 扫码操作，
/// 让上层 Widget 无需直接导入 dart:io 或原生包。
///
/// 解耦方式：
/// - [instance] 返回当前生效实现（默认是 [_StubImageService]）；
/// - app 通过 [setInstance] 注入原生 / Web 实现（如 `_NativeImageService()`）；
/// - 网络图片预览通过 [buildNetworkImage] 暴露可插拔 builder，
///   默认回退到 [Image.network]，app 可注入 cached_network_image 等实现。
abstract class ParkFormImageService {
  /// 当前生效实现（默认回退到 [_StubImageService]）。
  static ParkFormImageService _instance = _StubImageService();

  /// 获取当前生效实现。
  ///
  /// 若 app 已通过 [setInstance] 注入自定义实现，则返回该实现；
  /// 否则返回默认 stub（"暂不支持"）。
  static ParkFormImageService instance() => _instance;

  /// 注入自定义实现（app 启动时调用，如原生图片 / 扫码服务）。
  ///
  /// 示例（app 侧）：
  /// ```dart
  /// ParkFormImageService.setInstance(_NativeImageService());
  /// ```
  static void setInstance(ParkFormImageService service) {
    _instance = service;
  }

  /// 网络图片构建器（可插拔）。
  ///
  /// 为 null 时 [buildNetworkImage] 回退到 [Image.network]。
  /// app 可注入 cached_network_image 等实现以获得缓存 / 占位能力。
  static Widget Function(
    String url, {
    double? height,
    double? width,
    BoxFit fit,
  })? networkImageBuilder;

  /// 构建网络图片预览。
  ///
  /// [url] 图片地址。
  /// 优先使用 [networkImageBuilder]；未注入时回退到 [Image.network]。
  static Widget buildNetworkImage(
    String url, {
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    final Widget Function(String url, {double? height, double? width, BoxFit fit})?
        builder = networkImageBuilder;
    if (builder != null) {
      return builder(url, height: height, width: width, fit: fit);
    }
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
    );
  }

  /// 从本地文件路径读取图片字节。
  ///
  /// 返回 null 表示读取失败。
  Future<List<int>?> loadImageBytes(String path);

  /// 从相册选择图片。
  ///
  /// 返回 null 表示用户取消或平台不支持。
  Future<ParkImagePickResult?> pickFromGallery();

  /// 从相机拍照。
  ///
  /// 返回 null 表示用户取消或平台不支持。
  Future<ParkImagePickResult?> pickFromCamera();

  /// 裁剪图片。
  ///
  /// [sourcePath] 原图路径。
  /// 返回 null 表示用户取消或平台不支持。
  Future<ParkImagePickResult?> cropImage(String sourcePath);

  /// 构建扫码器控件（仅原生平台提供真实实现）。
  Widget buildScannerWidget({
    required String? currentValue,
    required ValueChanged<String> onScan,
    required String simulatedValue,
  });

  /// 构建扫码器浮层内容（仅原生平台提供真实实现）。
  Widget buildScannerOverlayContent({
    required ParkScannerOverlayHandle handle,
    required ValueChanged<String> onScan,
    required String simulatedValue,
  });
}

/// 默认图片服务实现（stub）。
///
/// 由 [ParkFormImageService._instance] 作为默认实现持有。
///
/// 历史上该类定义在独立的 `park_form_image_service_stub.dart` 中，但因该文件
/// 反向导入本文件造成循环依赖，导致解析期 [_StubImageService] 不可见。
/// 现已合并到本文件末尾，打破循环、消除编译错误，且 park_ui 仍可独立编译。
class _StubImageService implements ParkFormImageService {
  @override
  Future<List<int>?> loadImageBytes(String path) async => null;

  @override
  Future<ParkImagePickResult?> pickFromGallery() async => null;

  @override
  Future<ParkImagePickResult?> pickFromCamera() async => null;

  @override
  Future<ParkImagePickResult?> cropImage(String sourcePath) async => null;

  @override
  Widget buildScannerWidget({
    String? currentValue,
    required ValueChanged<String> onScan,
    required String simulatedValue,
  }) {
    return const _UnsupportedPlaceholder();
  }

  @override
  Widget buildScannerOverlayContent({
    required ParkScannerOverlayHandle handle,
    required ValueChanged<String> onScan,
    required String simulatedValue,
  }) {
    return const _UnsupportedPlaceholder();
  }
}

/// Web / 不支持场景的占位控件。
class _UnsupportedPlaceholder extends StatelessWidget {
  const _UnsupportedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('此功能在当前平台暂不支持')),
    );
  }
}
