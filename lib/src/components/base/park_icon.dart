import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import 'park_icon_size.dart';

/// Park 图标容器形状
enum ParkIconContainer {
  /// 无容器
  none,

  /// 圆形容器
  circle,

  /// 圆角方形容器
  rounded,
}

/// Park 图标组件
///
/// 对 Flutter 原生 [Icon] 的增强封装：
/// - 预设尺寸（small / medium / large / xlarge）
/// - 可选容器背景（circle / rounded）
/// - 主题色自动跟随
/// - 可选旋转动画（[spin]）
/// - 可选角标（[badge]）
/// - 可选点击交互（[onClick]）
///
/// ```dart
/// ParkIcon(Icons.home)
/// ParkIcon(Icons.star, size: ParkIconSize.large, color: Colors.amber)
/// ParkIcon(Icons.add, container: ParkIconContainer.circle, containerColor: brand)
/// ParkIcon(Icons.refresh, spin: true)
/// ParkIcon(Icons.mail, badge: 3)
/// ParkIcon(Icons.settings, onClick: () => print('tapped'))
/// ```
class ParkIcon extends StatefulWidget {
  /// 图标数据
  final IconData icon;

  /// 图标尺寸预设
  final ParkIconSize size;

  /// 自定义像素尺寸（优先于 [size]）
  final double? pixelSize;

  /// 图标颜色
  final Color? color;

  /// 容器类型
  final ParkIconContainer container;

  /// 容器背景色
  final Color? containerColor;

  /// 容器内边距（默认根据图标尺寸自动计算）
  final double? containerPadding;

  /// 语义标签
  final String? semanticLabel;

  /// 是否启用持续旋转动画。
  ///
  /// 为 true 时图标以 1.5 秒周期匀速旋转。
  final bool spin;

  /// 右上角角标数字。
  ///
  /// 为 null 时不显示角标；大于 99 时显示 "99+"。
  final int? badge;

  /// 点击回调。
  ///
  /// 不为 null 时图标包裹 [InkWell] 以提供涟漪反馈。
  final VoidCallback? onClick;

  /// 长按提示文本（包裹 Tooltip 组件）
  final String? tooltip;

  /// 是否显示红点角标（简单红点，不显示数字）
  final bool badgeDot;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 自定义旋转动画周期（默认为 1500ms）
  final Duration? spinDuration;

  /// 悬停状态颜色（仅当 [onClick] 不为 null 时有效）
  final Color? hoverColor;

  /// 旋转角度（度数，如 45、90、180）
  final double? rotate;

  /// 是否水平翻转
  final bool mirror;

  const ParkIcon(
    this.icon, {
    super.key,
    this.size = ParkIconSize.medium,
    this.pixelSize,
    this.color,
    this.container = ParkIconContainer.none,
    this.containerColor,
    this.containerPadding,
    this.semanticLabel,
    this.spin = false,
    this.badge,
    this.onClick,
    this.tooltip,
    this.badgeDot = false,
    this.onLongPress,
    this.spinDuration,
    this.hoverColor,
    this.rotate,
    this.mirror = false,
  });

  @override
  State<ParkIcon> createState() => _ParkIconState();
}

class _ParkIconState extends State<ParkIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _spinController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.spin) {
      _spinController = AnimationController(
        vsync: this,
        duration: widget.spinDuration ?? const Duration(milliseconds: 1500),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ParkIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spin != oldWidget.spin) {
      if (widget.spin && _spinController == null) {
        _spinController = AnimationController(
          vsync: this,
          duration: widget.spinDuration ?? const Duration(milliseconds: 1500),
        )..repeat();
      } else if (!widget.spin && _spinController != null) {
        _spinController!.stop();
        _spinController!.dispose();
        _spinController = null;
      }
    }
    // 更新旋转周期
    if (widget.spinDuration != oldWidget.spinDuration && _spinController != null) {
      _spinController!.duration = widget.spinDuration ?? const Duration(milliseconds: 1500);
    }
  }

  @override
  void dispose() {
    _spinController?.dispose();
    super.dispose();
  }

  double _resolveSize(ParkIconSize s) {
    switch (s) {
      case ParkIconSize.small:
        return 16.0;
      case ParkIconSize.medium:
        return 20.0;
      case ParkIconSize.large:
        return 24.0;
      case ParkIconSize.xlarge:
        return 32.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();
    final colors = park.colors;

    final iconSize = widget.pixelSize ?? _resolveSize(widget.size);
    final iconColor = widget.color ?? park.iconTheme.defaultColor ?? colors.brand;

    Widget iconWidget = Icon(
      widget.icon,
      size: iconSize,
      color: iconColor,
      semanticLabel: widget.semanticLabel,
    );

    // 静态旋转和镜像
    if (widget.rotate != null || widget.mirror) {
      iconWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ((widget.rotate ?? 0) * 3.14159265 / 180)
          ..scale(widget.mirror ? -1.0 : 1.0, 1.0),
        child: iconWidget,
      );
    }

    // 旋转动画
    if (widget.spin && _spinController != null) {
      iconWidget = RotationTransition(
        turns: _spinController!,
        child: iconWidget,
      );
    }

    // 容器背景
    if (widget.container != ParkIconContainer.none) {
      final padding = widget.containerPadding ?? (iconSize * 0.5);
      final bg = widget.containerColor ?? colors.brand.withValues(alpha: 0.1);
      final br = widget.container == ParkIconContainer.circle
          ? park.radius.brFull
          : park.radius.brMd;

      iconWidget = Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: br,
        ),
        child: iconWidget,
      );
    }

    // 角标叠加（badge 数字或 badgeDot 红点）
    if (widget.badgeDot || widget.badge != null) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            top: -4,
            right: -4,
            child: widget.badgeDot
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: park.spacing.xs, vertical: 0),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: park.radius.brFull,
                    ),
                    alignment: Alignment.center,
                    child: Builder(
                      builder: (_) {
                        final badgeValue = widget.badge ?? 0;
                        final badgeText = badgeValue > 99 ? '99+' : '$badgeValue';
                        return Text(
                          badgeText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textOnBrand,
                            fontSize: 10,
                            fontWeight: park.typography.weightMedium,
                            height: 1.2,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    }

    // 点击交互
    if (widget.onClick != null || widget.onLongPress != null) {
      // 悬停颜色效果
      if (widget.hoverColor != null && _isHovered) {
        iconWidget = ColorFiltered(
          colorFilter: ColorFilter.mode(widget.hoverColor!, BlendMode.srcIn),
          child: iconWidget,
        );
      }

      iconWidget = Semantics(
        button: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onClick,
            onLongPress: widget.onLongPress,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onClick,
                onLongPress: widget.onLongPress,
                borderRadius: widget.container == ParkIconContainer.circle
                    ? park.radius.brFull
                    : park.radius.brMd,
                child: iconWidget,
              ),
            ),
          ),
        ),
      );
    }

    // Tooltip 包裹
    if (widget.tooltip != null) {
      iconWidget = Tooltip(
        message: widget.tooltip!,
        child: iconWidget,
      );
    }

    // Non-interactive icons: provide semantic label for screen readers
    if (widget.semanticLabel != null &&
        widget.onClick == null &&
        widget.onLongPress == null) {
      iconWidget = Semantics(
        label: widget.semanticLabel,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
