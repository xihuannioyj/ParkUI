import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 全屏图片查看器
///
/// 通过静态方法 [show] 以全屏覆盖层方式打开图片查看器，
/// 支持左右滑动（PageView）、双指缩放（InteractiveViewer）、
/// 关闭按钮与页码指示器。
///
/// ```dart
/// ParkImageViewer.show(
///   context,
///   images: [NetworkImage('https://...')],
///   initialIndex: 0,
/// );
/// ```
class ParkImageViewer extends StatefulWidget {
  /// 图片列表
  final List<ImageProvider> images;

  /// 初始显示索引
  final int initialIndex;

  /// 长按图片时触发（用于保存/分享等操作）。
  final VoidCallback? onLongPress;

  /// 是否显示 "1/5" 索引指示器。
  final bool showIndex;

  /// 是否启用双击切换缩放。
  final bool doubleTapZoom;

  /// 是否启用垂直滑动关闭。
  final bool swipeToDismiss;

  const ParkImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onLongPress,
    this.showIndex = true,
    this.doubleTapZoom = true,
    this.swipeToDismiss = true,
  });

  /// 以全屏覆盖层方式展示图片查看器
  static void show(
    BuildContext context, {
    required List<ImageProvider> images,
    int initialIndex = 0,
    VoidCallback? onLongPress,
    bool showIndex = true,
    bool doubleTapZoom = true,
    bool swipeToDismiss = true,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        pageBuilder: (_, _, _) => ParkImageViewer(
          images: images,
          initialIndex: initialIndex,
          onLongPress: onLongPress,
          showIndex: showIndex,
          doubleTapZoom: doubleTapZoom,
          swipeToDismiss: swipeToDismiss,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  State<ParkImageViewer> createState() => _ParkImageViewerState();
}

class _ParkImageViewerState extends State<ParkImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    Widget scaffold = Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片 PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: widget.onLongPress,
                child: _ZoomableImage(
                  imageProvider: widget.images[index],
                  doubleTapZoom: widget.doubleTapZoom,
                ),
              );
            },
          ),

          // 顶部栏：关闭按钮 + 页码指示器
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.base,
                vertical: park.spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 关闭按钮
                  GestureDetector(
                    onTap: _close,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // 页码指示器
                  if (widget.showIndex && widget.images.length > 1)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: park.spacing.md,
                        vertical: park.spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: park.radius.brFull,
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.images.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: park.typography.sizeBodySmall,
                          fontWeight: park.typography.weightMedium,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  // 占位，保持居中
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Swipe to dismiss: vertical drag down to close
    if (widget.swipeToDismiss) {
      scaffold = GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
            _close();
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}

/// 可缩放图片（内部组件）
class _ZoomableImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final bool doubleTapZoom;

  const _ZoomableImage({
    required this.imageProvider,
    this.doubleTapZoom = true,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _transformController = TransformationController();
  bool _isZoomed = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (!widget.doubleTapZoom) return;
    setState(() {
      if (_isZoomed) {
        _transformController.value = Matrix4.identity();
        _isZoomed = false;
      } else {
        _transformController.value = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
        _isZoomed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: widget.doubleTapZoom ? _handleDoubleTap : null,
      child: Center(
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 4.0,
          boundaryMargin: const EdgeInsets.all(100),
          child: Image(
            image: widget.imageProvider,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) {
              final park = Theme.of(context).extension<ParkThemeData>() ??
                  ParkThemeData.light();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 64,
                  ),
                  SizedBox(height: park.spacing.sm),
                  Text(
                    '图片加载失败',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: park.typography.sizeBodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
