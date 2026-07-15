import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

Widget _wrapWithL10n(Widget child, ParkLocalizations l10n) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      builder: (_, c) => ParkLocalizationsWidget(
        localizations: l10n,
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ParkEmpty', () {
    testWidgets('创建不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkEmpty()));
      expect(find.byType(ParkEmpty), findsOneWidget);
    });

    testWidgets('自定义文案', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkEmpty(description: '没有数据哦')),
      );
      expect(find.text('没有数据哦'), findsOneWidget);
    });

    testWidgets('自定义图标', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkEmpty(icon: Icons.inbox)),
      );
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    // ── ParkEmptyType: noData ──
    testWidgets('noData 默认使用 inbox 图标和 l10n.noData', (tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          const ParkEmpty(type: ParkEmptyType.noData),
          ParkLocalizationsEn(),
        ),
      );
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
    });

    // ── ParkEmptyType: noResults ──
    testWidgets('noResults 使用 search_off 图标和 l10n.noSearchResults',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          const ParkEmpty(type: ParkEmptyType.noResults),
          ParkLocalizationsEn(),
        ),
      );
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No search results'), findsOneWidget);
    });

    testWidgets('noResults 可覆盖图标', (tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          const ParkEmpty(
            type: ParkEmptyType.noResults,
            icon: Icons.search,
          ),
          ParkLocalizationsEn(),
        ),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsNothing);
    });

    testWidgets('noResults 可覆盖文案', (tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          const ParkEmpty(
            type: ParkEmptyType.noResults,
            description: '什么都没找到',
          ),
          ParkLocalizationsEn(),
        ),
      );
      expect(find.text('什么都没找到'), findsOneWidget);
      expect(find.text('No search results'), findsNothing);
    });

    // ── ParkEmptyType: noPermission ──
    testWidgets('noPermission 使用 lock 图标和 l10n.noPermission',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          const ParkEmpty(type: ParkEmptyType.noPermission),
          ParkLocalizationsEn(),
        ),
      );
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('No permission'), findsOneWidget);
    });

    // ── 向后兼容 ──
    testWidgets('不传 type 时行为向后兼容（渲染默认图标和文案）',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithL10n(
          const ParkEmpty(),
          ParkLocalizationsZh(),
        ),
      );
      // 默认 type=noData → inbox 图标 + "暂无数据"
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('暂无数据'), findsOneWidget);
    });

    // ── action buttons ──
    testWidgets('actions 在描述下方渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkEmpty(
            actions: [
              ParkButton(
                variant: ParkButtonVariant.primary,
                onPressed: null,
                child: Text('重试'),
              ),
            ],
          ),
        ),
      );
      expect(find.text('重试'), findsOneWidget);
    });

    // ── 自定义 image 优先于 type 图标 ──
    testWidgets('image 优先于 type 默认图标', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const ParkEmpty(
            type: ParkEmptyType.noResults,
            image: Icon(Icons.star, key: ValueKey('custom_image')),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('custom_image')), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsNothing);
    });
  });
}
