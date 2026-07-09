import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkTabs', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTabs(
        tabs: ['标签1', '标签2', '标签3'],
        children: [Text('内容1'), Text('内容2'), Text('内容3')],
      )));
      expect(find.text('标签1'), findsOneWidget);
      expect(find.text('标签2'), findsOneWidget);
      expect(find.text('标签3'), findsOneWidget);
      expect(find.text('内容1'), findsOneWidget);
    });
    testWidgets('点击切换标签', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTabs(
        tabs: ['A', 'B'],
        children: [Text('内容A'), Text('内容B')],
      )));
      expect(find.text('内容A'), findsOneWidget);
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(find.text('内容B'), findsOneWidget);
    });
    testWidgets('自定义初始索引', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTabs(
        tabs: ['A', 'B'],
        children: [Text('内容A'), Text('内容B')],
        initialIndex: 1,
      )));
      expect(find.text('内容B'), findsOneWidget);
    });
  });
}
