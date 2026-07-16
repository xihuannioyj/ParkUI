import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// ParkFloatButton 悬浮位置
enum ParkFloatButtonPosition {
  /// 右下角
  bottomRight,

  /// 左下角
  bottomLeft,
}

/// ParkFloatButton 类型
enum ParkFloatButtonType {
  /// 主要 — 品牌色背景
  primary,

  /// 默认 — 白底 + 灰色图标
  defaultType,
}

/// ParkFloatButton 尺寸
enum ParkFloatButtonSize {
  /// 小尺寸 — 40px
  small,

  /// 默认尺寸 — 56px
  normal,
}

/// ParkFloatButton 形状
enum ParkFloatButtonShape {
  /// 圆形
  circle,

  /// 圆角方形
  rounded,
}

/// ParkFloatButton 菜单项数据模型
///
/// 用于 [ParkFloatButton.items] 列表，每个菜单项可配置图标、文字、点击回调。
class ParkFloatButtonItem {
  /// 菜单项图标。
  final IconData? icon;

  /// 菜单项文字标签。
  final String? label;

  /// 菜单项点击回调。
  final VoidCallback? onPressed;

  /// 是否禁用。
  final bool disabled;

  /// 工具提示文字。
  final String? tooltip;

  const ParkFloatButtonItem({
    this.icon,
    this.label,
    this.onPressed,
    this.disabled = false,
    this.tooltip,
  });
}

/// ParkFloatButton — 悬浮操作按钮
///
/// 对标 Ant Design FloatButton，悬浮在页面上的操作按钮。
/// 支持单个按钮模式和菜单模式（传入 [items] 列表）。
///
/// ```dart
/// // 单按钮模式
/// ParkFloatButton(
///   icon: Icons.add,
///   onPressed: () {},
/// )
///
/// // 菜单模式
/// ParkFloatButton(
///   icon: Icons.more_horiz,
///   items: [
///     ParkFloatButtonItem(icon: Icons.edit, label: '编辑', onPressed: () {}),
///     ParkFloatButtonItem(icon: Icons.delete, label: '删除', onPressed: () {}),
///   ],
/// )
/// ```
class ParkFloatButton extends StatefulWidget {
  /// 按钮图标。
  final IconData? icon;

  /// 按钮文字标签（仅在 [ParkFloatButtonShape.rounded] 时显示）。
  final String? label;

  /// 按钮点击回调（单按钮模式）。
  final VoidCallback? onPressed;

  /// 菜单项列表（传入后进入菜单模式）。
  final List<ParkFloatButtonItem>? items;

  /// 悬浮位置。
  final ParkFloatButtonPosition position;

  /// 按钮尺寸。
  final ParkFloatButtonSize size;

  /// 按钮类型（primary / default）。
  final ParkFloatButtonType type;

  /// 按钮形状（circle / rounded）。
  final ParkFloatButtonShape shape;

  /// 工具提示文字。
  final String? tooltip;

  /// 角标数字。
  final int? badge;

  /// 是否显示红点角标（优先于 [badge]）。
  final bool badgeDot;

  /// 距底部偏移量。
  final double? bottom;

  /// 距侧边偏移量。
  final double? side;

  /// 自定义背景色。
  final Color? backgroundColor;

  /// 自定义图标色。
  final Color? iconColor;

  const ParkFloatButton({
    super.key,
    this.icon,
    this.label,
    this.onPressed,
    this.items,
    this.position = ParkFloatButtonPosition.bottomRight,
    this.size = ParkFloatButtonSize.normal,
    this.type = ParkFloatButtonType.defaultType,
    this.shape = ParkFloatButtonShape.circle,
    this.tooltip,
    this.badge,
    this.badgeDot = false,
    this.bottom,
    this.side,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<ParkFloatButton> createState() => _ParkFloatButtonState();
}

class _ParkFloatButtonState extends State<ParkFloatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  bool _isMenuOpen = false;

  bool get _isMenuMode => widget.items != null && widget.items!.isNotEmpty;

  double get _buttonSize =>
      widget.size == ParkFloatButtonSize.small ? 40.0 : 56.0;

  double get _menuButtonSize =>
      widget.size == ParkFloatButtonSize.small ? 32.0 : 40.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (!_isMenuMode) return;
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _closeMenu() {
    if (!_isMenuMode || !_isMenuOpen) return;
    setState(() {
      _isMenuOpen = false;
      _animController.reverse();
    });
  }

  Color _resolveBgColor(ParkThemeData park) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    final colors = park.colors;
    switch (widget.type) {
      case ParkFloatButtonType.primary:
        return colors.brand;
      case ParkFloatButtonType.defaultType:
        return colors.surface;
    }
  }

