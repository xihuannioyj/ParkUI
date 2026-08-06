import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [ParkThemeData.light()]),
      home: Scaffold(body: Center(child: child)),
    );

/// 放大测试视口，确保 ListView 中所有骨架项都被构建。
Future<void> _pumpTall(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(child));
}

/// 匹配圆形头像骨架：width == height == size。
Finder _avatarOfSize(double size) => find.byWidgetPredicate(
      (Widget w) =>
          w is ParkSkeleton &&
          w.width == size &&
          w.height == size &&
          w.borderRadius == BorderRadius.circular(size / 2),
    );

/// 匹配圆角为 18 的卡片容器。
Finder _cardWithRadius18() => find.byWidgetPredicate(
      (Widget w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(18),
    );

void main() {
  group('ParkShimmerCard', () {
    testWidgets('默认参数渲染不抛异常', (tester) async {
      await tester.pumpWidget(_wrap(const ParkShimmerCard()));
      expect(find.byType(ParkShimmerCard), findsOneWidget);
      expect(find.byType(ParkSkeleton), findsWidgets);
    });

    testWidgets('hasAvatar 为 true 时展示头像占位', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkShimmerCard(hasAvatar: true)),
      );
      expect(_avatarOfSize(40), findsOneWidget);
    });

    testWidgets('自定义 avatarSize 与 lines', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkShimmerCard(hasAvatar: true, avatarSize: 56, lines: 2)),
      );
      expect(_avatarOfSize(56), findsOneWidget);
      // 2 行文本 + 1 头像 = 至少 3 个骨架块
      expect(find.byType(ParkSkeleton), findsWidgets);
    });
  });

  group('ParkLeaseListSkeleton', () {
    testWidgets('默认生成 itemCount 个卡片', (tester) async {
      await _pumpTall(tester, const ParkLeaseListSkeleton());
      expect(find.byType(ParkShimmerCard), findsNWidgets(4));
      expect(find.byType(ParkSkeleton), findsWidgets);
    });

    testWidgets('itemCount 自定义', (tester) async {
      await _pumpTall(tester, const ParkLeaseListSkeleton(itemCount: 3));
      expect(find.byType(ParkShimmerCard), findsNWidgets(3));
    });

    testWidgets('showSummary 为 true 时顶部多一个汇总卡片', (tester) async {
      await _pumpTall(
        tester,
        const ParkLeaseListSkeleton(showSummary: true, itemCount: 4),
      );
      expect(find.byType(ParkShimmerCard), findsNWidgets(4));
      expect(_cardWithRadius18(), findsOneWidget);
    });
  });

  group('ParkRoomListSkeleton', () {
    testWidgets('默认生成 itemCount 个房间卡片', (tester) async {
      await _pumpTall(tester, const ParkRoomListSkeleton());
      // 每个卡片 4 个圆形头像骨架（22）
      expect(_avatarOfSize(22), findsNWidgets(16));
      expect(find.byType(ParkSkeleton), findsWidgets);
    });

    testWidgets('itemCount 自定义', (tester) async {
      await _pumpTall(tester, const ParkRoomListSkeleton(itemCount: 2));
      expect(_avatarOfSize(22), findsNWidgets(8));
    });
  });

  group('ParkDetailPageSkeleton', () {
    testWidgets('默认生成 sectionCount 个详情卡片', (tester) async {
      await tester.pumpWidget(_wrap(const ParkDetailPageSkeleton()));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(_cardWithRadius18(), findsNWidgets(3));
    });

    testWidgets('sectionCount 自定义', (tester) async {
      await tester.pumpWidget(
        _wrap(const ParkDetailPageSkeleton(sectionCount: 2)),
      );
      expect(_cardWithRadius18(), findsNWidgets(2));
    });
  });
}
