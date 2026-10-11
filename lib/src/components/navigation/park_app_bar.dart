import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_surface.dart';

/// ParkAppBar / ParkSliverAppBar 默认阴影高度（扁平品牌风格，无阴影）。
const double _kDefaultElevation = 0.0;

/// ParkSliverAppBar 默认展开高度。
const double _kDefaultExpandedHeight = 200.0;

/// 返回按钮图标尺寸（与 ParkNavBar 保持一致）。
const double _kBackIconSize = 16.0;

/// 标题与 leading / actions 之间的默认间距（对齐 Flutter NavigationToolbar）。
const double _kDefaultTitleSpacing = NavigationToolbar.kMiddleSpacing;

/// 构建标题 Widget：String 走 Park 排版令牌，Widget 合并默认文字样式。
/// 当 [subtitle] 非空时，标题与副标题以 Column 纵向排列（副标题走 bodySmall 令牌）。
Widget? _parkBarTitle(
  Object? title,
  ParkThemeData park,
  Color titleColor, {
  String? subtitle,
  Color? subtitleColor,
}) {
  if (title == null && subtitle == null) return null;
  final TextStyle titleStyle = park.typography.h3.copyWith(color: titleColor);
  Widget titleWidget;
  if (title == null) {
    titleWidget = const SizedBox.shrink();
  } else if (title is String) {
    titleWidget = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: titleStyle,
    );
  } else {
    titleWidget =
        DefaultTextStyle.merge(style: titleStyle, child: title as Widget);
  }
  if (subtitle == null) return titleWidget;
  final TextStyle subtitleStyle = park.typography.bodySmall.copyWith(
    color: subtitleColor ?? titleColor.withValues(alpha: 0.65),
  );
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      titleWidget,
      Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: subtitleStyle,
      ),
    ],
  );
}

/// 构建带 Semantics 的返回按钮（label 走 ParkLocalizations：zh「返回」/ en「Back」）。
Widget _parkBarBackButton(BuildContext context, Color color) {
  return Semantics(
    button: true,
    label: ParkLocalizations.of(context).backLabel,
    child: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, size: _kBackIconSize, color: color),
      onPressed: () {
        final NavigatorState? navigator = Navigator.maybeOf(context);
        if (navigator != null && navigator.canPop()) {
          navigator.maybePop();
        }
      },
    ),
  );
}

/// leading 解析结果：最终传给 AppBar 的 leading 与 automaticallyImplyLeading。
class _ParkBarLeading {
  final Widget? widget;
  final bool imply;

  const _ParkBarLeading(this.widget, this.imply);
}

/// 解析 leading：可弹出且无抽屉时返回 Park 品牌返回按钮，
/// 其余情况交还原生 AppBar 的 imply 逻辑（抽屉按钮等）。
_ParkBarLeading _parkBarResolveLeading(
  BuildContext context,
  Widget? leading,
  bool automaticallyImplyLeading,
  Color fgColor,
) {
  if (leading != null || !automaticallyImplyLeading) {
    return _ParkBarLeading(leading, automaticallyImplyLeading);
  }
  final bool hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
  final bool canPop = Navigator.maybeOf(context)?.canPop() ?? false;
  if (canPop && !hasDrawer) {
    return _ParkBarLeading(_parkBarBackButton(context, fgColor), false);
  }
  return const _ParkBarLeading(null, true);
}

/// AppBar 表面材质的派生结果，供普通与 Sliver 形态共用。
@immutable
class ParkAppBarSurface {
  final Color fill;
  final Color titleColor;
  final Color bodyColor;
  final Color? shadowColor;
  final bool useBlur;
  final double blurSigma;

  const ParkAppBarSurface({
    required this.fill,
    required this.titleColor,
    required this.bodyColor,
    required this.shadowColor,
    required this.useBlur,
    required this.blurSigma,
  });
}

/// 解析 AppBar 表面材质。
///
/// AppBar 的 `elevation == 0` 是显式的无阴影语义，因此不会仅因切换风格
/// 凭空抬起；只有调用方请求 elevation 时，glass / neo / neon 才用令牌阴影
/// 的主色接管 Material 阴影色。圆角、shape、bottom 均保持原组件路径。
@visibleForTesting
ParkAppBarSurface resolveParkAppBarSurface({
  required BuildContext context,
  required ParkThemeData park,
  Color? backgroundColor,
  Color? foregroundColor,
  Color? shadowColor,
  double elevation = _kDefaultElevation,
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );
  final Color titleColor = foregroundColor ?? tokens.titleColor;

  return ParkAppBarSurface(
    fill: backgroundColor ?? tokens.fill,
    titleColor: titleColor,
    // stripe 必须保留改造前的 65% 前景色；其他风格消费表面正文语义色。
    bodyColor: foregroundColor != null
        ? foregroundColor.withValues(alpha: 0.65)
        : tokens.style == ParkSurfaceStyle.stripe
            ? park.colors.textPrimary.withValues(alpha: 0.65)
            : tokens.bodyColor,
    shadowColor: shadowColor ??
        (elevation > 0 && tokens.shadows != null && tokens.shadows!.isNotEmpty
            ? tokens.shadows!.first.color
            : null),
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
  );
}

