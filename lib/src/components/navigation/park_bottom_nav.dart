import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../theme/park_surface_style_scope.dart';
import '../../theme/park_surface_tokens.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_surface.dart';

/// Park 底部导航项数据模型。
class ParkBottomNavItem {
  /// 图标。
  final Widget icon;

  /// 选中态图标（可选，不设时复用 [icon]）。
  final Widget? activeIcon;

  /// 标签文字。
  final String label;

  /// 角标（数字或红点，可选）。
  final String? badge;

  const ParkBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// Park 底部导航类型。
enum ParkBottomNavType {
  /// 固定类型：所有项始终显示图标+文字。
  fixed,

  /// 移动类型：选中项展开，未选中只显示图标。
  shifting,
}

/// Park 底部导航尺寸。
enum ParkBottomNavSize {
  /// 小尺寸（图标 20，字号 10）
  small,

  /// 默认尺寸（图标 24，字号 12）
  medium,

  /// 大尺寸（图标 28，字号 14）
  large,
}

/// Park 底部导航栏。
///
/// 对齐 Flutter 原生 [BottomNavigationBar]，使用 park_ui 主题令牌。
/// 可通过 [Scaffold.bottomNavigationBar] 直接嵌入。
///
/// ```dart
/// Scaffold(
///   bottomNavigationBar: ParkBottomNav(
///     currentIndex: _currentIndex,
///     onTap: (index) => setState(() => _currentIndex = index),
///     items: [
///       ParkBottomNavItem(icon: Icon(Icons.home), label: '首页'),
///       ParkBottomNavItem(icon: Icon(Icons.search), label: '搜索'),
///       ParkBottomNavItem(icon: Icon(Icons.person), label: '我的'),
///     ],
///   ),
///   body: pages[_currentIndex],
/// )
/// ```
/// 底部导航栏表面材质的派生结果。
@immutable
class ParkBottomNavSurface {
  /// 容器填充色。
  final Color fill;

  /// 阴影；null 表示无阴影。
  final List<BoxShadow>? shadows;

  /// 选中项颜色 —— **恒为 [ParkColors.brand]**，不随表面风格变化。
  final Color selectedColor;

  /// 未选中项颜色（来自表面令牌的 bodyColor）。
  final Color unselectedColor;

  /// 是否需要背景模糊采样（glass 风格）。
  final bool useBlur;

  /// 模糊 sigma。
  final double blurSigma;

  const ParkBottomNavSurface({
    required this.fill,
    required this.shadows,
    required this.selectedColor,
    required this.unselectedColor,
    required this.useBlur,
    required this.blurSigma,
  });
}

/// 底部导航栏改造前的 elevation 阴影（浮层兜底 floor）。
///
/// 组件原本按 `elevation > 0` 画一条固定阴影（textPrimary 8% /
/// blur 20 / offset (0,-5)），并非 `park.shadows.*`。
List<BoxShadow> _bottomNavElevationShadow(ParkThemeData park) {
  return <BoxShadow>[
    BoxShadow(
      color: park.colors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, -5),
    ),
  ];
}

/// 解析底部导航栏的表面材质（浮层规范在 BottomNav 上的实现）。
///
/// 五条浮层规范：
/// 1. **阴影**：`tokens.shadows ?? 组件原值`（[_bottomNavElevationShadow]）——
///    但底部导航**不是**"恒定抬起"的浮层，它有显式的 `elevation` 旋钮，
///    `elevation == 0` 就是"不要阴影"，此时即便 glass / neo / neon 也不
///    凭空投影（否则全站底栏突然全部投影，非零回归）。
/// 2. **圆角**：底栏贴边满宽，无圆角，本组件不涉及。
/// 3. **边框**：原实现无描边，故 `bordered: false`。
/// 4. **文字色**：未选中项走 `tokens.bodyColor`。
/// 5. **特殊形态**：本组件无全屏形态；`shifting` 类型的指示器由 Flutter
///    原生 [BottomNavigationBar] 渲染，材质跟随选中色，不单独接管。
///
/// ## 🔴 B 组红线：选中态颜色恒为 brand
///
/// 导航组件的**选中态颜色使用 [ParkColors.brand]，绝不可随 `surfaceStyle`
/// 变化** —— 这是为了"导航栏在任何主题下都可辨识"。
/// 允许随样式变化的只有**指示器材质**，而本组件的指示器由原生
/// [BottomNavigationBar] 渲染（它用选中色画 shifting 背景），
/// 因此不单独接管，等于让指示器也保持 brand —— 是更保守的选择。
///
/// ## ⚠️ 未选中态为何仍走 tokens.bodyColor
///
/// 红线要求"未选中态同理"（不随样式漂移）。但 `colors.textSecondary`
/// 在 **neon + 深色** 下与容器 fill 只有 **2.00:1**：该风格 fill 翻转为
/// `colors.textPrimary`（暗色板下是纯白），而暗色板 textSecondary 是
/// `#ADB8C9`（浅 slate）—— 浅灰字压在白底上不可读。
///
/// 这与红线**自身的目的**（"保证导航栏在任何主题下都可辨识"）直接冲突。
/// 取舍如下：
/// - `tokens.bodyColor` 在 **stripe / flat / glass / neo** 下**字面等于**
///   `colors.textSecondary`，即 4/5 风格零漂移、观感零回归；
/// - 只有 neon + 深色这一格会变化，而变化正是为了避免 2.00:1 的缺陷。
/// 即：**漂移只发生在不漂移就不可读的那一格**。
@visibleForTesting
ParkBottomNavSurface resolveParkBottomNavSurface({
  required ParkThemeData park,
  required BuildContext context,
  double elevation = 0.0,
}) {
  // 底栏无描边语义。
  final ParkSurfaceTokens tokens = ParkSurfaceStyleScope.tokensOf(
    context,
    bordered: false,
  );

  return ParkBottomNavSurface(
    fill: tokens.fill,
    shadows: elevation > 0
        ? ParkSurfaceTokens.overlayShadows(
            tokens: tokens,
            floor: _bottomNavElevationShadow(park),
          )
        : null,
    selectedColor: park.colors.brand,
    unselectedColor: tokens.bodyColor,
    useBlur: tokens.useBackdropFilter,
    blurSigma: tokens.glassBlur,
  );
}

