import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/navigation/park_menu.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: SizedBox(width: 240, child: child)),
    );

void main() {
  group('ParkMenu - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'home', label: 'Home'),
            ParkMenuItem(key: 'settings', label: 'Settings'),
          ],
        ),
      ));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders icons when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'dash', label: 'Dashboard', icon: Icons.dashboard),
            ParkMenuItem(key: 'user', label: 'Users', icon: Icons.people),
          ],
        ),
      ));
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('selectedKey highlights the correct item', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'a', label: 'Item A'),
            ParkMenuItem(key: 'b', label: 'Item B'),
          ],
          selectedKey: 'b',
        ),
      ));
      final textB = tester.widget<Text>(find.text('Item B'));
      expect(textB.style?.fontWeight, FontWeight.w600);
    });
  });

  group('ParkMenu - interaction', () {
    testWidgets('tapping a leaf item triggers onSelect', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'home', label: 'Home'),
            ParkMenuItem(key: 'about', label: 'About'),
          ],
          onSelect: (key) => selected = key,
        ),
      ));
      await tester.tap(find.text('About'));
      await tester.pump();
      expect(selected, 'about');
    });

    testWidgets('tapping a parent item expands children', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'parent', label: 'Parent', children: [
              ParkMenuItem(key: 'child1', label: 'Child 1'),
              ParkMenuItem(key: 'child2', label: 'Child 2'),
            ]),
          ],
        ),
      ));
      // Children should not be visible initially
      expect(find.text('Child 1'), findsNothing);

      // Tap parent to expand
      await tester.tap(find.text('Parent'));
      await tester.pump();
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('tapping parent again collapses children', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'parent', label: 'Parent', children: [
              ParkMenuItem(key: 'child', label: 'Child'),
            ]),
          ],
        ),
      ));
      await tester.tap(find.text('Parent'));
      await tester.pump();
      expect(find.text('Child'), findsOneWidget);

      await tester.tap(find.text('Parent'));
      await tester.pump();
      expect(find.text('Child'), findsNothing);
    });

    testWidgets('defaultExpandedKeys shows children initially', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'parent', label: 'Parent', children: [
              ParkMenuItem(key: 'child', label: 'Child'),
            ]),
          ],
          defaultExpandedKeys: {'parent'},
        ),
      ));
      expect(find.text('Child'), findsOneWidget);
    });
  });

  group('ParkMenu - disabled & theme', () {
    testWidgets('disabled item does not trigger onSelect', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'disabled', label: 'Disabled', disabled: true),
          ],
          onSelect: (key) => selected = key,
        ),
      ));
      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(selected, isNull);
    });

    testWidgets('dark theme mode renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkMenu(
          items: const [
            ParkMenuItem(key: 'a', label: 'Item A'),
          ],
          themeMode: ParkMenuThemeMode.dark,
        ),
      ));
      expect(find.text('Item A'), findsOneWidget);
    });
  });

  group('ParkMenu - enums', () {
    test('ParkMenuMode has 3 values', () {
      expect(ParkMenuMode.values.length, 3);
    });

    test('ParkMenuThemeMode has light and dark', () {
      expect(ParkMenuThemeMode.values.length, 2);
    });
  });

  group('ParkMenu - size', () {
    testWidgets('renders with all three sizes', (tester) async {
      for (final size in ParkMenuSize.values) {
        await tester.pumpWidget(_wrap(
          ParkMenu(
            items: const [
              ParkMenuItem(key: 'a', label: 'Item A', icon: Icons.home),
            ],
            size: size,
          ),
        ));
        expect(find.text('Item A'), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
