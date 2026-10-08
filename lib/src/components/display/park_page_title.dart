import 'package:flutter/material.dart';

import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import 'park_gradient_text.dart';

/// 页面标题层级。
enum ParkPageTitleLevel {
  /// 页面大标题：字号取 `park.typography.sizePageTitle`（默认 30）。
  ///
  /// 用于页面顶部唯一的主标题。
  page,

  /// 区块标题：字号取 `park.typography.sizeSectionTitle`（默认 20）。
  ///
  /// 用于页面内的卡片区块 / 分组标题。
  section,
}

/// 页面大标题 —— 主标题 + 副标题 + 右侧操作区。
///
/// ## 定位
///
/// 提供页面级标题的**标准骨架**：标题 / 副标题 / action 三件套的间距、
/// 字号、颜色全部取自令牌，因此换主题 / 换预设时整站标题自动一致。
///
/// 字号来自新增的语义层（`pageTitle` / `sectionTitle`），而非复用
/// `display`（34）或 `h1`（28）—— 那两个是"海报级 / 一级标题"语义，
/// 直接拿来当页面标题会与既有层级冲突。
///
/// ## 性能
///
/// [gradientTitle] 会在标题上用 [ShaderMask]（一次离屏渲染）。
/// 🔴 **吸顶（sticky）场景建议关闭**：吸顶时标题随滚动持续重绘，
/// 叠加离屏渲染在低端机上会掉帧。
///
/// ## 示例
///
/// ```dart
/// ParkPageTitle(
///   title: '订单管理',
///   subtitle: '共 128 条',
///   action: ParkButton(child: Text('新建'), onPressed: _onCreate),
///   showDivider: true,
/// )
/// ```
class ParkPageTitle extends StatelessWidget {
  /// 主标题（必填）。
  final String title;

  /// 副标题；null 时不渲染。
  final String? subtitle;

  /// 右侧操作区；null 时不渲染。
  final Widget? action;

  /// 标题层级（page / section）。
  final ParkPageTitleLevel level;

  /// 主标题是否使用渐变（内部复用 [ParkGradientText]）。
  ///
  /// 🔴 吸顶场景建议关闭，理由见类文档"性能"。
  final bool gradientTitle;

  /// 是否在底部显示细分隔线。
  final bool showDivider;

  /// 内边距；null 时取 `park.spacing.page`。
  final EdgeInsetsGeometry? padding;

  /// 是否吸顶。
  ///
  /// 本组件**不**自行包 [SliverPersistentHeader]（那需要外层有
  /// [CustomScrollView] 上下文），仅通过 [preferredSize] 暴露高度，
  /// 便于外层交给 `SliverPersistentHeader` / `AppBar` 使用。
  final bool sticky;

  /// 标题下方的材质背景。
  ///
  /// null / [ParkPageTitleBackground.transparent] 表示不绘制背景；
  /// 其余值交由 [ParkSurfaceTokens.resolve] 派生，因此**自动跟随风格**。
  final ParkPageTitleBackground background;

