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
  group('ParkLink - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        text: '链接文本',
        onPressed: null,
      )));
      expect(find.text('链接文本'), findsOneWidget);
    });

    testWidgets('可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(ParkLink(
        text: '点我',
        onPressed: () => pressed++,
      )));
      await tester.tap(find.text('点我'));
      expect(pressed, 1);
    });

    testWidgets('disabled 不可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(ParkLink(
        text: '禁用',
        disabled: true,
        onPressed: () => pressed++,
      )));
      await tester.tap(find.text('禁用'));
      expect(pressed, 0);
    });
  });
}
