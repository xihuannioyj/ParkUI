import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import '../../l10n/park_localizations.dart';

/// Park 侧边栏主题
enum ParkSideBarTheme {
  /// 亮色（默认）
  light,

  /// 暗色
  dark,
}

/// 子菜单项点击回调
typedef ParkSideBarChildChanged =
    void Function(int parentIndex, int childIndex);

/// Park 侧边栏菜单项
class ParkSideBarItem {
  /// 图标
  final IconData icon;

  /// 标签文字
  final String label;

  /// 可选角标
  final String? badge;

  /// 子菜单项（展开后显示）
  final List<ParkSideBarItem>? children;

  /// 折叠状态下显示的 tooltip 文案。
  ///
  /// 为 null 时使用 [label] 作为 tooltip。
  final String? tooltip;

  /// 是否禁用（灰色、不可交互）
  final bool disabled;

  /// 是否显示小红点（替代文字角标）
  final bool dotBadge;

  const ParkSideBarItem({
    required this.icon,
    required this.label,
    this.badge,
    this.children,
    this.tooltip,
    this.disabled = false,
    this.dotBadge = false,
  });
}

/// Park 侧边导航栏
///
/// 提供垂直排列的菜单项列表，选中项以品牌色高亮。
/// 支持折叠为仅图标模式，以及含子菜单的可展开项。
///
/// ```dart
/// ParkSideBar(
///   items: [
///     ParkSideBarItem(icon: Icons.dashboard, label: '仪表盘'),
///     ParkSideBarItem(icon: Icons.people, label: '用户管理', badge: '12'),
///     ParkSideBarItem(icon: Icons.settings, label: '设置', children: [
///       ParkSideBarItem(icon: Icons.person, label: '个人信息'),
///       ParkSideBarItem(icon: Icons.lock, label: '安全设置'),
///     ]),
///   ],
///   selectedIndex: 0,
///   onChanged: (index) => print('选中 $index'),
/// )
/// ```
class ParkSideBar extends StatefulWidget {
  /// 菜单项列表
  final List<ParkSideBarItem> items;

  /// 当前选中索引（顶层）
  final int selectedIndex;

  /// 选中回调（顶层索引）
  final ValueChanged<int>? onChanged;

  /// 当前选中的子菜单索引（仅当 [selectedIndex] 指向含子项的父菜单时生效）
  final int? selectedChildIndex;

  /// 子菜单选中回调
  final ParkSideBarChildChanged? onChildChanged;

  /// 是否折叠为图标模式
  final bool collapsed;

  /// 展开时宽度
  final double width;

  /// 折叠时宽度
  final double collapsedWidth;

  /// 品牌区域（显示在侧边栏顶部）
  final Widget? logo;

  /// 是否显示底部折叠按钮
  final bool showCollapseButton;

  /// 折叠按钮点击回调
  final VoidCallback? onCollapseToggle;

  /// 侧边栏主题（亮色/暗色）
  final ParkSideBarTheme theme;

  /// 折叠状态变化回调
  final ValueChanged<bool>? onCollapse;

  /// 顶部区域（logo 下方的自定义内容）
  final Widget? header;

  /// 底部区域（折叠按钮上方的自定义内容）
  final Widget? footer;

  /// 绑定键（点号分隔的路径，如 `'selectedSidebarItem'`）
  final String? bindKey;

  /// 绑定服务实例
  final ParkBindingService? bindingService;

  const ParkSideBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onChanged,
    this.selectedChildIndex,
    this.onChildChanged,
    this.collapsed = false,
    this.width = 200,
    this.collapsedWidth = 64,
    this.logo,
    this.showCollapseButton = false,
    this.onCollapseToggle,
    this.theme = ParkSideBarTheme.light,
    this.onCollapse,
    this.header,
    this.footer,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkSideBar> createState() => _ParkSideBarState();
}

