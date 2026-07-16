import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Radio Demo
// =============================================================================

class RadioDemo extends StatelessWidget {
  const RadioDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Radio 单选框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('单选框组，支持水平/垂直/按钮样式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkRadio(
              options: const [
                ParkRadioOption(label: '选项 A', value: 'a'),
                ParkRadioOption(label: '选项 B', value: 'b'),
                ParkRadioOption(label: '选项 C', value: 'c'),
              ],
              value: _radioValue,
              onChanged: (v) => setState(() => _radioValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('按钮样式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkRadio(
              options: const [
                ParkRadioOption(label: '日', value: 'day'),
                ParkRadioOption(label: '周', value: 'week'),
                ParkRadioOption(label: '月', value: 'month'),
              ],
              value: _radioButtonValue,
              radioStyle: ParkRadioStyle.button,
              buttonJoin: true,
              onChanged: (v) => setState(() => _radioButtonValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('禁用状态', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkRadio(
          options: const [
            ParkRadioOption(label: '选项 A', value: 'a'),
            ParkRadioOption(label: '选项 B (禁用)', value: 'b', disabled: true),
          ],
          value: 'a',
          disabled: false,
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

String? _radioValue = 'a';
String? _radioButtonValue = 'day';
