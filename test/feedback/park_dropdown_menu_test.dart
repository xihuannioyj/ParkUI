import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_dropdown_menu.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(
        body: Center(child: child),
      ),
    );

void main() {
  group('ParkDropdownMenu - basic rendering', () {
    testWidgets('creates with trigger', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDropdownMenu(
          trigger: const Text('Open Menu'),
          items: const [
            ParkDropdownMenuItem(label: 'Item 1', value: '1'),
            ParkDropdownMenuItem(label: 'Item 2', value: '2'),
          ],
        ),
      ));
      expect(find.text('Open Menu'), findsOneWidget);
      // Items should not be visible initially
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('tapping trigger shows dropdown items', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDropdownMenu(
          trigger: const Text('Open'),
          items: const [
            ParkDropdownMenuItem(label: 'Apple', value: 'apple'),
            ParkDropdownMenuItem(label: 'Banana', value: 'banana'),
          ],
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
    });
  });

  group('ParkDropdownMenu - interaction', () {
    testWidgets('selecting an item triggers onSelected', (tester) async {
      String? selectedValue;
      await tester.pumpWidget(_wrap(
        ParkDropdownMenu(
          trigger: const Text('Select'),
          items: const [
            ParkDropdownMenuItem(label: 'Option A', value: 'a'),
            ParkDropdownMenuItem(label: 'Option B', value: 'b'),
          ],
          onSelected: (item) => selectedValue = item.value,
        ),
      ));
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();
      expect(selectedValue, 'b');
    });

    testWidgets('disabled item does not trigger onSelected', (tester) async {
      String? selectedValue;
      await tester.pumpWidget(_wrap(
        ParkDropdownMenu(
          trigger: const Text('Select'),
          items: const [
            ParkDropdownMenuItem(label: 'Disabled', value: 'd', disabled: true),
          ],
          onSelected: (item) => selectedValue = item.value,
        ),
      ));
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      expect(selectedValue, isNull);
    });
  });

  group('ParkDropdownMenu - features', () {
    testWidgets('renders with icon in menu items', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDropdownMenu(
          trigger: const Text('Menu'),
          items: const [
            ParkDropdownMenuItem(label: 'Edit', value: 'edit', icon: Icon(Icons.edit)),
          ],
        ),
      ));
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('direction up renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDropdownMenu(
          trigger: const Text('Up Menu'),
          direction: ParkDropdownDirection.up,
          items: const [
            ParkDropdownMenuItem(label: 'Item', value: 'i'),
          ],
        ),
      ));
      expect(find.byType(ParkDropdownMenu), findsOneWidget);
    });
  });

  group('ParkDropdownMenu - enums', () {
    test('ParkDropdownDirection has 2 values', () {
      expect(ParkDropdownDirection.values.length, 2);
    });

    test('ParkDropdownPlacement has 4 values', () {
      expect(ParkDropdownPlacement.values.length, 4);
    });
  });
}
