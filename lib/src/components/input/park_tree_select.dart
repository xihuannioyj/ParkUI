import 'package:flutter/material.dart';
import '../../binding/park_binding_mixin.dart';
import '../../binding/park_binding_service.dart';
import '../../theme/park_theme_data.dart';
import '../display/park_tree.dart';

/// 自定义展开/折叠图标构建器
typedef ParkTreeSwitcherIconBuilder = Widget Function(bool isExpanded);

/// Park 树选择器
///
/// 可展开的树结构，支持单选 / 多选、复选框联动（父子关联）、搜索过滤。
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
///
/// ### 使用新增的 treeCheckable API
///
/// ```dart
/// ParkTreeSelect(
///   nodes: nodes,
///   treeCheckable: true,
///   showSearch: true,
///   defaultCheckedKeys: ['team1'],
///   onCheck: (keys, halfKey) => print('选中: $keys, 半选父: $halfKey'),
/// )
/// ```
class ParkTreeSelect extends StatefulWidget {
  /// 树节点列表
  final List<ParkTreeNode> nodes;

  /// 已选中的节点 key 集合（向后兼容，配合 [checkable] 使用）。
  final Set<String> selectedKeys;

  /// 选中状态变更回调（向后兼容）。
  final ValueChanged<Set<String>>? onChanged;

  /// 是否多选模式（向后兼容）。
  final bool multiple;

  /// 是否显示复选框（向后兼容，默认 true）。
  final bool checkable;

  /// 是否启用搜索（向后兼容）。
  final bool searchable;

  /// 搜索框占位文案。
  final String searchHintText;

  /// 父子节点选中状态是否严格独立（向后兼容）。
  final bool treeCheckStrictly;

  /// 初始化时是否展开所有节点。
  final bool treeDefaultExpandAll;

  /// 是否显示树形连接线。
  final bool treeLine;

  /// 自定义展开/折叠图标。
  final ParkTreeSwitcherIconBuilder? switcherIcon;

  /// 多选模式下可见选中标签的最大数量。
  final int? maxTagCount;

  /// 绑定键（点号分隔的路径，如 `'treeSelectedKeys'`）。
  final String? bindKey;

  /// 绑定服务实例。
  final ParkBindingService? bindingService;

  // ========================================================================
  // 新增 API（§3.2 TreeSelect 增强）
  // ========================================================================

  /// 启用树复选框模式。
  ///
  /// 为 true 时每个树节点前显示复选框，支持多选、父子联动半选。
  /// 默认 false，此时与 [checkable] 等效。
  final bool treeCheckable;

  /// 是否在弹出面板顶部显示搜索输入框。
  ///
  /// 为 true 时输入实时过滤树节点（大小写不敏感匹配 label）。
  /// 默认 false，此时与 [searchable] 等效。
  final bool showSearch;

  /// 受控选中节点 key 列表（配合 [treeCheckable] 使用）。
  ///
  /// 非 null 时组件使用此值作为受控选中项。
  final List<String>? checkedKeys;

  /// 非受控初始选中 keys（配合 [treeCheckable] 使用）。
  ///
  /// 仅在初始化时生效，后续变化不更新。
  final List<String>? defaultCheckedKeys;

  /// 选中项变化回调（配合 [treeCheckable] 使用）。
  ///
  /// `checkedKeys` 为当前所有选中叶子节点的 key 列表，
  /// `halfCheckedKey` 为当前处于半选状态的父节点 key（可能为 null）。
  final void Function(List<String> checkedKeys, String? halfCheckedKey)? onCheck;

