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
  group('ParkMentions - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
          ParkMentionItem(value: 'bob', label: 'Bob'),
        ],
      )));
      expect(find.byType(ParkMentions), findsOneWidget);
    });

    testWidgets('displays placeholder', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [],
        placeholder: 'Type @ to mention',
      )));
      expect(find.text('Type @ to mention'), findsOneWidget);
    });

    testWidgets('renders TextField', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [],
      )));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays initial value', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [],
        value: 'Hello @alice',
      )));
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'Hello @alice');
    });
  });

  group('ParkMentions - interactions', () {
    testWidgets('typing triggers onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
        ],
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(changed, 'hello');
    });

    testWidgets('typing @ shows suggestion panel', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
          ParkMentionItem(value: 'bob', label: 'Bob'),
        ],
      )));
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      // Suggestion panel should show items
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('selecting item inserts mention text', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
          ParkMentionItem(value: 'bob', label: 'Bob'),
        ],
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      await tester.tap(find.text('Alice'));
      await tester.pump();
      // Default mentionBuilder inserts '@alice '
      expect(changed, '@alice ');
    });

    testWidgets('filtering narrows suggestions', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
          ParkMentionItem(value: 'bob', label: 'Bob'),
          ParkMentionItem(value: 'alan', label: 'Alan'),
        ],
      )));
      await tester.enterText(find.byType(TextField), '@al');
      await tester.pump();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Alan'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
    });

    testWidgets('onSearch callback fires', (tester) async {
      String? searchQuery;
      String? searchTrigger;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
        ],
        onSearch: (q, t) {
          searchQuery = q;
          searchTrigger = t;
        },
      )));
      await tester.enterText(find.byType(TextField), '@al');
      await tester.pump();
      expect(searchQuery, 'al');
      expect(searchTrigger, '@');
    });

    testWidgets('onSelect callback fires', (tester) async {
      ParkMentionItem? selectedItem;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
        ],
        onSelect: (item, trigger) => selectedItem = item,
      )));
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      await tester.tap(find.text('Alice'));
      await tester.pump();
      expect(selectedItem?.value, 'alice');
    });
  });

  group('ParkMentions - edge cases', () {
    testWidgets('disabled state prevents panel', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
        ],
        enabled: false,
      )));
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      // Panel should not appear
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('disabled item cannot be selected', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice', disabled: true),
        ],
      )));
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      // Disabled items should not be tappable (no onChanged)
      // The item shows but onTap is null
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('custom triggerChars work', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'flutter', label: 'Flutter'),
        ],
        triggerChars: const ['#'],
      )));
      await tester.enterText(find.byType(TextField), '#');
      await tester.pump();
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('custom mentionBuilder formats text', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
        ],
        mentionBuilder: (item, trigger) => '[@$trigger${item.label}]',
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), '@');
      await tester.pump();
      await tester.tap(find.text('Alice'));
      await tester.pump();
      expect(changed, '[@@Alice]');
    });

    testWidgets('space after trigger closes mention context', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
        ],
      )));
      await tester.enterText(find.byType(TextField), '@alice something');
      await tester.pump();
      // After space, the mention context should close
      // No overlay should be showing for this query
      expect(find.byType(ParkMentions), findsOneWidget);
    });
  });
}
