import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkCounter', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCounter()));
      expect(find.byType(ParkCounter), findsOneWidget);
    });
    testWidgets('显示数值', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCounter(value: 42)));
      expect(find.text('42'), findsOneWidget);
    });
    testWidgets('点击增减', (tester) async {
      int val = 5;
      await tester.pumpWidget(_wrap(ParkCounter(value: val, onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.add));
      expect(val, 6);
      await tester.tap(find.byIcon(Icons.remove));
      expect(val, 5);
    });
    testWidgets('min限制', (tester) async {
      int val = 0;
      await tester.pumpWidget(_wrap(ParkCounter(value: val, min: 0, onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.remove));
      expect(val, 0);
    });
  });
}
