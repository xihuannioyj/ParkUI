import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkPicker', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkPicker()));
      expect(find.byType(ParkPicker), findsOneWidget);
    });
    testWidgets('显示placeholder', (tester) async {
      await tester.pumpWidget(_wrap(const ParkPicker(hintText: '请选择')));
      expect(find.text('请选择'), findsOneWidget);
    });
  });
}
