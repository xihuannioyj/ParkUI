import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 模拟 ylzj 的 Tips 调用场景：
/// - ctx 来自 Navigator root overlay（GlobalKey<NavigatorState>）
/// - position: top + success（带图标）
/// - 刘海屏 padding（SafeArea 生效）
void main() {
  final navKey = GlobalKey<NavigatorState>();

  Widget app() => MaterialApp(
        navigatorKey: navKey,
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(body: Center(child: Text('home'))),
      );

  void ylzjStyleToast(String message) {
    final ctx =
        navKey.currentState?.overlay?.context ?? navKey.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ParkToast.success(ctx, message, position: ParkToastPosition.top);
    });
  }

  testWidgets('短文本 top+success+刘海 无异常', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0; // 360x640
    tester.view.padding = const FakeViewPadding(
      top: 44, bottom: 34, left: 0, right: 0,
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(app());
    ylzjStyleToast('登录成功,欢迎回来!');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final e = tester.takeException();
    expect(e, isNull, reason: '短文本 top toast 异常: $e');
  });

  testWidgets('长文本 top+success+刘海 无异常', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(
      top: 44, bottom: 34, left: 0, right: 0,
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(app());
    ylzjStyleToast(
      '这是一段非常非常长的错误提示文本，用于验证带图标的 Toast 在超长内容下文本自动收缩换行并截断省略，图标保持完整显示，不会出现布局越界报错，也不会撑破屏幕边缘。',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final e = tester.takeException();
    expect(e, isNull, reason: '长文本 top toast 异常: $e');
  });

  testWidgets('toast 后立即切换路由（offAllNamed 场景）无异常', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(
      top: 44, bottom: 34, left: 0, right: 0,
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(app());
    // 登录成功时序：dismiss → toast(postFrame) → 路由切换
    ylzjStyleToast('登录成功,欢迎回来!');
    navKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Scaffold(body: Text('main'))),
      (route) => false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 2)); // toast 自动关闭
    await tester.pump(const Duration(milliseconds: 400));
    final e = tester.takeException();
    expect(e, isNull, reason: 'toast+路由切换异常: $e');
  });

  // ── ScreenUtil 场景模拟：MediaQuery.size 被替换为设计稿假尺寸 375x812，
  //    实际渲染约束 360x640。ParkToast 必须按真实约束布局，不受假尺寸影响。

// ── ScreenUtil 场景模拟：MediaQuery.size 被替换为设计稿假尺寸 375x812，
//    实际渲染约束 360x640。ParkToast 必须按真实约束布局，不受假尺寸影响。
  group('ParkToast 在 ScreenUtil 假尺寸环境下', () {
    Widget screenUtilApp(Widget home) => MediaQuery(
          data: const MediaQueryData(
            size: Size(375, 812), // 设计稿假尺寸（ScreenUtil 替换后）
            padding: EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: MaterialApp(
            theme: ThemeData(extensions: [ParkThemeData.light()]),
            home: home,
          ),
        );

    testWidgets('top+success 短文本无异常且不超出实际屏宽', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0; // 实际 360x640
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(screenUtilApp(const Scaffold(body: Text('home'))));
      final ctx = tester.element(find.text('home'));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ParkToast.success(ctx, '登录成功,欢迎回来!',
            position: ParkToastPosition.top);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final e = tester.takeException();
      expect(e, isNull, reason: 'ScreenUtil 环境 toast 异常: $e');

      // toast 内容宽度不应超过实际屏宽 360
      final toastBox = tester.getRect(find.text('登录成功,欢迎回来!'));
      expect(toastBox.width, lessThan(360), reason: 'toast 不超实际屏宽');
    });

    testWidgets('长文本无异常且不超实际屏宽', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(screenUtilApp(const Scaffold(body: Text('home'))));
      final ctx = tester.element(find.text('home'));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ParkToast.show(
          ctx,
          '这是一段非常非常长的提示文本，用于验证 ScreenUtil 假尺寸环境下 toast 按真实约束布局，自动换行并截断省略，不越界不报错，宽度基准是实际屏幕而非设计稿。',
          position: ParkToastPosition.bottom,
        );
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final e = tester.takeException();
      expect(e, isNull, reason: 'ScreenUtil 长文本 toast 异常: $e');

      final toastBox = tester
          .getRect(find.textContaining('这是一段非常非常长的提示文本'));
      expect(toastBox.width, lessThan(360), reason: '长 toast 不超实际屏宽');
      expect(toastBox.right, lessThanOrEqualTo(360 + 1),
          reason: 'toast 右缘不越出实际屏宽');
    });
  });

  group('ParkToast 默认背景不透明（不透出页面内容）', () {
    testWidgets('默认 toast 气泡背景为不透明深色', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: const Scaffold(body: Text('home')),
      ));
      final ctx = tester.element(find.text('home'));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ParkToast.show(ctx, '1', position: ParkToastPosition.top);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 找到 toast 气泡容器（带圆角 decoration 的那个）
      final bubbleFinder = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color != null);
      final bubble = tester.widget<Container>(bubbleFinder.first);
      final color = (bubble.decoration as BoxDecoration).color!;
      expect(color.a, 1.0,
          reason: 'toast 默认背景必须 100% 不透明（alpha=${color.a}），'
              '任何残留透明度都会透出页面内容（如顶部装饰条）');
    });
  });

  group('ParkToast 文本样式（黄线下划线回归）', () {
    testWidgets('toast 文本显式 decoration: none（阻断 fallback 黄色下划线）', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: const Scaffold(body: Text('home')),
      ));
      final ctx = tester.element(find.text('home'));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ParkToast.success(ctx, '1', position: ParkToastPosition.top);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final toastText = tester.widget<Text>(find.text('1'));
      final style = toastText.style!;
      expect(style.decoration, TextDecoration.none,
          reason: 'toast 文本必须显式清除 decoration，'
              '否则继承 Overlay fallback style 的黄色下划线（1 下方黄线）');
    });
  });
}
