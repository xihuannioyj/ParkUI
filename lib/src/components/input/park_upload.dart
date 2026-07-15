import 'dart:typed_data';
import 'dart:ui' show PathMetric;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'park_upload_io_stub.dart'
    if (dart.library.io) 'park_upload_io_native.dart'
    if (dart.library.html) 'park_upload_io_web.dart';
import 'park_upload_drag_stub.dart'
    if (dart.library.html) 'park_upload_drag_web.dart';
import 'park_upload_crop_stub.dart'
    if (dart.library.io) 'park_upload_crop_native.dart';

import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';

/// 上传文件状态。
enum ParkUploadFileStatus {
  /// 等待上传。
  pending,

  /// 上传中。
  uploading,

  /// 上传完成。
  done,

  /// 上传失败。
  error,
}

/// 上传组件展示模式。
enum ParkUploadMode {
  /// 图片网格模式。
  imageGrid,

  /// 文件列表模式。
  fileList,

  /// 混合模式（当前按列表优先展示）。
  mixed,
}

/// 上传文件列表展示类型（AntD / TDesign 兼容）。
enum ParkUploadListType {
  /// 文本模式：文件名 + 进度条。
  text,

  /// 图片模式：缩略图 + 文件名。
  picture,

  /// 卡片模式：网格缩略图（类似 imageGrid）。
  pictureCard,
}

/// 上传文件数据。
class ParkUploadFile {
  /// 本地文件路径。
  final String path;

  /// 远程 URL（上传完成后赋值）。
  final String? url;

  /// 缩略图路径（图片类型时使用）。
  final String? thumbnailPath;

  /// 上传状态。
  final ParkUploadFileStatus status;

  /// 上传进度（0.0 ~ 1.0）。
  final double progress;

  /// 文件大小（字节）。
  final int? sizeBytes;

  /// 已完成上传的分片索引列表（分片续传用）。
  /// / List of completed chunk indices (for chunked upload resume).
  final List<int> completedChunks;

  /// 总分片数（分片续传用）。
  /// / Total number of chunks (for chunked upload).
  final int? totalChunks;

  /// 断点续传偏移：已成功上传的分片数。
  /// / Resume offset: number of chunks already uploaded.
  final int chunkResumeOffset;

  const ParkUploadFile({
    required this.path,
    this.url,
    this.thumbnailPath,
    this.status = ParkUploadFileStatus.pending,
    this.progress = 0.0,
    this.sizeBytes,
    this.completedChunks = const <int>[],
    this.totalChunks,
    this.chunkResumeOffset = 0,
  });

  ParkUploadFile copyWith({
    String? path,
    String? url,
    String? thumbnailPath,
    ParkUploadFileStatus? status,
    double? progress,
    int? sizeBytes,
    List<int>? completedChunks,
    int? totalChunks,
    int? chunkResumeOffset,
  }) {
    return ParkUploadFile(
      path: path ?? this.path,
      url: url ?? this.url,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      completedChunks: completedChunks ?? this.completedChunks,
      totalChunks: totalChunks ?? this.totalChunks,
      chunkResumeOffset: chunkResumeOffset ?? this.chunkResumeOffset,
    );
  }
}

/// 拖拽上传时传递的文件数据。
///
/// 跨平台兼容：Web 端来源于 [dart:html.File]，原生端来源于系统拖放。
class ParkDropFile {
  /// 文件名。
  final String name;

  /// 本地路径（原生平台可用，Web 平台为 null）。
  final String? path;

  const ParkDropFile({required this.name, this.path});
}

/// Park 文件上传组件。
///
/// 面向动态表单场景增强：
///
/// - 支持图片网格 / 文件列表 / 混合模式
/// - 支持文件类型限制
/// - 支持最大文件大小限制
/// - 支持上传前校验
/// - 支持失败重试
/// - 支持预览与删除能力控制
/// - 支持拖拽上传（原生 DragTarget + Web onDragOver/onDrop）
/// - 支持内部文件选择（未提供 [onAdd] 时自动使用系统文件选择器）
/// - 支持自定义上传请求（[customRequest]）
class ParkUpload extends StatefulWidget {
  /// 已选文件列表。
  final List<ParkUploadFile> files;

  /// 最大文件数量。
  final int maxCount;

  /// 添加文件回调（由外部触发文件选择器）。
  ///
  /// 未提供时使用内部文件选择逻辑。
  final VoidCallback? onAdd;

  /// 移除文件回调。
  final ValueChanged<ParkUploadFile>? onRemove;

  /// 预览文件回调。
  final ValueChanged<ParkUploadFile>? onPreview;

  /// 上传失败重试回调。
  final ValueChanged<ParkUploadFile>? onRetry;

  /// 文件列表变化回调（内部文件选择 / 上传完成时触发）。
  final ValueChanged<List<ParkUploadFile>>? onChanged;

  /// 展示模式。
  final ParkUploadMode mode;

  /// 允许的文件后缀列表，如 `['jpg', 'png', 'pdf']`。
  final List<String>? accept;

  /// 最大文件大小（MB）。默认 50MB。
  ///
  /// 设为 null 表示不限制文件大小。
  final double? maxSizeMB;

  /// 是否只允许图片文件。
  final bool imageOnly;

  /// 上传前校验器，返回错误文案表示不通过。
  final String? Function(ParkUploadFile file)? beforeAddValidator;

  /// 是否允许删除。
  final bool removable;

  /// 是否允许预览。
  final bool previewable;

  /// 是否启用拖拽上传区域。为 true 时整个上传区域接受拖放文件，
  /// 拖拽悬停时显示虚线高亮边框。
  final bool draggable;

