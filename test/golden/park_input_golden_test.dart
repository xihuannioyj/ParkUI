/// Golden tests for ParkInput states.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import 'golden_test_helper.dart';

void main() {
  group('ParkInput Golden Tests', () {
    testWidgets('default and with label', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkInput(hintText: 'Default input'),
          const SizedBox(height: 16),
          const ParkInput(label: 'Username', hintText: 'Enter username'),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_input_default.png'),
      );
    });

    testWidgets('disabled and readOnly states', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkInput(hintText: 'Disabled', enabled: false),
          const SizedBox(height: 16),
          const ParkInput(hintText: 'Read-only', readOnly: true),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_input_states.png'),
      );
    });

    testWidgets('with prefix icon and clearable', (tester) async {
      await tester.pumpWidget(
        goldenWrapColumn([
          const ParkInput(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search),
          ),
          const SizedBox(height: 16),
          const ParkInput(
            hintText: 'Clearable',
            clearable: true,
          ),
        ]),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_input_accessories.png'),
      );
    });
  });
}
