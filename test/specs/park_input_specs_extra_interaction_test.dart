// QA-04 (B274) — P0/P1 核心输入组件 spec demo 交互断言（Extra）
//
// 覆盖 park_input_specs_extra.dart 中的核心组件：ParkDateRangePicker。
//
// 测试策略同 park_input_specs_interaction_test.dart：
//   - pump spec 登记的 ParkDemoScenario.builder 做真实交互；
//   - 「可交互」demo 验证 onChanged 回显；「双向绑定」demo 验证 model→UI；
//   - 日期范围弹层使用手机视口防溢出。

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

/// 从 parkInputSpecsExtra 中按组件名 + demo 标题取出 demo。
ParkDemoScenario _demo(String component, String title) {
  final ParkComponentSpec? spec = parkInputSpecsExtra[component];
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
  group('ParkDateRangePicker spec 交互', () {
    testWidgets('范围变更回显：打开面板点选「今天」快捷预设触发 onChanged', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkDateRangePicker', '可交互：范围变更回显 (onChanged)');
      expect(find.text('等待选择...'), findsOneWidget);
      await tester.tap(find.byType(ParkDateRangePicker));
      await tester.pumpAndSettle();
      // 底部面板出现确定 / 取消与快捷预设。
      expect(find.text('确定'), findsOneWidget);
      await tester.tap(find.text('今天'));
      await tester.pumpAndSettle();
      // 点击「确定」提交范围，触发 onChanged 回显。
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(find.textContaining('onChanged:'), findsWidgets);
    });

    testWidgets('双向绑定：model 初始日期范围回显 UI（model→UI）', (tester) async {
      await _pumpDemo(tester, 'ParkDateRangePicker', '双向绑定（ParkBinding）');
      // 初始 model {dateRange: 2026-07-01 ~ 2026-07-15} 回显。
      expect(find.textContaining('2026-07-01'), findsWidgets);
    });

    testWidgets('双向绑定：点击触发器可打开日期范围面板', (tester) async {
      _usePhoneViewport(tester);
      await _pumpDemo(tester, 'ParkDateRangePicker', '双向绑定（ParkBinding）');
      await tester.tap(find.byType(ParkDateRangePicker));
      await tester.pumpAndSettle();
      expect(find.text('确定'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
    });
  });
}
