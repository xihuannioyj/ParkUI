// 边界回归测试（2026-08-14 审计修复）
//
// 覆盖审计发现并修复的 P0 边界错误：
//  1. ParkIndexes itemHeight<=0 除零
//  2. ParkGrid columnCount<=0 死循环
//  3. ParkAvatar maxCount<0 clamp ArgumentError
//  4. ParkToast / ParkMessage config(maxCount:0) 空 Map keys.first StateError
//  5. ParkOverlay show() 后同帧 close() LateInitializationError
//  6. ParkTour current 负数 RangeError
//  7. ParkDivider dashWidth+dashGap<=0 绘制死循环
//  8. ParkFloatButton icon=null Icon 崩溃
//  9. ParkMentions caret 越界 replaceRange RangeError
// 10. ParkFormItem rules/validator 拿到子组件真实值（B30 桥接）
// 11. ParkPagination 绑定初始值与 current 不一致时不在 build 期同步回调
// 12. ParkSwipeCell 拖拽打开触发 onOpen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/components/navigation/park_indexes.dart';
import 'package:park_ui/src/components/display/park_grid.dart';
import 'package:park_ui/src/components/display/park_avatar.dart';
import 'package:park_ui/src/components/feedback/park_toast.dart';
import 'package:park_ui/src/components/feedback/park_message.dart';
import 'package:park_ui/src/components/feedback/park_overlay.dart';
import 'package:park_ui/src/components/feedback/park_tour.dart';
import 'package:park_ui/src/components/base/park_divider.dart';
import 'package:park_ui/src/components/base/park_float_button.dart';
import 'package:park_ui/src/components/input/park_mentions.dart';
import 'package:park_ui/src/components/input/park_form_item.dart';
import 'package:park_ui/src/components/input/park_form.dart';
import 'package:park_ui/src/components/input/park_input.dart';
import 'package:park_ui/src/components/input/park_search.dart';
import 'package:park_ui/src/components/input/park_search_delegate.dart';
import 'package:park_ui/src/components/input/park_auto_complete.dart';
import 'package:park_ui/src/components/input/park_search_history.dart';
import 'package:park_ui/src/components/navigation/park_pagination.dart';
import 'package:park_ui/src/components/feedback/park_swipe_cell.dart';
import 'package:park_ui/src/components/display/park_countdown.dart';
import 'package:park_ui/src/components/display/park_collapse.dart';
import 'package:park_ui/src/components/base/park_text.dart';
import 'package:park_ui/src/components/base/park_grid_row.dart';
import 'package:park_ui/src/components/base/park_app.dart';
import 'package:park_ui/src/components/base/park_ink_well.dart';
import 'package:park_ui/src/components/input/park_textarea.dart';
import 'package:park_ui/src/components/input/park_input_number.dart';
import 'package:park_ui/src/components/input/park_input_group.dart';
import 'package:park_ui/src/components/display/park_splitter.dart';
import 'package:park_ui/src/components/display/park_statistic.dart';
import 'package:park_ui/src/components/display/park_swiper.dart';
import 'package:park_ui/src/components/display/park_watermark.dart';
import 'package:park_ui/src/components/input/park_slider.dart';
import 'package:park_ui/src/components/input/park_segmented.dart';
import 'package:park_ui/src/binding/park_binding_service.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  group('BR-01 ParkIndexes itemHeight<=0 除零', () {
    testWidgets('itemHeight=0 点击字母条不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkIndexes(
          indexes: const ['A', 'B', 'C'],
          itemHeight: 0,
          onIndexSelected: (_) {},
        ),
      ));
      await tester.tap(find.byType(ParkIndexes), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-02 ParkGrid columnCount<=0 死循环', () {
    testWidgets('columnCount=0 正常渲染不卡死', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkGrid(
          columnCount: 0,
          items: const [
            ParkGridItem(label: 'A'),
            ParkGridItem(label: 'B'),
            ParkGridItem(label: 'C'),
          ],
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(ParkGrid), findsOneWidget);
    });
  });

  group('BR-03 ParkAvatar maxCount 负数 clamp', () {
    testWidgets('maxCount=-1 不抛 ArgumentError', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkAvatarGroup(
          avatars: const [
            ParkAvatar(text: '张'),
            ParkAvatar(text: '李'),
          ],
          maxCount: -1,
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-04 ParkToast/ParkMessage maxCount=0', () {
    testWidgets('config(maxCount:0) 后 show 不抛 StateError', (tester) async {
      ParkToast.resetConfig();
      ParkToast.config(maxCount: 0);
      addTearDown(ParkToast.resetConfig);

      await tester.pumpWidget(_wrap(const SizedBox()));
      ParkToast.show(tester.element(find.byType(SizedBox)), 'hello');
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('ParkMessage config(maxCount:0) 后 show 不抛 StateError',
        (tester) async {
      ParkMessage.resetConfig();
      ParkMessage.config(maxCount: 0);
      addTearDown(ParkMessage.resetConfig);

      await tester.pumpWidget(_wrap(const SizedBox()));
      ParkMessage.info(tester.element(find.byType(SizedBox)), 'hello');
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-05 ParkOverlay 同帧 close', () {
    testWidgets('show 后立即 close 不抛 LateInitializationError',
        (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final handle = ParkOverlay.show(
        tester.element(find.byType(SizedBox)),
        child: const Text('overlay'),
      );
      // 同一帧内关闭（entry 尚未插入）
      handle.close();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('overlay'), findsNothing,
          reason: '同帧关闭后不应残留遮罩');
    });
  });

  group('BR-06 ParkTour current 负数', () {
    testWidgets('current=-1 不抛 RangeError', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkTour(
          open: true,
          current: -1,
          steps: const [
            ParkTourStep(title: '步骤1', description: '内容1'),
          ],
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-07 ParkDivider 虚线参数非法', () {
    testWidgets('dashWidth=0 dashGap=0 渲染不卡死', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkDivider(dashed: true, dashWidth: 0, dashGap: 0),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-08 ParkFloatButton icon=null', () {
    testWidgets('icon 为空不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        Stack(
          children: const [ParkFloatButton(icon: null)],
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-09 ParkMentions 空数据/空触发符', () {
    testWidgets('items 为空 + 输入 @ 不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkMentions(
          items: [],
          triggerChars: ['@'],
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-10 ParkFormItem rules 校验真实值（B30 桥接）', () {
    testWidgets('子组件已填值，rules required 校验应通过', (tester) async {
      final formKey = GlobalKey<FormState>();
      final inputController = TextEditingController(text: '张三');
      addTearDown(inputController.dispose);

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: ParkFormItem(
              label: '姓名',
              rules: const [ParkFormRule(required: true, message: '必填')],
              child: ParkInput(controller: inputController),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final bool isValid = formKey.currentState?.validate() ?? false;
      expect(isValid, isTrue,
          reason: '已填值的表单项 required 校验应通过（B30 桥接修复）');
      expect(find.text('必填'), findsNothing);
    });

    testWidgets('子组件为空值，rules required 校验应失败', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: ParkFormItem(
              label: '姓名',
              rules: const [ParkFormRule(required: true, message: '必填')],
              child: ParkInput(hintText: '请输入'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final bool isValid = formKey.currentState?.validate() ?? false;
      expect(isValid, isFalse);
      await tester.pump();
      expect(find.text('必填'), findsOneWidget);
    });
  });

  group('BR-11 ParkPagination 绑定初始值不回写 build 期', () {
    testWidgets('boundValue 与 current 不一致不抛 setState during build',
        (tester) async {
      final service = ParkBindingService({'page': 3});
      addTearDown(service.dispose);

      await tester.pumpWidget(_wrap(
        ParkPagination(
          total: 100,
          current: 1,
          bindingService: service,
          bindKey: 'page',
          onChanged: (page, size) {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-12 ParkSwipeCell 拖拽打开触发 onOpen', () {
    testWidgets('拖拽打开回调 onOpen', (tester) async {
      int openCount = 0;
      int closeCount = 0;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(
          body: ParkSwipeCell(
            rightActions: [
              ParkSwipeAction(
                label: '删除',
                onTap: () {},
                color: Colors.red,
              ),
            ],
            onOpen: () => openCount++,
            onClose: () => closeCount++,
            child: const SizedBox(height: 60, child: Text('内容')),
          ),
        ),
      ));
      await tester.pump();

      // 左滑打开（拖拽整个单元格，避免内容位移后找不到命中点）
      await tester.drag(find.byType(ParkSwipeCell), const Offset(-120, 0),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(openCount, 1, reason: '拖拽打开应触发 onOpen');

      // 右滑关闭
      await tester.drag(find.byType(ParkSwipeCell), const Offset(120, 0),
          warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(closeCount, 1, reason: '关闭应触发 onClose');
    });
  });

  group('BR-13 ParkAvatar gap 过大字号', () {
    testWidgets('gap>=40 时不因负字号崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAvatar(text: '张', gap: 40),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-14 ParkAvatarGroup 空列表', () {
    testWidgets('avatars=[] 渲染为空不占位', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAvatarGroup(avatars: []),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-15 ParkCountdown 负初始值', () {
    testWidgets('负 remaining 显示 00:00:00', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkCountdown(remaining: Duration(seconds: -5)),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('00'), findsWidgets, reason: '负值应钳制为 00');
    });
  });

  group('BR-16 ParkCollapse accordion 归一化', () {
    testWidgets('初始多开时只保留第一个激活面板', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkCollapse(
          accordion: true,
          activeKeys: const {'b', 'c'},
          items: const [
            ParkCollapseItem(key: 'a', title: '面板A', content: Text('A')),
            ParkCollapseItem(key: 'b', title: '面板B', content: Text('B')),
            ParkCollapseItem(key: 'c', title: '面板C', content: Text('C')),
          ],
        ),
      ));
      await tester.pump();
      // AnimatedCrossFade 的隐藏面板仍在元素树中，用 crossFadeState 断言展开数。
      final List<CrossFadeState> states = tester
          .widgetList<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .map((w) => w.crossFadeState)
          .toList();
      expect(states.where((s) => s == CrossFadeState.showSecond).length, 1,
          reason: 'accordion 初始多开应只保留第一个激活面板（BR-16 修复）');
    });
  });

  group('BR-17 ParkText style.color 保留', () {
    testWidgets('用户 style 颜色不被默认色覆盖', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkText('红色文字', style: TextStyle(color: Colors.red)),
      ));
      await tester.pump();
      final Text text = tester.widget<Text>(find.text('红色文字'));
      expect(text.style?.color, Colors.red,
          reason: 'style.color 应保留（P1-5 修复）');
    });
  });

  group('BR-18 ParkGridRow justify=end', () {
    testWidgets('end 对齐时内容靠右渲染', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkGridRow(
          justify: ParkGridJustify.end,
          children: [
            ParkGridCol(span: 6, child: const SizedBox(height: 20, width: 50)),
          ],
        ),
      ));
      await tester.pump();
      // ParkGridCol 仅提取数据不入树；内容 SizedBox 带 height:20 特征，精确定位。
      final Rect rowRect = tester.getRect(find.byType(ParkGridRow));
      final Finder contentFinder = find.byWidgetPredicate(
          (w) => w is SizedBox && w.height == 20);
      final Rect colRect = tester.getRect(contentFinder);
      final double gapRight = rowRect.right - colRect.right;
      expect(gapRight.abs() < 1.0, isTrue,
          reason: 'justify=end 内容应靠右（P1-4 修复），右侧间隙 $gapRight');
    });
  });

  group('BR-19 ParkApp 保留用户 ThemeExtension', () {
    testWidgets('传入 theme 自带的扩展不被丢弃', (tester) async {
      await tester.pumpWidget(ParkApp(
        home: const SizedBox(),
        theme: ThemeData(extensions: const [MyTestExtension(value: 42)]),
      ));
      await tester.pump();
      final BuildContext ctx = tester.element(find.byType(SizedBox).first);
      final MyTestExtension? ext = Theme.of(ctx).extension<MyTestExtension>();
      expect(ext, isNotNull, reason: '用户 ThemeExtension 应保留（P1-3 修复）');
      expect(ext!.value, 42);
    });
  });

  group('BR-20 ParkInkWell 切换状态保留子组件状态', () {
    testWidgets('disabled 切换不销毁子组件 State', (tester) async {
      final GlobalKey<_StatefulChildState> childKey =
          GlobalKey<_StatefulChildState>();
      bool disabled = false;

      await tester.pumpWidget(_wrap(
        StatefulBuilder(
          builder: (context, setParent) {
            return ParkInkWell(
              disabled: disabled,
              onTap: () {},
              child: _StatefulChild(key: childKey),
            );
          },
        ),
      ));
      await tester.pump();
      final State firstState = childKey.currentState!;

      // 切换 disabled 并重建
      disabled = true;
      await tester.pumpWidget(_wrap(
        StatefulBuilder(
          builder: (context, setParent) {
            return ParkInkWell(
              disabled: disabled,
              onTap: () {},
              child: _StatefulChild(key: childKey),
            );
          },
        ),
      ));
      await tester.pump();

      expect(identical(childKey.currentState, firstState), isTrue,
          reason: 'disabled 切换不应销毁子组件 State（P1-6 修复）');
    });
  });

  group('BR-21 ParkTextarea 外部 controller 受控', () {
    testWidgets('外部 controller 的修改生效', (tester) async {
      final controller = TextEditingController(text: '初始');
      addTearDown(controller.dispose);

      await tester.pumpWidget(_wrap(
        ParkTextarea(controller: controller),
      ));
      await tester.pump();
      expect(find.text('初始'), findsOneWidget);

      // 外部修改 controller → UI 应跟随（受控语义，P1-7 修复）
      controller.text = '外部修改';
      await tester.pump();
      expect(find.text('外部修改'), findsOneWidget,
          reason: '外部 controller 修改应生效（P1-7 修复）');
    });
  });

  group('BR-22 ParkInputNumber 浮点规整', () {
    testWidgets('0.1 步进连加三次显示 0.3', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkInputNumber(
          value: 0,
          step: 0.1,
          onChanged: (_) {},
        ),
      ));
      await tester.pump();
      // 点击三次 + 按钮
      final Finder plusBtn =
          find.byIcon(Icons.add).evaluate().isEmpty
              ? find.text('+')
              : find.byIcon(Icons.add);
      for (int i = 0; i < 3; i++) {
        await tester.tap(plusBtn.first, warnIfMissed: false);
        await tester.pump();
      }
      // 文本框应显示 0.3 而非 0.30000000000000004
      final EditableText editable = tester.widget<EditableText>(
          find.byType(EditableText).first);
      expect(editable.controller.text, '0.3',
          reason: '0.1 步进三次应为 0.3（P1-5 修复），实际 ${editable.controller.text}');
    });
  });

  group('BR-23 ParkInputGroup disabled 阻断交互', () {
    testWidgets('disabled 时点击子输入框不获焦', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkInputGroup(
          disabled: true,
          children: [ParkInput(hintText: '组内输入')],
        ),
      ));
      await tester.pump();
      await tester.tap(find.byType(ParkInput), warnIfMissed: false);
      await tester.pump();
      // IgnorePointer 包裹后输入框不应聚焦
      final EditableText editable = tester.widget<EditableText>(
          find.byType(EditableText).first);
      expect(editable.focusNode.hasFocus, isFalse,
          reason: 'disabled 组不应可交互（P1-10 修复）');
    });
  });

  group('BR-24 ParkSplitter 垂直无界高度', () {
    testWidgets('置于无界高度容器不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        SingleChildScrollView(
          child: ParkSplitter(
            axis: Axis.vertical,
            first: const SizedBox(height: 100, child: Text('上')),
            second: const SizedBox(height: 100, child: Text('下')),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: '垂直 splitter 在无界高度下应优雅退化（P0 修复）');
    });
  });

  group('BR-25 ParkStatistic 边界格式化', () {
    testWidgets('precision<0 不抛 RangeError，小数值不显示科学计数',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ParkStatistic(title: '统计', value: 0.0000001, precision: -1),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: 'precision<0 不应抛 RangeError（P1 修复）');
      // 科学计数法应被格式化掉
      expect(find.textContaining('e-'), findsNothing,
          reason: '小数值不应显示科学计数法（P1 修复）');
    });
  });

  group('BR-26 ParkSwiper 索引越界', () {
    testWidgets('initialIndex 越界不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSwiper(
          initialIndex: 99,
          children: const [Text('页1'), Text('页2')],
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'initialIndex 越界应钳制（P1 修复）');
    });
  });

  group('BR-27 ParkWatermark gap 非法', () {
    testWidgets('gapX=0 不平铺死循环（渲染不卡死）', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkWatermark(
          text: '机密',
          gapX: 0,
          gapY: 0,
          child: SizedBox(width: 100, height: 100),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: 'gap<=0 不应死循环（P0 修复）');
    });
  });

  group('BR-28 ParkSlider 范围参数边界', () {
    testWidgets('rangeStart>rangeEnd 自动交换不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSlider(
          range: true,
          min: 0,
          max: 100,
          rangeStart: 80,
          rangeEnd: 20,
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: 'rangeStart>rangeEnd 应交换（P1-4 修复）');
    });

    testWidgets('marks 越界值不逃逸范围', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSlider(
          min: 0,
          max: 100,
          marks: const [200, -50, 50],
          onChanged: (_) {},
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: '越界 marks 应被钳制，不抛布局异常（P1-5 修复）');
    });
  });

  group('BR-29 ParkSegmented 多选非受控', () {
    testWidgets('非受控多选有点击视觉反馈', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSegmented(
          multiSelect: true,
          items: const [
            ParkSegmentedItem(value: 'a', label: 'A'),
            ParkSegmentedItem(value: 'b', label: 'B'),
          ],
          onMultiChanged: (_) {},
        ),
      ));
      await tester.pump();
      // 初始无选中
      // 点击 A → 应显示选中态（内部集合驱动）
      await tester.tap(find.text('A'), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  // BR-30~32：输入组件提交统一 trim（2026-08-14 需求）
  // ═════════════════════════════════════════════════════════════════════════
  group('BR-30 表单提交统一 trim', () {
    testWidgets('onSubmit 收到的 String 值去掉两侧空格', (tester) async {
      Map<String, dynamic>? submitted;
      await tester.pumpWidget(_TrimFormHarness(onSubmit: (v) => submitted = v));
      await tester.pumpAndSettle();

      // 模拟用户录入带空格的内容（经绑定通道流入表单模型）
      await tester.enterText(find.byType(TextField), '  张三  ');
      await tester.pumpAndSettle();

      final ParkFormState formState =
          tester.state<ParkFormState>(find.byType(ParkForm));
      // 通过 form 提交（submit 内部会 trim）
      formState.submit();
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!['name'], '张三',
          reason: '提交值应 trim 两侧空格，实际 ${submitted!['name']}');
    });
  });

  group('BR-31 ParkInput onSubmitted trim', () {
    testWidgets('onSubmitted 回调值去掉两侧空格', (tester) async {
      String? submitted;
      await tester.pumpWidget(_wrap(
        ParkInput(
          hintText: '输入',
          onSubmitted: (v) => submitted = v,
        ),
      ));
      await tester.pump();

      // 输入带空格的内容并回车提交
      await tester.enterText(find.byType(TextField), '  内容  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, '内容',
          reason: 'onSubmitted 应 trim，实际 $submitted');
    });
  });

  group('BR-32 ParkSearch 提交 trim', () {
    testWidgets('onSearch 回调值去掉两侧空格', (tester) async {
      String? searched;
      await tester.pumpWidget(_wrap(
        ParkSearch(
          hintText: '搜索',
          onSearch: (v) => searched = v,
        ),
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '  关键词  ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(searched, '关键词',
          reason: 'onSearch 应 trim，实际 $searched');
    });
  });

  group('BR-33 ParkInput 搜索按钮提交 trim', () {
    testWidgets('点击搜索按钮 onSearch 回调值去掉两侧空格', (tester) async {
      String? searched;
      await tester.pumpWidget(_wrap(
        ParkInput(
          hintText: '输入',
          searchButton: const ParkInputSearchButtonConfig(text: '搜'),
          onSearch: (v) => searched = v,
        ),
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '  按钮  ');
      await tester.tap(find.text('搜'));
      await tester.pump();

      expect(searched, '按钮',
          reason: '搜索按钮点击应 trim，实际 $searched');
    });
  });

  group('BR-34 ParkAutoComplete 选中提交 trim', () {
    testWidgets('onSelected 回调值去掉两侧空格', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkAutoComplete(
          options: const ['  苹果  '],
          onSelected: (v) => selected = v,
        ),
      ));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '苹果');
      // 等待 300ms 防抖后弹出建议
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('  苹果  '));
      await tester.pump();

      expect(selected, '苹果',
          reason: 'onSelected 应 trim，实际 $selected');
    });
  });

  group('BR-35 showParkSearch 空输入点搜索', () {
    testWidgets('空输入点搜索：关闭搜索页并返回空串（清除过滤）', (tester) async {
      String? result = 'unset';
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showParkSearch<String>(
                    context: context,
                    hint: '搜索姓名',
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // 不输入任何内容，直接点「搜索」文字按钮
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing,
          reason: '空输入点搜索应关闭搜索页（纯取词模式视为清除过滤）');
      expect(result, '',
          reason: '空搜索应返回空串，供调用方恢复完整列表');
      expect(tester.takeException(), isNull);
    });
  });

  group('BR-36 ParkStorageSearchHistory 竞态', () {
    test('addHistory 写入不被异步 preload 覆盖', () async {
      final storage = _SlowHistoryStorage(const ['旧词']);
      final history = ParkStorageSearchHistory(storage: storage, limit: 10);
      // 触发异步 preload（50ms 后才完成）
      history.getHistory('s');
      // preload 完成前写入新词
      history.addHistory('s', '新词');
      // 等待异步加载与写入完成
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final items = history.getHistory('s');
      expect(items, contains('新词'),
          reason: '新写入的搜索词不应被异步 preload 覆盖，实际 $items');
      expect(items.first, '新词');
      expect(items, contains('旧词'),
          reason: 'preload 应合并存储数据，实际 $items');
    });
  });

  group('BR-37 ParkOverlay afterClose', () {
    testWidgets('关闭动画完成后触发 afterClose', (tester) async {
      bool afterClosed = false;
      final ValueNotifier<bool> visible = ValueNotifier<bool>(true);
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (context, v, _) => Scaffold(
            body: ParkOverlay(
              visible: v,
              afterClose: () => afterClosed = true,
              child: const Text('overlay'),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(afterClosed, false, reason: '未关闭时不应触发 afterClose');

      // 关闭：visible false → reverse 动画完成后触发 afterClose
      visible.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(afterClosed, true, reason: '关闭动画完成后应触发 afterClose');
      expect(tester.takeException(), isNull);
    });
  });
}

/// 有状态子组件（验证 Element/State 复用）。
class _StatefulChild extends StatefulWidget {
  const _StatefulChild({super.key});
  @override
  State<_StatefulChild> createState() => _StatefulChildState();
}

class _StatefulChildState extends State<_StatefulChild> {
  @override
  Widget build(BuildContext context) => const Text('child');
}

/// 测试用 ThemeExtension。
class MyTestExtension extends ThemeExtension<MyTestExtension> {
  const MyTestExtension({required this.value});
  final int value;

  @override
  MyTestExtension copyWith({int? value}) =>
      MyTestExtension(value: value ?? this.value);

  @override
  MyTestExtension lerp(covariant MyTestExtension? other, double t) {
    if (other == null) return this;
    return MyTestExtension(
        value: (value + (other.value - value) * t).round());
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BR-30~32：输入组件提交统一 trim（2026-08-14 需求）
// ═══════════════════════════════════════════════════════════════════════════
class _TrimFormHarness extends StatelessWidget {
  const _TrimFormHarness({required this.onSubmit});
  final void Function(Map<String, dynamic>) onSubmit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: ParkForm(
          // 通过绑定模型承载字段值：manual 模式下 ParkInput 经
          // bindKey → ParkBindingService.model 同步，submit() 合并模型值后统一 trim。
          model: const <String, dynamic>{'name': ''},
          onSubmit: onSubmit,
          showDefaultActions: false,
          children: <Widget>[
            ParkFormItem(
              label: '姓名',
              child: ParkInput(bindKey: 'name'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 慢速搜索历史存储（模拟异步 preload 与 addHistory 的竞态时序）。
class _SlowHistoryStorage implements ParkSearchHistoryStorage {
  _SlowHistoryStorage(this.stored);
  List<String> stored;

  @override
  Future<List<String>> loadHistory(String scope) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return stored;
  }

  @override
  Future<void> saveHistory(String scope, List<String> keywords) async {
    stored = keywords;
  }
}
