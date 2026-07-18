import 'package:flutter/material.dart';
import 'package:park_ui/park_ui.dart';

// =============================================================================
// AutoComplete Demo
// =============================================================================

class AutoCompleteDemo extends StatelessWidget {
  const AutoCompleteDemo({super.key});

  static const List<String> _fruits = [
    'Apple', 'Apricot', 'Avocado',
    'Banana', 'Blueberry', 'Blackberry',
    'Cherry', 'Coconut', 'Cranberry',
    'Date', 'Dragonfruit', 'Durian',
    'Grape', 'Grapefruit', 'Guava',
    'Kiwi', 'Kumquat', 'Kiwi',
    'Lemon', 'Lime', 'Lychee',
    'Mango', 'Melon', 'Mandarin',
    'Orange', 'Papaya', 'Peach',
    'Pear', 'Pineapple', 'Plum',
    'Raspberry', 'Strawberry', 'Watermelon',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('AutoComplete 自动完成', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('输入时弹出候选建议列表，支持自定义过滤。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkAutoComplete(
          options: _fruits,
          hintText: '输入水果名称',
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('选中: $value')),
            );
          },
        ),
        const SizedBox(height: 24),

        ParkText('自定义过滤', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkAutoComplete(
          options: _fruits,
          hintText: '输入首字母搜索',
          maxSuggestions: 4,
          filterFn: (input, option) =>
              option.toLowerCase().startsWith(input.toLowerCase()),
          onSelected: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('选中: $value')),
            );
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// InputNumber Demo
// =============================================================================

class InputNumberDemo extends StatefulWidget {
  const InputNumberDemo({super.key});

  @override
  State<InputNumberDemo> createState() => _InputNumberDemoState();
}

class _InputNumberDemoState extends State<InputNumberDemo> {
  double _value1 = 10;
  double _value2 = 50;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('InputNumber 数字输入框', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('支持 +/- 按钮步进、范围限制的数字输入。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInputNumber(
          value: _value1,
          min: 0,
          max: 100,
          step: 1,
          label: '数量',
          onChanged: (v) => setState(() => _value1 = v),
        ),
        const SizedBox(height: 24),

        ParkText('步进为 5', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkInputNumber(
          value: _value2,
          min: 0,
          max: 200,
          step: 5,
          label: '金额',
          onChanged: (v) => setState(() => _value2 = v),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// TimePicker Demo
// =============================================================================

class TimePickerDemo extends StatefulWidget {
  const TimePickerDemo({super.key});

  @override
  State<TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<TimePickerDemo> {
  TimeOfDay? _time1 = const TimeOfDay(hour: 9, minute: 30);
  TimeOfDay? _time2;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('TimePicker 时间选择', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('独立的时间选择组件，支持 HH:mm 和 HH:mm:ss 格式。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTimePicker(
          value: _time1,
          label: '上班时间',
          onChanged: (time) => setState(() => _time1 = time),
        ),
        const SizedBox(height: 24),

        ParkText('带秒选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkTimePicker(
          value: _time2,
          label: '闹钟时间',
          showSeconds: true,
          placeholder: '请选择时间',
          onChanged: (time) => setState(() => _time2 = time),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Mentions Demo
// =============================================================================

class MentionsDemo extends StatelessWidget {
  const MentionsDemo({super.key});

  static const List<ParkMentionItem> _users = [
    ParkMentionItem(value: 'alice', label: 'Alice'),
    ParkMentionItem(value: 'bob', label: 'Bob'),
    ParkMentionItem(value: 'charlie', label: 'Charlie'),
    ParkMentionItem(value: 'david', label: 'David'),
    ParkMentionItem(value: 'emma', label: 'Emma'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Mentions 提及', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('输入 @ 后弹出用户列表，选中后插入提及标记。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('基础用法', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkMentions(
          items: _users,
          placeholder: '输入 @ 提及某人',
          onChanged: (text) {
            debugPrint('Mentions text: $text');
          },
        ),
        const SizedBox(height: 24),

        ParkText('多触发符', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkMentions(
          items: _users,
          triggerChars: const ['@', '#'],
          placeholder: '输入 @ 提及用户，# 添加标签',
          onChanged: (text) {
            debugPrint('Multi-trigger text: $text');
          },
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}

// =============================================================================
// Picker Demo
// =============================================================================

class PickerDemo extends StatefulWidget {
  const PickerDemo({super.key});

  @override
  State<PickerDemo> createState() => _PickerDemoState();
}

class _PickerDemoState extends State<PickerDemo> {
  String? _city;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ParkText('Picker 滚轮选择器', preset: ParkTextPreset.h2),
        const SizedBox(height: 8),
        ParkText('底部弹出滚轮面板，支持单列和多列选择。',
            preset: ParkTextPreset.caption),
        const SizedBox(height: 24),

        ParkText('单列选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.secondary,
          onPressed: () async {
            final result = await ParkPicker.show(
              context,
              title: '选择城市',
              items: const [
                ParkPickerItem(label: '北京', value: 'beijing'),
                ParkPickerItem(label: '上海', value: 'shanghai'),
                ParkPickerItem(label: '广州', value: 'guangzhou'),
                ParkPickerItem(label: '深圳', value: 'shenzhen'),
                ParkPickerItem(label: '杭州', value: 'hangzhou'),
                ParkPickerItem(label: '成都', value: 'chengdu'),
              ],
              value: _city,
            );
            if (result != null) {
              setState(() => _city = result);
            }
          },
          child: Text(_city ?? '请选择城市'),
        ),
        const SizedBox(height: 24),

        ParkText('多列选择', preset: ParkTextPreset.h3),
        const SizedBox(height: 12),
        ParkButton(
          variant: ParkButtonVariant.secondary,
          onPressed: () async {
            await ParkPicker.showMultiColumn(
              context,
              title: '选择时间',
              columns: [
                List.generate(24, (i) => ParkPickerItem(
                  label: '${i.toString().padLeft(2, '0')} 时',
                  value: '${i.toString().padLeft(2, '0')}',
                )),
                List.generate(60, (i) => ParkPickerItem(
                  label: '${i.toString().padLeft(2, '0')} 分',
                  value: '${i.toString().padLeft(2, '0')}',
                )),
              ],
            );
          },
          child: const Text('选择时间'),
        ),
        const SizedBox(height: 16),
        const ParkDivider(),
      ],
    );
  }
}