/// glass AppBar 把填充与用户 flexibleSpace 放在同一模糊层内。
Widget? _parkBarFlexibleSpace({
  required Widget? child,
  required ParkAppBarSurface surface,
  required bool canBlur,
}) {
  if (!canBlur) return child;
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: surface.blurSigma,
        sigmaY: surface.blurSigma,
      ),
      child: ColoredBox(
        color: surface.fill,
        child: child ?? const SizedBox.expand(),
      ),
    ),
  );
}

/// Park 顶部应用栏 — 对齐 Flutter 原生 [AppBar] 的参数面，
/// 默认值全部走 ParkTheme 设计令牌（背景 [ParkColors.surface]、
/// 标题 [ParkTypography.h3]），用于收敛 ylzj 等项目中的原生 AppBar 用法（B273）。
///
/// 与 [ParkNavBar] 的区别：[ParkNavBar] 为完全自绘的轻量导航栏；
/// [ParkAppBar] 直接包装 [AppBar]，保留 Material 原生行为
/// （Scaffold.appBar 插槽、bottom、elevation 等），仅替换品牌视觉。
///
/// ```dart
/// Scaffold(
///   appBar: ParkAppBar(
///     title: '首页',
///     actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
///   ),
///   body: ...
/// )
/// ```
class ParkAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题：支持 String（走 Park 排版令牌）或自定义 Widget。
  final Object? title;

  /// 副标题：显示在标题下方，走 Park 排版令牌 bodySmall（14px，65% 透明度）。
  final String? subtitle;

  /// 自定义前置 Widget（替代默认返回按钮）。
  final Widget? leading;

  /// 是否在未提供 [leading] 时自动推断前置控件
  /// （可弹出路由显示 Park 返回按钮，有抽屉时显示抽屉按钮）。
  final bool automaticallyImplyLeading;

  /// 右侧操作按钮列表。
  final List<Widget>? actions;

  /// 标题是否居中；null 时跟随平台默认行为。
  final bool? centerTitle;

  /// 背景色（默认 park.colors.surface）。
  final Color? backgroundColor;

  /// 前景色：标题文字 / 返回按钮 / actions 图标颜色（默认 park.colors.textPrimary）。
  final Color? foregroundColor;

  /// 阴影高度（默认 0，扁平品牌风格）。
  final double? elevation;

  /// 底部附加 Widget（如 TabBar），高度计入 [preferredSize]。
  final PreferredSizeWidget? bottom;

  /// 标题与 leading / actions 之间的间距（默认 16，对齐 NavigationToolbar）。
  final double? titleSpacing;

  /// 表面着色（Material 3 默认有紫色 tint，传 Colors.transparent 可抑制）。
  final Color? surfaceTintColor;

  /// 工具栏高度（默认 kToolbarHeight = 56）。
  final double? toolbarHeight;

  /// 灵活空间 Widget（用于背景图片等场景，显示在工具栏下方）。
  final Widget? flexibleSpace;

  /// 阴影颜色（默认 null，跟随主题）。
  final Color? shadowColor;

  /// 应用栏形状（如 RoundedRectangleBorder），传入后覆盖默认矩形并影响阴影。
  final ShapeBorder? shape;

  /// 图标主题（作用于 leading / actions 图标）。
  final IconThemeData? iconTheme;

  const ParkAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.titleSpacing,
    this.surfaceTintColor,
    this.toolbarHeight,
    this.flexibleSpace,
    this.shadowColor,
    this.shape,
    this.iconTheme,
  }) : assert(
          title == null || title is String || title is Widget,
          'ParkAppBar.title must be a String or a Widget',
        );

  @override
  Size get preferredSize => Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) +
            (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final double effectiveElevation = elevation ?? _kDefaultElevation;
    final ParkAppBarSurface surface = resolveParkAppBarSurface(
      context: context,
      park: park,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      elevation: effectiveElevation,
    );
    final bool canBlur = surface.useBlur &&
        surface.blurSigma > 0 &&
        ParkSurfaceBlurDepth.of(context) < 1;
    final Color fgColor = surface.titleColor;

    final _ParkBarLeading resolved = _parkBarResolveLeading(
      context,
      leading,
      automaticallyImplyLeading,
      fgColor,
    );

    return AppBar(
      leading: resolved.widget,
      automaticallyImplyLeading: resolved.imply,
      title: _parkBarTitle(
        title,
        park,
        fgColor,
        subtitle: subtitle,
        subtitleColor: surface.bodyColor,
      ),
      centerTitle: centerTitle,
      backgroundColor: canBlur ? Colors.transparent : surface.fill,
      foregroundColor: fgColor,
      elevation: effectiveElevation,
      scrolledUnderElevation: _kDefaultElevation,
      bottom: bottom,
      titleSpacing: titleSpacing ?? _kDefaultTitleSpacing,
      actions: actions,
      surfaceTintColor: surfaceTintColor,
      toolbarHeight: toolbarHeight,
      flexibleSpace: _parkBarFlexibleSpace(
        child: flexibleSpace,
        surface: surface,
        canBlur: canBlur,
      ),
      shadowColor: surface.shadowColor,
      shape: shape,
      iconTheme: iconTheme,
    );
  }
}

