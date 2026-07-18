import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Statistic Demo
// =============================================================================

class StatisticDemo extends StatelessWidget {
  const StatisticDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Statistic 统计数值', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('以醒目大字展示数值，支持动画增长、前缀/后缀、精度控制。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 基础用法 ---
        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ParkStatistic(
                title: '活跃用户',
                value: 112893,
              ),
            ),
            Expanded(
              child: ParkStatistic(
                title: '新增访客',
                value: 8530,
              ),
            ),
            Expanded(
              child: ParkStatistic(
                title: '点击率',
                value: 68.25,
                precision: 2,
                suffix: const Text('%'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 带前缀/后缀 ---
        ParkText('前缀 & 后缀', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ParkStatistic(
                title: '收入',
                value: 98765,
                prefix: const Icon(Icons.attach_money, size: 22),
                groupSeparator: ',',
              ),
            ),
            Expanded(
              child: ParkStatistic(
                title: '增长',
                value: 15.3,
                precision: 1,
                prefix: const Icon(Icons.trending_up, size: 22,
                    color: Colors.green),
                suffix: const Text('%'),
              ),
            ),
            Expanded(
              child: ParkStatistic(
                title: '人数',
                value: 2349,
                suffix: const Text('人'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 关闭动画 ---
        ParkText('关闭动画', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkStatistic(
          title: '无动画',
          value: 42000,
          animate: false,
          prefix: const Icon(Icons.storage),
        ),
        const SizedBox(height: 24),

        // --- 自定义样式 ---
        ParkText('自定义样式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkStatistic(
          title: '自定义颜色',
          value: 9999,
          valueStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1677FF),
          ),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
