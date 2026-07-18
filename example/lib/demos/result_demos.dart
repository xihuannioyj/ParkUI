import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Result Demo
// =============================================================================

class ResultDemo extends StatelessWidget {
  const ResultDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Result 结果', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('操作结果反馈，支持 success / warning / error / info 及 HTTP 状态码预设。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        // --- 成功 ---
        ParkText('成功', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkResult(
          status: ParkResultStatus.success,
          title: '提交成功',
          description: '您的订单已成功提交，我们将尽快处理。',
        ),
        const SizedBox(height: 24),

        // --- 警告 ---
        ParkText('警告', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkResult(
          status: ParkResultStatus.warning,
          title: '请注意',
          description: '您的操作可能存在风险，请确认后继续。',
        ),
        const SizedBox(height: 24),

        // --- 错误 ---
        ParkText('错误', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkResult(
          status: ParkResultStatus.error,
          title: '操作失败',
          description: '网络异常，请检查网络连接后重试。',
        ),
        const SizedBox(height: 24),

        // --- 信息 ---
        ParkText('信息', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkResult(
          status: ParkResultStatus.info,
          title: '提示',
          description: '这是一条普通的信息提示。',
          actions: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('返回首页'),
            ),
            ParkButton(
              variant: ParkButtonVariant.secondary,
              onPressed: () {},
              child: const Text('查看详情'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- HTTP 状态码预设 ---
        ParkText('HTTP 状态码预设', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkResult.notFound(
          title: '页面未找到',
          description: '您访问的页面不存在或已被移除。',
          actions: [
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('返回首页'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
