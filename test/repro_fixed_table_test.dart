// 复现：ParkTable 固定列 — pumpAndSettle 检测无限重建循环
// 模拟组件详情页结构: ListView > Card > Column > Container(width:infinity) > demo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget detailPageLike(Widget demo) => MaterialApp(
      theme: ThemeData(extensions: <ThemeExtension>[ParkThemeData.light()]),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: demo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

void main() {
  final List<ParkTableColumn> fixedCols = <ParkTableColumn>[
    const ParkTableColumn(
        key: 'name', title: '姓名', width: 100, fixed: ParkColumnFixed.left),
    const ParkTableColumn(key: 'dept', title: '部门', width: 120),
    const ParkTableColumn(key: 'role', title: '角色', width: 120),
    ParkTableColumn(
      key: 'status',
      title: '状态',
      width: 120,
      fixed: ParkColumnFixed.right,
      render: (row, index) => ParkTag(
        text: row['status'] as String,
        theme: ParkTagTheme.success,
      ),
    ),
  ];

  const List<Map<String, dynamic>> data = <Map<String, dynamic>>[
    <String, dynamic>{'name': '张三', 'dept': '研发', 'role': '工程师', 'status': '在职'},
    <String, dynamic>{'name': '李四', 'dept': '设计', 'role': '设计师', 'status': '在职'},
  ];

  testWidgets('固定列 spec demo + pumpAndSettle（检测无限帧循环）', (tester) async {
    await tester.pumpWidget(detailPageLike(ParkTable(columns: fixedCols, data: data)));
    await tester.pumpAndSettle();
    expect(find.text('张三'), findsWidgets);
  });

  testWidgets('固定列 + bounded height(SizedBox 300) + pumpAndSettle', (tester) async {
    await tester.pumpWidget(detailPageLike(
      SizedBox(height: 300, child: ParkTable(columns: fixedCols, data: data)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('张三'), findsWidgets);
  });

  testWidgets('固定列 + sticky + bounded + pumpAndSettle', (tester) async {
    await tester.pumpWidget(detailPageLike(
      SizedBox(
        height: 300,
        child: ParkTable(columns: fixedCols, data: data, sticky: true),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('张三'), findsWidgets);
  });

  testWidgets('固定列横向滚动交互不卡死', (tester) async {
    await tester.pumpWidget(detailPageLike(ParkTable(columns: fixedCols, data: data)));
    await tester.pumpAndSettle();
    // 模拟横向拖拽中间滚动区
    final mid = find.text('部门').last;
    await tester.drag(mid, const Offset(-80, 0));
    await tester.pumpAndSettle();
    expect(find.text('张三'), findsWidgets);
  });
}
