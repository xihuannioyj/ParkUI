import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_sizing.dart';
import '../../theme/tokens/park_colors.dart';
import 'park_button_style.dart';

/// Park 图标位置
enum ParkIconPosition {
  /// 图标在文字前方
  start,

  /// 图标在文字后方
  end,
}

/// Park 按钮
///
/// 支持 6 种变体（primary / secondary / text / link / ghost / danger）、
/// 3 种尺寸（small / medium / large）、loading 和 disabled 状态。
///
/// ```dart
/// ParkButton(
///   variant: ParkButtonVariant.primary,
///   onPressed: () => print('pressed'),
///   child: Text('提交'),
/// )
///
/// ParkButton.icon(
///   icon: Icons.add,
///   label: '新建',
///   variant: ParkButtonVariant.ghost,
/// )
/// ```
class ParkButton extends StatefulWidget {
  /// 按钮文字
  final Widget? child;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 异步点击回调（执行时自动进入 loading 状态，完成后自动恢复）
  final Future<void> Function()? asyncOnPressed;

  /// 防抖间隔（防止重复点击）
  final Duration? debounceDuration;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 按钮变体
  final ParkButtonVariant variant;

  /// 按钮尺寸
  final ParkButtonSize size;

  /// 按钮形状
  final ParkButtonShape shape;

  /// 是否占满父容器宽度
  final bool block;

  /// 是否处于 loading 状态
  final bool loading;

  /// loading 指示器（可自定义）
  final Widget? loadingIndicator;

  /// 前置图标
  final Widget? icon;

  /// 自定义样式（覆盖变体默认样式）
  final ParkButtonStyle? style;

  /// 图标位置（在文字前方或后方）
  final ParkIconPosition iconPosition;

  /// 是否使用虚线边框
  final bool dashed;

  /// 渐变背景（设置后覆盖变体背景色）
  final Gradient? gradient;

  /// 角标数字（显示在按钮右上角）
  final int? badge;

  /// 是否显示红点角标（优先级高于 [badge] 数字显示）
  final bool badgeDot;

  /// 危险模式修饰符 — 为任意变体应用危险色
  final bool danger;

  /// 链接地址 — 设置后按钮点击将触发导航意图（通过 [onPressed] 回调处理）
  final String? href;

  /// HTML 按钮类型（主要用于 Web 表单语义）
  final ParkButtonHtmlType htmlType;

  /// 后置组件（显示在文字后方）
  final Widget? suffix;

  /// 自定义悬停颜色（覆盖默认悬停效果）
  final Color? hoverColor;

  /// 鼠标指针样式（启用时默认为 [SystemMouseCursors.click]）
  final MouseCursor? cursor;

  /// 悬停回调（参数为是否处于悬停状态）
  final ValueChanged<bool>? onHover;

  /// 是否为两字中文文本自动插入空格（符合中文排版规范）
  final bool autoInsertSpace;

  /// 获取焦点回调
  final VoidCallback? onFocus;

  /// 失去焦点回调
  final VoidCallback? onBlur;

  /// 幽灵模式 — 透明背景 + 边框（快捷方式，等价于 variant: ghost）
  final bool ghost;

  /// 是否为纯图标按钮（无文字，影响内边距和最小宽度）
  final bool iconOnly;

  /// 工具提示文本（长按或悬停时显示）
  final String? tooltip;

  /// 自定义高度覆盖（单位 px）。
  ///
  /// 传入时覆盖由 [size] 推导的默认高度（small:28 / medium:36 / large:44）。
  /// 常用于在组合容器（如 [ParkInputGroup]）中与其它控件
  /// （[ParkInput] / [ParkSelect]）做到严格等高。
  final double? height;

