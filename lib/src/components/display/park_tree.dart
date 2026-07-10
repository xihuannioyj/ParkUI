import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 树形控件组件
///
/// 支持递归节点渲染、展开/折叠、选中/多选、图标和异步加载。
///
/// ```dart
/// ParkTree(
///   data: [
///     ParkTreeNode(key: '1', label: '父节点A', children: [
///       ParkTreeNode(key: '1-1', label: '子节点A1'),
///       ParkTreeNode(key: '1-2', label: '子节点A2'),
///     ]),
///     ParkTreeNode(key: '2', label: '父节点B'),
///   ],
///   onSelect: (key) => print('选中: $key'),
/// )
/// ```
class ParkTree extends StatefulWidget {
  /// 树节点数据。
  final List<ParkTreeNode> data;

  /// 选中回调。
  final void Function(String key)? onSelect;

  /// 多选选中回调（仅 multiSelect 模式下）。
  final void Function(List<String> selectedKeys)? onMultiSelect;

  /// 是否启用多选。
  final bool multiSelect;

  /// 已选中的 key 列表。
  final List<String>? selectedKeys;

  /// 默认展开的 key 列表（为 null 时全部收起）。
  final Set<String>? defaultExpandedKeys;

  /// 是否显示连线。
  final bool showLine;

  /// 自定义节点图标。
  final IconData? nodeIcon;

  /// 自定义展开图标（替代默认箭头）。
  final Widget? expandIcon;

  /// 展开图标展开时的旋转角度（默认 90 度）。
  final double expandRotate;

  /// 异步加载子节点（返回 true 表示有子节点）。
  final Future<List<ParkTreeNode>> Function(ParkTreeNode node)? loadChildren;

  /// 创建 [ParkTree]。
  const ParkTree({
    super.key,
    required this.data,
    this.onSelect,
    this.onMultiSelect,
    this.multiSelect = false,
    this.selectedKeys,
    this.defaultExpandedKeys,
    this.showLine = false,
    this.nodeIcon,
    this.expandIcon,
    this.expandRotate = 90,
    this.loadChildren,
  });

  @override
  State<ParkTree> createState() => _ParkTreeState();
}

/// 树节点数据模型。
class ParkTreeNode {
  /// 节点唯一标识。
  final String key;

  /// 显示文字。
  final String label;

  /// 前导图标。
  final IconData? icon;

  /// 子节点。
  final List<ParkTreeNode> children;

  /// 是否禁用选中。
  final bool disabled;

  /// 是否默认展开。
  final bool defaultExpanded;

  /// 附加数据。
  final dynamic extra;

  const ParkTreeNode({
    required this.key,
    required this.label,
    this.icon,
    this.children = const [],
    this.disabled = false,
    this.defaultExpanded = false,
    this.extra,
  });

  bool get hasChildren => children.isNotEmpty;

  /// 是否为叶子节点。
  bool get isLeaf => children.isEmpty;
}

class _ParkTreeState extends State<ParkTree> {
  late Set<String> _expandedKeys;
  late Set<String> _selectedKeys;

  @override
  void initState() {
    super.initState();
    _expandedKeys = Set<String>.from(widget.defaultExpandedKeys ?? _defaultExpanded(widget.data));
    _selectedKeys = Set<String>.from(widget.selectedKeys ?? []);
  }

  Set<String> _defaultExpanded(List<ParkTreeNode> nodes) {
    final s = <String>{};
    for (final n in nodes) {
      if (n.defaultExpanded) s.add(n.key);
    }
    return s;
  }

  void _toggle(String key) {
    setState(() {
      if (_expandedKeys.contains(key)) _expandedKeys.remove(key);
      else _expandedKeys.add(key);
    });
  }

  void _select(String key, bool isGroup) {
    if (isGroup) { _toggle(key); return; }
    setState(() {
      if (widget.multiSelect) {
        if (_selectedKeys.contains(key)) _selectedKeys.remove(key);
        else _selectedKeys.add(key);
        widget.onMultiSelect?.call(_selectedKeys.toList());
      } else {
        _selectedKeys = {key};
        widget.onSelect?.call(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.data.map((n) => _buildNode(n, 0, park)).toList(),
    );
  }

  Widget _buildNode(ParkTreeNode node, int depth, ParkThemeData park) {
    final isExpanded = _expandedKeys.contains(node.key);
    final isSelected = _selectedKeys.contains(node.key);
    final hasChildren = node.hasChildren || (widget.loadChildren != null);
    final indent = 16.0 + depth * 20;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: node.disabled ? null : () => _select(node.key, hasChildren),
          child: Container(
            padding: EdgeInsets.only(left: indent, right: 12, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: isSelected ? park.colors.brand.withAlpha(20) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  child: hasChildren ? GestureDetector(
                    onTap: () => _toggle(node.key),
                    child: widget.expandIcon ?? Transform.rotate(
                      angle: isExpanded ? widget.expandRotate * 3.14159 / 180 : 0,
                      child: Icon(Icons.arrow_right, size: 18, color: park.colors.textSecondary),
                    ),
                  ) : const SizedBox(width: 18),
                ),
                if (widget.multiSelect) ...[
                  Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: isSelected ? park.colors.brand : park.colors.textSecondary),
                  const SizedBox(width: 4),
                ],
                if (node.icon != null) ...[
                  Icon(node.icon, size: 16, color: park.colors.textSecondary),
                  const SizedBox(width: 4),
                ] else if (widget.nodeIcon != null) ...[
                  Icon(widget.nodeIcon, size: 16, color: park.colors.textSecondary),
                  const SizedBox(width: 4),
                ],
                Text(node.label, style: TextStyle(fontSize: 14, color: isSelected ? park.colors.brand : park.colors.textPrimary)),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded && node.children.isNotEmpty)
          ...node.children.map((c) => _buildNode(c, depth + 1, park)),
      ],
    );
  }
}
