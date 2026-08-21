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
  // ParkNotification keeps a static map of active notifications. Dismiss any
  // survivors after each test so global state never leaks across tests.
  tearDown(ParkNotification.hide);

  group('ParkNotification - show API', () {
    testWidgets('show() displays title and description', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(
        ctx,
        title: '通知标题',
        description: '通知描述',
        duration: Duration.zero, // stay open until dismissed
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('通知标题'), findsOneWidget);
      expect(find.text('通知描述'), findsOneWidget);
    });

    testWidgets('success type shows the success icon', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(
        ctx,
        title: '成功',
        type: ParkNotificationType.success,
        duration: Duration.zero,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('error type shows the error icon', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(
        ctx,
        title: '失败',
        type: ParkNotificationType.error,
        duration: Duration.zero,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('closable: false hides the close button', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(
        ctx,
        title: '不可关闭',
        closable: false,
        duration: Duration.zero,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('不可关闭'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('ParkNotification - interactions', () {
    testWidgets('tapping the close button fires onClose and removes it',
        (tester) async {
      bool closed = false;
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(
        ctx,
        title: '手动关闭',
        duration: Duration.zero,
        onClose: () => closed = true,
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('手动关闭'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(find.text('手动关闭'), findsNothing);
    });

    testWidgets('auto-closes after the duration and fires onClose',
        (tester) async {
      bool closed = false;
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(
        ctx,
        title: '自动关闭',
        duration: const Duration(milliseconds: 1500),
        onClose: () => closed = true,
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('自动关闭'), findsOneWidget);
      expect(closed, isFalse);

      // Advance past the auto-close timer, then settle the exit animation.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(find.text('自动关闭'), findsNothing);
    });

    testWidgets('hide() dismisses all active notifications', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkNotification.show(ctx, title: '通知A', duration: Duration.zero);
      ParkNotification.show(ctx, title: '通知B', duration: Duration.zero);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('通知A'), findsOneWidget);
      expect(find.text('通知B'), findsOneWidget);

      ParkNotification.hide();
      await tester.pumpAndSettle();

      expect(find.text('通知A'), findsNothing);
      expect(find.text('通知B'), findsNothing);
    });
  });

  group('ParkNotification - size', () {
    testWidgets('renders with all three sizes', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      // 三档尺寸同时弹出，均可正常渲染（不抛异常）。
      // 注意：show 通过 post-frame callback 插入 OverlayEntry，
      // 需在 pumpWidget 后的同一个待渲染帧内完成所有 show 调用。
      for (final size in ParkNotificationSize.values) {
        ParkNotification.show(
          ctx,
          title: '尺寸通知',
          description: '尺寸描述',
          duration: Duration.zero,
          size: size,
        );
      }
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('尺寸通知'), findsNWidgets(3));
      expect(find.text('尺寸描述'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });
}
