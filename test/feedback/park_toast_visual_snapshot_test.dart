import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 把 ylzj 场景的 toast 渲染成图片，用于亲眼确认"黄线"形态。
void main() {
  testWidgets('toast 渲染快照：top + success + 1 + 橙色背景', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0; // 360x640 逻辑
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34, left: 0, right: 0);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Stack(
          children: [
            // 模拟 ylzj 页面顶部：高亮橙色渐变区（profile 卡片）
            Positioned(
              top: 0, left: 0, right: 0, height: 300,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF8A50), Color(0xFFFFB877)],
                  ),
                ),
                child: const Center(child: Text('邓', style: TextStyle(fontSize: 30, color: Colors.white))),
              ),
            ),
            const Text('home'),
          ],
        ),
      ),
    ));

    final ctx = tester.element(find.text('home'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ParkToast.success(ctx, '1', position: ParkToastPosition.top);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byType(Overlay),
      matchesGoldenFile('goldens/toast_top_1.png'),
    );
  });
}