  const ParkButton({
    super.key,
    this.child,
    this.onPressed,
    this.asyncOnPressed,
    this.debounceDuration,
    this.onLongPress,
    this.variant = ParkButtonVariant.secondary,
    this.size = ParkButtonSize.medium,
    this.shape = ParkButtonShape.rectangle,
    this.block = false,
    this.loading = false,
    this.loadingIndicator,
    this.icon,
    this.style,
    this.iconPosition = ParkIconPosition.start,
    this.dashed = false,
    this.gradient,
    this.badge,
    this.badgeDot = false,
    this.danger = false,
    this.href,
    this.htmlType = ParkButtonHtmlType.button,
    this.suffix,
    this.hoverColor,
    this.cursor,
    this.onHover,
    this.autoInsertSpace = false,
    this.onFocus,
    this.onBlur,
    this.ghost = false,
    this.iconOnly = false,
    this.tooltip,
    this.height,
  });

  /// 便捷构造：图标 + 文字
  factory ParkButton.icon({
    Key? key,
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ParkButtonVariant variant = ParkButtonVariant.secondary,
    ParkButtonSize size = ParkButtonSize.medium,
    bool block = false,
    bool loading = false,
    ParkButtonStyle? style,
    ParkIconPosition iconPosition = ParkIconPosition.start,
    bool dashed = false,
    Gradient? gradient,
    int? badge,
    bool badgeDot = false,
    bool danger = false,
    String? tooltip,
  }) {
    return ParkButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      variant: variant,
      size: size,
      block: block,
      loading: loading,
      style: style,
      icon: _ParkIconData(icon),
      iconPosition: iconPosition,
      dashed: dashed,
      gradient: gradient,
      badge: badge,
      badgeDot: badgeDot,
      danger: danger,
      tooltip: tooltip,
      child: Text(label),
    );
  }

  bool get _enabled => (onPressed != null || asyncOnPressed != null) && !loading;

  @override
  State<ParkButton> createState() => _ParkButtonState();
}

