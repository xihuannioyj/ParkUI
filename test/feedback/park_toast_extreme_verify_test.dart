import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

// 1000+ 字超长中文（4行必然截断）
final String megaText = '这是超长提示信息' * 120;

// 大量换行符文本
const String newlineText = '第一行\n第二行\n第三行\n第四行\n第五行\n第六行\n第七行\n第八行\n第九行\n第十行';

// 每行 40 字的 20 行文本
final String multiLineText =
    '四十字一行的长文本内容用于模拟真实业务中多行提示信息的展示效果测试组件边界情况是否会出现布局异常情况\n' * 8;

void main() {
  for (final pos in ParkToastPosition.values) {
    testWidgets('mega text ${pos.name} - no exception', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, megaText, position: pos, duration: const Duration(seconds: 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final e = tester.takeException();
      expect(e, isNull, reason: '${pos.name}: $e');
    });

    testWidgets('mega text success ${pos.name} - no exception', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.success(ctx, megaText, position: pos, duration: const Duration(seconds: 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final e = tester.takeException();
      expect(e, isNull, reason: 'success ${pos.name}: $e');
    });
  }

  testWidgets('newline-heavy text - no exception', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const SizedBox()));
    final ctx = tester.element(find.byType(SizedBox));
    ParkToast.warning(ctx, newlineText, duration: const Duration(seconds: 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final e = tester.takeException();
    expect(e, isNull, reason: 'newline: $e');
  });

  testWidgets('multi-line wrapped text - no exception', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const SizedBox()));
    final ctx = tester.element(find.byType(SizedBox));
    ParkToast.error(ctx, multiLineText, duration: const Duration(seconds: 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final e = tester.takeException();
    expect(e, isNull, reason: 'multiline: $e');
  });

  testWidgets('small screen 320x568 mega text top - no exception', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(const SizedBox()));
    final ctx = tester.element(find.byType(SizedBox));
    ParkToast.show(ctx, megaText, position: ParkToastPosition.top, duration: const Duration(seconds: 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final e = tester.takeException();
    expect(e, isNull, reason: 'small top: $e');
  });
}
