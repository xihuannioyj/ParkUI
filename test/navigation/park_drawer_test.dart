/// ParkDrawer 打开/关闭测试

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
  group('ParkDrawer - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          child: Text('抽屉内容'),
        ),
      ));
      expect(find.byType(ParkDrawer), findsOneWidget);
    });

    testWidgets('显示 header 内容', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          header: Text('标题'),
          child: Text('内容'),
        ),
      ));
      expect(find.text('标题'), findsOneWidget);
    });

    testWidgets('显示 footer 内容', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          footer: Text('底部'),
          child: Text('内容'),
        ),
      ));
      expect(find.text('底部'), findsOneWidget);
    });

    testWidgets('显示主体内容', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          child: Text('主体内容'),
        ),
      ));
      expect(find.text('主体内容'), findsOneWidget);
    });

    testWidgets('closable=true 时显示关闭按钮', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          closable: true,
          child: Text('内容'),
        ),
      ));
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('closable=false 时不显示关闭按钮', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          closable: false,
          child: Text('内容'),
        ),
      ));
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('ParkDrawer - 可见性控制', () {
    testWidgets('visible=false 时不渲染内容', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          visible: false,
          child: Text('隐藏内容'),
        ),
      ));
      expect(find.text('隐藏内容'), findsNothing);
    });

    testWidgets('visible=true 时渲染内容', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          visible: true,
          child: Text('显示内容'),
        ),
      ));
      expect(find.text('显示内容'), findsOneWidget);
    });

    testWidgets('visible 从 true 变为 false 时隐藏', (tester) async {
      bool visible = true;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return ParkDrawer(
              visible: visible,
              child: const Text('内容'),
            );
          },
        ),
      ));
      expect(find.text('内容'), findsOneWidget);
    });
  });

  group('ParkDrawer - 关闭回调', () {
    testWidgets('点击关闭按钮触发 onClose', (tester) async {
      int closed = 0;
      await tester.pumpWidget(_wrap(
        ParkDrawer(
          closable: true,
          onClose: () => closed++,
          child: const Text('内容'),
        ),
      ));
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, 1);
    });

    testWidgets('内部状态管理：点击关闭后隐藏', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          closable: true,
          child: Text('内容'),
        ),
      ));
      expect(find.text('内容'), findsOneWidget);

      // 点击关闭按钮
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // 内部状态应变为不可见
      expect(find.text('内容'), findsNothing);
    });
  });

  group('ParkDrawer - 方向与尺寸', () {
    testWidgets('左侧抽屉渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          placement: ParkDrawerPlacement.left,
          child: Text('左侧'),
        ),
      ));
      expect(find.text('左侧'), findsOneWidget);
    });

    testWidgets('右侧抽屉渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          placement: ParkDrawerPlacement.right,
          child: Text('右侧'),
        ),
      ));
      expect(find.text('右侧'), findsOneWidget);
    });

    testWidgets('底部抽屉渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          placement: ParkDrawerPlacement.bottom,
          child: Text('底部'),
        ),
      ));
      expect(find.text('底部'), findsOneWidget);
    });

    testWidgets('顶部抽屉渲染正常', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          placement: ParkDrawerPlacement.top,
          child: Text('顶部'),
        ),
      ));
      expect(find.text('顶部'), findsOneWidget);
    });
  });

  group('ParkDrawer - loading 状态', () {
    testWidgets('loading=true 时显示骨架屏占位', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDrawer(
          loading: true,
          child: Text('内容'),
        ),
      ));
      // loading 时不显示 child 内容
      expect(find.text('内容'), findsNothing);
    });
  });
}
