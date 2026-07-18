import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/input/park_switch.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

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
    testWidgets('disabled not clickable', (tester) async {
      bool val = false;
      await tester.pumpWidget(_wrap(ParkSwitch(value: val, onChanged: (v) => val = v, disabled: true)));
      await tester.tap(find.byType(ParkSwitch));
      expect(val, false);
    });

    testWidgets('label displays next to switch', (tester) async {
      await tester.pumpWidget(_wrap(ParkSwitch(
        value: false,
        label: 'Enable notifications',
      )));
      expect(find.text('Enable notifications'), findsOneWidget);
    });

    testWidgets('loading state shows spinner', (tester) async {
      await tester.pumpWidget(_wrap(ParkSwitch(
        value: false,
        loading: true,
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('custom checkedValue and uncheckedValue', (tester) async {
      dynamic val = 'no';
      await tester.pumpWidget(_wrap(ParkSwitch(
        value: val,
        checkedValue: 'yes',
        uncheckedValue: 'no',
        onChanged: (v) => val = v,
      )));
      await tester.tap(find.byType(ParkSwitch));
      expect(val, 'yes');
    });

    testWidgets('readOnly prevents interaction', (tester) async {
      bool val = false;
      await tester.pumpWidget(_wrap(ParkSwitch(
        value: val,
        readOnly: true,
        onChanged: (v) => val = v,
      )));
      await tester.tap(find.byType(ParkSwitch));
      expect(val, false);
    });

    testWidgets('different sizes render correctly', (tester) async {
      await tester.pumpWidget(_wrap(ParkSwitch(
        value: false,
        size: ParkSwitchSize.small,
      )));
      expect(find.byType(ParkSwitch), findsOneWidget);

      await tester.pumpWidget(_wrap(ParkSwitch(
        value: false,
        size: ParkSwitchSize.large,
      )));
      expect(find.byType(ParkSwitch), findsOneWidget);
    });
  });
}
