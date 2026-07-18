import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// ColorPicker Demo
// =============================================================================

class ColorPickerDemo extends StatelessWidget {
  const ColorPickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('ColorPicker 颜色选择器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('支持 HEX / RGB / HSB 三种格式切换的颜色选择组件。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkColorPicker(
          value: Color(0xFF1677FF),
        ),
        const SizedBox(height: 24),

        ParkText('RGB 格式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkColorPicker(
          value: Color.fromARGB(255, 82, 196, 26),
          format: ParkColorFormat.rgb,
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// DateRangePicker Demo
// =============================================================================

class DateRangePickerDemo extends StatelessWidget {
  const DateRangePickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('DateRangePicker 日期范围选择', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('选择起止日期范围，支持快捷预设。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        const ParkDateRangePicker(
          label: '日期范围',
          startHintText: '开始日期',
          endHintText: '结束日期',
        ),
        const SizedBox(height: 24),

        ParkText('带快捷预设', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkDateRangePicker(
          label: '快捷选择',
          startHintText: '开始',
          endHintText: '结束',
          shortcuts: [
            ParkDateRangeShortcut.today(ParkLocalizations.of(context)),
            ParkDateRangeShortcut.last7Days(ParkLocalizations.of(context)),
            ParkDateRangeShortcut.last30Days(ParkLocalizations.of(context)),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// InputGroup Demo
// =============================================================================

class InputGroupDemo extends StatelessWidget {
  const InputGroupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('InputGroup 组合输入', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('将多个输入控件组合成紧凑一体容器。', preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('紧凑模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInputGroup(
          children: [
            ParkInput(hintText: '姓名', bordered: false),
            ParkSelect(
              items: const [
                ParkSelectOption(label: '北京', value: 'bj'),
                ParkSelectOption(label: '上海', value: 'sh'),
              ],
              bordered: false,
            ),
          ],
        ),
        const SizedBox(height: 24),

        ParkText('非紧凑模式', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInputGroup(
          compact: false,
          spacing: 12,
          children: [
            ParkInput(hintText: '关键词'),
            ParkButton(
              variant: ParkButtonVariant.primary,
              onPressed: () {},
              child: const Text('搜索'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
