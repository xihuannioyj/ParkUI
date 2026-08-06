import 'package:flutter/material.dart';

import '../../theme/park_theme_data.dart';
import '../base/park_text.dart';

/// 白卡容器组件：标题 + 扩展区 + 内容块列表。
///
/// 垂直排列：标题行（标题文字 + 可选右侧扩展区），下方依次渲染内容块。
class ParkCardBlock extends StatelessWidget {
  /// 标题文字。
  final String title;

  /// 内容块列表。
  final List<Widget> widgetList;

  /// 可选扩展区（标题行右侧，图标自动继承品牌色）。
  final Widget? extensionWidget;

  const ParkCardBlock({
    super.key,
    required this.title,
    required this.widgetList,
    this.extensionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Expanded(
                child: ParkText(
                  title,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: park.colors.textPrimary,
                ),
              ),
              if (extensionWidget != null)
                Container(
                  decoration: BoxDecoration(
                    color: park.colors.brandLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconTheme(
                    data: theme.iconTheme.copyWith(
                      color: park.colors.brand,
                    ),
                    child: extensionWidget!,
                  ),
                ),
            ],
          ),
        ),
        ...widgetList,
      ],
    );
  }
}
