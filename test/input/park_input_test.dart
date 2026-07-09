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
  group('ParkInput - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(hintText: '请输入')));
      expect(find.byType(ParkInput), findsOneWidget);
    });

    testWidgets('显示 label', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(label: '用户名', hintText: '请输入用户名')));
      expect(find.text('用户名'), findsOneWidget);
    });

    testWidgets('显示 hintText', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(hintText: '请输入手机号')));
      expect(find.text('请输入手机号'), findsOneWidget);
    });

    testWidgets('显示 prefixIcon', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: '搜索',
        prefixIcon: const Icon(Icons.search),
      )));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('ParkInput - 交互', () {
    testWidgets('输入文本触发 onChanged', (tester) async {
      String value = '';
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: '输入',
        onChanged: (v) => value = v,
      )));
      await tester.enterText(find.byType(TextField), 'hello');
      expect(value, 'hello');
    });

    testWidgets('clearable 显示清除按钮', (tester) async {
      await tester.pumpWidget(_wrap(ParkInput(
        hintText: '可清除',
        clearable: true,
      )));
      // 先输入文字
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      // 应该出现清除图标
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('obscureText 密码切换', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(
        hintText: '密码',
        obscureText: true,
      )));
      // 应该显示眼睛图标用于切换
      final eyeIcon = find.byIcon(Icons.visibility_off);
      expect(eyeIcon, findsOneWidget);

      await tester.tap(eyeIcon);
      await tester.pump();
      // 切换后应变为 visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('maxLines > 1 多行输入', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(
        hintText: '备注',
        maxLines: 3,
      )));
      expect(find.byType(ParkInput), findsOneWidget);
    });

    testWidgets('maxLength 显示字数统计', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(
        hintText: '限制长度',
        maxLength: 10,
      )));
      // 字数统计 0/10
      expect(find.text('0/10'), findsOneWidget);
    });
  });

  group('ParkInput - 状态', () {
    testWidgets('enabled=false 禁用状态', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(
        hintText: '禁用输入',
        enabled: false,
      )));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('readOnly 只读状态', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInput(
        hintText: '只读',
        readOnly: true,
      )));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
    });

    testWidgets('validator 校验失败显示错误', (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(_wrap(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(body: Form(
          key: key,
          child: ParkInput(
            hintText: '必填',
            validator: (v) => (v == null || v.isEmpty) ? '不能为空' : null,
            autovalidateMode: AutovalidateMode.always,
          ),
        )),
      )));
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('不能为空'), findsOneWidget);
    });
  });
}