class _ParkButtonState extends State<ParkButton> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isAsyncLoading = false;
  DateTime? _lastTapTime;

  Future<void> _handleTap() async {
    // Debounce check
    if (widget.debounceDuration != null && _lastTapTime != null) {
      final elapsed = DateTime.now().difference(_lastTapTime!);
      if (elapsed < widget.debounceDuration!) return;
    }
    _lastTapTime = DateTime.now();

    if (widget.asyncOnPressed != null) {
      setState(() => _isAsyncLoading = true);
      try {
        await widget.asyncOnPressed!();
      } finally {
        if (mounted) setState(() => _isAsyncLoading = false);
      }
    } else {
      widget.onPressed?.call();
    }
  }

  bool get _isLoading => widget.loading || _isAsyncLoading;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;
    final radiusTokens = park.radius;

    final sizing = park.sizing;

    // 解析尺寸参数
    final sizeConfig = _resolveSize(widget.size, sizing);

    // 解析变体样式（ghost 修饰符优先，其次 danger 修饰符）
    final effectiveVariant = widget.ghost
        ? ParkButtonVariant.ghost
        : widget.danger && widget.variant != ParkButtonVariant.danger
            ? ParkButtonVariant.danger
            : widget.variant;
    final variantStyle = _resolveVariantStyle(effectiveVariant, colors);

    // 合并自定义样式
    final rawBg = widget.style?.backgroundColor ?? variantStyle.backgroundColor;
    final bg = widget.gradient != null
        ? Colors.transparent
        : (_isHovered
            ? (widget.hoverColor ??
                (rawBg != null && rawBg != Colors.transparent
                    ? Color.lerp(rawBg, Colors.white, 0.12)!
                    : rawBg))
            : rawBg);
    final fg = widget.style?.foregroundColor ?? variantStyle.foregroundColor;
    final borderC = widget.style?.borderColor ?? variantStyle.borderColor;
    final borderW = widget.style?.borderWidth ?? variantStyle.borderWidth;
    final fontSize = widget.style?.fontSize ?? sizeConfig.fontSize;
    final fontWeight =
        widget.style?.fontWeight ?? variantStyle.fontWeight;
    final height = widget.style?.height ?? widget.height ?? sizeConfig.height;
    final hPadding =
        widget.style?.padding?.horizontal ?? sizeConfig.hPadding;
    final disabledOpacity =
        widget.style?.disabledOpacity ?? 0.4;

    // 圆角
    final br = widget.shape == ParkButtonShape.circle
        ? radiusTokens.brFull
        : widget.shape == ParkButtonShape.round
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(
                widget.style?.borderRadius ?? variantStyle.borderRadius ?? radiusTokens.sm,
              );

    // 按下态
    final pressedScale = _isPressed ? 0.97 : 1.0;
    final pressedOpacity = _isPressed ? 0.85 : 1.0;

    // 内容构建
    final content = _buildContent(park, fg ?? colors.textPrimary, fontSize, fontWeight, _isLoading);

    // 边框构建（支持虚线）
    Border? border;
    if (widget.dashed && borderC != null) {
      // Flutter 原生 Border 不支持虚线，使用自定义 CustomPaint
      border = null; // 虚线通过 CustomPaint 实现
    } else if (borderC != null) {
      border = Border.all(color: borderC, width: borderW ?? 1.0);
    }

    final button = Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          widget.onFocus?.call();
        } else {
          widget.onBlur?.call();
        }
      },
      child: Semantics(
      button: true,
      enabled: widget._enabled,
      label: widget.child is Text ? (widget.child as Text).data : null,
      child: MouseRegion(
        cursor: widget._enabled
            ? (widget.cursor ?? SystemMouseCursors.click)
            : SystemMouseCursors.basic,
        onEnter: widget._enabled
            ? (_) {
                setState(() => _isHovered = true);
                widget.onHover?.call(true);
              }
            : null,
        onExit: widget._enabled
            ? (_) {
                setState(() => _isHovered = false);
                widget.onHover?.call(false);
              }
            : null,
        child: AnimatedScale(
          scale: pressedScale,
          duration: park.motion.quick,
          child: AnimatedOpacity(
            opacity: widget._enabled ? pressedOpacity : disabledOpacity,
            duration: park.motion.quick,
            child: GestureDetector(
              onTapDown: widget._enabled ? (_) => setState(() => _isPressed = true) : null,
              onTapUp: widget._enabled ? (_) => setState(() => _isPressed = false) : null,
              onTapCancel: widget._enabled ? () => setState(() => _isPressed = false) : null,
              onTap: widget._enabled ? _handleTap : null,
              onLongPress: widget._enabled ? widget.onLongPress : null,
              child: _buildDecoratedButton(
                park: park,
                height: height,
                hPadding: hPadding,
                bg: bg,
                gradient: widget.gradient,
                br: br,
                border: border,
                borderC: borderC,
                borderW: borderW,
                dashed: widget.dashed,
                content: content,
                badge: widget.badge,
                badgeDot: widget.badgeDot,
                colors: colors,
                block: widget.block,
                sizeConfig: sizeConfig,
              ),
            ),
          ),
        ),
      ),
    ),
    );

    final btn = widget.block ? button : button;
    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: btn,
      );
    }
    return btn;
  }

  Widget _buildDecoratedButton({
    required ParkThemeData park,
    required double height,
    required double hPadding,
    required Color? bg,
    required Gradient? gradient,
    required BorderRadius br,
    required Border? border,
    required Color? borderC,
    required double? borderW,
    required bool dashed,
    required Widget content,
    required int? badge,
    required bool badgeDot,
    required ParkColors colors,
    required bool block,
    required _SizeConfig sizeConfig,
  }) {
    Widget container;

    if (dashed && borderC != null) {
      // 虚线边框使用 CustomPaint
      container = CustomPaint(
        painter: _DashedBorderPainter(
          color: borderC,
          width: borderW ?? 1.0,
          borderRadius: br,
        ),
        child: Container(
          height: height,
          constraints: block
              ? const BoxConstraints(minWidth: double.infinity)
              : widget.iconOnly
                  ? BoxConstraints(minWidth: height)
                  : BoxConstraints(minWidth: sizeConfig.minWidth),
          padding: widget.iconOnly
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: hPadding / 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: br,
            gradient: gradient,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      );
    } else {
      container = Container(
        height: height,
        constraints: block
            ? const BoxConstraints(minWidth: double.infinity)
            : widget.iconOnly
                ? BoxConstraints(minWidth: height)
                : BoxConstraints(minWidth: sizeConfig.minWidth),
        padding: widget.iconOnly
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: hPadding / 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: br,
          border: border,
          gradient: gradient,
          boxShadow: widget.style?.elevation,
        ),
        alignment: Alignment.center,
        child: content,
      );
    }

    // Badge 角标
    if (badgeDot || badge != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          container,
          Positioned(
            top: -6,
            right: -6,
            child: badgeDot
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: park.spacing.xs, vertical: park.spacing.xxs),
                    constraints: const BoxConstraints(minWidth: 18),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      badge != null && badge > 99
                          ? '99+'
                          : '${badge ?? 0}',
                      style: TextStyle(
                        color: colors.textOnBrand,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      );
    }

    return container;
  }

  Widget _buildContent(ParkThemeData park, Color fgColor, double fontSize, FontWeight? fontWeight, bool isLoading) {
    // autoInsertSpace: 对两字中文文本自动插入空格
    Widget? textChild = widget.child;
    if (widget.autoInsertSpace && widget.child is Text) {
      final textData = (widget.child as Text).data ?? '';
      if (_isTwoCharChinese(textData)) {
        textChild = Text('${textData[0]}\u00A0${textData[1]}');
      }
    }

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.loadingIndicator ??
              SizedBox(
                width: fontSize,
                height: fontSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(fgColor),
                ),
              ),
          if (textChild != null) ...[
            SizedBox(width: widget.size == ParkButtonSize.small ? park.spacing.xs : park.spacing.sm),
            DefaultTextStyle(
              style: TextStyle(
                color: fgColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
              child: textChild,
            ),
          ],
          if (widget.suffix != null) ...[
            SizedBox(width: widget.size == ParkButtonSize.small ? park.spacing.xs : park.spacing.sm),
            IconTheme(
              data: IconThemeData(color: fgColor, size: fontSize),
              child: widget.suffix!,
            ),
          ],
        ],
      );
    }

    final hasIcon = widget.icon != null;
    final hasText = textChild != null;
    final hasSuffix = widget.suffix != null;

    final textWidget = hasText
        ? DefaultTextStyle(
            style: TextStyle(
              color: fgColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
            child: textChild,
          )
        : null;

    final iconWidget = hasIcon
        ? IconTheme(
            data: IconThemeData(color: fgColor, size: fontSize + 2),
            child: widget.icon!,
          )
        : null;

    final suffixWidget = hasSuffix
        ? IconTheme(
            data: IconThemeData(color: fgColor, size: fontSize),
            child: widget.suffix!,
          )
        : null;

    final gap = SizedBox(width: widget.size == ParkButtonSize.small ? park.spacing.xs : park.spacing.sm);

    // Build the content row based on iconPosition and presence of suffix
    final List<Widget> children = [];

    if (hasIcon && hasText) {
      if (widget.iconPosition == ParkIconPosition.start) {
        children.addAll([iconWidget!, gap, textWidget!]);
      } else {
        children.addAll([textWidget!, gap, iconWidget!]);
      }
    } else if (hasIcon) {
      children.add(iconWidget!);
    } else if (hasText) {
      children.add(textWidget!);
    }

    // Append suffix at the end
    if (hasSuffix) {
      if (children.isNotEmpty) children.add(gap);
      children.add(suffixWidget!);
    }

    if (children.isEmpty) {
      return DefaultTextStyle(
        style: TextStyle(
          color: fgColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        child: const SizedBox.shrink(),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  /// 判断是否为两字中文文本
  bool _isTwoCharChinese(String text) {
    if (text.length != 2) return false;
    return text.codeUnitAt(0) >= 0x4E00 &&
        text.codeUnitAt(0) <= 0x9FFF &&
        text.codeUnitAt(1) >= 0x4E00 &&
        text.codeUnitAt(1) <= 0x9FFF;
  }

  _SizeConfig _resolveSize(ParkButtonSize size, ParkSizing sizing) {
    switch (size) {
      case ParkButtonSize.small:
        return _SizeConfig(
          height: sizing.buttonHeightSm,
          fontSize: 12,
          minWidth: 56,
          hPadding: 16,
        );
      case ParkButtonSize.medium:
        return _SizeConfig(
          height: sizing.buttonHeightMd,
          fontSize: 14,
          minWidth: 64,
          hPadding: sizing.buttonHorizontalPaddingMd,
        );
      case ParkButtonSize.large:
        return _SizeConfig(
          height: sizing.buttonHeightLg,
          fontSize: 16,
          minWidth: 80,
          hPadding: 32,
        );
    }
  }

  _VariantStyle _resolveVariantStyle(ParkButtonVariant variant, ParkColors colors) {
    switch (variant) {
      case ParkButtonVariant.primary:
        return _VariantStyle(
          backgroundColor: colors.brand,
          foregroundColor: colors.textOnBrand,
          fontWeight: FontWeight.w500,
        );
      case ParkButtonVariant.secondary:
        return _VariantStyle(
          backgroundColor: colors.surface,
          foregroundColor: colors.textPrimary,
          borderColor: colors.border,
          borderWidth: 1.0,
          fontWeight: FontWeight.w400,
        );
      case ParkButtonVariant.text:
        return _VariantStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textPrimary,
          fontWeight: FontWeight.w400,
        );
      case ParkButtonVariant.link:
        return _VariantStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.brand,
          fontWeight: FontWeight.w400,
        );
      case ParkButtonVariant.ghost:
        return _VariantStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.brand,
          borderColor: colors.brand,
          borderWidth: 1.0,
          fontWeight: FontWeight.w500,
        );
      case ParkButtonVariant.danger:
        return _VariantStyle(
          backgroundColor: colors.error,
          foregroundColor: colors.textOnBrand,
          fontWeight: FontWeight.w500,
        );
      case ParkButtonVariant.filled:
        return _VariantStyle(
          backgroundColor: Color.lerp(colors.surface, colors.textPrimary, 0.04)!,
          foregroundColor: colors.textPrimary,
          fontWeight: FontWeight.w400,
        );
      case ParkButtonVariant.light:
        return _VariantStyle(
          backgroundColor: colors.brand.withValues(alpha: 0.08),
          foregroundColor: colors.brand,
          fontWeight: FontWeight.w500,
        );
    }
  }
}

