import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkTabBar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkTabBar(
        items: [
          ParkTabBarItem(icon: Icons.home, label: '首页'),
          ParkTabBarItem(icon: Icons.message, label: '消息'),
          ParkTabBarItem(icon: Icons.person, label: '我的'),
        ],
      )));
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    });
    testWidgets('点击切换', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(_wrap(ParkTabBar(
        items: [
          ParkTabBarItem(icon: Icons.star, label: 'A'),
          ParkTabBarItem(icon: Icons.star, label: 'B'),
        ],
        currentIndex: 0,
        onTap: (index) => tappedIndex = index,
      )));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);
    });
    testWidgets('带图标', (tester) async {
      await tester.pumpWidget(_wrap(ParkTabBar(
        items: [
          ParkTabBarItem(icon: Icons.home, label: '首页'),
          ParkTabBarItem(icon: Icons.person, label: '我的'),
        ],
      )));
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}
