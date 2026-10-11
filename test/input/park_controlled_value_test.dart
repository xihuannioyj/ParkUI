import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 受控 value 契约：父级改变 `value` 时，组件内部的 FormField 值必须跟随。
///
/// 背景：Park 输入组件都把 `value` 作为 `FormField.initialValue` 传入，而 Flutter 的
/// `FormFieldState` 只在首次创建时读取 `initialValue`（其 didUpdateWidget 只同步
/// forceErrorText）。组件若不在 didUpdateWidget 里自行同步，"重置 / 全选 / 外部联动"
/// 这类受控用法就不会更新显示。
///
/// 触发本套用例的真实线上问题：提成记录列表点“全选”后，每行的勾选框不变选中
/// （ParkCheckbox，见 test/input/park_checkbox_test.dart）。
///
/// ParkSlider 已自带同类同步，故不在本文件覆盖。
void main() {
  /// 用 StatefulBuilder 承载外部状态，并返回可从测试里改值的 setState。
  Future<StateSetter> pumpHost(
    WidgetTester tester,
    Widget Function() build,
  ) async {
    late StateSetter setOuter;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setOuter = setState;
              return build();
            },
          ),
        ),
      ),
    ));
    return setOuter;
  }

  /// 读取组件内部 FormField 的当前值。
  T? fieldValue<T>(WidgetTester tester, Type type) =>
      tester.state<FormFieldState<T>>(find.byType(type)).value;

  testWidgets('ParkSwitch 跟随外部 value', (tester) async {
    dynamic value = false;
    final StateSetter setOuter = await pumpHost(
      tester,
      () => ParkSwitch(
        value: value,
        checkedValue: true,
        uncheckedValue: false,
      ),
    );

    expect(fieldValue<dynamic>(tester, ParkSwitch), false);

    setOuter(() => value = true);
    await tester.pump();
    expect(fieldValue<dynamic>(tester, ParkSwitch), true);
  });

  testWidgets('ParkRadio 跟随外部 value', (tester) async {
    String? value = 'a';
    final StateSetter setOuter = await pumpHost(
      tester,
      () => ParkRadio(
        value: value,
        options: const <ParkRadioOption>[
          ParkRadioOption(label: 'A', value: 'a'),
          ParkRadioOption(label: 'B', value: 'b'),
        ],
      ),
    );

    expect(fieldValue<String>(tester, ParkRadio), 'a');

    setOuter(() => value = 'b');
    await tester.pump();
    expect(fieldValue<String>(tester, ParkRadio), 'b');
  });

  testWidgets('ParkRate 跟随外部 value', (tester) async {
    double value = 1;
    final StateSetter setOuter =
        await pumpHost(tester, () => ParkRate(value: value));

    expect(fieldValue<double>(tester, ParkRate), 1);

    setOuter(() => value = 4);
    await tester.pump();
    expect(fieldValue<double>(tester, ParkRate), 4);
  });

  testWidgets('ParkStepper 跟随外部 value（含文本框显示）', (tester) async {
    int value = 1;
    final StateSetter setOuter =
        await pumpHost(tester, () => ParkStepper(value: value));

    expect(fieldValue<int>(tester, ParkStepper), 1);
    expect(find.text('1'), findsOneWidget);

    setOuter(() => value = 5);
    await tester.pump();
    expect(fieldValue<int>(tester, ParkStepper), 5);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('ParkSelect 跟随外部 value', (tester) async {
    String? value = 'a';
    final StateSetter setOuter = await pumpHost(
      tester,
      () => ParkSelect(
        value: value,
        items: const <ParkSelectOption>[
          ParkSelectOption(label: 'A', value: 'a'),
          ParkSelectOption(label: 'B', value: 'b'),
        ],
      ),
    );

    expect(fieldValue<String>(tester, ParkSelect), 'a');
    expect(find.text('A'), findsOneWidget);

    setOuter(() => value = 'b');
    await tester.pump();
    expect(fieldValue<String>(tester, ParkSelect), 'b');
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('ParkCascader 跟随外部 value', (tester) async {
    List<String>? value = <String>['zj'];
    final StateSetter setOuter = await pumpHost(
      tester,
      () => ParkCascader(
        value: value,
        options: const <ParkCascaderOption>[
          ParkCascaderOption(label: '浙江', value: 'zj'),
          ParkCascaderOption(label: '江苏', value: 'js'),
        ],
      ),
    );

    expect(fieldValue<List<String>>(tester, ParkCascader), <String>['zj']);

    setOuter(() => value = <String>['js']);
    await tester.pump();
    expect(fieldValue<List<String>>(tester, ParkCascader), <String>['js']);
  });

  testWidgets('ParkCascader 内容相同的新 List 实例不覆盖内部已选值', (tester) async {
    List<String>? value = <String>['zj'];
    final StateSetter setOuter = await pumpHost(
      tester,
      () => ParkCascader(
        value: value,
        options: const <ParkCascaderOption>[
          ParkCascaderOption(label: '浙江', value: 'zj'),
          ParkCascaderOption(label: '江苏', value: 'js'),
        ],
      ),
    );

    final FormFieldState<List<String>> state =
        tester.state<FormFieldState<List<String>>>(find.byType(ParkCascader));

    // 模拟用户在选择面板里改成了江苏。
    state.didChange(<String>['js']);
    await tester.pump();
    expect(fieldValue<List<String>>(tester, ParkCascader), <String>['js']);

    // 父级重建，传入内容相同的新 List 实例：不应把用户刚选的值重置回去。
    setOuter(() => value = <String>['zj']);
    await tester.pump();
    expect(
      fieldValue<List<String>>(tester, ParkCascader),
      <String>['js'],
      reason: 'List 应按内容比较，内容未变时不应覆盖内部已选值',
    );
  });

  testWidgets('ParkDatePicker 跟随外部 value', (tester) async {
    DateTime? value = DateTime(2026, 1, 1);
    final StateSetter setOuter = await pumpHost(
      tester,
      () => ParkDatePicker(value: value, format: 'yyyy/MM/dd'),
    );

    expect(fieldValue<DateTime>(tester, ParkDatePicker), DateTime(2026, 1, 1));
    expect(find.text('2026/01/01'), findsOneWidget);

    setOuter(() => value = DateTime(2026, 5, 5));
    await tester.pump();
    expect(fieldValue<DateTime>(tester, ParkDatePicker), DateTime(2026, 5, 5));
    expect(find.text('2026/05/05'), findsOneWidget);
  });
}
