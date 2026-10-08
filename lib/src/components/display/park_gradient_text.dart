import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_gradient.dart';
import '../../theme/tokens/park_gradients.dart';

/// 渐变文字 —— 用渐变着色器填充文本。
///
/// ## 定位
///
/// 渐变文字是**装饰性强调**手段（Hero 标题、品牌 slogan、活动主标题），
/// 不是通用排版工具。所有颜色默认取自 [ParkGradients] 语义渐变，
/// 因此**自动跟随主题**：换预设 / 换品牌色，文字颜色随之改变，
/// 调用方无需传任何颜色参数。
///
/// ## 无障碍（重要）
///
/// [ShaderMask] 在部分平台会使 [Text] 的语义层丢失，导致读屏软件
/// **完全读不到这段文字**。因此本组件**强制**用 [Semantics] 包裹并提供
/// `label`（默认取 [text]）。若你需要"视觉上文字与语义不同"，
/// 用 [semanticsLabel] 覆盖，**不要**删掉 [Semantics]。
///
/// ## 性能
///
/// [ShaderMask] = **一次离屏渲染**，在低端 GPU 上开销明显。请遵守：
///
/// - **单屏建议 ≤ 3 处**渐变文字；
/// - **禁止用于长段落正文**（离屏纹理面积随文本长度线性膨胀）；
/// - **禁止在长列表 item 内使用 [shimmer]**（每帧重绘 × N 条 = 掉帧）。
///
/// 短标题（1 行内）的开销可接受。
///
/// ## 示例
///
/// ```dart
/// // 1. 零配置：自动跟随主题的品牌渐变
/// ParkGradientText(text: 'Park UI')
///
/// // 2. 描边 + 环形渐变
/// ParkGradientText(
///   text: 'NEON',
///   gradientType: ParkGradientType.sweep,
///   strokeWidth: 1.5,
/// )
///
/// // 3. 流动动画（系统"减弱动效"开启时自动停用）
/// ParkGradientText(text: '流动', shimmer: true)
/// ```
class ParkGradientText extends StatefulWidget {
  /// 文本内容（同时是默认的无障碍标签）。
  final String text;

  /// 文字样式；null 时取 `park.typography.pageTitle`。
  final TextStyle? style;

  /// 渐变类型（linear / radial / sweep）。
  ///
  /// 仅在 [gradient] 与 [colors] 均为 null 时用于挑选语义渐变预设；
  /// 显式传入 [gradient] 时以其自身的 [ParkGradient.type] 为准。
  final ParkGradientType gradientType;

  /// 自定义渐变令牌；null 时从主题渐变组按 [gradientType] 取预设。
  final ParkGradient? gradient;

  /// 便捷色列表；非空且 ≥2 色时**优先于** [gradient]。
  final List<Color>? colors;

  /// 文字对齐方式。
  final TextAlign textAlign;

  /// 最大行数；null 表示不限。
  final int? maxLines;

  /// 描边宽度；0（默认）表示不描边。
  ///
  /// ⚠️ 描边会让一个渐变文字产生 **2 次文本绘制调用**，仅在短标题上开启。
  final double strokeWidth;

  /// 描边色；null 时取主题表面色（`park.colors.surface`）作为底色把字形"垫"出来。
  final Color? strokeColor;

  /// 是否启用流动动画。
  ///
  /// 默认**关闭**。开启后仍会在
  /// `MediaQuery.disableAnimationsOf(context) == true`（系统"减弱动效"）
  /// 时自动停用。
  final bool shimmer;

  /// 流动周期；null 时取 `park.motion.slow`。
  ///
  /// 强制钳制到 ≥ 1s：过快的高频闪动既是体验问题也是无障碍问题
  /// （可能诱发光敏性癫痫）。
  final Duration? shimmerPeriod;

  /// 无障碍标签；null 时取 [text]。
  final String? semanticsLabel;

  /// 创建渐变文字。
  const ParkGradientText({
    super.key,
    required this.text,
    this.style,
    this.gradientType = ParkGradientType.linear,
    this.gradient,
    this.colors,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.strokeWidth = 0.0,
    this.strokeColor,
    this.shimmer = false,
    this.shimmerPeriod,
    this.semanticsLabel,
  }) : assert(strokeWidth >= 0.0, 'strokeWidth 不能为负');

  @override
  State<ParkGradientText> createState() => _ParkGradientTextState();
}

