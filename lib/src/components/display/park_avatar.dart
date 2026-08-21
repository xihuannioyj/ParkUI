import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Avatar size presets.
enum ParkAvatarSize { small, medium, large, xlarge }

/// Avatar shape.
enum ParkAvatarShape { circle, rounded, square }

/// Avatar online status.
enum ParkAvatarStatus { online, offline, busy, away }

/// A user avatar component with image, icon, or text fallback.
///
/// Displays a circular or rounded-square avatar. Falls back through
/// image → icon → text (first character) when a source is unavailable.
///
/// When [status] is provided, a colored status dot appears at the
/// bottom-right corner. Can coexist with [badge].
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
    this.status,
    this.statusDotSize = 8.0,
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

  /// Online status indicator shown as a colored dot at the bottom-right corner.
  ///
  /// Colors: online=green, offline=gray, busy=red, away=orange.
  /// When null, no status dot is rendered (backward compatible).
  final ParkAvatarStatus? status;

  /// Size of the status dot in logical pixels.
  ///
  /// Only meaningful when [status] is non-null. Defaults to 8.0.
  final double statusDotSize;

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

  // 边界防御：gap 过大时 0.4 - gap*0.01 会 ≤ 0 → 负字号 TextStyle 断言崩溃。
  double _fontSize(double avatarSize) =>
      avatarSize * (0.4 - gap * 0.01).clamp(0.12, 1.0).toDouble();

  double _iconSize(double avatarSize) => avatarSize * 0.5;

  BorderRadius _borderRadius(double avatarSize) {
    if (shape == ParkAvatarShape.circle) {
      return BorderRadius.circular(avatarSize / 2);
    }
    return BorderRadius.circular(avatarSize * 0.2);
  }

  /// Resolve the best image URL from [srcSet] based on device pixel ratio.
  ///
  /// Supports formats: "url 1x, url 2x" or "url 200w, url 400w".
  /// Falls back to the first URL if parsing fails.
  static ImageProvider? _resolveSrcSet(String? srcSet, ImageProvider? fallback, double devicePixelRatio) {
    if (srcSet == null || srcSet.isEmpty) return fallback;
    final entries = srcSet.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (entries.isEmpty) return fallback;

    String? bestUrl;
    double bestScore = double.infinity;

    for (final entry in entries) {
      final parts = entry.split(RegExp(r'\s+'));
      if (parts.isEmpty) continue;
      final url = parts[0];
      double descriptor = 1.0;
      if (parts.length >= 2) {
        final desc = parts[1];
        if (desc.endsWith('x')) {
          descriptor = double.tryParse(desc.substring(0, desc.length - 1)) ?? 1.0;
        } else if (desc.endsWith('w')) {
          descriptor = double.tryParse(desc.substring(0, desc.length - 1)) ?? 1.0;
        }
      }
      final score = (descriptor - devicePixelRatio).abs();
      if (score < bestScore) {
        bestScore = score;
        bestUrl = url;
      }
    }

    if (bestUrl != null && bestUrl.isNotEmpty) {
      return NetworkImage(bestUrl);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final dim = _resolveSize(park);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Resolve image provider: srcSet takes priority for responsive selection
    ImageProvider? resolvedImage = image;
    if (srcSet != null && srcSet!.isNotEmpty) {
      resolvedImage = _resolveSrcSet(srcSet, image, devicePixelRatio);
    }

    Widget content;
    if (resolvedImage != null) {
      content = Semantics(
        label: 'avatar',
        image: true,
        child: Image(
          image: resolvedImage,
          width: dim,
          height: dim,
          fit: BoxFit.cover,
          isAntiAlias: draggable,
          errorBuilder: (_, _, _) => _buildFallback(park, dim),
        ),
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

    if (badge == null && status == null) {
      if (onTap != null) {
        return Semantics(
          button: true,
          child: GestureDetector(onTap: onTap, child: avatar),
        );
      }
      return avatar;
    }

    final stackChildren = <Widget>[avatar];

    if (status != null) {
      stackChildren.add(
        Positioned(
          right: 0,
          bottom: 0,
          child: Semantics(
            label: '${status!.name} status',
            child: Container(
              width: statusDotSize,
              height: statusDotSize,
              decoration: BoxDecoration(
                color: _statusColor(park),
                shape: BoxShape.circle,
                border: Border.all(
                  color: park.colors.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (badge != null) {
      // Positioned 必须是 Stack 的直接子节点（ParentDataWidget 只能作用于
      // 直接子级），Semantics 移入 Positioned 内部（修复 ParentData 异常）。
      stackChildren.add(
        Positioned(
          right: -2,
          bottom: -2,
          child: Semantics(
            liveRegion: status != null,
            child: badge!,
          ),
        ),
      );
    }

    Widget result = SizedBox(
      width: dim,
      height: dim,
      child: Stack(
        clipBehavior: Clip.none,
        children: stackChildren,
      ),
    );

    if (onTap != null) {
      result = Semantics(
        button: true,
        child: GestureDetector(onTap: onTap, child: result),
      );
    }

    return result;
  }

  Color _statusColor(ParkThemeData park) {
    switch (status!) {
      case ParkAvatarStatus.online:
        return park.colors.success;
      case ParkAvatarStatus.offline:
        return park.colors.textDisabled;
      case ParkAvatarStatus.busy:
        return park.colors.error;
      case ParkAvatarStatus.away:
        return park.colors.warning;
    }
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
      return Semantics(
        label: text,
        child: Container(
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
    // 边界防御：空列表直接返回 shrink，避免渲染出 (dim-overlap) 宽的空占位框。
    if (avatars.isEmpty) return const SizedBox.shrink();
    // 边界防御：maxCount/count 传负数时 clamp(0, 负数) 会抛 ArgumentError。
    final effectiveMax = math.max(0, count ?? maxCount);
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
