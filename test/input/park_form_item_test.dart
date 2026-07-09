import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkFormItem', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormItem(label: '姓名', child: Text('内容'))));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('内容'), findsOneWidget);
    });
    testWidgets('required标记', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormItem(label: '必填项', required: true, child: Text('内容'))));
      expect(find.text('*'), findsOneWidget);
    });
    testWidgets('显示helpText', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormItem(label: '字段', helpText: '辅助说明', child: Text('内容'))));
      expect(find.text('辅助说明'), findsOneWidget);
    });
  });
}
