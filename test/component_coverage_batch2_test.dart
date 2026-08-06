import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/components/input/park_segmented.dart';
import 'package:park_ui/src/components/base/park_divider.dart';
import 'package:park_ui/src/components/base/park_app.dart';
import 'package:park_ui/src/components/base/park_float_button.dart';
import 'package:park_ui/src/components/display/park_grid.dart';
import 'package:park_ui/src/components/base/park_flex.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/components/navigation/park_bottom_nav.dart';
import 'package:park_ui/src/components/feedback/park_sheet_scaffold.dart';
import 'package:park_ui/src/components/navigation/park_indexes.dart';
import 'package:park_ui/src/components/display/park_swiper.dart';
import 'package:park_ui/src/components/display/park_watermark.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

/// Standard wrapper: MaterialApp + Scaffold + ParkThemeData.light() extension.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Wrapper that provides a Stack (needed by ParkFloatButton which uses Positioned).
Widget _wrapStack(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Stack(children: [child])),
  );
}

void main() {
  // ===========================================================================
  // 1. ParkSegmented
  // ===========================================================================
  group('ParkSegmented', () {
    testWidgets('smoke: builds without crashing', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSegmented(
          items: [
            ParkSegmentedItem(value: 'day', label: 'Day'),
            ParkSegmentedItem(value: 'week', label: 'Week'),
            ParkSegmentedItem(value: 'month', label: 'Month'),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkSegmented), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      // CR60-08: verify ParkSegmented widget items property
      final segmented = tester.widget<ParkSegmented>(find.byType(ParkSegmented));
      expect(segmented.items.length, 3);
      expect(segmented.items[0].value, 'day');
      expect(segmented.items[2].label, 'Month');
    });

    testWidgets('interaction: tapping item triggers onChanged', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkSegmented(
          items: const [
            ParkSegmentedItem(value: 'a', label: 'A'),
            ParkSegmentedItem(value: 'b', label: 'B'),
          ],
          value: 'a',
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
    });
  });

  // ===========================================================================
  // 2. ParkDivider
  // ===========================================================================
  group('ParkDivider', () {
    testWidgets('smoke: horizontal divider builds', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox(
        width: 200,
        child: ParkDivider(),
      )));
      expect(find.byType(ParkDivider), findsOneWidget);
    });

    testWidgets('feature: withText renders text and vertical axis works',
        (tester) async {
      await tester.pumpWidget(_wrap(Column(
        children: [
          ParkDivider.withText('OR'),
          const ParkDivider(axis: ParkDividerAxis.vertical, verticalHeight: 24),
        ],
      )));
      expect(find.text('OR'), findsOneWidget);
      expect(find.byType(ParkDivider), findsOneWidget);
    });
  });

  // ===========================================================================
  // 3. ParkApp
  // ===========================================================================
  group('ParkApp', () {
    testWidgets('smoke: builds as global config wrapper', (tester) async {
      await tester.pumpWidget(
        ParkApp(
          title: 'Test App',
          parkTheme: ParkThemeData.light(),
          home: const Scaffold(body: Text('Hello ParkApp')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello ParkApp'), findsOneWidget);
    });

    testWidgets('feature: injects ParkConfigProvider into tree', (tester) async {
      ParkThemeData? resolved;
      await tester.pumpWidget(
        ParkApp(
          parkTheme: ParkThemeData.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                resolved = ParkConfigProvider.maybeOf(context);
                return const Text('check');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(resolved, isNotNull);
    });
  });

  // ===========================================================================
  // 4. ParkFloatButton
  // ===========================================================================
  group('ParkFloatButton', () {
    testWidgets('smoke: single button builds', (tester) async {
      await tester.pumpWidget(_wrapStack(
        ParkFloatButton(
          icon: Icons.add,
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkFloatButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      // CR60-08: verify ParkFloatButton widget and Icon properties
      final fab = tester.widget<ParkFloatButton>(find.byType(ParkFloatButton));
      expect(fab.icon, Icons.add);
      expect(fab.onPressed, isNotNull);
      final icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon.icon, Icons.add);
    });

    testWidgets('interaction: tap triggers onPressed', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrapStack(
        ParkFloatButton(
          icon: Icons.add,
          onPressed: () => pressed = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });

  // ===========================================================================
  // 5. ParkGrid
  // ===========================================================================
  group('ParkGrid', () {
    testWidgets('smoke: builds with items', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkGrid(
          columnCount: 3,
          items: [
            ParkGridItem(label: 'A'),
            ParkGridItem(label: 'B'),
            ParkGridItem(label: 'C'),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkGrid), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      // CR60-08: verify ParkGrid widget properties
      final grid = tester.widget<ParkGrid>(find.byType(ParkGrid));
      expect(grid.columnCount, 3);
      expect(grid.items.length, 3);
      expect(grid.items[0].label, 'A');
    });

    testWidgets('interaction: onTap fires with correct index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(_wrap(
        ParkGrid(
          columnCount: 2,
          onTap: (i) => tappedIndex = i,
          items: const [
            ParkGridItem(label: 'Item0'),
            ParkGridItem(label: 'Item1'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Item1'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);
    });
  });

  // ===========================================================================
  // 6. ParkFlex
  // ===========================================================================
  group('ParkFlex', () {
    testWidgets('smoke: row layout builds', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFlex(
          direction: ParkFlexDirection.row,
          gap: 8,
          children: [
            Text('Left'),
            Text('Right'),
          ],
        ),
      ));
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('feature: wrap mode and column direction', (tester) async {
      await tester.pumpWidget(_wrap(
        const Column(
          children: [
            ParkFlex(
              direction: ParkFlexDirection.column,
              gap: 4,
              children: [Text('Top'), Text('Bottom')],
            ),
            ParkFlex(
              wrap: true,
              gap: 4,
              children: [Text('W1'), Text('W2'), Text('W3')],
            ),
          ],
        ),
      ));
      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
      expect(find.text('W1'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  // ===========================================================================
  // 7. ParkConfigProvider
  // ===========================================================================
  group('ParkConfigProvider', () {
    testWidgets('smoke: provides theme to descendants', (tester) async {
      ParkThemeData? theme;
      await tester.pumpWidget(
        MaterialApp(
          home: ParkConfigProvider(
            theme: ParkThemeData.light(),
            child: Builder(
              builder: (context) {
                theme = ParkConfigProvider.of(context);
                return const Text('child');
              },
            ),
          ),
        ),
      );
      expect(find.text('child'), findsOneWidget);
      expect(theme, isNotNull);
    });

    testWidgets('feature: maybeOf returns null when absent', (tester) async {
      ParkThemeData? theme;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              theme = ParkConfigProvider.maybeOf(context);
              return const Text('no provider');
            },
          ),
        ),
      );
      expect(find.text('no provider'), findsOneWidget);
      expect(theme, isNull);
    });
  });

  // ===========================================================================
  // 8. ParkBottomNav
  // ===========================================================================
  group('ParkBottomNav', () {
    testWidgets('smoke: builds with items', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (_) {},
          items: const [
            ParkBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
            ParkBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
            ParkBottomNavItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkBottomNav), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      // CR60-08: verify ParkBottomNav widget properties
      final nav = tester.widget<ParkBottomNav>(find.byType(ParkBottomNav));
      expect(nav.currentIndex, 0);
      expect(nav.items.length, 3);
      expect(nav.items[0].label, 'Home');
      expect(nav.items[2].label, 'Profile');
    });

    testWidgets('interaction: tapping item calls onTap with index',
        (tester) async {
      int? tapped;
      await tester.pumpWidget(_wrap(
        ParkBottomNav(
          currentIndex: 0,
          onTap: (i) => tapped = i,
          items: const [
            ParkBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
            ParkBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });
  });

  // ===========================================================================
  // 9. ParkSheetScaffold
  // ===========================================================================
  group('ParkSheetScaffold', () {
    testWidgets('smoke: builds with title and child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSheetScaffold(
          title: 'Select City',
          child: SizedBox(height: 100, child: Text('Body Content')),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Select City'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      // CR60-08: verify ParkSheetScaffold widget title property
      final scaffold = tester.widget<ParkSheetScaffold>(find.byType(ParkSheetScaffold));
      expect(scaffold.title, 'Select City');
    });

    testWidgets('interaction: confirm and cancel callbacks fire',
        (tester) async {
      bool confirmed = false;
      bool cancelled = false;
      await tester.pumpWidget(_wrap(
        ParkSheetScaffold(
          title: 'Test Sheet',
          cancelText: 'Cancel',
          confirmText: 'OK',
          onCancel: () => cancelled = true,
          onConfirm: () => confirmed = true,
          child: const SizedBox(height: 50),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(cancelled, isTrue);
    });
  });

  // ===========================================================================
  // 10. ParkIndexes
  // ===========================================================================
  group('ParkIndexes', () {
    testWidgets('smoke: builds index bar', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkIndexes(
          indexes: ['A', 'B', 'C', 'D'],
          showOverlay: false,
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkIndexes), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      // CR60-08: verify ParkIndexes widget properties
      final indexes = tester.widget<ParkIndexes>(find.byType(ParkIndexes));
      expect(indexes.indexes.length, 4);
      expect(indexes.indexes, contains('A'));
      expect(indexes.indexes, contains('D'));
      expect(indexes.showOverlay, isFalse);
    });

    testWidgets('interaction: tapping index fires onIndexSelected',
        (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkIndexes(
          indexes: const ['A', 'B', 'C'],
          showOverlay: false,
          onIndexSelected: (v) => selected = v,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(selected, 'B');
    });
  });

  // ===========================================================================
  // 11. ParkSwiper
  // ===========================================================================
  group('ParkSwiper', () {
    testWidgets('smoke: builds with children and indicator', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkSwiper(
          height: 150,
          children: [
            ColoredBox(color: Colors.red),
            ColoredBox(color: Colors.blue),
            ColoredBox(color: Colors.green),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkSwiper), findsOneWidget);
      // CR60-08: verify ParkSwiper widget properties
      final swiper = tester.widget<ParkSwiper>(find.byType(ParkSwiper));
      expect(swiper.height, 150);
      expect(swiper.children.length, 3);
    });

    testWidgets('interaction: swipe changes page and fires onPageChanged',
        (tester) async {
      int? changedTo;
      await tester.pumpWidget(_wrap(
        ParkSwiper(
          height: 150,
          loop: false,
          onPageChanged: (i) => changedTo = i,
          children: const [
            ColoredBox(color: Colors.red),
            ColoredBox(color: Colors.blue),
            ColoredBox(color: Colors.green),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // Fling left to go to next page (velocity ensures page change)
      await tester.fling(find.byType(ParkSwiper), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(changedTo, 1);
    });
  });

  // ===========================================================================
  // 12. ParkWatermark
  // ===========================================================================
  group('ParkWatermark', () {
    testWidgets('smoke: text watermark builds over child', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkWatermark(
          text: 'Confidential',
          child: SizedBox(width: 200, height: 200, child: Text('Content')),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ParkWatermark), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      // CR60-08: verify ParkWatermark widget text property
      final watermark = tester.widget<ParkWatermark>(find.byType(ParkWatermark));
      expect(watermark.text, 'Confidential');
    });

    testWidgets('feature: renders CustomPaint overlay for text watermark',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkWatermark(
          text: 'Secret',
          fontSize: 16,
          rotate: -30,
          gapX: 80,
          gapY: 60,
          child: SizedBox(width: 200, height: 200, child: Text('Data')),
        ),
      ));
      await tester.pumpAndSettle();
      // The watermark uses CustomPaint to render tiled text
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Data'), findsOneWidget);
    });
  });
}
