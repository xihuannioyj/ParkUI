import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkTable', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTable(
        columns: ['姓名', '年龄'],
        rows: [
          ['张三', '25'],
          ['李四', '30'],
        ],
      )));
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
    });
    testWidgets('空数据', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTable(columns: ['列1', '列2'], rows: [])));
      expect(find.text('暂无数据'), findsOneWidget);
    });
  });
}
