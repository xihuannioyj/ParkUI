import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 树形控件组件
///
/// 支持递归节点渲染、展开/折叠、选中/多选、图标、异步加载、拖拽排序和搜索高亮。
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

  /// 是否启用节点拖拽排序。
  final bool draggable;

  /// 拖拽排序回调（oldIndex, newIndex 为同级节点中的索引）。
  final void Function(int oldIndex, int newIndex)? onDragReorder;

  /// 搜索关键词，不为 null 时高亮匹配文字并展开包含匹配的父节点。
  final String? searchQuery;

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
    this.draggable = false,
    this.onDragReorder,
    this.searchQuery,
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

/// 拖拽数据，用于 DragTarget 和 LongPressDraggable 交互。
class _DraggableData {
  final String key;
  final int index;
  final String? parentKey;

  const _DraggableData({
    required this.key,
    required this.index,
    this.parentKey,
  });
}

class _ParkTreeState extends State<ParkTree> {
  late Set<String> _expandedKeys;
  late Set<String> _selectedKeys;

  /// 正在异步加载子节点的 key 集合。
  final Set<String> _loadingKeys = <String>{};

  /// 异步加载的子节点缓存（key -> loaded children）。
  final Map<String, List<ParkTreeNode>> _loadedChildren =
      <String, List<ParkTreeNode>>{};

  /// 当前正在拖拽的节点 key。
  String? _dragKey;

  /// 当前悬停的插入位置索引。
  int? _hoverIndex;

  /// 当前悬停的目标节点的 parent key（null 表示根级）。
  String? _hoverParentKey;

  @override
  void initState() {
    super.initState();
    _expandedKeys = Set<String>.from(
      widget.defaultExpandedKeys ?? _defaultExpanded(widget.data),
    );
    _selectedKeys = Set<String>.from(widget.selectedKeys ?? []);
    _applySearchQuery(widget.searchQuery);
  }

