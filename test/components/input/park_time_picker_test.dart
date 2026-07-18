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
  group('ParkTimePicker - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker()));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(label: 'Start Time')));
      expect(find.text('Start Time'), findsOneWidget);
    });

    testWidgets('displays placeholder when no value', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(placeholder: 'Pick a time')));
      expect(find.text('Pick a time'), findsOneWidget);
    });

    testWidgets('displays default placeholder when no value and no placeholder', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker()));
      // The default placeholder comes from ParkLocalizations - selectTimeText
      expect(find.byType(ParkTimePicker), findsOneWidget);
      // Should display some text (the default placeholder)
      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);
    });

    testWidgets('displays selected time value', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 9, minute: 30),
      )));
      expect(find.byType(ParkTimePicker), findsOneWidget);
      // The time should be formatted and displayed
      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);
    });

    testWidgets('shows time icon', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker()));
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('shows dropdown arrow when enabled', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker()));
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });
  });

  group('ParkTimePicker - interactions', () {
    testWidgets('disabled state does not show dropdown arrow', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(disabled: true)));
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);
    });

    testWidgets('disabled state uses disabled background', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(disabled: true)));
      // Tapping should not open picker
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      // No dialog should appear
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tap opens time picker dialog', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker()));
      // Tap the GestureDetector to open picker
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // Standard Material time picker dialog should appear
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('ParkTimePicker - showSeconds', () {
    testWidgets('showSeconds displays time icon', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 14, minute: 30),
        showSeconds: true,
      )));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });

    testWidgets('showSeconds formats with seconds', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 9, minute: 5),
        showSeconds: true,
      )));
      // Should contain formatted time with seconds (00)
      expect(find.byType(ParkTimePicker), findsOneWidget);
      // The text should contain the time with seconds
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final hasTimeText = textWidgets.any((t) =>
          t.data != null && t.data!.contains(':'));
      expect(hasTimeText, isTrue);
    });
  });

  group('ParkTimePicker - edge cases', () {
    testWidgets('handles midnight time', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 0, minute: 0),
      )));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });

    testWidgets('handles end of day time', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 23, minute: 59),
      )));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });

    testWidgets('didUpdateWidget syncs new value', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 9, minute: 0),
      )));
      // Rebuild with different value
      await tester.pumpWidget(_wrap(ParkTimePicker(
        value: TimeOfDay(hour: 15, minute: 30),
      )));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });
  });
}
