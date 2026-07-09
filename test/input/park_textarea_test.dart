import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkTextarea', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTextarea(hintText: '请输入备注')));
      expect(find.byType(ParkTextarea), findsOneWidget);
    });
    testWidgets('输入文本', (tester) async {
      String val = '';
      await tester.pumpWidget(_wrap(ParkTextarea(hintText: '输入', onChanged: (v) => val = v)));
      await tester.enterText(find.byType(TextField), '多行文本');
      expect(val, '多行文本');
    });
    testWidgets('maxLength限制', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTextarea(hintText: '限制', maxLength: 100)));
      expect(find.text('0/100'), findsOneWidget);
    });
  });
}
