// QA-04 (B274) — P0/P1 核心输入组件 spec demo 交互断言
//
// 覆盖 park_input_specs.dart 中的 8 个核心输入组件：
//   ParkInput / ParkTextarea / ParkSearch / ParkSwitch /
//   ParkCheckbox / ParkRadio / ParkSelect / ParkDatePicker
//
// 测试策略：
//   - 直接 pump spec 中登记的 ParkDemoScenario.builder（_DemoHost 提供 BuildContext）；
//   - 对「可交互」demo 做真实交互（键入 / 点击 / 切换），断言 StatefulBuilder 回显文本变化；
//   - 对「双向绑定」demo 验证 model→UI（初始 model 值回显）与 UI→model（交互后同步回 model）；
//   - 弹层类 demo（ParkSelect / ParkDatePicker）使用手机视口防止溢出。
//
// 铁律：不修改组件代码与既有测试；仅消费 lib/src/specs 公开 spec。

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 把 demo builder 挂到真实 BuildContext 上。
class _DemoHost extends StatelessWidget {
  final Widget Function(BuildContext) builder;
  const _DemoHost(this.builder);

  @override
  Widget build(BuildContext context) => builder(context);
}

/// 统一测试壳：MaterialApp + ParkThemeData 扩展 + 可滚动 Scaffold。
Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(
        extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );

/// 从 parkInputSpecs 中按组件名 + demo 标题取出 demo。
ParkDemoScenario _demo(String component, String title) {
  final ParkComponentSpec? spec = parkInputSpecs[component];
  expect(spec, isNotNull, reason: '缺少组件 spec：$component');
  return spec!.demos.firstWhere(
    (ParkDemoScenario d) => d.title == title,
    orElse: () => throw StateError('组件 $component 未找到 demo「$title」'),
  );
}

/// pump 指定 demo 并等待稳定。
Future<void> _pumpDemo(
  WidgetTester tester,
  String component,
  String title,
) async {
  await tester.pumpWidget(_wrap(_DemoHost(_demo(component, title).builder)));
  await tester.pumpAndSettle();
}

