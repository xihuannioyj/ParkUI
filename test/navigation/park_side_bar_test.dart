import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkSideBar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSideBar(
        items: [
          ParkSideBarItem(key: 'a', label: '选项A'),
          ParkSideBarItem(key: 'b', label: '选项B'),
        ],
      )));
      expect(find.text('选项A'), findsOneWidget);
      expect(find.text('选项B'), findsOneWidget);
    });
    testWidgets('点击选择', (tester) async {
      String selected = '';
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(key: 'a', label: 'A'),
          ParkSideBarItem(key: 'b', label: 'B'),
        ],
        onChanged: (key) => selected = key,
      )));
      await tester.tap(find.text('B'));
      expect(selected, 'b');
    });
  });
}
