import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

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

  /// 图标尺寸（默认 24）。
  final double iconSize;

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
    this.iconSize = 24,
    this.type = ParkBottomNavType.fixed,
    this.backgroundColor,
    this.elevation = 0,
  }) : assert(items.length >= 2 && items.length <= 5,
            'ParkBottomNav requires 2 to 5 items');

  /// 计算满足 WCAG AA（4.5:1）对比度要求的 Badge 背景色。
  ///
  /// 亮色主题 [error] (#DF1B41) 对白色文字对比度约 4.56:1，刚好达标。
  /// 暗色主题 [error] (#F25767) 对白色文字对比度仅约 3.3:1，不达标，
  /// 需加深至 #D41540（对比度约 4.6:1）。
  Color _badgeBackgroundColor(Color error, bool isDark) {
    if (isDark) {
      return const Color(0xFFD41540);
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;

    final effectiveBg = backgroundColor ?? colors.surface;
    final effectiveSelectedColor = selectedItemColor ?? colors.brand;
    final effectiveUnselectedColor =
        unselectedItemColor ?? colors.textSecondary;

    // 判断是否为暗色主题，用于 Badge 对比度修正
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = _badgeBackgroundColor(colors.error, isDark);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBg,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ]
            : null,
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
        selectedFontSize: selectedFontSize ?? 12,
        unselectedFontSize: unselectedFontSize ?? 12,
        iconSize: iconSize,
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
  }
}
