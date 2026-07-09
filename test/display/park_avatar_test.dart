import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkAvatar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar()));
      expect(find.byType(ParkAvatar), findsOneWidget);
    });
    testWidgets('文字头像', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar.text('张')));
      expect(find.text('张'), findsOneWidget);
    });
    testWidgets('图标头像', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar.icon(Icons.person)));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
    testWidgets('自定义大小', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar.text('A', size: 64)));
      expect(find.text('A'), findsOneWidget);
    });
  });
}
