import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_result.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkResult', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(title: 'Test')));
      expect(find.byType(ParkResult), findsOneWidget);
    });

    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        title: 'Operation Successful',
      )));
      expect(find.text('Operation Successful'), findsOneWidget);
    });

    testWidgets('displays description', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        title: 'Success',
        description: 'Your operation completed successfully.',
      )));
      expect(find.text('Your operation completed successfully.'), findsOneWidget);
    });

    testWidgets('success status shows check_circle icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        status: ParkResultStatus.success,
        title: 'Success',
      )));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('error status shows error icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        status: ParkResultStatus.error,
        title: 'Error',
      )));
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('warning status shows warning icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        status: ParkResultStatus.warning,
        title: 'Warning',
      )));
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('info status shows info icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        status: ParkResultStatus.info,
        title: 'Info',
      )));
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('displays actions', (tester) async {
      await tester.pumpWidget(_wrap(ParkResult(
        title: 'Done',
        actions: [
          ElevatedButton(onPressed: () {}, child: const Text('OK')),
        ],
      )));
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('forbidden factory creates 403 result', (tester) async {
      await tester.pumpWidget(_wrap(ParkResult.forbidden()));
      expect(find.byType(ParkResult), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('notFound factory creates 404 result', (tester) async {
      await tester.pumpWidget(_wrap(ParkResult.notFound()));
      expect(find.byType(ParkResult), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('serverError factory creates 500 result', (tester) async {
      await tester.pumpWidget(_wrap(ParkResult.serverError()));
      expect(find.byType(ParkResult), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });

    testWidgets('custom icon overrides default', (tester) async {
      await tester.pumpWidget(_wrap(const ParkResult(
        status: ParkResultStatus.success,
        title: 'Custom',
        icon: Icon(Icons.star, size: 56),
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });
  });
}
