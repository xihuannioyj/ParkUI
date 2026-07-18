import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_popover.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkPopover', () {
    testWidgets('creates with trigger and content', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopover(
          trigger: const Text('Click me'),
          content: const Text('Popover content'),
        ),
      ));
      expect(find.text('Click me'), findsOneWidget);
      // Content should not be visible initially
      expect(find.text('Popover content'), findsNothing);
    });

    testWidgets('shows content on tap (click trigger)', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopover(
          trigger: const Text('Trigger'),
          content: const Text('Body'),
        ),
      ));
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('custom direction', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopover(
          trigger: const Text('T'),
          content: const Text('C'),
          direction: ParkPopoverDirection.top,
        ),
      ));
      expect(find.byType(ParkPopover), findsOneWidget);
    });

    testWidgets('hover trigger mode', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopover(
          trigger: const Text('Hover me'),
          content: const Text('Hover content'),
          triggerMode: ParkPopoverTrigger.hover,
        ),
      ));
      expect(find.byType(ParkPopover), findsOneWidget);
      expect(find.text('Hover content'), findsNothing);
    });

    testWidgets('arrow configuration', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopover(
          trigger: const Text('T'),
          content: const Text('C'),
          arrow: false,
        ),
      ));
      expect(find.byType(ParkPopover), findsOneWidget);
    });
  });

  group('ParkPopover enums', () {
    test('ParkPopoverDirection has 12 values', () {
      expect(ParkPopoverDirection.values.length, 12);
    });

    test('ParkPopoverTrigger has click and hover', () {
      expect(ParkPopoverTrigger.values.length, 2);
      expect(ParkPopoverTrigger.click.index, 0);
      expect(ParkPopoverTrigger.hover.index, 1);
    });
  });
}
