import 'package:flutter/material.dart';
import 'park_theme_data.dart';
import 'tokens/park_blur.dart';
import 'tokens/park_colors.dart';
import 'tokens/park_radius.dart';

/// 表面边框调性。
///
/// 组件只声明"我要哪种边框"（如 `ParkCard` 把自己的 `variant` 映射到
/// [outline] / [inner] / [none]），**具体用什么颜色、什么宽度**由
/// [ParkSurfaceTokens.resolve] 按风格决定 —— 这样边框材质规则也只有一处。
enum ParkSurfaceBorderTone {
  /// 主边框（默认）：细边框，颜色随风格变化，hover 时高亮为品牌色。
  outline,

  /// 内嵌边框：弱化填充色边框（如内嵌面板）。
  inner,

  /// 无边框。
  none,
}

/// Park UI 表面令牌（Surface Tokens）。
///
/// ## 为什么需要它
///
/// [ParkSurfaceStyle] 只有 5 个值，无法直接回答组件作者真正关心的问题：
/// "我这个容器的**填充色**是什么？要不要**边框**？**阴影**用什么？
/// **圆角**多少？**标题 / 正文**用什么色？"
///
/// 如果让每个组件自己写 `switch (surfaceStyle)`，那么 211 个组件 × 5 个分支
/// = 1050 段重复翻译逻辑，且新增第 6 种风格要改 1050 处。
///
/// [ParkSurfaceTokens] 就是把"翻译"这一步抽出来的**唯一映射表**：
/// 组件只声明意图（[bordered] / [hovered] / [borderTone] / [transparent]），
/// 永远不直接判断风格。
///
/// ## 三条硬约束（来自设计决策，勿破坏）
///
/// 1. **不进 [ParkThemeData]**。材质之间没有有意义的中间态；若把派生结果
///    烘焙进主题，主题过渡动画会出现"玻璃的颜色 + stripe 的枚举"这种撕裂
///    状态。因此本类用工厂 [resolve] 在读取时派生，[ParkThemeData.surfaceStyle]
///    的枚举在 `t = 0.5` 整体跳变，派生层随之整体切换。
/// 2. **不污染 [ParkColors]**。风格只影响"表面"，绝不影响"品牌语义色"。
///    若 glass 风格让 `colors.brand` 变半透明，210 个消费 brand 的按钮 /
///    文字 / 图标会全部塌掉。这也是 115 个纯展示组件能零改动即自动正确的原因。
/// 3. **stripe 必须零回归**。[ParkSurfaceStyle.stripe] 分支的每一个数值都与
///    迁移前 `ParkCard._resolveSurface` 的 stripe 分支逐字段相等，由
///    `test/theme/stripe_baseline_test.dart` 锁定。
@immutable
class ParkSurfaceTokens {
  const ParkSurfaceTokens._({
    required this.style,
    required this.fill,
    required this.border,
    required this.radius,
    required this.shadows,
    required this.titleColor,
    required this.bodyColor,
    required this.glassBlur,
    required this.glassAlpha,
    required this.useBackdropFilter,
    required this.isDark,
  });

