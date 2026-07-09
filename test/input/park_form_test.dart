import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkForm', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(children: [])));
      expect(find.byType(ParkForm), findsOneWidget);
    });
    testWidgets('包含sections', (tester) async {
      await tester.pumpWidget(_wrap(const ParkForm(children: [
        ParkFormSection(title: '分组1', children: [ParkFormItem(label: '字段', child: Text('值'))]),
      ])));
      expect(find.text('分组1'), findsOneWidget);
    });
  });
}
