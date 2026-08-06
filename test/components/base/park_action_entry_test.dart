import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: [ParkThemeData.light()]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('ParkActionIconButton', () {
    testWidgets('renders icon and fires onPressed', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(ParkActionIconButton(
        icon: Icons.add,
        onPressed: () => pressed++,
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionIconButton(
        icon: Icons.edit,
        onPressed: () {},
        tooltip: '编辑',
      )));
      expect(find.byType(Tooltip), findsOneWidget);
      expect(tester.widget<Tooltip>(find.byType(Tooltip)).message, '编辑');
    });

    testWidgets('danger tone uses brand danger color', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionIconButton(
        icon: Icons.delete,
        onPressed: () {},
        tone: ParkActionTone.danger,
      )));
      final icon = tester.widget<ParkIcon>(find.byType(ParkIcon));
      expect(icon.color, const Color(0xFFD9485F));
    });

    testWidgets('primary tone uses brand color', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionIconButton(
        icon: Icons.add,
        onPressed: () {},
      )));
      final icon = tester.widget<ParkIcon>(find.byType(ParkIcon));
      expect(icon.color, ParkThemeData.light().colors.brand);
    });

    testWidgets('custom iconSize is honored', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionIconButton(
        icon: Icons.add,
        onPressed: () {},
        iconSize: 24,
      )));
      final icon = tester.widget<ParkIcon>(find.byType(ParkIcon));
      expect(icon.pixelSize, 24);
    });
  });

  group('ParkActionTile', () {
    testWidgets('renders title, subtitle and trailingText', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionTile(
        icon: Icons.home,
        title: '房源管理',
        subtitle: '管理您的房源信息',
        trailingText: '新',
        onTap: () {},
      )));
      expect(find.text('房源管理'), findsOneWidget);
      expect(find.text('管理您的房源信息'), findsOneWidget);
      expect(find.text('新'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
    });

    testWidgets('fires onTap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_wrap(ParkActionTile(
        icon: Icons.home,
        title: '房源管理',
        onTap: () => tapped++,
      )));
      await tester.tap(find.text('房源管理'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('danger tone uses brand danger color', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionTile(
        icon: Icons.delete,
        title: '删除',
        onTap: () {},
        tone: ParkActionTone.danger,
      )));
      final icon = tester.widget<ParkIcon>(find.byType(ParkIcon).first);
      expect(icon.color, const Color(0xFFD9485F));
    });

    testWidgets('hides subtitle and trailing when empty', (tester) async {
      await tester.pumpWidget(_wrap(ParkActionTile(
        icon: Icons.home,
        title: '房源管理',
        onTap: () {},
      )));
      expect(find.text('房源管理'), findsOneWidget);
    });
  });
}
