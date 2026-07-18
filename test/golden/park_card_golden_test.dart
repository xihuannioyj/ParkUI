/// Golden tests for ParkCard variants.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_card.dart';

import 'golden_test_helper.dart';

void main() {
  group('ParkCard Golden Tests', () {
    testWidgets('outlined and ghost variants', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          ParkCard(
            titleText: 'Outlined Card',
            variant: ParkCardVariant.outlined,
            child: const Text('Card content'),
          ),
          const SizedBox(height: 16),
          ParkCard(
            titleText: 'Ghost Card',
            variant: ParkCardVariant.ghost,
            child: const Text('Ghost content'),
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_card_variants.png'),
      );
    });

    testWidgets('card with actions bar', (tester) async {
      await tester.pumpWidget(
        goldenWrapSized(
          width: 360,
          height: 200,
          ParkCard(
            titleText: 'Card with Actions',
            actions: [
              TextButton(onPressed: () {}, child: const Text('Action 1')),
              TextButton(onPressed: () {}, child: const Text('Action 2')),
            ],
            child: const Text('Body content'),
          ),
        ),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_card_actions.png'),
      );
    });

    testWidgets('small size vs default size', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          ParkCard(
            titleText: 'Default Size',
            size: ParkCardSize.defaultSize,
            child: const Text('Default padding'),
          ),
          const SizedBox(height: 16),
          ParkCard(
            titleText: 'Small Size',
            size: ParkCardSize.small,
            child: const Text('Small padding'),
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_card_sizes.png'),
      );
    });
  });
}
