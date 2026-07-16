/// Golden tests for ParkBadge variants.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import 'golden_test_helper.dart';

void main() {
  group('ParkBadge Golden Tests', () {
    testWidgets('dot, count, and overflow variants', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkBadge(
            dot: true,
            child: Text('Dot Badge'),
          ),
          const SizedBox(height: 8),
          const ParkBadge(
            count: 5,
            child: Text('Count Badge'),
          ),
          const SizedBox(height: 8),
          const ParkBadge(
            count: 100,
            maxCount: 99,
            child: Text('Overflow Badge'),
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_badge_variants.png'),
      );
    });

    testWidgets('status variants: success, info, warning, error', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkBadge(
            status: ParkBadgeStatus.success,
            standaloneText: 'Success',
          ),
          SizedBox(height: 4),
          const ParkBadge(
            status: ParkBadgeStatus.info,
            standaloneText: 'Info',
          ),
          SizedBox(height: 4),
          const ParkBadge(
            status: ParkBadgeStatus.warning,
            standaloneText: 'Warning',
          ),
          SizedBox(height: 4),
          const ParkBadge(
            status: ParkBadgeStatus.error,
            standaloneText: 'Error',
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_badge_status.png'),
      );
    });

    testWidgets('small vs medium size', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkBadge(
            count: 3,
            size: ParkBadgeSize.small,
            child: Text('Small'),
          ),
          const SizedBox(height: 8),
          const ParkBadge(
            count: 3,
            size: ParkBadgeSize.medium,
            child: Text('Medium'),
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_badge_sizes.png'),
      );
    });
  });
}
