import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkTag', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTag(label: '标签')));
      expect(find.text('标签'), findsOneWidget);
    });
    testWidgets('可关闭标签', (tester) async {
      bool closed = false;
      await tester.pumpWidget(_wrap(ParkTag(label: '可关闭', closable: true, onClose: () => closed = true)));
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, true);
    });
    testWidgets('不同颜色', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTag(label: '红色', color: Colors.red)));
      expect(find.text('红色'), findsOneWidget);
    });
  });
}
