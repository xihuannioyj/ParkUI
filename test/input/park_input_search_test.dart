import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkInput.searchButton - loading (P0-3)', () {
    testWidgets('loading=true 显示 spinner 且不可点', (tester) async {
      String? searched;
      await tester.pumpWidget(_wrap(ParkInput(
        controller: TextEditingController(text: 'hello'),
        searchButton: const ParkInputSearchButtonConfig(
          loading: true,
          onSearch: null,
        ),
        onSearch: (v) => searched = v,
      )));

      // loading 态应渲染 spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 不可点：点击不应触发 onSearch
      await tester.tap(find.byType(ParkButton));
      await tester.pump();
      expect(searched, isNull);
    });
  });

  group('ParkInput.searchButton - 点击触发 (P0-3)', () {
    testWidgets('点击按钮触发 onSearch 并带正确文本', (tester) async {
      String? searched;
      final c = TextEditingController(text: 'hello');
      await tester.pumpWidget(_wrap(ParkInput(
        controller: c,
        searchButton: ParkInputSearchButtonConfig(
          text: '搜索',
          onSearch: (v) => searched = v,
        ),
      )));
      await tester.tap(find.byType(ParkButton));
      await tester.pump();
      expect(searched, 'hello');
    });

    testWidgets('searchButton=true 渲染默认「搜索」按钮', (tester) async {
      String? searched;
      final c = TextEditingController(text: 'world');
      await tester.pumpWidget(_wrap(ParkInput(
        controller: c,
        searchButton: true,
        onSearch: (v) => searched = v,
      )));
      expect(find.byType(ParkButton), findsOneWidget);
      expect(find.text('搜索'), findsOneWidget);
      await tester.tap(find.byType(ParkButton));
      await tester.pump();
      expect(searched, 'world');
    });
  });

  group('ParkInput.searchButton - 回车触发 (P0-3)', () {
    testWidgets('回车触发 onSearch 并带正确文本', (tester) async {
      String? searched;
      await tester.pumpWidget(_wrap(ParkInput(
        searchButton: ParkInputSearchButtonConfig(
          text: '搜索',
          onSearch: (v) => searched = v,
        ),
      )));
      await tester.enterText(find.byType(TextField), 'enter-text');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(searched, 'enter-text');
    });
  });
}
