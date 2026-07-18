import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_progress.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkProgress', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(value: 0.5)));
      expect(find.byType(ParkProgress), findsOneWidget);
    });
    testWidgets('百分比显示', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(value: 0.75, label: true)));
      expect(find.text('75%'), findsOneWidget);
    });
    testWidgets('custom color', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(value: 0.3, color: Colors.green)));
      expect(find.byType(ParkProgress), findsOneWidget);
    });

    testWidgets('dashboard type renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 0.6,
        type: ParkProgressType.dashboard,
      )));
      expect(find.byType(ParkProgress), findsOneWidget);
    });

    testWidgets('dashboard with label shows percentage', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 0.75,
        type: ParkProgressType.dashboard,
        label: true,
      )));
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('steps renders correct number of blocks', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 0.5,
        steps: 5,
      )));
      expect(find.byType(ParkProgress), findsOneWidget);
    });

    testWidgets('success status shows check icon when complete', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 1.0,
        status: ParkProgressStatus.success,
        label: true,
      )));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('error status shows error icon when complete', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 1.0,
        status: ParkProgressStatus.error,
        label: true,
      )));
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('custom label text', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 0.5,
        label: 'Half done',
      )));
      expect(find.text('Half done'), findsOneWidget);
    });

    testWidgets('formatLabel callback', (tester) async {
      await tester.pumpWidget(_wrap(ParkProgress(
        value: 0.75,
        label: true,
        formatLabel: (v) => '${(v * 100).toInt()} of 100',
      )));
      expect(find.text('75 of 100'), findsOneWidget);
    });

    testWidgets('value clamps to 0-1 range', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 1.5,
        label: true,
      )));
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('zero value shows 0%', (tester) async {
      await tester.pumpWidget(_wrap(const ParkProgress(
        value: 0.0,
        label: true,
      )));
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
