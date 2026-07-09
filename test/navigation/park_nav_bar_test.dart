import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkNavBar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkNavBar(title: '页面标题')));
      expect(find.text('页面标题'), findsOneWidget);
    });
    testWidgets('显示返回按钮', (tester) async {
      bool back = false;
      await tester.pumpWidget(_wrap(ParkNavBar(title: '详情', showBack: true, onBack: () => back = true)));
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      expect(back, true);
    });
    testWidgets('右侧操作按钮', (tester) async {
      await tester.pumpWidget(_wrap(const ParkNavBar(
        title: '标题',
        actions: [Icon(Icons.more_horiz)],
      )));
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });
    testWidgets('自定义颜色', (tester) async {
      await tester.pumpWidget(_wrap(const ParkNavBar(title: '自定义', backgroundColor: Colors.blue, titleColor: Colors.white)));
      expect(find.text('自定义'), findsOneWidget);
    });
  });
}
