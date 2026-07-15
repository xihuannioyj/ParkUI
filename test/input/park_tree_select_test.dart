import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkTreeSelect', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkTreeSelect(
        nodes: const [ParkTreeNode(key: '1', label: '研发部')],
      )));
      expect(find.byType(ParkTreeSelect), findsOneWidget);
    });
    testWidgets('显示节点', (tester) async {
      await tester.pumpWidget(_wrap(ParkTreeSelect(
        nodes: const [ParkTreeNode(key: '1', label: '研发部')],
      )));
      expect(find.text('研发部'), findsOneWidget);
    });
  });
}
