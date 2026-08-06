import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_card.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 360, child: child),
        ),
      ),
    );

void main() {
  group('ParkCard - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Test Card',
          child: const Text('Card content'),
        ),
      ));
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('renders without title', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkCard(child: Text('No title')),
      ));
      expect(find.text('No title'), findsOneWidget);
    });

    testWidgets('custom title widget overrides titleText', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkCard(
          title: Text('Custom Title'),
          titleText: 'Ignored Title',
          child: Text('Body'),
        ),
      ));
      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Ignored Title'), findsNothing);
    });
  });

  group('ParkCard - header features', () {
    testWidgets('extra widget renders in header', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Title',
          extra: const Text('More'),
          child: const Text('Body'),
        ),
      ));
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('description renders below title', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Title',
          description: 'Card description text',
          child: const Text('Body'),
        ),
      ));
      expect(find.text('Card description text'), findsOneWidget);
    });

    testWidgets('icon renders in header', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Title',
          icon: const Icon(Icons.star),
          child: const Text('Body'),
        ),
      ));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('showIndicator renders colored bar', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Title',
          showIndicator: true,
          child: const Text('Body'),
        ),
      ));
      expect(find.byType(ParkCard), findsOneWidget);
    });
  });

  group('ParkCard - actions bar', () {
    testWidgets('actions bar renders with dividers', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Title',
          actions: [
            TextButton(onPressed: () {}, child: const Text('Action 1')),
            TextButton(onPressed: () {}, child: const Text('Action 2')),
          ],
          child: const Text('Body'),
        ),
      ));
      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('empty actions list does not render bar', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Title',
          actions: const [],
          child: const Text('Body'),
        ),
      ));
      expect(find.byType(VerticalDivider), findsNothing);
    });
  });

  group('ParkCard - variants & states', () {
    testWidgets('ghost variant renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Ghost',
          variant: ParkCardVariant.ghost,
          child: const Text('Content'),
        ),
      ));
      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('inner variant renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Inner',
          variant: ParkCardVariant.inner,
          child: const Text('Content'),
        ),
      ));
      expect(find.text('Inner'), findsOneWidget);
    });

    testWidgets('small size renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Small',
          size: ParkCardSize.small,
          child: const Text('Content'),
        ),
      ));
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('loading shows skeleton', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Loading Card',
          loading: true,
          child: const Text('Should not appear'),
        ),
      ));
      expect(find.text('Should not appear'), findsNothing);
      expect(find.text('Loading Card'), findsOneWidget);
    });

    testWidgets('collapsible card toggles content', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Collapsible',
          collapsible: true,
          child: const Text('Hidden content'),
        ),
      ));
      expect(find.text('Hidden content'), findsOneWidget);

      // Tap the header to collapse
      await tester.tap(find.text('Collapsible'));
      await tester.pump();
      expect(find.text('Hidden content'), findsNothing);

      // Tap again to expand
      await tester.tap(find.text('Collapsible'));
      await tester.pump();
      expect(find.text('Hidden content'), findsOneWidget);
    });

    testWidgets('onPressed callback fires', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'Clickable',
          onPressed: () => tapCount++,
          child: const Text('Body'),
        ),
      ));
      await tester.tap(find.byType(ParkCard));
      expect(tapCount, 1);
    });

    testWidgets('cover renders above title', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCard(
          titleText: 'With Cover',
          cover: Container(height: 50, color: Colors.blue, key: const ValueKey('cover')),
          child: const Text('Body'),
        ),
      ));
      expect(find.byKey(const ValueKey('cover')), findsOneWidget);
    });
  });

  group('ParkCard - enums', () {
    test('ParkCardVariant has 4 values', () {
      expect(ParkCardVariant.values.length, 4);
    });

    test('ParkCardSize has 2 values', () {
      expect(ParkCardSize.values.length, 2);
    });
  });
}
