// Park Upload 平台辅助 — 空实现（Web 回退）。
//
// 通过条件导入，在原生平台使用 dart:io 实现文件操作，
// 在 Web 平台使用本空实现。
import 'package:flutter/material.dart';

// TODO(token): 待组件重构为 Widget 后替换为 park.colors.textDisabled
const Color _kIconColor = Color(0xFF999999);

/// 构建本地文件图片控件。
///
/// 空实现：返回占位图标。
Widget buildFileImageWidget(String path,
    {double width = 80, double height = 80, BoxFit fit = BoxFit.cover}) {
  return const Center(
    child: Icon(Icons.image_not_supported_outlined,
        size: 28, color: _kIconColor),
  );
}

/// 提取文件名。
///
/// 空实现：使用 `/` 分隔（Web 路径约定）。
String fileNameFromPath(String path) {
  return path.split('/').last;
}
