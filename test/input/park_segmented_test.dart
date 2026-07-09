import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

const _items = <ParkSegmentedItem>[
  ParkSegmentedItem(value: 'day', label: '日'),
  ParkSegmentedItem(value: 'week', label: '周'),
  ParkSegmentedItem(value: 'month', label: '月'),
];

void main() {
  group('ParkSegmented - 非受控选中 (P0-1)', () {
    testWidgets('空 onChanged 下点击即时选中（视觉更新）', (tester) async {
      String? tapped;
      await tester.pumpWidget(_wrap(ParkSegmented(
        items: _items,
        onChanged: (v) => tapped = v, // 非受控：父组件不维护 value
      )));
      final colors = ParkThemeData.light().colors;

      // 初始应选中第一项 'day'
      final day0 = tester.widget<Text>(find.text('日'));
      expect(day0.style!.color, colors.textPrimary);

      // 点击 '周'（无受控 value，依赖内部 _selectedValue）
      await tester.tap(find.text('周'));
      await tester.pump();

      final week = tester.widget<Text>(find.text('周'));
      final day1 = tester.widget<Text>(find.text('日'));
      // 选中态应即时跟随，无需父组件维护 value
      expect(week.style!.color, colors.textPrimary);
      expect(day1.style!.color, colors.textSecondary);
      expect(tapped, 'week');
    });
  });

  group('ParkSegmented - 受控跟随 (P0-1)', () {
    testWidgets('外部 value 变更后选中态经 didUpdateWidget 跟随', (tester) async {
      final wrapper = _ControlledWrapper();
      await tester.pumpWidget(_wrap(wrapper));
      final colors = ParkThemeData.light().colors;

      // 初始 value='day' -> '日' 高亮
      expect(tester.widget<Text>(find.text('日')).style!.color,
          colors.textPrimary);

      // 通过外部按钮改变 value（不点击 segmented 本身）
      await tester.tap(find.text('外部→月'));
      await tester.pump();

      final month = tester.widget<Text>(find.text('月'));
      final day2 = tester.widget<Text>(find.text('日'));
      expect(month.style!.color, colors.textPrimary);
      expect(day2.style!.color, colors.textSecondary);
    });
  });

  group('ParkSegmented - 滑块真实项宽 (P0-1)', () {
    testWidgets('滑块宽度对齐被选项真实宽度（非 60px 硬编码）', (tester) async {
      const longItems = <ParkSegmentedItem>[
        ParkSegmentedItem(value: 'a', label: '短'),
        ParkSegmentedItem(value: 'b', label: '很长很长的标签内容'),
      ];
      await tester.pumpWidget(_wrap(const ParkSegmented(items: longItems)));
      await tester.pumpAndSettle();

      // 选中宽项
      await tester.tap(find.text('很长很长的标签内容'));
      await tester.pumpAndSettle();

      final slider =
          tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned));
      final textSize =
          tester.getSize(find.text('很长很长的标签内容'));
      final hPadding = ParkThemeData.light().spacing.base;

      // 真实测量宽 = 文本宽 + 2*hPadding；若仍用 60px 硬编码则远小于此值
      expect(slider.width, closeTo(textSize.width + 2 * hPadding, 2.0));
    });
  });
}

/// 受控包装：用外部按钮改变 value，验证 didUpdateWidget 同步。
class _ControlledWrapper extends StatefulWidget {
  const _ControlledWrapper();
  @override
  State<_ControlledWrapper> createState() => _ControlledWrapperState();
}

class _ControlledWrapperState extends State<_ControlledWrapper> {
  String _value = 'day';
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkSegmented(
            value: _value,
            items: _items,
            onChanged: (v) => setState(() => _value = v),
          ),
          ElevatedButton(
            onPressed: () => setState(() => _value = 'month'),
            child: const Text('外部→月'),
          ),
        ],
      );
}
