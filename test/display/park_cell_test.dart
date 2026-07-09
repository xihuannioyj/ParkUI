import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkCell', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(titleText: '设置项')));
      expect(find.text('设置项'), findsOneWidget);
    });
    testWidgets('显示描述文字', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(titleText: '标题', descriptionText: '描述')));
      expect(find.text('描述'), findsOneWidget);
    });
    testWidgets('显示箭头', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(titleText: '可点击', arrow: true)));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
    testWidgets('显示左侧图标', (tester) async {
      await tester.pumpWidget(_wrap(ParkCell(titleText: '设置', leftIcon: const Icon(Icons.settings))));
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
    testWidgets('显示右侧备注', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(titleText: '版本', note: '1.0.0')));
      expect(find.text('1.0.0'), findsOneWidget);
    });
    testWidgets('可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(ParkCell(titleText: '点我', onPressed: () => pressed++)));
      await tester.tap(find.text('点我'));
      expect(pressed, 1);
    });
    testWidgets('无箭头无点击', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(titleText: '纯展示')));
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
    testWidgets('bordered=false不显示分割线', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(titleText: '无边', bordered: false)));
      expect(find.text('无边'), findsOneWidget);
    });
    testWidgets('自定义title Widget', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCell(title: Text('自定义', style: TextStyle(color: Colors.red)))));
      expect(find.text('自定义'), findsOneWidget);
    });
  });
}
