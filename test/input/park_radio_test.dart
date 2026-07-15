import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkRadio', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkRadio(
        options: const [ParkRadioOption(label: '选项A', value: 'a')],
        value: 'a',
      )));
      expect(find.byType(ParkRadio), findsOneWidget);
    });
    testWidgets('显示label', (tester) async {
      await tester.pumpWidget(_wrap(ParkRadio(
        options: const [ParkRadioOption(label: '选项A', value: 'a')],
        value: null,
      )));
      expect(find.text('选项A'), findsOneWidget);
    });
    testWidgets('选中状态', (tester) async {
      await tester.pumpWidget(_wrap(ParkRadio(
        options: const [ParkRadioOption(label: '选项A', value: 'a')],
        value: 'a',
      )));
      final item = tester.widget<ParkRadioItem>(find.byType(ParkRadioItem));
      expect(item.isSelected, isTrue);
    });
    testWidgets('未选中状态', (tester) async {
      await tester.pumpWidget(_wrap(ParkRadio(
        options: const [ParkRadioOption(label: '选项A', value: 'a')],
        value: 'b',
      )));
      final item = tester.widget<ParkRadioItem>(find.byType(ParkRadioItem));
      expect(item.isSelected, isFalse);
    });
    testWidgets('点击切换', (tester) async {
      String? val;
      await tester.pumpWidget(_wrap(ParkRadio(
        options: const [ParkRadioOption(label: '选项A', value: 'a')],
        value: val,
        onChanged: (v) => val = v,
      )));
      await tester.tap(find.byType(ParkRadioItem));
      expect(val, 'a');
    });
  });
}
