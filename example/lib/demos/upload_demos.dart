import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Upload Demo
// =============================================================================

class UploadDemo extends StatefulWidget {
  const UploadDemo({super.key});

  @override
  State<UploadDemo> createState() => _UploadDemoState();
}

class _UploadDemoState extends State<UploadDemo> {
  List<ParkUploadFile> _imageFiles = [];
  List<ParkUploadFile> _fileList = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Upload 上传', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('文件上传，支持图片网格、文件列表、拖拽上传。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('图片网格模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkUpload(
          files: _imageFiles,
          imageOnly: true,
          maxCount: 6,
          onChanged: (files) => setState(() => _imageFiles = files),
          onRemove: (file) {
            setState(() => _imageFiles.remove(file));
          },
        ),
        const SizedBox(height: 24),

        ParkText('文件列表模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkUpload(
          files: _fileList,
          mode: ParkUploadMode.fileList,
          accept: const ['pdf', 'doc', 'docx'],
          maxSizeMB: 20,
          onChanged: (files) => setState(() => _fileList = files),
          onRemove: (file) {
            setState(() => _fileList.remove(file));
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
