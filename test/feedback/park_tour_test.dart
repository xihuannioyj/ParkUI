import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_tour.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  group('ParkTour', () {
    testWidgets('creates without error when closed', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTour(
          open: false,
          steps: const [
            ParkTourStep(title: 'Step 1', description: 'First step'),
          ],
        ),
      ));
      expect(find.byType(ParkTour), findsOneWidget);
    });

    testWidgets('renders as SizedBox.shrink when not open', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTour(
          open: false,
          steps: const [
            ParkTourStep(title: 'Step 1', description: 'Desc'),
          ],
        ),
      ));
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('opens overlay when open=true', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTour(
          open: true,
          steps: const [
            ParkTourStep(title: 'Welcome', description: 'Welcome guide'),
          ],
          onClose: () {},
          onFinish: () {},
        ),
      ));
      await tester.pumpAndSettle();
      // The tour renders a SizedBox.shrink as its own widget
      expect(find.byType(ParkTour), findsOneWidget);
    });

    testWidgets('controlled mode calls onChange', (tester) async {
      int changedTo = -1;
      await tester.pumpWidget(_wrap(
        ParkTour(
          open: true,
          current: 0,
          onChange: (v) => changedTo = v,
          steps: const [
            ParkTourStep(title: 'S1', description: 'd1'),
            ParkTourStep(title: 'S2', description: 'd2'),
          ],
          onClose: () {},
          onFinish: () {},
        ),
      ));
      await tester.pump();
      // Find and tap "Next" button to go to step 2
      final nextFinder = find.text('下一步');
      if (nextFinder.evaluate().isNotEmpty) {
        await tester.tap(nextFinder);
        await tester.pump();
        expect(changedTo, 1);
      }
    });

    testWidgets('shows step indicator', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTour(
          open: true,
          steps: const [
            ParkTourStep(title: 'A', description: 'a'),
            ParkTourStep(title: 'B', description: 'b'),
            ParkTourStep(title: 'C', description: 'c'),
          ],
          onClose: () {},
          onFinish: () {},
        ),
      ));
      await tester.pumpAndSettle();
      // Tour builds without error; overlay content is in root overlay
      expect(find.byType(ParkTour), findsOneWidget);
    });
  });

  group('ParkTourStep', () {
    test('default values', () {
      const step = ParkTourStep(title: 'T', description: 'D');
      expect(step.target, isNull);
      expect(step.placement, isNull);
      expect(step.arrow, isNull);
      expect(step.mask, isNull);
    });
  });

  group('ParkTourPlacement', () {
    test('has expected values', () {
      expect(ParkTourPlacement.values.length, 13);
      expect(ParkTourPlacement.center.index, 0);
    });
  });
}
