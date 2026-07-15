import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

const _selectItems = <ParkSelectOption>[
  ParkSelectOption(label: '北京', value: 'bj'),
  ParkSelectOption(label: '上海', value: 'sh'),
];

void main() {
  group('ParkInputGroup - 紧凑容器 (P0-4)', () {
    testWidgets('单一圆角边框容器 + Clip.antiAlias', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputGroup(
        children: [
          ParkInput(hintText: '姓名', bordered: false),
          ParkSelect(items: _selectItems, hintText: '城市', bordered: false),
        ],
      )));
      final containers =
          tester.widgetList<Container>(find.byType(Container));
      final outer = containers.where((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.border != null &&
            d.borderRadius != null &&
            c.clipBehavior == Clip.antiAlias;
      }).toList();
      expect(outer, isNotEmpty,
          reason: '未找到带边框+圆角+裁剪的外层 Container');
      // medium 默认组高应为 48（外层 Container 设置了固定 height）
      final outerSize = tester.getSize(find.byWidget(outer.first));
      // 外层高度 = _groupHeight(48) + 上下边框(2) = 50
      expect(outerSize.height, 50.0);
    });

    testWidgets('相邻子项间 1px 分隔线', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputGroup(
        children: [
          ParkInput(hintText: 'A', bordered: false),
          ParkButton(
            variant: ParkButtonVariant.primary,
            child: Text('B'),
          ),
        ],
      )));
      // 分隔线是宽度恰为 1.0 的 Container（Container 无 .width getter，需取渲染尺寸）
      final dividerContainers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => tester.getSize(find.byWidget(c)).width == 1.0)
          .toList();
      // 2 个子项 -> 1 条分隔线
      expect(dividerContainers.length, 1);
    });

    testWidgets('组高随 size 变化 34/50/58', (tester) async {
      // 使用轻量 Text 子项避免 ParkInput 内部列约束干扰组容器高度检测。
      final cases = [
        // B60 修复：外层高度 = _groupHeight + 上下边框(2)，移除多余留空
        (ParkInputSize.small, 34.0),
        (ParkInputSize.medium, 50.0),
        (ParkInputSize.large, 58.0),
      ];
      for (final (size, expected) in cases) {
        await tester.pumpWidget(_wrap(ParkInputGroup(
          size: size,
          children: [const Text('x')],
        )));
        final containers =
            tester.widgetList<Container>(find.byType(Container));
        final outer = containers.where((c) {
          final d = c.decoration;
          return d is BoxDecoration &&
              d.border != null &&
              d.borderRadius != null;
        }).toList();
        expect(outer, isNotEmpty);
        final outerSize = tester.getSize(find.byWidget(outer.first));
        expect(outerSize.height, expected);
      }
    });

    testWidgets('ParkButton 经 height 覆盖与组严格等高', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputGroup(
        size: ParkInputSize.medium,
        children: [
          ParkInput(hintText: '关键词', bordered: false),
          ParkButton(height: 48, child: Text('搜索')),
        ],
      )));
      final btnSize = tester.getSize(find.byType(ParkButton));
      // 按钮放置在 Expanded+stretch 行内，会被拉伸至组容器内容区高度 50-2=48
      expect(btnSize.height, closeTo(48.0, 0.5));
    });

    testWidgets('disabled 边框置灰', (tester) async {
      await tester.pumpWidget(_wrap(ParkInputGroup(
        disabled: true,
        children: [ParkInput(hintText: 'x', bordered: false)],
      )));
      final colors = ParkThemeData.light().colors;
      final containers =
          tester.widgetList<Container>(find.byType(Container));
      final outer = containers.where((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.border != null &&
            d.borderRadius != null;
      }).toList();
      expect(outer, isNotEmpty);
      final border = (outer.first.decoration! as BoxDecoration).border as Border;
      expect(border.top.color, colors.divider);
    });
  });
}
