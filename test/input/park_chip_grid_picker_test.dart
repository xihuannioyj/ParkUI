import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_chip_grid_picker.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkChipGridPicker', () {
    final categories = [
      const ParkChipGridCategory(label: '户型', children: [
        ParkChipGridOption(value: '1', label: '一室'),
        ParkChipGridOption(value: '2', label: '二室'),
        ParkChipGridOption(value: '3', label: '三室'),
      ]),
      const ParkChipGridCategory(label: '朝向', children: [
        ParkChipGridOption(value: 'south', label: '朝南'),
        ParkChipGridOption(value: 'north', label: '朝北'),
      ]),
    ];

    testWidgets('renders categories and options', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkChipGridPicker(
          categories: categories,
          onChanged: (_) {},
        ),
      ));
      // Category tabs
      expect(find.text('户型'), findsOneWidget);
      expect(find.text('朝向'), findsOneWidget);
      // First category options visible
      expect(find.text('一室'), findsOneWidget);
      expect(find.text('二室'), findsOneWidget);
      expect(find.text('三室'), findsOneWidget);
    });

    testWidgets('selects option on tap, calls onChanged', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(_wrap(
        ParkChipGridPicker(
          categories: categories,
          onChanged: (v) => result = v,
        ),
      ));
      await tester.tap(find.text('一室'));
      expect(result, contains('1'));
    });

    testWidgets('multiSelect allows multiple selections', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(_wrap(
        ParkChipGridPicker(
          categories: categories,
          multiSelect: true,
          selectedValues: const {'1'},
          onChanged: (v) => result = v,
        ),
      ));
      await tester.tap(find.text('二室'));
      expect(result, containsAll(['1', '2']));
    });

    testWidgets('single select replaces previous', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(_wrap(
        ParkChipGridPicker(
          categories: categories,
          multiSelect: false,
          selectedValues: const {'1'},
          onChanged: (v) => result = v,
        ),
      ));
      await tester.tap(find.text('二室'));
      expect(result, equals({'2'}));
    });

    testWidgets('disabled options cannot be selected', (tester) async {
      final disabledCategories = [
        const ParkChipGridCategory(label: '户型', children: [
          ParkChipGridOption(value: '1', label: '一室'),
          ParkChipGridOption(value: '2', label: '二室', enabled: false),
        ]),
      ];
      Set<String>? result;
      await tester.pumpWidget(_wrap(
        ParkChipGridPicker(
          categories: disabledCategories,
          onChanged: (v) => result = v,
        ),
      ));
      await tester.tap(find.text('二室'));
      expect(result, isNull);
    });

    testWidgets('switching category updates grid', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkChipGridPicker(
          categories: categories,
          onChanged: (_) {},
        ),
      ));
      // Initially first category options shown
      expect(find.text('一室'), findsOneWidget);
      expect(find.text('朝南'), findsNothing);

      // Tap second category
      await tester.tap(find.text('朝向'));
      await tester.pumpAndSettle();

      // Now second category options shown
      expect(find.text('朝南'), findsOneWidget);
      expect(find.text('朝北'), findsOneWidget);
      expect(find.text('一室'), findsNothing);
    });
  });
}