class ParkBottomNav extends StatelessWidget {
  /// 当前选中索引。
  final int currentIndex;

  /// 切换回调。
  final ValueChanged<int> onTap;

  /// 导航项列表（至少 2 项，最多 5 项）。
  final List<ParkBottomNavItem> items;

  /// 选中项颜色（默认品牌色）。
  final Color? selectedItemColor;

  /// 未选中项颜色（默认次要文字色）。
  final Color? unselectedItemColor;

  /// 选中项字号（默认与未选中一致）。
  final double? selectedFontSize;

  /// 未选中项字号。
  final double? unselectedFontSize;

  /// 图标尺寸（null 时由 [size] 预设决定）。
  final double? iconSize;

  /// 导航尺寸（small/medium/large），作为 iconSize/fontSize 的快捷预设；
  /// 显式传入的 iconSize/selectedFontSize/unselectedFontSize 优先。
  final ParkBottomNavSize size;

  /// 导航类型（默认 fixed）。
  final ParkBottomNavType type;

  /// 背景色（默认 surface）。
  final Color? backgroundColor;

  /// 阴影高度（0 = 无阴影）。
  final double elevation;

  const ParkBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedFontSize,
    this.unselectedFontSize,
    this.iconSize,
    this.size = ParkBottomNavSize.medium,
    this.type = ParkBottomNavType.fixed,
    this.backgroundColor,
    this.elevation = 0,
  }) : assert(items.length >= 2 && items.length <= 5,
            'ParkBottomNav requires 2 to 5 items');

  /// 计算 Badge 背景色，使用主题 error 令牌。
  Color _badgeBackgroundColor(Color error) {
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;

    // 表面材质走派生层：局部 ParkSurfaceStyleScope 覆盖自动生效。
    final ParkBottomNavSurface surface = resolveParkBottomNavSurface(
      park: park,
      context: context,
      elevation: elevation,
    );

    // backgroundColor / selectedItemColor / unselectedItemColor 是用户
    // 逃生舱，优先级高于派生结果。
    final Color effectiveBg = backgroundColor ?? surface.fill;
    final Color effectiveSelectedColor =
        selectedItemColor ?? surface.selectedColor;
    final Color effectiveUnselectedColor =
        unselectedItemColor ?? surface.unselectedColor;

    // size 预设：图标与字号（显式参数优先）
    final double presetIconSize = switch (size) {
      ParkBottomNavSize.small => 20.0,
      ParkBottomNavSize.medium => 24.0,
      ParkBottomNavSize.large => 28.0,
    };
    final double presetFontSize = switch (size) {
      ParkBottomNavSize.small => 10.0,
      ParkBottomNavSize.medium => 12.0,
      ParkBottomNavSize.large => 14.0,
    };

    // Badge 背景色使用主题 error 令牌。
    final badgeBg = _badgeBackgroundColor(colors.error);

    Widget bar = Container(
      decoration: BoxDecoration(
        color: effectiveBg,
        boxShadow: surface.shadows,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: type == ParkBottomNavType.fixed
            ? BottomNavigationBarType.fixed
            : BottomNavigationBarType.shifting,
        selectedItemColor: effectiveSelectedColor,
        unselectedItemColor: effectiveUnselectedColor,
        selectedFontSize: selectedFontSize ?? presetFontSize,
        unselectedFontSize: unselectedFontSize ?? presetFontSize,
        iconSize: iconSize ?? presetIconSize,
        selectedLabelStyle: TextStyle(
          fontWeight: park.typography.weightMedium,
        ),
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: item.badge != null
                ? Badge(
                    backgroundColor: badgeBg,
                    label: Text(
                      item.badge!,
                      style: TextStyle(
                        color: colors.textOnBrand,
                        fontSize: park.typography.sizeOverline,
                      ),
                    ),
                    child: item.icon,
                  )
                : item.icon,
            activeIcon: item.activeIcon != null
                ? (item.badge != null
                    ? Badge(
                        backgroundColor: badgeBg,
                        label: Text(
                          item.badge!,
                          style: TextStyle(
                            color: colors.textOnBrand,
                            fontSize: park.typography.sizeOverline,
                          ),
                        ),
                        child: item.activeIcon!,
                      )
                    : item.activeIcon)
                : null,
            label: item.label,
          );
        }).toList(),
      ),
    );

    // glass 风格：叠加 BackdropFilter 采样背后的页面内容。
    // 底栏贴边满宽、无圆角，无需 ClipRRect；嵌套降级统一由
    // ParkSurfaceBlurDepth 判定（必须是 `< 1` 而非 `<= 1`）。
    if (surface.useBlur &&
        ParkSurfaceBlurDepth.of(context) < 1 &&
        surface.blurSigma > 0) {
      bar = BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: surface.blurSigma,
          sigmaY: surface.blurSigma,
        ),
        child: bar,
      );
    }
    return bar;
  }
}
