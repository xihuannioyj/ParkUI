import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkCheckbox - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkCheckbox()));
      expect(find.byType(ParkCheckbox), findsOneWidget);
    });

    testWidgets('显示 label', (tester) async {
      await tester.pumpWidget(_wrap(ParkCheckbox(label: const Text('同意协议'))));
      expect(find.text('同意协议'), findsOneWidget);
    });

    testWidgets('初始选中状态', (tester) async {
      await tester.pumpWidget(_wrap(ParkCheckbox(value: true)));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('初始未选中状态', (tester) async {
      await tester.pumpWidget(_wrap(ParkCheckbox(value: false)));
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });
  });

  group('ParkCheckbox - 交互', () {
    testWidgets('点击切换选中状态', (tester) async {
      bool? checked = false;
      await tester.pumpWidget(_wrap(ParkCheckbox(
        value: checked,
        onChanged: (v) => checked = v,
      )));
      await tester.tap(find.byType(ParkCheckbox));
      expect(checked, true);
    });
  });

  group('ParkCheckbox - 状态', () {
    testWidgets('disabled 不可点击', (tester) async {
      bool? checked = false;
      await tester.pumpWidget(_wrap(ParkCheckbox(
        value: checked,
        disabled: true,
        onChanged: (v) => checked = v,
      )));
      await tester.tap(find.byType(ParkCheckbox));
      expect(checked, false);
    });
  });

  group('ParkCheckbox - 受控 value 跟随外部变化', () {
    testWidgets('父级改变 value 时勾选外观同步更新（列表全选场景）', (tester) async {
      bool checked = false;
      late StateSetter setOuterState;

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setOuterState = setState;
              return ParkCheckbox(
                value: checked,
                onChanged: (bool value) => setState(() => checked = value),
              );
            },
          ),
        ),
      ));

      expect(find.byIcon(Icons.check_rounded), findsNothing);

      setOuterState(() => checked = true);
      await tester.pump();
      expect(
        find.byIcon(Icons.check_rounded),
        findsOneWidget,
        reason: '父级把 value 改为 true 后勾选框必须变为选中',
      );

      setOuterState(() => checked = false);
      await tester.pump();
      expect(
        find.byIcon(Icons.check_rounded),
        findsNothing,
        reason: '父级把 value 改回 false 后勾选框必须变回未选中',
      );
    });

    testWidgets('ParkCheckboxGroup 全选后各选项勾选框一起选中', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCheckboxGroup(
        options: <ParkCheckboxOption>[
          ParkCheckboxOption(label: 'A', value: 'a'),
          ParkCheckboxOption(label: 'B', value: 'b'),
        ],
        selectAll: true,
      )));

      expect(find.byIcon(Icons.check_rounded), findsNothing);

      // 垂直布局下“全选”复选框排在最前面。
      await tester.tap(find.byType(ParkCheckbox).first);
      await tester.pump();

      expect(
        find.byIcon(Icons.check_rounded),
        findsNWidgets(3),
        reason: '全选后两个选项与全选自身都应显示勾选',
      );
    });

    testWidgets('value 未变化时，父级重建不会重置用户刚点的勾选', (tester) async {
      late StateSetter setOuterState;

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              setOuterState = setState;
              // 传常量 value（非受控用法）：只有自身点击会改变勾选。
              return ParkCheckbox(value: false, onChanged: (_) {});
            },
          ),
        ),
      ));

      await tester.tap(find.byType(ParkCheckbox));
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // 父级因其它原因重建，但 value 未变化 —— 不应把用户刚点的勾选重置掉。
      setOuterState(() {});
      await tester.pump();
      expect(
        find.byIcon(Icons.check_rounded),
        findsOneWidget,
        reason: 'value 未变化时应保持内部勾选状态（向后兼容旧用法）',
      );
    });
  });
}
