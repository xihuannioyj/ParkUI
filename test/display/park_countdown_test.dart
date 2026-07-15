import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

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
    testWidgets('控制器可重置', (tester) async {
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
  });
}
