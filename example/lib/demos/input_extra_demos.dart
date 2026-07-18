import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Cascader Demo
// =============================================================================

class CascaderDemo extends StatelessWidget {
  const CascaderDemo({super.key});

  static const List<ParkCascaderOption> _areaOptions = [
    ParkCascaderOption(
      label: '浙江省',
      value: 'zj',
      children: [
        ParkCascaderOption(
          label: '杭州市',
          value: 'hz',
          children: [
            ParkCascaderOption(label: '西湖区', value: 'xh'),
            ParkCascaderOption(label: '余杭区', value: 'yh'),
          ],
        ),
        ParkCascaderOption(
          label: '宁波市',
          value: 'nb',
          children: [
            ParkCascaderOption(label: '海曙区', value: 'hs'),
            ParkCascaderOption(label: '鄞州区', value: 'yz'),
          ],
        ),
      ],
    ),
    ParkCascaderOption(
      label: '江苏省',
      value: 'js',
      children: [
        ParkCascaderOption(
          label: '南京市',
          value: 'nj',
          children: [
            ParkCascaderOption(label: '玄武区', value: 'xw'),
            ParkCascaderOption(label: '鼓楼区', value: 'gl'),
          ],
        ),
        ParkCascaderOption(
          label: '苏州市',
          value: 'sz',
          children: [
            ParkCascaderOption(label: '姑苏区', value: 'gu'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Cascader 级联选择', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('多级级联选择器，支持省市区等多层级数据选择。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCascader(
          label: '所在地区',
          hintText: '请选择省/市/区',
          options: _areaOptions,
          onChanged: (path) {},
        ),
        const SizedBox(height: 24),

        ParkText('搜索模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCascader(
          label: '搜索选择',
          hintText: '输入关键词搜索',
          options: _areaOptions,
          showSearch: true,
          onChanged: (path) {},
        ),
        const SizedBox(height: 24),

        ParkText('选择中间层级', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCascader(
          label: '选择省份',
          hintText: '可选择任意层级',
          options: _areaOptions,
          changeOnSelect: true,
          onChanged: (path) {},
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// TreeSelect Demo
// =============================================================================

class TreeSelectDemo extends StatelessWidget {
  const TreeSelectDemo({super.key});

  static const List<ParkTreeNode> _deptNodes = [
    ParkTreeNode(
      key: 'root',
      label: '总公司',
      children: [
        ParkTreeNode(
          key: 'dev',
          label: '研发部',
          children: [
            ParkTreeNode(key: 'fe', label: '前端组'),
            ParkTreeNode(key: 'be', label: '后端组'),
            ParkTreeNode(key: 'qa', label: '测试组'),
          ],
        ),
        ParkTreeNode(
          key: 'design',
          label: '设计部',
          children: [
            ParkTreeNode(key: 'ui', label: 'UI 设计'),
            ParkTreeNode(key: 'ux', label: 'UX 研究'),
          ],
        ),
        ParkTreeNode(
          key: 'ops',
          label: '运维部',
          children: [
            ParkTreeNode(key: 'infra', label: '基础设施'),
            ParkTreeNode(key: 'sec', label: '安全组'),
          ],
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('TreeSelect 树形选择', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('树形结构选择器，支持单选/多选、复选框联动和搜索过滤。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础树选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkTreeSelect(
              nodes: _deptNodes,
              selectedKeys: _treeSelectedKeys,
              checkable: true,
              treeDefaultExpandAll: true,
              onChanged: (keys) => setState(() => _treeSelectedKeys = keys),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('带搜索', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkTreeSelect(
              nodes: _deptNodes,
              selectedKeys: _treeSearchKeys,
              checkable: true,
              showSearch: true,
              treeDefaultExpandAll: true,
              onChanged: (keys) => setState(() => _treeSearchKeys = keys),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('连接线风格', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkTreeSelect(
              nodes: _deptNodes,
              selectedKeys: _treeLineKeys,
              checkable: true,
              treeLine: true,
              treeDefaultExpandAll: true,
              onChanged: (keys) => setState(() => _treeLineKeys = keys),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

Set<String> _treeSelectedKeys = {};
Set<String> _treeSearchKeys = {};
Set<String> _treeLineKeys = {};

// =============================================================================
// Calendar Demo
// =============================================================================

class CalendarDemo extends StatelessWidget {
  const CalendarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Calendar 日历', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('日历组件，支持单日选择、范围选择，可设置日期范围和禁用日期。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('单日选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkCalendar(
              value: _calendarDate,
              onChanged: (date) => setState(() => _calendarDate = date),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('范围选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkCalendar(
              selectionMode: ParkCalendarSelectionMode.range,
              rangeStart: _rangeStart,
              rangeEnd: _rangeEnd,
              onRangeChange: (start, end) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                });
              },
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('限制日期范围', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            final now = DateTime.now();
            return ParkCalendar(
              value: _limitedDate,
              minDate: DateTime(now.year, now.month, 1),
              maxDate: DateTime(now.year, now.month + 1, 0),
              disabledDate: (date) =>
                  date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday,
              onChanged: (date) => setState(() => _limitedDate = date),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

DateTime? _calendarDate;
DateTime? _rangeStart;
DateTime? _rangeEnd;
DateTime? _limitedDate;

// =============================================================================
// Segmented Demo
// =============================================================================

class SegmentedDemo extends StatelessWidget {
  const SegmentedDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Segmented 分段控制', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('在一组互斥选项中切换，选中态有滑块动画过渡。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSegmented(
              items: const [
                ParkSegmentedItem(value: 'day', label: '日'),
                ParkSegmentedItem(value: 'week', label: '周'),
                ParkSegmentedItem(value: 'month', label: '月'),
                ParkSegmentedItem(value: 'year', label: '年'),
              ],
              value: _segValue,
              onChanged: (v) => setState(() => _segValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('带图标', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSegmented(
              items: const [
                ParkSegmentedItem(
                    value: 'list', label: '列表', icon: Icon(Icons.list)),
                ParkSegmentedItem(
                    value: 'grid', label: '网格', icon: Icon(Icons.grid_view)),
                ParkSegmentedItem(
                    value: 'card', label: '卡片', icon: Icon(Icons.credit_card)),
              ],
              value: _segIconValue,
              onChanged: (v) => setState(() => _segIconValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return ParkSegmented(
                  items: const [
                    ParkSegmentedItem(value: 's1', label: '选项一'),
                    ParkSegmentedItem(value: 's2', label: '选项二'),
                    ParkSegmentedItem(value: 's3', label: '选项三'),
                  ],
                  size: ParkSegmentedSize.small,
                  value: _segSizeSmall,
                  onChanged: (v) => setState(() => _segSizeSmall = v),
                );
              },
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return ParkSegmented(
                  items: const [
                    ParkSegmentedItem(value: 'l1', label: '选项一'),
                    ParkSegmentedItem(value: 'l2', label: '选项二'),
                    ParkSegmentedItem(value: 'l3', label: '选项三'),
                  ],
                  size: ParkSegmentedSize.large,
                  value: _segSizeLarge,
                  onChanged: (v) => setState(() => _segSizeLarge = v),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('撑满宽度', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSegmented(
              block: true,
              items: const [
                ParkSegmentedItem(value: 'tab1', label: '标签一'),
                ParkSegmentedItem(value: 'tab2', label: '标签二'),
                ParkSegmentedItem(value: 'tab3', label: '标签三'),
              ],
              value: _segBlock,
              onChanged: (v) => setState(() => _segBlock = v),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

String _segValue = 'day';
String _segIconValue = 'list';
String _segSizeSmall = 's1';
String _segSizeLarge = 'l1';
String _segBlock = 'tab1';

// =============================================================================
// Transfer Demo
// =============================================================================

class TransferDemo extends StatelessWidget {
  const TransferDemo({super.key});

  static const List<ParkTransferItem> _allItems = [
    ParkTransferItem(key: '1', title: '用户管理'),
    ParkTransferItem(key: '2', title: '角色配置'),
    ParkTransferItem(key: '3', title: '权限分配'),
    ParkTransferItem(key: '4', title: '日志审计'),
    ParkTransferItem(key: '5', title: '数据备份'),
    ParkTransferItem(key: '6', title: '系统设置'),
    ParkTransferItem(key: '7', title: '消息通知'),
    ParkTransferItem(key: '8', title: '文件管理'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Transfer 穿梭框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('双栏列表选择，用于权限分配、角色选择等场景。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkTransfer(
              dataSource: _allItems,
              targetKeys: _transferKeys,
              leftTitle: const Text('可选'),
              rightTitle: const Text('已选'),
              onChange: (keys, dir) =>
                  setState(() => _transferKeys = keys),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('带搜索', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkTransfer(
              dataSource: _allItems,
              targetKeys: _transferSearchKeys,
              showSearch: true,
              leftTitle: const Text('源列表'),
              rightTitle: const Text('目标列表'),
              onChange: (keys, dir) =>
                  setState(() => _transferSearchKeys = keys),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('单向模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkTransfer(
              dataSource: _allItems.sublist(0, 5),
              targetKeys: _transferOneWayKeys,
              oneWay: true,
              leftTitle: const Text('待分配'),
              rightTitle: const Text('已分配'),
              onChange: (keys, dir) =>
                  setState(() => _transferOneWayKeys = keys),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

List<String> _transferKeys = ['3', '5'];
List<String> _transferSearchKeys = ['2'];
List<String> _transferOneWayKeys = ['1'];
