import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Stepper Demo
// =============================================================================

class StepperDemo extends StatelessWidget {
  const StepperDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Stepper 步进器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('数量选择器，支持最小/最大值限制、步长、禁用。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkStepper(
              value: _stepperValue,
              min: 0,
              max: 99,
              onChanged: (v) => setState(() => _stepperValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('步长为 5', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkStepper(
              value: _stepperStep5,
              min: 0,
              max: 100,
              step: 5,
              onChanged: (v) => setState(() => _stepperStep5 = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('禁用状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkStepper(
          value: 3,
          disabled: true,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

int _stepperValue = 1;
int _stepperStep5 = 10;
