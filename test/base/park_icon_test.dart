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
  group('ParkIcon - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkIcon(Icons.home)));
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('自定义大小', (tester) async {
      await tester.pumpWidget(_wrap(const ParkIcon(Icons.star, size: 48)));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('自定义颜色', (tester) async {
      await tester.pumpWidget(_wrap(const ParkIcon(Icons.favorite, color: Colors.red)));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
