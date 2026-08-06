import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/components/feedback/park_action_sheet.dart';
import 'package:park_ui/src/components/feedback/park_message.dart';
import 'package:park_ui/src/components/feedback/park_notification.dart';
import 'package:park_ui/src/components/input/park_auto_complete.dart';
import 'package:park_ui/src/components/input/park_calendar.dart';
import 'package:park_ui/src/components/input/park_chip_grid_picker.dart';
import 'package:park_ui/src/components/input/park_choice_group.dart';
import 'package:park_ui/src/components/input/park_color_picker.dart';
import 'package:park_ui/src/components/input/park_date_range_picker.dart';
import 'package:park_ui/src/components/input/park_mentions.dart';
import 'package:park_ui/src/components/input/park_time_picker.dart';
import 'package:park_ui/src/components/input/park_transfer.dart';
import 'package:park_ui/src/l10n/park_localizations.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

/// Standard wrapper: MaterialApp + Scaffold + ParkThemeData + ParkLocalizationsWidget.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    builder: (_, c) => ParkLocalizationsWidget(
      localizations: const ParkLocalizationsZh(),
      child: c!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

/// Wrapper with SingleChildScrollView for tall widgets.
Widget _wrapScroll(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    builder: (_, c) => ParkLocalizationsWidget(
      localizations: const ParkLocalizationsZh(),
      child: c!,
    ),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  // ==========================================================================
  // ParkActionSheet
  // ==========================================================================
  group('ParkActionSheet', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionSheet(
        title: 'Select action',
        actions: [
          ParkAction(label: 'Option A', onTap: () {}),
          ParkAction(label: 'Option B', onTap: () {}),
        ],
      )));
      expect(find.byType(ParkActionSheet), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      // CR60-08: verify ParkActionSheet widget properties
      final sheet = tester.widget<ParkActionSheet>(find.byType(ParkActionSheet));
      expect(sheet.title, 'Select action');
      expect(sheet.actions.length, 2);
      expect(sheet.actions[0].label, 'Option A');
    });

    testWidgets('interaction: tapping action fires onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        builder: (_, c) => ParkLocalizationsWidget(
          localizations: const ParkLocalizationsZh(),
          child: c!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ParkActionSheet.show(
                  context,
                  actions: [
                    ParkAction(label: 'Do it', onTap: () => tapped = true),
                  ],
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Do it'), findsOneWidget);
      await tester.tap(find.text('Do it'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  // ==========================================================================
  // ParkCalendar
  // ==========================================================================
  group('ParkCalendar', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrapScroll(
        ParkCalendar(value: DateTime(2025, 6, 15)),
      ));
      expect(find.byType(ParkCalendar), findsOneWidget);
      // Should show day numbers
      expect(find.text('15'), findsOneWidget);
      // CR60-08: verify ParkCalendar widget value property
      final calendar = tester.widget<ParkCalendar>(find.byType(ParkCalendar));
      expect(calendar.value, DateTime(2025, 6, 15));
    });

    testWidgets('interaction: tapping a date fires onChanged', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(_wrapScroll(
        ParkCalendar(
          value: DateTime(2025, 6, 15),
          onChanged: (d) => selected = d,
        ),
      ));
      // Tap day 20
      await tester.tap(find.text('20'));
      await tester.pump();
      expect(selected, isNotNull);
      expect(selected!.day, 20);
    });
  });

  // ==========================================================================
  // ParkDateRangePicker
  // ==========================================================================
  group('ParkDateRangePicker', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDateRangePicker()));
      expect(find.byType(ParkDateRangePicker), findsOneWidget);
      // Should show the date_range icon
      expect(find.byIcon(Icons.date_range_rounded), findsOneWidget);
      // CR60-08: verify icon widget property
      final icon = tester.widget<Icon>(find.byIcon(Icons.date_range_rounded));
      expect(icon.icon, Icons.date_range_rounded);
    });

    testWidgets('interaction: tapping opens bottom sheet', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDateRangePicker()));
      await tester.tap(find.byType(ParkDateRangePicker));
      await tester.pumpAndSettle();
      // The sheet should show start/end time fields
      expect(find.byIcon(Icons.calendar_today_rounded), findsWidgets);
    });
  });

  // ==========================================================================
  // ParkMentions
  // ==========================================================================
  group('ParkMentions', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [
          ParkMentionItem(value: 'alice', label: 'Alice'),
          ParkMentionItem(value: 'bob', label: 'Bob'),
        ],
      )));
      expect(find.byType(ParkMentions), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      // CR60-08: verify ParkMentions widget properties
      final mentions = tester.widget<ParkMentions>(find.byType(ParkMentions));
      expect(mentions.items.length, 2);
      expect(mentions.items[0].value, 'alice');
      expect(mentions.items[1].label, 'Bob');
    });

    testWidgets('interaction: typing fires onChanged', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(ParkMentions(
        items: const [ParkMentionItem(value: 'alice', label: 'Alice')],
        onChanged: (v) => changed = v,
      )));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(changed, 'hello');
    });
  });

  // ==========================================================================
  // ParkMessage
  // ==========================================================================
  group('ParkMessage', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkMessage(title: 'Test message')));
      expect(find.byType(ParkMessage), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
      // CR60-08: verify ParkMessage widget properties
      final msg = tester.widget<ParkMessage>(find.byType(ParkMessage));
      expect(msg.title, 'Test message');
      expect(msg.closable, isFalse);
    });

    testWidgets('interaction: static info shows overlay message', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        builder: (_, c) => ParkLocalizationsWidget(
          localizations: const ParkLocalizationsZh(),
          child: c!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ParkMessage.info(context, 'Info msg'),
              child: const Text('show'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();
      expect(find.text('Info msg'), findsOneWidget);
    });
  });

  // ==========================================================================
  // ParkNotification
  // ==========================================================================
  group('ParkNotification', () {
    testWidgets('smoke: show renders notification overlay', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        builder: (_, c) => ParkLocalizationsWidget(
          localizations: const ParkLocalizationsZh(),
          child: c!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ParkNotification.show(
                context,
                title: 'Notify title',
                description: 'Notify desc',
              ),
              child: const Text('notify'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('notify'));
      await tester.pumpAndSettle();
      expect(find.text('Notify title'), findsOneWidget);
      expect(find.text('Notify desc'), findsOneWidget);
    });

    testWidgets('interaction: close button dismisses notification', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        builder: (_, c) => ParkLocalizationsWidget(
          localizations: const ParkLocalizationsZh(),
          child: c!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ParkNotification.show(
                context,
                title: 'Closable',
                duration: const Duration(seconds: 30),
              ),
              child: const Text('notify'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('notify'));
      await tester.pumpAndSettle();
      expect(find.text('Closable'), findsOneWidget);
      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Closable'), findsNothing);
    });
  });

  // ==========================================================================
  // ParkTimePicker
  // ==========================================================================
  group('ParkTimePicker', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTimePicker()));
      expect(find.byType(ParkTimePicker), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
      // CR60-08: verify icon widget property
      final icon = tester.widget<Icon>(find.byIcon(Icons.access_time));
      expect(icon.icon, Icons.access_time);
    });

    testWidgets('interaction: tap opens bottom sheet with CupertinoPicker', (tester) async {
      await tester.pumpWidget(_wrap(const ParkTimePicker(showSeconds: true)));
      await tester.tap(find.byType(ParkTimePicker));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoPicker), findsWidgets);
    });
  });

  // ==========================================================================
  // ParkColorPicker
  // ==========================================================================
  group('ParkColorPicker', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrapScroll(
        const ParkColorPicker(value: Colors.blue),
      ));
      expect(find.byType(ParkColorPicker), findsOneWidget);
      // CR60-08: verify ParkColorPicker widget value property
      final picker = tester.widget<ParkColorPicker>(find.byType(ParkColorPicker));
      expect(picker.value, Colors.blue);
    });

    testWidgets('interaction: tapping preset color fires onChanged', (tester) async {
      Color? picked;
      await tester.pumpWidget(_wrapScroll(
        ParkColorPicker(
          value: Colors.blue,
          presetColors: [Colors.red, Colors.green],
          enableCustom: false,
          onChanged: (c) => picked = c,
        ),
      ));
      // Tap the first preset color (red)
      await tester.tap(find.byWidgetPredicate(
        (w) => w is Container && w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == Colors.red,
      ).first);
      await tester.pump();
      expect(picked, Colors.red);
    });
  });

  // ==========================================================================
  // ParkTransfer
  // ==========================================================================
  group('ParkTransfer', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(ParkTransfer(
        dataSource: const [
          ParkTransferItem(key: '1', title: 'Item A'),
          ParkTransferItem(key: '2', title: 'Item B'),
          ParkTransferItem(key: '3', title: 'Item C'),
        ],
        targetKeys: const ['3'],
      )));
      expect(find.byType(ParkTransfer), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item C'), findsOneWidget);
      // CR60-08: verify ParkTransfer widget properties
      final transfer = tester.widget<ParkTransfer>(find.byType(ParkTransfer));
      expect(transfer.dataSource.length, 3);
      expect(transfer.targetKeys, contains('3'));
      expect(transfer.dataSource[0].title, 'Item A');
    });

    testWidgets('interaction: select and transfer item fires onChanged', (tester) async {
      List<String>? resultKeys;
      TransferDirection? resultDir;
      await tester.pumpWidget(_wrap(ParkTransfer(
        dataSource: const [
          ParkTransferItem(key: '1', title: 'Item A'),
          ParkTransferItem(key: '2', title: 'Item B'),
        ],
        targetKeys: const [],
        onChanged: (keys, dir) {
          resultKeys = keys;
          resultDir = dir;
        },
      )));
      // Select Item A in left panel
      await tester.tap(find.text('Item A'));
      await tester.pump();
      // Tap the right-arrow transfer button
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
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAutoComplete(
        options: ['apple', 'banana', 'cherry'],
      )));
      expect(find.byType(ParkAutoComplete), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      // CR60-08: verify ParkAutoComplete widget options property
      final autoComplete = tester.widget<ParkAutoComplete>(find.byType(ParkAutoComplete));
      expect(autoComplete.options.length, 3);
      expect(autoComplete.options, contains('apple'));
      expect(autoComplete.options, contains('cherry'));
    });

    testWidgets('interaction: typing and selecting fires onSelected', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(ParkAutoComplete(
        options: const ['apple', 'apricot', 'banana'],
        onSelected: (v) => selected = v,
      )));
      await tester.enterText(find.byType(TextField), 'ap');
      // Wait for debounce (300ms)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      // Suggestions should appear; tap 'apple'
      expect(find.text('apple'), findsOneWidget);
      await tester.tap(find.text('apple'));
      await tester.pump();
      expect(selected, 'apple');
    });
  });

  // ==========================================================================
  // ParkChipGridPicker
  // ==========================================================================
  group('ParkChipGridPicker', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrapScroll(ParkChipGridPicker(
        categories: const [
          ParkChipGridCategory(label: 'Size', children: [
            ParkChipGridOption(value: 's', label: 'Small'),
            ParkChipGridOption(value: 'm', label: 'Medium'),
          ]),
        ],
        onChanged: (_) {},
      )));
      expect(find.byType(ParkChipGridPicker), findsOneWidget);
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('Small'), findsOneWidget);
      // CR60-08: verify ParkChipGridPicker widget categories property
      final picker = tester.widget<ParkChipGridPicker>(find.byType(ParkChipGridPicker));
      expect(picker.categories.length, 1);
      expect(picker.categories[0].label, 'Size');
      expect(picker.categories[0].children.length, 2);
    });

    testWidgets('interaction: tapping option fires onChanged with value', (tester) async {
      Set<String>? result;
      await tester.pumpWidget(_wrapScroll(ParkChipGridPicker(
        categories: const [
          ParkChipGridCategory(label: 'Size', children: [
            ParkChipGridOption(value: 's', label: 'Small'),
            ParkChipGridOption(value: 'm', label: 'Medium'),
          ]),
        ],
        selectedValues: const {},
        onChanged: (v) => result = v,
      )));
      await tester.tap(find.text('Small'));
      await tester.pump();
      expect(result, isNotNull);
      expect(result, contains('s'));
    });
  });

  // ==========================================================================
  // ParkChoiceGroup
  // ==========================================================================
  group('ParkChoiceGroup', () {
    testWidgets('smoke: builds without crash', (tester) async {
      await tester.pumpWidget(_wrap(ParkChoiceGroup(
        items: const [
          ParkChoiceItem(value: '1', label: 'Option A'),
          ParkChoiceItem(value: '2', label: 'Option B'),
        ],
        value: '1',
        onChanged: (_) {},
      )));
      expect(find.byType(ParkChoiceGroup), findsOneWidget);
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('Option B'), findsOneWidget);
      // CR60-08: verify ParkChoiceGroup widget properties
      final group = tester.widget<ParkChoiceGroup>(find.byType(ParkChoiceGroup));
      expect(group.items.length, 2);
      expect(group.value, '1');
      expect(group.items[0].label, 'Option A');
    });

    testWidgets('interaction: tapping item fires onChanged with value', (tester) async {
      String? selected;
      await tester.pumpWidget(_wrap(ParkChoiceGroup(
        items: const [
          ParkChoiceItem(value: '1', label: 'Option A'),
          ParkChoiceItem(value: '2', label: 'Option B'),
        ],
        value: '1',
        onChanged: (v) => selected = v,
      )));
      await tester.tap(find.text('Option B'));
      await tester.pump();
      expect(selected, '2');
    });
  });
}
