import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkProgress', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(value: 0.5)));
      expect(find.byType(ParkProgress), findsOneWidget);
    });
    testWidgets('百分比显示', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(value: 0.75, showLabel: true)));
      expect(find.text('75%'), findsOneWidget);
    });
    testWidgets('自定义颜色', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(value: 0.3, color: Colors.green)));
      expect(find.byType(ParkProgress), findsOneWidget);
    });
  });
}