  Color _resolveIconColor(ParkThemeData park) {
    if (widget.iconColor != null) return widget.iconColor!;
    final colors = park.colors;
    switch (widget.type) {
      case ParkFloatButtonType.primary:
        return colors.textOnBrand;
      case ParkFloatButtonType.defaultType:
        return colors.textSecondary;
    }
  }

  Color _resolveMenuBgColor(ParkThemeData park) {
    return park.colors.surface;
  }

  Color _resolveMenuIconColor(ParkThemeData park) {
    return park.colors.textSecondary;
  }

  Widget _buildSingleButton(ParkThemeData park, {bool isTrigger = false}) {
    final bgColor = isTrigger ? _resolveBgColor(park) : _resolveMenuBgColor(park);
    final iColor = isTrigger ? _resolveIconColor(park) : _resolveMenuIconColor(park);
    final currentSize = isTrigger ? _buttonSize : _menuButtonSize;
    final borderRadius = widget.shape == ParkFloatButtonShape.circle
        ? BorderRadius.circular(currentSize / 2)
        : BorderRadius.circular(park.radius.md);

    final content = Container(
      width: currentSize,
      height: currentSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _isMenuOpen && isTrigger ? Icons.close : widget.icon,
        color: iColor,
        size: isTrigger
            ? (widget.size == ParkFloatButtonSize.small ? 18 : 22)
            : (widget.size == ParkFloatButtonSize.small ? 16 : 18),
      ),
    );

    // Wrap with badge if needed.
    Widget result = content;
    if (isTrigger && (widget.badge != null || widget.badgeDot)) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: widget.badgeDot
                  ? null
                  : const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: widget.badgeDot
                  ? const BoxConstraints(minWidth: 8, minHeight: 8)
                  : const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D4F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: widget.badgeDot
                  ? null
                  : Text(
                      '${widget.badge! > 99 ? 99 : widget.badge!}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ],
      );
    }

    // Wrap with tooltip.
    if (widget.tooltip != null && isTrigger) {
      result = Tooltip(message: widget.tooltip!, child: result);
    }

    return result;
  }

  Widget _buildMenuItem(ParkFloatButtonItem item, ParkThemeData park) {
    final bgColor = _resolveMenuBgColor(park);
    final iColor = item.disabled
        ? park.colors.textDisabled
        : _resolveMenuIconColor(park);
    final borderRadius = widget.shape == ParkFloatButtonShape.circle
        ? BorderRadius.circular(_menuButtonSize / 2)
        : BorderRadius.circular(park.radius.md);

    Widget button = Container(
      width: _menuButtonSize,
      height: _menuButtonSize,
      decoration: BoxDecoration(
        color: item.disabled ? bgColor.withValues(alpha: 0.5) : bgColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        item.icon,
        color: iColor,
        size: widget.size == ParkFloatButtonSize.small ? 16 : 18,
      ),
    );

    // Wrap with label tooltip.
    if (item.label != null) {
      button = Tooltip(message: item.label!, child: button);
    } else if (item.tooltip != null) {
      button = Tooltip(message: item.tooltip!, child: button);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.disabled
            ? null
            : () {
                item.onPressed?.call();
                _closeMenu();
              },
        borderRadius: borderRadius,
        child: button,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ??
        ParkThemeData.light();

    final bottomOffset = widget.bottom ?? 24.0;
    final sideOffset = widget.side ?? 24.0;

    final isRight = widget.position == ParkFloatButtonPosition.bottomRight;

    if (!_isMenuMode) {
      // Single button mode.
      return Positioned(
        bottom: bottomOffset,
        right: isRight ? sideOffset : null,
        left: isRight ? null : sideOffset,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: widget.shape == ParkFloatButtonShape.circle
                ? BorderRadius.circular(_buttonSize / 2)
                : BorderRadius.circular(park.radius.md),
            child: _buildSingleButton(park, isTrigger: true),
          ),
        ),
      );
    }

    // Menu mode: main trigger + expandable items.
    return Positioned(
      bottom: bottomOffset,
      right: isRight ? sideOffset : null,
      left: isRight ? null : sideOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Menu items (expand upward).
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (BuildContext context, Widget? child) {
              final items = widget.items!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(items.length, (index) {
                  // Reverse order so first item is on top.
                  final reverseIndex = items.length - 1 - index;
                  final item = items[reverseIndex];
                  final itemOffset = (index + 1) * (_menuButtonSize + 12.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        (1 - _expandAnimation.value) * itemOffset,
                      ),
                      child: Opacity(
                        opacity: _expandAnimation.value,
                        child: _buildMenuItem(item, park),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          // Trigger button.
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleMenu,
              borderRadius: widget.shape == ParkFloatButtonShape.circle
                  ? BorderRadius.circular(_buttonSize / 2)
                  : BorderRadius.circular(park.radius.md),
              child: _buildSingleButton(park, isTrigger: true),
            ),
          ),
        ],
      ),
    );
  }
}