  @override
  void didUpdateWidget(ParkTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedKeys != null &&
        !_listEquals(widget.selectedKeys!, _selectedKeys.toList())) {
      setState(() {
        _selectedKeys = Set<String>.from(widget.selectedKeys!);
      });
    }
    if (widget.searchQuery != oldWidget.searchQuery) {
      _applySearchQuery(widget.searchQuery);
    }
  }

  /// 比较两个字符串列表是否相等（忽略顺序）。
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    return a.toSet().containsAll(b);
  }

  Set<String> _defaultExpanded(List<ParkTreeNode> nodes) {
    final s = <String>{};
    for (final n in nodes) {
      if (n.defaultExpanded) s.add(n.key);
    }
    return s;
  }

  /// 应用搜索查询：自动展开包含匹配项的父节点。
  void _applySearchQuery(String? query) {
    if (query == null || query.isEmpty) return;
    final lowerQuery = query.toLowerCase();
    final toExpand = <String>{};
    _collectExpandKeys(widget.data, lowerQuery, toExpand);
    if (toExpand.isNotEmpty) {
      setState(() {
        _expandedKeys.addAll(toExpand);
      });
    }
  }

  /// 递归收集包含搜索匹配的子节点的父节点 key。
  /// 返回 true 表示此子树内有匹配项。
  bool _collectExpandKeys(
      List<ParkTreeNode> nodes, String lowerQuery, Set<String> result) {
    bool anyMatch = false;
    for (final n in nodes) {
      final selfMatch = n.label.toLowerCase().contains(lowerQuery);
      final childResult = <String>{};
      final childMatch = n.children.isNotEmpty &&
          _collectExpandKeys(n.children, lowerQuery, childResult);

      if (childMatch) {
        result.add(n.key);
        result.addAll(childResult);
      }

      if (selfMatch || childMatch) {
        anyMatch = true;
      }
    }
    return anyMatch;
  }

  Future<void> _toggle(String key) async {
    if (_expandedKeys.contains(key)) {
      setState(() => _expandedKeys.remove(key));
      return;
    }

    final node = _findNodeByKey(widget.data, key);
    if (node != null &&
        widget.loadChildren != null &&
        node.children.isEmpty &&
        !_loadedChildren.containsKey(key)) {
      setState(() => _loadingKeys.add(key));
      try {
        final children = await widget.loadChildren!(node);
        if (mounted) {
          _loadedChildren[key] = children;
          setState(() {
            _loadingKeys.remove(key);
            _expandedKeys.add(key);
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _loadingKeys.remove(key));
        }
      }
    } else {
      setState(() => _expandedKeys.add(key));
    }
  }

  /// 在节点树中查找指定 key 的节点。
  ParkTreeNode? _findNodeByKey(List<ParkTreeNode> nodes, String key) {
    for (final n in nodes) {
      if (n.key == key) return n;
      if (n.children.isNotEmpty) {
        final found = _findNodeByKey(n.children, key);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _select(String key, bool isGroup) {
    if (isGroup) {
      _toggle(key);
      return;
    }
    setState(() {
      if (widget.multiSelect) {
        if (_selectedKeys.contains(key)) {
          _selectedKeys.remove(key);
        } else {
          _selectedKeys.add(key);
        }
        widget.onMultiSelect?.call(_selectedKeys.toList());
      } else {
        _selectedKeys = {key};
        widget.onSelect?.call(key);
      }
    });
  }

  // ========================================================================
  // Build
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _buildLevelChildren(widget.data, 0, null, park),
    );
  }

  /// 构建一级子树的所有子项（节点行 + 可选的拖拽放置区域）。
  List<Widget> _buildLevelChildren(
    List<ParkTreeNode> nodes,
    int depth,
    String? parentKey,
    ParkThemeData park,
  ) {
    final items = <Widget>[];
    for (int i = 0; i < nodes.length; i++) {
      if (widget.draggable) {
        items.add(_buildDropZone(parentKey, i, park));
      }
      items.add(_buildNode(nodes[i], depth, parentKey, i, park));
    }
    if (widget.draggable && nodes.isNotEmpty) {
      items.add(_buildDropZone(parentKey, nodes.length, park));
    }
    return items;
  }

  /// 构建拖拽放置区域（DragTarget + 指示线）。
  Widget _buildDropZone(String? parentKey, int index, ParkThemeData park) {
    return DragTarget<_DraggableData>(
      onWillAcceptWithDetails: (details) {
        if (details.data.parentKey != parentKey) return false;
        final oldIdx = details.data.index;
        final newIdx = index > oldIdx ? index - 1 : index;
        if (newIdx == oldIdx) {
          setState(() {
            _hoverParentKey = null;
            _hoverIndex = null;
          });
          return false;
        }
        setState(() {
          _hoverParentKey = parentKey;
          _hoverIndex = index;
        });
        return true;
      },
      onLeave: (data) {
        if (_hoverParentKey == parentKey && _hoverIndex == index) {
          setState(() {
            _hoverParentKey = null;
            _hoverIndex = null;
          });
        }
      },
      onAcceptWithDetails: (details) {
        final oldIdx = details.data.index;
        final newIdx = index > oldIdx ? index - 1 : index;
        setState(() {
          _dragKey = null;
          _hoverParentKey = null;
          _hoverIndex = null;
        });
        widget.onDragReorder?.call(oldIdx, newIdx);
      },
      builder: (context, candidateData, rejectedData) {
        final hovered = _dragKey != null &&
            _hoverParentKey == parentKey &&
            _hoverIndex == index;
        return Container(
          height: hovered ? park.spacing.xs : 1,
          margin: EdgeInsets.symmetric(
            horizontal: park.spacing.xs,
          ),
          decoration: BoxDecoration(
            color: hovered ? park.colors.brand : Colors.transparent,
            borderRadius: park.radius.brXs,
          ),
        );
      },
    );
  }

  /// 构建单个节点（包含行 + 展开的子节点）。
  Widget _buildNode(
    ParkTreeNode node,
    int depth,
    String? parentKey,
    int index,
    ParkThemeData park,
  ) {
    final isExpanded = _expandedKeys.contains(node.key);
    final isSelected = _selectedKeys.contains(node.key);
    final isLoading = _loadingKeys.contains(node.key);

    // 异步加载的子节点优先于 node.children
    final displayChildren = _loadedChildren[node.key] ?? node.children;
    final hasChildren = displayChildren.isNotEmpty ||
        (widget.loadChildren != null && !isLoading);

    final nodeContent = _buildNodeRow(
        node, depth, isSelected, isExpanded, hasChildren, isLoading, park);

    // 拖拽排序：LongPressDraggable 包裹节点行
    Widget rowWidget = nodeContent;
    if (widget.draggable && !node.disabled) {
      rowWidget = LongPressDraggable<_DraggableData>(
        data:
            _DraggableData(key: node.key, index: index, parentKey: parentKey),
        feedback: Material(
          elevation: 4,
          borderRadius: park.radius.brXs,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Opacity(
              opacity: 0.85,
              child: _buildNodeRow(
                  node, depth, false, false, false, false, park),
            ),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: nodeContent),
        onDragStarted: () => setState(() => _dragKey = node.key),
        onDragEnd: (_) {
          if (mounted) {
            setState(() {
              _dragKey = null;
              _hoverParentKey = null;
              _hoverIndex = null;
            });
          }
        },
        child: nodeContent,
      );
    }

    return Semantics(
      label:
          '${node.label}${isSelected ? ', 已选' : ''}${hasChildren ? ', ${isExpanded ? "已展开" : "已折叠"}' : ''}${widget.draggable ? ', 可拖拽排序' : ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rowWidget,
          if ((hasChildren || isLoading) && isExpanded)
            ..._buildLevelChildren(
                displayChildren, depth + 1, node.key, park),
        ],
      ),
    );
  }

  /// 构建节点行的内容（InkWell + 图标 + 文字 + 复选框）。
  Widget _buildNodeRow(
    ParkTreeNode node,
    int depth,
    bool isSelected,
    bool isExpanded,
    bool hasChildren,
    bool isLoading,
    ParkThemeData park,
  ) {
    final indent = park.spacing.base + depth * park.spacing.lg;

    return InkWell(
      onTap: node.disabled ? null : () => _select(node.key, hasChildren),
      child: Container(
        padding: EdgeInsets.only(
          left: indent,
          right: park.spacing.md,
          top: park.spacing.xs + 2,
          bottom: park.spacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? park.colors.brand.withAlpha(20) : null,
          borderRadius: park.radius.brXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: park.spacing.lg,
              child: isLoading
                  ? SizedBox(
                      width: park.spacing.base,
                      height: park.spacing.base,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: park.colors.brand,
                      ),
                    )
                  : hasChildren
                      ? GestureDetector(
                          onTap: () => _toggle(node.key),
                          child: widget.expandIcon ??
                              Transform.rotate(
                                angle: isExpanded
                                    ? widget.expandRotate * 3.14159 / 180
                                    : 0,
                                child: Icon(
                                  Icons.arrow_right,
                                  size: 18,
                                  color: park.colors.textSecondary,
                                ),
                              ),
                        )
                      : SizedBox(width: park.spacing.sm + 10),
            ),
            if (widget.multiSelect) ...[
              Icon(
                isSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                size: park.spacing.base,
                color: isSelected
                    ? park.colors.brand
                    : park.colors.textSecondary,
              ),
              park.spacing.hXs,
            ],
            if (node.icon != null) ...[
              Icon(node.icon,
                  size: park.spacing.base, color: park.colors.textSecondary),
              park.spacing.hXs,
            ] else if (widget.nodeIcon != null) ...[
              Icon(widget.nodeIcon,
                  size: park.spacing.base, color: park.colors.textSecondary),
              park.spacing.hXs,
            ],
            _buildLabelText(
                node.label, widget.searchQuery, isSelected, park),
          ],
        ),
      ),
    );
  }

  /// 构建标签文字（含搜索高亮）。
  Widget _buildLabelText(
      String label, String? query, bool isSelected, ParkThemeData park) {
    final baseStyle = TextStyle(
      fontSize: park.typography.sizeBodySmall,
      color: isSelected ? park.colors.brand : park.colors.textPrimary,
    );

    if (query == null || query.isEmpty) {
      return Text(label, style: baseStyle);
    }

    final lowerLabel = label.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    int idx;
    while ((idx = lowerLabel.indexOf(lowerQuery, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: label.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: label.substring(idx, idx + query.length),
        style: TextStyle(
          backgroundColor: park.colors.warning.withAlpha(60),
          color: park.colors.brand,
          fontWeight: park.typography.weightMedium,
        ),
      ));
      start = idx + query.length;
    }
    if (start < label.length) {
      spans.add(TextSpan(text: label.substring(start)));
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
    );
  }
}
