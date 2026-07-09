import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkInput 后缀/附件 (P0-2)', () {
    testWidgets('suffixIcon 出现在树中', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: '搜索',
        suffixIcon: const Icon(Icons.search),
      )));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('suffix 出现在树中', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: '金额',
        suffix: const Text('元'),
      )));
      expect(find.text('元'), findsOneWidget);
    });

    testWidgets('addonBefore 出现在树中', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: 'x',
        addonBefore: const Text('前缀'),
      )));
      expect(find.text('前缀'), findsOneWidget);
    });

    testWidgets('addonAfter 出现在树中', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: 'x',
        addonAfter: const Text('后缀'),
      )));
      expect(find.text('后缀'), findsOneWidget);
    });

    testWidgets('showCount 显示字数统计', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: 'x',
        maxLength: 10,
        showCount: true,
      )));
      expect(find.text('0/10'), findsOneWidget);
    });

    testWidgets('status=error 边框变红', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: 'x',
        status: ParkInputStatus.error,
      )));
      final colors = ParkThemeData.light().colors;
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final inputContainer = containers.where((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.borderRadius != null;
      }).toList();
      expect(inputContainer, isNotEmpty);
      final border =
          (inputContainer.first.decoration! as BoxDecoration).border as Border;
      expect(border.top.color, colors.error);
    });
  });
}
