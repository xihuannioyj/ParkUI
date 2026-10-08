import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_blur.dart';
import '../../theme/tokens/park_colors.dart';
import '../base/park_surface.dart';

/// 玻璃拟态面板 —— 半透明填充 + 背景模糊 + 1px 高光边。
///
/// ## 🔴 使用边界（务必先读）
///
/// **玻璃属"控制层"材质，不是"内容层"材质。** 依据 Apple HIG
/// "Materials" 一节：毛玻璃用于**内容之下/之上**的控制层（导航栏、
/// 浮层、悬浮按钮），一旦垫在**长篇内容 / 列表项**之下，背景高频细节
/// 会透过半透明层直接干扰前景文字，产生"浑浊、低对比度"的阅读体验 ——
/// Apple 官方 Mail.app 只在 toolbar 使用玻璃、从不对邮件列表用玻璃，
/// 正是基于此。
///
/// 因此本组件**禁止**用于：
/// - 长列表项（`ListView` / `Column` 中成百上千个 item）；
/// - 内容卡片 / 文章正文容器。
///
/// **允许**用于：导航栏、悬浮操作按钮、弹层、遮罩、浮层工具条。
/// 若确实需要在列表里"看起来有玻璃"，请用
/// [ParkGlassPanel.disabled] —— 它渲染同样的半透明渐变观感但**不采样背景**，
/// 成本接近一次普通绘制。
///
/// ## 性能
///
/// [BackdropFilter] 每次都触发 backdrop 采样 + 离屏渲染，是本组件库中
/// **成本最高**的能力。三重降级（见类文档与各字段说明）：
///
/// 1. **同屏数量**：单屏 ≥3 个面板时由调用方改用 [disabled]；
/// 2. **嵌套**：[depth] > 1 时内层自动关闭模糊（复用
///    [ParkSurfaceBlurDepth]，与 [ParkSurface] 同一套机制）；
/// 3. **系统偏好**：[MediaQuery.disableAnimationsOf] 为 true
///    （系统"减弱动效"/"减弱透明度"）时自动降级为半透明纯色。
///
/// ## 形状
///
/// 默认**胶囊**（`radius.brFull`），呼应 Apple 玻璃控件的默认形状；
/// 需要方角时传 [borderRadius]。
///
/// ## 示例
///
/// ```dart
/// // 导航栏玻璃（推荐用法）
/// ParkGlassPanel(
///   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
///   child: Text('筛选'),
/// )
///
/// // 列表项：请用 disabled（无背景采样）
/// ParkGlassPanel.disabled(child: Text(item.label))
/// ```
class ParkGlassPanel extends StatelessWidget {
  /// 填充透明度的可读性下限。
  ///
  /// intensity=0（完全降级）时仍保留这层底，文字才不会直接落在背景图上。
  static const double minFillAlpha = 0.15;

  /// 玻璃高光描边的标准透明度。
  ///
  /// 与 [ParkSurface] 的 1px 高光边保持同一观感，集中在此避免各处写死。
  static const double hairlineAlpha = 0.35;

  /// 在给定填充色上**可见**的 1px 描边色（玻璃容器的"高光边"）。
  ///
  /// ## 为什么需要这个函数
  ///
  /// 玻璃容器的描边不能恒用 `colors.textOnBrand`：它是"反色面色"，
  /// 在**深色**容器上表现为亮边（正确），但在 neon 这类
  /// **fill 会翻转为近白**的风格下，近白底 + 近白描边 = 描边消失。
  ///
  /// 这类"成对取值"如果在各组件里各写一份 `isDark ? A : B`，
  /// 改一处漏一处就会出现"容器有边、里面图标看不见"的半正确状态
  /// —— 本函数把规则收敛为**唯一实现点**，供 `ParkEmpty` /
  /// `ParkResult` / `ParkTag` 共用。
  ///
  /// 规则：暗底取反色面色（亮边），亮底取品牌色（暗边）——
  /// 两种明暗下描边都可见，且不引入新的裸色值。
  static Color hairlineColorFor({
    required Color fill,
    required ParkColors colors,
    required bool isDark,
  }) =>
      isDark ? colors.textOnBrand : colors.brand;

  /// 子内容。
  final Widget child;

