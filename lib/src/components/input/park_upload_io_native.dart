// Park Upload 平台辅助 — 原生平台实现。
//
// 使用 dart:io 的 File / Platform 提供本地文件图片加载。
import 'dart:io';

import 'package:flutter/material.dart';

// TODO(token): 待组件重构为 Widget 后替换为 park.colors.textDisabled
const Color _kIconColor = Color(0xFF999999);

/// 构建本地文件图片控件。
///
/// 原生实现：使用 Image.file + dart:io File。
Widget buildFileImageWidget(String path,
    {double width = 80, double height = 80, BoxFit fit = BoxFit.cover}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => const Center(
      child: Icon(Icons.broken_image_outlined,
          size: 28, color: _kIconColor),
    ),
  );
}

/// 提取文件名。
///
/// 原生实现：使用 Platform.pathSeparator 适配操作系统。
String fileNameFromPath(String path) {
  return path.split(Platform.pathSeparator).last;
}
