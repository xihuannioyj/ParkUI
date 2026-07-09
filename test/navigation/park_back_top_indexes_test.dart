import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ParkBackTop', () {
    testWidgets('滚动越过阈值后显示，回到顶部后隐藏', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();

      await tester.pumpWidget(
        _buildApp(_BackTopHarness(controller: controller, visibleOffset: 80)),
      );

      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);

      controller.jumpTo(120);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

      controller.jumpTo(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
    });

    testWidgets('滚动控制器失去挂载后应隐藏按钮', (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      final ValueNotifier<bool> showScrollable = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        _buildApp(
          ValueListenableBuilder<bool>(
            valueListenable: showScrollable,
            builder: (BuildContext context, bool visible, _) {
              return _BackTopHarness(
                controller: controller,
                visibleOffset: 80,
                showScrollable: visible,
              );
            },
          ),
        ),
      );

      controller.jumpTo(140);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

      showScrollable.value = false;
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('ParkIndexes', () {
    testWidgets('拖拽超出顶部或底部时应命中边界索引', (WidgetTester tester) async {
      final List<String> selected = <String>[];

      await tester.pumpWidget(
        _buildApp(
          Center(
            child: ParkIndexes(
              indexes: const <String>['A', 'B', 'C'],
              itemHeight: 20,
              showOverlay: false,
              onIndexSelected: selected.add,
            ),
          ),
        ),
      );

      final Finder finder = find.byType(ParkIndexes);
      final Offset topLeft = tester.getTopLeft(finder);
      final Size size = tester.getSize(finder);
      final double centerX = topLeft.dx + size.width / 2;

      final TestGesture gesture = await tester.startGesture(
        Offset(centerX, topLeft.dy + size.height / 2),
      );
      await tester.pump();

      await gesture.moveTo(Offset(centerX, topLeft.dy - 24));
      await tester.pump();

      await gesture.moveTo(Offset(centerX, topLeft.dy + size.height + 24));
      await tester.pump();

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(selected, isNotEmpty);
      expect(selected.contains('A'), isTrue);
      expect(selected.last, 'C');
    });

    testWidgets('连续选择时 overlay 应保留最新一次直到其生命周期结束', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          const Center(
            child: ParkIndexes(indexes: <String>['A', 'B'], itemHeight: 24),
          ),
        ),
      );

      await tester.tap(find.text('A'));
      await tester.pump();
      expect(find.byType(Overlay), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('park-indexes-overlay')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('B'));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('B'), findsWidgets);
      expect(find.byKey(const ValueKey<String>('park-indexes-overlay')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('B'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('park-indexes-overlay')), findsNothing);
    });
  });
}

class _BackTopHarness extends StatelessWidget {
  const _BackTopHarness({
    required this.controller,
    required this.visibleOffset,
    this.showScrollable = true,
  });

  final ScrollController controller;
  final double visibleOffset;
  final bool showScrollable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        if (showScrollable)
          ListView.builder(
            controller: controller,
            itemCount: 40,
            itemExtent: 40,
            itemBuilder: (BuildContext context, int index) {
              return Text('item-$index');
            },
          ),
        ParkBackTop(scrollController: controller, visibleOffset: visibleOffset),
      ],
    );
  }
}
