import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

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
  final bool light;

  /// 创建 [ParkMenu]。
  const ParkMenu({
    super.key,
    required this.items,
    this.onSelect,
    this.selectedKey,
    this.defaultExpandedKeys,
    this.light = false,
  });

  @override
  State<ParkMenu> createState() => _ParkMenuState();
}

class _ParkMenuState extends State<ParkMenu> {
  late Set<String> _expandedKeys;
  String? _selectedKey;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: widget.items.map((item) => _buildMenuItem(item, park, 0)).toList(),
    );
  }

  Widget _buildMenuItem(ParkMenuItem item, ParkThemeData park, int depth) {
    final isSelected = item.key == _selectedKey;
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isExpanded = _expandedKeys.contains(item.key);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 菜单项
        InkWell(
          onTap: () {
            if (hasChildren) {
              _toggleExpand(item.key);
            } else {
              _handleSelect(item.key);
            }
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 16.0 + depth * 16,
              right: 16,
              top: 10,
              bottom: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? park.colors.brand.withAlpha(26)
                  : Colors.transparent,
              border: isSelected
                  ? Border(left: BorderSide(color: park.colors.brand, width: 3))
                  : null,
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18,
                      color: isSelected ? park.colors.brand : park.colors.textSecondary),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? park.colors.brand : park.colors.textPrimary,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: park.colors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        // 子菜单
        if (hasChildren && isExpanded)
          ...item.children!.map((child) => _buildMenuItem(child, park, depth + 1)),
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
