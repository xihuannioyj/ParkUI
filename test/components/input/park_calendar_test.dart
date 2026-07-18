import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('ParkCalendar - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar()));
      expect(find.byType(ParkCalendar), findsOneWidget);
    });

    testWidgets('displays current month header', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar()));
      // Should show year/month text from localization
      expect(find.byType(ParkCalendar), findsOneWidget);
      // The header should contain navigation arrows
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('displays weekday labels', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar()));
      // Default firstDayOfWeek=1 (Monday), should display 7 weekday labels
      // Chinese defaults: 一 二 三 四 五 六 日
      expect(find.text('一'), findsOneWidget);
      expect(find.text('日'), findsOneWidget);
    });

    testWidgets('displays days of month', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
      )));
      // Day 1 should be visible
      expect(find.text('1'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('custom firstDayOfWeek changes weekday order', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar(
        firstDayOfWeek: 0, // Sunday first
      )));
      // Sunday should be first label
      expect(find.text('日'), findsOneWidget);
    });
  });

  group('ParkCalendar - interactions', () {
    testWidgets('tap date triggers onChanged', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 1),
        onChanged: (d) => changed = d,
      )));
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(changed, DateTime(2025, 6, 15));
    });

    testWidgets('prev month button navigates', (tester) async {
      DateTime? panelChanged;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        onPanelChange: (d) => panelChanged = d,
      )));
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(panelChanged, DateTime(2025, 5, 1));
    });

    testWidgets('next month button navigates', (tester) async {
      DateTime? panelChanged;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        onPanelChange: (d) => panelChanged = d,
      )));
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(panelChanged, DateTime(2025, 7, 1));
    });
  });

  group('ParkCalendar - disabled dates', () {
    testWidgets('disabledDates prevents selection', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 1),
        disabledDates: [DateTime(2025, 6, 15)],
        onChanged: (d) => changed = d,
      )));
      await tester.tap(find.text('15'));
      await tester.pump();
      expect(changed, isNull);
    });

    testWidgets('minDate prevents selection before', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        minDate: DateTime(2025, 6, 10),
        onChanged: (d) => changed = d,
      )));
      await tester.tap(find.text('5'));
      await tester.pump();
      expect(changed, isNull);
    });

    testWidgets('maxDate prevents selection after', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        maxDate: DateTime(2025, 6, 20),
        onChanged: (d) => changed = d,
      )));
      await tester.tap(find.text('25'));
      await tester.pump();
      expect(changed, isNull);
    });

    testWidgets('disabledDate callback prevents selection', (tester) async {
      DateTime? changed;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        disabledDate: (d) => d.weekday == DateTime.saturday,
        onChanged: (d) => changed = d,
      )));
      // June 2025: 7, 14, 21, 28 are Saturdays
      await tester.tap(find.text('7'));
      await tester.pump();
      expect(changed, isNull);
    });
  });

  group('ParkCalendar - range mode (new API)', () {
    testWidgets('renders in range selection mode', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar(
        selectionMode: ParkCalendarSelectionMode.range,
        rangeStart: DateTime(2025, 6, 10),
        rangeEnd: DateTime(2025, 6, 20),
      )));
      expect(find.byType(ParkCalendar), findsOneWidget);
    });

    testWidgets('tap sets range start when no start', (tester) async {
      DateTime? rangeStart;
      DateTime? rangeEnd;
      bool callbackFired = false;
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 1),
        selectionMode: ParkCalendarSelectionMode.range,
        onRangeChange: (s, e) {
          callbackFired = true;
          rangeStart = s;
          rangeEnd = e;
        },
      )));
      await tester.tap(find.text('10'));
      await tester.pump();
      expect(callbackFired, isTrue);
      expect(rangeStart, isNotNull);
      expect(rangeStart!.day, 10);
      expect(rangeStart!.month, 6);
      expect(rangeEnd, isNull);
    });
  });

  group('ParkCalendar - custom builders', () {
    testWidgets('headerBuilder replaces default header', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        headerBuilder: (month, onPrev, onNext) {
          return Row(
            children: [
              Text('Custom: ${month.year}-${month.month}'),
            ],
          );
        },
      )));
      expect(find.text('Custom: 2025-6'), findsOneWidget);
      // Default arrows should not be present
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('cellBuilder replaces default cell rendering', (tester) async {
      await tester.pumpWidget(_wrap(ParkCalendar(
        value: DateTime(2025, 6, 15),
        cellBuilder: (date, isSelected, isToday, isDisabled) {
          return Container(
            color: isSelected ? Colors.blue : Colors.grey,
            child: Text('D${date.day}'),
          );
        },
      )));
      expect(find.text('D15'), findsOneWidget);
    });
  });
}
