import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkLoading', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    testWidgets('显示加载文字', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLoading(text: '加载中...')));
      expect(find.text('加载中...'), findsOneWidget);
    });
    testWidgets('全屏加载', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLoading.fullscreen(text: '请稍候')));
      expect(find.text('请稍候'), findsOneWidget);
    });
    testWidgets('自定义颜色', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLoading(color: Colors.blue)));
      expect(find.byType(ParkLoading), findsOneWidget);
    });
  });
}
