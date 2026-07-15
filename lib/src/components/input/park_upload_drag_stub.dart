// Park Upload 拖拽 — 空实现（非 Web 平台）。
//
// 通过条件导入，在非 Web 平台使用本空实现。
import 'package:flutter/material.dart';

import 'park_upload.dart';

/// Web 浏览器拖拽事件监听组件（空实现）。
///
/// 非 Web 平台：直接透传 child，不处理任何拖拽事件。
class ParkUploadWebDragTarget extends StatelessWidget {
  const ParkUploadWebDragTarget({
    super.key,
    required this.child,
    this.onDragHoverChange,
    this.onDropFiles,
  });

  final Widget child;
  final void Function(bool hovering)? onDragHoverChange;
  final void Function(List<ParkDropFile> files)? onDropFiles;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
