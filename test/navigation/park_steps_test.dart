import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkSteps', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        current: 0,
        steps: ['步骤1', '步骤2', '步骤3'],
      )));
      expect(find.text('步骤1'), findsOneWidget);
      expect(find.text('步骤2'), findsOneWidget);
      expect(find.text('步骤3'), findsOneWidget);
    });
    testWidgets('当前步骤高亮', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        current: 1,
        steps: ['已完成', '进行中', '待处理'],
      )));
      expect(find.text('进行中'), findsOneWidget);
    });
    testWidgets('纵向步骤条', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSteps(
        current: 0,
        steps: ['步骤1', '步骤2'],
        direction: Axis.vertical,
      )));
      expect(find.text('步骤1'), findsOneWidget);
    });
  });
}
