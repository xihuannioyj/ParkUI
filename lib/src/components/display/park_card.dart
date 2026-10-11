import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../theme/park_surface_tokens.dart';
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

  /// 霓虹辉光色；null 时取 `park.colors.brand`。
  ///
  /// 仅 [ParkSurfaceStyle.neon] 下生效。其余风格忽略此参数。
  final Color? glowColor;

  /// 霓虹辉光强度（0-1）。
  ///
  /// 仅 [ParkSurfaceStyle.neon] 下生效。会**乘到**材质令牌给出的辉光
  /// 透明度上（而非替换），因此换预设时辉光"性格"仍由令牌决定。
  final double glowIntensity;

  /// 霓虹风格下是否用**渐变描边**替代实色描边。
  ///
  /// 渐变取自 `park.gradients.sweep`，随主题联动。
  ///
  /// 🔴 **仅在 [ParkSurfaceStyle.neon] 下生效**，其余风格一律忽略此参数
  /// （即保留实色描边）。这不是"软限制"，而是实打实的行为门控，见
  /// `_resolveSurface` 里的 `useGradientStroke`。
  ///
  /// ⚠️ 默认 **false**。曾默认为 true，但门控当时漏判 `surfaceStyle`，
  /// 导致**所有风格**（含默认 stripe）都被替换成渐变描边 → 实色细边框
  /// 消失、neo 凭空多出边框。详见 commit `bad1e39` 引入的回归。
  ///
  /// 想开启 neon 渐变描边需显式传 `true`；此时 [borderColor] 会失效
  /// （渐变描边与实色描边互斥，见 `_resolveSurface` 的说明）。
  final bool gradientBorder;

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
    this.glowColor,
    this.glowIntensity = 1.0,
    this.gradientBorder = false,
  }) : assert(
         glowIntensity >= 0.0 && glowIntensity <= 1.0,
         'glowIntensity 必须落在 0-1',
       );

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
      Gradient? gradientBorder,
      Color titleColor,
      Color bodyColor,
    })
    surface = _resolveSurface(park);

    // Determine effective border: borderColor overrides theme border when set.
    final Border? effectiveBorder = widget.borderColor != null && surface.border != null
        ? Border.all(color: widget.borderColor!, width: 1)
        : surface.border;

    // 🔴 文字色必须与表面令牌同源，不能硬编码 colors.textPrimary/Secondary。
    //
    // neon + 深色板下 [surface.fill] 会翻转为近白（colors.textPrimary），
    // 若文字仍取 colors.textPrimary 就是"白底白字"（实测 1.00:1），
    // 副标题取 colors.textSecondary 也只有 2.00:1 —— 与批次 1
    // ParkSurfaceTokens 那次 P0 同源。
    //
    // 因此：卡片**真的绘制了背景**时取 tokens 的 titleColor / bodyColor；
    // ghost 变体下 fill 恒为 Colors.transparent（不绘制表面），文字直接落在
    // 页面底色上，而页面底色不随风格翻转 —— 此时必须保留 colors.*。
    // 判据是"是否真的画了背景"，而非"风格是否为 neon"，与
    // ParkPageTitle 的 paintsBackground 同一思路。
    final bool paintsBackground = surface.color != null && surface.color!.a != 0;
    final Color titleColor = paintsBackground ? surface.titleColor : colors.textPrimary;
    final Color bodyColor = paintsBackground ? surface.bodyColor : colors.textSecondary;

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
                                                          color: titleColor,
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
                                          color: bodyColor,
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
                  // 模糊半径走 ParkBlur 令牌（park.blur.lg），不硬编码。
                  filter: ImageFilter.blur(
                    sigmaX: park.blur.lg,
                    sigmaY: park.blur.lg,
                  ),
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
          : _buildDecoratedCard(
              park: park,
              cardRadius: cardRadius,
              surface: surface,
              effectiveBorder: effectiveBorder,
              cardContent: cardContent,
            ),
          ),
    );
  }

  /// 非玻璃分支的卡片外壳。
  ///
  /// 🔴 **stripe 零回归约束**：当 [surface.gradientBorder] 为 null
  /// （即非 neon 风格）时，走的分支与迁移前 `AnimatedContainer` +
  /// `BoxDecoration(color/borderRadius/border/boxShadow)` **逐字段一致**，
  /// 因此 `test/golden/goldens/park_card_*.png` 零 diff。
  ///
  /// neon + gradientBorder 时额外套一层"渐变描边壳"：外层画渐变、
  /// 内层填充表面色，形成真正的**渐变描边**（Flutter 的
  /// `BoxDecoration.gradient` 只能铺满、不能只画描边，故必须分层）。
  Widget _buildDecoratedCard({
    required ParkThemeData park,
    required BorderRadius cardRadius,
    required ({
      Color? color,
      Border? border,
      List<BoxShadow>? shadows,
      bool useGlass,
      Gradient? gradientBorder,
      Color titleColor,
      Color bodyColor,
    })
    surface,
    required Border? effectiveBorder,
    required Widget cardContent,
  }) {
    final AnimatedContainer base = AnimatedContainer(
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
    );

    final Gradient? strokeGradient = surface.gradientBorder;
    if (strokeGradient == null) return base;

    // 渐变描边：外层渐变 + 内层实色，中间露出的宽度即描边。
    // 描边宽度取自主题命名约定（1.5dp），与 neon 风格"发光边"的观感匹配。
    const double neonStrokeWidth = 1.5;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        gradient: strokeGradient,
        boxShadow: surface.shadows,
      ),
      child: Padding(
        padding: const EdgeInsets.all(neonStrokeWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.color,
            borderRadius: BorderRadius.all(
              Radius.circular(
                // 🔴 必须夹到 >= 0：调用方可能传入小于描边宽度的圆角
                // （如 radius.xs=4 与 1.5 同量级时内缩后仍为正，但自定义
                // borderRadius 可能给 0），负半径会让 Radius.circular 抛断言。
                math.max(0.0, _radiusOf(cardRadius) - neonStrokeWidth),
              ),
            ),
          ),
          child: base,
        ),
      ),
    );
  }

  /// 从 [BorderRadius] 提取标量圆角（各角相同）。
  ///
  /// 非均匀圆角不参与渐变描边内缩，退化为 0 —— 此时内层无内缩，
  /// 描边宽度完全由外层 padding 决定，观感仍然正确。
  static double _radiusOf(BorderRadius radius) {
    if (radius.topLeft == radius.topRight &&
        radius.topRight == radius.bottomRight &&
        radius.bottomRight == radius.bottomLeft) {
      return radius.topLeft.x;
    }
    return 0.0;
  }

  /// 根据当前 [ParkThemeData.surfaceStyle] 解析卡片的表面材质。
  ///
  /// 材质规则（颜色 / 边框 / 阴影 / 是否玻璃）全部来自
  /// [ParkSurfaceTokens.resolve] —— 这是全项目唯一的"风格 → 表面"翻译点。
  /// 本方法只负责把卡片自身的状态（variant / bordered / hover / elevation /
  /// color）翻译成派生层的意图参数，因此新增风格时本方法无需改动。
  ///
  /// 🔴 **stripe 零回归约束**：非 neon 风格走一条与迁移前完全一致的路径，
  /// `gradientBorder` 恒为 null、`shadows` 原样透传材质令牌的值。
  /// `test/golden/goldens/park_card_*.png` 是这条约束的守门员 ——
  /// 任何让 stripe 产生 diff 的改动都是回归，不是改进。
  ({
    Color? color,
    Border? border,
    List<BoxShadow>? shadows,
    bool useGlass,
    Gradient? gradientBorder,
    Color titleColor,
    Color bodyColor,
  })
  _resolveSurface(ParkThemeData park) {
    final ParkSurfaceTokens surface = ParkSurfaceTokens.resolve(
      style: park.surfaceStyle,
      colors: park.colors,
      radius: park.radius,
      blur: park.blur,
      bordered: widget.bordered,
      hovered: _isHovered && widget.hoverable,
      borderTone: _borderTone,
      transparent: widget.variant == ParkCardVariant.ghost,
      elevation: widget.elevation ?? 0,
    );

    // 🔴 非 neon 风格原样返回，不做任何额外处理 —— 这是 stripe 零 diff 的关键。
    if (surface.style != ParkSurfaceStyle.neon) {
      return (
        color: widget.color ?? surface.fill,
        border: surface.border,
        shadows: surface.shadows,
        useGlass: surface.useBackdropFilter,
        gradientBorder: null,
        titleColor: surface.titleColor,
        bodyColor: surface.bodyColor,
      );
    }

    // ---- 以下仅 neon 风格生效 ----

    // 渐变描边门控：既看调用方意愿，也看当前风格。
    //
    // ⚠️ 两者缺一不可。只判 [gradientBorder] 会让所有风格被替换描边
    // （曾发生的 P0）；只判风格则让参数在非 neon 下完全无效、失去意义。
    final bool useGradientStroke =
        widget.gradientBorder && surface.style == ParkSurfaceStyle.neon;

    // 辉光：材质令牌给出的品牌辉光，强度与色相都可由调用方覆盖。
    // 颜色可被 glowColor 覆盖，默认取品牌色（令牌派生，非硬编码）。
    //
    // 🔴 强度以令牌 alpha 为**基准缩放**（而非替换）：这样换预设时
    // 辉光的"性格"（透明度/模糊半径的相对关系）仍由材质层决定。
    final Color glow = widget.glowColor ?? park.colors.brand;
    final double gi = widget.glowIntensity.clamp(0.0, 1.0);
    final List<BoxShadow>? glowShadows = surface.shadows == null
        ? null
        : <BoxShadow>[
            for (final BoxShadow s in surface.shadows!)
              BoxShadow(
                // glowColor 已覆盖时用其 alpha，否则按令牌 alpha 缩放。
                color: widget.glowColor == null
                    ? s.color.withValues(alpha: s.color.a * gi)
                    : glow.withValues(alpha: s.color.a * gi),
                blurRadius: s.blurRadius * gi,
                spreadRadius: s.spreadRadius * gi,
                offset: s.offset,
              ),
          ];

    return (
      color: widget.color ?? surface.fill,
      // 🔴 渐变描边只在 neon 下替换实色描边。
      //
      // 门控必须同时判断 [gradientBorder] 与 `surface.style` ——
      // 只判断前者会让**所有风格**（含默认 stripe）都被换成渐变描边，
      // 导致实色细边框消失、neo 凭空多出边框。详见字段文档的 P0 说明。
      //
      // 开启时 border 返回 null，由调用方用渐变描边代替实色描边；
      // 此时 [ParkCard.borderColor] 也一并失效（互斥，见 build 的说明）。
      border: useGradientStroke ? null : surface.border,
      shadows: glowShadows,
      useGlass: surface.useBackdropFilter,
      // 渐变描边用 sweep 令牌（随主题联动），禁止硬编码色值。
      gradientBorder: useGradientStroke ? park.gradients.sweep.asFlutter : null,
      // neon 下标题/正文必须取 surface 的成对色（fill 翻转过，colors.* 不跟随）。
      titleColor: surface.titleColor,
      bodyColor: surface.bodyColor,
    );
  }

  /// 把 [ParkCardVariant] 映射为边框调性。
  ///
  /// 具体用什么颜色 / 宽度由 [ParkSurfaceTokens.resolve] 按风格决定，
  /// 因此这里只表达"要哪种边框"，不携带任何颜色。
  ParkSurfaceBorderTone get _borderTone => switch (widget.variant) {
    ParkCardVariant.outlined || ParkCardVariant.ghost =>
      ParkSurfaceBorderTone.outline,
    ParkCardVariant.inner => ParkSurfaceBorderTone.inner,
    ParkCardVariant.preview => ParkSurfaceBorderTone.none,
  };

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
