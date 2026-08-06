import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  // 超长中文 — 200字无换行
  const longChinese = '这是一段非常非常长的提示信息用于测试ParkToast在极端情况下是否会出现布局溢出或者渲染错误'
      '我们需要确保组件能够正确处理各种长度的文本内容而不会导致界面崩溃或者显示异常'
      '这是商业组件必须具备的基本健壮性要求请确保所有边界条件都被正确处理';

  // 超长英文 — 无空格不可断
  const longEnglish =
      'ThisIsAnExtremelyLongEnglishMessageWithoutAnySpacesToTestWhetherTheToastComponentCanHandleUnbreakableTextWithoutOverflowingOrCrashingTheEntireApplicationLayout';

  group('ParkToast overflow detection - static API (overlay path)', () {
    testWidgets('long Chinese text via ParkToast.show - no overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.show(ctx, longChinese,
          duration: const Duration(seconds: 10));
      await tester.pump();

      // 关键：takeException 能捕获渲染管线的overflow异常
      final exception = tester.takeException();
      expect(exception, isNull,
          reason: '长中文文本不应产生渲染异常，实际异常: $exception');
      expect(find.text(longChinese), findsOneWidget);
    });

    testWidgets('long English text (unbreakable) via ParkToast.show',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.show(ctx, longEnglish,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: '不可断行英文不应产生渲染异常: $exception');
    });

    testWidgets('long text via ParkToast.success (overlay+icon)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.success(ctx, longChinese,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: 'success+长文本不应产生渲染异常: $exception');
    });

    testWidgets('long text via ParkToast.error (overlay+icon)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.error(ctx, longChinese,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: 'error+长文本不应产生渲染异常: $exception');
    });

    testWidgets('long text via ParkToast.warning (overlay+icon)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.warning(ctx, longChinese,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: 'warning+长文本不应产生渲染异常: $exception');
    });

    testWidgets('long text top position - no overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.show(ctx, longChinese,
          position: ParkToastPosition.top,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull, reason: '顶部位置+长文本不应溢出: $exception');
    });

    testWidgets('long text bottom position - no overflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.show(ctx, longChinese,
          position: ParkToastPosition.bottom,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull, reason: '底部位置+长文本不应溢出: $exception');
    });

    testWidgets('narrow screen 320px - long text', (tester) async {
      tester.view.physicalSize = const Size(960, 1600);
      tester.view.devicePixelRatio = 3.0; // 320px logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.show(ctx, longChinese,
          duration: const Duration(seconds: 10));
      await tester.pump();

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: '320px窄屏+长文本不应溢出: $exception');
    });
  });

  group('ParkToast overflow detection - widget path (standalone)', () {
    testWidgets('standalone ParkToast widget with long text', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(
        const ParkToast(message: longChinese),
      ));

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: '独立widget长文本不应溢出: $exception');
      expect(find.text(longChinese), findsOneWidget);
    });

    testWidgets('standalone ParkToast with icon + long text', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(
        ParkToast(
          message: longChinese,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        ),
      ));

      final exception = tester.takeException();
      expect(exception, isNull,
          reason: '独立widget+icon+长文本不应溢出: $exception');
    });
  });

  group('ParkToast - toast width constraint verification', () {
    testWidgets('toast container does not exceed 82% screen width',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0; // 360px logical
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));

      ParkToast.show(ctx, longChinese,
          duration: const Duration(seconds: 10));
      await tester.pump();

      // 找到toast的Container（有decoration的那个）
      final containerFinder = find.descendant(
        of: find.byType(Overlay),
        matching: find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius != null),
      );

      expect(containerFinder, findsWidgets);
      // 验证Container的renderObject宽度不超过屏幕82%
      final renderBox =
          tester.renderObject(containerFinder.first) as RenderBox;
      final maxWidth = 360.0 * 0.82; // 360 * 0.82 = 295.2
      expect(renderBox.size.width, lessThanOrEqualTo(maxWidth + 32),
          // 32 = 外层Padding(horizontal: park.spacing.lg=16) * 2
          reason:
              'toast宽度${renderBox.size.width}不应超过约束上限$maxWidth+padding');
    });
  });
}
