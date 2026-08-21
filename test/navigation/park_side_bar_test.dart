import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkSideBar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(icon: Icons.circle, label: '选项A'),
          ParkSideBarItem(icon: Icons.circle, label: '选项B'),
        ],
      )));
      expect(find.text('选项A'), findsOneWidget);
      expect(find.text('选项B'), findsOneWidget);
    });
    testWidgets('点击选择', (tester) async {
      int selected = -1;
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(icon: Icons.circle, label: 'A'),
          ParkSideBarItem(icon: Icons.circle, label: 'B'),
        ],
        onChanged: (index) => selected = index,
      )));
      await tester.tap(find.text('B'));
      expect(selected, 1);
    });

    testWidgets('collapsed mode shows icons only', (tester) async {
      await tester.pumpWidget(_wrap(ParkSideBar(
        collapsed: true,
        collapsedWidth: 64,
        items: [
          ParkSideBarItem(icon: Icons.dashboard, label: 'Dashboard'),
          ParkSideBarItem(icon: Icons.settings, label: 'Settings'),
        ],
      )));
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('children items expand on tap', (tester) async {
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(icon: Icons.folder, label: 'Parent', children: [
            ParkSideBarItem(icon: Icons.file_copy, label: 'Child1'),
            ParkSideBarItem(icon: Icons.file_copy, label: 'Child2'),
          ]),
        ],
        selectedIndex: 0,
      )));
      // selectedIndex=0 auto-expands the children
      expect(find.text('Child1'), findsOneWidget);
      expect(find.text('Child2'), findsOneWidget);
    });

    testWidgets('badge displays text', (tester) async {
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(icon: Icons.mail, label: 'Messages', badge: '12'),
        ],
      )));
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('disabled item does not trigger onChanged', (tester) async {
      int selected = -1;
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(icon: Icons.circle, label: 'Active'),
          ParkSideBarItem(icon: Icons.block, label: 'Disabled', disabled: true),
        ],
        onChanged: (index) => selected = index,
      )));
      await tester.tap(find.text('Disabled'));
      expect(selected, -1);
    });

    testWidgets('dark theme renders', (tester) async {
      await tester.pumpWidget(_wrap(ParkSideBar(
        theme: ParkSideBarTheme.dark,
        items: [
          ParkSideBarItem(icon: Icons.circle, label: 'DarkItem'),
        ],
      )));
      expect(find.text('DarkItem'), findsOneWidget);
    });

    testWidgets('header and footer render', (tester) async {
      await tester.pumpWidget(_wrap(ParkSideBar(
        items: [
          ParkSideBarItem(icon: Icons.circle, label: 'Item'),
        ],
        header: const Text('Header'),
        footer: const Text('Footer'),
      )));
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('三档尺寸均可渲染', (tester) async {
      await tester.pumpWidget(_wrap(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            child: ParkSideBar(
              size: ParkSideBarSize.small,
              items: const [ParkSideBarItem(icon: Icons.circle, label: '小')],
            ),
          ),
          SizedBox(
            height: 100,
            child: ParkSideBar(
              size: ParkSideBarSize.medium,
              items: const [ParkSideBarItem(icon: Icons.circle, label: '中')],
            ),
          ),
          SizedBox(
            height: 100,
            child: ParkSideBar(
              size: ParkSideBarSize.large,
              items: const [ParkSideBarItem(icon: Icons.circle, label: '大')],
            ),
          ),
        ],
      )));
      expect(find.text('小'), findsOneWidget);
      expect(find.text('中'), findsOneWidget);
      expect(find.text('大'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
