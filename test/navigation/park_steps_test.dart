import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkSteps', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 0,
        steps: [
          ParkStep(title: '步骤1'),
          ParkStep(title: '步骤2'),
          ParkStep(title: '步骤3'),
        ],
      )));
      expect(find.text('步骤1'), findsOneWidget);
      expect(find.text('步骤2'), findsOneWidget);
      expect(find.text('步骤3'), findsOneWidget);
    });
    testWidgets('当前步骤高亮', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 1,
        steps: [
          ParkStep(title: '已完成'),
          ParkStep(title: '进行中'),
          ParkStep(title: '待处理'),
        ],
      )));
      expect(find.text('进行中'), findsOneWidget);
    });
    testWidgets('纵向步骤条', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 0,
        steps: [
          ParkStep(title: '步骤1'),
          ParkStep(title: '步骤2'),
        ],
        direction: ParkStepsDirection.vertical,
      )));
      expect(find.text('步骤1'), findsOneWidget);
    });

    testWidgets('error status renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 1,
        steps: [
          ParkStep(title: 'Done', status: ParkStepStatus.finish),
          ParkStep(title: 'Failed', status: ParkStepStatus.error),
          ParkStep(title: 'Waiting'),
        ],
      )));
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('custom icon overrides number', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 0,
        steps: [
          ParkStep(title: 'Icon Step', icon: Icons.star),
          ParkStep(title: 'Normal'),
        ],
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('clickable steps trigger onStepTap', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(_wrap(ParkSteps(
        currentStep: 0,
        clickable: true,
        onStepTap: (i) => tappedIndex = i,
        steps: const [
          ParkStep(title: 'A'),
          ParkStep(title: 'B'),
        ],
      )));
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(tappedIndex, 1);
    });

    testWidgets('description text renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 0,
        steps: [
          ParkStep(title: 'Step1', description: 'Detail info'),
          ParkStep(title: 'Step2'),
        ],
      )));
      expect(find.text('Detail info'), findsOneWidget);
    });

    testWidgets('small size renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 0,
        size: ParkStepsSize.small,
        steps: [
          ParkStep(title: 'S1'),
          ParkStep(title: 'S2'),
        ],
      )));
      expect(find.text('S1'), findsOneWidget);
    });

    testWidgets('empty steps renders SizedBox', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        steps: [],
      )));
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('progressDot mode uses small dots', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        currentStep: 1,
        progressDot: true,
        steps: [
          ParkStep(title: 'A'),
          ParkStep(title: 'B'),
          ParkStep(title: 'C'),
        ],
      )));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });
}
