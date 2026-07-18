import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_alert.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(child: child),
      ),
    );

void main() {
  group('ParkAlert - basic rendering', () {
    testWidgets('creates info alert without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(message: 'Info message'),
      ));
      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('success alert shows check icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(type: ParkAlertType.success, message: 'Success'),
      ));
      expect(find.text('Success'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('warning alert shows warning icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(type: ParkAlertType.warning, message: 'Warning'),
      ));
      expect(find.text('Warning'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('error alert shows error icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(type: ParkAlertType.error, message: 'Error occurred'),
      ));
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('ParkAlert - features', () {
    testWidgets('description renders below message', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(
          message: 'Title',
          description: 'Detailed description here',
        ),
      ));
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Detailed description here'), findsOneWidget);
    });

    testWidgets('closable shows close icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(
          message: 'Closable alert',
          closable: true,
        ),
      ));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('close callback fires on tap', (tester) async {
      int closeCount = 0;
      await tester.pumpWidget(_wrap(
        ParkAlert(
          message: 'Close me',
          closable: true,
          onClose: () => closeCount++,
        ),
      ));
      await tester.tap(find.byIcon(Icons.close));
      expect(closeCount, 1);
    });

    testWidgets('showIcon=false hides icon', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(
          message: 'No icon',
          showIcon: false,
        ),
      ));
      expect(find.byIcon(Icons.info_outline), findsNothing);
      expect(find.text('No icon'), findsOneWidget);
    });

    testWidgets('custom icon overrides default', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(
          message: 'Custom icon',
          icon: Icon(Icons.star),
        ),
      ));
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('custom messageWidget overrides message text', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(
          message: 'Ignored',
          messageWidget: Text('Custom message widget'),
        ),
      ));
      expect(find.text('Custom message widget'), findsOneWidget);
      expect(find.text('Ignored'), findsNothing);
    });

    testWidgets('banner mode renders without border radius', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAlert(
          message: 'Banner alert',
          banner: true,
        ),
      ));
      expect(find.text('Banner alert'), findsOneWidget);
    });
  });

  group('ParkAlert - enums', () {
    test('ParkAlertType has 4 values', () {
      expect(ParkAlertType.values.length, 4);
    });
  });
}
