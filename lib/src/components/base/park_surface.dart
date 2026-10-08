import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';

/// 表面装饰器 —— 给子树强制指定一种材质。
///
/// ## 定位
///
/// 本组件**不是**一套独立的材质引擎，而是
/// `ParkSurfaceStyleScope`（局部风格覆盖）+ `BackdropFilter`（玻璃采样）
/// 的组合。这样保证装饰器与 Scope 永远不会渲染出不一致的风格，
/// 从根上消除"装饰器如何与父级风格组合"的嵌套歧义。
///
/// ## 何时使用
///
/// 适合"我就是要给这一小块区域加个玻璃"的显式出口，以及给新组件提供
/// 统一的实现基底。**不**建议用它做全局换肤 —— 全局换肤请改
/// `ParkThemeData.surfaceStyle`（那样 200+ 组件零改动即自动适配）。
///
/// ## 性能
///
/// 玻璃嵌套时 `BackdropFilter` 会对同一区域重复采样，成本呈平方级增长。
/// 因此本组件通过 [ParkSurfaceStyleScope.of] 记录嵌套深度，
/// 深度 > 1 时自动关闭模糊（降级为半透明纯色填充，视觉不塌陷）。
///
/// ```dart
/// ParkSurface(
///   style: ParkSurfaceStyle.glass,
///   borderRadius: BorderRadius.circular(16),
///   child: Text('这一小块是玻璃'),
/// )
/// ```
class ParkSurface extends StatelessWidget {
  /// 子内容。
  final Widget child;

  /// 强制指定表面风格；null 表示沿用上层（Scope 或全局主题）。
  final ParkSurfaceStyle? style;

  /// 玻璃强度（0-1），线性插值模糊半径与填充透明度。
  ///
  /// 为 0 时仍保留填充与边框，仅关闭模糊，避免"降级到无模糊"时视觉塌陷。
  final double intensity;

  /// 圆角覆盖；null 时使用表面令牌派生的圆角。
  final BorderRadius? borderRadius;

  /// 内边距。
  final EdgeInsetsGeometry? padding;

  /// 是否启用 1px 内发光边框（仅玻璃风格有意义）。
  final bool highlight;

  /// 强制关闭玻璃模糊（列表等长列表场景应显式关闭）。
  final bool blurDisabled;

  /// 创建表面装饰器。
  const ParkSurface({
    super.key,
    required this.child,
    this.style,
    this.intensity = 1.0,
    this.borderRadius,
    this.padding,
    this.highlight = true,
    this.blurDisabled = false,
  }) : assert(intensity >= 0.0 && intensity <= 1.0, 'intensity 必须落在 0-1');

  /// 当前上下文中是否允许渲染 [BackdropFilter]。
  ///
  /// [ParkSurfaceBlurDepth] 记录的是**祖先中已启用模糊的层数**，因此：
  /// - `depth == 0`：自己是最外层玻璃，允许采样；
  /// - `depth >= 1`：祖先已采样过同一区域，重复采样成本呈平方级增长，
  ///   降级为半透明纯色填充。
  ///
  /// 🔴 判定必须是 `< 1` 而非 `<= 1`：`<= 1` 会让第 2 层也采样，
  /// 3 层嵌套将渲染出 2 层 BackdropFilter（与 `ParkGlassPanel` 的
  /// `canRenderBlur` 语义不一致，且违背设计文档 D-1 的缓解措施）。
  /// 显式传入 [blurDisabled] 亦可强制关闭。
  static bool canBlur(BuildContext context, {bool disabled = false}) {
    if (disabled) return false;
    return ParkSurfaceBlurDepth.of(context) < 1;
  }

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 玻璃嵌套深度：+1 表示本节点若启用玻璃会新增一层采样。
    final int depth = ParkSurfaceBlurDepth.of(context);

    final ParkSurfaceStyle effectiveStyle =
        style ?? ParkSurfaceStyleScope.of(context);

    final ParkSurfaceTokens tokens = ParkSurfaceTokens.resolve(
      style: effectiveStyle,
      colors: park.colors,
      radius: park.radius,
      blur: park.blur,
      // 装饰器默认不带边框，避免与子组件自身边框叠加成双线；
      // 需要描边时用 highlight 或自行嵌套 Container。
      bordered: false,
    );

    final double i = intensity.clamp(0.0, 1.0);
    final BorderRadius radius = borderRadius ?? tokens.radius;

    // 强度插值：模糊 sigma 线性缩放，填充 alpha 在 intensity=0 时保留 0.15
    // 的底，避免完全透明导致文字不可读。
    final double sigma = tokens.useBackdropFilter
        ? tokens.glassBlur * i
        : 0.0;
    final bool useBlur = tokens.useBackdropFilter && sigma > 0 && depth < 1;

    final Color fill = tokens.useBackdropFilter
        ? tokens.fill.withValues(alpha: 0.15 + 0.40 * i)
        : tokens.fill;

    final Border? border = highlight && tokens.useBackdropFilter
        ? Border.all(
            color: park.colors.textOnBrand.withValues(alpha: 0.35 * i),
            width: 1,
          )
        : null;

    Widget content = AnimatedContainer(
      duration: park.motion.standard,
      curve: park.motion.defaultEasing,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: border,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: park.colors.textPrimary.withValues(alpha: 0.08 * i),
            blurRadius: 8 * i,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (useBlur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: content,
      );
    }

    // 用 Scope 向下传递风格，使子树组件也跟随本装饰器的材质。
    return ParkSurfaceStyleScope(
      style: effectiveStyle,
      child: ParkSurfaceBlurDepth(
        depth: tokens.useBackdropFilter ? depth + 1 : depth,
        child: ClipRRect(borderRadius: radius, child: content),
      ),
    );
  }
}

/// 记录子树中玻璃材质的嵌套深度。
///
/// 供 [ParkSurface] 判断是否应关闭内层 [BackdropFilter]，避免重复背景采样。
class ParkSurfaceBlurDepth extends InheritedWidget {
  /// 创建玻璃深度标记。
  const ParkSurfaceBlurDepth({
    super.key,
    required this.depth,
    required super.child,
  });

  /// 当前已启用的玻璃层数。
  final int depth;

  /// 读取当前玻璃嵌套深度；无标记时为 0。
  static int of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<ParkSurfaceBlurDepth>()
            ?.depth ??
        0;
  }

  @override
  bool updateShouldNotify(ParkSurfaceBlurDepth oldWidget) => depth != oldWidget.depth;
}
