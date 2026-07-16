import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Tree Demo
// =============================================================================

class TreeDemo extends StatelessWidget {
  const TreeDemo({super.key});

  static const List<ParkTreeNode> _treeData = [
    ParkTreeNode(
      key: '1',
      label: '技术中心',
      icon: Icons.business,
      children: [
        ParkTreeNode(key: '1-1', label: '前端组'),
        ParkTreeNode(key: '1-2', label: '后端组'),
        ParkTreeNode(
          key: '1-3',
          label: '移动端组',
          children: [
            ParkTreeNode(key: '1-3-1', label: 'iOS'),
            ParkTreeNode(key: '1-3-2', label: 'Android'),
          ],
        ),
      ],
    ),
    ParkTreeNode(
      key: '2',
      label: '产品中心',
      icon: Icons.business,
      children: [
        ParkTreeNode(key: '2-1', label: '设计组'),
        ParkTreeNode(key: '2-2', label: '产品组'),
      ],
    ),
    ParkTreeNode(key: '3', label: '市场部', icon: Icons.business),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Tree 树形控件', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('递归节点渲染、展开/折叠、多选、异步加载。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础树', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTree(
          data: _treeData,
          defaultExpandedKeys: const {'1'},
          onSelect: (key) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: $key')),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('多选模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTree(
          data: _treeData,
          multiSelect: true,
          defaultExpandedKeys: const {'1', '2'},
          onMultiSelect: (keys) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected: $keys')),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('连线样式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTree(
          data: _treeData,
          showLine: true,
          defaultExpandedKeys: const {'1'},
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
