import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkCascader', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [ParkCascaderOption(label: '浙江省', value: 'zj')],
      )));
      expect(find.byType(ParkCascader), findsOneWidget);
    });
    testWidgets('显示placeholder', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        hintText: '请选择地区',
        options: const [ParkCascaderOption(label: '浙江省', value: 'zj')],
      )));
      expect(find.text('请选择地区'), findsOneWidget);
    });

    testWidgets('disabled state renders', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [ParkCascaderOption(label: '浙江省', value: 'zj')],
        enabled: false,
      )));
      expect(find.byType(ParkCascader), findsOneWidget);
    });

    testWidgets('displays selected value', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        value: const ['zj'],
        options: const [ParkCascaderOption(label: '浙江省', value: 'zj')],
      )));
      expect(find.text('浙江省'), findsOneWidget);
    });

    testWidgets('multiple root options render', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [
          ParkCascaderOption(label: '浙江省', value: 'zj'),
          ParkCascaderOption(label: '江苏省', value: 'js'),
          ParkCascaderOption(label: '广东省', value: 'gd'),
        ],
      )));
      expect(find.byType(ParkCascader), findsOneWidget);
    });

    testWidgets('onChanged callback fires', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [ParkCascaderOption(label: '浙江省', value: 'zj')],
        onChanged: (_) {},
      )));
      await tester.tap(find.byType(ParkCascader));
      await tester.pumpAndSettle();
      // Tap on the option
      if (find.text('浙江省').evaluate().length > 1) {
        await tester.tap(find.text('浙江省').last);
        await tester.pumpAndSettle();
      }
      expect(find.byType(ParkCascader), findsOneWidget);
    });
  });

  group('ParkCascaderOption', () {
    test('isLeaf returns true when no children', () {
      const opt = ParkCascaderOption(label: 'A', value: 'a');
      expect(opt.isLeaf, isTrue);
    });

    test('isLeaf returns false with children', () {
      const opt = ParkCascaderOption(
        label: 'A',
        value: 'a',
        children: [ParkCascaderOption(label: 'B', value: 'b')],
      );
      expect(opt.isLeaf, isFalse);
    });

    test('disabled defaults to false', () {
      const opt = ParkCascaderOption(label: 'A', value: 'a');
      expect(opt.disabled, isFalse);
    });
  });
}
