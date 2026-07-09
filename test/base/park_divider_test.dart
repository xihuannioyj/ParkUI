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
  group('ParkDivider - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDivider()));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('水平分割线', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('带文字的分割线', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDivider(child: Text('OR'))));
      expect(find.text('OR'), findsOneWidget);
    });
  });
}
