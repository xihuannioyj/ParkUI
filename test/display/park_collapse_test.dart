import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('ParkCollapse', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCollapse(
        title: '折叠面板',
        children: [Text('内容')],
      )));
      expect(find.text('折叠面板'), findsOneWidget);
    });
    testWidgets('点击展开/折叠', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCollapse(
        title: '面板',
        children: [Text('隐藏内容')],
      )));
      expect(find.text('隐藏内容'), findsNothing);
      await tester.tap(find.text('面板'));
      await tester.pumpAndSettle();
      expect(find.text('隐藏内容'), findsOneWidget);
    });
  });
}
