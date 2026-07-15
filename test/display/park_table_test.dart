import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkTable', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'name', title: '姓名'),
          ParkTableColumn(key: 'age', title: '年龄'),
        ],
        data: const [
          {'name': '张三', 'age': '25'},
          {'name': '李四', 'age': '30'},
        ],
      )));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
    });
    testWidgets('空数据', (tester) async {
      await tester.pumpWidget(_wrap(ParkTable(
        columns: const [
          ParkTableColumn(key: 'c1', title: '列1'),
          ParkTableColumn(key: 'c2', title: '列2'),
        ],
        data: [],
      )));
      expect(find.text('暂无数据'), findsOneWidget);
    });
  });
}
