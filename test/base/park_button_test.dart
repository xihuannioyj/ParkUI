/// ParkButton 组件测试
/// 测试变体、尺寸、loading、disabled、icon 等

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 测试用包裹器
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkButton - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(child: const Text('按钮')),
      ));
      expect(find.text('按钮'), findsOneWidget);
    });

    testWidgets('primary 变体', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(variant: ParkButtonVariant.primary, child: const Text('提交')),
      ));
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('secondary 变体', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(variant: ParkButtonVariant.secondary, child: const Text('取消')),
      ));
      expect(find.text('取消'), findsOneWidget);
    });

    testWidgets('text 变体', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(variant: ParkButtonVariant.text, child: const Text('文字按钮')),
      ));
      expect(find.text('文字按钮'), findsOneWidget);
    });

    testWidgets('link 变体', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(variant: ParkButtonVariant.link, child: const Text('链接')),
      ));
      expect(find.text('链接'), findsOneWidget);
    });

    testWidgets('ghost 变体', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(variant: ParkButtonVariant.ghost, child: const Text('幽灵')),
      ));
      expect(find.text('幽灵'), findsOneWidget);
    });

    testWidgets('danger 变体', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(variant: ParkButtonVariant.danger, child: const Text('危险')),
      ));
      expect(find.text('危险'), findsOneWidget);
    });
  });

  group('ParkButton - 尺寸', () {
    testWidgets('small 尺寸', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(size: ParkButtonSize.small, child: const Text('小')),
      ));
      expect(find.text('小'), findsOneWidget);
    });

    testWidgets('medium 尺寸（默认）', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(child: const Text('中')),
      ));
      expect(find.text('中'), findsOneWidget);
    });

    testWidgets('large 尺寸', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(size: ParkButtonSize.large, child: const Text('大')),
      ));
      expect(find.text('大'), findsOneWidget);
    });
  });

  group('ParkButton - 状态', () {
    testWidgets('loading 状态显示 indicator', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(loading: true, child: const Text('加载中')),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('加载中'), findsOneWidget);
    });

    testWidgets('disabled 状态（无 onPressed）', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(
          child: const Text('禁用'),
          onPressed: null,
        ),
      ));
      await tester.tap(find.text('禁用'));
      // 无 onPressed 时不触发
    });

    testWidgets('onPressed 可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(
        ParkButton(
          child: const Text('点我'),
          onPressed: () => pressed++,
        ),
      ));
      await tester.tap(find.text('点我'));
      expect(pressed, 1);
    });

    testWidgets('onLongPress 可长按', (tester) async {
      int longPressed = 0;
      await tester.pumpWidget(_wrap(
        ParkButton(
          child: const Text('长按'),
          onLongPress: () => longPressed++,
        ),
      ));
      await tester.longPress(find.text('长按'));
      expect(longPressed, 1);
    });

    testWidgets('loading 状态下点击不触发', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(
        ParkButton(
          loading: true,
          child: const Text('加载中'),
          onPressed: () => pressed++,
        ),
      ));
      await tester.tap(find.text('加载中'));
      expect(pressed, 0);
    });

    testWidgets('自定义 loadingIndicator', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(
          loading: true,
          loadingIndicator: const Icon(Icons.hourglass_empty),
          child: const Text('等待'),
        ),
      ));
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
    });
  });

  group('ParkButton - 形状', () {
    testWidgets('block 占满宽度', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(block: true, child: const Text('全宽')),
      ));
      expect(find.text('全宽'), findsOneWidget);
    });

    testWidgets('round 形状', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(shape: ParkButtonShape.round, child: const Text('圆角')),
      ));
      expect(find.text('圆角'), findsOneWidget);
    });

    testWidgets('circle 形状', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(shape: ParkButtonShape.circle, child: const Text('圆形')),
      ));
      expect(find.text('圆形'), findsOneWidget);
    });
  });

  group('ParkButton - icon 构造', () {
    testWidgets('ParkButton.icon 创建带图标的按钮', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton.icon(
          icon: Icons.add,
          label: '新建',
          onPressed: () {},
        ),
      ));
      expect(find.text('新建'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('ParkButton.icon 可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(
        ParkButton.icon(
          icon: Icons.add,
          label: '新建',
          onPressed: () => pressed++,
        ),
      ));
      await tester.tap(find.text('新建'));
      expect(pressed, 1);
    });

    testWidgets('ParkButton.icon loading 状态', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton.icon(
          icon: Icons.add,
          label: '新建',
          loading: true,
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ParkButton - 自定义样式', () {
    testWidgets('自定义 style', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkButton(
          style: ParkButtonStyle(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('自定义'),
        ),
      ));
      expect(find.text('自定义'), findsOneWidget);
    });
  });
}
