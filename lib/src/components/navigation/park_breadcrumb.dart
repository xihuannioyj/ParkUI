import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// Park 面包屑尺寸
enum ParkBreadcrumbSize {
  /// 小尺寸（字号 12）
  small,

  /// 中尺寸（字号 14，默认）
  medium,

  /// 大尺寸（字号 16）
  large,
}

/// Park 面包屑项数据模型
///
/// 每一项可以是纯文字、带图标、可点击、或带下拉子菜单。
class ParkBreadcrumbItem {
  /// 显示文字
  final String label;

  /// 前置图标（可选）
  final IconData? icon;

  /// 点击回调（为空时不可点击）
  final VoidCallback? onTap;

  /// 下拉子项列表（不为空时显示下拉菜单）
  final List<ParkBreadcrumbItem>? overlay;

  const ParkBreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
    this.overlay,
  });
}

/// Park 面包屑导航
///
/// 显示当前页面在导航层级中的位置，支持图标、下拉子菜单、
/// 超长折叠（ellipsis）等常见面包屑功能。
///
/// ```dart
/// ParkBreadcrumb(
///   items: [
///     ParkBreadcrumbItem(label: '首页', icon: Icons.home, onTap: () {}),
///     ParkBreadcrumbItem(label: '列表', onTap: () {}),
///     ParkBreadcrumbItem(label: '详情'),
///   ],
/// )
/// ```
class ParkBreadcrumb extends StatelessWidget {
  /// 面包屑项列表
  final List<ParkBreadcrumbItem> items;

  /// 分隔符（字符串或自定义 Widget），默认 '/'
  final Widget separator;

  /// 最大显示项数。超出时在头部插入 "..." 按钮，
  /// 点击展开被隐藏的项列表。
  final int? maxItems;

  /// 面包屑尺寸
  final ParkBreadcrumbSize size;

  /// 分隔符图标（当 separator 为 null 时使用）
  final Widget? separatorIcon;

  /// 下拉菜单自定义样式类名
  final String? overlayClassName;

  ParkBreadcrumb({
    super.key,
    required this.items,
    Widget? separator,
    this.maxItems,
    this.size = ParkBreadcrumbSize.medium,
    this.separatorIcon,
    this.overlayClassName,
  }) : separator = separator ?? _defaultSeparator();

  /// 字符串快捷构造
  factory ParkBreadcrumb.text({
    Key? key,
    required List<ParkBreadcrumbItem> items,
    String separator = '/',
    int? maxItems,
    ParkBreadcrumbSize size = ParkBreadcrumbSize.medium,
  }) {
    return ParkBreadcrumb(
      key: key,
      items: items,
      separator: Text(separator),
      maxItems: maxItems,
      size: size,
    );
  }

  static Widget _defaultSeparator() => const Text('/');

  double get _fontSize {
    switch (size) {
      case ParkBreadcrumbSize.small:
        return 12.0;
      case ParkBreadcrumbSize.medium:
        return 14.0;
      case ParkBreadcrumbSize.large:
        return 16.0;
    }
  }

