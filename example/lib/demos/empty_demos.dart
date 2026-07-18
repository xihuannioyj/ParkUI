import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Empty Demo
// =============================================================================

class EmptyDemo extends StatelessWidget {
  const EmptyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Empty 空状态', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('空状态占位符，支持多种类型变体、自定义图片和操作按钮。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 类型变体 ---
        ParkText('类型变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 180,
                child: ParkEmpty(type: ParkEmptyType.noData),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 180,
                child: ParkEmpty(type: ParkEmptyType.noResults),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 180,
                child: ParkEmpty(type: ParkEmptyType.noPermission),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 自定义描述 ---
        ParkText('自定义描述', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ParkEmpty(
            description: '暂无订单数据，快去下单吧！',
            icon: Icons.shopping_cart,
          ),
        ),
        const SizedBox(height: 24),

        // --- 自定义图片 ---
        ParkText('自定义图片', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ParkEmpty(
            image: Icon(Icons.cloud_off, size: 80,
                color: Colors.grey.shade300),
            description: '没有云端数据同步',
          ),
        ),
        const SizedBox(height: 24),

        // --- 带操作按钮 ---
        ParkText('带操作按钮', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ParkEmpty(
            type: ParkEmptyType.noData,
            actions: [
              ParkButton(
                variant: ParkButtonVariant.primary,
                onPressed: () {},
                child: const Text('立即创建'),
              ),
              ParkButton(
                variant: ParkButtonVariant.secondary,
                onPressed: () {},
                child: const Text('了解更多'),
              ),
            ],
            footer: ParkText('提示：最多创建 10 条数据',
                preset: ParkTextPreset.caption),
          ),
        ),
        const SizedBox(height: 24),

        // --- 尺寸 ---
        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 120,
                child: ParkEmpty(
                  size: ParkEmptySize.small,
                  description: 'Small',
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 180,
                child: ParkEmpty(
                  size: ParkEmptySize.medium,
                  description: 'Medium',
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 240,
                child: ParkEmpty(
                  size: ParkEmptySize.large,
                  description: 'Large',
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
