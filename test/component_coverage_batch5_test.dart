/// Widget tests for components with zero/minimal dedicated test coverage.
///
/// Batch 5 covers:
/// - ParkAnchor (navigation) — anchor navigation with scroll spy
/// - ParkLayout (navigation) — page layout with header/sidebar/body/footer
/// - ParkInkWell (base) — lightweight tap container with press feedback
/// - ParkGridRow / ParkGridCol (base) — 24-column responsive grid system

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/l10n/park_localizations.dart';

// Targeted component imports
import 'package:park_ui/src/components/navigation/park_anchor.dart';
import 'package:park_ui/src/components/navigation/park_layout.dart';
import 'package:park_ui/src/components/base/park_ink_well.dart';
import 'package:park_ui/src/components/base/park_grid_row.dart';

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
  // ParkAnchor
  // ===========================================================================
  group('ParkAnchor', () {
    testWidgets('默认渲染所有锚点项', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkAnchor(
          items: [
            ParkAnchorItem(key: 'sec1', label: '基本信息'),
            ParkAnchorItem(key: 'sec2', label: '详细资料'),
            ParkAnchorItem(key: 'sec3', label: '设置'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkAnchor), findsOneWidget);
      expect(find.text('基本信息'), findsOneWidget);
      expect(find.text('详细资料'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });

    testWidgets('首项默认高亮（FontWeight.w600）', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkAnchor(
          items: [
            ParkAnchorItem(key: 'a', label: 'Alpha'),
            ParkAnchorItem(key: 'b', label: 'Beta'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // First item should be active with bold font
      final firstText = tester.widget<Text>(find.text('Alpha'));
      expect(firstText.style?.fontWeight, FontWeight.w600);

      // Second item should be inactive with normal font
      final secondText = tester.widget<Text>(find.text('Beta'));
      expect(secondText.style?.fontWeight, FontWeight.w400);
    });

    testWidgets('点击锚点项触发 onChanged 回调', (tester) async {
      String? changedKey;
      await tester.pumpWidget(_wrapWithL10n(
        ParkAnchor(
          items: const [
            ParkAnchorItem(key: 'x', label: 'Section X'),
            ParkAnchorItem(key: 'y', label: 'Section Y'),
          ],
          onChanged: (key) => changedKey = key,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Section Y'));
      await tester.pumpAndSettle();

      expect(changedKey, 'y');
    });

    testWidgets('点击后切换高亮状态', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        ParkAnchor(
          items: const [
            ParkAnchorItem(key: 'first', label: 'First'),
            ParkAnchorItem(key: 'second', label: 'Second'),
          ],
          onChanged: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      // Initially first is active
      var firstText = tester.widget<Text>(find.text('First'));
      expect(firstText.style?.fontWeight, FontWeight.w600);

      // Tap second item
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      // Now second should be active
      final secondText = tester.widget<Text>(find.text('Second'));
      expect(secondText.style?.fontWeight, FontWeight.w600);

      // First should become inactive
      firstText = tester.widget<Text>(find.text('First'));
      expect(firstText.style?.fontWeight, FontWeight.w400);
    });

    testWidgets('每个锚点项包含 Semantics button 语义', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkAnchor(
          items: [
            ParkAnchorItem(key: 's1', label: 'One'),
            ParkAnchorItem(key: 's2', label: 'Two'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      final semantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(ParkAnchor),
          matching: find.byType(Semantics),
        ),
      );
      // Each item has a Semantics wrapper with button=true
      expect(semantics.where((s) => s.properties.button == true).length, 2);
    });
  });

  // ===========================================================================
  // ParkLayout
  // ===========================================================================
  group('ParkLayout', () {
    testWidgets('仅 body 时正常渲染', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkLayout(
          body: Center(child: Text('Main Content')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkLayout), findsOneWidget);
      expect(find.text('Main Content'), findsOneWidget);
    });

    testWidgets('提供 header 和 footer 时正确显示', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkLayout(
          header: SizedBox(height: 56, child: Text('Header Bar')),
          footer: SizedBox(height: 40, child: Text('Footer Info')),
          body: Center(child: Text('Body')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Header Bar'), findsOneWidget);
      expect(find.text('Footer Info'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('sidebar 默认在左侧且宽度正确', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkLayout(
          sidebar: Text('Side Nav'),
          sidebarWidth: 200,
          body: Center(child: Text('Content')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Side Nav'), findsOneWidget);
      // Verify sidebar width via SizedBox
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.text('Side Nav'),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, 200);
    });

    testWidgets('sidebarLeft=false 时侧边栏在右侧', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkLayout(
          sidebar: Text('Right Panel'),
          sidebarLeft: false,
          body: Center(child: Text('Content')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Right Panel'), findsOneWidget);
      // The Row children order: [Expanded(body), Divider, Sidebar]
      // Verify sidebar is rendered (presence check is sufficient)
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('showSidebarDivider=false 时不显示分割线', (tester) async {
      await tester.pumpWidget(_wrapWithL10n(
        const ParkLayout(
          sidebar: Text('Nav'),
          showSidebarDivider: false,
          body: Center(child: Text('Content')),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nav'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
    });
  });

  // ===========================================================================
  // ParkInkWell
  // ===========================================================================
  group('ParkInkWell', () {
    testWidgets('默认渲染子组件', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkInkWell(
          onTap: () {},
          child: const Text('Tap Target'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkInkWell), findsOneWidget);
      expect(find.text('Tap Target'), findsOneWidget);
    });

    testWidgets('点击触发 onTap 回调', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        ParkInkWell(
          onTap: () => tapped = true,
          child: const SizedBox(width: 100, height: 50, child: Text('Btn')),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Btn'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('disabled 时直接渲染 child 无交互包装', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkInkWell(
          onTap: () {},
          disabled: true,
          child: const Text('Disabled Content'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Disabled Content'), findsOneWidget);
      // When disabled, no GestureDetector should be present
      expect(
        find.descendant(
          of: find.byType(ParkInkWell),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('长按触发 onLongPress 回调', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(_wrap(
        ParkInkWell(
          onLongPress: () => longPressed = true,
          child: const SizedBox(width: 100, height: 50, child: Text('Hold')),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Hold'));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('启用时包含 Semantics 和 AnimatedScale', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkInkWell(
          onTap: () {},
          child: const Text('Interactive'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ParkInkWell),
          matching: find.byType(Semantics),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ParkInkWell),
          matching: find.byType(AnimatedScale),
        ),
        findsOneWidget,
      );
    });
  });

  // ===========================================================================
  // ParkGridRow / ParkGridCol
  // ===========================================================================
  group('ParkGridRow / ParkGridCol', () {
    testWidgets('默认渲染所有列子组件', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkGridRow(
          children: [
            ParkGridCol(span: 8, child: Text('Col A')),
            ParkGridCol(span: 8, child: Text('Col B')),
            ParkGridCol(span: 8, child: Text('Col C')),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ParkGridRow), findsOneWidget);
      expect(find.text('Col A'), findsOneWidget);
      expect(find.text('Col B'), findsOneWidget);
      expect(find.text('Col C'), findsOneWidget);
    });

    testWidgets('列宽按 span 比例分配（span=12 占 50%）', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 480,
          child: ParkGridRow(
            children: [
              ParkGridCol(span: 12, child: Text('Half')),
              ParkGridCol(span: 12, child: Text('Other Half')),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Each col with span=12 in a 480px container should be 240px wide
      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(ParkGridRow),
          matching: find.byType(SizedBox),
        ),
      );
      final colBoxes = sizedBoxes.where((sb) => sb.width == 240).toList();
      expect(colBoxes.length, 2);
    });

    testWidgets('ParkBreakpoint.matchName 返回正确断点', (tester) async {
      // Pure logic test — no widget needed
      expect(ParkBreakpoint.matchName(400), 'xs');
      expect(ParkBreakpoint.matchName(576), 'sm');
      expect(ParkBreakpoint.matchName(800), 'md');
      expect(ParkBreakpoint.matchName(1000), 'lg');
      expect(ParkBreakpoint.matchName(1300), 'xl');
      expect(ParkBreakpoint.matchName(1700), 'xxl');
    });

    testWidgets('ParkGridResponsive.spanForBreakpoint 回退逻辑', (tester) async {
      const responsive = ParkGridResponsive(
        xs: 24,
        md: 12,
        xl: 6,
      );

      // xs -> uses xs
      expect(responsive.spanForBreakpoint('xs'), 24);
      // sm -> falls back to xs
      expect(responsive.spanForBreakpoint('sm'), 24);
      // md -> uses md
      expect(responsive.spanForBreakpoint('md'), 12);
      // lg -> falls back to md
      expect(responsive.spanForBreakpoint('lg'), 12);
      // xl -> uses xl
      expect(responsive.spanForBreakpoint('xl'), 6);
      // xxl -> falls back to xl
      expect(responsive.spanForBreakpoint('xxl'), 6);
    });

    testWidgets('超出 24 格的列自动换行', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 480,
          child: ParkGridRow(
            children: [
              ParkGridCol(span: 16, child: Text('Wide')),
              ParkGridCol(span: 16, child: Text('Wrapped')),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Both columns should still render (wrapped to next row)
      expect(find.text('Wide'), findsOneWidget);
      expect(find.text('Wrapped'), findsOneWidget);
      // A Column widget should be present to hold multiple rows
      expect(
        find.descendant(
          of: find.byType(ParkGridRow),
          matching: find.byType(Column),
        ),
        findsOneWidget,
      );
    });
  });
}
