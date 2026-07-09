import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkUpload', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkUpload()));
      expect(find.byType(ParkUpload), findsOneWidget);
    });
    testWidgets('显示上传按钮', (tester) async {
      await tester.pumpWidget(_wrap(const ParkUpload()));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
