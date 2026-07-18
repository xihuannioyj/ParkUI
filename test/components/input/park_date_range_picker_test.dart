import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkDateRangePicker - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker()));
      expect(find.byType(ParkDateRangePicker), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(label: 'Date Range')));
      expect(find.textContaining('Date Range'), findsOneWidget);
    });

    testWidgets('displays start and end dates', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        startTime: DateTime(2025, 1, 10),
        endTime: DateTime(2025, 3, 20),
      )));
      expect(find.textContaining('2025-01-10'), findsOneWidget);
      expect(find.textContaining('2025-03-20'), findsOneWidget);
    });

    testWidgets('displays date range icon', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker()));
      expect(find.byIcon(Icons.date_range_rounded), findsOneWidget);
    });

    testWidgets('no clear button when no value', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker()));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('shows clear button when has value', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        startTime: DateTime(2025, 1, 10),
        endTime: DateTime(2025, 3, 20),
      )));
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });

  group('ParkDateRangePicker - interactions', () {
    testWidgets('tap opens bottom sheet', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker()));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // Bottom sheet should appear with confirm/cancel buttons
      expect(find.text('确定'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('clear button resets dates and calls onChanged(null)', (tester) async {
      bool clearCalled = false;
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        startTime: DateTime(2025, 1, 10),
        endTime: DateTime(2025, 3, 20),
        onChanged: (v) {
          if (v == null) clearCalled = true;
        },
      )));
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(clearCalled, isTrue);
    });

    testWidgets('cancel button in sheet triggers onCancel', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        onCancel: () => cancelled = true,
      )));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(cancelled, isTrue);
    });
  });

  group('ParkDateRangePicker - ParkDateRange model', () {
    testWidgets('ParkDateRange equality', (tester) async {
      final a = ParkDateRange(start: DateTime(2025, 1, 1), end: DateTime(2025, 1, 31));
      final b = ParkDateRange(start: DateTime(2025, 1, 1), end: DateTime(2025, 1, 31));
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    testWidgets('ParkDateRange inequality', (tester) async {
      final a = ParkDateRange(start: DateTime(2025, 1, 1), end: DateTime(2025, 1, 31));
      final b = ParkDateRange(start: DateTime(2025, 1, 1), end: DateTime(2025, 2, 28));
      expect(a, isNot(equals(b)));
    });

    testWidgets('ParkDateRange toString', (tester) async {
      final range = ParkDateRange(start: DateTime(2025, 1, 1), end: DateTime(2025, 1, 31));
      expect(range.toString(), contains('ParkDateRange'));
    });
  });

  group('ParkDateRangePicker - shortcuts', () {
    testWidgets('shows shortcuts by default', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker()));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // Default shortcuts should include "今天" (today)
      expect(find.text('今天'), findsOneWidget);
    });

    testWidgets('showShortcuts=false hides shortcuts', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        showShortcuts: false,
      )));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('今天'), findsNothing);
    });
  });

  group('ParkDateRangePicker - edge cases', () {
    testWidgets('formats single digit months/days with padding', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        startTime: DateTime(2025, 3, 5),
        endTime: DateTime(2025, 11, 9),
      )));
      expect(find.textContaining('2025-03-05'), findsOneWidget);
      expect(find.textContaining('2025-11-09'), findsOneWidget);
    });

    testWidgets('display shows range format', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        startTime: DateTime(2025, 1, 10),
        endTime: DateTime(2025, 3, 20),
      )));
      expect(find.textContaining('~'), findsOneWidget);
    });

    testWidgets('label combined with date display', (tester) async {
      await tester.pumpWidget(_wrap(ParkDateRangePicker(
        label: 'Period',
        startTime: DateTime(2025, 1, 10),
        endTime: DateTime(2025, 3, 20),
      )));
      expect(find.textContaining('Period'), findsOneWidget);
    });
  });
}
