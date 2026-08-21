// 导航组件边界回归测试（2026-08-14 第二轮修复）
//
// 覆盖：
//  1. ParkDrawer.show() 模式 afterClose 在 entry 移除后仍回调（P1-2）
//  2. ParkDrawer 左右同屏不产生重复 ValueKey（P0-2）
//  3. ParkAnchor 高亮随滚动正确切换（P1-3/P1-4 坐标系 + GlobalKey 机制）
//  4. ParkSideBar 子项 disabled 不可交互（P1-5）
//  5. ParkIndexes 重复点击同一字母仍触发回调（P1-6）
//  6. ParkTabs children 缺失时内容区安全渲染（P0-3，release 防御）

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/components/navigation/park_drawer.dart';
import 'package:park_ui/src/components/navigation/park_anchor.dart';
import 'package:park_ui/src/components/navigation/park_side_bar.dart';
import 'package:park_ui/src/components/navigation/park_indexes.dart';
import 'package:park_ui/src/components/navigation/park_tabs.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  group('NB-01 ParkDrawer.show afterClose 回调', () {
    testWidgets('show() 关闭后 afterClose 仍触发一次', (tester) async {
      int afterCloseCount = 0;
      await tester.pumpWidget(_wrap(const SizedBox()));
      final BuildContext ctx = tester.element(find.byType(SizedBox));

      final entry = ParkDrawer.show(
        ctx,
        child: const Text('drawer'),
        afterClose: () => afterCloseCount++,
      );
      await tester.pumpAndSettle();
      expect(find.text('drawer'), findsOneWidget);

      // 通过 maskClosable 点击遮罩关闭（点右侧空白区域，避开左侧抽屉内容）
      await tester.tapAt(const Offset(700, 300));
      await tester.pumpAndSettle();

      expect(afterCloseCount, 1,
          reason: 'show() 模式关闭后 afterClose 应回调（P1-2 修复）');
      // 清理 overlay entry（若尚未移除）
      if (entry.mounted) entry.remove();
      await tester.pumpAndSettle();
    });
  });

  group('NB-02 ParkDrawer 左右同屏不重复 key', () {
    testWidgets('left + right 两个抽屉同时渲染不抛 Duplicate key',
        (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(
          children: const [
            ParkDrawer(
              placement: ParkDrawerPlacement.left,
              child: Text('左抽屉'),
            ),
            ParkDrawer(
              placement: ParkDrawerPlacement.right,
              child: Text('右抽屉'),
            ),
          ],
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('左抽屉'), findsOneWidget);
      expect(find.text('右抽屉'), findsOneWidget);
    });
  });

  group('NB-03 ParkAnchor 高亮随滚动切换', () {
    testWidgets('滚动到第二个 section 时高亮切到第二项', (tester) async {
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);
      final GlobalKey section2 = GlobalKey();

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 锚点导航（左侧固定）
              SizedBox(
                width: 120,
                child: ParkAnchor(
                  items: [
                    const ParkAnchorItem(key: 'a', label: '区域A'),
                    ParkAnchorItem(
                        key: 'b', label: '区域B', sectionKey: section2),
                  ],
                  scrollController: controller,
                  offset: 0,
                ),
              ),
              // 右侧滚动内容
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Column(
                    children: [
                      Container(
                          key: const Key('a'),
                          height: 400,
                          color: Colors.red,
                          child: const Text('A')),
                      Container(
                          key: section2,
                          height: 400,
                          color: Colors.green,
                          child: const Text('B')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // 初始高亮第一项（内容区样式：品牌色文字）
      Text aText() => tester.widget<Text>(
            find.descendant(
                of: find.byType(ParkAnchor), matching: find.text('区域A')),
          );
      Text bText() => tester.widget<Text>(
            find.descendant(
                of: find.byType(ParkAnchor), matching: find.text('区域B')),
          );

      expect(aText().style?.fontWeight == FontWeight.w600, isTrue,
          reason: '初始应高亮第一项');

      // 滚动 400px 使 section2 越过阈值 → 高亮切到第二项
      controller.jumpTo(400);
      await tester.pumpAndSettle();
      expect(bText().style?.fontWeight == FontWeight.w600, isTrue,
          reason: '滚动到区域B后应高亮第二项（P1-3/P1-4 修复）');
    });
  });

  group('NB-04 ParkSideBar 子项 disabled', () {
    testWidgets('disabled 子项点击不触发回调', (tester) async {
      int changedCount = 0;
      await tester.pumpWidget(_wrap(
        ParkSideBar(
          items: [
            ParkSideBarItem(
              icon: Icons.folder,
              label: '父项',
              children: [
                ParkSideBarItem(icon: Icons.radio_button_unchecked, label: '可用子项'),
                ParkSideBarItem(
                    icon: Icons.block, label: '禁用子项', disabled: true),
              ],
            ),
          ],
          onChanged: (index) => changedCount++,
        ),
      ));
      await tester.pump();

      await tester.tap(find.text('禁用子项'), warnIfMissed: false);
      await tester.pump();
      expect(changedCount, 0, reason: 'disabled 子项不应触发回调（P1-5 修复）');

      await tester.tap(find.text('可用子项'), warnIfMissed: false);
      await tester.pump();
      expect(changedCount, 1, reason: '可用子项应正常触发回调');
    });
  });

  group('NB-05 ParkIndexes 重复点击同一字母', () {
    testWidgets('重复点击当前字母仍触发回调', (tester) async {
      int selectCount = 0;
      await tester.pumpWidget(_wrap(
        ParkIndexes(
          indexes: const ['A', 'B', 'C'],
          onIndexSelected: (_) => selectCount++,
        ),
      ));
      await tester.pump();

      // 点击两次同一字母
      await tester.tap(find.text('A').first, warnIfMissed: false);
      await tester.pump();
      await tester.tap(find.text('A').first, warnIfMissed: false);
      await tester.pump();
      expect(selectCount, 2,
          reason: '重复点击同一字母不应吞掉回调（P1-6 修复）');
    });
  });

  group('NB-06 ParkTabs children 缺失防御', () {
    testWidgets('tabs 有值 children 为空时不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTabs(
          tabs: [ParkTab(label: '一'), ParkTab(label: '二')],
          children: null,
          destroyInactiveTabPane: true,
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('一'), findsOneWidget);
    });
  });
}
