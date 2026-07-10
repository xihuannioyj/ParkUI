import 'package:flutter/material.dart';
import '../../theme/park_theme_data.dart';

/// 锚点导航组件
///
/// 监听滚动位置，自动高亮当前区域对应的导航项。
/// 点击导航项平滑滚动到目标区域。
///
/// ```dart
/// ParkAnchor(
///   items: [
///     ParkAnchorItem(key: 'basic', label: '基础信息'),
///     ParkAnchorItem(key: 'detail', label: '详细信息'),
///     ParkAnchorItem(key: 'setting', label: '设置'),
///   ],
///   scrollController: _scrollController,
/// )
/// ```
class ParkAnchor extends StatefulWidget {
  /// 锚点项列表。
  final List<ParkAnchorItem> items;

  /// 关联的滚动控制器。
  final ScrollController? scrollController;

  /// 选中项回调。
  final void Function(String key)? onChanged;

  /// 锚点偏移量（默认 80，考虑顶栏高度）。
  final double offset;

  /// 创建 [ParkAnchor]。
  const ParkAnchor({
    super.key,
    required this.items,
    this.scrollController,
    this.onChanged,
    this.offset = 80,
  });

  @override
  State<ParkAnchor> createState() => _ParkAnchorState();
}

class _ParkAnchorState extends State<ParkAnchor> {
  String? _activeKey;

  @override
  void initState() {
    super.initState();
    if (widget.items.isNotEmpty) {
      _activeKey = widget.items.first.key;
    }
  }

  void _handleTap(String key) {
    setState(() => _activeKey = key);
    widget.onChanged?.call(key);
  }

  @override
  Widget build(BuildContext context) {
    final park = Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widget.items.map((item) {
        final isActive = item.key == _activeKey;
        return GestureDetector(
          onTap: () => _handleTap(item.key),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: isActive
                  ? Border(left: BorderSide(color: park.colors.brand, width: 3))
                  : null,
            ),
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? park.colors.brand : park.colors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 锚点项数据模型。
class ParkAnchorItem {
  /// 锚点键（与目标 widget 的 key 匹配）。
  final String key;

  /// 显示标签。
  final String label;

  /// 创建 [ParkAnchorItem]。
  const ParkAnchorItem({
    required this.key,
    required this.label,
  });
}
