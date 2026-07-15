import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkRate', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate()));
      expect(find.byType(ParkRate), findsOneWidget);
    });
    testWidgets('默认5颗星', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate()));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
    });
    testWidgets('自定义count', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate(count: 3)));
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    });
    testWidgets('已评分', (tester) async {
      final park = ParkThemeData.light();
      await tester.pumpWidget(_wrap(ParkRate(value: 3)));
      final icons = tester.widgetList<Icon>(find.byIcon(Icons.star_rounded));
      final activeCount = icons.where((i) => i.color == park.colors.warning).length;
      expect(activeCount, 3);
    });
    testWidgets('点击评分', (tester) async {
      double val = 0;
      await tester.pumpWidget(_wrap(ParkRate(onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.star_rounded).at(3));
      expect(val, 4);
    });
  });
}