  /// 是否启用拖拽上传。为 true 时整个上传区域接受拖放文件，
  /// 拖拽悬停时显示虚线高亮边框。
  ///
  /// 与 [draggable] 作用相同，新代码优先使用此参数。
  final bool dragEnabled;

  /// 是否允许一次选择多个文件。
  final bool multiple;

  /// 自定义上传实现。提供时替代默认上传逻辑。
  /// 回调中应更新 file.progress 和 file.status（通过 copyWith）。
  /// 返回 true 表示上传成功，false 表示失败。
  final Future<bool> Function(ParkUploadFile file)? customRequest;

  /// 文件列表展示类型。为 null 时自动推断：imageOnly 时使用 pictureCard，
  /// 否则使用 text。
  final ParkUploadListType? listType;

  /// 拖拽文件放下时的回调。仅在 [draggable] 为 true 时有效。
  final void Function(List<Object?> data)? onDropFiles;

  /// 拖拽文件放下时的回调。仅在 [dragEnabled] 为 true 时有效。
  ///
  /// 接收 [ParkDropFile] 列表，跨平台兼容。
  final void Function(List<ParkDropFile> files)? onFileDrop;

  /// 是否启用分片上传。为 true 且文件大小超过 [chunkSize] 时自动分片。
  /// / Enable chunked upload. When true and file size exceeds [chunkSize],
  /// the file is automatically split into chunks.
  final bool chunked;

  /// 分片大小（字节）。默认 1MB (1048576 字节)。
  /// / Chunk size in bytes. Defaults to 1MB (1048576 bytes).
  final int chunkSize;

  /// 分片上传回调。每个分片调用一次，由调用方实现实际上传逻辑。
  /// / Chunked upload callback. Called once per chunk; the caller implements
  /// the actual upload logic.
  final Future<void> Function(
    String filePath,
    List<int> chunkData,
    int chunkIndex,
    int totalChunks,
    void Function(double progress) onProgress,
  )?
  onChunkUpload;

  /// 是否启用上传前图片裁剪。为 true 且文件为图片时，上传前弹出裁剪界面。
  /// / Enable image cropping before upload. When true and the file is an image,
  /// a crop dialog is shown before uploading.
  final bool croppable;

  /// 裁剪比例（宽/高）。为 null 时自由裁剪。
  /// / Crop aspect ratio (width / height). Null means free-form cropping.
  final double? cropAspectRatio;

  /// 裁剪输出最大宽度（像素）。为 null 时不限制。
  /// / Max output width in pixels after cropping. Null means no limit.
  final int? cropMaxWidth;

  /// 裁剪输出最大高度（像素）。为 null 时不限制。
  /// / Max output height in pixels after cropping. Null means no limit.
  final int? cropMaxHeight;

  const ParkUpload({
    super.key,
    required this.files,
    this.maxCount = 9,
    this.onAdd,
    this.onRemove,
    this.onPreview,
    this.onRetry,
    this.onChanged,
    this.mode = ParkUploadMode.imageGrid,
    this.accept,
    this.maxSizeMB = 50,
    this.imageOnly = false,
    this.beforeAddValidator,
    this.removable = true,
    this.previewable = true,
    this.draggable = false,
    this.dragEnabled = false,
    this.multiple = false,
    this.customRequest,
    this.listType,
    this.onDropFiles,
    this.onFileDrop,
    this.chunked = false,
    this.chunkSize = 1024 * 1024,
    this.onChunkUpload,
    this.croppable = false,
    this.cropAspectRatio,
    this.cropMaxWidth,
    this.cropMaxHeight,
  });

  /// 校验文件是否符合当前上传器约束。
  ///
  /// 返回 null 表示通过，否则返回错误文案（固定中文，用于向后兼容）。
  /// 内部使用 [ParkLocalizations] 实现国际化版本。
  String? validateFile(ParkUploadFile file) {
    if (imageOnly && !_isImagePath(file.path)) {
      return '仅支持上传图片文件';
    }

    if (accept != null && accept!.isNotEmpty) {
      final String ext = _fileExtension(file.path);
      final bool supported = accept!
          .map((String item) => item.toLowerCase().replaceAll('.', ''))
          .contains(ext);
      if (!supported) {
        return '文件类型不支持';
      }
    }

    if (maxSizeMB != null && file.sizeBytes != null) {
      final double size = file.sizeBytes! / (1024 * 1024);
      if (size > maxSizeMB!) {
        return '文件大小不能超过 ${maxSizeMB!.toStringAsFixed(maxSizeMB! % 1 == 0 ? 0 : 1)}MB';
      }
    }

    if (beforeAddValidator != null) {
      return beforeAddValidator!(file);
    }

    return null;
  }

