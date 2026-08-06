// CR60-09 空数据边界测试
//
// 验证各组件在 items=[] / nodes=[] / dataSource=[] 等空数据场景下
// 渲染空态不崩溃，显示空态提示或至少不抛异常。
//
// 使用针对性 import 避免 barrel import 预存编译错误。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/components/display/park_table.dart';
import 'package:park_ui/src/components/display/park_tree.dart';
import 'package:park_ui/src/components/display/park_list.dart';
import 'package:park_ui/src/components/display/park_masonry.dart';
import 'package:park_ui/src/components/display/park_empty.dart';
import 'package:park_ui/src/components/input/park_select.dart';
import 'package:park_ui/src/components/input/park_transfer.dart';
import 'package:park_ui/src/components/input/park_cascader.dart';
import 'package:park_ui/src/components/input/park_auto_complete.dart';
import 'package:park_ui/src/components/navigation/park_menu.dart';
import 'package:park_ui/src/components/navigation/park_tabs.dart';
import 'package:park_ui/src/components/navigation/park_steps.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  // ─────────────────────────────────────────────────────────────────────────────
  // 1. ParkSelect items=[] 时点击不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkSelect empty items', () {
    testWidgets('ParkSelect 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkSelect(
          items: const [],
          hintText: '请选择',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkSelect), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkSelect with empty items tap does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkSelect(
          items: const [],
          hintText: '请选择',
          onChanged: (v) {},
        ),
      ));

      // Tap to open dropdown — should not crash with empty items
      await tester.tap(find.byType(ParkSelect), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. ParkTable columns=[] 或 rows=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkTable empty data', () {
    testWidgets('ParkTable 空数据不崩溃 (data=[])',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTable(
          columns: [
            ParkTableColumn(key: 'name', title: '姓名'),
            ParkTableColumn(key: 'age', title: '年龄'),
          ],
          data: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTable), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkTable 空数据不崩溃 (columns=[])',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTable(
          columns: [],
          data: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTable), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkTable with empty data shows empty state hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTable(
          columns: [
            ParkTableColumn(key: 'name', title: '姓名'),
          ],
          data: [],
          emptyText: '暂无数据',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTable), findsOneWidget);
      // Should show empty text or ParkEmpty widget
      final hasEmptyHint = find.text('暂无数据').evaluate().isNotEmpty ||
          find.byType(ParkEmpty).evaluate().isNotEmpty;
      expect(hasEmptyHint, isTrue,
          reason: 'ParkTable should show empty state when data is empty');
      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. ParkTree nodes=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkTree empty data', () {
    testWidgets('ParkTree 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTree(data: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTree), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkTree with empty nodes does not throw on interaction',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkTree(
          data: const [],
          onSelect: (key) {},
        ),
      ));

      // Tap on the tree area — should not crash
      await tester.tap(find.byType(ParkTree), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. ParkTransfer sourceItems=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkTransfer empty data', () {
    testWidgets('ParkTransfer 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTransfer(dataSource: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTransfer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkTransfer with empty dataSource and targetKeys renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTransfer(
          dataSource: [],
          targetKeys: [],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTransfer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. ParkCascader options=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkCascader empty data', () {
    testWidgets('ParkCascader 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkCascader(
          options: const [],
          hintText: '请选择地区',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkCascader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkCascader with empty options tap does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkCascader(
          options: const [],
          hintText: '请选择地区',
          onChanged: (v) {},
        ),
      ));

      // Tap to open cascader panel — should not crash with empty options
      await tester.tap(find.byType(ParkCascader), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 6. ParkAutoComplete suggestions=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkAutoComplete empty data', () {
    testWidgets('ParkAutoComplete 空数据不崩溃',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAutoComplete(
          options: [],
          hintText: '请输入搜索',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkAutoComplete), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkAutoComplete with empty options input does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAutoComplete(
          options: [],
          hintText: '请输入搜索',
        ),
      ));

      // Type text to trigger suggestion lookup — should not crash
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 7. ParkList items=[] 时渲染空态
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkList empty data', () {
    testWidgets('ParkList 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkList<String>(
          items: const [],
          itemBuilder: (context, item, index) => Text(item),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkList<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkList with empty items shows empty widget if provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkList<String>(
          items: const [],
          itemBuilder: (context, item, index) => Text(item),
          emptyWidget: const Center(child: Text('列表为空')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('列表为空'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 8. ParkMenu items=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkMenu empty data', () {
    testWidgets('ParkMenu 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkMenu(items: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkMenu), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkMenu with empty items tap does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [],
          onSelect: (key) {},
        ),
      ));

      await tester.tap(find.byType(ParkMenu), warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 9. ParkTabs tabs=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkTabs empty data', () {
    testWidgets('ParkTabs 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTabs(tabs: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTabs), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkTabs with empty tabs and no children renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkTabs(
          tabs: const [],
          onChanged: (index) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkTabs), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 10. ParkSteps steps=[] 时渲染空态不崩溃
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkSteps empty data', () {
    testWidgets('ParkSteps 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSteps(steps: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkSteps), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkSteps with empty steps and currentStep=0 renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSteps(
          steps: [],
          currentStep: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkSteps), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────────
  // 补充: ParkMasonry items=[] 时渲染空态
  // ─────────────────────────────────────────────────────────────────────────────
  group('CR60-09 ParkMasonry empty data', () {
    testWidgets('ParkMasonry 空数据不崩溃', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkMasonry<String>(
          items: const [],
          itemBuilder: (context, item, index) => Text(item),
          columns: 2,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkMasonry<String>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkMasonry with empty items shows emptyBuilder if provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(
        ParkMasonry<String>(
          items: const [],
          itemBuilder: (context, item, index) => Text(item),
          columns: 2,
          emptyBuilder: (context) => const Center(child: Text('暂无内容')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('暂无内容'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