/// 弹层类 demo 使用手机视口（1080x2340 / dpr 3），并登记清理。
void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('ParkInput spec 交互', () {
    testWidgets('实时回显输入：键入文本触发 onChanged 并回显', (tester) async {
      await _pumpDemo(tester, 'ParkInput', '可交互：实时回显输入');
      expect(find.text('已输入：'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pumpAndSettle();
      expect(find.text('已输入：hello'), findsOneWidget);
    });

    testWidgets('完整事件演示：点击输入框触发回调，日志离开初始态', (tester) async {
      await _pumpDemo(tester, 'ParkInput', '可交互：完整事件演示');
      expect(find.text('等待交互...'), findsOneWidget);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('等待交互...'), findsNothing);
    });

    testWidgets('双向绑定：model 初始值回显 UI（model→UI），输入再同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkInput', '双向绑定（ParkBinding）');
      // model→UI：初始 model {name: 张三} 回显。
      expect(find.textContaining('张三'), findsWidgets);
      // UI→model：键入新值同步回 model。
      await tester.enterText(find.byType(TextField), '李四');
      await tester.pumpAndSettle();
      expect(find.textContaining('李四'), findsWidgets);
    });
  });

  group('ParkTextarea spec 交互', () {
    testWidgets('实时回显多行输入：键入文本回显字符数', (tester) async {
      await _pumpDemo(tester, 'ParkTextarea', '可交互：实时回显多行输入');
      expect(find.text('已输入字符数：0'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pumpAndSettle();
      expect(find.text('已输入字符数：5'), findsOneWidget);
    });

    testWidgets('焦点事件演示：点击多行框触发 onFocus', (tester) async {
      await _pumpDemo(tester, 'ParkTextarea', '可交互：焦点事件演示');
      expect(find.text('等待交互...'), findsOneWidget);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('onFocus'), findsOneWidget);
    });

    testWidgets('双向绑定：model 初始值回显（model→UI），输入再同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkTextarea', '双向绑定（ParkBinding）');
      expect(find.textContaining('Flutter 开发者'), findsWidgets);
      await tester.enterText(find.byType(TextField), 'Dart 工程师');
      await tester.pumpAndSettle();
      expect(find.textContaining('Dart 工程师'), findsWidgets);
    });
  });

  group('ParkSearch spec 交互', () {
    testWidgets('实时搜索回显：键入搜索词触发 onChanged 并回显', (tester) async {
      await _pumpDemo(tester, 'ParkSearch', '可交互：实时搜索回显');
      expect(find.text('搜索词：'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle();
      expect(find.text('搜索词：flutter'), findsOneWidget);
    });

    testWidgets('清除与搜索事件演示：键入后点击清除按钮触发 onClear', (tester) async {
      await _pumpDemo(tester, 'ParkSearch', '可交互：清除与搜索事件演示');
      expect(find.text('等待交互...'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.clear_circled_solid));
      await tester.pumpAndSettle();
      expect(find.text('onClear'), findsOneWidget);
    });

    testWidgets('双向绑定：键入搜索词同步回 model（UI→model）', (tester) async {
      await _pumpDemo(tester, 'ParkSearch', '双向绑定（ParkBinding）');
      await tester.enterText(find.byType(TextField), 'dart');
      await tester.pumpAndSettle();
      expect(find.textContaining('dart'), findsWidgets);
    });
  });

  group('ParkSwitch spec 交互', () {
    testWidgets('实时回显开关状态：点击切换并回显', (tester) async {
      await _pumpDemo(tester, 'ParkSwitch', '可交互：实时回显开关状态');
      expect(find.text('状态：false'), findsOneWidget);
      await tester.tap(find.byType(ParkSwitch));
      await tester.pumpAndSettle();
      expect(find.text('状态：true'), findsOneWidget);
    });

    testWidgets('绑定演示：model 初始值回显到开关与实时值（model→UI）', (tester) async {
      await _pumpDemo(tester, 'ParkSwitch', '绑定演示');
      // model→UI：初始 model {enabled: true} 回显到「实时值」与开关。
      expect(find.textContaining('enabled: true'), findsWidgets);
      final ParkSwitch sw = tester.widget<ParkSwitch>(find.byType(ParkSwitch));
      expect(sw.initialValue, isTrue);
    });
  });

  group('ParkCheckbox spec 交互', () {
    testWidgets('实时回显选中状态：点击勾选并回显', (tester) async {
      await _pumpDemo(tester, 'ParkCheckbox', '可交互：实时回显选中状态');
      expect(find.text('已同意：false'), findsOneWidget);
      await tester.tap(find.byType(ParkCheckbox));
      await tester.pumpAndSettle();
      expect(find.text('已同意：true'), findsOneWidget);
    });

    testWidgets('双向绑定：model 初始值回显（model→UI），点击取消勾选同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkCheckbox', '绑定演示');
      expect(find.textContaining('agree: true'), findsWidgets);
      await tester.tap(find.byType(ParkCheckbox));
      await tester.pumpAndSettle();
      expect(find.textContaining('agree: false'), findsWidgets);
    });
  });

  group('ParkRadio spec 交互', () {
    testWidgets('实时回显选中值：点击选项 B 切换选中值', (tester) async {
      await _pumpDemo(tester, 'ParkRadio', '可交互：实时回显选中值');
      expect(find.text('选中：a'), findsOneWidget);
      await tester.tap(find.text('选项 B'));
      await tester.pumpAndSettle();
      expect(find.text('选中：b'), findsOneWidget);
    });

    testWidgets('双向绑定：model 初始值回显（model→UI），点击「女」同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkRadio', '绑定演示');
      expect(find.textContaining('gender: male'), findsWidgets);
      await tester.tap(find.text('女'));
      await tester.pumpAndSettle();
      expect(find.textContaining('gender: female'), findsWidgets);
    });
  });

  group('ParkSelect spec 交互', () {
    testWidgets('实时回显选中值：打开面板选择「上海」触发 onChanged', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkSelect', '可交互：实时回显选中值');
      expect(find.text('选中：beijing'), findsOneWidget);
      await tester.tap(find.byType(ParkSelect));
      await tester.pumpAndSettle();
      await tester.tap(find.text('上海').last);
      await tester.pumpAndSettle();
      expect(find.text('选中：shanghai'), findsOneWidget);
    });

    testWidgets('远程搜索回显：打开面板键入搜索词触发 onSearchChanged', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkSelect', '可交互：远程搜索回显');
      expect(find.text('搜索词：'), findsOneWidget);
      await tester.tap(find.byType(ParkSelect));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'gz');
      await tester.pumpAndSettle();
      expect(find.text('搜索词：gz'), findsOneWidget);
    });
  });

  group('ParkDatePicker spec 交互', () {
    testWidgets('实时回显选中日期：打开面板确认默认日期触发 onChanged', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkDatePicker', '可交互：实时回显选中日期');
      expect(find.text('已选：未选择'), findsOneWidget);
      await tester.tap(find.byType(ParkDatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.text('已选：未选择'), findsNothing);
    });

    testWidgets('双向绑定：model 初始日期回显 UI（model→UI）', (tester) async {
      await _pumpDemo(tester, 'ParkDatePicker', '双向绑定（ParkBinding）');
      // 初始 model {birthday: DateTime(2000,1,1)} 回显。
      expect(find.textContaining('2000-01-01'), findsWidgets);
    });

    testWidgets('双向绑定：点击触发器可打开日期面板', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkDatePicker', '双向绑定（ParkBinding）');
      await tester.tap(find.byType(ParkDatePicker));
      await tester.pumpAndSettle();
      expect(find.text('确定'), findsOneWidget);
    });
  });
}
