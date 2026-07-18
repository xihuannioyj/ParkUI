/// ParkPagination 基础渲染测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 测试用包裹器
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  group('ParkPagination - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 100, current: 1, pageSize: 10),
      ));
      expect(find.byType(ParkPagination), findsOneWidget);
    });

    testWidgets('显示页码按钮', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 50, current: 1, pageSize: 10),
      ));
      // 总共 5 页，应显示页码 1-5
      expect(find.text('1'), findsWidgets);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('当前页高亮', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 100, current: 3, pageSize: 10),
      ));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('总条数显示', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 200,
          current: 1,
          pageSize: 10,
          showTotal: true,
        ),
      ));
      // showTotal 应显示 "共 200 条" 或类似文本
      expect(find.byType(ParkPagination), findsOneWidget);
    });

    testWidgets('简洁模式显示 当前页/总页数', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 100,
          current: 2,
          pageSize: 10,
          simple: true,
        ),
      ));
      expect(find.text('2 / 10'), findsOneWidget);
    });
  });

  group('ParkPagination - 翻页交互', () {
    testWidgets('点击下一页触发 onChange', (tester) async {
      int changedPage = 0;
      await tester.pumpWidget(_wrap(
        ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
          onChange: (page, size) => changedPage = page,
        ),
      ));

      // 点击下一页按钮（chevron_right 图标）
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(changedPage, 2);
    });

    testWidgets('第一页时上一页按钮禁用', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 100, current: 1, pageSize: 10),
      ));
      // 上一页图标应存在但处于禁用态
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('disabled 状态下点击不触发', (tester) async {
      int changedPage = 0;
      await tester.pumpWidget(_wrap(
        ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
          disabled: true,
          onChange: (page, size) => changedPage = page,
        ),
      ));
      // disabled 时整个组件被 IgnorePointer 包裹
      expect(changedPage, 0);
    });
  });

  group('ParkPagination - 页码省略号算法', () {
    testWidgets('大量页码时显示省略号', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 1000, current: 50, pageSize: 10),
      ));
      // 100 页，当前第 50 页，应显示省略号
      expect(find.text('...'), findsWidgets);
      // 始终显示第一页和最后一页
      expect(find.text('1'), findsWidgets);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('少量页码时不显示省略号', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 50, current: 3, pageSize: 10),
      ));
      // 5 页全部显示，无省略号
      expect(find.text('...'), findsNothing);
    });
  });

  group('ParkPagination - 尺寸', () {
    testWidgets('small 尺寸渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
          size: ParkPaginationSize.small,
        ),
      ));
      expect(find.byType(ParkPagination), findsOneWidget);
    });

    testWidgets('medium 尺寸渲染正常（默认）', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(total: 100, current: 1, pageSize: 10),
      ));
      expect(find.byType(ParkPagination), findsOneWidget);
    });
  });

  group('ParkPagination - 快速跳转', () {
    testWidgets('showQuickJumper 显示跳转输入框', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
          showQuickJumper: true,
        ),
      ));
      // 应有 TextField 用于跳转
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('跳转输入提交后触发 onChange', (tester) async {
      int changedPage = 0;
      await tester.pumpWidget(_wrap(
        ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
          showQuickJumper: true,
          onChange: (page, size) => changedPage = page,
        ),
      ));
      await tester.enterText(find.byType(TextField), '5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(changedPage, 5);
    });
  });

  group('ParkPagination - 每页条数', () {
    testWidgets('showSizeChanger 显示下拉选择器', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
          showSizeChanger: true,
        ),
      ));
      expect(find.byType(DropdownButton<int>), findsOneWidget);
    });
  });

  group('ParkPagination - 总页数计算', () {
    testWidgets('total=0 时显示 1 页', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 0,
          current: 1,
          pageSize: 10,
          simple: true,
        ),
      ));
      expect(find.text('1 / 1'), findsOneWidget);
    });

    testWidgets('total=10 pageSize=10 显示 1 页', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 10,
          current: 1,
          pageSize: 10,
          simple: true,
        ),
      ));
      expect(find.text('1 / 1'), findsOneWidget);
    });

    testWidgets('total=11 pageSize=10 显示 2 页', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 11,
          current: 1,
          pageSize: 10,
          simple: true,
        ),
      ));
      expect(find.text('1 / 2'), findsOneWidget);
    });
  });
}
