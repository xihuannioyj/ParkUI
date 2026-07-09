import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';

/// 树节点数据
class ParkTreeNode {
  /// 节点唯一标识
  final String key;

  /// 节点显示文字
  final String label;

  /// 子节点列表
  final List<ParkTreeNode>? children;

  /// 是否禁用
  final bool disabled;

  const ParkTreeNode({
    required this.key,
    required this.label,
    this.children,
    this.disabled = false,
  });

  /// 是否为叶子节点
  bool get isLeaf => children == null || children!.isEmpty;
}

/// 自定义展开/折叠图标构建器
typedef ParkTreeSwitcherIconBuilder = Widget Function(bool isExpanded);

/// Park 树选择器
///
/// 可展开的树结构，支持单选 / 多选、复选框联动（父子关联）。
///
/// ```dart
/// ParkTreeSelect(
///   nodes: [
///     ParkTreeNode(
///       key: 'dept1',
///       label: '研发部',
///       children: [
///         ParkTreeNode(key: 'team1', label: '前端组'),
///         ParkTreeNode(key: 'team2', label: '后端组'),
///       ],
///     ),
///   ],
///   selectedKeys: {'team1'},
///   multiple: true,
///   checkable: true,
///   onChanged: (keys) => print(keys),
/// )
/// ```
class ParkTreeSelect extends StatefulWidget {
  /// 树节点列表
  final List<ParkTreeNode> nodes;

  /// 已选中的节点 key 集合
  final Set<String> selectedKeys;

  /// 选中状态变更回调
  final ValueChanged<Set<String>>? onChanged;

  /// 是否多选模式
  final bool multiple;

  /// 是否显示复选框
  final bool checkable;

  /// 是否启用搜索。
  final bool searchable;

  /// 搜索框占位文案。
  final String searchHintText;

  /// 父子节点选中状态是否严格独立。
  ///
  /// 为 true 时父节点选中不影响子节点，反之父子联动。
  final bool treeCheckStrictly;

  /// 初始化时是否展开所有节点。
  final bool treeDefaultExpandAll;

  /// 是否显示树形连接线。
  final bool treeLine;

  /// 自定义展开/折叠图标。
  ///
  /// 为 null 时使用默认 chevron_right 图标。
  final ParkTreeSwitcherIconBuilder? switcherIcon;

  /// 多选模式下可见选中标签的最大数量。
  ///
  /// 超出部分以 "+N" 显示。为 null 时不限制。
  final int? maxTagCount;

  /// 绑定键（点号分隔的路径，如 `'treeSelectedKeys'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  const ParkTreeSelect({
    super.key,
    required this.nodes,
    this.selectedKeys = const {},
    this.onChanged,
    this.multiple = false,
    this.checkable = true,
    this.searchable = false,
    this.searchHintText = '搜索节点',
    this.treeCheckStrictly = false,
    this.treeDefaultExpandAll = false,
    this.treeLine = false,
    this.switcherIcon,
    this.maxTagCount,
    this.bindKey,
    this.bindingService,
  });

  @override
  State<ParkTreeSelect> createState() => _ParkTreeSelectState();
}

