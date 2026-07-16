import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Countdown Demo
// =============================================================================

class CountdownDemo extends StatelessWidget {
  const CountdownDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Countdown 倒计时', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('倒计时组件，支持多种尺寸和主题风格。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础倒计时', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCountdown(
          remaining: const Duration(hours: 1, minutes: 30, seconds: 0),
          onFinish: () {},
        ),
        const SizedBox(height: 24),

        ParkText('圆形主题', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCountdown(
          remaining: const Duration(hours: 0, minutes: 25, seconds: 30),
          theme: ParkCountdownTheme.round,
          size: ParkCountdownSize.small,
        ),
        const SizedBox(height: 24),

        ParkText('大尺寸', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCountdown(
          remaining: const Duration(days: 2, hours: 5),
          size: ParkCountdownSize.large,
          theme: ParkCountdownTheme.square,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
