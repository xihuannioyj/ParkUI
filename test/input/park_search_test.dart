import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkSearch', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSearch()));
      expect(find.byType(ParkSearch), findsOneWidget);
    });
    testWidgets('显示placeholder', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSearch(hintText: '搜索...')));
      expect(find.text('搜索...'), findsOneWidget);
    });
    testWidgets('输入触发onChanged', (tester) async {
      String val = '';
      await tester.pumpWidget(_wrap(ParkSearch(onChanged: (v) => val = v)));
      await tester.enterText(find.byType(TextField), '关键词');
      expect(val, '关键词');
    });
    testWidgets('onSubmitted触发', (tester) async {
      String submitted = '';
      await tester.pumpWidget(_wrap(ParkSearch(onSubmitted: (v) => submitted = v)));
      await tester.enterText(find.byType(TextField), '搜索');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, '搜索');
    });
  });
}
