import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

const _items = [
  ParkSelectOption(label: '北京', value: 'beijing'),
  ParkSelectOption(label: '上海', value: 'shanghai'),
  ParkSelectOption(label: '广州', value: 'guangzhou'),
];

void main() {
  group('ParkSelect - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: _items,
        hintText: '请选择城市',
      )));
      expect(find.text('请选择城市'), findsOneWidget);
    });

    testWidgets('显示 label', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: _items,
        label: '城市',
      )));
      expect(find.text('城市'), findsOneWidget);
    });

    testWidgets('显示已选值', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: _items,
        value: 'beijing',
      )));
      expect(find.text('北京'), findsOneWidget);
    });

    testWidgets('emptyText 空态', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: [],
        emptyText: '没有选项',
      )));
      expect(find.text('请选择'), findsOneWidget);
    });

    testWidgets('disabled 禁用状态', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: _items,
        enabled: false,
        hintText: '禁用选择',
      )));
      expect(find.text('禁用选择'), findsOneWidget);
    });
  });

  group('ParkSelect - 交互', () {
    testWidgets('点击弹出选项面板', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: _items,
        hintText: '请选择城市',
      )));
      await tester.tap(find.text('请选择城市'));
      await tester.pumpAndSettle();
      // 底部面板应出现选项
      expect(find.text('北京'), findsWidgets);
    });
  });

  group('ParkSelect - 多选', () {
    testWidgets('多选模式', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: _items,
        multiple: true,
        value: 'beijing,shanghai',
        hintText: '多选城市',
      )));
      // 应显示已选的 chip
      expect(find.text('北京'), findsOneWidget);
      expect(find.text('上海'), findsOneWidget);
    });
  });

  group('ParkSelect - 选项', () {
    testWidgets('disabled 选项', (tester) async {
      await tester.pumpWidget(_wrap(ParkSelect(
        items: [
          ..._items,
          const ParkSelectOption(label: '深圳', value: 'shenzhen', disabled: true),
        ],
      )));
      expect(find.byType(ParkSelect), findsOneWidget);
    });
  });
}
