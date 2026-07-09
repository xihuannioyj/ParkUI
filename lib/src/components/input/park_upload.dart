import 'dart:ui' show PathMetric;

import 'park_upload_io_stub.dart'
    if (dart.library.io) 'park_upload_io_native.dart'
    if (dart.library.html) 'park_upload_io_web.dart';

import 'package:flutter/material.dart';

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

  const ParkUploadFile({
    required this.path,
    this.url,
    this.thumbnailPath,
    this.status = ParkUploadFileStatus.pending,
    this.progress = 0.0,
    this.sizeBytes,
  });

  ParkUploadFile copyWith({
    String? path,
    String? url,
    String? thumbnailPath,
    ParkUploadFileStatus? status,
    double? progress,
    int? sizeBytes,
  }) {
    return ParkUploadFile(
      path: path ?? this.path,
      url: url ?? this.url,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
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
class ParkUpload extends StatelessWidget {
  /// 已选文件列表。
  final List<ParkUploadFile> files;

  /// 最大文件数量。
  final int maxCount;

  /// 添加文件回调（由外部触发文件选择器）。
  final VoidCallback? onAdd;

  /// 移除文件回调。
  final ValueChanged<ParkUploadFile>? onRemove;

  /// 预览文件回调。
  final ValueChanged<ParkUploadFile>? onPreview;

  /// 上传失败重试回调。
  final ValueChanged<ParkUploadFile>? onRetry;

  /// 展示模式。
  final ParkUploadMode mode;

  /// 允许的文件后缀列表，如 `['jpg', 'png', 'pdf']`。
  final List<String>? accept;

  /// 最大文件大小（MB）。
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

  const ParkUpload({
    super.key,
    required this.files,
    this.maxCount = 9,
    this.onAdd,
    this.onRemove,
    this.onPreview,
    this.onRetry,
    this.mode = ParkUploadMode.imageGrid,
    this.accept,
    this.maxSizeMB,
    this.imageOnly = false,
    this.beforeAddValidator,
    this.removable = true,
    this.previewable = true,
    this.draggable = false,
    this.multiple = false,
    this.customRequest,
    this.listType,
    this.onDropFiles,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 解析有效的 listType：null 时自动推断
    final ParkUploadListType effectiveListType = listType ??
        (imageOnly ? ParkUploadListType.pictureCard : ParkUploadListType.text);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (_buildConstraintText().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: Text(
              _buildConstraintText(),
              style: TextStyle(
                fontSize: park.typography.sizeCaption,
                color: park.colors.textPlaceholder,
              ),
            ),
          ),
        if (effectiveListType == ParkUploadListType.pictureCard)
          _buildGrid(park)
        else if (effectiveListType == ParkUploadListType.picture)
          _buildList(park)
        else
          _buildTextList(park),
      ],
    );

    // 兼容旧的 mode 参数（当 listType 未指定时，mode 仍然生效）
    if (listType == null && mode != ParkUploadMode.imageGrid) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_buildConstraintText().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: park.spacing.sm),
              child: Text(
                _buildConstraintText(),
                style: TextStyle(
                  fontSize: park.typography.sizeCaption,
                  color: park.colors.textPlaceholder,
                ),
              ),
            ),
          _buildList(park),
        ],
      );
    }

    if (draggable) {
      return DragTarget<Object>(
        onAcceptWithDetails: (DragTargetDetails<Object> details) {
          onDropFiles?.call(<Object?>[details.data]);
          onAdd?.call();
        },
        builder: (
          BuildContext context,
          List<Object?> candidateData,
          List<dynamic> rejectedData,
        ) {
          final bool isHovering = candidateData.isNotEmpty;
          return CustomPaint(
            painter: _DashedBorderPainter(
              color: isHovering
                  ? park.colors.brand
                  : park.colors.border,
              strokeWidth: isHovering ? 2.0 : 1.0,
              dashWidth: 6.0,
              dashGap: 4.0,
              borderRadius: BorderRadius.circular(park.radius.md),
            ),
            child: Container(
              padding: EdgeInsets.all(park.spacing.sm),
              decoration: BoxDecoration(
                color: isHovering
                    ? park.colors.brandLight.withValues(alpha: 0.06)
                    : null,
                borderRadius: BorderRadius.circular(park.radius.md),
              ),
              child: content,
            ),
          );
        },
      );
    }

    return content;
  }

  /// 校验文件是否符合当前上传器约束。
  ///
  /// 返回 null 表示通过，否则返回错误文案。
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

  Widget _buildGrid(ParkThemeData park) {
    final radius = park.radius;
    final spacing = park.spacing;
    final bool canAdd = files.length < maxCount;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: <Widget>[
        ...files.map((ParkUploadFile file) => _buildGridItem(file, park)),
        if (canAdd)
          _buildAddButton(
            park,
            size: 80,
            borderRadius: BorderRadius.circular(radius.md),
          ),
      ],
    );
  }

  Widget _buildGridItem(ParkUploadFile file, ParkThemeData park) {
    final colors = park.colors;
    final radius = park.radius;

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          GestureDetector(
            onTap: previewable ? () => onPreview?.call(file) : null,
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
                child: _buildThumbnail(file),
              ),
            ),
          ),
          if (file.status == ParkUploadFileStatus.uploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.md),
                  color: Colors.black.withValues(alpha: 0.4),
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
                onTap: onRetry == null ? null : () => onRetry?.call(file),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius.md),
                    color: colors.error.withValues(alpha: 0.15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.error_outline, color: colors.error, size: 24),
                      if (onRetry != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '重试',
                            style: TextStyle(
                              color: colors.error,
                              fontSize: park.typography.sizeCaption,
                              fontWeight: park.typography.weightMedium,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (removable)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => onRemove?.call(file),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 12, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ParkUploadFile file) {
    if (file.thumbnailPath != null) {
      return buildFileImageWidget(file.thumbnailPath!,
          width: 80, height: 80, fit: BoxFit.cover);
    }

    if (_isImagePath(file.path)) {
      return buildFileImageWidget(file.path,
          width: 80, height: 80, fit: BoxFit.cover);
    }

    return _buildFileIcon(file);
  }

  Widget _buildFileIcon(ParkUploadFile file) {
    return Center(
      child: Icon(
        _fileIconForPath(file.path),
        size: 28,
        color: const Color(0xFF999999),
      ),
    );
  }

  Widget _buildAddButton(
    ParkThemeData park, {
    required double size,
    required BorderRadius borderRadius,
  }) {
    final colors = park.colors;

    return GestureDetector(
      onTap: onAdd,
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
    );
  }

  Widget _buildList(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;
    final bool canAdd = files.length < maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...files.map((ParkUploadFile file) {
          return Container(
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
                    child: _buildListThumbnail(file),
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
                            _formatFileSize(file.sizeBytes!),
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
                                '上传失败',
                                style: TextStyle(
                                  fontSize: typo.sizeCaption,
                                  color: colors.error,
                                ),
                              ),
                              if (onRetry != null) ...<Widget>[
                                SizedBox(width: spacing.xs),
                                GestureDetector(
                                  onTap: () => onRetry?.call(file),
                                  child: Text(
                                    '重试',
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
                if (previewable)
                  Padding(
                    padding: EdgeInsets.only(right: spacing.sm),
                    child: GestureDetector(
                      onTap: () => onPreview?.call(file),
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                if (removable)
                  GestureDetector(
                    onTap: () => onRemove?.call(file),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: colors.textPlaceholder,
                    ),
                  ),
              ],
            ),
          );
        }),
        if (canAdd)
          GestureDetector(
            onTap: onAdd,
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
                    '添加文件',
                    style: TextStyle(
                      fontSize: typo.sizeBodySmall,
                      color: colors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildListThumbnail(ParkUploadFile file) {
    if (file.thumbnailPath != null) {
      return buildFileImageWidget(file.thumbnailPath!,
          width: 40, height: 40, fit: BoxFit.cover);
    }
    if (_isImagePath(file.path)) {
      return buildFileImageWidget(file.path,
          width: 40, height: 40, fit: BoxFit.cover);
    }
    return _buildFileIcon(file);
  }

  /// 文本模式列表：文件图标 + 文件名 + 进度条 + 文件大小。
  Widget _buildTextList(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final radius = park.radius;
    final spacing = park.spacing;
    final bool canAdd = files.length < maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...files.map((ParkUploadFile file) {
          return Container(
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
                  _fileIconForPath(file.path),
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
                            valueColor:
                                AlwaysStoppedAnimation(colors.brand),
                          ),
                        ),
                      if (file.status == ParkUploadFileStatus.done &&
                          file.sizeBytes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _formatFileSize(file.sizeBytes!),
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
                                '上传失败',
                                style: TextStyle(
                                  fontSize: typo.sizeCaption,
                                  color: colors.error,
                                ),
                              ),
                              if (onRetry != null) ...<Widget>[
                                SizedBox(width: spacing.xs),
                                GestureDetector(
                                  onTap: () => onRetry?.call(file),
                                  child: Text(
                                    '重试',
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
                if (previewable)
                  Padding(
                    padding: EdgeInsets.only(right: spacing.sm),
                    child: GestureDetector(
                      onTap: () => onPreview?.call(file),
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                if (removable)
                  GestureDetector(
                    onTap: () => onRemove?.call(file),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: colors.textPlaceholder,
                    ),
                  ),
              ],
            ),
          );
        }),
        if (canAdd)
          GestureDetector(
            onTap: onAdd,
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
                    '添加文件',
                    style: TextStyle(
                      fontSize: typo.sizeBodySmall,
                      color: colors.textPlaceholder,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  bool _isImagePath(String path) {
    final String lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }

  String _fileNameFromPath(String path) {
    return fileNameFromPath(path);
  }

  String _fileExtension(String path) {
    final String lower = path.toLowerCase();
    final int index = lower.lastIndexOf('.');
    if (index == -1 || index == lower.length - 1) return '';
    return lower.substring(index + 1);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _buildConstraintText() {
    final List<String> parts = <String>[];
    if (imageOnly) {
      parts.add('仅支持图片');
    } else if (accept != null && accept!.isNotEmpty) {
      parts.add('支持 ${accept!.join(' / ')}');
    }
    if (maxSizeMB != null) {
      parts.add(
        '单文件不超过 ${maxSizeMB!.toStringAsFixed(maxSizeMB! % 1 == 0 ? 0 : 1)}MB',
      );
    }
    return parts.join('，');
  }

  IconData _fileIconForPath(String path) {
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
        final double end =
            (distance + dashWidth).clamp(0.0, metric.length);
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
