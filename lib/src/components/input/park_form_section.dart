import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';

/// Park 表单分组容器。
///
/// 用于组织一组相关字段，统一承载：
///
/// - section 标题
/// - section 描述
/// - 可选右侧操作区
/// - 组内字段间距
class ParkFormSection extends StatefulWidget {
  /// 分组标题。
  final String title;

  /// 分组描述。
  final String? description;

  /// 右侧扩展区域。
  final Widget? trailing;

  /// 子内容列表。
  final List<Widget> children;

  /// 组内子项间距。
  final double? spacing;

  /// 外层内边距。
  final EdgeInsetsGeometry? padding;

  /// 是否显示顶部标题区。
  final bool showHeader;

  /// 是否可折叠。为 true 时在标题区显示展开/收起箭头。默认 false。
  final bool collapsible;

  /// 初始折叠状态（仅当 [collapsible] 为 true 时生效）。默认 false（展开状态）。
  final bool defaultCollapsed;

  /// 折叠状态变更回调。
  final ValueChanged<bool>? onCollapseChanged;

  /// 是否在分组底部显示分割线。默认 false。
  final bool divider;

  /// 创建表单分组。
  const ParkFormSection({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    required this.children,
    this.spacing,
    this.padding,
    this.showHeader = true,
    this.collapsible = false,
    this.defaultCollapsed = false,
    this.onCollapseChanged,
    this.divider = false,
  });

  @override
  State<ParkFormSection> createState() => _ParkFormSectionState();
}

class _ParkFormSectionState extends State<ParkFormSection>
    with SingleTickerProviderStateMixin {
  late bool _collapsed;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.collapsible ? widget.defaultCollapsed : false;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: _collapsed ? 0.0 : 1.0,
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

  @override
  void didUpdateWidget(covariant ParkFormSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collapsible != oldWidget.collapsible ||
        widget.defaultCollapsed != oldWidget.defaultCollapsed) {
      setState(() {
        _collapsed = widget.collapsible ? widget.defaultCollapsed : false;
      });
      if (_collapsed && !_animController.isDismissed) {
        _animController.reverse();
      } else if (!_collapsed && !_animController.isCompleted) {
        _animController.forward();
      }
    }
  }

  void _toggleCollapse() {
    setState(() {
      _collapsed = !_collapsed;
    });
    if (_collapsed) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
    widget.onCollapseChanged?.call(_collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final colors = park.colors;
    final typo = park.typography;

    final List<Widget> contentChildren = <Widget>[];
    final double itemSpacing = widget.spacing ?? park.spacing.base;

    for (int i = 0; i < widget.children.length; i++) {
      contentChildren.add(widget.children[i]);
      if (i < widget.children.length - 1) {
        contentChildren.add(SizedBox(height: itemSpacing));
      }
    }

    return Container(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.showHeader)
            Semantics(
              button: widget.collapsible,
              label: widget.collapsible ? widget.title : null,
              child: GestureDetector(
              onTap: widget.collapsible ? _toggleCollapse : null,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.collapsible) ...<Widget>[
                    AnimatedRotation(
                      turns: _collapsed ? -0.25 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.expand_more,
                        size: typo.sizeH3 * 1.2,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: park.spacing.xs),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: typo.sizeH3,
                            fontWeight: typo.weightBold,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (widget.description != null &&
                            widget.description!.trim().isNotEmpty) ...<Widget>[
                          SizedBox(height: park.spacing.xs),
                          Text(
                            widget.description!,
                            style: TextStyle(
                              fontSize: typo.sizeBodySmall,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...<Widget>[
                    SizedBox(width: park.spacing.sm),
                    widget.trailing!,
                  ],
                ],
              ),
              ),
            ),
          if (widget.showHeader && widget.children.isNotEmpty)
            SizedBox(height: park.spacing.md),
          if (widget.collapsible)
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: contentChildren,
              ),
            )
          else
            ...contentChildren,
          if (widget.divider) ...<Widget>[
            SizedBox(height: park.spacing.md),
            Divider(
              height: 1,
              thickness: 1,
              color: colors.borderLight,
            ),
          ],
        ],
      ),
    );
  }
}
