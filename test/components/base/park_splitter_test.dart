import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// Flush pending gesture timers (e.g. DoubleTapGestureRecognizer's 40ms timer).
Future<void> _flushTimers(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
  );
}

/// Find the divider MouseRegion inside ParkSplitter.
Finder findDivider() {
  return find.descendant(
    of: find.byType(ParkSplitter),
    matching: find.byType(MouseRegion),
  ).first;
}

void main() {
  group('ParkSplitter', () {
    // 1. Basic render
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('left'),
          second: Text('right'),
        ),
      ));
      expect(find.byType(ParkSplitter), findsOneWidget);
    });

    // 2. Children render
    testWidgets('renders both first and second children', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('panel-A'),
          second: Text('panel-B'),
        ),
      ));
      expect(find.text('panel-A'), findsOneWidget);
      expect(find.text('panel-B'), findsOneWidget);
    });

    // 3. Three panels via nested splitters
    testWidgets('renders three panels via nested splitters', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('panel-1'),
          second: ParkSplitter(
            first: Text('panel-2'),
            second: Text('panel-3'),
          ),
        ),
      ));
      expect(find.text('panel-1'), findsOneWidget);
      expect(find.text('panel-2'), findsOneWidget);
      expect(find.text('panel-3'), findsOneWidget);
      expect(find.byType(ParkSplitter), findsNWidgets(2));
    });

    // 4. Divider exists between panels
    testWidgets('has a divider (MouseRegion) between panels', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('left'),
          second: Text('right'),
        ),
      ));
      expect(findDivider(), findsOneWidget);
    });

    // 5. Horizontal direction uses Row
    testWidgets('horizontal axis uses Row layout', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          axis: Axis.horizontal,
          first: Text('left'),
          second: Text('right'),
        ),
      ));
      expect(find.byType(Row), findsWidgets);
      final firstPos = tester.getCenter(find.text('left'));
      final secondPos = tester.getCenter(find.text('right'));
      expect(firstPos.dx, lessThan(secondPos.dx));
    });

    // 6. Vertical direction uses Column
    testWidgets('vertical axis uses Column layout', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          axis: Axis.vertical,
          first: Text('top'),
          second: Text('bottom'),
        ),
      ));
      expect(find.byType(Column), findsWidgets);
      final firstPos = tester.getCenter(find.text('top'));
      final secondPos = tester.getCenter(find.text('bottom'));
      expect(firstPos.dy, lessThan(secondPos.dy));
    });

    // 7. Default ratio controls initial panel sizes
    testWidgets('defaultRatio controls initial panel sizes', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          axis: Axis.horizontal,
          defaultRatio: 0.25,
          first: Text('small'),
          second: Text('large'),
        ),
      ));
      final firstBox =
          tester.renderObject(find.text('small')).parent as RenderBox;
      final secondBox =
          tester.renderObject(find.text('large')).parent as RenderBox;
      expect(firstBox.size.width, lessThan(secondBox.size.width));
    });

    // 8. Drag interaction triggers onRatioChanged
    testWidgets('dragging divider right triggers onRatioChanged',
        (tester) async {
      double? newRatio;
      await tester.pumpWidget(_wrap(
        ParkSplitter(
          axis: Axis.horizontal,
          defaultRatio: 0.5,
          onRatioChanged: (r) => newRatio = r,
          first: const Text('left'),
          second: const Text('right'),
        ),
      ));

      final divider = findDivider();
      await tester.drag(divider, const Offset(100, 0));
      await tester.pump();
      await _flushTimers(tester);

      expect(newRatio, isNotNull);
      expect(newRatio!, greaterThan(0.5));
    });

    // 9. Dragging left decreases ratio
    testWidgets('dragging divider left decreases ratio', (tester) async {
      double? newRatio;
      await tester.pumpWidget(_wrap(
        ParkSplitter(
          axis: Axis.horizontal,
          defaultRatio: 0.5,
          onRatioChanged: (r) => newRatio = r,
          first: const Text('left'),
          second: const Text('right'),
        ),
      ));

      final divider = findDivider();
      await tester.drag(divider, const Offset(-100, 0));
      await tester.pump();
      await _flushTimers(tester);

      expect(newRatio, isNotNull);
      expect(newRatio!, lessThan(0.5));
    });

    // 10. Min/max ratio constraints
    testWidgets('minRatio and maxRatio clamp drag range', (tester) async {
      double? reportedRatio;
      await tester.pumpWidget(_wrap(
        ParkSplitter(
          axis: Axis.horizontal,
          defaultRatio: 0.5,
          minRatio: 0.3,
          maxRatio: 0.7,
          onRatioChanged: (r) => reportedRatio = r,
          first: const Text('left'),
          second: const Text('right'),
        ),
      ));

      final divider = findDivider();

      // Drag far right (beyond maxRatio)
      await tester.drag(divider, const Offset(500, 0));
      await tester.pump();
      await _flushTimers(tester);

      expect(reportedRatio, isNotNull);
      expect(reportedRatio!, lessThanOrEqualTo(0.7));

      // Drag far left (beyond minRatio)
      reportedRatio = null;
      await tester.drag(divider, const Offset(-1000, 0));
      await tester.pump();
      await _flushTimers(tester);

      expect(reportedRatio, isNotNull);
      expect(reportedRatio!, greaterThanOrEqualTo(0.3));
    });

    // 11. Collapsible shows collapse buttons
    testWidgets('collapsible mode shows collapse buttons', (tester) async {
      // Use a wide divider so the 18px collapse buttons fit without overflow.
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('left'),
          second: Text('right'),
          collapsible: true,
          dividerThickness: 48.0,
        ),
      ));
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // 12. Non-collapsible hides collapse buttons
    testWidgets('non-collapsible mode has no collapse buttons',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('left'),
          second: Text('right'),
          collapsible: false,
        ),
      ));
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    // 13. Double tap resets to default ratio
    testWidgets('double tap divider resets to defaultRatio', (tester) async {
      double? reportedRatio;
      await tester.pumpWidget(_wrap(
        ParkSplitter(
          axis: Axis.horizontal,
          defaultRatio: 0.5,
          onRatioChanged: (r) => reportedRatio = r,
          first: const Text('left'),
          second: const Text('right'),
        ),
      ));

      // Drag to change ratio
      final divider = findDivider();
      await tester.drag(divider, const Offset(100, 0));
      await tester.pump();
      await _flushTimers(tester);
      expect(reportedRatio, isNotNull);
      expect(reportedRatio!, isNot(0.5));

      // Double tap to reset: simulate two quick taps via startGesture
      reportedRatio = null;
      final center = tester.getCenter(divider);
      final g1 = await tester.startGesture(center);
      await g1.up();
      await tester.pump(const Duration(milliseconds: 50));
      final g2 = await tester.startGesture(center);
      await g2.up();
      await tester.pumpAndSettle();

      expect(reportedRatio, 0.5);
    });

    // 14. Controlled mode via ratio parameter
    testWidgets('controlled ratio parameter overrides internal state',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          axis: Axis.horizontal,
          ratio: 0.3,
          first: Text('left'),
          second: Text('right'),
        ),
      ));

      final firstBox =
          tester.renderObject(find.text('left')).parent as RenderBox;
      final dividerThickness = ParkThemeData.light().spacing.xxs;
      final available = 800.0 - dividerThickness;
      final expectedWidth = available * 0.3;

      expect(firstBox.size.width, closeTo(expectedWidth, 1.0));
    });

    // 15. Vertical drag interaction
    testWidgets('vertical axis drag changes ratio', (tester) async {
      double? newRatio;
      await tester.pumpWidget(_wrap(
        ParkSplitter(
          axis: Axis.vertical,
          defaultRatio: 0.5,
          onRatioChanged: (r) => newRatio = r,
          first: const Text('top'),
          second: const Text('bottom'),
        ),
      ));

      final divider = findDivider();
      await tester.drag(divider, const Offset(0, 100));
      await tester.pump();
      await _flushTimers(tester);

      expect(newRatio, isNotNull);
      expect(newRatio!, greaterThan(0.5));
    });

    // 16. Custom divider thickness
    testWidgets('custom dividerThickness is applied', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSplitter(
          first: Text('left'),
          second: Text('right'),
          dividerThickness: 8.0,
        ),
      ));

      final dividerMouse = findDivider();
      final sizedBox = find.descendant(
        of: dividerMouse,
        matching: find.byType(SizedBox),
      );
      final box = tester.renderObject(sizedBox.first) as RenderBox;
      expect(box.size.width, 8.0);
    });
  });
}
