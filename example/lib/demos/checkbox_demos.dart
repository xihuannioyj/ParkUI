import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Checkbox Demo
// =============================================================================

class CheckboxDemo extends StatelessWidget {
  const CheckboxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Checkbox 复选框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('复选框/复选框组，支持半选态、禁用、全选。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkCheckbox(
              value: _checkboxValue,
              label: const Text('同意用户协议'),
              onChanged: (v) => setState(() => _checkboxValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('半选态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkCheckbox(
          value: false,
          indeterminate: true,
          label: const Text('半选状态'),
        ),
        const SizedBox(height: 24),

        ParkText('复选框组', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkCheckboxGroup(
              options: const [
                ParkCheckboxOption(label: 'React', value: 'react'),
                ParkCheckboxOption(label: 'Vue', value: 'vue'),
                ParkCheckboxOption(label: 'Flutter', value: 'flutter'),
                ParkCheckboxOption(label: 'Angular', value: 'angular', disabled: true),
              ],
              value: _checkboxGroupValue,
              selectAll: true,
              layout: ParkCheckboxGroupLayout.wrap,
              onChanged: (values, _) =>
                  setState(() => _checkboxGroupValue = values),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

bool _checkboxValue = false;
List<String> _checkboxGroupValue = ['react', 'flutter'];
