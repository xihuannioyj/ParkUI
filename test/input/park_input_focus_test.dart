import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkInput 焦点稳定性（首次聚焦输入首字符键盘缩回回归）', () {
    testWidgets('首次聚焦输入首字符后焦点不丢失（clearable 清除按钮出现不应重建 TextField）',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _wrap(ParkInput(
          focusNode: focusNode,
          hintText: '请输入',
          clearable: true,
        )),
      );

      // 点击获取焦点
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue, reason: '点击后应获得焦点');

      // 输入第一个字符 —— 触发 clearable 清除按钮出现
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();

      // 回归断言：修复前此处焦点丢失（hasFocus=false，键盘缩回）
      expect(focusNode.hasFocus, isTrue,
          reason: '输入首字符后焦点不应丢失（键盘不应缩回）');
      // clearable 行为不变：清除按钮应已出现
      expect(find.byIcon(CupertinoIcons.clear_circled_solid), findsOneWidget);
    });

    testWidgets('输入首字符后 EditableText 实例保持不变（TextField 树位置稳定）',
        (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _wrap(ParkInput(focusNode: focusNode, hintText: '请输入')),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final before =
          tester.state<EditableTextState>(find.byType(EditableText));

      await tester.enterText(find.byType(TextField), 'a');
      await tester.pumpAndSettle();
      final after =
          tester.state<EditableTextState>(find.byType(EditableText));

      // 同一个 EditableTextState 实例 → TextField 未被重建
      expect(identical(before, after), isTrue,
          reason: 'TextField 的 EditableText 不应因清除按钮出现而重建');
    });

    testWidgets('继续输入更多字符焦点持续保持', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _wrap(ParkInput(focusNode: focusNode, hintText: '请输入')),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      for (final s in ['a', 'ab', 'abc', 'abcd']) {
        await tester.enterText(find.byType(TextField), s);
        await tester.pumpAndSettle();
        expect(focusNode.hasFocus, isTrue, reason: '输入 "$s" 后焦点应保持');
      }
    });
  });
}
