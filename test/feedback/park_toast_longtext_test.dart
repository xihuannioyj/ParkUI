import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

// 超长中文文本 (~200字)
const String longChineseText =
    '这是一段非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常非常长的测试文本用于验证Toast组件在极端情况下的表现';

// 超长英文文本 (无空格，无法断词)
const String longEnglishText =
    'ThisIsAVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryVeryLongText';

// 中等长度文本 (~80字)
const String mediumText = '这是一段中等长度的文本，用来测试当文本超过屏幕宽度时Toast的表现，确保不会溢出';

void main() {
  group('ParkToast 长文本压力测试', () {
    // ===== 通过静态API (overlay路径) 测试 =====
    testWidgets('静态show + 超长中文文本 (200字)', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longChineseText);
      await tester.pump();
      // 检查是否有渲染错误
      final exception = tester.takeException();
      expect(exception, isNull, reason: '长中文文本不应抛异常: $exception');
      expect(find.text(longChineseText), findsOneWidget);
    });

    testWidgets('静态show + 超长英文文本 (无空格)', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longEnglishText);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: '长英文文本不应抛异常: $exception');
    });

    testWidgets('静态success + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.success(ctx, longChineseText);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'success+长文本不应抛异常: $exception');
    });

    testWidgets('静态error + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.error(ctx, longChineseText);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'error+长文本不应抛异常: $exception');
    });

    testWidgets('静态warning + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.warning(ctx, longChineseText);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'warning+长文本不应抛异常: $exception');
    });

    testWidgets('静态loading + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      final dismiss = ParkToast.loading(ctx, longChineseText);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'loading+长文本不应抛异常: $exception');
      dismiss();
      await tester.pump();
    });

    // ===== 不同位置 =====
    testWidgets('top位置 + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longChineseText, position: ParkToastPosition.top);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'top+长文本不应抛异常: $exception');
    });

    testWidgets('bottom位置 + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longChineseText, position: ParkToastPosition.bottom);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'bottom+长文本不应抛异常: $exception');
    });

    // ===== 独立widget路径 =====
    testWidgets('ParkToast widget + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(const ParkToast(message: longChineseText)));
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'widget长文本不应抛异常: $exception');
      expect(find.text(longChineseText), findsOneWidget);
    });

    testWidgets('ParkToast widget + icon + 长文本', (tester) async {
      await tester.pumpWidget(_wrap(ParkToast(
        message: longChineseText,
        icon: const Icon(Icons.check_circle),
      )));
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'widget+icon+长文本不应抛异常: $exception');
    });

    // ===== 窄屏模拟 (320px宽) =====
    testWidgets('窄屏(320px) + 长文本', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longChineseText);
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: '窄屏长文本不应抛异常: $exception');
    });

    // ===== 超长文本 + onClick =====
    testWidgets('长文本 + onClick', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longChineseText, onClick: () {});
      await tester.pump();
      final exception = tester.takeException();
      expect(exception, isNull, reason: '长文本+onClick不应抛异常: $exception');
    });

    // ===== pumpAndSettle 验证无溢出 =====
    testWidgets('pumpAndSettle 验证无渲染溢出', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, longChineseText);
      await tester.pump();
      // pumpAndSettle 会检测渲染溢出
      await tester.pumpAndSettle();
      final exception = tester.takeException();
      expect(exception, isNull, reason: 'pumpAndSettle不应有溢出: $exception');
    });
  });
}
