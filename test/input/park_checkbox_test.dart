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
      await tester.pumpWidget(_wrap(const ParkCheckbox()));
      expect(find.byType(ParkCheckbox), findsOneWidget);
    });

    testWidgets('显示 label', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCheckbox(label: '同意协议')));
      expect(find.text('同意协议'), findsOneWidget);
    });

    testWidgets('初始选中状态', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCheckbox(value: true)));
      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('初始未选中状态', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCheckbox(value: false)));
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
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
}
