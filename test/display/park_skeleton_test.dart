import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkSkeleton', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSkeleton()));
      expect(find.byType(ParkSkeleton), findsOneWidget);
    });
    testWidgets('自定义宽高', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSkeleton(width: 200, height: 20)));
      expect(find.byType(ParkSkeleton), findsOneWidget);
    });
    testWidgets('圆形', (tester) async {
      await tester.pumpWidget(_wrap(const ParkSkeleton.circle(size: 48)));
      expect(find.byType(ParkSkeleton), findsOneWidget);
    });
  });
}
