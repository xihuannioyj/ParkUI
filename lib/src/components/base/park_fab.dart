import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 悬浮按钮尺寸
enum ParkFabSize {
  /// 超小 — 28px
  xsmall,

  /// 小号 — 32px
  small,

  /// 常规 — 56px
  normal,

  /// 迷你 — 40px
  mini,
}

/// Park 悬浮按钮形状
enum ParkFabShape {
  /// 圆形
  circle,

  /// 圆角方形
  rounded,
}

/// Park 悬浮按钮主题变体
enum ParkFabTheme {
  /// 主要 — 品牌色背景
  primary,

  /// 默认 — 白底 + 品牌色图标
  defaultTheme,

  /// 浅色 — 品牌色调浅底
  light,

  /// 危险 — 错误色背景
  danger,
}

/// Park 悬浮操作按钮（FAB）
///
/// 用于页面主操作，固定在屏幕某个位置。
///
/// ```dart
/// ParkFab(
///   icon: Icons.add,
///   onPressed: () {},
/// )
///
/// ParkFab(
///   icon: Icons.edit,
///   label: '编辑',
///   shape: ParkFabShape.rounded,
///   onPressed: () {},
/// )
/// ```
class ParkFab extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 可选文字标签（有标签时自动变为 extended FAB）
  final String? label;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 尺寸
  final ParkFabSize size;

  /// 形状
  final ParkFabShape shape;

  /// 背景色（默认品牌色）
  final Color? backgroundColor;

  /// 前景色（默认白色）
  final Color? foregroundColor;

  /// 自定义阴影
  final List<BoxShadow>? elevation;

  /// 是否处于 loading 状态（显示圆形加载指示器）
  final bool loading;

  /// 是否禁用
  final bool disabled;

  /// 长按提示文本（包裹 Tooltip 组件）
  final String? tooltip;

  /// 主题变体（primary / defaultTheme / light / danger）
  final ParkFabTheme themeVariant;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否为迷你尺寸（等价于 size: ParkFabSize.mini 的快捷方式）
  final bool mini;

  const ParkFab({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.size = ParkFabSize.normal,
    this.shape = ParkFabShape.circle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.loading = false,
    this.disabled = false,
    this.tooltip,
    this.themeVariant = ParkFabTheme.primary,
    this.onLongPress,
    this.mini = false,
  });

  bool get _enabled => !disabled && !loading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;

    // 解析主题变体颜色
    final Color themeBg;
    final Color themeFg;
    switch (themeVariant) {
      case ParkFabTheme.primary:
        themeBg = colors.brand;
        themeFg = colors.textOnBrand;
        break;
      case ParkFabTheme.defaultTheme:
        themeBg = colors.surface;
        themeFg = colors.brand;
        break;
      case ParkFabTheme.light:
        themeBg = colors.brandLight;
        themeFg = colors.brand;
        break;
      case ParkFabTheme.danger:
        themeBg = colors.error;
        themeFg = colors.textOnBrand;
        break;
    }

    final bg = disabled
        ? colors.disabledBg
        : (backgroundColor ?? themeBg);
    final fg = disabled
        ? colors.textDisabled
        : (foregroundColor ?? themeFg);

    // 解析尺寸
    final effectiveSize = mini ? ParkFabSize.mini : size;
    final double fabSize;
    final double iconSize;
    switch (effectiveSize) {
      case ParkFabSize.xsmall:
        fabSize = 28.0;
        iconSize = 16.0;
        break;
      case ParkFabSize.small:
        fabSize = 32.0;
        iconSize = 18.0;
        break;
      case ParkFabSize.mini:
        fabSize = 40.0;
        iconSize = 20.0;
        break;
      case ParkFabSize.normal:
        fabSize = 56.0;
        iconSize = 24.0;
        break;
    }

    final shadows = disabled ? <BoxShadow>[] : (elevation ?? park.shadows.md);

    final br = shape == ParkFabShape.circle
        ? park.radius.brFull
        : park.radius.brLg;

    final hasLabel = label != null;

    Widget innerContent;

    if (loading) {
      // Loading 状态：显示转圈指示器
      innerContent = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    } else if (hasLabel) {
      innerContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          SizedBox(width: park.spacing.sm),
          Text(
            label!,
            style: TextStyle(
              color: fg,
              fontSize: park.typography.sizeBodySmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      innerContent = Center(
        child: Icon(icon, size: iconSize, color: fg),
      );
    }

    Widget fab = Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: Material(
        color: bg,
        borderRadius: br,
        elevation: 0,
        child: InkWell(
          onTap: _enabled ? onPressed : null,
          onLongPress: _enabled ? onLongPress : null,
          borderRadius: br,
          child: Container(
            height: fabSize,
            constraints: hasLabel
                ? const BoxConstraints(minWidth: 80)
                : BoxConstraints(minWidth: fabSize),
            padding: hasLabel
                ? EdgeInsets.symmetric(horizontal: park.spacing.base)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: br,
              boxShadow: shadows,
            ),
            child: innerContent,
          ),
        ),
      ),
    );

    // Disabled 时降低透明度
    if (disabled) {
      fab = Opacity(opacity: 0.5, child: fab);
    }

    // Tooltip 包裹
    if (tooltip != null) {
      fab = Tooltip(
        message: tooltip!,
        child: fab,
      );
    }

    return fab;
  }
}