  /// 玻璃强度 0.0–1.0，线性插值模糊半径、填充透明度与边框亮度。
  ///
  /// **0.0 时仍保留填充与边框**，仅关闭模糊 —— 这样"降级到无模糊"时
  /// 视觉不塌陷，且文字仍落在半透明底上保持可读。
  final double intensity;

  /// 模糊半径档位（默认 [ParkGlassBlur.lg]）。
  ///
  /// 🔴 必须取自 [ParkBlur] 令牌，**禁止魔法数**：模糊半径直接决定
  /// GPU 开销，也决定"够不够透"的观感，必须由令牌统一管控。
  final ParkGlassBlur blurLevel;

  /// 圆角；null 时使用胶囊（`radius.brFull`）。
  final BorderRadius? borderRadius;

  /// 内边距。
  final EdgeInsetsGeometry? padding;

  /// 半透明填充色；null 时取表面令牌派生的填充色。
  final Color? tint;

  /// 是否启用 1px 内发光高光边框。
  final bool highlight;

  /// 裁剪行为。
  final Clip clipBehavior;

  /// 点击回调；非 null 时自动包一层可点击语义。
  final VoidCallback? onTap;

  /// 强制关闭模糊（跳过所有降级判断）。
  ///
  /// 用于"想要玻璃观感但绝不能采样背景"的场景，如列表项。
  final bool blurDisabled;

  /// 创建玻璃拟态面板。
  const ParkGlassPanel({
    super.key,
    required this.child,
    this.intensity = 1.0,
    this.blurLevel = ParkGlassBlur.lg,
    this.borderRadius,
    this.padding,
    this.tint,
    this.highlight = true,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.blurDisabled = false,
  }) : assert(intensity >= 0.0 && intensity <= 1.0, 'intensity 必须落在 0-1');

  /// 列表等长列表场景的快捷构造：**观感保留、采样关闭**。
  ///
  /// 等价于 `blurDisabled: true`。刻意不提供"玻璃效果的列表项"，
  /// 因为 [BackdropFilter] × N 条必然掉帧 —— 详见类文档的使用边界。
  ParkGlassPanel.disabled({
    Key? key,
    required Widget child,
    double intensity = 1.0,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? tint,
    bool highlight = true,
    Clip clipBehavior = Clip.antiAlias,
    VoidCallback? onTap,
  }) : this(
         key: key,
         child: child,
         intensity: intensity,
         borderRadius: borderRadius,
         padding: padding,
         tint: tint,
         highlight: highlight,
         clipBehavior: clipBehavior,
         onTap: onTap,
         blurDisabled: true,
       );

  /// 当前上下文是否允许渲染 [BackdropFilter]。
  ///
  /// 四重判定（任一命中即降级）：
  /// 1. [blurDisabled] 显式关闭；
  /// 2. [intensity] 为 0（由调用方在 build 中以 `sigma > 0` 判定）；
  /// 3. `MediaQuery.disableAnimationsOf`（系统"减弱透明度"）；
  /// 4. 玻璃嵌套深度 —— 复用 [ParkSurfaceBlurDepth]，与 [ParkSurface]
  ///    完全同一套机制，不另造。
  ///
  /// 🔴 第 4 条刻意用 `depth < 1` 而非 `ParkSurface.canBlur` 的 `depth <= 1`：
  /// [ParkSurfaceBlurDepth.depth] 的语义是"**当前已启用的玻璃层数**"，
  /// 本组件渲染模糊后会把自己的子树标记为 `depth + 1`。因此当内层面板
  /// 读到 `depth == 1` 时，说明它已经**位于一个正在采样的玻璃面之上**，
  /// 再采样就是对同一 backdrop 重复采样（成本平方级增长），必须降级。
  ///
  /// （已向 team-lead 报告：`ParkSurface.canBlur` 的 `<= 1` 使嵌套两层
  /// 时内外都渲染模糊，属批次 1 遗留疑点，本批次未越界修改。）
  static bool canRenderBlur(BuildContext context, {required bool disabled}) {
    if (disabled) return false;
    if (MediaQuery.disableAnimationsOf(context)) return false;
    return ParkSurfaceBlurDepth.of(context) < 1;
  }

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    // 材质翻译统一走派生层，组件内**不判断具体风格**。
    final ParkSurfaceTokens surface = ParkSurfaceTokens.resolve(
      style: ParkSurfaceStyleScope.of(context),
      colors: park.colors,
      radius: park.radius,
      blur: park.blur,
      bordered: false,
    );

