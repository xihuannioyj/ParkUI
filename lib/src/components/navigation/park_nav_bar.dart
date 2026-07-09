import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

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

  /// 右侧操作按钮列表（[rightActions] 的别名，优先使用）
  final List<Widget>? actions;

  /// 导航栏底部附加内容（如搜索栏、二级标签等）
  final PreferredSizeWidget? bottom;

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
    this.actions,
    this.bottom,
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
  Size get preferredSize =>
      Size.fromHeight(height + (safeAreaTop ? _defaultTopSafeInset : 0));

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
    final colors = park.colors;
    final double topInset = safeAreaTop ? MediaQuery.paddingOf(context).top : 0;

    final bgColor = transparent
        ? Colors.transparent
        : (backgroundColor ?? colors.surface);
    final fgColor = titleColor ?? colors.textPrimary;
    final actionColor = colors.textPrimary;

    // 解析边框：transparent 模式始终无边框无阴影
    final showBorder = !transparent && bordered;
    final showElevation = !transparent && elevation > 0;

    return Container(
      height: height + topInset,
      decoration: BoxDecoration(
        color: bgColor,
        border: showBorder
            ? Border(bottom: BorderSide(color: colors.divider, width: 0.5))
            : null,
        boxShadow: showElevation
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
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
                              color: colors.textSecondary,
                              fontSize: park.typography.sizeOverline,
                              fontWeight: park.typography.weightRegular,
                            ),
                          ),
                        ],
                      )
                    : _buildTitle(fgColor, park),
                trailing: rightActions != null && rightActions!.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: rightActions!,
                      )
                    : null,
                middleSpacing: park.spacing.sm,
                centerMiddle: centerTitle,
              ),
            ),
          ],
        ),
      ),
    );
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
      label: '返回',
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

    // 如果 title 已经是 _ParkNavBarTitle 则直接返回（它自己处理样式）
    if (title is _ParkNavBarTitle) return title!;

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

  const _ParkNavBarTitle({required this.text, this.titleColor});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final fgColor = titleColor ?? park.colors.textPrimary;

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
