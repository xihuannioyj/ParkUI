import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkFormSection', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormSection(
        title: '基本信息',
        children: [ParkFormItem(label: '姓名', child: Text('张三'))],
      )));
      expect(find.text('基本信息'), findsOneWidget);
    });
    testWidgets('自定义children', (tester) async {
      await tester.pumpWidget(_wrap(const ParkFormSection(
        title: '分组',
        children: [
          ParkFormItem(label: '字段1', child: Text('值1')),
          ParkFormItem(label: '字段2', child: Text('值2')),
        ],
      )));
      expect(find.text('字段1：'), findsOneWidget);
      expect(find.text('字段2：'), findsOneWidget);
    });
  });
}
