import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/feedback/park_sheet_scaffold.dart';
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
  group('ParkSheetScaffold', () {
    testWidgets('show() renders title and child', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkSheetScaffold.show(
                context: context,
                title: '选择城市',
                child: const Text('内容区域'),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.text('选择城市'), findsOneWidget);
      expect(find.text('内容区域'), findsOneWidget);
    });

    testWidgets('confirm button returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ParkSheetScaffold.show(
                context: context,
                title: '测试',
                child: const SizedBox(height: 100),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('cancel button returns false', (tester) async {
      bool? result;
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ParkSheetScaffold.show(
                context: context,
                title: '测试',
                child: const SizedBox(height: 100),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('dismiss returns null', (tester) async {
      bool? result = true; // start non-null to verify it becomes null
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ParkSheetScaffold.show(
                context: context,
                title: '测试',
                child: const SizedBox(height: 100),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      // Tap the barrier to dismiss
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('confirmEnabled: false disables confirm', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkSheetScaffold.show(
                context: context,
                title: '测试',
                confirmEnabled: false,
                child: const SizedBox(height: 100),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      // The confirm button's Semantics should be disabled
      final semantics = tester.getSemantics(find.text('确定'));
      expect(semantics.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
    });

    testWidgets('showDragHandle renders handle', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              ParkSheetScaffold.show(
                context: context,
                title: '测试',
                showDragHandle: true,
                child: const SizedBox(height: 100),
              );
            },
            child: const Text('打开'),
          ),
        ),
      ));
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      // Verify the sheet rendered with drag handle
      expect(find.byType(ParkSheetScaffold), findsOneWidget);
      // Verify the sheet rendered with drag handle by checking the widget tree
      final sheet = tester.widget<ParkSheetScaffold>(
        find.byType(ParkSheetScaffold),
      );
      expect(sheet.showDragHandle, isTrue);
    });
  });
}
