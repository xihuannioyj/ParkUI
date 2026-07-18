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
  group('ParkInputNumber - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber()));
      expect(find.byType(ParkInputNumber), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(label: 'Quantity')));
      expect(find.text('Quantity'), findsOneWidget);
    });

    testWidgets('displays initial value', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(value: 42)));
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('displays zero when no value given', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber()));
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders +/- buttons', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(value: 5)));
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('respects precision formatting', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(value: 3.14, precision: 2)));
      expect(find.text('3.14'), findsOneWidget);
    });
  });

  group('ParkInputNumber - interactions', () {
    testWidgets('increment button increases value by step', (tester) async {
      double? changed;
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 10,
        step: 5,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(changed, 15);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('decrement button decreases value by step', (tester) async {
      double? changed;
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 10,
        step: 3,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(changed, 7);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('value is clamped to max', (tester) async {
      double? changed;
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 98,
        max: 100,
        step: 5,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(changed, 100);
    });

    testWidgets('value is clamped to min', (tester) async {
      double? changed;
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 2,
        min: 0,
        step: 5,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(changed, 0);
    });

    testWidgets('text submission updates value', (tester) async {
      double? changed;
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 0,
        min: 0,
        max: 100,
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), '25');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(changed, 25);
    });

    testWidgets('invalid text input resets to current value', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(value: 10)));
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(find.text('10'), findsOneWidget);
    });
  });

  group('ParkInputNumber - edge cases', () {
    testWidgets('disabled state renders with disabled TextField', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 5,
        disabled: true,
      )));
      // The TextField should be disabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('at min disables decrement button', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 0,
        min: 0,
        step: 1,
      )));
      // The decrement button should have a null onTap (disabled)
      final inkWell = tester.widget<InkWell>(find.ancestor(
        of: find.byIcon(Icons.remove),
        matching: find.byType(InkWell),
      ));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('at max disables increment button', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 100,
        max: 100,
        step: 1,
      )));
      final inkWell = tester.widget<InkWell>(find.ancestor(
        of: find.byIcon(Icons.add),
        matching: find.byType(InkWell),
      ));
      expect(inkWell.onTap, isNull);
    });

    testWidgets('step with decimal precision', (tester) async {
      double? changed;
      await tester.pumpWidget(_wrap(ParkInputNumber(
        value: 1.0,
        step: 0.5,
        precision: 1,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(changed, 1.5);
      expect(find.text('1.5'), findsOneWidget);
    });
  });
}
