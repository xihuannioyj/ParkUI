import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../base/park_surface.dart';

/// Park 顶部导航栏
///
/// 提供居中标题、返回箭头、右侧操作按钮等常见 App Bar 功能，
/// 支持透明背景模式（用于覆盖在内容之上）。
///
/// ```dart
/// ParkNavBar(
///   title: '首页',
///   leftArrow: true,
///   onBack: () => Navigator.pop(context),
///   rightActions: [
///     IconButton(icon: Icon(Icons.search), onPressed: () {}),
///   ],
/// )
/// ```
/// 顶部导航栏表面材质的派生结果。
@immutable
class ParkNavBarSurface {
  /// 导航栏填充色；透明模式下为 [Colors.transparent]。
  final Color fill;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 底部分割线颜色；null 表示不画分割线。
  final Color? dividerColor;

  /// 标题 / 返回箭头 / 右侧操作图标的前景色。
  final Color titleColor;

  /// 副标题色。
  final Color bodyColor;

  /// 是否需要背景模糊采样（glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  const ParkNavBarSurface({
    required this.fill,
    required this.shadows,
    required this.dividerColor,
    required this.titleColor,
    required this.bodyColor,
    required this.useBlur,
    required this.blurSigma,
  });
}

/// 导航栏改造前的 elevation 阴影（浮层兜底 floor）。
///
/// 组件原本按 `elevation` 现算一条阴影（overlay 8% / blur=elevation /
/// offset=(0, elevation/2)），并非 `park.shadows.*`。
List<BoxShadow> _navBarElevationShadow(ParkThemeData park, double elevation) {
  return <BoxShadow>[
    BoxShadow(
      color: park.colors.overlay.withValues(alpha: 0.08),
      blurRadius: elevation,
      offset: Offset(0, elevation / 2),
    ),
  ];
}

/// 导航栏底部分割线颜色。
///
/// 原实现固定用 `colors.divider`（亮色板 navy 7.8% / 暗色板 白 10%）。
/// 这在 **neon + 深色** 底下会失效：此时表面 fill 翻转为
/// `colors.textPrimary`（暗色板下是纯白），而暗色板的 divider 是"白 10%"
/// —— 白线压在白底上完全不可见。
///
/// 因此策略是：**原色仍可分辨时沿用原色**（stripe / flat 观感零回归），
/// 仅在原色与 fill 不可分辨时回落到表面文字色的低透明度版本。
///
/// ⚠️ `ParkColors.contrastRatio` 只读 r/g/b、**忽略 alpha**，所以这里必须
/// 先把半透明的 fill / divider 各自 alpha 合成到不透明底再比，否则算出来
/// 的是"未合成"的纯色，结论无效。
Color _navBarDividerColor({
  required ParkThemeData park,
  required Color fill,
  required Color fallback,
}) {
  final Color opaqueFill = Color.alphaBlend(fill, park.colors.background);
  final Color composited = Color.alphaBlend(park.colors.divider, opaqueFill);
  if (ParkColors.contrastRatio(composited, opaqueFill) > 1.02) {
    return park.colors.divider;
  }
  return fallback.withValues(alpha: 0.35);
}

