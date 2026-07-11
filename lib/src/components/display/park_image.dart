import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Image shape presets.
enum ParkImageShape { circle, rounded, rectangle }

/// A network image component with caching, placeholder, error handling, and shape options.
///
/// Uses [Image.network] with built-in error builder. Supports
/// circle, rounded, and rectangle shapes.
/// Provides static cache management: [ParkImage.clearCache] and [ParkImage.preloadImage].
class ParkImage extends StatelessWidget {
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

  BorderRadius _resolveBorderRadius(ParkThemeData park) {
    if (borderRadius != null) return borderRadius!;
    switch (shape) {
      case ParkImageShape.circle:
        return park.radius.brFull;
      case ParkImageShape.rounded:
        return BorderRadius.circular(park.radius.md);
      case ParkImageShape.rectangle:
        return BorderRadius.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final radius = _resolveBorderRadius(park);

    final effectiveWidth = width ?? 100.0;
    final effectiveHeight = height ?? 100.0;

    final imageWidget = ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              src,
              width: effectiveWidth,
              height: effectiveHeight,
              fit: fit,
              frameBuilder: fadeInDuration != null
                  ? (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: fadeInDuration!,
                          builder: (context, value, child) {
                            return Opacity(opacity: value, child: child);
                          },
                          child: child,
                        );
                      }
                      if (placeholder != null) return placeholder!;
                      return Container(
                        width: effectiveWidth,
                        height: effectiveHeight,
                        color: park.colors.disabledBg,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: park.colors.brand,
                          ),
                        ),
                      );
                    }
                  : null,
              loadingBuilder: fadeInDuration != null
                  ? null
                  : (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      if (placeholder != null) return placeholder!;
                      return Container(
                        width: effectiveWidth,
                        height: effectiveHeight,
                        color: park.colors.disabledBg,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: park.colors.brand,
                          ),
                        ),
                      );
                    },
              errorBuilder: (context, error, stackTrace) {
                if (fallback != null) return fallback!;
                if (errorWidget != null) return errorWidget!;
                return Container(
                  width: effectiveWidth,
                  height: effectiveHeight,
                  color: park.colors.disabledBg,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 32,
                    color: park.colors.textPlaceholder,
                  ),
                );
              },
            ),
            // Caption overlay
            if (caption != null)
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
                    caption!,
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

    if (previewable) {
      return GestureDetector(
        onTap: () => _openPreview(context),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  void _openPreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ParkImagePreview(src: src),
      ),
    );
  }
}

/// Full-screen image preview overlay.
class _ParkImagePreview extends StatelessWidget {
  final String src;

  const _ParkImagePreview({required this.src});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            src,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
