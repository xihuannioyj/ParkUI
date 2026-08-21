import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('ParkCollapse', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkCollapse(
        items: const [
          ParkCollapseItem(key: '1', title: '折叠面板', content: Text('内容')),
        ],
      )));
      expect(find.text('折叠面板'), findsOneWidget);
    });
    testWidgets('点击展开/折叠', (tester) async {
      await tester.pumpWidget(_wrap(ParkCollapse(
        items: const [
          ParkCollapseItem(key: '1', title: '面板', content: Text('隐藏内容')),
        ],
      )));
      final fade = find.ancestor(
        of: find.text('隐藏内容'),
        matching: find.byType(FadeTransition),
      ).first;
      // 初始折叠：内容不可见（透明度为 0）
      expect(tester.widget<FadeTransition>(fade).opacity.value, 0.0);
      // 点击展开
      await tester.tap(find.text('面板'));
      await tester.pumpAndSettle();
      expect(tester.widget<FadeTransition>(fade).opacity.value, 1.0);
      expect(find.text('隐藏内容'), findsOneWidget);
    });
    testWidgets('三档尺寸均可渲染', (tester) async {
      for (final size in ParkCollapseSize.values) {
        await tester.pumpWidget(_wrap(ParkCollapse(
          size: size,
          items: const [
            ParkCollapseItem(key: '1', title: '折叠面板', content: Text('内容')),
          ],
        )));
        expect(find.text('折叠面板'), findsOneWidget);
      }
    });
  });
}