class _ParkSideBarState extends State<ParkSideBar>
    with BindableWidgetMixin<int, ParkSideBar> {
  /// 记录哪些含子菜单的项处于展开状态
  final Set<int> _expandedIndexes = {};

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    _syncExpandedWithSelection();

    // 从 bindable 读取初始值
    final initialValue = boundValue;
    if (initialValue != null &&
        initialValue >= 0 &&
        initialValue < widget.items.length &&
        initialValue != widget.selectedIndex) {
      widget.onChanged?.call(initialValue);
    }
  }

  @override
  void didUpdateWidget(covariant ParkSideBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.selectedChildIndex != widget.selectedChildIndex ||
        oldWidget.collapsed != widget.collapsed ||
        oldWidget.items != widget.items) {
      _syncExpandedWithSelection();
    }
  }

  void _syncExpandedWithSelection() {
    if (widget.collapsed) {
      return;
    }

    final selectedIndex = widget.selectedIndex;
    if (selectedIndex < 0 || selectedIndex >= widget.items.length) {
      return;
    }

    final item = widget.items[selectedIndex];
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    if (!hasChildren) {
      return;
    }

    _expandedIndexes.add(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final l10n = ParkLocalizations.of(context);

    final currentWidth = widget.collapsed
        ? widget.collapsedWidth
        : widget.width;
    final resolvedWidth = currentWidth.clamp(0.0, double.infinity);

    final bool isDark = widget.theme == ParkSideBarTheme.dark;
    final bgColor = isDark ? colors.background : colors.surface;
    final borderColor = isDark ? colors.border : colors.divider;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: resolvedWidth,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(right: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Column(
        children: [
          // Logo area
          if (widget.logo != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.sm,
                vertical: park.spacing.md,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: widget.logo!,
            ),

          // Header area
          if (widget.header != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.sm,
                vertical: park.spacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: widget.header!,
            ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: park.spacing.sm),
              children: List.generate(widget.items.length, (index) {
                final item = widget.items[index];
                final isSelected = index == widget.selectedIndex;
                final hasChildren =
                    item.children != null && item.children!.isNotEmpty;
                final isExpanded = _expandedIndexes.contains(index);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildItem(
                      item: item,
                      isSelected: isSelected,
                      index: index,
                      hasChildren: hasChildren,
                      isExpanded: isExpanded,
                      park: park,
                    ),
                    if (hasChildren && isExpanded && !widget.collapsed)
                      ...List.generate(item.children!.length, (childIdx) {
                        final isChildSelected =
                            index == widget.selectedIndex &&
                            childIdx == widget.selectedChildIndex;

                        return _buildChildItem(
                          child: item.children![childIdx],
                          parentIndex: index,
                          childIndex: childIdx,
                          isSelected: isChildSelected,
                          park: park,
                        );
                      }),
                  ],
                );
              }),
            ),
          ),

          // Footer area
          if (widget.footer != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: park.spacing.sm,
                vertical: park.spacing.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: widget.footer!,
            ),

          // Collapse button
          if (widget.showCollapseButton)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Semantics(
                button: true,
                label: l10n.collapseText,
                child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  widget.onCollapseToggle?.call();
                  widget.onCollapse?.call(!widget.collapsed);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: park.spacing.sm,
                    vertical: park.spacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedRotation(
                        turns: widget.collapsed ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.first_page,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                      ),
                      if (!widget.collapsed) ...[
                        SizedBox(width: park.spacing.xs),
                        Text(
                          l10n.collapseText,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: park.typography.sizeBodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required ParkSideBarItem item,
    required bool isSelected,
    required int index,
    required bool hasChildren,
    required bool isExpanded,
    required ParkThemeData park,
  }) {
    final content = widget.collapsed
        ? Tooltip(
            message: item.tooltip ?? item.label,
            waitDuration: const Duration(milliseconds: 400),
            preferBelow: false,
            child: _buildItemContent(
              item: item,
              isSelected: isSelected,
              index: index,
              hasChildren: hasChildren,
              isExpanded: isExpanded,
              park: park,
            ),
          )
        : _buildItemContent(
            item: item,
            isSelected: isSelected,
            index: index,
            hasChildren: hasChildren,
            isExpanded: isExpanded,
            park: park,
          );

    return Semantics(
      label: item.label,
      button: true,
      selected: isSelected,
      child: content,
    );
  }

  Widget _buildItemContent({
    required ParkSideBarItem item,
    required bool isSelected,
    required int index,
    required bool hasChildren,
    required bool isExpanded,
    required ParkThemeData park,
  }) {
    final colors = park.colors;
    final activeColor = colors.brand;
    final inactiveColor = colors.textSecondary;
    final color = item.disabled
        ? colors.textSecondary.withValues(alpha: 0.4)
        : (isSelected ? activeColor : inactiveColor);
    final bgColor = (isSelected && !item.disabled)
        ? colors.brand.withValues(alpha: 0.08)
        : Colors.transparent;

    Widget content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.disabled
          ? null
          : () {
              if (hasChildren && !widget.collapsed) {
                setState(() {
                  if (isExpanded) {
                    _expandedIndexes.remove(index);
                  } else {
                    _expandedIndexes.add(index);
                  }
                });
              }
              widget.onChanged?.call(index);
              boundValue = index;
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.xxs,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: widget.collapsed ? 0 : park.spacing.sm,
          vertical: park.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: park.radius.brSm,
        ),
        child: Row(
          mainAxisAlignment: widget.collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            _buildLeadingIcon(item: item, color: color, park: park),
            if (!widget.collapsed) ...[
              SizedBox(width: park.spacing.sm),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: park.typography.sizeBody,
                    fontWeight: isSelected
                        ? park.typography.weightMedium
                        : park.typography.weightRegular,
                  ),
                ),
              ),
              if (item.dotBadge)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                )
              else if (item.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.brand : colors.textSecondary,
                    borderRadius: park.radius.brFull,
                  ),
                  child: Text(
                    item.badge!,
                    style: TextStyle(
                      color: colors.textOnBrand,
                      fontSize: park.typography.sizeOverline,
                      fontWeight: park.typography.weightMedium,
                      height: 1.2,
                    ),
                  ),
                ),
              if (hasChildren)
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: color,
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    // 禁用态：降低透明度
    if (item.disabled) {
      content = Opacity(opacity: 0.5, child: content);
    }

    return content;
  }

  Widget _buildLeadingIcon({
    required ParkSideBarItem item,
    required Color color,
    required ParkThemeData park,
  }) {
    final colors = park.colors;
    final icon = Icon(item.icon, size: 20, color: color);

    if (!widget.collapsed || (item.badge == null && !item.dotBadge)) {
      return icon;
    }

    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(child: icon),
          Positioned(
            top: 1,
            right: -1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildItem({
    required ParkSideBarItem child,
    required int parentIndex,
    required int childIndex,
    required bool isSelected,
    required ParkThemeData park,
  }) {
    final colors = park.colors;
    final textColor = isSelected ? colors.brand : colors.textSecondary;
    final bgColor = isSelected
        ? colors.brand.withValues(alpha: 0.08)
        : Colors.transparent;

    return Semantics(
      label: child.label,
      button: true,
      selected: isSelected,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.onChildChanged?.call(parentIndex, childIndex);
        widget.onChanged?.call(parentIndex);
        boundValue = parentIndex;
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: park.spacing.sm,
          vertical: park.spacing.xxs,
        ),
        padding: EdgeInsets.only(
          left: park.spacing.xl + park.spacing.sm,
          right: park.spacing.sm,
          top: park.spacing.xs,
          bottom: park.spacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: park.radius.brSm,
        ),
        child: Row(
          children: [
            Icon(child.icon, size: 16, color: textColor),
            SizedBox(width: park.spacing.sm),
            Expanded(
              child: Text(
                child.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: park.typography.sizeBodySmall,
                  fontWeight: isSelected
                      ? park.typography.weightMedium
                      : park.typography.weightRegular,
                ),
              ),
            ),
            if (child.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.15),
                  borderRadius: park.radius.brFull,
                ),
                child: Text(
                  child.badge!,
                  style: TextStyle(
                    color: textColor,
                    fontSize: park.typography.sizeOverline,
                    height: 1.2,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
