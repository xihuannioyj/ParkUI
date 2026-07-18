import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Collapse Demo
// =============================================================================

class CollapseDemo extends StatefulWidget {
  const CollapseDemo({super.key});

  @override
  State<CollapseDemo> createState() => _CollapseDemoState();
}

class _CollapseDemoState extends State<CollapseDemo> {
  Set<String> _activeKeys = {'1'};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Collapse 折叠面板', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('可折叠展开的内容面板，支持手风琴模式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCollapse(
          items: const [
            ParkCollapseItem(
              key: '1',
              title: '一致性 Consistency',
              content: Text('与现实生活一致：与现实生活的标准一致，减少学习成本。'),
            ),
            ParkCollapseItem(
              key: '2',
              title: '可控性 Controllability',
              content: Text('用户决策：控制决策权给用户，增强用户的成就感。'),
            ),
            ParkCollapseItem(
              key: '3',
              title: '效率 Efficiency',
              content: Text('简化流程：设计简洁直观的操作流程，降低认知负荷。'),
            ),
          ],
          activeKeys: _activeKeys,
          onChanged: (keys) => setState(() => _activeKeys = keys),
        ),
        const SizedBox(height: 24),

        ParkText('手风琴模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCollapse(
          accordion: true,
          items: const [
            ParkCollapseItem(
              key: 'a',
              title: '第一部分',
              content: Text('手风琴模式下同时只展开一个面板。'),
            ),
            ParkCollapseItem(
              key: 'b',
              title: '第二部分',
              content: Text('点击另一个面板会自动关闭当前展开的面板。'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Skeleton Demo
// =============================================================================

class SkeletonDemo extends StatelessWidget {
  const SkeletonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Skeleton 骨架屏', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('内容加载时展示占位骨架，支持多种预设形态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础骨架', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkSkeleton(width: 200, height: 16),
        const SizedBox(height: 8),
        const ParkSkeleton(width: 300, height: 16),
        const SizedBox(height: 24),

        ParkText('文本骨架', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSkeleton.text(lines: 3),
        const SizedBox(height: 24),

        ParkText('头像 + 文本组合', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            const ParkSkeleton(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
            const SizedBox(width: 16),
            Expanded(
              child: ParkSkeleton.text(lines: 2),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('按钮/圆形骨架', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          children: const [
            ParkSkeleton(width: 80, height: 32, button: true),
            ParkSkeleton(width: 48, height: 48, avatar: true),
            ParkSkeleton(width: 120, height: 24, round: true),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Swiper Demo
// =============================================================================

class SwiperDemo extends StatelessWidget {
  const SwiperDemo({super.key});

  static const List<Color> _colors = [
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFFCE4EC),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Swiper 轮播', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('支持自动播放、指示器和多种切换效果。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础轮播', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSwiper(
          height: 180,
          autoPlay: true,
          children: List.generate(4, (i) {
            return Container(
              decoration: BoxDecoration(
                color: _colors[i],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('Slide ${i + 1}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        ParkText('数字指示器', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkSwiper(
          height: 180,
          indicatorType: ParkSwiperIndicatorType.number,
          children: List.generate(3, (i) {
            return Container(
              decoration: BoxDecoration(
                color: _colors[i + 1],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('Page ${i + 1}',
                    style: const TextStyle(fontSize: 24)),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Image Demo
// =============================================================================

class ImageDemo extends StatelessWidget {
  const ImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Image 图片', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('网络图片组件，支持占位、错误处理和多种形状。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('形状变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ParkImage(
              src: 'https://picsum.photos/200/200?random=1',
              width: 80,
              height: 80,
              shape: ParkImageShape.circle,
            ),
            ParkImage(
              src: 'https://picsum.photos/200/200?random=2',
              width: 80,
              height: 80,
              shape: ParkImageShape.rounded,
            ),
            ParkImage(
              src: 'https://picsum.photos/200/200?random=3',
              width: 80,
              height: 80,
              shape: ParkImageShape.rectangle,
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('加载失败兜底', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkImage(
          src: 'https://invalid-url.example.com/broken.png',
          width: 120,
          height: 120,
          shape: ParkImageShape.rounded,
        ),
        const SizedBox(height: 24),

        ParkText('带标题图片', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkImage(
          src: 'https://picsum.photos/400/200?random=4',
          width: double.infinity,
          height: 160,
          shape: ParkImageShape.rounded,
          caption: '示例图片标题',
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Ellipsis Demo
// =============================================================================

class EllipsisDemo extends StatelessWidget {
  const EllipsisDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Ellipsis 文本省略', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('超长文本自动截断并显示省略号，支持 tooltip 和展开收起。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('单行省略', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkEllipsis(
          text: '这是一段非常长的文本内容，当容器宽度不够时会自动截断并显示省略号，悬浮可查看完整内容。',
          maxLines: 1,
        ),
        const SizedBox(height: 24),

        ParkText('多行省略', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkEllipsis(
          text: 'Park UI 是一套完整的 Flutter 组件库，提供丰富的高质量组件。它包含基础组件、输入组件、数据展示、反馈和导航等多个分类，'
              '覆盖了移动端和 Web 端常见的 UI 需求。所有组件都遵循统一的设计令牌系统，确保视觉一致性。',
          maxLines: 2,
        ),
        const SizedBox(height: 24),

        ParkText('可展开模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkEllipsis(
          text: '这是一段可以展开和收起的长文本内容。默认只显示两行，用户可以点击"展开"按钮查看完整内容，'
              '再次点击"收起"按钮可以折叠回原始状态。这种模式常用于文章摘要、评论展示等场景。',
          maxLines: 2,
          expandable: true,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Cell Demo
// =============================================================================

class CellDemo extends StatelessWidget {
  const CellDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Cell 单元格', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('列表单元格，支持图标、描述、箭头和备注信息。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkCell(titleText: '标题文字'),
        const ParkCell(titleText: '带箭头的单元格', arrow: true),
        const ParkCell(titleText: '带备注', note: '详细信息', arrow: true),
        const SizedBox(height: 24),

        ParkText('带图标', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkCell(
          titleText: '无线网络',
          descriptionText: '已连接到 WiFi',
          leftIcon: Icon(Icons.wifi),
          arrow: true,
        ),
        const ParkCell(
          titleText: '蓝牙',
          descriptionText: '已开启',
          leftIcon: Icon(Icons.bluetooth),
          arrow: true,
        ),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkCell(titleText: '小尺寸', size: ParkCellSize.small, arrow: true),
        const ParkCell(titleText: '中尺寸', size: ParkCellSize.medium, arrow: true),
        const ParkCell(titleText: '大尺寸', size: ParkCellSize.large, arrow: true),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