class _ParkTreeSelectState extends State<ParkTreeSelect>
    with BindableWidgetMixin<Set<String>, ParkTreeSelect> {
  late Set<String> _selectedKeys;
  late Set<String> _expandedKeys;
  String _keyword = '';

  @override
  void initState() {
    bindKey = widget.bindKey;
    bindingService = widget.bindingService;
    super.initState();
    final initialValue = boundValue;
    if (initialValue != null) {
      _selectedKeys = Set<String>.from(initialValue);
    } else {
      _selectedKeys = Set<String>.from(widget.selectedKeys);
    }
    _expandedKeys = <String>{};

    if (widget.treeDefaultExpandAll) {
      _expandAll(widget.nodes);
    } else {
      // 默认展开有选中子节点的父级
      _autoExpandForSelected(widget.nodes);
    }
  }

  void _expandAll(List<ParkTreeNode> nodes) {
    for (final node in nodes) {
      if (!node.isLeaf) {
        _expandedKeys.add(node.key);
        _expandAll(node.children!);
      }
    }
  }

  void _autoExpandForSelected(List<ParkTreeNode> nodes) {
    for (final node in nodes) {
      if (!node.isLeaf && _hasSelectedDescendant(node)) {
        _expandedKeys.add(node.key);
        _autoExpandForSelected(node.children!);
      }
    }
  }

  bool _hasSelectedDescendant(ParkTreeNode node) {
    if (node.isLeaf) return _selectedKeys.contains(node.key);
    for (final child in node.children!) {
      if (_selectedKeys.contains(child.key) || _hasSelectedDescendant(child)) {
        return true;
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(ParkTreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedKeys != oldWidget.selectedKeys) {
      _selectedKeys = Set<String>.from(widget.selectedKeys);
    }
  }

  /// 获取节点选中状态（考虑父子联动，或严格独立模式）
  _CheckState _getCheckState(ParkTreeNode node) {
    // 严格独立模式：仅判断自身
    if (widget.treeCheckStrictly) {
      return _selectedKeys.contains(node.key)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }

    if (node.isLeaf) {
      return _selectedKeys.contains(node.key)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }

    // 检查所有子孙节点的选中情况
    final allKeys = <String>[];
    _collectKeys(node, allKeys);

    final selectedCount = allKeys
        .where((k) => _selectedKeys.contains(k))
        .length;

    if (selectedCount == 0) return _CheckState.unchecked;
    if (selectedCount == allKeys.length) return _CheckState.checked;
    return _CheckState.indeterminate;
  }

  /// 收集节点所有子孙的 key（含自身如果是叶子）
  void _collectKeys(ParkTreeNode node, List<String> keys) {
    if (node.isLeaf) {
      keys.add(node.key);
    } else {
      for (final child in node.children!) {
        _collectKeys(child, keys);
      }
    }
  }

  /// 切换节点选中状态
  void _toggleNode(ParkTreeNode node) {
    if (node.disabled) return;

    setState(() {
      if (widget.multiple) {
        if (widget.treeCheckStrictly) {
          // 严格模式：只切换当前节点自身
          if (_selectedKeys.contains(node.key)) {
            _selectedKeys.remove(node.key);
          } else {
            _selectedKeys.add(node.key);
          }
        } else {
          final checkState = _getCheckState(node);
          final shouldCheck = checkState != _CheckState.checked;

          if (node.isLeaf) {
            if (shouldCheck) {
              _selectedKeys.add(node.key);
            } else {
              _selectedKeys.remove(node.key);
            }
          } else {
            // 选中/取消所有子孙叶子节点
            final leafKeys = <String>[];
            _collectKeys(node, leafKeys);
            for (final k in leafKeys) {
              if (shouldCheck) {
                _selectedKeys.add(k);
              } else {
                _selectedKeys.remove(k);
              }
            }
          }
        }
      } else {
        // 单选模式
        if (node.isLeaf) {
          _selectedKeys = {_selectedKeys.contains(node.key) ? '' : node.key};
          _selectedKeys.remove('');
        }
      }
    });

    widget.onChanged?.call(Set<String>.from(_selectedKeys));
    boundValue = Set<String>.from(_selectedKeys);
  }

  void _toggleExpand(ParkTreeNode node) {
    if (node.isLeaf) return;
    setState(() {
      if (_expandedKeys.contains(node.key)) {
        _expandedKeys.remove(node.key);
      } else {
        _expandedKeys.add(node.key);
      }
    });
  }

  /// 收集所有可见的叶子节点标签（用于 maxTagCount 显示）
  List<String> _getSelectedLabels() {
    final labels = <String>[];
    _collectLabels(widget.nodes, labels);
    return labels;
  }

  void _collectLabels(List<ParkTreeNode> nodes, List<String> labels) {
    for (final node in nodes) {
      if (_selectedKeys.contains(node.key)) {
        labels.add(node.label);
      }
      if (!node.isLeaf) {
        _collectLabels(node.children!, labels);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    final List<ParkTreeNode> visibleNodes = _keyword.trim().isEmpty
        ? widget.nodes
        : _filterNodes(widget.nodes, _keyword.trim().toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.searchable)
          Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: TextField(
              onChanged: (String value) {
                setState(() {
                  _keyword = value;
                });
              },
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.searchHintText,
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(park.radius.md),
                ),
              ),
            ),
          ),
        // maxTagCount 标签展示
        if (widget.multiple && widget.maxTagCount != null)
          _buildSelectedTags(park),
        ...visibleNodes.map((node) => _buildNode(node, 0, park)),
      ],
    );
  }

  Widget _buildSelectedTags(ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    final labels = _getSelectedLabels();
    if (labels.isEmpty) return const SizedBox.shrink();

    final maxCount = widget.maxTagCount!;
    final visibleLabels = labels.take(maxCount).toList();
    final overflowCount = labels.length - maxCount;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Wrap(
        spacing: spacing.xs,
        runSpacing: spacing.xs,
        children: [
          ...visibleLabels.map((label) => Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: colors.brand.withValues(alpha: 0.1),
              borderRadius: park.radius.brSm,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: typo.sizeCaption,
                color: colors.brand,
              ),
            ),
          )),
          if (overflowCount > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: park.radius.brSm,
              ),
              child: Text(
                '+$overflowCount',
                style: TextStyle(
                  fontSize: typo.sizeCaption,
                  color: colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<ParkTreeNode> _filterNodes(List<ParkTreeNode> nodes, String keyword) {
    final List<ParkTreeNode> result = <ParkTreeNode>[];

    for (final ParkTreeNode node in nodes) {
      final bool selfMatched = node.label.toLowerCase().contains(keyword);
      final List<ParkTreeNode> matchedChildren = node.children == null
          ? const <ParkTreeNode>[]
          : _filterNodes(node.children!, keyword);

      if (selfMatched || matchedChildren.isNotEmpty) {
        result.add(
          ParkTreeNode(
            key: node.key,
            label: node.label,
            disabled: node.disabled,
            children: matchedChildren.isEmpty ? node.children : matchedChildren,
          ),
        );
      }
    }

    return result;
  }

  Widget _buildNode(ParkTreeNode node, int depth, ParkThemeData park) {
    final colors = park.colors;
    final typo = park.typography;
    final spacing = park.spacing;

    final isExpanded = _expandedKeys.contains(node.key);
    final checkState = _getCheckState(node);
    final isSelected = _selectedKeys.contains(node.key);
    final indent = depth * 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: node.disabled ? null : () => _toggleNode(node),
          child: Container(
            padding: EdgeInsets.only(
              left: spacing.sm + indent,
              right: spacing.sm,
              top: spacing.sm,
              bottom: spacing.sm,
            ),
            child: Row(
              children: [
                // 展开/折叠图标
                SizedBox(
                  width: 20,
                  child: node.isLeaf
                      ? (widget.treeLine && depth > 0
                          ? Container(
                              width: 1,
                              height: 20,
                              color: colors.divider,
                            )
                          : const SizedBox.shrink())
                      : GestureDetector(
                          onTap: () => _toggleExpand(node),
                          child: widget.switcherIcon != null
                              ? widget.switcherIcon!(isExpanded)
                              : AnimatedRotation(
                                  turns: isExpanded ? 0.25 : 0,
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: colors.textSecondary,
                                  ),
                                ),
                        ),
                ),

                // 复选框
                if (widget.checkable) ...[
                  _buildCheckbox(checkState, node.disabled, park),
                  SizedBox(width: spacing.sm),
                ],

                // 标签
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontSize: typo.sizeBody,
                      color: node.disabled
                          ? colors.textDisabled
                          : isSelected || checkState == _CheckState.checked
                          ? colors.brand
                          : colors.textPrimary,
                      fontWeight: isSelected
                          ? typo.weightMedium
                          : typo.weightRegular,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 子节点（展开时显示）+ 连接线
        if (isExpanded && !node.isLeaf)
          ...node.children!.map(
            (child) => _buildNodeWithLine(child, depth + 1, park),
          ),
      ],
    );
  }

  Widget _buildNodeWithLine(
    ParkTreeNode node,
    int depth,
    ParkThemeData park,
  ) {
    if (!widget.treeLine) {
      return _buildNode(node, depth, park);
    }

    final colors = park.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧连接线缩进区域
        SizedBox(
          width: depth * 24.0 + park.spacing.sm,
          child: CustomPaint(
            size: const Size(24, 40),
            painter: _TreeLinePainter(
              color: colors.divider,
              depth: 0,
            ),
          ),
        ),
        Expanded(
          child: _buildNode(node, 0, park),
        ),
      ],
    );
  }

  Widget _buildCheckbox(_CheckState state, bool disabled, ParkThemeData park) {
    final colors = park.colors;

    final borderColor = disabled
        ? colors.textDisabled
        : state == _CheckState.checked || state == _CheckState.indeterminate
        ? colors.brand
        : colors.border;

    final bgColor = disabled && state == _CheckState.checked
        ? colors.textDisabled
        : state == _CheckState.checked || state == _CheckState.indeterminate
        ? colors.brand
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: borderColor, width: 1.5),
        color: bgColor,
      ),
      alignment: Alignment.center,
      child: state == _CheckState.checked
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : state == _CheckState.indeterminate
          ? Container(width: 8, height: 2, color: Colors.white)
          : null,
    );
  }
}

/// 树连接线画笔
class _TreeLinePainter extends CustomPainter {
  final Color color;
  final int depth;

  _TreeLinePainter({required this.color, required this.depth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 垂直线
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // 水平分支线
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TreeLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.depth != depth;
  }
}

/// 复选框状态
enum _CheckState { unchecked, checked, indeterminate }
