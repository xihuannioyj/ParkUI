// QA-04 (B274) — P0/P1 核心表单组件 spec demo 交互断言（Form）
//
// 覆盖 park_form_specs.dart 中的核心组件：ParkForm（schema 动态表单）。
//
// 测试策略：pump spec 登记的 ParkDemoScenario.builder，向 schema 渲染出的
// 文本 / 多行字段键入内容，断言输入回显到对应控件（真实 UI 交互）。

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

/// 从 parkFormSpecs 中按组件名 + demo 标题取出 demo。
ParkDemoScenario _demo(String component, String title) {
  final ParkComponentSpec? spec = parkFormSpecs[component];
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

void main() {
  group('ParkForm spec 交互（schema 动态表单）', () {
    testWidgets('基础动态表单：schema 渲染出文本 / 下拉 / 开关 / 多行字段', (tester) async {
      await _pumpDemo(tester, 'ParkForm', '基础动态表单');
      expect(find.text('姓名'), findsOneWidget);
      expect(find.text('城市'), findsOneWidget);
      expect(find.textContaining('是否会员'), findsWidgets);
      expect(find.text('备注'), findsOneWidget);
    });

    testWidgets('基础动态表单：向「姓名」文本字段键入并回显', (tester) async {
      await _pumpDemo(tester, 'ParkForm', '基础动态表单');
      await tester.enterText(find.byType(TextField).first, '李四');
      await tester.pumpAndSettle();
      expect(find.text('李四'), findsOneWidget);
    });

    testWidgets('基础动态表单：向「备注」多行字段键入并回显', (tester) async {
      await _pumpDemo(tester, 'ParkForm', '基础动态表单');
      await tester.enterText(find.byType(TextField).last, '补充说明');
      await tester.pumpAndSettle();
      expect(find.text('补充说明'), findsOneWidget);
    });
  });
}
