import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Avatar size presets.
enum ParkAvatarSize { small, medium, large, xlarge }

/// Avatar shape.
enum ParkAvatarShape { circle, square }

/// A user avatar component with image, icon, or text fallback.
///
/// Displays a circular or rounded-square avatar. Falls back through
/// image → icon → text (first character) when a source is unavailable.
class ParkAvatar extends StatelessWidget {
  /// Creates a ParkAvatar.
  const ParkAvatar({
    super.key,
    this.image,
    this.icon,
    this.text,
    this.size = ParkAvatarSize.medium,
    this.customSize,
    this.shape = ParkAvatarShape.circle,
    this.badge,
    this.gap = 4,
    this.backgroundColor,
    this.onTap,
    this.srcSet,
    this.draggable = true,
  });

  /// Optional image provider. Takes highest priority.
  final ImageProvider? image;

  /// Optional icon shown when [image] is null.
  final IconData? icon;

  /// Optional text — first character is displayed when both [image] and [icon] are null.
  final String? text;

  /// Preset size. Ignored when [customSize] is provided.
  final ParkAvatarSize size;

  /// Explicit pixel size that overrides [size].
  final double? customSize;

  /// Circle or rounded-square shape.
  final ParkAvatarShape shape;

  /// Optional badge widget positioned at the bottom-right corner.
  final Widget? badge;

  /// Text avatar font size padding (percentage of avatar size).
  ///
  /// Controls the padding around text avatars. Default is 4.
  final int gap;

  /// Custom background color that overrides the default fallback color.
  final Color? backgroundColor;

  /// Tap callback — makes the avatar clickable.
  final VoidCallback? onTap;

  /// Responsive image source set (e.g. "200w, 400w") for different screen densities.
  final String? srcSet;

  /// Whether the avatar image is draggable.
  final bool draggable;

  double _resolveSize(ParkThemeData park) {
    if (customSize != null) return customSize!;
    switch (size) {
      case ParkAvatarSize.small:
        return 32;
      case ParkAvatarSize.medium:
        return 40;
      case ParkAvatarSize.large:
        return 56;
      case ParkAvatarSize.xlarge:
        return 72;
    }
  }

  double _fontSize(double avatarSize) => avatarSize * (0.4 - gap * 0.01);

  double _iconSize(double avatarSize) => avatarSize * 0.5;

  BorderRadius _borderRadius(double avatarSize) {
    if (shape == ParkAvatarShape.circle) {
      return BorderRadius.circular(avatarSize / 2);
    }
    return BorderRadius.circular(avatarSize * 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final dim = _resolveSize(park);

    Widget content;
    if (image != null) {
      content = Image(
        image: image!,
        width: dim,
        height: dim,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(park, dim),
      );
    } else {
      content = _buildFallback(park, dim);
    }

    final avatar = ClipRRect(
      borderRadius: _borderRadius(dim),
      child: Container(
        width: dim,
        height: dim,
        decoration: BoxDecoration(
          borderRadius: _borderRadius(dim),
        ),
        child: content,
      ),
    );

    if (badge == null) {
      return onTap != null
          ? GestureDetector(onTap: onTap, child: avatar)
          : avatar;
    }

    Widget result = SizedBox(
      width: dim,
      height: dim,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: badge!,
          ),
        ],
      ),
    );

    if (onTap != null) {
      result = GestureDetector(onTap: onTap, child: result);
    }

    return result;
  }

  Widget _buildFallback(ParkThemeData park, double dim) {
    if (icon != null) {
      return Container(
        width: dim,
        height: dim,
        alignment: Alignment.center,
        color: backgroundColor ?? park.colors.brandLight,
        child: Icon(
          icon,
          size: _iconSize(dim),
          color: park.colors.brand,
        ),
      );
    }

    if (text != null && text!.isNotEmpty) {
      return Container(
        width: dim,
        height: dim,
        alignment: Alignment.center,
        color: backgroundColor ?? park.colors.brand,
        child: Text(
          text![0].toUpperCase(),
          style: TextStyle(
            fontSize: _fontSize(dim),
            fontWeight: park.typography.weightBold,
            color: park.colors.textOnBrand,
          ),
        ),
      );
    }

    // Ultimate fallback: person icon
    return Container(
      width: dim,
      height: dim,
      alignment: Alignment.center,
      color: backgroundColor ?? park.colors.disabledBg,
      child: Icon(
        Icons.person,
        size: _iconSize(dim),
        color: park.colors.textPlaceholder,
      ),
    );
  }
}

/// ParkAvatarGroup — 头像组
///
/// 将多个头像重叠显示，超出部分显示剩余计数。
///
/// ```dart
/// ParkAvatarGroup(
///   avatars: [
///     ParkAvatar(image: NetworkImage('...')),
///     ParkAvatar(text: '张三'),
///     ParkAvatar(icon: Icons.person),
///   ],
///   maxCount: 3,
///   size: ParkAvatarSize.small,
/// )
/// ```
class ParkAvatarGroup extends StatelessWidget {
  /// 头像列表
  final List<ParkAvatar> avatars;

  /// 最大显示数量（超出部分显示 +N）
  final int maxCount;

  /// 头像尺寸
  final ParkAvatarSize size;

  /// 重叠间距
  final double overlap;

  /// 最大可见头像数（优先级高于 maxCount，用于外部控制显示数量）
  final int? count;

  const ParkAvatarGroup({
    super.key,
    required this.avatars,
    this.maxCount = 5,
    this.size = ParkAvatarSize.small,
    this.overlap = 8,
    this.count,
  });

  double _resolveSize(ParkThemeData park) {
    switch (size) {
      case ParkAvatarSize.small:
        return 32;
      case ParkAvatarSize.medium:
        return 40;
      case ParkAvatarSize.large:
        return 56;
      case ParkAvatarSize.xlarge:
        return 72;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final dim = _resolveSize(park);
    final effectiveMax = count ?? maxCount;
    final visibleCount = avatars.length.clamp(0, effectiveMax);
    final remaining = avatars.length - visibleCount;
    final totalWidth = dim + (visibleCount - 1) * (dim - overlap) +
        (remaining > 0 ? dim - overlap : 0);

    return SizedBox(
      width: totalWidth,
      height: dim,
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * (dim - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: park.colors.surface,
                    width: 2,
                  ),
                ),
                child: avatars[i],
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: visibleCount * (dim - overlap),
              child: Container(
                width: dim,
                height: dim,
                decoration: BoxDecoration(
                  color: park.colors.disabledBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: park.colors.surface,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: dim * 0.3,
                    fontWeight: park.typography.weightBold,
                    color: park.colors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
