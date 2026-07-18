import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_masonry.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  group('ParkMasonry', () {
    testWidgets('creates with items', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        height: 400,
        child: ParkMasonry<String>(
          items: const ['A', 'B', 'C', 'D'],
          itemBuilder: (context, item, index) => SizedBox(
            height: 60 + index * 20.0,
            child: Center(child: Text(item)),
          ),
        ),
      )));
      expect(find.byWidgetPredicate((w) => w is ParkMasonry), findsOneWidget);
    });

    testWidgets('empty items shows empty state', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        height: 400,
        child: ParkMasonry<String>(
          items: const [],
          itemBuilder: (context, item, index) => Text(item),
        ),
      )));
      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('custom emptyBuilder', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        height: 400,
        child: ParkMasonry<String>(
          items: const [],
          itemBuilder: (context, item, index) => Text(item),
          emptyBuilder: (_) => const Text('Custom Empty'),
        ),
      )));
      expect(find.text('Custom Empty'), findsOneWidget);
    });

    testWidgets('different column count', (tester) async {
      await tester.pumpWidget(_wrap(SizedBox(
        height: 400,
        child: ParkMasonry<String>(
          items: const ['A', 'B', 'C', 'D', 'E', 'F'],
          columns: 3,
          itemBuilder: (context, item, index) => SizedBox(
            height: 50,
            child: Center(child: Text(item)),
          ),
        ),
      )));
      expect(find.byWidgetPredicate((w) => w is ParkMasonry), findsOneWidget);
    });

    test('asserts columns > 0', () {
      expect(
        () => ParkMasonry<String>(
          items: const ['A'],
          columns: 0,
          itemBuilder: (_, __, ___) => const Text('x'),
        ),
        throwsAssertionError,
      );
    });
  });
}
