import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: child),
    );

void main() {
  group('ParkInlineLoading', () {
    testWidgets('默认构造渲染 ParkLoading 且不居中', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInlineLoading()));
      expect(find.byType(ParkInlineLoading), findsOneWidget);
      expect(find.byType(ParkLoading), findsOneWidget);
      final loading = tester.widget<ParkLoading>(find.byType(ParkLoading));
      expect(loading.size, 24);
      expect(loading.type, ParkLoadingType.circular);
      expect(
        find.ancestor(
          of: find.byType(ParkLoading),
          matching: find.byType(Center),
        ),
        findsNothing,
      );
    });

    testWidgets('page 构造使用白卡面板并展示默认文案', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInlineLoading.page()));
      expect(find.byType(ParkLoadingPanel), findsOneWidget);
      expect(find.text('加载中...'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(ParkLoadingPanel),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });

    testWidgets('page 构造支持自定义文案', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkInlineLoading.page(text: '数据加载中...'),
        ),
      );
      expect(find.text('数据加载中...'), findsOneWidget);
      final loading = tester.widget<ParkLoading>(
        find.descendant(
          of: find.byType(ParkLoadingPanel),
          matching: find.byType(ParkLoading),
        ),
      );
      expect(loading.size, 26);
      // 面板内的加载色始终使用主题品牌令牌。
      expect(
        loading.color,
        ParkThemeData.light().colors.brand,
      );
    });

    testWidgets('compact 构造为居中圆形加载', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInlineLoading.compact()));
      expect(find.byType(ParkLoadingPanel), findsNothing);
      final loading = tester.widget<ParkLoading>(find.byType(ParkLoading));
      expect(loading.size, 24);
      expect(
        find.ancestor(
          of: find.byType(ParkLoading),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });

    testWidgets('button 构造为小尺寸白色加载且不居中', (tester) async {
      await tester.pumpWidget(_wrap(const ParkInlineLoading.button()));
      final loading = tester.widget<ParkLoading>(find.byType(ParkLoading));
      expect(loading.size, 16);
      expect(loading.color, Colors.white);
      expect(
        find.ancestor(
          of: find.byType(ParkLoading),
          matching: find.byType(Center),
        ),
        findsNothing,
      );
    });
  });

  group('ParkLoadingPanel', () {
    testWidgets('默认带遮罩渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkLoadingPanel(text: '加载中...')),
      );
      expect(find.byType(ParkLoadingPanel), findsOneWidget);
      // 遮罩模式下存在 absorbing 的 AbsorbPointer（ParkLoading 内部的
      // 非 absorbing AbsorbPointer 不参与断言）。
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is AbsorbPointer && w.absorbing,
        ),
        findsOneWidget,
      );
      expect(find.byType(ParkLoading), findsOneWidget);
      expect(find.text('加载中...'), findsOneWidget);
      final loading = tester.widget<ParkLoading>(find.byType(ParkLoading));
      expect(loading.size, 26);
    });

    testWidgets('withMask 为 false 时不带遮罩但内部居中', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkLoadingPanel(text: '加载中...', withMask: false)),
      );
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is AbsorbPointer && w.absorbing,
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(ParkLoadingPanel),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });
  });
}
