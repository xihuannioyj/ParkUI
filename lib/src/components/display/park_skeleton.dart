import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 骨架屏组件
///
/// 在内容加载时展示占位骨架，支持自定义尺寸与圆角，
/// 并提供 shimmer 渐变扫光动画效果。
///
/// ```dart
/// ParkSkeleton(width: 200, height: 16)
/// ParkSkeleton.text(lines: 3)
/// ParkSkeleton.avatar(size: 40)
/// ParkSkeleton.card()
/// ```
class ParkSkeleton extends StatefulWidget {
  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 圆角半径
  final BorderRadius? borderRadius;

  /// 是否启用 shimmer 动画
  final bool animated;

  /// When true, shows a circular avatar placeholder.
  final bool avatar;

  /// Number of paragraph lines to display.
  final int paragraph;

  /// When true, shows shimmer/pulse animation. Alias for [animated], takes priority when set.
  final bool active;

  /// When true, shows a button-shaped placeholder.
  final bool button;

  /// When true, renders a pill-shaped (fully rounded) skeleton.
  final bool round;

  /// Wrapper mode: when true, shows skeleton overlay on top of [children].
  /// When false, shows [children] directly. When null, disabled (standard skeleton mode).
  final bool? loading;

  /// Content widgets shown when [loading] is false, or overlaid when [loading] is true.
  final List<Widget>? children;

  const ParkSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.animated = true,
    this.avatar = false,
    this.paragraph = 0,
    this.active = true,
    this.button = false,
    this.round = false,
    this.loading,
    this.children,
  });

  /// 文本骨架：多行文本占位
  ///
  /// [lines] 行数，默认 3
  /// [lineHeight] 每行高度，默认 14
  /// [spacing] 行间距，默认 12
  /// [lastLineWidthFraction] 最后一行宽度占比，默认 0.6
  static Widget text({
    Key? key,
    int lines = 3,
    double lineHeight = 14,
    double spacing = 12,
    double lastLineWidthFraction = 0.6,
    bool animated = true,
  }) {
    return _ParkSkeletonText(
      key: key,
      lines: lines,
      lineHeight: lineHeight,
      spacing: spacing,
      lastLineWidthFraction: lastLineWidthFraction,
      animated: animated,
    );
  }

  /// 头像骨架：圆形占位
  ///
  /// [size] 直径，默认 40
  factory ParkSkeleton.avatar({
    Key? key,
    double size = 40,
    bool animated = true,
  }) {
    return ParkSkeleton(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      animated: animated,
    );
  }

  /// 卡片骨架：模拟卡片布局
  static Widget card({
    Key? key,
    bool animated = true,
  }) {
    return _ParkSkeletonCard(key: key, animated: animated);
  }

  @override
  State<ParkSkeleton> createState() => _ParkSkeletonState();
}

class _ParkSkeletonState extends State<ParkSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isAnimated => widget.active && widget.animated;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (_isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ParkSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isAnimated && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!_isAnimated && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    // Wrapper mode: loading overlay on children
    if (widget.loading != null && widget.children != null && widget.children!.isNotEmpty) {
      if (widget.loading == false) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.children!,
        );
      }
      // loading == true: show skeleton overlay
      return Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children!,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: park.colors.surface.withValues(alpha: 0.6),
                child: Center(
                  child: ParkSkeleton(
                    width: double.infinity,
                    height: widget.height ?? 16,
                    animated: widget.animated,
                    active: widget.active,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // If any compound layout params are set, render composite skeleton
    if (widget.avatar || widget.paragraph > 0 || widget.button) {
      return _buildCompound(park);
    }

    final baseColor = park.colors.disabledBg;
    final highlightColor = park.colors.border.withValues(alpha: 0.3);
    // Round pill shape overrides borderRadius
    final br = widget.round
        ? BorderRadius.circular((widget.height ?? 16) / 2)
        : (widget.borderRadius ?? BorderRadius.circular(park.radius.sm));

    if (!_isAnimated) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: br,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: br,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompound(ParkThemeData park) {
    final children = <Widget>[];

    if (widget.avatar) {
      children.add(ParkSkeleton.avatar(animated: _isAnimated));
    }

    if (widget.paragraph > 0) {
      children.add(Padding(
        padding: EdgeInsets.only(top: park.spacing.md),
        child: ParkSkeleton.text(lines: widget.paragraph, animated: _isAnimated),
      ));
    }

    if (widget.button) {
      children.add(Padding(
        padding: EdgeInsets.only(top: park.spacing.md),
        child: ParkSkeleton(
          width: 120,
          height: 36,
          borderRadius: BorderRadius.circular(park.radius.md),
          animated: _isAnimated,
        ),
      ));
    }

    if (children.length == 1) return children.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// 文本骨架（内部组件）
class _ParkSkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineWidthFraction;
  final bool animated;

  const _ParkSkeletonText({
    super.key,
    required this.lines,
    required this.lineHeight,
    required this.spacing,
    required this.lastLineWidthFraction,
    required this.animated,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (index) {
        final isLast = index == lines - 1;
        final widthFraction = isLast ? lastLineWidthFraction : 1.0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isLast ? 0 : spacing,
          ),
          child: FractionallySizedBox(
            widthFactor: widthFraction,
            child: ParkSkeleton(
              height: lineHeight,
              borderRadius: BorderRadius.circular(park.radius.sm),
              animated: animated,
            ),
          ),
        );
      }),
    );
  }
}

/// 卡片骨架（内部组件）
class _ParkSkeletonCard extends StatelessWidget {
  final bool animated;

  const _ParkSkeletonCard({super.key, required this.animated});

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    return Container(
      padding: EdgeInsets.all(park.spacing.base),
      decoration: BoxDecoration(
        color: park.colors.surface,
        borderRadius: park.radius.brMd,
        boxShadow: park.shadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部：头像 + 标题
          Row(
            children: [
              ParkSkeleton.avatar(size: 40, animated: animated),
              SizedBox(width: park.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParkSkeleton(
                      height: 14,
                      borderRadius: BorderRadius.circular(park.radius.sm),
                      animated: animated,
                    ),
                    SizedBox(height: park.spacing.sm),
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      child: ParkSkeleton(
                        height: 12,
                        borderRadius: BorderRadius.circular(park.radius.sm),
                        animated: animated,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: park.spacing.base),

          // 内容行
          ParkSkeleton.text(
            lines: 3,
            animated: animated,
          ),

          SizedBox(height: park.spacing.base),

          // 底部图片占位
          ParkSkeleton(
            height: 120,
            borderRadius: park.radius.brSm,
            animated: animated,
          ),
        ],
      ),
    );
  }
}
