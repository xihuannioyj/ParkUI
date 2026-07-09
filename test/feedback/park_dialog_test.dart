import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkDialog', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkDialog(
        title: '提示',
        content: '确定要删除吗？',
        onConfirm: () {},
      )));
      expect(find.text('提示'), findsOneWidget);
      expect(find.text('确定要删除吗？'), findsOneWidget);
    });
    testWidgets('点击确认按钮', (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(_wrap(ParkDialog(
        title: '确认',
        content: '是否继续？',
        onConfirm: () => confirmed = true,
      )));
      await tester.tap(find.text('确定'));
      expect(confirmed, true);
    });
    testWidgets('点击取消按钮', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(_wrap(ParkDialog(
        title: '确认',
        content: '是否继续？',
        onCancel: () => cancelled = true,
      )));
      await tester.tap(find.text('取消'));
      expect(cancelled, true);
    });
    testWidgets('自定义按钮文字', (tester) async {
      await tester.pumpWidget(_wrap(ParkDialog(
        title: '提示',
        content: '内容',
        confirmText: '好的',
        cancelText: '不了',
      )));
      expect(find.text('好的'), findsOneWidget);
      expect(find.text('不了'), findsOneWidget);
    });
    testWidgets('无取消按钮', (tester) async {
      await tester.pumpWidget(_wrap(ParkDialog(
        title: '提示',
        content: '单按钮',
        showCancel: false,
        onConfirm: () {},
      )));
      expect(find.text('取消'), findsNothing);
    });
  });
}
