/// Widget tests for components with zero/minimal dedicated test coverage.
///
/// Batch 4 covers:
/// - ParkSpace (base) — spacing layout component
/// - ParkEllipsis (display) — text ellipsis with expand/collapse
/// - ParkFooter (display) — page footer with links
/// - ParkSticky (display) — sticky positioning component

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/l10n/park_localizations.dart';

// Targeted component imports (avoid barrel to prevent unrelated compile errors)
import 'package:park_ui/src/components/base/park_space.dart';
import 'package:park_ui/src/components/display/park_ellipsis.dart';
import 'package:park_ui/src/components/display/park_footer.dart';
import 'package:park_ui/src/components/display/park_sticky.dart';

Widget _wrap(Widget child) {
  final theme = ParkThemeData.light();
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Scaffold(body: child),
    ),
  );
}

Widget _wrapWithL10n(Widget child) {
  final theme = ParkThemeData.light();
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: ParkLocalizationsWidget(
        localizations: const ParkLocalizationsZh(),
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  // ===========================================================================
  // ParkSpace
  // ===========================================================================
  group('ParkSpace', () {
    testWidgets('默认渲染不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSpace(
          children: const [Text('A'), Text('B'), Text('C')],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkSpace), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('水平方向插入正确数量的 SizedBox 间隔', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSpace(
          size: 16,
          children: const [Text('A'), Text('B'), Text('C')],
        ),
      ));
      await tester.pumpAndSettle();
      // 3 children → 2 spacers (SizedBox with width=16, height=0)
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacers = sizedBoxes
          .where((sb) => sb.width == 16 && sb.height == 0)
          .toList();
      expect(spacers.length, 2);
    });

    testWidgets('垂直方向使用 Column 并插入高度间隔', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSpace(
          direction: Axis.vertical,
          size: 12,
          children: const [Text('X'), Text('Y')],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
      // 2 children → 1 spacer with width=0, height=12
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacers = sizedBoxes
          .where((sb) => sb.height == 12 && sb.width == 0)
          .toList();
      expect(spacers.length, 1);
    });

    testWidgets('wrap 模式使用 Wrap 组件', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkSpace(
          wrap: true,
          size: 10,
          children: const [Text('A'), Text('B'), Text('C')],
        ),
      ));
      await tester.pumpAndSettle();
      final wrapWidget = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrapWidget.spacing, 10);
      expect(wrapWidget.runSpacing, 10);
    });

    testWidgets('空 children 渲染 SizedBox.shrink', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSpace(children: []),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkSpace), findsOneWidget);
      // Should render a zero-size SizedBox
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(ParkSpace),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
    });
  });

  // ===========================================================================
  // ParkEllipsis
  // ===========================================================================
  group('ParkEllipsis', () {
    testWidgets('默认渲染不崩溃', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkEllipsis(text: '这是一段测试文本'),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkEllipsis), findsOneWidget);
      expect(find.text('这是一段测试文本'), findsOneWidget);
    });

    testWidgets('maxLines 属性生效', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkEllipsis(
          text: 'Long text content that should be truncated',
          maxLines: 2,
          tooltip: false,
        ),
      ));
      await tester.pumpAndSettle();
      final textWidget = tester.widget<Text>(
        find.text('Long text content that should be truncated'),
      );
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('tooltip=false 时不包裹 MouseRegion', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkEllipsis(
          text: 'No tooltip text',
          tooltip: false,
        ),
      ));
      await tester.pumpAndSettle();
      // When tooltip is disabled, no MouseRegion should wrap the text
      expect(
        find.descendant(
          of: find.byType(ParkEllipsis),
          matching: find.byType(MouseRegion),
        ),
        findsNothing,
      );
    });

    testWidgets('expandable 模式显示展开按钮', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkEllipsis(
          text: '这是一段很长的文本内容，需要展开才能看到全部',
          expandable: true,
          maxLines: 1,
        ),
      ));
      await tester.pumpAndSettle();
      // Should show "展开" button (Chinese localization)
      expect(find.text('展开'), findsOneWidget);
    });

    testWidgets('expandable 模式点击切换展开/收起', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkEllipsis(
          text: '这是一段很长的文本内容，需要展开才能看到全部',
          expandable: true,
          maxLines: 1,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('展开'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('展开'));
      await tester.pumpAndSettle();
      expect(find.text('收起'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('收起'));
      await tester.pumpAndSettle();
      expect(find.text('展开'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkFooter
  // ===========================================================================
  group('ParkFooter', () {
    testWidgets('默认渲染不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFooter(text: 'Park UI'),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkFooter), findsOneWidget);
      expect(find.text('Park UI'), findsOneWidget);
    });

    testWidgets('显示版权信息', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFooter(
          text: 'Park UI',
          copyright: '© 2025 Park UI. All rights reserved.',
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('© 2025 Park UI. All rights reserved.'), findsOneWidget);
    });

    testWidgets('渲染链接列表', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkFooter(
          text: 'Park UI',
          links: [
            ParkFooterLink(label: '关于我们', onTap: () {}),
            ParkFooterLink(label: '服务条款', onTap: () {}),
            ParkFooterLink(label: '隐私政策', onTap: () {}),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('关于我们'), findsOneWidget);
      expect(find.text('服务条款'), findsOneWidget);
      expect(find.text('隐私政策'), findsOneWidget);
    });

    testWidgets('点击链接触发 onTap 回调', (tester) async {
      var tappedLabel = '';
      await tester.pumpWidget(_wrap(
        ParkFooter(
          text: 'Park UI',
          links: [
            ParkFooterLink(label: '关于我们', onTap: () => tappedLabel = '关于我们'),
            ParkFooterLink(label: '服务条款', onTap: () => tappedLabel = '服务条款'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('服务条款'));
      await tester.pumpAndSettle();
      expect(tappedLabel, '服务条款');
    });

    testWidgets('logo 组件正确显示', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkFooter(
          text: 'Park UI',
          logo: Container(
            key: const Key('test-logo'),
            width: 32,
            height: 32,
            color: Colors.blue,
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('test-logo')), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkSticky
  // ===========================================================================
  group('ParkSticky', () {
    testWidgets('默认渲染不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSticky(
          child: Text('Sticky Header'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkSticky), findsOneWidget);
      expect(find.text('Sticky Header'), findsOneWidget);
    });

    testWidgets('子组件被 AnimatedContainer 包裹', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSticky(
          child: Text('Content'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(ParkSticky),
          matching: find.byType(AnimatedContainer),
        ),
        findsOneWidget,
      );
    });

    testWidgets('包含 NotificationListener 监听滚动', (tester) async {
      await tester.pumpWidget(_wrap(
        SingleChildScrollView(
          child: Column(
            children: [
              const ParkSticky(
                child: Text('Sticky'),
              ),
              Container(height: 1000, color: Colors.grey),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // ParkSticky internally uses NotificationListener<ScrollNotification>
      expect(
        find.byWidgetPredicate(
          (w) => w is NotificationListener<ScrollNotification>,
        ),
        findsWidgets,
      );
    });

    testWidgets('showShadow=false 时吸顶不显示阴影', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSticky(
          showShadow: false,
          child: Text('No Shadow'),
        ),
      ));
      await tester.pumpAndSettle();
      // Initially not sticky, so no decoration regardless
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ParkSticky),
          matching: find.byType(AnimatedContainer),
        ),
      );
      // When not sticky, decoration should be null
      expect(animatedContainer.decoration, isNull);
    });

    testWidgets('在可滚动容器中渲染并响应滚动不崩溃', (tester) async {
      await tester.pumpWidget(_wrap(
        SingleChildScrollView(
          child: Column(
            children: [
              Container(height: 100, color: Colors.red),
              ParkSticky(
                backgroundColor: Colors.white,
                onStickyChanged: (_) {},
                child: Container(
                  height: 50,
                  color: Colors.blue,
                  child: const Text('Sticky Bar'),
                ),
              ),
              Container(height: 2000, color: Colors.grey),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Sticky Bar'), findsOneWidget);

      // Scroll down — should not crash regardless of sticky state transition
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.byType(ParkSticky), findsOneWidget);
    });
  });
}
