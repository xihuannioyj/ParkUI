import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkRate', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRate()));
      expect(find.byType(ParkRate), findsOneWidget);
    });
    testWidgets('默认5颗星', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRate()));
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
    });
    testWidgets('自定义count', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRate(count: 3)));
      expect(find.byIcon(Icons.star_border), findsNWidgets(3));
    });
    testWidgets('已评分', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRate(value: 3)));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
    });
    testWidgets('点击评分', (tester) async {
      double val = 0;
      await tester.pumpWidget(_wrap(ParkRate(onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.star_border).at(3));
      expect(val, 4);
    });
  });
}
