import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_countdown.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkCountdown', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkCountdown(remaining: const Duration(minutes: 5))));
      expect(find.byType(ParkCountdown), findsOneWidget);
    });
    testWidgets('显示时长', (tester) async {
      final controller = ParkCountdownController(remaining: const Duration(minutes: 1, seconds: 5));
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(minutes: 1, seconds: 5),
        controller: controller,
      )));
      expect(find.text('01'), findsOneWidget);
      expect(find.text('05'), findsOneWidget);
    });
    testWidgets('倒计时递减', (tester) async {
      final controller = ParkCountdownController(remaining: const Duration(seconds: 3));
      addTearDown(controller.pause);
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(seconds: 3),
        controller: controller,
      )));
      controller.start(() {});
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(controller.remaining.inSeconds, 1);
      controller.pause();
    });
    testWidgets('controller can reset', (tester) async {
      final controller = ParkCountdownController(remaining: const Duration(seconds: 3));
      addTearDown(controller.pause);
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(seconds: 3),
        controller: controller,
      )));
      controller.start(() {});
      await tester.pump(const Duration(seconds: 1));
      controller.reset();
      expect(controller.remaining, const Duration(seconds: 3));
      controller.pause();
    });

    testWidgets('small size renderss', (tester) async {
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(minutes: 1),
        size: ParkCountdownSize.small,
      )));
      expect(find.byType(ParkCountdown), findsOneWidget);
    });

    testWidgets('large size renders', (tester) async {
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(minutes: 1),
        size: ParkCountdownSize.large,
      )));
      expect(find.byType(ParkCountdown), findsOneWidget);
    });

    testWidgets('onFinish callback fires when countdown completes', (tester) async {
      bool finished = false;
      final controller = ParkCountdownController(remaining: const Duration(seconds: 2));
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(seconds: 2),
        controller: controller,
      )));
      controller.start(() => finished = true);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(finished, isTrue);
      controller.pause();
    });

    testWidgets('controller pause stops countdown', (tester) async {
      final controller = ParkCountdownController(remaining: const Duration(seconds: 5));
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(seconds: 5),
        controller: controller,
      )));
      controller.start(() {});
      await tester.pump(const Duration(seconds: 1));
      controller.pause();
      final remainingAfterPause = controller.remaining;
      await tester.pump(const Duration(seconds: 2));
      expect(controller.remaining, remainingAfterPause);
    });

    testWidgets('controller isRunning state', (tester) async {
      final controller = ParkCountdownController(remaining: const Duration(seconds: 5));
      expect(controller.isRunning, isFalse);
      controller.start(() {});
      expect(controller.isRunning, isTrue);
      controller.pause();
      expect(controller.isRunning, isFalse);
      controller.dispose();
    });

    testWidgets('round theme renders', (tester) async {
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(minutes: 1),
        theme: ParkCountdownTheme.round,
      )));
      expect(find.byType(ParkCountdown), findsOneWidget);
    });

    testWidgets('square theme renders', (tester) async {
      await tester.pumpWidget(_wrap(ParkCountdown(
        remaining: const Duration(minutes: 1),
        theme: ParkCountdownTheme.square,
      )));
      expect(find.byType(ParkCountdown), findsOneWidget);
    });
  });
}
