import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../../theme/tokens/park_colors.dart';
import '../base/park_surface.dart';

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

/// Park 底部导航栏尺寸
enum ParkTabBarSize {
  /// 小尺寸（更矮的栏高、小图标、小字号）
  small,

  /// 默认尺寸
  medium,

  /// 大尺寸（更高的栏高、大图标、大字号）
  large,
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
/// 底部标签栏表面材质的派生结果。
@immutable
class ParkTabBarSurface {
  /// 容器填充色。
  final Color fill;

  /// 容器圆角（保留组件原值：悬浮式 brLg / 贴底式 zero）。
  final BorderRadius radius;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 顶部分割线颜色；null 表示不画。
  final Color? dividerColor;

  /// 选中项颜色 —— **恒为 [ParkColors.brand]**，不随表面风格变化。
  final Color selectedColor;

  /// 未选中项颜色（来自表面令牌的 bodyColor）。
  final Color unselectedColor;

  /// 是否需要背景模糊采样（glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  const ParkTabBarSurface({
    required this.fill,
    required this.radius,
    required this.shadows,
    required this.dividerColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.useBlur,
    required this.blurSigma,
  });
}

/// 贴底式标签栏改造前的 elevation 阴影（浮层兜底 floor）。
///
/// 组件原本按 `elevation` 现算一条阴影（textPrimary 8% / blur=elevation /
/// offset=(0, -elevation*0.25)），并非 `park.shadows.*`。
List<BoxShadow> _tabBarElevationShadow(ParkThemeData park, double elevation) {
  return <BoxShadow>[
    BoxShadow(
      color: park.colors.textPrimary.withValues(alpha: 0.08),
      blurRadius: elevation,
      offset: Offset(0, -(elevation * 0.25)),
    ),
  ];
}

/// 标签栏顶部分割线颜色（与 ParkNavBar 同一策略）。
///
/// 原实现固定用 `colors.divider`（亮色板 navy 7.8% / 暗色板 白 10%）。
/// 在 **neon + 深色** 下会失效：此时 fill 翻转为 `colors.textPrimary`
/// （暗色板纯白），而暗色板 divider 是"白 10%" —— 白线压白底不可见。
/// 因此原色可分辨时沿用原色（stripe / flat 观感零回归），
/// 不可分辨时才回落到表面文字色的低透明度版本。
///
/// ⚠️ `ParkColors.contrastRatio` 只读 r/g/b、**忽略 alpha**，必须先 alpha
/// 合成到不透明底再比。
Color _tabBarDividerColor({
  required ParkThemeData park,
  required Color fill,
  required Color fallback,
}) {
  final Color opaqueFill = Color.alphaBlend(fill, park.colors.background);
  final Color composited = Color.alphaBlend(park.colors.divider, opaqueFill);
  if (ParkColors.contrastRatio(composited, opaqueFill) > 1.02) {
    return park.colors.divider;
  }
  return fallback.withValues(alpha: 0.35);
}

