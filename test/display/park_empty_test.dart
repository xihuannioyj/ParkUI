import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkEmpty', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkEmpty()));
      expect(find.byType(ParkEmpty), findsOneWidget);
    });
    testWidgets('自定义文案', (tester) async {
      await tester.pumpWidget(_wrap(const ParkEmpty(description: '没有数据哦')));
      expect(find.text('没有数据哦'), findsOneWidget);
    });
    testWidgets('自定义图标', (tester) async {
      await tester.pumpWidget(_wrap(const ParkEmpty(icon: Icon(Icons.inbox))));
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });
  });
}
