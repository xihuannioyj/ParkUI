import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// Input Demo
// =============================================================================

class InputDemo extends StatelessWidget {
  const InputDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Input 输入框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('基础文本输入，支持多种尺寸、前/后图标、清除按钮、密码切换。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInput(
          label: '用户名',
          hintText: '请输入用户名',
        ),
        const SizedBox(height: 16),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInput(
          label: '小尺寸',
          hintText: 'Small',
          size: ParkInputSize.small,
        ),
        const SizedBox(height: 12),
        ParkInput(
          label: '中尺寸',
          hintText: 'Medium',
          size: ParkInputSize.medium,
        ),
        const SizedBox(height: 12),
        ParkInput(
          label: '大尺寸',
          hintText: 'Large',
          size: ParkInputSize.large,
        ),
        const SizedBox(height: 24),

        ParkText('交互示例', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                ParkInput(
                  label: '密码',
                  hintText: '请输入密码',
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 12),
                ParkInput(
                  label: '带清除',
                  hintText: '输入内容后可清除',
                  clearable: true,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

bool _obscure = true;

// =============================================================================
// Select Demo
// =============================================================================

class SelectDemo extends StatelessWidget {
  const SelectDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Select 选择器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('下拉选择，支持单选、多选、搜索、分组。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSelect(
              label: '城市',
              items: const [
                ParkSelectOption(label: '北京', value: 'bj'),
                ParkSelectOption(label: '上海', value: 'sh'),
                ParkSelectOption(label: '广州', value: 'gz'),
                ParkSelectOption(label: '深圳', value: 'sz'),
              ],
              value: _selectValue,
              onChanged: (v) => setState(() => _selectValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('分组选项', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSelect(
              label: '地区',
              items: const [],
              groupedOptions: const [
                ParkSelectGroupOption(
                  groupLabel: '一线城市',
                  options: [
                    ParkSelectOption(label: '北京', value: 'bj'),
                    ParkSelectOption(label: '上海', value: 'sh'),
                  ],
                ),
                ParkSelectGroupOption(
                  groupLabel: '新一线',
                  options: [
                    ParkSelectOption(label: '成都', value: 'cd'),
                    ParkSelectOption(label: '杭州', value: 'hz'),
                  ],
                ),
              ],
              value: _groupSelectValue,
              onChanged: (v) => setState(() => _groupSelectValue = v),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

String? _selectValue;
String? _groupSelectValue;

// =============================================================================
// DatePicker Demo
// =============================================================================

class DatePickerDemo extends StatelessWidget {
  const DatePickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('DatePicker 日期选择', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('日期/时间选择器，支持多种模式和快捷选项。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkDatePicker(
              label: '选择日期',
              value: _dateValue,
              onChanged: (v) => setState(() => _dateValue = v),
            );
          },
        ),
        const SizedBox(height: 16),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkDatePicker(
              label: '日期+时间',
              mode: ParkDatePickerMode.dateTime,
              value: _dateTimeValue,
              onChanged: (v) => setState(() => _dateTimeValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('带快捷选项', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkDatePicker(
              label: '带快捷',
              value: _shortcutDate,
              onChanged: (v) => setState(() => _shortcutDate = v),
              shortcuts: [
                ParkDatePickerShortcut.today(),
                ParkDatePickerShortcut.last7Days(),
                ParkDatePickerShortcut.last30Days(),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

DateTime? _dateValue;
DateTime? _dateTimeValue;
DateTime? _shortcutDate;

// =============================================================================
// Switch Demo
// =============================================================================

class SwitchDemo extends StatelessWidget {
  const SwitchDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Switch 开关', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('拨动开关，支持多种尺寸、自定义颜色和加载状态。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('尺寸变体', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Wrap(
              spacing: 24,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ParkSwitch(
                  value: _switchSmall,
                  size: ParkSwitchSize.small,
                  onChanged: (v) => setState(() => _switchSmall = v),
                ),
                ParkSwitch(
                  value: _switchMedium,
                  size: ParkSwitchSize.medium,
                  onChanged: (v) => setState(() => _switchMedium = v),
                ),
                ParkSwitch(
                  value: _switchLarge,
                  size: ParkSwitchSize.large,
                  onChanged: (v) => setState(() => _switchLarge = v),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('交互示例', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                ParkSwitch(
                  value: _switchLoading,
                  loading: true,
                  onChanged: (v) {},
                ),
                const SizedBox(height: 8),
                ParkText('加载中状态', preset: ParkTextPreset.caption),
                const SizedBox(height: 12),
                ParkSwitch(
                  value: _switchDisabled,
                  disabled: true,
                  onChanged: (v) {},
                ),
                const SizedBox(height: 8),
                ParkText('禁用状态', preset: ParkTextPreset.caption),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

bool _switchSmall = true;
bool _switchMedium = false;
bool _switchLarge = true;
bool _switchLoading = true;
bool _switchDisabled = false;

// =============================================================================
// Slider Demo
// =============================================================================

class SliderDemo extends StatelessWidget {
  const SliderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Slider 滑块', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('连续/离散滑动，支持数值显示、刻度标记、双滑块范围选择。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSlider(
              value: _sliderValue,
              showValue: true,
              onChanged: (v) => setState(() => _sliderValue = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('离散刻度', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSlider(
              value: _sliderDiscrete,
              min: 0,
              max: 100,
              divisions: 5,
              showValue: true,
              onChanged: (v) => setState(() => _sliderDiscrete = v),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('范围选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (context, setState) {
            return ParkSlider(
              range: true,
              rangeStart: _rangeStart,
              rangeEnd: _rangeEnd,
              min: 0,
              max: 100,
              showValue: true,
              onRangeChanged: (start, end) {
                setState(() {
                  _rangeStart = start;
                  _rangeEnd = end;
                });
              },
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

double _sliderValue = 30;
double _sliderDiscrete = 40;
double _rangeStart = 20;
double _rangeEnd = 80;
