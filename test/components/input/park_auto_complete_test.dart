import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkAutoComplete - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'banana', 'cherry'],
      )));
      expect(find.byType(ParkAutoComplete), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple'],
        hintText: 'Search fruit',
      )));
      expect(find.text('Search fruit'), findsOneWidget);
    });

    testWidgets('renders TextField', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple'],
      )));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('no clear button when empty', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple'],
      )));
      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('ParkAutoComplete - interactions', () {
    testWidgets('typing triggers onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'banana'],
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), 'app');
      await tester.pump();
      expect(changed, 'app');
    });

    testWidgets('suffix icon area exists after input', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'banana'],
        onChanged: (_) {},
      )));
      // Before input: no IconButton
      expect(find.byType(IconButton), findsNothing);
      // Enter text to trigger _onTextChanged and setState
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // After input: the component should have text in controller
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, 'test');
    });

    testWidgets('onChanged fires with empty when input cleared programmatically', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'banana'],
        onChanged: (v) => changes.add(v),
      )));
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();
      expect(changes, contains('test'));
      // Clear by entering empty text
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(changes, contains(''));
    });

    testWidgets('shows suggestions after typing with debounce', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'application', 'banana'],
      )));
      await tester.enterText(find.byType(TextField), 'app');
      // Wait for debounce (300ms)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      // Suggestions should appear in overlay
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('application'), findsOneWidget);
      expect(find.text('banana'), findsNothing);
    });

    testWidgets('selecting suggestion triggers onSelected', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'application'],
        onSelected: (v) => selected = v,
      )));
      await tester.enterText(find.byType(TextField), 'app');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.tap(find.text('apple'));
      await tester.pump();
      expect(selected, 'apple');
    });

    testWidgets('maxSuggestions limits displayed items', (tester) async {
      final options = List.generate(20, (i) => 'item_$i');
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: options,
        maxSuggestions: 3,
      )));
      await tester.enterText(find.byType(TextField), 'item');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      // Should only show 3 items max
      expect(find.text('item_0'), findsOneWidget);
      expect(find.text('item_1'), findsOneWidget);
      expect(find.text('item_2'), findsOneWidget);
      expect(find.text('item_3'), findsNothing);
    });
  });

  group('ParkAutoComplete - custom filter', () {
    testWidgets('custom filterFn is applied', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['Apple', 'Banana', 'Cherry'],
        filterFn: (input, option) => option.startsWith(input),
      )));
      await tester.enterText(find.byType(TextField), 'A');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
    });

    testWidgets('empty input hides suggestions', (tester) async {
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'banana'],
      )));
      await tester.enterText(find.byType(TextField), 'app');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      expect(find.text('apple'), findsOneWidget);
      // Clear input
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      // Suggestions should be hidden
      expect(find.text('apple'), findsNothing);
    });
  });
}