/// 解析顶部导航栏的表面材质（浮层规范在 NavBar 上的实现）。
///
/// 五条浮层规范：
/// 1. **阴影**：`tokens.shadows ?? 组件原值`（[_navBarElevationShadow]）——
///    但导航栏**不是**"恒定抬起"的浮层，它有显式的 `elevation` 旋钮，
///    `elevation == 0` 就是"不要阴影"。此时即便 glass / neo / neon 也不
///    凭空加阴影，否则全站导航栏会突然全部投影（非零回归）。
/// 2. **圆角**：导航栏无圆角（贴边满宽），本组件不涉及圆角。
/// 3. **边框**：尊重组件原有的 `bordered` 语义 —— 底边 0.5px 分割线。
///    它是"分割线"而非"表面 outline"，**不**消费 `tokens.border`
///    （后者是 `Border.all` 四边 1px，会改变观感）；颜色由
///    [_navBarDividerColor] 做表面适配。
/// 4. **文字色**：`tokens.titleColor` / `tokens.bodyColor`。
///    透明栏走独立分支，用 `colors.textPrimary` / `textSecondary`。
/// 5. **特殊形态**：[transparent] 是**独立分支**（同时短路填充 / 阴影 /
///    分割线 / 模糊四个属性），整条 return，避免"透明但带阴影"的撕裂态。
@visibleForTesting
ParkNavBarSurface resolveParkNavBarSurface({
  required ParkThemeData park,
  required BuildContext context,
  bool transparent = false,
  bool bordered = true,
  double elevation = 0.0,
}) {
  // 导航栏没有"表面 outline"语义（只有底部分割线），故 bordered: false，
  // 分割线由 _navBarDividerColor 单独处理。
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  if (transparent) {
    return ParkNavBarSurface(
      fill: Colors.transparent,
      shadows: null,
      dividerColor: null,
      // 🔴 透明栏背后是**页面内容**（colors.background），不再有表面，
      // 因此可读基准是页面背景而非 fill。neon + 深色下 tokens.titleColor
      // 是 colors.surface（深 navy），压在深色页面上会完全消失。
      // colors.textPrimary / textSecondary 按定义即"在 background 上可读"。
      titleColor: park.colors.textPrimary,
      bodyColor: park.colors.textSecondary,
      useBlur: false,
      blurSigma: 0.0,
    );
  }

  return ParkNavBarSurface(
    fill: tokens.fill,
    shadows: elevation > 0
        ? ParkSurfaceTokens.overlayShadows(
            tokens: tokens,
            floor: _navBarElevationShadow(park, elevation),
          )
        : null,
    dividerColor: bordered
        ? _navBarDividerColor(
            park: park,
            fill: tokens.fill,
            fallback: tokens.titleColor,
          )
        : null,
    titleColor: tokens.titleColor,
    bodyColor: tokens.bodyColor,
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
  );
}

class ParkNavBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题（字符串或自定义 Widget）
  final Widget? title;

  /// 是否显示左侧返回箭头
  final bool leftArrow;

  /// 返回按钮点击回调
  final VoidCallback? onBack;

  /// 右侧操作按钮列表
  final List<Widget>? rightActions;

  /// 是否透明背景（无底色、无边框、无阴影）
  final bool transparent;

  /// 导航栏高度（默认 56）
  final double height;

  /// 背景色（覆盖主题默认值）
  final Color? backgroundColor;

  /// 标题文字颜色
  final Color? titleColor;

  /// 是否为顶部状态栏预留安全区域
  final bool safeAreaTop;

  /// 是否显示底部边框
  final bool bordered;

  /// 阴影高度（0 = 无阴影）
  final double elevation;

  /// 标题是否始终居中（不受 leading / trailing 宽度影响）
  final bool centerTitle;

  /// 自定义标题 Widget（优先级高于 [title]）
  final Widget? titleWidget;

  /// 自定义前置 Widget（替代默认返回箭头）
  final Widget? leading;

  /// 副标题（显示在主标题下方）
  final String? subTitle;

  /// 返回确认回调（返回 false 取消返回操作）。
  ///
  /// 与 [onBack] 的区别：[onBackConfirm] 为异步确认，
  /// 返回 true 继续执行返回操作，返回 false 取消。
  final Future<bool> Function()? onBackConfirm;

  /// 导航栏底部附加内容（如搜索栏、二级标签等）
  final PreferredSizeWidget? bottom;

  /// [bottom] 的固定高度（用于 [preferredSize] 精确预留，避免底部内容挤压工具栏溢出）。
  final double? bottomHeight;

  const ParkNavBar({
    super.key,
    this.title,
    this.leftArrow = false,
    this.onBack,
    this.rightActions,
    this.transparent = false,
    this.height = 56.0,
    this.backgroundColor,
    this.titleColor,
    this.safeAreaTop = true,
    this.bordered = true,
    this.elevation = 0,
    this.centerTitle = false,
    this.titleWidget,
    this.leading,
    this.subTitle,
    this.onBackConfirm,
    this.bottom,
    this.bottomHeight,
  });

  /// 以字符串快捷构造标题
  factory ParkNavBar.text({
    Key? key,
    required String title,
    bool leftArrow = false,
    VoidCallback? onBack,
    List<Widget>? rightActions,
    bool transparent = false,
    double height = 56.0,
    Color? backgroundColor,
    Color? titleColor,
    bool safeAreaTop = true,
    bool bordered = true,
    double elevation = 0,
    bool centerTitle = false,
    Widget? titleWidget,
    Widget? leading,
    String? subTitle,
    Future<bool> Function()? onBackConfirm,
  }) {
    return ParkNavBar(
      key: key,
      title: _ParkNavBarTitle(text: title, titleColor: titleColor),
      leftArrow: leftArrow,
      onBack: onBack,
      rightActions: rightActions,
      transparent: transparent,
      height: height,
      backgroundColor: backgroundColor,
      titleColor: titleColor,
      safeAreaTop: safeAreaTop,
      bordered: bordered,
      elevation: elevation,
      centerTitle: centerTitle,
      titleWidget: titleWidget,
      leading: leading,
      subTitle: subTitle,
      onBackConfirm: onBackConfirm,
    );
  }

  @override
  Size get preferredSize {
    // 与 build 保持一致：总高计入 topInset 与 bottom 高度，
    // 否则 Scaffold 预留高度与实际渲染高度错位、bottom 挤压工具栏溢出。
    final double bottomH = bottomHeight ?? bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(
        height + (safeAreaTop ? _defaultTopSafeInset : 0) + bottomH);
  }

  static double get _defaultTopSafeInset {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return 0;

    final view = views.first;
    return view.viewPadding.top / view.devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final double topInset = safeAreaTop ? MediaQuery.paddingOf(context).top : 0;

    // 表面材质走派生层：局部 ParkSurfaceStyleScope 覆盖自动生效。
    final ParkNavBarSurface surface = resolveParkNavBarSurface(
      park: park,
      context: context,
      transparent: transparent,
      bordered: bordered,
      elevation: elevation,
    );

    // backgroundColor / titleColor 是用户逃生舱，优先级高于派生结果。
    final Color bgColor = backgroundColor ?? surface.fill;
    final Color fgColor = titleColor ?? surface.titleColor;
    // 返回箭头 / 右侧操作图标跟随表面前景色（与改造前一致，不随 titleColor
    // 覆盖而变），但必须来自表面令牌以保证在任何风格下都可辨。
    final Color actionColor = surface.titleColor;

    Widget bar = Container(
      // 总高计入 bottom 高度，避免 bottom 挤压工具栏导致 RenderFlex 溢出。
      height: height + topInset + (bottomHeight ?? bottom?.preferredSize.height ?? 0),
      decoration: BoxDecoration(
        color: bgColor,
        // 分割线：保留组件原有几何（仅底边 0.5px），颜色做表面适配。
        border: surface.dividerColor != null
            ? Border(
                bottom: BorderSide(color: surface.dividerColor!, width: 0.5),
              )
            : null,
        boxShadow: surface.shadows,
      ),
      child: SizedBox.expand(
        child: Column(
          children: [
            if (topInset > 0) SizedBox(height: topInset),
            Expanded(
              child: NavigationToolbar(
                leading: leading != null
                    ? leading!
                    : (leftArrow
                        ? _buildBackButton(context, park, actionColor)
                        : null),
                middle: subTitle != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTitle(fgColor, park),
                          SizedBox(height: park.spacing.xxs),
                          Text(
                            subTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              // 副标题走 surface.bodyColor（与改造前的
                              // colors.textSecondary 同源，但会随风格翻转）。
                              color: surface.bodyColor,
                              fontSize: park.typography.sizeOverline,
                              fontWeight: park.typography.weightRegular,
                            ),
                          ),
                        ],
                      )
                    : _buildTitle(fgColor, park),
                trailing: (rightActions != null && rightActions!.isNotEmpty)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: rightActions!,
                      )
                    : null,
                middleSpacing: park.spacing.sm,
                centerMiddle: centerTitle,
              ),
            ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );

    // glass 风格：叠加 BackdropFilter 采样背后的页面内容。
    // 导航栏没有圆角，无需 ClipRRect；嵌套降级统一由 ParkSurfaceBlurDepth
    // 判定（必须是 `< 1` 而非 `<= 1`）。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      bar = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: surface.blurSigma,
          sigmaY: surface.blurSigma,
        ),
        child: bar,
      );
    }
    return bar;
  }

  void _handleBack(BuildContext context) async {
    // 异步确认回调：返回 false 取消返回
    if (onBackConfirm != null) {
      final shouldProceed = await onBackConfirm!();
      if (!shouldProceed || !context.mounted) return;
    }

    if (onBack != null) {
      onBack!.call();
      return;
    }

    final NavigatorState? navigator = Navigator.maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.maybePop();
    }
  }

  Widget _buildBackButton(
    BuildContext context,
    ParkThemeData park,
    Color color,
  ) {
    return Semantics(
      button: true,
      label: ParkLocalizations.of(context).backLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleBack(context),
        child: SizedBox(
          width: 44,
          height: height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: park.spacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(Color fgColor, ParkThemeData park) {
    // titleWidget 优先级最高
    if (titleWidget != null) {
      return DefaultTextStyle(
        style: TextStyle(
          color: fgColor,
          fontSize: park.typography.sizeH3,
          fontWeight: park.typography.weightMedium,
        ),
        child: titleWidget!,
      );
    }

    if (title == null) return const SizedBox.shrink();

    // 如果 title 已经是 _ParkNavBarTitle 则重建一个（它自己处理样式）。
    //
    // 不能原样返回：_ParkNavBarTitle 需要知道当前是否处于透明栏 ——
    // 透明栏的可读基准是页面背景而非表面，漏传会让它按"有表面"取
    // tokens.titleColor（neon + 深色下是深 navy，压在深色页面上会消失）。
    if (title is _ParkNavBarTitle) {
      final _ParkNavBarTitle asTitle = title! as _ParkNavBarTitle;
      return _ParkNavBarTitle(
        text: asTitle.text,
        titleColor: asTitle.titleColor,
        transparent: transparent,
      );
    }

    // 外部传入的自定义 Widget
    return DefaultTextStyle(
      style: TextStyle(
        color: fgColor,
        fontSize: park.typography.sizeH3,
        fontWeight: park.typography.weightMedium,
      ),
      child: title!,
    );
  }
}

/// 内部用：文字标题
class _ParkNavBarTitle extends StatelessWidget {
  final String text;
  final Color? titleColor;

  /// 是否处于透明导航栏中。
  ///
  /// 透明栏背后是**页面内容**而非表面，文字色的可读基准不同
  /// （见 [resolveParkNavBarSurface] 的 transparent 分支），因此必须透传。
  final bool transparent;

  const _ParkNavBarTitle({
    required this.text,
    this.titleColor,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    // 与 ParkNavBar 走同一个解析器，保证"标题色 vs 表面"的成对取值不分裂。
    final ParkNavBarSurface surface = resolveParkNavBarSurface(
      park: park,
      context: context,
      transparent: transparent,
    );
    final Color fgColor = titleColor ?? surface.titleColor;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: fgColor,
        fontSize: park.typography.sizeH3,
        fontWeight: park.typography.weightMedium,
      ),
    );
  }
}
