/// Extended smoke tests for base components that lacked individual tests.
///
/// Each test verifies:
/// - Component can be created with required params
/// - Component renders without throwing

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/components/base/park_space.dart';
import 'package:park_ui/src/components/base/park_flex.dart';
import 'package:park_ui/src/components/base/park_float_button.dart';
import 'package:park_ui/src/components/base/park_typography.dart';
import 'package:park_ui/src/components/base/park_ink_well.dart';
import 'package:park_ui/src/components/base/park_grid_row.dart';

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
  // ParkSpace
  // ===========================================================================
  group('ParkSpace - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkSpace(
            children: [
              Text('A'),
              Text('B'),
              Text('C'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkSpace), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkFlex
  // ===========================================================================
  group('ParkFlex - smoke test', () {
    testWidgets('creates and renders with row direction', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkFlex(
            direction: ParkFlexDirection.row,
            gap: 8,
            children: [
              Container(width: 40, height: 40, color: Colors.blue),
              Container(width: 40, height: 40, color: Colors.green),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkFlex), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkFloatButton
  // ===========================================================================
  group('ParkFloatButton - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      final theme = ParkThemeData.light();
      await tester.pumpWidget(
        ParkConfigProvider(
          theme: theme,
          child: MaterialApp(
            theme: ThemeData(extensions: [theme]),
            home: Scaffold(
              body: Stack(
                children: [
                  const Center(child: Text('content')),
                  ParkFloatButton(
                    icon: Icons.add,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkFloatButton), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkTitle
  // ===========================================================================
  group('ParkTitle - smoke test', () {
    testWidgets('creates and renders with text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkTitle(text: 'Test Title', level: 1),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkTitle), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkInkWell
  // ===========================================================================
  group('ParkInkWell - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkInkWell(
            onTap: () {},
            child: const Text('Tap me'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkInkWell), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkGridRow
  // ===========================================================================
  group('ParkGridRow - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkGridRow(
            children: [
              Text('Col1'),
              Text('Col2'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkGridRow), findsOneWidget);
    });
  });
}
