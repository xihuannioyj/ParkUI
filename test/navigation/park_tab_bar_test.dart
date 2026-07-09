import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkTabBar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTabBar(
        tabs: ['首页', '消息', '我的'],
        children: [Text('首页'), Text('消息'), Text('我的')],
      )));
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });
    testWidgets('点击切换', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTabBar(
        tabs: ['A', 'B'],
        children: [Text('A内容'), Text('B内容')],
      )));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(find.text('B内容'), findsOneWidget);
    });
    testWidgets('带图标', (tester) async {
      await tester.pumpWidget(_wrap(ParkTabBar(
        tabs: const ['首页', '我的'],
        icons: const [Icons.home, Icons.person],
        children: const [Text('首页'), Text('我的')],
      )));
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
