import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_search_delegate.dart';
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
  group('showParkSearch', () {
    testWidgets('opens search page', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showParkSearch<String>(
                context: context,
                hint: '搜索房源',
              );
            },
            child: const Text('搜索'),
          ),
        ),
      ));
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();
      // Search page should show the hint text in the TextField
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays history items', (tester) async {
      final history = ParkInMemorySearchHistory();
      history.addHistory('test', '关键词A');
      history.addHistory('test', '关键词B');

      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showParkSearch<String>(
                context: context,
                historyScope: 'test',
                history: history,
                autofocus: false,
              );
            },
            child: const Text('搜索'),
          ),
        ),
      ));
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();
      expect(find.text('关键词A'), findsOneWidget);
      expect(find.text('关键词B'), findsOneWidget);
      expect(find.text('搜索历史'), findsOneWidget);
    });

    testWidgets('tapping history item triggers search', (tester) async {
      final history = ParkInMemorySearchHistory();
      history.addHistory('test', '历史词');
      String? searchedKeyword;

      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showParkSearch<String>(
                context: context,
                historyScope: 'test',
                history: history,
                autofocus: false,
                onSearch: (keyword) async {
                  searchedKeyword = keyword;
                  return <String>[];
                },
              );
            },
            child: const Text('搜索'),
          ),
        ),
      ));
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('历史词'));
      await tester.pumpAndSettle();
      expect(searchedKeyword, '历史词');
    });

    testWidgets('clear button removes text', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showParkSearch<String>(
                context: context,
                autofocus: false,
              );
            },
            child: const Text('搜索'),
          ),
        ),
      ));
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), '测试文字');
      await tester.pumpAndSettle();

      // Clear button should appear
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Text should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('search button calls onSearch', (tester) async {
      String? searchedKeyword;
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showParkSearch<String>(
                context: context,
                autofocus: false,
                onSearch: (keyword) async {
                  searchedKeyword = keyword;
                  return <String>['结果1'];
                },
              );
            },
            child: const Text('搜索'),
          ),
        ),
      ));
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '查询词');
      await tester.pumpAndSettle();

      // Tap the search button (搜索 text in the bar)
      await tester.tap(find.text('搜索').last);
      await tester.pumpAndSettle();
      expect(searchedKeyword, '查询词');
    });

    testWidgets('back button pops', (tester) async {
      await tester.pumpWidget(_wrap(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showParkSearch<String>(
                context: context,
                autofocus: false,
              );
            },
            child: const Text('搜索'),
          ),
        ),
      ));
      await tester.tap(find.text('搜索'));
      await tester.pumpAndSettle();

      // Search page is showing
      expect(find.byType(TextField), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back to the original page
      expect(find.byType(TextField), findsNothing);
      expect(find.text('搜索'), findsOneWidget);
    });
  });
}
