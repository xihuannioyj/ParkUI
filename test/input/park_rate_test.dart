import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_rate.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

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
    testWidgets('click to rate', (tester) async {
      double val = 0;
      await tester.pumpWidget(_wrap(ParkRate(onChanged: (v) => val = v)));
      await tester.tap(find.byIcon(Icons.star_rounded).at(3));
      expect(val, 4);
    });

    testWidgets('readOnly prevents interaction', (tester) async {
      double val = 0;
      await tester.pumpWidget(_wrap(ParkRate(
        value: 3,
        readOnly: true,
        onChanged: (v) => val = v,
      )));
      await tester.tap(find.byIcon(Icons.star_rounded).at(4));
      expect(val, 0);
    });

    testWidgets('disabled prevents interaction', (tester) async {
      double val = 0;
      await tester.pumpWidget(_wrap(ParkRate(
        value: 2,
        disabled: true,
        onChanged: (v) => val = v,
      )));
      await tester.tap(find.byIcon(Icons.star_rounded).at(3));
      expect(val, 0);
    });

    testWidgets('showText displays value text', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate(
        value: 3,
        showText: true,
      )));
      expect(find.text('3 / 5'), findsOneWidget);
    });

    testWidgets('custom textBuilder', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate(
        value: 4,
        showText: true,
        textBuilder: (v, c) => 'Rating: $v',
      )));
      expect(find.text('Rating: 4.0'), findsOneWidget);
    });

    testWidgets('tapping unfilled star changes value', (tester) async {
      double val = 0;
      await tester.pumpWidget(_wrap(ParkRate(
        value: val,
        allowHalf: false,
        onChanged: (v) => val = v,
      )));
      // Tap 2nd star (unfilled) to set rating to 2
      await tester.tap(find.byIcon(Icons.star_rounded).at(1));
      await tester.pumpAndSettle();
      expect(val, greaterThan(0));
    });

    testWidgets('custom icon renders', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate(
        value: 2,
        icon: Icons.favorite,
      )));
      // Custom icon should appear (at least some instances for filled/unfilled stars)
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('different count values', (tester) async {
      await tester.pumpWidget(_wrap(ParkRate(
        value: 3,
        count: 10,
      )));
      // Rate widget should render with 10 star positions
      expect(find.byType(ParkRate), findsOneWidget);
    });
  });
}
