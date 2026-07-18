import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/src/components/display/park_avatar.dart';
import 'package:park_ui/src/theme/park_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(theme: ThemeData(extensions: [ParkThemeData.light()]), home: Scaffold(body: Center(child: child)));

void main() {
  group('ParkAvatar', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar()));
      expect(find.byType(ParkAvatar), findsOneWidget);
    });
    testWidgets('文字头像', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(text: '张')));
      expect(find.text('张'), findsOneWidget);
    });
    testWidgets('图标头像', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(icon: Icons.person)));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
    testWidgets('custom size', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(text: 'A', size: ParkAvatarSize.large)));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('square shape renders', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(
        text: 'B',
        shape: ParkAvatarShape.square,
      )));
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('status dot renders for online status', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(
        text: 'C',
        status: ParkAvatarStatus.online,
      )));
      expect(find.text('C'), findsOneWidget);
      expect(find.bySemanticsLabel('online status'), findsOneWidget);
    });

    testWidgets('status dot renders for busy status', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(
        text: 'D',
        status: ParkAvatarStatus.busy,
      )));
      expect(find.bySemanticsLabel('busy status'), findsOneWidget);
    });

    testWidgets('onTap callback fires', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(_wrap(ParkAvatar(
        text: 'E',
        onTap: () => tapCount++,
      )));
      await tester.tap(find.byType(ParkAvatar));
      expect(tapCount, 1);
    });

    testWidgets('customSize overrides preset size', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar(
        text: 'F',
        customSize: 100,
      )));
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('fallback to person icon when no source', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatar()));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('ParkAvatarGroup', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatarGroup(
        avatars: [
          ParkAvatar(text: 'A'),
          ParkAvatar(text: 'B'),
          ParkAvatar(text: 'C'),
        ],
      )));
      expect(find.byType(ParkAvatarGroup), findsOneWidget);
    });

    testWidgets('shows overflow count when exceeding maxCount', (tester) async {
      await tester.pumpWidget(_wrap(const ParkAvatarGroup(
        avatars: [
          ParkAvatar(text: 'A'),
          ParkAvatar(text: 'B'),
          ParkAvatar(text: 'C'),
          ParkAvatar(text: 'D'),
          ParkAvatar(text: 'E'),
        ],
        maxCount: 3,
      )));
      expect(find.text('+2'), findsOneWidget);
    });
  });
}
