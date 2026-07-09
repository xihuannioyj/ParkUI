// Park Upload 平台辅助 — Web 平台实现。
//
// Web 环境无 dart:io，使用 / 作为路径分隔符。
import 'package:flutter/material.dart';

/// 构建本地文件图片控件。
///
/// Web 实现：返回占位图标（Web 无法直接访问本地文件路径）。
Widget buildFileImageWidget(String path,
    {double width = 80, double height = 80, BoxFit fit = BoxFit.cover}) {
  return const Center(
    child: Icon(Icons.image_not_supported_outlined,
        size: 28, color: Color(0xFF999999)),
  );
}

/// 提取文件名。
///
/// Web 实现：使用 / 分隔（Web 路径约定）。
String fileNameFromPath(String path) {
  return path.split('/').last;
}
