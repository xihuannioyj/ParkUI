import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';

/// 通用行容器组件：列表行布局。
///
/// 将多个 [ParkRowPageItem] 水平等分排列，每个条目包含
/// 上方的 label 与下方的值容器；可选 [title] 作为整组标题。
class ParkRowPage extends StatelessWidget {
  /// 可选组标题。
  final String? title;

  /// 行条目列表。
  final List<ParkRowPageItem> items;

  const ParkRowPage({super.key, required this.items, this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    final List<Widget> itemWidgets = [];
    for (int index = 0; index < items.length; index++) {
      itemWidgets.add(_getRowWidget(items[index], theme, park));
      if (index != items.length - 1) {
        itemWidgets.add(const SizedBox(width: 10));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: park.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: itemWidgets,
          ),
        ],
      ),
    );
  }

  // 获取行数据
  Widget _getRowWidget(
    ParkRowPageItem item,
    ThemeData theme,
    ParkThemeData park,
  ) {
    final List<Widget> valueChildren = [
      Expanded(
        child: Text(
          item.value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: park.colors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
    if (item.trailing != null) {
      valueChildren.add(const SizedBox(width: 4));
      valueChildren.add(item.trailing!);
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: park.colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: park.colors.background,
              borderRadius: BorderRadius.circular(park.radius.md),
              border: Border.all(
                color: park.colors.border.withValues(alpha: 0.9),
              ),
            ),
            child: Row(children: valueChildren),
          ),
        ],
      ),
    );
  }
}

/// 行容器条目：单行内容配置。
class ParkRowPageItem {
  /// 条目标签。
  final String label;

  /// 条目值。
  final String value;

  /// 可选尾部组件。
  final Widget? trailing;

  const ParkRowPageItem({
    required this.label,
    required this.value,
    this.trailing,
  });
}