/// 内部用：尺寸配置
class _SizeConfig {
  final double height;
  final double fontSize;
  final double minWidth;
  final double hPadding;

  const _SizeConfig({
    required this.height,
    required this.fontSize,
    required this.minWidth,
    required this.hPadding,
  });
}

/// 内部用：变体样式
class _VariantStyle {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final FontWeight? fontWeight;
  final double? borderRadius;

  const _VariantStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.fontWeight,
    this.borderRadius,
  });
}

/// 内部用：IconData 包装为 Widget
class _ParkIconData extends StatelessWidget {
  final IconData icon;
  const _ParkIconData(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(icon);
  }
}

// =============================================================================
// ParkButtonGroupMode — 按钮组排列模式
// =============================================================================

/// 按钮组排列模式。
enum ParkButtonGroupMode {
  /// 紧密贴合模式：按钮之间无间隙，首尾按钮圆角，中间直角。
  joined,

  /// 均分模式：所有按钮均分可用空间（等宽/等高）。
  equal,
}

// =============================================================================
// ParkButtonGroup — 按钮组
// =============================================================================

/// Park 按钮组
///
/// 将多个 [ParkButton] 组合在一起。
///
/// 支持两种模式：
/// - [ParkButtonGroupMode.joined]（默认）：紧密贴合，首尾按钮保留圆角。
/// - [ParkButtonGroupMode.equal]：所有按钮均分可用空间（等宽/等高）。
///
/// ```dart
/// // 贴合模式
/// ParkButtonGroup(
///   children: [
///     ParkButton(child: Text('左'), onPressed: () {}),
///     ParkButton(child: Text('中'), onPressed: () {}),
///     ParkButton(child: Text('右'), onPressed: () {}),
///   ],
/// )
///
/// // 均分模式（3 个按钮各占 1/3 宽度）
/// ParkButtonGroup(
///   mode: ParkButtonGroupMode.equal,
///   children: [
///     ParkButton(variant: ParkButtonVariant.primary, child: Text('通过')),
///     ParkButton(child: Text('驳回')),
///     ParkButton(child: Text('转办')),
///   ],
/// )
/// ```
class ParkButtonGroup extends StatelessWidget {
  /// 按钮列表
  final List<Widget> children;

