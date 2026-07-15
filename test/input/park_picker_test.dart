import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkPicker', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkPicker(
        items: const [ParkPickerItem(label: '北京', value: 'beijing')],
      )));
      expect(find.byType(ParkPicker), findsOneWidget);
    });
    testWidgets('显示选项', (tester) async {
      await tester.pumpWidget(_wrap(ParkPicker(
        items: const [ParkPickerItem(label: '北京', value: 'beijing')],
      )));
      expect(find.text('北京'), findsOneWidget);
    });
  });
}
