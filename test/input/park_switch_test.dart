import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkSwitch', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(ParkSwitch(value: false)));
      expect(find.byType(ParkSwitch), findsOneWidget);
    });
    testWidgets('点击切换', (tester) async {
      bool val = false;
      await tester.pumpWidget(_wrap(ParkSwitch(value: val, onChanged: (v) => val = v)));
      await tester.tap(find.byType(ParkSwitch));
      expect(val, true);
    });
    testWidgets('disabled不可点击', (tester) async {
      bool val = false;
      await tester.pumpWidget(_wrap(ParkSwitch(value: val, onChanged: (v) => val = v, disabled: true)));
      await tester.tap(find.byType(ParkSwitch));
      expect(val, false);
    });
  });
}
