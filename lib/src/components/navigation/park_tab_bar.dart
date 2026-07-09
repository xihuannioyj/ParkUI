import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// Park 底部导航栏类型
enum ParkTabBarType {
  /// 固定式 — 贴底，有顶部边线
  fixed,

  /// 悬浮式 — 圆角卡片悬浮于底部，带阴影
  floating,
}

/// Park 底部导航栏形状
enum ParkTabBarShape {
  /// 默认（无额外形状）
  normal,

  /// 圆角
  round,

  /// 内凹（中间凹陷）
  notch,
}

/// Park 底部导航项数据
class ParkTabBarItem {
  /// 默认图标
  final IconData icon;

  /// 选中态图标（为空时使用 [icon]）
  final IconData? activeIcon;

  /// 标签文字
  final String label;

  /// 可选角标
  final String? badge;

  /// 是否显示小红点（替代文字角标）
  final bool dotIndicator;

  const ParkTabBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.dotIndicator = false,
  });
}

/// Park 底部导航栏
///
/// 用于 App 底部 Tab 切换导航，支持固定与悬浮两种风格。
/// 选中项显示品牌色，未选中为灰色。
///
/// ```dart
/// ParkTabBar(
///   items: [
///     ParkTabBarItem(icon: Icons.home, label: '首页'),
///     ParkTabBarItem(icon: Icons.search, label: '发现'),
///     ParkTabBarItem(icon: Icons.person, label: '我的'),
///   ],
///   currentIndex: 0,
///   onTap: (index) => setState(() => _index = index),
/// )
/// ```
class ParkTabBar extends StatefulWidget {
  /// 导航项列表
  final List<ParkTabBarItem> items;

  /// 当前受控选中索引
  ///
  /// 为空时组件内部自行维护选中状态；
  /// 不为空时由外部控制选中项。
  final int? currentIndex;

  /// 非受控模式下的初始索引
  final int initialIndex;

  /// 点击回调
  final ValueChanged<int>? onTap;

  /// 导航栏类型
  final ParkTabBarType type;

  /// 是否自动为底部留出安全区域
  final bool useSafeArea;

  /// 是否固定在屏幕底部。
  ///
  /// 为 true 时 tab bar 始终贴底并自动处理安全区域；
  /// 为 false 时组件作为普通布局元素，不占用安全区域。
  final bool fixed;

  /// 导航栏上方的阴影高度（像素）。
  ///
  /// 仅在 [fixed] 为 true 且非悬浮模式时生效。默认 8。
  final double elevation;

  /// 是否显示顶部分割线。
  ///
  /// 仅在非悬浮模式下生效。默认 true。
  final bool bordered;

  /// 中心凸起按钮（FAB），显示在底部导航栏中央
  final Widget? centerAction;

  /// 导航栏形状变体
  final ParkTabBarShape shape;

  /// 绑定键（点号分隔的路径，如 `'selectedTabBarIndex'`）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  const ParkTabBar({
    super.key,
    required this.items,
    this.currentIndex,
    this.initialIndex = 0,
    this.onTap,
    this.type = ParkTabBarType.fixed,
    this.useSafeArea = true,
    this.fixed = true,
    this.elevation = 8,
    this.bordered = true,
    this.centerAction,
    this.shape = ParkTabBarShape.normal,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkTabBar> createState() => _ParkTabBarState();
}

class _ParkTabBarState extends State<ParkTabBar>
    with BindableWidgetMixin<int, ParkTabBar> {
  late int _currentIndex;

  bool get _isControlled => widget.currentIndex != null;

  int _normalizeIndex(int index) {
    if (widget.items.isEmpty) return 0;
    return index.clamp(0, widget.items.length - 1);
  }

  int get _effectiveIndex {
    if (_isControlled) {
      return _normalizeIndex(widget.currentIndex!);
    }
    return _normalizeIndex(_currentIndex);
  }

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    final initialValue = boundValue;
    _currentIndex =
        _normalizeIndex(initialValue ?? widget.currentIndex ?? widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant ParkTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isControlled) {
      _currentIndex = _normalizeIndex(widget.currentIndex!);
      return;
    }

    if (oldWidget.items.length != widget.items.length) {
      _currentIndex = _normalizeIndex(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final isFloating = widget.type == ParkTabBarType.floating;
    final selectedIndex = _effectiveIndex;

    const barHeight = 56.0;

    final content = Container(
      height: barHeight,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: isFloating ? park.radius.brLg : BorderRadius.zero,
        border: isFloating
            ? null
            : (widget.bordered
                ? Border(top: BorderSide(color: colors.divider, width: 0.5))
                : null),
        boxShadow: isFloating
            ? park.shadows.md
            : (widget.fixed && widget.elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: widget.elevation,
                      offset: Offset(0, -(widget.elevation * 0.25)),
                    ),
                  ]
                : null),
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            children: List.generate(widget.items.length, (index) {
              return Expanded(
                child: _buildItem(
                  item: widget.items[index],
                  isSelected: index == selectedIndex,
                  index: index,
                  park: park,
                ),
              );
            }),
          ),
          if (widget.centerAction != null)
            Positioned(
              top: -16,
              child: widget.centerAction!,
            ),
        ],
      ),
    );

    // fixed=false 时不包裹 SafeArea
    if (!widget.fixed) {
      if (!isFloating) return content;
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        child: content,
      );
    }

    if (!widget.useSafeArea) {
      if (!isFloating) return content;
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        child: content,
      );
    }

    if (isFloating) {
      return SafeArea(
        top: false,
        left: false,
        right: false,
        minimum: EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
        child: content,
      );
    }

    return SafeArea(top: false, left: false, right: false, child: content);
  }

  Widget _buildItem({
    required ParkTabBarItem item,
    required bool isSelected,
    required int index,
    required ParkThemeData park,
  }) {
    final colors = park.colors;
    final activeColor = colors.brand;
    final inactiveColor = colors.textSecondary;
    final color = isSelected ? activeColor : inactiveColor;
    final iconData = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isControlled) {
            setState(() {
              _currentIndex = index;
            });
          }
          widget.onTap?.call(index);
          boundValue = index;
        },
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, size: 24, color: color),
                  SizedBox(height: park.spacing.xxs),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: color,
                      fontSize: park.typography.sizeOverline,
                      fontWeight: isSelected
                          ? park.typography.weightMedium
                          : park.typography.weightRegular,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (item.dotIndicator)
              Positioned(
                top: 4,
                right: 0,
                left: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            else if (item.badge != null)
              Positioned(
                top: 4,
                right: 0,
                left: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error,
                      borderRadius: park.radius.brFull,
                    ),
                    child: Text(
                      item.badge!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textOnBrand,
                        fontSize: 10,
                        fontWeight: park.typography.weightMedium,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
