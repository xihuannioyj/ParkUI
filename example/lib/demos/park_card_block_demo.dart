import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkCardBlock Demo
// =============================================================================

class CardBlockDemo extends StatelessWidget {
  const CardBlockDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('CardBlock 卡片块', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('白卡容器：标题 + 扩展区 + 内容块列表，用于页面分区组织。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCardBlock(
          title: '基础信息',
          widgetList: [
            const ParkFormRow(
              label: '房源名称',
              child: ParkCell(
                size: ParkCellSize.small,
                titleText: '阳光花园 3 栋 502',
                bordered: false,
              ),
            ),
            const ParkFormRow(
              label: '户型',
              child: ParkCell(
                size: ParkCellSize.small,
                titleText: '三室一厅 · 89㎡',
                bordered: false,
              ),
            ),
            const ParkFormRow(
              label: '租金',
              child: ParkCell(
                size: ParkCellSize.small,
                titleText: '¥4,800/月',
                bordered: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('带扩展区', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCardBlock(
          title: '房源图片',
          extensionWidget: IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () => ParkToast.show(context, '添加图片'),
            tooltip: '添加图片',
          ),
          widgetList: [
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 3 ? 0 : 8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: park.colors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: park.colors.textPlaceholder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
