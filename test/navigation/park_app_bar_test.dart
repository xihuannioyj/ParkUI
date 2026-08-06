import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

/// 测试辅助：以 Park 主题扩展包裹页面。
Widget _wrap(Widget child, {ParkThemeData? parkTheme}) => MaterialApp(
      theme: ThemeData(extensions: [parkTheme ?? ParkThemeData.light()]),
      home: child,
    );

/// 测试辅助：根路由放一个按钮，点击推入带 ParkAppBar 的第二页（形成可弹出路由）。
Future<void> _pumpTwoRoutes(
  WidgetTester tester, {
  ParkThemeData? parkTheme,
  PreferredSizeWidget Function(BuildContext context)? secondAppBar,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: ThemeData(extensions: [parkTheme ?? ParkThemeData.light()]),
    home: Builder(
      builder: (BuildContext context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (BuildContext ctx) => Scaffold(
                  appBar: secondAppBar?.call(ctx) ??
                      const ParkAppBar(title: '第二页'),
                ),
              ));
            },
            child: const Text('go'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

void main() {
  group('ParkAppBar', () {
    testWidgets('渲染 String 标题并走 Park 排版令牌', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(appBar: const ParkAppBar(title: '页面标题'))),
      );
      expect(find.text('页面标题'), findsOneWidget);

      final Text titleText = tester.widget<Text>(find.text('页面标题'));
      final ParkTypography typography = ParkThemeData.light().typography;
      expect(titleText.style?.fontSize, typography.sizeH3);
      expect(titleText.style?.fontWeight, typography.weightMedium);
    });

    testWidgets('渲染 Widget 标题', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.storefront, size: 20),
                SizedBox(width: 8),
                Text('品牌商城'),
              ],
            ),
          ),
        )),
      );
      expect(find.text('品牌商城'), findsOneWidget);
      expect(find.byIcon(Icons.storefront), findsOneWidget);
    });

    testWidgets('可弹出路由自动显示返回按钮且可点击返回', (tester) async {
      await _pumpTwoRoutes(tester);
      expect(find.text('第二页'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('第二页'), findsNothing);
      expect(find.text('go'), findsOneWidget);
    });

    testWidgets('返回按钮带 Semantics 标签（zh：返回）', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpTwoRoutes(tester);
      expect(find.bySemanticsLabel('返回'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('automaticallyImplyLeading: false 不显示返回按钮',
        (tester) async {
      await _pumpTwoRoutes(
        tester,
        secondAppBar: (BuildContext _) => const ParkAppBar(
          title: '第二页',
          automaticallyImplyLeading: false,
        ),
      );
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('自定义 leading 优先于自动返回按钮', (tester) async {
      await _pumpTwoRoutes(
        tester,
        secondAppBar: (BuildContext _) => const ParkAppBar(
          title: '第二页',
          leading: Icon(Icons.menu),
        ),
      );
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('actions 渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: ParkAppBar(
            title: '首页',
            actions: <Widget>[
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        )),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('暗色模式：背景默认走 park.colors.surface（dark）',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(appBar: const ParkAppBar(title: '暗色')),
          parkTheme: ParkThemeData.dark(),
        ),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.backgroundColor, ParkThemeData.dark().colors.surface);

      final Text titleText = tester.widget<Text>(find.text('暗色'));
      expect(titleText.style?.color, ParkThemeData.dark().colors.textPrimary);
    });

    testWidgets('亮色模式：背景默认走 park.colors.surface（light）',
        (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(appBar: const ParkAppBar(title: '亮色'))),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.backgroundColor, ParkThemeData.light().colors.surface);
    });

    testWidgets('自定义 backgroundColor / foregroundColor / elevation 生效',
        (tester) async {
      final ParkThemeData park = ParkThemeData.light();
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: ParkAppBar(
            title: '品牌色',
            backgroundColor: park.colors.brand,
            foregroundColor: park.colors.textOnBrand,
            elevation: 4,
          ),
        )),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.backgroundColor, park.colors.brand);
      expect(bar.foregroundColor, park.colors.textOnBrand);
      expect(bar.elevation, 4);

      final Text titleText = tester.widget<Text>(find.text('品牌色'));
      expect(titleText.style?.color, park.colors.textOnBrand);
    });

    testWidgets('centerTitle / titleSpacing 透传', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(title: '居中', centerTitle: true),
        )),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.centerTitle, true);
      expect(bar.titleSpacing, NavigationToolbar.kMiddleSpacing);
    });

    testWidgets('bottom 计入 preferredSize', (tester) async {
      const ParkAppBar bar = ParkAppBar(
        title: '商品',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: SizedBox(height: 44, child: Center(child: Text('搜索栏'))),
        ),
      );
      expect(bar.preferredSize.height, kToolbarHeight + 44);

      await tester.pumpWidget(_wrap(const Scaffold(appBar: bar)));
      expect(find.text('搜索栏'), findsOneWidget);
    });

    testWidgets('surfaceTintColor 透传至 AppBar', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(
            title: '透明',
            surfaceTintColor: Colors.transparent,
          ),
        )),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.surfaceTintColor, Colors.transparent);
    });

    testWidgets('toolbarHeight 改变工具栏高度及 preferredSize',
        (tester) async {
      const ParkAppBar bar = ParkAppBar(
        title: '高栏',
        toolbarHeight: 80,
      );
      expect(bar.preferredSize.height, 80);

      await tester.pumpWidget(_wrap(const Scaffold(appBar: bar)));
      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.toolbarHeight, 80);
    });

    testWidgets('flexibleSpace 渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(
            title: '背景',
            flexibleSpace: DecoratedBox(
              key: Key('flex_bg'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
          ),
        )),
      );
      expect(find.byKey(const Key('flex_bg')), findsOneWidget);
      final AppBar appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.flexibleSpace, isNotNull);
    });

    testWidgets('subtitle 渲染在标题下方', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(
            title: '订单详情',
            subtitle: '订单号：20240601001',
          ),
        )),
      );
      expect(find.text('订单详情'), findsOneWidget);
      expect(find.text('订单号：20240601001'), findsOneWidget);
    });

    testWidgets('shadowColor / shape / iconTheme 透传至 AppBar', (tester) async {
      const ShapeBorder shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      );
      const IconThemeData iconTheme = IconThemeData(size: 22, color: Colors.red);
      await tester.pumpWidget(
        _wrap(const Scaffold(
          appBar: ParkAppBar(
            title: '样式',
            shadowColor: Colors.orange,
            shape: shape,
            iconTheme: iconTheme,
          ),
        )),
      );
      final AppBar bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.shadowColor, Colors.orange);
      expect(bar.shape, shape);
      expect(bar.iconTheme?.size, 22);
      expect(bar.iconTheme?.color, Colors.red);
    });

    testWidgets('subtitle 使用 bodySmall 排版令牌', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(
            title: '标题',
            subtitle: '副标题',
          ),
        )),
      );
      final Text subtitleText =
          tester.widget<Text>(find.text('副标题'));
      final ParkTypography typography = ParkThemeData.light().typography;
      expect(subtitleText.style?.fontSize, typography.sizeBodySmall);
    });

    testWidgets('仅 subtitle 无 title 时仍渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          appBar: const ParkAppBar(subtitle: '仅副标题'),
        )),
      );
      expect(find.text('仅副标题'), findsOneWidget);
    });
  });

  group('ParkSliverAppBar', () {
    testWidgets('CustomScrollView 中渲染标题', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: const <Widget>[
              ParkSliverAppBar(title: '发现', expandedHeight: 240),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      expect(find.text('发现'), findsOneWidget);

      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.expandedHeight, 240);
    });

    testWidgets('pinned / floating / stretch 透传', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: const <Widget>[
              ParkSliverAppBar(
                title: '消息',
                pinned: true,
                floating: true,
                stretch: true,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.pinned, true);
      expect(sliver.floating, true);
      expect(sliver.stretch, true);
      expect(sliver.expandedHeight, 200); // 默认展开高度
    });

    testWidgets('可弹出路由自动显示返回按钮且可点击返回', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [ParkThemeData.light()]),
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (BuildContext _) => Scaffold(
                      body: CustomScrollView(
                        slivers: const <Widget>[
                          ParkSliverAppBar(title: '第二页'),
                          SliverToBoxAdapter(child: SizedBox(height: 800)),
                        ],
                      ),
                    ),
                  ));
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('第二页'), findsNothing);
    });

    testWidgets('暗色模式：背景默认走 park.colors.surface（dark）',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          Scaffold(
            body: CustomScrollView(
              slivers: const <Widget>[
                ParkSliverAppBar(title: '暗色'),
                SliverToBoxAdapter(child: SizedBox(height: 800)),
              ],
            ),
          ),
          parkTheme: ParkThemeData.dark(),
        ),
      );
      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.backgroundColor, ParkThemeData.dark().colors.surface);
    });

    testWidgets('actions 渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              ParkSliverAppBar(
                title: '订单',
                actions: <Widget>[
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('surfaceTintColor 透传至 SliverAppBar', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: const <Widget>[
              ParkSliverAppBar(
                title: '透明',
                surfaceTintColor: Colors.transparent,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.surfaceTintColor, Colors.transparent);
    });

    testWidgets('toolbarHeight 透传至 SliverAppBar', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: const <Widget>[
              ParkSliverAppBar(
                title: '高栏',
                toolbarHeight: 72,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.toolbarHeight, 72);
    });

    testWidgets('flexibleSpace 渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: const <Widget>[
              ParkSliverAppBar(
                title: '背景',
                flexibleSpace: DecoratedBox(
                  key: Key('sliver_flex_bg'),
                  decoration: BoxDecoration(color: Colors.green),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      expect(find.byKey(const Key('sliver_flex_bg')), findsOneWidget);
      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.flexibleSpace, isNotNull);
    });

    testWidgets('subtitle 渲染在标题下方', (tester) async {
      await tester.pumpWidget(
        _wrap(Scaffold(
          body: CustomScrollView(
            slivers: const <Widget>[
              ParkSliverAppBar(
                title: '发现',
                subtitle: '探索精彩内容',
                expandedHeight: 240,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      expect(find.text('发现'), findsOneWidget);
      expect(find.text('探索精彩内容'), findsOneWidget);
    });

    testWidgets('shadowColor / shape / iconTheme 透传至 SliverAppBar',
        (tester) async {
      const ShapeBorder shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      );
      const IconThemeData iconTheme =
          IconThemeData(size: 20, color: Colors.blue);
      await tester.pumpWidget(
        _wrap(const Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              ParkSliverAppBar(
                title: '样式',
                shadowColor: Colors.teal,
                shape: shape,
                iconTheme: iconTheme,
              ),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        )),
      );
      final SliverAppBar sliver =
          tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliver.shadowColor, Colors.teal);
      expect(sliver.shape, shape);
      expect(sliver.iconTheme?.size, 20);
      expect(sliver.iconTheme?.color, Colors.blue);
    });
  });
}
