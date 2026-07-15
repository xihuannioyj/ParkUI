import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkBadge', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkBadge(count: 5, child: Icon(Icons.notifications))));
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
    testWidgets('红点模式', (tester) async {
      await tester.pumpWidget(_wrap(const ParkBadge(dot: true, child: Icon(Icons.mail))));
      expect(find.byIcon(Icons.mail), findsOneWidget);
    });
    testWidgets('count=0不显示', (tester) async {
      await tester.pumpWidget(_wrap(const ParkBadge(count: 0, child: Icon(Icons.notifications))));
      expect(find.text('0'), findsNothing);
    });
    testWidgets('大数字显示99+', (tester) async {
      await tester.pumpWidget(_wrap(const ParkBadge(count: 150, maxCount: 99, child: Icon(Icons.notifications))));
      expect(find.text('99+'), findsOneWidget);
    });
  });
}
