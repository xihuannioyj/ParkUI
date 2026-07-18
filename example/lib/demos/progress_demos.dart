import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Progress Demo
// =============================================================================

class ProgressDemo extends StatelessWidget {
  const ProgressDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Progress 进度条', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('展示操作进度，支持线条/环形/步骤样式、状态色和渐变。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 线条进度条 ---
        ParkText('线条进度条', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkProgress(value: 0.3, label: true),
        const SizedBox(height: 12),
        const ParkProgress(value: 0.7, label: true),
        const SizedBox(height: 12),
        const ParkProgress(value: 1.0, label: true,
            status: ParkProgressStatus.success),
        const SizedBox(height: 24),

        // --- 环形进度条 ---
        ParkText('环形进度条 (Dashboard)', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            ParkProgress(
              value: 0.25,
              type: ParkProgressType.dashboard,
              label: true,
              size: 80,
            ),
            ParkProgress(
              value: 0.75,
              type: ParkProgressType.dashboard,
              label: true,
              size: 80,
              status: ParkProgressStatus.success,
            ),
            ParkProgress(
              value: 1.0,
              type: ParkProgressType.dashboard,
              label: true,
              size: 80,
              status: ParkProgressStatus.error,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- 步骤进度条 ---
        ParkText('步骤进度条', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkProgress(value: 0.4, steps: 5),
        const SizedBox(height: 12),
        const ParkProgress(value: 0.8, steps: 8, stepWidth: 12,
            strokeWidth: 8),
        const SizedBox(height: 24),

        // --- 状态色 ---
        ParkText('状态色', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkProgress(value: 0.5, status: ParkProgressStatus.normal,
            label: true),
        const SizedBox(height: 8),
        const ParkProgress(value: 1.0, status: ParkProgressStatus.success,
            label: true),
        const SizedBox(height: 8),
        const ParkProgress(value: 0.6, status: ParkProgressStatus.error,
            label: true),
        const SizedBox(height: 8),
        const ParkProgress(value: 0.7, status: ParkProgressStatus.active,
            label: true),
        const SizedBox(height: 24),

        // --- 自定义粗细 ---
        ParkText('自定义粗细', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkProgress(value: 0.6, strokeWidth: 4, label: true),
        const SizedBox(height: 8),
        const ParkProgress(value: 0.6, strokeWidth: 10, label: true),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
