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
  group('ParkCascader - basic rendering', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [],
      )));
      expect(find.byType(ParkCascader), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        label: 'Region',
        options: const [],
      )));
      expect(find.text('Region'), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        hintText: 'Select province/city',
        options: const [],
      )));
      expect(find.text('Select province/city'), findsOneWidget);
    });

    testWidgets('displays selected value as path labels', (tester) async {
      final options = [
        ParkCascaderOption(
          label: 'Zhejiang',
          value: 'zj',
          children: [
            ParkCascaderOption(label: 'Hangzhou', value: 'hz'),
          ],
        ),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(
        options: options,
        value: ['zj', 'hz'],
      )));
      expect(find.text('Zhejiang / Hangzhou'), findsOneWidget);
    });

    testWidgets('shows arrow icon', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [],
      )));
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
    });
  });

  group('ParkCascader - interactions', () {
    testWidgets('tap opens bottom sheet', (tester) async {
      final options = [
        ParkCascaderOption(label: 'A', value: 'a'),
        ParkCascaderOption(label: 'B', value: 'b'),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(options: options)));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // Bottom sheet should show options
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('disabled state prevents opening sheet', (tester) async {
      final options = [
        ParkCascaderOption(label: 'A', value: 'a'),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(
        options: options,
        enabled: false,
      )));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // No bottom sheet should appear
      expect(find.text('A'), findsNothing);
    });

    testWidgets('selecting leaf option triggers onChanged', (tester) async {
      List<String>? changed;
      final options = [
        ParkCascaderOption(
          label: 'Zhejiang',
          value: 'zj',
          children: [
            ParkCascaderOption(label: 'Hangzhou', value: 'hz'),
            ParkCascaderOption(label: 'Ningbo', value: 'nb'),
          ],
        ),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(
        options: options,
        onChanged: (v) => changed = v,
      )));
      // Open sheet
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // Tap parent option to go to next level
      await tester.tap(find.text('Zhejiang'));
      await tester.pumpAndSettle();
      // Tap leaf option
      await tester.tap(find.text('Hangzhou'));
      await tester.pumpAndSettle();
      // Tap confirm
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(changed, ['zj', 'hz']);
    });
  });

  group('ParkCascader - static methods', () {
    testWidgets('encodePath and decodePath roundtrip', (tester) async {
      final path = ['zj', 'hz', 'xh'];
      final encoded = ParkCascader.encodePath(path);
      final decoded = ParkCascader.decodePath(encoded);
      expect(decoded, path);
    });

    testWidgets('encodePath uses separator', (tester) async {
      final encoded = ParkCascader.encodePath(['a', 'b', 'c']);
      expect(encoded, contains('\x01'));
    });
  });

  group('ParkCascader - edge cases', () {
    testWidgets('empty options shows empty state in sheet', (tester) async {
      await tester.pumpWidget(_wrap(ParkCascader(
        options: const [],
        emptyText: 'No data available',
      )));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('changeOnSelect allows selecting non-leaf', (tester) async {
      List<String>? changed;
      final options = [
        ParkCascaderOption(
          label: 'Zhejiang',
          value: 'zj',
          children: [
            ParkCascaderOption(label: 'Hangzhou', value: 'hz'),
          ],
        ),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(
        options: options,
        changeOnSelect: true,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zhejiang'));
      await tester.pumpAndSettle();
      // With changeOnSelect, tapping a parent should still allow confirm
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(changed, ['zj']);
    });

    testWidgets('disabled option cannot be tapped', (tester) async {
      List<String>? changed;
      final options = [
        ParkCascaderOption(label: 'Disabled', value: 'd', disabled: true),
        ParkCascaderOption(label: 'Enabled', value: 'e'),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(
        options: options,
        onChanged: (v) => changed = v,
      )));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      // Tap disabled option should not navigate
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      expect(changed, isNull);
    });

    testWidgets('displayRender customizes display text', (tester) async {
      final options = [
        ParkCascaderOption(
          label: 'Zhejiang',
          value: 'zj',
          children: [
            ParkCascaderOption(label: 'Hangzhou', value: 'hz'),
          ],
        ),
      ];
      await tester.pumpWidget(_wrap(ParkCascader(
        options: options,
        value: ['zj', 'hz'],
        displayRender: (labels) => labels.join(' > '),
      )));
      expect(find.text('Zhejiang > Hangzhou'), findsOneWidget);
    });
  });
}
