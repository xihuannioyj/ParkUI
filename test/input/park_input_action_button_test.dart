import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkInput.actionButton - 渲染', () {
    testWidgets('filled 样式渲染按钮文案', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkInput(
            hintText: '请输入验证码',
            actionButton: ParkInputActionButton(
              child: const Text('发送验证码'),
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('发送验证码'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('text 文字链样式渲染按钮文案', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkInput(
            hintText: '输入 6 位数字口令',
            actionButton: ParkInputActionButton(
              style: ParkInputActionButtonStyle.text,
              child: const Text('校验'),
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('校验'), findsOneWidget);
    });
  });

  group('ParkInput.actionButton - 交互', () {
    testWidgets('点击按钮触发 onPressed', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          ParkInput(
            hintText: '验证码',
            actionButton: ParkInputActionButton(
              child: const Text('发送'),
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('发送'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('onPressed=null 时按钮禁用且点击无响应', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkInput(
            hintText: '验证码',
            actionButton: const ParkInputActionButton(
              child: Text('60s'),
              onPressed: null,
            ),
          ),
        ),
      );
      expect(find.text('60s'), findsOneWidget);
      // 禁用态：InkWell 的 onTap 应为 null
      final InkWell well = tester.widget<InkWell>(
        find.ancestor(of: find.text('60s'), matching: find.byType(InkWell)).first,
      );
      expect(well.onTap, isNull);
    });

    testWidgets('输入框 disabled 时按钮也不可用', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          ParkInput(
            hintText: '验证码',
            enabled: false,
            actionButton: ParkInputActionButton(
              child: const Text('发送'),
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('发送'), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('ParkInput.actionButton - 互斥约束', () {
    test('searchButton 与 actionButton 同时设置触发 assert', () {
      expect(
        () => ParkInput(
          searchButton: true,
          actionButton: ParkInputActionButton(
            child: const Text('发送'),
            onPressed: () {},
          ),
        ),
        throwsAssertionError,
      );
    });
  });

  group('ParkInput - 双层边框修复', () {
    testWidgets('bordered 模式下 TextField 自身边框为 none（无黑色内边框）', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(ParkInput(hintText: '密码')));
      final TextField tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration!.border, InputBorder.none);
      expect(tf.decoration!.enabledBorder, InputBorder.none);
      expect(tf.decoration!.focusedBorder, InputBorder.none);
      expect(tf.decoration!.disabledBorder, InputBorder.none);
      expect(tf.decoration!.errorBorder, InputBorder.none);
      expect(tf.decoration!.focusedErrorBorder, InputBorder.none);
    });
  });
}
