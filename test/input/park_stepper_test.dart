import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkStepper', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStepper()));
      expect(find.byType(ParkStepper), findsOneWidget);
    });
    testWidgets('默认值为0', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStepper()));
      expect(find.text('0'), findsOneWidget);
    });
    testWidgets('自定义初始值', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStepper(value: 5)));
      expect(find.text('5'), findsOneWidget);
    });
    testWidgets('点击加号', (tester) async {
      int val = 0;
      await tester.pumpWidget(_wrap(ParkStepper(value: val, onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.add));
      expect(val, 1);
    });
    testWidgets('点击减号', (tester) async {
      int val = 5;
      await tester.pumpWidget(_wrap(ParkStepper(value: val, onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.remove));
      expect(val, 4);
    });
    testWidgets('min/max限制', (tester) async {
      int val = 0;
      await tester.pumpWidget(_wrap(ParkStepper(value: val, min: 0, max: 10, onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.remove));
      expect(val, 0); // 不能小于0
    });
  });
}
