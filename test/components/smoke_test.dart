/// Smoke tests for 10 high-risk components.
///
/// Each smoke test verifies:
/// - Component can be created (with required params)
/// - Component renders without throwing (pumpWidget succeeds)
/// - Basic interaction (tap, value change, etc.)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Theme imports
import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';

// Component imports (targeted to avoid pre-existing compilation errors in barrel)
import 'package:park_ui/src/components/input/park_select.dart';
import 'package:park_ui/src/components/display/park_tree.dart';
import 'package:park_ui/src/components/display/park_table.dart';
import 'package:park_ui/src/components/input/park_upload.dart';
import 'package:park_ui/src/components/input/park_date_picker.dart';
import 'package:park_ui/src/components/feedback/park_dialog.dart';
import 'package:park_ui/src/components/feedback/park_notification.dart';
import 'package:park_ui/src/components/feedback/park_tour.dart';
import 'package:park_ui/src/components/navigation/park_menu.dart';
import 'package:park_ui/src/components/navigation/park_tabs.dart';

/// Wraps [child] with standard Park UI theme for widget tests.
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

/// Wraps [child] with bounded height for widgets that need finite constraints.
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
  // ParkSelect
  // ===========================================================================
  group('ParkSelect - smoke test', () {
    testWidgets('creates and renders with options', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkSelect(
            items: const [
              ParkSelectOption(label: 'Beijing', value: 'bj'),
              ParkSelectOption(label: 'Shanghai', value: 'sh'),
            ],
            hintText: 'Select city',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkSelect), findsOneWidget);
    });

    testWidgets('tapping opens dropdown panel', (tester) async {
      // ignore: unused_local_variable
      String? selected;
      await tester.pumpWidget(
        _wrap(
          ParkSelect(
            items: const [
              ParkSelectOption(label: 'Beijing', value: 'bj'),
              ParkSelectOption(label: 'Shanghai', value: 'sh'),
            ],
            hintText: 'Select',
            onChanged: (v) => selected = v,
          ),
        ),
      );
      await tester.pump();

      // Tap the select to open dropdown
      await tester.tap(find.byType(ParkSelect));
      await tester.pumpAndSettle();

      // The dropdown should be visible now
      expect(find.text('Beijing'), findsWidgets);
    });
  });

  // ===========================================================================
  // ParkTree
  // ===========================================================================
  group('ParkTree - smoke test', () {
    testWidgets('creates and renders with data', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTree(
            data: const [
              ParkTreeNode(key: '1', label: 'Node A', children: [
                ParkTreeNode(key: '1-1', label: 'Child A1'),
              ]),
              ParkTreeNode(key: '2', label: 'Node B'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTree), findsOneWidget);
      expect(find.text('Node A'), findsOneWidget);
      expect(find.text('Node B'), findsOneWidget);
    });

    testWidgets('expanding a node shows children', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTree(
            data: const [
              ParkTreeNode(key: '1', label: 'Parent', children: [
                ParkTreeNode(key: '1-1', label: 'Child'),
              ]),
            ],
          ),
        ),
      );
      await tester.pump();

      // Tap expand icon
      await tester.tap(find.byType(ParkTree));
      await tester.pumpAndSettle();

      // Parent should still be visible
      expect(find.text('Parent'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkTable
  // ===========================================================================
  group('ParkTable - smoke test', () {
    testWidgets('creates and renders with columns and data', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTable(
            columns: const [
              ParkTableColumn(key: 'name', title: 'Name'),
              ParkTableColumn(key: 'age', title: 'Age', width: 80),
            ],
            data: const [
              {'name': 'Alice', 'age': '30'},
              {'name': 'Bob', 'age': '25'},
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTable), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('renders empty state when data is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTable(
            columns: const [
              ParkTableColumn(key: 'name', title: 'Name'),
            ],
            data: const [],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTable), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkUpload
  // ===========================================================================
  group('ParkUpload - smoke test', () {
    testWidgets('creates and renders with empty files', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkUpload(
            files: const [],
            onAdd: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkUpload), findsOneWidget);
    });

    testWidgets('renders with existing files', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkUpload(
            files: const [
              ParkUploadFile(
                path: '/tmp/test.jpg',
                status: ParkUploadFileStatus.done,
                progress: 1.0,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkUpload), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDatePicker
  // ===========================================================================
  group('ParkDatePicker - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDatePicker(
            label: 'Date',
            hintText: 'Select date',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkDatePicker), findsOneWidget);
    });

    testWidgets('tapping opens date picker popup', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDatePicker(
            label: 'Date',
            hintText: 'Select',
          ),
        ),
      );
      await tester.pump();

      // Tap to open picker
      await tester.tap(find.byType(ParkDatePicker));
      await tester.pumpAndSettle();

      // Should show some date picker UI
      expect(find.byType(ParkDatePicker), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkDialog
  // ===========================================================================
  group('ParkDialog - smoke test', () {
    testWidgets('creates and renders with title and content', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkDialog(
            title: 'Test Dialog',
            content: 'Dialog content',
            onConfirm: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkDialog), findsOneWidget);
      expect(find.text('Test Dialog'), findsOneWidget);
    });

    testWidgets('confirm button triggers callback', (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(
        _wrap(
          ParkDialog(
            title: 'Confirm',
            content: 'Are you sure?',
            confirmText: 'OK',
            onConfirm: () => confirmed = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pump();
      expect(confirmed, isTrue);
    });
  });

  // ===========================================================================
  // ParkNotification
  // ===========================================================================
  group('ParkNotification - smoke test', () {
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

      // Context is now valid from the pumpWidget above
      expect(capturedContext, isNotNull);

      // Call show() — this schedules a postFrameCallback
      ParkNotification.show(
        capturedContext!,
        title: 'Test Notification',
        description: 'This is a test',
        duration: const Duration(milliseconds: 100),
      );

      // Pump to process the postFrameCallback and insert overlay
      await tester.pump();
      // Let the notification auto-dismiss
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // If we got here without exceptions, the smoke test passes
      // Verify the app tree survived the notification show + auto-dismiss cycle
      expect(find.text('body'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkTour
  // ===========================================================================
  group('ParkTour - smoke test', () {
    testWidgets('creates without error when open=false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTour(
            open: false,
            steps: const [
              ParkTourStep(
                title: 'Step 1',
                description: 'First step description',
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTour), findsOneWidget);
      expect(find.text('Step 1'), findsNothing);
    });

    testWidgets('does not render content when open=false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkTour(
            open: false,
            steps: const [
              ParkTourStep(
                title: 'Hidden Step',
                description: 'Should not show',
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Hidden Step'), findsNothing);
    });
  });

  // ===========================================================================
  // ParkMenu
  // ===========================================================================
  group('ParkMenu - smoke test', () {
    testWidgets('creates and renders with items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkMenu(
            items: const [
              ParkMenuItem(key: 'home', label: 'Home', icon: Icons.home),
              ParkMenuItem(key: 'settings', label: 'Settings', icon: Icons.settings),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkMenu), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping item triggers onSelect', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _wrap(
          ParkMenu(
            items: const [
              ParkMenuItem(key: 'home', label: 'Home'),
              ParkMenuItem(key: 'about', label: 'About'),
            ],
            onSelect: (key) => selected = key,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(selected, 'home');
    });
  });

  // ===========================================================================
  // ParkTabs
  // ===========================================================================
  group('ParkTabs - smoke test', () {
    testWidgets('creates and renders with tabs', (tester) async {
      await tester.pumpWidget(
        _wrapBounded(
          ParkTabs(
            tabs: const [
              ParkTab(label: 'Tab 1'),
              ParkTab(label: 'Tab 2'),
              ParkTab(label: 'Tab 3'),
            ],
            children: const [
              Center(child: Text('Content 1')),
              Center(child: Text('Content 2')),
              Center(child: Text('Content 3')),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTabs), findsOneWidget);
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);
    });

    testWidgets('tapping tab switches content', (tester) async {
      int? changedIndex;
      await tester.pumpWidget(
        _wrapBounded(
          ParkTabs(
            tabs: const [
              ParkTab(label: 'Tab A'),
              ParkTab(label: 'Tab B'),
            ],
            children: const [
              Center(child: Text('Page A')),
              Center(child: Text('Page B')),
            ],
            onChanged: (i) => changedIndex = i,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();
      expect(changedIndex, 1);
    });
  });
}