  double get _iconSize {
    switch (size) {
      case ParkBreadcrumbSize.small:
        return 14.0;
      case ParkBreadcrumbSize.medium:
        return 16.0;
      case ParkBreadcrumbSize.large:
        return 18.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    if (items.isEmpty) return const SizedBox.shrink();

    // 判断是否需要折叠
    final bool needCollapse =
        maxItems != null && maxItems! > 0 && items.length > maxItems!;

    // 可见项列表
    final List<_VisibleEntry> visibleEntries = [];

    if (needCollapse) {
      // 折叠：第一项 + 省略号 + 最后 (maxItems - 1) 项
      visibleEntries.add(_VisibleEntry(
        item: items.first,
        index: 0,
        isLast: false,
      ));
      visibleEntries.add(const _VisibleEntry.ellipsis());

      final tailCount = maxItems! - 1;
      final tailStart = items.length - tailCount;
      for (int i = tailStart; i < items.length; i++) {
        visibleEntries.add(_VisibleEntry(
          item: items[i],
          index: i,
          isLast: i == items.length - 1,
        ));
      }
    } else {
      for (int i = 0; i < items.length; i++) {
        visibleEntries.add(_VisibleEntry(
          item: items[i],
          index: i,
          isLast: i == items.length - 1,
        ));
      }
    }

    // 被折叠隐藏的项（第一项之后到 tailStart 之前）
    final List<ParkBreadcrumbItem> hiddenItems = needCollapse
        ? items.sublist(1, items.length - (maxItems! - 1))
        : const [];

    // 构建 Row children
    final children = <Widget>[];
    for (int i = 0; i < visibleEntries.length; i++) {
      final entry = visibleEntries[i];

      if (entry.isEllipsis) {
        // 省略号按钮
        children.add(_buildEllipsisButton(park, hiddenItems));
      } else {
        children.add(_buildItem(context, park, entry));
      }

      // 分隔符（最后一项之后不加）
      final bool isLastEntry = i == visibleEntries.length - 1;
      if (!isLastEntry) {
        children.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: park.spacing.xs),
          child: DefaultTextStyle(
            style: TextStyle(
              color: park.colors.textPlaceholder,
              fontSize: _fontSize,
            ),
            child: separator,
          ),
        ));
      }
    }

    return Semantics(
      label: '面包屑导航',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  /// 构建单个面包屑项
  Widget _buildItem(
    BuildContext context,
    ParkThemeData park,
    _VisibleEntry entry,
  ) {
    final item = entry.item!;
    final isLast = entry.isLast;
    final isClickable = !isLast && (item.onTap != null || item.overlay != null);

    // 有下拉子菜单时使用 PopupMenuButton
    if (item.overlay != null && item.overlay!.isNotEmpty && !isLast) {
      return _buildDropdownItem(context, park, item);
    }

    Widget content = _buildItemContent(park, item, isClickable, isLast);

    if (isClickable) {
      content = _BreadcrumbHoverable(
        onTap: item.onTap,
        fontSize: _fontSize,
        child: content,
      );
    }

    return Semantics(
      label: item.label,
      button: isClickable,
      child: content,
    );
  }

  /// 构建项内容（图标 + 文字）
  Widget _buildItemContent(
    ParkThemeData park,
    ParkBreadcrumbItem item,
    bool isClickable,
    bool isLast,
  ) {
    final color = isLast
        ? park.colors.textPrimary
        : (isClickable ? park.colors.brand : park.colors.textSecondary);

    final fontWeight =
        isLast ? park.typography.weightBold : park.typography.weightRegular;

    final children = <Widget>[];

    if (item.icon != null) {
      children.add(Icon(item.icon, size: _iconSize, color: color));
      children.add(SizedBox(width: park.spacing.xxs));
    }

    children.add(Text(
      item.label,
      style: TextStyle(
        color: color,
        fontSize: _fontSize,
        fontWeight: fontWeight,
        decoration:
            isClickable ? TextDecoration.underline : TextDecoration.none,
        decorationColor: isClickable ? color : null,
      ),
    ));

    if (children.length == 1) return children.first;
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  /// 构建带下拉菜单的面包屑项
  Widget _buildDropdownItem(
    BuildContext context,
    ParkThemeData park,
    ParkBreadcrumbItem item,
  ) {
    return Semantics(
      label: '${item.label}，有子菜单',
      button: true,
      child: PopupMenuButton<ParkBreadcrumbItem>(
        offset: Offset(0, _fontSize + park.spacing.sm),
        onSelected: (subItem) => subItem.onTap?.call(),
        itemBuilder: (context) {
          return item.overlay!.map((subItem) {
            return PopupMenuItem<ParkBreadcrumbItem>(
              value: subItem,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subItem.icon != null) ...[
                    Icon(subItem.icon,
                        size: _iconSize, color: park.colors.textPrimary),
                    SizedBox(width: park.spacing.xs),
                  ],
                  Text(
                    subItem.label,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: park.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: _BreadcrumbHoverable(
          onTap: null, // PopupMenuButton handles tap
          fontSize: _fontSize,
          child: _buildItemContent(park, item, true, false),
        ),
      ),
    );
  }

  /// 构建省略号按钮（点击展开隐藏项）
  Widget _buildEllipsisButton(
    ParkThemeData park,
    List<ParkBreadcrumbItem> hiddenItems,
  ) {
    if (hiddenItems.isEmpty) {
      return Text(
        '...',
        style: TextStyle(
          color: park.colors.textSecondary,
          fontSize: _fontSize,
        ),
      );
    }

    return Semantics(
      label: '展开更多面包屑',
      button: true,
      child: PopupMenuButton<ParkBreadcrumbItem>(
        offset: Offset(0, _fontSize + park.spacing.sm),
        onSelected: (item) => item.onTap?.call(),
        itemBuilder: (context) {
          return hiddenItems.map((item) {
            return PopupMenuItem<ParkBreadcrumbItem>(
              value: item,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.icon != null) ...[
                    Icon(item.icon,
                        size: _iconSize, color: park.colors.textPrimary),
                    SizedBox(width: park.spacing.xs),
                  ],
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: park.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: park.spacing.xxs),
          child: Text(
            '...',
            style: TextStyle(
              color: park.colors.textSecondary,
              fontSize: _fontSize,
              fontWeight: park.typography.weightBold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 可见条目包装（可能是普通项，也可能是省略号占位）
class _VisibleEntry {
  final ParkBreadcrumbItem? item;
  final int index;
  final bool isLast;
  final bool isEllipsis;

  const _VisibleEntry({
    required this.item,
    required this.index,
    required this.isLast,
  }) : isEllipsis = false;

  const _VisibleEntry.ellipsis()
      : item = null,
        index = -1,
        isLast = false,
        isEllipsis = true;
}

/// 面包屑项 hover 状态管理
class _BreadcrumbHoverable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double fontSize;

  const _BreadcrumbHoverable({
    required this.onTap,
    required this.child,
    required this.fontSize,
  });

  @override
  State<_BreadcrumbHoverable> createState() => _BreadcrumbHoverableState();
}

class _BreadcrumbHoverableState extends State<_BreadcrumbHoverable> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: park.spacing.xxs,
            vertical: park.spacing.xxs,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? park.colors.brand.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(park.radius.xs),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
