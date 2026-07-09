import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: <ParkThemeData>[ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

/// Custom matcher: find ParkList regardless of generic type parameter.
Finder _findParkList() => find.byWidgetPredicate((Widget w) => w is ParkList);

void main() {
  group('ParkList', () {
    group('基础渲染', () {
      testWidgets('创建普通列表', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: <String>['A', 'B', 'C'],
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
        )));
        expect(_findParkList(), findsOneWidget);
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('空列表显示空状态', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: <String>[],
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
        )));
        // 默认显示 "暂无数据"
        expect(find.text('暂无数据'), findsOneWidget);
      });

      testWidgets('空列表显示自定义 emptyWidget', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: <String>[],
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          emptyWidget: const Center(child: Text('自定义空状态')),
        )));
        expect(find.text('自定义空状态'), findsOneWidget);
      });

      testWidgets('显示 header 和 footer', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: const <String>['A', 'B'],
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          header: const Text('列表头部'),
          footer: const Text('列表底部'),
        )));
        expect(find.text('列表头部'), findsOneWidget);
        expect(find.text('列表底部'), findsOneWidget);
      });

      testWidgets('split 分割线', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: const <String>['A', 'B', 'C'],
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          split: true,
        )));
        // 应该有 Divider widget
        expect(find.byType(Divider), findsWidgets);
      });
    });

    group('loading 骨架屏', () {
      testWidgets('loading 时显示骨架屏', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: const <String>['A'],
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          loading: true,
          loadingItemCount: 3,
        )));
        // 骨架屏应渲染 ParkSkeleton
        expect(find.byType(ParkSkeleton), findsWidgets);
      });
    });

    group('onLoadMore / loadingMore / noMore', () {
      testWidgets('启用 onLoadMore 时不抛异常', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 400,
          child: ParkList<String>(
            items: List<String>.generate(5, (int i) => 'Item $i'),
            itemBuilder: (BuildContext context, String item, int index) {
              return ListTile(title: Text(item));
            },
            onLoadMore: () async {
              await Future<void>.delayed(const Duration(milliseconds: 10));
            },
          ),
        )));
        expect(_findParkList(), findsOneWidget);
        expect(find.text('Item 0'), findsOneWidget);
      });

      testWidgets('loadingMore 时显示底部加载指示器', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: List<String>.generate(5, (int i) => 'Item $i'),
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          onLoadMore: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
          loadingMore: true,
        )));
        // loadingMore=true 应显示 "加载中..."
        expect(find.text('加载中...'), findsOneWidget);
        // 应有 CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('noMore 时显示 "已加载全部数据"', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: List<String>.generate(5, (int i) => 'Item $i'),
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          onLoadMore: () async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
          noMore: true,
          loadingMore: false,
        )));
        // noMore=true + loadingMore=false 应显示 "已加载全部数据"
        expect(find.text('已加载全部数据'), findsOneWidget);
      });

      testWidgets('loadMore 插槽优先级高于 onLoadMore 指示器', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: List<String>.generate(5, (int i) => 'Item $i'),
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          onLoadMore: () async {},
          loadingMore: true,
          loadMore: const Text('自定义加载更多'),
        )));
        // 自定义 loadMore 插槽应显示
        expect(find.text('自定义加载更多'), findsOneWidget);
      });

      testWidgets('loadingMore 为 false 且 noMore 为 false 时不显示底部提示', (tester) async {
        await tester.pumpWidget(_wrap(ParkList<String>(
          items: List<String>.generate(5, (int i) => 'Item $i'),
          itemBuilder: (BuildContext context, String item, int index) {
            return ListTile(title: Text(item));
          },
          onLoadMore: () async {},
          loadingMore: false,
          noMore: false,
        )));
        // 不应显示底部指示器
        expect(find.text('加载中...'), findsNothing);
        expect(find.text('已加载全部数据'), findsNothing);
      });
    });

    group('itemExtent 虚拟化', () {
      testWidgets('itemExtent 启用虚拟化渲染', (tester) async {
        await tester.pumpWidget(_wrap(SizedBox(
          height: 600,
          child: ParkList<String>(
            items: List<String>.generate(5, (int i) => 'Item $i'),
            itemBuilder: (BuildContext context, String item, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(item),
              );
            },
            itemExtent: 56,
          ),
        )));
        expect(_findParkList(), findsOneWidget);
        expect(find.text('Item 0'), findsOneWidget);
      });
    });
  });
}
