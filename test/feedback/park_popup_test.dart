import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkPopup', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkPopup(
        child: const Text('显示弹出层'),
        popupBuilder: (ctx) => Container(
          padding: const EdgeInsets.all(16),
          child: const Text('弹出内容'),
        ),
      )));
      expect(find.text('显示弹出层'), findsOneWidget);
    });
    testWidgets('点击显示弹出层', (tester) async {
      await tester.pumpWidget(_wrap(ParkPopup(
        child: const Text('点我弹出'),
        popupBuilder: (ctx) => Container(
          padding: const EdgeInsets.all(16),
          child: const Text('弹出内容'),
        ),
      )));
      await tester.tap(find.text('点我弹出'));
      await tester.pumpAndSettle();
      expect(find.text('弹出内容'), findsOneWidget);
    });
  });
}
