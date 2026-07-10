import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_motion.dart';

/// ParkInkWell — 轻量级点击容器
///
/// 为任意 child Widget 添加 Park 主题一致的交互反馈：
/// - 按下时 scale 缩小 + opacity 降低
/// - 悬停时背景高亮
/// - 鼠标指针变为手型
/// - 可访问性语义
///
/// 与 [ParkButton] 的区别：
/// - [ParkButton] 是有样式的按钮（背景色/边框/loading/尺寸变体）
/// - [ParkInkWell] 是纯粹的交互容器（无附加样式），
///   适用于 Card、Cell、Tag、ListTile、Search、Tree 节点等场景。
///
/// ```dart
/// ParkInkWell(
///   onTap: () => print('tapped'),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('可点击卡片'),
///   ),
/// )
/// ```
class ParkInkWell extends StatefulWidget {
  /// 被包裹的可点击内容
  final Widget child;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 悬停状态变化回调
  final ValueChanged<bool>? onHover;

  /// 禁用状态（为 true 时无交互反馈）
  final bool disabled;

  /// 高亮/涟漪的圆角（默认 8）
  final BorderRadius? borderRadius;

  /// 按下时 scale 缩放比例（默认 0.97）
  final double pressedScale;

  /// 按下时 opacity 透明度（默认 0.85）
  final double pressedOpacity;

  /// 动画时长（默认 ParkMotion.quick = 100ms）
  final Duration duration;

  /// 鼠标指针样式（默认 click）
  final MouseCursor? cursor;

  /// 是否在鼠标悬停时显示品牌色背景高亮（默认 true）
  final bool showHoverHighlight;

  /// 动画曲线
  final Curve curve;

  const ParkInkWell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onHover,
    this.disabled = false,
    this.borderRadius,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.85,
    this.duration = ParkMotion.quick,
    this.cursor,
    this.showHoverHighlight = true,
    this.curve = Curves.easeInOut,
  });

  bool get _enabled => (onTap != null || onLongPress != null) && !disabled;

  @override
  State<ParkInkWell> createState() => _ParkInkWellState();
}

class _ParkInkWellState extends State<ParkInkWell> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget._enabled) {
      return widget.child;
    }

    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final br = widget.borderRadius ?? park.radius.brSm;

    return Semantics(
      button: true,
      enabled: true,
      child: MouseRegion(
        cursor: widget.cursor ?? SystemMouseCursors.click,
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
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedScale(
            scale: _isPressed ? widget.pressedScale : 1.0,
            duration: widget.duration,
            curve: widget.curve,
            child: AnimatedOpacity(
              opacity: _isPressed ? widget.pressedOpacity : 1.0,
              duration: widget.duration,
              child: Container(
                decoration: widget.showHoverHighlight && _isHovered
                    ? BoxDecoration(
                        color: park.colors.brand.withValues(alpha: 0.04),
                        borderRadius: br,
                      )
                    : null,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
