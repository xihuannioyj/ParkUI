import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkRowPage', () {
    testWidgets('renders labels and values', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRowPage(
        items: [
          ParkRowPageItem(label: '租赁名称', value: '阳光花园 3-2-1'),
          ParkRowPageItem(label: '租赁周期', value: '2026-01-01 至 2026-12-31'),
        ],
      )));
      expect(find.text('租赁名称'), findsOneWidget);
      expect(find.text('阳光花园 3-2-1'), findsOneWidget);
      expect(find.text('租赁周期'), findsOneWidget);
      expect(find.text('2026-01-01 至 2026-12-31'), findsOneWidget);
    });

    testWidgets('renders optional title', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRowPage(
        title: '合同信息',
        items: [ParkRowPageItem(label: '甲方', value: '张三')],
      )));
      expect(find.text('合同信息'), findsOneWidget);
      expect(find.text('甲方'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRowPage(
        items: [
          ParkRowPageItem(
            label: '冷表初始值',
            value: '12',
            trailing: Icon(Icons.edit_outlined),
          ),
        ],
      )));
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('single item renders without gap', (tester) async {
      await tester.pumpWidget(_wrap(const ParkRowPage(
        items: [ParkRowPageItem(label: '仅一项', value: '1')],
      )));
      expect(find.text('仅一项'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });
  });
}
