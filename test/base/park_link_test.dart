import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/base/park_link.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkLink - 基本渲染', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        '链接文本',
        onTap: null,
      )));
      expect(find.text('链接文本'), findsOneWidget);
    });

    testWidgets('可点击', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(ParkLink(
        '点我',
        onTap: () => pressed++,
      )));
      await tester.tap(find.text('点我'));
      expect(pressed, 1);
    });

    testWidgets('disabled not clickable', (tester) async {
      int pressed = 0;
      await tester.pumpWidget(_wrap(ParkLink(
        'Disabled',
        disabled: true,
        onTap: () => pressed++,
      )));
      await tester.tap(find.text('Disabled'));
      expect(pressed, 0);
    });

    testWidgets('icon displays before text', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'With Icon',
        icon: Icon(Icons.link),
      )));
      expect(find.byIcon(Icons.link), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('trailingIcon displays after text', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'External',
        trailingIcon: Icon(Icons.open_in_new),
      )));
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      expect(find.text('External'), findsOneWidget);
    });

    testWidgets('underline variant renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'Underlined',
        variant: ParkLinkVariant.underline,
      )));
      expect(find.text('Underlined'), findsOneWidget);
    });

    testWidgets('loading state shows spinner', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'Loading',
        loading: true,
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('different link styles render', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'Primary',
        linkStyle: ParkLinkStyle.primary,
      )));
      expect(find.text('Primary'), findsOneWidget);

      await tester.pumpWidget(_wrap(const ParkLink(
        'Danger',
        linkStyle: ParkLinkStyle.danger,
      )));
      expect(find.text('Danger'), findsOneWidget);
    });

    testWidgets('different sizes render', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'Small',
        linkSize: ParkLinkSize.small,
      )));
      expect(find.text('Small'), findsOneWidget);

      await tester.pumpWidget(_wrap(const ParkLink(
        'Large',
        linkSize: ParkLinkSize.large,
      )));
      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets('custom color overrides default', (tester) async {
      await tester.pumpWidget(_wrap(const ParkLink(
        'Custom',
        color: Colors.purple,
      )));
      expect(find.text('Custom'), findsOneWidget);
    });
  });
}
