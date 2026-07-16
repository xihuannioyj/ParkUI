/// Golden tests for ParkButton variants.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import 'golden_test_helper.dart';

void main() {
  group('ParkButton Golden Tests', () {
    testWidgets('primary and secondary variants', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          ParkButton(
            variant: ParkButtonVariant.primary,
            child: const Text('Primary'),
          ),
          const SizedBox(height: 8),
          ParkButton(
            variant: ParkButtonVariant.secondary,
            child: const Text('Secondary'),
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_button_variants.png'),
      );
    });

    testWidgets('text and link variants', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          ParkButton(
            variant: ParkButtonVariant.text,
            child: const Text('Text Button'),
          ),
          const SizedBox(height: 8),
          ParkButton(
            variant: ParkButtonVariant.link,
            child: const Text('Link Button'),
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_button_text_link.png'),
      );
    });

    testWidgets('sizes small, medium, large', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          ParkButton(size: ParkButtonSize.small, child: const Text('Small')),
          const SizedBox(height: 8),
          ParkButton(size: ParkButtonSize.medium, child: const Text('Medium')),
          const SizedBox(height: 8),
          ParkButton(size: ParkButtonSize.large, child: const Text('Large')),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_button_sizes.png'),
      );
    });
  });
}
