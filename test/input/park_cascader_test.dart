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
  });
}
