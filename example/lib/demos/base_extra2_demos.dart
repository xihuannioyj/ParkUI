import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// InkWell Demo
// =============================================================================

class InkWellDemo extends StatelessWidget {
  const InkWellDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('InkWell 点击容器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('轻量级点击容器，为子组件添加按下缩放、透明度和悬停高亮反馈。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInkWell(
          onTap: () {
            ParkMessage.info(context, '点击了卡片');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.touch_app, color: Colors.blue),
                SizedBox(width: 12),
                Text('点击我试试'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('自定义圆角和动画参数', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInkWell(
          borderRadius: BorderRadius.circular(16),
          pressedScale: 0.95,
          pressedOpacity: 0.7,
          onTap: () {
            ParkMessage.info(context, '圆角容器被点击');
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.rounded_corner, color: Colors.green),
                SizedBox(width: 12),
                Text('自定义缩放和透明度'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        ParkText('禁用状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInkWell(
          disabled: true,
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.block, color: Colors.grey),
                SizedBox(width: 12),
                Text('禁用状态（无交互反馈）'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// ButtonGroup Demo
// =============================================================================

class ButtonGroupDemo extends StatelessWidget {
  const ButtonGroupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('ButtonGroup 按钮组', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('将多个按钮组合在一起，支持连接和均分模式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('连接模式（默认）', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButtonGroup(
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('通过'),
            ),
            ParkButton(
              onPressed: () {},
              child: const Text('驳回'),
            ),
            ParkButton(
              onPressed: () {},
              child: const Text('转办'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('均分模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButtonGroup(
          mode: ParkButtonGroupMode.equal,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('确认'),
            ),
            ParkButton(
              onPressed: () {},
              child: const Text('取消'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('垂直方向', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButtonGroup(
          direction: Axis.vertical,
          children: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('步骤一'),
            ),
            ParkButton(
              onPressed: () {},
              child: const Text('步骤二'),
            ),
            ParkButton(
              onPressed: () {},
              child: const Text('步骤三'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
