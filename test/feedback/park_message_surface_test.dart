/// `ParkMessage` 接入表面派生层的测试。
///
/// ## 覆盖矩阵
///
/// - 4 语义填充（info / success / warning / error）× 5 风格 × 明/暗 = 40 组合：
///   标题 / 正文文字色与**语义填充**的对比度 ≥ 4.5:1
/// - glass：渲染 `BackdropFilter`；其余风格不渲染
/// - stripe / flat 零回归：阴影回落到组件原值 `shadows.md`
/// - glass / neo / neon 接管阴影（非 null 且不等于 `shadows.md`）
/// - `ParkSurfaceStyleScope` 局部覆盖生效
///
/// ## 为什么重点测「标题 + 正文」两处文字色与语义填充
///
/// 改造前 `title` 硬编码 `colors.textPrimary`、`content` 硬编码
/// `colors.textSecondary`（分处两地，典型"成对取值漏改"高危点）。
/// 消息填充恒为**语义浅色**（infoLight 等），与语义文字对天然配对，本应恒可读。
/// 但表面令牌在 neon + 深色下会把文字翻转为 `colors.surface`（深 navy），
/// 而填充仍是近黑的 infoLight 深色 —— 若误用令牌会反成"深字深底"。
/// 因此文字色走**语义对**、且二者同进同出，缺一不可。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

const String _kTitle = '操作成功';
const String _kContent = '数据已保存至云端。';

/// 触发一条全局消息并 settle 到内容可见（走真实 overlay 路径）。
Future<void> pumpMessage(
  WidgetTester tester, {
  required ParkThemeData theme,
  required _MsgType type,
  ParkSurfaceStyle? scopeStyle,
  Duration duration = const Duration(seconds: 30),
}) async {
  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(
      body: Builder(
        builder: (BuildContext context) => ElevatedButton(
          onPressed: () => _triggerType(context, type, duration),
          child: const Text('触发'),
        ),
      ),
    ),
  );

  if (scopeStyle != null) {
    app = ParkSurfaceStyleScope(style: scopeStyle, child: app);
  }

  await tester.pumpWidget(app);
  await tester.tap(find.text('触发'));
  // 冲刷 post-frame callback（OverlayEntry 在此插入）。
  await tester.pump();
  // 让 slide/fade 动画跑完，确保内容 widget 已挂载。
  await tester.pump(const Duration(milliseconds: 350));
}

enum _MsgType { info, success, warning, error }

void _triggerType(BuildContext context, _MsgType type, Duration duration) {
  switch (type) {
    case _MsgType.info:
      ParkMessage.info(context, _kTitle, content: _kContent, duration: duration);
    case _MsgType.success:
      ParkMessage.success(context, _kTitle, content: _kContent, duration: duration);
    case _MsgType.warning:
      ParkMessage.warning(context, _kTitle, content: _kContent, duration: duration);
    case _MsgType.error:
      ParkMessage.error(context, _kTitle, content: _kContent, duration: duration);
  }
}

/// 取消息**容器**的 decoration（真实渲染路径：标题文字向上找祖先 Container）。
BoxDecoration messageDecoration(WidgetTester tester) {
  final Finder finder = find
      .ancestor(
        of: find.text(_kTitle),
        matching: find.byType(Container),
      )
      .first;
  final Container container = tester.widget<Container>(finder);
  final Decoration? d = container.decoration;
  if (d is BoxDecoration) return d;
  throw StateError('未找到消息容器 decoration');
}

Color titleColorOf(WidgetTester tester) =>
    tester.widget<Text>(find.text(_kTitle)).style!.color!;

Color contentColorOf(WidgetTester tester) =>
    tester.widget<Text>(find.text(_kContent)).style!.color!;

/// 把可能半透明的填充合成到不透明页面背景上（消息填充为不透明语义色，
/// 合成后仍是自身；保留合成步骤以防未来填充变半透明）。
Color effectiveFill(BoxDecoration d, ParkThemeData theme) =>
    Color.alphaBlend(d.color!, theme.colors.background);

