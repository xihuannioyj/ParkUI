/// ParkBreadcrumb 基础渲染 + 折叠测试

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
  group('ParkBreadcrumb - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: '首页'),
            ParkBreadcrumbItem(label: '列表'),
            ParkBreadcrumbItem(label: '详情'),
          ],
        ),
      ));
      expect(find.byType(ParkBreadcrumb), findsOneWidget);
    });

    testWidgets('显示所有项文字', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: '首页'),
            ParkBreadcrumbItem(label: '列表'),
            ParkBreadcrumbItem(label: '详情'),
          ],
        ),
      ));
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('列表'), findsOneWidget);
      expect(find.text('详情'), findsOneWidget);
    });

    testWidgets('显示分隔符', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: 'A'),
            ParkBreadcrumbItem(label: 'B'),
          ],
          separator: const Text('>'),
        ),
      ));
      expect(find.text('>'), findsOneWidget);
    });

    testWidgets('空 items 不渲染内容', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(items: const []),
      ));
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('带图标项渲染图标', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: '首页', icon: Icons.home),
            ParkBreadcrumbItem(label: '详情'),
          ],
        ),
      ));
      expect(find.byIcon(Icons.home), findsOneWidget);
    });
  });

  group('ParkBreadcrumb - 折叠 (maxItems)', () {
    testWidgets('超出 maxItems 时显示省略号', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: '首页'),
            ParkBreadcrumbItem(label: '分类'),
            ParkBreadcrumbItem(label: '子分类'),
            ParkBreadcrumbItem(label: '品牌'),
            ParkBreadcrumbItem(label: '商品'),
          ],
          maxItems: 3,
        ),
      ));
      // 折叠后应显示 "..."
      expect(find.text('...'), findsOneWidget);
      // 第一项和最后两项应可见
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('商品'), findsOneWidget);
    });

    testWidgets('未超出 maxItems 时不折叠', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: 'A'),
            ParkBreadcrumbItem(label: 'B'),
            ParkBreadcrumbItem(label: 'C'),
          ],
          maxItems: 5,
        ),
      ));
      expect(find.text('...'), findsNothing);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('maxItems=2 时只显示首项和末项', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: const [
            ParkBreadcrumbItem(label: '首页'),
            ParkBreadcrumbItem(label: '中间1'),
            ParkBreadcrumbItem(label: '中间2'),
            ParkBreadcrumbItem(label: '末页'),
          ],
          maxItems: 2,
        ),
      ));
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('末页'), findsOneWidget);
      // 中间项被隐藏
      expect(find.text('中间1'), findsNothing);
      expect(find.text('中间2'), findsNothing);
    });
  });

  group('ParkBreadcrumb - 尺寸', () {
    testWidgets('small 尺寸渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          size: ParkBreadcrumbSize.small,
          items: const [
            ParkBreadcrumbItem(label: 'A'),
            ParkBreadcrumbItem(label: 'B'),
          ],
        ),
      ));
      expect(find.byType(ParkBreadcrumb), findsOneWidget);
    });

    testWidgets('large 尺寸渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          size: ParkBreadcrumbSize.large,
          items: const [
            ParkBreadcrumbItem(label: 'A'),
            ParkBreadcrumbItem(label: 'B'),
          ],
        ),
      ));
      expect(find.byType(ParkBreadcrumb), findsOneWidget);
    });
  });

  group('ParkBreadcrumb - 可点击项', () {
    testWidgets('onTap 回调触发', (tester) async {
      int tapped = 0;
      await tester.pumpWidget(_wrap(
        ParkBreadcrumb(
          items: [
            ParkBreadcrumbItem(label: '首页', onTap: () => tapped++),
            const ParkBreadcrumbItem(label: '详情'),
          ],
        ),
      ));
      await tester.tap(find.text('首页'));
      expect(tapped, 1);
    });
  });
}
