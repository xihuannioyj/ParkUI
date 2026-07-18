/// Smoke tests for zero-coverage components.
///
/// Each test verifies the widget can be created with minimal required
/// parameters and pumped without error.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';

// Component imports
import 'package:park_ui/src/components/base/park_flex.dart';
import 'package:park_ui/src/components/base/park_float_button.dart';
import 'package:park_ui/src/components/base/park_grid_row.dart';
import 'package:park_ui/src/components/base/park_ink_well.dart';
import 'package:park_ui/src/components/base/park_typography.dart';
import 'package:park_ui/src/components/base/park_text.dart';
import 'package:park_ui/src/components/feedback/park_action_sheet.dart';
import 'package:park_ui/src/components/input/park_auto_complete.dart';
import 'package:park_ui/src/components/input/park_calendar.dart';
import 'package:park_ui/src/components/input/park_mentions.dart';
import 'package:park_ui/src/components/input/park_date_preset.dart';
import 'package:park_ui/src/components/navigation/park_layout.dart';
import 'package:park_ui/src/components/navigation/park_anchor.dart';
import 'package:park_ui/src/components/navigation/park_pagination.dart';

Widget _wrap(Widget child) {
  final theme = ParkThemeData.light();
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Scaffold(body: child),
    ),
  );
}

Widget _wrapStack(Widget child) {
  final theme = ParkThemeData.light();
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Stack(children: [child]),
    ),
  );
}

void main() {
  // ===========================================================================
  // ParkFlex
  // ===========================================================================
  group('ParkFlex - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkFlex(
          children: [Text('A'), Text('B')],
        ),
      ));
      expect(find.byType(ParkFlex), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkFloatButton
  // ===========================================================================
  group('ParkFloatButton - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrapStack(
        ParkFloatButton(
          icon: Icons.add,
          onPressed: () {},
        ),
      ));
      expect(find.byType(ParkFloatButton), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkGridRow / ParkGridCol
  // ===========================================================================
  group('ParkGridRow / ParkGridCol - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkGridRow(
          children: [
            ParkGridCol(span: 12, child: Text('Left')),
            ParkGridCol(span: 12, child: Text('Right')),
          ],
        ),
      ));
      expect(find.byType(ParkGridRow), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkInkWell
  // ===========================================================================
  group('ParkInkWell - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkInkWell(
          onTap: () {},
          child: const Text('Tap me'),
        ),
      ));
      expect(find.byType(ParkInkWell), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkTypography (ParkTitle / ParkText)
  // ===========================================================================
  group('ParkTypography / ParkText - smoke test', () {
    testWidgets('ParkTitle creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkTitle(level: 1, text: 'Heading'),
      ));
      expect(find.byType(ParkTitle), findsOneWidget);
    });

    testWidgets('ParkText creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkText('Hello world'),
      ));
      expect(find.byType(ParkText), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkActionSheet
  // ===========================================================================
  group('ParkActionSheet - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkActionSheet(
          actions: [
            ParkAction(label: 'Action 1'),
            ParkAction(label: 'Action 2'),
          ],
        ),
      ));
      expect(find.byType(ParkActionSheet), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkAutoComplete
  // ===========================================================================
  group('ParkAutoComplete - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        ParkAutoComplete(
          options: const ['Apple', 'Banana', 'Cherry'],
        ),
      ));
      expect(find.byType(ParkAutoComplete), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkCalendar
  // ===========================================================================
  group('ParkCalendar - smoke test', () {
    testWidgets('creates without error', (tester) async {
      // Calendar needs more vertical space than the default 600px test surface
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_wrap(
        ParkCalendar(
          onChanged: (_) {},
        ),
      ));
      expect(find.byType(ParkCalendar), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkMentions
  // ===========================================================================
  group('ParkMentions - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkMentions(
          items: [
            ParkMentionItem(value: 'alice', label: 'Alice'),
            ParkMentionItem(value: 'bob', label: 'Bob'),
          ],
        ),
      ));
      expect(find.byType(ParkMentions), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDatePreset (data class, not a widget)
  // ===========================================================================
  group('ParkDatePreset - smoke test', () {
    test('creates without error', () {
      final preset = ParkDatePreset(
        label: 'Today',
        onSelect: () {},
        date: DateTime.now(),
      );
      expect(preset.label, 'Today');
    });
  });

  // ===========================================================================
  // ParkLayout
  // ===========================================================================
  group('ParkLayout - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkLayout(
          body: Text('Body content'),
        ),
      ));
      expect(find.byType(ParkLayout), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkAnchor
  // ===========================================================================
  group('ParkAnchor - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkAnchor(
          items: [
            ParkAnchorItem(key: 'section1', label: 'Section 1'),
            ParkAnchorItem(key: 'section2', label: 'Section 2'),
          ],
        ),
      ));
      expect(find.byType(ParkAnchor), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkPagination
  // ===========================================================================
  group('ParkPagination - smoke test', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const ParkPagination(
          total: 100,
          current: 1,
          pageSize: 10,
        ),
      ));
      expect(find.byType(ParkPagination), findsOneWidget);
    });
  });
}
