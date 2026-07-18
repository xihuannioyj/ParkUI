import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_popconfirm.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(child: child),
      ),
    );

void main() {
  group('ParkPopconfirm - basic rendering', () {
    testWidgets('creates with child widget', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Confirm action?',
          child: const Text('Delete'),
        ),
      ));
      expect(find.text('Delete'), findsOneWidget);
      // Bubble should not be visible initially
      expect(find.text('Confirm action?'), findsNothing);
    });

    testWidgets('tapping child shows popconfirm bubble', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Are you sure?',
          child: const Text('Trigger'),
        ),
      ));
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(find.text('Are you sure?'), findsOneWidget);
    });
  });

  group('ParkPopconfirm - interaction', () {
    testWidgets('confirm callback fires', (tester) async {
      int confirmCount = 0;
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Confirm?',
          onConfirm: () => confirmCount++,
          child: const Text('Click me'),
        ),
      ));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      // Find and tap the confirm button
      final confirmFinder = find.text('确定');
      expect(confirmFinder, findsOneWidget);
      await tester.tap(confirmFinder);
      await tester.pumpAndSettle();
      expect(confirmCount, 1);
    });

    testWidgets('cancel callback fires and closes bubble', (tester) async {
      int cancelCount = 0;
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Confirm?',
          onCancel: () => cancelCount++,
          child: const Text('Click me'),
        ),
      ));
      await tester.tap(find.text('Click me'));
      await tester.pumpAndSettle();

      final cancelFinder = find.text('取消');
      expect(cancelFinder, findsOneWidget);
      await tester.tap(cancelFinder);
      await tester.pumpAndSettle();
      expect(cancelCount, 1);
    });

    testWidgets('description renders in bubble', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Delete this?',
          description: 'This action cannot be undone',
          child: const Text('Delete'),
        ),
      ));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('This action cannot be undone'), findsOneWidget);
    });

    testWidgets('danger mode renders confirm button', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Dangerous action',
          danger: true,
          child: const Text('Delete All'),
        ),
      ));
      await tester.tap(find.text('Delete All'));
      await tester.pumpAndSettle();
      expect(find.text('Dangerous action'), findsOneWidget);
    });

    testWidgets('custom confirm and cancel text', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkPopconfirm(
          title: 'Sure?',
          confirmText: 'Yes',
          cancelText: 'No',
          child: const Text('Ask'),
        ),
      ));
      await tester.tap(find.text('Ask'));
      await tester.pumpAndSettle();
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });
  });
}
