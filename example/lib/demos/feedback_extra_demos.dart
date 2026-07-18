import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Tour Demo
// =============================================================================

class TourDemo extends StatefulWidget {
  const TourDemo({super.key});

  @override
  State<TourDemo> createState() => _TourDemoState();
}

class _TourDemoState extends State<TourDemo> {
  final GlobalKey _step1Key = GlobalKey();
  final GlobalKey _step2Key = GlobalKey();
  final GlobalKey _step3Key = GlobalKey();
  bool _tourOpen = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ParkText('Tour 引导步骤', preset: ParkTextPreset.h2),
            const SizedBox(height: 8),
            ParkText('新手指引组件，通过遮罩高亮和气泡卡片引导用户了解页面功能。',
                preset: ParkTextPreset.caption),
            const SizedBox(height: 24),

            ParkText('基础用法', preset: ParkTextPreset.h3),
            const SizedBox(height: 12),
            ParkText('点击下方按钮启动引导，将依次高亮三个目标元素。',
                preset: ParkTextPreset.caption),
            const SizedBox(height: 16),

            // Target elements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  key: _step1Key,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.search, size: 32, color: Colors.blue),
                ),
                Container(
                  key: _step2Key,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.favorite, size: 32, color: Colors.green),
                ),
                Container(
                  key: _step3Key,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.settings, size: 32, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () => setState(() => _tourOpen = true),
              child: const Text('开始引导'),
            ),
            const SizedBox(height: 16),
            const ParkDivider(),
          ],
        ),

        // Tour overlay
        if (_tourOpen)
          ParkTour(
            open: _tourOpen,
            steps: [
              ParkTourStep(
                target: _step1Key,
                title: '搜索功能',
                description: '点击这里可以搜索您需要的内容。',
                placement: ParkTourPlacement.bottom,
              ),
              ParkTourStep(
                target: _step2Key,
                title: '收藏功能',
                description: '收藏您喜欢的项目，方便快速访问。',
                placement: ParkTourPlacement.bottom,
              ),
              ParkTourStep(
                target: _step3Key,
                title: '系统设置',
                description: '在这里管理您的偏好设置和账户信息。',
                placement: ParkTourPlacement.bottom,
              ),
            ],
            onClose: () => setState(() => _tourOpen = false),
            onFinish: () => setState(() => _tourOpen = false),
          ),
      ],
    );
  }
}

// =============================================================================
// Popover Demo
// =============================================================================

class PopoverDemo extends StatelessWidget {
  const PopoverDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Popover 气泡卡片', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('点击或悬浮时在目标元素旁弹出气泡卡片，支持自定义内容和方向。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法（点击触发）', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            ParkPopover(
              direction: ParkPopoverDirection.bottom,
              triggerMode: ParkPopoverTrigger.click,
              content: Container(
                padding: const EdgeInsets.all(12),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('气泡标题',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 8),
                    Text('这是一段气泡卡片内容。'),
                  ],
                ),
              ),
              trigger: ParkButton(
                variant: ParkButtonVariant.primary,
                child: const Text('点击弹出'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('不同方向', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final dir in [
              ParkPopoverDirection.top,
              ParkPopoverDirection.bottom,
              ParkPopoverDirection.left,
              ParkPopoverDirection.right,
            ])
              ParkPopover(
                direction: dir,
                content: Container(
                  padding: const EdgeInsets.all(12),
                  child: Text('方向: ${dir.name}'),
                ),
                trigger: ParkButton(
                  variant: ParkButtonVariant.secondary,
                  child: Text(dir.name),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('悬浮触发', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            ParkPopover(
              direction: ParkPopoverDirection.bottom,
              triggerMode: ParkPopoverTrigger.hover,
              content: Container(
                padding: const EdgeInsets.all(12),
                child: const Text('悬浮显示的内容'),
              ),
              trigger: ParkButton(
                variant: ParkButtonVariant.secondary,
                child: const Text('悬浮我'),
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
