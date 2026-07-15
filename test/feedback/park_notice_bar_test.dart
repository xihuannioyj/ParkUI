import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkNoticeBar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkNoticeBar(text: '这是一条通知')));
      expect(find.text('这是一条通知'), findsOneWidget);
    });
    testWidgets('可关闭', (tester) async {
      bool closed = false;
      await tester.pumpWidget(_wrap(ParkNoticeBar(
        text: '可关闭通知',
        closable: true,
        onClose: () => closed = true,
      )));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(closed, true);
    });
    testWidgets('不同主题', (tester) async {
      await tester.pumpWidget(_wrap(const ParkNoticeBar(text: '警告', variant: ParkNoticeBarVariant.warning)));
      expect(find.text('警告'), findsOneWidget);
    });
  });
}
