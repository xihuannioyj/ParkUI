import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_date_picker.dart';
import 'package:park_ui/src/l10n/park_localizations.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      builder: (_, c) => ParkLocalizationsWidget(
        localizations: const ParkLocalizationsZh(),
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkDatePicker enhanced', () {
    testWidgets('allowedDateRanges: renders without error', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(_wrap(
        ParkDatePicker(
          label: '日期',
          mode: ParkDatePickerMode.date,
          allowedDateRanges: [
            DateTimeRange(
              start: now.subtract(const Duration(days: 7)),
              end: now.add(const Duration(days: 7)),
            ),
          ],
        ),
      ));
      expect(find.byType(ParkDatePicker), findsOneWidget);
      expect(find.text('日期'), findsOneWidget);
    });

    testWidgets('timeWithSeconds mode: renders three wheels', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDatePicker(
          label: '时间',
          mode: ParkDatePickerMode.timeWithSeconds,
        ),
      ));
      // Tap to open the picker
      await tester.tap(find.byType(ParkDatePicker));
      await tester.pumpAndSettle();

      // Three CupertinoPicker wheels for H:M:S
      expect(find.byType(CupertinoPicker), findsNWidgets(3));
    });

    testWidgets('allowedDateRanges null: all dates allowed', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDatePicker(
          label: '日期',
          mode: ParkDatePickerMode.date,
          allowedDateRanges: null,
        ),
      ));
      // Tap to open the picker
      await tester.tap(find.byType(ParkDatePicker));
      await tester.pumpAndSettle();

      // Confirm button should be enabled (not disabled)
      final confirmFinder = find.text('确定');
      expect(confirmFinder, findsOneWidget);
      final semantics = tester.getSemantics(confirmFinder);
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isTrue);
    });

    testWidgets('ParkDatePicker mode dateTime renders', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkDatePicker(
          label: '日期时间',
          mode: ParkDatePickerMode.dateTime,
        ),
      ));
      expect(find.byType(ParkDatePicker), findsOneWidget);
      expect(find.text('日期时间'), findsOneWidget);

      // Tap to open
      await tester.tap(find.byType(ParkDatePicker));
      await tester.pumpAndSettle();

      // Should show a CupertinoDatePicker in dateAndTime mode
      expect(find.byType(CupertinoDatePicker), findsOneWidget);
    });
  });
}
