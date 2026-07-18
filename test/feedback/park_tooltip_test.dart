import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_tooltip.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkTooltip', () {
    testWidgets('creates with message and child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTooltip(
          message: 'Tooltip text',
          child: Text('Trigger'),
        ),
      ));
      expect(find.text('Trigger'), findsOneWidget);
      // Tooltip content not visible until hover/tap
      expect(find.text('Tooltip text'), findsNothing);
    });

    testWidgets('tap trigger shows tooltip', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTooltip(
          message: 'Tap tip',
          trigger: ParkTooltipTrigger.tap,
          child: Text('Tap me'),
        ),
      ));
      await tester.tap(find.text('Tap me'));
      await tester.pump();
      expect(find.text('Tap tip'), findsOneWidget);
    });

    testWidgets('controlled open=true shows tooltip', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTooltip(
          message: 'Controlled',
          open: true,
          child: Text('Child'),
        ),
      ));
      await tester.pump();
      expect(find.text('Controlled'), findsOneWidget);
    });

    testWidgets('placement options', (tester) async {
      for (final placement in ParkTooltipPlacement.values) {
        await tester.pumpWidget(_wrap(
          ParkTooltip(
            message: 'tip',
            placement: placement,
            child: const Text('C'),
          ),
        ));
        expect(find.byType(ParkTooltip), findsOneWidget);
      }
    });

    testWidgets('custom color and maxWidth', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTooltip(
          message: 'Custom',
          color: Colors.red,
          textColor: Colors.white,
          maxWidth: 300,
          child: Text('X'),
        ),
      ));
      expect(find.byType(ParkTooltip), findsOneWidget);
    });
  });

  group('ParkTooltip enums', () {
    test('ParkTooltipPlacement has 8 values', () {
      expect(ParkTooltipPlacement.values.length, 8);
    });

    test('ParkTooltipTrigger has hover and tap', () {
      expect(ParkTooltipTrigger.values.length, 2);
    });
  });
}
