import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkDatePicker', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkDatePicker(
        onChanged: (_) {},
      )));
      expect(find.byType(ParkDatePicker), findsOneWidget);
    });
    testWidgets('显示label', (tester) async {
      await tester.pumpWidget(_wrap(ParkDatePicker(label: '选择日期', onChanged: (_) {})));
      expect(find.text('选择日期'), findsOneWidget);
    });
    testWidgets('显示初始日期', (tester) async {
      final date = DateTime(2025, 6, 15);
      await tester.pumpWidget(_wrap(ParkDatePicker(value: date, onChanged: (_) {})));
      expect(find.text('2025-06-15'), findsOneWidget);
    });
    testWidgets('disabled状态', (tester) async {
      await tester.pumpWidget(_wrap(ParkDatePicker(enabled: false, onChanged: (_) {})));
      expect(find.byType(ParkDatePicker), findsOneWidget);
    });
  });
}
