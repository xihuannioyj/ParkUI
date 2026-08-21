import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  // Reset the global message config (maxCount etc.) between tests.
  setUp(ParkMessage.resetConfig);

  // ===========================================================================
  // ParkMessage — 直接渲染（Widget 形态）
  // ===========================================================================
  group('ParkMessage - widget rendering', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMessage(
        title: '提示标题',
        content: '提示内容',
      )));

      expect(find.text('提示标题'), findsOneWidget);
      expect(find.text('提示内容'), findsOneWidget);
      // CR60-08: verify ParkMessage widget properties
      final msg = tester.widget<ParkMessage>(find.byType(ParkMessage));
      expect(msg.title, '提示标题');
      expect(msg.content, '提示内容');
      expect(msg.closable, isFalse);
    });

    testWidgets('renders a custom icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMessage(
        title: '带图标',
        icon: Icon(Icons.star),
      )));

      expect(find.byIcon(Icons.star), findsOneWidget);
      // CR60-08: verify icon widget and ParkMessage.icon property
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.icon, Icons.star);
      final msg = tester.widget<ParkMessage>(find.byType(ParkMessage));
      expect(msg.icon, isNotNull);
      expect(msg.title, '带图标');
    });

    testWidgets('closable shows a close icon', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMessage(
        title: '可关闭',
        closable: true,
      )));

      expect(find.byIcon(Icons.close), findsOneWidget);
      // CR60-08: verify closable property on widget
      final msg = tester.widget<ParkMessage>(find.byType(ParkMessage));
      expect(msg.closable, isTrue);
      expect(msg.title, '可关闭');
    });

    testWidgets('三档尺寸均可渲染', (tester) async {
      await tester.pumpWidget(_wrap(const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ParkMessage(title: '小', size: ParkMessageSize.small),
          ParkMessage(title: '中', size: ParkMessageSize.medium),
          ParkMessage(title: '大', size: ParkMessageSize.large),
        ],
      )));

      expect(find.text('小'), findsOneWidget);
      expect(find.text('中'), findsOneWidget);
      expect(find.text('大'), findsOneWidget);
      final msgs = tester
          .widgetList<ParkMessage>(find.byType(ParkMessage))
          .toList();
      expect(
        msgs.map((m) => m.size),
        [ParkMessageSize.small, ParkMessageSize.medium, ParkMessageSize.large],
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ===========================================================================
  // ParkMessage — 静态弹出 API（Overlay + 自动关闭）
  // ===========================================================================
  group('ParkMessage - static show API', () {
    testWidgets('info() shows a message via the overlay then auto-dismisses',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkMessage.info(ctx, '已保存', duration: const Duration(seconds: 2));
      // First pump fires the postFrameCallback that inserts the overlay entry,
      // the second builds the message widget.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('已保存'), findsOneWidget);

      // Advance past the duration so the dismiss timer fires and cleans up.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('已保存'), findsNothing);
    });

    testWidgets('success() shows the success icon', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkMessage.success(
        ctx,
        '操作成功',
        duration: const Duration(milliseconds: 200),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('操作成功'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });

    testWidgets('error() shows the error icon', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkMessage.error(
        ctx,
        '操作失败',
        duration: const Duration(milliseconds: 200),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('操作失败'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });

    testWidgets('auto-dismiss fires onClose', (tester) async {
      bool closed = false;
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkMessage.info(
        ctx,
        '自动关闭',
        duration: const Duration(milliseconds: 300),
        onClose: () => closed = true,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('自动关闭'), findsOneWidget);
      expect(closed, isFalse);

      // Advance past the duration → timer fires → exit animation → onClose.
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(find.text('自动关闭'), findsNothing);
    });

    testWidgets('tapping the message fires onClick and dismisses it',
        (tester) async {
      bool clicked = false;
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkMessage.info(
        ctx,
        '点我',
        duration: const Duration(seconds: 5),
        onClick: () => clicked = true,
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('点我'), findsOneWidget);

      await tester.tap(find.text('点我'));
      await tester.pumpAndSettle();
      expect(clicked, isTrue);
      // _handleTap closes the message after invoking the callback.
      expect(find.text('点我'), findsNothing);
    });

    testWidgets('info() 支持三档尺寸同时弹出', (tester) async {
      ParkMessage.config(maxCount: 3);
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      // 三档尺寸同时弹出，均可正常渲染（不抛异常）。
      for (final size in ParkMessageSize.values) {
        ParkMessage.info(
          ctx,
          '尺寸消息',
          content: '尺寸内容',
          duration: const Duration(seconds: 2),
          size: size,
        );
      }
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('尺寸消息'), findsNWidgets(3));
      expect(find.text('尺寸内容'), findsNWidgets(3));
      expect(tester.takeException(), isNull);

      // 清理：推进过 duration，让自动关闭定时器触发并完成退出动画。
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('尺寸消息'), findsNothing);
    });
  });
}
