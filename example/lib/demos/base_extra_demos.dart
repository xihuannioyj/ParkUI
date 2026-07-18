import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Flex Demo
// =============================================================================

class FlexDemo extends StatelessWidget {
  const FlexDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Flex 弹性布局', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('统一封装 Row / Column / Wrap，支持 gap、换行和 flex 分配。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('水平布局', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFlex(
          direction: ParkFlexDirection.row,
          gap: 12,
          children: [
            Container(width: 60, height: 40, color: Colors.blue.shade200),
            Container(width: 60, height: 40, color: Colors.green.shade200),
            Container(width: 60, height: 40, color: Colors.orange.shade200),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('垂直布局', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFlex(
          direction: ParkFlexDirection.column,
          gap: 8,
          children: [
            Container(width: double.infinity, height: 30, color: Colors.blue.shade200),
            Container(width: double.infinity, height: 30, color: Colors.green.shade200),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('换行模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFlex(
          wrap: true,
          gap: 8,
          children: List.generate(
            8,
            (i) => Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.primaries[i % Colors.primaries.length].shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('Flex 比例分配', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkFlex(
          flexValues: [1, 2, 1],
          gap: 8,
          children: [
            Container(height: 40, color: Colors.red.shade200),
            Container(height: 40, color: Colors.blue.shade200),
            Container(height: 40, color: Colors.green.shade200),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Typography Demo
// =============================================================================

class TypographyDemo extends StatelessWidget {
  const TypographyDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Typography 标题排版', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('语义化标题组件，支持 1-5 级标题、副标题和复制功能。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('标题级别', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkTitle(text: '一级标题 H1', level: 1),
        const ParkTitle(text: '二级标题 H2', level: 2),
        const ParkTitle(text: '三级标题 H3', level: 3),
        const ParkTitle(text: '四级标题 H4', level: 4),
        const ParkTitle(text: '五级标题 H5', level: 5),
        const SizedBox(height: 24),

        ParkText('带副标题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkTitle(
          text: '项目概览',
          level: 2,
          subtitle: '这是副标题描述文字',
        ),
        const SizedBox(height: 24),

        ParkText('可复制标题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkTitle(text: '点击右侧图标复制', level: 3, copyable: true),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// FloatButton Demo
// =============================================================================

class FloatButtonDemo extends StatelessWidget {
  const FloatButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('FloatButton 悬浮按钮', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('页面级悬浮按钮，支持单按钮和菜单模式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ParkFloatButton(
              icon: Icons.add,
              onPressed: () {},
            ),
            ParkFloatButton(
              icon: Icons.settings,
              type: ParkFloatButtonType.defaultType,
              onPressed: () {},
            ),
            ParkFloatButton(
              icon: Icons.star,
              size: ParkFloatButtonSize.small,
              onPressed: () {},
            ),
            ParkFloatButton(
              icon: Icons.edit,
              shape: ParkFloatButtonShape.rounded,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('菜单模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: const Center(child: Text('预览区域')),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ParkFloatButton(
                  icon: Icons.apps,
                  items: const [
                    ParkFloatButtonItem(icon: Icons.camera_alt, label: '拍照'),
                    ParkFloatButtonItem(icon: Icons.image, label: '相册'),
                    ParkFloatButtonItem(icon: Icons.file_copy, label: '文件'),
                  ],
                ),
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
