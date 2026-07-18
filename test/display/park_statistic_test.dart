import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_statistic.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkStatistic', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(value: 100)));
      expect(find.byType(ParkStatistic), findsOneWidget);
    });

    testWidgets('displays title when provided', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 100,
        title: 'Active Users',
      )));
      expect(find.text('Active Users'), findsOneWidget);
    });

    testWidgets('displays prefix and suffix', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 42,
        prefix: Icon(Icons.people),
        suffix: Text('persons'),
        animate: false,
      )));
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.text('persons'), findsOneWidget);
    });

    testWidgets('formats value with precision', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 1234.5678,
        precision: 2,
        animate: false,
      )));
      expect(find.text('1,234.57'), findsOneWidget);
    });

    testWidgets('formats value with thousands separator', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 1234567,
        animate: false,
      )));
      expect(find.text('1,234,567'), findsOneWidget);
    });

    testWidgets('animate=false shows final value immediately', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 999,
        animate: false,
      )));
      expect(find.text('999'), findsOneWidget);
    });

    testWidgets('negative value shows minus sign', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: -1234,
        animate: false,
      )));
      expect(find.text('-1,234'), findsOneWidget);
    });

    testWidgets('custom groupSeparator', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 1234567,
        groupSeparator: '.',
        animate: false,
      )));
      expect(find.text('1.234.567'), findsOneWidget);
    });

    testWidgets('empty groupSeparator disables grouping', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 1234567,
        groupSeparator: '',
        animate: false,
      )));
      expect(find.text('1234567'), findsOneWidget);
    });

    testWidgets('zero value renders correctly', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 0,
        animate: false,
      )));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('integer value shows no decimal point', (tester) async {
      await tester.pumpWidget(_wrap(const ParkStatistic(
        value: 42,
        animate: false,
      )));
      expect(find.text('42'), findsOneWidget);
    });
  });
}
