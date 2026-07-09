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
  group('ParkText - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkText('Hello')));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('显示多行文本', (tester) async {
      await tester.pumpWidget(_wrap(const ParkText('第一行\n第二行')));
      expect(find.text('第一行\n第二行'), findsOneWidget);
    });

    testWidgets('空字符串', (tester) async {
      await tester.pumpWidget(_wrap(const ParkText('')));
      expect(find.byType(ParkText), findsOneWidget);
    });
  });
}
