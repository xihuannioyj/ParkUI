import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/park_theme_data.dart';

/// Park 链接变体
enum ParkLinkVariant {
  /// 默认链接（品牌色，无下划线）
  defaultLink,

  /// 带下划线的链接
  underline,
}

/// Park 链接打开方式
enum ParkLinkTarget {
  /// 在当前上下文打开
  self,

  /// 在新窗口/上下文中打开
  blank,
}

/// Park 链接语义样式
enum ParkLinkStyle {
  /// 主要（品牌色）
  primary,

  /// 默认
  defaultStyle,

  /// 危险（错误色）
  danger,

  /// 警告
  warning,

  /// 成功
  success,
}

/// Park 链接尺寸
enum ParkLinkSize {
  /// 小号（12px）
  small,

  /// 中号（14px，默认）
  medium,

  /// 大号（16px）
  large,
}

/// Park 链接
///
/// 文字超链接组件，支持 normal / disabled / pressed 三种状态，
/// 可选下划线装饰。
///
/// ```dart
/// ParkLink(
///   '查看详情',
///   onTap: () => print('tapped'),
/// )
///
/// ParkLink(
///   '外部链接',
///   variant: ParkLinkVariant.underline,
///   href: 'https://example.com',
///   target: ParkLinkTarget.blank,
///   onTap: () => launchUrl(uri),
/// )
/// ```
class ParkLink extends StatefulWidget {
  /// 链接文字
  final String text;

  /// 点击回调
  final VoidCallback? onTap;

  /// 链接变体
  final ParkLinkVariant variant;

  /// 文字颜色（覆盖品牌色）
  final Color? color;

  /// 文字大小
  final double? fontSize;

  /// 自定义样式
  final TextStyle? style;

  /// 是否禁用
  final bool disabled;

  /// 前置图标
  final Widget? icon;

  /// 后置图标
  final Widget? trailingIcon;

  /// 链接地址（URL）
  final String? href;

  /// 打开方式（在当前上下文或新窗口）
  final ParkLinkTarget target;

  /// 是否处于 loading 状态（显示加载转圈）
  final bool loading;

  /// 是否已访问（改变颜色表示已访问状态）
  final bool visited;

  /// 语义样式（primary / defaultStyle / danger / warning / success）
  final ParkLinkStyle linkStyle;

  /// 链接尺寸（small / medium / large）
  final ParkLinkSize linkSize;

  /// 悬停颜色（覆盖默认悬停效果）
  final Color? hoverColor;

  /// 已访问颜色（覆盖默认紫色已访问样式）
  final Color? visitedColor;

  /// 是否触发下载（Web 场景下设置 download 属性）
  final bool download;

  /// 链接 rel 属性（Web 场景语义，如 'noopener', 'noreferrer'）
  final String? rel;

  const ParkLink(
    this.text, {
    super.key,
    this.onTap,
    this.variant = ParkLinkVariant.defaultLink,
    this.color,
    this.fontSize,
    this.style,
    this.disabled = false,
    this.icon,
    this.trailingIcon,
    this.href,
    this.target = ParkLinkTarget.self,
    this.loading = false,
    this.visited = false,
    this.linkStyle = ParkLinkStyle.defaultStyle,
    this.linkSize = ParkLinkSize.medium,
    this.hoverColor,
    this.visitedColor,
    this.download = false,
    this.rel,
  });

  @override
  State<ParkLink> createState() => _ParkLinkState();
}

class _ParkLinkState extends State<ParkLink> {
  bool _isPressed = false;
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    try {
      final uri = Uri.parse(widget.href!);
      // B79: Block dangerous URL schemes (e.g. javascript:) that could be
      // executed on the Web platform. Only allow safe, well-known schemes.
      const allowedSchemes = {'http', 'https', 'mailto', 'tel'};
      if (!allowedSchemes.contains(uri.scheme.toLowerCase())) {
        debugPrint('ParkLink: Blocked unsafe scheme: ${uri.scheme}');
        return;
      }
      if (widget.target == ParkLinkTarget.blank) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('ParkLink: Failed to launch URL: ${widget.href}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;

    // 解析语义样式颜色
    Color styleColor;
    switch (widget.linkStyle) {
      case ParkLinkStyle.primary:
        styleColor = colors.brand;
        break;
      case ParkLinkStyle.defaultStyle:
        styleColor = colors.brand;
        break;
      case ParkLinkStyle.danger:
        styleColor = colors.error;
        break;
      case ParkLinkStyle.warning:
        styleColor = colors.warning;
        break;
      case ParkLinkStyle.success:
        styleColor = colors.success;
        break;
    }

    // 解析已访问颜色
    final effectiveVisitedColor = widget.visitedColor ?? colors.brand;

    // 解析基础颜色
    final baseColor = widget.color ??
        (widget.disabled
            ? colors.textDisabled
            : widget.visited
                ? effectiveVisitedColor
                : styleColor);

    // 悬停颜色
    final hoveredColor = widget.hoverColor ?? colors.brandDark;
    final pressedColor =
        _isPressed && !widget.disabled ? colors.brandDark : baseColor;
    final displayColor =
        _isHovered && !widget.disabled && !_isPressed ? hoveredColor : pressedColor;

    // 解析尺寸
    final double effectiveFontSize;
    if (widget.fontSize != null) {
      effectiveFontSize = widget.fontSize!;
    } else {
      switch (widget.linkSize) {
        case ParkLinkSize.small:
          effectiveFontSize = park.typography.sizeOverline;
          break;
        case ParkLinkSize.medium:
          effectiveFontSize = park.typography.sizeBody;
          break;
        case ParkLinkSize.large:
          effectiveFontSize = park.typography.sizeH3;
          break;
      }
    }

    final decoration = widget.variant == ParkLinkVariant.underline &&
            !widget.disabled
        ? TextDecoration.underline
        : TextDecoration.none;

    final effectiveStyle = widget.style?.copyWith(
          color: displayColor,
          decoration: decoration,
          decorationColor: displayColor,
        ) ??
        TextStyle(
          color: displayColor,
          fontSize: effectiveFontSize,
          decoration: decoration,
          decorationColor: displayColor,
        );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading spinner
        if (widget.loading) ...[
          SizedBox(
            width: effectiveFontSize,
            height: effectiveFontSize,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(displayColor),
            ),
          ),
          SizedBox(width: park.spacing.xs),
        ],
        if (widget.icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: displayColor,
              size: effectiveFontSize + 2,
            ),
            child: widget.icon!,
          ),
          SizedBox(width: park.spacing.xs),
        ],
        Text(widget.text, style: effectiveStyle),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: park.spacing.xs),
          IconTheme(
            data: IconThemeData(
              color: displayColor,
              size: effectiveFontSize + 2,
            ),
            child: widget.trailingIcon!,
          ),
        ],
      ],
    );

    if (widget.disabled || widget.loading) {
      return Semantics(
        link: true,
        enabled: false,
        child: Opacity(opacity: widget.disabled ? 0.6 : 1.0, child: content),
      );
    }

    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else if (widget.href != null) {
              _launchUrl();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      ),
    );
  }
}