  /// 由 [style] 与基础令牌派生表面材质。
  ///
  /// 这是**全项目唯一的材质翻译点**：新增一种风格只需在此加一个分支，
  /// 所有消费 [ParkSurfaceTokens] 的组件自动适配，组件本身零改动。
  ///
  /// 5 种风格在本方法内全部有显式分支，**刻意不写 `_` 通配**，
  /// 因此新增枚举值时编译器会强制补齐分支（不会静默漏掉）。
  ///
  /// 🔴 但这只对本方法成立 —— `fill` / `titleColor` 的派生逻辑分散在
  /// `painted` 与构造处，新增风格时**必须同步核对这两处**，
  /// 否则会出现"填充色对了、标题色没对"的半正确状态。
  ///
  /// 组件意图参数：
  /// - [bordered] 是否绘制边框；
  /// - [hovered] 是否处于 hover 态（影响边框高亮与 stripe 阴影高度）；
  /// - [borderTone] 边框调性（`outline` / `inner` / `none`）；
  /// - [transparent] 是否为 ghost 态（不绘制填充与阴影）。
  ///
  ///   ⚠️ 已知行为变更（相对迁移前的 `ParkCard._resolveSurface`）：迁移前
  ///   **只有 flat / neo / neon / stripe 检查 isGhost，glass 不检查**，
  ///   因此 ghost + glass 的卡片仍会画出 55% 半透明填充。迁移后 ghost
  ///   对全部 5 种风格一致生效（填充透明、不画阴影）。
  ///
  ///   这是**有意的修正**而非回归：ghost 的语义就是"不绘制表面"，
  ///   旧实现让 glass 漏判属于不一致。但它确实改变了 glass + ghost 的观感，
  ///   故在此显式记录，供 review 与回滚时定位。
  /// - [elevation] 阴影高度基线（仅 stripe 分支使用，其余风格用自带阴影）。
  factory ParkSurfaceTokens.resolve({
    required ParkSurfaceStyle style,
    required ParkColors colors,
    required ParkRadius radius,
    required ParkBlur blur,
    bool bordered = true,
    bool hovered = false,
    ParkSurfaceBorderTone borderTone = ParkSurfaceBorderTone.outline,
    bool transparent = false,
    double elevation = 0.0,
  }) {
    final bool isDark = colors.background.computeLuminance() < 0.5;

    // 填充色：Ghost 态任何风格都不绘制。
    //
    // ⚠️ 这里的 switch 必须穷举全部 5 个风格，**不要加 `_` 通配**。
    // neon 是唯一随明暗翻转填充色的风格：深色底下表面要取亮色
    // （`colors.textPrimary`），否则深色卡片会与深色背景几乎同色、不可分辨。
    // 若图省事写 `_ => colors.surface`，新增风格还会静默继承 stripe 的填充色
    // 而无人察觉 —— 所以这里刻意不写通配分支，让编译器强制补齐。
    final Color painted = switch (style) {
      ParkSurfaceStyle.stripe => colors.surface,
      ParkSurfaceStyle.flat => colors.surface,
      ParkSurfaceStyle.glass => colors.surface.withValues(alpha: 0.55),
      ParkSurfaceStyle.neo => colors.background,
      ParkSurfaceStyle.neon =>
        isDark ? colors.textPrimary : colors.surface,
    };
    final Color fill = transparent ? Colors.transparent : painted;

    // 边框：调性与开关由组件声明，颜色 / 宽度由风格决定。
    final Border? border = (bordered &&
            borderTone != ParkSurfaceBorderTone.none)
        ? _resolveBorder(
            style: style,
            colors: colors,
            tone: borderTone,
            hovered: hovered,
          )
        : null;

    // 阴影：每种风格一套，transparent（ghost）态一律不绘制。
    final List<BoxShadow>? shadows = transparent
        ? null
        : switch (style) {
            ParkSurfaceStyle.stripe => _stripeShadows(
              colors: colors,
              elevation: elevation,
              hovered: hovered,
            ),
            ParkSurfaceStyle.flat => null,
            ParkSurfaceStyle.glass => <BoxShadow>[
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            ParkSurfaceStyle.neo => <BoxShadow>[
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
            ],
            ParkSurfaceStyle.neon => <BoxShadow>[
              BoxShadow(
                color: colors.brand.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          };

    final bool useBackdropFilter = style == ParkSurfaceStyle.glass;

    return ParkSurfaceTokens._(
      style: style,
      fill: fill,
      border: border,
      radius: radius.brMd,
      shadows: shadows,
      // 标题色必须与 [fill] 相反，否则深底深字/白底白字导致标题不可见。
      //
      // ⚠️ 这行与上面 `painted` 的 neon 分支是**强耦合**的，请勿"简化"：
      // neon + 深色时 fill = colors.textPrimary（暗色板下为纯白），
      // 因此标题必须取 colors.surface（暗色板下为深 navy）才可读。
      // 若改成"始终 colors.textPrimary"，就会变成白底白字 —— 标题消失。
      titleColor: style == ParkSurfaceStyle.neon && isDark
          ? colors.surface
          : colors.textPrimary,
      bodyColor: colors.textSecondary,
      glassBlur: useBackdropFilter ? blur.lg : 0.0,
      glassAlpha: style == ParkSurfaceStyle.glass ? 0.55 : 1.0,
      useBackdropFilter: useBackdropFilter,
      isDark: isDark,
    );
  }

  /// 浮层类组件（Dialog / Popover / Sheet / 导航栏 …）的阴影取值。
  ///
  /// ## 为什么需要这个入口
  ///
  /// [resolve] 的阴影是**卡片语义** —— stripe / flat 在 `elevation == 0`
  /// 时返回 null。但浮层是**恒定抬起**的（对话框永远有投影），阴影不可为
  /// null。若浮层直接消费 `tokens.shadows`，stripe / flat 风格的浮层会
  /// **凭空丢失阴影**，观感明显退化。
  ///
  /// 规则：**风格接管优先，浮层下限兜底**。
  /// - stripe / flat → `tokens.shadows` 为 null → 回落到 [floor]（零回归）；
  /// - glass / neo / neon → 风格自带阴影 → 材质性格生效。
  ///
  /// ## 用法
  ///
  /// ```dart
  /// shadows: ParkSurfaceTokens.overlayShadows(
  ///   tokens: tokens,
  ///   floor: park.shadows.lg,   // 浮层默认用 lg（Dialog / Sheet）
  /// ),
  /// ```
  ///
  /// 圆角**不**由本方法决定：各浮层有自己的尺寸语义（Dialog 是更大的表面
  /// 用 `brLg`，Popover 是卡片尺寸用 `brMd`），应保留组件原值而非消费
  /// `tokens.radius`（那是卡片语义）。
  static List<BoxShadow>? overlayShadows({
    required ParkSurfaceTokens tokens,
    required List<BoxShadow> floor,
  }) {
    return tokens.shadows ?? floor;
  }

  /// 按风格解析边框的颜色与宽度。
  ///
  /// 5 种风格全部有显式分支，新增风格时编译器会强制补齐。
  /// 新拟态（neo）返回 null —— 它靠双柔光阴影表达体积感，不画边框。
  static Border? _resolveBorder({
    required ParkSurfaceStyle style,
    required ParkColors colors,
    required ParkSurfaceBorderTone tone,
    required bool hovered,
  }) {
    return switch (style) {
      ParkSurfaceStyle.stripe => _stripeBorder(
        colors: colors,
        tone: tone,
        hovered: hovered,
      ),
      ParkSurfaceStyle.flat => Border.all(
        color: hovered
            ? colors.brand.withValues(alpha: 0.35)
            : colors.borderLight,
        width: 1,
      ),
      ParkSurfaceStyle.glass => Border.all(
        color: colors.textOnBrand.withValues(alpha: 0.40),
        width: 1,
      ),
      ParkSurfaceStyle.neo => null,
      ParkSurfaceStyle.neon => Border.all(
        color: colors.brand.withValues(alpha: 0.55),
        width: 1,
      ),
    };
  }

  /// Stripe 风格的边框：主边框 hover 时高亮为品牌色，内嵌边框用弱化填充色。
  static Border? _stripeBorder({
    required ParkColors colors,
    required ParkSurfaceBorderTone tone,
    required bool hovered,
  }) {
    return switch (tone) {
      ParkSurfaceBorderTone.outline => Border.all(
        color: hovered
            ? colors.brand.withValues(alpha: 0.3)
            : colors.border,
        width: 1,
      ),
      ParkSurfaceBorderTone.inner => Border.all(
        color: colors.disabledBg,
        width: 1,
      ),
      ParkSurfaceBorderTone.none => null,
    };
  }

  /// Stripe 风格的阴影：仅在有elevation 时绘制，hover 时额外抬高 2 级。
  static List<BoxShadow>? _stripeShadows({
    required ParkColors colors,
    required double elevation,
    required bool hovered,
  }) {
    final double currentElevation = elevation + (hovered ? 2.0 : 0.0);
    if (currentElevation <= 0) return null;
    return <BoxShadow>[
      BoxShadow(
        color: colors.textPrimary.withValues(alpha: 0.08),
        blurRadius: currentElevation * 4,
        offset: Offset(0, currentElevation * 2),
      ),
    ];
  }

  /// 派生自哪种表面风格（便于组件判断"是否玻璃"等）。
  final ParkSurfaceStyle style;

  /// 表面填充色。
  final Color fill;

  /// 表面边框；null 表示无边框。
  final Border? border;

  /// 表面圆角。
  final BorderRadius radius;

  /// 表面阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 标题在当前表面上的可读色。
  final Color titleColor;

  /// 正文在当前表面上的可读色。
  final Color bodyColor;

  /// 背景模糊 sigma（0 = 不模糊）。
  final double glassBlur;

  /// 玻璃填充透明度（0-1）。
  final double glassAlpha;

  /// 是否需要 [BackdropFilter] 背景采样。
  final bool useBackdropFilter;

  /// 当前色板是否深色（由 `colors.background` 亮度推导，供组件省去重复计算）。
  final bool isDark;

  /// 是否为玻璃风格（便捷判断）。
  bool get isGlass => useBackdropFilter;

  /// 阴影列表，永不为 null（无阴影时返回空列表）。
  ///
  /// 便于组件直接传给 `BoxDecoration.boxShadow`，无需写 `?? const []`。
  List<BoxShadow> get shadowsOrEmpty => shadows ?? const <BoxShadow>[];

  /// 复制并覆盖部分字段。
  ParkSurfaceTokens copyWith({
    ParkSurfaceStyle? style,
    Color? fill,
    Border? border,
    BorderRadius? radius,
    List<BoxShadow>? shadows,
    Color? titleColor,
    Color? bodyColor,
    double? glassBlur,
    double? glassAlpha,
    bool? useBackdropFilter,
    bool? isDark,
  }) {
    return ParkSurfaceTokens._(
      style: style ?? this.style,
      fill: fill ?? this.fill,
      border: border ?? this.border,
      radius: radius ?? this.radius,
      shadows: shadows ?? this.shadows,
      titleColor: titleColor ?? this.titleColor,
      bodyColor: bodyColor ?? this.bodyColor,
      glassBlur: glassBlur ?? this.glassBlur,
      glassAlpha: glassAlpha ?? this.glassAlpha,
      useBackdropFilter: useBackdropFilter ?? this.useBackdropFilter,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkSurfaceTokens &&
          runtimeType == other.runtimeType &&
          style == other.style &&
          fill == other.fill &&
          border == other.border &&
          radius == other.radius &&
          _shadowListEquals(shadows, other.shadows) &&
          titleColor == other.titleColor &&
          bodyColor == other.bodyColor &&
          glassBlur == other.glassBlur &&
          glassAlpha == other.glassAlpha &&
          useBackdropFilter == other.useBackdropFilter &&
          isDark == other.isDark;

  @override
  int get hashCode => Object.hash(
    style,
    fill,
    border,
    radius,
    shadows == null ? null : Object.hashAll(shadows!),
    titleColor,
    bodyColor,
    glassBlur,
    glassAlpha,
    useBackdropFilter,
    isDark,
  );

  /// 比较两个 [BoxShadow] 列表元素逐一相等。
  static bool _shadowListEquals(List<BoxShadow>? a, List<BoxShadow>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
