/// Extended smoke tests for navigation components that lacked individual tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:park_ui/src/theme/park_theme_data.dart';
import 'package:park_ui/src/theme/park_config_provider.dart';
import 'package:park_ui/src/components/navigation/park_anchor.dart';
import 'package:park_ui/src/components/navigation/park_layout.dart';
import 'package:park_ui/src/components/navigation/park_pagination.dart';
import 'package:park_ui/src/components/navigation/park_bottom_nav.dart';

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
  // ParkAnchor
  // ===========================================================================
  group('ParkAnchor - smoke test', () {
    testWidgets('creates and renders with items', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkAnchor(
            items: const [
              ParkAnchorItem(key: 'section1', label: 'Section 1'),
              ParkAnchorItem(key: 'section2', label: 'Section 2'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkAnchor), findsOneWidget);
      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkLayout
  // ===========================================================================
  group('ParkLayout - smoke test', () {
    testWidgets('creates and renders with body only', (tester) async {
      await tester.pumpWidget(
        _wrapBounded(
          const ParkLayout(
            body: Center(child: Text('Content')),
          ),
          height: 400,
        ),
      );
      await tester.pump();
      expect(find.byType(ParkLayout), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders with header and sidebar', (tester) async {
      await tester.pumpWidget(
        _wrapBounded(
          ParkLayout(
            header: Container(
              color: Colors.blue,
              child: const Text('Header'),
            ),
            sidebar: Container(
              color: Colors.grey.shade200,
              child: const Text('Sidebar'),
            ),
            body: const Center(child: Text('Body')),
            sidebarWidth: 150,
          ),
          height: 400,
        ),
      );
      await tester.pump();
      expect(find.byType(ParkLayout), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkPagination
  // ===========================================================================
  group('ParkPagination - smoke test', () {
    testWidgets('creates and renders', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ParkPagination(
            total: 100,
            pageSize: 10,
            current: 1,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ParkPagination), findsOneWidget);
    });
  });

  // ===========================================================================
  // ParkBottomNav
  // ===========================================================================
  group('ParkBottomNav - smoke test', () {
    testWidgets('creates and renders with items', (tester) async {
      await tester.pumpWidget(
        _wrapBounded(
          ParkBottomNav(
            items: const [
              ParkBottomNavItem(icon: Icon(Icons.home), label: 'Home'),
              ParkBottomNavItem(icon: Icon(Icons.search), label: 'Search'),
              ParkBottomNavItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
            currentIndex: 0,
            onTap: (_) {},
          ),
          height: 400,
        ),
      );
      await tester.pump();
      expect(find.byType(ParkBottomNav), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
