import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _buildRefreshApp({
  required Future<void> Function() onRefresh,
  bool useMaterialRefreshIndicator = false,
}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
    ),
    home: Scaffold(
      body: SizedBox(
        height: 320,
        child: ParkRefreshView(
          useMaterialRefreshIndicator: useMaterialRefreshIndicator,
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const <Widget>[
              SizedBox(height: 800, child: Text('refresh-content')),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ParkRefreshView', () {
    testWidgets('默认走 ParkRefresh 模式', (tester) async {
      await tester.pumpWidget(
        _buildRefreshApp(onRefresh: () async {}),
      );
      expect(find.byType(ParkRefreshView), findsOneWidget);
      expect(find.byType(ParkRefresh), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('useMaterialRefreshIndicator 为 true 时走原生 RefreshIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildRefreshApp(
          onRefresh: () async {},
          useMaterialRefreshIndicator: true,
        ),
      );
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(ParkRefresh), findsNothing);
    });

    testWidgets('ParkRefresh 模式下下拉超过阈值触发 onRefresh', (tester) async {
      final completer = Completer<void>();
      var refreshCount = 0;

      await tester.pumpWidget(
        _buildRefreshApp(
          onRefresh: () {
            refreshCount++;
            return completer.future;
          },
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, 140));
      await tester.pump();

      expect(refreshCount, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('原生模式下拉触发 onRefresh', (tester) async {
      final completer = Completer<void>();
      var refreshCount = 0;

      await tester.pumpWidget(
        _buildRefreshApp(
          onRefresh: () {
            refreshCount++;
            return completer.future;
          },
          useMaterialRefreshIndicator: true,
        ),
      );

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      // RefreshIndicator 在 snap 动画结束后才调用 onRefresh。
      await tester.pump(const Duration(seconds: 1));

      expect(refreshCount, 1);

      completer.complete();
      await tester.pumpAndSettle();

      expect(refreshCount, 1);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
