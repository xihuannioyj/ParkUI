/// Extended smoke tests for input components that lacked individual tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/components/input/park_auto_complete.dart';
import 'package:park_ui/src/components/input/park_calendar.dart';
import 'package:park_ui/src/components/input/park_color_picker.dart';
import 'package:park_ui/src/components/input/park_date_range_picker.dart';
import 'package:park_ui/src/components/input/park_input_group.dart';
import 'package:park_ui/src/components/input/park_input.dart';
import 'package:park_ui/src/components/input/park_select.dart';
import 'package:park_ui/src/components/input/park_mentions.dart';
import 'package:park_ui/src/components/input/park_time_picker.dart';

Widget _wrap(Widget child) {
  final theme = ParkThemeData.light();
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

void main() {
  // ===========================================================================
  // ParkAutoComplete
  // ===========================================================================
  group('ParkAutoComplete - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkAutoComplete(
            options: const ['apple', 'banana', 'cherry'],
            hintText: 'Type fruit',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkAutoComplete), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkCalendar
  // ===========================================================================
  group('ParkCalendar - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkCalendar(
            value: DateTime(2025, 6, 15),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkCalendar), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkColorPicker
  // ===========================================================================
  group('ParkColorPicker - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkColorPicker(
            value: Color(0xFF1677FF),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkColorPicker), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDateRangePicker
  // ===========================================================================
  group('ParkDateRangePicker - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDateRangePicker(
            label: 'Range',
            startHintText: 'Start',
            endHintText: 'End',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkDateRangePicker), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkInputGroup
  // ===========================================================================
  group('ParkInputGroup - smoke test', () {
    testWidgets('creates and renders in compact mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkInputGroup(
            children: [
              ParkInput(hintText: 'Name', bordered: false),
              ParkSelect(
                items: const [
                  ParkSelectOption(label: 'BJ', value: 'bj'),
                ],
                bordered: false,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkInputGroup), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkMentions
  // ===========================================================================
  group('ParkMentions - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkMentions(
            items: const [
              ParkMentionItem(value: 'alice', label: 'alice'),
              ParkMentionItem(value: 'bob', label: 'bob'),
              ParkMentionItem(value: 'charlie', label: 'charlie'),
            ],
            placeholder: 'Type @ to mention',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkMentions), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkTimePicker
  // ===========================================================================
  group('ParkTimePicker - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTimePicker(
            placeholder: 'Select time',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTimePicker), findsOneWidget);
    });
  });
}
