import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkSlider', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkSlider()));
      expect(find.byType(ParkSlider), findsOneWidget);
    });
    testWidgets('初始值', (tester) async {
      await tester.pumpWidget(_wrap(ParkSlider(value: 50)));
      expect(find.byType(ParkSlider), findsOneWidget);
    });
    testWidgets('min/max', (tester) async {
      await tester.pumpWidget(_wrap(ParkSlider(min: 10, max: 90, value: 50)));
      expect(find.byType(ParkSlider), findsOneWidget);
    });
  });
}