/// Park Sliver 应用栏 — 对齐 Flutter 原生 [SliverAppBar] 的参数面，
/// 用于 CustomScrollView，支持吸顶 / 浮动 / 拉伸 / 展开折叠，
/// 默认值全部走 ParkTheme 设计令牌（B273）。
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     ParkSliverAppBar(
///       title: '发现',
///       pinned: true,
///       expandedHeight: 240,
///     ),
///     SliverList(...),
///   ],
/// )
/// ```
class ParkSliverAppBar extends StatelessWidget {
  /// 标题：支持 String（走 Park 排版令牌）或自定义 Widget。
  final Object? title;

  /// 副标题：显示在标题下方，走 Park 排版令牌 bodySmall（14px，65% 透明度）。
  final String? subtitle;

  /// 自定义前置 Widget（替代默认返回按钮）。
  final Widget? leading;

  /// 是否在未提供 [leading] 时自动推断前置控件
  /// （可弹出路由显示 Park 返回按钮，有抽屉时显示抽屉按钮）。
  final bool automaticallyImplyLeading;

  /// 右侧操作按钮列表。
  final List<Widget>? actions;

  /// 标题是否居中；null 时跟随平台默认行为。
  final bool? centerTitle;

  /// 背景色（默认 park.colors.surface）。
  final Color? backgroundColor;

  /// 前景色：标题文字 / 返回按钮 / actions 图标颜色（默认 park.colors.textPrimary）。
  final Color? foregroundColor;

  /// 阴影高度（默认 0，扁平品牌风格）。
  final double? elevation;

  /// 底部附加 Widget（如 TabBar）。
  final PreferredSizeWidget? bottom;

  /// 标题与 leading / actions 之间的间距（默认 16，对齐 NavigationToolbar）。
  final double? titleSpacing;

  /// 折叠后是否吸顶。
  final bool pinned;

  /// 是否浮动（向下滚动时立即出现）。
  final bool floating;

  /// 是否支持过度拉伸效果。
  final bool stretch;

  /// 展开态总高度（默认 200）。
  final double expandedHeight;

  /// 表面着色（Material 3 默认有紫色 tint，传 Colors.transparent 可抑制）。
  final Color? surfaceTintColor;

  /// 工具栏高度（默认 kToolbarHeight = 56）。
  final double? toolbarHeight;

  /// 灵活空间 Widget（用于背景图片等场景，显示在工具栏下方）。
  final Widget? flexibleSpace;

  /// 阴影颜色（默认 null，跟随主题）。
  final Color? shadowColor;

  /// 应用栏形状（如 RoundedRectangleBorder），传入后覆盖默认矩形并影响阴影。
  final ShapeBorder? shape;

  /// 图标主题（作用于 leading / actions 图标）。
  final IconThemeData? iconTheme;

  const ParkSliverAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.titleSpacing,
    this.pinned = false,
    this.floating = false,
    this.stretch = false,
    this.expandedHeight = _kDefaultExpandedHeight,
    this.surfaceTintColor,
    this.toolbarHeight,
    this.flexibleSpace,
    this.shadowColor,
    this.shape,
    this.iconTheme,
  }) : assert(
          title == null || title is String || title is Widget,
          'ParkSliverAppBar.title must be a String or a Widget',
        );

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final double effectiveElevation = elevation ?? _kDefaultElevation;
    final ParkAppBarSurface surface = resolveParkAppBarSurface(
      context: context,
      park: park,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shadowColor: shadowColor,
      elevation: effectiveElevation,
    );
    final bool canBlur = surface.useBlur &&
        surface.blurSigma > 0 &&
        ParkSurfaceBlurDepth.of(context) < 1;
    final Color fgColor = surface.titleColor;

    final _ParkBarLeading resolved = _parkBarResolveLeading(
      context,
      leading,
      automaticallyImplyLeading,
      fgColor,
    );

    return SliverAppBar(
      leading: resolved.widget,
      automaticallyImplyLeading: resolved.imply,
      title: _parkBarTitle(
        title,
        park,
        fgColor,
        subtitle: subtitle,
        subtitleColor: surface.bodyColor,
      ),
      centerTitle: centerTitle,
      backgroundColor: canBlur ? Colors.transparent : surface.fill,
      foregroundColor: fgColor,
      elevation: effectiveElevation,
      scrolledUnderElevation: _kDefaultElevation,
      bottom: bottom,
      titleSpacing: titleSpacing ?? _kDefaultTitleSpacing,
      actions: actions,
      pinned: pinned,
      floating: floating,
      stretch: stretch,
      expandedHeight: expandedHeight,
      surfaceTintColor: surfaceTintColor,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      flexibleSpace: _parkBarFlexibleSpace(
        child: flexibleSpace,
        surface: surface,
        canBlur: canBlur,
      ),
      shadowColor: surface.shadowColor,
      shape: shape,
      iconTheme: iconTheme,
    );
  }
}
