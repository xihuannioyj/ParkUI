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
  group('ParkFab - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkFab(
        onPressed: () {},
        child: const Icon(Icons.add),
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(ParkFab(
        onPressed: () => pressed++,
        child: const Icon(Icons.add),
      )));
      await tester.tap(find.byIcon(Icons.add));
      expect(pressed, 1);
    });

    testWidgets('自定义颜色', (tester) async {
      await tester.pumpWidget(_wrap(ParkFab(
        onPressed: () {},
        color: Colors.blue,
        child: const Icon(Icons.edit),
      )));
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