  /// 判断文件路径是否为图片格式。
  static bool _isImagePath(String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  /// 提取文件后缀。
  static String _fileExtension(String path) {
    final String lower = path.toLowerCase();
    final int index = lower.lastIndexOf('.');
    if (index == -1 || index == lower.length - 1) return '';
    return lower.substring(index + 1);
  }

  /// 格式化文件大小。
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 根据文件路径获取对应图标。
  static IconData _fileIconForPath(String path) {
    final String lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_outlined;
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return Icons.table_chart_outlined;
    }
    if (lower.endsWith('.mp4') || lower.endsWith('.mov')) {
      return Icons.videocam_outlined;
    }
    if (lower.endsWith('.mp3') || lower.endsWith('.wav')) {
      return Icons.audiotrack_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _fileNameFromPath(String path) {
    return fileNameFromPath(path);
  }

  @override
  State<ParkUpload> createState() => _ParkUploadState();
}

class _ParkUploadState extends State<ParkUpload> {
  /// 使用国际化版本校验文件。
  String? _validateWithL10n(ParkUploadFile file, ParkLocalizations l10n) {
    if (widget.imageOnly && !ParkUpload._isImagePath(file.path)) {
      return l10n.imageOnlyUpload;
    }

    if (widget.accept != null && widget.accept!.isNotEmpty) {
      final String ext = ParkUpload._fileExtension(file.path);
      final bool supported = widget.accept!
          .map((String item) => item.toLowerCase().replaceAll('.', ''))
          .contains(ext);
      if (!supported) {
        return l10n.fileTypeNotSupported;
      }
    }

    if (widget.maxSizeMB != null && file.sizeBytes != null) {
      final double size = file.sizeBytes! / (1024 * 1024);
      if (size > widget.maxSizeMB!) {
        return l10n.fileSizeExceedsText(widget.maxSizeMB!);
      }
    }

    if (widget.beforeAddValidator != null) {
      return widget.beforeAddValidator!(file);
    }

    return null;
  }

  /// 处理添加文件操作。
  ///
  /// 若 [onAdd] 已提供，调用外部回调（向后兼容）。
  /// 否则使用 [FilePicker] 内部选择文件，执行校验和上传。
  Future<void> _handleAdd() async {
    // 向后兼容：父组件提供了 onAdd，由外部处理
    if (widget.onAdd != null) {
      widget.onAdd!();
      return;
    }

    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: widget.multiple,
        type: _resolveFileType(),
        allowedExtensions: _resolveAllowedExtensions(),
      );

      if (result == null || result.files.isEmpty) return;

      final l10n = ParkLocalizations.of(context);
      final List<ParkUploadFile> validFiles = <ParkUploadFile>[];
      final List<String> errors = <String>[];

      for (final PlatformFile platformFile in result.files) {
        final String filePath = platformFile.path ?? platformFile.name;
        final ParkUploadFile file = ParkUploadFile(
          path: filePath,
          sizeBytes: platformFile.size,
        );

        // 1. 调用公开的 validateFile() 校验
        final String? validationError = widget.validateFile(file);
        if (validationError != null) {
          errors.add('${platformFile.name}: $validationError');
          continue;
        }

        // 2. 国际化校验
        final String? l10nError = _validateWithL10n(file, l10n);
        if (l10nError != null) {
          errors.add('${platformFile.name}: $l10nError');
          continue;
        }

        // 检查是否达到最大文件数
        if (widget.files.length + validFiles.length >= widget.maxCount) {
          errors.add(l10n.singleFileLimitText(widget.maxSizeMB ?? 0));
          break;
        }

        validFiles.add(file);
      }

      if (errors.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errors.join('\n')),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      if (validFiles.isEmpty) return;

      // 图片裁剪处理 / Image cropping (if enabled)
      final List<ParkUploadFile> processedFiles = <ParkUploadFile>[];
      for (final ParkUploadFile file in validFiles) {
        if (widget.croppable &&
            ParkUpload._isImagePath(file.path) &&
            context.mounted) {
          final ParkCropRectangle? cropRect =
              await showDialog<ParkCropRectangle>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) => _CropImageDialog(
                  imagePath: file.path,
                  aspectRatio: widget.cropAspectRatio,
                ),
              );
          if (!context.mounted) return;
          if (cropRect != null) {
            try {
              final Uint8List croppedBytes = await processCroppedImage(
                file.path,
                cropRect.left,
                cropRect.top,
                cropRect.width,
                cropRect.height,
                widget.cropMaxWidth,
                widget.cropMaxHeight,
              );
              if (croppedBytes.isNotEmpty) {
                processedFiles.add(
                  ParkUploadFile(
                    path: file.path,
                    sizeBytes: croppedBytes.length,
                  ),
                );
                continue;
              }
            } catch (_) {
              // 裁剪失败，使用原图 / Crop failed, fall back to original
            }
          } else {
            // 用户取消裁剪，跳过该文件 / User cancelled crop
            continue;
          }
        }
        processedFiles.add(file);
      }

      if (processedFiles.isEmpty) return;

      // 添加文件（pending 状态）
      final List<ParkUploadFile> updatedFiles = List<ParkUploadFile>.from(
        widget.files,
      )..addAll(processedFiles);
      widget.onChanged?.call(updatedFiles);

      // 分片上传 / Chunked upload
      if (widget.chunked && widget.onChunkUpload != null) {
        for (final ParkUploadFile file in processedFiles) {
          _processChunkedUpload(file);
        }
        return;
      }

