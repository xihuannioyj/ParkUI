import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: child));

void main() {
  group('ParkToast - Widget', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkToast(message: '提示信息')));
      expect(find.text('提示信息'), findsOneWidget);
    });
    testWidgets('带图标的Toast', (tester) async {
      await tester.pumpWidget(_wrap(ParkToast(
        message: '成功',
        icon: const Icon(Icons.check_circle, color: Colors.green),
      )));
      expect(find.text('成功'), findsOneWidget);
    });
    testWidgets('自定义背景色', (tester) async {
      await tester.pumpWidget(_wrap(const ParkToast(message: '自定义', bgColor: Colors.blue)));
      expect(find.text('自定义'), findsOneWidget);
    });
    testWidgets('不同位置', (tester) async {
      await tester.pumpWidget(_wrap(const ParkToast(message: '顶部', position: ParkToastPosition.top)));
      expect(find.text('顶部'), findsOneWidget);
    });
  });

  group('ParkToast - 静态方法', () {
    testWidgets('show 不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      // toast.show 通过 overlay 显示，需 build context
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.show(ctx, '测试Toast');
      await tester.pump();
      expect(find.text('测试Toast'), findsOneWidget);
    });
    testWidgets('success Toast', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.success(ctx, '操作成功');
      await tester.pump();
      expect(find.text('操作成功'), findsOneWidget);
    });
    testWidgets('error Toast', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.error(ctx, '操作失败');
      await tester.pump();
      expect(find.text('操作失败'), findsOneWidget);
    });
    testWidgets('warning Toast', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      final ctx = tester.element(find.byType(SizedBox));
      ParkToast.warning(ctx, '请注意');
      await tester.pump();
      expect(find.text('请注意'), findsOneWidget);
    });
  });
}