/// 解析底部标签栏的表面材质（浮层规范在 TabBar 上的实现）。
///
/// 五条浮层规范：
/// 1. **阴影**：`tokens.shadows ?? 组件原值` —— 贴底式按 `elevation` 旋钮
///    （`elevation == 0` 即"不要阴影"），悬浮式兜底到 `park.shadows.md`。
/// 2. **圆角**：保留组件原值（悬浮 `brLg` / 贴底 `zero`），
///    **不**消费 `tokens.radius`（卡片语义 brMd）。
/// 3. **边框**：尊重组件原有的 `bordered` 语义 —— 顶部 0.5px 分割线，
///    颜色做表面适配；悬浮式不画分割线。
/// 4. **文字色**：未选中项走 `tokens.bodyColor`（理由同 [ParkBottomNav]）。
/// 5. **特殊形态**：[ParkTabBarType.floating] 作为**独立分支**整条 return
///    —— 它同时决定圆角 / 阴影 / 分割线三件事，塞进通用路径会出现
///    "圆角了但仍贴底"的撕裂态。
///
/// ## 🔴 B 组红线
///
/// 选中态颜色恒为 [ParkColors.brand]，绝不可随 `surfaceStyle` 变化。
/// 本组件的选中指示就是"选中项颜色本身"（没有独立的高亮条 / 滑块），
/// 因此指示器材质同样恒为 brand —— 这是最保守的选择。
@visibleForTesting
ParkTabBarSurface resolveParkTabBarSurface({
  required ParkThemeData park,
  required BuildContext context,
  required ParkTabBarType type,
  bool fixed = true,
  double elevation = 8.0,
  bool bordered = true,
}) {
  // 标签栏的边框是"顶部分割线"而非表面 outline，故 bordered: false，
  // 分割线由 _tabBarDividerColor 单独处理。
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  final Color selectedColor = park.colors.brand;
  final Color unselectedColor = tokens.bodyColor;

  // 🔴 悬浮式是独立分支：圆角 + 阴影 + 无分割线三件事整条处理。
  if (type == ParkTabBarType.floating) {
    return ParkTabBarSurface(
      fill: tokens.fill,
      radius: park.radius.brLg,
      shadows: ParkSurfaceTokens.overlayShadows(
        tokens: tokens,
        floor: park.shadows.md,
      ),
      dividerColor: null,
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
      useBlur: tokens.useBackdropFilter,
      blurSigma: tokens.glassBlur,
    );
  }

  return ParkTabBarSurface(
    fill: tokens.fill,
    radius: BorderRadius.zero,
    shadows: (fixed && elevation > 0)
        ? ParkSurfaceTokens.overlayShadows(
            tokens: tokens,
            floor: _tabBarElevationShadow(park, elevation),
          )
        : null,
    dividerColor: bordered
        ? _tabBarDividerColor(
            park: park,
            fill: tokens.fill,
            fallback: tokens.titleColor,
          )
        : null,
    selectedColor: selectedColor,
    unselectedColor: unselectedColor,
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
  );
}

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

  /// 导航栏尺寸（small / medium / large），控制栏高、字号与图标大小。
  final ParkTabBarSize size;

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
    this.size = ParkTabBarSize.medium,
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
    final isFloating = widget.type == ParkTabBarType.floating;
    final selectedIndex = _effectiveIndex;

    // size 令牌：小/中/大 三档栏高、字号与图标大小
    final double barHeight = switch (widget.size) {
      ParkTabBarSize.small => 48.0,
      ParkTabBarSize.medium => 56.0,
      ParkTabBarSize.large => 64.0,
    };
    final double iconSize = switch (widget.size) {
      ParkTabBarSize.small => 20.0,
      ParkTabBarSize.medium => 24.0,
      ParkTabBarSize.large => 28.0,
    };
    final double labelFontSize = switch (widget.size) {
      ParkTabBarSize.small => 10.0,
      ParkTabBarSize.medium => park.typography.sizeOverline,
      ParkTabBarSize.large => park.typography.sizeBody,
    };
    // 悬浮式导航栏外层内边距
    final EdgeInsets floatingPadding = switch (widget.size) {
      ParkTabBarSize.small => EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.xs,
        ),
      ParkTabBarSize.medium => EdgeInsets.symmetric(
          horizontal: park.spacing.base,
          vertical: park.spacing.sm,
        ),
      ParkTabBarSize.large => EdgeInsets.symmetric(
          horizontal: park.spacing.lg,
          vertical: park.spacing.md,
        ),
    };

    // 表面材质走派生层：局部 ParkSurfaceStyleScope 覆盖自动生效。
    final ParkTabBarSurface surface = resolveParkTabBarSurface(
      park: park,
      context: context,
      type: widget.type,
      fixed: widget.fixed,
      elevation: widget.elevation,
      bordered: widget.bordered,
    );

    Widget content = Container(
      height: barHeight,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: surface.fill,
        // 圆角保留组件原值（悬浮 brLg / 贴底 zero），不消费 tokens.radius。
        borderRadius: surface.radius,
        // 分割线：保留组件原有几何（仅顶边 0.5px），颜色做表面适配。
        border: surface.dividerColor != null
            ? Border(top: BorderSide(color: surface.dividerColor!, width: 0.5))
            : null,
        boxShadow: surface.shadows,
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
                  iconSize: iconSize,
                  labelFontSize: labelFontSize,
                  activeColor: surface.selectedColor,
                  inactiveColor: surface.unselectedColor,
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

    // glass 风格：叠加 BackdropFilter 采样背后内容。
    //
    // 🔴 这里**刻意不包 ClipRRect**：Stack 用了 `clipBehavior: Clip.none`
    // 让 [ParkTabBar.centerAction]（凸起 FAB，top: -16）能够溢出容器边界，
    // 一旦裁剪就会把 FAB 切掉。悬浮式的圆角由 Container 自己的
    // `borderRadius` 负责，不需要额外裁剪。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: surface.blurSigma,
          sigmaY: surface.blurSigma,
        ),
        child: content,
      );
    }

    // fixed=false 时不包裹 SafeArea
    if (!widget.fixed) {
      if (!isFloating) return content;
      return Padding(
        padding: floatingPadding,
        child: content,
      );
    }

    if (!widget.useSafeArea) {
      if (!isFloating) return content;
      return Padding(
        padding: floatingPadding,
        child: content,
      );
    }

    if (isFloating) {
      return SafeArea(
        top: false,
        left: false,
        right: false,
        minimum: floatingPadding,
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
    required double iconSize,
    required double labelFontSize,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final colors = park.colors;
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
                  Icon(iconData, size: iconSize, color: color),
                  SizedBox(height: park.spacing.xxs),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: color,
                      fontSize: labelFontSize,
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
                        fontSize: park.typography.sizeOverline,
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
