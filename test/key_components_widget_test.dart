import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_mentions.dart';
import 'package:park_ui/src/components/input/park_time_picker.dart';
import 'package:park_ui/src/components/input/park_calendar.dart';
import 'package:park_ui/src/components/input/park_color_picker.dart';
import 'package:park_ui/src/components/input/park_transfer.dart';
import 'package:park_ui/src/components/input/park_auto_complete.dart';
import 'package:park_ui/src/components/input/park_checkbox.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  // ==========================================================================
  // ParkMentions
  // ==========================================================================
  group('ParkMentions', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'a', label: 'A'),
          ParkMentionItem(value: 'b', label: 'B'),
        ],
      )));
      expect(find.byType(ParkMentions), findsOneWidget);
    });

    testWidgets('onChanged fires on text input', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [ParkMentionItem(value: 'a', label: 'A')],
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(changed, 'hello');
    });
  });

  // ==========================================================================
  // ParkTimePicker
  // ==========================================================================
  group('ParkTimePicker', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTimePicker()));
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });

    testWidgets('tap opens bottom sheet picker', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTimePicker(showSeconds: true)));
      // Tap the picker trigger area (GestureDetector wrapping the container)
      await tester.tap(find.byType(ParkTimePicker));
      await tester.pumpAndSettle();
      // Bottom sheet should appear with CupertinoPicker
      expect(find.byType(CupertinoPicker), findsWidgets);
    });
  });

  // ==========================================================================
  // ParkCalendar
  // ==========================================================================
  group('ParkCalendar', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(body: SingleChildScrollView(
          child: ParkCalendar(value: DateTime(2025, 6, 15)),
        )),
      ));
      expect(find.byType(ParkCalendar), findsOneWidget);
    });

    testWidgets('onChanged fires on date tap', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Scaffold(body: SingleChildScrollView(
          child: ParkCalendar(
            value: DateTime(2025, 6, 15),
            onChanged: (date) => selected = date,
          ),
        )),
      ));
      // Tap on day "20" in the calendar grid
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(selected, isNotNull);
      expect(selected!.day, 20);
      expect(selected!.month, 6);
    });
  });

  // ==========================================================================
  // ParkColorPicker
  // ==========================================================================
  group('ParkColorPicker', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkColorPicker()));
      expect(find.byType(ParkColorPicker), findsOneWidget);
    });

    testWidgets('onChanged fires on preset color tap', (tester) async {
      Color? picked;
      await tester.pumpWidget(_wrap(ParkColorPicker(
        presetColors: const [Colors.red, Colors.green, Colors.blue],
        onChanged: (c) => picked = c,
      )));
      // Find the Wrap containing preset colors and tap the first GestureDetector
      final gestureFinder = find.descendant(
        of: find.byType(Wrap),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureFinder.first);
      await tester.pump();
      expect(picked, isNotNull);
      expect(picked, Colors.red);
    });
  });

  // ==========================================================================
  // ParkTransfer
  // ==========================================================================
  group('ParkTransfer', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(ParkTransfer(
        dataSource: const [
          ParkTransferItem(key: '1', title: 'Option A'),
          ParkTransferItem(key: '2', title: 'Option B'),
          ParkTransferItem(key: '3', title: 'Option C'),
        ],
      )));
      expect(find.byType(ParkTransfer), findsOneWidget);
    });

    testWidgets('onChanged fires after select and transfer', (tester) async {
      List<String>? resultKeys;
      TransferDirection? resultDir;
      await tester.pumpWidget(_wrap(ParkTransfer(
        dataSource: const [
          ParkTransferItem(key: '1', title: 'Option A'),
          ParkTransferItem(key: '2', title: 'Option B'),
        ],
        onChanged: (keys, dir) {
          resultKeys = keys;
          resultDir = dir;
        },
      )));
      // Tap on "Option A" in the left panel to select it
      await tester.tap(find.text('Option A'));
      await tester.pump();
      // Tap the transfer-to-right button (chevron_right icon)
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(resultKeys, contains('1'));
      expect(resultDir, TransferDirection.leftToRight);
    });
  });

  // ==========================================================================
  // ParkAutoComplete
  // ==========================================================================
  group('ParkAutoComplete', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAutoComplete(
        options: ['apple', 'banana', 'cherry'],
      )));
      expect(find.byType(ParkAutoComplete), findsOneWidget);
    });

    testWidgets('onChanged fires on text input', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'banana', 'cherry'],
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), 'app');
      await tester.pump();
      expect(changed, 'app');
    });
  });

  // ==========================================================================
  // ParkCheckboxGroup
  // ==========================================================================
  group('ParkCheckboxGroup', () {
    testWidgets('builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkCheckboxGroup(
        options: [
          ParkCheckboxOption(label: 'A', value: 'a'),
          ParkCheckboxOption(label: 'B', value: 'b'),
          ParkCheckboxOption(label: 'C', value: 'c'),
        ],
      )));
      expect(find.byType(ParkCheckboxGroup), findsOneWidget);
    });

    testWidgets('onChanged fires on checkbox tap', (tester) async {
      List<String>? selectedValues;
      await tester.pumpWidget(_wrap(ParkCheckboxGroup(
        options: const [
          ParkCheckboxOption(label: 'A', value: 'a'),
          ParkCheckboxOption(label: 'B', value: 'b'),
        ],
        onChanged: (values, _) => selectedValues = values,
      )));
      // Tap on the first checkbox (label 'A')
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(selectedValues, isNotNull);
      expect(selectedValues, contains('a'));
    });
  });
}
