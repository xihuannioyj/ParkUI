import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkRowPage Demo
// =============================================================================

class RowPageDemo extends StatelessWidget {
  const RowPageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('RowPage 行容器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('将多个行条目水平等分排列，适合数据概览/汇总场景。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkRowPage(
          items: [
            ParkRowPageItem(label: '在租房源', value: '128'),
            ParkRowPageItem(label: '待审核', value: '6'),
            ParkRowPageItem(label: '已下架', value: '23'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('带标题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkRowPage(
          title: '本月经营数据',
          items: [
            ParkRowPageItem(label: '订单数', value: '1,286'),
            ParkRowPageItem(label: '成交额', value: '¥86.4万'),
            ParkRowPageItem(label: '续约率', value: '92%'),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('自定义尾部组件', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkRowPage(
          title: '账户概览',
          items: [
            ParkRowPageItem(
              label: '账户余额',
              value: '¥12,680.50',
              trailing: ParkIcon(
                Icons.visibility_outlined,
                pixelSize: 16,
                color: park.colors.textPlaceholder,
                container: ParkIconContainer.none,
              ),
            ),
            ParkRowPageItem(
              label: '待结算',
              value: '¥3,200.00',
              trailing: Text(
                '3天后到账',
                style: TextStyle(
                  fontSize: 11,
                  color: park.colors.textPlaceholder,
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
