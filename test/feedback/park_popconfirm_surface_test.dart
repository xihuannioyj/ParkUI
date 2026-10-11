/// `ParkPopconfirm` 接入表面派生层的测试。
///
/// ## 覆盖矩阵
///
/// - 5 风格 × 明/暗 = 10 组合：标题 / 描述文字色与容器 fill 的对比度 ≥ 4.5:1
/// - `danger` / `confirmLoading`：只改按钮语义色，**不改容器材质**
/// - stripe / flat 零回归：阴影回落到组件原值、圆角保持 `radius.lg`
/// - glass：渲染 `BackdropFilter`；其余风格不渲染
/// - `ParkSurfaceStyleScope` 局部覆盖生效
///
/// ## 为什么重点测「标题 + 描述」两处文字色
///
/// 改造前 `title` 硬编码 `colors.textPrimary`、`description` 硬编码
/// `colors.textSecondary`（分处两地，典型"成对取值漏改"高危点）。
/// 容器 fill 一旦改由风格令牌决定，neon + 深色底下 fill 翻转为近白，
/// 两处文字都会撞成 1.00:1（白底白字）。因此二者**同进同出**，缺一不可。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_ui/park_ui.dart';

const String _kTitle = '确认删除？';
const String _kDescription = '删除后将无法恢复，请确认操作。';

/// 打开一个气泡确认框并 settle。
Future<void> pumpPopconfirm(
  WidgetTester tester, {
  required ParkThemeData theme,
  bool danger = false,
  bool confirmLoading = false,
  bool withIcon = false,
  ParkSurfaceStyle? scopeStyle,
}) async {
  Widget app = MaterialApp(
    theme: ThemeData(extensions: <ThemeExtension<ParkThemeData>>[theme]),
    home: Scaffold(
      body: Center(
        child: ParkPopconfirm(
          title: _kTitle,
          description: _kDescription,
          icon: withIcon ? Icons.help_outline : null,
          danger: danger,
          confirmLoading: confirmLoading,
          child: const Text('删除'),
        ),
      ),
    ),
  );

  if (scopeStyle != null) {
    app = ParkSurfaceStyleScope(style: scopeStyle, child: app);
  }

  await tester.pumpWidget(app);
  await tester.tap(find.text('删除'));
  await tester.pump();
}

/// 取气泡**容器**的 decoration。
///
/// 走真实渲染路径：从标题文字向上找祖先 Container —— 这正是本次改动真正
/// 影响的"容器元素 vs 容器 fill"关系，而不是拿文字去比 `colors.background`
/// 那种本来就恒真的路径。
BoxDecoration bubbleDecoration(WidgetTester tester) {
  final Finder finder = find
      .ancestor(
        of: find.text(_kTitle),
        matching: find.byType(Container),
      )
      .first;
  final Container container = tester.widget<Container>(finder);
  final Decoration? d = container.decoration;
  if (d is BoxDecoration) return d;
  throw StateError('未找到气泡容器 decoration');
}

/// 取标题文字的实际渲染色。
Color titleColorOf(WidgetTester tester) {
  return tester.widget<Text>(find.text(_kTitle)).style!.color!;
}

/// 取描述文字的实际渲染色。
Color descriptionColorOf(WidgetTester tester) {
  return tester.widget<Text>(find.text(_kDescription)).style!.color!;
}

/// 把可能半透明的填充合成到不透明页面背景上。
///
/// 🔴 `ParkColors.contrastRatio` 只读 r/g/b、**忽略 alpha**。glass 风格的
/// fill 是 `surface@0.55`，直接拿它算对比度在数学上是无效的（算的是"未合成"
/// 的纯色）。必须先 alpha 合成到不透明底再算。
Color effectiveFill(BoxDecoration d, ParkThemeData theme) {
  return Color.alphaBlend(d.color!, theme.colors.background);
}

