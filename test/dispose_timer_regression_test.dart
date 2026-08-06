// CR60-10 dispose 后 Timer 回归测试
//
// 验证组件在 dispose 后，内部 Timer 不再触发 setState，
// 不会抛出 "setState() called after dispose()" 异常。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  // ─────────────────────────────────────────────────────────────────────────────
  // 1. ParkSwiper autoPlay=true → pump → 立即 dispose → 等待 timer 周期 → 不抛异常
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-10 ParkSwiper dispose timer regression', () {
    testWidgets('autoPlay timer does not fire setState after dispose',
        (WidgetTester tester) async {
      // Build a ParkSwiper with autoPlay enabled and a short interval
      await tester.pumpWidget(_wrap(
        ParkSwiper(
          autoPlay: true,
          interval: const Duration(seconds: 1),
          children: const [
            SizedBox(height: 200, child: Center(child: Text('Page 1'))),
            SizedBox(height: 200, child: Center(child: Text('Page 2'))),
            SizedBox(height: 200, child: Center(child: Text('Page 3'))),
          ],
        ),
      ));

      // Verify the swiper is rendered
      expect(find.byType(ParkSwiper), findsOneWidget);

      // Let the auto-play timer tick once
      await tester.pump(const Duration(seconds: 1));

      // Immediately dispose by replacing with a different widget
      await tester.pumpWidget(_wrap(const SizedBox()));

      // Wait for multiple timer periods to ensure no setState after dispose
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));

      // If we reach here without exception, the timer was properly cancelled
      expect(tester.takeException(), isNull);
    });

    testWidgets('swiper dispose during animation does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkSwiper(
          autoPlay: true,
          interval: const Duration(milliseconds: 500),
          animationDuration: const Duration(milliseconds: 350),
          children: const [
            SizedBox(height: 200, child: Center(child: Text('A'))),
            SizedBox(height: 200, child: Center(child: Text('B'))),
          ],
        ),
      ));

      // Trigger a page change by waiting for auto-play
      await tester.pump(const Duration(milliseconds: 500));
      // Start the animation
      await tester.pump(const Duration(milliseconds: 100));

      // Dispose mid-animation
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. ParkCountdown → start → 立即 dispose → 不抛异常
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-10 ParkCountdown dispose timer regression', () {
    testWidgets('countdown timer does not fire after dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkCountdown(
          remaining: const Duration(minutes: 5),
          onFinish: () {},
        ),
      ));

      expect(find.byType(ParkCountdown), findsOneWidget);

      // Let the countdown tick
      await tester.pump(const Duration(seconds: 1));

      // Immediately dispose
      await tester.pumpWidget(_wrap(const SizedBox()));

      // Wait for multiple timer periods
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);
    });

    testWidgets('countdown with external controller dispose does not crash',
        (WidgetTester tester) async {
      final controller = ParkCountdownController(
        remaining: const Duration(seconds: 30),
      );

      await tester.pumpWidget(_wrap(
        ParkCountdown(
          remaining: const Duration(seconds: 30),
          controller: controller,
        ),
      ));

      expect(find.byType(ParkCountdown), findsOneWidget);

      // Start the countdown
      controller.start(null);
      await tester.pump(const Duration(seconds: 1));

      // Dispose the widget
      await tester.pumpWidget(_wrap(const SizedBox()));

      // Wait for timer periods — controller's timer should be cancelled on dispose
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));

      expect(tester.takeException(), isNull);

      // Clean up controller
      controller.dispose();
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. ParkNotification autoClose → show → 立即 dismiss → 不抛异常
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-10 ParkNotification dispose timer regression', () {
    testWidgets('notification show then immediate dismiss does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkNotification.show(
                context,
                title: '测试通知',
                description: '这是一条测试通知',
                type: ParkNotificationType.info,
                duration: const Duration(seconds: 3),
              );
            },
            child: const Text('Show'),
          ),
        ),
      ));

      // Show the notification
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Immediately hide all notifications (simulates rapid dismiss)
      ParkNotification.hide();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Wait for the auto-close timer period to pass
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    testWidgets('notification auto-close timer does not fire after widget tree disposal',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkNotification.show(
                context,
                title: '自动关闭通知',
                type: ParkNotificationType.success,
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Notify'),
          ),
        ),
      ));

      // Show notification
      await tester.tap(find.text('Notify'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Dispose entire widget tree before auto-close fires
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();

      // Wait past the auto-close duration
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });

    testWidgets('multiple rapid show/dismiss cycles do not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkNotification.show(
                context,
                title: '快速通知',
                duration: const Duration(seconds: 1),
              );
            },
            child: const Text('Fire'),
          ),
        ),
      ));

      // Rapidly show and hide multiple times
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Fire'));
        await tester.pump(const Duration(milliseconds: 50));
        ParkNotification.hide();
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Wait for all timers to expire
      await tester.pump(const Duration(seconds: 2));

      expect(tester.takeException(), isNull);
    });
  });
}