    final int depth = ParkSurfaceBlurDepth.of(context);
    final double i = intensity.clamp(0.0, 1.0);
    final BorderRadius radius = borderRadius ?? park.radius.brFull;

    // 模糊半径取自 ParkBlur 令牌，无魔法数。
    final double baseSigma = blurLevel.sigmaOf(park.blur);
    final double sigma = baseSigma * i;

    final bool renderBlur =
        canRenderBlur(context, disabled: blurDisabled) && sigma > 0;

    // 填充透明度：从"可读性下限"线性插值到表面令牌的 glassAlpha。
    //
    // - `minFillAlpha`（0.15）是**可读性下限**：intensity=0 时仍保留它，
    //   否则文字会直接落在背景图上，在任何背景上都不可读 ——
    //   这正是"降级到无模糊时视觉不塌陷"的实现方式。
    // - `surface.glassAlpha` 是上限：glass 风格为 0.55（半透明），
    //   其余风格为 1.0（不透明）—— 因此非玻璃风格下满强度得到
    //   实心面板，玻璃风格下得到半透明面板。
    //
    // 🔴 glassAlpha 取自 ParkSurfaceTokens 而非本地常量，
    // 这样"玻璃有多透"永远是材质层的单一事实来源。
    final Color baseTint = tint ?? surface.fill;
    final double fillAlpha =
        minFillAlpha + (surface.glassAlpha - minFillAlpha) * i;
    final Color fill = baseTint.withValues(alpha: fillAlpha);

    final Border? border = highlight
        ? Border.all(
            // 高光边走统一规则（暗底亮边 / 亮底暗边），任何明暗都可见。
            color: hairlineColorFor(
              fill: fill,
              colors: park.colors,
              isDark: surface.isDark,
            ).withValues(alpha: hairlineAlpha * i),
            width: 1,
          )
        : null;

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: border,
        // 悬浮感：阴影透明度随强度线性缩放。
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: park.colors.textPrimary.withValues(alpha: 0.08 * i),
            blurRadius: park.blur.sm * 2 * i,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    if (onTap != null) {
      content = Material(
        color: const Color(0x00000000),
        borderRadius: radius,
        child: InkWell(borderRadius: radius, onTap: onTap, child: content),
      );
    }

    if (renderBlur) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: content,
      );
    }

    // 与 ParkSurface 一致：把风格与玻璃深度向下传递，
    // 使嵌套的内层面板能自动降级（depth+1）。
    return ParkSurfaceStyleScope(
      style: surface.style,
      child: ParkSurfaceBlurDepth(
        depth: renderBlur ? depth + 1 : depth,
        child: ClipRRect(borderRadius: radius, clipBehavior: clipBehavior,
            child: content),
      ),
    );
  }
}

/// 玻璃模糊档位 —— 全部映射到 [ParkBlur] 的 4 级令牌，无独立数值。
///
/// 刻意用**枚举**而非裸 `double`：模糊半径直接决定 GPU 开销，
/// 用枚举把"允许哪些值"收敛成 4 个可枚举、可 review 的选项，
/// 调用方无法（也不该）传入魔法数。
enum ParkGlassBlur {
  /// 轻量玻璃（4px 默认）—— tooltip / 徽标 / 小浮层。
  sm,

  /// 中等玻璃（8px 默认）—— 下拉菜单 / 浮动面板。
  md,

  /// 强玻璃（16px 默认）—— 导航栏 / 对话框遮罩 / 侧边栏。**默认值**。
  lg,

  /// 极强玻璃（24px 默认）—— 全屏模态遮罩。
  xl;

  /// 从 [ParkBlur] 令牌解析出实际 sigma 值。
  ///
  /// 🔴 这是本组件**唯一**允许出现模糊半径的地方，且值全部来自令牌，
  /// 因此换主题 / 换预设（glass / aurora 有更强的 blur 性格）时
  /// 玻璃强度会自动跟随。
  double sigmaOf(ParkBlur blur) => switch (this) {
    ParkGlassBlur.sm => blur.sm,
    ParkGlassBlur.md => blur.md,
    ParkGlassBlur.lg => blur.lg,
    ParkGlassBlur.xl => blur.xl,
  };
}
