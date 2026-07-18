/// Extended smoke tests for display components that lacked individual tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/components/display/park_ellipsis.dart';
import 'package:park_ui/src/components/display/park_footer.dart';
import 'package:park_ui/src/components/display/park_grid.dart';
import 'package:park_ui/src/components/display/park_splitter.dart';
import 'package:park_ui/src/components/display/park_sticky.dart';
import 'package:park_ui/src/components/display/park_progress.dart';

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
  // ParkEllipsis
  // ===========================================================================
  group('ParkEllipsis - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkEllipsis(text: 'This is a long text that should be truncated'),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkEllipsis), findsOneWidget);
    });

    testWidgets('renders with maxLines', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkEllipsis(
            text: 'Multi-line text content',
            maxLines: 2,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkEllipsis), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkFooter
  // ===========================================================================
  group('ParkFooter - smoke test', () {
    testWidgets('creates and renders with links', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkFooter(
            text: 'Park UI',
            links: [
              ParkFooterLink(label: 'About'),
              ParkFooterLink(label: 'Terms'),
            ],
            copyright: '2025 Park UI',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkFooter), findsOneWidget);
      expect(find.text('Park UI'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkGrid
  // ===========================================================================
  group('ParkGrid - smoke test', () {
    testWidgets('creates and renders with items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkGrid(
            columnCount: 3,
            items: const [
              ParkGridItem(label: 'A'),
              ParkGridItem(label: 'B'),
              ParkGridItem(label: 'C'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkGrid), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkSplitter
  // ===========================================================================
  group('ParkSplitter - smoke test', () {
    testWidgets('creates and renders horizontal', (tester) async {
      await tester.pumpWidget(
        _wrapBounded(
          SizedBox(
            height: 200,
            child: ParkSplitter(
              axis: Axis.horizontal,
              first: Container(color: Colors.blue.shade50),
              second: Container(color: Colors.green.shade50),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkSplitter), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkSticky
  // ===========================================================================
  group('ParkSticky - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkSticky(
            child: Text('Sticky Header'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkSticky), findsOneWidget);
      expect(find.text('Sticky Header'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkProgress
  // ===========================================================================
  group('ParkProgress - smoke test', () {
    testWidgets('creates and renders with value', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkProgress(value: 0.5),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkProgress), findsOneWidget);
    });
  });
}