void main() {
  // ==========================================================================
  // 1. 4 语义填充 × 5 风格 × 明/暗：标题 / 正文与语义填充的对比度
  // ==========================================================================
  group('ParkMessage · 4 填充 × 5 风格 × 明/暗 · 文字可读性', () {
    for (final _MsgType type in _MsgType.values) {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        for (final Brightness brightness in Brightness.values) {
          final String label = '${type.name} / $style / ${brightness.name}';

          testWidgets('$label · 标题与语义填充 ≥ 4.5:1', (
            WidgetTester tester,
          ) async {
            final ParkThemeData theme =
                (brightness == Brightness.dark
                        ? ParkThemeData.dark()
                        : ParkThemeData.light())
                    .copyWith(surfaceStyle: style);

            await pumpMessage(tester, theme: theme, type: type);

            final Color fill =
                effectiveFill(messageDecoration(tester), theme);
            final double ratio =
                ParkColors.contrastRatio(titleColorOf(tester), fill);
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$label 标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
            );
          });

          testWidgets('$label · 正文与语义填充 ≥ 4.5:1', (
            WidgetTester tester,
          ) async {
            final ParkThemeData theme =
                (brightness == Brightness.dark
                        ? ParkThemeData.dark()
                        : ParkThemeData.light())
                    .copyWith(surfaceStyle: style);

            await pumpMessage(tester, theme: theme, type: type);

            final Color fill =
                effectiveFill(messageDecoration(tester), theme);
            final double ratio =
                ParkColors.contrastRatio(contentColorOf(tester), fill);
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '$label 正文对比度仅 ${ratio.toStringAsFixed(2)}:1',
            );
          });
        }
      }
    }

    // 🔴 neon + 深色是最易踩坑的组合：若误用表面令牌文字（深 navy）配近黑语义填充
    // 会"深字深底"。这里显式锁"对比度达标"，与上面矩阵重叠但语义更锐利。
    testWidgets('neon + dark · 标题/正文与语义填充对比度 ≥ 4.5（防深字深底）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await pumpMessage(tester, theme: theme, type: _MsgType.info);

      final Color fill = effectiveFill(messageDecoration(tester), theme);
      expect(
        ParkColors.contrastRatio(titleColorOf(tester), fill),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        ParkColors.contrastRatio(contentColorOf(tester), fill),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  // ==========================================================================
  // 2. 零回归：stripe / flat 的阴影回落到组件原值
  // ==========================================================================
  group('ParkMessage · stripe/flat 零回归', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.flat,
    ]) {
      testWidgets('$style · 阴影回落到组件原值 shadows.md（不是风格阴影）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpMessage(tester, theme: theme, type: _MsgType.info);

        final List<BoxShadow>? shadows =
            messageDecoration(tester).boxShadow;
        expect(shadows, equals(theme.shadows.md));
      });

      testWidgets('$style · 圆角保持组件原值 radius.brMd', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpMessage(tester, theme: theme, type: _MsgType.info);

        expect(
          messageDecoration(tester).borderRadius,
          equals(BorderRadius.circular(theme.radius.brMd)),
        );
      });

      testWidgets('$style · 填充等于 infoLight（与改造前一致）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpMessage(tester, theme: theme, type: _MsgType.info);

        expect(messageDecoration(tester).color, equals(theme.colors.infoLight));
      });
    }

    testWidgets('所有风格 · 无描边（消息无 bordered 语义）', (
      WidgetTester tester,
    ) async {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpMessage(tester, theme: theme, type: _MsgType.info);

        expect(
          messageDecoration(tester).border,
          isNull,
          reason: '$style 消息不应凭空出现描边',
        );
      }
    });
  });

  // ==========================================================================
  // 3. 非 stripe 风格接管阴影
  // ==========================================================================
  group('ParkMessage · 非 stripe 风格接管阴影', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.glass,
      ParkSurfaceStyle.neo,
      ParkSurfaceStyle.neon,
    ]) {
      testWidgets('$style · 阴影不为 null 且不等于组件原值', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpMessage(tester, theme: theme, type: _MsgType.info);

        final List<BoxShadow>? shadows =
            messageDecoration(tester).boxShadow;
        expect(
          shadows,
          isNotNull,
          reason: '$style 应自带阴影（否则风格接管无意义）',
        );
        expect(
          shadows,
          isNot(equals(theme.shadows.md)),
          reason: '$style 的阴影应与浮层兜底值不同，即风格确实接管了',
        );
      });
    }
  });

  // ==========================================================================
  // 4. 玻璃风格
  // ==========================================================================
  group('ParkMessage · 玻璃风格', () {
    testWidgets('glass 渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpMessage(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        type: _MsgType.info,
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe 不渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpMessage(tester, theme: ParkThemeData.light(), type: _MsgType.info);

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 5. 局部 Scope 覆盖
  // ==========================================================================
  group('ParkMessage · ParkSurfaceStyleScope 局部覆盖', () {
    testWidgets('全局 stripe + 局部 glass → 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpMessage(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
        type: _MsgType.info,
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('全局 glass + 局部 stripe → 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpMessage(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        scopeStyle: ParkSurfaceStyle.stripe,
        type: _MsgType.info,
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 6. 派生函数直测（成对取值：titleColor / bodyColor 与语义填充同源）
  // ==========================================================================
  group('ParkMessage · resolveParkMessageSurface 成对取值', () {
    for (final _MsgType type in _MsgType.values) {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        for (final Brightness brightness in Brightness.values) {
          testWidgets(
              '${type.name} / $style / ${brightness.name} · 文字对比语义填充', (
            WidgetTester tester,
          ) async {
            final ParkThemeData theme =
                (brightness == Brightness.dark
                        ? ParkThemeData.dark()
                        : ParkThemeData.light())
                    .copyWith(surfaceStyle: style);

            late ParkMessageSurface resolved;
            await tester.pumpWidget(
              MaterialApp(
                theme: ThemeData(
                  extensions: <ThemeExtension<ParkThemeData>>[theme],
                ),
                home: Builder(
                  builder: (BuildContext ctx) {
                    resolved = resolveParkMessageSurface(
                      park: theme,
                      context: ctx,
                      backgroundColor: theme.colors.infoLight,
                    );
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );

            final Color fill = Color.alphaBlend(
              resolved.fill,
              theme.colors.background,
            );
            expect(
              ParkColors.contrastRatio(resolved.titleColor, fill),
              greaterThanOrEqualTo(4.5),
            );
            expect(
              ParkColors.contrastRatio(resolved.bodyColor, fill),
              greaterThanOrEqualTo(4.5),
            );
          });
        }
      }
    }

    testWidgets('圆角恒为 radius.brMd（不消费 cards 语义）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      late ParkMessageSurface resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: <ThemeExtension<ParkThemeData>>[theme],
          ),
          home: Builder(
            builder: (BuildContext ctx) {
              resolved = resolveParkMessageSurface(
                park: theme,
                context: ctx,
                backgroundColor: theme.colors.infoLight,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        resolved.radius,
        equals(BorderRadius.circular(theme.radius.brMd)),
      );
    });
  });
}
