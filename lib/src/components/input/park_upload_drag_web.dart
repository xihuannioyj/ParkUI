// Park Upload 拖拽 — Web 平台实现。
//
// 通过 package:web 监听浏览器原生拖拽事件，捕获 File 对象。
// 使用 GlobalKey 定位当前组件的渲染区域，判断拖放是否落在区域内。
// B82c: 从 dart:html 迁移到 package:web + dart:js_interop。
import 'package:web/web.dart' as web;
import 'dart:js_interop';

import 'package:flutter/material.dart';

import 'park_upload.dart';

/// Web 浏览器拖拽事件监听组件。
///
/// 在 Flutter Web 中监听原始 HTML 文档的 dragover / drop 事件，
/// 当文件拖入组件区域时触发回调。
class ParkUploadWebDragTarget extends StatefulWidget {
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
  State<ParkUploadWebDragTarget> createState() =>
      _ParkUploadWebDragTargetState();
}

class _ParkUploadWebDragTargetState extends State<ParkUploadWebDragTarget> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'park_upload_web_drag');
  web.EventListener? _dragOverHandler;
  web.EventListener? _dragLeaveHandler;
  web.EventListener? _dropHandler;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _dragOverHandler = ((web.Event event) {
      final dragEvent = event as web.DragEvent;
      if (_isInsideWidget(dragEvent.clientX, dragEvent.clientY)) {
        dragEvent.preventDefault();
        if (!_hovering) {
          _hovering = true;
          widget.onDragHoverChange?.call(true);
        }
      } else {
        if (_hovering) {
          _hovering = false;
          widget.onDragHoverChange?.call(false);
        }
      }
    }).toJS;

    _dragLeaveHandler = ((web.Event event) {
      if (_hovering) {
        _hovering = false;
        widget.onDragHoverChange?.call(false);
      }
    }).toJS;

    _dropHandler = ((web.Event event) {
      final dragEvent = event as web.DragEvent;
      if (_isInsideWidget(dragEvent.clientX, dragEvent.clientY)) {
        dragEvent.preventDefault();
        _hovering = false;
        widget.onDragHoverChange?.call(false);

        final List<ParkDropFile> files = <ParkDropFile>[];
        final fileList = dragEvent.dataTransfer?.files;
        if (fileList != null) {
          for (int i = 0; i < fileList.length; i++) {
            final file = fileList.item(i);
            if (file != null) {
              files.add(ParkDropFile(name: file.name, path: null));
            }
          }
        }
        if (files.isNotEmpty) {
          widget.onDropFiles?.call(files);
        }
      }
    }).toJS;

    web.document.addEventListener('dragover', _dragOverHandler!);
    web.document.addEventListener('dragleave', _dragLeaveHandler!);
    web.document.addEventListener('drop', _dropHandler!);
  }

  bool _isInsideWidget(int clientX, int clientY) {
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return false;

    final Offset topLeft = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    return clientX >= topLeft.dx &&
        clientX <= topLeft.dx + size.width &&
        clientY >= topLeft.dy &&
        clientY <= topLeft.dy + size.height;
  }

  @override
  void dispose() {
    if (_dragOverHandler != null) {
      web.document.removeEventListener('dragover', _dragOverHandler!);
    }
    if (_dragLeaveHandler != null) {
      web.document.removeEventListener('dragleave', _dragLeaveHandler!);
    }
    if (_dropHandler != null) {
      web.document.removeEventListener('drop', _dropHandler!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _childKey, child: widget.child);
  }
}
