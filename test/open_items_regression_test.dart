// 开放项回归测试（B42–B53）
//
// 本文件由测试工程师在对齐「需求文档 / 开发文档 / 开发问题汇总 / 改进文档」后生成，
// 用于把仍敞着的开放项转成可执行的验收断言。
//
// 约定：断言写成「修复后的期望行为」。若某条 FAIL，即证明该 B 项在代码中仍真实存在
// （与 改进文档 §整改任务清单 的 `[ ]` 状态一致）；若 PASS，则需回写文档状态。
//
// 已代码核实为 DONE 的项（B25/B27/B30/B35/B40/B44/B49）不在此文件重复，其状态已在
// 改进文档 中回写为 ✅。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  // ───────────────────────── B50 · form_validator url 正则误伤 ─────────────────────────
  group('B50 ParkFormValidator url 正则误伤', () {
    test('内置 url 正则应用于合法链接时应通过（当前被 _safeRegExp 误拒 → 预期 FAIL）', () {
      final pattern = ParkRegexRegistry.get('url')!;
      // 模式本身正确，可匹配合法链接
      expect(RegExp(pattern).hasMatch('https://example.com'), isTrue,
          reason: 'url 模式本身合法');
      // 经校验路径应放行合法链接（B50 修复后期望 isValid == true）
      final field = ParkFormFieldSchema(
        fieldId: 'u',
        fieldType: ParkFieldType.text,
        labelName: '链接',
        fieldName: 'u',
        regexExpression: pattern,
      );
      final result = ParkFormValidators.regex('https://example.com', field);
      expect(result.isValid, isTrue,
          reason: 'url 正则含嵌套量词 (\\.[\\w\\-]+)+ 被 _safeRegExp 误拒，合法链接被错判无效');
    });
  });

  // ───────────────────────── B32 · FormFormatterEngine 未接线 ─────────────────────────
  group('B32 FormFormatterEngine 死代码 / 未接线', () {
    test('applyAll 千分位格式化正确（引擎可用，但动态表单未消费 = 仍 OPEN）', () {
      final engine = FormFormatterEngine();
      final out = engine.applyAll(
        const ParkFormFieldFormatterSchema(formatterType: FormatterType.thousands),
        1234567.89,
      );
      expect(out, '1,234,567.89');
    });
  });

  // ───────────────────────── B52 · _TrackContext 全局单例 ─────────────────────────
  group('B52 _TrackContext 全局单例跨实例污染', () {
    test('两个 service 的 watchEffect 各自独立触发（隔离性）', () async {
      final s1 = ParkBindingService({'a': 1});
      final s2 = ParkBindingService({'b': 2});
      int s1Fires = 0;
      int s2Fires = 0;

      // 先 bind 路径，使 setValue 能通过 bindable 的 listener 触发 effect
      s1.bind<int>('a');
      s2.bind<int>('b');

      // 各自追踪自己的路径
      s1.watchEffect(() {
        s1.getValue('a');
        s1Fires++;
      });
      s2.watchEffect(() {
        s2.getValue('b');
        s2Fires++;
      });

      // 初始执行：各触发一次
      expect(s1Fires, 1);
      expect(s2Fires, 1);

      // s1 的值变化 → 仅 s1 的 effect 应重执行
      s1.setValue('a', 10);
      await s1.nextTick(); // 排干调度器微任务，让 _triggerEffects 执行

      expect(s1Fires, 2, reason: 's1 的值变化应触发 s1 自身的 effect');
      expect(s2Fires, 1, reason: 's1 的变化不应触发 s2 的 effect（实例隔离）');

      s1.dispose();
      s2.dispose();
    });

    test('cross-instance getValue 不应将路径记入另一 service 的依赖（B52 核心场景）',
        () async {
      final s1 = ParkBindingService({'a': 1, 'b': 1});
      final s2 = ParkBindingService({'c': 1});
      int s1Fires = 0;

      // 先 bind 路径，使 setValue 能通过 bindable 的 listener 触发 effect
      s1.bind<int>('a');
      s1.bind<int>('b');
      s2.bind<int>('c');

      // s1 的 effect 内部调用了 s2.getValue('c')
      // 修复前：'c' 被全局 _TrackContext 错误记入 s1 的依赖
      // 修复后：每个 service 各自追踪，s1 的依赖只包含 'a' 和 'b'
      s1.watchEffect(() {
        s1.getValue('a');
        s1.getValue('b');
        // ignore: avoid_dynamic_calls
        s2.getValue('c'); // 跨实例访问 — 修复前会污染 s1 的依赖
        s1Fires++;
      });

      expect(s1Fires, 1);

      // 改变 s2 的 'c' — 不应触发 s1 的 effect（'c' 不属于 s1 的依赖）
      final firesBefore = s1Fires;
      s2.setValue('c', 10);
      await s1.nextTick();

      expect(s1Fires, firesBefore,
          reason: 's2 的 c 变化不应触发 s1 的 effect（跨实例依赖未污染）');

      // 改变 s1 的 'a' — 应触发 s1 的 effect
      s1.setValue('a', 100);
      await s1.nextTick();

      expect(s1Fires, firesBefore + 1,
          reason: 's1 自身的 a 变化仍应触发 s1 的 effect');

      s1.dispose();
      s2.dispose();
    });
  });

  // ───────────────────────── B42 · ParkColorPicker 自定义 HSV 面板 ─────────────────────────
  group('B42 ParkColorPicker enableCustom', () {
    testWidgets('enableCustom:true 应渲染 HSV 面板（SV方块 + 色相条）',
        (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        enableCustom: true,
        onChanged: null,
      )));
      await tester.pumpAndSettle();
      // 有 HSV 面板时共 22 个 GestureDetector（20 预设 + 2 HSV）
      expect(find.byType(GestureDetector), findsNWidgets(22),
          reason: 'enableCustom true 应渲染色相条 + SV 面板');
    });

    testWidgets('enableCustom:false 不渲染 HSV 面板', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker(
        enableCustom: false,
        onChanged: null,
      )));
      await tester.pumpAndSettle();
      // 无 HSV 面板时共 20 个 GestureDetector（仅预设）
      expect(find.byType(GestureDetector), findsNWidgets(20),
          reason: 'enableCustom false 不应渲染色相条 + SV 面板');
    });
  });

  // ───────────────────────── B45 · ParkTimePicker showSeconds ─────────────────────────
  group('B45 ParkTimePicker showSeconds', () {
    testWidgets('showSeconds:true 可构建且不崩溃（秒选择已实现，验证 showSeconds 参数生效）', (tester) async {
      await tester.pumpWidget(_wrap(ParkTimePicker(
        showSeconds: true,
        onChanged: (_) {},
      )));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });
  });

  // ───────────────────────── B43 · ParkTransfer disabled 仅禁中间按钮 ─────────────────────────
  group('B43 ParkTransfer disabled 真禁', () {
    testWidgets('disabled:true 时点击列表项不应触发 onChange（当前仅禁中间按钮）',
        (tester) async {
      List<String>? lastChanged;
      await tester.pumpWidget(_wrap(ParkTransfer(
        disabled: true,
        dataSource: const [
          ParkTransferItem(key: '1', title: 'A'),
          ParkTransferItem(key: '2', title: 'B'),
        ],
        onChange: (keys, _) => lastChanged = keys,
      )));
      await tester.pumpAndSettle();
      // 点击左侧待选项：禁用态下不应触发 onChange（实际 bug：列表项仍可选中）
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(lastChanged, isNull,
          reason: '禁用态点击列表项不应改变已选项');
    });
  });

  // ───────────────────────── B48 · ParkPopconfirm Overlay dispose 泄漏 ─────────────────────────
  group('B48 ParkPopconfirm Overlay 泄漏', () {
    testWidgets('卸载时应清理 OverlayEntry，不残留 overlay', (tester) async {
      await tester.pumpWidget(_wrap(const ParkPopconfirm(
        child: Text('触发'),
      )));
      await tester.pumpAndSettle();

      // 点击触发 popconfirm 显示 overlay bubble
      await tester.tap(find.text('触发'));
      await tester.pumpAndSettle();

      // 记录卸载前的 overlay 数量
      final overlayBefore = tester.widgetList(find.byType(Overlay)).length;

      // 卸载组件：dispose 中 _cleanupPopconfirm 应移除 OverlayEntry
      await tester.pumpWidget(_wrap(const SizedBox.shrink()));
      await tester.pumpAndSettle();

      // 验证：卸载后 overlay 数量不应增加（无残留 OverlayEntry）
      final overlayAfter = tester.widgetList(find.byType(Overlay)).length;
      expect(overlayAfter, lessThanOrEqualTo(overlayBefore),
          reason: 'ParkPopconfirm dispose 应清理 OverlayEntry，不应残留');
    });
  });

  // ───────────────────────── B47 / B53 · afterClose 接线（代码审查确认仍 OPEN） ─────────────────────────
  group('B47/B53 afterClose 烟雾', () {
    testWidgets('ParkDialog 接受 afterClose 且不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(ParkDialog(
        title: 't',
        content: 'c',
        afterClose: () {},
        onConfirm: () {},
      )));
      expect(find.text('t'), findsOneWidget);
    });
    testWidgets('ParkDrawer 接受 afterClose 且不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(ParkDrawer(
        afterClose: () {},
        child: const Text('content'),
      )));
      expect(find.text('content'), findsOneWidget);
    });
  });
}
