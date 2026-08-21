// Park Upload 平台辅助 — Web 平台实现。
//
// Web 环境无 dart:io，使用 / 作为路径分隔符。
import 'package:flutter/material.dart';

// TODO(token): 待组件重构为 Widget 后替换为 park.colors.textDisabled
const Color _kIconColor = Color(0xFF999999);

/// 构建本地文件图片控件。
///
/// Web 实现：返回占位图标（Web 无法直接访问本地文件路径）。
Widget buildFileImageWidget(String path,
    {double width = 80, double height = 80, BoxFit fit = BoxFit.cover}) {
  return const Center(
    child: Icon(Icons.image_not_supported_outlined,
        size: 28, color: _kIconColor),
  );
}

/// 提取文件名。
///
/// Web 实现：使用 / 分隔（Web 路径约定）。
String fileNameFromPath(String path) {
  return path.split('/').last;
}

/// 读取文件前 [maxBytes] 字节用于魔数校验。
///
/// Web 实现：无法通过本地路径访问文件字节，返回 null（调用方会跳过魔数校验，
/// 与 web 无 dart:io 的约束一致）。
Future<List<int>?> readMagicBytes(String path, {int maxBytes = 12}) async {
  return null;
}
