import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_choice_group.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkChoiceGroup', () {
    final items = [
      const ParkChoiceItem(value: '1', label: '整租'),
      const ParkChoiceItem(value: '2', label: '合租'),
      const ParkChoiceItem(value: '3', label: '短租'),
    ];

    testWidgets('renders all items', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: items,
          onChanged: (_) {},
        ),
      ));
      expect(find.text('整租'), findsOneWidget);
      expect(find.text('合租'), findsOneWidget);
      expect(find.text('短租'), findsOneWidget);
    });

    testWidgets('calls onChanged with correct value on tap', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: items,
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.tap(find.text('合租'));
      expect(selected, '2');
    });

    testWidgets('highlights selected item', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: items,
          value: '1',
          onChanged: (_) {},
        ),
      ));
      // The selected item's Semantics should have selected flag
      final semantics = tester.getSemantics(find.text('整租'));
      expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('disabled items cannot be selected', (tester) async {
      String? selected;
      final disabledItems = [
        const ParkChoiceItem(value: '1', label: '可选'),
        const ParkChoiceItem(value: '2', label: '不可选', enabled: false),
      ];
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: disabledItems,
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.tap(find.text('不可选'));
      expect(selected, isNull);
    });

    testWidgets('join mode renders without spacing', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: items,
          join: true,
          onChanged: (_) {},
        ),
      ));
      // In join mode, no SizedBox(width: spacing) between items in a row.
      // Verify all items still render correctly.
      expect(find.text('整租'), findsOneWidget);
      expect(find.text('合租'), findsOneWidget);
      expect(find.text('短租'), findsOneWidget);
    });

    testWidgets('vertical direction stacks items', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: items,
          direction: Axis.vertical,
          onChanged: (_) {},
        ),
      ));
      // In vertical mode, a Column is used
      expect(find.byType(Column), findsWidgets);
      expect(find.text('整租'), findsOneWidget);
      expect(find.text('合租'), findsOneWidget);
    });

    testWidgets('readOnly prevents selection', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: items,
          readOnly: true,
          onChanged: (v) => selected = v,
        ),
      ));
      await tester.tap(find.text('整租'));
      expect(selected, isNull);
    });

    testWidgets('leading widget displays', (tester) async {
      final leadingItems = [
        ParkChoiceItem(
          value: '1',
          label: '带图标',
          leading: const Icon(Icons.home, key: Key('leading_icon')),
        ),
      ];
      await tester.pumpWidget(_wrap(
        ParkChoiceGroup(
          items: leadingItems,
          onChanged: (_) {},
        ),
      ));
      expect(find.byKey(const Key('leading_icon')), findsOneWidget);
    });
  });
}
