import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/base/park_divider.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkDivider - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDivider()));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('水平分割线', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('divider with text', (tester) async {
      await tester.pumpWidget(_wrap(ParkDivider.withText('OR')));
      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('vertical divider renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDivider(
        axis: ParkDividerAxis.vertical,
        verticalHeight: 24,
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('dashed divider renders', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(dashed: true),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('dotted divider renders', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(dotted: true),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('custom color', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(color: Colors.red),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('custom thickness', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(thickness: 2),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('withText left alignment', (tester) async {
      await tester.pumpWidget(_wrap(ParkDivider.withText(
        'Left',
        textAlign: ParkDividerTextAlign.left,
      )));
      expect(find.text('Left'), findsOneWidget);
    });

    testWidgets('withText right alignment', (tester) async {
      await tester.pumpWidget(_wrap(ParkDivider.withText(
        'Right',
        textAlign: ParkDividerTextAlign.right,
      )));
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('withText with icon', (tester) async {
      await tester.pumpWidget(_wrap(ParkDivider.withText(
        'Settings',
        icon: Icons.settings,
      )));
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
