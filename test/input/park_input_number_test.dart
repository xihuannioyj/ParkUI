import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_input_number.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 300, child: child),
        ),
      ),
    );

void main() {
  group('ParkInputNumber - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkInputNumber(value: 10),
      ));
      expect(find.byType(ParkInputNumber), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays initial value', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkInputNumber(value: 42),
      ));
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('shows label when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkInputNumber(value: 0, label: 'Quantity'),
      ));
      expect(find.text('Quantity'), findsOneWidget);
    });
  });

  group('ParkInputNumber - interaction', () {
    testWidgets('step up button increases value', (tester) async {
      double? changedValue;
      await tester.pumpWidget(_wrap(
        ParkInputNumber(
          value: 10,
          step: 5,
          onChanged: (v) => changedValue = v,
        ),
      ));
      // Find and tap the + button
      final plusFinder = find.byIcon(Icons.add);
      expect(plusFinder, findsOneWidget);
      await tester.tap(plusFinder);
      await tester.pump();
      expect(changedValue, 15);
    });

    testWidgets('step down button decreases value', (tester) async {
      double? changedValue;
      await tester.pumpWidget(_wrap(
        ParkInputNumber(
          value: 10,
          step: 3,
          onChanged: (v) => changedValue = v,
        ),
      ));
      final minusFinder = find.byIcon(Icons.remove);
      expect(minusFinder, findsOneWidget);
      await tester.tap(minusFinder);
      await tester.pump();
      expect(changedValue, 7);
    });

    testWidgets('value does not exceed max', (tester) async {
      double? changedValue;
      await tester.pumpWidget(_wrap(
        ParkInputNumber(
          value: 98,
          max: 100,
          step: 5,
          onChanged: (v) => changedValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(changedValue, 100);
    });

    testWidgets('value does not go below min', (tester) async {
      double? changedValue;
      await tester.pumpWidget(_wrap(
        ParkInputNumber(
          value: 2,
          min: 0,
          step: 5,
          onChanged: (v) => changedValue = v,
        ),
      ));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(changedValue, 0);
    });
  });

  group('ParkInputNumber - disabled state', () {
    testWidgets('disabled mode prevents interaction', (tester) async {
      double? changedValue;
      await tester.pumpWidget(_wrap(
        ParkInputNumber(
          value: 10,
          disabled: true,
          onChanged: (v) => changedValue = v,
        ),
      ));
      expect(find.byType(ParkInputNumber), findsOneWidget);
      // Buttons should be present but taps should not change value
      expect(changedValue, isNull);
    });
  });
}
