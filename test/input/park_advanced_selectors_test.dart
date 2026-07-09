import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

void main() {
  testWidgets('ParkPicker 应能渲染标题与选项', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: const Scaffold(
          body: SizedBox(
            height: 260,
            child: ParkPicker(
              title: '选择城市',
              items: <ParkPickerItem>[
                ParkPickerItem(label: '北京', value: 'beijing'),
                ParkPickerItem(label: '上海', value: 'shanghai'),
              ],
              value: 'beijing',
            ),
          ),
        ),
      ),
    );

    expect(find.text('选择城市'), findsOneWidget);
    expect(find.text('北京'), findsWidgets);
  });

  testWidgets('ParkTreeSelect 多选模式应能展示节点', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
        ),
        home: Scaffold(
          body: ParkTreeSelect(
            multiple: true,
            nodes: const <ParkTreeNode>[
              ParkTreeNode(
                key: 'dept1',
                label: '研发部',
                children: <ParkTreeNode>[
                  ParkTreeNode(key: 'team1', label: '前端组'),
                  ParkTreeNode(key: 'team2', label: '后端组'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('研发部'), findsOneWidget);
  });
}
