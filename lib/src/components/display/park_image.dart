import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import 'park_image_viewer.dart';

/// Image shape presets.
enum ParkImageShape { circle, rounded, rectangle }

/// A network image component with caching, placeholder, error handling, and shape options.
///
/// Uses [Image.network] with built-in error builder. Supports
/// circle, rounded, and rectangle shapes.
/// Provides static cache management: [ParkImage.clearCache] and [ParkImage.preloadImage].
class ParkImage extends StatefulWidget {
  /// Creates a ParkImage.
  const ParkImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.shape = ParkImageShape.rounded,
    this.previewable = false,
    this.fallback,
    this.fadeInDuration,
    this.caption,
    this.lazy = false,
    this.retry = 0,
    this.onLoad,
    this.onError,
    this.memoryCache = true,
    this.allowedSchemes = const <String>['http', 'https'],
  });

  /// Image URL.
  final String src;

  /// Optional width constraint.
  final double? width;

  /// Optional height constraint.
  final double? height;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  /// Widget shown while the image is loading.
  final Widget? placeholder;

  /// Widget shown when loading fails.
  final Widget? errorWidget;

  /// Explicit border radius. Overrides [shape] defaults when provided.
  final BorderRadius? borderRadius;

  /// Shape preset.
  final ParkImageShape shape;

  /// When true, tapping image opens full-screen viewer.
  final bool previewable;

  /// Custom error/fallback widget when image fails to load.
  /// Takes priority over [errorWidget] when both are set.
  final Widget? fallback;

  /// Duration of the fade-in animation when the image finishes loading.
  /// When null, no fade animation is applied.
  final Duration? fadeInDuration;

  /// Overlay caption text displayed at the bottom of the image.
  final String? caption;

  /// Whether to lazily load the image (defer loading until visible in viewport).
  final bool lazy;

  /// Number of retries when loading fails. Default 0 (no retry).
  final int retry;

  /// Called when image loads successfully.
  final VoidCallback? onLoad;

  /// Called when image loading fails.
  final VoidCallback? onError;

  /// Whether to cache the image in memory. When true, uses [imageCache] for
  /// caching decoded images; when false, bypasses cache.
  /// Default true.
  final bool memoryCache;

  /// Allowed URL schemes for the image source.
  ///
  /// Before building the [ImageProvider], the URL's scheme is validated
  /// against this list. Defaults to `['http', 'https']`.
  /// Set to an empty list to allow any scheme.
  final List<String> allowedSchemes;

  /// Preload an image into the image cache.
  /// Returns a [Future] that completes when the image is fully decoded.
  static Future<void> preloadImage(BuildContext context, String url) {
    return precacheImage(NetworkImage(url), context);
  }

  /// Clear the entire image cache.
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
  }

  /// Evict a specific image from cache by URL.
  static void evictImage(String url) {
    PaintingBinding.instance.imageCache.evict(NetworkImage(url));
  }

  @override
  State<ParkImage> createState() => _ParkImageState();
}

