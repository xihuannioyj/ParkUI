import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';
import '../base/park_button.dart';
import '../base/park_button_style.dart';

/// 穿梭框组件
///
/// 双栏列表选择，支持搜索、全选、拖拽排序。
/// 用于权限分配、角色选择、字段映射等场景。
///
/// ```dart
/// ParkTransfer(
///   dataSource: [
///     ParkTransferItem(key: '1', title: '选项A'),
///     ParkTransferItem(key: '2', title: '选项B'),
///   ],
///   targetKeys: ['2'],
///   onChange: (keys, direction) => print('$direction: $keys'),
/// )
/// ```
class ParkTransfer extends StatefulWidget {
  /// 所有可选项列表。
  final List<ParkTransferItem> dataSource;

  /// 已选中的目标 key 列表。
  final List<String>? targetKeys;

  /// 选中变更回调（返回当前目标 keys + 移动方向）。
  final void Function(List<String> targetKeys, TransferDirection direction)? onChange;

  /// 左侧标题。
  final String? leftTitle;

  /// 右侧标题。
  final String? rightTitle;

  /// 是否显示搜索框。
  final bool showSearch;

  /// 是否禁用。
  final bool disabled;

  /// 自定义渲染项。
  final Widget Function(ParkTransferItem item, bool selected)? renderItem;

  /// 创建 [ParkTransfer]。
  const ParkTransfer({
    super.key,
    required this.dataSource,
    this.targetKeys,
    this.onChange,
    this.leftTitle = '待选',
    this.rightTitle = '已选',
    this.showSearch = false,
    this.disabled = false,
    this.renderItem,
  });

  @override
  State<ParkTransfer> createState() => _ParkTransferState();
}

/// 穿梭方向。
enum TransferDirection { leftToRight, rightToLeft }

/// 穿梭框项。
class ParkTransferItem {
  final String key;
  final String title;
  final String? subtitle;

  const ParkTransferItem({
    required this.key,
    required this.title,
    this.subtitle,
  });
}

class _ParkTransferState extends State<ParkTransfer> {
  late Set<String> _targetKeys;
  final _leftController = TextEditingController();
  final _rightController = TextEditingController();
  Set<String> _leftSelected = {};
  Set<String> _rightSelected = {};

  @override
  void initState() {
    super.initState();
    _targetKeys = Set<String>.from(widget.targetKeys ?? []);
  }

  List<ParkTransferItem> get _leftItems =>
      widget.dataSource.where((i) => !_targetKeys.contains(i.key)).toList();
  List<ParkTransferItem> get _rightItems =>
      widget.dataSource.where((i) => _targetKeys.contains(i.key)).toList();

  List<ParkTransferItem> _filtered(List<ParkTransferItem> items, String query) {
    if (query.isEmpty) return items;
    return items.where((i) => i.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void _transfer(TransferDirection dir) {
    if (dir == TransferDirection.leftToRight) {
      _targetKeys.addAll(_leftSelected);
      _leftSelected.clear();
    } else {
      _targetKeys.removeAll(_rightSelected);
      _rightSelected.clear();
    }
    setState(() {});
    widget.onChange?.call(_targetKeys.toList(), dir);
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final leftItems = _filtered(_leftItems, _leftController.text);
    final rightItems = _filtered(_rightItems, _rightController.text);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPanel(park, widget.leftTitle ?? '待选', leftItems, _leftSelected, true, _leftController)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ParkButton(
                child: const Icon(Icons.chevron_right, size: 20),
                variant: ParkButtonVariant.secondary,
                size: ParkButtonSize.small,
                onPressed: _leftSelected.isEmpty || widget.disabled ? null : () => _transfer(TransferDirection.leftToRight),
              ),
              const SizedBox(height: 8),
              ParkButton(
                child: const Icon(Icons.chevron_left, size: 20),
                variant: ParkButtonVariant.secondary,
                size: ParkButtonSize.small,
                onPressed: _rightSelected.isEmpty || widget.disabled ? null : () => _transfer(TransferDirection.rightToLeft),
              ),
            ],
          ),
        ),
        Expanded(child: _buildPanel(park, widget.rightTitle ?? '已选', rightItems, _rightSelected, false, _rightController)),
      ],
    );
  }

  Widget _buildPanel(ParkThemeData park, String title, List<ParkTransferItem> items, Set<String> selected, bool isLeft, TextEditingController searchCtrl) {
    final allSelected = items.isNotEmpty && items.every((i) => selected.contains(i.key));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: park.colors.surface,
            border: Border.all(color: park.colors.border),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: park.colors.textPrimary)),
              const Spacer(),
              Text('${items.length}', style: TextStyle(fontSize: 12, color: park.colors.textSecondary)),
            ],
          ),
        ),
        // Search
        if (widget.showSearch)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border(left: BorderSide(color: park.colors.border), right: BorderSide(color: park.colors.border))),
            child: TextField(
              controller: searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '搜索...',
                hintStyle: TextStyle(fontSize: 13, color: park.colors.textPlaceholder),
                border: InputBorder.none,
                isDense: true,
                prefixIconConstraints: const BoxConstraints(maxWidth: 24),
                prefixIcon: Icon(Icons.search, size: 16, color: park.colors.textSecondary),
              ),
              style: TextStyle(fontSize: 13, color: park.colors.textPrimary),
            ),
          ),
        // Body
        SizedBox(
          height: 240,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: park.colors.border),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: items.isEmpty
                ? Center(child: Text('暂无数据', style: TextStyle(fontSize: 13, color: park.colors.textPlaceholder)))
                : Column(
                    children: [
                      // Select all
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (allSelected) selected.clear();
                            else items.forEach((i) => selected.add(i.key));
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: park.colors.borderLight))),
                          child: Row(
                            children: [
                              Icon(allSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: park.colors.brand),
                              const SizedBox(width: 6),
                              Text('全选', style: TextStyle(fontSize: 13, color: park.colors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) => _buildItem(items[i], selected, park),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(ParkTransferItem item, Set<String> selected, ParkThemeData park) {
    final isSel = selected.contains(item.key);
    if (widget.renderItem != null) return widget.renderItem!(item, isSel);

    return InkWell(
      onTap: () => setState(() { isSel ? selected.remove(item.key) : selected.add(item.key); }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? park.colors.brand.withAlpha(13) : null,
          border: Border(bottom: BorderSide(color: park.colors.borderLight)),
        ),
        child: Row(
          children: [
            Icon(isSel ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: isSel ? park.colors.brand : park.colors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(item.title, style: TextStyle(fontSize: 13, color: park.colors.textPrimary))),
            if (item.subtitle != null)
              Text(item.subtitle!, style: TextStyle(fontSize: 11, color: park.colors.textPlaceholder)),
          ],
        ),
      ),
    );
  }
}
