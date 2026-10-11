import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../l10n/park_localizations.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../base/park_surface.dart';
import '../base/park_text.dart';
import 'park_loading.dart';

/// 加载面板改造前的浮层阴影（浮层规范第 1 条的 floor）。
///
/// 组件原本用的是一条**字面量**阴影（#111827 10% / blur 24 / offset 0,8），
/// 并非 `park.shadows.*`。stripe / flat 风格下 [ParkSurfaceTokens.shadows]
/// 为 null，必须回落到这条原值，否则加载面板会凭空换一套阴影（非零回归）。
///
/// 私有而非公开：它是"改造前的字面量"，一旦公开就会被误当成可配置项，
/// 而它的正确性恰恰依赖于**不再被改动**。
const List<BoxShadow> _loadingPanelShadowFloor = <BoxShadow>[
  BoxShadow(
    color: Color(0x1A111827),
    blurRadius: 24,
    offset: Offset(0, 8),
  ),
];

/// 加载面板表面材质的派生结果。
@immutable
class ParkLoadingPanelSurface {
  /// 面板填充色（含不透明度）。
  final Color fill;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 是否需要背景模糊采样（仅 glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  /// 加载文案色 —— **必须**来自表面令牌。
  final Color textColor;

  const ParkLoadingPanelSurface({
    required this.fill,
    required this.shadows,
    required this.useBlur,
    required this.blurSigma,
    required this.textColor,
  });
}

/// 解析加载面板的表面材质（浮层规范在 LoadingPanel 上的实现）。
///
/// 五条浮层规范：
/// 1. 阴影 `tokens.shadows ?? floor`（[_loadingPanelShadowFloor]）——
///    风格接管优先，浮层原值兜底；
/// 2. 圆角保留组件原值 `BorderRadius.circular(18)`，
///    **不**消费 `tokens.radius`（那是卡片语义 brMd = 12）；
/// 3. 组件原本无边框，故 `bordered: false`，不凭空加边框；
/// 4. 文字色取 `tokens.titleColor`；
/// 5. 本组件无全屏 / 特殊形态，故没有独立分支。
///
/// ⚠️ 不透明度是**单一来源**：面板改造前固定为 96% 不透明（避免透出页面内容），
/// 该基线在非 glass 风格下继续生效；glass 风格下改由材质令牌自身的 0.55
/// 接管 —— 两条路径都读同一个 `tokens`，不会出现两处各写一遍的分叉。
@visibleForTesting
ParkLoadingPanelSurface resolveParkLoadingPanelSurface({
  required ParkThemeData park,
  required BuildContext context,
}) {
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    // 面板用阴影表达"抬起"，不需要描边。
    bordered: false,
  );

  final double alpha = tokens.isGlass ? tokens.glassAlpha : 0.96;
  return ParkLoadingPanelSurface(
    fill: tokens.fill.withValues(alpha: alpha),
    shadows: ParkSurfaceTokens.overlayShadows(
      tokens: tokens,
      floor: _loadingPanelShadowFloor,
    ),
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
    textColor: tokens.titleColor,
  );
}

/// 统一的局部加载组件。
///
/// 约定三种常用场景：
/// - 页面主体空白加载：使用 [ParkInlineLoading.page]
/// - 图片/卡片局部占位：使用 [ParkInlineLoading.compact]
/// - 按钮内图标加载：使用 [ParkInlineLoading.button]
class ParkInlineLoading extends StatelessWidget {
  /// 加载尺寸。
  final double size;

  /// 加载颜色。
  final Color? color;

  /// 可选文案。
  final String? text;

  /// 是否使用白卡风格面板。
  final bool usePanel;

  /// 是否居中包裹。
  final bool centered;

  const ParkInlineLoading({
    super.key,
    this.size = 24,
    this.color,
    this.text,
    this.usePanel = false,
    this.centered = false,
  });

  /// 页面主体加载态。
  const ParkInlineLoading.page({super.key, this.text, this.color})
      : size = 26,
        usePanel = true,
        centered = true;

  /// 局部卡片/图片占位加载态。
  const ParkInlineLoading.compact({super.key, this.size = 24, this.color})
      : text = null,
        usePanel = false,
        centered = true;

  /// 按钮内图标加载态。
  const ParkInlineLoading.button({
    super.key,
    this.size = 16,
    // 主题统一：默认 null 由 ParkLoading 按主题解析（深色按钮上用反色），
    // 原硬编码 Colors.white 在暗色主题下置于深色背景上不可见。
    this.color,
  })  : text = null,
        usePanel = false,
        centered = false;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (usePanel) {
      child = ParkLoadingPanel(
        text: text ?? ParkLocalizations.of(context).loading,
        withMask: false,
      );
    } else {
      child = ParkLoading(
        type: ParkLoadingType.circular,
        size: size,
        color: color,
      );
    }

    if (centered) {
      return Center(child: child);
    }

    return child;
  }
}

/// 统一白卡式加载面板。
class ParkLoadingPanel extends StatelessWidget {
  /// 加载文案。
  final String text;

  /// 是否展示半透明遮罩。
  final bool withMask;

  const ParkLoadingPanel({super.key, required this.text, this.withMask = true});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 表面材质走派生层：局部 ParkSurfaceStyleScope 覆盖自动生效。
    final ParkLoadingPanelSurface surface = resolveParkLoadingPanelSurface(
      park: park,
      context: context,
    );
    // 圆角保留组件原值 18（不消费 tokens.radius）。
    const BorderRadius panelRadius = BorderRadius.all(Radius.circular(18));

    Widget card = RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: surface.fill,
          borderRadius: panelRadius,
          boxShadow: surface.shadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParkLoading(
              type: ParkLoadingType.circular,
              size: 26,
              color: park.colors.brand,
            ),
            const SizedBox(height: 10),
            ParkText(
              text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: surface.textColor,
            ),
          ],
        ),
      ),
    );

    // glass 风格：叠加 BackdropFilter 采样背后的页面内容。
    //
    // 复用 ParkSurfaceBlurDepth 做嵌套降级，避免重复采样同一 backdrop。
    // 判定必须是 `< 1` 而非 `<= 1`（见 ParkSurface.canBlur 的说明）。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      card = ClipRRect(
        borderRadius: panelRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: surface.blurSigma,
            sigmaY: surface.blurSigma,
          ),
          child: card,
        ),
      );
    }

    if (!withMask) {
      return Center(child: card);
    }

    return AbsorbPointer(
      child: Container(
        // 主题统一：遮罩走 overlay 令牌（原硬编码白色面纱在暗色主题下刺眼）
        color: park.colors.overlay.withValues(alpha: 0.18),
        alignment: Alignment.center,
        child: card,
      ),
    );
  }
}
