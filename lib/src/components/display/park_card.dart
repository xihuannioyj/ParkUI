import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../../theme/tokens/park_radius.dart';
import '../../theme/tokens/park_spacing.dart';
import 'park_skeleton.dart';

/// ParkCard 样式变体
enum ParkCardVariant { outlined, ghost, inner, preview }

/// ParkCard 尺寸预设
enum ParkCardSize { small, defaultSize, large }

/// ParkCard — 卡片容器组件
///
/// 提供带标题、右上角操作区、圆角阴影的卡片容器，
/// 支持 hoverable 悬浮效果、loading 骨架屏、cover 封面图、actions 操作栏、
/// 自定义内边距和颜色。
///
/// ```dart
/// ParkCard(
///   titleText: '卡片标题',
///   extra: ParkButton(variant: ParkButtonVariant.text, child: Text('更多')),
///   cover: Image.network('https://example.com/cover.jpg'),
///   actions: [TextButton(onPressed: () {}, child: Text('操作1'))],
///   child: Text('卡片内容'),
///   hoverable: true,
/// )
/// ```
class ParkCard extends StatefulWidget {
  /// 自定义标题 Widget（优先级高于 [titleText]）
  final Widget? title;

  /// 标题文字（当 [title] 为空时使用）
  final String? titleText;

  /// 右上角操作区
  final Widget? extra;

  /// 卡片内容
  final Widget child;

  /// 是否显示边框
  final bool bordered;

  /// 阴影高度（null 使用主题默认值）。
  ///
  /// 注意：仅在 `ParkSurfaceStyle.stripe` 主题风格下生效，
  /// 其他表面风格（flat / glass / neo / neon）使用各自内置阴影，忽略此参数。
  final double? elevation;

  /// 内容区内边距
  final EdgeInsetsGeometry? padding;

  /// 圆角（null 使用主题默认值）
  final BorderRadius? borderRadius;

  /// 背景色（null 使用主题默认值）
  final Color? color;

  /// 鼠标悬浮时是否浮起
  final bool hoverable;

  /// 点击回调（不为 null 时卡片可点击）
  final VoidCallback? onPressed;

  /// 是否处于加载状态（显示骨架屏）
  final bool loading;

  /// 底部操作栏（均匀分布的按钮，之间以分割线分隔）
  final List<Widget>? actions;

  /// 封面图/Widget（显示在卡片最顶部，标题之上）
  final Widget? cover;

  /// 卡片样式变体
  final ParkCardVariant variant;

  /// 卡片尺寸预设
  final ParkCardSize size;

  /// 是否在头部和内容之间显示分割线
  final bool headStyle;

  /// 是否可折叠（点击头部切换展开/收起）
  final bool collapsible;

  /// 描述文字（显示在标题下方）
  final String? description;

  /// 头部图标（显示在标题左侧，替代指示条）
  final Widget? icon;

  /// 是否显示左侧彩色指示条（显示在标题左侧，icon 为空时有效）
  final bool showIndicator;

  /// 自定义边框颜色（覆盖主题默认边框色）
  final Color? borderColor;

  const ParkCard({
    super.key,
    this.title,
    this.titleText,
    this.extra,
    required this.child,
    this.bordered = true,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.color,
    this.hoverable = false,
    this.onPressed,
    this.loading = false,
    this.actions,
    this.cover,
    this.variant = ParkCardVariant.outlined,
    this.size = ParkCardSize.defaultSize,
    this.headStyle = false,
    this.collapsible = false,
    this.description,
    this.icon,
    this.showIndicator = false,
    this.borderColor,
  });

  @override
  State<ParkCard> createState() => _ParkCardState();
}

class _ParkCardState extends State<ParkCard> {
  bool _isHovered = false;
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final ParkColors colors = park.colors;
    final ParkRadius radius = park.radius;
    final ParkSpacing spacing = park.spacing;

    final ({
      Color? color,
      Border? border,
      List<BoxShadow>? shadows,
      bool useGlass,
    })
    surface = _resolveSurface(park);

    // Determine effective border: borderColor overrides theme border when set.
    final Border? effectiveBorder = widget.borderColor != null && surface.border != null
        ? Border.all(color: widget.borderColor!, width: 1)
        : surface.border;

