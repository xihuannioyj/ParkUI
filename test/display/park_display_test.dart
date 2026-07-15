import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('基础展示组件应正常渲染', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ParkAvatar(text: '张三'),
            ParkBadge(count: 5, child: Icon(Icons.mail)),
            ParkCell(titleText: '设置', descriptionText: '应用设置', arrow: true),
            ParkEmpty(icon: Icons.inbox, description: '暂无数据'),
            ParkTag(text: '标签'),
            ParkProgress(value: 0.5, label: true),
            ParkResult(status: ParkResultStatus.success, title: '成功'),
            ParkFooter(text: 'Park UI'),
          ],
        ),
      ),
    );

    expect(find.text('张'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.text('标签'), findsOneWidget);
    expect(find.text('成功'), findsOneWidget);
    expect(find.text('Park UI'), findsOneWidget);
  });

  testWidgets('ParkCollapse 应支持展开收起', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        const ParkCollapse(
          items: <ParkCollapseItem>[
            ParkCollapseItem(
              key: 'a',
              title: '标题 A',
              content: Text('内容 A'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('标题 A'), findsOneWidget);
    await tester.tap(find.text('标题 A'));
    await tester.pumpAndSettle();
    expect(find.text('内容 A'), findsOneWidget);
  });

  testWidgets('ParkSkeleton 应支持基础骨架和文本骨架', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ParkSkeleton(width: 80, height: 12, animated: false),
            ParkSkeleton.text(lines: 2, animated: false),
          ],
        ),
      ),
    );

    expect(find.byType(ParkSkeleton), findsWidgets);
  });

  testWidgets('ParkSwiper 应展示页面内容', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        ParkSwiper(
          height: 120,
          children: <Widget>[
            Container(color: Colors.blue, child: const Text('第一页')),
            Container(color: Colors.green, child: const Text('第二页')),
          ],
        ),
      ),
    );

    expect(find.text('第一页'), findsOneWidget);
  });

  testWidgets('ParkTable 应展示表头和数据', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        const ParkTable(
          columns: <ParkTableColumn>[
            ParkTableColumn(key: 'name', title: '姓名'),
            ParkTableColumn(key: 'age', title: '年龄'),
          ],
          data: <Map<String, dynamic>>[
            <String, dynamic>{'name': '张三', 'age': '28'},
          ],
        ),
      ),
    );

    expect(find.text('姓名'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);
  });

  testWidgets('ParkCountdown 应展示倒计时文本', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildApp(
        const ParkCountdown(remaining: Duration(minutes: 1, seconds: 2)),
      ),
    );

    expect(find.textContaining('01'), findsWidgets);
  });
}
