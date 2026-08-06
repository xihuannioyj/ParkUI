import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ParkLoadingPanel Demo
// =============================================================================

class LoadingPanelDemo extends StatelessWidget {
  const LoadingPanelDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final park =
        Theme.of(context).extension<ParkThemeData>() ?? ParkThemeData.light();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('LoadingPanel 加载面板', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('统一局部加载组件：内联加载 + 白卡加载面板。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('ParkInlineLoading 默认', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const SizedBox(
          height: 80,
          child: ParkInlineLoading(),
        ),
        const SizedBox(height: 24),

        ParkText('ParkInlineLoading.page 页面主体加载', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: Container(
            decoration: BoxDecoration(
              color: park.colors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const ParkInlineLoading.page(text: '页面加载中...'),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('ParkInlineLoading.compact 局部占位', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: park.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: park.colors.border),
                  ),
                  child: const ParkInlineLoading.compact(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: park.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: park.colors.border),
                  ),
                  child: const ParkInlineLoading.compact(size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ParkText('ParkInlineLoading.button 按钮内加载', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 120,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: park.colors.brand,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const ParkInlineLoading.button(),
            ),
            const SizedBox(width: 16),
            Container(
              width: 120,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: park.colors.background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: park.colors.border),
              ),
              child: const ParkInlineLoading.button(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('ParkLoadingPanel 白卡面板', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: park.colors.background,
                  child: Center(
                    child: ParkText('底层内容',
                        preset: ParkTextPreset.body,
                        color: park.colors.textSecondary),
                  ),
                ),
              ),
              const Center(
                child: ParkLoadingPanel(text: '加载中...', withMask: false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