  /// 创建页面大标题。
  const ParkPageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.level = ParkPageTitleLevel.page,
    this.gradientTitle = false,
    this.showDivider = false,
    this.padding,
    this.sticky = false,
    this.background = ParkPageTitleBackground.transparent,
  });

  /// 吸顶场景下的建议高度（供外层 `SliverPersistentHeader` 使用）。
  ///
  /// 由字号令牌推导而非硬编码：换主题字号时高度自动跟随。
  double preferredSize(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final double titleSize = level == ParkPageTitleLevel.page
        ? park.typography.sizePageTitle
        : park.typography.sizeSectionTitle;
    // 标题行高（token 化）+ 上下内边距 + 副标题行 + 分隔线。
    final double titleLine = titleSize * park.typography.lineHeightTitle;
    final double subtitleLine = subtitle == null
        ? 0.0
        : park.typography.sizeBody * park.typography.lineHeightBody +
              park.spacing.xs;
    return titleLine +
        subtitleLine +
        park.spacing.base * 2 +
        (showDivider ? park.spacing.base : 0.0);
  }

  /// 按层级取标题字号（**禁止硬编码**）。
  double _titleFontSize(ParkThemeData park) =>
      level == ParkPageTitleLevel.page
      ? park.typography.sizePageTitle
      : park.typography.sizeSectionTitle;

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 🔴 **背景与前景必须同源派生。**
    //
    // 当 [background] 绘制了表面时，标题/副标题色**必须**取自同一份表面
    // 令牌的 `titleColor` / `bodyColor`，不能沿用 `colors.textPrimary`：
    // neon + 深色板下 `ParkSurfaceTokens.fill` 会翻转成近白
    // （colors.textPrimary），若前景仍是 colors.textPrimary（也是白）
    // 就是"白底白字"—— 实测对比度 1.00:1，标题彻底不可见。
    //
    // 反之，透明背景（默认）下文字直接落在页面底色上，页面底色恒为
    // `colors.background`、不随风格翻转，此时必须保留 colors.* ——
    // 若此时改用 tokens.titleColor，neon + 深色板下反而会变成
    // 深色字落在近白卡片上（虽然本组件没画卡片，但子组件可能画了）。
    //
    // 因此这里的判定条件是"**本组件是否真的画了背景**"，
    // 而不是"当前风格是什么"。
    final bool paintsBackground =
        background != ParkPageTitleBackground.transparent;
    final ParkSurfaceTokens surface = paintsBackground
        ? ParkSurfaceTokens.resolve(
            style: ParkSurfaceStyleScope.of(context),
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
            // 标题栏通常贴着页面顶部，用内嵌边框调性避免与内容卡片撞成双线。
            borderTone: ParkSurfaceBorderTone.inner,
          )
        : ParkSurfaceTokens.resolve(
            style: ParkSurfaceStyle.stripe,
            colors: park.colors,
            radius: park.radius,
            blur: park.blur,
          );

    final double fontSize = _titleFontSize(park);
    final TextStyle titleStyle = TextStyle(
      fontSize: fontSize,
      // 层级越高字重越重，形成明确的标题梯度。
      fontWeight: level == ParkPageTitleLevel.page
          ? park.typography.weightBold
          : park.typography.weightMedium,
      height: park.typography.lineHeightTitle,
      fontFamily: park.typography.fontFamily,
      color: paintsBackground ? surface.titleColor : park.colors.textPrimary,
    );

    // 副标题色：⚠️ 不能直接用 `surface.bodyColor`。
    //
    // `bodyColor` 在所有风格下都恒等于 `colors.textSecondary`
    // （见 ParkSurfaceTokens.resolve:189），**不随 fill 翻转**。
    // 于是 neon + 深色板下：fill 翻成近白，而 bodyColor 仍是浅灰
    // —— 实测仅 2.00:1，副标题同样不可读。
    //
    // 因此这里从两个令牌候选里**实测取优**，而不是照搬 bodyColor：
    // 令牌是候选集，对比度才是判据。
    final Color subtitleColor = paintsBackground
        ? (ParkColors.contrastRatio(surface.bodyColor, surface.fill) >= 4.5
            ? surface.bodyColor
            : surface.titleColor)
        : park.colors.textSecondary;

    final Widget titleWidget = gradientTitle
        ? ParkGradientText(
            text: title,
            style: titleStyle,
            textAlign: TextAlign.start,
          )
        : Text(title, style: titleStyle, textAlign: TextAlign.start);

    final Widget titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        titleWidget,
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.only(top: park.spacing.xxs),
            child: Text(
              subtitle!,
              style: park.typography.body.copyWith(
                color: subtitleColor,
                fontSize: park.typography.sizeBody,
              ),
              textAlign: TextAlign.start,
            ),
          ),
      ],
    );

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: titleColumn),
            if (action != null) ...<Widget>[
              SizedBox(width: park.spacing.base),
              // 垂直居中偏上：标题通常比按钮高，略微下移观感更稳。
              Align(alignment: Alignment.centerRight, child: action),
            ],
          ],
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(top: park.spacing.base),
            child: Divider(
              color: park.colors.divider,
              thickness: 1,
              height: 1,
            ),
          ),
      ],
    );

    content = Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: park.spacing.base),
      child: content,
    );

    // 背景材质：复用上面已解析的 surface，保证背景与前景同源。
    // （paintsBackground 为 true 时 surface 就是按当前风格派生的那份）
    if (paintsBackground) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: surface.fill,
          border: surface.border,
          boxShadow: surface.shadowsOrEmpty,
        ),
        child: content,
      );
    }

    return Semantics(
      header: true,
      label: subtitle == null ? title : '$title, $subtitle',
      // 标题文字本身会被读屏朗读；这里只补"这是一个标题"的角色语义，
      // 故不排除内层语义（与 ParkGradientText 的处理不同）。
      child: content,
    );
  }
}

/// 页面标题的背景材质档位。
enum ParkPageTitleBackground {
  /// 透明（默认）：不绘制背景，与页面底色融为一体。
  transparent,

  /// 填充：使用当前风格派生的表面填充色（stripe/flat/glass/neo/neon）。
  ///
  /// 具体颜色 / 边框 / 阴影全部由 [ParkSurfaceTokens.resolve] 决定，
  /// 因此**自动跟随风格** —— glass 预设下即得到半透明玻璃标题栏。
  fill,
}
