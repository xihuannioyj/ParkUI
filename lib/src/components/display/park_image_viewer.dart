import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// Park 全屏图片查看器
///
/// 通过静态方法 [show] 以全屏覆盖层方式打开图片查看器，
/// 支持左右滑动（PageView）、双指缩放（InteractiveViewer）、
/// 关闭按钮与页码指示器。
///
/// 增强功能：
/// - 预览工具条（缩放/旋转/翻转）
/// - 失败兜底 [errorBuilder]
/// - 点击关闭 [onTap]
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

  /// 是否显示底部预览工具条（缩放+、缩放−、旋转、翻转）。
  final bool showToolbar;

  /// 图片加载失败时自定义渲染 Widget。
  /// 不传时默认显示 `Icons.broken_image` 灰色图标 + "图片加载失败" 文字。
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  /// 点击预览区域触发。默认关闭查看器。
  final VoidCallback? onTap;

  const ParkImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onLongPress,
    this.showIndex = true,
    this.doubleTapZoom = true,
    this.swipeToDismiss = true,
    this.showToolbar = true,
    this.errorBuilder,
    this.onTap,
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
    bool showToolbar = true,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    VoidCallback? onTap,
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
          showToolbar: showToolbar,
          errorBuilder: errorBuilder,
          onTap: onTap,
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

  /// 按需创建的 TransformationController，只在 [showToolbar] 为 true 时使用。
  final List<TransformationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _close() {
    Navigator.of(context).pop();
  }

  // ── 控制器管理 ──

  TransformationController _controllerForIndex(int index) {
    while (_controllers.length <= index) {
      _controllers.add(TransformationController());
    }
    return _controllers[index];
  }

  TransformationController? get _currentController {
    if (_currentIndex < _controllers.length) {
      return _controllers[_currentIndex];
    }
    return null;
  }

  // ── 工具条操作 ──

  void _zoomIn() {
    final ctrl = _currentController;
    if (ctrl == null) return;
    final current = ctrl.value;
    final scale = current.getMaxScaleOnAxis();
    if (scale >= 4.0) return;
    final newScale = (scale * 1.25).clamp(0.5, 4.0);
    final ratio = newScale / scale;
    ctrl.value = current * Matrix4.diagonal3Values(ratio, ratio, 1.0);
  }

  void _zoomOut() {
    final ctrl = _currentController;
    if (ctrl == null) return;
    final current = ctrl.value;
    final scale = current.getMaxScaleOnAxis();
    if (scale <= 0.5) return;
    final newScale = (scale / 1.25).clamp(0.5, 4.0);
    final ratio = newScale / scale;
    ctrl.value = current * Matrix4.diagonal3Values(ratio, ratio, 1.0);
  }

  void _rotate() {
    final ctrl = _currentController;
    if (ctrl == null) return;
    final current = ctrl.value;
    ctrl.value = current * Matrix4.rotationZ(math.pi / 2);
  }

  void _flipHorizontal() {
    final ctrl = _currentController;
    if (ctrl == null) return;
    final current = ctrl.value;
    ctrl.value = current * Matrix4.diagonal3Values(-1, 1, 1);
  }

  void _flipVertical() {
    final ctrl = _currentController;
    if (ctrl == null) return;
    final current = ctrl.value;
    ctrl.value = current * Matrix4.diagonal3Values(1, -1, 1);
  }

  // ── 构建 ──

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);

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
                onTap: widget.onTap ?? _close,
                onLongPress: widget.onLongPress,
                child: _ZoomableImage(
                  imageProvider: widget.images[index],
                  doubleTapZoom: widget.doubleTapZoom,
                  transformationController: widget.showToolbar
                      ? _controllerForIndex(index)
                      : null,
                  errorBuilder: widget.errorBuilder,
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
                  Semantics(
                    label: l10n.closeText,
                    button: true,
                    child: GestureDetector(
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
                  ),

                  // 页码指示器
                  if (widget.showIndex && widget.images.length > 1)
                    Semantics(
                      label: '${_currentIndex + 1} / ${widget.images.length}',
                      container: true,
                      child: Container(
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

          // 底部预览工具条
          if (widget.showToolbar) _buildToolbar(park),
        ],
      ),
    );

    // Swipe to dismiss: vertical drag down to close
    if (widget.swipeToDismiss) {
      scaffold = GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            _close();
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  /// 构建底部预览工具条：缩放+、缩放−、旋转、水平翻转、垂直翻转
  Widget _buildToolbar(ParkThemeData park) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(bottom: park.spacing.base),
            padding: EdgeInsets.symmetric(
              horizontal: park.spacing.base,
              vertical: park.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: park.radius.brFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToolbarButton(
                  icon: Icons.zoom_out,
                  semanticLabel: ParkLocalizations.of(context).decreaseValue,
                  onTap: _zoomOut,
                ),
                SizedBox(width: park.spacing.lg),
                _ToolbarButton(
                  icon: Icons.zoom_in,
                  semanticLabel: ParkLocalizations.of(context).increaseValue,
                  onTap: _zoomIn,
                ),
                SizedBox(width: park.spacing.lg),
                _ToolbarButton(
                  icon: Icons.rotate_right,
                  semanticLabel: '旋转',
                  onTap: _rotate,
                ),
                SizedBox(width: park.spacing.lg),
                _ToolbarButton(
                  icon: Icons.flip,
                  semanticLabel: '水平翻转',
                  onTap: _flipHorizontal,
                ),
                SizedBox(width: park.spacing.lg),
                _ToolbarButton(
                  icon: Icons.flip_to_front,
                  semanticLabel: '垂直翻转',
                  onTap: _flipVertical,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 工具条按钮
// =============================================================================

/// 预览工具条中的单个操作按钮
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 可缩放图片（内部组件）
// =============================================================================

/// 可缩放图片，支持双指缩放（InteractiveViewer）和双击切换缩放。
class _ZoomableImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final bool doubleTapZoom;

  /// 外部传入的 TransformationController。
  /// 由父组件在 [ParkImageViewer.showToolbar] 为 true 时提供，
  /// 用于工具条按钮控制当前图片的缩放/旋转/翻转。
  final TransformationController? transformationController;

  /// 外部传入的错误构建器。为 null 时使用默认兜底 UI。
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const _ZoomableImage({
    required this.imageProvider,
    this.doubleTapZoom = true,
    this.transformationController,
    this.errorBuilder,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  late final TransformationController _transformController;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformController = widget.transformationController ??
        TransformationController();
  }

  @override
  void dispose() {
    // 仅当控制器由本组件创建时才负责销毁
    if (widget.transformationController == null) {
      _transformController.dispose();
    }
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
            errorBuilder: widget.errorBuilder ?? _defaultErrorBuilder,
          ),
        ),
      ),
    );
  }

  /// 默认图片加载失败兜底 UI
  Widget _defaultErrorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final l10n = ParkLocalizations.of(context);
    return Semantics(
      label: l10n.imageLoadFailed,
      image: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.white.withValues(alpha: 0.5),
            size: 64,
          ),
          SizedBox(height: park.spacing.sm),
          Text(
            l10n.imageLoadFailed,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: park.typography.sizeBodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
