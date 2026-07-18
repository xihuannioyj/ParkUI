import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Timeline Demo
// =============================================================================

class TimelineDemo extends StatelessWidget {
  const TimelineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Timeline 时间线', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('按时间顺序展示事件，支持左/右/交替布局、自定义图标和待加载状态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 基础用法 ---
        ParkText('基础用法（左侧）', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTimeline(
          mode: ParkTimelineMode.left,
          items: const [
            ParkTimelineItem(
              title: '创建项目',
              description: '初始化项目结构',
              time: '2026-07-01 09:00',
            ),
            ParkTimelineItem(
              title: '需求评审',
              description: '完成第一轮需求评审',
              time: '2026-07-05 14:30',
            ),
            ParkTimelineItem(
              title: '开发完成',
              time: '2026-07-10 18:00',
            ),
            ParkTimelineItem(
              title: '上线部署',
              description: '生产环境部署成功',
              time: '2026-07-12 10:00',
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 交替布局 ---
        ParkText('交替布局', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTimeline(
          mode: ParkTimelineMode.alternate,
          items: const [
            ParkTimelineItem(
              title: '方案讨论',
              time: '07-01',
              icon: Icons.lightbulb,
              color: Colors.orange,
            ),
            ParkTimelineItem(
              title: 'UI 设计',
              time: '07-03',
              icon: Icons.palette,
              color: Colors.purple,
            ),
            ParkTimelineItem(
              title: '前端开发',
              time: '07-05',
              icon: Icons.code,
            ),
            ParkTimelineItem(
              title: '测试验收',
              time: '07-08',
              icon: Icons.verified,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 待加载 ---
        ParkText('待加载状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTimeline(
          mode: ParkTimelineMode.left,
          pending: true,
          pendingLabel: '处理中...',
          items: const [
            ParkTimelineItem(
              title: '步骤一',
              description: '已完成',
              time: '10:00',
            ),
            ParkTimelineItem(
              title: '步骤二',
              description: '已完成',
              time: '11:30',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