void main() {
  // ==========================================================================
  // 1. 5 风格 × 明/暗：标题 / 描述与容器 fill 的对比度
  // ==========================================================================
  group('ParkPopconfirm · 5 风格 × 明/暗 · 文字可读性', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        final String label = '$style / ${brightness.name}';

        testWidgets('$label · 标题与容器 fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpPopconfirm(tester, theme: theme);

          final Color fill = effectiveFill(bubbleDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            titleColorOf(tester),
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label 标题对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });

        testWidgets('$label · 描述与容器 fill ≥ 4.5:1', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          await pumpPopconfirm(tester, theme: theme);

          final Color fill = effectiveFill(bubbleDecoration(tester), theme);
          final double ratio = ParkColors.contrastRatio(
            descriptionColorOf(tester),
            fill,
          );
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label 描述对比度仅 ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    }

    // 🔴 neon 是唯一有 isDark 分支的风格，单独锁"文字 != fill"。
    // 只测 stripe 等于测不出来 —— 这是本项目反复强调的教训。
    testWidgets('neon + dark · 标题/描述都不等于 fill（防白底白字）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await pumpPopconfirm(tester, theme: theme);

      final Color fill = bubbleDecoration(tester).color!;
      expect(
        titleColorOf(tester),
        isNot(equals(fill)),
        reason: 'neon+dark 下 fill 翻转为近白，标题若仍用 textPrimary 即白底白字',
      );
      expect(descriptionColorOf(tester), isNot(equals(fill)));
    });

    testWidgets('neon + dark · 沿用 textPrimary 会撞成 1.00:1（反证）', (
      WidgetTester tester,
    ) async {
      final ParkThemeData theme = ParkThemeData.dark().copyWith(
        surfaceStyle: ParkSurfaceStyle.neon,
      );

      await pumpPopconfirm(tester, theme: theme);

      final Color fill = bubbleDecoration(tester).color!;
      expect(
        ParkColors.contrastRatio(theme.colors.textPrimary, fill),
        lessThan(1.5),
        reason: '这正是"若不改文字色会白底白字"的证据',
      );
    });
  });

  // ==========================================================================
  // 2. danger / confirmLoading 只改按钮，不改容器材质
  // ==========================================================================
  group('ParkPopconfirm · danger / confirmLoading 不影响容器材质', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.neon,
    ]) {
      testWidgets('$style · danger 只改语义色，容器材质与 default 相同', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );

        await pumpPopconfirm(tester, theme: theme, danger: false, withIcon: true);
        final BoxDecoration plain = bubbleDecoration(tester);
        final Color plainIconColor = tester
            .widget<Icon>(find.byIcon(Icons.help_outline))
            .color!;

        await pumpPopconfirm(tester, theme: theme, danger: true, withIcon: true);
        final BoxDecoration danger = bubbleDecoration(tester);
        final Color dangerIconColor = tester
            .widget<Icon>(find.byIcon(Icons.help_outline))
            .color!;

        // ① 容器材质完全不受 danger 影响（本次改造要保证的部分）。
        expect(danger.color, equals(plain.color));
        expect(danger.borderRadius, equals(plain.borderRadius));
        expect(danger.boxShadow, equals(plain.boxShadow));
        // ② 边界的另一半：danger **确实**改了语义色（brand → error）。
        //    少了这条，上面三等式可能在"danger 压根没接线"时也全绿。
        expect(plainIconColor, equals(theme.colors.brand));
        expect(dangerIconColor, equals(theme.colors.error));
      });

      testWidgets('$style · confirmLoading 时容器材质不变', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );

        await pumpPopconfirm(tester, theme: theme, confirmLoading: false);
        final BoxDecoration plain = bubbleDecoration(tester);

        await pumpPopconfirm(tester, theme: theme, confirmLoading: true);
        final BoxDecoration loading = bubbleDecoration(tester);

        expect(loading.color, equals(plain.color));
        expect(loading.borderRadius, equals(plain.borderRadius));
      });
    }
  });

  // ==========================================================================
  // 3. 零回归：stripe / flat 的阴影与圆角
  // ==========================================================================
  group('ParkPopconfirm · stripe/flat 零回归', () {
    for (final ParkSurfaceStyle style in <ParkSurfaceStyle>[
      ParkSurfaceStyle.stripe,
      ParkSurfaceStyle.flat,
    ]) {
      testWidgets('$style · 阴影回落到组件原值（不是 shadows.lg）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopconfirm(tester, theme: theme);

        final List<BoxShadow>? shadows = bubbleDecoration(tester).boxShadow;
        expect(shadows, isNotNull);
        // 抄改造前的**字面量**：overlay 10% / blur 16 / offset (0, 8)。
        // 用字面量而非"两个实现相等"，避免两边同时漂移时静默通过。
        expect(
          shadows,
          equals(<BoxShadow>[
            BoxShadow(
              color: theme.colors.overlay.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ]),
        );
        expect(
          shadows,
          isNot(equals(theme.shadows.lg)),
          reason: '组件原本用的是自定义阴影，不是 shadows.lg',
        );
      });

      testWidgets('$style · 圆角保持组件原值 radius.lg', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopconfirm(tester, theme: theme);

        expect(
          bubbleDecoration(tester).borderRadius,
          equals(BorderRadius.circular(theme.radius.lg)),
        );
      });

      testWidgets('$style · 填充色等于 colors.surface（与改造前一致）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopconfirm(tester, theme: theme);

        expect(bubbleDecoration(tester).color, equals(theme.colors.surface));
      });
    }

    testWidgets('所有风格 · 无描边（组件无 bordered 语义）', (
      WidgetTester tester,
    ) async {
      for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );
        await pumpPopconfirm(tester, theme: theme);

        expect(
          bubbleDecoration(tester).border,
          isNull,
          reason: '$style 气泡确认框不应凭空出现描边',
        );
      }
    });
  });

  // ==========================================================================
  // 4. 材质性格：glass / neo / neon 接管阴影
  // ==========================================================================
  group('ParkPopconfirm · 非 stripe 风格接管阴影', () {
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
        await pumpPopconfirm(tester, theme: theme);

        final List<BoxShadow>? shadows = bubbleDecoration(tester).boxShadow;
        expect(
          shadows,
          isNotNull,
          reason: '$style 应自带阴影（否则风格接管无意义）',
        );
        expect(
          shadows,
          isNot(
            equals(<BoxShadow>[
              BoxShadow(
                color: theme.colors.overlay.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ]),
          ),
          reason: '$style 的阴影应与浮层兜底值不同，即风格确实接管了',
        );
      });
    }

    testWidgets('neo · 双柔光阴影（两条）', (WidgetTester tester) async {
      final ParkThemeData theme = ParkThemeData.light().copyWith(
        surfaceStyle: ParkSurfaceStyle.neo,
      );
      await pumpPopconfirm(tester, theme: theme);

      expect(bubbleDecoration(tester).boxShadow!.length, equals(2));
    });
  });

  // ==========================================================================
  // 5. 玻璃风格
  // ==========================================================================
  group('ParkPopconfirm · 玻璃风格', () {
    testWidgets('glass 渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpPopconfirm(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('stripe 不渲染 BackdropFilter', (WidgetTester tester) async {
      await pumpPopconfirm(tester, theme: ParkThemeData.light());

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 6. 局部 Scope 覆盖
  // ==========================================================================
  group('ParkPopconfirm · ParkSurfaceStyleScope 局部覆盖', () {
    testWidgets('全局 stripe + 局部 glass → 渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpPopconfirm(
        tester,
        theme: ParkThemeData.light(),
        scopeStyle: ParkSurfaceStyle.glass,
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('全局 glass + 局部 stripe → 不渲染 BackdropFilter', (
      WidgetTester tester,
    ) async {
      await pumpPopconfirm(
        tester,
        theme: ParkThemeData.light().copyWith(
          surfaceStyle: ParkSurfaceStyle.glass,
        ),
        scopeStyle: ParkSurfaceStyle.stripe,
      );

      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  // ==========================================================================
  // 7. 派生函数直测（成对取值：titleColor / bodyColor 与 fill 同源）
  // ==========================================================================
  group('ParkPopconfirm · resolveParkPopconfirmSurface 成对取值', () {
    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      for (final Brightness brightness in Brightness.values) {
        testWidgets('$style / ${brightness.name} · titleColor/bodyColor 可读', (
          WidgetTester tester,
        ) async {
          final ParkThemeData theme =
              (brightness == Brightness.dark
                      ? ParkThemeData.dark()
                      : ParkThemeData.light())
                  .copyWith(surfaceStyle: style);

          late ParkPopconfirmSurface resolved;
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                extensions: <ThemeExtension<ParkThemeData>>[theme],
              ),
              home: Builder(
                builder: (BuildContext ctx) {
                  resolved = resolveParkPopconfirmSurface(
                    park: theme,
                    context: ctx,
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

    for (final ParkSurfaceStyle style in ParkSurfaceStyle.values) {
      testWidgets('$style · 圆角恒为 radius.lg（不消费 cards 语义 brMd）', (
        WidgetTester tester,
      ) async {
        final ParkThemeData theme = ParkThemeData.light().copyWith(
          surfaceStyle: style,
        );

        late ParkPopconfirmSurface resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              extensions: <ThemeExtension<ParkThemeData>>[theme],
            ),
            home: Builder(
              builder: (BuildContext ctx) {
                resolved = resolveParkPopconfirmSurface(
                  park: theme,
                  context: ctx,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // 浮层规范第 2 条：圆角保持组件原值（lg=16），
        // 绝不消费 tokens.radius（卡片语义 brMd=12，会缩小 4px）。
        expect(
          resolved.radius,
          equals(BorderRadius.circular(theme.radius.lg)),
        );
        expect(
          resolved.radius,
          // ⚠️ radius.brMd 返回的已经是 BorderRadius（见 ParkRadius.brMd），
          // 不能再包一层 BorderRadius.circular() —— 那是把 BorderRadius 当 double 传。
          isNot(equals(theme.radius.brMd)),
        );
      });
    }
  });

  // ==========================================================================
  // 8. 公开签名零破坏
  // ==========================================================================
  group('ParkPopconfirm · 公开默认值不变', () {
    test('所有公开参数默认值锁定', () {
      const ParkPopconfirm p = ParkPopconfirm(child: Text('t'));
      expect(p.title, isNull);
      expect(p.description, isNull);
      expect(p.confirmText, '');
      expect(p.cancelText, '');
      expect(p.autoCloseAfterConfirm, isTrue);
      expect(p.danger, isFalse);
      expect(p.confirmLoading, isFalse);
    });
  });
}
