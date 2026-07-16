/// Golden tests for ParkTag variants.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import 'golden_test_helper.dart';

void main() {
  group('ParkTag Golden Tests', () {
    testWidgets('dark, light, outline variants', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkTag(text: 'Dark', variant: ParkTagVariant.dark),
          SizedBox(height: 4),
          const ParkTag(text: 'Light', variant: ParkTagVariant.light),
          SizedBox(height: 4),
          const ParkTag(text: 'Outline', variant: ParkTagVariant.outline),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_tag_variants.png'),
      );
    });

    testWidgets('color themes: primary, success, warning, danger', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkTag(text: 'Primary', theme: ParkTagTheme.primary),
          SizedBox(height: 4),
          const ParkTag(text: 'Success', theme: ParkTagTheme.success),
          SizedBox(height: 4),
          const ParkTag(text: 'Warning', theme: ParkTagTheme.warning),
          SizedBox(height: 4),
          const ParkTag(text: 'Danger', theme: ParkTagTheme.danger),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_tag_themes.png'),
      );
    });

    testWidgets('sizes small, medium, large', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkTag(text: 'Small', size: ParkTagSize.small),
          SizedBox(height: 4),
          const ParkTag(text: 'Medium', size: ParkTagSize.medium),
          SizedBox(height: 4),
          const ParkTag(text: 'Large', size: ParkTagSize.large),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_tag_sizes.png'),
      );
    });
  });
}
