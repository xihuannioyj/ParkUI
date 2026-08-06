import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 全组件 fallback 免疫测试：
/// Overlay 环境无 Material → DefaultTextStyle 回退到 fallback style
/// （红色 48px monospace + 黄色下划线）。任何在 overlay 渲染的组件文本
/// 都必须显式 decoration: none 或有 Material 包裹，否则出现黄线/红字。
void main() {
  Future<void> expectNoFallback(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final e = tester.takeException();
    expect(e, isNull, reason: '渲染异常: $e');

    final texts = tester.widgetList<Text>(find.byType(Text)).toList();
    for (final t in texts) {
      final style = t.style;
      if (style == null) continue;
      // fallback style 特征：decoration underline（黄色）或 monospace/48px
      if (style.decoration == TextDecoration.underline) {
        fail('组件文本继承了 fallback 黄色下划线: "${t.data}" style=$style');
      }
      if (style.fontFamily == 'monospace' && style.fontSize == 48) {
        fail('组件文本继承了 fallback 红字 48px: "${t.data}"');
      }
    }
  }

  testWidgets('ParkToast.success 免疫 fallback', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(body: Text('home')),
    ));
    final ctx = tester.element(find.text('home'));
    ParkToast.success(ctx, '1', position: ParkToastPosition.top);
    await expectNoFallback(tester);
  });

  testWidgets('ParkLoading 免疫 fallback（内嵌 overlay 模式）', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(
        body: Center(
          child: ParkLoading(loading: true, text: '加载中', child: Text('x')),
        ),
      ),
    ));
    await expectNoFallback(tester);
  });

  testWidgets('ParkTooltip 免疫 fallback', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(
        body: Center(
          child: ParkTooltip(
            message: '提示文字',
            open: true,
            child: Text('trigger'),
          ),
        ),
      ),
    ));
    await expectNoFallback(tester);
  });

  testWidgets('ParkMessage.show 免疫 fallback', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(body: Text('home')),
    ));
    final ctx = tester.element(find.text('home'));
    ParkMessage.success(ctx, '消息标题', content: '消息内容');
    await expectNoFallback(tester);
  });

  testWidgets('ParkNotification.show 免疫 fallback', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(body: Text('home')),
    ));
    final ctx = tester.element(find.text('home'));
    ParkNotification.show(ctx,
        title: '通知标题', description: '通知描述');
    await expectNoFallback(tester);
  });

  testWidgets('ParkDrawer 免疫 fallback（用户 child 文本）', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(
        body: ParkDrawer(
          visible: true,
          widthFactor: 2 / 3,
          child: Text('抽屉内容'),
        ),
      ),
    ));
    await expectNoFallback(tester);
  });

  testWidgets('ParkTour 免疫 fallback', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: const Scaffold(
        body: ParkTour(
          open: true,
          steps: [
            ParkTourStep(title: '标题', description: '描述'),
          ],
          onClose: null,
          onFinish: null,
        ),
      ),
    ));
    await expectNoFallback(tester);
  });
}