  /// 排列方向（默认为水平方向）
  final Axis direction;

  /// 组模式。默认 [ParkButtonGroupMode.joined]。
  final ParkButtonGroupMode mode;

  const ParkButtonGroup({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mode = ParkButtonGroupMode.joined,
  });

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final radiusTokens = park.radius;
    final radius = radiusTokens.sm;

    if (children.isEmpty) return const SizedBox.shrink();

    if (children.length == 1) {
      return children.first;
    }

    final isHorizontal = direction == Axis.horizontal;

    final isEqual = mode == ParkButtonGroupMode.equal;

    if (isEqual) {
      // 均分模式：每个子项用 Expanded 包裹，均分可用空间
      return isHorizontal
          ? Row(
              children: children
                  .map((child) => Expanded(child: child))
                  .toList(),
            )
          : Column(
              children: children
                  .map((child) => Expanded(child: child))
                  .toList(),
            );
    }

    return isHorizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(children.length, (index) {
              final isFirst = index == 0;
              final isLast = index == children.length - 1;

              final br = BorderRadius.only(
                topLeft: isFirst ? Radius.circular(radius) : Radius.zero,
                bottomLeft: isFirst ? Radius.circular(radius) : Radius.zero,
                topRight: isLast ? Radius.circular(radius) : Radius.zero,
                bottomRight: isLast ? Radius.circular(radius) : Radius.zero,
              );

              return ClipRRect(
                borderRadius: br,
                child: children[index],
              );
            }),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(children.length, (index) {
              final isFirst = index == 0;
              final isLast = index == children.length - 1;

              final br = BorderRadius.only(
                topLeft: isFirst ? Radius.circular(radius) : Radius.zero,
                topRight: isFirst ? Radius.circular(radius) : Radius.zero,
                bottomLeft: isLast ? Radius.circular(radius) : Radius.zero,
                bottomRight: isLast ? Radius.circular(radius) : Radius.zero,
              );

              return ClipRRect(
                borderRadius: br,
                child: children[index],
              );
            }),
          );
  }
}

// =============================================================================
// 虚线边框画笔
// =============================================================================

/// 内部用：虚线边框 CustomPainter
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final BorderRadius borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.width,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    final rrect = borderRadius.toRRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final path = Path()..addRRect(rrect);

    // Draw dashed path
    const dashWidth = 4.0;
    const dashGap = 3.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.width != width ||
        oldDelegate.borderRadius != borderRadius;
  }
}