      // 若提供了 customRequest，执行自定义上传
      if (widget.customRequest != null && context.mounted) {
        _executeCustomUploads(processedFiles, l10n);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  /// 解析文件选择器的文件类型。
  FileType _resolveFileType() {
    if (widget.imageOnly) return FileType.image;
    if (widget.accept != null && widget.accept!.isNotEmpty) {
      return FileType.custom;
    }
    return FileType.any;
  }

  /// 解析文件选择器的允许扩展名列表。
  List<String>? _resolveAllowedExtensions() {
    if (widget.accept != null && widget.accept!.isNotEmpty) {
      return widget.accept;
    }
    if (widget.imageOnly) {
      return <String>['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    }
    return null;
  }

  /// 执行自定义上传。
  Future<void> _executeCustomUploads(
    List<ParkUploadFile> newFiles,
    ParkLocalizations l10n,
  ) async {
    for (final ParkUploadFile file in newFiles) {
      final int index = widget.files.length + newFiles.indexOf(file);

      // 标记为上传中
      if (!context.mounted) return;
      List<ParkUploadFile> updated = List<ParkUploadFile>.from(widget.files);
      if (index < updated.length) {
        updated[index] = updated[index].copyWith(
          status: ParkUploadFileStatus.uploading,
        );
        widget.onChanged?.call(updated);
      }

      try {
        final bool success = await widget.customRequest!(file);
        if (!context.mounted) return;
        updated = List<ParkUploadFile>.from(widget.files);
        if (index < updated.length) {
          updated[index] = updated[index].copyWith(
            status: success
                ? ParkUploadFileStatus.done
                : ParkUploadFileStatus.error,
          );
          widget.onChanged?.call(updated);
        }
      } catch (_) {
        if (!context.mounted) return;
        updated = List<ParkUploadFile>.from(widget.files);
        if (index < updated.length) {
          updated[index] = updated[index].copyWith(
            status: ParkUploadFileStatus.error,
          );
          widget.onChanged?.call(updated);
        }
      }
    }
  }

  /// 处理分片上传。
  ///
  /// 当 [chunked] 为 true 且文件大小超过 [chunkSize] 时，将文件拆分为多个分片，
  /// 逐个调用 [onChunkUpload] 回调。支持断点续传：失败后从上次成功位置继续。
  Future<void> _processChunkedUpload(ParkUploadFile file) async {
    final int fileSize = file.sizeBytes ?? 0;
    final int chunkSize = widget.chunkSize;

    // 文件小于分片大小，不需要分片 / File smaller than chunk size
    if (fileSize <= chunkSize || fileSize == 0) {
      if (widget.onChunkUpload != null) {
        final int index = widget.files.indexOf(file);
        if (index < 0) return;
        List<ParkUploadFile> updated = List<ParkUploadFile>.from(widget.files);
        updated[index] = updated[index].copyWith(
          status: ParkUploadFileStatus.uploading,
        );
        widget.onChanged?.call(updated);
        try {
          await widget.onChunkUpload!(file.path, <int>[], 0, 1, (
            double progress,
          ) {
            if (!context.mounted) return;
            final List<ParkUploadFile> u = List<ParkUploadFile>.from(
              widget.files,
            );
            if (index < u.length) {
              u[index] = u[index].copyWith(progress: progress);
              widget.onChanged?.call(u);
            }
          });
          if (!context.mounted) return;
          updated = List<ParkUploadFile>.from(widget.files);
          if (index < updated.length) {
            updated[index] = updated[index].copyWith(
              status: ParkUploadFileStatus.done,
              progress: 1.0,
            );
            widget.onChanged?.call(updated);
          }
        } catch (_) {
          if (!context.mounted) return;
          updated = List<ParkUploadFile>.from(widget.files);
          if (index < updated.length) {
            updated[index] = updated[index].copyWith(
              status: ParkUploadFileStatus.error,
            );
            widget.onChanged?.call(updated);
          }
        }
      }
      return;
    }

    // 计算分片 / Calculate chunks
    final int totalChunks = (fileSize / chunkSize).ceil();
    final ParkChunkedUploader uploader = ParkChunkedUploader(
      filePath: file.path,
      chunkSize: chunkSize,
      totalChunks: totalChunks,
    );

    final int index = widget.files.indexOf(file);
    if (index < 0) return;

    // 标记为上传中，初始化分片信息 / Mark as uploading, init chunk info
    List<ParkUploadFile> updated = List<ParkUploadFile>.from(widget.files);
    updated[index] = updated[index].copyWith(
      status: ParkUploadFileStatus.uploading,
      totalChunks: totalChunks,
    );
    widget.onChanged?.call(updated);

    // 从断点位置继续 / Resume from last completed chunk
    int startChunk = file.chunkResumeOffset;

    for (int i = startChunk; i < totalChunks; i++) {
      if (!context.mounted) return;

      try {
        final List<int> chunkData = await uploader.readChunk(i);

        await widget.onChunkUpload!(file.path, chunkData, i, totalChunks, (
          double progress,
        ) {
          if (!context.mounted) return;
          final List<ParkUploadFile> u = List<ParkUploadFile>.from(
            widget.files,
          );
          if (index < u.length) {
            final double overallProgress = (i + progress) / totalChunks;
            u[index] = u[index].copyWith(progress: overallProgress);
            widget.onChanged?.call(u);
          }
        });

        // 分片上传成功 / Chunk uploaded successfully
        if (!context.mounted) return;
        updated = List<ParkUploadFile>.from(widget.files);
        if (index < updated.length) {
          final List<int> completed = List<int>.from(
            updated[index].completedChunks,
          )..add(i);
          updated[index] = updated[index].copyWith(
            completedChunks: completed,
            chunkResumeOffset: i + 1,
            progress: (i + 1) / totalChunks,
          );
          widget.onChanged?.call(updated);
        }
      } catch (_) {
        // 分片上传失败，记录断点位置 / Chunk failed, save resume offset
        if (!context.mounted) return;
        updated = List<ParkUploadFile>.from(widget.files);
        if (index < updated.length) {
          updated[index] = updated[index].copyWith(
            status: ParkUploadFileStatus.error,
          );
          widget.onChanged?.call(updated);
        }
        return;
      }
    }

    // 所有分片上传完成 / All chunks uploaded
    if (!context.mounted) return;
    updated = List<ParkUploadFile>.from(widget.files);
    if (index < updated.length) {
      updated[index] = updated[index].copyWith(
        status: ParkUploadFileStatus.done,
        progress: 1.0,
      );
      widget.onChanged?.call(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

    // 解析有效的 listType：null 时自动推断
    final ParkUploadListType effectiveListType =
        widget.listType ??
        (widget.imageOnly
            ? ParkUploadListType.pictureCard
            : ParkUploadListType.text);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_buildConstraintText(l10n).isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: Text(
              _buildConstraintText(l10n),
              style: TextStyle(
                fontSize: park.typography.sizeCaption,
                color: park.colors.textPlaceholder,
              ),
            ),
          ),
        if (effectiveListType == ParkUploadListType.pictureCard)
          _buildGrid(park, l10n)
        else if (effectiveListType == ParkUploadListType.picture)
          _buildList(park, l10n)
        else
          _buildTextList(park, l10n),
      ],
    );

    // 兼容旧的 mode 参数（当 listType 未指定时，mode 仍然生效）
    if (widget.listType == null && widget.mode != ParkUploadMode.imageGrid) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_buildConstraintText(l10n).isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: park.spacing.sm),
              child: Text(
                _buildConstraintText(l10n),
                style: TextStyle(
                  fontSize: park.typography.sizeCaption,
                  color: park.colors.textPlaceholder,
                ),
              ),
            ),
          _buildList(park, l10n),
        ],
      );
    }

    final bool _dragEnabled = widget.dragEnabled || widget.draggable;

    if (_dragEnabled) {
      return _DragUploadArea(
        park: park,
        onDropFiles: widget.onDropFiles,
        onFileDrop: widget.onFileDrop,
        onAdd: _handleAdd,
        child: content,
      );
    }

    return content;
  }

  Widget _buildGrid(ParkThemeData park, ParkLocalizations l10n) {
    final radius = park.radius;
    final spacing = park.spacing;
    final bool canAdd = widget.files.length < widget.maxCount;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: <Widget>[
        ...widget.files.map(
          (ParkUploadFile file) => _buildGridItem(file, park, l10n),
        ),
        if (canAdd)
          _buildAddButton(
            park,
            l10n,
            size: 80,
            borderRadius: BorderRadius.circular(radius.md),
          ),
      ],
    );
  }

  Widget _buildGridItem(
    ParkUploadFile file,
    ParkThemeData park,
    ParkLocalizations l10n,
  ) {
    final colors = park.colors;
    final radius = park.radius;

    return Semantics(
      label: _fileNameFromPath(file.path),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            GestureDetector(
              onTap: widget.previewable
                  ? () => widget.onPreview?.call(file)
                  : null,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.md),
                  border: Border.all(color: colors.border, width: 0.5),
                  color: colors.disabledBg,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius.md),
                  child: _buildThumbnail(file, park),
                ),
              ),
            ),
            if (file.status == ParkUploadFileStatus.uploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius.md),
                    color: park.colors.overlay,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: file.progress > 0 ? file.progress : null,
                        valueColor: AlwaysStoppedAnimation(colors.textOnBrand),
                      ),
                    ),
                  ),
                ),
              ),
            if (file.status == ParkUploadFileStatus.error)
              Positioned.fill(
                child: GestureDetector(
                  onTap: widget.onRetry == null
                      ? null
                      : () => widget.onRetry?.call(file),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius.md),
                      color: colors.error.withValues(alpha: 0.15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: colors.error,
                          size: 24,
                        ),
                        if (widget.onRetry != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Semantics(
                              label: l10n.retry,
                              child: Text(
                                l10n.retry,
                                style: TextStyle(
                                  color: colors.error,
                                  fontSize: park.typography.sizeCaption,
                                  fontWeight: park.typography.weightMedium,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            if (widget.removable)
              Semantics(
                label: l10n.deleteFileLabel,
                child: Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => widget.onRemove?.call(file),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(ParkUploadFile file, ParkThemeData park) {
    if (file.thumbnailPath != null) {
      return buildFileImageWidget(
        file.thumbnailPath!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }

    if (ParkUpload._isImagePath(file.path)) {
      return buildFileImageWidget(
        file.path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }

    return _buildFileIcon(file, park);
  }

  Widget _buildFileIcon(ParkUploadFile file, ParkThemeData park) {
    return Center(
      child: Icon(
        ParkUpload._fileIconForPath(file.path),
        size: 28,
        color: park.colors.textPlaceholder,
      ),
    );
  }

  Widget _buildAddButton(
    ParkThemeData park,
    ParkLocalizations l10n, {
    required double size,
    required BorderRadius borderRadius,
  }) {
    final colors = park.colors;

    return Semantics(
      label: l10n.addFileText,
      child: GestureDetector(
        onTap: _handleAdd,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.disabledBg,
            borderRadius: borderRadius,
            border: Border.all(
              color: colors.border,
              width: 0.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add, size: 24, color: colors.textPlaceholder),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(ParkThemeData park, ParkLocalizations l10n) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;
    final bool canAdd = widget.files.length < widget.maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...widget.files.map((ParkUploadFile file) {
          return Semantics(
            label: _fileNameFromPath(file.path),
            child: Container(
              margin: EdgeInsets.only(bottom: spacing.sm),
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(radius.md),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius.sm),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: _buildListThumbnail(file, park),
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _fileNameFromPath(file.path),
                          style: TextStyle(
                            fontSize: typo.sizeBodySmall,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (file.sizeBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              ParkUpload._formatFileSize(file.sizeBytes!),
                              style: TextStyle(
                                fontSize: typo.sizeCaption,
                                color: colors.textPlaceholder,
                              ),
                            ),
                          ),
                        if (file.status == ParkUploadFileStatus.uploading)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: LinearProgressIndicator(
                              value: file.progress > 0 ? file.progress : null,
                              minHeight: 3,
                              backgroundColor: colors.disabledBg,
                              valueColor: AlwaysStoppedAnimation(colors.brand),
                            ),
                          ),
                        if (file.status == ParkUploadFileStatus.error)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  l10n.uploadFailed,
                                  style: TextStyle(
                                    fontSize: typo.sizeCaption,
                                    color: colors.error,
                                  ),
                                ),
                                if (widget.onRetry != null) ...<Widget>[
                                  SizedBox(width: spacing.xs),
                                  GestureDetector(
                                    onTap: () => widget.onRetry?.call(file),
                                    child: Text(
                                      l10n.retry,
                                      style: TextStyle(
                                        fontSize: typo.sizeCaption,
                                        color: colors.brand,
                                        fontWeight: typo.weightMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.previewable)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.sm),
                      child: GestureDetector(
                        onTap: () => widget.onPreview?.call(file),
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  if (widget.removable)
                    Semantics(
                      label: l10n.deleteFileLabel,
                      child: GestureDetector(
                        onTap: () => widget.onRemove?.call(file),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colors.textPlaceholder,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        if (canAdd)
          Semantics(
            label: l10n.addFileText,
            child: GestureDetector(
              onTap: _handleAdd,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: spacing.md),
                decoration: BoxDecoration(
                  color: colors.disabledBg,
                  borderRadius: BorderRadius.circular(radius.md),
                  border: Border.all(color: colors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, size: 18, color: colors.textPlaceholder),
                    SizedBox(width: spacing.xs),
                    Text(
                      l10n.addFileText,
                      style: TextStyle(
                        fontSize: typo.sizeBodySmall,
                        color: colors.textPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListThumbnail(ParkUploadFile file, ParkThemeData park) {
    if (file.thumbnailPath != null) {
      return buildFileImageWidget(
        file.thumbnailPath!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
    if (ParkUpload._isImagePath(file.path)) {
      return buildFileImageWidget(
        file.path,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
    return _buildFileIcon(file, park);
  }

  /// 文本模式列表：文件图标 + 文件名 + 进度条 + 文件大小。
  Widget _buildTextList(ParkThemeData park, ParkLocalizations l10n) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;
    final bool canAdd = widget.files.length < widget.maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...widget.files.map((ParkUploadFile file) {
          return Semantics(
            label: _fileNameFromPath(file.path),
            child: Container(
              margin: EdgeInsets.only(bottom: spacing.sm),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(radius.md),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    ParkUpload._fileIconForPath(file.path),
                    size: 18,
                    color: file.status == ParkUploadFileStatus.done
                        ? colors.brand
                        : colors.textSecondary,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _fileNameFromPath(file.path),
                          style: TextStyle(
                            fontSize: typo.sizeBodySmall,
                            color: file.status == ParkUploadFileStatus.error
                                ? colors.error
                                : colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (file.status == ParkUploadFileStatus.uploading)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: LinearProgressIndicator(
                              value: file.progress > 0 ? file.progress : null,
                              minHeight: 2,
                              backgroundColor: colors.disabledBg,
                              valueColor: AlwaysStoppedAnimation(colors.brand),
                            ),
                          ),
                        if (file.status == ParkUploadFileStatus.done &&
                            file.sizeBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              ParkUpload._formatFileSize(file.sizeBytes!),
                              style: TextStyle(
                                fontSize: typo.sizeCaption,
                                color: colors.textPlaceholder,
                              ),
                            ),
                          ),
                        if (file.status == ParkUploadFileStatus.error)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  l10n.uploadFailed,
                                  style: TextStyle(
                                    fontSize: typo.sizeCaption,
                                    color: colors.error,
                                  ),
                                ),
                                if (widget.onRetry != null) ...<Widget>[
                                  SizedBox(width: spacing.xs),
                                  GestureDetector(
                                    onTap: () => widget.onRetry?.call(file),
                                    child: Text(
                                      l10n.retry,
                                      style: TextStyle(
                                        fontSize: typo.sizeCaption,
                                        color: colors.brand,
                                        fontWeight: typo.weightMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.previewable)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.sm),
                      child: GestureDetector(
                        onTap: () => widget.onPreview?.call(file),
                        child: Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  if (widget.removable)
                    Semantics(
                      label: l10n.deleteFileLabel,
                      child: GestureDetector(
                        onTap: () => widget.onRemove?.call(file),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: colors.textPlaceholder,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        if (canAdd)
          Semantics(
            label: l10n.addFileText,
            child: GestureDetector(
              onTap: _handleAdd,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: spacing.sm),
                decoration: BoxDecoration(
                  color: colors.disabledBg,
                  borderRadius: BorderRadius.circular(radius.md),
                  border: Border.all(color: colors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, size: 16, color: colors.textPlaceholder),
                    SizedBox(width: spacing.xs),
                    Text(
                      l10n.addFileText,
                      style: TextStyle(
                        fontSize: typo.sizeBodySmall,
                        color: colors.textPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _fileNameFromPath(String path) {
    return fileNameFromPath(path);
  }

  String _buildConstraintText(ParkLocalizations l10n) {
    final List<String> parts = <String>[];
    if (widget.imageOnly) {
      parts.add(l10n.imageOnlyConstraint);
    } else if (widget.accept != null && widget.accept!.isNotEmpty) {
      parts.add(l10n.supportedFormatsText(widget.accept!));
    }
    if (widget.maxSizeMB != null) {
      parts.add(l10n.singleFileLimitText(widget.maxSizeMB!));
    }
    return parts.join('，');
  }
}

/// 拖拽上传区域——管理 DragTarget（Flutter 内部拖拽）和 Web 浏览器拖拽的
/// 悬停状态，并提供统一的视觉反馈。
class _DragUploadArea extends StatefulWidget {
  final Widget child;
  final void Function(List<Object?> data)? onDropFiles;
  final void Function(List<ParkDropFile> files)? onFileDrop;
  final VoidCallback? onAdd;
  final ParkThemeData park;

  const _DragUploadArea({
    required this.child,
    required this.park,
    this.onDropFiles,
    this.onFileDrop,
    this.onAdd,
  });

  @override
  _DragUploadAreaState createState() => _DragUploadAreaState();
}

class _DragUploadAreaState extends State<_DragUploadArea> {
  bool _dragTargetHovering = false;
  bool _webHovering = false;

  bool get _isHovering => _dragTargetHovering || _webHovering;

  Widget _buildVisualWrapper(Widget content) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: _isHovering
            ? widget.park.colors.brand
            : widget.park.colors.border,
        strokeWidth: _isHovering ? 2.0 : 1.0,
        dashWidth: 6.0,
        dashGap: 4.0,
        borderRadius: BorderRadius.circular(widget.park.radius.md),
      ),
      child: Container(
        padding: EdgeInsets.all(widget.park.spacing.sm),
        decoration: BoxDecoration(
          color: _isHovering
              ? widget.park.colors.brandLight.withValues(alpha: 0.06)
              : null,
          borderRadius: BorderRadius.circular(widget.park.radius.md),
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);

    final Widget dragTarget = DragTarget<Object>(
      onAcceptWithDetails: (DragTargetDetails<Object> details) {
        widget.onDropFiles?.call(<Object?>[details.data]);
        widget.onAdd?.call();
      },
      builder:
          (
            BuildContext context,
            List<Object?> candidateData,
            List<dynamic> rejectedData,
          ) {
            _dragTargetHovering = candidateData.isNotEmpty;
            return _buildVisualWrapper(widget.child);
          },
    );

    return Semantics(
      label: l10n.dragUploadAreaLabel,
      child: ParkUploadWebDragTarget(
        onDragHoverChange: (bool hovering) {
          if (_webHovering != hovering) {
            setState(() => _webHovering = hovering);
          }
        },
        onDropFiles: (List<ParkDropFile> files) {
          widget.onFileDrop?.call(files);
        },
        child: dragTarget,
      ),
    );
  }
}

/// 虚线边框画笔，用于拖拽上传区域视觉反馈。
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final BorderRadius borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = borderRadius.toRRect(Offset.zero & size);
    final Path path = Path()..addRRect(rrect);

    final List<PathMetric> metrics = path.computeMetrics().toList();
    for (final PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0.0, metric.length);
        final Path extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashGap != oldDelegate.dashGap ||
        borderRadius != oldDelegate.borderRadius;
  }
}

// ---------------------------------------------------------------------------
// 分片上传器 / Chunked upload helper
// ---------------------------------------------------------------------------

/// 分片上传器，负责从文件中读取指定分片数据。
///
/// 纯 Dart 实现，不依赖外部分片库。通过条件导入的平台辅助文件
/// （[readFileChunk]）读取文件字节片段。
class ParkChunkedUploader {
  /// 文件路径。
  final String filePath;

  /// 分片大小（字节）。
  final int chunkSize;

  /// 总分片数。
  final int totalChunks;

  /// 创建分片上传器。
  const ParkChunkedUploader({
    required this.filePath,
    required this.chunkSize,
    required this.totalChunks,
  });

  /// 读取第 [index] 个分片的字节数据。
  Future<List<int>> readChunk(int index) async {
    final int start = index * chunkSize;
    final int end = start + chunkSize;
    return readFileChunk(filePath, start, end);
  }
}

// ---------------------------------------------------------------------------
// 裁剪区域 / Crop rectangle
// ---------------------------------------------------------------------------

/// 裁剪区域，使用归一化坐标（0.0 ~ 1.0）表示。
///
/// 用于裁剪对话框与图片处理之间的数据传递。
class ParkCropRectangle {
  /// 左上角 X 坐标（0.0 ~ 1.0）。
  final double left;

  /// 左上角 Y 坐标（0.0 ~ 1.0）。
  final double top;

  /// 宽度（0.0 ~ 1.0）。
  final double width;

  /// 高度（0.0 ~ 1.0）。
  final double height;

  /// 创建裁剪区域。
  const ParkCropRectangle({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// 根据中心和尺寸创建裁剪区域（归一化坐标）。
  factory ParkCropRectangle.fromCenter({
    required double centerX,
    required double centerY,
    required double width,
    required double height,
  }) {
    return ParkCropRectangle(
      left: (centerX - width / 2).clamp(0.0, 1.0),
      top: (centerY - height / 2).clamp(0.0, 1.0),
      width: width.clamp(0.0, 1.0),
      height: height.clamp(0.0, 1.0),
    );
  }

  /// 根据原始图片尺寸计算实际像素裁剪区域。
  Rect toRect(int imageWidth, int imageHeight) {
    return Rect.fromLTWH(
      left * imageWidth,
      top * imageHeight,
      width * imageWidth,
      height * imageHeight,
    );
  }
}

// ---------------------------------------------------------------------------
// 图片裁剪对话框 / Crop image dialog
// ---------------------------------------------------------------------------

class _CropImageDialog extends StatefulWidget {
  final String imagePath;
  final double? aspectRatio;

  const _CropImageDialog({required this.imagePath, this.aspectRatio});

  @override
  State<_CropImageDialog> createState() => _CropImageDialogState();
}

class _CropImageDialogState extends State<_CropImageDialog> {
  /// 裁剪区域（归一化坐标 0.0 ~ 1.0）。
  late ParkCropRectangle _cropRect;

  /// 图片原始尺寸。
  Size _imageSize = Size.zero;

  /// 图片是否已加载。
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    try {
      final List<int> dims = await readImageDimensions(widget.imagePath);
      if (!mounted) return;
      setState(() {
        _imageSize = Size(dims[0].toDouble(), dims[1].toDouble());
        _imageLoaded = true;
        _initCropRect();
      });
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop(null);
    }
  }

  void _initCropRect() {
    if (widget.aspectRatio != null) {
      final double ratio = widget.aspectRatio!;
      double w = 0.8;
      double h = w / ratio;
      if (h > 0.8) {
        h = 0.8;
        w = h * ratio;
      }
      _cropRect = ParkCropRectangle.fromCenter(
        centerX: 0.5,
        centerY: 0.5,
        width: w,
        height: h,
      );
    } else {
      _cropRect = const ParkCropRectangle(
        left: 0.1,
        top: 0.1,
        width: 0.8,
        height: 0.8,
      );
    }
  }

  void _onDragUpdate(DragUpdateDetails details, Size displaySize) {
    final double dx = details.delta.dx / displaySize.width;
    final double dy = details.delta.dy / displaySize.height;
    double newLeft = (_cropRect.left + dx).clamp(0.0, 1.0 - _cropRect.width);
    double newTop = (_cropRect.top + dy).clamp(0.0, 1.0 - _cropRect.height);
    if (widget.aspectRatio != null) {
      if (dx.abs() > dy.abs()) {
        newLeft = newLeft.clamp(0.0, 1.0 - _cropRect.width);
        newTop = (_cropRect.top).clamp(0.0, 1.0 - _cropRect.height);
      } else {
        newTop = newTop.clamp(0.0, 1.0 - _cropRect.height);
        newLeft = (_cropRect.left).clamp(0.0, 1.0 - _cropRect.width);
      }
    }
    setState(() {
      _cropRect = ParkCropRectangle(
        left: newLeft,
        top: newTop,
        width: _cropRect.width,
        height: _cropRect.height,
      );
    });
  }

  void _onResizeUpdate(DragUpdateDetails details, Size displaySize) {
    final double delta =
        (details.delta.dx + details.delta.dy) /
        (displaySize.width + displaySize.height);
    double newWidth = (_cropRect.width + delta).clamp(0.1, 1.0);
    double newHeight = (_cropRect.height + delta).clamp(0.1, 1.0);
    if (widget.aspectRatio != null) {
      final double ratio = widget.aspectRatio!;
      final double displayRatio = displaySize.width / displaySize.height;
      final double normalizedRatio = ratio / displayRatio;
      newWidth = newWidth.clamp(0.1, 1.0);
      newHeight = newWidth / normalizedRatio;
      if (newHeight > 1.0) {
        newHeight = 1.0;
        newWidth = newHeight * normalizedRatio;
      }
    }
    final double maxRight = _cropRect.left + newWidth;
    final double maxBottom = _cropRect.top + newHeight;
    if (maxRight > 1.0 || maxBottom > 1.0) return;
    setState(() {
      _cropRect = ParkCropRectangle(
        left: _cropRect.left,
        top: _cropRect.top,
        width: newWidth,
        height: newHeight,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ParkLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.retry.isNotEmpty ? '裁剪图片' : 'Crop Image'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: _imageLoaded
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: buildFileImageWidget(
                          widget.imagePath,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onPanUpdate: (details) => _onDragUpdate(
                            details,
                            Size(constraints.maxWidth, constraints.maxHeight),
                          ),
                          child: CustomPaint(
                            painter: _CropImagePainter(
                              cropRect: _cropRect,
                              imageSize: _imageSize,
                              displaySize: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right:
                            (1 - _cropRect.left - _cropRect.width) *
                                constraints.maxWidth -
                            8,
                        bottom:
                            (1 - _cropRect.top - _cropRect.height) *
                                constraints.maxHeight -
                            8,
                        width: 24,
                        height: 24,
                        child: GestureDetector(
                          onPanUpdate: (details) => _onResizeUpdate(
                            details,
                            Size(constraints.maxWidth, constraints.maxHeight),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.retry.isNotEmpty ? '取消' : 'Cancel'),
        ),
        TextButton(
          onPressed: _imageLoaded
              ? () => Navigator.of(context).pop(_cropRect)
              : null,
          child: Text(l10n.retry.isNotEmpty ? '确认' : 'Confirm'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 裁剪区域绘制器 / Crop overlay painter
// ---------------------------------------------------------------------------

class _CropImagePainter extends CustomPainter {
  final ParkCropRectangle cropRect;
  final Size imageSize;
  final Size displaySize;

  _CropImagePainter({
    required this.cropRect,
    required this.imageSize,
    required this.displaySize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dimPaint = Paint()..color = const Color(0x88000000);
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 计算图片在显示区域内的实际绘制区域（考虑 BoxFit.contain）
    final double imageAspect = imageSize.width / imageSize.height;
    double drawWidth, drawHeight, offsetX, offsetY;
    if (imageAspect > displaySize.width / displaySize.height) {
      drawWidth = displaySize.width;
      drawHeight = displaySize.width / imageAspect;
      offsetX = 0;
      offsetY = (displaySize.height - drawHeight) / 2;
    } else {
      drawHeight = displaySize.height;
      drawWidth = displaySize.height * imageAspect;
      offsetX = (displaySize.width - drawWidth) / 2;
      offsetY = 0;
    }

    final Rect cropDisplayRect = Rect.fromLTWH(
      offsetX + cropRect.left * drawWidth,
      offsetY + cropRect.top * drawHeight,
      cropRect.width * drawWidth,
      cropRect.height * drawHeight,
    );

    // 绘制半透明遮罩（裁剪区域外部）
    final Path dimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropDisplayRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(dimPath, dimPaint);

    // 绘制裁剪框边框
    canvas.drawRect(cropDisplayRect, borderPaint);

    // 绘制网格线（三分法）
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int i = 1; i < 3; i++) {
      final double x = cropDisplayRect.left + cropDisplayRect.width * i / 3;
      canvas.drawLine(
        Offset(x, cropDisplayRect.top),
        Offset(x, cropDisplayRect.bottom),
        gridPaint,
      );
      final double y = cropDisplayRect.top + cropDisplayRect.height * i / 3;
      canvas.drawLine(
        Offset(cropDisplayRect.left, y),
        Offset(cropDisplayRect.right, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CropImagePainter oldDelegate) {
    return cropRect != oldDelegate.cropRect ||
        imageSize != oldDelegate.imageSize ||
        displaySize != oldDelegate.displaySize;
  }
}
