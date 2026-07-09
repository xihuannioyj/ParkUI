import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _buildRefreshApp({
  required Future<void> Function() onRefresh,
  ScrollController? controller,
  double threshold = 80,
}) {
  return MaterialApp(
    theme: ThemeData(
      extensions: <ThemeExtension<dynamic>>[ParkThemeData.light()],
    ),
    home: Scaffold(
      body: SizedBox(
        height: 320,
        child: ParkRefresh(
          refreshThreshold: threshold,
          onRefresh: onRefresh,
          child: ListView(
            controller: controller,
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
  testWidgets('ParkRefresh 下拉超过阈值后触发刷新并显示完成态', (WidgetTester tester) async {
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
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('ParkRefresh 下拉不足阈值时不触发刷新', (WidgetTester tester) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      _buildRefreshApp(
        threshold: 100,
        onRefresh: () async {
          refreshCount++;
        },
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, 40));
    await tester.pumpAndSettle();

    expect(refreshCount, 0);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('ParkRefresh 非顶部位置下拉时不触发刷新', (WidgetTester tester) async {
    var refreshCount = 0;
    final controller = ScrollController(initialScrollOffset: 120);

    await tester.pumpWidget(
      _buildRefreshApp(
        controller: controller,
        onRefresh: () async {
          refreshCount++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, 50));
    await tester.pumpAndSettle();

    expect(refreshCount, 0);
  });
}