  /// 父子节点选中是否严格独立。
  ///
  /// 为 true 时子节点选中不影响父节点状态，父节点选中不影响子节点。
  /// 默认 false，此时与 [treeCheckStrictly] 等效。
  final bool checkStrictly;

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
    // 新增 API
    this.treeCheckable = false,
    this.showSearch = false,
    this.checkedKeys,
    this.defaultCheckedKeys,
    this.onCheck,
    this.checkStrictly = false,
  });

  /// 是否使用新增 API（treeCheckable 或 showSearch 任一开启）。
  bool get _useNewApi => treeCheckable || showSearch;

  /// 有效复选框显示模式。
  bool get _effectiveCheckable => treeCheckable || checkable;

  /// 有效搜索模式。
  bool get _effectiveSearchable => showSearch || searchable;

  /// 有效严格模式。
  bool get _effectiveCheckStrictly => checkStrictly || treeCheckStrictly;

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

    if (widget._useNewApi) {
      // 新 API 路径
      if (widget.checkedKeys != null) {
        _selectedKeys = Set<String>.from(widget.checkedKeys!);
      } else if (widget.defaultCheckedKeys != null) {
        _selectedKeys = Set<String>.from(widget.defaultCheckedKeys!);
      } else {
        _selectedKeys = Set<String>.from(widget.selectedKeys);
      }
    } else {
      // 向后兼容路径
      final initialValue = boundValue;
      if (initialValue != null) {
        _selectedKeys = Set<String>.from(initialValue);
      } else {
        _selectedKeys = Set<String>.from(widget.selectedKeys);
      }
    }

    _expandedKeys = <String>{};

    if (widget.treeDefaultExpandAll) {
      _expandAll(widget.nodes);
    } else {
      _autoExpandForSelected(widget.nodes);
    }
  }

  void _expandAll(List<ParkTreeNode> nodes) {
    for (final node in nodes) {
      if (!node.isLeaf) {
        _expandedKeys.add(node.key);
        _expandAll(node.children);
      }
    }
  }

  void _autoExpandForSelected(List<ParkTreeNode> nodes) {
    for (final node in nodes) {
      if (!node.isLeaf && _hasSelectedDescendant(node)) {
        _expandedKeys.add(node.key);
        _autoExpandForSelected(node.children);
      }
    }
  }

  bool _hasSelectedDescendant(ParkTreeNode node) {
    if (node.isLeaf) return _selectedKeys.contains(node.key);
    for (final child in node.children) {
      if (_selectedKeys.contains(child.key) || _hasSelectedDescendant(child)) {
        return true;
      }
    }
    return false;
  }

  @override
  void didUpdateWidget(ParkTreeSelect oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._useNewApi) {
      // 新 API：受控 checkedKeys
      if (widget.checkedKeys != null && widget.checkedKeys != oldWidget.checkedKeys) {
        _selectedKeys = Set<String>.from(widget.checkedKeys!);
      }
    } else {
      // 向后兼容：selectedKeys
      if (widget.selectedKeys != oldWidget.selectedKeys) {
        _selectedKeys = Set<String>.from(widget.selectedKeys);
      }
    }
  }

  /// 获取节点选中状态（考虑父子联动，或严格独立模式）。
  _CheckState _getCheckState(ParkTreeNode node) {
    // 严格独立模式：仅判断自身
    if (widget._effectiveCheckStrictly) {
      return _selectedKeys.contains(node.key)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }

    if (node.isLeaf) {
      return _selectedKeys.contains(node.key)
          ? _CheckState.checked
          : _CheckState.unchecked;
    }

    // 收集所有子孙叶子节点的 key
    final leafKeys = <String>[];
    _collectLeafKeys(node, leafKeys);

    final selectedCount =
        leafKeys.where((k) => _selectedKeys.contains(k)).length;

    if (selectedCount == 0) return _CheckState.unchecked;
    if (selectedCount == leafKeys.length) return _CheckState.checked;
    return _CheckState.indeterminate;
  }

  /// 收集节点下所有叶子节点的 key。
  void _collectLeafKeys(ParkTreeNode node, List<String> keys) {
    if (node.isLeaf) {
      keys.add(node.key);
    } else {
      for (final child in node.children) {
        _collectLeafKeys(child, keys);
      }
    }
  }

  /// 查找给定节点最近的半选父节点 key（不含自身）。
  String? _findHalfCheckedParent(ParkTreeNode node) {
    for (final root in widget.nodes) {
      final result = _findHalfCheckedAncestor(root, node.key, <String>{});
      if (result != null) return result;
    }
    return null;
  }

  /// 递归查找是否为指定 key 节点的祖先，并返回半选状态的祖先。
  String? _findHalfCheckedAncestor(
      ParkTreeNode node, String targetKey, Set<String> seen) {
    if (seen.contains(node.key)) return null;
    seen.add(node.key);

    for (final child in node.children) {
      if (child.key == targetKey) {
        // node 是 target 的直接父节点
        final state = _getCheckState(node);
        return state == _CheckState.indeterminate ? node.key : null;
      }
      final result = _findHalfCheckedAncestor(child, targetKey, seen);
      if (result != null) return result;
    }
    return null;
  }

  /// 切换节点选中状态。
  void _toggleNode(ParkTreeNode node) {
    if (node.disabled) return;

    setState(() {
      if (widget._effectiveCheckable) {
        // 复选框模式
        if (widget._effectiveCheckStrictly) {
          // 严格模式：只切换当前节点自身
          if (_selectedKeys.contains(node.key)) {
            _selectedKeys.remove(node.key);
          } else {
            _selectedKeys.add(node.key);
          }
        } else {
          // 联动模式
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
            _collectLeafKeys(node, leafKeys);
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
        // 非复选框模式（单选）
        if (node.isLeaf) {
          _selectedKeys = {_selectedKeys.contains(node.key) ? '' : node.key};
          _selectedKeys.remove('');
        }
      }
    });

    // 回调通知
    widget.onChanged?.call(Set<String>.from(_selectedKeys));
    boundValue = Set<String>.from(_selectedKeys);

    if (widget._useNewApi) {
      final checkedList = _selectedKeys.toList()..sort();
      String? halfKey;
      if (!widget._effectiveCheckStrictly && !node.isLeaf && widget.treeCheckable) {
        halfKey = _findHalfCheckedParent(node);
      }
      widget.onCheck?.call(checkedList, halfKey);
    }
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

  /// 收集所有可见的已选节点标签（用于 maxTagCount 显示）。
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
        _collectLabels(node.children, labels);
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
        // 搜索输入框（使用有效搜索模式）
        if (widget._effectiveSearchable)
          Padding(
            padding: EdgeInsets.only(bottom: park.spacing.sm),
            child: Semantics(
              label: '搜索树节点',
              child: TextField(
                onChanged: (String value) {
                  setState(() {
                    _keyword = value;
                  });
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.searchHintText,
                  prefixIcon: Icon(Icons.search, size: park.spacing.base),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(park.radius.md),
                  ),
                ),
              ),
            ),
          ),
        // 多选标签展示
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
              vertical: spacing.xxs,
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
                vertical: spacing.xxs,
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

  /// 过滤树节点（大小写不敏感匹配 label）。
  List<ParkTreeNode> _filterNodes(List<ParkTreeNode> nodes, String keyword) {
    final List<ParkTreeNode> result = <ParkTreeNode>[];

    for (final ParkTreeNode node in nodes) {
      final bool selfMatched = node.label.toLowerCase().contains(keyword);
      final List<ParkTreeNode> matchedChildren = node.children.isEmpty
          ? const <ParkTreeNode>[]
          : _filterNodes(node.children, keyword);

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
    final indent = depth * spacing.xl;

    final checkLabel = widget._effectiveCheckable
        ? switch (checkState) {
            _CheckState.checked => ', 已选中',
            _CheckState.indeterminate => ', 部分选中',
            _CheckState.unchecked => ', 未选中',
          }
        : isSelected
            ? ', 已选'
            : '';
    final expandLabel = !node.isLeaf
        ? ', ${isExpanded ? "已展开" : "已折叠"}'
        : '';
    final disabledLabel = node.disabled ? ', 已禁用' : '';
    final nodeLabel =
        '${node.label}$checkLabel$expandLabel$disabledLabel';

    return Semantics(
      label: nodeLabel,
      child: Column(
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
                    width: spacing.lg,
                    child: node.isLeaf
                        ? (widget.treeLine && depth > 0
                            ? Container(
                                width: 1,
                                height: spacing.lg,
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

                  // 复选框（使用有效复选框模式）
                  if (widget._effectiveCheckable) ...[
                    _buildCheckbox(checkState, node.disabled, park),
                    SizedBox(width: spacing.sm),
                  ],

                  // 标签（带搜索高亮）
                  Expanded(
                    child: _keyword.trim().isEmpty
                        ? Text(
                            node.label,
                            style: TextStyle(
                              fontSize: typo.sizeBody,
                              color: node.disabled
                                  ? colors.textDisabled
                                  : isSelected ||
                                          checkState == _CheckState.checked
                                      ? colors.brand
                                      : colors.textPrimary,
                              fontWeight: isSelected
                                  ? typo.weightMedium
                                  : typo.weightRegular,
                            ),
                          )
                        : _buildHighlightedText(
                            node.label, _keyword.trim(), isSelected,
                            node.disabled, park),
                  ),
                ],
              ),
            ),
          ),

          // 子节点（展开时显示）+ 连接线
          if (isExpanded && !node.isLeaf)
            ...node.children.map(
              (child) => _buildNodeWithLine(child, depth + 1, park),
            ),
        ],
      ),
    );
  }

  /// 构建带搜索高亮的标签文字。
  Widget _buildHighlightedText(
    String label,
    String keyword,
    bool isSelected,
    bool disabled,
    ParkThemeData park,
  ) {
    final colors = park.colors;
    final typo = park.typography;

    final baseStyle = TextStyle(
      fontSize: typo.sizeBody,
      color: disabled
          ? colors.textDisabled
          : isSelected
              ? colors.brand
              : colors.textPrimary,
      fontWeight: isSelected ? typo.weightMedium : typo.weightRegular,
    );

    if (keyword.isEmpty) {
      return Text(label, style: baseStyle);
    }

    final lowerLabel = label.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    final spans = <InlineSpan>[];
    int start = 0;

    int idx;
    while ((idx = lowerLabel.indexOf(lowerKeyword, start)) != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: label.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: label.substring(idx, idx + keyword.length),
        style: TextStyle(
          backgroundColor: colors.warning.withAlpha(60),
          color: colors.brand,
          fontWeight: typo.weightMedium,
        ),
      ));
      start = idx + keyword.length;
    }
    if (start < label.length) {
      spans.add(TextSpan(text: label.substring(start)));
    }

    return Text.rich(
      TextSpan(children: spans, style: baseStyle),
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
          width: depth * park.spacing.xl + park.spacing.sm,
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
    final spacing = park.spacing;

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

    return Semantics(
      label: disabled ? '复选框，已禁用' : '复选框',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: spacing.lg,
        height: spacing.lg,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(park.radius.xs),
          border: Border.all(color: borderColor, width: 1.5),
          color: bgColor,
        ),
        alignment: Alignment.center,
        child: state == _CheckState.checked
            ? Icon(Icons.check, size: spacing.base - 4, color: Colors.white)
            : state == _CheckState.indeterminate
                ? Container(
                    width: spacing.sm,
                    height: spacing.xxs,
                    color: Colors.white)
                : null,
      ),
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
