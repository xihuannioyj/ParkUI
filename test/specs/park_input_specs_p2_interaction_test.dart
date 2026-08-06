// QA-04 (B274) — P0/P1 核心输入组件 spec demo 交互断言（Part 2）
//
// 覆盖 park_input_specs_p2.dart 中的 8 个核心输入/表单组件：
//   ParkPicker / ParkCascader / ParkTreeSelect / ParkSlider /
//   ParkStepper / ParkRate / ParkUpload / ParkForm
//
// 测试策略同 park_input_specs_interaction_test.dart：
//   - pump spec 登记的 ParkDemoScenario.builder 做真实交互；
//   - 「双向绑定」demo 验证 model→UI 与 UI→model；
//   - 弹层 / 滚轮类 demo（Picker / Cascader / TreeSelect）使用手机视口防溢出。

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

/// 从 parkInputSpecsPart2 中按组件名 + demo 标题取出 demo。
ParkDemoScenario _demo(String component, String title) {
  final ParkComponentSpec? spec = parkInputSpecsPart2[component];
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
  group('ParkPicker spec 交互', () {
    testWidgets('双向绑定：内联滚轮渲染且 model 初始值回显（model→UI）', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkPicker', '双向绑定（ParkBinding）');
      expect(find.byType(CupertinoPicker), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
      expect(find.textContaining('city: beijing'), findsWidgets);
    });

    testWidgets('双向绑定：滚动滚轮选择「上海」并确定，同步回 model（UI→model）',
        (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkPicker', '双向绑定（ParkBinding）');
      // 向上滚动一格，从「北京」切到「上海」。
      await tester.drag(find.byType(CupertinoPicker), const Offset(0, -32));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.textContaining('city: shanghai'), findsWidgets);
    });
  });

  group('ParkCascader spec 交互', () {
    testWidgets('双向绑定：model 初始值回显（model→UI）', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkCascader', '双向绑定（ParkBinding）');
      expect(find.textContaining('zj'), findsWidgets);
    });

    testWidgets('双向绑定：打开面板选择「江苏省/南京市」同步回 model（UI→model）',
        (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkCascader', '双向绑定（ParkBinding）');
      await tester.tap(find.byType(ParkCascader));
      await tester.pumpAndSettle();
      await tester.tap(find.text('江苏省').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('南京市').last);
      await tester.pumpAndSettle();
      // 单选级联需点击「确定」提交路径。
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.textContaining('nj'), findsWidgets);
    });
  });

  group('ParkTreeSelect spec 交互', () {
    testWidgets('双向绑定：model 初始值回显（model→UI）', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkTreeSelect', '双向绑定（ParkBinding）');
      expect(find.textContaining('team1'), findsWidgets);
    });

    testWidgets('双向绑定：勾选「设计部」节点改变 model（UI→model）', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkTreeSelect', '双向绑定（ParkBinding）');
      expect(find.text('model: {team1}'), findsOneWidget);
      await tester.tap(find.text('设计部'));
      await tester.pumpAndSettle();
      // 勾选后选中集合不再是 {team1}。
      expect(find.text('model: {team1}'), findsNothing);
    });
  });

  group('ParkSlider spec 交互', () {
    testWidgets('基础滑块：拖动滑杆改变显示值', (tester) async {
      await _pumpDemo(tester, 'ParkSlider', '基础滑块');
      expect(find.text('50.0'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.text('50.0'), findsNothing);
    });

    testWidgets('双向绑定：model 初始值回显（model→UI），拖动后同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkSlider', '双向绑定（ParkBinding）');
      expect(find.textContaining('volume: 50'), findsWidgets);
      await tester.drag(find.byType(Slider), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(find.textContaining('volume: 50'), findsNothing);
    });
  });

  group('ParkStepper spec 交互', () {
    testWidgets('基础步进器：点击加号递增数值', (tester) async {
      await _pumpDemo(tester, 'ParkStepper', '基础步进器');
      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.plus));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('双向绑定：model 初始值回显（model→UI），点击加号同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkStepper', '双向绑定（ParkBinding）');
      expect(find.textContaining('count: 5'), findsWidgets);
      await tester.tap(find.byIcon(CupertinoIcons.plus));
      await tester.pumpAndSettle();
      expect(find.textContaining('count: 6'), findsWidgets);
    });
  });

  group('ParkRate spec 交互', () {
    testWidgets('基础评分：点击星星更新评分', (tester) async {
      await _pumpDemo(tester, 'ParkRate', '基础评分');
      expect(find.text('评分: 3'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.star_rounded).last);
      await tester.pumpAndSettle();
      expect(find.text('评分: 3'), findsNothing);
    });

    testWidgets('双向绑定：model 初始值回显（model→UI），点击星星同步回 model（UI→model）',
        (tester) async {
      await _pumpDemo(tester, 'ParkRate', '双向绑定（ParkBinding）');
      expect(find.textContaining('score: 3.0'), findsWidgets);
      await tester.tap(find.byIcon(Icons.star_rounded).at(4));
      await tester.pumpAndSettle();
      expect(find.textContaining('score: 3.0'), findsNothing);
    });
  });

  group('ParkUpload spec 交互', () {
    testWidgets('双向绑定：初始空态回显（model→UI）', (tester) async {
      await _pumpDemo(tester, 'ParkUpload', '双向绑定（ParkBinding）');
      expect(find.text('绑定状态: 共 0 个文件'), findsOneWidget);
      expect(find.text('（暂未选择文件 — 上传前状态）'), findsOneWidget);
    });

    testWidgets('双向绑定：点击添加按钮上传文件并同步回 model（UI→model）', (tester) async {
      await _pumpDemo(tester, 'ParkUpload', '双向绑定（ParkBinding）');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('绑定状态: 共 1 个文件'), findsOneWidget);
      expect(find.textContaining('file_1.pdf'), findsWidgets);
    });
  });

  group('ParkForm spec 交互（表单容器统一入口）', () {
    testWidgets('双向绑定：model 初始值回显（model→UI）', (tester) async {
      await _pumpDemo(tester, 'ParkForm', '双向绑定（ParkBinding）');
      expect(find.textContaining('name: '), findsWidgets);
    });

    testWidgets('双向绑定：在姓名输入框键入同步回 model（UI→model）', (tester) async {
      await _pumpDemo(tester, 'ParkForm', '双向绑定（ParkBinding）');
      await tester.enterText(find.byType(TextField).first, '王五');
      await tester.pumpAndSettle();
      expect(find.textContaining('name: 王五'), findsWidgets);
    });
  });
}
