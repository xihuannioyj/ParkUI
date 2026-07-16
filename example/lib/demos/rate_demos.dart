import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Rate Demo
// =============================================================================

class RateDemo extends StatelessWidget {
  const RateDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Rate 评分', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('星级评分，支持半星、自定义图标、只读模式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkRate(
              value: _rateValue,
              onChanged: (v) => setState(() => _rateValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('半星模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkRate(
              value: _halfRateValue,
              allowHalf: true,
              showText: true,
              onChanged: (v) => setState(() => _halfRateValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('自定义图标', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkRate(
              value: _iconRateValue,
              icon: Icons.favorite,
              activeColor: Colors.red,
              count: 5,
              onChanged: (v) => setState(() => _iconRateValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('只读模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkRate(
          value: 3.5,
          readOnly: true,
          allowHalf: true,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

double _rateValue = 3;
double _halfRateValue = 2.5;
double _iconRateValue = 4;
