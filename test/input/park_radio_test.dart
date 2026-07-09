import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkRadio', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRadio(value: 'a', groupValue: 'a')));
      expect(find.byType(ParkRadio), findsOneWidget);
    });
    testWidgets('显示label', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRadio(value: 'a', groupValue: null, label: '选项A')));
      expect(find.text('选项A'), findsOneWidget);
    });
    testWidgets('选中状态', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRadio(value: 'a', groupValue: 'a')));
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });
    testWidgets('未选中状态', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRadio(value: 'a', groupValue: 'b')));
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });
    testWidgets('点击切换', (tester) async {
      String? val;
      await tester.pumpWidget(_wrap(ParkRadio(value: 'a', groupValue: val, onChanged: (v) => val = v)));
      await tester.tap(find.byType(ParkRadio));
      expect(val, 'a');
    });
  });
}
