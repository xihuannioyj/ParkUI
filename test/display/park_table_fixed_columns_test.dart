import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 阶段 1 P0 修复定向测试（T05 ParkTable 固定列）
///
/// 构造含 left/right 固定列的 ParkTable，pump 后断言三段式布局能正常渲染、
/// 固定列标题与数据均可见，且整个过程不抛异常。
void main() {
  group('T05 ParkTable 固定列', () {
    final List<ParkTableColumn> columns = <ParkTableColumn>[
      ParkTableColumn(
        key: 'name',
        title: '姓名',
        fixed: ParkColumnFixed.left,
        width: 120,
      ),
      ParkTableColumn(key: 'age', title: '年龄', width: 80),
      ParkTableColumn(
        key: 'op',
        title: '操作',
        fixed: ParkColumnFixed.right,
        width: 100,
      ),
    ];

    final List<Map<String, dynamic>> data = <Map<String, dynamic>>[
      {'name': '张三', 'age': '28', 'op': '编辑'},
      {'name': '李四', 'age': '32', 'op': '删除'},
    ];

    testWidgets('含 left/right 固定列时正常渲染且不抛异常', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension>[ParkThemeData.light()]),
          home: Scaffold(body: ParkTable(columns: columns, data: data)),
        ),
      );

      // 表格整体渲染
      expect(find.byType(ParkTable), findsOneWidget);

      // 三段式固定列布局已启用（左固定 + 中间 + 右固定），固定列标题可见
      expect(find.text('姓名'), findsWidgets); // 左固定列
      expect(find.text('年龄'), findsWidgets); // 中间列
      expect(find.text('操作'), findsWidgets); // 右固定列

      // 数据行渲染
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
    });

    testWidgets('无固定列时（全部 none）仍正常渲染', (WidgetTester tester) async {
      final List<ParkTableColumn> plain = <ParkTableColumn>[
        ParkTableColumn(key: 'name', title: '姓名', width: 120),
        ParkTableColumn(key: 'age', title: '年龄', width: 80),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: <ThemeExtension>[ParkThemeData.light()]),
          home: Scaffold(body: ParkTable(columns: plain, data: data)),
        ),
      );
      expect(find.byType(ParkTable), findsOneWidget);
      expect(find.text('姓名'), findsWidgets);
      expect(find.text('年龄'), findsWidgets);
    });
  });
}
