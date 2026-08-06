import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_dropdown_filter.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: SizedBox(width: 360, child: child)),
    );

void main() {
  testWidgets('scrollable=false 时标签均分铺满全宽', (tester) async {
    await tester.pumpWidget(_wrap(ParkDropdownFilter(
      scrollable: false,
      items: const [
        DropdownFilterItem(label: '状态', options: [DropdownFilterOption(label: '全部', value: '0')]),
        DropdownFilterItem(label: '期限', options: [DropdownFilterOption(label: '全部', value: '-1')]),
        DropdownFilterItem(label: '类别', options: [DropdownFilterOption(label: '全部', value: 'all')]),
      ],
    )));

    final barWidth = tester.getSize(find.byType(ParkDropdownFilter)).width;
    expect(barWidth, 360, reason: '筛选栏应占满容器宽度');

    // 每个标签等宽 = 360/3 = 120（测 Semantics 容器宽度，Text 自身只有内容宽）
    for (final label in ['状态', '期限', '类别']) {
      final labelFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == label,
      );
      expect(labelFinder, findsOneWidget, reason: '应找到 $label 标签');
      final w = tester.getSize(labelFinder).width;
      expect(w, closeTo(120, 1), reason: '$label 标签应均分等宽，实际 $w');
    }
  });

  testWidgets('scrollable=true 保持原有行为（内容宽度，可横滑）', (tester) async {
    await tester.pumpWidget(_wrap(ParkDropdownFilter(
      scrollable: true,
      items: const [
        DropdownFilterItem(label: '状态', options: []),
        DropdownFilterItem(label: '期限', options: []),
        DropdownFilterItem(label: '类别', options: []),
      ],
    )));
    await tester.pump();
    final e = tester.takeException();
    expect(e, isNull);
  });
}