class _ParkGradientTextState extends State<ParkGradientText>
    with SingleTickerProviderStateMixin {
  /// 流动动画的最小周期（见 [ParkGradientText.shimmerPeriod]）。
  static const Duration minShimmerPeriod = Duration(seconds: 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: minShimmerPeriod,
  );

  /// 解析后的流动周期。主题 motion 在 didChangeDependencies 后才可读，
  /// 故缓存到字段并在变化时同步给 controller。
  Duration _effectivePeriod = minShimmerPeriod;

  @override
  void initState() {
    super.initState();
    if (widget.shimmer) _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Duration requested = widget.shimmerPeriod ?? _park.motion.slow;
    final Duration clamped =
        requested < minShimmerPeriod ? minShimmerPeriod : requested;
    if (clamped != _effectivePeriod) {
      _effectivePeriod = clamped;
      _controller.duration = clamped;
    }
    // 🔴 必须在这里也同步 ticker：`MediaQuery.disableAnimations` 变化只会
    // 触发 didChangeDependencies（不会触发 didUpdateWidget），若只在该处
    // 同步，系统"减弱动效"切换后 controller 会继续空转（ticker 永不停止）。
    _syncTicker();
  }

  @override
  void didUpdateWidget(ParkGradientText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  /// 按当前开关状态启停 ticker。
  ///
  /// 覆盖两种触发路径：调用方改了 [shimmer]，或系统"减弱动效"被切换。
  void _syncTicker() {
    final bool shouldRun = _shimmerActive;
    if (shouldRun && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldRun && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ParkThemeData get _park =>
      Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

  /// 动画是否真正运行：组件开关 && 系统未要求减弱动效。
  bool get _shimmerActive {
    if (!widget.shimmer) return false;
    if (MediaQuery.disableAnimationsOf(context)) return false;
    return true;
  }

  /// 按优先级解析最终渐变令牌。
  ///
  /// 优先级：[colors] > [gradient] > 主题语义渐变（随 [gradientType] 变化）。
  /// 这样"用户不传任何颜色"也能工作，且默认跟随主题联动
  /// （aurora / candy 预设覆盖 gradients 令牌后文字自动变色）。
  ParkGradient _resolveGradient(ParkThemeData park) {
    final List<Color>? explicit = widget.colors;
    if (explicit != null && explicit.length >= 2) {
      return ParkGradient(
        type: widget.gradientType,
        colors: explicit,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final ParkGradient? provided = widget.gradient;
    if (provided != null) return provided;

    final ParkGradients g = park.gradients;
    return switch (widget.gradientType) {
      ParkGradientType.linear => g.brand,
      ParkGradientType.radial =>
        g.brand.copyWith(type: ParkGradientType.radial),
      ParkGradientType.sweep => g.sweep,
    };
  }

  /// 按流动进度平移线性渐变，形成循环扫过的高光。
  ///
  /// 刻意**不用** shader 矩阵变换（`Gradient.createShader` 不接受变换矩阵），
  /// 改为每帧重建一个平移后的 `LinearGradient` —— 在短标题上完全可接受，
  /// 且避免了 `Matrix4` 手工拼装易出的错。
  Gradient _flowGradient(ParkGradient gradient, double t) {
    if (!_shimmerActive) return gradient.asFlutter;

    // 行程：一个宽度的高光从左扫到右，再从左重新开始。
    final double travel = t * 3.0 - 1.5;
    return LinearGradient(
      colors: gradient.colors,
      stops: gradient.stops,
      // Alignment 允许超出 [-1, 1]，配合 clamp 平铺即为扫光效果。
      begin: Alignment(travel - 0.5, 0.0),
      end: Alignment(travel + 0.5, 0.0),
      tileMode: gradient.tileMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ParkThemeData park = _park;
    final ParkGradient gradient = _resolveGradient(park);

    // 颜色完全交给着色器：先抹掉 style 里的 color / shadows，
    // 否则会与 shader 结果叠加成"脏色"，也会让描边层出现双层发虚。
    final TextStyle baseStyle = (widget.style ?? park.typography.pageTitle)
        .copyWith(color: null, shadows: const <Shadow>[]);

    final bool useStroke = widget.strokeWidth > 0;

    final Widget gradientLayer = _buildGradientLayer(
      gradient: gradient,
      style: baseStyle,
    );

    final Widget body = useStroke
        ? Stack(
            children: <Widget>[
              // 底层：纯色描边字形，把渐变字形"垫"出清晰的轮廓。
              Text(
                widget.text,
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                style: baseStyle.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = widget.strokeWidth
                    ..strokeJoin = StrokeJoin.round
                    ..color = widget.strokeColor ?? park.colors.surface,
                ),
              ),
              gradientLayer,
            ],
          )
        : gradientLayer;

    return Semantics(
      label: widget.semanticsLabel ?? widget.text,
      // 渐变文字对读屏不可见；排除内层语义避免同一文本被朗读两次。
      excludeSemantics: true,
      child: ClipRect(child: body),
    );
  }

  /// 构建渐变着色层；shimmer 关闭时不引入任何 ticker。
  Widget _buildGradientLayer({
    required ParkGradient gradient,
    required TextStyle style,
  }) {
    final Widget text = Text(
      widget.text,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      style: style,
    );

    final Widget masked = ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) =>
          _flowGradient(gradient, _controller.value).createShader(bounds),
      child: text,
    );

    if (!_shimmerActive) return masked;

    return AnimatedBuilder(
      animation: _controller,
      child: masked,
      builder: (BuildContext context, Widget? child) =>
          child ?? const SizedBox.shrink(),
    );
  }
}
