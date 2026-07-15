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
  });
}
