/// Extended smoke tests for feedback components that lacked individual tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/components/feedback/park_action_sheet.dart';
import 'package:park_ui/src/components/feedback/park_notification.dart';
import 'package:park_ui/src/components/feedback/park_overlay.dart';
import 'package:park_ui/src/components/feedback/park_popup.dart';
import 'package:park_ui/src/components/feedback/park_refresh.dart';
import 'package:park_ui/src/components/feedback/park_dropdown_menu.dart';
import 'package:park_ui/src/components/feedback/park_dropdown_sheet.dart';
import 'package:park_ui/src/components/feedback/park_dropdown_filter.dart';
import 'package:park_ui/src/components/feedback/park_message.dart';

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

Widget _wrapBounded(Widget child, {double height = 600}) {
  final theme = ParkThemeData.light();
  return ParkConfigProvider(
    theme: theme,
    child: MaterialApp(
      theme: ThemeData(extensions: [theme]),
      home: Scaffold(
        body: SizedBox(height: height, child: child),
      ),
    ),
  );
}

void main() {
  // ===========================================================================
  // ParkActionSheet
  // ===========================================================================
  group('ParkActionSheet - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkActionSheet(
            actions: const [
              ParkAction(label: 'Option 1'),
              ParkAction(label: 'Option 2'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkActionSheet), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkOverlay
  // ===========================================================================
  group('ParkOverlay - smoke test', () {
    testWidgets('creates and renders when visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkOverlay(
            visible: true,
            child: Center(child: Text('Overlay Content')),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkOverlay), findsOneWidget);
    });

    testWidgets('does not show content when not visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkOverlay(
            visible: false,
            child: Center(child: Text('Hidden')),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Hidden'), findsNothing);
    });
  });

  // ===========================================================================
  // ParkPopup
  // ===========================================================================
  group('ParkPopup - smoke test', () {
    testWidgets('creates and renders when visible', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkPopup(
            visible: true,
            child: Text('Popup Content'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkPopup), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkRefresh
  // ===========================================================================
  group('ParkRefresh - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrapBounded(
          ParkRefresh(
            onRefresh: () async {},
            child: ListView(
              children: const [
                ListTile(title: Text('Item 1')),
                ListTile(title: Text('Item 2')),
              ],
            ),
          ),
          height: 400,
        ),
      );
      await tester.pump();
      expect(find.byType(ParkRefresh), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDropdownMenu
  // ===========================================================================
  group('ParkDropdownMenu - smoke test', () {
    testWidgets('creates and renders with trigger', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDropdownMenu(
            items: const [
              ParkDropdownMenuItem(label: 'Item 1', value: '1'),
              ParkDropdownMenuItem(label: 'Item 2', value: '2'),
            ],
            trigger: const Text('Open Menu'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkDropdownMenu), findsOneWidget);
      expect(find.text('Open Menu'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDropdownSheet
  // ===========================================================================
  group('ParkDropdownSheet - smoke test', () {
    testWidgets('creates and renders with trigger', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDropdownSheet(
            title: 'Select',
            items: const [
              ParkDropdownSheetItem(label: 'A', value: 'a'),
              ParkDropdownSheetItem(label: 'B', value: 'b'),
            ],
            trigger: const Text('Open Sheet'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkDropdownSheet), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDropdownFilter
  // ===========================================================================
  group('ParkDropdownFilter - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDropdownFilter(
            items: [
              DropdownFilterItem(
                label: 'Status',
                options: const [
                  DropdownFilterOption(label: 'All', value: 'all'),
                  DropdownFilterOption(label: 'Active', value: 'active'),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkDropdownFilter), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkMessage
  // ===========================================================================
  group('ParkMessage - smoke test', () {
    testWidgets('show can be called without throwing', (tester) async {
      final theme = ParkThemeData.light();
      BuildContext? capturedContext;

      await tester.pumpWidget(
        ParkConfigProvider(
          theme: theme,
          child: MaterialApp(
            theme: ThemeData(extensions: [theme]),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const Text('body');
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedContext, isNotNull);

      ParkMessage.info(
        capturedContext!,
        'Test message',
        duration: const Duration(milliseconds: 100),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the app tree survived the ParkMessage show + auto-dismiss cycle
      expect(find.text('body'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkNotification (additional)
  // ===========================================================================
  group('ParkNotification - additional smoke test', () {
    testWidgets('show with different types', (tester) async {
      final theme = ParkThemeData.light();
      BuildContext? capturedContext;

      await tester.pumpWidget(
        ParkConfigProvider(
          theme: theme,
          child: MaterialApp(
            theme: ThemeData(extensions: [theme]),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const Text('body');
                },
              ),
            ),
          ),
        ),
      );

      ParkNotification.show(
        capturedContext!,
        title: 'Success',
        type: ParkNotificationType.success,
        duration: const Duration(milliseconds: 100),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Verify the app tree survived the notification show + auto-dismiss cycle
      expect(find.text('body'), findsOneWidget);
    });
  });
}
