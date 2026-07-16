import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 导航菜单主题模式。
enum ParkMenuThemeMode {
  /// 浅色模式
  light,

  /// 暗色模式
  dark,
}

/// 导航菜单布局模式。
enum ParkMenuMode {
  /// 垂直内联模式（子菜单展开在下方）
  inline,

  /// 垂直模式（与 [inline] 行为一致，为向后兼容保留）
  vertical,

  /// 水平模式
  horizontal,
}

/// 导航菜单组件
///
/// 支持多级展开、选中高亮、图标和分隔线。
/// 通过 [items] 声明式构建菜单树。
///
/// ```dart
/// ParkMenu(
///   items: [
///     ParkMenuItem(key: 'dashboard', label: '仪表盘', icon: Icons.dashboard),
///     ParkMenuItem(key: 'settings', label: '设置', icon: Icons.settings, children: [
///       ParkMenuItem(key: 'profile', label: '个人资料'),
///       ParkMenuItem(key: 'security', label: '安全设置'),
///     ]),
///   ],
///   onSelect: (key) => print('选中: $key'),
/// )
/// ```
class ParkMenu extends StatefulWidget {
  /// 菜单项列表。
  final List<ParkMenuItem> items;

  /// 选中回调。
  final void Function(String key)? onSelect;

  /// 当前选中项 key。
  final String? selectedKey;

  /// 默认展开的父菜单 key 列表。
  final Set<String>? defaultExpandedKeys;

  /// 是否为浅色模式（默认 false，使用暗色）。
  ///
  /// 已废弃，请使用 [themeMode] 代替。
  @Deprecated('Use themeMode instead')
  final bool light;

  /// 菜单主题模式。
  ///
  /// `light`：当前行为；`dark`：菜单背景深色、文字/图标白色，选中项高亮。
  final ParkMenuThemeMode themeMode;

  /// 是否为内联折叠模式。
  ///
  /// 为 true 时侧边菜单折叠为图标模式（只显示图标，隐藏文字），hover 展开。
  /// 仅当 [mode] 为 [ParkMenuMode.vertical] 或 [ParkMenuMode.inline] 时有效。
  final bool inlineCollapsed;

  /// 折叠模式下的菜单宽度。
  final double collapsedWidth;

  /// 菜单布局模式。
  final ParkMenuMode mode;

  /// 创建 [ParkMenu]。
  const ParkMenu({
    super.key,
    required this.items,
    this.onSelect,
    this.selectedKey,
    this.defaultExpandedKeys,
    @Deprecated('Use themeMode instead') this.light = false,
    this.themeMode = ParkMenuThemeMode.light,
    this.inlineCollapsed = false,
    this.collapsedWidth = 56.0,
    this.mode = ParkMenuMode.inline,
  });

  @override
  State<ParkMenu> createState() => _ParkMenuState();
}

class _ParkMenuState extends State<ParkMenu> {
  late Set<String> _expandedKeys;
  String? _selectedKey;
  final Set<String> _hoveredKeys = {};
  bool _primaryHovered = false;

  @override
  void initState() {
    super.initState();
    _expandedKeys = Set<String>.from(widget.defaultExpandedKeys ?? {});
    _selectedKey = widget.selectedKey;
  }

  @override
  void didUpdateWidget(ParkMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedKey != oldWidget.selectedKey) {
      _selectedKey = widget.selectedKey;
    }
  }

  void _handleSelect(String key) {
    setState(() => _selectedKey = key);
    widget.onSelect?.call(key);
  }

  void _toggleExpand(String key) {
    setState(() {
      if (_expandedKeys.contains(key)) {
        _expandedKeys.remove(key);
      } else {
        _expandedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    // light 已废弃，通过 themeMode 替代
    final resolvedThemeMode = widget.light ? ParkMenuThemeMode.light : widget.themeMode;
    final isDarkMode = resolvedThemeMode == ParkMenuThemeMode.dark;
    final isCollapsible = widget.inlineCollapsed &&
        (widget.mode == ParkMenuMode.vertical || widget.mode == ParkMenuMode.inline);

    return Semantics(
      label: 'Navigation menu',
      container: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _primaryHovered = true),
        onExit: (_) {
          if (isCollapsible) {
            setState(() {
              _primaryHovered = false;
              _hoveredKeys.clear();
            });
          }
        },
        child: Container(
          width: isCollapsible ? widget.collapsedWidth : null,
          color: isDarkMode ? park.colors.surface : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: widget.items
                .map((item) => _buildMenuItem(item, park, 0, collapsed: isCollapsible, dark: isDarkMode))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    ParkMenuItem item,
    ParkThemeData park,
    int depth, {
    required bool collapsed,
    required bool dark,
  }) {
    final isSelected = item.key == _selectedKey;
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isExpanded = _expandedKeys.contains(item.key);
    final isHovered = _hoveredKeys.contains(item.key);
    final showFull = !collapsed || isHovered || isSelected || isExpanded;

    // 暗色模式下颜色
    final Color textColor;
    final Color iconColor;
    final Color selectedBgColor;
    final Color expandIconColor;
    final Color disabledTextColor;

    if (dark) {
      textColor = park.colors.textOnBrand;
      iconColor = park.colors.textOnBrand;
      selectedBgColor = park.colors.brand.withAlpha(40);
      expandIconColor = park.colors.textOnBrand.withAlpha(180);
      disabledTextColor = park.colors.textDisabled;
    } else {
      textColor = isSelected ? park.colors.brand : park.colors.textPrimary;
      iconColor = isSelected ? park.colors.brand : park.colors.textSecondary;
      selectedBgColor = park.colors.brand.withAlpha(26);
      expandIconColor = park.colors.textSecondary;
      disabledTextColor = park.colors.textDisabled;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: item.label,
          selected: isSelected,
          enabled: !item.disabled,
          child: InkWell(
            onTap: item.disabled
                ? null
                : () {
                    if (hasChildren) {
                      _toggleExpand(item.key);
                    } else {
                      _handleSelect(item.key);
                    }
                  },
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoveredKeys.add(item.key)),
              onExit: (_) => setState(() => _hoveredKeys.remove(item.key)),
              child: Container(
                padding: EdgeInsets.only(
                  left: collapsed ? 16.0 : 16.0 + depth * 16,
                  right: 16,
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedBgColor
                      : Colors.transparent,
                  border: isSelected
                      ? Border(
                          left: BorderSide(
                            color: park.colors.brand,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 18,
                        color: item.disabled
                            ? disabledTextColor
                            : iconColor,
                      ),
                      if (showFull) const SizedBox(width: 10),
                    ],
                    if (showFull)
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: item.disabled
                                ? disabledTextColor
                                : textColor,
                          ),
                        ),
                      ),
                    if (showFull && hasChildren)
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: expandIconColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 子菜单
        if (hasChildren && isExpanded && showFull)
          ...item.children!
              .map((child) =>
                  _buildMenuItem(child, park, depth + 1, collapsed: collapsed, dark: dark)),
      ],
    );
  }
}

/// 菜单项数据模型。
class ParkMenuItem {
  /// 菜单项唯一标识。
  final String key;

  /// 显示标签。
  final String label;

  /// 前导图标。
  final IconData? icon;

  /// 子菜单项（支持递归嵌套）。
  final List<ParkMenuItem>? children;

  /// 是否禁用。
  final bool disabled;

  /// 创建 [ParkMenuItem]。
  const ParkMenuItem({
    required this.key,
    required this.label,
    this.icon,
    this.children,
    this.disabled = false,
  });
}
