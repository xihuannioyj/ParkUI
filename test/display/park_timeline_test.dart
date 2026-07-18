import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_timeline.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 400, child: child),
        ),
      ),
    );

void main() {
  group('ParkTimeline - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          items: const [
            ParkTimelineItem(title: 'Event 1'),
            ParkTimelineItem(title: 'Event 2'),
          ],
        ),
      ));
      expect(find.text('Event 1'), findsOneWidget);
      expect(find.text('Event 2'), findsOneWidget);
    });

    testWidgets('renders description and time', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          items: const [
            ParkTimelineItem(
              title: 'Order placed',
              description: 'Your order has been received',
              time: '10:00',
            ),
          ],
        ),
      ));
      expect(find.text('Order placed'), findsOneWidget);
      expect(find.text('Your order has been received'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('empty items renders nothing', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          items: const [],
        ),
      ));
      expect(find.byType(ParkTimeline), findsOneWidget);
    });
  });

  group('ParkTimeline - features', () {
    testWidgets('custom icon renders in dot', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          items: const [
            ParkTimelineItem(title: 'Shipped', icon: Icons.local_shipping),
          ],
        ),
      ));
      expect(find.byIcon(Icons.local_shipping), findsOneWidget);
    });

    testWidgets('custom color applies to dot', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          items: const [
            ParkTimelineItem(title: 'Done', color: Colors.green),
          ],
        ),
      ));
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('pending mode shows loading indicator', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          pending: true,
          pendingLabel: 'Loading...',
          items: const [
            ParkTimelineItem(title: 'Event 1'),
          ],
        ),
      ));
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('custom dotWidget overrides default', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          items: [
            ParkTimelineItem(
              title: 'Custom Dot',
              dotWidget: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                key: const ValueKey('custom_dot'),
              ),
            ),
          ],
        ),
      ));
      expect(find.byKey(const ValueKey('custom_dot')), findsOneWidget);
    });
  });

  group('ParkTimeline - modes', () {
    testWidgets('right mode renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          mode: ParkTimelineMode.right,
          items: const [
            ParkTimelineItem(title: 'Right Event'),
          ],
        ),
      ));
      expect(find.text('Right Event'), findsOneWidget);
    });

    testWidgets('alternate mode renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          mode: ParkTimelineMode.alternate,
          items: const [
            ParkTimelineItem(title: 'Left'),
            ParkTimelineItem(title: 'Right'),
          ],
        ),
      ));
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('reverse mode reverses order', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTimeline(
          animationDuration: Duration.zero,
          animationDelay: Duration.zero,
          reverse: true,
          items: const [
            ParkTimelineItem(title: 'First'),
            ParkTimelineItem(title: 'Second'),
          ],
        ),
      ));
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
    });
  });

  group('ParkTimeline - enums', () {
    test('ParkTimelineMode has 3 values', () {
      expect(ParkTimelineMode.values.length, 3);
    });

    test('ParkTimelineLabelPlacement has 2 values', () {
      expect(ParkTimelineLabelPlacement.values.length, 2);
    });
  });
}