    final BorderRadius cardRadius = widget.borderRadius ?? radius.brMd;
    final EdgeInsetsGeometry defaultPadding = switch (widget.size) {
      ParkCardSize.small => EdgeInsets.all(spacing.sm),
      ParkCardSize.defaultSize => EdgeInsets.all(spacing.base),
      ParkCardSize.large => EdgeInsets.all(spacing.lg),
    };
    final EdgeInsetsGeometry cardPadding = widget.padding ?? defaultPadding;

    final bool hasHeader =
        widget.title != null ||
        widget.titleText != null ||
        widget.extra != null ||
        widget.collapsible ||
        widget.description != null ||
        widget.icon != null ||
        widget.showIndicator;

    // 卡片内容（加载时显示骨架屏）
    final Widget bodyContent = widget.loading
        ? _buildSkeletonContent(park)
        : widget.child;

    final Widget cardContent = Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: cardRadius,
        splashColor: colors.brand.withValues(alpha: 0.05),
        highlightColor: colors.brand.withValues(alpha: 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.cover != null) widget.cover!,
            Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (hasHeader) ...<Widget>[
                    GestureDetector(
                      onTap: widget.collapsible
                          ? () => setState(() => _isCollapsed = !_isCollapsed)
                          : null,
                      child: Container(
                        padding: widget.headStyle
                            ? EdgeInsets.only(bottom: spacing.sm)
                            : null,
                        decoration: widget.headStyle
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colors.divider,
                                    width: 0.5,
                                  ),
                                ),
                              )
                            : null,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // 图标或指示条
                            if (widget.icon != null)
                              Padding(
                                padding: EdgeInsets.only(right: spacing.sm),
                                child: widget.icon!,
                              )
                            else if (widget.showIndicator)
                              Container(
                                width: 4,
                                height: 20,
                                margin: EdgeInsets.only(right: spacing.sm),
                                decoration: BoxDecoration(
                                  color: colors.brand,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            // 标题 + 描述
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                            widget.title ??
                                            (widget.titleText != null
                                                ? Text(
                                                    widget.titleText!,
                                                    style: park.typography.body
                                                        .copyWith(
                                                          // 列表项名称统一 13 加粗（三档规范）
                                                          fontSize: park
                                                              .typography
                                                              .sizeBody,
                                                          fontWeight: park
                                                              .typography
                                                              .weightBold,
                                                          color: colors
                                                              .textPrimary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : const SizedBox.shrink()),
                                      ),
                                      if (widget.extra != null) widget.extra!,
                                      if (widget.collapsible)
                                        Icon(
                                          _isCollapsed
                                              ? Icons
                                                    .keyboard_arrow_down_rounded
                                              : Icons.keyboard_arrow_up_rounded,
                                          size: 20,
                                          color: colors.textPlaceholder,
                                        ),
                                    ],
                                  ),
                                  if (widget.description != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: spacing.xs),
                                      child: Text(
                                        widget.description!,
                                        style: park.typography.caption.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: widget.headStyle ? spacing.md : spacing.base,
                    ),
                  ],
                  if (!_isCollapsed) bodyContent,
                ],
              ),
            ),
            if (widget.actions != null && widget.actions!.isNotEmpty)
              _buildActionsBar(park),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      label: widget.titleText,
      child: MouseRegion(
      onEnter: widget.hoverable || widget.onPressed != null
          ? (_) => setState(() => _isHovered = true)
          : null,
      onExit: widget.hoverable || widget.onPressed != null
          ? (_) => setState(() => _isHovered = false)
          : null,
      child: surface.useGlass
          ? AnimatedContainer(
              duration: park.motion.standard,
              curve: park.motion.defaultEasing,
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                boxShadow: surface.shadows,
              ),
              child: ClipRRect(
                borderRadius: cardRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AnimatedContainer(
                    duration: park.motion.standard,
                    curve: park.motion.defaultEasing,
                    decoration: BoxDecoration(
                      color: surface.color,
                      borderRadius: cardRadius,
                      border: effectiveBorder,
                    ),
                    child: cardContent,
                  ),
                ),
              ),
            )
          : AnimatedContainer(
              duration: park.motion.standard,
              curve: park.motion.defaultEasing,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: surface.color,
                borderRadius: cardRadius,
                border: effectiveBorder,
                boxShadow: surface.shadows,
              ),
              child: cardContent,
            ),
          ),
    );
  }

  /// 根据当前 [ParkThemeData.surfaceStyle] 解析卡片的表面材质：
  /// 颜色 / 边框 / 阴影 / 是否使用毛玻璃。
  ({Color? color, Border? border, List<BoxShadow>? shadows, bool useGlass})
  _resolveSurface(ParkThemeData park) {
    final ParkColors colors = park.colors;
    final bool isGhost = widget.variant == ParkCardVariant.ghost;
    final Color? explicit = widget.color;

    switch (park.surfaceStyle) {
      case ParkSurfaceStyle.flat:
        final Color color =
            explicit ?? (isGhost ? Colors.transparent : colors.surface);
        final Border? border = widget.bordered
            ? Border.all(
                color: _isHovered && widget.hoverable
                    ? colors.brand.withValues(alpha: 0.35)
                    : colors.borderLight,
                width: 1,
              )
            : null;
        return (color: color, border: border, shadows: null, useGlass: false);

      case ParkSurfaceStyle.glass:
        final Color color = explicit ?? colors.surface.withValues(alpha: 0.55);
        final Border? border = widget.bordered
            ? Border.all(
                color: colors.textOnBrand.withValues(alpha: 0.40), width: 1)
            : null;
        final List<BoxShadow> shadows = <BoxShadow>[
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ];
        return (color: color, border: border, shadows: shadows, useGlass: true);

      case ParkSurfaceStyle.neo:
        final Color color =
            explicit ?? (isGhost ? Colors.transparent : colors.background);
        final List<BoxShadow> shadows = isGhost
            ? <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: colors.textOnBrand.withValues(alpha: 0.9),
                  blurRadius: 12,
                  offset: const Offset(-5, -5),
                ),
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(5, 5),
                ),
              ];
        return (color: color, border: null, shadows: shadows, useGlass: false);

      case ParkSurfaceStyle.neon:
        final bool isDark = colors.background.computeLuminance() < 0.5;
        final Color color =
            explicit ??
            (isGhost
                ? Colors.transparent
                : (isDark ? colors.textPrimary : colors.surface));
        final Border? border = widget.bordered
            ? Border.all(color: colors.brand.withValues(alpha: 0.55), width: 1)
            : null;
        final List<BoxShadow> shadows = isGhost
            ? <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: colors.brand.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ];
        return (
          color: color,
          border: border,
          shadows: shadows,
          useGlass: false,
        );

      case ParkSurfaceStyle.stripe:
        final Color color =
            explicit ?? (isGhost ? Colors.transparent : colors.surface);
        final Border? border = _defaultBorder(park);
        final double baseElevation = widget.elevation ?? 0;
        final double currentElevation =
            baseElevation + (_isHovered && widget.hoverable ? 2.0 : 0);
        final List<BoxShadow>? shadows = currentElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: currentElevation * 4,
                  offset: Offset(0, currentElevation * 2),
                ),
              ]
            : null;
        return (
          color: color,
          border: border,
          shadows: shadows,
          useGlass: false,
        );
    }
  }

  /// Stripe 经典风的默认边框逻辑（按 variant 区分）。
  Border? _defaultBorder(ParkThemeData park) {
    final ParkColors colors = park.colors;
    if (!widget.bordered) return null;
    if (widget.variant == ParkCardVariant.outlined ||
        widget.variant == ParkCardVariant.ghost) {
      return Border.all(
        color: _isHovered && widget.hoverable
            ? colors.brand.withValues(alpha: 0.3)
            : colors.border,
        width: 1,
      );
    } else if (widget.variant == ParkCardVariant.inner) {
      return Border.all(color: colors.disabledBg, width: 1);
    }
    return null;
  }

  Widget _buildSkeletonContent(ParkThemeData park) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ParkSkeleton(
          width: double.infinity,
          height: 16,
          borderRadius: BorderRadius.circular(park.radius.sm),
        ),
        SizedBox(height: park.spacing.sm),
        FractionallySizedBox(
          widthFactor: 0.8,
          child: ParkSkeleton(
            height: 14,
            borderRadius: BorderRadius.circular(park.radius.sm),
          ),
        ),
        SizedBox(height: park.spacing.sm),
        FractionallySizedBox(
          widthFactor: 0.6,
          child: ParkSkeleton(
            height: 14,
            borderRadius: BorderRadius.circular(park.radius.sm),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsBar(ParkThemeData park) {
    final actions = widget.actions!;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: park.colors.divider, width: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: actions.asMap().entries.expand((entry) sync* {
            final index = entry.key;
            final action = entry.value;
            if (index > 0) {
              yield VerticalDivider(
                width: 1,
                thickness: 0.5,
                color: park.colors.divider,
              );
            }
            yield Expanded(child: Center(child: action));
          }).toList(),
        ),
      ),
    );
  }
}
