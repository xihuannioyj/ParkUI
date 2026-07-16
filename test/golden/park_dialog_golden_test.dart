/// Golden tests for ParkDialog variants.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

import 'golden_test_helper.dart';

void main() {
  group('ParkDialog Golden Tests', () {
    testWidgets('default dialog with confirm and cancel', (tester) async {
      await tester.pumpWidget(
        goldenWrapSized(
          width: 320,
          height: 200,
          ParkDialog(
            title: 'Confirm',
            content: 'Are you sure you want to proceed?',
            confirmText: 'OK',
            cancelText: 'Cancel',
            onConfirm: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_dialog_confirm.png'),
      );
    });

    testWidgets('single-button dialog (no cancel)', (tester) async {
      await tester.pumpWidget(
        goldenWrapSized(
          width: 320,
          height: 180,
          ParkDialog(
            title: 'Notice',
            content: 'Operation completed successfully.',
            confirmText: 'Got it',
            onConfirm: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_dialog_single_button.png'),
      );
    });

    testWidgets('dialog with custom content widget', (tester) async {
      await tester.pumpWidget(
        goldenWrapSized(
          width: 320,
          height: 220,
          ParkDialog(
            title: 'Custom Content',
            content: '',
            onConfirm: () {},
          ),
        ),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/park_dialog_custom.png'),
      );
    });
  });
}