class _ParkImageState extends State<ParkImage> {
  int _retryCount = 0;
  int _loadAttempt = 0;
  bool _isVisible = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _isVisible = !widget.lazy;
    if (widget.lazy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkVisibility();
      });
    }
  }

  @override
  void didUpdateWidget(ParkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _retryCount = 0;
      _loadAttempt++;
      _hasError = false;
      _isVisible = !widget.lazy;
      if (widget.lazy) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkVisibility();
        });
      }
    }
    if (oldWidget.lazy != widget.lazy && widget.lazy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkVisibility();
      });
    }
  }

  void _checkVisibility() {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;
    final RenderBox box = renderObject as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    // B80: Check both X and Y axis viewport visibility (with 200px preload buffer).
    final viewportHeight = MediaQuery.of(context).size.height;
    final viewportWidth = MediaQuery.of(context).size.width;
    final visibleY = position.dy + size.height >= -200 &&
        position.dy <= viewportHeight + 200;
    final visibleX = position.dx + size.width >= -200 &&
        position.dx <= viewportWidth + 200;
    if (visibleY && visibleX) {
      if (!_isVisible) {
        setState(() => _isVisible = true);
      }
    } else {
      if (_isVisible) {
        setState(() => _isVisible = false);
      }
    }
  }

  void _onLoadSuccess() {
    if (!mounted) return;
    _hasError = false;
    if (!widget.memoryCache) {
      PaintingBinding.instance.imageCache.evict(NetworkImage(widget.src));
    }
    widget.onLoad?.call();
  }

  void _onLoadError() {
    if (!mounted) return;
    _hasError = true;
    if (_retryCount < widget.retry) {
      _retryCount++;
      _loadAttempt++;
      setState(() {});
    } else {
      widget.onError?.call();
    }
  }

  /// 检查 URL 的 scheme 是否在允许列表中。
  ///
  /// 若 [allowedSchemes] 为空列表，则默认仅允许 http / https。
  static bool _isSchemeAllowed(String url, List<String> allowedSchemes) {
    final List<String> allowed =
        allowedSchemes.isEmpty ? <String>['http', 'https'] : allowedSchemes;
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return false;
    final String scheme = uri.scheme.toLowerCase();
    if (scheme.isEmpty) return false;
    return allowed
        .map((String s) => s.toLowerCase())
        .contains(scheme);
  }

  BorderRadius _resolveBorderRadius(ParkThemeData park) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    switch (widget.shape) {
      case ParkImageShape.circle:
        return park.radius.brFull;
      case ParkImageShape.rounded:
        return BorderRadius.circular(park.radius.md);
      case ParkImageShape.rectangle:
        return BorderRadius.zero;
    }
  }

  Widget _buildDefaultPlaceholder(
    ParkThemeData park,
    double w,
    double h, [
    ImageChunkEvent? loadingProgress,
  ]) {
    return Container(
      width: w,
      height: h,
      color: park.colors.disabledBg,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: loadingProgress?.expectedTotalBytes != null
              ? loadingProgress!.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          color: park.colors.brand,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ParkThemeData park, double w, double h) {
    if (widget.fallback != null) return widget.fallback!;
    if (widget.errorWidget != null) return widget.errorWidget!;
    return Container(
      width: w,
      height: h,
      color: park.colors.disabledBg,
      child: Icon(
        Icons.broken_image_outlined,
        size: 32,
        color: park.colors.textPlaceholder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final radius = _resolveBorderRadius(park);

    final effectiveWidth = widget.width ?? 100.0;
    final effectiveHeight = widget.height ?? 100.0;

    // URL scheme 安全校验
    final bool schemeValid = _isSchemeAllowed(widget.src, widget.allowedSchemes);

    // 内存缓存控制：memoryCache=false 时绕过 ImageCache
    final ImageProvider imageProvider = NetworkImage(widget.src);

    Widget buildImageContent() {
      if (!schemeValid) {
        return _buildErrorWidget(park, effectiveWidth, effectiveHeight);
      }
      if (!_isVisible && widget.lazy) {
        return _buildDefaultPlaceholder(park, effectiveWidth, effectiveHeight);
      }
      if (_hasError && _retryCount >= widget.retry) {
        return _buildErrorWidget(park, effectiveWidth, effectiveHeight);
      }

      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image(
                key: ValueKey('${widget.src}_$_loadAttempt'),
                image: imageProvider,
                width: effectiveWidth,
                height: effectiveHeight,
                fit: widget.fit,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame != null) {
                    // 图片至少加载了一帧，标记成功
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _onLoadSuccess(),
                    );
                    if (widget.fadeInDuration != null && !wasSynchronouslyLoaded) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: widget.fadeInDuration!,
                        builder: (context, value, child) {
                          return Opacity(opacity: value, child: child);
                        },
                        child: child,
                      );
                    }
                    return child;
                  }
                  // frame 为 null，图片还在加载
                  if (widget.placeholder != null) return widget.placeholder!;
                  return _buildDefaultPlaceholder(park, effectiveWidth, effectiveHeight);
                },
                loadingBuilder: widget.fadeInDuration != null
                    ? null
                    : (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        if (widget.placeholder != null) return widget.placeholder!;
                        return _buildDefaultPlaceholder(
                          park,
                          effectiveWidth,
                          effectiveHeight,
                          loadingProgress,
                        );
                      },
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _onLoadError());
                  return _buildErrorWidget(park, effectiveWidth, effectiveHeight);
                },
              ),
              // Caption overlay
              if (widget.caption != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: park.spacing.sm,
                      vertical: park.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: Text(
                      widget.caption!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: park.typography.sizeBodySmall,
                        fontWeight: park.typography.weightMedium,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    Widget imageWidget = buildImageContent();

    if (widget.previewable) {
      imageWidget = Semantics(
        button: true,
        label: 'Preview image',
        child: GestureDetector(
        onTap: () => _openPreview(context),
        child: imageWidget,
      ),
      );
    }

    return imageWidget;
  }

  void _openPreview(BuildContext context) {
    ParkImageViewer.show(
      context,
      images: <ImageProvider>[NetworkImage(widget.src)],
      initialIndex: 0,
    );
  }
}
